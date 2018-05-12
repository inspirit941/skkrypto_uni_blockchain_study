pragma solidity ^0.4.20;

contract OreOrecoin{
	//상태변수 선언
	string public name; //토큰이름
	string public symbol; //토큰단위
	uint8 public decimals; //소수점 이하 자릿수
	uint256 public totalsupply; //토큰 총량

	mapping (address => uint256) public balanceOf; //각 주소의 잔고

	// 이벤트 알림
	event Transfer(address indexed from, address indexed to, uint256 value);

	// 생성자
	function OreOreCoin(uint256 _supply, string _name, string _symbol, uint8 _decimals) public {
		balanceOf[msg.sender] =_supply;
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalsupply = _supply;
	}
	//송금
	function transfer(address _to, uint256 _value) public {
	//부정송금 확인
	if (balanceOf[msg.sender] < _value) throw;
	if (balanceOf[_to] + _value < balanceOf[_to]) throw;
	// 송금하는 주소와 받는 주소의 잔액 갱신
	balanceOf[msg.sender] -= _value;
	balanceOf[_to] += _value;
	//이벤트 알림
	Transfer(msg.sender, _to, _value);
	}
}