# Tietokonearkkitehtuuri 1, harjoitustyš 4, laskin

		.globl main
		.data
		
# MŠŠritetŠŠn tarkastelua varten merkkien ascii-arvot 
# heksalukuina
potenssi:	.byte	0x5E
kerto:		.byte	0x2A
jako:		.byte	0x2F
summa:		.byte	0x2B
vahennys:	.byte	0x2D
pilkku:		.byte	0x2C
ylaraja:	.byte	0x39
alaraja:	.byte	0x30

# MŠŠritetŠŠn ohjelman aikana tarvittavat tulosteet
ALKUTULOSTE:	.asciiz "SyštŠ lauseke: "
VIRHETULOSTE:	.asciiz "\nVirheellinen syšte.\n"

SYOTE:		.asciiz ""
		.space 30

		.text

main:		li	$v0, 4				# Ladataan syscallin string tulostuspalvelu
		la	$a0, ALKUTULOSTE		# Osoite josta tuloste luetaan
		syscall
		and	$s0, $zero, $s0			# Alustetaan rekisteri, johon luettu merkki asetetaan
		and	$t0, $zero, $t0			# Alustetaan laskuri, jolla mŠŠritetŠŠn merkille oikea 
							# tarkastelulohko
		
lueSyote:
		li	$v0, 12				# Ladataan syscallin charin lukupalvelu
		la	$s0, SYOTE			# Osoite, johon luettu merkki ohjataan
		syscall
		sb	$v0, 0($s0)			# Ladataan luettu merkki rekisteriin 
		
		# 1. kierroksen tarkastus
		beqz	$t0, v1tarkistus 		# EnsimmŠisen merkin on oltava numero
		
		# 2. kierroksen tarkastus
		beq	$t0, 1, v2tarkistus		# Toinen merkki saa olla joko numero tai pilkku. 
							# Jos luetaan pilkku, siirrytŠŠn seuraavaan tarkasteluun,
							# muuten pysytŠŠn samassa
		
		# 3. kierroksen tarkastus		
		#beq	$t0, 2, v3tarkistus		# Pilkun jŠlkeen on tultava numero
		
		# 4. kierroksen tarkastus
		#beq	$t0, 3, v4tarkistus		# Pilkun jŠlkeinen toinen merkki voi olla joko numero
							# tai operaattori. Jos luetaan operaattori, siirrytŠŠn
							# seuraavaan tarkasteluun, muuten pysytŠŠn samassa.

		# Jos lšydetŠŠn operaattori, hypŠtŠŠn tarkistusten alkuun.
		# Erikoistilanteena potenssi, jolloin merkin jŠlkeen etsitŠŠn kokonaislukua		
		
pinotallennus:	j	lueSyote			# TŠhŠn pinoon tallentaminen

pilkkutilanne:	j 	pilkkutilanne			# MitŠ tŠŠllŠ tehdŠŠn?

loppu:		j	loppu

v1tarkistus:	lb	$t1, alaraja			# Ladataan numeroiden ascii-alaraja
		lb	$t3, 0($s0)			# Ladataan luettu merkki
		sge	$t2, $t3, $t1			# Katsotaan, onko luettu merkki rajan ylŠpuolella
		lb	$t1, ylaraja			# Ladtaan numeroiden ylŠraja
		sle	$t3, $t3, $t1			# Katsotaan, onko luettu merkki rajan alapuolella
		
		and	$t1, $t2, $t3			# Jos siis rajojen vŠlissŠ, merkki on numero ja 
							# asetetaan $t1 = 1
		beqz	$t1, virhe			# Jos merkki ei ollut numero, hypŠtŠŠn virheeseen
		addi	$t0, $t0, 1			# Kasvatetaan tarkastelulaskuria
		j	pinotallennus			# HypŠtŠŠn pinotallennukseen, jossa luettu merkki asetetaan
							# pinoon
							
v2tarkistus:	lb	$t1, alaraja			# Ladataan numeroiden ascii-alaraja
		lb	$t3, 0($s0)			# Ladataan luettu merkki
		sge	$t2, $t3, $t1			# Katsotaan, onko luettu merkki rajan ylŠpuolella
		lb	$t1, ylaraja			# Ladtaan numeroiden ylŠraja
		sle	$t4, $t3, $t1			# Katsotaan, onko luettu merkki rajan alapuolella
		
		and	$t1, $t2, $t4			# Jos siis rajojen vŠlissŠ, merkki on numero ja 
							# asetetaan $t1 = 1
		beq	$t1, 1, pinotallennus		# Jos kyseessŠ numero, hypŠtŠŠn pinotallennukseen
		
		lb	$t1, pilkku			# Ladataan numeroiden ascii-alaraja
		beq	$t1, $t3, pilkkutilanne		# Jos lšydetŠŠn pilkku, hypŠtŠŠn pilkkutilanteeseen
		
		j	virhe				# Jos kyseessŠ ei ollut numero eikŠ pilkku, hypŠtŠŠn
							# virheeseen
	
virhe:		
		li	$v0, 4				# Ladataan syscallin string tulostuspalvelu
		la	$a0, VIRHETULOSTE		# Osoite josta tuloste luetaan
		syscall	

		j	main				# HypŠtŠŠn takaisin ohjelman alkuun
		
#aliohjelmat
lisaaminen:	jr	$ra

vahennys:	jr	$ra

kertominen:	jr	$ra

jako:		jr	$ra

potenssi:	jr	$ra
