import random as rd

PATNUM = 10000
f = open("C:/myStudy/Topic Instance/SPI/pattern.txt", "w")

randome_pats = []
for i in range(PATNUM):
    randome_pat = '{:02x}'.format(rd.randint(0, 255))
    randome_pats.append(randome_pat)

f.write(str(PATNUM))
for number in randome_pats:
    f.write("\n\n")
    f.write(number)