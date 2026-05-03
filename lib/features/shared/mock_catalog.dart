class DealItem {
  const DealItem({
    required this.id,
    required this.title,
    required this.martName,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.discountRate,
    required this.imageUrl,
    required this.description,
    required this.comparisons,
    this.badge = '특가',
  });

  final String id;
  final String title;
  final String martName;
  final String category;
  final int price;
  final int originalPrice;
  final int discountRate;
  final String imageUrl;
  final String description;
  final List<MartPriceComparison> comparisons;
  final String badge;
}

class MartPriceComparison {
  const MartPriceComparison({
    required this.martName,
    required this.productName,
    required this.price,
    required this.unit,
    required this.distance,
    required this.period,
    required this.source,
    this.hasParking = true,
    this.isCheapest = false,
  });

  final String martName;
  final String productName;
  final int price;
  final String unit;
  final String distance;
  final String period;
  final String source;
  final bool hasParking;
  final bool isCheapest;
}

class FlyerItem {
  const FlyerItem({
    required this.id,
    required this.martName,
    required this.title,
    required this.period,
    required this.imageUrl,
    required this.address,
    required this.businessHours,
    required this.phoneNumber,
    required this.closedDays,
    required this.parkingInfo,
    required this.description,
    required this.dataSource,
  });

  final String id;
  final String martName;
  final String title;
  final String period;
  final String imageUrl;
  final String address;
  final String businessHours;
  final String phoneNumber;
  final String closedDays;
  final String parkingInfo;
  final String description;
  final String dataSource;
}

class CommunityPost {
  const CommunityPost({
    required this.title,
    required this.place,
    required this.time,
    required this.current,
    required this.capacity,
    required this.pricePerPerson,
    required this.imageUrl,
  });

  final String title;
  final String place;
  final String time;
  final int current;
  final int capacity;
  final int pricePerPerson;
  final String imageUrl;
}

class RecipeSuggestion {
  const RecipeSuggestion({
    required this.title,
    required this.reason,
    required this.time,
    required this.difficulty,
    required this.budget,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.relatedDealIds,
    this.tag = '추천',
  });

  final String title;
  final String reason;
  final String time;
  final String difficulty;
  final int budget;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> relatedDealIds;
  final String tag;
}

class ReceiptSummary {
  const ReceiptSummary({
    required this.date,
    required this.martName,
    required this.description,
    required this.amount,
  });

  final String date;
  final String martName;
  final String description;
  final int amount;
}

