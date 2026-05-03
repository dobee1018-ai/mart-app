import sys

recipe_logic = """
// Recipe Data
const recipeData = {
    'spicy_pork': {
        title: '매콤달콤 황금비율 제육볶음',
        img: 'https://images.unsplash.com/photo-1628294895950-9805252327bc?w=800&q=80',
        tag: '돼지고기 반값 특가 활용',
        tagColor: 'bg-orange',
        meta: '<i class="far fa-clock"></i> 조리시간: 20분 · <i class="fas fa-signal"></i> 난이도: 쉬움',
        ingredients: [
            { name: '돼지고기 앞다리살/목살', status: '할인중', highlight: true },
            { name: '양파', status: '할인중', highlight: true },
            { name: '대파', status: '할인중', highlight: true },
            { name: '고추장/진간장', status: '보유중', highlight: false }
        ],
        steps: [
            '돼지고기는 먹기 좋은 크기로 썰고, 양파는 채 썰고, 대파는 어슷썰어 준비합니다.',
            '고추장, 간장, 고춧가루, 다진마늘, 설탕, 참기름을 섞어 양념장을 만듭니다.',
            '프라이팬에 기름을 약간 두르고 돼지고기를 먼저 볶아줍니다. 겉면이 익으면 야채를 넣습니다.',
            '야채가 숨이 죽으면 양념장을 넣고 타지 않게 중불에서 빠르게 볶아내면 완성!'
        ],
        searchKeywords: ['돼지 삼겹살', '돼지 목살', '양파', '대파']
    },
    'shin_toowoomba': {
        title: '꾸덕꾸덕 신라면 투움바 파스타',
        img: 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800&q=80',
        tag: '신라면 할인 활용',
        tagColor: 'bg-yellow',
        meta: '<i class="far fa-clock"></i> 조리시간: 15분 · <i class="fas fa-signal"></i> 난이도: 보통',
        ingredients: [
            { name: '신라면', status: '할인중', highlight: true },
            { name: '우유', status: '할인중', highlight: true },
            { name: '양파', status: '할인중', highlight: true },
            { name: '베이컨/소시지', status: '보유중', highlight: false }
        ],
        steps: [
            '양파와 소시지를 먹기 좋게 썰어 팬에 버터를 두르고 볶습니다.',
            '우유 200ml를 붓고 끓어오르면 신라면 면과 스프를 1/2만 넣습니다.',
            '면이 익으면서 국물이 꾸덕해질 때까지 졸여줍니다.',
            '기호에 따라 슬라이스 치즈를 넣고 잘 저어주면 완성!'
        ],
        searchKeywords: ['신라면', '양파', '우유']
    },
    'fruit_salad': {
        title: '상큼폭발 제철 과일 샐러드',
        img: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
        tag: '신선 과일 특가',
        tagColor: 'bg-blue',
        meta: '<i class="far fa-clock"></i> 조리시간: 10분 · <i class="fas fa-signal"></i> 난이도: 아주 쉬움',
        ingredients: [
            { name: '사과', status: '할인중', highlight: true },
            { name: '딸기', status: '할인중', highlight: true },
            { name: '바나나', status: '할인중', highlight: true },
            { name: '요거트/마요네즈', status: '보유중', highlight: false }
        ],
        steps: [
            '사과, 딸기, 바나나 등 준비된 과일을 한 입 크기로 깍둑썰기 합니다.',
            '넓은 볼에 과일을 담고 취향에 따라 요거트나 마요네즈를 뿌립니다.',
            '과일이 뭉개지지 않게 살살 버무려줍니다.',
            '견과류를 살짝 뿌려주면 더욱 고소하고 맛있는 과일 샐러드 완성!'
        ],
        searchKeywords: ['사과', '딸기', '바나나']
    }
};

window.openRecipeDetail = function(recipeId) {
    const data = recipeData[recipeId];
    if (!data) return;
    
    document.getElementById('rd-img').src = data.img;
    document.getElementById('rd-title').textContent = data.title;
    
    const tagEl = document.getElementById('rd-tag');
    tagEl.className = 'recipe-tag mb-10 ' + data.tagColor;
    tagEl.textContent = data.tag;
    
    document.getElementById('rd-meta').innerHTML = data.meta;
    
    // Ingredients
    let ingHtml = '';
    data.ingredients.forEach(ing => {
        const statusBadge = ing.highlight 
            ? `<span class="badge" style="background:var(--primary);">${ing.status}</span>`
            : `<span class="text-primary font-weight-bold"><i class="fas fa-check-circle"></i> ${ing.status}</span>`;
            
        ingHtml += `
            <li style="padding: 12px 0; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items:center;">
                <span style="font-size: 1.05rem;">${ing.name}</span> ${statusBadge}
            </li>
        `;
    });
    document.getElementById('rd-ingredients').innerHTML = ingHtml;
    
    // Steps
    let stepHtml = '';
    data.steps.forEach((step, index) => {
        stepHtml += `
            <div class="step-item mb-20" style="display:flex; gap: 15px;">
                <div class="step-num" style="background:var(--primary); color:white; width: 32px; height: 32px; border-radius: 50%; display:flex; justify-content:center; align-items:center; font-weight:bold; flex-shrink: 0;">${index + 1}</div>
                <p style="line-height:1.5; padding-top:5px;">${step}</p>
            </div>
        `;
    });
    document.getElementById('rd-steps').innerHTML = stepHtml;
    
    // Required Products
    let prodHtml = '';
    const foundIds = new Set();
    
    data.searchKeywords.forEach(keyword => {
        // Find matching product in generatedProducts
        const match = generatedProducts.find(p => p.title.includes(keyword) && !foundIds.has(p.id));
        if (match) {
            foundIds.add(match.id);
            prodHtml += `
                <div class="small-prod-card" style="min-width: 140px; max-width: 140px; border: 1px solid var(--border); border-radius: 12px; overflow: hidden; background: white; flex-shrink: 0; box-shadow: 0 2px 4px rgba(0,0,0,0.05);" onclick="openProductDetail('${match.id}')">
                    <img src="${match.img}" style="width: 100%; height: 90px; object-fit: cover;">
                    <div style="padding: 10px;">
                        <span style="font-size: 0.7rem; color: var(--primary); font-weight: bold;">${match.discount} 할인</span>
                        <h4 style="font-size: 0.85rem; margin: 4px 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${match.title}</h4>
                        <strong style="font-size: 0.95rem; color: var(--dark);">${match.price}</strong>
                    </div>
                </div>
            `;
        }
    });
    
    if(prodHtml === '') {
        prodHtml = '<p style="color:var(--gray); font-size:0.9rem;">현재 일치하는 할인 상품이 없습니다.</p>';
    }
    
    document.getElementById('rd-products').innerHTML = prodHtml;
    
    navigateTo('view-recipe-detail');
};
"""

with open('/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js', 'a', encoding='utf-8') as f:
    f.write(recipe_logic)

print("Appended recipe logic using python.")
