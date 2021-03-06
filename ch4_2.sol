pragma solidity ^0.4.20;

contract OreOrecoin{
	//상태변수 선언
	string public name; //토큰이름
	string public symbol; //토큰단위
	uint8 public decimals; //소수점 이하 자릿수
	uint256 public totalsupply; //토큰 총량

	mapping (address => uint256) public balanceOf; //각 주소의 잔고
	mapping (address => int8) public blackList; //블랙리스트
	address public owner; //소유자 주소

	//수식자
	modifier onlyOwner() {
		require(msg.sender == owner); 
		_;
	}

	// 이벤트 알림
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Blacklisted(address indexed target);
	event DelfromBlacklist(address indexed target);
	event RejectPaytoBlacklist(address indexed from, address indexed to, uint256 value);
	event RejectPayfromBlacklist(address indexed from, address indexed to, uint256 value);


	// 생성자
	function OreOreCoin(uint256 _supply, string _name, string _symbol, uint8 _decimals) public {
		balanceOf[msg.sender] =_supply;
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalsupply = _supply;
		owner = msg.sender; // 소유자 주소 설정
	}

	//주소를 블랙리스트에 등록
	function blacklisting(address _addr) public onlyOwner{
		blackList[_addr] = 1;
		Blacklisted(_addr);
	}

	//주소를 블랙리스트에서 해제
	function Deletefromblacklist(address _addr) public onlyOwner{
		blackList[_addr] = -1;
		Blacklisted(_addr);
	}

	//송금
	function transfer(address _to, uint256 _value) public{
	//부정송금 확인
	require(balanceOf[msg.sender] >= _value);
	require( _value >= 0);
	//블랙리스트에 존재하는 주소는 입출금 불가
	if (blackList[msg.sender] >0){
		RejectPayfromBlacklist(msg.sender, _to, _value);
	} else if (blackList[_to]> 0){
		RejectPaytoBlacklist(msg.sender, _to, _value);
	} else {
	// 송금하는 주소와 받는 주소의 잔액 갱신
	balanceOf[msg.sender] -= _value;
	balanceOf[_to] += _value;
	//이벤트 알림
	Transfer(msg.sender, _to, _value);
		}
	}
}