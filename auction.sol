pragma solidity >= 0.7.0 < 0.9.0;

contract AuctionContract {
    address payable public beneficiary;
    uint public auctionEndTime;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturnsBook;

    bool ended = false;

    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        if ( auctionEndTime <= block.timestamp ) {
            revert("Auction Has Already Ended");
        }

        if ( msg.value <= highestBid ) {
            revert("Your Bid is not the highest one, Highest Bid right now is : &{highestBid}");
        }
        if ( highestBid != 0 )
        pendingReturnsBook[highestBidder] = highestBid;  
         
         highestBid = msg.value;
         highestBidder = msg.sender;
         emit HighestBidIncrease(highestBidder, highestBid);
    }

    function withdraw() public returns(bool) {
         uint amount = pendingReturnsBook[msg.sender];
         if ( amount > 0 ) {
             pendingReturnsBook[msg.sender] = 0;
             if ( !(payable(msg.sender).send(amount)) ) {
                 pendingReturnsBook[msg.sender] = amount;
                 return false;
             }
         }
         return true;
    }

    function endAuction() public {
      if ( ended ) {
          revert("The Auction has already ended");
      }
      
      if ( auctionEndTime > block.timestamp ) {
          revert("The Auction has not ended yet");
      }

        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
        ended = true;
    }
}