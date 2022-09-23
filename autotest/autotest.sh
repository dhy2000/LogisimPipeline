#!/bin/bash
# cwd='$PROJECT/autotest'

# Logisim and Mars
LOGISIM=logisim.jar
MARS=Mars.jar
# Testbench and filename needed by tb
TESTBENCH=tb-pipeline.circ
TESTCIRC_NAME=test.circ
# Tools
LOAD_ROM=load_rom.py
TABLE_CONV=table_convert.py
CHECKER=cpu-checker

TEST_CIRC=../mips.circ


ASMS=`find ../tests/asms -name '*.asm'`

set -e

for asm in $ASMS; do
    echo 'Testing '$asm
    java -jar ${MARS} a nc mc CompactDataAtZero dump .text HexText code.txt $asm
    java -jar ${MARS} db nc mc CompactDataAtZero 100000 $asm > stdtrace.txt
    python3 -u ${LOAD_ROM} ${TEST_CIRC} code.txt > ${TESTCIRC_NAME}
    java -jar ${LOGISIM} ${TESTBENCH} -tty table | python3 -u ${TABLE_CONV} > logisimtrace.txt
    ./${CHECKER} --std=stdtrace.txt --ans=logisimtrace.txt
done
