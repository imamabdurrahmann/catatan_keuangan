import os, re
strings = set()
for root, dirs, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            with open(os.path.join(root, f), 'r', encoding='utf-8') as file:
                content = file.read()
                # Find single quoted strings
                strings.update(re.findall(r"'([^']*)'", content))
                # Find double quoted strings
                strings.update(re.findall(r'"([^"]*)"', content))
with open('all_strings.txt', 'w', encoding='utf-8') as out:
    out.write('\n'.join(sorted([s for s in strings if s.strip() and len(s) > 1])))
print("Extraction complete.")
