enum ProductCategory {
  vegetable('채소'),
  fruit('과일'),
  meat('정육'),
  seafood('수산'),
  eggDairy('계란/유제품'),
  riceGrain('쌀/잡곡'),
  chilledFrozen('냉장/냉동'),
  processed('가공식품'),
  seasoning('조미료'),
  living('생활용품');

  const ProductCategory(this.label);
  final String label;
}

enum ApprovalStatus {
  pending('승인 대기'),
  approved('승인 완료'),
  rejected('반려'),
  needsRevision('수정 요청'),
  duplicate('중복 처리');

  const ApprovalStatus(this.label);
  final String label;
}

enum ReportType {
  flyer('전단지'),
  sms('특가 문자'),
  receipt('영수증'),
  priceTag('매장 특가 사진'),
  manual('직접 입력');

  const ReportType(this.label);
  final String label;
}

enum MartStatus {
  open('운영중'),
  temporaryClosed('휴업'),
  closed('폐점'),
  hidden('비노출');

  const MartStatus(this.label);
  final String label;
}

enum UserRole {
  user('일반 사용자'),
  trustedReporter('우수 특가 제보자'),
  martManager('마트 관리자'),
  admin('서비스 관리자');

  const UserRole(this.label);
  final String label;
}

enum PointStatus {
  scheduled('적립 예정'),
  completed('적립 완료'),
  exchangeRequested('교환 신청'),
  exchanged('교환 완료'),
  rejected('반려'),
  canceled('취소');

  const PointStatus(this.label);
  final String label;
}

enum ReviewStatus {
  scheduled('공개 대기'),
  needsReview('관리자 검토'),
  blocked('자동 차단'),
  published('공개'),
  hidden('숨김');

  const ReviewStatus(this.label);
  final String label;
}

enum ReviewTargetType {
  mart('마트 리뷰'),
  product('상품 리뷰');

  const ReviewTargetType(this.label);
  final String label;
}
