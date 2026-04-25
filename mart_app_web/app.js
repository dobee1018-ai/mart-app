const views = document.querySelectorAll('.view');
const navItems = document.querySelectorAll('.nav-item');
const headerTitle = document.getElementById('header-title');
const backBtn = document.getElementById('back-btn');

// View Titles
const viewTitles = {
    'view-home': '우리 동네 핫딜 🔥',
    'view-flyers': '우리 동네 전단지',
    'view-community': '우리 동네 소분모임',
    'view-recipe': '오늘 저녁 뭐 먹지?',
    'view-memo': '장보기 메모',
    'view-mypage': '마이페이지',
    'view-mart-detail': '마트 상세정보',
    'view-receipt-record': '이달의 소비 기록',
    'view-write-review': '리뷰 작성',
    'view-report-info': '정보 제보',
    'view-product-detail': '상품 상세',
    'view-community-detail': '소분모임 상세',
    'view-recipe-detail': '레시피 상세',
    'view-point-exchange': '포인트 교환'
};

// Navigation History
let historyList = ['view-home'];

// Global Navigation Function
window.navigateTo = function(targetId, isBack = false) {
    views.forEach(view => {
        view.classList.remove('active');
    });

    const targetView = document.getElementById(targetId);
    if (targetView) {
        targetView.classList.add('active');
        headerTitle.textContent = viewTitles[targetId] || '마트 할인 앱';
        
        // Update Bottom Nav
        navItems.forEach(nav => nav.classList.remove('active'));
        const activeNav = document.querySelector(`.nav-item[data-target="${targetId}"]`);
        if (activeNav) {
            activeNav.classList.add('active');
        }

        // Manage Back Button
        const mainNavIds = ['view-home', 'view-flyers', 'view-community', 'view-recipe', 'view-memo', 'view-mypage'];
        if (mainNavIds.includes(targetId)) {
            backBtn.classList.add('hidden');
            historyList = [targetId];
        } else {
            backBtn.classList.remove('hidden');
            if (!isBack && historyList[historyList.length - 1] !== targetId) {
                historyList.push(targetId);
            }
        }
        
        // Reset home filter if navigating to home
        if (targetId === 'view-home' && window.filterHomeProducts) {
            window.filterHomeProducts('all');
        }
        
        // Scroll to top
        document.getElementById('main-content').scrollTop = 0;
    }
};

// Nav Clicks
navItems.forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        const target = item.getAttribute('data-target');
        window.navigateTo(target);
    });
});

// Back Button
backBtn.addEventListener('click', () => {
    if (historyList.length > 1) {
        historyList.pop(); // Remove current view from history
        const previousView = historyList[historyList.length - 1];
        window.navigateTo(previousView, true);
    }
});

// Add Memo functionality
const addMemoBtn = document.getElementById('add-memo-btn');
const memoInput = document.getElementById('memo-input');
const memoList = document.querySelector('.memo-list');

if (addMemoBtn && memoInput) {
    addMemoBtn.addEventListener('click', () => {
        if (memoInput.value.trim() !== '') {
            const newItem = document.createElement('label');
            newItem.className = 'memo-item';
            newItem.innerHTML = `
                <input type="checkbox">
                <span class="memo-text">${memoInput.value}</span>
            `;
            memoList.appendChild(newItem);
            memoInput.value = '';
        }
    });

    memoInput.addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            addMemoBtn.click();
        }
    });
}

// Star Rating Interaction
const stars = document.querySelectorAll('.star-rating i');
stars.forEach((star, index) => {
    star.addEventListener('click', () => {
        stars.forEach((s, i) => {
            if (i <= index) {
                s.classList.remove('far');
                s.classList.add('fas', 'active');
            } else {
                s.classList.remove('fas', 'active');
                s.classList.add('far');
            }
        });
    });
});

// Report Type Selection
const reportTypes = document.querySelectorAll('.report-type-card');
reportTypes.forEach(card => {
    card.addEventListener('click', () => {
        reportTypes.forEach(c => c.classList.remove('active'));
        card.classList.add('active');
    });
});

// Notification Button
const notiBtn = document.getElementById('noti-btn');
if(notiBtn) {
    notiBtn.addEventListener('click', () => {
        alert('알림: 행복식자재마트 계란(30구) 46% 할인 행사가 진행중입니다!');
    });
}

// Add to Cart functionality
window.cartData = {};

function parsePrice(priceStr) {
    if (!priceStr) return 0;
    return parseInt(priceStr.replace(/[^0-9]/g, '')) || 0;
}

function formatPrice(num) {
    return '₩' + num.toLocaleString();
}

window.renderMypageCart = function() {
    const container = document.getElementById('mypage-cart-container');
    if (!container) return;
    
    if (Object.keys(window.cartData).length === 0) {
        container.innerHTML = `<div style="padding: 20px; text-align: center; background: var(--white); border-radius: 12px; border: 1px dashed var(--border); color: var(--gray);">담은 상품이 없습니다.</div>`;
        return;
    }
    
    let html = '';
    for (const mart in window.cartData) {
        const items = window.cartData[mart];
        let martTotal = 0;
        let itemsHtml = '';
        
        items.forEach((item, index) => {
            martTotal += item.priceNum;
            itemsHtml += `
                <div style="display:flex; justify-content:space-between; margin-bottom: 8px; font-size: 0.95rem;">
                    <span>- ${item.name}</span>
                    <span>${formatPrice(item.priceNum)}</span>
                </div>
            `;
        });
        
        html += `
            <div class="mart-cart-group" style="background: var(--white); padding: 15px; border-radius: 12px; border: 1px solid var(--primary); margin-bottom: 15px; box-shadow: 0 2px 4px rgba(16,185,129,0.05);">
                <h4 style="border-bottom: 1px solid var(--light-gray); padding-bottom: 8px; margin-bottom: 12px; color: var(--dark); display: flex; justify-content: space-between;">
                    <span><i class="fas fa-store text-primary"></i> ${mart}</span>
                    <button class="text-btn text-gray" onclick="window.clearMartCart('${mart}')" style="font-size:0.8rem;"><i class="fas fa-times"></i> 삭제</button>
                </h4>
                ${itemsHtml}
                <div style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed var(--border); display:flex; justify-content:space-between; font-weight: 700;">
                    <span>총 결제 예상 금액</span>
                    <span class="text-primary" style="font-size: 1.15rem;">${formatPrice(martTotal)}</span>
                </div>
                <button class="btn-primary mt-15" style="width: 100%; padding: 12px; font-size: 0.95rem;" onclick="alert('${mart} 결제 페이지로 이동합니다.')">이 마트에서 구매하기</button>
            </div>
        `;
    }
    container.innerHTML = html;
};

window.clearMartCart = function(mart) {
    if (confirm(`${mart} 장바구니를 삭제하시겠습니까?`)) {
        delete window.cartData[mart];
        window.renderMypageCart();
    }
};

