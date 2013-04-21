# Tietokonearkkitehtuuri 1, harjoitustyö 4, laskin

		.globl main
		.data
		
# Maaritetaan tarkastelua varten merkkien ascii-arvot 
# heksalukuina
potenssi:	.byte	0x5E
kerto:		.byte	0x2A
jako:		.byte	0x2F
summa:		.byte	0x2B
vahennys:	.byte	0x2D
pilkku:		.byte	0x2C
ylaraja:	.byte	0x39
alaraja:	.byte	0x30

# Maaritetaan ohjelman aikana tarvittavat tulosteet
ALKUTULOSTE:	.asciiz "Syota lauseke: "
VIRHETULOSTE:	.asciiz "\nVirheellinen syote.\n"

SYOTE:		.asciiz ""
		.space 30

		.text

main:		li	$v0, 4				# Ladataan syscallin string tulostuspalvelu
		la	$a0, ALKUTULOSTE		# Osoite josta tuloste luetaan
		syscall
		and	$s0, $zero, $s0			# Alustetaan rekisteri, johon luettu merkki asetetaan
		and	$t0, $zero, $t0			# Alustetaan laskuri, jolla määritetään merkille oikea 
							# tarkastelulohko
		
lueSyote:
		li	$v0, 12				# Ladataan syscallin charin lukupalvelu
		la	$s0, SYOTE			# Osoite, johon luettu merkki ohjataan
		syscall
		sb	$v0, 0($s0)			# Ladataan luettu merkki rekisteriin 
		
		# 1. kierroksen tarkastus
		beqz	$t0, v1tarkistus 		# Ensimmäisen merkin on oltava numero
		
		# 2. kierroksen tarkastus
		beq	$t0, 1, v2tarkistus		# Toinen merkki saa olla joko numero tai pilkku. 
							# Jos luetaan pilkku, siirrytään seuraavaan tarkasteluun,
							# muuten pysytään samassa
		
		# 3. kierroksen tarkastus		
		#beq	$t0, 2, v3tarkistus		# Pilkun jalkeen on tultava numero
		
		# 4. kierroksen tarkastus
		#beq	$t0, 3, v4tarkistus		# Pilkun jälkeinen toinen merkki voi olla joko numero
							# tai operaattori. Jos luetaan operaattori, siirrytään
							# seuraavaan tarkasteluun, muuten pysytään samassa.

		# Jos löydetaan operaattori, hypataan tarkistusten alkuun.
		# Erikoistilanteena potenssi, jolloin merkin jälkeen etsitään kokonaislukua		
		
pinotallennus:	j	lueSyote			# Tahan pinoon tallentaminen

pilkkutilanne:	j 	pilkkutilanne			# Mita talla tehdaan?

loppu:		j	loppu

v1tarkistus:	lb	$t1, alaraja			# Ladataan numeroiden ascii-alaraja
		lb	$t3, 0($s0)			# Ladataan luettu merkki
		sge	$t2, $t3, $t1			# Katsotaan, onko luettu merkki rajan yläpuolella
		lb	$t1, ylaraja			# Ladtaan numeroiden yläraja
		sle	$t3, $t3, $t1			# Katsotaan, onko luettu merkki rajan alapuolella
		
		and	$t1, $t2, $t3			# Jos siis rajojen valissa, merkki on numero ja 
							# asetetaan $t1 = 1
		beqz	$t1, virhe			# Jos merkki ei ollut numero, hypätään virheeseen
		addi	$t0, $t0, 1			# Kasvatetaan tarkastelulaskuria
		j	pinotallennus			# Hypätään pinotallennukseen, jossa luettu merkki asetetaan
							# pinoon
							
v2tarkistus:	lb	$t1, alaraja			# Ladataan numeroiden ascii-alaraja
		lb	$t3, 0($s0)			# Ladataan luettu merkki
		sge	$t2, $t3, $t1			# Katsotaan, onko luettu merkki rajan yläpuolella
		lb	$t1, ylaraja			# Ladtaan numeroiden ylaraja
		sle	$t4, $t3, $t1			# Katsotaan, onko luettu merkki rajan alapuolella
		
		and	$t1, $t2, $t4			# Jos siis rajojen valissa, merkki on numero ja 
							# asetetaan $t1 = 1
		beq	$t1, 1, pinotallennus		# Jos kyseessä numero, hypätään pinotallennukseen
		
		lb	$t1, pilkku			# Ladataan numeroiden ascii-alaraja
		beq	$t1, $t3, pilkkutilanne		# Jos löydetään pilkku, hypataan pilkkutilanteeseen
		
		j	virhe				# Jos kyseessä ei ollut numero eikä pilkku, hypätään
							# virheeseen
	
virhe:		
		li	$v0, 4				# Ladataan syscallin string tulostuspalvelu
		la	$a0, VIRHETULOSTE		# Osoite josta tuloste luetaan
		syscall	

		j	main				# Hypataan takaisin ohjelman alkuun
		
#aliohjelmat
lisaaminen:	#add.s	$,$,$
		jr	$ra

vahennys:	#sub.s	$,$,$
		jr	$ra

kertominen:	#loop add.s x kertaa
		jr	$ra

jako:		#
		jr	$ra

potenssi:	#
		jr	$ra
