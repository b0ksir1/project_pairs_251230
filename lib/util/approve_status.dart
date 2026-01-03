enum ApproveStatus{
  request(0), // 요청
  seniorApproved(1), // 팀장 승인
  directorApproved(2), // 임원 승인
  cancel(3), // 취소 
  reject(4), // 반려
  complete(5); // 완료
  final int code;
  const ApproveStatus(this.code); 
}