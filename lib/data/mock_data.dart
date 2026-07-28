import '../models/models.dart';

const List<Map<String, dynamic>> categories = [
  {'id': 'electronics', 'name': '전자기기', 'icon': '📱'},
  {'id': 'clothing', 'name': '의류', 'icon': '👔'},
  {'id': 'wallet', 'name': '지갑/카드', 'icon': '👛'},
  {'id': 'accessories', 'name': '액세서리', 'icon': '⌚'},
  {'id': 'etc', 'name': '기타', 'icon': '📦'},
];

final List<LostItem> mockLostItems = [
  LostItem(
    id: '1',
    category: 'electronics',
    title: '아이폰 15 Pro',
    description: '강남역 2번 출구 근처에서 습득했습니다. 티타늄 블랙 색상이며 케이스가 씌워져 있습니다.',
    imageUrl: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400',
    createdAt: DateTime(2026, 5, 3),
    location: '강남역 2번 출구',
    mapPos: const MapPos(x: 55, y: 62),
    quizzes: const [
      Quiz(question: '이 폰의 케이스 색상은 무엇인가요?', type: 'multiple', options: ['검정색', '파란색', '투명', '분홍색'], correctAnswer: 2),
      Quiz(question: '폰 잠금화면 배경은 무엇인가요?', type: 'multiple', options: ['풍경', '강아지', '우주', '단색'], correctAnswer: 1),
      Quiz(question: '케이스 뒷면에 있는 스티커는?', type: 'text', correctAnswer: '별'),
    ],
  ),
  LostItem(
    id: '2',
    category: 'wallet',
    title: '갈색 가죽 지갑',
    description: '홍대입구역 근처 카페 의자 밑에 있었습니다. 여러 장의 카드가 들어있어요.',
    imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400',
    createdAt: DateTime(2026, 5, 2),
    location: '홍대입구역 카페',
    mapPos: const MapPos(x: 28, y: 38),
    quizzes: const [
      Quiz(question: '지갑 안에 들어있는 카드 개수는?', type: 'multiple', options: ['2-3장', '4-5장', '6-7장', '8장 이상'], correctAnswer: 1),
      Quiz(question: '지갑의 브랜드는?', type: 'multiple', options: ['구찌', '루이비통', '프라다', '노브랜드'], correctAnswer: 3),
      Quiz(question: '지갑 안 명함에 적힌 회사명은?', type: 'text', correctAnswer: '스타트업코리아'),
    ],
  ),
  LostItem(
    id: '3',
    category: 'clothing',
    title: '검정 패딩 점퍼',
    description: '신촌 버스정류장 벤치에 놓여있던 것을 발견했습니다.',
    imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
    createdAt: DateTime(2026, 5, 1),
    location: '신촌 버스정류장',
    mapPos: const MapPos(x: 33, y: 32),
    quizzes: const [
      Quiz(question: '패딩의 브랜드는 무엇인가요?', type: 'multiple', options: ['노스페이스', '파타고니아', '네파', '콜롬비아'], correctAnswer: 0),
      Quiz(question: '패딩 사이즈는?', type: 'multiple', options: ['S', 'M', 'L', 'XL'], correctAnswer: 2),
      Quiz(question: '주머니에 들어있던 물건은?', type: 'text', correctAnswer: '장갑'),
    ],
  ),
  LostItem(
    id: '4',
    category: 'accessories',
    title: '은색 손목시계',
    description: '이대역 근처 음식점 테이블에 있었습니다. 고급스러운 메탈 밴드 시계입니다.',
    imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=400',
    createdAt: DateTime(2026, 4, 30),
    location: '이대역 음식점',
    mapPos: const MapPos(x: 30, y: 34),
    quizzes: const [
      Quiz(question: '시계 브랜드를 고르세요', type: 'multiple', options: ['세이코', '시티즌', '카시오', '오리엔트'], correctAnswer: 2),
      Quiz(question: '시계 밴드 재질은?', type: 'multiple', options: ['가죽', '메탈', '고무', '천'], correctAnswer: 1),
      Quiz(question: '시계 뒷면 각인 이니셜은?', type: 'text', correctAnswer: 'KSH'),
    ],
  ),
  LostItem(
    id: '5',
    category: 'electronics',
    title: '에어팟 프로 2세대',
    description: '합정역 5번 출구 근처 편의점 앞에서 발견했습니다. 케이스째로 있어요.',
    imageUrl: 'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=400',
    createdAt: DateTime(2026, 4, 29),
    location: '합정역 5번 출구',
    mapPos: const MapPos(x: 24, y: 40),
    quizzes: const [
      Quiz(question: '케이스의 각인 이니셜은?', type: 'multiple', options: ['없음', 'J.K', 'S.H', 'M.Y'], correctAnswer: 1),
      Quiz(question: '에어팟 케이스 색상은?', type: 'multiple', options: ['화이트', '블랙', '실버', '골드'], correctAnswer: 0),
      Quiz(question: '케이스에 붙어있는 키링 색은?', type: 'text', correctAnswer: '파랑'),
    ],
  ),
  LostItem(
    id: '6',
    category: 'etc',
    title: '노란색 우산',
    description: '잠실역 롯데월드몰 내부 우산꽂이 옆에 있었습니다.',
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    createdAt: DateTime(2026, 4, 28),
    location: '잠실역 롯데월드몰',
    mapPos: const MapPos(x: 68, y: 63),
    quizzes: const [
      Quiz(question: '우산 손잡이 모양은?', type: 'multiple', options: ['일자형', '곡선형', '나무손잡이', '투명'], correctAnswer: 2),
      Quiz(question: '우산 크기는?', type: 'multiple', options: ['장우산', '2단 우산', '3단 우산', '자동우산'], correctAnswer: 2),
      Quiz(question: '우산 손잡이에 적힌 글자는?', type: 'text', correctAnswer: 'HAPPY'),
    ],
  ),
  LostItem(
    id: '7',
    category: 'wallet',
    title: '교통카드 (티머니)',
    description: '종로3가역 부근 지하철 좌석에서 발견했습니다.',
    createdAt: DateTime(2026, 4, 27),
    location: '종로3가역',
    mapPos: const MapPos(x: 47, y: 30),
    quizzes: const [
      Quiz(question: '카드 뒷면에 적힌 이름의 성은?', type: 'multiple', options: ['김', '이', '박', '최'], correctAnswer: 0),
      Quiz(question: '카드 종류는?', type: 'multiple', options: ['티머니', '캐시비', '레일플러스', '마이비'], correctAnswer: 0),
      Quiz(question: '카드에 붙은 스티커 캐릭터는?', type: 'text', correctAnswer: '카카오프렌즈'),
    ],
  ),
];

