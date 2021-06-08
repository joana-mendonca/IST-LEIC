from random import *

for i in range(0,1024):
	user = randint(1, 16)
	tempo = randint(1, 365)
	local = randint(1, 16)
	lingua = randint(1, 100)
	tipo = ("\'redacao\'", "\'traducao\'")[randint(0, 1)]
	com_prop = ("FALSE", "TRUE")[randint(0, 1)]
	if user > 16 or tempo > 365 or local > 16 or lingua > 100:
		print("fuck")
		break

	print("(%d,%d,%d,%d,%s,%s)," % (user, tempo, local, lingua, tipo, com_prop), end = '')