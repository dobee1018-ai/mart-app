import json
import re

path = '/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix broken images (replace Unsplash with LoremFlickr matching keywords)
def get_lorem_flickr(title):
    keywords = ['fruit', 'vegetable', 'meat', 'snack', 'ramen', 'milk', 'egg', 'onion', 'garlic', 'apple', 'pear', 'grape']
    match_keyword = 'grocery'
    for k in keywords:
        if k in title.lower() or (k == 'fruit' and ('사과' in title or '배' in title or '포도' in title)) or \
           (k == 'vegetable' and ('양파' in title or '마늘' in title or '당근' in title)) or \
           (k == 'meat' and ('한우' in title or '돼지' in title or '닭' in title)) or \
           (k == 'ramen' and '라면' in title) or \
           (k == 'snack' and '과자' in title):
            match_keyword = k
            break
    # Use seed based on title to keep it consistent
    import hashlib
    seed = hashlib.md5(title.encode()).hexdigest()[:8]
    return f'https://loremflickr.com/400/400/{match_keyword}?lock={seed}'

# Extract products
pattern = r'const generatedProducts = (\[.*?\]);'
match = re.search(pattern, content, re.DOTALL)
if match:
    products_json = match.group(1)
    # The JSON in the JS file might have single quotes or other JS-specifics, but usually it's just JSON-like.
    # Actually, it's a JS array. Let's try to parse it.
    # For safety, I'll just do a string replacement for the images in the whole content.
    
    # 2. Add new marts and their products
    new_marts = ['대륙식자재마트', '천사 식자재마트', '상지 식자재마트', '엘마트']
    new_products = []
    for i, mart in enumerate(new_marts):
        prod1 = {
            "id": f"new_prod_{i}_0",
            "category": "processed",
            "img": f"https://loremflickr.com/400/400/grocery?lock={i}1",
            "badge": "특가",
            "title": f"{mart} 대용량 식용유 (1.8L)",
            "discount": "30%",
            "price": "₩4,200",
            "originalPrice": "₩6,000",
            "desc": f"{mart}에서 제안하는 대용량 식자재 특가입니다.",
            "mart": mart,
            "comparisons": [
                {"mart": mart, "product": "대용량 식용유 (1.8L)", "price": "₩4,200", "isCheapest": True},
                {"mart": "대대로 마트", "product": "식용유 (1.8L)", "price": "₩5,500", "isCheapest": False}
            ]
        }
        prod2 = {
            "id": f"new_prod_{i}_1",
            "category": "veg",
            "img": f"https://loremflickr.com/400/400/onion?lock={i}2",
            "badge": "박스특가",
            "title": f"{mart} 양파 (15kg/망)",
            "discount": "40%",
            "price": "₩12,000",
            "originalPrice": "₩20,000",
            "desc": "식당 및 대량 소비를 위한 최저가 양파 망 상품입니다.",
            "mart": mart,
            "comparisons": [
                {"mart": mart, "product": "양파 (15kg)", "price": "₩12,000", "isCheapest": True},
                {"mart": "하나로마트", "product": "양파 (15kg)", "price": "₩15,800", "isCheapest": False}
            ]
        }
        new_products.extend([prod1, prod2])

    # Convert to JSON string for JS
    new_prods_str = json.dumps(new_products, ensure_ascii=False, indent=4)
    # Strip the brackets to merge
    new_prods_inner = new_prods_str[1:-1].strip()
    
    # Insert new products at the beginning of the array
    updated_products_json = '[' + new_prods_inner + ',\n' + products_json[1:]
    content = content.replace(products_json, updated_products_json)

# 3. Final image fix for all (lazy regex replacement)
# Replace all unsplash links with loremlfickr (using a generic one for now or trying to capture title)
# Actually, let's just do a generic replacement for anything starting with images.unsplash.com
content = re.sub(r'https://images\.unsplash\.com/photo-[a-zA-Z0-9?=&-]+', 'https://loremflickr.com/400/400/grocery', content)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
