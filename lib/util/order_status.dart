enum OrderStatus{
  request(0), // 요청
  readyTo(1), // 준비 중
  pickup(2), // 픽업 완료
  cancel(3);// 취소
  
  final int code;
  const OrderStatus(this.code); 
}