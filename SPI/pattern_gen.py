import random as rd

PATNUM = 200
f = open("C:/Users/B10557/Desktop/GAI project/pattern.txt", "w")

randome_pats = []
for i in range(PATNUM):
    randome_pat = '{:x}'.format(rd.randint(0, 16))
    randome_pats.append(randome_pat)

f.write(str(PATNUM))
for number in randome_pats:
    f.write("\n\n")
    f.write(number)