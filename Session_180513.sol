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

contract ERC20Interface {
    event Transfer( address indexed _from, address indexed _to, uint _value);
    event Approval( address indexed _owner, address indexed _spender, uint _value);
    
    function totalSupply() constant public returns (uint _supply);
    function balanceOf( address _who ) constant public returns (uint _value);
    function transfer( address _to, uint _value) public returns (bool _success);
    function approve( address _spender, uint _value ) public returns (bool _success);
    function allowance( address _owner, address _spender ) constant public returns (uint _allowance);
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success);
}
// 시간관계상 ERC20의 기본 함수를 전부 만들지 못해 Skkcoin is ERC20Interface로 토큰을 만들지 못함.

contract Skkcoin is ERC20Interface{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalsupply;
    
    uint private E18 = 10 ** 18; //wei 계산을 편하게 하려고
    
    address public owner;
    
    using SafeMath for uint256;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) internal allowed;
    //allowed[누가][누구에게] = '얼마' 의 인출 권한을 주는가
    
    constructor(uint256 _supply, string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalsupply = _supply * E18;
        owner = msg.sender;
        balanceOf[msg.sender] = totalsupply; 
    }
    
    function totalSupply() constant public returns (uint256){
      return totalsupply;   
    }
    function balanceOf(address _who) public view returns (uint256){
        return balanceOf[_who];
    }
    
    function transfer( address _to, uint _value) public returns (bool){
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        //계좌액수 오버플로우 방지 등등이 목적인듯
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].sub(_value);
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve( address _spender, uint _value ) public returns (bool _success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance( address _owner, address _spender ) constant public returns (uint _allowance){
        return allowed[_owner][_spender];
    }
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success){
        require(_to !=address(0));
        require(_value <= balanceOf[_from]);
        require(_value <= allowed[_from][msg.sender]);
        
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    event Transfer( address indexed _from, address indexed _to, uint _value);
    event Approval( address indexed _owner, address indexed _spender, uint _value);
    
}