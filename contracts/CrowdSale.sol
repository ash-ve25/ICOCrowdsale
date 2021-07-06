pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./ICOToken.sol";

contract Crowdsale {   
   using SafeMath for uint;
   bool icoCompleted;
   uint public icoStartTime;
   uint public icoEndTime;
   uint public tokenRate;
   address public tokenAddress;
   uint public fundingGoal;
   address payable owner;
   ICOToken public token;   
   uint public tokensRaised;
   uint public etherRaised;

   uint public rateOne = 5000;
   uint public rateTwo = 4000;
   uint public rateThree = 3000;
   uint public rateFour = 2000;

   uint public limitTierOne = 25000000 + (10 ** token.decimals());
   uint public limitTierTwo = 50000000 + (10 ** token.decimals());
   uint public limitTierThree = 75000000 + (10 ** token.decimals());
   uint public limitTierFour = 100000000 + (10 ** token.decimals());

   modifier whenIcoCompleted {      
      require(icoCompleted);
      _;
   }

   modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

   constructor(uint _icoStartTime, uint _icoEndTime, uint _tokenRate, address _tokenAddress, uint _fundingGoal) public {
      require(_icoStartTime != 0 && _icoEndTime != 0 &&
            _icoStartTime < _icoEndTime && _tokenRate != 0 &&
            _tokenAddress != address(0) && _fundingGoal != 0);
      icoStartTime = _icoStartTime;
      icoEndTime = _icoEndTime;
      tokenRate = _tokenRate;
      tokenAddress = _tokenAddress;
      fundingGoal = _fundingGoal;
      token = ICOToken(_tokenAddress);
      owner = msg.sender;
      buy();   
   }

   function buy() public payable {  
      require(tokensRaised < fundingGoal);
      require(now < icoEndTime && now > icoStartTime); 

      uint tokensToBuy;
      uint etherUsed = msg.value;

   // If the tokens raised are less than 25 million with decimals, apply the first rate
      if(tokensRaised < limitTierOne){
         //Tier 1
         tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateOne;

         // If the amount of tokens that you want to buy gets out of this tier
         if(tokensRaised + tokensToBuy > limitTierOne){
            tokensToBuy = calculateExcessTokens(etherUsed, limitTierOne, 1, rateOne);
         }
      }else if(tokensRaised >= limitTierOne && tokensRaised < limitTierTwo){
       //Tier 2
         tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateTwo;  

         // If the amount of tokens that you want to buy gets out of this tier
         if(tokensRaised + tokensToBuy > limitTierTwo){
            tokensToBuy = calculateExcessTokens(etherUsed, limitTierTwo, 2, rateTwo);
         }
      }else if(tokensRaised >=limitTierTwo && tokensRaised < limitTierThree){
         //Tier 3
         tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateThree;  

        // If the amount of tokens that you want to buy gets out of this tier
         if(tokensRaised + tokensToBuy > limitTierThree) {
            tokensToBuy = calculateExcessTokens(etherUsed, limitTierThree, 3, rateThree);
         }
      }else if(tokensRaised >= limitTierThree) {
        // Tier 4
         tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateFour;
      }
      

      // Check if we have reached and exceeded the funding goal to refund the exceeding tokens and ether
      if(tokensRaised + tokensToBuy > fundingGoal) {
         uint exceedingTokens = tokensRaised + tokensToBuy - fundingGoal;

         uint exceedingEther;         

         // Convert the exceedingTokens to ether and refund that ether         
         exceedingEther = exceedingTokens * 1 ether / tokenRate / token.decimals();

         msg.sender.transfer(exceedingEther);

         // Change the tokens to buy to the new number         
         tokensToBuy -= exceedingTokens;         

         // Update the counter of ether used         
         etherUsed -= exceedingEther;
      }

      // Send the tokens to the buyer
      token.buyTokens(msg.sender, tokensToBuy);

      // Increase the tokens raised and ether raised state variables
      tokensRaised += tokensToBuy;      
      etherRaised += etherUsed;
   }

//global transfer function to transfer the balance of the contract to the owner of it.
   function extractEther() public whenIcoCompleted onlyOwner {   
      owner.transfer(address(this).balance);
   }


   function calculateExcessTokens(
   uint amount,
   uint tokensThisTier,
   uint tierSelected,
   uint _rate
) public returns(uint totalTokens) {
   require(amount > 0 && tokensThisTier > 0 && _rate > 0);
   require(tierSelected >= 1 && tierSelected <= 4);   uint weiThisTier = tokensThisTier.sub(tokensRaised).div(_rate);
   uint weiNextTier = amount.sub(weiThisTier);
   uint tokensNextTier = 0;
   bool returnTokens = false;   // If there are excessive weis for the last tier, refund those
   if(tierSelected != 4)
      tokensNextTier = calculateTokensTier(weiNextTier, tierSelected.add(1));
   else
      returnTokens = true;   totalTokens = tokensThisTier.sub(tokensRaised).add(tokensNextTier);   // Do the transfer at the end
   if(returnTokens) msg.sender.transfer(weiNextTier);
}function calculateTokensTier(uint weiPaid, uint tierSelected)
   internal view returns(uint calculatedTokens)
{
   require(weiPaid > 0);
   require(tierSelected >= 1 && tierSelected <= 4);if(tierSelected == 1)
      calculatedTokens = weiPaid * (10 ** token.decimals()) / 1 ether * rateOne;
   else if(tierSelected == 2)
      calculatedTokens = weiPaid * (10 ** token.decimals()) / 1 ether * rateTwo;
   else if(tierSelected == 3)
      calculatedTokens = weiPaid * (10 ** token.decimals()) / 1 ether * rateThree;
   else
      calculatedTokens = weiPaid * (10 ** token.decimals()) / 1 ether * rateFour;
}
}