window.addToCart = function(productName, martName, priceStr) {
    const cartList = document.getElementById('cart-list');
    if (cartList) {
        // Remove empty message if it exists
        const emptyMsg = document.getElementById('empty-cart-msg');
        if (emptyMsg) {
            emptyMsg.remove();
        }
        
        const newItem = document.createElement('label');
        newItem.className = 'memo-item highlight';
        newItem.innerHTML = `
            <input type="checkbox">
            <div class="memo-content">
                <span class="memo-text">${productName}</span>
                <span class="memo-alert" style="color: var(--primary); font-size: 0.8rem; margin-top: 4px; font-weight: 600; display: block;"><i class="fas fa-shopping-cart"></i> ${martName} ${priceStr ? '- ' + priceStr : ''}</span>
            </div>
        `;
        cartList.insertBefore(newItem, cartList.firstChild);
    }
    
    // 2. 마이페이지 마트별 장바구니 데이터 추가 및 렌더링
    if (!window.cartData[martName]) {
        window.cartData[martName] = [];
    }
    window.cartData[martName].push({
        name: productName,
        priceStr: priceStr,
        priceNum: parsePrice(priceStr)
    });
    window.renderMypageCart();
    
    alert(`장바구니에 추가되었습니다:\n[${martName}] ${productName}`);
};

// Add inventory functionality
const addInvBtn = document.getElementById('add-inv-btn');
const invInput = document.getElementById('inv-input');
const inventoryGrid = document.getElementById('inventory-grid');

if (addInvBtn && invInput) {
    addInvBtn.addEventListener('click', () => {
        if (invInput.value.trim() !== '') {
            const newItem = document.createElement('label');
            newItem.className = 'inv-item';
            newItem.innerHTML = `<input type="checkbox" checked> ${invInput.value}`;
            inventoryGrid.appendChild(newItem);
            invInput.value = '';
        }
    });

    invInput.addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            addInvBtn.click();
        }
    });
}

// Flyer Modal Logic
window.openFlyerModal = function(imgSrc) {
    const modal = document.getElementById('flyer-modal');
    const modalImg = document.getElementById('flyer-modal-img');
    if (modal && modalImg) {
        // Fallback to placeholder if not uploaded yet
        modalImg.onerror = function() {
            this.src = 'https://loremflickr.com/400/400/grocery';
        };
        modalImg.src = imgSrc;
        modal.classList.remove('hidden');
    }
};

window.closeFlyerModal = function() {
    const modal = document.getElementById('flyer-modal');
    if (modal) {
        modal.classList.add('hidden');
    }
};

// Dynamic Product Detail Data
const productData = {
    'hanwoo': {
        img: 'https://loremflickr.com/400/400/grocery',
        badge: '전국단위 특가',
        title: '프리미엄 한우 세트 (1kg)',
        discount: '27%',
        price: '₩110,000',
        originalPrice: '₩150,000',
        desc: '최상급 품질의 한우를 엄선하여 구성한 프리미엄 세트입니다. 명절 선물이나 특별한 날 가족과 함께 즐기기 좋습니다. 당일 입고된 신선한 고기만 판매합니다.',
        comparisons: [
            { mart: '행복한 식자재마트', product: '프리미엄 한우 세트 (1kg)', price: '₩110,000', isCheapest: true },
            { mart: '하나로마트 율량점', product: '무항생제 한우 선물세트 (1kg)', price: '₩125,000', isCheapest: false },
            { mart: '대대로 마트', product: '1등급 한우 모듬 세트 (1.2kg)', price: '₩132,000', isCheapest: false }
        ]
    },
    'egg': {
        img: 'eggs.png',
        badge: '46% 행복 식자재',
        title: '동물복지 유정란 (30구)',
        discount: '46%',
        price: '₩6,900',
        originalPrice: '₩12,800',
        desc: '넓은 사육환경에서 스트레스 없이 자란 닭이 낳은 동물복지 유정란입니다. 신선도가 매우 뛰어나고 고소한 맛이 일품입니다.',
        comparisons: [
            { mart: '행복한 식자재마트', product: '동물복지 유정란 (30구)', price: '₩6,900', isCheapest: true },
            { mart: '하나로마트 율량점', product: '친환경 유정란 (30구)', price: '₩8,500', isCheapest: false },
            { mart: '로켓프레시', product: '무항생제 유정란 대란 30구', price: '₩9,200', isCheapest: false }
        ]
    },
    'strawberry': {
        img: 'https://loremflickr.com/400/400/grocery',
        badge: '25% 하나로마트',
        title: '제철 딸기 (500g)',
        discount: '25%',
        price: '₩7,900',
        originalPrice: '₩10,500',
        desc: '지금이 가장 맛있는 제철 딸기입니다. 당도가 높고 과육이 단단하여 아이들 간식으로 최고입니다.',
        comparisons: [
            { mart: '하나로마트 율량점', product: '제철 딸기 (500g)', price: '₩7,900', isCheapest: true },
            { mart: '행복한 식자재마트', product: '논산 딸기 특품 (500g)', price: '₩8,900', isCheapest: false },
            { mart: '대대로 마트', product: '새벽수확 딸기 (500g)', price: '₩9,500', isCheapest: false }
        ]
    },
    'cake': {
        img: 'https://loremflickr.com/400/400/grocery',
        badge: '로켓프레시 비교가',
        title: '초코 케이크 (1호)',
        discount: '27%',
        price: '₩15,900',
        originalPrice: '₩22,000',
        desc: '진한 초콜릿의 풍미를 느낄 수 있는 수제 초코 케이크입니다. 파티나 기념일을 더욱 특별하게 만들어 줍니다.',
        comparisons: [
            { mart: '로켓프레시', product: '초코 케이크 (1호)', price: '₩15,900', isCheapest: true },
            { mart: '뚜레쥬르', product: '진한 초코 생크림 케이크', price: '₩24,000', isCheapest: false },
            { mart: '파리바게뜨', product: '초코듬뿍 케이크', price: '₩26,000', isCheapest: false }
        ]
    },
    'milk': {
        img: 'https://loremflickr.com/400/400/grocery',
        badge: '30% 행복 식자재',
        title: '맛있는 우유 (900ml)',
        discount: '30%',
        price: '₩1,980',
        originalPrice: '₩2,850',
        desc: '매일매일 신선하게 배달되는 1등급 원유 100% 우유입니다. 고소하고 담백한 맛으로 온 가족이 함께 마시기 좋습니다.',
        comparisons: [
            { mart: '행복한 식자재마트', product: '맛있는 우유 (900ml)', price: '₩1,980', isCheapest: true },
            { mart: '대대로 마트', product: '매일우유 오리지널 (900ml)', price: '₩2,500', isCheapest: false },
            { mart: '하나로마트 율량점', product: '서울우유 (1L)', price: '₩2,850', isCheapest: false }
        ]
    },
    'ramen': {
        img: 'https://loremflickr.com/400/400/grocery',
        badge: '15% 대대로 마트',
        title: '신라면 (5입)',
        discount: '15%',
        price: '₩3,800',
        originalPrice: '₩4,500',
        desc: '한국인이 가장 사랑하는 라면, 얼큰하고 시원한 국물 맛이 일품인 신라면입니다. 5개입 멀티팩으로 더 저렴하게 즐기세요.',
        comparisons: [
            { mart: '대대로 마트', product: '신라면 (5입)', price: '₩3,800', isCheapest: true },
            { mart: '행복한 식자재마트', product: '신라면 (5입)', price: '₩4,100', isCheapest: false },
            { mart: '하나로마트 율량점', product: '신라면 (5입)', price: '₩4,300', isCheapest: false }
        ]
    }
};

