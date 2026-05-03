import re

path = '/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

target = """    generatedProducts.forEach(p => {
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
    });"""

replacement = """    generatedProducts.forEach(p => {
        if (category === 'all' || p.category === category) {
            let cleanTitle = p.title.replace(new RegExp(p.mart, 'g'), '').trim();
            // Remove lingering brackets or spaces if any
            cleanTitle = cleanTitle.replace(/^[\\[\\]\\s]+/, '');
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
                    <button class="add-cart-btn" onclick="event.stopPropagation(); window.addToCart('${cleanTitle.replace(/'/g, "\\'")}', '${p.mart}', '${p.price}')"><i class="fas fa-plus"></i></button>
                </div>
            `;
        }
    });"""

content = content.replace(target, replacement)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated home product list rendering.")
