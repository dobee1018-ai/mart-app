import json
import re

image_map = {
    '사과': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6faa6?w=200&q=80',
    '배': 'https://images.unsplash.com/photo-1514756331096-242fdeb70d4a?w=200&q=80',
    '포도': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=200&q=80',
    '수박': 'https://images.unsplash.com/photo-1589984662646-e7b2e4962f18?w=200&q=80',
    '참외': 'https://images.unsplash.com/photo-1574856344991-afa31b4941c5?w=200&q=80',
    '복숭아': 'https://images.unsplash.com/photo-1528821128474-27f963b062bf?w=200&q=80',
    '자두': 'https://images.unsplash.com/photo-1601379327628-2ce1031d2797?w=200&q=80',
    '딸기': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200&q=80',
    '바나나': 'https://images.unsplash.com/photo-1571501679680-de32f1e7aad4?w=200&q=80',
    '오렌지': 'https://images.unsplash.com/photo-1547514701-42782101795e?w=200&q=80',
    '파인애플': 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=200&q=80',
    '망고': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=200&q=80',
    
    '양파': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&q=80',
    '대파': 'https://images.unsplash.com/photo-1596482161727-deee12521c7e?w=200&q=80',
    '마늘': 'https://images.unsplash.com/photo-1540148426945-14733325a500?w=200&q=80',
    '당근': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200&q=80',
    '감자': 'https://images.unsplash.com/photo-1518977676601-b140985fdea5?w=200&q=80',
    '고구마': 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?w=200&q=80',
    '배추': 'https://images.unsplash.com/photo-1556801712-76c8eb07bbc9?w=200&q=80',
    '무': 'https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80',
    '상추': 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=200&q=80',
    '깻잎': 'https://images.unsplash.com/photo-1628773822503-ca2eb471804c?w=200&q=80',
    '오이': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=200&q=80',
    '호박': 'https://images.unsplash.com/photo-1570586437263-ab629fccc818?w=200&q=80',

    '한우 등심': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=200&q=80',
    '돼지 삼겹살': 'https://images.unsplash.com/photo-1628268909376-e8c44bb3153f?w=200&q=80',
    '닭볶음탕용 닭': 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=200&q=80',
    '한우 국거리': 'https://images.unsplash.com/photo-1551028150-64b9e398f678?w=200&q=80',
    '돼지 목살': 'https://images.unsplash.com/photo-1602491453631-e2a5fc9f9f23?w=200&q=80',
    '닭가슴살': 'https://images.unsplash.com/photo-1532550907401-4fa39af42a78?w=200&q=80',
    '오리고기': 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=200&q=80',
    '계란 30구': 'eggs.png',
    '메추리알': 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=200&q=80',
    '소불고기': 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=200&q=80',
    
    '신라면': 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=200&q=80',
    '진라면': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&q=80',
    '삼양라면': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&q=80',
    '너구리': 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=200&q=80',
    '짜파게티': 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=200&q=80',
    '안성탕면': 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=200&q=80',
    '불닭볶음면': 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=200&q=80',
    '오징어짬뽕': 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=200&q=80',
    '비빔면': 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=200&q=80',
    
    '새우깡': 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80',
    '포카칩': 'https://images.unsplash.com/photo-1566478989037-e924e50ba0b4?w=200&q=80',
    '꼬깔콘': 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80',
    '맛동산': 'https://images.unsplash.com/photo-1566478989037-e924e50ba0b4?w=200&q=80',
    '초코파이': 'https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?w=200&q=80',
    '몽쉘': 'https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?w=200&q=80',
    
    '두루마리 휴지': 'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=200&q=80',
    '세탁세제': 'https://images.unsplash.com/photo-1584820927508-ea2b73af8e48?w=200&q=80',
    '주방세제': 'https://images.unsplash.com/photo-1585832770485-e68a5dbfa5cd?w=200&q=80',
    '샴푸': 'https://images.unsplash.com/photo-1585232004423-244e0e6904e3?w=200&q=80',
    '바디워시': 'https://images.unsplash.com/photo-1585232004423-244e0e6904e3?w=200&q=80',
    '치약': 'https://images.unsplash.com/photo-1559598467-f8b76c8155d0?w=200&q=80',
    '칫솔': 'https://images.unsplash.com/photo-1559598467-f8b76c8155d0?w=200&q=80',
    '물티슈': 'https://images.unsplash.com/photo-1584483749714-d85ec6f1ce3e?w=200&q=80'
}

with open('/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js', 'r', encoding='utf-8') as f:
    content = f.read()

match = re.search(r'const generatedProducts = (\[.*\]);\s+generatedProducts\.forEach', content, flags=re.DOTALL)
if match:
    data_str = match.group(1)
    try:
        products = json.loads(data_str)
        for p in products:
            for keyword, url in image_map.items():
                if keyword in p['title']:
                    p['img'] = url
                    break
        
        new_data_str = json.dumps(products, ensure_ascii=False, indent=4)
        new_content = content[:match.start(1)] + new_data_str + content[match.end(1):]
        
        with open('/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js', 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Successfully updated images.")
    except Exception as e:
        print("Error parsing json:", e)
else:
    print("Could not find generatedProducts block.")
