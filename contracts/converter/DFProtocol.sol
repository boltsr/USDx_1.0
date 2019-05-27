pragma solidity ^0.5.2;

import '../update/DFUpgrader.sol';

contract DFProtocol is DFUpgrader {

    event Deposit (address indexed _tokenID, address indexed _sender, uint _amount, uint _balance);
    event Withdraw(address indexed _tokenID, address indexed _sender, uint _amount, uint _balance);
    event Destroy (address indexed _sender, uint _amount);
    event Claim   (address indexed _sender, uint _balance);

    function deposit(address _tokenID, uint _amount) public returns (uint){
        uint _balance = iDFEngine.deposit(msg.sender, _tokenID, _amount);
        emit Deposit(_tokenID, msg.sender, _amount, _balance);
        return _balance;
    }

    function withdraw(address _tokenID, uint _amount) public returns (uint) {
        uint _balance = iDFEngine.withdraw(msg.sender, _tokenID, _amount);
        emit Withdraw(_tokenID, msg.sender, _amount, _balance);
        return _balance;
    }

    function destroy(uint _amount) public {
        iDFEngine.destroy(msg.sender, _amount);
        emit Destroy(msg.sender, _amount);
    }

    function claim() public returns (uint) {
        uint _balance = iDFEngine.claim(msg.sender);
        emit Claim(msg.sender, _balance);
        return _balance;
    }
}