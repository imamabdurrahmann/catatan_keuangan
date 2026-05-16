import os

for root, dirs, files in os.walk('lib'):
    # Skip models to avoid damaging database column mappings etc.
    if 'models' in root:
        continue
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            # Revert variable-killing replacements
            content = content.replace('useKata Sandi', 'usePassword')
            content = content.replace('enteredKata Sandi', 'enteredPassword')
            
            # Revert Kata Sandi back to Password for safety, then string-only
            # Actually, I can just replace exactly 'Kata Sandi' => 'Password' generally
            content = content.replace('Kata Sandi', 'Password')
            content = content.replace("'Password'", "'Kata Sandi'")
            content = content.replace('"Password"', '"Kata Sandi"')
            content = content.replace('Konfirmasi Password', 'Konfirmasi Kata Sandi')
            
            with open(path, 'w', encoding='utf-8') as file:
                file.write(content)
print("Fix applied.")
