pragma solidity ^0.5.0;

library SafeMath {
    function mul(uint a, uint b) internal pure returns(uint c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the      
        // benefit is lost if 'b' is also tested.      
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522      
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns(uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0      
        // uint256 c = a / b;      
        // assert(a == b * c + a % b); 
        // There is no case in which this doesn't hold      return a / b;   
    }

    function sub(uint a, uint b) internal pure returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns(uint c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}