final List<AngelUser> mockAngelUsers = [
  const AngelUser(id: '1', name: '김천사', avatar: '😇', itemsFound: 42, points: 1250),
  const AngelUser(id: '2', name: '이착한', avatar: '🌟', itemsFound: 38, points: 1140),
  const AngelUser(id: '3', name: '박선행', avatar: '✨', itemsFound: 35, points: 1050),
  const AngelUser(id: '4', name: '최따뜻', avatar: '💝', itemsFound: 28, points: 840),
  const AngelUser(id: '5', name: '정나눔', avatar: '🎁', itemsFound: 24, points: 720),
];

List<ChatThread> mockChatThreads = [
  ChatThread(
    id: '1',
    itemTitle: '아이폰 15 Pro',
    itemEmoji: '📱',
    otherUser: '김천사',
    otherAvatar: '😇',
    lastMessage: '안녕하세요! 강남역 근처에 계신가요?',
    lastTime: '방금',
    unread: 2,
    messages: const [
      ChatMessage(id: 'm1', senderId: 'other', text: '안녕하세요! 아이폰 퀴즈를 맞추셨군요 🎉', time: '14:20'),
      ChatMessage(id: 'm2', senderId: 'me', text: '네! 제 폰이 맞아요. 언제 받을 수 있을까요?', time: '14:21'),
      ChatMessage(id: 'm3', senderId: 'other', text: '강남역 근처에 계신가요? 오늘 저녁에 만날 수 있어요', time: '14:22'),
      ChatMessage(id: 'm4', senderId: 'other', text: '안녕하세요! 강남역 근처에 계신가요?', time: '14:35'),
    ],
  ),
  ChatThread(
    id: '2',
    itemTitle: '갈색 가죽 지갑',
    itemEmoji: '👛',
    otherUser: '이착한',
    otherAvatar: '🌟',
    lastMessage: '지갑 잘 받았습니다. 정말 감사해요!',
    lastTime: '어제',
    unread: 0,
    messages: const [
      ChatMessage(id: 'm1', senderId: 'other', text: '지갑을 홍대 카페에서 발견했어요!', time: '09:00'),
      ChatMessage(id: 'm2', senderId: 'me', text: '정말요?! 감사합니다 ㅠㅠ', time: '09:05'),
      ChatMessage(id: 'm3', senderId: 'other', text: '홍대입구역 2번 출구 스타벅스에서 드릴게요', time: '09:10'),
      ChatMessage(id: 'm4', senderId: 'me', text: '지갑 잘 받았습니다. 정말 감사해요!', time: '11:30'),
    ],
  ),
];