// 임시 목업 이미지입니다. 출시 전에는 마트 제공/직접 촬영/승인 이미지로 교체합니다.
const dealItems = [
  DealItem(
    id: 'hanwoo',
    title: '프리미엄 한우 세트 (1kg)',
    martName: '행복한식자재마트 단구점',
    category: 'meat',
    price: 110000,
    originalPrice: 150000,
    discountRate: 27,
    imageUrl:
        'https://sitem.ssgcdn.com/98/64/64/item/1000043646498_i1_1200.jpg',
    description:
        '최상급 품질의 한우를 엄선해 구성한 프리미엄 세트입니다. 명절 선물이나 특별한 날 가족 식탁에 어울리는 행사 상품입니다.',
    badge: '전국단위 특가',
    comparisons: [
      MartPriceComparison(
        martName: '행복한식자재마트 단구점',
        productName: '프리미엄 한우 세트 (1kg)',
        price: 110000,
        unit: '1kg',
        distance: '1.2km',
        period: '4/28 ~ 5/04',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '무항생제 한우 선물세트 (1kg)',
        price: 125000,
        unit: '1kg',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '관리자 입력',
      ),
      MartPriceComparison(
        martName: 'SG마트 단계점',
        productName: '1등급 한우 모듬 세트 (1.2kg)',
        price: 132000,
        unit: '1.2kg',
        distance: '4.6km',
        period: '4/28 ~ 5/02',
        source: '온라인 전단',
      ),
    ],
  ),
  DealItem(
    id: 'egg',
    title: '동물복지 유정란 (30구)',
    martName: '행복한식자재마트 단구점',
    category: 'meat',
    price: 6900,
    originalPrice: 12800,
    discountRate: 46,
    imageUrl:
        'https://sitem.ssgcdn.com/07/25/58/item/1000608582507_i1_1200.jpg',
    description:
        '넓은 사육환경에서 생산된 동물복지 유정란입니다. 30구 대용량 구성이라 가족 장보기와 식당 준비에 모두 적합합니다.',
    badge: '행복 식자재',
    comparisons: [
      MartPriceComparison(
        martName: '행복한식자재마트 단구점',
        productName: '동물복지 유정란 (30구)',
        price: 6900,
        unit: '30구',
        distance: '1.2km',
        period: '4/28 ~ 5/04',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '친환경 유정란 (30구)',
        price: 8500,
        unit: '30구',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '영수증 특가 제보',
      ),
      MartPriceComparison(
        martName: '우리홈마켓 원주점',
        productName: '무항생제 유정란 대란 30구',
        price: 9200,
        unit: '30구',
        distance: '배송',
        period: '오늘 도착',
        source: '온라인 특가 정보',
        hasParking: false,
      ),
    ],
  ),
  DealItem(
    id: 'strawberry',
    title: '제철 딸기 (500g)',
    martName: '하나로마트 판부농협본점',
    category: 'veg',
    price: 7900,
    originalPrice: 10500,
    discountRate: 25,
    imageUrl:
        'https://sitem.ssgcdn.com/79/38/46/item/1000038463879_i1_1200.jpg',
    description: '당도 높은 제철 딸기 500g 행사 상품입니다. 아이 간식이나 디저트 재료로 쓰기 좋습니다.',
    badge: '신선 과일',
    comparisons: [
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '제철 딸기 (500g)',
        price: 7900,
        unit: '500g',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '행복한식자재마트 단구점',
        productName: '논산 딸기 특품 (500g)',
        price: 8900,
        unit: '500g',
        distance: '1.2km',
        period: '4/28 ~ 5/04',
        source: '매장 특가 제보',
      ),
      MartPriceComparison(
        martName: 'SG마트 단계점',
        productName: '새벽수확 딸기 (500g)',
        price: 9500,
        unit: '500g',
        distance: '4.6km',
        period: '4/28 ~ 5/02',
        source: '온라인 전단',
      ),
    ],
  ),
  DealItem(
    id: 'oil',
    title: '대용량 식용유 (1.8L)',
    martName: '대륙식자재마트 원주본점',
    category: 'processed',
    price: 4200,
    originalPrice: 6000,
    discountRate: 30,
    imageUrl:
        'https://sitem.ssgcdn.com/24/11/61/item/0000006611124_i1_1200.jpg',
    description:
        '튀김, 볶음, 전 요리에 두루 쓰기 좋은 1.8L 식용유 행사 상품입니다. 대용량 장보기 품목으로 추천합니다.',
    badge: '대용량 특가',
    comparisons: [
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '대용량 식용유 (1.8L)',
        price: 4200,
        unit: '1.8L',
        distance: '3.1km',
        period: '4/28 ~ 5/07',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '상지식자재할인마트',
        productName: '식용유 (1.8L)',
        price: 4900,
        unit: '1.8L',
        distance: '2.4km',
        period: '4/28 ~ 5/03',
        source: '매장 특가 제보',
      ),
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '카놀라유 (1.8L)',
        price: 5500,
        unit: '1.8L',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '영수증 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'onion',
    title: '양파 (15kg/망)',
    martName: '상지식자재할인마트',
    category: 'veg',
    price: 12000,
    originalPrice: 20000,
    discountRate: 40,
    imageUrl:
        'https://sitem.ssgcdn.com/97/16/63/item/1000012631697_i1_1200.jpg',
    description: '소분모임과 식당 장보기에 적합한 15kg 양파망입니다. 김치, 카레, 볶음요리 준비에 실속 있는 구성입니다.',
    badge: '박스특가',
    comparisons: [
      MartPriceComparison(
        martName: '상지식자재할인마트',
        productName: '양파 (15kg/망)',
        price: 12000,
        unit: '15kg',
        distance: '2.4km',
        period: '4/28 ~ 5/03',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '양파 대용량망 (15kg)',
        price: 13500,
        unit: '15kg',
        distance: '3.1km',
        period: '4/28 ~ 5/07',
        source: '관리자 입력',
      ),
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '양파 (15kg)',
        price: 15800,
        unit: '15kg',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'pork_front',
    title: '국내산 돼지 앞다리살 (1kg)',
    martName: '대륙식자재마트 원주본점',
    category: 'meat',
    price: 8900,
    originalPrice: 12900,
    discountRate: 31,
    imageUrl:
        'https://sitem.ssgcdn.com/84/10/98/item/1000520981084_i1_1200.jpg',
    description: '제육볶음, 수육, 찌개용으로 활용하기 좋은 국내산 돼지 앞다리살 1kg 행사 상품입니다.',
    badge: '정육 특가',
    comparisons: [
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '국내산 돼지 앞다리살 (1kg)',
        price: 8900,
        unit: '1kg',
        distance: '3.1km',
        period: '4/29 ~ 5/05',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '돼지 앞다리살 불고기용 (1kg)',
        price: 9800,
        unit: '1kg',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '매장 특가 제보',
      ),
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '국내산 앞다리살 (1kg)',
        price: 10900,
        unit: '1kg',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '영수증 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'chicken_breast',
    title: '닭가슴살 냉장팩 (1kg)',
    martName: '엘마트 개운점',
    category: 'meat',
    price: 6500,
    originalPrice: 8900,
    discountRate: 27,
    imageUrl:
        'https://sitem.ssgcdn.com/80/39/85/item/1000019853980_i1_1200.jpg',
    description: '샐러드, 볶음밥, 다이어트 도시락에 활용하기 좋은 냉장 닭가슴살 1kg 상품입니다.',
    badge: '단백질 특가',
    comparisons: [
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '닭가슴살 냉장팩 (1kg)',
        price: 6500,
        unit: '1kg',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '닭가슴살 벌크팩 (1kg)',
        price: 7200,
        unit: '1kg',
        distance: '3.1km',
        period: '4/29 ~ 5/05',
        source: '전단지',
      ),
    ],
  ),
  DealItem(
    id: 'tofu',
    title: '국산콩 두부 (300g x 2입)',
    martName: '행복한식자재마트 문막점',
    category: 'processed',
    price: 2500,
    originalPrice: 3600,
    discountRate: 31,
    imageUrl:
        'https://sitem.ssgcdn.com/05/01/57/item/1000621570105_i1_1200.jpg',
    description: '찌개, 부침, 샐러드에 두루 쓰기 좋은 국산콩 두부 2입 묶음 행사 상품입니다.',
    badge: '반찬 재료',
    comparisons: [
      MartPriceComparison(
        martName: '행복한식자재마트 문막점',
        productName: '국산콩 두부 (300g x 2입)',
        price: 2500,
        unit: '2입',
        distance: '문막',
        period: '4/29 ~ 5/04',
        source: '매장 특가 제보',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '부침두부 (300g x 2입)',
        price: 2900,
        unit: '2입',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '영수증 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'milk_1l',
    title: '맛있는 우유 (900ml)',
    martName: '엘마트 개운점',
    category: 'dairy',
    price: 1980,
    originalPrice: 2850,
    discountRate: 31,
    imageUrl:
        'https://sitem.ssgcdn.com/02/86/45/item/1000348458602_i1_1200.jpg',
    description: '아침 식사와 간식에 곁들이기 좋은 900ml 우유 행사 상품입니다.',
    badge: '유제품 특가',
    comparisons: [
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '맛있는 우유 (900ml)',
        price: 1980,
        unit: '900ml',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '서울우유 (1L)',
        price: 2850,
        unit: '1L',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '영수증 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'yogurt',
    title: '떠먹는 요구르트 플레인 (8입)',
    martName: 'SG마트 단계점',
    category: 'dairy',
    price: 3980,
    originalPrice: 5200,
    discountRate: 23,
    imageUrl:
        'https://sitem.ssgcdn.com/14/28/92/item/1000327922814_i1_1200.jpg',
    description: '아침 대용이나 아이 간식으로 좋은 플레인 요구르트 8입 묶음 상품입니다.',
    badge: '간식 특가',
    comparisons: [
      MartPriceComparison(
        martName: 'SG마트 단계점',
        productName: '떠먹는 요구르트 플레인 (8입)',
        price: 3980,
        unit: '8입',
        distance: '4.0km',
        period: '4/29 ~ 5/02',
        source: '온라인 전단',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '플레인 요구르트 (8입)',
        price: 4500,
        unit: '8입',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'apple',
    title: '세척 사과 (5입 봉)',
    martName: '하나로마트 판부농협본점',
    category: 'veg',
    price: 6900,
    originalPrice: 9900,
    discountRate: 30,
    imageUrl:
        'https://sitem.ssgcdn.com/05/72/64/item/1000546647205_i1_1200.jpg',
    description: '아침 과일이나 도시락 간식으로 좋은 세척 사과 5입 봉 상품입니다.',
    badge: '과일 특가',
    comparisons: [
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '세척 사과 (5입 봉)',
        price: 6900,
        unit: '5입',
        distance: '2.8km',
        period: '4/29 ~ 5/01',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: 'SG마트 단계점',
        productName: '국산 사과 (5입)',
        price: 7900,
        unit: '5입',
        distance: '4.0km',
        period: '4/29 ~ 5/02',
        source: '온라인 전단',
      ),
    ],
  ),
  DealItem(
    id: 'potato',
    title: '감자 (3kg 박스)',
    martName: '대륙식자재마트 원주본점',
    category: 'veg',
    price: 5900,
    originalPrice: 8500,
    discountRate: 31,
    imageUrl:
        'https://sitem.ssgcdn.com/79/02/14/item/1000206140279_i1_1200.jpg',
    description: '카레, 조림, 볶음 요리에 활용하기 좋은 감자 3kg 박스 행사 상품입니다.',
    badge: '박스특가',
    comparisons: [
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '감자 (3kg 박스)',
        price: 5900,
        unit: '3kg',
        distance: '3.1km',
        period: '4/29 ~ 5/05',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '상지식자재할인마트',
        productName: '감자 실속팩 (3kg)',
        price: 6800,
        unit: '3kg',
        distance: '확인 필요',
        period: '4/29 ~ 5/03',
        source: '관리자 입력',
      ),
    ],
  ),
  DealItem(
    id: 'rice_10kg',
    title: '철원 오대쌀 (10kg)',
    martName: 'SG마트 단계점',
    category: 'rice',
    price: 32900,
    originalPrice: 38900,
    discountRate: 15,
    imageUrl:
        'https://sitem.ssgcdn.com/47/91/70/item/0000007709147_i1_1200.jpg',
    description: '밥맛 좋은 쌀을 찾는 가정에 적합한 10kg 쌀 행사 상품입니다.',
    badge: '쌀 특가',
    comparisons: [
      MartPriceComparison(
        martName: 'SG마트 단계점',
        productName: '철원 오대쌀 (10kg)',
        price: 32900,
        unit: '10kg',
        distance: '4.0km',
        period: '4/29 ~ 5/02',
        source: '온라인 전단',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '국산 쌀 (10kg)',
        price: 34500,
        unit: '10kg',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'ramen',
    title: '신라면 멀티팩 (5입)',
    martName: '엘마트 개운점',
    category: 'processed',
    price: 3800,
    originalPrice: 4500,
    discountRate: 16,
    imageUrl:
        'https://sitem.ssgcdn.com/48/36/33/item/0000008333648_i1_1200.jpg',
    description: '간편식으로 많이 찾는 라면 5입 멀티팩 행사 상품입니다.',
    badge: '라면 특가',
    comparisons: [
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '신라면 멀티팩 (5입)',
        price: 3800,
        unit: '5입',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '신라면 (5입)',
        price: 4100,
        unit: '5입',
        distance: '3.1km',
        period: '4/29 ~ 5/05',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'tuna',
    title: '참치캔 (150g x 4입)',
    martName: '행복한식자재마트 문막점',
    category: 'processed',
    price: 7900,
    originalPrice: 10500,
    discountRate: 25,
    imageUrl:
        'https://sitem.ssgcdn.com/25/06/38/item/0000008380625_i1_1200.jpg',
    description: '김치찌개, 주먹밥, 샐러드에 활용하기 좋은 참치캔 4입 묶음입니다.',
    badge: '통조림 특가',
    comparisons: [
      MartPriceComparison(
        martName: '행복한식자재마트 문막점',
        productName: '참치캔 (150g x 4입)',
        price: 7900,
        unit: '4입',
        distance: '문막',
        period: '4/29 ~ 5/04',
        source: '매장 특가 제보',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '참치 살코기 (150g x 4입)',
        price: 8900,
        unit: '4입',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '영수증 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'soy_sauce',
    title: '진간장 (1.7L)',
    martName: '대륙식자재마트 원주본점',
    category: 'seasoning',
    price: 3900,
    originalPrice: 5200,
    discountRate: 25,
    imageUrl:
        'https://sitem.ssgcdn.com/70/29/70/item/1000599702970_i1_1200.jpg',
    description: '볶음, 조림, 무침에 자주 쓰이는 기본 조미료 진간장 1.7L 행사 상품입니다.',
    badge: '조미료 특가',
    comparisons: [
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '진간장 (1.7L)',
        price: 3900,
        unit: '1.7L',
        distance: '3.1km',
        period: '4/29 ~ 5/05',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '양조간장 (1.7L)',
        price: 4600,
        unit: '1.7L',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'gochujang',
    title: '태양초 고추장 (1kg)',
    martName: '엘마트 개운점',
    category: 'seasoning',
    price: 6900,
    originalPrice: 8900,
    discountRate: 22,
    imageUrl:
        'https://sitem.ssgcdn.com/12/00/61/item/0000006610012_i1_1200.jpg',
    description: '비빔밥, 볶음, 찌개 양념에 활용하기 좋은 고추장 1kg 행사 상품입니다.',
    badge: '양념 특가',
    comparisons: [
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '태양초 고추장 (1kg)',
        price: 6900,
        unit: '1kg',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '매운 고추장 (1kg)',
        price: 7500,
        unit: '1kg',
        distance: '3.1km',
        period: '4/29 ~ 5/05',
        source: '관리자 입력',
      ),
    ],
  ),
  DealItem(
    id: 'detergent',
    title: '주방세제 리필 (1.2L)',
    martName: '엘마트 개운점',
    category: 'living',
    price: 2900,
    originalPrice: 4200,
    discountRate: 31,
    imageUrl:
        'https://sitem.ssgcdn.com/85/00/46/item/2097001460085_i1_1200.jpg',
    description: '매일 쓰는 주방세제를 실속 있게 구매할 수 있는 리필형 생활용품 행사 상품입니다.',
    badge: '생활용품',
    comparisons: [
      MartPriceComparison(
        martName: '엘마트 개운점',
        productName: '주방세제 리필 (1.2L)',
        price: 2900,
        unit: '1.2L',
        distance: '2.0km',
        period: '4/29 ~ 5/03',
        source: '전단지',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '행복한식자재마트 문막점',
        productName: '주방세제 대용량 리필 (1.2L)',
        price: 3400,
        unit: '1.2L',
        distance: '문막',
        period: '4/29 ~ 5/04',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'bean_sprouts',
    title: '국산 콩나물 (1kg)',
    martName: '행복한식자재마트 태장점',
    category: 'veg',
    price: 1900,
    originalPrice: 2800,
    discountRate: 32,
    imageUrl:
        'https://sitem.ssgcdn.com/36/65/38/item/1000532386536_i1_1200.jpg',
    description: '국, 무침, 볶음요리에 두루 쓰기 좋은 1kg 콩나물 특가 상품입니다.',
    badge: '태장점 특가',
    comparisons: [
      MartPriceComparison(
        martName: '행복한식자재마트 태장점',
        productName: '국산 콩나물 (1kg)',
        price: 1900,
        unit: '1kg',
        distance: '태장동',
        period: '이번 주',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '행복한식자재마트 단구점',
        productName: '콩나물 실속팩 (1kg)',
        price: 2200,
        unit: '1kg',
        distance: '단구동',
        period: '이번 주',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'frozen_dumpling',
    title: '왕만두 냉동팩 (1.4kg)',
    martName: '행복한식자재할인마트 태장점',
    category: 'processed',
    price: 8900,
    originalPrice: 11900,
    discountRate: 25,
    imageUrl:
        'https://sitem.ssgcdn.com/53/20/75/item/1000544752053_i1_1200.jpg',
    description: '찜, 국, 전골에 활용하기 좋은 대용량 왕만두 냉동팩입니다.',
    badge: '할인형 특가',
    comparisons: [
      MartPriceComparison(
        martName: '행복한식자재할인마트 태장점',
        productName: '왕만두 냉동팩 (1.4kg)',
        price: 8900,
        unit: '1.4kg',
        distance: '태장동',
        period: '이번 주',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '우리홈마켓 원주점',
        productName: '냉동 만두 대용량 (1.2kg)',
        price: 9900,
        unit: '1.2kg',
        distance: '태장동',
        period: '이번 주',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'monomart_sauce',
    title: '업소용 돈까스소스 (2kg)',
    martName: '모노마트 원주점',
    category: 'seasoning',
    price: 9800,
    originalPrice: 12500,
    discountRate: 22,
    imageUrl:
        'https://sitem.ssgcdn.com/77/19/38/item/1000577381977_i1_1200.jpg',
    description: '분식, 도시락, 튀김 메뉴에 쓰기 좋은 업소용 소스 특가 상품입니다.',
    badge: '업소용 특가',
    comparisons: [
      MartPriceComparison(
        martName: '모노마트 원주점',
        productName: '업소용 돈까스소스 (2kg)',
        price: 9800,
        unit: '2kg',
        distance: '단계동',
        period: '이번 주',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '대륙식자재마트 원주본점',
        productName: '돈까스소스 대용량 (2kg)',
        price: 10900,
        unit: '2kg',
        distance: '개운동',
        period: '이번 주',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'sparkling_water',
    title: '탄산수 묶음 (500ml x 20입)',
    martName: '우리홈마켓 원주점',
    category: 'processed',
    price: 9900,
    originalPrice: 13900,
    discountRate: 29,
    imageUrl:
        'https://sitem.ssgcdn.com/39/52/57/item/1000054575239_i1_1200.jpg',
    description: '24시간 마트에서 장보기 좋은 탄산수 20입 묶음 특가입니다.',
    badge: '24시간 특가',
    comparisons: [
      MartPriceComparison(
        martName: '우리홈마켓 원주점',
        productName: '탄산수 묶음 (500ml x 20입)',
        price: 9900,
        unit: '20입',
        distance: '태장동',
        period: '이번 주',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: 'SG마트 행구점',
        productName: '탄산수 500ml 묶음',
        price: 11500,
        unit: '20입',
        distance: '행구동',
        period: '이번 주',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'salad_mix',
    title: '샐러드 채소 믹스 (500g)',
    martName: '오드리푸드마켓 원주점',
    category: 'veg',
    price: 4900,
    originalPrice: 6900,
    discountRate: 29,
    imageUrl:
        'https://sitem.ssgcdn.com/46/83/78/item/1000633788346_i1_1200.jpg',
    description: '간편하게 씻어 먹기 좋은 샐러드 채소 믹스 특가 상품입니다.',
    badge: '신선 특가',
    comparisons: [
      MartPriceComparison(
        martName: '오드리푸드마켓 원주점',
        productName: '샐러드 채소 믹스 (500g)',
        price: 4900,
        unit: '500g',
        distance: '태장동',
        period: '이번 주',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '하나로마트 판부농협본점',
        productName: '쌈채소 믹스팩 (500g)',
        price: 5900,
        unit: '500g',
        distance: '관설동',
        period: '이번 주',
        source: '전단지',
      ),
    ],
  ),
  DealItem(
    id: 'flour_bulk',
    title: '중력 밀가루 (10kg)',
    martName: '탑식자재할인마트',
    category: 'processed',
    price: 13900,
    originalPrice: 16900,
    discountRate: 18,
    imageUrl:
        'https://sitem.ssgcdn.com/68/90/60/item/0000006609068_i1_1200.jpg',
    description: '전, 부침, 베이킹에 활용하기 좋은 10kg 대용량 밀가루입니다.',
    badge: '문막 특가',
    comparisons: [
      MartPriceComparison(
        martName: '탑식자재할인마트',
        productName: '중력 밀가루 (10kg)',
        price: 13900,
        unit: '10kg',
        distance: '문막읍',
        period: '이번 주',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: '행복한식자재마트 문막점',
        productName: '밀가루 대용량 (10kg)',
        price: 14800,
        unit: '10kg',
        distance: '문막읍',
        period: '이번 주',
        source: '매장 특가 제보',
      ),
    ],
  ),
  DealItem(
    id: 'grape_pack',
    title: '씨없는 포도 (1.5kg)',
    martName: 'SG마트 행구점',
    category: 'veg',
    price: 11900,
    originalPrice: 15900,
    discountRate: 25,
    imageUrl:
        'https://sitem.ssgcdn.com/53/24/29/item/1000633292453_i1_1200.jpg',
    description: '아이 간식과 디저트로 좋은 씨없는 포도 1.5kg 특가 상품입니다.',
    badge: '행구점 특가',
    comparisons: [
      MartPriceComparison(
        martName: 'SG마트 행구점',
        productName: '씨없는 포도 (1.5kg)',
        price: 11900,
        unit: '1.5kg',
        distance: '행구동',
        period: '이번 주',
        source: '관리자 입력',
        isCheapest: true,
      ),
      MartPriceComparison(
        martName: 'SG마트 단계점',
        productName: '수입 포도팩 (1.5kg)',
        price: 12900,
        unit: '1.5kg',
        distance: '단계동',
        period: '이번 주',
        source: '매장 특가 제보',
      ),
    ],
  ),
];

const flyerItems = [
  FlyerItem(
    id: 'daeryuk-wonju',
    martName: '대륙식자재마트 원주본점',
    title: '24시간 운영 대형 식자재마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&q=80',
    address: '강원 원주시 서원대로 411',
    businessHours: '24시간 (연중무휴)',
    phoneNumber: '033-764-4945',
    closedDays: '연중무휴',
    parkingInfo: '주차 정보 확인 필요',
    description: '개운동 서원대로에 위치한 대형 식자재마트입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'happy-dangu',
    martName: '행복한식자재마트 단구점',
    title: '단구권 지역형 식자재마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800&q=80',
    address: '강원 원주시 남원로534번길 64-1',
    businessHours: '07:00~22:00',
    phoneNumber: '033-765-7737',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '단구동 생활권에서 이용하기 좋은 지역형 식자재마트입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'happy-taejang',
    martName: '행복한식자재마트 태장점',
    title: '태장동 행복한식자재마트 지점',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
    address: '강원 원주시 현충로 12',
    businessHours: '07:00~22:00',
    phoneNumber: '033-744-9600',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '태장동 현충로에 위치한 행복한식자재마트 지점입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'happy-discount-taejang',
    martName: '행복한식자재할인마트 태장점',
    title: '태장동 할인형 식자재마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&q=80',
    address: '강원 원주시 현충로 305',
    businessHours: '07:00~22:30',
    phoneNumber: '033-743-1030',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '태장동 현충로에 위치한 할인형 식자재마트입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'happy-munmak',
    martName: '행복한식자재마트 문막점',
    title: '문막읍 외곽 지역 식자재마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800&q=80',
    address: '강원 원주시 문막읍 건등로 62 1층',
    businessHours: '08:00~22:00',
    phoneNumber: '033-744-1008',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '문막읍 건등로에 위치한 행복한식자재마트 외곽 지역 매장입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'sangji-food',
    martName: '상지식자재할인마트',
    title: '우산동 대표 식자재마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
    address: '강원 원주시 북원로 2501',
    businessHours: '06:00~23:00',
    phoneNumber: '033-733-5400',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '북원로에 위치한 원주 대표 식자재마트입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'hanaro-panbu',
    martName: '하나로마트 판부농협본점',
    title: '농협 운영 신선식품 강점 마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=800&q=80',
    address: '강원 원주시 치악로 1527 판부농협',
    businessHours: '동절기 08:00~21:00 / 하절기 08:00~22:00',
    phoneNumber: '033-769-0200',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '판부농협에서 운영하는 하나로마트 본점으로 신선식품 장보기에 적합합니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'lmart-gaeun',
    martName: '엘마트 개운점',
    title: '개운동 일반마트 + 식자재',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&q=80',
    address: '강원 원주시 단구로 227',
    businessHours: '07:00~22:30',
    phoneNumber: '0507-1424-2523',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '개운동 단구로에 위치한 일반마트와 식자재 장보기 매장입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'monomart-wonju',
    martName: '모노마트 원주점',
    title: '단계동 업소용 식자재 매장',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800&q=80',
    address: '강원 원주시 서원대로 121-9 1층',
    businessHours: '09:00~19:00',
    phoneNumber: '033-735-0429',
    closedDays: '일요일 휴무',
    parkingInfo: '주차 정보 확인 필요',
    description: '단계동 서원대로에 위치한 업소용 성격의 식자재 매장입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'woorihome-wonju',
    martName: '우리홈마켓 원주점',
    title: '북원로 24시간 운영 마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
    address: '강원 원주시 북원로 2638 1층 우리홈마켓',
    businessHours: '24시간 영업, 일요일 22:00 마감, 월요일 08:00 오픈',
    phoneNumber: '033-744-5515',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description:
        '북원로에 위치한 24시간 운영 마트입니다. 일요일은 22:00 마감, 월요일은 08:00 오픈 정보가 있습니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'odri-food',
    martName: '오드리푸드마켓 원주점',
    title: '태장동 식자재 + 일반식품 마켓',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=800&q=80',
    address: '강원 원주시 현충로 54',
    businessHours: '08:00~22:00',
    phoneNumber: '0507-1345-8200',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '태장동 현충로에 위치한 식자재와 일반식품을 함께 취급하는 마켓입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'sg-dangye',
    martName: 'SG마트 단계점',
    title: '단계동 동네형 마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&q=80',
    address: '강원 원주시 백간길 25',
    businessHours: '08:00~22:00',
    phoneNumber: '0507-1428-6672',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '단계동 백간길에 위치한 동네형 마트입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'top-food-munmak',
    martName: '탑식자재할인마트',
    title: '문막읍 식자재 할인마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800&q=80',
    address: '강원 원주시 문막읍 원문로 1587',
    businessHours: '정보 없음',
    phoneNumber: '033-734-1066',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '문막읍 원문로에 위치한 식자재 할인마트입니다.',
    dataSource: '기본 정보',
  ),
  FlyerItem(
    id: 'sg-haenggu',
    martName: 'SG마트 행구점',
    title: '행구동 동네형 마트',
    period: '마트 정보',
    imageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
    address: '강원 원주시 행구로 148',
    businessHours: '08:00~22:00',
    phoneNumber: '033-733-8811',
    closedDays: '확인 필요',
    parkingInfo: '주차 정보 확인 필요',
    description: '행구동 행구로에 위치한 SG마트 지점입니다.',
    dataSource: '기본 정보',
  ),
];

const communityPosts = [
  CommunityPost(
    title: '대용량 양파 1망 소분해요',
    place: '원주 중앙공원 인근',
    time: '오늘 18:00',
    current: 2,
    capacity: 4,
    pricePerPerson: 1500,
    imageUrl:
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=800&q=80',
  ),
  CommunityPost(
    title: '맛있는 우유 900ml 1개',
    place: '상지마트 앞',
    time: '오늘 19:30',
    current: 1,
    capacity: 1,
    pricePerPerson: 1600,
    imageUrl:
        'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800&q=80',
  ),
];

const recipeSuggestions = [
  RecipeSuggestion(
    title: '1만원 이하 제육볶음',
    reason: '돼지고기 특가 + 보유 양파 활용',
    time: '20분',
    difficulty: '쉬움',
    budget: 9200,
    imageUrl:
        'https://images.unsplash.com/photo-1628294895950-9805252327bc?w=800&q=80',
    ingredients: ['돼지고기', '양파', '대파', '고춧가루', '간장', '설탕', '식용유'],
    steps: [
      '돼지고기는 먹기 좋은 크기로 썰고 양파와 대파를 준비합니다.',
      '고춧가루, 간장, 설탕을 섞어 양념장을 만듭니다.',
      '팬에 식용유를 두르고 돼지고기를 먼저 볶습니다.',
      '양파와 대파, 양념장을 넣고 센 불에서 빠르게 볶아 마무리합니다.',
    ],
    relatedDealIds: ['pork_front', 'onion', 'soy_sauce', 'oil'],
    tag: '돼지고기 특가',
  ),
  RecipeSuggestion(
    title: '계란 대파 볶음밥',
    reason: '계란 특가 + 기본 조미료 활용',
    time: '15분',
    difficulty: '쉬움',
    budget: 4800,
    imageUrl:
        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&q=80',
    ingredients: ['계란', '대파', '밥', '소금', '간장', '식용유'],
    steps: [
      '대파를 잘게 썰고 계란은 소금 약간을 넣어 풀어둡니다.',
      '팬에 식용유를 두르고 대파를 볶아 향을 냅니다.',
      '계란을 넣어 반쯤 익힌 뒤 밥을 넣고 고슬하게 볶습니다.',
      '간장으로 간을 맞추고 센 불에서 한 번 더 볶아냅니다.',
    ],
    relatedDealIds: ['egg', 'soy_sauce', 'oil'],
    tag: '냉장고 비우기',
  ),
  RecipeSuggestion(
    title: '양파 듬뿍 카레',
    reason: '대용량 양파 소분 + 감자 특가 조합',
    time: '35분',
    difficulty: '보통',
    budget: 7800,
    imageUrl:
        'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=800&q=80',
    ingredients: ['양파', '감자', '당근', '카레가루', '식용유', '밥'],
    steps: [
      '양파, 감자, 당근을 한입 크기로 썰어 준비합니다.',
      '냄비에 식용유를 두르고 양파를 충분히 볶아 단맛을 냅니다.',
      '감자와 당근을 넣고 볶은 뒤 물을 부어 익힙니다.',
      '카레가루를 풀어 넣고 농도가 날 때까지 끓인 뒤 밥과 함께 냅니다.',
    ],
    relatedDealIds: ['onion', 'potato', 'oil'],
    tag: '소분모임 연계',
  ),
];

const receiptSummaries = [
  ReceiptSummary(
    date: '4.28',
    martName: '행복한식자재마트 단구점',
    description: '계란 외 4건',
    amount: 24500,
  ),
  ReceiptSummary(
    date: '4.24',
    martName: '하나로마트 판부농협본점',
    description: '돼지고기 앞다리살 외 2건',
    amount: 18200,
  ),
];
