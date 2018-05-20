pragma solidity ^0.4.23;
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


//회원관리용 계약
contract Members is Owner {
  //상태변수 선언
  address public coin; //토큰 주소
  MemberStatus[] public status; //회원 등급 배열
  mapping (address => History) public tradingHistory; //회원별 거래내역

//회원등급용 구조체
  struct MemberStatus{
    string name; //등급명
    uint256 times; //최저거래횟수
    uint256 sum; //최저거래금액
    int rate; //캐시백 비율
  }
  struct History{
    uint256 times;//거래횟수
    uint256 sum;//거래금액
    uint256 statusIndex;//등급 인덱스
  }

  //토큰 한정 메소드용 수식자
  modifier onlyCoin(){
  //코인 주소를 설정하면 이 코인에서만 함수를 쓸 수 있다.
    require(msg.sender ==coin);
    _;
  }

  //토큰 주소 설정
  function setCoin(address _addr) onlyOwner(){
    coin = _addr;
  }

  //새 회원 등급 추가
  function pushStatus(string _name, uint256 _times, uint256 _sum, int8 rate) public onlyOwner(){
    status.push(MemberStatus({
    name : _name,
    times : _times,
    sum : _sum,
    rate : rate
    }));
  }

  //회원등급 내용변경
  function editStatus(uint256 _index, string _name, uint256 _times, uint256 _sum, int8 _rate) public onlyOwner(){
    if (_index < status.length){
      status[_index].name = _name;
      status[_index].times = _times;
      status[_index].sum = _sum;
      status[_index].rate = _rate;
    }
  }

  //거래내역 갱신
  //회원이 거래를 새로 할 때마다 갱신됨. 
  function updateHistory(address _member, uint256 _value) public onlyCoin(){
    tradingHistory[_member].times = tradingHistory[_member].times.add(1);
    tradingHistory[_member].sum = tradingHistory[_member].sum.add(_value);

    //거래마다 새로운 회원등급 결정
    uint256 index;
    int8 tmprate;
    for (uint i=0; i <status.length;i++){
      //최저거래횟수, 최저거래금액 충족 시 가장 캐시백 비율이 좋은 등급으로 설정
      if (tradingHistory[_member].times >= status[i].times && 
        tradingHistory[_member].sum>=status[i].sum &&
        tmprate < status[i].rate){
        index = i;
      }
    }
    tradingHistory[_member].statusIndex = index;
  }

//캐시백 비율 확인
function getCashbackRate(address _member) public view returns (int8 rate){
  rate = status[tradingHistory[_member].statusIndex].rate;
  }

}