## Assemblylaskin
  	.globl	main
		.data

potenssi:	.byte	0x5E
kerto:		.byte	0x2A
jako:		.byte	0x2F
summa:		.byte	0x2B
vahennys:	.byte	0x2D
pilkku:		.byte	0x2C
ylaraja:	.byte	0x39
alaraja:	.byte	0x30

		.space 31

alkuViesti:	.asciiz	"Syötä lauseke: "
lauseke:	.asciiz ""
		.space	31
		.align	2

		.text

main:		li	$v0, 4
		la	$a0, alkuViesti
		syscall

		li	$v0, 8
		la	$a0, lauseke
		li	$a1, 31
		syscall

		la	$s0, lauseke		# Osoitin lausekkeeseen
		addi	$s1, $zero, 0x10014000	# Ulostulopino
		and	$s2, $s2, $zero		# Pinon laskuri
		and	$s3, $s3, $zero		# Ulostulopinon laskuri

alg:		lb	$t0, 0($s0)		# Ladataan merkki osoittimesta
		lb	$t1, alaraja		# Ladataan numeroiden ascii-alaraja
		sge	$t2, $t0, $t1		# Katsotaan, onko luettu merkki rajan yläpuolella
		lb	$t1, ylaraja		# Ladataan numeroiden ascii-yläraja
		sle	$t3, $t0, $t1		# Katsotaan, onko luettu merkki rajan alapuolella
		and	$t1, $t2, $t3		# Jos siis rajojen välissä, merkki on numero ja 
						# asetetaan $t1 = 1
		beqz	$t1 tutkiOperaattori	# Jos ei ole numero, katsotaan onko jokin operaattori
		jal	string2float
		j	alg		

tutkiOperaattori:
		seq	$t1, $t0, 0x20		# Onko space
		beq	$t1, 1,	kasvatus
		seq	$t1, $t0, 0x5E		# Onko potenssi
		beq	$t1, 1, lisaaPinoon
		seq	$t1, $t0, 0x2A		# onko kerto
		beq	$t1, 1, expVertailu
		seq	$t1, $t0, 0x2F		# Onko jako
		beq	$t1, 1, expVertailu
		seq	$t1, $t0, 0x2B		# Onko summa
		beq	$t1, 1, expVertailu
		seq	$t1, $t0, 0x2D		# Onko vähennys
		beq	$t1, 1, expVertailu
		beqz	$t0, parsittu
		beq	$t0, 10, parsittu

		j	VIRHE

expVertailu: 
						# Katsotaan onko eksponentteja

		beqz	$s2, lisaaPinoon	# Jos pinossa ei ole mitään lisätään suoraan pinoon
						# Katsotaan onko pinon päällimmäinen
		lw	$t1, 4($sp)		# potenssi, kerto, tai jakolasku

		li	$t2, 0x5E		# eksponentti
		seq	$t3, $t1, $t2		# Jos eksponentti
		beqz	$t3, kertoVertailu
		sw	$t1, 0($s1)
		addi	$s2, $s2, -1
		addi	$s3, $s3, 1
		addi	$s1, $s1, 4
		addi	$sp, $sp, 4
		j	expVertailu

kertoVertailu:	lw	$t1, 4($sp)		
		li	$t2, 0x2A		# kertolasku	
		seq	$t3, $t1, $t2		# jos kertolasku
		li	$t2, 0x2F		# jakolasku
		seq	$t4, $t1, $t2
		or	$t2, $t3, $t4
		beqz	$t2, summaVertailu

		sw	$t1, 0($s1)
		addi	$s2, $s2, -1
		addi	$s3, $s3, 1
		addi	$s1, $s1, 4
		addi	$sp, $sp, 4

		beq	$t0, 0x2A, lisaaPinoon
		beq	$t0, 0x2F, lisaaPinoon

summaVertailu:	lw	$t1, 4($sp)
		sw	$t1, 0($s1)
		addi	$s2, $s2, -1
		addi	$s3, $s3, 1
		addi	$s1, $s1, 4
		addi	$sp, $sp, 4
		j	lisaaPinoon

kasvatus:	
		addi	$s0, $s0, 1
		j	alg

lisaaPinoon:	
		addi	$s2, $s2, 1
		sw	$t0, 0($sp)
		addi	$sp, $sp, -4
		addi	$s0, $s0, 1
		j	alg
		# Kaikki merkit haettu, käydään läpi pinoa
		# Operaattori ulostulojonoon
VIRHE:		j	VIRHE		
parsittu:	
		addi	$sp, $sp, 4
		beqz	$s2, pinoTyhja
		lw	$t0, 0($sp)
		addi	$s2, $s2, -1
		addi	$s3, $s3, 1
		sw	$t0, 0($s1)
		addi	$s1, $s1, 4
		j	parsittu

# Tyhjätään ulostulojono RPN-algoritmilla ja lasketaan
pinoTyhja:	
		addi	$s5, $zero, 0x10014000	# Ulostulopinon osoite
		addi	$sp, $sp, -4
		
laske:		lw	$t0, 0($s5)		# Ladataan merkki ulostulopinosta
		addi	$s3, $s3, -1		# Vähennetään ulostulopinon laskuria
						# Onko numero vai operaattori
						
		beq	$t0, 0x5E, laskePotenssi
		beq	$t0, 0x2A, laskeKerto
		beq	$t0, 0x2F, laskeJako
		beq	$t0, 0x2B, laskeSumma
		beq	$t0, 0x2D, laskeErotus
		
		beqz	$t0, loppu
		sw	$t0, 0($sp)
		addi	$sp, $sp, -4
		addi	$s5, $s5, 4
		addi	$s2, $s2, 1
		addi	$s3, $s3, -1
		j	laske