final List<ShopItem> mockShopItems = [
  const ShopItem(id: 's1', title: '스타벅스 아메리카노', description: '따뜻하거나 차갑게', cost: 150, emoji: '☕', category: '카페', stock: 10),
  const ShopItem(id: 's2', title: 'CU 편의점 3천원 쿠폰', description: '전 상품 사용 가능', cost: 80, emoji: '🏪', category: '편의점', stock: 20),
  const ShopItem(id: 's3', title: '유니세프 1,000원 기부', description: '선행 포인트로 기부하기', cost: 30, emoji: '💝', category: '기부', stock: 999),
  const ShopItem(id: 's4', title: '배달의민족 2천원 쿠폰', description: '1만원 이상 주문 시', cost: 60, emoji: '🍜', category: '배달', stock: 15),
  const ShopItem(id: 's5', title: '영화관 팝콘 교환권', description: 'CGV/롯데시네마', cost: 120, emoji: '🍿', category: '영화', stock: 5),
  const ShopItem(id: 's6', title: '이마트24 5천원 쿠폰', description: '5천원 이상 구매 시', cost: 130, emoji: '🛒', category: '편의점', stock: 8),
  const ShopItem(id: 's7', title: '초록우산 어린이재단 기부', description: '아이들에게 희망을', cost: 50, emoji: '🌱', category: '기부', stock: 999),
  const ShopItem(id: 's8', title: '네이버페이 포인트 1천P', description: '즉시 지급', cost: 200, emoji: '💳', category: '포인트', stock: 30),
];

const Map<String, String> categoryEmoji = {
  'electronics': '📱',
  'wallet': '👛',
  'clothing': '👔',
  'accessories': '⌚',
  'etc': '📦',
};

const Map<String, int> categoryColors = {
  'electronics': 0xFF5B9BF2,
  'wallet': 0xFFF28BAA,
  'clothing': 0xFF8FC7EF,
  'accessories': 0xFFAE8FE8,
  'etc': 0xFFE8C48A,
};

const List<Map<String, dynamic>> districts = [
  {'name': '은평구', 'x': 22.0, 'y': 20.0},
  {'name': '서대문구', 'x': 33.0, 'y': 31.0},
  {'name': '마포구', 'x': 28.0, 'y': 40.0},
  {'name': '종로구', 'x': 46.0, 'y': 28.0},
  {'name': '중구', 'x': 50.0, 'y': 36.0},
  {'name': '용산구', 'x': 47.0, 'y': 44.0},
  {'name': '성동구', 'x': 60.0, 'y': 39.0},
  {'name': '강서구', 'x': 16.0, 'y': 55.0},
  {'name': '영등포구', 'x': 28.0, 'y': 55.0},
  {'name': '동작구', 'x': 39.0, 'y': 60.0},
  {'name': '서초구', 'x': 47.0, 'y': 66.0},
  {'name': '강남구', 'x': 58.0, 'y': 64.0},
  {'name': '송파구', 'x': 68.0, 'y': 64.0},
  {'name': '강동구', 'x': 76.0, 'y': 57.0},
  {'name': '광진구', 'x': 65.0, 'y': 44.0},
  {'name': '노원구', 'x': 65.0, 'y': 14.0},
  {'name': '도봉구', 'x': 55.0, 'y': 10.0},
  {'name': '강북구', 'x': 48.0, 'y': 16.0},
  {'name': '성북구', 'x': 56.0, 'y': 24.0},
  {'name': '동대문구', 'x': 60.0, 'y': 31.0},
  {'name': '중랑구', 'x': 68.0, 'y': 30.0},
  {'name': '관악구', 'x': 37.0, 'y': 68.0},
];

const List<Map<String, dynamic>> recentActivity = [
  {'id': 1, 'icon': '🎉', 'text': '김천사님이 아이폰 매칭 성공', 'time': '3분 전', 'type': 'match'},
  {'id': 2, 'icon': '📦', 'text': '이착한님이 지갑을 등록했어요', 'time': '12분 전', 'type': 'register'},
  {'id': 3, 'icon': '🔍', 'text': '박선행님이 갤럭시 워치를 찾았어요', 'time': '34분 전', 'type': 'found'},
  {'id': 4, 'icon': '✅', 'text': '에어팟 매칭 완료!', 'time': '1시간 전', 'type': 'match'},
];