window.openProductDetail = function(productId) {
    const data = productData[productId];
    if (!data) return;
    
    let cleanTitle = data.title;
    if (data.mart) {
        cleanTitle = cleanTitle.replace(new RegExp(data.mart, 'g'), '').trim();
        cleanTitle = cleanTitle.replace(/^[\[\]\s]+/, '');
    }
    
    document.getElementById('pd-img').src = data.img;
    
    // Show mart name and badge nicely
    const badgeHtml = `<span style="margin-right: 8px;"><i class="fas fa-store"></i> ${data.mart}</span> <span style="background:var(--primary); color:white; padding:2px 6px; border-radius:4px; font-size:0.8rem;">${data.badge}</span>`;
    const badgeEl = document.getElementById('pd-badge');
    badgeEl.innerHTML = badgeHtml;
    badgeEl.style.background = 'none';
    badgeEl.style.color = 'var(--dark)';
    badgeEl.style.padding = '0';
    
    document.getElementById('pd-title').textContent = cleanTitle;
    
    const discEl = document.getElementById('pd-discount');
    if (data.discount) {
        discEl.textContent = data.discount;
        discEl.style.display = 'inline-block';
    } else {
        discEl.style.display = 'none';
    }
    
    document.getElementById('pd-price').textContent = data.price;
    document.getElementById('pd-original-price').textContent = data.originalPrice;
    document.getElementById('pd-desc').textContent = data.desc;
    
    document.getElementById('pd-cart-btn').onclick = function() {
        window.addToCart(cleanTitle, data.comparisons[0].mart, data.price);
    };
    
    let compHtml = '';
    data.comparisons.forEach(comp => {
        const borderStyle = comp.isCheapest ? 'border: 1.5px solid var(--primary); background: rgba(16, 185, 129, 0.03);' : 'border: 1px solid var(--border); background: var(--white);';
        const badgeHtml = comp.isCheapest ? `<span class="badge mb-5" style="display:inline-block; margin-bottom: 5px;">현재 페이지 (최저가)</span>` : '';
        const priceColor = comp.isCheapest ? 'var(--primary)' : 'var(--dark)';
        const btnStyle = comp.isCheapest ? 'background: var(--primary); color: white;' : '';
        
        compHtml += `
            <div class="comparison-item" style="display:flex; justify-content:space-between; align-items:center; padding: 15px; border-radius: 12px; margin-bottom: 12px; ${borderStyle}">
                <div>
                    ${badgeHtml}
                    <h4 style="font-size: 1.05rem; margin-bottom: 4px;">${comp.mart}</h4>
                    <p style="font-size: 0.85rem; color: var(--gray);">${comp.product}</p>
                </div>
                <div style="text-align: right; display: flex; flex-direction: column; align-items: flex-end;">
                    <strong style="font-size: 1.25rem; color: ${priceColor};">${comp.price}</strong>
                    <button class="add-cart-btn mt-5" style="width: 32px; height: 32px; margin-top: 8px; ${btnStyle}" onclick="window.addToCart('${comp.product}', '${comp.mart}', '${comp.price}')"><i class="fas fa-plus"></i></button>
                </div>
            </div>
        `;
    });
    
    document.getElementById('pd-comparison-list').innerHTML = compHtml;
    
    navigateTo('view-product-detail');
};


