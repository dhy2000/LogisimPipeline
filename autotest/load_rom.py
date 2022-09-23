# Load code.txt into Logisim ROM

'''
1. Load and parse XML
2. find <comp name="ROM"> / <a name="contents"> / prefix="addr/data: 12 32"
3. clear and insert hex code
'''

import os, sys
import re
from xml.etree import ElementTree

from numpy import mat

# Usage: python -u load_rom.py circuit.circ code.txt

def ishex(s: str):
    try:
        int(s, 16)
    except ValueError:
        return False
    return True

try:
    circfile: str
    codefile: str
    circfile, codefile = sys.argv[1], sys.argv[2]
except IndexError:
    print("Usage: python -u load_rom.py circ.circ code.txt")

with open(circfile, "r") as fp:
    xmlcirc = fp.read()
with open(codefile, "r") as fp:
    code = list(filter(ishex, map(lambda s : s.strip(), fp.read().split('\n'))))

circ = ElementTree.fromstring(xmlcirc)

roms = circ.findall(".//comp[@name='ROM']")
if len(roms) == 0:
    print("ROM required.")
    exit(0)

for rom in roms:
    content = rom.find("./a[@name='contents']")
    match = re.match(r'addr/data: \d+ 32', content.text.split('\n')[0])
    if match:
        title = match.group()
        content.text = title + '\n' + ' '.join(code)

print('<?xml version="1.0" encoding="UTF-8" standalone="no"?>')
print(ElementTree.tostring(circ, encoding='unicode'))
