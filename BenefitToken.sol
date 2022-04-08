// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BenefitToken is ERC20 {

    uint256 public INITIAL_SUPPLY = 500;
    address public publisher;
    
    enum Step {Init, Req, Accept, Done}
    struct Benefit {
        uint threshold;
        uint cost;
        string benefitText;
    }
    Benefit[] public benefits;
    mapping(address => Benefit) public benefitProgressings;
    mapping(address => Step) benefitStates;


    modifier onlyPublisher() {
        require(msg.sender == publisher, "not publisher ");
        _;
    }

    modifier onlySharholders() {
        require(msg.sender != publisher, "not sharHolders ");
        _;
    }

    constructor() ERC20("benefitToken", "BNT") {
        _mint(msg.sender, INITIAL_SUPPLY);
        publisher = msg.sender;
    }

    function addBenefit(uint threshold, uint cost, string memory benefitText) public onlyPublisher {
        benefits.push(Benefit({
            threshold: threshold,
            cost: cost,
            benefitText: benefitText
        }));
    }


    function deleteBenefit() public onlyPublisher {
        benefits.pop();
    }

    
    function requestBenefit(uint benefitIdx) public onlySharholders {
        require(benefits.length > benefitIdx, "invalid index");
        uint threshold = benefits[benefitIdx].threshold;
        require(threshold < balanceOf(msg.sender));
        require(benefitStates[msg.sender] == Step.Init || benefitStates[msg.sender] == Step.Done, "invalid step ");
        

        benefitProgressings[msg.sender] = benefits[benefitIdx];
        benefitStates[msg.sender] = Step.Req;

    }

    function acceptBenefit(address requestor) public onlyPublisher {
        // Benefit memory benefit = benefitProgressings[msg.sender]
        benefitStates[msg.sender] = Step.Accept;
    }

    function completeBenefit() public onlySharholders {
        Benefit memory benefit = benefitProgressings[msg.sender];
        if (benefit.cost > 0)
            transfer(publisher, benefit.cost);

        benefitStates[msg.sender] = Step.Done;
    }


    // 발행자 혜택 사용 확인 
    // 참여자 혜택 사용 확인 
    



}
