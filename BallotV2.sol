pragma solidity >=0.4.22 <0.9.0;

//SPDX-License-Identifier: UNLICENSED

contract Ballot {
    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }

    struct Proposal {
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;

    enum Phase {Init, Regs, Vote, Done}
    Phase public state = Phase.Init;

    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase, "invalid Phase");
        _;
    }

    modifier onlyChair() {
        require(msg.sender == chairperson, "not chair person");
        _;
    }

    constructor (uint numProposals) payable{
        chairperson = payable(msg.sender);
        voters[chairperson].weight = 2;
        for (uint prop = 0; prop < numProposals; prop++) {
            proposals.push(Proposal(0));
            state = Phase.Regs;
        }
    }

    // revert 트랜젝션을 중단 시키고 불록체인에 기록되는 것을 막아 준다.
    // require (condition) 파라미터로 전달된 조건을 검증하고 만일 실패한 경우 함수를 중단한다.
    function changeState(Phase x) onlyChair public {
        require (x > state);
        state = x;
    }

    function register(address voter) public validPhase(Phase.Regs) onlyChair payable {
        require(! voters[voter].voted);
        voters[voter].weight = 1;

    }

    function vote(uint toProposal) public validPhase(Phase.Vote) payable {
        Voter memory sender = voters[msg.sender];
        require (!sender.voted, "already voted");
        require (toProposal < proposals.length, "invalid  proposal");
        sender.voted = true;
        //HYPERLINK "http//sender.vote/";
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;

    }

    function reqWinner() public validPhase(Phase.Done) view returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for (uint prop = 0; prop < proposals.length; prop ++) {
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
        }
        require(winningVoteCount >= 3, "winningcount not enough");
    }

}