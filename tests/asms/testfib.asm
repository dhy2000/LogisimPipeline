.text 0x3000
_start:
    ori   $t0, $zero, 0x1   # t0 = 1
    ori   $t1, $zero, 0x1   # t1 = 1
    ori   $s1, $zero, 0x4   # s1 = 4
    ori   $t4, $zero, 0x100 # t4 = 0x100
    ori   $a0, $zero, 0x200 # a0 = 0x200
    addu  $t5, $a0, $t4     # t5 = 0x300

loop:
    addu  $t2, $t0, $t1     # t2 = t0+t1
    ori   $t0, $t1, 0x0     # t0 = t1
    ori   $t1, $t2, 0x0     # t1 = t2
    sw    $t1, 0($a0)
    lw    $t3, 0($a0)
    bne   $t1, $t3, end
    ori   $zero, $zero, 0   # noop
    addu  $a0, $a0, $s1     # a0 += 4
    bne   $a0, $t5, loop
    ori   $zero, $zero, 0   # noop

end:
    bne   $s1, $zero, end
    nop
