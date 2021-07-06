pragma solidity ^0.5.0;

import "./Token.sol";

contract ICOToken is Token{

	string public name = 'ASH Token';
	string public tkr = 'ASH';
	uint public decimals = 18;
	address payable owner;
	address public crowdsaleAddress;
	uint public icoEndTime;

	modifier onlyCrowdSale{
		require(msg.sender == crowdsaleAddress);
		_;
	}

	modifier onlyOwner{
		require(msg.sender == owner);
		_;
	}

	modifier afterCrowdsale {
	    require(now > icoEndTime || msg.sender == crowdsaleAddress);
	    _;
    }

	constructor(uint _icoEndTime) public {
		require(_icoEndTime > 0);
		totalSupply_ = 1000000;
		owner = msg.sender;
		icoEndTime = _icoEndTime;
	}

//which will be used to set the value of the crowdsaleAddress variable.
	function setCrowdsale(address _crowdsaleAddress) public onlyOwner{
		require(_crowdsaleAddress != address(0));
		crowdsaleAddress = _crowdsaleAddress;
	}

//function which will be used to send tokens to people that participate in the ICO. This function is only executable by the Crowdsale contract, that’s why we need the address of it.
	function buyTokens(address _receiver, uint _amount) public onlyCrowdSale{
		require(_receiver != address(0));
		require(_amount > 0);
		transfer(_receiver, _amount);
	}

	function transfer(address _to, uint _value) public afterCrowdsale returns(bool) {
    return super.transfer(_to, _value);
}

	/// @notice Override the functions to not allow token transfers until the end of the ICO   
	function transferFrom(address _from, address _to, uint _value) public afterCrowdsale returns(bool) {
	    return super.transferFrom(_from, _to, _value);
	}

	/// @notice Override the functions to not allow token transfers until the end of the ICO   
	function approve(address _spender, uint _value) public afterCrowdsale returns(bool) {
	    return super.approve(_spender, _value);
	}

	/// @notice Override the functions to not allow token transfers until the end of the ICO   
	function increaseApproval(address _spender, uint _addedValue) public afterCrowdsale returns(bool success) {
	    return super.increaseApproval(_spender, _addedValue);
	}

	/// @notice Override the functions to not allow token transfers until the end of the ICO   
	function decreaseApproval(address _spender, uint _subtractedValue) public afterCrowdsale returns(bool success) {
	    return super.decreaseApproval(_spender, _subtractedValue);
	}

    function emergencyExtract() external onlyOwner {
        owner.transfer(address(this).balance);
    }

}