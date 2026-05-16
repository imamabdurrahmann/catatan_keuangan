import os

for root, dirs, files in os.walk('lib'):
    if 'models' in root: continue
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            # Revert everything Anggaran back to Budget
            content = content.replace('Anggaran', 'Budget')
            content = content.replace('anggaran', 'budget')
            
            # Now specifically target the known UI strings
            content = content.replace("'Nominal Budget'", "'Nominal Anggaran'")
            content = content.replace("'Set Budget'", "'Atur Anggaran'")
            content = content.replace("'Edit budget '", "'Edit anggaran '")
            content = content.replace("'budget terpakai'", "'anggaran terpakai'")
            content = content.replace("'Melebihi budget '", "'Melebihi anggaran '")
            content = content.replace("'Budget:'", "'Anggaran:'")
            content = content.replace("'Budget '", "'Anggaran '")
            content = content.replace("'Budget'", "'Anggaran'")
            content = content.replace('"Budget"', '"Anggaran"')
            
            with open(path, 'w', encoding='utf-8') as file:
                file.write(content)

print("Reverted budget class names and properly formatted strings.")
