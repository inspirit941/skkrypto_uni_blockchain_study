pragma solidity ^0.4.24;

contract PersonCertification{
	//계약 관리자 주소
	address admin;
	//열람 허가 정보
	struct AppDetail{
		bool allowReference;
		uint256 approveBlockNo;
		uint256 refLimitBlockNo;
		address applicant;
	}
	// 여러 명에게 열람허가를 할 수 없으며, 열람 허가된 정보는 누구나 볼 수 있다.

	//본인 정보
	struct PersonDetail{
		string name;
		string birth;
		address[] orglist;
	}
	//orglist에는 학교나 기업 등 인증기관의 이더리움 주소가 배열 형태로 저장된다.

	//인증 기관 정보
	struct OrganizationDetail{
		string name;
	}
// 실제로 진행할 경우 기업 식별 ID를 추가하거나 계약관리자가 인증기관이라는 것을 알기 쉽게 하기 위한 플래그 등이 필요할 것이다.


	//해당 키의 열람허가 정보
	mapping(address=> AppDetail) appDetail;
//주소별로 열람 허용할 정보를 저장한다

	//해당 키의 본인확인 정보
	mapping(address => PersonDetail) personDetail;
// 해당 주소는 본인 확인용이다

	//해당 키의 조직정보
	mapping(address => OrganizationDetail) public orgDetail;
	
	//생성자
	function PersonCertification() public {
		admin = msg.sender;
	} //modifier로 onlyowner 설정이 필요하다

	//데이터 등록기관 (set)
	//본인 정보를 등록
	function setPerson(string _name, string _birth) public {
		PersonDetail[msg.sender].name = _name;
		PersonDetail[msg.sender].birth = _birth;
	}
	//조직 등록
	function setOrganization(string _name) public {
		orgDetail[msg.sender].name = _name;
	}
	//조직이 개인의 소속을 증명
	function setBelong(address _person) public {
		personDetail[_person].orglist.push(msg.sender)
	} //이건 조직만 할 수 있도록 modifier 필요.
	
	//본인 확인 정보 참조를 허가함
	//applicant는 참조를 허가할 대상 주소를 말한다. 이 예제의 경우 기업의 채용 담당자 주소.
	//_span의 경우 블록 번호로부터 어느 정도 이후까지의 블록을 참조할 수 있는지 지정한다. 일반적이라면 시간 단위까지 지정해 관리할 수 있으나 이더리움은 그게 안 됨. 따라서 1개의 블록이 생성되는 데 걸리는 시간을 고려해 블록단위로 시간을 제한해야 한다. 
	ex) 24시간 참조허용을 하고 싶다면, 한 블록 생성에 30초가 걸릴 경우 24*60*2로 계산해 2880블록 이후까지를 설정하는 식이다.

	function setApprove(address _applicant, uint256 _span) public {
		appDetail[msg.sender].allowReference = true;
		appDetail[msg.sender].approveBlockNo = block.number;
		appDetail[msg.sender].refLimitBlockNo = block.number + _span;
		appDetail[msg.sender].applicant = _applicant;
	}

//데이터 취득 함수
	

	//본인 확인정보 참조
	function getPerson(address _person) public constant returns(
		bool _allowReference;
		uint256 _approveBlockNo;
		uint256 _refLimitBlockNo;
		address _applicant;
		string _name;
		string _birth;
		address[] _orglist;){
			_allowReference = appDetail[_person].allowReference;
			_approveBlockNo = appDetail[_person].approveBlockNo;
			_refLimitBlockNo = appDetail[_person].refLimitBlockNo;
			_applicant = appDetail[_person].applicant;
			//열람을 제한할 정보
			if ((msg.sender == _applicant) && (_allowReference == true) && (block.number < _refLimitBlockNo) || (msg.sender == admin) || (msg.sender == _person)){
				_name = PersonDetail[_person].name;
				_birth = PersonDetail[_person].birth;
				_orglist = PersonDetail[_person].orglist;
			}
			// 열람을 제한한 정보는 특정 조건을 만족한 사람만이 열람할 수 있다. if문의 제약에서는 1. 계약관리자 2. 본인 3. 본인에게 열람허가를 받은 자가 기간 내에 확인 가능
		}

}