laskePotenssi: 	j laskePotenssi
laskeKerto:	j laskeKerto
laskeJako:	j laskeJako

laskeSumma:	lwc1	$f0, 8($sp)
		addi	$s2, $s2, -1
		lwc1	$f1, 4($sp)
		
		add.s	$f0, $f0, $f1
		swc1	$f0, 4($sp)
		addi	$s5, $s5, 4
		j	laske
		
laskeErotus:	lwc1	$f0, 8($sp)
		addi	$s2, $s2, -1
		lwc1	$f1, 4($sp)
		
		sub.s	$f0, $f0, $f1
		swc1	$f0, 4($sp)
		addi	$s5, $s5, 4
		j	laske
		
loppu:		j	loppu


##-******************************************************************************************-##
# String2Float, muunnos toimii oikein
string2float:	li	$t0, 10			# Muunnoksessa tarvitaan kerrointa 10
		mtc1	$t0, $f2		# Siirretään se apuprosessorille
		cvt.s.w	$f2, $f2		# Muunnetaan numero floatiksi

		li	$t0, 0			# Nollataan
		mtc1	$t0, $f4		# Asetetaan rekisteri $f4 nollaksi (tästä tulee kokonaislukuosa )
		cvt.s.w	$f4, $f4		# Muunnetaan liukuluvuksi rekisterin sisältö

		mtc1	$t0, $f6		# Murto-osan varasto $f6 asetetaan nollaksi
		cvt.s.w	$f6, $f6		# Muunnetaan liukuluvuksi

		li	$t4, 0			# Murto-osan numeroiden lukumäärän nollaus
		li	$t5, 0			# Tieto lisätäänkö murto-osaan vai kokonaislukuun

lukulooppi:	lb	$t2, 0($s0)		# Ladataan merkki syötteestä
		bne	$t2, 0x2c, eiPilkkua	# Tutkitaan onko annettu merkki pilkku, jos ei niin hypätään
		li	$t5, 1			# Pilkun jälkeen murtolippu päälle
		j	seuraavaMerkki		# Hypätään osoittimen kasvatukseen

eiPilkkua:					# Tutkitaan vieläkö luetaan lukua vai onko tultu loppuun
		lb	$t6, ylaraja		# Numeroiden yläraja
		sle	$t7, $t2, $t6		# Onko pienempi tai yhtäsuuri kuin yläraja
		lb	$t6, alaraja		# Numeroiden alaraja
		sge	$t8, $t2, $t6		# Suurempi tai yhtäsuuri
		and	$t6, $t7, $t8		# Jos kumpikin ehto täyttyy -> numero

		beqz	$t6, numeroLoppu	# Jos ei numero, niin hypätään

		beq	$t5, 1, lueMurto	# Jos murtolippu on päällä, hypätään

lueKokonais:	subi	$t2, $t2, 0x30		# Muutetaan ascii-merkki numeroksi
		mtc1	$t2, $f10		# Siirretään merkki apuprosessorille
		cvt.s.w	$f10, $f10		# Muunnetaan liukuluvuksi
		mul.s	$f4, $f4, $f2		# Kerrotaan jo luettua aikaisempaa lukua kymmenellä
		add.s	$f4, $f4, $f10		# Lisätään merkki kerrottuun arvoon
		j	seuraavaMerkki		# Siirrytään kasvattamaan laskuria

lueMurto:	subi	$t2, $t2, 0x30		# Muutetaan ascii-merkki numeroksi
		mtc1	$t2, $f10		# Siirretään numero apuprosessorille
		cvt.s.w	$f10, $f10		# Muunnetaan floatiksi
		mul.s	$f6, $f6, $f2		
		add.s	$f6, $f6, $f10		# Lisätään merkki murto-osaan
		addi	$t4, $t4, 1		# Kasvatetaan murto-osan numeroiden lukumäärää
		j	seuraavaMerkki		# Siirrytään kasvattamaan laskuria

seuraavaMerkki:	addi	$s0, $s0, 1		# Kasvatetaan luettavan merkin osoitetta
		j	lukulooppi		# Luetaan seuraava merkki

numeroLoppu:	beq	$t5, 0, ohitaMurto	# Jos numero on luettu loppuun eikä murto-osaa ole ohitetaan
		li	$t0, 1			# Asetetaan $t0 1:kse
		mtc1	$t0, $f20		# Kopioidaan 1 $f20:een
		cvt.s.w	$f20, $f20		# Liukulukumuunnos

murtoLooppi:	mul.s	$f20, $f20, $f2		# Kerrotaan f20 10:llä
		addi	$t4, $t4, -1		# Pienennetään murto-osan numeroiden lukumäärää
		bgtz	$t4, murtoLooppi	# Jos murto-osassa on numeroita jäljellä uudestaan
		div.s	$f6, $f6, $f20		# Lopuksi jaetaan
		add.s	$f4, $f4, $f6		# Ja summataan

ohitaMurto:	mov.s	$f0, $f4		# Kopioidaan summa f0:aan
		swc1	$f0, 0($s1)		# Tallennetaan arvo $s1:een
		addi	$s3, $s3, 1
		addi	$s1, $s1, 4
		jr	$ra			# Palataan takaisin pääohjelmaan
