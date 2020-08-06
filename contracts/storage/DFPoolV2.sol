pragma solidity ^0.5.2;

import "../token/ERC20SafeTransfer.sol";
import "../utility/DSMath.sol";
import "../utility/DSAuth.sol";
import "../utility/Utils.sol";
import "./interfaces/IDToken.sol";
import "./interfaces/IDTokenController.sol";
import "../token/interfaces/IDSWrappedToken.sol";

contract DFPoolV1 is DSMath, DSAuth, Utils, ERC20SafeTransfer {
    address dfcol;

    constructor(address _dfcol) public {
        dfcol = _dfcol;
    }

    function transferFromSender(
        address _tokenID,
        address _from,
        uint256 _amount
    ) public auth returns (bool) {
        uint256 _balance = IERC20(_tokenID).balanceOf(address(this));
        require(
            doTransferFrom(_tokenID, _from, address(this), _amount),
            "transferFromSender: failed"
        );
        assert(
            sub(IERC20(_tokenID).balanceOf(address(this)), _balance) == _amount
        );
        return true;
    }

    function transferOut(
        address _tokenID,
        address _to,
        uint256 _amount
    ) public validAddress(_to) auth returns (bool) {
        uint256 _balance = IERC20(_tokenID).balanceOf(_to);
        require(doTransferOut(_tokenID, _to, _amount), "transferOut: failed");
        assert(sub(IERC20(_tokenID).balanceOf(_to), _balance) == _amount);
        return true;
    }

    function transferToCol(address _tokenID, uint256 _amount)
        public
        auth
        returns (bool)
    {
        require(
            dfcol != address(0),
            "TransferToCol: collateral address empty."
        );
        uint256 _balance = IERC20(_tokenID).balanceOf(dfcol);
        require(
            doTransferOut(_tokenID, dfcol, _amount),
            "transferToCol: failed"
        );
        assert(sub(IERC20(_tokenID).balanceOf(dfcol), _balance) == _amount);
        return true;
    }

    function transferFromSenderToCol(
        address _tokenID,
        address _from,
        uint256 _amount
    ) public auth returns (bool) {
        require(
            dfcol != address(0),
            "TransferFromSenderToCol: collateral address empty."
        );
        uint256 _balance = IERC20(_tokenID).balanceOf(dfcol);
        require(
            doTransferFrom(_tokenID, _from, dfcol, _amount),
            "transferFromSenderToCol: failed"
        );
        assert(sub(IERC20(_tokenID).balanceOf(dfcol), _balance) == _amount);
        return true;
    }

    function approveToEngine(address _tokenIdx, address _engineAddress)
        public
        auth
    {
        require(
            doApprove(_tokenIdx, _engineAddress, uint256(-1)),
            "approveToEngine: Approve failed!"
        );
    }
}

contract DFPoolV2 is ERC20SafeTransfer, DFPoolV1(address(0)) {
    bool private initialized;
    address dFPoolOld;
    address dTokenController;

    constructor(
        address _dfcol,
        address _dFPoolOld,
        address _dTokenController
    ) public {
        initialize(_dfcol, _dFPoolOld, _dTokenController);
    }

    // --- Init ---
    function initialize(
        address _dfcol,
        address _dFPoolOld,
        address _dTokenController
    ) public {
        require(!initialized, "initialize: Already initialized!");
        owner = msg.sender;
        dfcol = _dfcol;
        dFPoolOld = _dFPoolOld;
        dTokenController = _dTokenController;
        initialized = true;
    }

    function transferFromSenderOneClick(
        address _tokenID,
        address _from,
        uint256 _amount
    ) public returns (bool) {
        super.transferFromSender(_tokenID, _from, _amount);
        IDToken(IDTokenController(dTokenController).getDToken(_tokenID)).mint(
            address(this),
            _amount
        );
        return true;
    }

    function transferOutSrc(
        address _tokenID,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        IDToken(IDTokenController(dTokenController).getDToken(_tokenID))
            .redeemUnderlying(address(this), _amount);
        transferOut(_tokenID, _to, _amount);
        return true;
    }

    function transferToCol(address _tokenID, uint256 _amount)
        public
        returns (bool)
    {
        super.transferToCol(_tokenID, _amount);
        address _srcToken = IDSWrappedToken(_tokenID).getSrcERC20();
        IDToken(IDTokenController(dTokenController).getDToken(_srcToken)).mint(
            address(this),
            IDSWrappedToken(_tokenID).reverseByMultiple(_amount)
        );
        return true;
    }

    function migrateOldPool(address[] calldata _tokens, address _usdx)
        external
        auth
    {
        address _dFPoolOld = dFPoolOld;
        address _dfcol = dfcol;
        address _dTokenController = dTokenController;
        address _srcToken;
        uint256 _balance;
        for (uint256 i = 0; i < _tokens.length; i++) {
            // transfer pending wrapped token to new pool
            _balance = IERC20(_tokens[i]).balanceOf(_dFPoolOld);
            if (_balance > 0)
                DFPoolV1(_dFPoolOld).transferOut(
                    _tokens[i],
                    address(this),
                    _balance
                );

            // transfer all src token to new pool
            _srcToken = IDSWrappedToken(_tokens[i]).getSrcERC20();
            _balance = IERC20(_srcToken).balanceOf(_dFPoolOld);
            if (_balance > 0)
                DFPoolV1(_dFPoolOld).transferOut(
                    _srcToken,
                    address(this),
                    _balance
                );

            // mint collateral token into dToken
            _balance = IERC20(_tokens[i]).balanceOf(_dfcol);
            if (_balance > 0)
                IDToken(
                    IDTokenController(_dTokenController).getDToken(_srcToken)
                )
                    .mint(
                    address(this),
                    IDSWrappedToken(_tokens[i]).reverseByMultiple(_balance)
                );
        }

        // transfer claimable USDx to new pool
        _balance = IERC20(_usdx).balanceOf(_dFPoolOld);
        if (_balance > 0)
            DFPoolV1(_dFPoolOld).transferOut(_usdx, address(this), _balance);
    }

    function approve(address _tokenID) external auth {
        address _dToken = IDTokenController(dTokenController).getDToken(
            _tokenID
        );
        require(_dToken != address(0), "approve: dToekn address empty.");
        require(
            doApprove(_tokenID, _dToken, uint256(-1)),
            "approve: Approve failed!"
        );
    }
}
