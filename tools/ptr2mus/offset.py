#!python2
import mmap
import sys

file_name = sys.argv[1]

with open(file_name, "rb") as fd:
    needle = "\x00\x07\x77\x77\x77\x77\x77\x77\x77\x77\x77\x77\x77\x77\x77\x77"
    needle_len = len(needle)
    haystack = mmap.mmap(fd.fileno(), length=0, access=mmap.ACCESS_READ)
    offset = haystack.find(needle)
    print('0')
    while offset >= 0:
        offset += 16
        offhex = hex(offset)[2:]
        hex_string = ''.join(r'\x%02X' % ord(b)
                                for b in haystack[offset: offset+needle_len])
        print('{}'.format(offhex))
        offset += needle_len
        offset = haystack.find(needle, offset) 