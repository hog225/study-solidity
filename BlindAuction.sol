// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.4.23 <0.7.0;

contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    enum Phase {Init, Bidding, Reveal, Done}
    Phase public state = Phase.Init;


    address payable public beneficiary; // contract 배포자가 수혜자다 

    mapping(address => Bid) public bids;

    address public highestBidder;
    uint public highestBid = 0;
    bytes32 public bidAmount;

    mapping(address => uint) depositReturns;

    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase, "invalid phase ");
        _;
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "only beneficiary ... ");
        _;
    }

    constructor() public {
        beneficiary = msg.sender;
        state = Phase.Bidding;
    }

    function changeState(Phase x) public onlyBeneficiary {
        if (x < state) revert();
        state = x;
    }

    function bid(bytes32 _blindedBid) public payable validPhase(Phase.Bidding) {
        bids[msg.sender] = Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        });
    }

    // 이건 테스트 용 절대 배포 되서는 안된다. 
    function showBlindedBid(uint num) public {
        bytes32 secret = 0x4265260000000000000000000000000000000000000000000000000000000000;
        bidAmount = keccak256(abi.encodePacked(num, secret));
    }

    /// Reveal your blinded bids. You will get a refund for all
    /// correctly blinded invalid bids and for all bids except for
    /// the totally highest.
    function reveal(
        uint value,
        bytes32 secret
    ) public validPhase(Phase.Reveal) {
        uint refund;
        
        Bid storage bidToCheck = bids[msg.sender];
        if (bidToCheck.blindedBid == keccak256(abi.encodePacked(value, secret))) {
            refund += bidToCheck.deposit;
            if (bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }
        }
        
        msg.sender.transfer(refund);
    }

    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(address bidder, uint value) internal
            returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            depositReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public {
        uint amount = depositReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            depositReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd()
        public
        validPhase(Phase.Done)
    {
        beneficiary.transfer(highestBid);
    }
}
