pragma solidity ^0.8.7;
//SPDX-License-Identifier: UNLICENSED
contract Airlines {
    address chairperson;
    struct details {
        uint escrow; // 지불 정산
        uint status;
        uint hashOfDetails;
    }

    mapping (address => details) public balanceDetails; //mapping (keytype => value type) map name 
    mapping (address => uint) memberShip;

    // modifier 함수의 동작을 변경하기 위함 
    modifier onlyChairperson {
        require (msg.sender == chairperson);
        _; // modifier 를 상속받은 함수가 실행되는 시정이라고 생각하면 될것 같다. 
    }

    modifier onlyMember {
        require (memberShip[msg.sender] == 1);
        _; // modifier 를 상속받은 함수가 실행되는 시정이라고 생각하면 될것 같다. 
    }

    // 생성자 
    constructor () public payable { // payable 은 뭔가 address의 밸런스를 변경하거나 할때 사용 
        chairperson = msg.sender;
        memberShip[msg.sender] = 1;
        balanceDetails[msg.sender].escrow = msg.value;
    }

    /*contract 함수들 */

    function register() public payable {
        address AirlineA = msg.sender;
        memberShip[msg.sender] = 1;
        balanceDetails[msg.sender].escrow = msg.value;
    }

    // payable 은 이더를 전송할 수 있는 함수인 sender, transfer 를 이용한다. 
    function unregister(address payable AirlineZ) onlyChairperson public {
        memberShip[AirlineZ] = 0;
        // 출발 항공사에게 에스크로 반환 조건을 추가할 수도 있다. /
        AirlineZ.transfer(balanceDetails[AirlineZ].escrow);
        balanceDetails[AirlineZ].escrow = 0;

    }

    function request(address toAirline, uint hashOfDetails) onlyMember public {
        if (memberShip[toAirline] != 1) {
            revert();
        }
        balanceDetails[msg.sender].status=0;
        balanceDetails[msg.sender].hashOfDetails = hashOfDetails;
    }

    function response(address fromAirline, uint hashOfDetails, uint done) onlyMember public {
        if (memberShip[fromAirline] != 1) {
            revert();
        }
        balanceDetails[msg.sender].status = done;
        balanceDetails[fromAirline].hashOfDetails = hashOfDetails;
    }

    function settlePayment (address payable toAirline) onlyMember payable public {
        address fromAirline = msg.sender;
        uint amt = msg.value;

        balanceDetails[toAirline].escrow = balanceDetails[toAirline].escrow + amt;
        balanceDetails[fromAirline].escrow = balanceDetails[fromAirline].escrow - amt;

        toAirline.transfer(amt);
    }

}