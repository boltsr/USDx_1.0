pragma solidity ^0.5.2;

import '../token/interfaces/IDSToken.sol';
import '../token/interfaces/IDSWrappedToken.sol';
import '../storage/interfaces/IDFStore.sol';
import '../storage/interfaces/IDFPool.sol';
import '../storage/interfaces/IDFCollateral.sol';
import '../storage/interfaces/IDFFunds.sol';
import '../oracle/interfaces/IMedianizer.sol';
import '../utility/DSAuth.sol';
import "../utility/DSMath.sol";

contract DFEngine is DSMath, DSAuth {
    IDFStore public dfStore;
    IDFPool public dfPool;
    IDFCollateral public dfCol;
    IDFFunds public dfFunds;
    IDSToken public usdxToken;
    IDSToken public dfToken;

    enum ProcessType {
        CT_DEPOSIT,
        CT_DESTROY,
        CT_CLAIM,
        CT_WITHDRAW
    }

    enum TokenType {
        TT_DF,
        TT_USDX
    }

    constructor (
        address _usdxToken,
        address _dfStore,
        address _dfPool,
        address _dfCol,
        address _dfFunds)
        public
    {
        usdxToken = IDSToken(_usdxToken);
        dfStore = IDFStore(_dfStore);
        dfPool = IDFPool(_dfPool);
        dfCol = IDFCollateral(_dfCol);
        dfFunds = IDFFunds(_dfFunds);
    }

    function getPrice(address oracle) public view returns (uint) {
        bytes32 price = IMedianizer(oracle).read();
        return uint(price);
    }

    function _unifiedCommission(ProcessType ct, uint _feeTokenIdx, address depositor, uint _amount) internal {
        uint rate = dfStore.getFeeRate(uint(ct));
        if(rate > 0) {
            address _token = dfStore.getTypeToken(_feeTokenIdx);
            require(_token != address(0), "_UnifiedCommission: fee token not correct.");
            uint dfPrice = getPrice(dfStore.getTokenMedian(_token));
            uint dfFee = div(mul(mul(_amount, rate), WAD), mul(10000, dfPrice));
            IDSToken(_token).transferFrom(depositor, address(dfFunds), dfFee);
        }
    }

    function deposit(address _depositor, address _srcToken, uint _feeTokenIdx, uint _srcAmount) public auth returns (uint) {
        require(_srcAmount > 0, "Deposit: amount not allow.");
        address _tokenID = dfStore.getWrappedToken(_srcToken);
        require(dfStore.getMintingToken(_tokenID), "Deposit: asset not allow.");

        dfPool.transferFromSender(_srcToken, _depositor, _srcAmount);
        uint _amount = IDSWrappedToken(_tokenID).wrap(address(dfPool), _srcAmount);
        _unifiedCommission(ProcessType.CT_DEPOSIT, _feeTokenIdx, _depositor, _amount);

        address[] memory _tokens;
        uint[] memory _mintCW;
        (, , , _tokens, _mintCW) = dfStore.getSectionData(dfStore.getMintPosition());

        uint[] memory _tokenBalance = new uint[](_tokens.length);
        uint[] memory _resUSDXBalance = new uint[](_tokens.length);
        uint[] memory _depositorBalance = new uint[](_tokens.length);
        // uint _depositorMintAmount;
        // uint _depositorMintTotal;
        //For stack limit sake.
        uint _misc = uint(-1);

        for (uint i = 0; i < _tokens.length; i++) {
            _tokenBalance[i] = dfStore.getTokenBalance(_tokens[i]);
            _resUSDXBalance[i] = dfStore.getResUSDXBalance(_tokens[i]);
            _depositorBalance[i] = dfStore.getDepositorBalance(_depositor, _tokens[i]);
            if (_tokenID == _tokens[i]){
                _tokenBalance[i] = add(_tokenBalance[i], _amount);
                _depositorBalance[i] = add(_depositorBalance[i], _amount);
                // _index = i;
            }
            _misc = min(div(_tokenBalance[i], _mintCW[i]), _misc);
        }
        if (_misc > 0) {
            return _convert(_depositor, _tokens, _mintCW, _tokenBalance, _resUSDXBalance, _depositorBalance, _misc);
        }
            /** Just retrieve minting tokens here. If minted balance has USDX, call claim.*/
        for (uint i = 0; i < _tokens.length; i++) {
            _tokenBalance[0] = min(_depositorBalance[i], _resUSDXBalance[i]);

            if (_tokenBalance[0] == 0) {
                if (_tokenID == _tokens[i]) {
                    dfStore.setDepositorBalance(_depositor, _tokens[i], _depositorBalance[i]);
                }
                continue;
            }

            dfStore.setDepositorBalance(_depositor, _tokens[i], sub(_depositorBalance[i], _tokenBalance[0]));
            dfStore.setResUSDXBalance(_tokens[i], sub(_resUSDXBalance[i], _tokenBalance[0]));
            _tokenBalance[1] = add(_tokenBalance[1], _tokenBalance[0]);
        }

        if (_tokenBalance[1] > 0)
            dfPool.transferOut(address(usdxToken), _depositor, _tokenBalance[1]);

        _misc = add(_amount, dfStore.getTokenBalance(_tokenID));
        dfStore.setTokenBalance(_tokenID, _misc);

        return (_tokenBalance[1]);
    }

    function withdraw(address _depositor, address _srcToken, uint _feeTokenIdx, uint _srcAmount) public auth returns (uint) {
        require(_srcAmount > 0, "Withdraw: not enough balance.");

        address _tokenID = dfStore.getWrappedToken(_srcToken);
        uint _amount = IDSWrappedToken(_tokenID).changeByMultiple(_srcAmount);

        uint _depositorBalance = dfStore.getDepositorBalance(_depositor, _tokenID);
        uint _tokenBalance = dfStore.getTokenBalance(_tokenID);
        uint _withdrawAmount = min(_amount, min(_tokenBalance, _depositorBalance));

        if (_withdrawAmount <= 0)
            return (0);

        _depositorBalance = sub(_depositorBalance, _withdrawAmount);
        dfStore.setDepositorBalance(_depositor, _tokenID, _depositorBalance);
        dfStore.setTokenBalance(_tokenID, sub(_tokenBalance, _withdrawAmount));
        _unifiedCommission(ProcessType.CT_WITHDRAW, _feeTokenIdx, _depositor, _withdrawAmount);
        IDSWrappedToken(_tokenID).unwrap(address(dfPool), _withdrawAmount);
        uint _srcWithdrawAmount = IDSWrappedToken(_tokenID).reverseByMultiple(_withdrawAmount);
        dfPool.transferOut(_srcToken, _depositor, _srcWithdrawAmount);

        return (_srcWithdrawAmount);
    }

    function claim(address _depositor, uint _feeTokenIdx) public auth returns (uint) {
        address[] memory _tokens = dfStore.getMintedTokenList();
        uint _resUSDXBalance;
        uint _depositorBalance;
        uint _depositorMintAmount;
        uint _mintAmount;

        for (uint i = 0; i < _tokens.length; i++) {
            _resUSDXBalance = dfStore.getResUSDXBalance(_tokens[i]);
            _depositorBalance = dfStore.getDepositorBalance(_depositor, _tokens[i]);

            _depositorMintAmount = min(_resUSDXBalance, _depositorBalance);
            _mintAmount = add(_mintAmount, _depositorMintAmount);

            if (_depositorMintAmount > 0){
                dfStore.setResUSDXBalance(_tokens[i], sub(_resUSDXBalance, _depositorMintAmount));
                dfStore.setDepositorBalance(_depositor, _tokens[i], sub(_depositorBalance, _depositorMintAmount));
            }
        }

        if (_mintAmount <= 0)
            return 0;

        _unifiedCommission(ProcessType.CT_CLAIM, _feeTokenIdx, _depositor, _mintAmount);
        dfPool.transferOut(address(usdxToken), _depositor, _mintAmount);
        return _mintAmount;
    }

    function destroy(address _depositor, uint _feeTokenIdx, uint _amount) public auth returns (bool) {
        require(_amount > dfStore.getMinBurnAmount(), "Destroy: amount not correct.");
        require(_amount <= usdxToken.balanceOf(_depositor), "Destroy: exceed max USDX balance.");
        require(_amount <= sub(dfStore.getTotalMinted(), dfStore.getTotalBurned()), "Destroy: not enough to burn.");
        address[] memory _tokens;
        uint[] memory _burnCW;
        // uint _burnPosition;
        uint _sumBurnCW;
        uint _burned;
        uint _minted;
        uint _burnedAmount;
        uint _amountTemp = _amount;
        uint _tokenAmount;
        // uint _srcTokenAmount; 

        _unifiedCommission(ProcessType.CT_DESTROY, _feeTokenIdx, _depositor, _amount);

        while(_amountTemp > 0) {

            // _burnPosition = dfStore.getBurnPosition();
            (_minted, _burned, , _tokens, _burnCW) = dfStore.getSectionData(dfStore.getBurnPosition());

            _sumBurnCW = 0;
            for (uint i = 0; i < _burnCW.length; i++) {
                _sumBurnCW = add(_sumBurnCW, _burnCW[i]);
            }

            if (add(_burned, _amountTemp) <= _minted){
                dfStore.setSectionBurned(add(_burned, _amountTemp));
                _burnedAmount = _amountTemp;
                _amountTemp = 0;
            } else {
                _burnedAmount = sub(_minted, _burned);
                _amountTemp = sub(_amountTemp, _burnedAmount);
                dfStore.setSectionBurned(_minted);
                dfStore.burnSectionMoveon();
            }

            for (uint i = 0; i < _tokens.length; i++) {

                _tokenAmount = div(mul(_burnedAmount, _burnCW[i]), _sumBurnCW);
                IDSWrappedToken(_tokens[i]).unwrap(address(dfCol), _tokenAmount);
                // _srcTokenAmount = IDSWrappedToken(_tokens[i]).reverseByMultiple(_tokenAmount);
                dfPool.transferOut(IDSWrappedToken(_tokens[i]).getSrcERC20(), _depositor, IDSWrappedToken(_tokens[i]).reverseByMultiple(_tokenAmount));
                // dfCol.transferOut(_tokens[i], dfPool, div(mul(_burnedAmount, _burnCW[i]), _sumBurnCW));
            }
        }

        usdxToken.burn(_depositor, _amount);
        dfStore.setTotalCol(sub(dfStore.getTotalCol(), _amount));
        checkUSDXTotalAndColTotal();
        dfStore.addTotalBurned(_amount);

        return true;
    }

    function _convert(
        address _depositor,
        address[] memory _tokens,
        uint[] memory _mintCW,
        uint[] memory _tokenBalance,
        uint[] memory _resUSDXBalance,
        uint[] memory _depositorBalance,
        uint _step)
        internal
        returns(uint)
    {
        uint _mintAmount;
        uint _mintTotal;
        uint _depositorMintAmount;
        uint _depositorMintTotal;

        for (uint i = 0; i < _tokens.length; i++) {
            _mintAmount = mul(_step, _mintCW[i]);
            _depositorMintAmount = min(_depositorBalance[i], add(_resUSDXBalance[i], _mintAmount));
            dfStore.setTokenBalance(_tokens[i], sub(_tokenBalance[i], _mintAmount));
            dfPool.transferToCol(_tokens[i], _mintAmount);
            _mintTotal = add(_mintTotal, _mintAmount);

            if (_depositorMintAmount == 0){
                dfStore.setResUSDXBalance(_tokens[i], add(_resUSDXBalance[i], _mintAmount));
                continue;
            }

            dfStore.setDepositorBalance(_depositor, _tokens[i], sub(_depositorBalance[i], _depositorMintAmount));
            dfStore.setResUSDXBalance(_tokens[i], sub(add(_resUSDXBalance[i], _mintAmount), _depositorMintAmount));
            _depositorMintTotal = add(_depositorMintTotal, _depositorMintAmount);
        }

        dfStore.addTotalMinted(_mintTotal);
        dfStore.addSectionMinted(_mintTotal);
        usdxToken.mint(address(dfPool), _mintTotal);
        dfStore.setTotalCol(add(dfStore.getTotalCol(), _mintTotal));
        checkUSDXTotalAndColTotal();
        dfPool.transferOut(address(usdxToken), _depositor, _depositorMintTotal);
        return _depositorMintTotal;
    }

    function checkUSDXTotalAndColTotal() internal view {
        address[] memory _tokens = dfStore.getMintedTokenList();
        address _dfCol = address(dfCol);
        uint _colTotal;
        for (uint i = 0; i < _tokens.length; i++) {
            _colTotal = add(_colTotal, IDSToken(_tokens[i]).balanceOf(_dfCol));
        }
        uint _usdxTotalSupply = usdxToken.totalSupply();
        require(_usdxTotalSupply <= _colTotal,
                "checkUSDXTotalAndColTotal : Amount of the usdx will be greater than collateral.");
        require(_usdxTotalSupply == dfStore.getTotalCol(),
                "checkUSDXTotalAndColTotal : Usdx and total collateral are not equal.");
    }

    function getDepositMaxMint(address _depositor, address _tokenID, uint _amount) public view returns (uint) {
        require(dfStore.getMintingToken(_tokenID), "CalcDepositorMintTotal: asset not allow.");

        uint _mintAmount;
        uint _depositorMintAmount;
        uint _depositorMintTotal;
        uint _step = uint(-1);
        address[] memory _tokens;
        uint[] memory _mintCW;
        (, , , _tokens, _mintCW) = dfStore.getSectionData(dfStore.getMintPosition());

        uint[] memory _tokenBalance = new uint[](_tokens.length);
        uint[] memory _depositorBalance = new uint[](_tokens.length);
        uint[] memory _resUSDXBalance = new uint[](_tokens.length);

        for (uint i = 0; i < _tokens.length; i++) {
            _tokenBalance[i] = dfStore.getTokenBalance(_tokens[i]);
            _resUSDXBalance[i] = dfStore.getResUSDXBalance(_tokens[i]);
            _depositorBalance[i] = dfStore.getDepositorBalance(_depositor, _tokens[i]);
            if (_tokenID == _tokens[i]){
                _tokenBalance[i] = add(_tokenBalance[i], _amount);
                _depositorBalance[i] = add(_depositorBalance[i], _amount);
            }
            _step = min(div(_tokenBalance[i], _mintCW[i]), _step);
        }

        for (uint i = 0; i < _tokens.length; i++) {
            _mintAmount = mul(_step, _mintCW[i]);
            _depositorMintAmount = min(_depositorBalance[i], add(_resUSDXBalance[i], _mintAmount));
            _depositorMintTotal = add(_depositorMintTotal, _depositorMintAmount);
        }

        return _depositorMintTotal;
    }

    function getMaxToClaim(address _depositor) public view returns (uint) {
        uint _resUSDXBalance;
        uint _depositorBalance;
        uint _depositorClaimAmount;
        uint _claimAmount;
        address[] memory _tokens = dfStore.getMintedTokenList();

        for (uint i = 0; i < _tokens.length; i++) {
            _resUSDXBalance = dfStore.getResUSDXBalance(_tokens[i]);
            _depositorBalance = dfStore.getDepositorBalance(_depositor, _tokens[i]);

            _depositorClaimAmount = min(_resUSDXBalance, _depositorBalance);
            _claimAmount = add(_claimAmount, _depositorClaimAmount);
        }

        return _claimAmount;
    }

    function getCollateralMaxClaim() public view returns (address[] memory, uint[] memory) {
        address[] memory _tokens = dfStore.getMintedTokenList();
        uint[] memory _balance = new uint[](_tokens.length);

        for (uint i = 0; i < _tokens.length; i++) {
            _balance[i] = dfStore.getResUSDXBalance(_tokens[i]);
        }

        return (_tokens, _balance);
    }

    function getMintingSection() public view returns(address[] memory, uint[] memory) {
        uint position = dfStore.getMintPosition();
        uint[] memory weight = dfStore.getSectionWeight(position);
        address[] memory tokens = dfStore.getSectionToken(position);

        return (tokens, weight);
    }

    function getBurningSection() public view returns(address[] memory, uint[] memory) {
        uint position = dfStore.getBurnPosition();
        uint[] memory weight = dfStore.getSectionWeight(position);
        address[] memory tokens = dfStore.getSectionToken(position);

        return (tokens, weight);
    }

    function getWithdrawBalances(address _depositor) public view returns(address[] memory, uint[] memory) {
        address[] memory tokens = dfStore.getMintedTokenList();
        uint[] memory weight = new uint[](tokens.length);

        for (uint i = 0; i < tokens.length; i++) {
            weight[i] = calcWithdrawAmount(_depositor, tokens[i]);
        }

        return (tokens, weight);
    }

    function getPrices(uint _tokenIdx) public view returns (uint) {
        address _token = dfStore.getTypeToken(_tokenIdx);
        require(_token != address(0), "_UnifiedCommission: fee token not correct.");
        uint dfPrice = getPrice(dfStore.getTokenMedian(_token));

        return dfPrice;
    }

    function getFeeRateByID(uint _processIdx) public view returns (uint) {
        return dfStore.getFeeRate(_processIdx);
    }

    function getDestroyThreshold() public view returns (uint) {
        return dfStore.getMinBurnAmount();
    }

    function calcWithdrawAmount(address _depositor, address _tokenID) internal view returns (uint) {
        uint _depositorBalance = dfStore.getDepositorBalance(_depositor, _tokenID);
        uint _tokenBalance = dfStore.getTokenBalance(_tokenID);
        uint _withdrawAmount = min(_tokenBalance, _depositorBalance);

        return _withdrawAmount;
    }

    function oneClickMinting(address _depositor, uint _feeTokenIdx, uint _amount) public auth {
        address[] memory _tokens;
        uint[] memory _mintCW;
        uint _sumMintCW;

        (_tokens, _mintCW) = getMintingSection();
        for (uint i = 0; i < _mintCW.length; i++) {
            _sumMintCW = add(_sumMintCW, _mintCW[i]);
        }
        require(_amount % _sumMintCW == 0, "OneClickMinting: amount error");

        _unifiedCommission(ProcessType.CT_DEPOSIT, _feeTokenIdx, _depositor, _amount);

        for (uint i = 0; i < _mintCW.length; i++) {
            require(dfPool.transferFromSenderToCol(_tokens[i], _depositor, div(mul(_amount, _mintCW[i]), _sumMintCW)),
                    "ERC20 TransferFrom: not enough amount");
        }

        dfStore.addTotalMinted(_amount);
        dfStore.addSectionMinted(_amount);
        usdxToken.mint(_depositor, _amount);

        dfStore.setTotalCol(add(dfStore.getTotalCol(), _amount));
        checkUSDXTotalAndColTotal();
    }
}
