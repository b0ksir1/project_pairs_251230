enum ApproveStatus{
  readyToSenior(1), // 팀장 승인 대기 중
  readyToDirecotr(2), // 임원 승인 대기 중
  directorApproved(3), // 발주 승인 완료
  purchased(4), // 발주 중 
  readyToObtain(5), // 수주 대기 중
  readyToConfirmObtain(6), // 수주 확인 대기 중
  complete(7), // 완료
  cancel(8), // 취소
  reject(9); // 반려
  final int code;
  const ApproveStatus(this.code); 
}