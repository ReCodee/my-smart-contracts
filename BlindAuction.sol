pragma solidity >= 0.7.0 < 0.9.0;

contract BlindAuction {

    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

address payable public beneficiary;
uint public biddingEndTime;
uint public revealEndTime;
uint public AuctionEndTime;
bool public ended = false;

mapping (address => Bid[]) public bids;

address public highestBidder;
uint public highestBid;

mapping (address => uint) public pendingReturns;

event AuctionEnded(address winner, uint higestBid);

modifier onlyBefore(uint time) {
  require(block.timestamp < time);
   _;
}

modifier onlyAfter(uint time) {
  require(block.timestamp >= time);
  _;
}

constructor(address payable _beneficiary, uint _auctionTime, uint _revealTime) {
  beneficiary = _beneficiary;
  AuctionEndTime = block.timestamp + _auctionTime;
  revealEndTime = AuctionEndTime + _revealTime;
}

function generateBlindedBidBytes32(uint value, bool fake) public view returns(bytes32) {
  return keccak256(abi.encodePacked(value, fake));
}

function bid(bytes32 _blindedBid) payable public onlyBefore(AuctionEndTime) {
   bids[msg.sender].push(Bid({
       blindedBid : _blindedBid,
       deposit : msg.value
   }));
}

function reveal(
    uint[] memory _values,
    bool[] memory _fake
   )
    public
    onlyAfter(biddingEndTime)
    onlyBefore(revealEndTime) 
   {
    uint length = bids[msg.sender].length;
    require(_values.length == length );
    require(_fake.length == length );
    for (uint i = 0 ; i < length ; i++ ) {
        Bid storage bidToCheck = bids[msg.sender][i];
        (uint value, bool fake) = (_values[i], _fake[i]);
        if ( bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake)) ) {
            continue;
        }
        if ( !fake && bidToCheck.deposit >= value ) {
            placeBid(msg.sender, bidToCheck.deposit);
        }
        bidToCheck.blindedBid = bytes32(0);
    }
   }

function auctionEnd() public {
   require(!ended);
   emit AuctionEnded(highestBidder, highestBid);
   ended = true;
   beneficiary.transfer(highestBid);
}

function withdraw() public {
  uint amount = pendingReturns[msg.sender];
  if ( amount > 0 ) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
  }
}

function placeBid(address bidder, uint value) internal returns(bool) {
    if ( value <= highestBid ) {
        return false;
    }

    if ( highestBidder != address(0) ) {
        pendingReturns[highestBidder] += highestBid;       
    }
    highestBid = value;
    highestBidder = bidder;
    return true;
 }
}