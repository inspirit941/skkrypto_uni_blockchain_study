pragma solidity ^0.4.24;

contract TransactionLogOK{
	//저장소 정의
	mapping (bytes32 => mapping(bytes32 => string)) public tranlog;
	function setTransaction(bytes32 user_id, bytes32 project_id, string tran_data) public {
		//이미 등록된 경우 예외처리
		require(bytes(tranlog[user_id][project_id]).length == 0);
		//등록
		tranlog[user_id][project_id] = tran_data;
	}

	//사용자, 프로젝트별 거래 내용을 가져오기
	function getTransaction(bytes32 user_id, bytes32 project_id) public constant returns (string tran_data){
		return tranlog[user_id][project_id];
	}
}