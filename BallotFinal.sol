pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENSED

contract BallotFinal {
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

    constructor (uint numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 2;
        for (uint prop = 0; prop < numProposals; prop++) {
            proposals.push(Proposal(0));
        }
    }

    // revert 트랜젝션을 중단 시키고 불록체인에 기록되는 것을 막아 준다. 
    // require (condition) 파라미터로 전달된 조건을 검증하고 만일 실패한 경우 함수를 중단한다. 
    function changeState(Phase x) public {
        if (msg.sender != chairperson) revert();
        if (x < state) revert();
        state = x;

    }

}