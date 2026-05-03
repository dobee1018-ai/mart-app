import json
import re

with open('/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js', 'r', encoding='utf-8') as f:
    content = f.read()

match = re.search(r'const generatedProducts = (\[.*?\]);\s+generatedProducts\.forEach', content, flags=re.DOTALL)
if match:
    data_str = match.group(1)
    products = json.loads(data_str)
    
    count = 0
    for p in products:
        if '돼지' in p['title'] or '삼겹살' in p['title'] or '목살' in p['title']:
            p['img'] = 'pork.png'
            count += 1
            
    if count > 0:
        new_data_str = json.dumps(products, ensure_ascii=False, indent=4)
        new_content = content[:match.start(1)] + new_data_str + content[match.end(1):]
        
        with open('/Users/hanseunghan/test.py/mart.app/mart_app_web/app.js', 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Successfully updated {count} pork images.")
    else:
        print("No pork products found.")
else:
    print("Could not find generatedProducts block.")
