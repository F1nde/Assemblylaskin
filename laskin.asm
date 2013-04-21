# Tietokonearkkitehtuuri 1, harjoitusty� 4, laskin

		.globl main
		.data
		
# M��ritet��n tarkastelua varten merkkien ascii-arvot 
# heksalukuina
potenssi:	.byte	0x5E
kerto:		.byte	0x2A
jako:		.byte	0x2F
summa:		.byte	0x2B
vahennys:	.byte	0x2D
pilkku:		.byte	0x2C
ylaraja:	.byte	0x39
alaraja:	.byte	0x30

# M��ritet��n ohjelman aikana tarvittavat tulosteet
ALKUTULOSTE:	.asciiz "Sy�t� lauseke: "
VIRHETULOSTE:	.asciiz "\nVirheellinen sy�te.\n"

SYOTE:		.asciiz ""
		.space 30

		.text

main:		li	$v0, 4				# Ladataan syscallin string tulostuspalvelu
		la	$a0, ALKUTULOSTE		# Osoite josta tuloste luetaan
		syscall
		and	$s0, $zero, $s0			# Alustetaan rekisteri, johon luettu merkki asetetaan
		and	$t0, $zero, $t0			# Alustetaan laskuri, jolla m��ritet��n merkille oikea 
							# tarkastelulohko
		
lueSyote:
		li	$v0, 12				# Ladataan syscallin charin lukupalvelu
		la	$s0, SYOTE			# Osoite, johon luettu merkki ohjataan
		syscall
		sb	$v0, 0($s0)			# Ladataan luettu merkki rekisteriin 
		
		# 1. kierroksen tarkastus
		beqz	$t0, v1tarkistus 		# Ensimm�isen merkin on oltava numero
		
		# 2. kierroksen tarkastus
		beq	$t0, 1, v2tarkistus		# Toinen merkki saa olla joko numero tai pilkku. 
							# Jos luetaan pilkku, siirryt��n seuraavaan tarkasteluun,
							# muuten pysyt��n samassa
		
		# 3. kierroksen tarkastus		
		#beq	$t0, 2, v3tarkistus		# Pilkun j�lkeen on tultava numero
		
		# 4. kierroksen tarkastus
		#beq	$t0, 3, v4tarkistus		# Pilkun j�lkeinen toinen merkki voi olla joko numero
							# tai operaattori. Jos luetaan operaattori, siirryt��n
							# seuraavaan tarkasteluun, muuten pysyt��n samassa.

		# Jos l�ydet��n operaattori, hyp�t��n tarkistusten alkuun.
		# Erikoistilanteena potenssi, jolloin merkin j�lkeen etsit��n kokonaislukua		
		
pinotallennus:	j	lueSyote			# T�h�n pinoon tallentaminen

pilkkutilanne:	j 	pilkkutilanne			# Mit� t��ll� tehd��n?

loppu:		j	loppu

v1tarkistus:	lb	$t1, alaraja			# Ladataan numeroiden ascii-alaraja
		lb	$t3, 0($s0)			# Ladataan luettu merkki
		sge	$t2, $t3, $t1			# Katsotaan, onko luettu merkki rajan yl�puolella
		lb	$t1, ylaraja			# Ladtaan numeroiden yl�raja
		sle	$t3, $t3, $t1			# Katsotaan, onko luettu merkki rajan alapuolella
		
		and	$t1, $t2, $t3			# Jos siis rajojen v�liss�, merkki on numero ja 
							# asetetaan $t1 = 1
		beqz	$t1, virhe			# Jos merkki ei ollut numero, hyp�t��n virheeseen
		addi	$t0, $t0, 1			# Kasvatetaan tarkastelulaskuria
		j	pinotallennus			# Hyp�t��n pinotallennukseen, jossa luettu merkki asetetaan
							# pinoon
							
v2tarkistus:	lb	$t1, alaraja			# Ladataan numeroiden ascii-alaraja
		lb	$t3, 0($s0)			# Ladataan luettu merkki
		sge	$t2, $t3, $t1			# Katsotaan, onko luettu merkki rajan yl�puolella
		lb	$t1, ylaraja			# Ladtaan numeroiden yl�raja
		sle	$t4, $t3, $t1			# Katsotaan, onko luettu merkki rajan alapuolella
		
		and	$t1, $t2, $t4			# Jos siis rajojen v�liss�, merkki on numero ja 
							# asetetaan $t1 = 1
		beq	$t1, 1, pinotallennus		# Jos kyseess� numero, hyp�t��n pinotallennukseen
		
		lb	$t1, pilkku			# Ladataan numeroiden ascii-alaraja
		beq	$t1, $t3, pilkkutilanne		# Jos l�ydet��n pilkku, hyp�t��n pilkkutilanteeseen
		
		j	virhe				# Jos kyseess� ei ollut numero eik� pilkku, hyp�t��n
							# virheeseen
	
virhe:		
		li	$v0, 4				# Ladataan syscallin string tulostuspalvelu
		la	$a0, VIRHETULOSTE		# Osoite josta tuloste luetaan
		syscall	

		j	main				# Hyp�t��n takaisin ohjelman alkuun
		
#aliohjelmat
lisaaminen:	jr	$ra

vahennys:	jr	$ra

kertominen:	jr	$ra

jako:		jr	$ra

potenssi:	jr	$ra
