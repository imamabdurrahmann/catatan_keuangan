import sys
import py_compile
sys.path.insert(0, 'C:/Users/muham/catatan_keuangan/scripts')
try:
    py_compile.compile('C:/Users/muham/catatan_keuangan/scripts/export_to_csv.py', doraise=True)
    print("PYTHON_COMPILE:SUCCESS")
except py_compile.PyCompileError as e:
    print(f"PYTHON_COMPILE:FAILED\n{e}")
    sys.exit(1)
