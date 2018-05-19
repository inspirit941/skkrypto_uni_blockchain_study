 //ch.4-4 회원관리 기능

 //소유자 관리용 계약
contract Owned {
  //상태 변수
  address public owner; //소유자 주소
  event TransferOwnership(address indexed oldaddr, address indexed newaddr);


  using SafeMath for uint256;

  //소유자 한정 메서드용 수식자
  modifier onlyOwner() public{
    require(msg.sender == owner);
    _;
  }
  
  function Owned() public{
    owner = msg.sender; // 처음 계약 생성한 주소를 소유자로 한다.
  }
  
  function transferOwnership(address _new) onlyOwner {
    address oldaddr = owner;
    owner = _new;
    emit TransferOwnership(oldaddr, owner);
  } //소유자 변경
}