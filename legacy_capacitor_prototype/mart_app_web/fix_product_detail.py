import re

path = '/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

target = """window.openProductDetail = function(productId) {
    const data = productData[productId];
    if (!data) return;
    
    document.getElementById('pd-img').src = data.img;
    document.getElementById('pd-badge').textContent = data.badge;
    document.getElementById('pd-title').textContent = data.title;"""

replacement = """window.openProductDetail = function(productId) {
    const data = productData[productId];
    if (!data) return;
    
    let cleanTitle = data.title;
    if (data.mart) {
        cleanTitle = cleanTitle.replace(new RegExp(data.mart, 'g'), '').trim();
        cleanTitle = cleanTitle.replace(/^[\\[\\]\\s]+/, '');
    }
    
    document.getElementById('pd-img').src = data.img;
    
    // Show mart name and badge nicely
    const badgeHtml = `<span style="margin-right: 8px;"><i class="fas fa-store"></i> ${data.mart}</span> <span style="background:var(--primary); color:white; padding:2px 6px; border-radius:4px; font-size:0.8rem;">${data.badge}</span>`;
    const badgeEl = document.getElementById('pd-badge');
    badgeEl.innerHTML = badgeHtml;
    badgeEl.style.background = 'none';
    badgeEl.style.color = 'var(--dark)';
    badgeEl.style.padding = '0';
    
    document.getElementById('pd-title').textContent = cleanTitle;"""

# Also fix the pd-cart-btn
target2 = """    document.getElementById('pd-cart-btn').onclick = function() {
        window.addToCart(data.title, data.comparisons[0].mart, data.price);
    };"""

replacement2 = """    document.getElementById('pd-cart-btn').onclick = function() {
        window.addToCart(cleanTitle, data.comparisons[0].mart, data.price);
    };"""

content = content.replace(target, replacement)
content = content.replace(target2, replacement2)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated product detail rendering.")
