import json
import random

categories = {
    'fruit': ['사과', '배', '포도', '수박', '참외', '복숭아', '자두', '딸기', '바나나', '오렌지', '파인애플', '망고'],
    'veg': ['양파', '대파', '마늘', '당근', '감자', '고구마', '배추', '무', '상추', '깻잎', '오이', '호박'],
    'ramen': ['신라면', '진라면', '삼양라면', '너구리', '짜파게티', '안성탕면', '불닭볶음면', '오징어짬뽕', '비빔면', '진짬뽕', '참깨라면', '육개장'],
    'snack': ['새우깡', '포카칩', '꼬깔콘', '오징어땅콩', '맛동산', '홈런볼', '꿀꽈배기', '카스타드', '초코파이', '오예스', '몽쉘', '콘칲'],
    'meat': ['한우 등심', '돼지 삼겹살', '닭볶음탕용 닭', '한우 국거리', '돼지 목살', '닭가슴살', '오리고기', '계란 30구', '메추리알', '소불고기'],
    'processed': ['두루마리 휴지', '세탁세제', '주방세제', '샴푸', '린스', '바디워시', '치약', '칫솔', '물티슈', '섬유유연제']
}

marts = ['행복한 식자재마트', '하나로마트 율량점', '대대로 마트', '로켓프레시', '이마트 에브리데이']

images = {
    'fruit': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=200&q=80',
    'veg': 'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=200&q=80',
    'ramen': 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=200&q=80',
    'snack': 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80',
    'meat': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=200&q=80',
    'processed': 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=200&q=80'
}

products = []

for cat, items in categories.items():
    for i in range(10):
        item_name = items[i % len(items)]
        if cat == 'fruit':
            name = f"신선한 {item_name} (1kg)"
            base_price = random.randint(5000, 15000)
        elif cat == 'veg':
            name = f"유기농 {item_name} (1단/1봉)"
            base_price = random.randint(2000, 8000)
        elif cat == 'ramen':
            name = f"{item_name} (5입 멀티팩)"
            base_price = random.randint(3500, 5000)
        elif cat == 'snack':
            name = f"인기 {item_name} (대용량)"
            base_price = random.randint(2000, 4000)
        elif cat == 'meat':
            name = f"무항생제 {item_name} (500g)"
            base_price = random.randint(10000, 35000)
        elif cat == 'processed':
            name = f"생활 필수 {item_name}"
            base_price = random.randint(3000, 15000)
            
        discount_rate = random.randint(10, 40)
        price = int(base_price * (1 - discount_rate/100))
        price = (price // 100) * 100
        
        mart = random.choice(marts)
        
        prod_id = f"prod_{cat}_{i}"
        
        # Format string for prices
        price_str = f"₩{price:,}"
        orig_price_str = f"₩{base_price:,}"
        
        comparisons = []
        # Generate 3 comparisons
        comps_marts = random.sample(marts, 3)
        if mart not in comps_marts:
            comps_marts[0] = mart
            
        is_cheapest_assigned = False
        for c_mart in comps_marts:
            c_price = price if c_mart == mart else price + random.randint(500, 2000)
            c_price = (c_price // 100) * 100
            
            is_ch = False
            if c_mart == mart:
                is_ch = True
                
            comparisons.append({
                "mart": c_mart,
                "product": name,
                "price": f"₩{c_price:,}",
                "isCheapest": is_ch
            })
            
        # Ensure comparisons are sorted by price (cheapest first)
        comparisons.sort(key=lambda x: int(x['price'].replace('₩','').replace(',','')))
        comparisons[0]['isCheapest'] = True
        for j in range(1, len(comparisons)):
            comparisons[j]['isCheapest'] = False
            
        products.append({
            "id": prod_id,
            "category": cat,
            "img": images[cat],
            "badge": f"{discount_rate}% {mart[:4]}",
            "title": name,
            "discount": f"{discount_rate}%",
            "price": price_str,
            "originalPrice": orig_price_str,
            "desc": f"고객님들의 많은 사랑을 받고 있는 {name}입니다. 신선도와 품질을 보장합니다.",
            "mart": mart,
            "comparisons": comparisons
        })

# Output JS code to append to app.js
js_code = f"\n\n// Generated Product Data\nconst generatedProducts = {json.dumps(products, ensure_ascii=False, indent=4)};\n\n"
js_code += """
generatedProducts.forEach(p => {
    productData[p.id] = p;
});

window.filterHomeProducts = function(category) {
    // Update active tag
    const tags = document.querySelectorAll('#home-filter-tags .tag');
    tags.forEach(t => t.classList.remove('active'));
    event.target.classList.add('active');

    const list = document.getElementById('home-product-list');
    if (!list) return;

    let html = '';
    generatedProducts.forEach(p => {
        if (category === 'all' || p.category === category) {
            html += `
                <div class="product-item" onclick="openProductDetail('${p.id}')" style="cursor:pointer;">
                    <img src="${p.img}" alt="${p.title}" class="prod-img">
                    <div class="prod-info">
                        <div class="prod-badge">${p.badge}</div>
                        <h3 style="font-size: 0.95rem; margin: 8px 0 5px;">${p.title}</h3>
                        <p class="prod-price"><strong>${p.price}</strong> <del style="color:var(--gray); font-size:0.8rem;">${p.originalPrice}</del></p>
                    </div>
                    <button class="add-cart-btn" onclick="event.stopPropagation(); window.addToCart('${p.title}', '${p.mart}', '${p.price}')"><i class="fas fa-plus"></i></button>
                </div>
            `;
        }
    });
    list.innerHTML = html;
};

// Initial render
document.addEventListener('DOMContentLoaded', () => {
    const list = document.getElementById('home-product-list');
    if (list && generatedProducts.length > 0) {
        // Mock a click on '전체보기' to render all
        filterHomeProducts('all');
        const firstTag = document.querySelector('#home-filter-tags .tag');
        if(firstTag) firstTag.classList.add('active');
    }
});
"""

with open('/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js', 'a', encoding='utf-8') as f:
    f.write(js_code)

print("Generated and appended 60 products to app.js")
