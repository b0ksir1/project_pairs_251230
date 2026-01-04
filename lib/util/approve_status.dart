enum ApproveStatus{
  readyToSenior(0), // 팀장 승인 대기 중
  readyToDirecotr(1), // 임원 승인 대기 중
  directorApproved(2), // 발주 승인 완료
  purchased(3), // 발주 중 
  readyToObtain(4), // 수주 대기 중
  readyToConfirmObtain(5), // 수주 확인 대기 중
  complete(6), // 완료
  cancel(7), // 취소
  reject(8); // 반려
  final int code;
  const ApproveStatus(this.code); 
}