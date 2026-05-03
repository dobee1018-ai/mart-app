import sys

search_logic = """
// Home Search Logic
window.searchHomeProducts = function(query) {
    const list = document.getElementById('home-product-list');
    if (!list) return;

    query = (query || '').trim().toLowerCase();
    
    // Unset active tags if searching
    const tags = document.querySelectorAll('#home-filter-tags .tag');
    tags.forEach(t => t.classList.remove('active'));

    if (query === '') {
        // Revert to all
        window.filterHomeProducts('all');
        return;
    }

    let html = '';
    generatedProducts.forEach(p => {
        if (p.title.toLowerCase().includes(query) || p.mart.toLowerCase().includes(query)) {
            html += `
                <div class="product-item" onclick="openProductDetail('${p.id}')" style="cursor:pointer;">
                    <img src="${p.img}" alt="${p.title}" class="prod-img">
                    <div class="prod-info">
                        <div class="prod-badge">${p.badge}</div>
                        <h3 style="font-size: 1rem; margin-bottom: 6px; line-height: 1.3;">${p.title}</h3>
                        <p class="prod-price"><strong>${p.price}</strong> <del style="color:var(--gray); font-size:0.8rem;">${p.originalPrice}</del></p>
                    </div>
                    <button class="add-cart-btn" onclick="event.stopPropagation(); window.addToCart('${p.title}', '${p.mart}', '${p.price}')"><i class="fas fa-plus"></i></button>
                </div>
            `;
        }
    });
    
    if (html === '') {
        html = '<div style="grid-column: 1 / -1; padding: 40px 20px; text-align: center; color: var(--gray);">검색 결과가 없습니다.</div>';
    }
    
    list.innerHTML = html;
};
"""

with open('/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js', 'a', encoding='utf-8') as f:
    f.write(search_logic)

print("Appended search logic using python.")