// Generated Product Data
const generatedProducts = [
    {
        "id": "new_prod_0_0",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1620619864275-c5464161eb3a?w=200&q=80",
        "badge": "특가",
        "title": "대륙식자재마트 대용량 식용유 (1.8L)",
        "discount": "30%",
        "price": "₩4,200",
        "originalPrice": "₩6,000",
        "desc": "대륙식자재마트에서 제안하는 대용량 식자재 특가입니다.",
        "mart": "대륙식자재마트",
        "comparisons": [
            {
                "mart": "대륙식자재마트",
                "product": "대용량 식용유 (1.8L)",
                "price": "₩4,200",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "식용유 (1.8L)",
                "price": "₩5,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "new_prod_0_1",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&q=80",
        "badge": "박스특가",
        "title": "대륙식자재마트 양파 (15kg/망)",
        "discount": "40%",
        "price": "₩12,000",
        "originalPrice": "₩20,000",
        "desc": "식당 및 대량 소비를 위한 최저가 양파 망 상품입니다.",
        "mart": "대륙식자재마트",
        "comparisons": [
            {
                "mart": "대륙식자재마트",
                "product": "양파 (15kg)",
                "price": "₩12,000",
                "isCheapest": true
            },
            {
                "mart": "하나로마트",
                "product": "양파 (15kg)",
                "price": "₩15,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "new_prod_1_0",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1620619864275-c5464161eb3a?w=200&q=80",
        "badge": "특가",
        "title": "천사 식자재마트 대용량 식용유 (1.8L)",
        "discount": "30%",
        "price": "₩4,200",
        "originalPrice": "₩6,000",
        "desc": "천사 식자재마트에서 제안하는 대용량 식자재 특가입니다.",
        "mart": "천사 식자재마트",
        "comparisons": [
            {
                "mart": "천사 식자재마트",
                "product": "대용량 식용유 (1.8L)",
                "price": "₩4,200",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "식용유 (1.8L)",
                "price": "₩5,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "new_prod_1_1",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&q=80",
        "badge": "박스특가",
        "title": "천사 식자재마트 양파 (15kg/망)",
        "discount": "40%",
        "price": "₩12,000",
        "originalPrice": "₩20,000",
        "desc": "식당 및 대량 소비를 위한 최저가 양파 망 상품입니다.",
        "mart": "천사 식자재마트",
        "comparisons": [
            {
                "mart": "천사 식자재마트",
                "product": "양파 (15kg)",
                "price": "₩12,000",
                "isCheapest": true
            },
            {
                "mart": "하나로마트",
                "product": "양파 (15kg)",
                "price": "₩15,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "new_prod_2_0",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1620619864275-c5464161eb3a?w=200&q=80",
        "badge": "특가",
        "title": "상지 식자재마트 대용량 식용유 (1.8L)",
        "discount": "30%",
        "price": "₩4,200",
        "originalPrice": "₩6,000",
        "desc": "상지 식자재마트에서 제안하는 대용량 식자재 특가입니다.",
        "mart": "상지 식자재마트",
        "comparisons": [
            {
                "mart": "상지 식자재마트",
                "product": "대용량 식용유 (1.8L)",
                "price": "₩4,200",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "식용유 (1.8L)",
                "price": "₩5,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "new_prod_2_1",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&q=80",
        "badge": "박스특가",
        "title": "상지 식자재마트 양파 (15kg/망)",
        "discount": "40%",
        "price": "₩12,000",
        "originalPrice": "₩20,000",
        "desc": "식당 및 대량 소비를 위한 최저가 양파 망 상품입니다.",
        "mart": "상지 식자재마트",
        "comparisons": [
            {
                "mart": "상지 식자재마트",
                "product": "양파 (15kg)",
                "price": "₩12,000",
                "isCheapest": true
            },
            {
                "mart": "하나로마트",
                "product": "양파 (15kg)",
                "price": "₩15,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "new_prod_3_0",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1620619864275-c5464161eb3a?w=200&q=80",
        "badge": "특가",
        "title": "엘마트 대용량 식용유 (1.8L)",
        "discount": "30%",
        "price": "₩4,200",
        "originalPrice": "₩6,000",
        "desc": "엘마트에서 제안하는 대용량 식자재 특가입니다.",
        "mart": "엘마트",
        "comparisons": [
            {
                "mart": "엘마트",
                "product": "대용량 식용유 (1.8L)",
                "price": "₩4,200",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "식용유 (1.8L)",
                "price": "₩5,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "new_prod_3_1",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&q=80",
        "badge": "박스특가",
        "title": "엘마트 양파 (15kg/망)",
        "discount": "40%",
        "price": "₩12,000",
        "originalPrice": "₩20,000",
        "desc": "식당 및 대량 소비를 위한 최저가 양파 망 상품입니다.",
        "mart": "엘마트",
        "comparisons": [
            {
                "mart": "엘마트",
                "product": "양파 (15kg)",
                "price": "₩12,000",
                "isCheapest": true
            },
            {
                "mart": "하나로마트",
                "product": "양파 (15kg)",
                "price": "₩15,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_0",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1560806887-1e4cd0b6faa6?w=200&q=80",
        "badge": "25% 대대로 ",
        "title": "신선한 사과 (1kg)",
        "discount": "25%",
        "price": "₩5,500",
        "originalPrice": "₩7,361",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 사과 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "신선한 사과 (1kg)",
                "price": "₩5,500",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "신선한 사과 (1kg)",
                "price": "₩6,600",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "신선한 사과 (1kg)",
                "price": "₩6,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_1",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1514756331096-242fdeb70d4a?w=200&q=80",
        "badge": "26% 이마트 ",
        "title": "신선한 배 (1kg)",
        "discount": "26%",
        "price": "₩4,600",
        "originalPrice": "₩6,248",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 배 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "신선한 배 (1kg)",
                "price": "₩4,600",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "신선한 배 (1kg)",
                "price": "₩5,300",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "신선한 배 (1kg)",
                "price": "₩6,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_2",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=200&q=80",
        "badge": "19% 행복한 ",
        "title": "신선한 포도 (1kg)",
        "discount": "19%",
        "price": "₩7,100",
        "originalPrice": "₩8,834",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 포도 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "신선한 포도 (1kg)",
                "price": "₩7,100",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "신선한 포도 (1kg)",
                "price": "₩7,600",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "신선한 포도 (1kg)",
                "price": "₩8,600",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_3",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1589984662646-e7b2e4962f18?w=200&q=80",
        "badge": "22% 하나로마",
        "title": "신선한 수박 (1kg)",
        "discount": "22%",
        "price": "₩6,900",
        "originalPrice": "₩8,887",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 수박 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "신선한 수박 (1kg)",
                "price": "₩6,900",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "신선한 수박 (1kg)",
                "price": "₩7,900",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "신선한 수박 (1kg)",
                "price": "₩8,700",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_4",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1574856344991-afa31b4941c5?w=200&q=80",
        "badge": "29% 행복한 ",
        "title": "신선한 참외 (1kg)",
        "discount": "29%",
        "price": "₩6,100",
        "originalPrice": "₩8,702",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 참외 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "신선한 참외 (1kg)",
                "price": "₩6,100",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "신선한 참외 (1kg)",
                "price": "₩6,800",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "신선한 참외 (1kg)",
                "price": "₩7,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_5",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1528821128474-27f963b062bf?w=200&q=80",
        "badge": "19% 행복한 ",
        "title": "신선한 복숭아 (1kg)",
        "discount": "19%",
        "price": "₩4,400",
        "originalPrice": "₩5,483",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 복숭아 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "신선한 복숭아 (1kg)",
                "price": "₩4,400",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "신선한 복숭아 (1kg)",
                "price": "₩5,100",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "신선한 복숭아 (1kg)",
                "price": "₩6,300",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_6",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1601379327628-2ce1031d2797?w=200&q=80",
        "badge": "20% 대대로 ",
        "title": "신선한 자두 (1kg)",
        "discount": "20%",
        "price": "₩7,400",
        "originalPrice": "₩9,274",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 자두 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "신선한 자두 (1kg)",
                "price": "₩7,400",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "신선한 자두 (1kg)",
                "price": "₩8,700",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "신선한 자두 (1kg)",
                "price": "₩9,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_7",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200&q=80",
        "badge": "26% 이마트 ",
        "title": "신선한 딸기 (1kg)",
        "discount": "26%",
        "price": "₩5,300",
        "originalPrice": "₩7,209",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 딸기 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "신선한 딸기 (1kg)",
                "price": "₩5,300",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "신선한 딸기 (1kg)",
                "price": "₩6,200",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "신선한 딸기 (1kg)",
                "price": "₩6,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_8",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1571501679680-de32f1e7aad4?w=200&q=80",
        "badge": "31% 이마트 ",
        "title": "신선한 바나나 (1kg)",
        "discount": "31%",
        "price": "₩8,200",
        "originalPrice": "₩11,943",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 바나나 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "신선한 바나나 (1kg)",
                "price": "₩8,200",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "신선한 바나나 (1kg)",
                "price": "₩9,100",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "신선한 바나나 (1kg)",
                "price": "₩9,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_fruit_9",
        "category": "fruit",
        "img": "https://images.unsplash.com/photo-1547514701-42782101795e?w=200&q=80",
        "badge": "38% 대대로 ",
        "title": "신선한 오렌지 (1kg)",
        "discount": "38%",
        "price": "₩7,800",
        "originalPrice": "₩12,595",
        "desc": "고객님들의 많은 사랑을 받고 있는 신선한 오렌지 (1kg)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "신선한 오렌지 (1kg)",
                "price": "₩7,800",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "신선한 오렌지 (1kg)",
                "price": "₩9,500",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "신선한 오렌지 (1kg)",
                "price": "₩9,700",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_0",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&q=80",
        "badge": "35% 대대로 ",
        "title": "유기농 양파 (1단/1봉)",
        "discount": "35%",
        "price": "₩3,300",
        "originalPrice": "₩5,138",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 양파 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "유기농 양파 (1단/1봉)",
                "price": "₩3,300",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "유기농 양파 (1단/1봉)",
                "price": "₩3,900",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "유기농 양파 (1단/1봉)",
                "price": "₩4,700",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_1",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1596482161727-deee12521c7e?w=200&q=80",
        "badge": "11% 대대로 ",
        "title": "유기농 대파 (1단/1봉)",
        "discount": "11%",
        "price": "₩5,500",
        "originalPrice": "₩6,292",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 대파 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "유기농 대파 (1단/1봉)",
                "price": "₩5,500",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "유기농 대파 (1단/1봉)",
                "price": "₩6,500",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "유기농 대파 (1단/1봉)",
                "price": "₩7,200",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_2",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1540148426945-14733325a500?w=200&q=80",
        "badge": "27% 행복한 ",
        "title": "유기농 마늘 (1단/1봉)",
        "discount": "27%",
        "price": "₩2,900",
        "originalPrice": "₩4,073",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 마늘 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "유기농 마늘 (1단/1봉)",
                "price": "₩2,900",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "유기농 마늘 (1단/1봉)",
                "price": "₩3,900",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "유기농 마늘 (1단/1봉)",
                "price": "₩4,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_3",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200&q=80",
        "badge": "22% 행복한 ",
        "title": "유기농 당근 (1단/1봉)",
        "discount": "22%",
        "price": "₩2,300",
        "originalPrice": "₩2,997",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 당근 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "유기농 당근 (1단/1봉)",
                "price": "₩2,300",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "유기농 당근 (1단/1봉)",
                "price": "₩3,600",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "유기농 당근 (1단/1봉)",
                "price": "₩3,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_4",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1518977676601-b140985fdea5?w=200&q=80",
        "badge": "14% 로켓프레",
        "title": "유기농 감자 (1단/1봉)",
        "discount": "14%",
        "price": "₩5,800",
        "originalPrice": "₩6,816",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 감자 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "유기농 감자 (1단/1봉)",
                "price": "₩5,800",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "유기농 감자 (1단/1봉)",
                "price": "₩6,900",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "유기농 감자 (1단/1봉)",
                "price": "₩7,000",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_5",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?w=200&q=80",
        "badge": "32% 행복한 ",
        "title": "유기농 고구마 (1단/1봉)",
        "discount": "32%",
        "price": "₩4,200",
        "originalPrice": "₩6,224",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 고구마 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "유기농 고구마 (1단/1봉)",
                "price": "₩4,200",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "유기농 고구마 (1단/1봉)",
                "price": "₩4,700",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "유기농 고구마 (1단/1봉)",
                "price": "₩5,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_6",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1514756331096-242fdeb70d4a?w=200&q=80",
        "badge": "31% 대대로 ",
        "title": "유기농 배추 (1단/1봉)",
        "discount": "31%",
        "price": "₩3,100",
        "originalPrice": "₩4,501",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 배추 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "유기농 배추 (1단/1봉)",
                "price": "₩3,100",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "유기농 배추 (1단/1봉)",
                "price": "₩4,000",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "유기농 배추 (1단/1봉)",
                "price": "₩4,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_7",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "38% 하나로마",
        "title": "유기농 무 (1단/1봉)",
        "discount": "38%",
        "price": "₩4,700",
        "originalPrice": "₩7,727",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 무 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "유기농 무 (1단/1봉)",
                "price": "₩4,700",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "유기농 무 (1단/1봉)",
                "price": "₩6,100",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "유기농 무 (1단/1봉)",
                "price": "₩6,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_8",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=200&q=80",
        "badge": "29% 로켓프레",
        "title": "유기농 상추 (1단/1봉)",
        "discount": "29%",
        "price": "₩5,000",
        "originalPrice": "₩7,119",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 상추 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "유기농 상추 (1단/1봉)",
                "price": "₩5,000",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "유기농 상추 (1단/1봉)",
                "price": "₩6,200",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "유기농 상추 (1단/1봉)",
                "price": "₩6,900",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_veg_9",
        "category": "veg",
        "img": "https://images.unsplash.com/photo-1628773822503-ca2eb471804c?w=200&q=80",
        "badge": "38% 하나로마",
        "title": "유기농 깻잎 (1단/1봉)",
        "discount": "38%",
        "price": "₩1,300",
        "originalPrice": "₩2,219",
        "desc": "고객님들의 많은 사랑을 받고 있는 유기농 깻잎 (1단/1봉)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "유기농 깻잎 (1단/1봉)",
                "price": "₩1,300",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "유기농 깻잎 (1단/1봉)",
                "price": "₩1,800",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "유기농 깻잎 (1단/1봉)",
                "price": "₩3,000",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_0",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=200&q=80",
        "badge": "13% 로켓프레",
        "title": "신라면 (5입 멀티팩)",
        "discount": "13%",
        "price": "₩3,500",
        "originalPrice": "₩4,134",
        "desc": "고객님들의 많은 사랑을 받고 있는 신라면 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "신라면 (5입 멀티팩)",
                "price": "₩3,500",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "신라면 (5입 멀티팩)",
                "price": "₩4,000",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "신라면 (5입 멀티팩)",
                "price": "₩5,300",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_1",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&q=80",
        "badge": "40% 이마트 ",
        "title": "진라면 (5입 멀티팩)",
        "discount": "40%",
        "price": "₩2,200",
        "originalPrice": "₩3,732",
        "desc": "고객님들의 많은 사랑을 받고 있는 진라면 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "진라면 (5입 멀티팩)",
                "price": "₩2,200",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "진라면 (5입 멀티팩)",
                "price": "₩2,700",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "진라면 (5입 멀티팩)",
                "price": "₩3,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_2",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&q=80",
        "badge": "25% 로켓프레",
        "title": "삼양라면 (5입 멀티팩)",
        "discount": "25%",
        "price": "₩3,400",
        "originalPrice": "₩4,659",
        "desc": "고객님들의 많은 사랑을 받고 있는 삼양라면 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "삼양라면 (5입 멀티팩)",
                "price": "₩3,400",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "삼양라면 (5입 멀티팩)",
                "price": "₩4,700",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "삼양라면 (5입 멀티팩)",
                "price": "₩5,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_3",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1552611052-33e04de081de?w=200&q=80",
        "badge": "33% 대대로 ",
        "title": "너구리 (5입 멀티팩)",
        "discount": "33%",
        "price": "₩3,000",
        "originalPrice": "₩4,526",
        "desc": "고객님들의 많은 사랑을 받고 있는 너구리 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "너구리 (5입 멀티팩)",
                "price": "₩3,000",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "너구리 (5입 멀티팩)",
                "price": "₩3,900",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "너구리 (5입 멀티팩)",
                "price": "₩4,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_4",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=200&q=80",
        "badge": "22% 이마트 ",
        "title": "짜파게티 (5입 멀티팩)",
        "discount": "22%",
        "price": "₩3,600",
        "originalPrice": "₩4,715",
        "desc": "고객님들의 많은 사랑을 받고 있는 짜파게티 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "짜파게티 (5입 멀티팩)",
                "price": "₩3,600",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "짜파게티 (5입 멀티팩)",
                "price": "₩4,200",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "짜파게티 (5입 멀티팩)",
                "price": "₩5,000",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_5",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=200&q=80",
        "badge": "36% 로켓프레",
        "title": "안성탕면 (5입 멀티팩)",
        "discount": "36%",
        "price": "₩2,400",
        "originalPrice": "₩3,897",
        "desc": "고객님들의 많은 사랑을 받고 있는 안성탕면 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "안성탕면 (5입 멀티팩)",
                "price": "₩2,400",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "안성탕면 (5입 멀티팩)",
                "price": "₩3,400",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "안성탕면 (5입 멀티팩)",
                "price": "₩3,700",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_6",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=200&q=80",
        "badge": "26% 로켓프레",
        "title": "불닭볶음면 (5입 멀티팩)",
        "discount": "26%",
        "price": "₩2,600",
        "originalPrice": "₩3,614",
        "desc": "고객님들의 많은 사랑을 받고 있는 불닭볶음면 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "불닭볶음면 (5입 멀티팩)",
                "price": "₩2,600",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "불닭볶음면 (5입 멀티팩)",
                "price": "₩4,100",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "불닭볶음면 (5입 멀티팩)",
                "price": "₩4,200",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_7",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1552611052-33e04de081de?w=200&q=80",
        "badge": "25% 행복한 ",
        "title": "오징어짬뽕 (5입 멀티팩)",
        "discount": "25%",
        "price": "₩2,900",
        "originalPrice": "₩3,964",
        "desc": "고객님들의 많은 사랑을 받고 있는 오징어짬뽕 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "오징어짬뽕 (5입 멀티팩)",
                "price": "₩2,900",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "오징어짬뽕 (5입 멀티팩)",
                "price": "₩3,600",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "오징어짬뽕 (5입 멀티팩)",
                "price": "₩4,300",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_8",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1552611052-33e04de081de?w=200&q=80",
        "badge": "35% 하나로마",
        "title": "비빔면 (5입 멀티팩)",
        "discount": "35%",
        "price": "₩2,300",
        "originalPrice": "₩3,547",
        "desc": "고객님들의 많은 사랑을 받고 있는 비빔면 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "비빔면 (5입 멀티팩)",
                "price": "₩2,300",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "비빔면 (5입 멀티팩)",
                "price": "₩2,800",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "비빔면 (5입 멀티팩)",
                "price": "₩3,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_ramen_9",
        "category": "ramen",
        "img": "https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=200&q=80",
        "badge": "28% 하나로마",
        "title": "진짬뽕 (5입 멀티팩)",
        "discount": "28%",
        "price": "₩2,900",
        "originalPrice": "₩4,071",
        "desc": "고객님들의 많은 사랑을 받고 있는 진짬뽕 (5입 멀티팩)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "진짬뽕 (5입 멀티팩)",
                "price": "₩2,900",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "진짬뽕 (5입 멀티팩)",
                "price": "₩3,600",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "진짬뽕 (5입 멀티팩)",
                "price": "₩3,700",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_0",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80",
        "badge": "33% 로켓프레",
        "title": "인기 새우깡 (대용량)",
        "discount": "33%",
        "price": "₩2,400",
        "originalPrice": "₩3,589",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 새우깡 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "인기 새우깡 (대용량)",
                "price": "₩2,400",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "인기 새우깡 (대용량)",
                "price": "₩3,100",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "인기 새우깡 (대용량)",
                "price": "₩3,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_1",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1566478989037-e924e50ba0b4?w=200&q=80",
        "badge": "37% 대대로 ",
        "title": "인기 포카칩 (대용량)",
        "discount": "37%",
        "price": "₩1,400",
        "originalPrice": "₩2,267",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 포카칩 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "인기 포카칩 (대용량)",
                "price": "₩1,400",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "인기 포카칩 (대용량)",
                "price": "₩2,200",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "인기 포카칩 (대용량)",
                "price": "₩2,700",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_2",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80",
        "badge": "15% 로켓프레",
        "title": "인기 꼬깔콘 (대용량)",
        "discount": "15%",
        "price": "₩3,200",
        "originalPrice": "₩3,812",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 꼬깔콘 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "인기 꼬깔콘 (대용량)",
                "price": "₩3,200",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "인기 꼬깔콘 (대용량)",
                "price": "₩3,900",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "인기 꼬깔콘 (대용량)",
                "price": "₩4,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_3",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80",
        "badge": "36% 하나로마",
        "title": "인기 오징어땅콩 (대용량)",
        "discount": "36%",
        "price": "₩2,500",
        "originalPrice": "₩3,932",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 오징어땅콩 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "인기 오징어땅콩 (대용량)",
                "price": "₩2,500",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "인기 오징어땅콩 (대용량)",
                "price": "₩4,100",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "인기 오징어땅콩 (대용량)",
                "price": "₩4,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_4",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1566478989037-e924e50ba0b4?w=200&q=80",
        "badge": "35% 행복한 ",
        "title": "인기 맛동산 (대용량)",
        "discount": "35%",
        "price": "₩2,200",
        "originalPrice": "₩3,498",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 맛동산 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "인기 맛동산 (대용량)",
                "price": "₩2,200",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "인기 맛동산 (대용량)",
                "price": "₩2,700",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "인기 맛동산 (대용량)",
                "price": "₩2,900",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_5",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80",
        "badge": "27% 행복한 ",
        "title": "인기 홈런볼 (대용량)",
        "discount": "27%",
        "price": "₩1,800",
        "originalPrice": "₩2,565",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 홈런볼 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "인기 홈런볼 (대용량)",
                "price": "₩1,800",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "인기 홈런볼 (대용량)",
                "price": "₩2,600",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "인기 홈런볼 (대용량)",
                "price": "₩3,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_6",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1514756331096-242fdeb70d4a?w=200&q=80",
        "badge": "13% 이마트 ",
        "title": "인기 꿀꽈배기 (대용량)",
        "discount": "13%",
        "price": "₩1,900",
        "originalPrice": "₩2,275",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 꿀꽈배기 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "인기 꿀꽈배기 (대용량)",
                "price": "₩1,900",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "인기 꿀꽈배기 (대용량)",
                "price": "₩2,700",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "인기 꿀꽈배기 (대용량)",
                "price": "₩3,600",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_7",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80",
        "badge": "21% 하나로마",
        "title": "인기 카스타드 (대용량)",
        "discount": "21%",
        "price": "₩2,600",
        "originalPrice": "₩3,345",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 카스타드 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "인기 카스타드 (대용량)",
                "price": "₩2,600",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "인기 카스타드 (대용량)",
                "price": "₩3,300",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "인기 카스타드 (대용량)",
                "price": "₩4,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_8",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?w=200&q=80",
        "badge": "36% 대대로 ",
        "title": "인기 초코파이 (대용량)",
        "discount": "36%",
        "price": "₩2,000",
        "originalPrice": "₩3,171",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 초코파이 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "인기 초코파이 (대용량)",
                "price": "₩2,000",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "인기 초코파이 (대용량)",
                "price": "₩2,900",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "인기 초코파이 (대용량)",
                "price": "₩3,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_snack_9",
        "category": "snack",
        "img": "https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200&q=80",
        "badge": "28% 행복한 ",
        "title": "인기 오예스 (대용량)",
        "discount": "28%",
        "price": "₩2,600",
        "originalPrice": "₩3,640",
        "desc": "고객님들의 많은 사랑을 받고 있는 인기 오예스 (대용량)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "인기 오예스 (대용량)",
                "price": "₩2,600",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "인기 오예스 (대용량)",
                "price": "₩3,300",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "인기 오예스 (대용량)",
                "price": "₩4,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_0",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "33% 로켓프레",
        "title": "무항생제 한우 등심 (500g)",
        "discount": "33%",
        "price": "₩9,500",
        "originalPrice": "₩14,244",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 한우 등심 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "무항생제 한우 등심 (500g)",
                "price": "₩9,500",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "무항생제 한우 등심 (500g)",
                "price": "₩10,600",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "무항생제 한우 등심 (500g)",
                "price": "₩11,300",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_1",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "28% 대대로 ",
        "title": "무항생제 돼지 삼겹살 (500g)",
        "discount": "28%",
        "price": "₩12,900",
        "originalPrice": "₩18,040",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 돼지 삼겹살 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "무항생제 돼지 삼겹살 (500g)",
                "price": "₩12,900",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "무항생제 돼지 삼겹살 (500g)",
                "price": "₩13,400",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "무항생제 돼지 삼겹살 (500g)",
                "price": "₩13,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_2",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "16% 대대로 ",
        "title": "무항생제 닭볶음탕용 닭 (500g)",
        "discount": "16%",
        "price": "₩17,500",
        "originalPrice": "₩20,835",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 닭볶음탕용 닭 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "무항생제 닭볶음탕용 닭 (500g)",
                "price": "₩17,500",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "무항생제 닭볶음탕용 닭 (500g)",
                "price": "₩18,300",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "무항생제 닭볶음탕용 닭 (500g)",
                "price": "₩18,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_3",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "16% 행복한 ",
        "title": "무항생제 한우 국거리 (500g)",
        "discount": "16%",
        "price": "₩10,500",
        "originalPrice": "₩12,610",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 한우 국거리 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "무항생제 한우 국거리 (500g)",
                "price": "₩10,500",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "무항생제 한우 국거리 (500g)",
                "price": "₩11,000",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "무항생제 한우 국거리 (500g)",
                "price": "₩11,400",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_4",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "11% 하나로마",
        "title": "무항생제 돼지 목살 (500g)",
        "discount": "11%",
        "price": "₩16,100",
        "originalPrice": "₩18,160",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 돼지 목살 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "무항생제 돼지 목살 (500g)",
                "price": "₩16,100",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "무항생제 돼지 목살 (500g)",
                "price": "₩17,400",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "무항생제 돼지 목살 (500g)",
                "price": "₩17,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_5",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "29% 이마트 ",
        "title": "무항생제 닭가슴살 (500g)",
        "discount": "29%",
        "price": "₩9,500",
        "originalPrice": "₩13,435",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 닭가슴살 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "무항생제 닭가슴살 (500g)",
                "price": "₩9,500",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "무항생제 닭가슴살 (500g)",
                "price": "₩11,200",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "무항생제 닭가슴살 (500g)",
                "price": "₩11,200",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_6",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "35% 하나로마",
        "title": "무항생제 오리고기 (500g)",
        "discount": "35%",
        "price": "₩21,600",
        "originalPrice": "₩33,250",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 오리고기 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "무항생제 오리고기 (500g)",
                "price": "₩21,600",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "무항생제 오리고기 (500g)",
                "price": "₩22,400",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "무항생제 오리고기 (500g)",
                "price": "₩22,900",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_7",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "19% 이마트 ",
        "title": "무항생제 계란 30구 (500g)",
        "discount": "19%",
        "price": "₩16,100",
        "originalPrice": "₩19,934",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 계란 30구 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "무항생제 계란 30구 (500g)",
                "price": "₩16,100",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "무항생제 계란 30구 (500g)",
                "price": "₩16,800",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "무항생제 계란 30구 (500g)",
                "price": "₩17,900",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_8",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "31% 대대로 ",
        "title": "무항생제 메추리알 (500g)",
        "discount": "31%",
        "price": "₩23,300",
        "originalPrice": "₩33,860",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 메추리알 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "무항생제 메추리알 (500g)",
                "price": "₩23,300",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "무항생제 메추리알 (500g)",
                "price": "₩24,200",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "무항생제 메추리알 (500g)",
                "price": "₩25,200",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_meat_9",
        "category": "meat",
        "img": "https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=200&q=80",
        "badge": "36% 행복한 ",
        "title": "무항생제 소불고기 (500g)",
        "discount": "36%",
        "price": "₩22,300",
        "originalPrice": "₩34,969",
        "desc": "고객님들의 많은 사랑을 받고 있는 무항생제 소불고기 (500g)입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "무항생제 소불고기 (500g)",
                "price": "₩22,300",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "무항생제 소불고기 (500g)",
                "price": "₩23,000",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "무항생제 소불고기 (500g)",
                "price": "₩23,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_0",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=200&q=80",
        "badge": "36% 로켓프레",
        "title": "생활 필수 두루마리 휴지",
        "discount": "36%",
        "price": "₩2,200",
        "originalPrice": "₩3,580",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 두루마리 휴지입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "생활 필수 두루마리 휴지",
                "price": "₩2,200",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "생활 필수 두루마리 휴지",
                "price": "₩3,400",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "생활 필수 두루마리 휴지",
                "price": "₩4,100",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_1",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1584820927508-ea2b73af8e48?w=200&q=80",
        "badge": "23% 행복한 ",
        "title": "생활 필수 세탁세제",
        "discount": "23%",
        "price": "₩7,400",
        "originalPrice": "₩9,702",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 세탁세제입니다. 신선도와 품질을 보장합니다.",
        "mart": "행복한 식자재마트",
        "comparisons": [
            {
                "mart": "행복한 식자재마트",
                "product": "생활 필수 세탁세제",
                "price": "₩7,400",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "생활 필수 세탁세제",
                "price": "₩8,500",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "생활 필수 세탁세제",
                "price": "₩8,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_2",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1585832770485-e68a5dbfa5cd?w=200&q=80",
        "badge": "21% 로켓프레",
        "title": "생활 필수 주방세제",
        "discount": "21%",
        "price": "₩7,900",
        "originalPrice": "₩10,006",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 주방세제입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "생활 필수 주방세제",
                "price": "₩7,900",
                "isCheapest": true
            },
            {
                "mart": "하나로마트 율량점",
                "product": "생활 필수 주방세제",
                "price": "₩9,000",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "생활 필수 주방세제",
                "price": "₩9,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_3",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1585232004423-244e0e6904e3?w=200&q=80",
        "badge": "15% 하나로마",
        "title": "생활 필수 샴푸",
        "discount": "15%",
        "price": "₩9,300",
        "originalPrice": "₩11,042",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 샴푸입니다. 신선도와 품질을 보장합니다.",
        "mart": "하나로마트 율량점",
        "comparisons": [
            {
                "mart": "하나로마트 율량점",
                "product": "생활 필수 샴푸",
                "price": "₩9,300",
                "isCheapest": true
            },
            {
                "mart": "대대로 마트",
                "product": "생활 필수 샴푸",
                "price": "₩10,100",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "생활 필수 샴푸",
                "price": "₩10,300",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_4",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=200&q=80",
        "badge": "29% 이마트 ",
        "title": "생활 필수 린스",
        "discount": "29%",
        "price": "₩2,400",
        "originalPrice": "₩3,424",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 린스입니다. 신선도와 품질을 보장합니다.",
        "mart": "이마트 에브리데이",
        "comparisons": [
            {
                "mart": "이마트 에브리데이",
                "product": "생활 필수 린스",
                "price": "₩2,400",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "생활 필수 린스",
                "price": "₩3,100",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "생활 필수 린스",
                "price": "₩3,600",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_5",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1585232004423-244e0e6904e3?w=200&q=80",
        "badge": "12% 대대로 ",
        "title": "생활 필수 바디워시",
        "discount": "12%",
        "price": "₩8,200",
        "originalPrice": "₩9,363",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 바디워시입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "생활 필수 바디워시",
                "price": "₩8,200",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "생활 필수 바디워시",
                "price": "₩8,800",
                "isCheapest": false
            },
            {
                "mart": "로켓프레시",
                "product": "생활 필수 바디워시",
                "price": "₩8,900",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_6",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1559598467-f8b76c8155d0?w=200&q=80",
        "badge": "23% 대대로 ",
        "title": "생활 필수 치약",
        "discount": "23%",
        "price": "₩9,700",
        "originalPrice": "₩12,670",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 치약입니다. 신선도와 품질을 보장합니다.",
        "mart": "대대로 마트",
        "comparisons": [
            {
                "mart": "대대로 마트",
                "product": "생활 필수 치약",
                "price": "₩9,700",
                "isCheapest": true
            },
            {
                "mart": "로켓프레시",
                "product": "생활 필수 치약",
                "price": "₩11,400",
                "isCheapest": false
            },
            {
                "mart": "이마트 에브리데이",
                "product": "생활 필수 치약",
                "price": "₩11,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_7",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1559598467-f8b76c8155d0?w=200&q=80",
        "badge": "37% 로켓프레",
        "title": "생활 필수 칫솔",
        "discount": "37%",
        "price": "₩4,100",
        "originalPrice": "₩6,640",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 칫솔입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "생활 필수 칫솔",
                "price": "₩4,100",
                "isCheapest": true
            },
            {
                "mart": "행복한 식자재마트",
                "product": "생활 필수 칫솔",
                "price": "₩5,200",
                "isCheapest": false
            },
            {
                "mart": "하나로마트 율량점",
                "product": "생활 필수 칫솔",
                "price": "₩5,500",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_8",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1584483749714-d85ec6f1ce3e?w=200&q=80",
        "badge": "31% 로켓프레",
        "title": "생활 필수 물티슈",
        "discount": "31%",
        "price": "₩9,300",
        "originalPrice": "₩13,611",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 물티슈입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "생활 필수 물티슈",
                "price": "₩9,300",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "생활 필수 물티슈",
                "price": "₩10,500",
                "isCheapest": false
            },
            {
                "mart": "행복한 식자재마트",
                "product": "생활 필수 물티슈",
                "price": "₩10,800",
                "isCheapest": false
            }
        ]
    },
    {
        "id": "prod_processed_9",
        "category": "processed",
        "img": "https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=200&q=80",
        "badge": "29% 로켓프레",
        "title": "생활 필수 섬유유연제",
        "discount": "29%",
        "price": "₩8,200",
        "originalPrice": "₩11,642",
        "desc": "고객님들의 많은 사랑을 받고 있는 생활 필수 섬유유연제입니다. 신선도와 품질을 보장합니다.",
        "mart": "로켓프레시",
        "comparisons": [
            {
                "mart": "로켓프레시",
                "product": "생활 필수 섬유유연제",
                "price": "₩8,200",
                "isCheapest": true
            },
            {
                "mart": "이마트 에브리데이",
                "product": "생활 필수 섬유유연제",
                "price": "₩9,300",
                "isCheapest": false
            },
            {
                "mart": "대대로 마트",
                "product": "생활 필수 섬유유연제",
                "price": "₩10,100",
                "isCheapest": false
            }
        ]
    }
];


generatedProducts.forEach(p => {
    productData[p.id] = p;
});

window.filterHomeProducts = function(category) {
    // Update active tag
    const tags = document.querySelectorAll('#home-filter-tags .tag');
    tags.forEach(t => t.classList.remove('active'));
    
    // Safety check for event
    if (window.event && window.event.target && window.event.target.classList && window.event.target.tagName === 'BUTTON') {
        window.event.target.classList.add('active');
    } else {
        // Fallback: manually match the category to a tag
        const tagMap = {'all': 0, 'meat': 1, 'veg': 2, 'ramen': 3, 'snack': 4, 'processed': 5};
        const tagIndex = tagMap[category];
        if (tagIndex !== undefined && tags[tagIndex]) {
            tags[tagIndex].classList.add('active');
        }
    }

    const list = document.getElementById('home-product-list');
    if (!list) return;

    let html = '';
    generatedProducts.forEach(p => {
        if (category === 'all' || p.category === category) {
            let cleanTitle = p.title.replace(new RegExp(p.mart, 'g'), '').trim();
            // Remove lingering brackets or spaces if any
            cleanTitle = cleanTitle.replace(/^[\[\]\s]+/, '');
            html += `
                <div class="product-item" onclick="openProductDetail('${p.id}')" style="cursor:pointer; display: flex; flex-direction: column;">
                    <img src="${p.img}" alt="${cleanTitle}" class="prod-img">
                    <div class="prod-info" style="flex: 1; display: flex; flex-direction: column;">
                        <div class="flex-between" style="align-items: flex-start; margin-bottom: 4px;">
                            <div class="prod-badge">${p.badge}</div>
                        </div>
                        <div style="margin-bottom: 4px;">
                            <span style="font-size: 0.75rem; color: var(--primary); font-weight: 700; background: rgba(16,185,129,0.1); padding: 2px 6px; border-radius: 4px;">
                                <i class="fas fa-store"></i> ${p.mart}
                            </span>
                        </div>
                        <h3 style="font-size: 0.95rem; margin: 4px 0 8px; line-height: 1.3; font-weight: 700;">${cleanTitle}</h3>
                        <p class="prod-price" style="margin-top: auto;"><strong>${p.price}</strong> <del style="color:var(--gray); font-size:0.8rem;">${p.originalPrice}</del></p>
                    </div>
                    <button class="add-cart-btn" onclick="event.stopPropagation(); window.addToCart('${cleanTitle.replace(/'/g, "\'")}', '${p.mart}', '${p.price}')"><i class="fas fa-plus"></i></button>
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

// Recipe Data
const recipeData = {
    'spicy_pork': {
        title: '매콤달콤 황금비율 제육볶음',
        img: 'https://loremflickr.com/400/400/grocery',
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
        img: 'https://loremflickr.com/400/400/grocery',
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
        img: 'https://loremflickr.com/400/400/grocery',
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
