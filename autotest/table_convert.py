# convert logisim table into cpu trace

while True:
    try:
        line = input()
    except EOFError:
        break
    pc_w, pc_m, regw, rega, regd, memw, mema, memd, tim = map(lambda s : int(s.replace(' ', ''), 2), line.split('\t'))
    if regw and rega != 0:
        print("%d@%08x: $%2d <= %08x" % (tim, pc_w, rega, regd))
    if memw:
        print("%d@%08x: *%08x <= %08x" % (tim, pc_m, mema, memd))    