<<<<<<< HEAD
<<<<<<< HEAD
import random as rd

PATNUM = 10
f = open("pattern.txt", "w")

randome_pats = []
for i in range(PATNUM):
    randome_pat = '{:02x}'.format(rd.randint(0, 255))
    randome_pats.append(randome_pat)

f.write(str(PATNUM))
for number in randome_pats:
    f.write("\n\n")
    f.write(number + '\n')

=======
import random as rd

PATNUM = 10
f = open("pattern.txt", "w")

randome_pats = []
for i in range(PATNUM):
    randome_pat = '{:02x}'.format(rd.randint(0, 255))
    randome_pats.append(randome_pat)

for number in randome_pats:
    f.write(str(PATNUM))
    f.write("\n\n")
    f.write(number + '\n')

>>>>>>> 4836f23e6d3c5823cbda72ab33a5a638b951ad62
=======
import random as rd

PATNUM = 10
f = open("pattern.txt", "w")

randome_pats = []
for i in range(PATNUM):
    randome_pat = '{:02x}'.format(rd.randint(0, 255))
    randome_pats.append(randome_pat)

for number in randome_pats:
    f.write(str(PATNUM))
    f.write("\n\n")
    f.write(number + '\n')

>>>>>>> 39059d7608a97f01c32b431de6bb75b2ca74f4cd
f.close()