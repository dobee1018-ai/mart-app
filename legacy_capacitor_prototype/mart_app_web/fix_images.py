import json
import re
import hashlib

path = '/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern to find the JSON array
pattern = r'const generatedProducts = (\[.*?\]);'
match = re.search(pattern, content, re.DOTALL)
if match:
    products_json = match.group(1)
    try:
        # Note: products_json might have trailing commas or other JS quirks, but let's try
        products = json.loads(products_json)
        
        keywords = {
            '사과': 'apple', '배': 'pear', '포도': 'grape', '수박': 'watermelon', '딸기': 'strawberry',
            '양파': 'onion', '마늘': 'garlic', '당근': 'carrot', '감자': 'potato', '배추': 'cabbage',
            '한우': 'beef', '돼지': 'pork', '닭': 'chicken', '계란': 'egg',
            '라면': 'noodle', '과자': 'snack', '우유': 'milk', '치약': 'toothpaste', '휴지': 'tissue'
        }

        for p in products:
            # If it's a loremflickr link but generic 'grocery', or any image link really
            found_key = 'grocery'
            for k, v in keywords.items():
                if k in p['title']:
                    found_key = v
                    break
            seed = hashlib.md5(p['title'].encode()).hexdigest()[:6]
            p['img'] = f'https://loremflickr.com/400/400/{found_key}?lock={seed}'
        
        updated_json = json.dumps(products, ensure_ascii=False, indent=4)
        content = content.replace(products_json, updated_json)
        
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Images updated successfully.")
    except Exception as e:
        print(f"Error: {e}")
