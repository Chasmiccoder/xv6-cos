
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	bbe080e7          	jalr	-1090(ra) # 5bce <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	bac080e7          	jalr	-1108(ra) # 5bce <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
      42:	0d250513          	addi	a0,a0,210 # 6110 <malloc+0x10c>
      46:	00006097          	auipc	ra,0x6
      4a:	f00080e7          	jalr	-256(ra) # 5f46 <printf>
=======
      42:	06250513          	addi	a0,a0,98 # 60a0 <malloc+0xea>
      46:	00006097          	auipc	ra,0x6
      4a:	eb8080e7          	jalr	-328(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	b3e080e7          	jalr	-1218(ra) # 5b8e <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	0000a797          	auipc	a5,0xa
      5c:	51078793          	addi	a5,a5,1296 # a568 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	c1868693          	addi	a3,a3,-1000 # cc78 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
      84:	0b050513          	addi	a0,a0,176 # 6130 <malloc+0x12c>
      88:	00006097          	auipc	ra,0x6
      8c:	ebe080e7          	jalr	-322(ra) # 5f46 <printf>
=======
      84:	04050513          	addi	a0,a0,64 # 60c0 <malloc+0x10a>
      88:	00006097          	auipc	ra,0x6
      8c:	e76080e7          	jalr	-394(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	afc080e7          	jalr	-1284(ra) # 5b8e <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
      ac:	0a050513          	addi	a0,a0,160 # 6148 <malloc+0x144>
=======
      ac:	03050513          	addi	a0,a0,48 # 60d8 <malloc+0x122>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      b0:	00006097          	auipc	ra,0x6
      b4:	b1e080e7          	jalr	-1250(ra) # 5bce <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	afa080e7          	jalr	-1286(ra) # 5bb6 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
      ca:	0a250513          	addi	a0,a0,162 # 6168 <malloc+0x164>
=======
      ca:	03250513          	addi	a0,a0,50 # 60f8 <malloc+0x142>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      ce:	00006097          	auipc	ra,0x6
      d2:	b00080e7          	jalr	-1280(ra) # 5bce <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
      ea:	06a50513          	addi	a0,a0,106 # 6150 <malloc+0x14c>
      ee:	00006097          	auipc	ra,0x6
      f2:	e58080e7          	jalr	-424(ra) # 5f46 <printf>
=======
      ea:	ffa50513          	addi	a0,a0,-6 # 60e0 <malloc+0x12a>
      ee:	00006097          	auipc	ra,0x6
      f2:	e10080e7          	jalr	-496(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	a96080e7          	jalr	-1386(ra) # 5b8e <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     106:	07650513          	addi	a0,a0,118 # 6178 <malloc+0x174>
     10a:	00006097          	auipc	ra,0x6
     10e:	e3c080e7          	jalr	-452(ra) # 5f46 <printf>
=======
     106:	00650513          	addi	a0,a0,6 # 6108 <malloc+0x152>
     10a:	00006097          	auipc	ra,0x6
     10e:	df4080e7          	jalr	-524(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	a7a080e7          	jalr	-1414(ra) # 5b8e <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     130:	07450513          	addi	a0,a0,116 # 61a0 <malloc+0x19c>
=======
     130:	00450513          	addi	a0,a0,4 # 6130 <malloc+0x17a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     134:	00006097          	auipc	ra,0x6
     138:	aaa080e7          	jalr	-1366(ra) # 5bde <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     144:	06050513          	addi	a0,a0,96 # 61a0 <malloc+0x19c>
=======
     144:	ff050513          	addi	a0,a0,-16 # 6130 <malloc+0x17a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     148:	00006097          	auipc	ra,0x6
     14c:	a86080e7          	jalr	-1402(ra) # 5bce <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
<<<<<<< HEAD
     158:	05c58593          	addi	a1,a1,92 # 61b0 <malloc+0x1ac>
=======
     158:	fec58593          	addi	a1,a1,-20 # 6140 <malloc+0x18a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     15c:	00006097          	auipc	ra,0x6
     160:	a52080e7          	jalr	-1454(ra) # 5bae <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     16c:	03850513          	addi	a0,a0,56 # 61a0 <malloc+0x19c>
=======
     16c:	fc850513          	addi	a0,a0,-56 # 6130 <malloc+0x17a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     170:	00006097          	auipc	ra,0x6
     174:	a5e080e7          	jalr	-1442(ra) # 5bce <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
<<<<<<< HEAD
     180:	03c58593          	addi	a1,a1,60 # 61b8 <malloc+0x1b4>
=======
     180:	fcc58593          	addi	a1,a1,-52 # 6148 <malloc+0x192>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	a28080e7          	jalr	-1496(ra) # 5bae <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     198:	00c50513          	addi	a0,a0,12 # 61a0 <malloc+0x19c>
=======
     198:	f9c50513          	addi	a0,a0,-100 # 6130 <malloc+0x17a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     19c:	00006097          	auipc	ra,0x6
     1a0:	a42080e7          	jalr	-1470(ra) # 5bde <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	a10080e7          	jalr	-1520(ra) # 5bb6 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	a06080e7          	jalr	-1530(ra) # 5bb6 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     1ce:	ff650513          	addi	a0,a0,-10 # 61c0 <malloc+0x1bc>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	d74080e7          	jalr	-652(ra) # 5f46 <printf>
=======
     1ce:	f8650513          	addi	a0,a0,-122 # 6150 <malloc+0x19a>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	d2c080e7          	jalr	-724(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00006097          	auipc	ra,0x6
     1e0:	9b2080e7          	jalr	-1614(ra) # 5b8e <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00006097          	auipc	ra,0x6
     214:	9be080e7          	jalr	-1602(ra) # 5bce <open>
    close(fd);
     218:	00006097          	auipc	ra,0x6
     21c:	99e080e7          	jalr	-1634(ra) # 5bb6 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	zext.b	s1,s1
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00006097          	auipc	ra,0x6
     24a:	998080e7          	jalr	-1640(ra) # 5bde <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	zext.b	s1,s1
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     280:	f6c50513          	addi	a0,a0,-148 # 61e8 <malloc+0x1e4>
=======
     280:	efc50513          	addi	a0,a0,-260 # 6178 <malloc+0x1c2>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     284:	00006097          	auipc	ra,0x6
     288:	95a080e7          	jalr	-1702(ra) # 5bde <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
<<<<<<< HEAD
     294:	f58a8a93          	addi	s5,s5,-168 # 61e8 <malloc+0x1e4>
=======
     294:	ee8a8a93          	addi	s5,s5,-280 # 6178 <malloc+0x1c2>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      int cc = write(fd, buf, sz);
     298:	0000da17          	auipc	s4,0xd
     29c:	9e0a0a13          	addi	s4,s4,-1568 # cc78 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <diskfull+0x7>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00006097          	auipc	ra,0x6
     2b0:	922080e7          	jalr	-1758(ra) # 5bce <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00006097          	auipc	ra,0x6
     2c2:	8f0080e7          	jalr	-1808(ra) # 5bae <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49263          	bne	s1,a0,32c <bigwrite+0xc8>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00006097          	auipc	ra,0x6
     2d6:	8dc080e7          	jalr	-1828(ra) # 5bae <write>
      if(cc != sz){
     2da:	04951a63          	bne	a0,s1,32e <bigwrite+0xca>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00006097          	auipc	ra,0x6
     2e4:	8d6080e7          	jalr	-1834(ra) # 5bb6 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00006097          	auipc	ra,0x6
     2ee:	8f4080e7          	jalr	-1804(ra) # 5bde <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
<<<<<<< HEAD
     316:	ee650513          	addi	a0,a0,-282 # 61f8 <malloc+0x1f4>
     31a:	00006097          	auipc	ra,0x6
     31e:	c2c080e7          	jalr	-980(ra) # 5f46 <printf>
=======
     316:	e7650513          	addi	a0,a0,-394 # 6188 <malloc+0x1d2>
     31a:	00006097          	auipc	ra,0x6
     31e:	be4080e7          	jalr	-1052(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     322:	4505                	li	a0,1
     324:	00006097          	auipc	ra,0x6
     328:	86a080e7          	jalr	-1942(ra) # 5b8e <exit>
      if(cc != sz){
     32c:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
<<<<<<< HEAD
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	ee250513          	addi	a0,a0,-286 # 6218 <malloc+0x214>
     33e:	00006097          	auipc	ra,0x6
     342:	c08080e7          	jalr	-1016(ra) # 5f46 <printf>
=======
     32e:	86aa                	mv	a3,a0
     330:	864e                	mv	a2,s3
     332:	85de                	mv	a1,s7
     334:	00006517          	auipc	a0,0x6
     338:	e7450513          	addi	a0,a0,-396 # 61a8 <malloc+0x1f2>
     33c:	00006097          	auipc	ra,0x6
     340:	bc2080e7          	jalr	-1086(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
     344:	4505                	li	a0,1
     346:	00006097          	auipc	ra,0x6
     34a:	848080e7          	jalr	-1976(ra) # 5b8e <exit>

000000000000034e <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     34e:	7179                	addi	sp,sp,-48
     350:	f406                	sd	ra,40(sp)
     352:	f022                	sd	s0,32(sp)
     354:	ec26                	sd	s1,24(sp)
     356:	e84a                	sd	s2,16(sp)
     358:	e44e                	sd	s3,8(sp)
     35a:	e052                	sd	s4,0(sp)
     35c:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
<<<<<<< HEAD
     360:	00006517          	auipc	a0,0x6
     364:	ed050513          	addi	a0,a0,-304 # 6230 <malloc+0x22c>
     368:	00006097          	auipc	ra,0x6
     36c:	8ae080e7          	jalr	-1874(ra) # 5c16 <unlink>
     370:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     374:	00006997          	auipc	s3,0x6
     378:	ebc98993          	addi	s3,s3,-324 # 6230 <malloc+0x22c>
=======
     35e:	00006517          	auipc	a0,0x6
     362:	e6250513          	addi	a0,a0,-414 # 61c0 <malloc+0x20a>
     366:	00006097          	auipc	ra,0x6
     36a:	878080e7          	jalr	-1928(ra) # 5bde <unlink>
     36e:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     372:	00006997          	auipc	s3,0x6
     376:	e4e98993          	addi	s3,s3,-434 # 61c0 <malloc+0x20a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     37a:	5a7d                	li	s4,-1
     37c:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     380:	20100593          	li	a1,513
     384:	854e                	mv	a0,s3
     386:	00006097          	auipc	ra,0x6
     38a:	848080e7          	jalr	-1976(ra) # 5bce <open>
     38e:	84aa                	mv	s1,a0
    if(fd < 0){
     390:	06054b63          	bltz	a0,406 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
     394:	4605                	li	a2,1
     396:	85d2                	mv	a1,s4
     398:	00006097          	auipc	ra,0x6
     39c:	816080e7          	jalr	-2026(ra) # 5bae <write>
    close(fd);
     3a0:	8526                	mv	a0,s1
     3a2:	00006097          	auipc	ra,0x6
     3a6:	814080e7          	jalr	-2028(ra) # 5bb6 <close>
    unlink("junk");
     3aa:	854e                	mv	a0,s3
     3ac:	00006097          	auipc	ra,0x6
     3b0:	832080e7          	jalr	-1998(ra) # 5bde <unlink>
  for(int i = 0; i < assumed_free; i++){
     3b4:	397d                	addiw	s2,s2,-1
     3b6:	fc0915e3          	bnez	s2,380 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
<<<<<<< HEAD
     3bc:	20100593          	li	a1,513
     3c0:	00006517          	auipc	a0,0x6
     3c4:	e7050513          	addi	a0,a0,-400 # 6230 <malloc+0x22c>
     3c8:	00006097          	auipc	ra,0x6
     3cc:	83e080e7          	jalr	-1986(ra) # 5c06 <open>
     3d0:	84aa                	mv	s1,a0
=======
     3ba:	20100593          	li	a1,513
     3be:	00006517          	auipc	a0,0x6
     3c2:	e0250513          	addi	a0,a0,-510 # 61c0 <malloc+0x20a>
     3c6:	00006097          	auipc	ra,0x6
     3ca:	808080e7          	jalr	-2040(ra) # 5bce <open>
     3ce:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
     3d0:	04054863          	bltz	a0,420 <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
<<<<<<< HEAD
     3d6:	4605                	li	a2,1
     3d8:	00006597          	auipc	a1,0x6
     3dc:	de058593          	addi	a1,a1,-544 # 61b8 <malloc+0x1b4>
     3e0:	00006097          	auipc	ra,0x6
     3e4:	806080e7          	jalr	-2042(ra) # 5be6 <write>
     3e8:	4785                	li	a5,1
     3ea:	04f50963          	beq	a0,a5,43c <badwrite+0xec>
    printf("write failed\n");
     3ee:	00006517          	auipc	a0,0x6
     3f2:	e6250513          	addi	a0,a0,-414 # 6250 <malloc+0x24c>
     3f6:	00006097          	auipc	ra,0x6
     3fa:	b50080e7          	jalr	-1200(ra) # 5f46 <printf>
=======
     3d4:	4605                	li	a2,1
     3d6:	00006597          	auipc	a1,0x6
     3da:	d7258593          	addi	a1,a1,-654 # 6148 <malloc+0x192>
     3de:	00005097          	auipc	ra,0x5
     3e2:	7d0080e7          	jalr	2000(ra) # 5bae <write>
     3e6:	4785                	li	a5,1
     3e8:	04f50963          	beq	a0,a5,43a <badwrite+0xec>
    printf("write failed\n");
     3ec:	00006517          	auipc	a0,0x6
     3f0:	df450513          	addi	a0,a0,-524 # 61e0 <malloc+0x22a>
     3f4:	00006097          	auipc	ra,0x6
     3f8:	b0a080e7          	jalr	-1270(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     3fc:	4505                	li	a0,1
     3fe:	00005097          	auipc	ra,0x5
     402:	790080e7          	jalr	1936(ra) # 5b8e <exit>
      printf("open junk failed\n");
<<<<<<< HEAD
     408:	00006517          	auipc	a0,0x6
     40c:	e3050513          	addi	a0,a0,-464 # 6238 <malloc+0x234>
     410:	00006097          	auipc	ra,0x6
     414:	b36080e7          	jalr	-1226(ra) # 5f46 <printf>
=======
     406:	00006517          	auipc	a0,0x6
     40a:	dc250513          	addi	a0,a0,-574 # 61c8 <malloc+0x212>
     40e:	00006097          	auipc	ra,0x6
     412:	af0080e7          	jalr	-1296(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     416:	4505                	li	a0,1
     418:	00005097          	auipc	ra,0x5
     41c:	776080e7          	jalr	1910(ra) # 5b8e <exit>
    printf("open junk failed\n");
<<<<<<< HEAD
     422:	00006517          	auipc	a0,0x6
     426:	e1650513          	addi	a0,a0,-490 # 6238 <malloc+0x234>
     42a:	00006097          	auipc	ra,0x6
     42e:	b1c080e7          	jalr	-1252(ra) # 5f46 <printf>
=======
     420:	00006517          	auipc	a0,0x6
     424:	da850513          	addi	a0,a0,-600 # 61c8 <malloc+0x212>
     428:	00006097          	auipc	ra,0x6
     42c:	ad6080e7          	jalr	-1322(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     430:	4505                	li	a0,1
     432:	00005097          	auipc	ra,0x5
     436:	75c080e7          	jalr	1884(ra) # 5b8e <exit>
  }
  close(fd);
     43a:	8526                	mv	a0,s1
     43c:	00005097          	auipc	ra,0x5
     440:	77a080e7          	jalr	1914(ra) # 5bb6 <close>
  unlink("junk");
<<<<<<< HEAD
     446:	00006517          	auipc	a0,0x6
     44a:	dea50513          	addi	a0,a0,-534 # 6230 <malloc+0x22c>
     44e:	00005097          	auipc	ra,0x5
     452:	7c8080e7          	jalr	1992(ra) # 5c16 <unlink>
=======
     444:	00006517          	auipc	a0,0x6
     448:	d7c50513          	addi	a0,a0,-644 # 61c0 <malloc+0x20a>
     44c:	00005097          	auipc	ra,0x5
     450:	792080e7          	jalr	1938(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

  exit(0);
     454:	4501                	li	a0,0
     456:	00005097          	auipc	ra,0x5
     45a:	738080e7          	jalr	1848(ra) # 5b8e <exit>

000000000000045e <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     45e:	715d                	addi	sp,sp,-80
     460:	e486                	sd	ra,72(sp)
     462:	e0a2                	sd	s0,64(sp)
     464:	fc26                	sd	s1,56(sp)
     466:	f84a                	sd	s2,48(sp)
     468:	f44e                	sd	s3,40(sp)
     46a:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     46c:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     46e:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     472:	40000993          	li	s3,1024
    name[0] = 'z';
     476:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     47a:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     47e:	41f4d71b          	sraiw	a4,s1,0x1f
     482:	01b7571b          	srliw	a4,a4,0x1b
     486:	009707bb          	addw	a5,a4,s1
     48a:	4057d69b          	sraiw	a3,a5,0x5
     48e:	0306869b          	addiw	a3,a3,48
     492:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     496:	8bfd                	andi	a5,a5,31
     498:	9f99                	subw	a5,a5,a4
     49a:	0307879b          	addiw	a5,a5,48
     49e:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4a2:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4a6:	fb040513          	addi	a0,s0,-80
     4aa:	00005097          	auipc	ra,0x5
     4ae:	734080e7          	jalr	1844(ra) # 5bde <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     4b2:	60200593          	li	a1,1538
     4b6:	fb040513          	addi	a0,s0,-80
     4ba:	00005097          	auipc	ra,0x5
     4be:	714080e7          	jalr	1812(ra) # 5bce <open>
    if(fd < 0){
     4c2:	00054963          	bltz	a0,4d4 <outofinodes+0x76>
      // failure is eventually expected.
      break;
    }
    close(fd);
     4c6:	00005097          	auipc	ra,0x5
     4ca:	6f0080e7          	jalr	1776(ra) # 5bb6 <close>
  for(int i = 0; i < nzz; i++){
     4ce:	2485                	addiw	s1,s1,1
     4d0:	fb3493e3          	bne	s1,s3,476 <outofinodes+0x18>
     4d4:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     4d6:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     4da:	40000993          	li	s3,1024
    name[0] = 'z';
     4de:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4e2:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4e6:	41f4d71b          	sraiw	a4,s1,0x1f
     4ea:	01b7571b          	srliw	a4,a4,0x1b
     4ee:	009707bb          	addw	a5,a4,s1
     4f2:	4057d69b          	sraiw	a3,a5,0x5
     4f6:	0306869b          	addiw	a3,a3,48
     4fa:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     4fe:	8bfd                	andi	a5,a5,31
     500:	9f99                	subw	a5,a5,a4
     502:	0307879b          	addiw	a5,a5,48
     506:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     50a:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     50e:	fb040513          	addi	a0,s0,-80
     512:	00005097          	auipc	ra,0x5
     516:	6cc080e7          	jalr	1740(ra) # 5bde <unlink>
  for(int i = 0; i < nzz; i++){
     51a:	2485                	addiw	s1,s1,1
     51c:	fd3491e3          	bne	s1,s3,4de <outofinodes+0x80>
  }
}
     520:	60a6                	ld	ra,72(sp)
     522:	6406                	ld	s0,64(sp)
     524:	74e2                	ld	s1,56(sp)
     526:	7942                	ld	s2,48(sp)
     528:	79a2                	ld	s3,40(sp)
     52a:	6161                	addi	sp,sp,80
     52c:	8082                	ret

000000000000052e <copyin>:
{
     52e:	715d                	addi	sp,sp,-80
     530:	e486                	sd	ra,72(sp)
     532:	e0a2                	sd	s0,64(sp)
     534:	fc26                	sd	s1,56(sp)
     536:	f84a                	sd	s2,48(sp)
     538:	f44e                	sd	s3,40(sp)
     53a:	f052                	sd	s4,32(sp)
     53c:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     53e:	4785                	li	a5,1
     540:	07fe                	slli	a5,a5,0x1f
     542:	fcf43023          	sd	a5,-64(s0)
     546:	57fd                	li	a5,-1
     548:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     54c:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
<<<<<<< HEAD
     552:	00006a17          	auipc	s4,0x6
     556:	d0ea0a13          	addi	s4,s4,-754 # 6260 <malloc+0x25c>
=======
     550:	00006a17          	auipc	s4,0x6
     554:	ca0a0a13          	addi	s4,s4,-864 # 61f0 <malloc+0x23a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    uint64 addr = addrs[ai];
     558:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     55c:	20100593          	li	a1,513
     560:	8552                	mv	a0,s4
     562:	00005097          	auipc	ra,0x5
     566:	66c080e7          	jalr	1644(ra) # 5bce <open>
     56a:	84aa                	mv	s1,a0
    if(fd < 0){
     56c:	08054863          	bltz	a0,5fc <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     570:	6609                	lui	a2,0x2
     572:	85ce                	mv	a1,s3
     574:	00005097          	auipc	ra,0x5
     578:	63a080e7          	jalr	1594(ra) # 5bae <write>
    if(n >= 0){
     57c:	08055d63          	bgez	a0,616 <copyin+0xe8>
    close(fd);
     580:	8526                	mv	a0,s1
     582:	00005097          	auipc	ra,0x5
     586:	634080e7          	jalr	1588(ra) # 5bb6 <close>
    unlink("copyin1");
     58a:	8552                	mv	a0,s4
     58c:	00005097          	auipc	ra,0x5
     590:	652080e7          	jalr	1618(ra) # 5bde <unlink>
    n = write(1, (char*)addr, 8192);
     594:	6609                	lui	a2,0x2
     596:	85ce                	mv	a1,s3
     598:	4505                	li	a0,1
     59a:	00005097          	auipc	ra,0x5
     59e:	614080e7          	jalr	1556(ra) # 5bae <write>
    if(n > 0){
     5a2:	08a04963          	bgtz	a0,634 <copyin+0x106>
    if(pipe(fds) < 0){
     5a6:	fb840513          	addi	a0,s0,-72
     5aa:	00005097          	auipc	ra,0x5
     5ae:	5f4080e7          	jalr	1524(ra) # 5b9e <pipe>
     5b2:	0a054063          	bltz	a0,652 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     5b6:	6609                	lui	a2,0x2
     5b8:	85ce                	mv	a1,s3
     5ba:	fbc42503          	lw	a0,-68(s0)
     5be:	00005097          	auipc	ra,0x5
     5c2:	5f0080e7          	jalr	1520(ra) # 5bae <write>
    if(n > 0){
     5c6:	0aa04363          	bgtz	a0,66c <copyin+0x13e>
    close(fds[0]);
     5ca:	fb842503          	lw	a0,-72(s0)
     5ce:	00005097          	auipc	ra,0x5
     5d2:	5e8080e7          	jalr	1512(ra) # 5bb6 <close>
    close(fds[1]);
     5d6:	fbc42503          	lw	a0,-68(s0)
     5da:	00005097          	auipc	ra,0x5
     5de:	5dc080e7          	jalr	1500(ra) # 5bb6 <close>
  for(int ai = 0; ai < 2; ai++){
     5e2:	0921                	addi	s2,s2,8
     5e4:	fd040793          	addi	a5,s0,-48
     5e8:	f6f918e3          	bne	s2,a5,558 <copyin+0x2a>
}
     5ec:	60a6                	ld	ra,72(sp)
     5ee:	6406                	ld	s0,64(sp)
     5f0:	74e2                	ld	s1,56(sp)
     5f2:	7942                	ld	s2,48(sp)
     5f4:	79a2                	ld	s3,40(sp)
     5f6:	7a02                	ld	s4,32(sp)
     5f8:	6161                	addi	sp,sp,80
     5fa:	8082                	ret
      printf("open(copyin1) failed\n");
<<<<<<< HEAD
     5fe:	00006517          	auipc	a0,0x6
     602:	c6a50513          	addi	a0,a0,-918 # 6268 <malloc+0x264>
     606:	00006097          	auipc	ra,0x6
     60a:	940080e7          	jalr	-1728(ra) # 5f46 <printf>
=======
     5fc:	00006517          	auipc	a0,0x6
     600:	bfc50513          	addi	a0,a0,-1028 # 61f8 <malloc+0x242>
     604:	00006097          	auipc	ra,0x6
     608:	8fa080e7          	jalr	-1798(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     60c:	4505                	li	a0,1
     60e:	00005097          	auipc	ra,0x5
     612:	580080e7          	jalr	1408(ra) # 5b8e <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
<<<<<<< HEAD
     618:	862a                	mv	a2,a0
     61a:	85ce                	mv	a1,s3
     61c:	00006517          	auipc	a0,0x6
     620:	c6450513          	addi	a0,a0,-924 # 6280 <malloc+0x27c>
     624:	00006097          	auipc	ra,0x6
     628:	922080e7          	jalr	-1758(ra) # 5f46 <printf>
=======
     616:	862a                	mv	a2,a0
     618:	85ce                	mv	a1,s3
     61a:	00006517          	auipc	a0,0x6
     61e:	bf650513          	addi	a0,a0,-1034 # 6210 <malloc+0x25a>
     622:	00006097          	auipc	ra,0x6
     626:	8dc080e7          	jalr	-1828(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     62a:	4505                	li	a0,1
     62c:	00005097          	auipc	ra,0x5
     630:	562080e7          	jalr	1378(ra) # 5b8e <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
<<<<<<< HEAD
     636:	862a                	mv	a2,a0
     638:	85ce                	mv	a1,s3
     63a:	00006517          	auipc	a0,0x6
     63e:	c7650513          	addi	a0,a0,-906 # 62b0 <malloc+0x2ac>
     642:	00006097          	auipc	ra,0x6
     646:	904080e7          	jalr	-1788(ra) # 5f46 <printf>
=======
     634:	862a                	mv	a2,a0
     636:	85ce                	mv	a1,s3
     638:	00006517          	auipc	a0,0x6
     63c:	c0850513          	addi	a0,a0,-1016 # 6240 <malloc+0x28a>
     640:	00006097          	auipc	ra,0x6
     644:	8be080e7          	jalr	-1858(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     648:	4505                	li	a0,1
     64a:	00005097          	auipc	ra,0x5
     64e:	544080e7          	jalr	1348(ra) # 5b8e <exit>
      printf("pipe() failed\n");
<<<<<<< HEAD
     654:	00006517          	auipc	a0,0x6
     658:	c8c50513          	addi	a0,a0,-884 # 62e0 <malloc+0x2dc>
     65c:	00006097          	auipc	ra,0x6
     660:	8ea080e7          	jalr	-1814(ra) # 5f46 <printf>
=======
     652:	00006517          	auipc	a0,0x6
     656:	c1e50513          	addi	a0,a0,-994 # 6270 <malloc+0x2ba>
     65a:	00006097          	auipc	ra,0x6
     65e:	8a4080e7          	jalr	-1884(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     662:	4505                	li	a0,1
     664:	00005097          	auipc	ra,0x5
     668:	52a080e7          	jalr	1322(ra) # 5b8e <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
<<<<<<< HEAD
     66e:	862a                	mv	a2,a0
     670:	85ce                	mv	a1,s3
     672:	00006517          	auipc	a0,0x6
     676:	c7e50513          	addi	a0,a0,-898 # 62f0 <malloc+0x2ec>
     67a:	00006097          	auipc	ra,0x6
     67e:	8cc080e7          	jalr	-1844(ra) # 5f46 <printf>
=======
     66c:	862a                	mv	a2,a0
     66e:	85ce                	mv	a1,s3
     670:	00006517          	auipc	a0,0x6
     674:	c1050513          	addi	a0,a0,-1008 # 6280 <malloc+0x2ca>
     678:	00006097          	auipc	ra,0x6
     67c:	886080e7          	jalr	-1914(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     680:	4505                	li	a0,1
     682:	00005097          	auipc	ra,0x5
     686:	50c080e7          	jalr	1292(ra) # 5b8e <exit>

000000000000068a <copyout>:
{
     68a:	711d                	addi	sp,sp,-96
     68c:	ec86                	sd	ra,88(sp)
     68e:	e8a2                	sd	s0,80(sp)
     690:	e4a6                	sd	s1,72(sp)
     692:	e0ca                	sd	s2,64(sp)
     694:	fc4e                	sd	s3,56(sp)
     696:	f852                	sd	s4,48(sp)
     698:	f456                	sd	s5,40(sp)
     69a:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     69c:	4785                	li	a5,1
     69e:	07fe                	slli	a5,a5,0x1f
     6a0:	faf43823          	sd	a5,-80(s0)
     6a4:	57fd                	li	a5,-1
     6a6:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     6aa:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
<<<<<<< HEAD
     6b0:	00006a17          	auipc	s4,0x6
     6b4:	c70a0a13          	addi	s4,s4,-912 # 6320 <malloc+0x31c>
    n = write(fds[1], "x", 1);
     6b8:	00006a97          	auipc	s5,0x6
     6bc:	b00a8a93          	addi	s5,s5,-1280 # 61b8 <malloc+0x1b4>
=======
     6ae:	00006a17          	auipc	s4,0x6
     6b2:	c02a0a13          	addi	s4,s4,-1022 # 62b0 <malloc+0x2fa>
    n = write(fds[1], "x", 1);
     6b6:	00006a97          	auipc	s5,0x6
     6ba:	a92a8a93          	addi	s5,s5,-1390 # 6148 <malloc+0x192>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    uint64 addr = addrs[ai];
     6be:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6c2:	4581                	li	a1,0
     6c4:	8552                	mv	a0,s4
     6c6:	00005097          	auipc	ra,0x5
     6ca:	508080e7          	jalr	1288(ra) # 5bce <open>
     6ce:	84aa                	mv	s1,a0
    if(fd < 0){
     6d0:	08054663          	bltz	a0,75c <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     6d4:	6609                	lui	a2,0x2
     6d6:	85ce                	mv	a1,s3
     6d8:	00005097          	auipc	ra,0x5
     6dc:	4ce080e7          	jalr	1230(ra) # 5ba6 <read>
    if(n > 0){
     6e0:	08a04b63          	bgtz	a0,776 <copyout+0xec>
    close(fd);
     6e4:	8526                	mv	a0,s1
     6e6:	00005097          	auipc	ra,0x5
     6ea:	4d0080e7          	jalr	1232(ra) # 5bb6 <close>
    if(pipe(fds) < 0){
     6ee:	fa840513          	addi	a0,s0,-88
     6f2:	00005097          	auipc	ra,0x5
     6f6:	4ac080e7          	jalr	1196(ra) # 5b9e <pipe>
     6fa:	08054d63          	bltz	a0,794 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     6fe:	4605                	li	a2,1
     700:	85d6                	mv	a1,s5
     702:	fac42503          	lw	a0,-84(s0)
     706:	00005097          	auipc	ra,0x5
     70a:	4a8080e7          	jalr	1192(ra) # 5bae <write>
    if(n != 1){
     70e:	4785                	li	a5,1
     710:	08f51f63          	bne	a0,a5,7ae <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     714:	6609                	lui	a2,0x2
     716:	85ce                	mv	a1,s3
     718:	fa842503          	lw	a0,-88(s0)
     71c:	00005097          	auipc	ra,0x5
     720:	48a080e7          	jalr	1162(ra) # 5ba6 <read>
    if(n > 0){
     724:	0aa04263          	bgtz	a0,7c8 <copyout+0x13e>
    close(fds[0]);
     728:	fa842503          	lw	a0,-88(s0)
     72c:	00005097          	auipc	ra,0x5
     730:	48a080e7          	jalr	1162(ra) # 5bb6 <close>
    close(fds[1]);
     734:	fac42503          	lw	a0,-84(s0)
     738:	00005097          	auipc	ra,0x5
     73c:	47e080e7          	jalr	1150(ra) # 5bb6 <close>
  for(int ai = 0; ai < 2; ai++){
     740:	0921                	addi	s2,s2,8
     742:	fc040793          	addi	a5,s0,-64
     746:	f6f91ce3          	bne	s2,a5,6be <copyout+0x34>
}
     74a:	60e6                	ld	ra,88(sp)
     74c:	6446                	ld	s0,80(sp)
     74e:	64a6                	ld	s1,72(sp)
     750:	6906                	ld	s2,64(sp)
     752:	79e2                	ld	s3,56(sp)
     754:	7a42                	ld	s4,48(sp)
     756:	7aa2                	ld	s5,40(sp)
     758:	6125                	addi	sp,sp,96
     75a:	8082                	ret
      printf("open(README) failed\n");
<<<<<<< HEAD
     75e:	00006517          	auipc	a0,0x6
     762:	bca50513          	addi	a0,a0,-1078 # 6328 <malloc+0x324>
     766:	00005097          	auipc	ra,0x5
     76a:	7e0080e7          	jalr	2016(ra) # 5f46 <printf>
=======
     75c:	00006517          	auipc	a0,0x6
     760:	b5c50513          	addi	a0,a0,-1188 # 62b8 <malloc+0x302>
     764:	00005097          	auipc	ra,0x5
     768:	79a080e7          	jalr	1946(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     76c:	4505                	li	a0,1
     76e:	00005097          	auipc	ra,0x5
     772:	420080e7          	jalr	1056(ra) # 5b8e <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
<<<<<<< HEAD
     778:	862a                	mv	a2,a0
     77a:	85ce                	mv	a1,s3
     77c:	00006517          	auipc	a0,0x6
     780:	bc450513          	addi	a0,a0,-1084 # 6340 <malloc+0x33c>
     784:	00005097          	auipc	ra,0x5
     788:	7c2080e7          	jalr	1986(ra) # 5f46 <printf>
=======
     776:	862a                	mv	a2,a0
     778:	85ce                	mv	a1,s3
     77a:	00006517          	auipc	a0,0x6
     77e:	b5650513          	addi	a0,a0,-1194 # 62d0 <malloc+0x31a>
     782:	00005097          	auipc	ra,0x5
     786:	77c080e7          	jalr	1916(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     78a:	4505                	li	a0,1
     78c:	00005097          	auipc	ra,0x5
     790:	402080e7          	jalr	1026(ra) # 5b8e <exit>
      printf("pipe() failed\n");
<<<<<<< HEAD
     796:	00006517          	auipc	a0,0x6
     79a:	b4a50513          	addi	a0,a0,-1206 # 62e0 <malloc+0x2dc>
     79e:	00005097          	auipc	ra,0x5
     7a2:	7a8080e7          	jalr	1960(ra) # 5f46 <printf>
=======
     794:	00006517          	auipc	a0,0x6
     798:	adc50513          	addi	a0,a0,-1316 # 6270 <malloc+0x2ba>
     79c:	00005097          	auipc	ra,0x5
     7a0:	762080e7          	jalr	1890(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	3e8080e7          	jalr	1000(ra) # 5b8e <exit>
      printf("pipe write failed\n");
<<<<<<< HEAD
     7b0:	00006517          	auipc	a0,0x6
     7b4:	bc050513          	addi	a0,a0,-1088 # 6370 <malloc+0x36c>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	78e080e7          	jalr	1934(ra) # 5f46 <printf>
=======
     7ae:	00006517          	auipc	a0,0x6
     7b2:	b5250513          	addi	a0,a0,-1198 # 6300 <malloc+0x34a>
     7b6:	00005097          	auipc	ra,0x5
     7ba:	748080e7          	jalr	1864(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     7be:	4505                	li	a0,1
     7c0:	00005097          	auipc	ra,0x5
     7c4:	3ce080e7          	jalr	974(ra) # 5b8e <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
<<<<<<< HEAD
     7ca:	862a                	mv	a2,a0
     7cc:	85ce                	mv	a1,s3
     7ce:	00006517          	auipc	a0,0x6
     7d2:	bba50513          	addi	a0,a0,-1094 # 6388 <malloc+0x384>
     7d6:	00005097          	auipc	ra,0x5
     7da:	770080e7          	jalr	1904(ra) # 5f46 <printf>
=======
     7c8:	862a                	mv	a2,a0
     7ca:	85ce                	mv	a1,s3
     7cc:	00006517          	auipc	a0,0x6
     7d0:	b4c50513          	addi	a0,a0,-1204 # 6318 <malloc+0x362>
     7d4:	00005097          	auipc	ra,0x5
     7d8:	72a080e7          	jalr	1834(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     7dc:	4505                	li	a0,1
     7de:	00005097          	auipc	ra,0x5
     7e2:	3b0080e7          	jalr	944(ra) # 5b8e <exit>

00000000000007e6 <truncate1>:
{
     7e6:	711d                	addi	sp,sp,-96
     7e8:	ec86                	sd	ra,88(sp)
     7ea:	e8a2                	sd	s0,80(sp)
     7ec:	e4a6                	sd	s1,72(sp)
     7ee:	e0ca                	sd	s2,64(sp)
     7f0:	fc4e                	sd	s3,56(sp)
     7f2:	f852                	sd	s4,48(sp)
     7f4:	f456                	sd	s5,40(sp)
     7f6:	1080                	addi	s0,sp,96
     7f8:	8aaa                	mv	s5,a0
  unlink("truncfile");
<<<<<<< HEAD
     7fc:	00006517          	auipc	a0,0x6
     800:	9a450513          	addi	a0,a0,-1628 # 61a0 <malloc+0x19c>
     804:	00005097          	auipc	ra,0x5
     808:	412080e7          	jalr	1042(ra) # 5c16 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     80c:	60100593          	li	a1,1537
     810:	00006517          	auipc	a0,0x6
     814:	99050513          	addi	a0,a0,-1648 # 61a0 <malloc+0x19c>
     818:	00005097          	auipc	ra,0x5
     81c:	3ee080e7          	jalr	1006(ra) # 5c06 <open>
     820:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     822:	4611                	li	a2,4
     824:	00006597          	auipc	a1,0x6
     828:	98c58593          	addi	a1,a1,-1652 # 61b0 <malloc+0x1ac>
     82c:	00005097          	auipc	ra,0x5
     830:	3ba080e7          	jalr	954(ra) # 5be6 <write>
=======
     7fa:	00006517          	auipc	a0,0x6
     7fe:	93650513          	addi	a0,a0,-1738 # 6130 <malloc+0x17a>
     802:	00005097          	auipc	ra,0x5
     806:	3dc080e7          	jalr	988(ra) # 5bde <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     80a:	60100593          	li	a1,1537
     80e:	00006517          	auipc	a0,0x6
     812:	92250513          	addi	a0,a0,-1758 # 6130 <malloc+0x17a>
     816:	00005097          	auipc	ra,0x5
     81a:	3b8080e7          	jalr	952(ra) # 5bce <open>
     81e:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     820:	4611                	li	a2,4
     822:	00006597          	auipc	a1,0x6
     826:	91e58593          	addi	a1,a1,-1762 # 6140 <malloc+0x18a>
     82a:	00005097          	auipc	ra,0x5
     82e:	384080e7          	jalr	900(ra) # 5bae <write>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd1);
     832:	8526                	mv	a0,s1
     834:	00005097          	auipc	ra,0x5
     838:	382080e7          	jalr	898(ra) # 5bb6 <close>
  int fd2 = open("truncfile", O_RDONLY);
<<<<<<< HEAD
     83e:	4581                	li	a1,0
     840:	00006517          	auipc	a0,0x6
     844:	96050513          	addi	a0,a0,-1696 # 61a0 <malloc+0x19c>
     848:	00005097          	auipc	ra,0x5
     84c:	3be080e7          	jalr	958(ra) # 5c06 <open>
     850:	84aa                	mv	s1,a0
=======
     83c:	4581                	li	a1,0
     83e:	00006517          	auipc	a0,0x6
     842:	8f250513          	addi	a0,a0,-1806 # 6130 <malloc+0x17a>
     846:	00005097          	auipc	ra,0x5
     84a:	388080e7          	jalr	904(ra) # 5bce <open>
     84e:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  int n = read(fd2, buf, sizeof(buf));
     850:	02000613          	li	a2,32
     854:	fa040593          	addi	a1,s0,-96
     858:	00005097          	auipc	ra,0x5
     85c:	34e080e7          	jalr	846(ra) # 5ba6 <read>
  if(n != 4){
     860:	4791                	li	a5,4
     862:	0cf51e63          	bne	a0,a5,93e <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
<<<<<<< HEAD
     868:	40100593          	li	a1,1025
     86c:	00006517          	auipc	a0,0x6
     870:	93450513          	addi	a0,a0,-1740 # 61a0 <malloc+0x19c>
     874:	00005097          	auipc	ra,0x5
     878:	392080e7          	jalr	914(ra) # 5c06 <open>
     87c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     87e:	4581                	li	a1,0
     880:	00006517          	auipc	a0,0x6
     884:	92050513          	addi	a0,a0,-1760 # 61a0 <malloc+0x19c>
     888:	00005097          	auipc	ra,0x5
     88c:	37e080e7          	jalr	894(ra) # 5c06 <open>
     890:	892a                	mv	s2,a0
=======
     866:	40100593          	li	a1,1025
     86a:	00006517          	auipc	a0,0x6
     86e:	8c650513          	addi	a0,a0,-1850 # 6130 <malloc+0x17a>
     872:	00005097          	auipc	ra,0x5
     876:	35c080e7          	jalr	860(ra) # 5bce <open>
     87a:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     87c:	4581                	li	a1,0
     87e:	00006517          	auipc	a0,0x6
     882:	8b250513          	addi	a0,a0,-1870 # 6130 <malloc+0x17a>
     886:	00005097          	auipc	ra,0x5
     88a:	348080e7          	jalr	840(ra) # 5bce <open>
     88e:	892a                	mv	s2,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  n = read(fd3, buf, sizeof(buf));
     890:	02000613          	li	a2,32
     894:	fa040593          	addi	a1,s0,-96
     898:	00005097          	auipc	ra,0x5
     89c:	30e080e7          	jalr	782(ra) # 5ba6 <read>
     8a0:	8a2a                	mv	s4,a0
  if(n != 0){
     8a2:	ed4d                	bnez	a0,95c <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8a4:	02000613          	li	a2,32
     8a8:	fa040593          	addi	a1,s0,-96
     8ac:	8526                	mv	a0,s1
     8ae:	00005097          	auipc	ra,0x5
     8b2:	2f8080e7          	jalr	760(ra) # 5ba6 <read>
     8b6:	8a2a                	mv	s4,a0
  if(n != 0){
     8b8:	e971                	bnez	a0,98c <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
<<<<<<< HEAD
     8bc:	4619                	li	a2,6
     8be:	00006597          	auipc	a1,0x6
     8c2:	b5a58593          	addi	a1,a1,-1190 # 6418 <malloc+0x414>
     8c6:	854e                	mv	a0,s3
     8c8:	00005097          	auipc	ra,0x5
     8cc:	31e080e7          	jalr	798(ra) # 5be6 <write>
=======
     8ba:	4619                	li	a2,6
     8bc:	00006597          	auipc	a1,0x6
     8c0:	aec58593          	addi	a1,a1,-1300 # 63a8 <malloc+0x3f2>
     8c4:	854e                	mv	a0,s3
     8c6:	00005097          	auipc	ra,0x5
     8ca:	2e8080e7          	jalr	744(ra) # 5bae <write>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  n = read(fd3, buf, sizeof(buf));
     8ce:	02000613          	li	a2,32
     8d2:	fa040593          	addi	a1,s0,-96
     8d6:	854a                	mv	a0,s2
     8d8:	00005097          	auipc	ra,0x5
     8dc:	2ce080e7          	jalr	718(ra) # 5ba6 <read>
  if(n != 6){
     8e0:	4799                	li	a5,6
     8e2:	0cf51d63          	bne	a0,a5,9bc <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     8e6:	02000613          	li	a2,32
     8ea:	fa040593          	addi	a1,s0,-96
     8ee:	8526                	mv	a0,s1
     8f0:	00005097          	auipc	ra,0x5
     8f4:	2b6080e7          	jalr	694(ra) # 5ba6 <read>
  if(n != 2){
     8f8:	4789                	li	a5,2
     8fa:	0ef51063          	bne	a0,a5,9da <truncate1+0x1f4>
  unlink("truncfile");
<<<<<<< HEAD
     900:	00006517          	auipc	a0,0x6
     904:	8a050513          	addi	a0,a0,-1888 # 61a0 <malloc+0x19c>
     908:	00005097          	auipc	ra,0x5
     90c:	30e080e7          	jalr	782(ra) # 5c16 <unlink>
=======
     8fe:	00006517          	auipc	a0,0x6
     902:	83250513          	addi	a0,a0,-1998 # 6130 <malloc+0x17a>
     906:	00005097          	auipc	ra,0x5
     90a:	2d8080e7          	jalr	728(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd1);
     90e:	854e                	mv	a0,s3
     910:	00005097          	auipc	ra,0x5
     914:	2a6080e7          	jalr	678(ra) # 5bb6 <close>
  close(fd2);
     918:	8526                	mv	a0,s1
     91a:	00005097          	auipc	ra,0x5
     91e:	29c080e7          	jalr	668(ra) # 5bb6 <close>
  close(fd3);
     922:	854a                	mv	a0,s2
     924:	00005097          	auipc	ra,0x5
     928:	292080e7          	jalr	658(ra) # 5bb6 <close>
}
     92c:	60e6                	ld	ra,88(sp)
     92e:	6446                	ld	s0,80(sp)
     930:	64a6                	ld	s1,72(sp)
     932:	6906                	ld	s2,64(sp)
     934:	79e2                	ld	s3,56(sp)
     936:	7a42                	ld	s4,48(sp)
     938:	7aa2                	ld	s5,40(sp)
     93a:	6125                	addi	sp,sp,96
     93c:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
<<<<<<< HEAD
     940:	862a                	mv	a2,a0
     942:	85d6                	mv	a1,s5
     944:	00006517          	auipc	a0,0x6
     948:	a7450513          	addi	a0,a0,-1420 # 63b8 <malloc+0x3b4>
     94c:	00005097          	auipc	ra,0x5
     950:	5fa080e7          	jalr	1530(ra) # 5f46 <printf>
=======
     93e:	862a                	mv	a2,a0
     940:	85d6                	mv	a1,s5
     942:	00006517          	auipc	a0,0x6
     946:	a0650513          	addi	a0,a0,-1530 # 6348 <malloc+0x392>
     94a:	00005097          	auipc	ra,0x5
     94e:	5b4080e7          	jalr	1460(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     952:	4505                	li	a0,1
     954:	00005097          	auipc	ra,0x5
     958:	23a080e7          	jalr	570(ra) # 5b8e <exit>
    printf("aaa fd3=%d\n", fd3);
<<<<<<< HEAD
     95e:	85ca                	mv	a1,s2
     960:	00006517          	auipc	a0,0x6
     964:	a7850513          	addi	a0,a0,-1416 # 63d8 <malloc+0x3d4>
     968:	00005097          	auipc	ra,0x5
     96c:	5de080e7          	jalr	1502(ra) # 5f46 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     970:	8652                	mv	a2,s4
     972:	85d6                	mv	a1,s5
     974:	00006517          	auipc	a0,0x6
     978:	a7450513          	addi	a0,a0,-1420 # 63e8 <malloc+0x3e4>
     97c:	00005097          	auipc	ra,0x5
     980:	5ca080e7          	jalr	1482(ra) # 5f46 <printf>
=======
     95c:	85ca                	mv	a1,s2
     95e:	00006517          	auipc	a0,0x6
     962:	a0a50513          	addi	a0,a0,-1526 # 6368 <malloc+0x3b2>
     966:	00005097          	auipc	ra,0x5
     96a:	598080e7          	jalr	1432(ra) # 5efe <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     96e:	8652                	mv	a2,s4
     970:	85d6                	mv	a1,s5
     972:	00006517          	auipc	a0,0x6
     976:	a0650513          	addi	a0,a0,-1530 # 6378 <malloc+0x3c2>
     97a:	00005097          	auipc	ra,0x5
     97e:	584080e7          	jalr	1412(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     982:	4505                	li	a0,1
     984:	00005097          	auipc	ra,0x5
     988:	20a080e7          	jalr	522(ra) # 5b8e <exit>
    printf("bbb fd2=%d\n", fd2);
<<<<<<< HEAD
     98e:	85a6                	mv	a1,s1
     990:	00006517          	auipc	a0,0x6
     994:	a7850513          	addi	a0,a0,-1416 # 6408 <malloc+0x404>
     998:	00005097          	auipc	ra,0x5
     99c:	5ae080e7          	jalr	1454(ra) # 5f46 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     9a0:	8652                	mv	a2,s4
     9a2:	85d6                	mv	a1,s5
     9a4:	00006517          	auipc	a0,0x6
     9a8:	a4450513          	addi	a0,a0,-1468 # 63e8 <malloc+0x3e4>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	59a080e7          	jalr	1434(ra) # 5f46 <printf>
=======
     98c:	85a6                	mv	a1,s1
     98e:	00006517          	auipc	a0,0x6
     992:	a0a50513          	addi	a0,a0,-1526 # 6398 <malloc+0x3e2>
     996:	00005097          	auipc	ra,0x5
     99a:	568080e7          	jalr	1384(ra) # 5efe <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     99e:	8652                	mv	a2,s4
     9a0:	85d6                	mv	a1,s5
     9a2:	00006517          	auipc	a0,0x6
     9a6:	9d650513          	addi	a0,a0,-1578 # 6378 <malloc+0x3c2>
     9aa:	00005097          	auipc	ra,0x5
     9ae:	554080e7          	jalr	1364(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     9b2:	4505                	li	a0,1
     9b4:	00005097          	auipc	ra,0x5
     9b8:	1da080e7          	jalr	474(ra) # 5b8e <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
<<<<<<< HEAD
     9be:	862a                	mv	a2,a0
     9c0:	85d6                	mv	a1,s5
     9c2:	00006517          	auipc	a0,0x6
     9c6:	a5e50513          	addi	a0,a0,-1442 # 6420 <malloc+0x41c>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	57c080e7          	jalr	1404(ra) # 5f46 <printf>
=======
     9bc:	862a                	mv	a2,a0
     9be:	85d6                	mv	a1,s5
     9c0:	00006517          	auipc	a0,0x6
     9c4:	9f050513          	addi	a0,a0,-1552 # 63b0 <malloc+0x3fa>
     9c8:	00005097          	auipc	ra,0x5
     9cc:	536080e7          	jalr	1334(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     9d0:	4505                	li	a0,1
     9d2:	00005097          	auipc	ra,0x5
     9d6:	1bc080e7          	jalr	444(ra) # 5b8e <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
<<<<<<< HEAD
     9dc:	862a                	mv	a2,a0
     9de:	85d6                	mv	a1,s5
     9e0:	00006517          	auipc	a0,0x6
     9e4:	a6050513          	addi	a0,a0,-1440 # 6440 <malloc+0x43c>
     9e8:	00005097          	auipc	ra,0x5
     9ec:	55e080e7          	jalr	1374(ra) # 5f46 <printf>
=======
     9da:	862a                	mv	a2,a0
     9dc:	85d6                	mv	a1,s5
     9de:	00006517          	auipc	a0,0x6
     9e2:	9f250513          	addi	a0,a0,-1550 # 63d0 <malloc+0x41a>
     9e6:	00005097          	auipc	ra,0x5
     9ea:	518080e7          	jalr	1304(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     9ee:	4505                	li	a0,1
     9f0:	00005097          	auipc	ra,0x5
     9f4:	19e080e7          	jalr	414(ra) # 5b8e <exit>

00000000000009f8 <writetest>:
{
     9f8:	7139                	addi	sp,sp,-64
     9fa:	fc06                	sd	ra,56(sp)
     9fc:	f822                	sd	s0,48(sp)
     9fe:	f426                	sd	s1,40(sp)
     a00:	f04a                	sd	s2,32(sp)
     a02:	ec4e                	sd	s3,24(sp)
     a04:	e852                	sd	s4,16(sp)
     a06:	e456                	sd	s5,8(sp)
     a08:	e05a                	sd	s6,0(sp)
     a0a:	0080                	addi	s0,sp,64
     a0c:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
<<<<<<< HEAD
     a10:	20200593          	li	a1,514
     a14:	00006517          	auipc	a0,0x6
     a18:	a4c50513          	addi	a0,a0,-1460 # 6460 <malloc+0x45c>
     a1c:	00005097          	auipc	ra,0x5
     a20:	1ea080e7          	jalr	490(ra) # 5c06 <open>
=======
     a0e:	20200593          	li	a1,514
     a12:	00006517          	auipc	a0,0x6
     a16:	9de50513          	addi	a0,a0,-1570 # 63f0 <malloc+0x43a>
     a1a:	00005097          	auipc	ra,0x5
     a1e:	1b4080e7          	jalr	436(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
     a22:	0a054d63          	bltz	a0,adc <writetest+0xe4>
     a26:	892a                	mv	s2,a0
     a28:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
<<<<<<< HEAD
     a2c:	00006997          	auipc	s3,0x6
     a30:	a5c98993          	addi	s3,s3,-1444 # 6488 <malloc+0x484>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a34:	00006a97          	auipc	s5,0x6
     a38:	a8ca8a93          	addi	s5,s5,-1396 # 64c0 <malloc+0x4bc>
=======
     a2a:	00006997          	auipc	s3,0x6
     a2e:	9ee98993          	addi	s3,s3,-1554 # 6418 <malloc+0x462>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a32:	00006a97          	auipc	s5,0x6
     a36:	a1ea8a93          	addi	s5,s5,-1506 # 6450 <malloc+0x49a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(i = 0; i < N; i++){
     a3a:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a3e:	4629                	li	a2,10
     a40:	85ce                	mv	a1,s3
     a42:	854a                	mv	a0,s2
     a44:	00005097          	auipc	ra,0x5
     a48:	16a080e7          	jalr	362(ra) # 5bae <write>
     a4c:	47a9                	li	a5,10
     a4e:	0af51563          	bne	a0,a5,af8 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a52:	4629                	li	a2,10
     a54:	85d6                	mv	a1,s5
     a56:	854a                	mv	a0,s2
     a58:	00005097          	auipc	ra,0x5
     a5c:	156080e7          	jalr	342(ra) # 5bae <write>
     a60:	47a9                	li	a5,10
     a62:	0af51a63          	bne	a0,a5,b16 <writetest+0x11e>
  for(i = 0; i < N; i++){
     a66:	2485                	addiw	s1,s1,1
     a68:	fd449be3          	bne	s1,s4,a3e <writetest+0x46>
  close(fd);
     a6c:	854a                	mv	a0,s2
     a6e:	00005097          	auipc	ra,0x5
     a72:	148080e7          	jalr	328(ra) # 5bb6 <close>
  fd = open("small", O_RDONLY);
<<<<<<< HEAD
     a78:	4581                	li	a1,0
     a7a:	00006517          	auipc	a0,0x6
     a7e:	9e650513          	addi	a0,a0,-1562 # 6460 <malloc+0x45c>
     a82:	00005097          	auipc	ra,0x5
     a86:	184080e7          	jalr	388(ra) # 5c06 <open>
     a8a:	84aa                	mv	s1,a0
=======
     a76:	4581                	li	a1,0
     a78:	00006517          	auipc	a0,0x6
     a7c:	97850513          	addi	a0,a0,-1672 # 63f0 <malloc+0x43a>
     a80:	00005097          	auipc	ra,0x5
     a84:	14e080e7          	jalr	334(ra) # 5bce <open>
     a88:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
     a8a:	0a054563          	bltz	a0,b34 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     a8e:	7d000613          	li	a2,2000
     a92:	0000c597          	auipc	a1,0xc
     a96:	1e658593          	addi	a1,a1,486 # cc78 <buf>
     a9a:	00005097          	auipc	ra,0x5
     a9e:	10c080e7          	jalr	268(ra) # 5ba6 <read>
  if(i != N*SZ*2){
     aa2:	7d000793          	li	a5,2000
     aa6:	0af51563          	bne	a0,a5,b50 <writetest+0x158>
  close(fd);
     aaa:	8526                	mv	a0,s1
     aac:	00005097          	auipc	ra,0x5
     ab0:	10a080e7          	jalr	266(ra) # 5bb6 <close>
  if(unlink("small") < 0){
<<<<<<< HEAD
     ab6:	00006517          	auipc	a0,0x6
     aba:	9aa50513          	addi	a0,a0,-1622 # 6460 <malloc+0x45c>
     abe:	00005097          	auipc	ra,0x5
     ac2:	158080e7          	jalr	344(ra) # 5c16 <unlink>
     ac6:	0a054463          	bltz	a0,b6e <writetest+0x174>
=======
     ab4:	00006517          	auipc	a0,0x6
     ab8:	93c50513          	addi	a0,a0,-1732 # 63f0 <malloc+0x43a>
     abc:	00005097          	auipc	ra,0x5
     ac0:	122080e7          	jalr	290(ra) # 5bde <unlink>
     ac4:	0a054463          	bltz	a0,b6c <writetest+0x174>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
     ac8:	70e2                	ld	ra,56(sp)
     aca:	7442                	ld	s0,48(sp)
     acc:	74a2                	ld	s1,40(sp)
     ace:	7902                	ld	s2,32(sp)
     ad0:	69e2                	ld	s3,24(sp)
     ad2:	6a42                	ld	s4,16(sp)
     ad4:	6aa2                	ld	s5,8(sp)
     ad6:	6b02                	ld	s6,0(sp)
     ad8:	6121                	addi	sp,sp,64
     ada:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
<<<<<<< HEAD
     ade:	85da                	mv	a1,s6
     ae0:	00006517          	auipc	a0,0x6
     ae4:	98850513          	addi	a0,a0,-1656 # 6468 <malloc+0x464>
     ae8:	00005097          	auipc	ra,0x5
     aec:	45e080e7          	jalr	1118(ra) # 5f46 <printf>
=======
     adc:	85da                	mv	a1,s6
     ade:	00006517          	auipc	a0,0x6
     ae2:	91a50513          	addi	a0,a0,-1766 # 63f8 <malloc+0x442>
     ae6:	00005097          	auipc	ra,0x5
     aea:	418080e7          	jalr	1048(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     aee:	4505                	li	a0,1
     af0:	00005097          	auipc	ra,0x5
     af4:	09e080e7          	jalr	158(ra) # 5b8e <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
<<<<<<< HEAD
     afa:	8626                	mv	a2,s1
     afc:	85da                	mv	a1,s6
     afe:	00006517          	auipc	a0,0x6
     b02:	99a50513          	addi	a0,a0,-1638 # 6498 <malloc+0x494>
     b06:	00005097          	auipc	ra,0x5
     b0a:	440080e7          	jalr	1088(ra) # 5f46 <printf>
=======
     af8:	8626                	mv	a2,s1
     afa:	85da                	mv	a1,s6
     afc:	00006517          	auipc	a0,0x6
     b00:	92c50513          	addi	a0,a0,-1748 # 6428 <malloc+0x472>
     b04:	00005097          	auipc	ra,0x5
     b08:	3fa080e7          	jalr	1018(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     b0c:	4505                	li	a0,1
     b0e:	00005097          	auipc	ra,0x5
     b12:	080080e7          	jalr	128(ra) # 5b8e <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
<<<<<<< HEAD
     b18:	8626                	mv	a2,s1
     b1a:	85da                	mv	a1,s6
     b1c:	00006517          	auipc	a0,0x6
     b20:	9b450513          	addi	a0,a0,-1612 # 64d0 <malloc+0x4cc>
     b24:	00005097          	auipc	ra,0x5
     b28:	422080e7          	jalr	1058(ra) # 5f46 <printf>
=======
     b16:	8626                	mv	a2,s1
     b18:	85da                	mv	a1,s6
     b1a:	00006517          	auipc	a0,0x6
     b1e:	94650513          	addi	a0,a0,-1722 # 6460 <malloc+0x4aa>
     b22:	00005097          	auipc	ra,0x5
     b26:	3dc080e7          	jalr	988(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     b2a:	4505                	li	a0,1
     b2c:	00005097          	auipc	ra,0x5
     b30:	062080e7          	jalr	98(ra) # 5b8e <exit>
    printf("%s: error: open small failed!\n", s);
<<<<<<< HEAD
     b36:	85da                	mv	a1,s6
     b38:	00006517          	auipc	a0,0x6
     b3c:	9c050513          	addi	a0,a0,-1600 # 64f8 <malloc+0x4f4>
     b40:	00005097          	auipc	ra,0x5
     b44:	406080e7          	jalr	1030(ra) # 5f46 <printf>
=======
     b34:	85da                	mv	a1,s6
     b36:	00006517          	auipc	a0,0x6
     b3a:	95250513          	addi	a0,a0,-1710 # 6488 <malloc+0x4d2>
     b3e:	00005097          	auipc	ra,0x5
     b42:	3c0080e7          	jalr	960(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     b46:	4505                	li	a0,1
     b48:	00005097          	auipc	ra,0x5
     b4c:	046080e7          	jalr	70(ra) # 5b8e <exit>
    printf("%s: read failed\n", s);
<<<<<<< HEAD
     b52:	85da                	mv	a1,s6
     b54:	00006517          	auipc	a0,0x6
     b58:	9c450513          	addi	a0,a0,-1596 # 6518 <malloc+0x514>
     b5c:	00005097          	auipc	ra,0x5
     b60:	3ea080e7          	jalr	1002(ra) # 5f46 <printf>
=======
     b50:	85da                	mv	a1,s6
     b52:	00006517          	auipc	a0,0x6
     b56:	95650513          	addi	a0,a0,-1706 # 64a8 <malloc+0x4f2>
     b5a:	00005097          	auipc	ra,0x5
     b5e:	3a4080e7          	jalr	932(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     b62:	4505                	li	a0,1
     b64:	00005097          	auipc	ra,0x5
     b68:	02a080e7          	jalr	42(ra) # 5b8e <exit>
    printf("%s: unlink small failed\n", s);
<<<<<<< HEAD
     b6e:	85da                	mv	a1,s6
     b70:	00006517          	auipc	a0,0x6
     b74:	9c050513          	addi	a0,a0,-1600 # 6530 <malloc+0x52c>
     b78:	00005097          	auipc	ra,0x5
     b7c:	3ce080e7          	jalr	974(ra) # 5f46 <printf>
=======
     b6c:	85da                	mv	a1,s6
     b6e:	00006517          	auipc	a0,0x6
     b72:	95250513          	addi	a0,a0,-1710 # 64c0 <malloc+0x50a>
     b76:	00005097          	auipc	ra,0x5
     b7a:	388080e7          	jalr	904(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     b7e:	4505                	li	a0,1
     b80:	00005097          	auipc	ra,0x5
     b84:	00e080e7          	jalr	14(ra) # 5b8e <exit>

0000000000000b88 <writebig>:
{
     b88:	7139                	addi	sp,sp,-64
     b8a:	fc06                	sd	ra,56(sp)
     b8c:	f822                	sd	s0,48(sp)
     b8e:	f426                	sd	s1,40(sp)
     b90:	f04a                	sd	s2,32(sp)
     b92:	ec4e                	sd	s3,24(sp)
     b94:	e852                	sd	s4,16(sp)
     b96:	e456                	sd	s5,8(sp)
     b98:	0080                	addi	s0,sp,64
     b9a:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
<<<<<<< HEAD
     b9e:	20200593          	li	a1,514
     ba2:	00006517          	auipc	a0,0x6
     ba6:	9ae50513          	addi	a0,a0,-1618 # 6550 <malloc+0x54c>
     baa:	00005097          	auipc	ra,0x5
     bae:	05c080e7          	jalr	92(ra) # 5c06 <open>
     bb2:	89aa                	mv	s3,a0
=======
     b9c:	20200593          	li	a1,514
     ba0:	00006517          	auipc	a0,0x6
     ba4:	94050513          	addi	a0,a0,-1728 # 64e0 <malloc+0x52a>
     ba8:	00005097          	auipc	ra,0x5
     bac:	026080e7          	jalr	38(ra) # 5bce <open>
     bb0:	89aa                	mv	s3,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(i = 0; i < MAXFILE; i++){
     bb2:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     bb4:	0000c917          	auipc	s2,0xc
     bb8:	0c490913          	addi	s2,s2,196 # cc78 <buf>
  for(i = 0; i < MAXFILE; i++){
     bbc:	10c00a13          	li	s4,268
  if(fd < 0){
     bc0:	06054c63          	bltz	a0,c38 <writebig+0xb0>
    ((int*)buf)[0] = i;
     bc4:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     bc8:	40000613          	li	a2,1024
     bcc:	85ca                	mv	a1,s2
     bce:	854e                	mv	a0,s3
     bd0:	00005097          	auipc	ra,0x5
     bd4:	fde080e7          	jalr	-34(ra) # 5bae <write>
     bd8:	40000793          	li	a5,1024
     bdc:	06f51c63          	bne	a0,a5,c54 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     be0:	2485                	addiw	s1,s1,1
     be2:	ff4491e3          	bne	s1,s4,bc4 <writebig+0x3c>
  close(fd);
     be6:	854e                	mv	a0,s3
     be8:	00005097          	auipc	ra,0x5
     bec:	fce080e7          	jalr	-50(ra) # 5bb6 <close>
  fd = open("big", O_RDONLY);
<<<<<<< HEAD
     bf2:	4581                	li	a1,0
     bf4:	00006517          	auipc	a0,0x6
     bf8:	95c50513          	addi	a0,a0,-1700 # 6550 <malloc+0x54c>
     bfc:	00005097          	auipc	ra,0x5
     c00:	00a080e7          	jalr	10(ra) # 5c06 <open>
     c04:	89aa                	mv	s3,a0
=======
     bf0:	4581                	li	a1,0
     bf2:	00006517          	auipc	a0,0x6
     bf6:	8ee50513          	addi	a0,a0,-1810 # 64e0 <malloc+0x52a>
     bfa:	00005097          	auipc	ra,0x5
     bfe:	fd4080e7          	jalr	-44(ra) # 5bce <open>
     c02:	89aa                	mv	s3,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  n = 0;
     c04:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c06:	0000c917          	auipc	s2,0xc
     c0a:	07290913          	addi	s2,s2,114 # cc78 <buf>
  if(fd < 0){
     c0e:	06054263          	bltz	a0,c72 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c12:	40000613          	li	a2,1024
     c16:	85ca                	mv	a1,s2
     c18:	854e                	mv	a0,s3
     c1a:	00005097          	auipc	ra,0x5
     c1e:	f8c080e7          	jalr	-116(ra) # 5ba6 <read>
    if(i == 0){
     c22:	c535                	beqz	a0,c8e <writebig+0x106>
    } else if(i != BSIZE){
     c24:	40000793          	li	a5,1024
     c28:	0af51f63          	bne	a0,a5,ce6 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     c2c:	00092683          	lw	a3,0(s2)
     c30:	0c969a63          	bne	a3,s1,d04 <writebig+0x17c>
    n++;
     c34:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c36:	bff1                	j	c12 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
<<<<<<< HEAD
     c3a:	85d6                	mv	a1,s5
     c3c:	00006517          	auipc	a0,0x6
     c40:	91c50513          	addi	a0,a0,-1764 # 6558 <malloc+0x554>
     c44:	00005097          	auipc	ra,0x5
     c48:	302080e7          	jalr	770(ra) # 5f46 <printf>
=======
     c38:	85d6                	mv	a1,s5
     c3a:	00006517          	auipc	a0,0x6
     c3e:	8ae50513          	addi	a0,a0,-1874 # 64e8 <malloc+0x532>
     c42:	00005097          	auipc	ra,0x5
     c46:	2bc080e7          	jalr	700(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     c4a:	4505                	li	a0,1
     c4c:	00005097          	auipc	ra,0x5
     c50:	f42080e7          	jalr	-190(ra) # 5b8e <exit>
      printf("%s: error: write big file failed\n", s, i);
<<<<<<< HEAD
     c56:	8626                	mv	a2,s1
     c58:	85d6                	mv	a1,s5
     c5a:	00006517          	auipc	a0,0x6
     c5e:	91e50513          	addi	a0,a0,-1762 # 6578 <malloc+0x574>
     c62:	00005097          	auipc	ra,0x5
     c66:	2e4080e7          	jalr	740(ra) # 5f46 <printf>
=======
     c54:	8626                	mv	a2,s1
     c56:	85d6                	mv	a1,s5
     c58:	00006517          	auipc	a0,0x6
     c5c:	8b050513          	addi	a0,a0,-1872 # 6508 <malloc+0x552>
     c60:	00005097          	auipc	ra,0x5
     c64:	29e080e7          	jalr	670(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     c68:	4505                	li	a0,1
     c6a:	00005097          	auipc	ra,0x5
     c6e:	f24080e7          	jalr	-220(ra) # 5b8e <exit>
    printf("%s: error: open big failed!\n", s);
<<<<<<< HEAD
     c74:	85d6                	mv	a1,s5
     c76:	00006517          	auipc	a0,0x6
     c7a:	92a50513          	addi	a0,a0,-1750 # 65a0 <malloc+0x59c>
     c7e:	00005097          	auipc	ra,0x5
     c82:	2c8080e7          	jalr	712(ra) # 5f46 <printf>
=======
     c72:	85d6                	mv	a1,s5
     c74:	00006517          	auipc	a0,0x6
     c78:	8bc50513          	addi	a0,a0,-1860 # 6530 <malloc+0x57a>
     c7c:	00005097          	auipc	ra,0x5
     c80:	282080e7          	jalr	642(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     c84:	4505                	li	a0,1
     c86:	00005097          	auipc	ra,0x5
     c8a:	f08080e7          	jalr	-248(ra) # 5b8e <exit>
      if(n == MAXFILE - 1){
     c8e:	10b00793          	li	a5,267
     c92:	02f48a63          	beq	s1,a5,cc6 <writebig+0x13e>
  close(fd);
     c96:	854e                	mv	a0,s3
     c98:	00005097          	auipc	ra,0x5
     c9c:	f1e080e7          	jalr	-226(ra) # 5bb6 <close>
  if(unlink("big") < 0){
<<<<<<< HEAD
     ca2:	00006517          	auipc	a0,0x6
     ca6:	8ae50513          	addi	a0,a0,-1874 # 6550 <malloc+0x54c>
     caa:	00005097          	auipc	ra,0x5
     cae:	f6c080e7          	jalr	-148(ra) # 5c16 <unlink>
     cb2:	06054963          	bltz	a0,d24 <writebig+0x19a>
=======
     ca0:	00006517          	auipc	a0,0x6
     ca4:	84050513          	addi	a0,a0,-1984 # 64e0 <malloc+0x52a>
     ca8:	00005097          	auipc	ra,0x5
     cac:	f36080e7          	jalr	-202(ra) # 5bde <unlink>
     cb0:	06054963          	bltz	a0,d22 <writebig+0x19a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
     cb4:	70e2                	ld	ra,56(sp)
     cb6:	7442                	ld	s0,48(sp)
     cb8:	74a2                	ld	s1,40(sp)
     cba:	7902                	ld	s2,32(sp)
     cbc:	69e2                	ld	s3,24(sp)
     cbe:	6a42                	ld	s4,16(sp)
     cc0:	6aa2                	ld	s5,8(sp)
     cc2:	6121                	addi	sp,sp,64
     cc4:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
<<<<<<< HEAD
     cc8:	10b00613          	li	a2,267
     ccc:	85d6                	mv	a1,s5
     cce:	00006517          	auipc	a0,0x6
     cd2:	8f250513          	addi	a0,a0,-1806 # 65c0 <malloc+0x5bc>
     cd6:	00005097          	auipc	ra,0x5
     cda:	270080e7          	jalr	624(ra) # 5f46 <printf>
=======
     cc6:	10b00613          	li	a2,267
     cca:	85d6                	mv	a1,s5
     ccc:	00006517          	auipc	a0,0x6
     cd0:	88450513          	addi	a0,a0,-1916 # 6550 <malloc+0x59a>
     cd4:	00005097          	auipc	ra,0x5
     cd8:	22a080e7          	jalr	554(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
     cdc:	4505                	li	a0,1
     cde:	00005097          	auipc	ra,0x5
     ce2:	eb0080e7          	jalr	-336(ra) # 5b8e <exit>
      printf("%s: read failed %d\n", s, i);
<<<<<<< HEAD
     ce8:	862a                	mv	a2,a0
     cea:	85d6                	mv	a1,s5
     cec:	00006517          	auipc	a0,0x6
     cf0:	8fc50513          	addi	a0,a0,-1796 # 65e8 <malloc+0x5e4>
     cf4:	00005097          	auipc	ra,0x5
     cf8:	252080e7          	jalr	594(ra) # 5f46 <printf>
=======
     ce6:	862a                	mv	a2,a0
     ce8:	85d6                	mv	a1,s5
     cea:	00006517          	auipc	a0,0x6
     cee:	88e50513          	addi	a0,a0,-1906 # 6578 <malloc+0x5c2>
     cf2:	00005097          	auipc	ra,0x5
     cf6:	20c080e7          	jalr	524(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     cfa:	4505                	li	a0,1
     cfc:	00005097          	auipc	ra,0x5
     d00:	e92080e7          	jalr	-366(ra) # 5b8e <exit>
      printf("%s: read content of block %d is %d\n", s,
<<<<<<< HEAD
     d06:	8626                	mv	a2,s1
     d08:	85d6                	mv	a1,s5
     d0a:	00006517          	auipc	a0,0x6
     d0e:	8f650513          	addi	a0,a0,-1802 # 6600 <malloc+0x5fc>
     d12:	00005097          	auipc	ra,0x5
     d16:	234080e7          	jalr	564(ra) # 5f46 <printf>
=======
     d04:	8626                	mv	a2,s1
     d06:	85d6                	mv	a1,s5
     d08:	00006517          	auipc	a0,0x6
     d0c:	88850513          	addi	a0,a0,-1912 # 6590 <malloc+0x5da>
     d10:	00005097          	auipc	ra,0x5
     d14:	1ee080e7          	jalr	494(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
     d18:	4505                	li	a0,1
     d1a:	00005097          	auipc	ra,0x5
     d1e:	e74080e7          	jalr	-396(ra) # 5b8e <exit>
    printf("%s: unlink big failed\n", s);
<<<<<<< HEAD
     d24:	85d6                	mv	a1,s5
     d26:	00006517          	auipc	a0,0x6
     d2a:	90250513          	addi	a0,a0,-1790 # 6628 <malloc+0x624>
     d2e:	00005097          	auipc	ra,0x5
     d32:	218080e7          	jalr	536(ra) # 5f46 <printf>
=======
     d22:	85d6                	mv	a1,s5
     d24:	00006517          	auipc	a0,0x6
     d28:	89450513          	addi	a0,a0,-1900 # 65b8 <malloc+0x602>
     d2c:	00005097          	auipc	ra,0x5
     d30:	1d2080e7          	jalr	466(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     d34:	4505                	li	a0,1
     d36:	00005097          	auipc	ra,0x5
     d3a:	e58080e7          	jalr	-424(ra) # 5b8e <exit>

0000000000000d3e <unlinkread>:
{
     d3e:	7179                	addi	sp,sp,-48
     d40:	f406                	sd	ra,40(sp)
     d42:	f022                	sd	s0,32(sp)
     d44:	ec26                	sd	s1,24(sp)
     d46:	e84a                	sd	s2,16(sp)
     d48:	e44e                	sd	s3,8(sp)
     d4a:	1800                	addi	s0,sp,48
     d4c:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
<<<<<<< HEAD
     d50:	20200593          	li	a1,514
     d54:	00006517          	auipc	a0,0x6
     d58:	8ec50513          	addi	a0,a0,-1812 # 6640 <malloc+0x63c>
     d5c:	00005097          	auipc	ra,0x5
     d60:	eaa080e7          	jalr	-342(ra) # 5c06 <open>
=======
     d4e:	20200593          	li	a1,514
     d52:	00006517          	auipc	a0,0x6
     d56:	87e50513          	addi	a0,a0,-1922 # 65d0 <malloc+0x61a>
     d5a:	00005097          	auipc	ra,0x5
     d5e:	e74080e7          	jalr	-396(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
     d62:	0e054563          	bltz	a0,e4c <unlinkread+0x10e>
     d66:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
<<<<<<< HEAD
     d6a:	4615                	li	a2,5
     d6c:	00006597          	auipc	a1,0x6
     d70:	90458593          	addi	a1,a1,-1788 # 6670 <malloc+0x66c>
     d74:	00005097          	auipc	ra,0x5
     d78:	e72080e7          	jalr	-398(ra) # 5be6 <write>
=======
     d68:	4615                	li	a2,5
     d6a:	00006597          	auipc	a1,0x6
     d6e:	89658593          	addi	a1,a1,-1898 # 6600 <malloc+0x64a>
     d72:	00005097          	auipc	ra,0x5
     d76:	e3c080e7          	jalr	-452(ra) # 5bae <write>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd);
     d7a:	8526                	mv	a0,s1
     d7c:	00005097          	auipc	ra,0x5
     d80:	e3a080e7          	jalr	-454(ra) # 5bb6 <close>
  fd = open("unlinkread", O_RDWR);
<<<<<<< HEAD
     d86:	4589                	li	a1,2
     d88:	00006517          	auipc	a0,0x6
     d8c:	8b850513          	addi	a0,a0,-1864 # 6640 <malloc+0x63c>
     d90:	00005097          	auipc	ra,0x5
     d94:	e76080e7          	jalr	-394(ra) # 5c06 <open>
     d98:	84aa                	mv	s1,a0
=======
     d84:	4589                	li	a1,2
     d86:	00006517          	auipc	a0,0x6
     d8a:	84a50513          	addi	a0,a0,-1974 # 65d0 <malloc+0x61a>
     d8e:	00005097          	auipc	ra,0x5
     d92:	e40080e7          	jalr	-448(ra) # 5bce <open>
     d96:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
     d98:	0c054863          	bltz	a0,e68 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
<<<<<<< HEAD
     d9e:	00006517          	auipc	a0,0x6
     da2:	8a250513          	addi	a0,a0,-1886 # 6640 <malloc+0x63c>
     da6:	00005097          	auipc	ra,0x5
     daa:	e70080e7          	jalr	-400(ra) # 5c16 <unlink>
     dae:	ed61                	bnez	a0,e86 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     db0:	20200593          	li	a1,514
     db4:	00006517          	auipc	a0,0x6
     db8:	88c50513          	addi	a0,a0,-1908 # 6640 <malloc+0x63c>
     dbc:	00005097          	auipc	ra,0x5
     dc0:	e4a080e7          	jalr	-438(ra) # 5c06 <open>
     dc4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dc6:	460d                	li	a2,3
     dc8:	00006597          	auipc	a1,0x6
     dcc:	8f058593          	addi	a1,a1,-1808 # 66b8 <malloc+0x6b4>
     dd0:	00005097          	auipc	ra,0x5
     dd4:	e16080e7          	jalr	-490(ra) # 5be6 <write>
=======
     d9c:	00006517          	auipc	a0,0x6
     da0:	83450513          	addi	a0,a0,-1996 # 65d0 <malloc+0x61a>
     da4:	00005097          	auipc	ra,0x5
     da8:	e3a080e7          	jalr	-454(ra) # 5bde <unlink>
     dac:	ed61                	bnez	a0,e84 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     dae:	20200593          	li	a1,514
     db2:	00006517          	auipc	a0,0x6
     db6:	81e50513          	addi	a0,a0,-2018 # 65d0 <malloc+0x61a>
     dba:	00005097          	auipc	ra,0x5
     dbe:	e14080e7          	jalr	-492(ra) # 5bce <open>
     dc2:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dc4:	460d                	li	a2,3
     dc6:	00006597          	auipc	a1,0x6
     dca:	88258593          	addi	a1,a1,-1918 # 6648 <malloc+0x692>
     dce:	00005097          	auipc	ra,0x5
     dd2:	de0080e7          	jalr	-544(ra) # 5bae <write>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd1);
     dd6:	854a                	mv	a0,s2
     dd8:	00005097          	auipc	ra,0x5
     ddc:	dde080e7          	jalr	-546(ra) # 5bb6 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     de0:	660d                	lui	a2,0x3
     de2:	0000c597          	auipc	a1,0xc
     de6:	e9658593          	addi	a1,a1,-362 # cc78 <buf>
     dea:	8526                	mv	a0,s1
     dec:	00005097          	auipc	ra,0x5
     df0:	dba080e7          	jalr	-582(ra) # 5ba6 <read>
     df4:	4795                	li	a5,5
     df6:	0af51563          	bne	a0,a5,ea0 <unlinkread+0x162>
  if(buf[0] != 'h'){
     dfa:	0000c717          	auipc	a4,0xc
     dfe:	e7e74703          	lbu	a4,-386(a4) # cc78 <buf>
     e02:	06800793          	li	a5,104
     e06:	0af71b63          	bne	a4,a5,ebc <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     e0a:	4629                	li	a2,10
     e0c:	0000c597          	auipc	a1,0xc
     e10:	e6c58593          	addi	a1,a1,-404 # cc78 <buf>
     e14:	8526                	mv	a0,s1
     e16:	00005097          	auipc	ra,0x5
     e1a:	d98080e7          	jalr	-616(ra) # 5bae <write>
     e1e:	47a9                	li	a5,10
     e20:	0af51c63          	bne	a0,a5,ed8 <unlinkread+0x19a>
  close(fd);
     e24:	8526                	mv	a0,s1
     e26:	00005097          	auipc	ra,0x5
     e2a:	d90080e7          	jalr	-624(ra) # 5bb6 <close>
  unlink("unlinkread");
<<<<<<< HEAD
     e30:	00006517          	auipc	a0,0x6
     e34:	81050513          	addi	a0,a0,-2032 # 6640 <malloc+0x63c>
     e38:	00005097          	auipc	ra,0x5
     e3c:	dde080e7          	jalr	-546(ra) # 5c16 <unlink>
=======
     e2e:	00005517          	auipc	a0,0x5
     e32:	7a250513          	addi	a0,a0,1954 # 65d0 <malloc+0x61a>
     e36:	00005097          	auipc	ra,0x5
     e3a:	da8080e7          	jalr	-600(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
     e3e:	70a2                	ld	ra,40(sp)
     e40:	7402                	ld	s0,32(sp)
     e42:	64e2                	ld	s1,24(sp)
     e44:	6942                	ld	s2,16(sp)
     e46:	69a2                	ld	s3,8(sp)
     e48:	6145                	addi	sp,sp,48
     e4a:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
<<<<<<< HEAD
     e4e:	85ce                	mv	a1,s3
     e50:	00006517          	auipc	a0,0x6
     e54:	80050513          	addi	a0,a0,-2048 # 6650 <malloc+0x64c>
     e58:	00005097          	auipc	ra,0x5
     e5c:	0ee080e7          	jalr	238(ra) # 5f46 <printf>
=======
     e4c:	85ce                	mv	a1,s3
     e4e:	00005517          	auipc	a0,0x5
     e52:	79250513          	addi	a0,a0,1938 # 65e0 <malloc+0x62a>
     e56:	00005097          	auipc	ra,0x5
     e5a:	0a8080e7          	jalr	168(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     e5e:	4505                	li	a0,1
     e60:	00005097          	auipc	ra,0x5
     e64:	d2e080e7          	jalr	-722(ra) # 5b8e <exit>
    printf("%s: open unlinkread failed\n", s);
<<<<<<< HEAD
     e6a:	85ce                	mv	a1,s3
     e6c:	00006517          	auipc	a0,0x6
     e70:	80c50513          	addi	a0,a0,-2036 # 6678 <malloc+0x674>
     e74:	00005097          	auipc	ra,0x5
     e78:	0d2080e7          	jalr	210(ra) # 5f46 <printf>
=======
     e68:	85ce                	mv	a1,s3
     e6a:	00005517          	auipc	a0,0x5
     e6e:	79e50513          	addi	a0,a0,1950 # 6608 <malloc+0x652>
     e72:	00005097          	auipc	ra,0x5
     e76:	08c080e7          	jalr	140(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     e7a:	4505                	li	a0,1
     e7c:	00005097          	auipc	ra,0x5
     e80:	d12080e7          	jalr	-750(ra) # 5b8e <exit>
    printf("%s: unlink unlinkread failed\n", s);
<<<<<<< HEAD
     e86:	85ce                	mv	a1,s3
     e88:	00006517          	auipc	a0,0x6
     e8c:	81050513          	addi	a0,a0,-2032 # 6698 <malloc+0x694>
     e90:	00005097          	auipc	ra,0x5
     e94:	0b6080e7          	jalr	182(ra) # 5f46 <printf>
=======
     e84:	85ce                	mv	a1,s3
     e86:	00005517          	auipc	a0,0x5
     e8a:	7a250513          	addi	a0,a0,1954 # 6628 <malloc+0x672>
     e8e:	00005097          	auipc	ra,0x5
     e92:	070080e7          	jalr	112(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     e96:	4505                	li	a0,1
     e98:	00005097          	auipc	ra,0x5
     e9c:	cf6080e7          	jalr	-778(ra) # 5b8e <exit>
    printf("%s: unlinkread read failed", s);
<<<<<<< HEAD
     ea2:	85ce                	mv	a1,s3
     ea4:	00006517          	auipc	a0,0x6
     ea8:	81c50513          	addi	a0,a0,-2020 # 66c0 <malloc+0x6bc>
     eac:	00005097          	auipc	ra,0x5
     eb0:	09a080e7          	jalr	154(ra) # 5f46 <printf>
=======
     ea0:	85ce                	mv	a1,s3
     ea2:	00005517          	auipc	a0,0x5
     ea6:	7ae50513          	addi	a0,a0,1966 # 6650 <malloc+0x69a>
     eaa:	00005097          	auipc	ra,0x5
     eae:	054080e7          	jalr	84(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     eb2:	4505                	li	a0,1
     eb4:	00005097          	auipc	ra,0x5
     eb8:	cda080e7          	jalr	-806(ra) # 5b8e <exit>
    printf("%s: unlinkread wrong data\n", s);
<<<<<<< HEAD
     ebe:	85ce                	mv	a1,s3
     ec0:	00006517          	auipc	a0,0x6
     ec4:	82050513          	addi	a0,a0,-2016 # 66e0 <malloc+0x6dc>
     ec8:	00005097          	auipc	ra,0x5
     ecc:	07e080e7          	jalr	126(ra) # 5f46 <printf>
=======
     ebc:	85ce                	mv	a1,s3
     ebe:	00005517          	auipc	a0,0x5
     ec2:	7b250513          	addi	a0,a0,1970 # 6670 <malloc+0x6ba>
     ec6:	00005097          	auipc	ra,0x5
     eca:	038080e7          	jalr	56(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     ece:	4505                	li	a0,1
     ed0:	00005097          	auipc	ra,0x5
     ed4:	cbe080e7          	jalr	-834(ra) # 5b8e <exit>
    printf("%s: unlinkread write failed\n", s);
<<<<<<< HEAD
     eda:	85ce                	mv	a1,s3
     edc:	00006517          	auipc	a0,0x6
     ee0:	82450513          	addi	a0,a0,-2012 # 6700 <malloc+0x6fc>
     ee4:	00005097          	auipc	ra,0x5
     ee8:	062080e7          	jalr	98(ra) # 5f46 <printf>
=======
     ed8:	85ce                	mv	a1,s3
     eda:	00005517          	auipc	a0,0x5
     ede:	7b650513          	addi	a0,a0,1974 # 6690 <malloc+0x6da>
     ee2:	00005097          	auipc	ra,0x5
     ee6:	01c080e7          	jalr	28(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     eea:	4505                	li	a0,1
     eec:	00005097          	auipc	ra,0x5
     ef0:	ca2080e7          	jalr	-862(ra) # 5b8e <exit>

0000000000000ef4 <linktest>:
{
     ef4:	1101                	addi	sp,sp,-32
     ef6:	ec06                	sd	ra,24(sp)
     ef8:	e822                	sd	s0,16(sp)
     efa:	e426                	sd	s1,8(sp)
     efc:	e04a                	sd	s2,0(sp)
     efe:	1000                	addi	s0,sp,32
     f00:	892a                	mv	s2,a0
  unlink("lf1");
<<<<<<< HEAD
     f04:	00006517          	auipc	a0,0x6
     f08:	81c50513          	addi	a0,a0,-2020 # 6720 <malloc+0x71c>
     f0c:	00005097          	auipc	ra,0x5
     f10:	d0a080e7          	jalr	-758(ra) # 5c16 <unlink>
  unlink("lf2");
     f14:	00006517          	auipc	a0,0x6
     f18:	81450513          	addi	a0,a0,-2028 # 6728 <malloc+0x724>
     f1c:	00005097          	auipc	ra,0x5
     f20:	cfa080e7          	jalr	-774(ra) # 5c16 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f24:	20200593          	li	a1,514
     f28:	00005517          	auipc	a0,0x5
     f2c:	7f850513          	addi	a0,a0,2040 # 6720 <malloc+0x71c>
     f30:	00005097          	auipc	ra,0x5
     f34:	cd6080e7          	jalr	-810(ra) # 5c06 <open>
=======
     f02:	00005517          	auipc	a0,0x5
     f06:	7ae50513          	addi	a0,a0,1966 # 66b0 <malloc+0x6fa>
     f0a:	00005097          	auipc	ra,0x5
     f0e:	cd4080e7          	jalr	-812(ra) # 5bde <unlink>
  unlink("lf2");
     f12:	00005517          	auipc	a0,0x5
     f16:	7a650513          	addi	a0,a0,1958 # 66b8 <malloc+0x702>
     f1a:	00005097          	auipc	ra,0x5
     f1e:	cc4080e7          	jalr	-828(ra) # 5bde <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f22:	20200593          	li	a1,514
     f26:	00005517          	auipc	a0,0x5
     f2a:	78a50513          	addi	a0,a0,1930 # 66b0 <malloc+0x6fa>
     f2e:	00005097          	auipc	ra,0x5
     f32:	ca0080e7          	jalr	-864(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
     f36:	10054763          	bltz	a0,1044 <linktest+0x150>
     f3a:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
<<<<<<< HEAD
     f3e:	4615                	li	a2,5
     f40:	00005597          	auipc	a1,0x5
     f44:	73058593          	addi	a1,a1,1840 # 6670 <malloc+0x66c>
     f48:	00005097          	auipc	ra,0x5
     f4c:	c9e080e7          	jalr	-866(ra) # 5be6 <write>
     f50:	4795                	li	a5,5
     f52:	10f51863          	bne	a0,a5,1062 <linktest+0x16c>
=======
     f3c:	4615                	li	a2,5
     f3e:	00005597          	auipc	a1,0x5
     f42:	6c258593          	addi	a1,a1,1730 # 6600 <malloc+0x64a>
     f46:	00005097          	auipc	ra,0x5
     f4a:	c68080e7          	jalr	-920(ra) # 5bae <write>
     f4e:	4795                	li	a5,5
     f50:	10f51863          	bne	a0,a5,1060 <linktest+0x16c>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd);
     f54:	8526                	mv	a0,s1
     f56:	00005097          	auipc	ra,0x5
     f5a:	c60080e7          	jalr	-928(ra) # 5bb6 <close>
  if(link("lf1", "lf2") < 0){
<<<<<<< HEAD
     f60:	00005597          	auipc	a1,0x5
     f64:	7c858593          	addi	a1,a1,1992 # 6728 <malloc+0x724>
     f68:	00005517          	auipc	a0,0x5
     f6c:	7b850513          	addi	a0,a0,1976 # 6720 <malloc+0x71c>
     f70:	00005097          	auipc	ra,0x5
     f74:	cb6080e7          	jalr	-842(ra) # 5c26 <link>
     f78:	10054363          	bltz	a0,107e <linktest+0x188>
  unlink("lf1");
     f7c:	00005517          	auipc	a0,0x5
     f80:	7a450513          	addi	a0,a0,1956 # 6720 <malloc+0x71c>
     f84:	00005097          	auipc	ra,0x5
     f88:	c92080e7          	jalr	-878(ra) # 5c16 <unlink>
  if(open("lf1", 0) >= 0){
     f8c:	4581                	li	a1,0
     f8e:	00005517          	auipc	a0,0x5
     f92:	79250513          	addi	a0,a0,1938 # 6720 <malloc+0x71c>
     f96:	00005097          	auipc	ra,0x5
     f9a:	c70080e7          	jalr	-912(ra) # 5c06 <open>
     f9e:	0e055e63          	bgez	a0,109a <linktest+0x1a4>
  fd = open("lf2", 0);
     fa2:	4581                	li	a1,0
     fa4:	00005517          	auipc	a0,0x5
     fa8:	78450513          	addi	a0,a0,1924 # 6728 <malloc+0x724>
     fac:	00005097          	auipc	ra,0x5
     fb0:	c5a080e7          	jalr	-934(ra) # 5c06 <open>
     fb4:	84aa                	mv	s1,a0
=======
     f5e:	00005597          	auipc	a1,0x5
     f62:	75a58593          	addi	a1,a1,1882 # 66b8 <malloc+0x702>
     f66:	00005517          	auipc	a0,0x5
     f6a:	74a50513          	addi	a0,a0,1866 # 66b0 <malloc+0x6fa>
     f6e:	00005097          	auipc	ra,0x5
     f72:	c80080e7          	jalr	-896(ra) # 5bee <link>
     f76:	10054363          	bltz	a0,107c <linktest+0x188>
  unlink("lf1");
     f7a:	00005517          	auipc	a0,0x5
     f7e:	73650513          	addi	a0,a0,1846 # 66b0 <malloc+0x6fa>
     f82:	00005097          	auipc	ra,0x5
     f86:	c5c080e7          	jalr	-932(ra) # 5bde <unlink>
  if(open("lf1", 0) >= 0){
     f8a:	4581                	li	a1,0
     f8c:	00005517          	auipc	a0,0x5
     f90:	72450513          	addi	a0,a0,1828 # 66b0 <malloc+0x6fa>
     f94:	00005097          	auipc	ra,0x5
     f98:	c3a080e7          	jalr	-966(ra) # 5bce <open>
     f9c:	0e055e63          	bgez	a0,1098 <linktest+0x1a4>
  fd = open("lf2", 0);
     fa0:	4581                	li	a1,0
     fa2:	00005517          	auipc	a0,0x5
     fa6:	71650513          	addi	a0,a0,1814 # 66b8 <malloc+0x702>
     faa:	00005097          	auipc	ra,0x5
     fae:	c24080e7          	jalr	-988(ra) # 5bce <open>
     fb2:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
     fb4:	10054063          	bltz	a0,10b4 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     fb8:	660d                	lui	a2,0x3
     fba:	0000c597          	auipc	a1,0xc
     fbe:	cbe58593          	addi	a1,a1,-834 # cc78 <buf>
     fc2:	00005097          	auipc	ra,0x5
     fc6:	be4080e7          	jalr	-1052(ra) # 5ba6 <read>
     fca:	4795                	li	a5,5
     fcc:	10f51263          	bne	a0,a5,10d0 <linktest+0x1dc>
  close(fd);
     fd0:	8526                	mv	a0,s1
     fd2:	00005097          	auipc	ra,0x5
     fd6:	be4080e7          	jalr	-1052(ra) # 5bb6 <close>
  if(link("lf2", "lf2") >= 0){
<<<<<<< HEAD
     fdc:	00005597          	auipc	a1,0x5
     fe0:	74c58593          	addi	a1,a1,1868 # 6728 <malloc+0x724>
     fe4:	852e                	mv	a0,a1
     fe6:	00005097          	auipc	ra,0x5
     fea:	c40080e7          	jalr	-960(ra) # 5c26 <link>
     fee:	10055063          	bgez	a0,10ee <linktest+0x1f8>
  unlink("lf2");
     ff2:	00005517          	auipc	a0,0x5
     ff6:	73650513          	addi	a0,a0,1846 # 6728 <malloc+0x724>
     ffa:	00005097          	auipc	ra,0x5
     ffe:	c1c080e7          	jalr	-996(ra) # 5c16 <unlink>
  if(link("lf2", "lf1") >= 0){
    1002:	00005597          	auipc	a1,0x5
    1006:	71e58593          	addi	a1,a1,1822 # 6720 <malloc+0x71c>
    100a:	00005517          	auipc	a0,0x5
    100e:	71e50513          	addi	a0,a0,1822 # 6728 <malloc+0x724>
    1012:	00005097          	auipc	ra,0x5
    1016:	c14080e7          	jalr	-1004(ra) # 5c26 <link>
    101a:	0e055863          	bgez	a0,110a <linktest+0x214>
  if(link(".", "lf1") >= 0){
    101e:	00005597          	auipc	a1,0x5
    1022:	70258593          	addi	a1,a1,1794 # 6720 <malloc+0x71c>
    1026:	00006517          	auipc	a0,0x6
    102a:	80a50513          	addi	a0,a0,-2038 # 6830 <malloc+0x82c>
    102e:	00005097          	auipc	ra,0x5
    1032:	bf8080e7          	jalr	-1032(ra) # 5c26 <link>
    1036:	0e055863          	bgez	a0,1126 <linktest+0x230>
=======
     fda:	00005597          	auipc	a1,0x5
     fde:	6de58593          	addi	a1,a1,1758 # 66b8 <malloc+0x702>
     fe2:	852e                	mv	a0,a1
     fe4:	00005097          	auipc	ra,0x5
     fe8:	c0a080e7          	jalr	-1014(ra) # 5bee <link>
     fec:	10055063          	bgez	a0,10ec <linktest+0x1f8>
  unlink("lf2");
     ff0:	00005517          	auipc	a0,0x5
     ff4:	6c850513          	addi	a0,a0,1736 # 66b8 <malloc+0x702>
     ff8:	00005097          	auipc	ra,0x5
     ffc:	be6080e7          	jalr	-1050(ra) # 5bde <unlink>
  if(link("lf2", "lf1") >= 0){
    1000:	00005597          	auipc	a1,0x5
    1004:	6b058593          	addi	a1,a1,1712 # 66b0 <malloc+0x6fa>
    1008:	00005517          	auipc	a0,0x5
    100c:	6b050513          	addi	a0,a0,1712 # 66b8 <malloc+0x702>
    1010:	00005097          	auipc	ra,0x5
    1014:	bde080e7          	jalr	-1058(ra) # 5bee <link>
    1018:	0e055863          	bgez	a0,1108 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    101c:	00005597          	auipc	a1,0x5
    1020:	69458593          	addi	a1,a1,1684 # 66b0 <malloc+0x6fa>
    1024:	00005517          	auipc	a0,0x5
    1028:	79c50513          	addi	a0,a0,1948 # 67c0 <malloc+0x80a>
    102c:	00005097          	auipc	ra,0x5
    1030:	bc2080e7          	jalr	-1086(ra) # 5bee <link>
    1034:	0e055863          	bgez	a0,1124 <linktest+0x230>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    1038:	60e2                	ld	ra,24(sp)
    103a:	6442                	ld	s0,16(sp)
    103c:	64a2                	ld	s1,8(sp)
    103e:	6902                	ld	s2,0(sp)
    1040:	6105                	addi	sp,sp,32
    1042:	8082                	ret
    printf("%s: create lf1 failed\n", s);
<<<<<<< HEAD
    1046:	85ca                	mv	a1,s2
    1048:	00005517          	auipc	a0,0x5
    104c:	6e850513          	addi	a0,a0,1768 # 6730 <malloc+0x72c>
    1050:	00005097          	auipc	ra,0x5
    1054:	ef6080e7          	jalr	-266(ra) # 5f46 <printf>
=======
    1044:	85ca                	mv	a1,s2
    1046:	00005517          	auipc	a0,0x5
    104a:	67a50513          	addi	a0,a0,1658 # 66c0 <malloc+0x70a>
    104e:	00005097          	auipc	ra,0x5
    1052:	eb0080e7          	jalr	-336(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1056:	4505                	li	a0,1
    1058:	00005097          	auipc	ra,0x5
    105c:	b36080e7          	jalr	-1226(ra) # 5b8e <exit>
    printf("%s: write lf1 failed\n", s);
<<<<<<< HEAD
    1062:	85ca                	mv	a1,s2
    1064:	00005517          	auipc	a0,0x5
    1068:	6e450513          	addi	a0,a0,1764 # 6748 <malloc+0x744>
    106c:	00005097          	auipc	ra,0x5
    1070:	eda080e7          	jalr	-294(ra) # 5f46 <printf>
=======
    1060:	85ca                	mv	a1,s2
    1062:	00005517          	auipc	a0,0x5
    1066:	67650513          	addi	a0,a0,1654 # 66d8 <malloc+0x722>
    106a:	00005097          	auipc	ra,0x5
    106e:	e94080e7          	jalr	-364(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1072:	4505                	li	a0,1
    1074:	00005097          	auipc	ra,0x5
    1078:	b1a080e7          	jalr	-1254(ra) # 5b8e <exit>
    printf("%s: link lf1 lf2 failed\n", s);
<<<<<<< HEAD
    107e:	85ca                	mv	a1,s2
    1080:	00005517          	auipc	a0,0x5
    1084:	6e050513          	addi	a0,a0,1760 # 6760 <malloc+0x75c>
    1088:	00005097          	auipc	ra,0x5
    108c:	ebe080e7          	jalr	-322(ra) # 5f46 <printf>
=======
    107c:	85ca                	mv	a1,s2
    107e:	00005517          	auipc	a0,0x5
    1082:	67250513          	addi	a0,a0,1650 # 66f0 <malloc+0x73a>
    1086:	00005097          	auipc	ra,0x5
    108a:	e78080e7          	jalr	-392(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    108e:	4505                	li	a0,1
    1090:	00005097          	auipc	ra,0x5
    1094:	afe080e7          	jalr	-1282(ra) # 5b8e <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
<<<<<<< HEAD
    109a:	85ca                	mv	a1,s2
    109c:	00005517          	auipc	a0,0x5
    10a0:	6e450513          	addi	a0,a0,1764 # 6780 <malloc+0x77c>
    10a4:	00005097          	auipc	ra,0x5
    10a8:	ea2080e7          	jalr	-350(ra) # 5f46 <printf>
=======
    1098:	85ca                	mv	a1,s2
    109a:	00005517          	auipc	a0,0x5
    109e:	67650513          	addi	a0,a0,1654 # 6710 <malloc+0x75a>
    10a2:	00005097          	auipc	ra,0x5
    10a6:	e5c080e7          	jalr	-420(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    10aa:	4505                	li	a0,1
    10ac:	00005097          	auipc	ra,0x5
    10b0:	ae2080e7          	jalr	-1310(ra) # 5b8e <exit>
    printf("%s: open lf2 failed\n", s);
<<<<<<< HEAD
    10b6:	85ca                	mv	a1,s2
    10b8:	00005517          	auipc	a0,0x5
    10bc:	6f850513          	addi	a0,a0,1784 # 67b0 <malloc+0x7ac>
    10c0:	00005097          	auipc	ra,0x5
    10c4:	e86080e7          	jalr	-378(ra) # 5f46 <printf>
=======
    10b4:	85ca                	mv	a1,s2
    10b6:	00005517          	auipc	a0,0x5
    10ba:	68a50513          	addi	a0,a0,1674 # 6740 <malloc+0x78a>
    10be:	00005097          	auipc	ra,0x5
    10c2:	e40080e7          	jalr	-448(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    10c6:	4505                	li	a0,1
    10c8:	00005097          	auipc	ra,0x5
    10cc:	ac6080e7          	jalr	-1338(ra) # 5b8e <exit>
    printf("%s: read lf2 failed\n", s);
<<<<<<< HEAD
    10d2:	85ca                	mv	a1,s2
    10d4:	00005517          	auipc	a0,0x5
    10d8:	6f450513          	addi	a0,a0,1780 # 67c8 <malloc+0x7c4>
    10dc:	00005097          	auipc	ra,0x5
    10e0:	e6a080e7          	jalr	-406(ra) # 5f46 <printf>
=======
    10d0:	85ca                	mv	a1,s2
    10d2:	00005517          	auipc	a0,0x5
    10d6:	68650513          	addi	a0,a0,1670 # 6758 <malloc+0x7a2>
    10da:	00005097          	auipc	ra,0x5
    10de:	e24080e7          	jalr	-476(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    10e2:	4505                	li	a0,1
    10e4:	00005097          	auipc	ra,0x5
    10e8:	aaa080e7          	jalr	-1366(ra) # 5b8e <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
<<<<<<< HEAD
    10ee:	85ca                	mv	a1,s2
    10f0:	00005517          	auipc	a0,0x5
    10f4:	6f050513          	addi	a0,a0,1776 # 67e0 <malloc+0x7dc>
    10f8:	00005097          	auipc	ra,0x5
    10fc:	e4e080e7          	jalr	-434(ra) # 5f46 <printf>
=======
    10ec:	85ca                	mv	a1,s2
    10ee:	00005517          	auipc	a0,0x5
    10f2:	68250513          	addi	a0,a0,1666 # 6770 <malloc+0x7ba>
    10f6:	00005097          	auipc	ra,0x5
    10fa:	e08080e7          	jalr	-504(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    10fe:	4505                	li	a0,1
    1100:	00005097          	auipc	ra,0x5
    1104:	a8e080e7          	jalr	-1394(ra) # 5b8e <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
<<<<<<< HEAD
    110a:	85ca                	mv	a1,s2
    110c:	00005517          	auipc	a0,0x5
    1110:	6fc50513          	addi	a0,a0,1788 # 6808 <malloc+0x804>
    1114:	00005097          	auipc	ra,0x5
    1118:	e32080e7          	jalr	-462(ra) # 5f46 <printf>
=======
    1108:	85ca                	mv	a1,s2
    110a:	00005517          	auipc	a0,0x5
    110e:	68e50513          	addi	a0,a0,1678 # 6798 <malloc+0x7e2>
    1112:	00005097          	auipc	ra,0x5
    1116:	dec080e7          	jalr	-532(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    111a:	4505                	li	a0,1
    111c:	00005097          	auipc	ra,0x5
    1120:	a72080e7          	jalr	-1422(ra) # 5b8e <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
<<<<<<< HEAD
    1126:	85ca                	mv	a1,s2
    1128:	00005517          	auipc	a0,0x5
    112c:	71050513          	addi	a0,a0,1808 # 6838 <malloc+0x834>
    1130:	00005097          	auipc	ra,0x5
    1134:	e16080e7          	jalr	-490(ra) # 5f46 <printf>
=======
    1124:	85ca                	mv	a1,s2
    1126:	00005517          	auipc	a0,0x5
    112a:	6a250513          	addi	a0,a0,1698 # 67c8 <malloc+0x812>
    112e:	00005097          	auipc	ra,0x5
    1132:	dd0080e7          	jalr	-560(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1136:	4505                	li	a0,1
    1138:	00005097          	auipc	ra,0x5
    113c:	a56080e7          	jalr	-1450(ra) # 5b8e <exit>

0000000000001140 <validatetest>:
{
    1140:	7139                	addi	sp,sp,-64
    1142:	fc06                	sd	ra,56(sp)
    1144:	f822                	sd	s0,48(sp)
    1146:	f426                	sd	s1,40(sp)
    1148:	f04a                	sd	s2,32(sp)
    114a:	ec4e                	sd	s3,24(sp)
    114c:	e852                	sd	s4,16(sp)
    114e:	e456                	sd	s5,8(sp)
    1150:	e05a                	sd	s6,0(sp)
    1152:	0080                	addi	s0,sp,64
    1154:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1156:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
<<<<<<< HEAD
    115a:	00005997          	auipc	s3,0x5
    115e:	6fe98993          	addi	s3,s3,1790 # 6858 <malloc+0x854>
    1162:	597d                	li	s2,-1
=======
    1158:	00005997          	auipc	s3,0x5
    115c:	69098993          	addi	s3,s3,1680 # 67e8 <malloc+0x832>
    1160:	597d                	li	s2,-1
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1162:	6a85                	lui	s5,0x1
    1164:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1168:	85a6                	mv	a1,s1
    116a:	854e                	mv	a0,s3
    116c:	00005097          	auipc	ra,0x5
    1170:	a82080e7          	jalr	-1406(ra) # 5bee <link>
    1174:	01251f63          	bne	a0,s2,1192 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1178:	94d6                	add	s1,s1,s5
    117a:	ff4497e3          	bne	s1,s4,1168 <validatetest+0x28>
}
    117e:	70e2                	ld	ra,56(sp)
    1180:	7442                	ld	s0,48(sp)
    1182:	74a2                	ld	s1,40(sp)
    1184:	7902                	ld	s2,32(sp)
    1186:	69e2                	ld	s3,24(sp)
    1188:	6a42                	ld	s4,16(sp)
    118a:	6aa2                	ld	s5,8(sp)
    118c:	6b02                	ld	s6,0(sp)
    118e:	6121                	addi	sp,sp,64
    1190:	8082                	ret
      printf("%s: link should not succeed\n", s);
<<<<<<< HEAD
    1194:	85da                	mv	a1,s6
    1196:	00005517          	auipc	a0,0x5
    119a:	6d250513          	addi	a0,a0,1746 # 6868 <malloc+0x864>
    119e:	00005097          	auipc	ra,0x5
    11a2:	da8080e7          	jalr	-600(ra) # 5f46 <printf>
=======
    1192:	85da                	mv	a1,s6
    1194:	00005517          	auipc	a0,0x5
    1198:	66450513          	addi	a0,a0,1636 # 67f8 <malloc+0x842>
    119c:	00005097          	auipc	ra,0x5
    11a0:	d62080e7          	jalr	-670(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    11a4:	4505                	li	a0,1
    11a6:	00005097          	auipc	ra,0x5
    11aa:	9e8080e7          	jalr	-1560(ra) # 5b8e <exit>

00000000000011ae <bigdir>:
{
    11ae:	715d                	addi	sp,sp,-80
    11b0:	e486                	sd	ra,72(sp)
    11b2:	e0a2                	sd	s0,64(sp)
    11b4:	fc26                	sd	s1,56(sp)
    11b6:	f84a                	sd	s2,48(sp)
    11b8:	f44e                	sd	s3,40(sp)
    11ba:	f052                	sd	s4,32(sp)
    11bc:	ec56                	sd	s5,24(sp)
    11be:	e85a                	sd	s6,16(sp)
    11c0:	0880                	addi	s0,sp,80
    11c2:	89aa                	mv	s3,a0
  unlink("bd");
<<<<<<< HEAD
    11c6:	00005517          	auipc	a0,0x5
    11ca:	6c250513          	addi	a0,a0,1730 # 6888 <malloc+0x884>
    11ce:	00005097          	auipc	ra,0x5
    11d2:	a48080e7          	jalr	-1464(ra) # 5c16 <unlink>
  fd = open("bd", O_CREATE);
    11d6:	20000593          	li	a1,512
    11da:	00005517          	auipc	a0,0x5
    11de:	6ae50513          	addi	a0,a0,1710 # 6888 <malloc+0x884>
    11e2:	00005097          	auipc	ra,0x5
    11e6:	a24080e7          	jalr	-1500(ra) # 5c06 <open>
=======
    11c4:	00005517          	auipc	a0,0x5
    11c8:	65450513          	addi	a0,a0,1620 # 6818 <malloc+0x862>
    11cc:	00005097          	auipc	ra,0x5
    11d0:	a12080e7          	jalr	-1518(ra) # 5bde <unlink>
  fd = open("bd", O_CREATE);
    11d4:	20000593          	li	a1,512
    11d8:	00005517          	auipc	a0,0x5
    11dc:	64050513          	addi	a0,a0,1600 # 6818 <malloc+0x862>
    11e0:	00005097          	auipc	ra,0x5
    11e4:	9ee080e7          	jalr	-1554(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    11e8:	0c054963          	bltz	a0,12ba <bigdir+0x10c>
  close(fd);
    11ec:	00005097          	auipc	ra,0x5
    11f0:	9ca080e7          	jalr	-1590(ra) # 5bb6 <close>
  for(i = 0; i < N; i++){
    11f4:	4901                	li	s2,0
    name[0] = 'x';
    11f6:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
<<<<<<< HEAD
    11fc:	00005a17          	auipc	s4,0x5
    1200:	68ca0a13          	addi	s4,s4,1676 # 6888 <malloc+0x884>
=======
    11fa:	00005a17          	auipc	s4,0x5
    11fe:	61ea0a13          	addi	s4,s4,1566 # 6818 <malloc+0x862>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(i = 0; i < N; i++){
    1202:	1f400b13          	li	s6,500
    name[0] = 'x';
    1206:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    120a:	41f9571b          	sraiw	a4,s2,0x1f
    120e:	01a7571b          	srliw	a4,a4,0x1a
    1212:	012707bb          	addw	a5,a4,s2
    1216:	4067d69b          	sraiw	a3,a5,0x6
    121a:	0306869b          	addiw	a3,a3,48
    121e:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1222:	03f7f793          	andi	a5,a5,63
    1226:	9f99                	subw	a5,a5,a4
    1228:	0307879b          	addiw	a5,a5,48
    122c:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1230:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    1234:	fb040593          	addi	a1,s0,-80
    1238:	8552                	mv	a0,s4
    123a:	00005097          	auipc	ra,0x5
    123e:	9b4080e7          	jalr	-1612(ra) # 5bee <link>
    1242:	84aa                	mv	s1,a0
    1244:	e949                	bnez	a0,12d6 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1246:	2905                	addiw	s2,s2,1
    1248:	fb691fe3          	bne	s2,s6,1206 <bigdir+0x58>
  unlink("bd");
<<<<<<< HEAD
    124e:	00005517          	auipc	a0,0x5
    1252:	63a50513          	addi	a0,a0,1594 # 6888 <malloc+0x884>
    1256:	00005097          	auipc	ra,0x5
    125a:	9c0080e7          	jalr	-1600(ra) # 5c16 <unlink>
=======
    124c:	00005517          	auipc	a0,0x5
    1250:	5cc50513          	addi	a0,a0,1484 # 6818 <malloc+0x862>
    1254:	00005097          	auipc	ra,0x5
    1258:	98a080e7          	jalr	-1654(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    name[0] = 'x';
    125c:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1260:	1f400a13          	li	s4,500
    name[0] = 'x';
    1264:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1268:	41f4d71b          	sraiw	a4,s1,0x1f
    126c:	01a7571b          	srliw	a4,a4,0x1a
    1270:	009707bb          	addw	a5,a4,s1
    1274:	4067d69b          	sraiw	a3,a5,0x6
    1278:	0306869b          	addiw	a3,a3,48
    127c:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1280:	03f7f793          	andi	a5,a5,63
    1284:	9f99                	subw	a5,a5,a4
    1286:	0307879b          	addiw	a5,a5,48
    128a:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    128e:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1292:	fb040513          	addi	a0,s0,-80
    1296:	00005097          	auipc	ra,0x5
    129a:	948080e7          	jalr	-1720(ra) # 5bde <unlink>
    129e:	ed21                	bnez	a0,12f6 <bigdir+0x148>
  for(i = 0; i < N; i++){
    12a0:	2485                	addiw	s1,s1,1
    12a2:	fd4491e3          	bne	s1,s4,1264 <bigdir+0xb6>
}
    12a6:	60a6                	ld	ra,72(sp)
    12a8:	6406                	ld	s0,64(sp)
    12aa:	74e2                	ld	s1,56(sp)
    12ac:	7942                	ld	s2,48(sp)
    12ae:	79a2                	ld	s3,40(sp)
    12b0:	7a02                	ld	s4,32(sp)
    12b2:	6ae2                	ld	s5,24(sp)
    12b4:	6b42                	ld	s6,16(sp)
    12b6:	6161                	addi	sp,sp,80
    12b8:	8082                	ret
    printf("%s: bigdir create failed\n", s);
<<<<<<< HEAD
    12bc:	85ce                	mv	a1,s3
    12be:	00005517          	auipc	a0,0x5
    12c2:	5d250513          	addi	a0,a0,1490 # 6890 <malloc+0x88c>
    12c6:	00005097          	auipc	ra,0x5
    12ca:	c80080e7          	jalr	-896(ra) # 5f46 <printf>
=======
    12ba:	85ce                	mv	a1,s3
    12bc:	00005517          	auipc	a0,0x5
    12c0:	56450513          	addi	a0,a0,1380 # 6820 <malloc+0x86a>
    12c4:	00005097          	auipc	ra,0x5
    12c8:	c3a080e7          	jalr	-966(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    12cc:	4505                	li	a0,1
    12ce:	00005097          	auipc	ra,0x5
    12d2:	8c0080e7          	jalr	-1856(ra) # 5b8e <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
<<<<<<< HEAD
    12d8:	fb040613          	addi	a2,s0,-80
    12dc:	85ce                	mv	a1,s3
    12de:	00005517          	auipc	a0,0x5
    12e2:	5d250513          	addi	a0,a0,1490 # 68b0 <malloc+0x8ac>
    12e6:	00005097          	auipc	ra,0x5
    12ea:	c60080e7          	jalr	-928(ra) # 5f46 <printf>
=======
    12d6:	fb040613          	addi	a2,s0,-80
    12da:	85ce                	mv	a1,s3
    12dc:	00005517          	auipc	a0,0x5
    12e0:	56450513          	addi	a0,a0,1380 # 6840 <malloc+0x88a>
    12e4:	00005097          	auipc	ra,0x5
    12e8:	c1a080e7          	jalr	-998(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    12ec:	4505                	li	a0,1
    12ee:	00005097          	auipc	ra,0x5
    12f2:	8a0080e7          	jalr	-1888(ra) # 5b8e <exit>
      printf("%s: bigdir unlink failed", s);
<<<<<<< HEAD
    12f8:	85ce                	mv	a1,s3
    12fa:	00005517          	auipc	a0,0x5
    12fe:	5d650513          	addi	a0,a0,1494 # 68d0 <malloc+0x8cc>
    1302:	00005097          	auipc	ra,0x5
    1306:	c44080e7          	jalr	-956(ra) # 5f46 <printf>
=======
    12f6:	85ce                	mv	a1,s3
    12f8:	00005517          	auipc	a0,0x5
    12fc:	56850513          	addi	a0,a0,1384 # 6860 <malloc+0x8aa>
    1300:	00005097          	auipc	ra,0x5
    1304:	bfe080e7          	jalr	-1026(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1308:	4505                	li	a0,1
    130a:	00005097          	auipc	ra,0x5
    130e:	884080e7          	jalr	-1916(ra) # 5b8e <exit>

0000000000001312 <pgbug>:
{
    1312:	7179                	addi	sp,sp,-48
    1314:	f406                	sd	ra,40(sp)
    1316:	f022                	sd	s0,32(sp)
    1318:	ec26                	sd	s1,24(sp)
    131a:	1800                	addi	s0,sp,48
  argv[0] = 0;
    131c:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1320:	00008497          	auipc	s1,0x8
    1324:	ce048493          	addi	s1,s1,-800 # 9000 <big>
    1328:	fd840593          	addi	a1,s0,-40
    132c:	6088                	ld	a0,0(s1)
    132e:	00005097          	auipc	ra,0x5
    1332:	898080e7          	jalr	-1896(ra) # 5bc6 <exec>
  pipe(big);
    1336:	6088                	ld	a0,0(s1)
    1338:	00005097          	auipc	ra,0x5
    133c:	866080e7          	jalr	-1946(ra) # 5b9e <pipe>
  exit(0);
    1340:	4501                	li	a0,0
    1342:	00005097          	auipc	ra,0x5
    1346:	84c080e7          	jalr	-1972(ra) # 5b8e <exit>

000000000000134a <badarg>:
{
    134a:	7139                	addi	sp,sp,-64
    134c:	fc06                	sd	ra,56(sp)
    134e:	f822                	sd	s0,48(sp)
    1350:	f426                	sd	s1,40(sp)
    1352:	f04a                	sd	s2,32(sp)
    1354:	ec4e                	sd	s3,24(sp)
    1356:	0080                	addi	s0,sp,64
    1358:	64b1                	lui	s1,0xc
    135a:	35048493          	addi	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char*)0xffffffff;
    135e:	597d                	li	s2,-1
    1360:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
<<<<<<< HEAD
    1366:	00005997          	auipc	s3,0x5
    136a:	de298993          	addi	s3,s3,-542 # 6148 <malloc+0x144>
=======
    1364:	00005997          	auipc	s3,0x5
    1368:	d7498993          	addi	s3,s3,-652 # 60d8 <malloc+0x122>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    argv[0] = (char*)0xffffffff;
    136c:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1370:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1374:	fc040593          	addi	a1,s0,-64
    1378:	854e                	mv	a0,s3
    137a:	00005097          	auipc	ra,0x5
    137e:	84c080e7          	jalr	-1972(ra) # 5bc6 <exec>
  for(int i = 0; i < 50000; i++){
    1382:	34fd                	addiw	s1,s1,-1
    1384:	f4e5                	bnez	s1,136c <badarg+0x22>
  exit(0);
    1386:	4501                	li	a0,0
    1388:	00005097          	auipc	ra,0x5
    138c:	806080e7          	jalr	-2042(ra) # 5b8e <exit>

0000000000001390 <copyinstr2>:
{
    1390:	7155                	addi	sp,sp,-208
    1392:	e586                	sd	ra,200(sp)
    1394:	e1a2                	sd	s0,192(sp)
    1396:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1398:	f6840793          	addi	a5,s0,-152
    139c:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    13a0:	07800713          	li	a4,120
    13a4:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    13a8:	0785                	addi	a5,a5,1
    13aa:	fed79de3          	bne	a5,a3,13a4 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13ae:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13b2:	f6840513          	addi	a0,s0,-152
    13b6:	00005097          	auipc	ra,0x5
    13ba:	828080e7          	jalr	-2008(ra) # 5bde <unlink>
  if(ret != -1){
    13be:	57fd                	li	a5,-1
    13c0:	0ef51063          	bne	a0,a5,14a0 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13c4:	20100593          	li	a1,513
    13c8:	f6840513          	addi	a0,s0,-152
    13cc:	00005097          	auipc	ra,0x5
    13d0:	802080e7          	jalr	-2046(ra) # 5bce <open>
  if(fd != -1){
    13d4:	57fd                	li	a5,-1
    13d6:	0ef51563          	bne	a0,a5,14c0 <copyinstr2+0x130>
  ret = link(b, b);
    13da:	f6840593          	addi	a1,s0,-152
    13de:	852e                	mv	a0,a1
    13e0:	00005097          	auipc	ra,0x5
    13e4:	80e080e7          	jalr	-2034(ra) # 5bee <link>
  if(ret != -1){
    13e8:	57fd                	li	a5,-1
    13ea:	0ef51b63          	bne	a0,a5,14e0 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
<<<<<<< HEAD
    13f0:	00006797          	auipc	a5,0x6
    13f4:	73878793          	addi	a5,a5,1848 # 7b28 <malloc+0x1b24>
    13f8:	f4f43c23          	sd	a5,-168(s0)
    13fc:	f6043023          	sd	zero,-160(s0)
=======
    13ee:	00006797          	auipc	a5,0x6
    13f2:	6ca78793          	addi	a5,a5,1738 # 7ab8 <malloc+0x1b02>
    13f6:	f4f43c23          	sd	a5,-168(s0)
    13fa:	f6043023          	sd	zero,-160(s0)
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  ret = exec(b, args);
    13fe:	f5840593          	addi	a1,s0,-168
    1402:	f6840513          	addi	a0,s0,-152
    1406:	00004097          	auipc	ra,0x4
    140a:	7c0080e7          	jalr	1984(ra) # 5bc6 <exec>
  if(ret != -1){
    140e:	57fd                	li	a5,-1
    1410:	0ef51963          	bne	a0,a5,1502 <copyinstr2+0x172>
  int pid = fork();
    1414:	00004097          	auipc	ra,0x4
    1418:	772080e7          	jalr	1906(ra) # 5b86 <fork>
  if(pid < 0){
    141c:	10054363          	bltz	a0,1522 <copyinstr2+0x192>
  if(pid == 0){
    1420:	12051463          	bnez	a0,1548 <copyinstr2+0x1b8>
    1424:	00008797          	auipc	a5,0x8
    1428:	13c78793          	addi	a5,a5,316 # 9560 <big.0>
    142c:	00009697          	auipc	a3,0x9
    1430:	13468693          	addi	a3,a3,308 # a560 <big.0+0x1000>
      big[i] = 'x';
    1434:	07800713          	li	a4,120
    1438:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    143c:	0785                	addi	a5,a5,1
    143e:	fed79de3          	bne	a5,a3,1438 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1442:	00009797          	auipc	a5,0x9
    1446:	10078f23          	sb	zero,286(a5) # a560 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
<<<<<<< HEAD
    144c:	00007797          	auipc	a5,0x7
    1450:	0fc78793          	addi	a5,a5,252 # 8548 <malloc+0x2544>
    1454:	6390                	ld	a2,0(a5)
    1456:	6794                	ld	a3,8(a5)
    1458:	6b98                	ld	a4,16(a5)
    145a:	6f9c                	ld	a5,24(a5)
    145c:	f2c43823          	sd	a2,-208(s0)
    1460:	f2d43c23          	sd	a3,-200(s0)
    1464:	f4e43023          	sd	a4,-192(s0)
    1468:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    146c:	f3040593          	addi	a1,s0,-208
    1470:	00005517          	auipc	a0,0x5
    1474:	cd850513          	addi	a0,a0,-808 # 6148 <malloc+0x144>
    1478:	00004097          	auipc	ra,0x4
    147c:	786080e7          	jalr	1926(ra) # 5bfe <exec>
=======
    144a:	00007797          	auipc	a5,0x7
    144e:	0ae78793          	addi	a5,a5,174 # 84f8 <malloc+0x2542>
    1452:	6390                	ld	a2,0(a5)
    1454:	6794                	ld	a3,8(a5)
    1456:	6b98                	ld	a4,16(a5)
    1458:	6f9c                	ld	a5,24(a5)
    145a:	f2c43823          	sd	a2,-208(s0)
    145e:	f2d43c23          	sd	a3,-200(s0)
    1462:	f4e43023          	sd	a4,-192(s0)
    1466:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    146a:	f3040593          	addi	a1,s0,-208
    146e:	00005517          	auipc	a0,0x5
    1472:	c6a50513          	addi	a0,a0,-918 # 60d8 <malloc+0x122>
    1476:	00004097          	auipc	ra,0x4
    147a:	750080e7          	jalr	1872(ra) # 5bc6 <exec>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(ret != -1){
    147e:	57fd                	li	a5,-1
    1480:	0af50e63          	beq	a0,a5,153c <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
<<<<<<< HEAD
    1486:	55fd                	li	a1,-1
    1488:	00005517          	auipc	a0,0x5
    148c:	4f050513          	addi	a0,a0,1264 # 6978 <malloc+0x974>
    1490:	00005097          	auipc	ra,0x5
    1494:	ab6080e7          	jalr	-1354(ra) # 5f46 <printf>
=======
    1484:	55fd                	li	a1,-1
    1486:	00005517          	auipc	a0,0x5
    148a:	48250513          	addi	a0,a0,1154 # 6908 <malloc+0x952>
    148e:	00005097          	auipc	ra,0x5
    1492:	a70080e7          	jalr	-1424(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1496:	4505                	li	a0,1
    1498:	00004097          	auipc	ra,0x4
    149c:	6f6080e7          	jalr	1782(ra) # 5b8e <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
<<<<<<< HEAD
    14a2:	862a                	mv	a2,a0
    14a4:	f6840593          	addi	a1,s0,-152
    14a8:	00005517          	auipc	a0,0x5
    14ac:	44850513          	addi	a0,a0,1096 # 68f0 <malloc+0x8ec>
    14b0:	00005097          	auipc	ra,0x5
    14b4:	a96080e7          	jalr	-1386(ra) # 5f46 <printf>
=======
    14a0:	862a                	mv	a2,a0
    14a2:	f6840593          	addi	a1,s0,-152
    14a6:	00005517          	auipc	a0,0x5
    14aa:	3da50513          	addi	a0,a0,986 # 6880 <malloc+0x8ca>
    14ae:	00005097          	auipc	ra,0x5
    14b2:	a50080e7          	jalr	-1456(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    14b6:	4505                	li	a0,1
    14b8:	00004097          	auipc	ra,0x4
    14bc:	6d6080e7          	jalr	1750(ra) # 5b8e <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
<<<<<<< HEAD
    14c2:	862a                	mv	a2,a0
    14c4:	f6840593          	addi	a1,s0,-152
    14c8:	00005517          	auipc	a0,0x5
    14cc:	44850513          	addi	a0,a0,1096 # 6910 <malloc+0x90c>
    14d0:	00005097          	auipc	ra,0x5
    14d4:	a76080e7          	jalr	-1418(ra) # 5f46 <printf>
=======
    14c0:	862a                	mv	a2,a0
    14c2:	f6840593          	addi	a1,s0,-152
    14c6:	00005517          	auipc	a0,0x5
    14ca:	3da50513          	addi	a0,a0,986 # 68a0 <malloc+0x8ea>
    14ce:	00005097          	auipc	ra,0x5
    14d2:	a30080e7          	jalr	-1488(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    14d6:	4505                	li	a0,1
    14d8:	00004097          	auipc	ra,0x4
    14dc:	6b6080e7          	jalr	1718(ra) # 5b8e <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
<<<<<<< HEAD
    14e2:	86aa                	mv	a3,a0
    14e4:	f6840613          	addi	a2,s0,-152
    14e8:	85b2                	mv	a1,a2
    14ea:	00005517          	auipc	a0,0x5
    14ee:	44650513          	addi	a0,a0,1094 # 6930 <malloc+0x92c>
    14f2:	00005097          	auipc	ra,0x5
    14f6:	a54080e7          	jalr	-1452(ra) # 5f46 <printf>
=======
    14e0:	86aa                	mv	a3,a0
    14e2:	f6840613          	addi	a2,s0,-152
    14e6:	85b2                	mv	a1,a2
    14e8:	00005517          	auipc	a0,0x5
    14ec:	3d850513          	addi	a0,a0,984 # 68c0 <malloc+0x90a>
    14f0:	00005097          	auipc	ra,0x5
    14f4:	a0e080e7          	jalr	-1522(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    14f8:	4505                	li	a0,1
    14fa:	00004097          	auipc	ra,0x4
    14fe:	694080e7          	jalr	1684(ra) # 5b8e <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
<<<<<<< HEAD
    1504:	567d                	li	a2,-1
    1506:	f6840593          	addi	a1,s0,-152
    150a:	00005517          	auipc	a0,0x5
    150e:	44e50513          	addi	a0,a0,1102 # 6958 <malloc+0x954>
    1512:	00005097          	auipc	ra,0x5
    1516:	a34080e7          	jalr	-1484(ra) # 5f46 <printf>
=======
    1502:	567d                	li	a2,-1
    1504:	f6840593          	addi	a1,s0,-152
    1508:	00005517          	auipc	a0,0x5
    150c:	3e050513          	addi	a0,a0,992 # 68e8 <malloc+0x932>
    1510:	00005097          	auipc	ra,0x5
    1514:	9ee080e7          	jalr	-1554(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1518:	4505                	li	a0,1
    151a:	00004097          	auipc	ra,0x4
    151e:	674080e7          	jalr	1652(ra) # 5b8e <exit>
    printf("fork failed\n");
<<<<<<< HEAD
    1524:	00006517          	auipc	a0,0x6
    1528:	8b450513          	addi	a0,a0,-1868 # 6dd8 <malloc+0xdd4>
    152c:	00005097          	auipc	ra,0x5
    1530:	a1a080e7          	jalr	-1510(ra) # 5f46 <printf>
=======
    1522:	00006517          	auipc	a0,0x6
    1526:	84650513          	addi	a0,a0,-1978 # 6d68 <malloc+0xdb2>
    152a:	00005097          	auipc	ra,0x5
    152e:	9d4080e7          	jalr	-1580(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1532:	4505                	li	a0,1
    1534:	00004097          	auipc	ra,0x4
    1538:	65a080e7          	jalr	1626(ra) # 5b8e <exit>
    exit(747); // OK
    153c:	2eb00513          	li	a0,747
    1540:	00004097          	auipc	ra,0x4
    1544:	64e080e7          	jalr	1614(ra) # 5b8e <exit>
  int st = 0;
    1548:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    154c:	f5440513          	addi	a0,s0,-172
    1550:	00004097          	auipc	ra,0x4
    1554:	646080e7          	jalr	1606(ra) # 5b96 <wait>
  if(st != 747){
    1558:	f5442703          	lw	a4,-172(s0)
    155c:	2eb00793          	li	a5,747
    1560:	00f71663          	bne	a4,a5,156c <copyinstr2+0x1dc>
}
    1564:	60ae                	ld	ra,200(sp)
    1566:	640e                	ld	s0,192(sp)
    1568:	6169                	addi	sp,sp,208
    156a:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
<<<<<<< HEAD
    156e:	00005517          	auipc	a0,0x5
    1572:	43250513          	addi	a0,a0,1074 # 69a0 <malloc+0x99c>
    1576:	00005097          	auipc	ra,0x5
    157a:	9d0080e7          	jalr	-1584(ra) # 5f46 <printf>
=======
    156c:	00005517          	auipc	a0,0x5
    1570:	3c450513          	addi	a0,a0,964 # 6930 <malloc+0x97a>
    1574:	00005097          	auipc	ra,0x5
    1578:	98a080e7          	jalr	-1654(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    157c:	4505                	li	a0,1
    157e:	00004097          	auipc	ra,0x4
    1582:	610080e7          	jalr	1552(ra) # 5b8e <exit>

0000000000001586 <truncate3>:
{
    1586:	7159                	addi	sp,sp,-112
    1588:	f486                	sd	ra,104(sp)
    158a:	f0a2                	sd	s0,96(sp)
    158c:	eca6                	sd	s1,88(sp)
    158e:	e8ca                	sd	s2,80(sp)
    1590:	e4ce                	sd	s3,72(sp)
    1592:	e0d2                	sd	s4,64(sp)
    1594:	fc56                	sd	s5,56(sp)
    1596:	1880                	addi	s0,sp,112
    1598:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
<<<<<<< HEAD
    159c:	60100593          	li	a1,1537
    15a0:	00005517          	auipc	a0,0x5
    15a4:	c0050513          	addi	a0,a0,-1024 # 61a0 <malloc+0x19c>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	65e080e7          	jalr	1630(ra) # 5c06 <open>
    15b0:	00004097          	auipc	ra,0x4
    15b4:	63e080e7          	jalr	1598(ra) # 5bee <close>
=======
    159a:	60100593          	li	a1,1537
    159e:	00005517          	auipc	a0,0x5
    15a2:	b9250513          	addi	a0,a0,-1134 # 6130 <malloc+0x17a>
    15a6:	00004097          	auipc	ra,0x4
    15aa:	628080e7          	jalr	1576(ra) # 5bce <open>
    15ae:	00004097          	auipc	ra,0x4
    15b2:	608080e7          	jalr	1544(ra) # 5bb6 <close>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  pid = fork();
    15b6:	00004097          	auipc	ra,0x4
    15ba:	5d0080e7          	jalr	1488(ra) # 5b86 <fork>
  if(pid < 0){
    15be:	08054063          	bltz	a0,163e <truncate3+0xb8>
  if(pid == 0){
    15c2:	e969                	bnez	a0,1694 <truncate3+0x10e>
    15c4:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
<<<<<<< HEAD
    15ca:	00005a17          	auipc	s4,0x5
    15ce:	bd6a0a13          	addi	s4,s4,-1066 # 61a0 <malloc+0x19c>
      int n = write(fd, "1234567890", 10);
    15d2:	00005a97          	auipc	s5,0x5
    15d6:	42ea8a93          	addi	s5,s5,1070 # 6a00 <malloc+0x9fc>
=======
    15c8:	00005a17          	auipc	s4,0x5
    15cc:	b68a0a13          	addi	s4,s4,-1176 # 6130 <malloc+0x17a>
      int n = write(fd, "1234567890", 10);
    15d0:	00005a97          	auipc	s5,0x5
    15d4:	3c0a8a93          	addi	s5,s5,960 # 6990 <malloc+0x9da>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      int fd = open("truncfile", O_WRONLY);
    15d8:	4585                	li	a1,1
    15da:	8552                	mv	a0,s4
    15dc:	00004097          	auipc	ra,0x4
    15e0:	5f2080e7          	jalr	1522(ra) # 5bce <open>
    15e4:	84aa                	mv	s1,a0
      if(fd < 0){
    15e6:	06054a63          	bltz	a0,165a <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    15ea:	4629                	li	a2,10
    15ec:	85d6                	mv	a1,s5
    15ee:	00004097          	auipc	ra,0x4
    15f2:	5c0080e7          	jalr	1472(ra) # 5bae <write>
      if(n != 10){
    15f6:	47a9                	li	a5,10
    15f8:	06f51f63          	bne	a0,a5,1676 <truncate3+0xf0>
      close(fd);
    15fc:	8526                	mv	a0,s1
    15fe:	00004097          	auipc	ra,0x4
    1602:	5b8080e7          	jalr	1464(ra) # 5bb6 <close>
      fd = open("truncfile", O_RDONLY);
    1606:	4581                	li	a1,0
    1608:	8552                	mv	a0,s4
    160a:	00004097          	auipc	ra,0x4
    160e:	5c4080e7          	jalr	1476(ra) # 5bce <open>
    1612:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1614:	02000613          	li	a2,32
    1618:	f9840593          	addi	a1,s0,-104
    161c:	00004097          	auipc	ra,0x4
    1620:	58a080e7          	jalr	1418(ra) # 5ba6 <read>
      close(fd);
    1624:	8526                	mv	a0,s1
    1626:	00004097          	auipc	ra,0x4
    162a:	590080e7          	jalr	1424(ra) # 5bb6 <close>
    for(int i = 0; i < 100; i++){
    162e:	39fd                	addiw	s3,s3,-1
    1630:	fa0994e3          	bnez	s3,15d8 <truncate3+0x52>
    exit(0);
    1634:	4501                	li	a0,0
    1636:	00004097          	auipc	ra,0x4
    163a:	558080e7          	jalr	1368(ra) # 5b8e <exit>
    printf("%s: fork failed\n", s);
<<<<<<< HEAD
    1640:	85ca                	mv	a1,s2
    1642:	00005517          	auipc	a0,0x5
    1646:	38e50513          	addi	a0,a0,910 # 69d0 <malloc+0x9cc>
    164a:	00005097          	auipc	ra,0x5
    164e:	8fc080e7          	jalr	-1796(ra) # 5f46 <printf>
=======
    163e:	85ca                	mv	a1,s2
    1640:	00005517          	auipc	a0,0x5
    1644:	32050513          	addi	a0,a0,800 # 6960 <malloc+0x9aa>
    1648:	00005097          	auipc	ra,0x5
    164c:	8b6080e7          	jalr	-1866(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1650:	4505                	li	a0,1
    1652:	00004097          	auipc	ra,0x4
    1656:	53c080e7          	jalr	1340(ra) # 5b8e <exit>
        printf("%s: open failed\n", s);
<<<<<<< HEAD
    165c:	85ca                	mv	a1,s2
    165e:	00005517          	auipc	a0,0x5
    1662:	38a50513          	addi	a0,a0,906 # 69e8 <malloc+0x9e4>
    1666:	00005097          	auipc	ra,0x5
    166a:	8e0080e7          	jalr	-1824(ra) # 5f46 <printf>
=======
    165a:	85ca                	mv	a1,s2
    165c:	00005517          	auipc	a0,0x5
    1660:	31c50513          	addi	a0,a0,796 # 6978 <malloc+0x9c2>
    1664:	00005097          	auipc	ra,0x5
    1668:	89a080e7          	jalr	-1894(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    166c:	4505                	li	a0,1
    166e:	00004097          	auipc	ra,0x4
    1672:	520080e7          	jalr	1312(ra) # 5b8e <exit>
        printf("%s: write got %d, expected 10\n", s, n);
<<<<<<< HEAD
    1678:	862a                	mv	a2,a0
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	39450513          	addi	a0,a0,916 # 6a10 <malloc+0xa0c>
    1684:	00005097          	auipc	ra,0x5
    1688:	8c2080e7          	jalr	-1854(ra) # 5f46 <printf>
=======
    1676:	862a                	mv	a2,a0
    1678:	85ca                	mv	a1,s2
    167a:	00005517          	auipc	a0,0x5
    167e:	32650513          	addi	a0,a0,806 # 69a0 <malloc+0x9ea>
    1682:	00005097          	auipc	ra,0x5
    1686:	87c080e7          	jalr	-1924(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    168a:	4505                	li	a0,1
    168c:	00004097          	auipc	ra,0x4
    1690:	502080e7          	jalr	1282(ra) # 5b8e <exit>
    1694:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
<<<<<<< HEAD
    169a:	00005a17          	auipc	s4,0x5
    169e:	b06a0a13          	addi	s4,s4,-1274 # 61a0 <malloc+0x19c>
    int n = write(fd, "xxx", 3);
    16a2:	00005a97          	auipc	s5,0x5
    16a6:	38ea8a93          	addi	s5,s5,910 # 6a30 <malloc+0xa2c>
=======
    1698:	00005a17          	auipc	s4,0x5
    169c:	a98a0a13          	addi	s4,s4,-1384 # 6130 <malloc+0x17a>
    int n = write(fd, "xxx", 3);
    16a0:	00005a97          	auipc	s5,0x5
    16a4:	320a8a93          	addi	s5,s5,800 # 69c0 <malloc+0xa0a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16a8:	60100593          	li	a1,1537
    16ac:	8552                	mv	a0,s4
    16ae:	00004097          	auipc	ra,0x4
    16b2:	520080e7          	jalr	1312(ra) # 5bce <open>
    16b6:	84aa                	mv	s1,a0
    if(fd < 0){
    16b8:	04054763          	bltz	a0,1706 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    16bc:	460d                	li	a2,3
    16be:	85d6                	mv	a1,s5
    16c0:	00004097          	auipc	ra,0x4
    16c4:	4ee080e7          	jalr	1262(ra) # 5bae <write>
    if(n != 3){
    16c8:	478d                	li	a5,3
    16ca:	04f51c63          	bne	a0,a5,1722 <truncate3+0x19c>
    close(fd);
    16ce:	8526                	mv	a0,s1
    16d0:	00004097          	auipc	ra,0x4
    16d4:	4e6080e7          	jalr	1254(ra) # 5bb6 <close>
  for(int i = 0; i < 150; i++){
    16d8:	39fd                	addiw	s3,s3,-1
    16da:	fc0997e3          	bnez	s3,16a8 <truncate3+0x122>
  wait(&xstatus);
    16de:	fbc40513          	addi	a0,s0,-68
    16e2:	00004097          	auipc	ra,0x4
    16e6:	4b4080e7          	jalr	1204(ra) # 5b96 <wait>
  unlink("truncfile");
<<<<<<< HEAD
    16ec:	00005517          	auipc	a0,0x5
    16f0:	ab450513          	addi	a0,a0,-1356 # 61a0 <malloc+0x19c>
    16f4:	00004097          	auipc	ra,0x4
    16f8:	522080e7          	jalr	1314(ra) # 5c16 <unlink>
=======
    16ea:	00005517          	auipc	a0,0x5
    16ee:	a4650513          	addi	a0,a0,-1466 # 6130 <malloc+0x17a>
    16f2:	00004097          	auipc	ra,0x4
    16f6:	4ec080e7          	jalr	1260(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  exit(xstatus);
    16fa:	fbc42503          	lw	a0,-68(s0)
    16fe:	00004097          	auipc	ra,0x4
    1702:	490080e7          	jalr	1168(ra) # 5b8e <exit>
      printf("%s: open failed\n", s);
<<<<<<< HEAD
    1708:	85ca                	mv	a1,s2
    170a:	00005517          	auipc	a0,0x5
    170e:	2de50513          	addi	a0,a0,734 # 69e8 <malloc+0x9e4>
    1712:	00005097          	auipc	ra,0x5
    1716:	834080e7          	jalr	-1996(ra) # 5f46 <printf>
=======
    1706:	85ca                	mv	a1,s2
    1708:	00005517          	auipc	a0,0x5
    170c:	27050513          	addi	a0,a0,624 # 6978 <malloc+0x9c2>
    1710:	00004097          	auipc	ra,0x4
    1714:	7ee080e7          	jalr	2030(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1718:	4505                	li	a0,1
    171a:	00004097          	auipc	ra,0x4
    171e:	474080e7          	jalr	1140(ra) # 5b8e <exit>
      printf("%s: write got %d, expected 3\n", s, n);
<<<<<<< HEAD
    1724:	862a                	mv	a2,a0
    1726:	85ca                	mv	a1,s2
    1728:	00005517          	auipc	a0,0x5
    172c:	31050513          	addi	a0,a0,784 # 6a38 <malloc+0xa34>
    1730:	00005097          	auipc	ra,0x5
    1734:	816080e7          	jalr	-2026(ra) # 5f46 <printf>
=======
    1722:	862a                	mv	a2,a0
    1724:	85ca                	mv	a1,s2
    1726:	00005517          	auipc	a0,0x5
    172a:	2a250513          	addi	a0,a0,674 # 69c8 <malloc+0xa12>
    172e:	00004097          	auipc	ra,0x4
    1732:	7d0080e7          	jalr	2000(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1736:	4505                	li	a0,1
    1738:	00004097          	auipc	ra,0x4
    173c:	456080e7          	jalr	1110(ra) # 5b8e <exit>

0000000000001740 <exectest>:
{
    1740:	715d                	addi	sp,sp,-80
    1742:	e486                	sd	ra,72(sp)
    1744:	e0a2                	sd	s0,64(sp)
    1746:	fc26                	sd	s1,56(sp)
    1748:	f84a                	sd	s2,48(sp)
    174a:	0880                	addi	s0,sp,80
    174c:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
<<<<<<< HEAD
    1750:	00005797          	auipc	a5,0x5
    1754:	9f878793          	addi	a5,a5,-1544 # 6148 <malloc+0x144>
    1758:	fcf43023          	sd	a5,-64(s0)
    175c:	00005797          	auipc	a5,0x5
    1760:	2fc78793          	addi	a5,a5,764 # 6a58 <malloc+0xa54>
    1764:	fcf43423          	sd	a5,-56(s0)
    1768:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    176c:	00005517          	auipc	a0,0x5
    1770:	2f450513          	addi	a0,a0,756 # 6a60 <malloc+0xa5c>
    1774:	00004097          	auipc	ra,0x4
    1778:	4a2080e7          	jalr	1186(ra) # 5c16 <unlink>
=======
    174e:	00005797          	auipc	a5,0x5
    1752:	98a78793          	addi	a5,a5,-1654 # 60d8 <malloc+0x122>
    1756:	fcf43023          	sd	a5,-64(s0)
    175a:	00005797          	auipc	a5,0x5
    175e:	28e78793          	addi	a5,a5,654 # 69e8 <malloc+0xa32>
    1762:	fcf43423          	sd	a5,-56(s0)
    1766:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    176a:	00005517          	auipc	a0,0x5
    176e:	28650513          	addi	a0,a0,646 # 69f0 <malloc+0xa3a>
    1772:	00004097          	auipc	ra,0x4
    1776:	46c080e7          	jalr	1132(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  pid = fork();
    177a:	00004097          	auipc	ra,0x4
    177e:	40c080e7          	jalr	1036(ra) # 5b86 <fork>
  if(pid < 0) {
    1782:	04054663          	bltz	a0,17ce <exectest+0x8e>
    1786:	84aa                	mv	s1,a0
  if(pid == 0) {
    1788:	e959                	bnez	a0,181e <exectest+0xde>
    close(1);
    178a:	4505                	li	a0,1
    178c:	00004097          	auipc	ra,0x4
    1790:	42a080e7          	jalr	1066(ra) # 5bb6 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
<<<<<<< HEAD
    1796:	20100593          	li	a1,513
    179a:	00005517          	auipc	a0,0x5
    179e:	2c650513          	addi	a0,a0,710 # 6a60 <malloc+0xa5c>
    17a2:	00004097          	auipc	ra,0x4
    17a6:	464080e7          	jalr	1124(ra) # 5c06 <open>
=======
    1794:	20100593          	li	a1,513
    1798:	00005517          	auipc	a0,0x5
    179c:	25850513          	addi	a0,a0,600 # 69f0 <malloc+0xa3a>
    17a0:	00004097          	auipc	ra,0x4
    17a4:	42e080e7          	jalr	1070(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(fd < 0) {
    17a8:	04054163          	bltz	a0,17ea <exectest+0xaa>
    if(fd != 1) {
    17ac:	4785                	li	a5,1
    17ae:	04f50c63          	beq	a0,a5,1806 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
<<<<<<< HEAD
    17b4:	85ca                	mv	a1,s2
    17b6:	00005517          	auipc	a0,0x5
    17ba:	2ca50513          	addi	a0,a0,714 # 6a80 <malloc+0xa7c>
    17be:	00004097          	auipc	ra,0x4
    17c2:	788080e7          	jalr	1928(ra) # 5f46 <printf>
=======
    17b2:	85ca                	mv	a1,s2
    17b4:	00005517          	auipc	a0,0x5
    17b8:	25c50513          	addi	a0,a0,604 # 6a10 <malloc+0xa5a>
    17bc:	00004097          	auipc	ra,0x4
    17c0:	742080e7          	jalr	1858(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    17c4:	4505                	li	a0,1
    17c6:	00004097          	auipc	ra,0x4
    17ca:	3c8080e7          	jalr	968(ra) # 5b8e <exit>
     printf("%s: fork failed\n", s);
<<<<<<< HEAD
    17d0:	85ca                	mv	a1,s2
    17d2:	00005517          	auipc	a0,0x5
    17d6:	1fe50513          	addi	a0,a0,510 # 69d0 <malloc+0x9cc>
    17da:	00004097          	auipc	ra,0x4
    17de:	76c080e7          	jalr	1900(ra) # 5f46 <printf>
=======
    17ce:	85ca                	mv	a1,s2
    17d0:	00005517          	auipc	a0,0x5
    17d4:	19050513          	addi	a0,a0,400 # 6960 <malloc+0x9aa>
    17d8:	00004097          	auipc	ra,0x4
    17dc:	726080e7          	jalr	1830(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     exit(1);
    17e0:	4505                	li	a0,1
    17e2:	00004097          	auipc	ra,0x4
    17e6:	3ac080e7          	jalr	940(ra) # 5b8e <exit>
      printf("%s: create failed\n", s);
<<<<<<< HEAD
    17ec:	85ca                	mv	a1,s2
    17ee:	00005517          	auipc	a0,0x5
    17f2:	27a50513          	addi	a0,a0,634 # 6a68 <malloc+0xa64>
    17f6:	00004097          	auipc	ra,0x4
    17fa:	750080e7          	jalr	1872(ra) # 5f46 <printf>
=======
    17ea:	85ca                	mv	a1,s2
    17ec:	00005517          	auipc	a0,0x5
    17f0:	20c50513          	addi	a0,a0,524 # 69f8 <malloc+0xa42>
    17f4:	00004097          	auipc	ra,0x4
    17f8:	70a080e7          	jalr	1802(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    17fc:	4505                	li	a0,1
    17fe:	00004097          	auipc	ra,0x4
    1802:	390080e7          	jalr	912(ra) # 5b8e <exit>
    if(exec("echo", echoargv) < 0){
<<<<<<< HEAD
    1808:	fc040593          	addi	a1,s0,-64
    180c:	00005517          	auipc	a0,0x5
    1810:	93c50513          	addi	a0,a0,-1732 # 6148 <malloc+0x144>
    1814:	00004097          	auipc	ra,0x4
    1818:	3ea080e7          	jalr	1002(ra) # 5bfe <exec>
    181c:	02054163          	bltz	a0,183e <exectest+0xfc>
=======
    1806:	fc040593          	addi	a1,s0,-64
    180a:	00005517          	auipc	a0,0x5
    180e:	8ce50513          	addi	a0,a0,-1842 # 60d8 <malloc+0x122>
    1812:	00004097          	auipc	ra,0x4
    1816:	3b4080e7          	jalr	948(ra) # 5bc6 <exec>
    181a:	02054163          	bltz	a0,183c <exectest+0xfc>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if (wait(&xstatus) != pid) {
    181e:	fdc40513          	addi	a0,s0,-36
    1822:	00004097          	auipc	ra,0x4
    1826:	374080e7          	jalr	884(ra) # 5b96 <wait>
    182a:	02951763          	bne	a0,s1,1858 <exectest+0x118>
  if(xstatus != 0)
    182e:	fdc42503          	lw	a0,-36(s0)
    1832:	cd0d                	beqz	a0,186c <exectest+0x12c>
    exit(xstatus);
    1834:	00004097          	auipc	ra,0x4
    1838:	35a080e7          	jalr	858(ra) # 5b8e <exit>
      printf("%s: exec echo failed\n", s);
<<<<<<< HEAD
    183e:	85ca                	mv	a1,s2
    1840:	00005517          	auipc	a0,0x5
    1844:	25050513          	addi	a0,a0,592 # 6a90 <malloc+0xa8c>
    1848:	00004097          	auipc	ra,0x4
    184c:	6fe080e7          	jalr	1790(ra) # 5f46 <printf>
=======
    183c:	85ca                	mv	a1,s2
    183e:	00005517          	auipc	a0,0x5
    1842:	1e250513          	addi	a0,a0,482 # 6a20 <malloc+0xa6a>
    1846:	00004097          	auipc	ra,0x4
    184a:	6b8080e7          	jalr	1720(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    184e:	4505                	li	a0,1
    1850:	00004097          	auipc	ra,0x4
    1854:	33e080e7          	jalr	830(ra) # 5b8e <exit>
    printf("%s: wait failed!\n", s);
<<<<<<< HEAD
    185a:	85ca                	mv	a1,s2
    185c:	00005517          	auipc	a0,0x5
    1860:	24c50513          	addi	a0,a0,588 # 6aa8 <malloc+0xaa4>
    1864:	00004097          	auipc	ra,0x4
    1868:	6e2080e7          	jalr	1762(ra) # 5f46 <printf>
    186c:	b7d1                	j	1830 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    186e:	4581                	li	a1,0
    1870:	00005517          	auipc	a0,0x5
    1874:	1f050513          	addi	a0,a0,496 # 6a60 <malloc+0xa5c>
    1878:	00004097          	auipc	ra,0x4
    187c:	38e080e7          	jalr	910(ra) # 5c06 <open>
=======
    1858:	85ca                	mv	a1,s2
    185a:	00005517          	auipc	a0,0x5
    185e:	1de50513          	addi	a0,a0,478 # 6a38 <malloc+0xa82>
    1862:	00004097          	auipc	ra,0x4
    1866:	69c080e7          	jalr	1692(ra) # 5efe <printf>
    186a:	b7d1                	j	182e <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    186c:	4581                	li	a1,0
    186e:	00005517          	auipc	a0,0x5
    1872:	18250513          	addi	a0,a0,386 # 69f0 <malloc+0xa3a>
    1876:	00004097          	auipc	ra,0x4
    187a:	358080e7          	jalr	856(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0) {
    187e:	02054a63          	bltz	a0,18b2 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1882:	4609                	li	a2,2
    1884:	fb840593          	addi	a1,s0,-72
    1888:	00004097          	auipc	ra,0x4
    188c:	31e080e7          	jalr	798(ra) # 5ba6 <read>
    1890:	4789                	li	a5,2
    1892:	02f50e63          	beq	a0,a5,18ce <exectest+0x18e>
    printf("%s: read failed\n", s);
<<<<<<< HEAD
    1898:	85ca                	mv	a1,s2
    189a:	00005517          	auipc	a0,0x5
    189e:	c7e50513          	addi	a0,a0,-898 # 6518 <malloc+0x514>
    18a2:	00004097          	auipc	ra,0x4
    18a6:	6a4080e7          	jalr	1700(ra) # 5f46 <printf>
=======
    1896:	85ca                	mv	a1,s2
    1898:	00005517          	auipc	a0,0x5
    189c:	c1050513          	addi	a0,a0,-1008 # 64a8 <malloc+0x4f2>
    18a0:	00004097          	auipc	ra,0x4
    18a4:	65e080e7          	jalr	1630(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    18a8:	4505                	li	a0,1
    18aa:	00004097          	auipc	ra,0x4
    18ae:	2e4080e7          	jalr	740(ra) # 5b8e <exit>
    printf("%s: open failed\n", s);
<<<<<<< HEAD
    18b4:	85ca                	mv	a1,s2
    18b6:	00005517          	auipc	a0,0x5
    18ba:	13250513          	addi	a0,a0,306 # 69e8 <malloc+0x9e4>
    18be:	00004097          	auipc	ra,0x4
    18c2:	688080e7          	jalr	1672(ra) # 5f46 <printf>
=======
    18b2:	85ca                	mv	a1,s2
    18b4:	00005517          	auipc	a0,0x5
    18b8:	0c450513          	addi	a0,a0,196 # 6978 <malloc+0x9c2>
    18bc:	00004097          	auipc	ra,0x4
    18c0:	642080e7          	jalr	1602(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    18c4:	4505                	li	a0,1
    18c6:	00004097          	auipc	ra,0x4
    18ca:	2c8080e7          	jalr	712(ra) # 5b8e <exit>
  unlink("echo-ok");
<<<<<<< HEAD
    18d0:	00005517          	auipc	a0,0x5
    18d4:	19050513          	addi	a0,a0,400 # 6a60 <malloc+0xa5c>
    18d8:	00004097          	auipc	ra,0x4
    18dc:	33e080e7          	jalr	830(ra) # 5c16 <unlink>
=======
    18ce:	00005517          	auipc	a0,0x5
    18d2:	12250513          	addi	a0,a0,290 # 69f0 <malloc+0xa3a>
    18d6:	00004097          	auipc	ra,0x4
    18da:	308080e7          	jalr	776(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(buf[0] == 'O' && buf[1] == 'K')
    18de:	fb844703          	lbu	a4,-72(s0)
    18e2:	04f00793          	li	a5,79
    18e6:	00f71863          	bne	a4,a5,18f6 <exectest+0x1b6>
    18ea:	fb944703          	lbu	a4,-71(s0)
    18ee:	04b00793          	li	a5,75
    18f2:	02f70063          	beq	a4,a5,1912 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
<<<<<<< HEAD
    18f8:	85ca                	mv	a1,s2
    18fa:	00005517          	auipc	a0,0x5
    18fe:	1c650513          	addi	a0,a0,454 # 6ac0 <malloc+0xabc>
    1902:	00004097          	auipc	ra,0x4
    1906:	644080e7          	jalr	1604(ra) # 5f46 <printf>
=======
    18f6:	85ca                	mv	a1,s2
    18f8:	00005517          	auipc	a0,0x5
    18fc:	15850513          	addi	a0,a0,344 # 6a50 <malloc+0xa9a>
    1900:	00004097          	auipc	ra,0x4
    1904:	5fe080e7          	jalr	1534(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1908:	4505                	li	a0,1
    190a:	00004097          	auipc	ra,0x4
    190e:	284080e7          	jalr	644(ra) # 5b8e <exit>
    exit(0);
    1912:	4501                	li	a0,0
    1914:	00004097          	auipc	ra,0x4
    1918:	27a080e7          	jalr	634(ra) # 5b8e <exit>

000000000000191c <pipe1>:
{
    191c:	711d                	addi	sp,sp,-96
    191e:	ec86                	sd	ra,88(sp)
    1920:	e8a2                	sd	s0,80(sp)
    1922:	e4a6                	sd	s1,72(sp)
    1924:	e0ca                	sd	s2,64(sp)
    1926:	fc4e                	sd	s3,56(sp)
    1928:	f852                	sd	s4,48(sp)
    192a:	f456                	sd	s5,40(sp)
    192c:	f05a                	sd	s6,32(sp)
    192e:	ec5e                	sd	s7,24(sp)
    1930:	1080                	addi	s0,sp,96
    1932:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1934:	fa840513          	addi	a0,s0,-88
    1938:	00004097          	auipc	ra,0x4
    193c:	266080e7          	jalr	614(ra) # 5b9e <pipe>
    1940:	e93d                	bnez	a0,19b6 <pipe1+0x9a>
    1942:	84aa                	mv	s1,a0
  pid = fork();
    1944:	00004097          	auipc	ra,0x4
    1948:	242080e7          	jalr	578(ra) # 5b86 <fork>
    194c:	8a2a                	mv	s4,a0
  if(pid == 0){
    194e:	c151                	beqz	a0,19d2 <pipe1+0xb6>
  } else if(pid > 0){
    1950:	16a05d63          	blez	a0,1aca <pipe1+0x1ae>
    close(fds[1]);
    1954:	fac42503          	lw	a0,-84(s0)
    1958:	00004097          	auipc	ra,0x4
    195c:	25e080e7          	jalr	606(ra) # 5bb6 <close>
    total = 0;
    1960:	8a26                	mv	s4,s1
    cc = 1;
    1962:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1964:	0000ba97          	auipc	s5,0xb
    1968:	314a8a93          	addi	s5,s5,788 # cc78 <buf>
    196c:	864e                	mv	a2,s3
    196e:	85d6                	mv	a1,s5
    1970:	fa842503          	lw	a0,-88(s0)
    1974:	00004097          	auipc	ra,0x4
    1978:	232080e7          	jalr	562(ra) # 5ba6 <read>
    197c:	10a05263          	blez	a0,1a80 <pipe1+0x164>
      for(i = 0; i < n; i++){
    1980:	0000b717          	auipc	a4,0xb
    1984:	2f870713          	addi	a4,a4,760 # cc78 <buf>
    1988:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    198c:	00074683          	lbu	a3,0(a4)
    1990:	0ff4f793          	zext.b	a5,s1
    1994:	2485                	addiw	s1,s1,1
    1996:	0cf69163          	bne	a3,a5,1a58 <pipe1+0x13c>
      for(i = 0; i < n; i++){
    199a:	0705                	addi	a4,a4,1
    199c:	fec498e3          	bne	s1,a2,198c <pipe1+0x70>
      total += n;
    19a0:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19a4:	0019979b          	slliw	a5,s3,0x1
    19a8:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    19ac:	670d                	lui	a4,0x3
    19ae:	fb377fe3          	bgeu	a4,s3,196c <pipe1+0x50>
        cc = sizeof(buf);
    19b2:	698d                	lui	s3,0x3
    19b4:	bf65                	j	196c <pipe1+0x50>
    printf("%s: pipe() failed\n", s);
<<<<<<< HEAD
    19ba:	85ca                	mv	a1,s2
    19bc:	00005517          	auipc	a0,0x5
    19c0:	11c50513          	addi	a0,a0,284 # 6ad8 <malloc+0xad4>
    19c4:	00004097          	auipc	ra,0x4
    19c8:	582080e7          	jalr	1410(ra) # 5f46 <printf>
=======
    19b6:	85ca                	mv	a1,s2
    19b8:	00005517          	auipc	a0,0x5
    19bc:	0b050513          	addi	a0,a0,176 # 6a68 <malloc+0xab2>
    19c0:	00004097          	auipc	ra,0x4
    19c4:	53e080e7          	jalr	1342(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    19c8:	4505                	li	a0,1
    19ca:	00004097          	auipc	ra,0x4
    19ce:	1c4080e7          	jalr	452(ra) # 5b8e <exit>
    close(fds[0]);
    19d2:	fa842503          	lw	a0,-88(s0)
    19d6:	00004097          	auipc	ra,0x4
    19da:	1e0080e7          	jalr	480(ra) # 5bb6 <close>
    for(n = 0; n < N; n++){
    19de:	0000bb17          	auipc	s6,0xb
    19e2:	29ab0b13          	addi	s6,s6,666 # cc78 <buf>
    19e6:	416004bb          	negw	s1,s6
    19ea:	0ff4f493          	zext.b	s1,s1
    19ee:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    19f2:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    19f4:	6a85                	lui	s5,0x1
    19f6:	42da8a93          	addi	s5,s5,1069 # 142d <copyinstr2+0x9d>
{
    19fa:	87da                	mv	a5,s6
        buf[i] = seq++;
    19fc:	0097873b          	addw	a4,a5,s1
    1a00:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1a04:	0785                	addi	a5,a5,1
    1a06:	fef99be3          	bne	s3,a5,19fc <pipe1+0xe0>
        buf[i] = seq++;
    1a0a:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a0e:	40900613          	li	a2,1033
    1a12:	85de                	mv	a1,s7
    1a14:	fac42503          	lw	a0,-84(s0)
    1a18:	00004097          	auipc	ra,0x4
    1a1c:	196080e7          	jalr	406(ra) # 5bae <write>
    1a20:	40900793          	li	a5,1033
    1a24:	00f51c63          	bne	a0,a5,1a3c <pipe1+0x120>
    for(n = 0; n < N; n++){
    1a28:	24a5                	addiw	s1,s1,9
    1a2a:	0ff4f493          	zext.b	s1,s1
    1a2e:	fd5a16e3          	bne	s4,s5,19fa <pipe1+0xde>
    exit(0);
    1a32:	4501                	li	a0,0
    1a34:	00004097          	auipc	ra,0x4
    1a38:	15a080e7          	jalr	346(ra) # 5b8e <exit>
        printf("%s: pipe1 oops 1\n", s);
<<<<<<< HEAD
    1a40:	85ca                	mv	a1,s2
    1a42:	00005517          	auipc	a0,0x5
    1a46:	0ae50513          	addi	a0,a0,174 # 6af0 <malloc+0xaec>
    1a4a:	00004097          	auipc	ra,0x4
    1a4e:	4fc080e7          	jalr	1276(ra) # 5f46 <printf>
=======
    1a3c:	85ca                	mv	a1,s2
    1a3e:	00005517          	auipc	a0,0x5
    1a42:	04250513          	addi	a0,a0,66 # 6a80 <malloc+0xaca>
    1a46:	00004097          	auipc	ra,0x4
    1a4a:	4b8080e7          	jalr	1208(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    1a4e:	4505                	li	a0,1
    1a50:	00004097          	auipc	ra,0x4
    1a54:	13e080e7          	jalr	318(ra) # 5b8e <exit>
          printf("%s: pipe1 oops 2\n", s);
<<<<<<< HEAD
    1a5c:	85ca                	mv	a1,s2
    1a5e:	00005517          	auipc	a0,0x5
    1a62:	0aa50513          	addi	a0,a0,170 # 6b08 <malloc+0xb04>
    1a66:	00004097          	auipc	ra,0x4
    1a6a:	4e0080e7          	jalr	1248(ra) # 5f46 <printf>
=======
    1a58:	85ca                	mv	a1,s2
    1a5a:	00005517          	auipc	a0,0x5
    1a5e:	03e50513          	addi	a0,a0,62 # 6a98 <malloc+0xae2>
    1a62:	00004097          	auipc	ra,0x4
    1a66:	49c080e7          	jalr	1180(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    1a6a:	60e6                	ld	ra,88(sp)
    1a6c:	6446                	ld	s0,80(sp)
    1a6e:	64a6                	ld	s1,72(sp)
    1a70:	6906                	ld	s2,64(sp)
    1a72:	79e2                	ld	s3,56(sp)
    1a74:	7a42                	ld	s4,48(sp)
    1a76:	7aa2                	ld	s5,40(sp)
    1a78:	7b02                	ld	s6,32(sp)
    1a7a:	6be2                	ld	s7,24(sp)
    1a7c:	6125                	addi	sp,sp,96
    1a7e:	8082                	ret
    if(total != N * SZ){
    1a80:	6785                	lui	a5,0x1
    1a82:	42d78793          	addi	a5,a5,1069 # 142d <copyinstr2+0x9d>
    1a86:	02fa0063          	beq	s4,a5,1aa6 <pipe1+0x18a>
      printf("%s: pipe1 oops 3 total %d\n", total);
<<<<<<< HEAD
    1a8e:	85d2                	mv	a1,s4
    1a90:	00005517          	auipc	a0,0x5
    1a94:	09050513          	addi	a0,a0,144 # 6b20 <malloc+0xb1c>
    1a98:	00004097          	auipc	ra,0x4
    1a9c:	4ae080e7          	jalr	1198(ra) # 5f46 <printf>
=======
    1a8a:	85d2                	mv	a1,s4
    1a8c:	00005517          	auipc	a0,0x5
    1a90:	02450513          	addi	a0,a0,36 # 6ab0 <malloc+0xafa>
    1a94:	00004097          	auipc	ra,0x4
    1a98:	46a080e7          	jalr	1130(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1a9c:	4505                	li	a0,1
    1a9e:	00004097          	auipc	ra,0x4
    1aa2:	0f0080e7          	jalr	240(ra) # 5b8e <exit>
    close(fds[0]);
    1aa6:	fa842503          	lw	a0,-88(s0)
    1aaa:	00004097          	auipc	ra,0x4
    1aae:	10c080e7          	jalr	268(ra) # 5bb6 <close>
    wait(&xstatus);
    1ab2:	fa440513          	addi	a0,s0,-92
    1ab6:	00004097          	auipc	ra,0x4
    1aba:	0e0080e7          	jalr	224(ra) # 5b96 <wait>
    exit(xstatus);
    1abe:	fa442503          	lw	a0,-92(s0)
    1ac2:	00004097          	auipc	ra,0x4
    1ac6:	0cc080e7          	jalr	204(ra) # 5b8e <exit>
    printf("%s: fork() failed\n", s);
<<<<<<< HEAD
    1ace:	85ca                	mv	a1,s2
    1ad0:	00005517          	auipc	a0,0x5
    1ad4:	07050513          	addi	a0,a0,112 # 6b40 <malloc+0xb3c>
    1ad8:	00004097          	auipc	ra,0x4
    1adc:	46e080e7          	jalr	1134(ra) # 5f46 <printf>
=======
    1aca:	85ca                	mv	a1,s2
    1acc:	00005517          	auipc	a0,0x5
    1ad0:	00450513          	addi	a0,a0,4 # 6ad0 <malloc+0xb1a>
    1ad4:	00004097          	auipc	ra,0x4
    1ad8:	42a080e7          	jalr	1066(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    1adc:	4505                	li	a0,1
    1ade:	00004097          	auipc	ra,0x4
    1ae2:	0b0080e7          	jalr	176(ra) # 5b8e <exit>

0000000000001ae6 <exitwait>:
{
    1ae6:	7139                	addi	sp,sp,-64
    1ae8:	fc06                	sd	ra,56(sp)
    1aea:	f822                	sd	s0,48(sp)
    1aec:	f426                	sd	s1,40(sp)
    1aee:	f04a                	sd	s2,32(sp)
    1af0:	ec4e                	sd	s3,24(sp)
    1af2:	e852                	sd	s4,16(sp)
    1af4:	0080                	addi	s0,sp,64
    1af6:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1af8:	4901                	li	s2,0
    1afa:	06400993          	li	s3,100
    pid = fork();
    1afe:	00004097          	auipc	ra,0x4
    1b02:	088080e7          	jalr	136(ra) # 5b86 <fork>
    1b06:	84aa                	mv	s1,a0
    if(pid < 0){
    1b08:	02054a63          	bltz	a0,1b3c <exitwait+0x56>
    if(pid){
    1b0c:	c151                	beqz	a0,1b90 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1b0e:	fcc40513          	addi	a0,s0,-52
    1b12:	00004097          	auipc	ra,0x4
    1b16:	084080e7          	jalr	132(ra) # 5b96 <wait>
    1b1a:	02951f63          	bne	a0,s1,1b58 <exitwait+0x72>
      if(i != xstate) {
    1b1e:	fcc42783          	lw	a5,-52(s0)
    1b22:	05279963          	bne	a5,s2,1b74 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1b26:	2905                	addiw	s2,s2,1
    1b28:	fd391be3          	bne	s2,s3,1afe <exitwait+0x18>
}
    1b2c:	70e2                	ld	ra,56(sp)
    1b2e:	7442                	ld	s0,48(sp)
    1b30:	74a2                	ld	s1,40(sp)
    1b32:	7902                	ld	s2,32(sp)
    1b34:	69e2                	ld	s3,24(sp)
    1b36:	6a42                	ld	s4,16(sp)
    1b38:	6121                	addi	sp,sp,64
    1b3a:	8082                	ret
      printf("%s: fork failed\n", s);
<<<<<<< HEAD
    1b40:	85d2                	mv	a1,s4
    1b42:	00005517          	auipc	a0,0x5
    1b46:	e8e50513          	addi	a0,a0,-370 # 69d0 <malloc+0x9cc>
    1b4a:	00004097          	auipc	ra,0x4
    1b4e:	3fc080e7          	jalr	1020(ra) # 5f46 <printf>
=======
    1b3c:	85d2                	mv	a1,s4
    1b3e:	00005517          	auipc	a0,0x5
    1b42:	e2250513          	addi	a0,a0,-478 # 6960 <malloc+0x9aa>
    1b46:	00004097          	auipc	ra,0x4
    1b4a:	3b8080e7          	jalr	952(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1b4e:	4505                	li	a0,1
    1b50:	00004097          	auipc	ra,0x4
    1b54:	03e080e7          	jalr	62(ra) # 5b8e <exit>
        printf("%s: wait wrong pid\n", s);
<<<<<<< HEAD
    1b5c:	85d2                	mv	a1,s4
    1b5e:	00005517          	auipc	a0,0x5
    1b62:	ffa50513          	addi	a0,a0,-6 # 6b58 <malloc+0xb54>
    1b66:	00004097          	auipc	ra,0x4
    1b6a:	3e0080e7          	jalr	992(ra) # 5f46 <printf>
=======
    1b58:	85d2                	mv	a1,s4
    1b5a:	00005517          	auipc	a0,0x5
    1b5e:	f8e50513          	addi	a0,a0,-114 # 6ae8 <malloc+0xb32>
    1b62:	00004097          	auipc	ra,0x4
    1b66:	39c080e7          	jalr	924(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    1b6a:	4505                	li	a0,1
    1b6c:	00004097          	auipc	ra,0x4
    1b70:	022080e7          	jalr	34(ra) # 5b8e <exit>
        printf("%s: wait wrong exit status\n", s);
<<<<<<< HEAD
    1b78:	85d2                	mv	a1,s4
    1b7a:	00005517          	auipc	a0,0x5
    1b7e:	ff650513          	addi	a0,a0,-10 # 6b70 <malloc+0xb6c>
    1b82:	00004097          	auipc	ra,0x4
    1b86:	3c4080e7          	jalr	964(ra) # 5f46 <printf>
=======
    1b74:	85d2                	mv	a1,s4
    1b76:	00005517          	auipc	a0,0x5
    1b7a:	f8a50513          	addi	a0,a0,-118 # 6b00 <malloc+0xb4a>
    1b7e:	00004097          	auipc	ra,0x4
    1b82:	380080e7          	jalr	896(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    1b86:	4505                	li	a0,1
    1b88:	00004097          	auipc	ra,0x4
    1b8c:	006080e7          	jalr	6(ra) # 5b8e <exit>
      exit(i);
    1b90:	854a                	mv	a0,s2
    1b92:	00004097          	auipc	ra,0x4
    1b96:	ffc080e7          	jalr	-4(ra) # 5b8e <exit>

0000000000001b9a <twochildren>:
{
    1b9a:	1101                	addi	sp,sp,-32
    1b9c:	ec06                	sd	ra,24(sp)
    1b9e:	e822                	sd	s0,16(sp)
    1ba0:	e426                	sd	s1,8(sp)
    1ba2:	e04a                	sd	s2,0(sp)
    1ba4:	1000                	addi	s0,sp,32
    1ba6:	892a                	mv	s2,a0
    1ba8:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bac:	00004097          	auipc	ra,0x4
    1bb0:	fda080e7          	jalr	-38(ra) # 5b86 <fork>
    if(pid1 < 0){
    1bb4:	02054c63          	bltz	a0,1bec <twochildren+0x52>
    if(pid1 == 0){
    1bb8:	c921                	beqz	a0,1c08 <twochildren+0x6e>
      int pid2 = fork();
    1bba:	00004097          	auipc	ra,0x4
    1bbe:	fcc080e7          	jalr	-52(ra) # 5b86 <fork>
      if(pid2 < 0){
    1bc2:	04054763          	bltz	a0,1c10 <twochildren+0x76>
      if(pid2 == 0){
    1bc6:	c13d                	beqz	a0,1c2c <twochildren+0x92>
        wait(0);
    1bc8:	4501                	li	a0,0
    1bca:	00004097          	auipc	ra,0x4
    1bce:	fcc080e7          	jalr	-52(ra) # 5b96 <wait>
        wait(0);
    1bd2:	4501                	li	a0,0
    1bd4:	00004097          	auipc	ra,0x4
    1bd8:	fc2080e7          	jalr	-62(ra) # 5b96 <wait>
  for(int i = 0; i < 1000; i++){
    1bdc:	34fd                	addiw	s1,s1,-1
    1bde:	f4f9                	bnez	s1,1bac <twochildren+0x12>
}
    1be0:	60e2                	ld	ra,24(sp)
    1be2:	6442                	ld	s0,16(sp)
    1be4:	64a2                	ld	s1,8(sp)
    1be6:	6902                	ld	s2,0(sp)
    1be8:	6105                	addi	sp,sp,32
    1bea:	8082                	ret
      printf("%s: fork failed\n", s);
<<<<<<< HEAD
    1bf0:	85ca                	mv	a1,s2
    1bf2:	00005517          	auipc	a0,0x5
    1bf6:	dde50513          	addi	a0,a0,-546 # 69d0 <malloc+0x9cc>
    1bfa:	00004097          	auipc	ra,0x4
    1bfe:	34c080e7          	jalr	844(ra) # 5f46 <printf>
=======
    1bec:	85ca                	mv	a1,s2
    1bee:	00005517          	auipc	a0,0x5
    1bf2:	d7250513          	addi	a0,a0,-654 # 6960 <malloc+0x9aa>
    1bf6:	00004097          	auipc	ra,0x4
    1bfa:	308080e7          	jalr	776(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1bfe:	4505                	li	a0,1
    1c00:	00004097          	auipc	ra,0x4
    1c04:	f8e080e7          	jalr	-114(ra) # 5b8e <exit>
      exit(0);
    1c08:	00004097          	auipc	ra,0x4
    1c0c:	f86080e7          	jalr	-122(ra) # 5b8e <exit>
        printf("%s: fork failed\n", s);
<<<<<<< HEAD
    1c14:	85ca                	mv	a1,s2
    1c16:	00005517          	auipc	a0,0x5
    1c1a:	dba50513          	addi	a0,a0,-582 # 69d0 <malloc+0x9cc>
    1c1e:	00004097          	auipc	ra,0x4
    1c22:	328080e7          	jalr	808(ra) # 5f46 <printf>
=======
    1c10:	85ca                	mv	a1,s2
    1c12:	00005517          	auipc	a0,0x5
    1c16:	d4e50513          	addi	a0,a0,-690 # 6960 <malloc+0x9aa>
    1c1a:	00004097          	auipc	ra,0x4
    1c1e:	2e4080e7          	jalr	740(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    1c22:	4505                	li	a0,1
    1c24:	00004097          	auipc	ra,0x4
    1c28:	f6a080e7          	jalr	-150(ra) # 5b8e <exit>
        exit(0);
    1c2c:	00004097          	auipc	ra,0x4
    1c30:	f62080e7          	jalr	-158(ra) # 5b8e <exit>

0000000000001c34 <forkfork>:
{
    1c34:	7179                	addi	sp,sp,-48
    1c36:	f406                	sd	ra,40(sp)
    1c38:	f022                	sd	s0,32(sp)
    1c3a:	ec26                	sd	s1,24(sp)
    1c3c:	1800                	addi	s0,sp,48
    1c3e:	84aa                	mv	s1,a0
    int pid = fork();
    1c40:	00004097          	auipc	ra,0x4
    1c44:	f46080e7          	jalr	-186(ra) # 5b86 <fork>
    if(pid < 0){
    1c48:	04054163          	bltz	a0,1c8a <forkfork+0x56>
    if(pid == 0){
    1c4c:	cd29                	beqz	a0,1ca6 <forkfork+0x72>
    int pid = fork();
    1c4e:	00004097          	auipc	ra,0x4
    1c52:	f38080e7          	jalr	-200(ra) # 5b86 <fork>
    if(pid < 0){
    1c56:	02054a63          	bltz	a0,1c8a <forkfork+0x56>
    if(pid == 0){
    1c5a:	c531                	beqz	a0,1ca6 <forkfork+0x72>
    wait(&xstatus);
    1c5c:	fdc40513          	addi	a0,s0,-36
    1c60:	00004097          	auipc	ra,0x4
    1c64:	f36080e7          	jalr	-202(ra) # 5b96 <wait>
    if(xstatus != 0) {
    1c68:	fdc42783          	lw	a5,-36(s0)
    1c6c:	ebbd                	bnez	a5,1ce2 <forkfork+0xae>
    wait(&xstatus);
    1c6e:	fdc40513          	addi	a0,s0,-36
    1c72:	00004097          	auipc	ra,0x4
    1c76:	f24080e7          	jalr	-220(ra) # 5b96 <wait>
    if(xstatus != 0) {
    1c7a:	fdc42783          	lw	a5,-36(s0)
    1c7e:	e3b5                	bnez	a5,1ce2 <forkfork+0xae>
}
    1c80:	70a2                	ld	ra,40(sp)
    1c82:	7402                	ld	s0,32(sp)
    1c84:	64e2                	ld	s1,24(sp)
    1c86:	6145                	addi	sp,sp,48
    1c88:	8082                	ret
      printf("%s: fork failed", s);
<<<<<<< HEAD
    1c8e:	85a6                	mv	a1,s1
    1c90:	00005517          	auipc	a0,0x5
    1c94:	f0050513          	addi	a0,a0,-256 # 6b90 <malloc+0xb8c>
    1c98:	00004097          	auipc	ra,0x4
    1c9c:	2ae080e7          	jalr	686(ra) # 5f46 <printf>
=======
    1c8a:	85a6                	mv	a1,s1
    1c8c:	00005517          	auipc	a0,0x5
    1c90:	e9450513          	addi	a0,a0,-364 # 6b20 <malloc+0xb6a>
    1c94:	00004097          	auipc	ra,0x4
    1c98:	26a080e7          	jalr	618(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1c9c:	4505                	li	a0,1
    1c9e:	00004097          	auipc	ra,0x4
    1ca2:	ef0080e7          	jalr	-272(ra) # 5b8e <exit>
{
    1ca6:	0c800493          	li	s1,200
        int pid1 = fork();
    1caa:	00004097          	auipc	ra,0x4
    1cae:	edc080e7          	jalr	-292(ra) # 5b86 <fork>
        if(pid1 < 0){
    1cb2:	00054f63          	bltz	a0,1cd0 <forkfork+0x9c>
        if(pid1 == 0){
    1cb6:	c115                	beqz	a0,1cda <forkfork+0xa6>
        wait(0);
    1cb8:	4501                	li	a0,0
    1cba:	00004097          	auipc	ra,0x4
    1cbe:	edc080e7          	jalr	-292(ra) # 5b96 <wait>
      for(int j = 0; j < 200; j++){
    1cc2:	34fd                	addiw	s1,s1,-1
    1cc4:	f0fd                	bnez	s1,1caa <forkfork+0x76>
      exit(0);
    1cc6:	4501                	li	a0,0
    1cc8:	00004097          	auipc	ra,0x4
    1ccc:	ec6080e7          	jalr	-314(ra) # 5b8e <exit>
          exit(1);
    1cd0:	4505                	li	a0,1
    1cd2:	00004097          	auipc	ra,0x4
    1cd6:	ebc080e7          	jalr	-324(ra) # 5b8e <exit>
          exit(0);
    1cda:	00004097          	auipc	ra,0x4
    1cde:	eb4080e7          	jalr	-332(ra) # 5b8e <exit>
      printf("%s: fork in child failed", s);
<<<<<<< HEAD
    1ce6:	85a6                	mv	a1,s1
    1ce8:	00005517          	auipc	a0,0x5
    1cec:	eb850513          	addi	a0,a0,-328 # 6ba0 <malloc+0xb9c>
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	256080e7          	jalr	598(ra) # 5f46 <printf>
=======
    1ce2:	85a6                	mv	a1,s1
    1ce4:	00005517          	auipc	a0,0x5
    1ce8:	e4c50513          	addi	a0,a0,-436 # 6b30 <malloc+0xb7a>
    1cec:	00004097          	auipc	ra,0x4
    1cf0:	212080e7          	jalr	530(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1cf4:	4505                	li	a0,1
    1cf6:	00004097          	auipc	ra,0x4
    1cfa:	e98080e7          	jalr	-360(ra) # 5b8e <exit>

0000000000001cfe <reparent2>:
{
    1cfe:	1101                	addi	sp,sp,-32
    1d00:	ec06                	sd	ra,24(sp)
    1d02:	e822                	sd	s0,16(sp)
    1d04:	e426                	sd	s1,8(sp)
    1d06:	1000                	addi	s0,sp,32
    1d08:	32000493          	li	s1,800
    int pid1 = fork();
    1d0c:	00004097          	auipc	ra,0x4
    1d10:	e7a080e7          	jalr	-390(ra) # 5b86 <fork>
    if(pid1 < 0){
    1d14:	00054f63          	bltz	a0,1d32 <reparent2+0x34>
    if(pid1 == 0){
    1d18:	c915                	beqz	a0,1d4c <reparent2+0x4e>
    wait(0);
    1d1a:	4501                	li	a0,0
    1d1c:	00004097          	auipc	ra,0x4
    1d20:	e7a080e7          	jalr	-390(ra) # 5b96 <wait>
  for(int i = 0; i < 800; i++){
    1d24:	34fd                	addiw	s1,s1,-1
    1d26:	f0fd                	bnez	s1,1d0c <reparent2+0xe>
  exit(0);
    1d28:	4501                	li	a0,0
    1d2a:	00004097          	auipc	ra,0x4
    1d2e:	e64080e7          	jalr	-412(ra) # 5b8e <exit>
      printf("fork failed\n");
<<<<<<< HEAD
    1d36:	00005517          	auipc	a0,0x5
    1d3a:	0a250513          	addi	a0,a0,162 # 6dd8 <malloc+0xdd4>
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	208080e7          	jalr	520(ra) # 5f46 <printf>
=======
    1d32:	00005517          	auipc	a0,0x5
    1d36:	03650513          	addi	a0,a0,54 # 6d68 <malloc+0xdb2>
    1d3a:	00004097          	auipc	ra,0x4
    1d3e:	1c4080e7          	jalr	452(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1d42:	4505                	li	a0,1
    1d44:	00004097          	auipc	ra,0x4
    1d48:	e4a080e7          	jalr	-438(ra) # 5b8e <exit>
      fork();
    1d4c:	00004097          	auipc	ra,0x4
    1d50:	e3a080e7          	jalr	-454(ra) # 5b86 <fork>
      fork();
    1d54:	00004097          	auipc	ra,0x4
    1d58:	e32080e7          	jalr	-462(ra) # 5b86 <fork>
      exit(0);
    1d5c:	4501                	li	a0,0
    1d5e:	00004097          	auipc	ra,0x4
    1d62:	e30080e7          	jalr	-464(ra) # 5b8e <exit>

0000000000001d66 <createdelete>:
{
    1d66:	7175                	addi	sp,sp,-144
    1d68:	e506                	sd	ra,136(sp)
    1d6a:	e122                	sd	s0,128(sp)
    1d6c:	fca6                	sd	s1,120(sp)
    1d6e:	f8ca                	sd	s2,112(sp)
    1d70:	f4ce                	sd	s3,104(sp)
    1d72:	f0d2                	sd	s4,96(sp)
    1d74:	ecd6                	sd	s5,88(sp)
    1d76:	e8da                	sd	s6,80(sp)
    1d78:	e4de                	sd	s7,72(sp)
    1d7a:	e0e2                	sd	s8,64(sp)
    1d7c:	fc66                	sd	s9,56(sp)
    1d7e:	0900                	addi	s0,sp,144
    1d80:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1d82:	4901                	li	s2,0
    1d84:	4991                	li	s3,4
    pid = fork();
    1d86:	00004097          	auipc	ra,0x4
    1d8a:	e00080e7          	jalr	-512(ra) # 5b86 <fork>
    1d8e:	84aa                	mv	s1,a0
    if(pid < 0){
    1d90:	02054f63          	bltz	a0,1dce <createdelete+0x68>
    if(pid == 0){
    1d94:	c939                	beqz	a0,1dea <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1d96:	2905                	addiw	s2,s2,1
    1d98:	ff3917e3          	bne	s2,s3,1d86 <createdelete+0x20>
    1d9c:	4491                	li	s1,4
    wait(&xstatus);
    1d9e:	f7c40513          	addi	a0,s0,-132
    1da2:	00004097          	auipc	ra,0x4
    1da6:	df4080e7          	jalr	-524(ra) # 5b96 <wait>
    if(xstatus != 0)
    1daa:	f7c42903          	lw	s2,-132(s0)
    1dae:	0e091263          	bnez	s2,1e92 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1db2:	34fd                	addiw	s1,s1,-1
    1db4:	f4ed                	bnez	s1,1d9e <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1db6:	f8040123          	sb	zero,-126(s0)
    1dba:	03000993          	li	s3,48
    1dbe:	5a7d                	li	s4,-1
    1dc0:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1dc4:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1dc6:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1dc8:	07400a93          	li	s5,116
    1dcc:	a29d                	j	1f32 <createdelete+0x1cc>
      printf("fork failed\n", s);
<<<<<<< HEAD
    1dd2:	85e6                	mv	a1,s9
    1dd4:	00005517          	auipc	a0,0x5
    1dd8:	00450513          	addi	a0,a0,4 # 6dd8 <malloc+0xdd4>
    1ddc:	00004097          	auipc	ra,0x4
    1de0:	16a080e7          	jalr	362(ra) # 5f46 <printf>
=======
    1dce:	85e6                	mv	a1,s9
    1dd0:	00005517          	auipc	a0,0x5
    1dd4:	f9850513          	addi	a0,a0,-104 # 6d68 <malloc+0xdb2>
    1dd8:	00004097          	auipc	ra,0x4
    1ddc:	126080e7          	jalr	294(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    1de0:	4505                	li	a0,1
    1de2:	00004097          	auipc	ra,0x4
    1de6:	dac080e7          	jalr	-596(ra) # 5b8e <exit>
      name[0] = 'p' + pi;
    1dea:	0709091b          	addiw	s2,s2,112
    1dee:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1df2:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1df6:	4951                	li	s2,20
    1df8:	a015                	j	1e1c <createdelete+0xb6>
          printf("%s: create failed\n", s);
<<<<<<< HEAD
    1dfe:	85e6                	mv	a1,s9
    1e00:	00005517          	auipc	a0,0x5
    1e04:	c6850513          	addi	a0,a0,-920 # 6a68 <malloc+0xa64>
    1e08:	00004097          	auipc	ra,0x4
    1e0c:	13e080e7          	jalr	318(ra) # 5f46 <printf>
=======
    1dfa:	85e6                	mv	a1,s9
    1dfc:	00005517          	auipc	a0,0x5
    1e00:	bfc50513          	addi	a0,a0,-1028 # 69f8 <malloc+0xa42>
    1e04:	00004097          	auipc	ra,0x4
    1e08:	0fa080e7          	jalr	250(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
          exit(1);
    1e0c:	4505                	li	a0,1
    1e0e:	00004097          	auipc	ra,0x4
    1e12:	d80080e7          	jalr	-640(ra) # 5b8e <exit>
      for(i = 0; i < N; i++){
    1e16:	2485                	addiw	s1,s1,1
    1e18:	07248863          	beq	s1,s2,1e88 <createdelete+0x122>
        name[1] = '0' + i;
    1e1c:	0304879b          	addiw	a5,s1,48
    1e20:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e24:	20200593          	li	a1,514
    1e28:	f8040513          	addi	a0,s0,-128
    1e2c:	00004097          	auipc	ra,0x4
    1e30:	da2080e7          	jalr	-606(ra) # 5bce <open>
        if(fd < 0){
    1e34:	fc0543e3          	bltz	a0,1dfa <createdelete+0x94>
        close(fd);
    1e38:	00004097          	auipc	ra,0x4
    1e3c:	d7e080e7          	jalr	-642(ra) # 5bb6 <close>
        if(i > 0 && (i % 2 ) == 0){
    1e40:	fc905be3          	blez	s1,1e16 <createdelete+0xb0>
    1e44:	0014f793          	andi	a5,s1,1
    1e48:	f7f9                	bnez	a5,1e16 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e4a:	01f4d79b          	srliw	a5,s1,0x1f
    1e4e:	9fa5                	addw	a5,a5,s1
    1e50:	4017d79b          	sraiw	a5,a5,0x1
    1e54:	0307879b          	addiw	a5,a5,48
    1e58:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1e5c:	f8040513          	addi	a0,s0,-128
    1e60:	00004097          	auipc	ra,0x4
    1e64:	d7e080e7          	jalr	-642(ra) # 5bde <unlink>
    1e68:	fa0557e3          	bgez	a0,1e16 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
<<<<<<< HEAD
    1e70:	85e6                	mv	a1,s9
    1e72:	00005517          	auipc	a0,0x5
    1e76:	d4e50513          	addi	a0,a0,-690 # 6bc0 <malloc+0xbbc>
    1e7a:	00004097          	auipc	ra,0x4
    1e7e:	0cc080e7          	jalr	204(ra) # 5f46 <printf>
=======
    1e6c:	85e6                	mv	a1,s9
    1e6e:	00005517          	auipc	a0,0x5
    1e72:	ce250513          	addi	a0,a0,-798 # 6b50 <malloc+0xb9a>
    1e76:	00004097          	auipc	ra,0x4
    1e7a:	088080e7          	jalr	136(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
            exit(1);
    1e7e:	4505                	li	a0,1
    1e80:	00004097          	auipc	ra,0x4
    1e84:	d0e080e7          	jalr	-754(ra) # 5b8e <exit>
      exit(0);
    1e88:	4501                	li	a0,0
    1e8a:	00004097          	auipc	ra,0x4
    1e8e:	d04080e7          	jalr	-764(ra) # 5b8e <exit>
      exit(1);
    1e92:	4505                	li	a0,1
    1e94:	00004097          	auipc	ra,0x4
    1e98:	cfa080e7          	jalr	-774(ra) # 5b8e <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
<<<<<<< HEAD
    1ea0:	f8040613          	addi	a2,s0,-128
    1ea4:	85e6                	mv	a1,s9
    1ea6:	00005517          	auipc	a0,0x5
    1eaa:	d3250513          	addi	a0,a0,-718 # 6bd8 <malloc+0xbd4>
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	098080e7          	jalr	152(ra) # 5f46 <printf>
=======
    1e9c:	f8040613          	addi	a2,s0,-128
    1ea0:	85e6                	mv	a1,s9
    1ea2:	00005517          	auipc	a0,0x5
    1ea6:	cc650513          	addi	a0,a0,-826 # 6b68 <malloc+0xbb2>
    1eaa:	00004097          	auipc	ra,0x4
    1eae:	054080e7          	jalr	84(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    1eb2:	4505                	li	a0,1
    1eb4:	00004097          	auipc	ra,0x4
    1eb8:	cda080e7          	jalr	-806(ra) # 5b8e <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ebc:	054b7163          	bgeu	s6,s4,1efe <createdelete+0x198>
      if(fd >= 0)
    1ec0:	02055a63          	bgez	a0,1ef4 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1ec4:	2485                	addiw	s1,s1,1
    1ec6:	0ff4f493          	zext.b	s1,s1
    1eca:	05548c63          	beq	s1,s5,1f22 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1ece:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1ed2:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1ed6:	4581                	li	a1,0
    1ed8:	f8040513          	addi	a0,s0,-128
    1edc:	00004097          	auipc	ra,0x4
    1ee0:	cf2080e7          	jalr	-782(ra) # 5bce <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1ee4:	00090463          	beqz	s2,1eec <createdelete+0x186>
    1ee8:	fd2bdae3          	bge	s7,s2,1ebc <createdelete+0x156>
    1eec:	fa0548e3          	bltz	a0,1e9c <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ef0:	014b7963          	bgeu	s6,s4,1f02 <createdelete+0x19c>
        close(fd);
    1ef4:	00004097          	auipc	ra,0x4
    1ef8:	cc2080e7          	jalr	-830(ra) # 5bb6 <close>
    1efc:	b7e1                	j	1ec4 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1efe:	fc0543e3          	bltz	a0,1ec4 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
<<<<<<< HEAD
    1f06:	f8040613          	addi	a2,s0,-128
    1f0a:	85e6                	mv	a1,s9
    1f0c:	00005517          	auipc	a0,0x5
    1f10:	cf450513          	addi	a0,a0,-780 # 6c00 <malloc+0xbfc>
    1f14:	00004097          	auipc	ra,0x4
    1f18:	032080e7          	jalr	50(ra) # 5f46 <printf>
=======
    1f02:	f8040613          	addi	a2,s0,-128
    1f06:	85e6                	mv	a1,s9
    1f08:	00005517          	auipc	a0,0x5
    1f0c:	c8850513          	addi	a0,a0,-888 # 6b90 <malloc+0xbda>
    1f10:	00004097          	auipc	ra,0x4
    1f14:	fee080e7          	jalr	-18(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    1f18:	4505                	li	a0,1
    1f1a:	00004097          	auipc	ra,0x4
    1f1e:	c74080e7          	jalr	-908(ra) # 5b8e <exit>
  for(i = 0; i < N; i++){
    1f22:	2905                	addiw	s2,s2,1
    1f24:	2a05                	addiw	s4,s4,1
    1f26:	2985                	addiw	s3,s3,1 # 3001 <execout+0xa7>
    1f28:	0ff9f993          	zext.b	s3,s3
    1f2c:	47d1                	li	a5,20
    1f2e:	02f90a63          	beq	s2,a5,1f62 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1f32:	84e2                	mv	s1,s8
    1f34:	bf69                	j	1ece <createdelete+0x168>
  for(i = 0; i < N; i++){
    1f36:	2905                	addiw	s2,s2,1
    1f38:	0ff97913          	zext.b	s2,s2
    1f3c:	2985                	addiw	s3,s3,1
    1f3e:	0ff9f993          	zext.b	s3,s3
    1f42:	03490863          	beq	s2,s4,1f72 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f46:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f48:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f4c:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f50:	f8040513          	addi	a0,s0,-128
    1f54:	00004097          	auipc	ra,0x4
    1f58:	c8a080e7          	jalr	-886(ra) # 5bde <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1f5c:	34fd                	addiw	s1,s1,-1
    1f5e:	f4ed                	bnez	s1,1f48 <createdelete+0x1e2>
    1f60:	bfd9                	j	1f36 <createdelete+0x1d0>
    1f62:	03000993          	li	s3,48
    1f66:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f6a:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1f6c:	08400a13          	li	s4,132
    1f70:	bfd9                	j	1f46 <createdelete+0x1e0>
}
    1f72:	60aa                	ld	ra,136(sp)
    1f74:	640a                	ld	s0,128(sp)
    1f76:	74e6                	ld	s1,120(sp)
    1f78:	7946                	ld	s2,112(sp)
    1f7a:	79a6                	ld	s3,104(sp)
    1f7c:	7a06                	ld	s4,96(sp)
    1f7e:	6ae6                	ld	s5,88(sp)
    1f80:	6b46                	ld	s6,80(sp)
    1f82:	6ba6                	ld	s7,72(sp)
    1f84:	6c06                	ld	s8,64(sp)
    1f86:	7ce2                	ld	s9,56(sp)
    1f88:	6149                	addi	sp,sp,144
    1f8a:	8082                	ret

0000000000001f8c <linkunlink>:
{
    1f8c:	711d                	addi	sp,sp,-96
    1f8e:	ec86                	sd	ra,88(sp)
    1f90:	e8a2                	sd	s0,80(sp)
    1f92:	e4a6                	sd	s1,72(sp)
    1f94:	e0ca                	sd	s2,64(sp)
    1f96:	fc4e                	sd	s3,56(sp)
    1f98:	f852                	sd	s4,48(sp)
    1f9a:	f456                	sd	s5,40(sp)
    1f9c:	f05a                	sd	s6,32(sp)
    1f9e:	ec5e                	sd	s7,24(sp)
    1fa0:	e862                	sd	s8,16(sp)
    1fa2:	e466                	sd	s9,8(sp)
    1fa4:	1080                	addi	s0,sp,96
    1fa6:	84aa                	mv	s1,a0
  unlink("x");
<<<<<<< HEAD
    1fac:	00004517          	auipc	a0,0x4
    1fb0:	20c50513          	addi	a0,a0,524 # 61b8 <malloc+0x1b4>
    1fb4:	00004097          	auipc	ra,0x4
    1fb8:	c62080e7          	jalr	-926(ra) # 5c16 <unlink>
=======
    1fa8:	00004517          	auipc	a0,0x4
    1fac:	1a050513          	addi	a0,a0,416 # 6148 <malloc+0x192>
    1fb0:	00004097          	auipc	ra,0x4
    1fb4:	c2e080e7          	jalr	-978(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  pid = fork();
    1fb8:	00004097          	auipc	ra,0x4
    1fbc:	bce080e7          	jalr	-1074(ra) # 5b86 <fork>
  if(pid < 0){
    1fc0:	02054b63          	bltz	a0,1ff6 <linkunlink+0x6a>
    1fc4:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1fc6:	06100c93          	li	s9,97
    1fca:	c111                	beqz	a0,1fce <linkunlink+0x42>
    1fcc:	4c85                	li	s9,1
    1fce:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1fd2:	41c659b7          	lui	s3,0x41c65
    1fd6:	e6d9899b          	addiw	s3,s3,-403 # 41c64e6d <base+0x41c551f5>
    1fda:	690d                	lui	s2,0x3
    1fdc:	0399091b          	addiw	s2,s2,57 # 3039 <fourteen+0x1b>
    if((x % 3) == 0){
    1fe0:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1fe2:	4b05                	li	s6,1
      unlink("x");
<<<<<<< HEAD
    1fe8:	00004a97          	auipc	s5,0x4
    1fec:	1d0a8a93          	addi	s5,s5,464 # 61b8 <malloc+0x1b4>
      link("cat", "x");
    1ff0:	00005b97          	auipc	s7,0x5
    1ff4:	c38b8b93          	addi	s7,s7,-968 # 6c28 <malloc+0xc24>
    1ff8:	a825                	j	2030 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1ffa:	85a6                	mv	a1,s1
    1ffc:	00005517          	auipc	a0,0x5
    2000:	9d450513          	addi	a0,a0,-1580 # 69d0 <malloc+0x9cc>
    2004:	00004097          	auipc	ra,0x4
    2008:	f42080e7          	jalr	-190(ra) # 5f46 <printf>
=======
    1fe4:	00004a97          	auipc	s5,0x4
    1fe8:	164a8a93          	addi	s5,s5,356 # 6148 <malloc+0x192>
      link("cat", "x");
    1fec:	00005b97          	auipc	s7,0x5
    1ff0:	bccb8b93          	addi	s7,s7,-1076 # 6bb8 <malloc+0xc02>
    1ff4:	a825                	j	202c <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1ff6:	85a6                	mv	a1,s1
    1ff8:	00005517          	auipc	a0,0x5
    1ffc:	96850513          	addi	a0,a0,-1688 # 6960 <malloc+0x9aa>
    2000:	00004097          	auipc	ra,0x4
    2004:	efe080e7          	jalr	-258(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2008:	4505                	li	a0,1
    200a:	00004097          	auipc	ra,0x4
    200e:	b84080e7          	jalr	-1148(ra) # 5b8e <exit>
      close(open("x", O_RDWR | O_CREATE));
    2012:	20200593          	li	a1,514
    2016:	8556                	mv	a0,s5
    2018:	00004097          	auipc	ra,0x4
    201c:	bb6080e7          	jalr	-1098(ra) # 5bce <open>
    2020:	00004097          	auipc	ra,0x4
    2024:	b96080e7          	jalr	-1130(ra) # 5bb6 <close>
  for(i = 0; i < 100; i++){
    2028:	34fd                	addiw	s1,s1,-1
    202a:	c88d                	beqz	s1,205c <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    202c:	033c87bb          	mulw	a5,s9,s3
    2030:	012787bb          	addw	a5,a5,s2
    2034:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    2038:	0347f7bb          	remuw	a5,a5,s4
    203c:	dbf9                	beqz	a5,2012 <linkunlink+0x86>
    } else if((x % 3) == 1){
    203e:	01678863          	beq	a5,s6,204e <linkunlink+0xc2>
      unlink("x");
    2042:	8556                	mv	a0,s5
    2044:	00004097          	auipc	ra,0x4
    2048:	b9a080e7          	jalr	-1126(ra) # 5bde <unlink>
    204c:	bff1                	j	2028 <linkunlink+0x9c>
      link("cat", "x");
    204e:	85d6                	mv	a1,s5
    2050:	855e                	mv	a0,s7
    2052:	00004097          	auipc	ra,0x4
    2056:	b9c080e7          	jalr	-1124(ra) # 5bee <link>
    205a:	b7f9                	j	2028 <linkunlink+0x9c>
  if(pid)
    205c:	020c0463          	beqz	s8,2084 <linkunlink+0xf8>
    wait(0);
    2060:	4501                	li	a0,0
    2062:	00004097          	auipc	ra,0x4
    2066:	b34080e7          	jalr	-1228(ra) # 5b96 <wait>
}
    206a:	60e6                	ld	ra,88(sp)
    206c:	6446                	ld	s0,80(sp)
    206e:	64a6                	ld	s1,72(sp)
    2070:	6906                	ld	s2,64(sp)
    2072:	79e2                	ld	s3,56(sp)
    2074:	7a42                	ld	s4,48(sp)
    2076:	7aa2                	ld	s5,40(sp)
    2078:	7b02                	ld	s6,32(sp)
    207a:	6be2                	ld	s7,24(sp)
    207c:	6c42                	ld	s8,16(sp)
    207e:	6ca2                	ld	s9,8(sp)
    2080:	6125                	addi	sp,sp,96
    2082:	8082                	ret
    exit(0);
    2084:	4501                	li	a0,0
    2086:	00004097          	auipc	ra,0x4
    208a:	b08080e7          	jalr	-1272(ra) # 5b8e <exit>

000000000000208e <forktest>:
{
    208e:	7179                	addi	sp,sp,-48
    2090:	f406                	sd	ra,40(sp)
    2092:	f022                	sd	s0,32(sp)
    2094:	ec26                	sd	s1,24(sp)
    2096:	e84a                	sd	s2,16(sp)
    2098:	e44e                	sd	s3,8(sp)
    209a:	1800                	addi	s0,sp,48
    209c:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    209e:	4481                	li	s1,0
    20a0:	3e800913          	li	s2,1000
    pid = fork();
    20a4:	00004097          	auipc	ra,0x4
    20a8:	ae2080e7          	jalr	-1310(ra) # 5b86 <fork>
    if(pid < 0)
    20ac:	02054863          	bltz	a0,20dc <forktest+0x4e>
    if(pid == 0)
    20b0:	c115                	beqz	a0,20d4 <forktest+0x46>
  for(n=0; n<N; n++){
    20b2:	2485                	addiw	s1,s1,1
    20b4:	ff2498e3          	bne	s1,s2,20a4 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
<<<<<<< HEAD
    20bc:	85ce                	mv	a1,s3
    20be:	00005517          	auipc	a0,0x5
    20c2:	b8a50513          	addi	a0,a0,-1142 # 6c48 <malloc+0xc44>
    20c6:	00004097          	auipc	ra,0x4
    20ca:	e80080e7          	jalr	-384(ra) # 5f46 <printf>
=======
    20b8:	85ce                	mv	a1,s3
    20ba:	00005517          	auipc	a0,0x5
    20be:	b1e50513          	addi	a0,a0,-1250 # 6bd8 <malloc+0xc22>
    20c2:	00004097          	auipc	ra,0x4
    20c6:	e3c080e7          	jalr	-452(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    20ca:	4505                	li	a0,1
    20cc:	00004097          	auipc	ra,0x4
    20d0:	ac2080e7          	jalr	-1342(ra) # 5b8e <exit>
      exit(0);
    20d4:	00004097          	auipc	ra,0x4
    20d8:	aba080e7          	jalr	-1350(ra) # 5b8e <exit>
  if (n == 0) {
    20dc:	cc9d                	beqz	s1,211a <forktest+0x8c>
  if(n == N){
    20de:	3e800793          	li	a5,1000
    20e2:	fcf48be3          	beq	s1,a5,20b8 <forktest+0x2a>
  for(; n > 0; n--){
    20e6:	00905b63          	blez	s1,20fc <forktest+0x6e>
    if(wait(0) < 0){
    20ea:	4501                	li	a0,0
    20ec:	00004097          	auipc	ra,0x4
    20f0:	aaa080e7          	jalr	-1366(ra) # 5b96 <wait>
    20f4:	04054163          	bltz	a0,2136 <forktest+0xa8>
  for(; n > 0; n--){
    20f8:	34fd                	addiw	s1,s1,-1
    20fa:	f8e5                	bnez	s1,20ea <forktest+0x5c>
  if(wait(0) != -1){
    20fc:	4501                	li	a0,0
    20fe:	00004097          	auipc	ra,0x4
    2102:	a98080e7          	jalr	-1384(ra) # 5b96 <wait>
    2106:	57fd                	li	a5,-1
    2108:	04f51563          	bne	a0,a5,2152 <forktest+0xc4>
}
    210c:	70a2                	ld	ra,40(sp)
    210e:	7402                	ld	s0,32(sp)
    2110:	64e2                	ld	s1,24(sp)
    2112:	6942                	ld	s2,16(sp)
    2114:	69a2                	ld	s3,8(sp)
    2116:	6145                	addi	sp,sp,48
    2118:	8082                	ret
    printf("%s: no fork at all!\n", s);
<<<<<<< HEAD
    211e:	85ce                	mv	a1,s3
    2120:	00005517          	auipc	a0,0x5
    2124:	b1050513          	addi	a0,a0,-1264 # 6c30 <malloc+0xc2c>
    2128:	00004097          	auipc	ra,0x4
    212c:	e1e080e7          	jalr	-482(ra) # 5f46 <printf>
=======
    211a:	85ce                	mv	a1,s3
    211c:	00005517          	auipc	a0,0x5
    2120:	aa450513          	addi	a0,a0,-1372 # 6bc0 <malloc+0xc0a>
    2124:	00004097          	auipc	ra,0x4
    2128:	dda080e7          	jalr	-550(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    212c:	4505                	li	a0,1
    212e:	00004097          	auipc	ra,0x4
    2132:	a60080e7          	jalr	-1440(ra) # 5b8e <exit>
      printf("%s: wait stopped early\n", s);
<<<<<<< HEAD
    213a:	85ce                	mv	a1,s3
    213c:	00005517          	auipc	a0,0x5
    2140:	b3450513          	addi	a0,a0,-1228 # 6c70 <malloc+0xc6c>
    2144:	00004097          	auipc	ra,0x4
    2148:	e02080e7          	jalr	-510(ra) # 5f46 <printf>
=======
    2136:	85ce                	mv	a1,s3
    2138:	00005517          	auipc	a0,0x5
    213c:	ac850513          	addi	a0,a0,-1336 # 6c00 <malloc+0xc4a>
    2140:	00004097          	auipc	ra,0x4
    2144:	dbe080e7          	jalr	-578(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    2148:	4505                	li	a0,1
    214a:	00004097          	auipc	ra,0x4
    214e:	a44080e7          	jalr	-1468(ra) # 5b8e <exit>
    printf("%s: wait got too many\n", s);
<<<<<<< HEAD
    2156:	85ce                	mv	a1,s3
    2158:	00005517          	auipc	a0,0x5
    215c:	b3050513          	addi	a0,a0,-1232 # 6c88 <malloc+0xc84>
    2160:	00004097          	auipc	ra,0x4
    2164:	de6080e7          	jalr	-538(ra) # 5f46 <printf>
=======
    2152:	85ce                	mv	a1,s3
    2154:	00005517          	auipc	a0,0x5
    2158:	ac450513          	addi	a0,a0,-1340 # 6c18 <malloc+0xc62>
    215c:	00004097          	auipc	ra,0x4
    2160:	da2080e7          	jalr	-606(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2164:	4505                	li	a0,1
    2166:	00004097          	auipc	ra,0x4
    216a:	a28080e7          	jalr	-1496(ra) # 5b8e <exit>

000000000000216e <kernmem>:
{
    216e:	715d                	addi	sp,sp,-80
    2170:	e486                	sd	ra,72(sp)
    2172:	e0a2                	sd	s0,64(sp)
    2174:	fc26                	sd	s1,56(sp)
    2176:	f84a                	sd	s2,48(sp)
    2178:	f44e                	sd	s3,40(sp)
    217a:	f052                	sd	s4,32(sp)
    217c:	ec56                	sd	s5,24(sp)
    217e:	0880                	addi	s0,sp,80
    2180:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2182:	4485                	li	s1,1
    2184:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    2186:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2188:	69b1                	lui	s3,0xc
    218a:	35098993          	addi	s3,s3,848 # c350 <uninit+0x1de8>
    218e:	1003d937          	lui	s2,0x1003d
    2192:	090e                	slli	s2,s2,0x3
    2194:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    2198:	00004097          	auipc	ra,0x4
    219c:	9ee080e7          	jalr	-1554(ra) # 5b86 <fork>
    if(pid < 0){
    21a0:	02054963          	bltz	a0,21d2 <kernmem+0x64>
    if(pid == 0){
    21a4:	c529                	beqz	a0,21ee <kernmem+0x80>
    wait(&xstatus);
    21a6:	fbc40513          	addi	a0,s0,-68
    21aa:	00004097          	auipc	ra,0x4
    21ae:	9ec080e7          	jalr	-1556(ra) # 5b96 <wait>
    if(xstatus != -1)  // did kernel kill child?
    21b2:	fbc42783          	lw	a5,-68(s0)
    21b6:	05579d63          	bne	a5,s5,2210 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21ba:	94ce                	add	s1,s1,s3
    21bc:	fd249ee3          	bne	s1,s2,2198 <kernmem+0x2a>
}
    21c0:	60a6                	ld	ra,72(sp)
    21c2:	6406                	ld	s0,64(sp)
    21c4:	74e2                	ld	s1,56(sp)
    21c6:	7942                	ld	s2,48(sp)
    21c8:	79a2                	ld	s3,40(sp)
    21ca:	7a02                	ld	s4,32(sp)
    21cc:	6ae2                	ld	s5,24(sp)
    21ce:	6161                	addi	sp,sp,80
    21d0:	8082                	ret
      printf("%s: fork failed\n", s);
<<<<<<< HEAD
    21d6:	85d2                	mv	a1,s4
    21d8:	00004517          	auipc	a0,0x4
    21dc:	7f850513          	addi	a0,a0,2040 # 69d0 <malloc+0x9cc>
    21e0:	00004097          	auipc	ra,0x4
    21e4:	d66080e7          	jalr	-666(ra) # 5f46 <printf>
=======
    21d2:	85d2                	mv	a1,s4
    21d4:	00004517          	auipc	a0,0x4
    21d8:	78c50513          	addi	a0,a0,1932 # 6960 <malloc+0x9aa>
    21dc:	00004097          	auipc	ra,0x4
    21e0:	d22080e7          	jalr	-734(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    21e4:	4505                	li	a0,1
    21e6:	00004097          	auipc	ra,0x4
    21ea:	9a8080e7          	jalr	-1624(ra) # 5b8e <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
<<<<<<< HEAD
    21f2:	0004c683          	lbu	a3,0(s1)
    21f6:	8626                	mv	a2,s1
    21f8:	85d2                	mv	a1,s4
    21fa:	00005517          	auipc	a0,0x5
    21fe:	aa650513          	addi	a0,a0,-1370 # 6ca0 <malloc+0xc9c>
    2202:	00004097          	auipc	ra,0x4
    2206:	d44080e7          	jalr	-700(ra) # 5f46 <printf>
=======
    21ee:	0004c683          	lbu	a3,0(s1)
    21f2:	8626                	mv	a2,s1
    21f4:	85d2                	mv	a1,s4
    21f6:	00005517          	auipc	a0,0x5
    21fa:	a3a50513          	addi	a0,a0,-1478 # 6c30 <malloc+0xc7a>
    21fe:	00004097          	auipc	ra,0x4
    2202:	d00080e7          	jalr	-768(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    2206:	4505                	li	a0,1
    2208:	00004097          	auipc	ra,0x4
    220c:	986080e7          	jalr	-1658(ra) # 5b8e <exit>
      exit(1);
    2210:	4505                	li	a0,1
    2212:	00004097          	auipc	ra,0x4
    2216:	97c080e7          	jalr	-1668(ra) # 5b8e <exit>

000000000000221a <MAXVAplus>:
{
    221a:	7179                	addi	sp,sp,-48
    221c:	f406                	sd	ra,40(sp)
    221e:	f022                	sd	s0,32(sp)
    2220:	ec26                	sd	s1,24(sp)
    2222:	e84a                	sd	s2,16(sp)
    2224:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    2226:	4785                	li	a5,1
    2228:	179a                	slli	a5,a5,0x26
    222a:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    222e:	fd843783          	ld	a5,-40(s0)
    2232:	cf85                	beqz	a5,226a <MAXVAplus+0x50>
    2234:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    2236:	54fd                	li	s1,-1
    pid = fork();
    2238:	00004097          	auipc	ra,0x4
    223c:	94e080e7          	jalr	-1714(ra) # 5b86 <fork>
    if(pid < 0){
    2240:	02054b63          	bltz	a0,2276 <MAXVAplus+0x5c>
    if(pid == 0){
    2244:	c539                	beqz	a0,2292 <MAXVAplus+0x78>
    wait(&xstatus);
    2246:	fd440513          	addi	a0,s0,-44
    224a:	00004097          	auipc	ra,0x4
    224e:	94c080e7          	jalr	-1716(ra) # 5b96 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2252:	fd442783          	lw	a5,-44(s0)
    2256:	06979463          	bne	a5,s1,22be <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    225a:	fd843783          	ld	a5,-40(s0)
    225e:	0786                	slli	a5,a5,0x1
    2260:	fcf43c23          	sd	a5,-40(s0)
    2264:	fd843783          	ld	a5,-40(s0)
    2268:	fbe1                	bnez	a5,2238 <MAXVAplus+0x1e>
}
    226a:	70a2                	ld	ra,40(sp)
    226c:	7402                	ld	s0,32(sp)
    226e:	64e2                	ld	s1,24(sp)
    2270:	6942                	ld	s2,16(sp)
    2272:	6145                	addi	sp,sp,48
    2274:	8082                	ret
      printf("%s: fork failed\n", s);
<<<<<<< HEAD
    227a:	85ca                	mv	a1,s2
    227c:	00004517          	auipc	a0,0x4
    2280:	75450513          	addi	a0,a0,1876 # 69d0 <malloc+0x9cc>
    2284:	00004097          	auipc	ra,0x4
    2288:	cc2080e7          	jalr	-830(ra) # 5f46 <printf>
=======
    2276:	85ca                	mv	a1,s2
    2278:	00004517          	auipc	a0,0x4
    227c:	6e850513          	addi	a0,a0,1768 # 6960 <malloc+0x9aa>
    2280:	00004097          	auipc	ra,0x4
    2284:	c7e080e7          	jalr	-898(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    2288:	4505                	li	a0,1
    228a:	00004097          	auipc	ra,0x4
    228e:	904080e7          	jalr	-1788(ra) # 5b8e <exit>
      *(char*)a = 99;
    2292:	fd843783          	ld	a5,-40(s0)
    2296:	06300713          	li	a4,99
    229a:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
<<<<<<< HEAD
    22a2:	fd843603          	ld	a2,-40(s0)
    22a6:	85ca                	mv	a1,s2
    22a8:	00005517          	auipc	a0,0x5
    22ac:	a1850513          	addi	a0,a0,-1512 # 6cc0 <malloc+0xcbc>
    22b0:	00004097          	auipc	ra,0x4
    22b4:	c96080e7          	jalr	-874(ra) # 5f46 <printf>
=======
    229e:	fd843603          	ld	a2,-40(s0)
    22a2:	85ca                	mv	a1,s2
    22a4:	00005517          	auipc	a0,0x5
    22a8:	9ac50513          	addi	a0,a0,-1620 # 6c50 <malloc+0xc9a>
    22ac:	00004097          	auipc	ra,0x4
    22b0:	c52080e7          	jalr	-942(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    22b4:	4505                	li	a0,1
    22b6:	00004097          	auipc	ra,0x4
    22ba:	8d8080e7          	jalr	-1832(ra) # 5b8e <exit>
      exit(1);
    22be:	4505                	li	a0,1
    22c0:	00004097          	auipc	ra,0x4
    22c4:	8ce080e7          	jalr	-1842(ra) # 5b8e <exit>

00000000000022c8 <bigargtest>:
{
    22c8:	7179                	addi	sp,sp,-48
    22ca:	f406                	sd	ra,40(sp)
    22cc:	f022                	sd	s0,32(sp)
    22ce:	ec26                	sd	s1,24(sp)
    22d0:	1800                	addi	s0,sp,48
    22d2:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
<<<<<<< HEAD
    22d8:	00005517          	auipc	a0,0x5
    22dc:	a0050513          	addi	a0,a0,-1536 # 6cd8 <malloc+0xcd4>
    22e0:	00004097          	auipc	ra,0x4
    22e4:	936080e7          	jalr	-1738(ra) # 5c16 <unlink>
=======
    22d4:	00005517          	auipc	a0,0x5
    22d8:	99450513          	addi	a0,a0,-1644 # 6c68 <malloc+0xcb2>
    22dc:	00004097          	auipc	ra,0x4
    22e0:	902080e7          	jalr	-1790(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  pid = fork();
    22e4:	00004097          	auipc	ra,0x4
    22e8:	8a2080e7          	jalr	-1886(ra) # 5b86 <fork>
  if(pid == 0){
    22ec:	c121                	beqz	a0,232c <bigargtest+0x64>
  } else if(pid < 0){
    22ee:	0a054063          	bltz	a0,238e <bigargtest+0xc6>
  wait(&xstatus);
    22f2:	fdc40513          	addi	a0,s0,-36
    22f6:	00004097          	auipc	ra,0x4
    22fa:	8a0080e7          	jalr	-1888(ra) # 5b96 <wait>
  if(xstatus != 0)
    22fe:	fdc42503          	lw	a0,-36(s0)
    2302:	e545                	bnez	a0,23aa <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
<<<<<<< HEAD
    2308:	4581                	li	a1,0
    230a:	00005517          	auipc	a0,0x5
    230e:	9ce50513          	addi	a0,a0,-1586 # 6cd8 <malloc+0xcd4>
    2312:	00004097          	auipc	ra,0x4
    2316:	8f4080e7          	jalr	-1804(ra) # 5c06 <open>
=======
    2304:	4581                	li	a1,0
    2306:	00005517          	auipc	a0,0x5
    230a:	96250513          	addi	a0,a0,-1694 # 6c68 <malloc+0xcb2>
    230e:	00004097          	auipc	ra,0x4
    2312:	8c0080e7          	jalr	-1856(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    2316:	08054e63          	bltz	a0,23b2 <bigargtest+0xea>
  close(fd);
    231a:	00004097          	auipc	ra,0x4
    231e:	89c080e7          	jalr	-1892(ra) # 5bb6 <close>
}
    2322:	70a2                	ld	ra,40(sp)
    2324:	7402                	ld	s0,32(sp)
    2326:	64e2                	ld	s1,24(sp)
    2328:	6145                	addi	sp,sp,48
    232a:	8082                	ret
    232c:	00007797          	auipc	a5,0x7
    2330:	13478793          	addi	a5,a5,308 # 9460 <args.1>
    2334:	00007697          	auipc	a3,0x7
    2338:	22468693          	addi	a3,a3,548 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
<<<<<<< HEAD
    2340:	00005717          	auipc	a4,0x5
    2344:	9a870713          	addi	a4,a4,-1624 # 6ce8 <malloc+0xce4>
    2348:	e398                	sd	a4,0(a5)
=======
    233c:	00005717          	auipc	a4,0x5
    2340:	93c70713          	addi	a4,a4,-1732 # 6c78 <malloc+0xcc2>
    2344:	e398                	sd	a4,0(a5)
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    for(i = 0; i < MAXARG-1; i++)
    2346:	07a1                	addi	a5,a5,8
    2348:	fed79ee3          	bne	a5,a3,2344 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    234c:	00007597          	auipc	a1,0x7
    2350:	11458593          	addi	a1,a1,276 # 9460 <args.1>
    2354:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
<<<<<<< HEAD
    235c:	00004517          	auipc	a0,0x4
    2360:	dec50513          	addi	a0,a0,-532 # 6148 <malloc+0x144>
    2364:	00004097          	auipc	ra,0x4
    2368:	89a080e7          	jalr	-1894(ra) # 5bfe <exec>
    fd = open("bigarg-ok", O_CREATE);
    236c:	20000593          	li	a1,512
    2370:	00005517          	auipc	a0,0x5
    2374:	96850513          	addi	a0,a0,-1688 # 6cd8 <malloc+0xcd4>
    2378:	00004097          	auipc	ra,0x4
    237c:	88e080e7          	jalr	-1906(ra) # 5c06 <open>
=======
    2358:	00004517          	auipc	a0,0x4
    235c:	d8050513          	addi	a0,a0,-640 # 60d8 <malloc+0x122>
    2360:	00004097          	auipc	ra,0x4
    2364:	866080e7          	jalr	-1946(ra) # 5bc6 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2368:	20000593          	li	a1,512
    236c:	00005517          	auipc	a0,0x5
    2370:	8fc50513          	addi	a0,a0,-1796 # 6c68 <malloc+0xcb2>
    2374:	00004097          	auipc	ra,0x4
    2378:	85a080e7          	jalr	-1958(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    close(fd);
    237c:	00004097          	auipc	ra,0x4
    2380:	83a080e7          	jalr	-1990(ra) # 5bb6 <close>
    exit(0);
    2384:	4501                	li	a0,0
    2386:	00004097          	auipc	ra,0x4
    238a:	808080e7          	jalr	-2040(ra) # 5b8e <exit>
    printf("%s: bigargtest: fork failed\n", s);
<<<<<<< HEAD
    2392:	85a6                	mv	a1,s1
    2394:	00005517          	auipc	a0,0x5
    2398:	a3450513          	addi	a0,a0,-1484 # 6dc8 <malloc+0xdc4>
    239c:	00004097          	auipc	ra,0x4
    23a0:	baa080e7          	jalr	-1110(ra) # 5f46 <printf>
=======
    238e:	85a6                	mv	a1,s1
    2390:	00005517          	auipc	a0,0x5
    2394:	9c850513          	addi	a0,a0,-1592 # 6d58 <malloc+0xda2>
    2398:	00004097          	auipc	ra,0x4
    239c:	b66080e7          	jalr	-1178(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    23a0:	4505                	li	a0,1
    23a2:	00003097          	auipc	ra,0x3
    23a6:	7ec080e7          	jalr	2028(ra) # 5b8e <exit>
    exit(xstatus);
    23aa:	00003097          	auipc	ra,0x3
    23ae:	7e4080e7          	jalr	2020(ra) # 5b8e <exit>
    printf("%s: bigarg test failed!\n", s);
<<<<<<< HEAD
    23b6:	85a6                	mv	a1,s1
    23b8:	00005517          	auipc	a0,0x5
    23bc:	a3050513          	addi	a0,a0,-1488 # 6de8 <malloc+0xde4>
    23c0:	00004097          	auipc	ra,0x4
    23c4:	b86080e7          	jalr	-1146(ra) # 5f46 <printf>
=======
    23b2:	85a6                	mv	a1,s1
    23b4:	00005517          	auipc	a0,0x5
    23b8:	9c450513          	addi	a0,a0,-1596 # 6d78 <malloc+0xdc2>
    23bc:	00004097          	auipc	ra,0x4
    23c0:	b42080e7          	jalr	-1214(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    23c4:	4505                	li	a0,1
    23c6:	00003097          	auipc	ra,0x3
    23ca:	7c8080e7          	jalr	1992(ra) # 5b8e <exit>

00000000000023ce <stacktest>:
{
    23ce:	7179                	addi	sp,sp,-48
    23d0:	f406                	sd	ra,40(sp)
    23d2:	f022                	sd	s0,32(sp)
    23d4:	ec26                	sd	s1,24(sp)
    23d6:	1800                	addi	s0,sp,48
    23d8:	84aa                	mv	s1,a0
  pid = fork();
    23da:	00003097          	auipc	ra,0x3
    23de:	7ac080e7          	jalr	1964(ra) # 5b86 <fork>
  if(pid == 0) {
    23e2:	c115                	beqz	a0,2406 <stacktest+0x38>
  } else if(pid < 0){
    23e4:	04054463          	bltz	a0,242c <stacktest+0x5e>
  wait(&xstatus);
    23e8:	fdc40513          	addi	a0,s0,-36
    23ec:	00003097          	auipc	ra,0x3
    23f0:	7aa080e7          	jalr	1962(ra) # 5b96 <wait>
  if(xstatus == -1)  // kernel killed child?
    23f4:	fdc42503          	lw	a0,-36(s0)
    23f8:	57fd                	li	a5,-1
    23fa:	04f50763          	beq	a0,a5,2448 <stacktest+0x7a>
    exit(xstatus);
    23fe:	00003097          	auipc	ra,0x3
    2402:	790080e7          	jalr	1936(ra) # 5b8e <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2406:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
<<<<<<< HEAD
    240c:	77fd                	lui	a5,0xfffff
    240e:	97ba                	add	a5,a5,a4
    2410:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    2414:	85a6                	mv	a1,s1
    2416:	00005517          	auipc	a0,0x5
    241a:	9f250513          	addi	a0,a0,-1550 # 6e08 <malloc+0xe04>
    241e:	00004097          	auipc	ra,0x4
    2422:	b28080e7          	jalr	-1240(ra) # 5f46 <printf>
=======
    2408:	77fd                	lui	a5,0xfffff
    240a:	97ba                	add	a5,a5,a4
    240c:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    2410:	85a6                	mv	a1,s1
    2412:	00005517          	auipc	a0,0x5
    2416:	98650513          	addi	a0,a0,-1658 # 6d98 <malloc+0xde2>
    241a:	00004097          	auipc	ra,0x4
    241e:	ae4080e7          	jalr	-1308(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2422:	4505                	li	a0,1
    2424:	00003097          	auipc	ra,0x3
    2428:	76a080e7          	jalr	1898(ra) # 5b8e <exit>
    printf("%s: fork failed\n", s);
<<<<<<< HEAD
    2430:	85a6                	mv	a1,s1
    2432:	00004517          	auipc	a0,0x4
    2436:	59e50513          	addi	a0,a0,1438 # 69d0 <malloc+0x9cc>
    243a:	00004097          	auipc	ra,0x4
    243e:	b0c080e7          	jalr	-1268(ra) # 5f46 <printf>
=======
    242c:	85a6                	mv	a1,s1
    242e:	00004517          	auipc	a0,0x4
    2432:	53250513          	addi	a0,a0,1330 # 6960 <malloc+0x9aa>
    2436:	00004097          	auipc	ra,0x4
    243a:	ac8080e7          	jalr	-1336(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    243e:	4505                	li	a0,1
    2440:	00003097          	auipc	ra,0x3
    2444:	74e080e7          	jalr	1870(ra) # 5b8e <exit>
    exit(0);
    2448:	4501                	li	a0,0
    244a:	00003097          	auipc	ra,0x3
    244e:	744080e7          	jalr	1860(ra) # 5b8e <exit>

0000000000002452 <textwrite>:
{
    2452:	7179                	addi	sp,sp,-48
    2454:	f406                	sd	ra,40(sp)
    2456:	f022                	sd	s0,32(sp)
    2458:	ec26                	sd	s1,24(sp)
    245a:	1800                	addi	s0,sp,48
    245c:	84aa                	mv	s1,a0
  pid = fork();
    245e:	00003097          	auipc	ra,0x3
    2462:	728080e7          	jalr	1832(ra) # 5b86 <fork>
  if(pid == 0) {
    2466:	c115                	beqz	a0,248a <textwrite+0x38>
  } else if(pid < 0){
    2468:	02054963          	bltz	a0,249a <textwrite+0x48>
  wait(&xstatus);
    246c:	fdc40513          	addi	a0,s0,-36
    2470:	00003097          	auipc	ra,0x3
    2474:	726080e7          	jalr	1830(ra) # 5b96 <wait>
  if(xstatus == -1)  // kernel killed child?
    2478:	fdc42503          	lw	a0,-36(s0)
    247c:	57fd                	li	a5,-1
    247e:	02f50c63          	beq	a0,a5,24b6 <textwrite+0x64>
    exit(xstatus);
    2482:	00003097          	auipc	ra,0x3
    2486:	70c080e7          	jalr	1804(ra) # 5b8e <exit>
    *addr = 10;
    248a:	47a9                	li	a5,10
    248c:	00f02023          	sw	a5,0(zero) # 0 <copyinstr1>
    exit(1);
    2490:	4505                	li	a0,1
    2492:	00003097          	auipc	ra,0x3
    2496:	6fc080e7          	jalr	1788(ra) # 5b8e <exit>
    printf("%s: fork failed\n", s);
<<<<<<< HEAD
    249e:	85a6                	mv	a1,s1
    24a0:	00004517          	auipc	a0,0x4
    24a4:	53050513          	addi	a0,a0,1328 # 69d0 <malloc+0x9cc>
    24a8:	00004097          	auipc	ra,0x4
    24ac:	a9e080e7          	jalr	-1378(ra) # 5f46 <printf>
=======
    249a:	85a6                	mv	a1,s1
    249c:	00004517          	auipc	a0,0x4
    24a0:	4c450513          	addi	a0,a0,1220 # 6960 <malloc+0x9aa>
    24a4:	00004097          	auipc	ra,0x4
    24a8:	a5a080e7          	jalr	-1446(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    24ac:	4505                	li	a0,1
    24ae:	00003097          	auipc	ra,0x3
    24b2:	6e0080e7          	jalr	1760(ra) # 5b8e <exit>
    exit(0);
    24b6:	4501                	li	a0,0
    24b8:	00003097          	auipc	ra,0x3
    24bc:	6d6080e7          	jalr	1750(ra) # 5b8e <exit>

00000000000024c0 <manywrites>:
{
    24c0:	711d                	addi	sp,sp,-96
    24c2:	ec86                	sd	ra,88(sp)
    24c4:	e8a2                	sd	s0,80(sp)
    24c6:	e4a6                	sd	s1,72(sp)
    24c8:	e0ca                	sd	s2,64(sp)
    24ca:	fc4e                	sd	s3,56(sp)
    24cc:	f852                	sd	s4,48(sp)
    24ce:	f456                	sd	s5,40(sp)
    24d0:	f05a                	sd	s6,32(sp)
    24d2:	ec5e                	sd	s7,24(sp)
    24d4:	1080                	addi	s0,sp,96
    24d6:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    24d8:	4981                	li	s3,0
    24da:	4911                	li	s2,4
    int pid = fork();
    24dc:	00003097          	auipc	ra,0x3
    24e0:	6aa080e7          	jalr	1706(ra) # 5b86 <fork>
    24e4:	84aa                	mv	s1,a0
    if(pid < 0){
    24e6:	02054963          	bltz	a0,2518 <manywrites+0x58>
    if(pid == 0){
    24ea:	c521                	beqz	a0,2532 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    24ec:	2985                	addiw	s3,s3,1
    24ee:	ff2997e3          	bne	s3,s2,24dc <manywrites+0x1c>
    24f2:	4491                	li	s1,4
    int st = 0;
    24f4:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    24f8:	fa840513          	addi	a0,s0,-88
    24fc:	00003097          	auipc	ra,0x3
    2500:	69a080e7          	jalr	1690(ra) # 5b96 <wait>
    if(st != 0)
    2504:	fa842503          	lw	a0,-88(s0)
    2508:	ed6d                	bnez	a0,2602 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    250a:	34fd                	addiw	s1,s1,-1
    250c:	f4e5                	bnez	s1,24f4 <manywrites+0x34>
  exit(0);
    250e:	4501                	li	a0,0
    2510:	00003097          	auipc	ra,0x3
    2514:	67e080e7          	jalr	1662(ra) # 5b8e <exit>
      printf("fork failed\n");
<<<<<<< HEAD
    251c:	00005517          	auipc	a0,0x5
    2520:	8bc50513          	addi	a0,a0,-1860 # 6dd8 <malloc+0xdd4>
    2524:	00004097          	auipc	ra,0x4
    2528:	a22080e7          	jalr	-1502(ra) # 5f46 <printf>
=======
    2518:	00005517          	auipc	a0,0x5
    251c:	85050513          	addi	a0,a0,-1968 # 6d68 <malloc+0xdb2>
    2520:	00004097          	auipc	ra,0x4
    2524:	9de080e7          	jalr	-1570(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    2528:	4505                	li	a0,1
    252a:	00003097          	auipc	ra,0x3
    252e:	664080e7          	jalr	1636(ra) # 5b8e <exit>
      name[0] = 'b';
    2532:	06200793          	li	a5,98
    2536:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    253a:	0619879b          	addiw	a5,s3,97
    253e:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    2542:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    2546:	fa840513          	addi	a0,s0,-88
    254a:	00003097          	auipc	ra,0x3
    254e:	694080e7          	jalr	1684(ra) # 5bde <unlink>
    2552:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    2554:	0000ab17          	auipc	s6,0xa
    2558:	724b0b13          	addi	s6,s6,1828 # cc78 <buf>
        for(int i = 0; i < ci+1; i++){
    255c:	8a26                	mv	s4,s1
    255e:	0209ce63          	bltz	s3,259a <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    2562:	20200593          	li	a1,514
    2566:	fa840513          	addi	a0,s0,-88
    256a:	00003097          	auipc	ra,0x3
    256e:	664080e7          	jalr	1636(ra) # 5bce <open>
    2572:	892a                	mv	s2,a0
          if(fd < 0){
    2574:	04054763          	bltz	a0,25c2 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    2578:	660d                	lui	a2,0x3
    257a:	85da                	mv	a1,s6
    257c:	00003097          	auipc	ra,0x3
    2580:	632080e7          	jalr	1586(ra) # 5bae <write>
          if(cc != sz){
    2584:	678d                	lui	a5,0x3
    2586:	04f51e63          	bne	a0,a5,25e2 <manywrites+0x122>
          close(fd);
    258a:	854a                	mv	a0,s2
    258c:	00003097          	auipc	ra,0x3
    2590:	62a080e7          	jalr	1578(ra) # 5bb6 <close>
        for(int i = 0; i < ci+1; i++){
    2594:	2a05                	addiw	s4,s4,1
    2596:	fd49d6e3          	bge	s3,s4,2562 <manywrites+0xa2>
        unlink(name);
    259a:	fa840513          	addi	a0,s0,-88
    259e:	00003097          	auipc	ra,0x3
    25a2:	640080e7          	jalr	1600(ra) # 5bde <unlink>
      for(int iters = 0; iters < howmany; iters++){
    25a6:	3bfd                	addiw	s7,s7,-1
    25a8:	fa0b9ae3          	bnez	s7,255c <manywrites+0x9c>
      unlink(name);
    25ac:	fa840513          	addi	a0,s0,-88
    25b0:	00003097          	auipc	ra,0x3
    25b4:	62e080e7          	jalr	1582(ra) # 5bde <unlink>
      exit(0);
    25b8:	4501                	li	a0,0
    25ba:	00003097          	auipc	ra,0x3
    25be:	5d4080e7          	jalr	1492(ra) # 5b8e <exit>
            printf("%s: cannot create %s\n", s, name);
<<<<<<< HEAD
    25c6:	fa840613          	addi	a2,s0,-88
    25ca:	85d6                	mv	a1,s5
    25cc:	00005517          	auipc	a0,0x5
    25d0:	86450513          	addi	a0,a0,-1948 # 6e30 <malloc+0xe2c>
    25d4:	00004097          	auipc	ra,0x4
    25d8:	972080e7          	jalr	-1678(ra) # 5f46 <printf>
=======
    25c2:	fa840613          	addi	a2,s0,-88
    25c6:	85d6                	mv	a1,s5
    25c8:	00004517          	auipc	a0,0x4
    25cc:	7f850513          	addi	a0,a0,2040 # 6dc0 <malloc+0xe0a>
    25d0:	00004097          	auipc	ra,0x4
    25d4:	92e080e7          	jalr	-1746(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
            exit(1);
    25d8:	4505                	li	a0,1
    25da:	00003097          	auipc	ra,0x3
    25de:	5b4080e7          	jalr	1460(ra) # 5b8e <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
<<<<<<< HEAD
    25e6:	86aa                	mv	a3,a0
    25e8:	660d                	lui	a2,0x3
    25ea:	85d6                	mv	a1,s5
    25ec:	00004517          	auipc	a0,0x4
    25f0:	c2c50513          	addi	a0,a0,-980 # 6218 <malloc+0x214>
    25f4:	00004097          	auipc	ra,0x4
    25f8:	952080e7          	jalr	-1710(ra) # 5f46 <printf>
=======
    25e2:	86aa                	mv	a3,a0
    25e4:	660d                	lui	a2,0x3
    25e6:	85d6                	mv	a1,s5
    25e8:	00004517          	auipc	a0,0x4
    25ec:	bc050513          	addi	a0,a0,-1088 # 61a8 <malloc+0x1f2>
    25f0:	00004097          	auipc	ra,0x4
    25f4:	90e080e7          	jalr	-1778(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
            exit(1);
    25f8:	4505                	li	a0,1
    25fa:	00003097          	auipc	ra,0x3
    25fe:	594080e7          	jalr	1428(ra) # 5b8e <exit>
      exit(st);
    2602:	00003097          	auipc	ra,0x3
    2606:	58c080e7          	jalr	1420(ra) # 5b8e <exit>

000000000000260a <copyinstr3>:
{
    260a:	7179                	addi	sp,sp,-48
    260c:	f406                	sd	ra,40(sp)
    260e:	f022                	sd	s0,32(sp)
    2610:	ec26                	sd	s1,24(sp)
    2612:	1800                	addi	s0,sp,48
  sbrk(8192);
    2614:	6509                	lui	a0,0x2
    2616:	00003097          	auipc	ra,0x3
    261a:	600080e7          	jalr	1536(ra) # 5c16 <sbrk>
  uint64 top = (uint64) sbrk(0);
    261e:	4501                	li	a0,0
    2620:	00003097          	auipc	ra,0x3
    2624:	5f6080e7          	jalr	1526(ra) # 5c16 <sbrk>
  if((top % PGSIZE) != 0){
    2628:	03451793          	slli	a5,a0,0x34
    262c:	e3c9                	bnez	a5,26ae <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    262e:	4501                	li	a0,0
    2630:	00003097          	auipc	ra,0x3
    2634:	5e6080e7          	jalr	1510(ra) # 5c16 <sbrk>
  if(top % PGSIZE){
    2638:	03451793          	slli	a5,a0,0x34
    263c:	e3d9                	bnez	a5,26c2 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    263e:	fff50493          	addi	s1,a0,-1 # 1fff <linkunlink+0x73>
  *b = 'x';
    2642:	07800793          	li	a5,120
    2646:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    264a:	8526                	mv	a0,s1
    264c:	00003097          	auipc	ra,0x3
    2650:	592080e7          	jalr	1426(ra) # 5bde <unlink>
  if(ret != -1){
    2654:	57fd                	li	a5,-1
    2656:	08f51363          	bne	a0,a5,26dc <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    265a:	20100593          	li	a1,513
    265e:	8526                	mv	a0,s1
    2660:	00003097          	auipc	ra,0x3
    2664:	56e080e7          	jalr	1390(ra) # 5bce <open>
  if(fd != -1){
    2668:	57fd                	li	a5,-1
    266a:	08f51863          	bne	a0,a5,26fa <copyinstr3+0xf0>
  ret = link(b, b);
    266e:	85a6                	mv	a1,s1
    2670:	8526                	mv	a0,s1
    2672:	00003097          	auipc	ra,0x3
    2676:	57c080e7          	jalr	1404(ra) # 5bee <link>
  if(ret != -1){
    267a:	57fd                	li	a5,-1
    267c:	08f51e63          	bne	a0,a5,2718 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
<<<<<<< HEAD
    2684:	00005797          	auipc	a5,0x5
    2688:	4a478793          	addi	a5,a5,1188 # 7b28 <malloc+0x1b24>
    268c:	fcf43823          	sd	a5,-48(s0)
    2690:	fc043c23          	sd	zero,-40(s0)
=======
    2680:	00005797          	auipc	a5,0x5
    2684:	43878793          	addi	a5,a5,1080 # 7ab8 <malloc+0x1b02>
    2688:	fcf43823          	sd	a5,-48(s0)
    268c:	fc043c23          	sd	zero,-40(s0)
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  ret = exec(b, args);
    2690:	fd040593          	addi	a1,s0,-48
    2694:	8526                	mv	a0,s1
    2696:	00003097          	auipc	ra,0x3
    269a:	530080e7          	jalr	1328(ra) # 5bc6 <exec>
  if(ret != -1){
    269e:	57fd                	li	a5,-1
    26a0:	08f51c63          	bne	a0,a5,2738 <copyinstr3+0x12e>
}
    26a4:	70a2                	ld	ra,40(sp)
    26a6:	7402                	ld	s0,32(sp)
    26a8:	64e2                	ld	s1,24(sp)
    26aa:	6145                	addi	sp,sp,48
    26ac:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    26ae:	0347d513          	srli	a0,a5,0x34
    26b2:	6785                	lui	a5,0x1
    26b4:	40a7853b          	subw	a0,a5,a0
    26b8:	00003097          	auipc	ra,0x3
    26bc:	55e080e7          	jalr	1374(ra) # 5c16 <sbrk>
    26c0:	b7bd                	j	262e <copyinstr3+0x24>
    printf("oops\n");
<<<<<<< HEAD
    26c6:	00004517          	auipc	a0,0x4
    26ca:	78250513          	addi	a0,a0,1922 # 6e48 <malloc+0xe44>
    26ce:	00004097          	auipc	ra,0x4
    26d2:	878080e7          	jalr	-1928(ra) # 5f46 <printf>
=======
    26c2:	00004517          	auipc	a0,0x4
    26c6:	71650513          	addi	a0,a0,1814 # 6dd8 <malloc+0xe22>
    26ca:	00004097          	auipc	ra,0x4
    26ce:	834080e7          	jalr	-1996(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    26d2:	4505                	li	a0,1
    26d4:	00003097          	auipc	ra,0x3
    26d8:	4ba080e7          	jalr	1210(ra) # 5b8e <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
<<<<<<< HEAD
    26e0:	862a                	mv	a2,a0
    26e2:	85a6                	mv	a1,s1
    26e4:	00004517          	auipc	a0,0x4
    26e8:	20c50513          	addi	a0,a0,524 # 68f0 <malloc+0x8ec>
    26ec:	00004097          	auipc	ra,0x4
    26f0:	85a080e7          	jalr	-1958(ra) # 5f46 <printf>
=======
    26dc:	862a                	mv	a2,a0
    26de:	85a6                	mv	a1,s1
    26e0:	00004517          	auipc	a0,0x4
    26e4:	1a050513          	addi	a0,a0,416 # 6880 <malloc+0x8ca>
    26e8:	00004097          	auipc	ra,0x4
    26ec:	816080e7          	jalr	-2026(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    26f0:	4505                	li	a0,1
    26f2:	00003097          	auipc	ra,0x3
    26f6:	49c080e7          	jalr	1180(ra) # 5b8e <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
<<<<<<< HEAD
    26fe:	862a                	mv	a2,a0
    2700:	85a6                	mv	a1,s1
    2702:	00004517          	auipc	a0,0x4
    2706:	20e50513          	addi	a0,a0,526 # 6910 <malloc+0x90c>
    270a:	00004097          	auipc	ra,0x4
    270e:	83c080e7          	jalr	-1988(ra) # 5f46 <printf>
=======
    26fa:	862a                	mv	a2,a0
    26fc:	85a6                	mv	a1,s1
    26fe:	00004517          	auipc	a0,0x4
    2702:	1a250513          	addi	a0,a0,418 # 68a0 <malloc+0x8ea>
    2706:	00003097          	auipc	ra,0x3
    270a:	7f8080e7          	jalr	2040(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    270e:	4505                	li	a0,1
    2710:	00003097          	auipc	ra,0x3
    2714:	47e080e7          	jalr	1150(ra) # 5b8e <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
<<<<<<< HEAD
    271c:	86aa                	mv	a3,a0
    271e:	8626                	mv	a2,s1
    2720:	85a6                	mv	a1,s1
    2722:	00004517          	auipc	a0,0x4
    2726:	20e50513          	addi	a0,a0,526 # 6930 <malloc+0x92c>
    272a:	00004097          	auipc	ra,0x4
    272e:	81c080e7          	jalr	-2020(ra) # 5f46 <printf>
=======
    2718:	86aa                	mv	a3,a0
    271a:	8626                	mv	a2,s1
    271c:	85a6                	mv	a1,s1
    271e:	00004517          	auipc	a0,0x4
    2722:	1a250513          	addi	a0,a0,418 # 68c0 <malloc+0x90a>
    2726:	00003097          	auipc	ra,0x3
    272a:	7d8080e7          	jalr	2008(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    272e:	4505                	li	a0,1
    2730:	00003097          	auipc	ra,0x3
    2734:	45e080e7          	jalr	1118(ra) # 5b8e <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
<<<<<<< HEAD
    273c:	567d                	li	a2,-1
    273e:	85a6                	mv	a1,s1
    2740:	00004517          	auipc	a0,0x4
    2744:	21850513          	addi	a0,a0,536 # 6958 <malloc+0x954>
    2748:	00003097          	auipc	ra,0x3
    274c:	7fe080e7          	jalr	2046(ra) # 5f46 <printf>
=======
    2738:	567d                	li	a2,-1
    273a:	85a6                	mv	a1,s1
    273c:	00004517          	auipc	a0,0x4
    2740:	1ac50513          	addi	a0,a0,428 # 68e8 <malloc+0x932>
    2744:	00003097          	auipc	ra,0x3
    2748:	7ba080e7          	jalr	1978(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    274c:	4505                	li	a0,1
    274e:	00003097          	auipc	ra,0x3
    2752:	440080e7          	jalr	1088(ra) # 5b8e <exit>

0000000000002756 <rwsbrk>:
{
    2756:	1101                	addi	sp,sp,-32
    2758:	ec06                	sd	ra,24(sp)
    275a:	e822                	sd	s0,16(sp)
    275c:	e426                	sd	s1,8(sp)
    275e:	e04a                	sd	s2,0(sp)
    2760:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2762:	6509                	lui	a0,0x2
    2764:	00003097          	auipc	ra,0x3
    2768:	4b2080e7          	jalr	1202(ra) # 5c16 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    276c:	57fd                	li	a5,-1
    276e:	06f50263          	beq	a0,a5,27d2 <rwsbrk+0x7c>
    2772:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2774:	7579                	lui	a0,0xffffe
    2776:	00003097          	auipc	ra,0x3
    277a:	4a0080e7          	jalr	1184(ra) # 5c16 <sbrk>
    277e:	57fd                	li	a5,-1
    2780:	06f50663          	beq	a0,a5,27ec <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
<<<<<<< HEAD
    2788:	20100593          	li	a1,513
    278c:	00004517          	auipc	a0,0x4
    2790:	6fc50513          	addi	a0,a0,1788 # 6e88 <malloc+0xe84>
    2794:	00003097          	auipc	ra,0x3
    2798:	472080e7          	jalr	1138(ra) # 5c06 <open>
    279c:	892a                	mv	s2,a0
=======
    2784:	20100593          	li	a1,513
    2788:	00004517          	auipc	a0,0x4
    278c:	69050513          	addi	a0,a0,1680 # 6e18 <malloc+0xe62>
    2790:	00003097          	auipc	ra,0x3
    2794:	43e080e7          	jalr	1086(ra) # 5bce <open>
    2798:	892a                	mv	s2,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    279a:	06054663          	bltz	a0,2806 <rwsbrk+0xb0>
  n = write(fd, (void*)(a+4096), 1024);
    279e:	6785                	lui	a5,0x1
    27a0:	94be                	add	s1,s1,a5
    27a2:	40000613          	li	a2,1024
    27a6:	85a6                	mv	a1,s1
    27a8:	00003097          	auipc	ra,0x3
    27ac:	406080e7          	jalr	1030(ra) # 5bae <write>
    27b0:	862a                	mv	a2,a0
  if(n >= 0){
    27b2:	06054763          	bltz	a0,2820 <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
<<<<<<< HEAD
    27bc:	85a6                	mv	a1,s1
    27be:	00004517          	auipc	a0,0x4
    27c2:	6ea50513          	addi	a0,a0,1770 # 6ea8 <malloc+0xea4>
    27c6:	00003097          	auipc	ra,0x3
    27ca:	780080e7          	jalr	1920(ra) # 5f46 <printf>
=======
    27b6:	85a6                	mv	a1,s1
    27b8:	00004517          	auipc	a0,0x4
    27bc:	68050513          	addi	a0,a0,1664 # 6e38 <malloc+0xe82>
    27c0:	00003097          	auipc	ra,0x3
    27c4:	73e080e7          	jalr	1854(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    27c8:	4505                	li	a0,1
    27ca:	00003097          	auipc	ra,0x3
    27ce:	3c4080e7          	jalr	964(ra) # 5b8e <exit>
    printf("sbrk(rwsbrk) failed\n");
<<<<<<< HEAD
    27d8:	00004517          	auipc	a0,0x4
    27dc:	67850513          	addi	a0,a0,1656 # 6e50 <malloc+0xe4c>
    27e0:	00003097          	auipc	ra,0x3
    27e4:	766080e7          	jalr	1894(ra) # 5f46 <printf>
=======
    27d2:	00004517          	auipc	a0,0x4
    27d6:	60e50513          	addi	a0,a0,1550 # 6de0 <malloc+0xe2a>
    27da:	00003097          	auipc	ra,0x3
    27de:	724080e7          	jalr	1828(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    27e2:	4505                	li	a0,1
    27e4:	00003097          	auipc	ra,0x3
    27e8:	3aa080e7          	jalr	938(ra) # 5b8e <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
<<<<<<< HEAD
    27f2:	00004517          	auipc	a0,0x4
    27f6:	67650513          	addi	a0,a0,1654 # 6e68 <malloc+0xe64>
    27fa:	00003097          	auipc	ra,0x3
    27fe:	74c080e7          	jalr	1868(ra) # 5f46 <printf>
=======
    27ec:	00004517          	auipc	a0,0x4
    27f0:	60c50513          	addi	a0,a0,1548 # 6df8 <malloc+0xe42>
    27f4:	00003097          	auipc	ra,0x3
    27f8:	70a080e7          	jalr	1802(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    27fc:	4505                	li	a0,1
    27fe:	00003097          	auipc	ra,0x3
    2802:	390080e7          	jalr	912(ra) # 5b8e <exit>
    printf("open(rwsbrk) failed\n");
<<<<<<< HEAD
    280c:	00004517          	auipc	a0,0x4
    2810:	68450513          	addi	a0,a0,1668 # 6e90 <malloc+0xe8c>
    2814:	00003097          	auipc	ra,0x3
    2818:	732080e7          	jalr	1842(ra) # 5f46 <printf>
=======
    2806:	00004517          	auipc	a0,0x4
    280a:	61a50513          	addi	a0,a0,1562 # 6e20 <malloc+0xe6a>
    280e:	00003097          	auipc	ra,0x3
    2812:	6f0080e7          	jalr	1776(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2816:	4505                	li	a0,1
    2818:	00003097          	auipc	ra,0x3
    281c:	376080e7          	jalr	886(ra) # 5b8e <exit>
  close(fd);
    2820:	854a                	mv	a0,s2
    2822:	00003097          	auipc	ra,0x3
    2826:	394080e7          	jalr	916(ra) # 5bb6 <close>
  unlink("rwsbrk");
<<<<<<< HEAD
    2830:	00004517          	auipc	a0,0x4
    2834:	65850513          	addi	a0,a0,1624 # 6e88 <malloc+0xe84>
    2838:	00003097          	auipc	ra,0x3
    283c:	3de080e7          	jalr	990(ra) # 5c16 <unlink>
  fd = open("README", O_RDONLY);
    2840:	4581                	li	a1,0
    2842:	00004517          	auipc	a0,0x4
    2846:	ade50513          	addi	a0,a0,-1314 # 6320 <malloc+0x31c>
    284a:	00003097          	auipc	ra,0x3
    284e:	3bc080e7          	jalr	956(ra) # 5c06 <open>
    2852:	892a                	mv	s2,a0
=======
    282a:	00004517          	auipc	a0,0x4
    282e:	5ee50513          	addi	a0,a0,1518 # 6e18 <malloc+0xe62>
    2832:	00003097          	auipc	ra,0x3
    2836:	3ac080e7          	jalr	940(ra) # 5bde <unlink>
  fd = open("README", O_RDONLY);
    283a:	4581                	li	a1,0
    283c:	00004517          	auipc	a0,0x4
    2840:	a7450513          	addi	a0,a0,-1420 # 62b0 <malloc+0x2fa>
    2844:	00003097          	auipc	ra,0x3
    2848:	38a080e7          	jalr	906(ra) # 5bce <open>
    284c:	892a                	mv	s2,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    284e:	02054963          	bltz	a0,2880 <rwsbrk+0x12a>
  n = read(fd, (void*)(a+4096), 10);
    2852:	4629                	li	a2,10
    2854:	85a6                	mv	a1,s1
    2856:	00003097          	auipc	ra,0x3
    285a:	350080e7          	jalr	848(ra) # 5ba6 <read>
    285e:	862a                	mv	a2,a0
  if(n >= 0){
    2860:	02054d63          	bltz	a0,289a <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
<<<<<<< HEAD
    286a:	85a6                	mv	a1,s1
    286c:	00004517          	auipc	a0,0x4
    2870:	66c50513          	addi	a0,a0,1644 # 6ed8 <malloc+0xed4>
    2874:	00003097          	auipc	ra,0x3
    2878:	6d2080e7          	jalr	1746(ra) # 5f46 <printf>
=======
    2864:	85a6                	mv	a1,s1
    2866:	00004517          	auipc	a0,0x4
    286a:	60250513          	addi	a0,a0,1538 # 6e68 <malloc+0xeb2>
    286e:	00003097          	auipc	ra,0x3
    2872:	690080e7          	jalr	1680(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2876:	4505                	li	a0,1
    2878:	00003097          	auipc	ra,0x3
    287c:	316080e7          	jalr	790(ra) # 5b8e <exit>
    printf("open(rwsbrk) failed\n");
<<<<<<< HEAD
    2886:	00004517          	auipc	a0,0x4
    288a:	60a50513          	addi	a0,a0,1546 # 6e90 <malloc+0xe8c>
    288e:	00003097          	auipc	ra,0x3
    2892:	6b8080e7          	jalr	1720(ra) # 5f46 <printf>
=======
    2880:	00004517          	auipc	a0,0x4
    2884:	5a050513          	addi	a0,a0,1440 # 6e20 <malloc+0xe6a>
    2888:	00003097          	auipc	ra,0x3
    288c:	676080e7          	jalr	1654(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2890:	4505                	li	a0,1
    2892:	00003097          	auipc	ra,0x3
    2896:	2fc080e7          	jalr	764(ra) # 5b8e <exit>
  close(fd);
    289a:	854a                	mv	a0,s2
    289c:	00003097          	auipc	ra,0x3
    28a0:	31a080e7          	jalr	794(ra) # 5bb6 <close>
  exit(0);
    28a4:	4501                	li	a0,0
    28a6:	00003097          	auipc	ra,0x3
    28aa:	2e8080e7          	jalr	744(ra) # 5b8e <exit>

00000000000028ae <sbrkbasic>:
{
    28ae:	7139                	addi	sp,sp,-64
    28b0:	fc06                	sd	ra,56(sp)
    28b2:	f822                	sd	s0,48(sp)
    28b4:	f426                	sd	s1,40(sp)
    28b6:	f04a                	sd	s2,32(sp)
    28b8:	ec4e                	sd	s3,24(sp)
    28ba:	e852                	sd	s4,16(sp)
    28bc:	0080                	addi	s0,sp,64
    28be:	8a2a                	mv	s4,a0
  pid = fork();
    28c0:	00003097          	auipc	ra,0x3
    28c4:	2c6080e7          	jalr	710(ra) # 5b86 <fork>
  if(pid < 0){
    28c8:	02054c63          	bltz	a0,2900 <sbrkbasic+0x52>
  if(pid == 0){
    28cc:	ed21                	bnez	a0,2924 <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    28ce:	40000537          	lui	a0,0x40000
    28d2:	00003097          	auipc	ra,0x3
    28d6:	344080e7          	jalr	836(ra) # 5c16 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    28da:	57fd                	li	a5,-1
    28dc:	02f50f63          	beq	a0,a5,291a <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    28e0:	400007b7          	lui	a5,0x40000
    28e4:	97aa                	add	a5,a5,a0
      *b = 99;
    28e6:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    28ea:	6705                	lui	a4,0x1
      *b = 99;
    28ec:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for(b = a; b < a+TOOMUCH; b += 4096){
    28f0:	953a                	add	a0,a0,a4
    28f2:	fef51de3          	bne	a0,a5,28ec <sbrkbasic+0x3e>
    exit(1);
    28f6:	4505                	li	a0,1
    28f8:	00003097          	auipc	ra,0x3
    28fc:	296080e7          	jalr	662(ra) # 5b8e <exit>
    printf("fork failed in sbrkbasic\n");
<<<<<<< HEAD
    2906:	00004517          	auipc	a0,0x4
    290a:	5fa50513          	addi	a0,a0,1530 # 6f00 <malloc+0xefc>
    290e:	00003097          	auipc	ra,0x3
    2912:	638080e7          	jalr	1592(ra) # 5f46 <printf>
=======
    2900:	00004517          	auipc	a0,0x4
    2904:	59050513          	addi	a0,a0,1424 # 6e90 <malloc+0xeda>
    2908:	00003097          	auipc	ra,0x3
    290c:	5f6080e7          	jalr	1526(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2910:	4505                	li	a0,1
    2912:	00003097          	auipc	ra,0x3
    2916:	27c080e7          	jalr	636(ra) # 5b8e <exit>
      exit(0);
    291a:	4501                	li	a0,0
    291c:	00003097          	auipc	ra,0x3
    2920:	272080e7          	jalr	626(ra) # 5b8e <exit>
  wait(&xstatus);
    2924:	fcc40513          	addi	a0,s0,-52
    2928:	00003097          	auipc	ra,0x3
    292c:	26e080e7          	jalr	622(ra) # 5b96 <wait>
  if(xstatus == 1){
    2930:	fcc42703          	lw	a4,-52(s0)
    2934:	4785                	li	a5,1
    2936:	00f70d63          	beq	a4,a5,2950 <sbrkbasic+0xa2>
  a = sbrk(0);
    293a:	4501                	li	a0,0
    293c:	00003097          	auipc	ra,0x3
    2940:	2da080e7          	jalr	730(ra) # 5c16 <sbrk>
    2944:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2946:	4901                	li	s2,0
    2948:	6985                	lui	s3,0x1
    294a:	38898993          	addi	s3,s3,904 # 1388 <badarg+0x3e>
    294e:	a005                	j	296e <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
<<<<<<< HEAD
    2956:	85d2                	mv	a1,s4
    2958:	00004517          	auipc	a0,0x4
    295c:	5c850513          	addi	a0,a0,1480 # 6f20 <malloc+0xf1c>
    2960:	00003097          	auipc	ra,0x3
    2964:	5e6080e7          	jalr	1510(ra) # 5f46 <printf>
=======
    2950:	85d2                	mv	a1,s4
    2952:	00004517          	auipc	a0,0x4
    2956:	55e50513          	addi	a0,a0,1374 # 6eb0 <malloc+0xefa>
    295a:	00003097          	auipc	ra,0x3
    295e:	5a4080e7          	jalr	1444(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2962:	4505                	li	a0,1
    2964:	00003097          	auipc	ra,0x3
    2968:	22a080e7          	jalr	554(ra) # 5b8e <exit>
    a = b + 1;
    296c:	84be                	mv	s1,a5
    b = sbrk(1);
    296e:	4505                	li	a0,1
    2970:	00003097          	auipc	ra,0x3
    2974:	2a6080e7          	jalr	678(ra) # 5c16 <sbrk>
    if(b != a){
    2978:	04951c63          	bne	a0,s1,29d0 <sbrkbasic+0x122>
    *b = 1;
    297c:	4785                	li	a5,1
    297e:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2982:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2986:	2905                	addiw	s2,s2,1
    2988:	ff3912e3          	bne	s2,s3,296c <sbrkbasic+0xbe>
  pid = fork();
    298c:	00003097          	auipc	ra,0x3
    2990:	1fa080e7          	jalr	506(ra) # 5b86 <fork>
    2994:	892a                	mv	s2,a0
  if(pid < 0){
    2996:	04054e63          	bltz	a0,29f2 <sbrkbasic+0x144>
  c = sbrk(1);
    299a:	4505                	li	a0,1
    299c:	00003097          	auipc	ra,0x3
    29a0:	27a080e7          	jalr	634(ra) # 5c16 <sbrk>
  c = sbrk(1);
    29a4:	4505                	li	a0,1
    29a6:	00003097          	auipc	ra,0x3
    29aa:	270080e7          	jalr	624(ra) # 5c16 <sbrk>
  if(c != a + 1){
    29ae:	0489                	addi	s1,s1,2
    29b0:	04a48f63          	beq	s1,a0,2a0e <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
<<<<<<< HEAD
    29ba:	85d2                	mv	a1,s4
    29bc:	00004517          	auipc	a0,0x4
    29c0:	5c450513          	addi	a0,a0,1476 # 6f80 <malloc+0xf7c>
    29c4:	00003097          	auipc	ra,0x3
    29c8:	582080e7          	jalr	1410(ra) # 5f46 <printf>
=======
    29b4:	85d2                	mv	a1,s4
    29b6:	00004517          	auipc	a0,0x4
    29ba:	55a50513          	addi	a0,a0,1370 # 6f10 <malloc+0xf5a>
    29be:	00003097          	auipc	ra,0x3
    29c2:	540080e7          	jalr	1344(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    29c6:	4505                	li	a0,1
    29c8:	00003097          	auipc	ra,0x3
    29cc:	1c6080e7          	jalr	454(ra) # 5b8e <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
<<<<<<< HEAD
    29d6:	872a                	mv	a4,a0
    29d8:	86a6                	mv	a3,s1
    29da:	864a                	mv	a2,s2
    29dc:	85d2                	mv	a1,s4
    29de:	00004517          	auipc	a0,0x4
    29e2:	56250513          	addi	a0,a0,1378 # 6f40 <malloc+0xf3c>
    29e6:	00003097          	auipc	ra,0x3
    29ea:	560080e7          	jalr	1376(ra) # 5f46 <printf>
=======
    29d0:	872a                	mv	a4,a0
    29d2:	86a6                	mv	a3,s1
    29d4:	864a                	mv	a2,s2
    29d6:	85d2                	mv	a1,s4
    29d8:	00004517          	auipc	a0,0x4
    29dc:	4f850513          	addi	a0,a0,1272 # 6ed0 <malloc+0xf1a>
    29e0:	00003097          	auipc	ra,0x3
    29e4:	51e080e7          	jalr	1310(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    29e8:	4505                	li	a0,1
    29ea:	00003097          	auipc	ra,0x3
    29ee:	1a4080e7          	jalr	420(ra) # 5b8e <exit>
    printf("%s: sbrk test fork failed\n", s);
<<<<<<< HEAD
    29f8:	85d2                	mv	a1,s4
    29fa:	00004517          	auipc	a0,0x4
    29fe:	56650513          	addi	a0,a0,1382 # 6f60 <malloc+0xf5c>
    2a02:	00003097          	auipc	ra,0x3
    2a06:	544080e7          	jalr	1348(ra) # 5f46 <printf>
=======
    29f2:	85d2                	mv	a1,s4
    29f4:	00004517          	auipc	a0,0x4
    29f8:	4fc50513          	addi	a0,a0,1276 # 6ef0 <malloc+0xf3a>
    29fc:	00003097          	auipc	ra,0x3
    2a00:	502080e7          	jalr	1282(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2a04:	4505                	li	a0,1
    2a06:	00003097          	auipc	ra,0x3
    2a0a:	188080e7          	jalr	392(ra) # 5b8e <exit>
  if(pid == 0)
    2a0e:	00091763          	bnez	s2,2a1c <sbrkbasic+0x16e>
    exit(0);
    2a12:	4501                	li	a0,0
    2a14:	00003097          	auipc	ra,0x3
    2a18:	17a080e7          	jalr	378(ra) # 5b8e <exit>
  wait(&xstatus);
    2a1c:	fcc40513          	addi	a0,s0,-52
    2a20:	00003097          	auipc	ra,0x3
    2a24:	176080e7          	jalr	374(ra) # 5b96 <wait>
  exit(xstatus);
    2a28:	fcc42503          	lw	a0,-52(s0)
    2a2c:	00003097          	auipc	ra,0x3
    2a30:	162080e7          	jalr	354(ra) # 5b8e <exit>

0000000000002a34 <sbrkmuch>:
{
    2a34:	7179                	addi	sp,sp,-48
    2a36:	f406                	sd	ra,40(sp)
    2a38:	f022                	sd	s0,32(sp)
    2a3a:	ec26                	sd	s1,24(sp)
    2a3c:	e84a                	sd	s2,16(sp)
    2a3e:	e44e                	sd	s3,8(sp)
    2a40:	e052                	sd	s4,0(sp)
    2a42:	1800                	addi	s0,sp,48
    2a44:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2a46:	4501                	li	a0,0
    2a48:	00003097          	auipc	ra,0x3
    2a4c:	1ce080e7          	jalr	462(ra) # 5c16 <sbrk>
    2a50:	892a                	mv	s2,a0
  a = sbrk(0);
    2a52:	4501                	li	a0,0
    2a54:	00003097          	auipc	ra,0x3
    2a58:	1c2080e7          	jalr	450(ra) # 5c16 <sbrk>
    2a5c:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2a5e:	06400537          	lui	a0,0x6400
    2a62:	9d05                	subw	a0,a0,s1
    2a64:	00003097          	auipc	ra,0x3
    2a68:	1b2080e7          	jalr	434(ra) # 5c16 <sbrk>
  if (p != a) {
    2a6c:	0ca49863          	bne	s1,a0,2b3c <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2a70:	4501                	li	a0,0
    2a72:	00003097          	auipc	ra,0x3
    2a76:	1a4080e7          	jalr	420(ra) # 5c16 <sbrk>
    2a7a:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2a7c:	00a4f963          	bgeu	s1,a0,2a8e <sbrkmuch+0x5a>
    *pp = 1;
    2a80:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2a82:	6705                	lui	a4,0x1
    *pp = 1;
    2a84:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2a88:	94ba                	add	s1,s1,a4
    2a8a:	fef4ede3          	bltu	s1,a5,2a84 <sbrkmuch+0x50>
  *lastaddr = 99;
    2a8e:	064007b7          	lui	a5,0x6400
    2a92:	06300713          	li	a4,99
    2a96:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2a9a:	4501                	li	a0,0
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	17a080e7          	jalr	378(ra) # 5c16 <sbrk>
    2aa4:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2aa6:	757d                	lui	a0,0xfffff
    2aa8:	00003097          	auipc	ra,0x3
    2aac:	16e080e7          	jalr	366(ra) # 5c16 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2ab0:	57fd                	li	a5,-1
    2ab2:	0af50363          	beq	a0,a5,2b58 <sbrkmuch+0x124>
  c = sbrk(0);
    2ab6:	4501                	li	a0,0
    2ab8:	00003097          	auipc	ra,0x3
    2abc:	15e080e7          	jalr	350(ra) # 5c16 <sbrk>
  if(c != a - PGSIZE){
    2ac0:	77fd                	lui	a5,0xfffff
    2ac2:	97a6                	add	a5,a5,s1
    2ac4:	0af51863          	bne	a0,a5,2b74 <sbrkmuch+0x140>
  a = sbrk(0);
    2ac8:	4501                	li	a0,0
    2aca:	00003097          	auipc	ra,0x3
    2ace:	14c080e7          	jalr	332(ra) # 5c16 <sbrk>
    2ad2:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2ad4:	6505                	lui	a0,0x1
    2ad6:	00003097          	auipc	ra,0x3
    2ada:	140080e7          	jalr	320(ra) # 5c16 <sbrk>
    2ade:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2ae0:	0aa49a63          	bne	s1,a0,2b94 <sbrkmuch+0x160>
    2ae4:	4501                	li	a0,0
    2ae6:	00003097          	auipc	ra,0x3
    2aea:	130080e7          	jalr	304(ra) # 5c16 <sbrk>
    2aee:	6785                	lui	a5,0x1
    2af0:	97a6                	add	a5,a5,s1
    2af2:	0af51163          	bne	a0,a5,2b94 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2af6:	064007b7          	lui	a5,0x6400
    2afa:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2afe:	06300793          	li	a5,99
    2b02:	0af70963          	beq	a4,a5,2bb4 <sbrkmuch+0x180>
  a = sbrk(0);
    2b06:	4501                	li	a0,0
    2b08:	00003097          	auipc	ra,0x3
    2b0c:	10e080e7          	jalr	270(ra) # 5c16 <sbrk>
    2b10:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2b12:	4501                	li	a0,0
    2b14:	00003097          	auipc	ra,0x3
    2b18:	102080e7          	jalr	258(ra) # 5c16 <sbrk>
    2b1c:	40a9053b          	subw	a0,s2,a0
    2b20:	00003097          	auipc	ra,0x3
    2b24:	0f6080e7          	jalr	246(ra) # 5c16 <sbrk>
  if(c != a){
    2b28:	0aa49463          	bne	s1,a0,2bd0 <sbrkmuch+0x19c>
}
    2b2c:	70a2                	ld	ra,40(sp)
    2b2e:	7402                	ld	s0,32(sp)
    2b30:	64e2                	ld	s1,24(sp)
    2b32:	6942                	ld	s2,16(sp)
    2b34:	69a2                	ld	s3,8(sp)
    2b36:	6a02                	ld	s4,0(sp)
    2b38:	6145                	addi	sp,sp,48
    2b3a:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
<<<<<<< HEAD
    2b42:	85ce                	mv	a1,s3
    2b44:	00004517          	auipc	a0,0x4
    2b48:	45c50513          	addi	a0,a0,1116 # 6fa0 <malloc+0xf9c>
    2b4c:	00003097          	auipc	ra,0x3
    2b50:	3fa080e7          	jalr	1018(ra) # 5f46 <printf>
=======
    2b3c:	85ce                	mv	a1,s3
    2b3e:	00004517          	auipc	a0,0x4
    2b42:	3f250513          	addi	a0,a0,1010 # 6f30 <malloc+0xf7a>
    2b46:	00003097          	auipc	ra,0x3
    2b4a:	3b8080e7          	jalr	952(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2b4e:	4505                	li	a0,1
    2b50:	00003097          	auipc	ra,0x3
    2b54:	03e080e7          	jalr	62(ra) # 5b8e <exit>
    printf("%s: sbrk could not deallocate\n", s);
<<<<<<< HEAD
    2b5e:	85ce                	mv	a1,s3
    2b60:	00004517          	auipc	a0,0x4
    2b64:	48850513          	addi	a0,a0,1160 # 6fe8 <malloc+0xfe4>
    2b68:	00003097          	auipc	ra,0x3
    2b6c:	3de080e7          	jalr	990(ra) # 5f46 <printf>
=======
    2b58:	85ce                	mv	a1,s3
    2b5a:	00004517          	auipc	a0,0x4
    2b5e:	41e50513          	addi	a0,a0,1054 # 6f78 <malloc+0xfc2>
    2b62:	00003097          	auipc	ra,0x3
    2b66:	39c080e7          	jalr	924(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2b6a:	4505                	li	a0,1
    2b6c:	00003097          	auipc	ra,0x3
    2b70:	022080e7          	jalr	34(ra) # 5b8e <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
<<<<<<< HEAD
    2b7a:	86aa                	mv	a3,a0
    2b7c:	8626                	mv	a2,s1
    2b7e:	85ce                	mv	a1,s3
    2b80:	00004517          	auipc	a0,0x4
    2b84:	48850513          	addi	a0,a0,1160 # 7008 <malloc+0x1004>
    2b88:	00003097          	auipc	ra,0x3
    2b8c:	3be080e7          	jalr	958(ra) # 5f46 <printf>
=======
    2b74:	86aa                	mv	a3,a0
    2b76:	8626                	mv	a2,s1
    2b78:	85ce                	mv	a1,s3
    2b7a:	00004517          	auipc	a0,0x4
    2b7e:	41e50513          	addi	a0,a0,1054 # 6f98 <malloc+0xfe2>
    2b82:	00003097          	auipc	ra,0x3
    2b86:	37c080e7          	jalr	892(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2b8a:	4505                	li	a0,1
    2b8c:	00003097          	auipc	ra,0x3
    2b90:	002080e7          	jalr	2(ra) # 5b8e <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
<<<<<<< HEAD
    2b9a:	86d2                	mv	a3,s4
    2b9c:	8626                	mv	a2,s1
    2b9e:	85ce                	mv	a1,s3
    2ba0:	00004517          	auipc	a0,0x4
    2ba4:	4a850513          	addi	a0,a0,1192 # 7048 <malloc+0x1044>
    2ba8:	00003097          	auipc	ra,0x3
    2bac:	39e080e7          	jalr	926(ra) # 5f46 <printf>
=======
    2b94:	86d2                	mv	a3,s4
    2b96:	8626                	mv	a2,s1
    2b98:	85ce                	mv	a1,s3
    2b9a:	00004517          	auipc	a0,0x4
    2b9e:	43e50513          	addi	a0,a0,1086 # 6fd8 <malloc+0x1022>
    2ba2:	00003097          	auipc	ra,0x3
    2ba6:	35c080e7          	jalr	860(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2baa:	4505                	li	a0,1
    2bac:	00003097          	auipc	ra,0x3
    2bb0:	fe2080e7          	jalr	-30(ra) # 5b8e <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
<<<<<<< HEAD
    2bba:	85ce                	mv	a1,s3
    2bbc:	00004517          	auipc	a0,0x4
    2bc0:	4bc50513          	addi	a0,a0,1212 # 7078 <malloc+0x1074>
    2bc4:	00003097          	auipc	ra,0x3
    2bc8:	382080e7          	jalr	898(ra) # 5f46 <printf>
=======
    2bb4:	85ce                	mv	a1,s3
    2bb6:	00004517          	auipc	a0,0x4
    2bba:	45250513          	addi	a0,a0,1106 # 7008 <malloc+0x1052>
    2bbe:	00003097          	auipc	ra,0x3
    2bc2:	340080e7          	jalr	832(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2bc6:	4505                	li	a0,1
    2bc8:	00003097          	auipc	ra,0x3
    2bcc:	fc6080e7          	jalr	-58(ra) # 5b8e <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
<<<<<<< HEAD
    2bd6:	86aa                	mv	a3,a0
    2bd8:	8626                	mv	a2,s1
    2bda:	85ce                	mv	a1,s3
    2bdc:	00004517          	auipc	a0,0x4
    2be0:	4d450513          	addi	a0,a0,1236 # 70b0 <malloc+0x10ac>
    2be4:	00003097          	auipc	ra,0x3
    2be8:	362080e7          	jalr	866(ra) # 5f46 <printf>
=======
    2bd0:	86aa                	mv	a3,a0
    2bd2:	8626                	mv	a2,s1
    2bd4:	85ce                	mv	a1,s3
    2bd6:	00004517          	auipc	a0,0x4
    2bda:	46a50513          	addi	a0,a0,1130 # 7040 <malloc+0x108a>
    2bde:	00003097          	auipc	ra,0x3
    2be2:	320080e7          	jalr	800(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2be6:	4505                	li	a0,1
    2be8:	00003097          	auipc	ra,0x3
    2bec:	fa6080e7          	jalr	-90(ra) # 5b8e <exit>

0000000000002bf0 <sbrkarg>:
{
    2bf0:	7179                	addi	sp,sp,-48
    2bf2:	f406                	sd	ra,40(sp)
    2bf4:	f022                	sd	s0,32(sp)
    2bf6:	ec26                	sd	s1,24(sp)
    2bf8:	e84a                	sd	s2,16(sp)
    2bfa:	e44e                	sd	s3,8(sp)
    2bfc:	1800                	addi	s0,sp,48
    2bfe:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2c00:	6505                	lui	a0,0x1
    2c02:	00003097          	auipc	ra,0x3
    2c06:	014080e7          	jalr	20(ra) # 5c16 <sbrk>
    2c0a:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
<<<<<<< HEAD
    2c12:	20100593          	li	a1,513
    2c16:	00004517          	auipc	a0,0x4
    2c1a:	4c250513          	addi	a0,a0,1218 # 70d8 <malloc+0x10d4>
    2c1e:	00003097          	auipc	ra,0x3
    2c22:	fe8080e7          	jalr	-24(ra) # 5c06 <open>
    2c26:	84aa                	mv	s1,a0
  unlink("sbrk");
    2c28:	00004517          	auipc	a0,0x4
    2c2c:	4b050513          	addi	a0,a0,1200 # 70d8 <malloc+0x10d4>
    2c30:	00003097          	auipc	ra,0x3
    2c34:	fe6080e7          	jalr	-26(ra) # 5c16 <unlink>
=======
    2c0c:	20100593          	li	a1,513
    2c10:	00004517          	auipc	a0,0x4
    2c14:	45850513          	addi	a0,a0,1112 # 7068 <malloc+0x10b2>
    2c18:	00003097          	auipc	ra,0x3
    2c1c:	fb6080e7          	jalr	-74(ra) # 5bce <open>
    2c20:	84aa                	mv	s1,a0
  unlink("sbrk");
    2c22:	00004517          	auipc	a0,0x4
    2c26:	44650513          	addi	a0,a0,1094 # 7068 <malloc+0x10b2>
    2c2a:	00003097          	auipc	ra,0x3
    2c2e:	fb4080e7          	jalr	-76(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0)  {
    2c32:	0404c163          	bltz	s1,2c74 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2c36:	6605                	lui	a2,0x1
    2c38:	85ca                	mv	a1,s2
    2c3a:	8526                	mv	a0,s1
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	f72080e7          	jalr	-142(ra) # 5bae <write>
    2c44:	04054663          	bltz	a0,2c90 <sbrkarg+0xa0>
  close(fd);
    2c48:	8526                	mv	a0,s1
    2c4a:	00003097          	auipc	ra,0x3
    2c4e:	f6c080e7          	jalr	-148(ra) # 5bb6 <close>
  a = sbrk(PGSIZE);
    2c52:	6505                	lui	a0,0x1
    2c54:	00003097          	auipc	ra,0x3
    2c58:	fc2080e7          	jalr	-62(ra) # 5c16 <sbrk>
  if(pipe((int *) a) != 0){
    2c5c:	00003097          	auipc	ra,0x3
    2c60:	f42080e7          	jalr	-190(ra) # 5b9e <pipe>
    2c64:	e521                	bnez	a0,2cac <sbrkarg+0xbc>
}
    2c66:	70a2                	ld	ra,40(sp)
    2c68:	7402                	ld	s0,32(sp)
    2c6a:	64e2                	ld	s1,24(sp)
    2c6c:	6942                	ld	s2,16(sp)
    2c6e:	69a2                	ld	s3,8(sp)
    2c70:	6145                	addi	sp,sp,48
    2c72:	8082                	ret
    printf("%s: open sbrk failed\n", s);
<<<<<<< HEAD
    2c7a:	85ce                	mv	a1,s3
    2c7c:	00004517          	auipc	a0,0x4
    2c80:	46450513          	addi	a0,a0,1124 # 70e0 <malloc+0x10dc>
    2c84:	00003097          	auipc	ra,0x3
    2c88:	2c2080e7          	jalr	706(ra) # 5f46 <printf>
=======
    2c74:	85ce                	mv	a1,s3
    2c76:	00004517          	auipc	a0,0x4
    2c7a:	3fa50513          	addi	a0,a0,1018 # 7070 <malloc+0x10ba>
    2c7e:	00003097          	auipc	ra,0x3
    2c82:	280080e7          	jalr	640(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2c86:	4505                	li	a0,1
    2c88:	00003097          	auipc	ra,0x3
    2c8c:	f06080e7          	jalr	-250(ra) # 5b8e <exit>
    printf("%s: write sbrk failed\n", s);
<<<<<<< HEAD
    2c96:	85ce                	mv	a1,s3
    2c98:	00004517          	auipc	a0,0x4
    2c9c:	46050513          	addi	a0,a0,1120 # 70f8 <malloc+0x10f4>
    2ca0:	00003097          	auipc	ra,0x3
    2ca4:	2a6080e7          	jalr	678(ra) # 5f46 <printf>
=======
    2c90:	85ce                	mv	a1,s3
    2c92:	00004517          	auipc	a0,0x4
    2c96:	3f650513          	addi	a0,a0,1014 # 7088 <malloc+0x10d2>
    2c9a:	00003097          	auipc	ra,0x3
    2c9e:	264080e7          	jalr	612(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2ca2:	4505                	li	a0,1
    2ca4:	00003097          	auipc	ra,0x3
    2ca8:	eea080e7          	jalr	-278(ra) # 5b8e <exit>
    printf("%s: pipe() failed\n", s);
<<<<<<< HEAD
    2cb2:	85ce                	mv	a1,s3
    2cb4:	00004517          	auipc	a0,0x4
    2cb8:	e2450513          	addi	a0,a0,-476 # 6ad8 <malloc+0xad4>
    2cbc:	00003097          	auipc	ra,0x3
    2cc0:	28a080e7          	jalr	650(ra) # 5f46 <printf>
=======
    2cac:	85ce                	mv	a1,s3
    2cae:	00004517          	auipc	a0,0x4
    2cb2:	dba50513          	addi	a0,a0,-582 # 6a68 <malloc+0xab2>
    2cb6:	00003097          	auipc	ra,0x3
    2cba:	248080e7          	jalr	584(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2cbe:	4505                	li	a0,1
    2cc0:	00003097          	auipc	ra,0x3
    2cc4:	ece080e7          	jalr	-306(ra) # 5b8e <exit>

0000000000002cc8 <argptest>:
{
    2cc8:	1101                	addi	sp,sp,-32
    2cca:	ec06                	sd	ra,24(sp)
    2ccc:	e822                	sd	s0,16(sp)
    2cce:	e426                	sd	s1,8(sp)
    2cd0:	e04a                	sd	s2,0(sp)
    2cd2:	1000                	addi	s0,sp,32
    2cd4:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
<<<<<<< HEAD
    2cdc:	4581                	li	a1,0
    2cde:	00004517          	auipc	a0,0x4
    2ce2:	43250513          	addi	a0,a0,1074 # 7110 <malloc+0x110c>
    2ce6:	00003097          	auipc	ra,0x3
    2cea:	f20080e7          	jalr	-224(ra) # 5c06 <open>
=======
    2cd6:	4581                	li	a1,0
    2cd8:	00004517          	auipc	a0,0x4
    2cdc:	3c850513          	addi	a0,a0,968 # 70a0 <malloc+0x10ea>
    2ce0:	00003097          	auipc	ra,0x3
    2ce4:	eee080e7          	jalr	-274(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if (fd < 0) {
    2ce8:	02054b63          	bltz	a0,2d1e <argptest+0x56>
    2cec:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2cee:	4501                	li	a0,0
    2cf0:	00003097          	auipc	ra,0x3
    2cf4:	f26080e7          	jalr	-218(ra) # 5c16 <sbrk>
    2cf8:	567d                	li	a2,-1
    2cfa:	fff50593          	addi	a1,a0,-1
    2cfe:	8526                	mv	a0,s1
    2d00:	00003097          	auipc	ra,0x3
    2d04:	ea6080e7          	jalr	-346(ra) # 5ba6 <read>
  close(fd);
    2d08:	8526                	mv	a0,s1
    2d0a:	00003097          	auipc	ra,0x3
    2d0e:	eac080e7          	jalr	-340(ra) # 5bb6 <close>
}
    2d12:	60e2                	ld	ra,24(sp)
    2d14:	6442                	ld	s0,16(sp)
    2d16:	64a2                	ld	s1,8(sp)
    2d18:	6902                	ld	s2,0(sp)
    2d1a:	6105                	addi	sp,sp,32
    2d1c:	8082                	ret
    printf("%s: open failed\n", s);
<<<<<<< HEAD
    2d24:	85ca                	mv	a1,s2
    2d26:	00004517          	auipc	a0,0x4
    2d2a:	cc250513          	addi	a0,a0,-830 # 69e8 <malloc+0x9e4>
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	218080e7          	jalr	536(ra) # 5f46 <printf>
=======
    2d1e:	85ca                	mv	a1,s2
    2d20:	00004517          	auipc	a0,0x4
    2d24:	c5850513          	addi	a0,a0,-936 # 6978 <malloc+0x9c2>
    2d28:	00003097          	auipc	ra,0x3
    2d2c:	1d6080e7          	jalr	470(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2d30:	4505                	li	a0,1
    2d32:	00003097          	auipc	ra,0x3
    2d36:	e5c080e7          	jalr	-420(ra) # 5b8e <exit>

0000000000002d3a <sbrkbugs>:
{
    2d3a:	1141                	addi	sp,sp,-16
    2d3c:	e406                	sd	ra,8(sp)
    2d3e:	e022                	sd	s0,0(sp)
    2d40:	0800                	addi	s0,sp,16
  int pid = fork();
    2d42:	00003097          	auipc	ra,0x3
    2d46:	e44080e7          	jalr	-444(ra) # 5b86 <fork>
  if(pid < 0){
    2d4a:	02054263          	bltz	a0,2d6e <sbrkbugs+0x34>
  if(pid == 0){
    2d4e:	ed0d                	bnez	a0,2d88 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2d50:	00003097          	auipc	ra,0x3
    2d54:	ec6080e7          	jalr	-314(ra) # 5c16 <sbrk>
    sbrk(-sz);
    2d58:	40a0053b          	negw	a0,a0
    2d5c:	00003097          	auipc	ra,0x3
    2d60:	eba080e7          	jalr	-326(ra) # 5c16 <sbrk>
    exit(0);
    2d64:	4501                	li	a0,0
    2d66:	00003097          	auipc	ra,0x3
    2d6a:	e28080e7          	jalr	-472(ra) # 5b8e <exit>
    printf("fork failed\n");
<<<<<<< HEAD
    2d74:	00004517          	auipc	a0,0x4
    2d78:	06450513          	addi	a0,a0,100 # 6dd8 <malloc+0xdd4>
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	1ca080e7          	jalr	458(ra) # 5f46 <printf>
=======
    2d6e:	00004517          	auipc	a0,0x4
    2d72:	ffa50513          	addi	a0,a0,-6 # 6d68 <malloc+0xdb2>
    2d76:	00003097          	auipc	ra,0x3
    2d7a:	188080e7          	jalr	392(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2d7e:	4505                	li	a0,1
    2d80:	00003097          	auipc	ra,0x3
    2d84:	e0e080e7          	jalr	-498(ra) # 5b8e <exit>
  wait(0);
    2d88:	4501                	li	a0,0
    2d8a:	00003097          	auipc	ra,0x3
    2d8e:	e0c080e7          	jalr	-500(ra) # 5b96 <wait>
  pid = fork();
    2d92:	00003097          	auipc	ra,0x3
    2d96:	df4080e7          	jalr	-524(ra) # 5b86 <fork>
  if(pid < 0){
    2d9a:	02054563          	bltz	a0,2dc4 <sbrkbugs+0x8a>
  if(pid == 0){
    2d9e:	e121                	bnez	a0,2dde <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2da0:	00003097          	auipc	ra,0x3
    2da4:	e76080e7          	jalr	-394(ra) # 5c16 <sbrk>
    sbrk(-(sz - 3500));
    2da8:	6785                	lui	a5,0x1
    2daa:	dac7879b          	addiw	a5,a5,-596 # dac <unlinkread+0x6e>
    2dae:	40a7853b          	subw	a0,a5,a0
    2db2:	00003097          	auipc	ra,0x3
    2db6:	e64080e7          	jalr	-412(ra) # 5c16 <sbrk>
    exit(0);
    2dba:	4501                	li	a0,0
    2dbc:	00003097          	auipc	ra,0x3
    2dc0:	dd2080e7          	jalr	-558(ra) # 5b8e <exit>
    printf("fork failed\n");
<<<<<<< HEAD
    2dca:	00004517          	auipc	a0,0x4
    2dce:	00e50513          	addi	a0,a0,14 # 6dd8 <malloc+0xdd4>
    2dd2:	00003097          	auipc	ra,0x3
    2dd6:	174080e7          	jalr	372(ra) # 5f46 <printf>
=======
    2dc4:	00004517          	auipc	a0,0x4
    2dc8:	fa450513          	addi	a0,a0,-92 # 6d68 <malloc+0xdb2>
    2dcc:	00003097          	auipc	ra,0x3
    2dd0:	132080e7          	jalr	306(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2dd4:	4505                	li	a0,1
    2dd6:	00003097          	auipc	ra,0x3
    2dda:	db8080e7          	jalr	-584(ra) # 5b8e <exit>
  wait(0);
    2dde:	4501                	li	a0,0
    2de0:	00003097          	auipc	ra,0x3
    2de4:	db6080e7          	jalr	-586(ra) # 5b96 <wait>
  pid = fork();
    2de8:	00003097          	auipc	ra,0x3
    2dec:	d9e080e7          	jalr	-610(ra) # 5b86 <fork>
  if(pid < 0){
    2df0:	02054a63          	bltz	a0,2e24 <sbrkbugs+0xea>
  if(pid == 0){
    2df4:	e529                	bnez	a0,2e3e <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2df6:	00003097          	auipc	ra,0x3
    2dfa:	e20080e7          	jalr	-480(ra) # 5c16 <sbrk>
    2dfe:	67ad                	lui	a5,0xb
    2e00:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x298>
    2e04:	40a7853b          	subw	a0,a5,a0
    2e08:	00003097          	auipc	ra,0x3
    2e0c:	e0e080e7          	jalr	-498(ra) # 5c16 <sbrk>
    sbrk(-10);
    2e10:	5559                	li	a0,-10
    2e12:	00003097          	auipc	ra,0x3
    2e16:	e04080e7          	jalr	-508(ra) # 5c16 <sbrk>
    exit(0);
    2e1a:	4501                	li	a0,0
    2e1c:	00003097          	auipc	ra,0x3
    2e20:	d72080e7          	jalr	-654(ra) # 5b8e <exit>
    printf("fork failed\n");
<<<<<<< HEAD
    2e2a:	00004517          	auipc	a0,0x4
    2e2e:	fae50513          	addi	a0,a0,-82 # 6dd8 <malloc+0xdd4>
    2e32:	00003097          	auipc	ra,0x3
    2e36:	114080e7          	jalr	276(ra) # 5f46 <printf>
=======
    2e24:	00004517          	auipc	a0,0x4
    2e28:	f4450513          	addi	a0,a0,-188 # 6d68 <malloc+0xdb2>
    2e2c:	00003097          	auipc	ra,0x3
    2e30:	0d2080e7          	jalr	210(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    2e34:	4505                	li	a0,1
    2e36:	00003097          	auipc	ra,0x3
    2e3a:	d58080e7          	jalr	-680(ra) # 5b8e <exit>
  wait(0);
    2e3e:	4501                	li	a0,0
    2e40:	00003097          	auipc	ra,0x3
    2e44:	d56080e7          	jalr	-682(ra) # 5b96 <wait>
  exit(0);
    2e48:	4501                	li	a0,0
    2e4a:	00003097          	auipc	ra,0x3
    2e4e:	d44080e7          	jalr	-700(ra) # 5b8e <exit>

0000000000002e52 <sbrklast>:
{
    2e52:	7179                	addi	sp,sp,-48
    2e54:	f406                	sd	ra,40(sp)
    2e56:	f022                	sd	s0,32(sp)
    2e58:	ec26                	sd	s1,24(sp)
    2e5a:	e84a                	sd	s2,16(sp)
    2e5c:	e44e                	sd	s3,8(sp)
    2e5e:	e052                	sd	s4,0(sp)
    2e60:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2e62:	4501                	li	a0,0
    2e64:	00003097          	auipc	ra,0x3
    2e68:	db2080e7          	jalr	-590(ra) # 5c16 <sbrk>
  if((top % 4096) != 0)
    2e6c:	03451793          	slli	a5,a0,0x34
    2e70:	ebd9                	bnez	a5,2f06 <sbrklast+0xb4>
  sbrk(4096);
    2e72:	6505                	lui	a0,0x1
    2e74:	00003097          	auipc	ra,0x3
    2e78:	da2080e7          	jalr	-606(ra) # 5c16 <sbrk>
  sbrk(10);
    2e7c:	4529                	li	a0,10
    2e7e:	00003097          	auipc	ra,0x3
    2e82:	d98080e7          	jalr	-616(ra) # 5c16 <sbrk>
  sbrk(-20);
    2e86:	5531                	li	a0,-20
    2e88:	00003097          	auipc	ra,0x3
    2e8c:	d8e080e7          	jalr	-626(ra) # 5c16 <sbrk>
  top = (uint64) sbrk(0);
    2e90:	4501                	li	a0,0
    2e92:	00003097          	auipc	ra,0x3
    2e96:	d84080e7          	jalr	-636(ra) # 5c16 <sbrk>
    2e9a:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2e9c:	fc050913          	addi	s2,a0,-64 # fc0 <linktest+0xcc>
  p[0] = 'x';
    2ea0:	07800a13          	li	s4,120
    2ea4:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2ea8:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2eac:	20200593          	li	a1,514
    2eb0:	854a                	mv	a0,s2
    2eb2:	00003097          	auipc	ra,0x3
    2eb6:	d1c080e7          	jalr	-740(ra) # 5bce <open>
    2eba:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2ebc:	4605                	li	a2,1
    2ebe:	85ca                	mv	a1,s2
    2ec0:	00003097          	auipc	ra,0x3
    2ec4:	cee080e7          	jalr	-786(ra) # 5bae <write>
  close(fd);
    2ec8:	854e                	mv	a0,s3
    2eca:	00003097          	auipc	ra,0x3
    2ece:	cec080e7          	jalr	-788(ra) # 5bb6 <close>
  fd = open(p, O_RDWR);
    2ed2:	4589                	li	a1,2
    2ed4:	854a                	mv	a0,s2
    2ed6:	00003097          	auipc	ra,0x3
    2eda:	cf8080e7          	jalr	-776(ra) # 5bce <open>
  p[0] = '\0';
    2ede:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2ee2:	4605                	li	a2,1
    2ee4:	85ca                	mv	a1,s2
    2ee6:	00003097          	auipc	ra,0x3
    2eea:	cc0080e7          	jalr	-832(ra) # 5ba6 <read>
  if(p[0] != 'x')
    2eee:	fc04c783          	lbu	a5,-64(s1)
    2ef2:	03479463          	bne	a5,s4,2f1a <sbrklast+0xc8>
}
    2ef6:	70a2                	ld	ra,40(sp)
    2ef8:	7402                	ld	s0,32(sp)
    2efa:	64e2                	ld	s1,24(sp)
    2efc:	6942                	ld	s2,16(sp)
    2efe:	69a2                	ld	s3,8(sp)
    2f00:	6a02                	ld	s4,0(sp)
    2f02:	6145                	addi	sp,sp,48
    2f04:	8082                	ret
    sbrk(4096 - (top % 4096));
    2f06:	0347d513          	srli	a0,a5,0x34
    2f0a:	6785                	lui	a5,0x1
    2f0c:	40a7853b          	subw	a0,a5,a0
    2f10:	00003097          	auipc	ra,0x3
    2f14:	d06080e7          	jalr	-762(ra) # 5c16 <sbrk>
    2f18:	bfa9                	j	2e72 <sbrklast+0x20>
    exit(1);
    2f1a:	4505                	li	a0,1
    2f1c:	00003097          	auipc	ra,0x3
    2f20:	c72080e7          	jalr	-910(ra) # 5b8e <exit>

0000000000002f24 <sbrk8000>:
{
    2f24:	1141                	addi	sp,sp,-16
    2f26:	e406                	sd	ra,8(sp)
    2f28:	e022                	sd	s0,0(sp)
    2f2a:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2f2c:	80000537          	lui	a0,0x80000
    2f30:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff038c>
    2f32:	00003097          	auipc	ra,0x3
    2f36:	ce4080e7          	jalr	-796(ra) # 5c16 <sbrk>
  volatile char *top = sbrk(0);
    2f3a:	4501                	li	a0,0
    2f3c:	00003097          	auipc	ra,0x3
    2f40:	cda080e7          	jalr	-806(ra) # 5c16 <sbrk>
  *(top-1) = *(top-1) + 1;
    2f44:	fff54783          	lbu	a5,-1(a0)
    2f48:	2785                	addiw	a5,a5,1 # 1001 <linktest+0x10d>
    2f4a:	0ff7f793          	zext.b	a5,a5
    2f4e:	fef50fa3          	sb	a5,-1(a0)
}
    2f52:	60a2                	ld	ra,8(sp)
    2f54:	6402                	ld	s0,0(sp)
    2f56:	0141                	addi	sp,sp,16
    2f58:	8082                	ret

0000000000002f5a <execout>:
{
    2f5a:	715d                	addi	sp,sp,-80
    2f5c:	e486                	sd	ra,72(sp)
    2f5e:	e0a2                	sd	s0,64(sp)
    2f60:	fc26                	sd	s1,56(sp)
    2f62:	f84a                	sd	s2,48(sp)
    2f64:	f44e                	sd	s3,40(sp)
    2f66:	f052                	sd	s4,32(sp)
    2f68:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2f6a:	4901                	li	s2,0
    2f6c:	49bd                	li	s3,15
    int pid = fork();
    2f6e:	00003097          	auipc	ra,0x3
    2f72:	c18080e7          	jalr	-1000(ra) # 5b86 <fork>
    2f76:	84aa                	mv	s1,a0
    if(pid < 0){
    2f78:	02054063          	bltz	a0,2f98 <execout+0x3e>
    } else if(pid == 0){
    2f7c:	c91d                	beqz	a0,2fb2 <execout+0x58>
      wait((int*)0);
    2f7e:	4501                	li	a0,0
    2f80:	00003097          	auipc	ra,0x3
    2f84:	c16080e7          	jalr	-1002(ra) # 5b96 <wait>
  for(int avail = 0; avail < 15; avail++){
    2f88:	2905                	addiw	s2,s2,1
    2f8a:	ff3912e3          	bne	s2,s3,2f6e <execout+0x14>
  exit(0);
    2f8e:	4501                	li	a0,0
    2f90:	00003097          	auipc	ra,0x3
    2f94:	bfe080e7          	jalr	-1026(ra) # 5b8e <exit>
      printf("fork failed\n");
<<<<<<< HEAD
    2f9e:	00004517          	auipc	a0,0x4
    2fa2:	e3a50513          	addi	a0,a0,-454 # 6dd8 <malloc+0xdd4>
    2fa6:	00003097          	auipc	ra,0x3
    2faa:	fa0080e7          	jalr	-96(ra) # 5f46 <printf>
=======
    2f98:	00004517          	auipc	a0,0x4
    2f9c:	dd050513          	addi	a0,a0,-560 # 6d68 <malloc+0xdb2>
    2fa0:	00003097          	auipc	ra,0x3
    2fa4:	f5e080e7          	jalr	-162(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    2fa8:	4505                	li	a0,1
    2faa:	00003097          	auipc	ra,0x3
    2fae:	be4080e7          	jalr	-1052(ra) # 5b8e <exit>
        if(a == 0xffffffffffffffffLL)
    2fb2:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2fb4:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2fb6:	6505                	lui	a0,0x1
    2fb8:	00003097          	auipc	ra,0x3
    2fbc:	c5e080e7          	jalr	-930(ra) # 5c16 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2fc0:	01350763          	beq	a0,s3,2fce <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2fc4:	6785                	lui	a5,0x1
    2fc6:	97aa                	add	a5,a5,a0
    2fc8:	ff478fa3          	sb	s4,-1(a5) # fff <linktest+0x10b>
      while(1){
    2fcc:	b7ed                	j	2fb6 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2fce:	01205a63          	blez	s2,2fe2 <execout+0x88>
        sbrk(-4096);
    2fd2:	757d                	lui	a0,0xfffff
    2fd4:	00003097          	auipc	ra,0x3
    2fd8:	c42080e7          	jalr	-958(ra) # 5c16 <sbrk>
      for(int i = 0; i < avail; i++)
    2fdc:	2485                	addiw	s1,s1,1
    2fde:	ff249ae3          	bne	s1,s2,2fd2 <execout+0x78>
      close(1);
    2fe2:	4505                	li	a0,1
    2fe4:	00003097          	auipc	ra,0x3
    2fe8:	bd2080e7          	jalr	-1070(ra) # 5bb6 <close>
      char *args[] = { "echo", "x", 0 };
<<<<<<< HEAD
    2ff2:	00003517          	auipc	a0,0x3
    2ff6:	15650513          	addi	a0,a0,342 # 6148 <malloc+0x144>
    2ffa:	faa43c23          	sd	a0,-72(s0)
    2ffe:	00003797          	auipc	a5,0x3
    3002:	1ba78793          	addi	a5,a5,442 # 61b8 <malloc+0x1b4>
    3006:	fcf43023          	sd	a5,-64(s0)
    300a:	fc043423          	sd	zero,-56(s0)
=======
    2fec:	00003517          	auipc	a0,0x3
    2ff0:	0ec50513          	addi	a0,a0,236 # 60d8 <malloc+0x122>
    2ff4:	faa43c23          	sd	a0,-72(s0)
    2ff8:	00003797          	auipc	a5,0x3
    2ffc:	15078793          	addi	a5,a5,336 # 6148 <malloc+0x192>
    3000:	fcf43023          	sd	a5,-64(s0)
    3004:	fc043423          	sd	zero,-56(s0)
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exec("echo", args);
    3008:	fb840593          	addi	a1,s0,-72
    300c:	00003097          	auipc	ra,0x3
    3010:	bba080e7          	jalr	-1094(ra) # 5bc6 <exec>
      exit(0);
    3014:	4501                	li	a0,0
    3016:	00003097          	auipc	ra,0x3
    301a:	b78080e7          	jalr	-1160(ra) # 5b8e <exit>

000000000000301e <fourteen>:
{
    301e:	1101                	addi	sp,sp,-32
    3020:	ec06                	sd	ra,24(sp)
    3022:	e822                	sd	s0,16(sp)
    3024:	e426                	sd	s1,8(sp)
    3026:	1000                	addi	s0,sp,32
    3028:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
<<<<<<< HEAD
    3030:	00004517          	auipc	a0,0x4
    3034:	2b850513          	addi	a0,a0,696 # 72e8 <malloc+0x12e4>
    3038:	00003097          	auipc	ra,0x3
    303c:	bf6080e7          	jalr	-1034(ra) # 5c2e <mkdir>
    3040:	e165                	bnez	a0,3120 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3042:	00004517          	auipc	a0,0x4
    3046:	0fe50513          	addi	a0,a0,254 # 7140 <malloc+0x113c>
    304a:	00003097          	auipc	ra,0x3
    304e:	be4080e7          	jalr	-1052(ra) # 5c2e <mkdir>
    3052:	e56d                	bnez	a0,313c <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    3054:	20000593          	li	a1,512
    3058:	00004517          	auipc	a0,0x4
    305c:	14050513          	addi	a0,a0,320 # 7198 <malloc+0x1194>
    3060:	00003097          	auipc	ra,0x3
    3064:	ba6080e7          	jalr	-1114(ra) # 5c06 <open>
=======
    302a:	00004517          	auipc	a0,0x4
    302e:	24e50513          	addi	a0,a0,590 # 7278 <malloc+0x12c2>
    3032:	00003097          	auipc	ra,0x3
    3036:	bc4080e7          	jalr	-1084(ra) # 5bf6 <mkdir>
    303a:	e165                	bnez	a0,311a <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    303c:	00004517          	auipc	a0,0x4
    3040:	09450513          	addi	a0,a0,148 # 70d0 <malloc+0x111a>
    3044:	00003097          	auipc	ra,0x3
    3048:	bb2080e7          	jalr	-1102(ra) # 5bf6 <mkdir>
    304c:	e56d                	bnez	a0,3136 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    304e:	20000593          	li	a1,512
    3052:	00004517          	auipc	a0,0x4
    3056:	0d650513          	addi	a0,a0,214 # 7128 <malloc+0x1172>
    305a:	00003097          	auipc	ra,0x3
    305e:	b74080e7          	jalr	-1164(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    3062:	0e054863          	bltz	a0,3152 <fourteen+0x134>
  close(fd);
    3066:	00003097          	auipc	ra,0x3
    306a:	b50080e7          	jalr	-1200(ra) # 5bb6 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
<<<<<<< HEAD
    3074:	4581                	li	a1,0
    3076:	00004517          	auipc	a0,0x4
    307a:	19a50513          	addi	a0,a0,410 # 7210 <malloc+0x120c>
    307e:	00003097          	auipc	ra,0x3
    3082:	b88080e7          	jalr	-1144(ra) # 5c06 <open>
=======
    306e:	4581                	li	a1,0
    3070:	00004517          	auipc	a0,0x4
    3074:	13050513          	addi	a0,a0,304 # 71a0 <malloc+0x11ea>
    3078:	00003097          	auipc	ra,0x3
    307c:	b56080e7          	jalr	-1194(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    3080:	0e054763          	bltz	a0,316e <fourteen+0x150>
  close(fd);
    3084:	00003097          	auipc	ra,0x3
    3088:	b32080e7          	jalr	-1230(ra) # 5bb6 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
<<<<<<< HEAD
    3092:	00004517          	auipc	a0,0x4
    3096:	1ee50513          	addi	a0,a0,494 # 7280 <malloc+0x127c>
    309a:	00003097          	auipc	ra,0x3
    309e:	b94080e7          	jalr	-1132(ra) # 5c2e <mkdir>
    30a2:	c57d                	beqz	a0,3190 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    30a4:	00004517          	auipc	a0,0x4
    30a8:	23450513          	addi	a0,a0,564 # 72d8 <malloc+0x12d4>
    30ac:	00003097          	auipc	ra,0x3
    30b0:	b82080e7          	jalr	-1150(ra) # 5c2e <mkdir>
    30b4:	cd65                	beqz	a0,31ac <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    30b6:	00004517          	auipc	a0,0x4
    30ba:	22250513          	addi	a0,a0,546 # 72d8 <malloc+0x12d4>
    30be:	00003097          	auipc	ra,0x3
    30c2:	b58080e7          	jalr	-1192(ra) # 5c16 <unlink>
  unlink("12345678901234/12345678901234");
    30c6:	00004517          	auipc	a0,0x4
    30ca:	1ba50513          	addi	a0,a0,442 # 7280 <malloc+0x127c>
    30ce:	00003097          	auipc	ra,0x3
    30d2:	b48080e7          	jalr	-1208(ra) # 5c16 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    30d6:	00004517          	auipc	a0,0x4
    30da:	13a50513          	addi	a0,a0,314 # 7210 <malloc+0x120c>
    30de:	00003097          	auipc	ra,0x3
    30e2:	b38080e7          	jalr	-1224(ra) # 5c16 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    30e6:	00004517          	auipc	a0,0x4
    30ea:	0b250513          	addi	a0,a0,178 # 7198 <malloc+0x1194>
    30ee:	00003097          	auipc	ra,0x3
    30f2:	b28080e7          	jalr	-1240(ra) # 5c16 <unlink>
  unlink("12345678901234/123456789012345");
    30f6:	00004517          	auipc	a0,0x4
    30fa:	04a50513          	addi	a0,a0,74 # 7140 <malloc+0x113c>
    30fe:	00003097          	auipc	ra,0x3
    3102:	b18080e7          	jalr	-1256(ra) # 5c16 <unlink>
  unlink("12345678901234");
    3106:	00004517          	auipc	a0,0x4
    310a:	1e250513          	addi	a0,a0,482 # 72e8 <malloc+0x12e4>
    310e:	00003097          	auipc	ra,0x3
    3112:	b08080e7          	jalr	-1272(ra) # 5c16 <unlink>
=======
    308c:	00004517          	auipc	a0,0x4
    3090:	18450513          	addi	a0,a0,388 # 7210 <malloc+0x125a>
    3094:	00003097          	auipc	ra,0x3
    3098:	b62080e7          	jalr	-1182(ra) # 5bf6 <mkdir>
    309c:	c57d                	beqz	a0,318a <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    309e:	00004517          	auipc	a0,0x4
    30a2:	1ca50513          	addi	a0,a0,458 # 7268 <malloc+0x12b2>
    30a6:	00003097          	auipc	ra,0x3
    30aa:	b50080e7          	jalr	-1200(ra) # 5bf6 <mkdir>
    30ae:	cd65                	beqz	a0,31a6 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    30b0:	00004517          	auipc	a0,0x4
    30b4:	1b850513          	addi	a0,a0,440 # 7268 <malloc+0x12b2>
    30b8:	00003097          	auipc	ra,0x3
    30bc:	b26080e7          	jalr	-1242(ra) # 5bde <unlink>
  unlink("12345678901234/12345678901234");
    30c0:	00004517          	auipc	a0,0x4
    30c4:	15050513          	addi	a0,a0,336 # 7210 <malloc+0x125a>
    30c8:	00003097          	auipc	ra,0x3
    30cc:	b16080e7          	jalr	-1258(ra) # 5bde <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    30d0:	00004517          	auipc	a0,0x4
    30d4:	0d050513          	addi	a0,a0,208 # 71a0 <malloc+0x11ea>
    30d8:	00003097          	auipc	ra,0x3
    30dc:	b06080e7          	jalr	-1274(ra) # 5bde <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    30e0:	00004517          	auipc	a0,0x4
    30e4:	04850513          	addi	a0,a0,72 # 7128 <malloc+0x1172>
    30e8:	00003097          	auipc	ra,0x3
    30ec:	af6080e7          	jalr	-1290(ra) # 5bde <unlink>
  unlink("12345678901234/123456789012345");
    30f0:	00004517          	auipc	a0,0x4
    30f4:	fe050513          	addi	a0,a0,-32 # 70d0 <malloc+0x111a>
    30f8:	00003097          	auipc	ra,0x3
    30fc:	ae6080e7          	jalr	-1306(ra) # 5bde <unlink>
  unlink("12345678901234");
    3100:	00004517          	auipc	a0,0x4
    3104:	17850513          	addi	a0,a0,376 # 7278 <malloc+0x12c2>
    3108:	00003097          	auipc	ra,0x3
    310c:	ad6080e7          	jalr	-1322(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    3110:	60e2                	ld	ra,24(sp)
    3112:	6442                	ld	s0,16(sp)
    3114:	64a2                	ld	s1,8(sp)
    3116:	6105                	addi	sp,sp,32
    3118:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
<<<<<<< HEAD
    3120:	85a6                	mv	a1,s1
    3122:	00004517          	auipc	a0,0x4
    3126:	ff650513          	addi	a0,a0,-10 # 7118 <malloc+0x1114>
    312a:	00003097          	auipc	ra,0x3
    312e:	e1c080e7          	jalr	-484(ra) # 5f46 <printf>
=======
    311a:	85a6                	mv	a1,s1
    311c:	00004517          	auipc	a0,0x4
    3120:	f8c50513          	addi	a0,a0,-116 # 70a8 <malloc+0x10f2>
    3124:	00003097          	auipc	ra,0x3
    3128:	dda080e7          	jalr	-550(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    312c:	4505                	li	a0,1
    312e:	00003097          	auipc	ra,0x3
    3132:	a60080e7          	jalr	-1440(ra) # 5b8e <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
<<<<<<< HEAD
    313c:	85a6                	mv	a1,s1
    313e:	00004517          	auipc	a0,0x4
    3142:	02250513          	addi	a0,a0,34 # 7160 <malloc+0x115c>
    3146:	00003097          	auipc	ra,0x3
    314a:	e00080e7          	jalr	-512(ra) # 5f46 <printf>
=======
    3136:	85a6                	mv	a1,s1
    3138:	00004517          	auipc	a0,0x4
    313c:	fb850513          	addi	a0,a0,-72 # 70f0 <malloc+0x113a>
    3140:	00003097          	auipc	ra,0x3
    3144:	dbe080e7          	jalr	-578(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3148:	4505                	li	a0,1
    314a:	00003097          	auipc	ra,0x3
    314e:	a44080e7          	jalr	-1468(ra) # 5b8e <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
<<<<<<< HEAD
    3158:	85a6                	mv	a1,s1
    315a:	00004517          	auipc	a0,0x4
    315e:	06e50513          	addi	a0,a0,110 # 71c8 <malloc+0x11c4>
    3162:	00003097          	auipc	ra,0x3
    3166:	de4080e7          	jalr	-540(ra) # 5f46 <printf>
=======
    3152:	85a6                	mv	a1,s1
    3154:	00004517          	auipc	a0,0x4
    3158:	00450513          	addi	a0,a0,4 # 7158 <malloc+0x11a2>
    315c:	00003097          	auipc	ra,0x3
    3160:	da2080e7          	jalr	-606(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3164:	4505                	li	a0,1
    3166:	00003097          	auipc	ra,0x3
    316a:	a28080e7          	jalr	-1496(ra) # 5b8e <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
<<<<<<< HEAD
    3174:	85a6                	mv	a1,s1
    3176:	00004517          	auipc	a0,0x4
    317a:	0ca50513          	addi	a0,a0,202 # 7240 <malloc+0x123c>
    317e:	00003097          	auipc	ra,0x3
    3182:	dc8080e7          	jalr	-568(ra) # 5f46 <printf>
=======
    316e:	85a6                	mv	a1,s1
    3170:	00004517          	auipc	a0,0x4
    3174:	06050513          	addi	a0,a0,96 # 71d0 <malloc+0x121a>
    3178:	00003097          	auipc	ra,0x3
    317c:	d86080e7          	jalr	-634(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3180:	4505                	li	a0,1
    3182:	00003097          	auipc	ra,0x3
    3186:	a0c080e7          	jalr	-1524(ra) # 5b8e <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
<<<<<<< HEAD
    3190:	85a6                	mv	a1,s1
    3192:	00004517          	auipc	a0,0x4
    3196:	10e50513          	addi	a0,a0,270 # 72a0 <malloc+0x129c>
    319a:	00003097          	auipc	ra,0x3
    319e:	dac080e7          	jalr	-596(ra) # 5f46 <printf>
=======
    318a:	85a6                	mv	a1,s1
    318c:	00004517          	auipc	a0,0x4
    3190:	0a450513          	addi	a0,a0,164 # 7230 <malloc+0x127a>
    3194:	00003097          	auipc	ra,0x3
    3198:	d6a080e7          	jalr	-662(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    319c:	4505                	li	a0,1
    319e:	00003097          	auipc	ra,0x3
    31a2:	9f0080e7          	jalr	-1552(ra) # 5b8e <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
<<<<<<< HEAD
    31ac:	85a6                	mv	a1,s1
    31ae:	00004517          	auipc	a0,0x4
    31b2:	14a50513          	addi	a0,a0,330 # 72f8 <malloc+0x12f4>
    31b6:	00003097          	auipc	ra,0x3
    31ba:	d90080e7          	jalr	-624(ra) # 5f46 <printf>
=======
    31a6:	85a6                	mv	a1,s1
    31a8:	00004517          	auipc	a0,0x4
    31ac:	0e050513          	addi	a0,a0,224 # 7288 <malloc+0x12d2>
    31b0:	00003097          	auipc	ra,0x3
    31b4:	d4e080e7          	jalr	-690(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    31b8:	4505                	li	a0,1
    31ba:	00003097          	auipc	ra,0x3
    31be:	9d4080e7          	jalr	-1580(ra) # 5b8e <exit>

00000000000031c2 <diskfull>:
{
    31c2:	b9010113          	addi	sp,sp,-1136
    31c6:	46113423          	sd	ra,1128(sp)
    31ca:	46813023          	sd	s0,1120(sp)
    31ce:	44913c23          	sd	s1,1112(sp)
    31d2:	45213823          	sd	s2,1104(sp)
    31d6:	45313423          	sd	s3,1096(sp)
    31da:	45413023          	sd	s4,1088(sp)
    31de:	43513c23          	sd	s5,1080(sp)
    31e2:	43613823          	sd	s6,1072(sp)
    31e6:	43713423          	sd	s7,1064(sp)
    31ea:	43813023          	sd	s8,1056(sp)
    31ee:	47010413          	addi	s0,sp,1136
    31f2:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
<<<<<<< HEAD
    31fa:	00004517          	auipc	a0,0x4
    31fe:	13650513          	addi	a0,a0,310 # 7330 <malloc+0x132c>
    3202:	00003097          	auipc	ra,0x3
    3206:	a14080e7          	jalr	-1516(ra) # 5c16 <unlink>
=======
    31f4:	00004517          	auipc	a0,0x4
    31f8:	0cc50513          	addi	a0,a0,204 # 72c0 <malloc+0x130a>
    31fc:	00003097          	auipc	ra,0x3
    3200:	9e2080e7          	jalr	-1566(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(fi = 0; done == 0; fi++){
    3204:	4a01                	li	s4,0
    name[0] = 'b';
    3206:	06200b13          	li	s6,98
    name[1] = 'i';
    320a:	06900a93          	li	s5,105
    name[2] = 'g';
    320e:	06700993          	li	s3,103
    3212:	10c00b93          	li	s7,268
    3216:	aabd                	j	3394 <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
<<<<<<< HEAD
    321e:	b9040613          	addi	a2,s0,-1136
    3222:	85e2                	mv	a1,s8
    3224:	00004517          	auipc	a0,0x4
    3228:	11c50513          	addi	a0,a0,284 # 7340 <malloc+0x133c>
    322c:	00003097          	auipc	ra,0x3
    3230:	d1a080e7          	jalr	-742(ra) # 5f46 <printf>
=======
    3218:	b9040613          	addi	a2,s0,-1136
    321c:	85e2                	mv	a1,s8
    321e:	00004517          	auipc	a0,0x4
    3222:	0b250513          	addi	a0,a0,178 # 72d0 <malloc+0x131a>
    3226:	00003097          	auipc	ra,0x3
    322a:	cd8080e7          	jalr	-808(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      break;
    322e:	a821                	j	3246 <diskfull+0x84>
        close(fd);
    3230:	854a                	mv	a0,s2
    3232:	00003097          	auipc	ra,0x3
    3236:	984080e7          	jalr	-1660(ra) # 5bb6 <close>
    close(fd);
    323a:	854a                	mv	a0,s2
    323c:	00003097          	auipc	ra,0x3
    3240:	97a080e7          	jalr	-1670(ra) # 5bb6 <close>
  for(fi = 0; done == 0; fi++){
    3244:	2a05                	addiw	s4,s4,1
  for(int i = 0; i < nzz; i++){
    3246:	4481                	li	s1,0
    name[0] = 'z';
    3248:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    324c:	08000993          	li	s3,128
    name[0] = 'z';
    3250:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3254:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    3258:	41f4d71b          	sraiw	a4,s1,0x1f
    325c:	01b7571b          	srliw	a4,a4,0x1b
    3260:	009707bb          	addw	a5,a4,s1
    3264:	4057d69b          	sraiw	a3,a5,0x5
    3268:	0306869b          	addiw	a3,a3,48
    326c:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3270:	8bfd                	andi	a5,a5,31
    3272:	9f99                	subw	a5,a5,a4
    3274:	0307879b          	addiw	a5,a5,48
    3278:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    327c:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3280:	bb040513          	addi	a0,s0,-1104
    3284:	00003097          	auipc	ra,0x3
    3288:	95a080e7          	jalr	-1702(ra) # 5bde <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    328c:	60200593          	li	a1,1538
    3290:	bb040513          	addi	a0,s0,-1104
    3294:	00003097          	auipc	ra,0x3
    3298:	93a080e7          	jalr	-1734(ra) # 5bce <open>
    if(fd < 0)
    329c:	00054963          	bltz	a0,32ae <diskfull+0xec>
    close(fd);
    32a0:	00003097          	auipc	ra,0x3
    32a4:	916080e7          	jalr	-1770(ra) # 5bb6 <close>
  for(int i = 0; i < nzz; i++){
    32a8:	2485                	addiw	s1,s1,1
    32aa:	fb3493e3          	bne	s1,s3,3250 <diskfull+0x8e>
  if(mkdir("diskfulldir") == 0)
<<<<<<< HEAD
    32b4:	00004517          	auipc	a0,0x4
    32b8:	07c50513          	addi	a0,a0,124 # 7330 <malloc+0x132c>
    32bc:	00003097          	auipc	ra,0x3
    32c0:	972080e7          	jalr	-1678(ra) # 5c2e <mkdir>
    32c4:	12050963          	beqz	a0,33f6 <diskfull+0x22e>
  unlink("diskfulldir");
    32c8:	00004517          	auipc	a0,0x4
    32cc:	06850513          	addi	a0,a0,104 # 7330 <malloc+0x132c>
    32d0:	00003097          	auipc	ra,0x3
    32d4:	946080e7          	jalr	-1722(ra) # 5c16 <unlink>
=======
    32ae:	00004517          	auipc	a0,0x4
    32b2:	01250513          	addi	a0,a0,18 # 72c0 <malloc+0x130a>
    32b6:	00003097          	auipc	ra,0x3
    32ba:	940080e7          	jalr	-1728(ra) # 5bf6 <mkdir>
    32be:	12050963          	beqz	a0,33f0 <diskfull+0x22e>
  unlink("diskfulldir");
    32c2:	00004517          	auipc	a0,0x4
    32c6:	ffe50513          	addi	a0,a0,-2 # 72c0 <malloc+0x130a>
    32ca:	00003097          	auipc	ra,0x3
    32ce:	914080e7          	jalr	-1772(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(int i = 0; i < nzz; i++){
    32d2:	4481                	li	s1,0
    name[0] = 'z';
    32d4:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    32d8:	08000993          	li	s3,128
    name[0] = 'z';
    32dc:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    32e0:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    32e4:	41f4d71b          	sraiw	a4,s1,0x1f
    32e8:	01b7571b          	srliw	a4,a4,0x1b
    32ec:	009707bb          	addw	a5,a4,s1
    32f0:	4057d69b          	sraiw	a3,a5,0x5
    32f4:	0306869b          	addiw	a3,a3,48
    32f8:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    32fc:	8bfd                	andi	a5,a5,31
    32fe:	9f99                	subw	a5,a5,a4
    3300:	0307879b          	addiw	a5,a5,48
    3304:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3308:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    330c:	bb040513          	addi	a0,s0,-1104
    3310:	00003097          	auipc	ra,0x3
    3314:	8ce080e7          	jalr	-1842(ra) # 5bde <unlink>
  for(int i = 0; i < nzz; i++){
    3318:	2485                	addiw	s1,s1,1
    331a:	fd3491e3          	bne	s1,s3,32dc <diskfull+0x11a>
  for(int i = 0; i < fi; i++){
    331e:	03405e63          	blez	s4,335a <diskfull+0x198>
    3322:	4481                	li	s1,0
    name[0] = 'b';
    3324:	06200a93          	li	s5,98
    name[1] = 'i';
    3328:	06900993          	li	s3,105
    name[2] = 'g';
    332c:	06700913          	li	s2,103
    name[0] = 'b';
    3330:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    3334:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    3338:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    333c:	0304879b          	addiw	a5,s1,48
    3340:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3344:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3348:	bb040513          	addi	a0,s0,-1104
    334c:	00003097          	auipc	ra,0x3
    3350:	892080e7          	jalr	-1902(ra) # 5bde <unlink>
  for(int i = 0; i < fi; i++){
    3354:	2485                	addiw	s1,s1,1
    3356:	fd449de3          	bne	s1,s4,3330 <diskfull+0x16e>
}
    335a:	46813083          	ld	ra,1128(sp)
    335e:	46013403          	ld	s0,1120(sp)
    3362:	45813483          	ld	s1,1112(sp)
    3366:	45013903          	ld	s2,1104(sp)
    336a:	44813983          	ld	s3,1096(sp)
    336e:	44013a03          	ld	s4,1088(sp)
    3372:	43813a83          	ld	s5,1080(sp)
    3376:	43013b03          	ld	s6,1072(sp)
    337a:	42813b83          	ld	s7,1064(sp)
    337e:	42013c03          	ld	s8,1056(sp)
    3382:	47010113          	addi	sp,sp,1136
    3386:	8082                	ret
    close(fd);
    3388:	854a                	mv	a0,s2
    338a:	00003097          	auipc	ra,0x3
    338e:	82c080e7          	jalr	-2004(ra) # 5bb6 <close>
  for(fi = 0; done == 0; fi++){
    3392:	2a05                	addiw	s4,s4,1
    name[0] = 'b';
    3394:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    3398:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    339c:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    33a0:	030a079b          	addiw	a5,s4,48
    33a4:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    33a8:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    33ac:	b9040513          	addi	a0,s0,-1136
    33b0:	00003097          	auipc	ra,0x3
    33b4:	82e080e7          	jalr	-2002(ra) # 5bde <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    33b8:	60200593          	li	a1,1538
    33bc:	b9040513          	addi	a0,s0,-1136
    33c0:	00003097          	auipc	ra,0x3
    33c4:	80e080e7          	jalr	-2034(ra) # 5bce <open>
    33c8:	892a                	mv	s2,a0
    if(fd < 0){
    33ca:	e40547e3          	bltz	a0,3218 <diskfull+0x56>
    33ce:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    33d0:	40000613          	li	a2,1024
    33d4:	bb040593          	addi	a1,s0,-1104
    33d8:	854a                	mv	a0,s2
    33da:	00002097          	auipc	ra,0x2
    33de:	7d4080e7          	jalr	2004(ra) # 5bae <write>
    33e2:	40000793          	li	a5,1024
    33e6:	e4f515e3          	bne	a0,a5,3230 <diskfull+0x6e>
    for(int i = 0; i < MAXFILE; i++){
    33ea:	34fd                	addiw	s1,s1,-1
    33ec:	f0f5                	bnez	s1,33d0 <diskfull+0x20e>
    33ee:	bf69                	j	3388 <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
<<<<<<< HEAD
    33f6:	00004517          	auipc	a0,0x4
    33fa:	f6a50513          	addi	a0,a0,-150 # 7360 <malloc+0x135c>
    33fe:	00003097          	auipc	ra,0x3
    3402:	b48080e7          	jalr	-1208(ra) # 5f46 <printf>
    3406:	b5c9                	j	32c8 <diskfull+0x100>
=======
    33f0:	00004517          	auipc	a0,0x4
    33f4:	f0050513          	addi	a0,a0,-256 # 72f0 <malloc+0x133a>
    33f8:	00003097          	auipc	ra,0x3
    33fc:	b06080e7          	jalr	-1274(ra) # 5efe <printf>
    3400:	b5c9                	j	32c2 <diskfull+0x100>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

0000000000003402 <iputtest>:
{
    3402:	1101                	addi	sp,sp,-32
    3404:	ec06                	sd	ra,24(sp)
    3406:	e822                	sd	s0,16(sp)
    3408:	e426                	sd	s1,8(sp)
    340a:	1000                	addi	s0,sp,32
    340c:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
<<<<<<< HEAD
    3414:	00004517          	auipc	a0,0x4
    3418:	f7c50513          	addi	a0,a0,-132 # 7390 <malloc+0x138c>
    341c:	00003097          	auipc	ra,0x3
    3420:	812080e7          	jalr	-2030(ra) # 5c2e <mkdir>
    3424:	04054563          	bltz	a0,346e <iputtest+0x66>
  if(chdir("iputdir") < 0){
    3428:	00004517          	auipc	a0,0x4
    342c:	f6850513          	addi	a0,a0,-152 # 7390 <malloc+0x138c>
    3430:	00003097          	auipc	ra,0x3
    3434:	806080e7          	jalr	-2042(ra) # 5c36 <chdir>
    3438:	04054963          	bltz	a0,348a <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    343c:	00004517          	auipc	a0,0x4
    3440:	f9450513          	addi	a0,a0,-108 # 73d0 <malloc+0x13cc>
    3444:	00002097          	auipc	ra,0x2
    3448:	7d2080e7          	jalr	2002(ra) # 5c16 <unlink>
    344c:	04054d63          	bltz	a0,34a6 <iputtest+0x9e>
  if(chdir("/") < 0){
    3450:	00004517          	auipc	a0,0x4
    3454:	fb050513          	addi	a0,a0,-80 # 7400 <malloc+0x13fc>
    3458:	00002097          	auipc	ra,0x2
    345c:	7de080e7          	jalr	2014(ra) # 5c36 <chdir>
    3460:	06054163          	bltz	a0,34c2 <iputtest+0xba>
=======
    340e:	00004517          	auipc	a0,0x4
    3412:	f1250513          	addi	a0,a0,-238 # 7320 <malloc+0x136a>
    3416:	00002097          	auipc	ra,0x2
    341a:	7e0080e7          	jalr	2016(ra) # 5bf6 <mkdir>
    341e:	04054563          	bltz	a0,3468 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    3422:	00004517          	auipc	a0,0x4
    3426:	efe50513          	addi	a0,a0,-258 # 7320 <malloc+0x136a>
    342a:	00002097          	auipc	ra,0x2
    342e:	7d4080e7          	jalr	2004(ra) # 5bfe <chdir>
    3432:	04054963          	bltz	a0,3484 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    3436:	00004517          	auipc	a0,0x4
    343a:	f2a50513          	addi	a0,a0,-214 # 7360 <malloc+0x13aa>
    343e:	00002097          	auipc	ra,0x2
    3442:	7a0080e7          	jalr	1952(ra) # 5bde <unlink>
    3446:	04054d63          	bltz	a0,34a0 <iputtest+0x9e>
  if(chdir("/") < 0){
    344a:	00004517          	auipc	a0,0x4
    344e:	f4650513          	addi	a0,a0,-186 # 7390 <malloc+0x13da>
    3452:	00002097          	auipc	ra,0x2
    3456:	7ac080e7          	jalr	1964(ra) # 5bfe <chdir>
    345a:	06054163          	bltz	a0,34bc <iputtest+0xba>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    345e:	60e2                	ld	ra,24(sp)
    3460:	6442                	ld	s0,16(sp)
    3462:	64a2                	ld	s1,8(sp)
    3464:	6105                	addi	sp,sp,32
    3466:	8082                	ret
    printf("%s: mkdir failed\n", s);
<<<<<<< HEAD
    346e:	85a6                	mv	a1,s1
    3470:	00004517          	auipc	a0,0x4
    3474:	f2850513          	addi	a0,a0,-216 # 7398 <malloc+0x1394>
    3478:	00003097          	auipc	ra,0x3
    347c:	ace080e7          	jalr	-1330(ra) # 5f46 <printf>
=======
    3468:	85a6                	mv	a1,s1
    346a:	00004517          	auipc	a0,0x4
    346e:	ebe50513          	addi	a0,a0,-322 # 7328 <malloc+0x1372>
    3472:	00003097          	auipc	ra,0x3
    3476:	a8c080e7          	jalr	-1396(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    347a:	4505                	li	a0,1
    347c:	00002097          	auipc	ra,0x2
    3480:	712080e7          	jalr	1810(ra) # 5b8e <exit>
    printf("%s: chdir iputdir failed\n", s);
<<<<<<< HEAD
    348a:	85a6                	mv	a1,s1
    348c:	00004517          	auipc	a0,0x4
    3490:	f2450513          	addi	a0,a0,-220 # 73b0 <malloc+0x13ac>
    3494:	00003097          	auipc	ra,0x3
    3498:	ab2080e7          	jalr	-1358(ra) # 5f46 <printf>
=======
    3484:	85a6                	mv	a1,s1
    3486:	00004517          	auipc	a0,0x4
    348a:	eba50513          	addi	a0,a0,-326 # 7340 <malloc+0x138a>
    348e:	00003097          	auipc	ra,0x3
    3492:	a70080e7          	jalr	-1424(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3496:	4505                	li	a0,1
    3498:	00002097          	auipc	ra,0x2
    349c:	6f6080e7          	jalr	1782(ra) # 5b8e <exit>
    printf("%s: unlink ../iputdir failed\n", s);
<<<<<<< HEAD
    34a6:	85a6                	mv	a1,s1
    34a8:	00004517          	auipc	a0,0x4
    34ac:	f3850513          	addi	a0,a0,-200 # 73e0 <malloc+0x13dc>
    34b0:	00003097          	auipc	ra,0x3
    34b4:	a96080e7          	jalr	-1386(ra) # 5f46 <printf>
=======
    34a0:	85a6                	mv	a1,s1
    34a2:	00004517          	auipc	a0,0x4
    34a6:	ece50513          	addi	a0,a0,-306 # 7370 <malloc+0x13ba>
    34aa:	00003097          	auipc	ra,0x3
    34ae:	a54080e7          	jalr	-1452(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    34b2:	4505                	li	a0,1
    34b4:	00002097          	auipc	ra,0x2
    34b8:	6da080e7          	jalr	1754(ra) # 5b8e <exit>
    printf("%s: chdir / failed\n", s);
<<<<<<< HEAD
    34c2:	85a6                	mv	a1,s1
    34c4:	00004517          	auipc	a0,0x4
    34c8:	f4450513          	addi	a0,a0,-188 # 7408 <malloc+0x1404>
    34cc:	00003097          	auipc	ra,0x3
    34d0:	a7a080e7          	jalr	-1414(ra) # 5f46 <printf>
=======
    34bc:	85a6                	mv	a1,s1
    34be:	00004517          	auipc	a0,0x4
    34c2:	eda50513          	addi	a0,a0,-294 # 7398 <malloc+0x13e2>
    34c6:	00003097          	auipc	ra,0x3
    34ca:	a38080e7          	jalr	-1480(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    34ce:	4505                	li	a0,1
    34d0:	00002097          	auipc	ra,0x2
    34d4:	6be080e7          	jalr	1726(ra) # 5b8e <exit>

00000000000034d8 <exitiputtest>:
{
    34d8:	7179                	addi	sp,sp,-48
    34da:	f406                	sd	ra,40(sp)
    34dc:	f022                	sd	s0,32(sp)
    34de:	ec26                	sd	s1,24(sp)
    34e0:	1800                	addi	s0,sp,48
    34e2:	84aa                	mv	s1,a0
  pid = fork();
    34e4:	00002097          	auipc	ra,0x2
    34e8:	6a2080e7          	jalr	1698(ra) # 5b86 <fork>
  if(pid < 0){
    34ec:	04054663          	bltz	a0,3538 <exitiputtest+0x60>
  if(pid == 0){
    34f0:	ed45                	bnez	a0,35a8 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
<<<<<<< HEAD
    34f8:	00004517          	auipc	a0,0x4
    34fc:	e9850513          	addi	a0,a0,-360 # 7390 <malloc+0x138c>
    3500:	00002097          	auipc	ra,0x2
    3504:	72e080e7          	jalr	1838(ra) # 5c2e <mkdir>
    3508:	04054963          	bltz	a0,355a <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    350c:	00004517          	auipc	a0,0x4
    3510:	e8450513          	addi	a0,a0,-380 # 7390 <malloc+0x138c>
    3514:	00002097          	auipc	ra,0x2
    3518:	722080e7          	jalr	1826(ra) # 5c36 <chdir>
    351c:	04054d63          	bltz	a0,3576 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    3520:	00004517          	auipc	a0,0x4
    3524:	eb050513          	addi	a0,a0,-336 # 73d0 <malloc+0x13cc>
    3528:	00002097          	auipc	ra,0x2
    352c:	6ee080e7          	jalr	1774(ra) # 5c16 <unlink>
    3530:	06054163          	bltz	a0,3592 <exitiputtest+0xb4>
=======
    34f2:	00004517          	auipc	a0,0x4
    34f6:	e2e50513          	addi	a0,a0,-466 # 7320 <malloc+0x136a>
    34fa:	00002097          	auipc	ra,0x2
    34fe:	6fc080e7          	jalr	1788(ra) # 5bf6 <mkdir>
    3502:	04054963          	bltz	a0,3554 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    3506:	00004517          	auipc	a0,0x4
    350a:	e1a50513          	addi	a0,a0,-486 # 7320 <malloc+0x136a>
    350e:	00002097          	auipc	ra,0x2
    3512:	6f0080e7          	jalr	1776(ra) # 5bfe <chdir>
    3516:	04054d63          	bltz	a0,3570 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    351a:	00004517          	auipc	a0,0x4
    351e:	e4650513          	addi	a0,a0,-442 # 7360 <malloc+0x13aa>
    3522:	00002097          	auipc	ra,0x2
    3526:	6bc080e7          	jalr	1724(ra) # 5bde <unlink>
    352a:	06054163          	bltz	a0,358c <exitiputtest+0xb4>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(0);
    352e:	4501                	li	a0,0
    3530:	00002097          	auipc	ra,0x2
    3534:	65e080e7          	jalr	1630(ra) # 5b8e <exit>
    printf("%s: fork failed\n", s);
<<<<<<< HEAD
    353e:	85a6                	mv	a1,s1
    3540:	00003517          	auipc	a0,0x3
    3544:	49050513          	addi	a0,a0,1168 # 69d0 <malloc+0x9cc>
    3548:	00003097          	auipc	ra,0x3
    354c:	9fe080e7          	jalr	-1538(ra) # 5f46 <printf>
=======
    3538:	85a6                	mv	a1,s1
    353a:	00003517          	auipc	a0,0x3
    353e:	42650513          	addi	a0,a0,1062 # 6960 <malloc+0x9aa>
    3542:	00003097          	auipc	ra,0x3
    3546:	9bc080e7          	jalr	-1604(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    354a:	4505                	li	a0,1
    354c:	00002097          	auipc	ra,0x2
    3550:	642080e7          	jalr	1602(ra) # 5b8e <exit>
      printf("%s: mkdir failed\n", s);
<<<<<<< HEAD
    355a:	85a6                	mv	a1,s1
    355c:	00004517          	auipc	a0,0x4
    3560:	e3c50513          	addi	a0,a0,-452 # 7398 <malloc+0x1394>
    3564:	00003097          	auipc	ra,0x3
    3568:	9e2080e7          	jalr	-1566(ra) # 5f46 <printf>
=======
    3554:	85a6                	mv	a1,s1
    3556:	00004517          	auipc	a0,0x4
    355a:	dd250513          	addi	a0,a0,-558 # 7328 <malloc+0x1372>
    355e:	00003097          	auipc	ra,0x3
    3562:	9a0080e7          	jalr	-1632(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    3566:	4505                	li	a0,1
    3568:	00002097          	auipc	ra,0x2
    356c:	626080e7          	jalr	1574(ra) # 5b8e <exit>
      printf("%s: child chdir failed\n", s);
<<<<<<< HEAD
    3576:	85a6                	mv	a1,s1
    3578:	00004517          	auipc	a0,0x4
    357c:	ea850513          	addi	a0,a0,-344 # 7420 <malloc+0x141c>
    3580:	00003097          	auipc	ra,0x3
    3584:	9c6080e7          	jalr	-1594(ra) # 5f46 <printf>
=======
    3570:	85a6                	mv	a1,s1
    3572:	00004517          	auipc	a0,0x4
    3576:	e3e50513          	addi	a0,a0,-450 # 73b0 <malloc+0x13fa>
    357a:	00003097          	auipc	ra,0x3
    357e:	984080e7          	jalr	-1660(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    3582:	4505                	li	a0,1
    3584:	00002097          	auipc	ra,0x2
    3588:	60a080e7          	jalr	1546(ra) # 5b8e <exit>
      printf("%s: unlink ../iputdir failed\n", s);
<<<<<<< HEAD
    3592:	85a6                	mv	a1,s1
    3594:	00004517          	auipc	a0,0x4
    3598:	e4c50513          	addi	a0,a0,-436 # 73e0 <malloc+0x13dc>
    359c:	00003097          	auipc	ra,0x3
    35a0:	9aa080e7          	jalr	-1622(ra) # 5f46 <printf>
=======
    358c:	85a6                	mv	a1,s1
    358e:	00004517          	auipc	a0,0x4
    3592:	de250513          	addi	a0,a0,-542 # 7370 <malloc+0x13ba>
    3596:	00003097          	auipc	ra,0x3
    359a:	968080e7          	jalr	-1688(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    359e:	4505                	li	a0,1
    35a0:	00002097          	auipc	ra,0x2
    35a4:	5ee080e7          	jalr	1518(ra) # 5b8e <exit>
  wait(&xstatus);
    35a8:	fdc40513          	addi	a0,s0,-36
    35ac:	00002097          	auipc	ra,0x2
    35b0:	5ea080e7          	jalr	1514(ra) # 5b96 <wait>
  exit(xstatus);
    35b4:	fdc42503          	lw	a0,-36(s0)
    35b8:	00002097          	auipc	ra,0x2
    35bc:	5d6080e7          	jalr	1494(ra) # 5b8e <exit>

00000000000035c0 <dirtest>:
{
    35c0:	1101                	addi	sp,sp,-32
    35c2:	ec06                	sd	ra,24(sp)
    35c4:	e822                	sd	s0,16(sp)
    35c6:	e426                	sd	s1,8(sp)
    35c8:	1000                	addi	s0,sp,32
    35ca:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
<<<<<<< HEAD
    35d2:	00004517          	auipc	a0,0x4
    35d6:	e6650513          	addi	a0,a0,-410 # 7438 <malloc+0x1434>
    35da:	00002097          	auipc	ra,0x2
    35de:	654080e7          	jalr	1620(ra) # 5c2e <mkdir>
    35e2:	04054563          	bltz	a0,362c <dirtest+0x66>
  if(chdir("dir0") < 0){
    35e6:	00004517          	auipc	a0,0x4
    35ea:	e5250513          	addi	a0,a0,-430 # 7438 <malloc+0x1434>
    35ee:	00002097          	auipc	ra,0x2
    35f2:	648080e7          	jalr	1608(ra) # 5c36 <chdir>
    35f6:	04054963          	bltz	a0,3648 <dirtest+0x82>
  if(chdir("..") < 0){
    35fa:	00004517          	auipc	a0,0x4
    35fe:	e5e50513          	addi	a0,a0,-418 # 7458 <malloc+0x1454>
    3602:	00002097          	auipc	ra,0x2
    3606:	634080e7          	jalr	1588(ra) # 5c36 <chdir>
    360a:	04054d63          	bltz	a0,3664 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    360e:	00004517          	auipc	a0,0x4
    3612:	e2a50513          	addi	a0,a0,-470 # 7438 <malloc+0x1434>
    3616:	00002097          	auipc	ra,0x2
    361a:	600080e7          	jalr	1536(ra) # 5c16 <unlink>
    361e:	06054163          	bltz	a0,3680 <dirtest+0xba>
=======
    35cc:	00004517          	auipc	a0,0x4
    35d0:	dfc50513          	addi	a0,a0,-516 # 73c8 <malloc+0x1412>
    35d4:	00002097          	auipc	ra,0x2
    35d8:	622080e7          	jalr	1570(ra) # 5bf6 <mkdir>
    35dc:	04054563          	bltz	a0,3626 <dirtest+0x66>
  if(chdir("dir0") < 0){
    35e0:	00004517          	auipc	a0,0x4
    35e4:	de850513          	addi	a0,a0,-536 # 73c8 <malloc+0x1412>
    35e8:	00002097          	auipc	ra,0x2
    35ec:	616080e7          	jalr	1558(ra) # 5bfe <chdir>
    35f0:	04054963          	bltz	a0,3642 <dirtest+0x82>
  if(chdir("..") < 0){
    35f4:	00004517          	auipc	a0,0x4
    35f8:	df450513          	addi	a0,a0,-524 # 73e8 <malloc+0x1432>
    35fc:	00002097          	auipc	ra,0x2
    3600:	602080e7          	jalr	1538(ra) # 5bfe <chdir>
    3604:	04054d63          	bltz	a0,365e <dirtest+0x9e>
  if(unlink("dir0") < 0){
    3608:	00004517          	auipc	a0,0x4
    360c:	dc050513          	addi	a0,a0,-576 # 73c8 <malloc+0x1412>
    3610:	00002097          	auipc	ra,0x2
    3614:	5ce080e7          	jalr	1486(ra) # 5bde <unlink>
    3618:	06054163          	bltz	a0,367a <dirtest+0xba>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    361c:	60e2                	ld	ra,24(sp)
    361e:	6442                	ld	s0,16(sp)
    3620:	64a2                	ld	s1,8(sp)
    3622:	6105                	addi	sp,sp,32
    3624:	8082                	ret
    printf("%s: mkdir failed\n", s);
<<<<<<< HEAD
    362c:	85a6                	mv	a1,s1
    362e:	00004517          	auipc	a0,0x4
    3632:	d6a50513          	addi	a0,a0,-662 # 7398 <malloc+0x1394>
    3636:	00003097          	auipc	ra,0x3
    363a:	910080e7          	jalr	-1776(ra) # 5f46 <printf>
=======
    3626:	85a6                	mv	a1,s1
    3628:	00004517          	auipc	a0,0x4
    362c:	d0050513          	addi	a0,a0,-768 # 7328 <malloc+0x1372>
    3630:	00003097          	auipc	ra,0x3
    3634:	8ce080e7          	jalr	-1842(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3638:	4505                	li	a0,1
    363a:	00002097          	auipc	ra,0x2
    363e:	554080e7          	jalr	1364(ra) # 5b8e <exit>
    printf("%s: chdir dir0 failed\n", s);
<<<<<<< HEAD
    3648:	85a6                	mv	a1,s1
    364a:	00004517          	auipc	a0,0x4
    364e:	df650513          	addi	a0,a0,-522 # 7440 <malloc+0x143c>
    3652:	00003097          	auipc	ra,0x3
    3656:	8f4080e7          	jalr	-1804(ra) # 5f46 <printf>
=======
    3642:	85a6                	mv	a1,s1
    3644:	00004517          	auipc	a0,0x4
    3648:	d8c50513          	addi	a0,a0,-628 # 73d0 <malloc+0x141a>
    364c:	00003097          	auipc	ra,0x3
    3650:	8b2080e7          	jalr	-1870(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3654:	4505                	li	a0,1
    3656:	00002097          	auipc	ra,0x2
    365a:	538080e7          	jalr	1336(ra) # 5b8e <exit>
    printf("%s: chdir .. failed\n", s);
<<<<<<< HEAD
    3664:	85a6                	mv	a1,s1
    3666:	00004517          	auipc	a0,0x4
    366a:	dfa50513          	addi	a0,a0,-518 # 7460 <malloc+0x145c>
    366e:	00003097          	auipc	ra,0x3
    3672:	8d8080e7          	jalr	-1832(ra) # 5f46 <printf>
=======
    365e:	85a6                	mv	a1,s1
    3660:	00004517          	auipc	a0,0x4
    3664:	d9050513          	addi	a0,a0,-624 # 73f0 <malloc+0x143a>
    3668:	00003097          	auipc	ra,0x3
    366c:	896080e7          	jalr	-1898(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3670:	4505                	li	a0,1
    3672:	00002097          	auipc	ra,0x2
    3676:	51c080e7          	jalr	1308(ra) # 5b8e <exit>
    printf("%s: unlink dir0 failed\n", s);
<<<<<<< HEAD
    3680:	85a6                	mv	a1,s1
    3682:	00004517          	auipc	a0,0x4
    3686:	df650513          	addi	a0,a0,-522 # 7478 <malloc+0x1474>
    368a:	00003097          	auipc	ra,0x3
    368e:	8bc080e7          	jalr	-1860(ra) # 5f46 <printf>
=======
    367a:	85a6                	mv	a1,s1
    367c:	00004517          	auipc	a0,0x4
    3680:	d8c50513          	addi	a0,a0,-628 # 7408 <malloc+0x1452>
    3684:	00003097          	auipc	ra,0x3
    3688:	87a080e7          	jalr	-1926(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    368c:	4505                	li	a0,1
    368e:	00002097          	auipc	ra,0x2
    3692:	500080e7          	jalr	1280(ra) # 5b8e <exit>

0000000000003696 <subdir>:
{
    3696:	1101                	addi	sp,sp,-32
    3698:	ec06                	sd	ra,24(sp)
    369a:	e822                	sd	s0,16(sp)
    369c:	e426                	sd	s1,8(sp)
    369e:	e04a                	sd	s2,0(sp)
    36a0:	1000                	addi	s0,sp,32
    36a2:	892a                	mv	s2,a0
  unlink("ff");
<<<<<<< HEAD
    36aa:	00004517          	auipc	a0,0x4
    36ae:	f1650513          	addi	a0,a0,-234 # 75c0 <malloc+0x15bc>
    36b2:	00002097          	auipc	ra,0x2
    36b6:	564080e7          	jalr	1380(ra) # 5c16 <unlink>
  if(mkdir("dd") != 0){
    36ba:	00004517          	auipc	a0,0x4
    36be:	dd650513          	addi	a0,a0,-554 # 7490 <malloc+0x148c>
    36c2:	00002097          	auipc	ra,0x2
    36c6:	56c080e7          	jalr	1388(ra) # 5c2e <mkdir>
    36ca:	38051663          	bnez	a0,3a56 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    36ce:	20200593          	li	a1,514
    36d2:	00004517          	auipc	a0,0x4
    36d6:	dde50513          	addi	a0,a0,-546 # 74b0 <malloc+0x14ac>
    36da:	00002097          	auipc	ra,0x2
    36de:	52c080e7          	jalr	1324(ra) # 5c06 <open>
    36e2:	84aa                	mv	s1,a0
=======
    36a4:	00004517          	auipc	a0,0x4
    36a8:	eac50513          	addi	a0,a0,-340 # 7550 <malloc+0x159a>
    36ac:	00002097          	auipc	ra,0x2
    36b0:	532080e7          	jalr	1330(ra) # 5bde <unlink>
  if(mkdir("dd") != 0){
    36b4:	00004517          	auipc	a0,0x4
    36b8:	d6c50513          	addi	a0,a0,-660 # 7420 <malloc+0x146a>
    36bc:	00002097          	auipc	ra,0x2
    36c0:	53a080e7          	jalr	1338(ra) # 5bf6 <mkdir>
    36c4:	38051663          	bnez	a0,3a50 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    36c8:	20200593          	li	a1,514
    36cc:	00004517          	auipc	a0,0x4
    36d0:	d7450513          	addi	a0,a0,-652 # 7440 <malloc+0x148a>
    36d4:	00002097          	auipc	ra,0x2
    36d8:	4fa080e7          	jalr	1274(ra) # 5bce <open>
    36dc:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    36de:	38054763          	bltz	a0,3a6c <subdir+0x3d6>
  write(fd, "ff", 2);
<<<<<<< HEAD
    36e8:	4609                	li	a2,2
    36ea:	00004597          	auipc	a1,0x4
    36ee:	ed658593          	addi	a1,a1,-298 # 75c0 <malloc+0x15bc>
    36f2:	00002097          	auipc	ra,0x2
    36f6:	4f4080e7          	jalr	1268(ra) # 5be6 <write>
=======
    36e2:	4609                	li	a2,2
    36e4:	00004597          	auipc	a1,0x4
    36e8:	e6c58593          	addi	a1,a1,-404 # 7550 <malloc+0x159a>
    36ec:	00002097          	auipc	ra,0x2
    36f0:	4c2080e7          	jalr	1218(ra) # 5bae <write>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd);
    36f4:	8526                	mv	a0,s1
    36f6:	00002097          	auipc	ra,0x2
    36fa:	4c0080e7          	jalr	1216(ra) # 5bb6 <close>
  if(unlink("dd") >= 0){
<<<<<<< HEAD
    3704:	00004517          	auipc	a0,0x4
    3708:	d8c50513          	addi	a0,a0,-628 # 7490 <malloc+0x148c>
    370c:	00002097          	auipc	ra,0x2
    3710:	50a080e7          	jalr	1290(ra) # 5c16 <unlink>
    3714:	36055d63          	bgez	a0,3a8e <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    3718:	00004517          	auipc	a0,0x4
    371c:	df050513          	addi	a0,a0,-528 # 7508 <malloc+0x1504>
    3720:	00002097          	auipc	ra,0x2
    3724:	50e080e7          	jalr	1294(ra) # 5c2e <mkdir>
    3728:	38051163          	bnez	a0,3aaa <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    372c:	20200593          	li	a1,514
    3730:	00004517          	auipc	a0,0x4
    3734:	e0050513          	addi	a0,a0,-512 # 7530 <malloc+0x152c>
    3738:	00002097          	auipc	ra,0x2
    373c:	4ce080e7          	jalr	1230(ra) # 5c06 <open>
    3740:	84aa                	mv	s1,a0
=======
    36fe:	00004517          	auipc	a0,0x4
    3702:	d2250513          	addi	a0,a0,-734 # 7420 <malloc+0x146a>
    3706:	00002097          	auipc	ra,0x2
    370a:	4d8080e7          	jalr	1240(ra) # 5bde <unlink>
    370e:	36055d63          	bgez	a0,3a88 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    3712:	00004517          	auipc	a0,0x4
    3716:	d8650513          	addi	a0,a0,-634 # 7498 <malloc+0x14e2>
    371a:	00002097          	auipc	ra,0x2
    371e:	4dc080e7          	jalr	1244(ra) # 5bf6 <mkdir>
    3722:	38051163          	bnez	a0,3aa4 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3726:	20200593          	li	a1,514
    372a:	00004517          	auipc	a0,0x4
    372e:	d9650513          	addi	a0,a0,-618 # 74c0 <malloc+0x150a>
    3732:	00002097          	auipc	ra,0x2
    3736:	49c080e7          	jalr	1180(ra) # 5bce <open>
    373a:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    373c:	38054263          	bltz	a0,3ac0 <subdir+0x42a>
  write(fd, "FF", 2);
<<<<<<< HEAD
    3746:	4609                	li	a2,2
    3748:	00004597          	auipc	a1,0x4
    374c:	e1858593          	addi	a1,a1,-488 # 7560 <malloc+0x155c>
    3750:	00002097          	auipc	ra,0x2
    3754:	496080e7          	jalr	1174(ra) # 5be6 <write>
=======
    3740:	4609                	li	a2,2
    3742:	00004597          	auipc	a1,0x4
    3746:	dae58593          	addi	a1,a1,-594 # 74f0 <malloc+0x153a>
    374a:	00002097          	auipc	ra,0x2
    374e:	464080e7          	jalr	1124(ra) # 5bae <write>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd);
    3752:	8526                	mv	a0,s1
    3754:	00002097          	auipc	ra,0x2
    3758:	462080e7          	jalr	1122(ra) # 5bb6 <close>
  fd = open("dd/dd/../ff", 0);
<<<<<<< HEAD
    3762:	4581                	li	a1,0
    3764:	00004517          	auipc	a0,0x4
    3768:	e0450513          	addi	a0,a0,-508 # 7568 <malloc+0x1564>
    376c:	00002097          	auipc	ra,0x2
    3770:	49a080e7          	jalr	1178(ra) # 5c06 <open>
    3774:	84aa                	mv	s1,a0
=======
    375c:	4581                	li	a1,0
    375e:	00004517          	auipc	a0,0x4
    3762:	d9a50513          	addi	a0,a0,-614 # 74f8 <malloc+0x1542>
    3766:	00002097          	auipc	ra,0x2
    376a:	468080e7          	jalr	1128(ra) # 5bce <open>
    376e:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    3770:	36054663          	bltz	a0,3adc <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3774:	660d                	lui	a2,0x3
    3776:	00009597          	auipc	a1,0x9
    377a:	50258593          	addi	a1,a1,1282 # cc78 <buf>
    377e:	00002097          	auipc	ra,0x2
    3782:	428080e7          	jalr	1064(ra) # 5ba6 <read>
  if(cc != 2 || buf[0] != 'f'){
    3786:	4789                	li	a5,2
    3788:	36f51863          	bne	a0,a5,3af8 <subdir+0x462>
    378c:	00009717          	auipc	a4,0x9
    3790:	4ec74703          	lbu	a4,1260(a4) # cc78 <buf>
    3794:	06600793          	li	a5,102
    3798:	36f71063          	bne	a4,a5,3af8 <subdir+0x462>
  close(fd);
    379c:	8526                	mv	a0,s1
    379e:	00002097          	auipc	ra,0x2
    37a2:	418080e7          	jalr	1048(ra) # 5bb6 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
<<<<<<< HEAD
    37ac:	00004597          	auipc	a1,0x4
    37b0:	e0c58593          	addi	a1,a1,-500 # 75b8 <malloc+0x15b4>
    37b4:	00004517          	auipc	a0,0x4
    37b8:	d7c50513          	addi	a0,a0,-644 # 7530 <malloc+0x152c>
    37bc:	00002097          	auipc	ra,0x2
    37c0:	46a080e7          	jalr	1130(ra) # 5c26 <link>
    37c4:	34051b63          	bnez	a0,3b1a <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    37c8:	00004517          	auipc	a0,0x4
    37cc:	d6850513          	addi	a0,a0,-664 # 7530 <malloc+0x152c>
    37d0:	00002097          	auipc	ra,0x2
    37d4:	446080e7          	jalr	1094(ra) # 5c16 <unlink>
    37d8:	34051f63          	bnez	a0,3b36 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    37dc:	4581                	li	a1,0
    37de:	00004517          	auipc	a0,0x4
    37e2:	d5250513          	addi	a0,a0,-686 # 7530 <malloc+0x152c>
    37e6:	00002097          	auipc	ra,0x2
    37ea:	420080e7          	jalr	1056(ra) # 5c06 <open>
    37ee:	36055263          	bgez	a0,3b52 <subdir+0x4b6>
  if(chdir("dd") != 0){
    37f2:	00004517          	auipc	a0,0x4
    37f6:	c9e50513          	addi	a0,a0,-866 # 7490 <malloc+0x148c>
    37fa:	00002097          	auipc	ra,0x2
    37fe:	43c080e7          	jalr	1084(ra) # 5c36 <chdir>
    3802:	36051663          	bnez	a0,3b6e <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    3806:	00004517          	auipc	a0,0x4
    380a:	e4a50513          	addi	a0,a0,-438 # 7650 <malloc+0x164c>
    380e:	00002097          	auipc	ra,0x2
    3812:	428080e7          	jalr	1064(ra) # 5c36 <chdir>
    3816:	36051a63          	bnez	a0,3b8a <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    381a:	00004517          	auipc	a0,0x4
    381e:	e6650513          	addi	a0,a0,-410 # 7680 <malloc+0x167c>
    3822:	00002097          	auipc	ra,0x2
    3826:	414080e7          	jalr	1044(ra) # 5c36 <chdir>
    382a:	36051e63          	bnez	a0,3ba6 <subdir+0x50a>
  if(chdir("./..") != 0){
    382e:	00004517          	auipc	a0,0x4
    3832:	e8250513          	addi	a0,a0,-382 # 76b0 <malloc+0x16ac>
    3836:	00002097          	auipc	ra,0x2
    383a:	400080e7          	jalr	1024(ra) # 5c36 <chdir>
    383e:	38051263          	bnez	a0,3bc2 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3842:	4581                	li	a1,0
    3844:	00004517          	auipc	a0,0x4
    3848:	d7450513          	addi	a0,a0,-652 # 75b8 <malloc+0x15b4>
    384c:	00002097          	auipc	ra,0x2
    3850:	3ba080e7          	jalr	954(ra) # 5c06 <open>
    3854:	84aa                	mv	s1,a0
=======
    37a6:	00004597          	auipc	a1,0x4
    37aa:	da258593          	addi	a1,a1,-606 # 7548 <malloc+0x1592>
    37ae:	00004517          	auipc	a0,0x4
    37b2:	d1250513          	addi	a0,a0,-750 # 74c0 <malloc+0x150a>
    37b6:	00002097          	auipc	ra,0x2
    37ba:	438080e7          	jalr	1080(ra) # 5bee <link>
    37be:	34051b63          	bnez	a0,3b14 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    37c2:	00004517          	auipc	a0,0x4
    37c6:	cfe50513          	addi	a0,a0,-770 # 74c0 <malloc+0x150a>
    37ca:	00002097          	auipc	ra,0x2
    37ce:	414080e7          	jalr	1044(ra) # 5bde <unlink>
    37d2:	34051f63          	bnez	a0,3b30 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    37d6:	4581                	li	a1,0
    37d8:	00004517          	auipc	a0,0x4
    37dc:	ce850513          	addi	a0,a0,-792 # 74c0 <malloc+0x150a>
    37e0:	00002097          	auipc	ra,0x2
    37e4:	3ee080e7          	jalr	1006(ra) # 5bce <open>
    37e8:	36055263          	bgez	a0,3b4c <subdir+0x4b6>
  if(chdir("dd") != 0){
    37ec:	00004517          	auipc	a0,0x4
    37f0:	c3450513          	addi	a0,a0,-972 # 7420 <malloc+0x146a>
    37f4:	00002097          	auipc	ra,0x2
    37f8:	40a080e7          	jalr	1034(ra) # 5bfe <chdir>
    37fc:	36051663          	bnez	a0,3b68 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    3800:	00004517          	auipc	a0,0x4
    3804:	de050513          	addi	a0,a0,-544 # 75e0 <malloc+0x162a>
    3808:	00002097          	auipc	ra,0x2
    380c:	3f6080e7          	jalr	1014(ra) # 5bfe <chdir>
    3810:	36051a63          	bnez	a0,3b84 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3814:	00004517          	auipc	a0,0x4
    3818:	dfc50513          	addi	a0,a0,-516 # 7610 <malloc+0x165a>
    381c:	00002097          	auipc	ra,0x2
    3820:	3e2080e7          	jalr	994(ra) # 5bfe <chdir>
    3824:	36051e63          	bnez	a0,3ba0 <subdir+0x50a>
  if(chdir("./..") != 0){
    3828:	00004517          	auipc	a0,0x4
    382c:	e1850513          	addi	a0,a0,-488 # 7640 <malloc+0x168a>
    3830:	00002097          	auipc	ra,0x2
    3834:	3ce080e7          	jalr	974(ra) # 5bfe <chdir>
    3838:	38051263          	bnez	a0,3bbc <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    383c:	4581                	li	a1,0
    383e:	00004517          	auipc	a0,0x4
    3842:	d0a50513          	addi	a0,a0,-758 # 7548 <malloc+0x1592>
    3846:	00002097          	auipc	ra,0x2
    384a:	388080e7          	jalr	904(ra) # 5bce <open>
    384e:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    3850:	38054463          	bltz	a0,3bd8 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3854:	660d                	lui	a2,0x3
    3856:	00009597          	auipc	a1,0x9
    385a:	42258593          	addi	a1,a1,1058 # cc78 <buf>
    385e:	00002097          	auipc	ra,0x2
    3862:	348080e7          	jalr	840(ra) # 5ba6 <read>
    3866:	4789                	li	a5,2
    3868:	38f51663          	bne	a0,a5,3bf4 <subdir+0x55e>
  close(fd);
    386c:	8526                	mv	a0,s1
    386e:	00002097          	auipc	ra,0x2
    3872:	348080e7          	jalr	840(ra) # 5bb6 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
<<<<<<< HEAD
    387c:	4581                	li	a1,0
    387e:	00004517          	auipc	a0,0x4
    3882:	cb250513          	addi	a0,a0,-846 # 7530 <malloc+0x152c>
    3886:	00002097          	auipc	ra,0x2
    388a:	380080e7          	jalr	896(ra) # 5c06 <open>
    388e:	38055463          	bgez	a0,3c16 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3892:	20200593          	li	a1,514
    3896:	00004517          	auipc	a0,0x4
    389a:	eaa50513          	addi	a0,a0,-342 # 7740 <malloc+0x173c>
    389e:	00002097          	auipc	ra,0x2
    38a2:	368080e7          	jalr	872(ra) # 5c06 <open>
    38a6:	38055663          	bgez	a0,3c32 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    38aa:	20200593          	li	a1,514
    38ae:	00004517          	auipc	a0,0x4
    38b2:	ec250513          	addi	a0,a0,-318 # 7770 <malloc+0x176c>
    38b6:	00002097          	auipc	ra,0x2
    38ba:	350080e7          	jalr	848(ra) # 5c06 <open>
    38be:	38055863          	bgez	a0,3c4e <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    38c2:	20000593          	li	a1,512
    38c6:	00004517          	auipc	a0,0x4
    38ca:	bca50513          	addi	a0,a0,-1078 # 7490 <malloc+0x148c>
    38ce:	00002097          	auipc	ra,0x2
    38d2:	338080e7          	jalr	824(ra) # 5c06 <open>
    38d6:	38055a63          	bgez	a0,3c6a <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    38da:	4589                	li	a1,2
    38dc:	00004517          	auipc	a0,0x4
    38e0:	bb450513          	addi	a0,a0,-1100 # 7490 <malloc+0x148c>
    38e4:	00002097          	auipc	ra,0x2
    38e8:	322080e7          	jalr	802(ra) # 5c06 <open>
    38ec:	38055d63          	bgez	a0,3c86 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    38f0:	4585                	li	a1,1
    38f2:	00004517          	auipc	a0,0x4
    38f6:	b9e50513          	addi	a0,a0,-1122 # 7490 <malloc+0x148c>
    38fa:	00002097          	auipc	ra,0x2
    38fe:	30c080e7          	jalr	780(ra) # 5c06 <open>
    3902:	3a055063          	bgez	a0,3ca2 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3906:	00004597          	auipc	a1,0x4
    390a:	efa58593          	addi	a1,a1,-262 # 7800 <malloc+0x17fc>
    390e:	00004517          	auipc	a0,0x4
    3912:	e3250513          	addi	a0,a0,-462 # 7740 <malloc+0x173c>
    3916:	00002097          	auipc	ra,0x2
    391a:	310080e7          	jalr	784(ra) # 5c26 <link>
    391e:	3a050063          	beqz	a0,3cbe <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3922:	00004597          	auipc	a1,0x4
    3926:	ede58593          	addi	a1,a1,-290 # 7800 <malloc+0x17fc>
    392a:	00004517          	auipc	a0,0x4
    392e:	e4650513          	addi	a0,a0,-442 # 7770 <malloc+0x176c>
    3932:	00002097          	auipc	ra,0x2
    3936:	2f4080e7          	jalr	756(ra) # 5c26 <link>
    393a:	3a050063          	beqz	a0,3cda <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    393e:	00004597          	auipc	a1,0x4
    3942:	c7a58593          	addi	a1,a1,-902 # 75b8 <malloc+0x15b4>
    3946:	00004517          	auipc	a0,0x4
    394a:	b6a50513          	addi	a0,a0,-1174 # 74b0 <malloc+0x14ac>
    394e:	00002097          	auipc	ra,0x2
    3952:	2d8080e7          	jalr	728(ra) # 5c26 <link>
    3956:	3a050063          	beqz	a0,3cf6 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    395a:	00004517          	auipc	a0,0x4
    395e:	de650513          	addi	a0,a0,-538 # 7740 <malloc+0x173c>
    3962:	00002097          	auipc	ra,0x2
    3966:	2cc080e7          	jalr	716(ra) # 5c2e <mkdir>
    396a:	3a050463          	beqz	a0,3d12 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    396e:	00004517          	auipc	a0,0x4
    3972:	e0250513          	addi	a0,a0,-510 # 7770 <malloc+0x176c>
    3976:	00002097          	auipc	ra,0x2
    397a:	2b8080e7          	jalr	696(ra) # 5c2e <mkdir>
    397e:	3a050863          	beqz	a0,3d2e <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3982:	00004517          	auipc	a0,0x4
    3986:	c3650513          	addi	a0,a0,-970 # 75b8 <malloc+0x15b4>
    398a:	00002097          	auipc	ra,0x2
    398e:	2a4080e7          	jalr	676(ra) # 5c2e <mkdir>
    3992:	3a050c63          	beqz	a0,3d4a <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3996:	00004517          	auipc	a0,0x4
    399a:	dda50513          	addi	a0,a0,-550 # 7770 <malloc+0x176c>
    399e:	00002097          	auipc	ra,0x2
    39a2:	278080e7          	jalr	632(ra) # 5c16 <unlink>
    39a6:	3c050063          	beqz	a0,3d66 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    39aa:	00004517          	auipc	a0,0x4
    39ae:	d9650513          	addi	a0,a0,-618 # 7740 <malloc+0x173c>
    39b2:	00002097          	auipc	ra,0x2
    39b6:	264080e7          	jalr	612(ra) # 5c16 <unlink>
    39ba:	3c050463          	beqz	a0,3d82 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    39be:	00004517          	auipc	a0,0x4
    39c2:	af250513          	addi	a0,a0,-1294 # 74b0 <malloc+0x14ac>
    39c6:	00002097          	auipc	ra,0x2
    39ca:	270080e7          	jalr	624(ra) # 5c36 <chdir>
    39ce:	3c050863          	beqz	a0,3d9e <subdir+0x702>
  if(chdir("dd/xx") == 0){
    39d2:	00004517          	auipc	a0,0x4
    39d6:	f7e50513          	addi	a0,a0,-130 # 7950 <malloc+0x194c>
    39da:	00002097          	auipc	ra,0x2
    39de:	25c080e7          	jalr	604(ra) # 5c36 <chdir>
    39e2:	3c050c63          	beqz	a0,3dba <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    39e6:	00004517          	auipc	a0,0x4
    39ea:	bd250513          	addi	a0,a0,-1070 # 75b8 <malloc+0x15b4>
    39ee:	00002097          	auipc	ra,0x2
    39f2:	228080e7          	jalr	552(ra) # 5c16 <unlink>
    39f6:	3e051063          	bnez	a0,3dd6 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    39fa:	00004517          	auipc	a0,0x4
    39fe:	ab650513          	addi	a0,a0,-1354 # 74b0 <malloc+0x14ac>
    3a02:	00002097          	auipc	ra,0x2
    3a06:	214080e7          	jalr	532(ra) # 5c16 <unlink>
    3a0a:	3e051463          	bnez	a0,3df2 <subdir+0x756>
  if(unlink("dd") == 0){
    3a0e:	00004517          	auipc	a0,0x4
    3a12:	a8250513          	addi	a0,a0,-1406 # 7490 <malloc+0x148c>
    3a16:	00002097          	auipc	ra,0x2
    3a1a:	200080e7          	jalr	512(ra) # 5c16 <unlink>
    3a1e:	3e050863          	beqz	a0,3e0e <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3a22:	00004517          	auipc	a0,0x4
    3a26:	f9e50513          	addi	a0,a0,-98 # 79c0 <malloc+0x19bc>
    3a2a:	00002097          	auipc	ra,0x2
    3a2e:	1ec080e7          	jalr	492(ra) # 5c16 <unlink>
    3a32:	3e054c63          	bltz	a0,3e2a <subdir+0x78e>
  if(unlink("dd") < 0){
    3a36:	00004517          	auipc	a0,0x4
    3a3a:	a5a50513          	addi	a0,a0,-1446 # 7490 <malloc+0x148c>
    3a3e:	00002097          	auipc	ra,0x2
    3a42:	1d8080e7          	jalr	472(ra) # 5c16 <unlink>
    3a46:	40054063          	bltz	a0,3e46 <subdir+0x7aa>
=======
    3876:	4581                	li	a1,0
    3878:	00004517          	auipc	a0,0x4
    387c:	c4850513          	addi	a0,a0,-952 # 74c0 <malloc+0x150a>
    3880:	00002097          	auipc	ra,0x2
    3884:	34e080e7          	jalr	846(ra) # 5bce <open>
    3888:	38055463          	bgez	a0,3c10 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    388c:	20200593          	li	a1,514
    3890:	00004517          	auipc	a0,0x4
    3894:	e4050513          	addi	a0,a0,-448 # 76d0 <malloc+0x171a>
    3898:	00002097          	auipc	ra,0x2
    389c:	336080e7          	jalr	822(ra) # 5bce <open>
    38a0:	38055663          	bgez	a0,3c2c <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    38a4:	20200593          	li	a1,514
    38a8:	00004517          	auipc	a0,0x4
    38ac:	e5850513          	addi	a0,a0,-424 # 7700 <malloc+0x174a>
    38b0:	00002097          	auipc	ra,0x2
    38b4:	31e080e7          	jalr	798(ra) # 5bce <open>
    38b8:	38055863          	bgez	a0,3c48 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    38bc:	20000593          	li	a1,512
    38c0:	00004517          	auipc	a0,0x4
    38c4:	b6050513          	addi	a0,a0,-1184 # 7420 <malloc+0x146a>
    38c8:	00002097          	auipc	ra,0x2
    38cc:	306080e7          	jalr	774(ra) # 5bce <open>
    38d0:	38055a63          	bgez	a0,3c64 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    38d4:	4589                	li	a1,2
    38d6:	00004517          	auipc	a0,0x4
    38da:	b4a50513          	addi	a0,a0,-1206 # 7420 <malloc+0x146a>
    38de:	00002097          	auipc	ra,0x2
    38e2:	2f0080e7          	jalr	752(ra) # 5bce <open>
    38e6:	38055d63          	bgez	a0,3c80 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    38ea:	4585                	li	a1,1
    38ec:	00004517          	auipc	a0,0x4
    38f0:	b3450513          	addi	a0,a0,-1228 # 7420 <malloc+0x146a>
    38f4:	00002097          	auipc	ra,0x2
    38f8:	2da080e7          	jalr	730(ra) # 5bce <open>
    38fc:	3a055063          	bgez	a0,3c9c <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3900:	00004597          	auipc	a1,0x4
    3904:	e9058593          	addi	a1,a1,-368 # 7790 <malloc+0x17da>
    3908:	00004517          	auipc	a0,0x4
    390c:	dc850513          	addi	a0,a0,-568 # 76d0 <malloc+0x171a>
    3910:	00002097          	auipc	ra,0x2
    3914:	2de080e7          	jalr	734(ra) # 5bee <link>
    3918:	3a050063          	beqz	a0,3cb8 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    391c:	00004597          	auipc	a1,0x4
    3920:	e7458593          	addi	a1,a1,-396 # 7790 <malloc+0x17da>
    3924:	00004517          	auipc	a0,0x4
    3928:	ddc50513          	addi	a0,a0,-548 # 7700 <malloc+0x174a>
    392c:	00002097          	auipc	ra,0x2
    3930:	2c2080e7          	jalr	706(ra) # 5bee <link>
    3934:	3a050063          	beqz	a0,3cd4 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3938:	00004597          	auipc	a1,0x4
    393c:	c1058593          	addi	a1,a1,-1008 # 7548 <malloc+0x1592>
    3940:	00004517          	auipc	a0,0x4
    3944:	b0050513          	addi	a0,a0,-1280 # 7440 <malloc+0x148a>
    3948:	00002097          	auipc	ra,0x2
    394c:	2a6080e7          	jalr	678(ra) # 5bee <link>
    3950:	3a050063          	beqz	a0,3cf0 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3954:	00004517          	auipc	a0,0x4
    3958:	d7c50513          	addi	a0,a0,-644 # 76d0 <malloc+0x171a>
    395c:	00002097          	auipc	ra,0x2
    3960:	29a080e7          	jalr	666(ra) # 5bf6 <mkdir>
    3964:	3a050463          	beqz	a0,3d0c <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3968:	00004517          	auipc	a0,0x4
    396c:	d9850513          	addi	a0,a0,-616 # 7700 <malloc+0x174a>
    3970:	00002097          	auipc	ra,0x2
    3974:	286080e7          	jalr	646(ra) # 5bf6 <mkdir>
    3978:	3a050863          	beqz	a0,3d28 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    397c:	00004517          	auipc	a0,0x4
    3980:	bcc50513          	addi	a0,a0,-1076 # 7548 <malloc+0x1592>
    3984:	00002097          	auipc	ra,0x2
    3988:	272080e7          	jalr	626(ra) # 5bf6 <mkdir>
    398c:	3a050c63          	beqz	a0,3d44 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3990:	00004517          	auipc	a0,0x4
    3994:	d7050513          	addi	a0,a0,-656 # 7700 <malloc+0x174a>
    3998:	00002097          	auipc	ra,0x2
    399c:	246080e7          	jalr	582(ra) # 5bde <unlink>
    39a0:	3c050063          	beqz	a0,3d60 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    39a4:	00004517          	auipc	a0,0x4
    39a8:	d2c50513          	addi	a0,a0,-724 # 76d0 <malloc+0x171a>
    39ac:	00002097          	auipc	ra,0x2
    39b0:	232080e7          	jalr	562(ra) # 5bde <unlink>
    39b4:	3c050463          	beqz	a0,3d7c <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    39b8:	00004517          	auipc	a0,0x4
    39bc:	a8850513          	addi	a0,a0,-1400 # 7440 <malloc+0x148a>
    39c0:	00002097          	auipc	ra,0x2
    39c4:	23e080e7          	jalr	574(ra) # 5bfe <chdir>
    39c8:	3c050863          	beqz	a0,3d98 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    39cc:	00004517          	auipc	a0,0x4
    39d0:	f1450513          	addi	a0,a0,-236 # 78e0 <malloc+0x192a>
    39d4:	00002097          	auipc	ra,0x2
    39d8:	22a080e7          	jalr	554(ra) # 5bfe <chdir>
    39dc:	3c050c63          	beqz	a0,3db4 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    39e0:	00004517          	auipc	a0,0x4
    39e4:	b6850513          	addi	a0,a0,-1176 # 7548 <malloc+0x1592>
    39e8:	00002097          	auipc	ra,0x2
    39ec:	1f6080e7          	jalr	502(ra) # 5bde <unlink>
    39f0:	3e051063          	bnez	a0,3dd0 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    39f4:	00004517          	auipc	a0,0x4
    39f8:	a4c50513          	addi	a0,a0,-1460 # 7440 <malloc+0x148a>
    39fc:	00002097          	auipc	ra,0x2
    3a00:	1e2080e7          	jalr	482(ra) # 5bde <unlink>
    3a04:	3e051463          	bnez	a0,3dec <subdir+0x756>
  if(unlink("dd") == 0){
    3a08:	00004517          	auipc	a0,0x4
    3a0c:	a1850513          	addi	a0,a0,-1512 # 7420 <malloc+0x146a>
    3a10:	00002097          	auipc	ra,0x2
    3a14:	1ce080e7          	jalr	462(ra) # 5bde <unlink>
    3a18:	3e050863          	beqz	a0,3e08 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3a1c:	00004517          	auipc	a0,0x4
    3a20:	f3450513          	addi	a0,a0,-204 # 7950 <malloc+0x199a>
    3a24:	00002097          	auipc	ra,0x2
    3a28:	1ba080e7          	jalr	442(ra) # 5bde <unlink>
    3a2c:	3e054c63          	bltz	a0,3e24 <subdir+0x78e>
  if(unlink("dd") < 0){
    3a30:	00004517          	auipc	a0,0x4
    3a34:	9f050513          	addi	a0,a0,-1552 # 7420 <malloc+0x146a>
    3a38:	00002097          	auipc	ra,0x2
    3a3c:	1a6080e7          	jalr	422(ra) # 5bde <unlink>
    3a40:	40054063          	bltz	a0,3e40 <subdir+0x7aa>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    3a44:	60e2                	ld	ra,24(sp)
    3a46:	6442                	ld	s0,16(sp)
    3a48:	64a2                	ld	s1,8(sp)
    3a4a:	6902                	ld	s2,0(sp)
    3a4c:	6105                	addi	sp,sp,32
    3a4e:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
<<<<<<< HEAD
    3a56:	85ca                	mv	a1,s2
    3a58:	00004517          	auipc	a0,0x4
    3a5c:	a4050513          	addi	a0,a0,-1472 # 7498 <malloc+0x1494>
    3a60:	00002097          	auipc	ra,0x2
    3a64:	4e6080e7          	jalr	1254(ra) # 5f46 <printf>
=======
    3a50:	85ca                	mv	a1,s2
    3a52:	00004517          	auipc	a0,0x4
    3a56:	9d650513          	addi	a0,a0,-1578 # 7428 <malloc+0x1472>
    3a5a:	00002097          	auipc	ra,0x2
    3a5e:	4a4080e7          	jalr	1188(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3a62:	4505                	li	a0,1
    3a64:	00002097          	auipc	ra,0x2
    3a68:	12a080e7          	jalr	298(ra) # 5b8e <exit>
    printf("%s: create dd/ff failed\n", s);
<<<<<<< HEAD
    3a72:	85ca                	mv	a1,s2
    3a74:	00004517          	auipc	a0,0x4
    3a78:	a4450513          	addi	a0,a0,-1468 # 74b8 <malloc+0x14b4>
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	4ca080e7          	jalr	1226(ra) # 5f46 <printf>
=======
    3a6c:	85ca                	mv	a1,s2
    3a6e:	00004517          	auipc	a0,0x4
    3a72:	9da50513          	addi	a0,a0,-1574 # 7448 <malloc+0x1492>
    3a76:	00002097          	auipc	ra,0x2
    3a7a:	488080e7          	jalr	1160(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3a7e:	4505                	li	a0,1
    3a80:	00002097          	auipc	ra,0x2
    3a84:	10e080e7          	jalr	270(ra) # 5b8e <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
<<<<<<< HEAD
    3a8e:	85ca                	mv	a1,s2
    3a90:	00004517          	auipc	a0,0x4
    3a94:	a4850513          	addi	a0,a0,-1464 # 74d8 <malloc+0x14d4>
    3a98:	00002097          	auipc	ra,0x2
    3a9c:	4ae080e7          	jalr	1198(ra) # 5f46 <printf>
=======
    3a88:	85ca                	mv	a1,s2
    3a8a:	00004517          	auipc	a0,0x4
    3a8e:	9de50513          	addi	a0,a0,-1570 # 7468 <malloc+0x14b2>
    3a92:	00002097          	auipc	ra,0x2
    3a96:	46c080e7          	jalr	1132(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3a9a:	4505                	li	a0,1
    3a9c:	00002097          	auipc	ra,0x2
    3aa0:	0f2080e7          	jalr	242(ra) # 5b8e <exit>
    printf("subdir mkdir dd/dd failed\n", s);
<<<<<<< HEAD
    3aaa:	85ca                	mv	a1,s2
    3aac:	00004517          	auipc	a0,0x4
    3ab0:	a6450513          	addi	a0,a0,-1436 # 7510 <malloc+0x150c>
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	492080e7          	jalr	1170(ra) # 5f46 <printf>
=======
    3aa4:	85ca                	mv	a1,s2
    3aa6:	00004517          	auipc	a0,0x4
    3aaa:	9fa50513          	addi	a0,a0,-1542 # 74a0 <malloc+0x14ea>
    3aae:	00002097          	auipc	ra,0x2
    3ab2:	450080e7          	jalr	1104(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3ab6:	4505                	li	a0,1
    3ab8:	00002097          	auipc	ra,0x2
    3abc:	0d6080e7          	jalr	214(ra) # 5b8e <exit>
    printf("%s: create dd/dd/ff failed\n", s);
<<<<<<< HEAD
    3ac6:	85ca                	mv	a1,s2
    3ac8:	00004517          	auipc	a0,0x4
    3acc:	a7850513          	addi	a0,a0,-1416 # 7540 <malloc+0x153c>
    3ad0:	00002097          	auipc	ra,0x2
    3ad4:	476080e7          	jalr	1142(ra) # 5f46 <printf>
=======
    3ac0:	85ca                	mv	a1,s2
    3ac2:	00004517          	auipc	a0,0x4
    3ac6:	a0e50513          	addi	a0,a0,-1522 # 74d0 <malloc+0x151a>
    3aca:	00002097          	auipc	ra,0x2
    3ace:	434080e7          	jalr	1076(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3ad2:	4505                	li	a0,1
    3ad4:	00002097          	auipc	ra,0x2
    3ad8:	0ba080e7          	jalr	186(ra) # 5b8e <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
<<<<<<< HEAD
    3ae2:	85ca                	mv	a1,s2
    3ae4:	00004517          	auipc	a0,0x4
    3ae8:	a9450513          	addi	a0,a0,-1388 # 7578 <malloc+0x1574>
    3aec:	00002097          	auipc	ra,0x2
    3af0:	45a080e7          	jalr	1114(ra) # 5f46 <printf>
=======
    3adc:	85ca                	mv	a1,s2
    3ade:	00004517          	auipc	a0,0x4
    3ae2:	a2a50513          	addi	a0,a0,-1494 # 7508 <malloc+0x1552>
    3ae6:	00002097          	auipc	ra,0x2
    3aea:	418080e7          	jalr	1048(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3aee:	4505                	li	a0,1
    3af0:	00002097          	auipc	ra,0x2
    3af4:	09e080e7          	jalr	158(ra) # 5b8e <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
<<<<<<< HEAD
    3afe:	85ca                	mv	a1,s2
    3b00:	00004517          	auipc	a0,0x4
    3b04:	a9850513          	addi	a0,a0,-1384 # 7598 <malloc+0x1594>
    3b08:	00002097          	auipc	ra,0x2
    3b0c:	43e080e7          	jalr	1086(ra) # 5f46 <printf>
=======
    3af8:	85ca                	mv	a1,s2
    3afa:	00004517          	auipc	a0,0x4
    3afe:	a2e50513          	addi	a0,a0,-1490 # 7528 <malloc+0x1572>
    3b02:	00002097          	auipc	ra,0x2
    3b06:	3fc080e7          	jalr	1020(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3b0a:	4505                	li	a0,1
    3b0c:	00002097          	auipc	ra,0x2
    3b10:	082080e7          	jalr	130(ra) # 5b8e <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
<<<<<<< HEAD
    3b1a:	85ca                	mv	a1,s2
    3b1c:	00004517          	auipc	a0,0x4
    3b20:	aac50513          	addi	a0,a0,-1364 # 75c8 <malloc+0x15c4>
    3b24:	00002097          	auipc	ra,0x2
    3b28:	422080e7          	jalr	1058(ra) # 5f46 <printf>
=======
    3b14:	85ca                	mv	a1,s2
    3b16:	00004517          	auipc	a0,0x4
    3b1a:	a4250513          	addi	a0,a0,-1470 # 7558 <malloc+0x15a2>
    3b1e:	00002097          	auipc	ra,0x2
    3b22:	3e0080e7          	jalr	992(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3b26:	4505                	li	a0,1
    3b28:	00002097          	auipc	ra,0x2
    3b2c:	066080e7          	jalr	102(ra) # 5b8e <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
<<<<<<< HEAD
    3b36:	85ca                	mv	a1,s2
    3b38:	00004517          	auipc	a0,0x4
    3b3c:	ab850513          	addi	a0,a0,-1352 # 75f0 <malloc+0x15ec>
    3b40:	00002097          	auipc	ra,0x2
    3b44:	406080e7          	jalr	1030(ra) # 5f46 <printf>
=======
    3b30:	85ca                	mv	a1,s2
    3b32:	00004517          	auipc	a0,0x4
    3b36:	a4e50513          	addi	a0,a0,-1458 # 7580 <malloc+0x15ca>
    3b3a:	00002097          	auipc	ra,0x2
    3b3e:	3c4080e7          	jalr	964(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3b42:	4505                	li	a0,1
    3b44:	00002097          	auipc	ra,0x2
    3b48:	04a080e7          	jalr	74(ra) # 5b8e <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
<<<<<<< HEAD
    3b52:	85ca                	mv	a1,s2
    3b54:	00004517          	auipc	a0,0x4
    3b58:	abc50513          	addi	a0,a0,-1348 # 7610 <malloc+0x160c>
    3b5c:	00002097          	auipc	ra,0x2
    3b60:	3ea080e7          	jalr	1002(ra) # 5f46 <printf>
=======
    3b4c:	85ca                	mv	a1,s2
    3b4e:	00004517          	auipc	a0,0x4
    3b52:	a5250513          	addi	a0,a0,-1454 # 75a0 <malloc+0x15ea>
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	3a8080e7          	jalr	936(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3b5e:	4505                	li	a0,1
    3b60:	00002097          	auipc	ra,0x2
    3b64:	02e080e7          	jalr	46(ra) # 5b8e <exit>
    printf("%s: chdir dd failed\n", s);
<<<<<<< HEAD
    3b6e:	85ca                	mv	a1,s2
    3b70:	00004517          	auipc	a0,0x4
    3b74:	ac850513          	addi	a0,a0,-1336 # 7638 <malloc+0x1634>
    3b78:	00002097          	auipc	ra,0x2
    3b7c:	3ce080e7          	jalr	974(ra) # 5f46 <printf>
=======
    3b68:	85ca                	mv	a1,s2
    3b6a:	00004517          	auipc	a0,0x4
    3b6e:	a5e50513          	addi	a0,a0,-1442 # 75c8 <malloc+0x1612>
    3b72:	00002097          	auipc	ra,0x2
    3b76:	38c080e7          	jalr	908(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3b7a:	4505                	li	a0,1
    3b7c:	00002097          	auipc	ra,0x2
    3b80:	012080e7          	jalr	18(ra) # 5b8e <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
<<<<<<< HEAD
    3b8a:	85ca                	mv	a1,s2
    3b8c:	00004517          	auipc	a0,0x4
    3b90:	ad450513          	addi	a0,a0,-1324 # 7660 <malloc+0x165c>
    3b94:	00002097          	auipc	ra,0x2
    3b98:	3b2080e7          	jalr	946(ra) # 5f46 <printf>
=======
    3b84:	85ca                	mv	a1,s2
    3b86:	00004517          	auipc	a0,0x4
    3b8a:	a6a50513          	addi	a0,a0,-1430 # 75f0 <malloc+0x163a>
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	370080e7          	jalr	880(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3b96:	4505                	li	a0,1
    3b98:	00002097          	auipc	ra,0x2
    3b9c:	ff6080e7          	jalr	-10(ra) # 5b8e <exit>
    printf("chdir dd/../../dd failed\n", s);
<<<<<<< HEAD
    3ba6:	85ca                	mv	a1,s2
    3ba8:	00004517          	auipc	a0,0x4
    3bac:	ae850513          	addi	a0,a0,-1304 # 7690 <malloc+0x168c>
    3bb0:	00002097          	auipc	ra,0x2
    3bb4:	396080e7          	jalr	918(ra) # 5f46 <printf>
=======
    3ba0:	85ca                	mv	a1,s2
    3ba2:	00004517          	auipc	a0,0x4
    3ba6:	a7e50513          	addi	a0,a0,-1410 # 7620 <malloc+0x166a>
    3baa:	00002097          	auipc	ra,0x2
    3bae:	354080e7          	jalr	852(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3bb2:	4505                	li	a0,1
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	fda080e7          	jalr	-38(ra) # 5b8e <exit>
    printf("%s: chdir ./.. failed\n", s);
<<<<<<< HEAD
    3bc2:	85ca                	mv	a1,s2
    3bc4:	00004517          	auipc	a0,0x4
    3bc8:	af450513          	addi	a0,a0,-1292 # 76b8 <malloc+0x16b4>
    3bcc:	00002097          	auipc	ra,0x2
    3bd0:	37a080e7          	jalr	890(ra) # 5f46 <printf>
=======
    3bbc:	85ca                	mv	a1,s2
    3bbe:	00004517          	auipc	a0,0x4
    3bc2:	a8a50513          	addi	a0,a0,-1398 # 7648 <malloc+0x1692>
    3bc6:	00002097          	auipc	ra,0x2
    3bca:	338080e7          	jalr	824(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3bce:	4505                	li	a0,1
    3bd0:	00002097          	auipc	ra,0x2
    3bd4:	fbe080e7          	jalr	-66(ra) # 5b8e <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
<<<<<<< HEAD
    3bde:	85ca                	mv	a1,s2
    3be0:	00004517          	auipc	a0,0x4
    3be4:	af050513          	addi	a0,a0,-1296 # 76d0 <malloc+0x16cc>
    3be8:	00002097          	auipc	ra,0x2
    3bec:	35e080e7          	jalr	862(ra) # 5f46 <printf>
=======
    3bd8:	85ca                	mv	a1,s2
    3bda:	00004517          	auipc	a0,0x4
    3bde:	a8650513          	addi	a0,a0,-1402 # 7660 <malloc+0x16aa>
    3be2:	00002097          	auipc	ra,0x2
    3be6:	31c080e7          	jalr	796(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3bea:	4505                	li	a0,1
    3bec:	00002097          	auipc	ra,0x2
    3bf0:	fa2080e7          	jalr	-94(ra) # 5b8e <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
<<<<<<< HEAD
    3bfa:	85ca                	mv	a1,s2
    3bfc:	00004517          	auipc	a0,0x4
    3c00:	af450513          	addi	a0,a0,-1292 # 76f0 <malloc+0x16ec>
    3c04:	00002097          	auipc	ra,0x2
    3c08:	342080e7          	jalr	834(ra) # 5f46 <printf>
=======
    3bf4:	85ca                	mv	a1,s2
    3bf6:	00004517          	auipc	a0,0x4
    3bfa:	a8a50513          	addi	a0,a0,-1398 # 7680 <malloc+0x16ca>
    3bfe:	00002097          	auipc	ra,0x2
    3c02:	300080e7          	jalr	768(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3c06:	4505                	li	a0,1
    3c08:	00002097          	auipc	ra,0x2
    3c0c:	f86080e7          	jalr	-122(ra) # 5b8e <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
<<<<<<< HEAD
    3c16:	85ca                	mv	a1,s2
    3c18:	00004517          	auipc	a0,0x4
    3c1c:	af850513          	addi	a0,a0,-1288 # 7710 <malloc+0x170c>
    3c20:	00002097          	auipc	ra,0x2
    3c24:	326080e7          	jalr	806(ra) # 5f46 <printf>
=======
    3c10:	85ca                	mv	a1,s2
    3c12:	00004517          	auipc	a0,0x4
    3c16:	a8e50513          	addi	a0,a0,-1394 # 76a0 <malloc+0x16ea>
    3c1a:	00002097          	auipc	ra,0x2
    3c1e:	2e4080e7          	jalr	740(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3c22:	4505                	li	a0,1
    3c24:	00002097          	auipc	ra,0x2
    3c28:	f6a080e7          	jalr	-150(ra) # 5b8e <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
<<<<<<< HEAD
    3c32:	85ca                	mv	a1,s2
    3c34:	00004517          	auipc	a0,0x4
    3c38:	b1c50513          	addi	a0,a0,-1252 # 7750 <malloc+0x174c>
    3c3c:	00002097          	auipc	ra,0x2
    3c40:	30a080e7          	jalr	778(ra) # 5f46 <printf>
=======
    3c2c:	85ca                	mv	a1,s2
    3c2e:	00004517          	auipc	a0,0x4
    3c32:	ab250513          	addi	a0,a0,-1358 # 76e0 <malloc+0x172a>
    3c36:	00002097          	auipc	ra,0x2
    3c3a:	2c8080e7          	jalr	712(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3c3e:	4505                	li	a0,1
    3c40:	00002097          	auipc	ra,0x2
    3c44:	f4e080e7          	jalr	-178(ra) # 5b8e <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
<<<<<<< HEAD
    3c4e:	85ca                	mv	a1,s2
    3c50:	00004517          	auipc	a0,0x4
    3c54:	b3050513          	addi	a0,a0,-1232 # 7780 <malloc+0x177c>
    3c58:	00002097          	auipc	ra,0x2
    3c5c:	2ee080e7          	jalr	750(ra) # 5f46 <printf>
=======
    3c48:	85ca                	mv	a1,s2
    3c4a:	00004517          	auipc	a0,0x4
    3c4e:	ac650513          	addi	a0,a0,-1338 # 7710 <malloc+0x175a>
    3c52:	00002097          	auipc	ra,0x2
    3c56:	2ac080e7          	jalr	684(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3c5a:	4505                	li	a0,1
    3c5c:	00002097          	auipc	ra,0x2
    3c60:	f32080e7          	jalr	-206(ra) # 5b8e <exit>
    printf("%s: create dd succeeded!\n", s);
<<<<<<< HEAD
    3c6a:	85ca                	mv	a1,s2
    3c6c:	00004517          	auipc	a0,0x4
    3c70:	b3450513          	addi	a0,a0,-1228 # 77a0 <malloc+0x179c>
    3c74:	00002097          	auipc	ra,0x2
    3c78:	2d2080e7          	jalr	722(ra) # 5f46 <printf>
=======
    3c64:	85ca                	mv	a1,s2
    3c66:	00004517          	auipc	a0,0x4
    3c6a:	aca50513          	addi	a0,a0,-1334 # 7730 <malloc+0x177a>
    3c6e:	00002097          	auipc	ra,0x2
    3c72:	290080e7          	jalr	656(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3c76:	4505                	li	a0,1
    3c78:	00002097          	auipc	ra,0x2
    3c7c:	f16080e7          	jalr	-234(ra) # 5b8e <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
<<<<<<< HEAD
    3c86:	85ca                	mv	a1,s2
    3c88:	00004517          	auipc	a0,0x4
    3c8c:	b3850513          	addi	a0,a0,-1224 # 77c0 <malloc+0x17bc>
    3c90:	00002097          	auipc	ra,0x2
    3c94:	2b6080e7          	jalr	694(ra) # 5f46 <printf>
=======
    3c80:	85ca                	mv	a1,s2
    3c82:	00004517          	auipc	a0,0x4
    3c86:	ace50513          	addi	a0,a0,-1330 # 7750 <malloc+0x179a>
    3c8a:	00002097          	auipc	ra,0x2
    3c8e:	274080e7          	jalr	628(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3c92:	4505                	li	a0,1
    3c94:	00002097          	auipc	ra,0x2
    3c98:	efa080e7          	jalr	-262(ra) # 5b8e <exit>
    printf("%s: open dd wronly succeeded!\n", s);
<<<<<<< HEAD
    3ca2:	85ca                	mv	a1,s2
    3ca4:	00004517          	auipc	a0,0x4
    3ca8:	b3c50513          	addi	a0,a0,-1220 # 77e0 <malloc+0x17dc>
    3cac:	00002097          	auipc	ra,0x2
    3cb0:	29a080e7          	jalr	666(ra) # 5f46 <printf>
=======
    3c9c:	85ca                	mv	a1,s2
    3c9e:	00004517          	auipc	a0,0x4
    3ca2:	ad250513          	addi	a0,a0,-1326 # 7770 <malloc+0x17ba>
    3ca6:	00002097          	auipc	ra,0x2
    3caa:	258080e7          	jalr	600(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3cae:	4505                	li	a0,1
    3cb0:	00002097          	auipc	ra,0x2
    3cb4:	ede080e7          	jalr	-290(ra) # 5b8e <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
<<<<<<< HEAD
    3cbe:	85ca                	mv	a1,s2
    3cc0:	00004517          	auipc	a0,0x4
    3cc4:	b5050513          	addi	a0,a0,-1200 # 7810 <malloc+0x180c>
    3cc8:	00002097          	auipc	ra,0x2
    3ccc:	27e080e7          	jalr	638(ra) # 5f46 <printf>
=======
    3cb8:	85ca                	mv	a1,s2
    3cba:	00004517          	auipc	a0,0x4
    3cbe:	ae650513          	addi	a0,a0,-1306 # 77a0 <malloc+0x17ea>
    3cc2:	00002097          	auipc	ra,0x2
    3cc6:	23c080e7          	jalr	572(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3cca:	4505                	li	a0,1
    3ccc:	00002097          	auipc	ra,0x2
    3cd0:	ec2080e7          	jalr	-318(ra) # 5b8e <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
<<<<<<< HEAD
    3cda:	85ca                	mv	a1,s2
    3cdc:	00004517          	auipc	a0,0x4
    3ce0:	b5c50513          	addi	a0,a0,-1188 # 7838 <malloc+0x1834>
    3ce4:	00002097          	auipc	ra,0x2
    3ce8:	262080e7          	jalr	610(ra) # 5f46 <printf>
=======
    3cd4:	85ca                	mv	a1,s2
    3cd6:	00004517          	auipc	a0,0x4
    3cda:	af250513          	addi	a0,a0,-1294 # 77c8 <malloc+0x1812>
    3cde:	00002097          	auipc	ra,0x2
    3ce2:	220080e7          	jalr	544(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3ce6:	4505                	li	a0,1
    3ce8:	00002097          	auipc	ra,0x2
    3cec:	ea6080e7          	jalr	-346(ra) # 5b8e <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
<<<<<<< HEAD
    3cf6:	85ca                	mv	a1,s2
    3cf8:	00004517          	auipc	a0,0x4
    3cfc:	b6850513          	addi	a0,a0,-1176 # 7860 <malloc+0x185c>
    3d00:	00002097          	auipc	ra,0x2
    3d04:	246080e7          	jalr	582(ra) # 5f46 <printf>
=======
    3cf0:	85ca                	mv	a1,s2
    3cf2:	00004517          	auipc	a0,0x4
    3cf6:	afe50513          	addi	a0,a0,-1282 # 77f0 <malloc+0x183a>
    3cfa:	00002097          	auipc	ra,0x2
    3cfe:	204080e7          	jalr	516(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3d02:	4505                	li	a0,1
    3d04:	00002097          	auipc	ra,0x2
    3d08:	e8a080e7          	jalr	-374(ra) # 5b8e <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
<<<<<<< HEAD
    3d12:	85ca                	mv	a1,s2
    3d14:	00004517          	auipc	a0,0x4
    3d18:	b7450513          	addi	a0,a0,-1164 # 7888 <malloc+0x1884>
    3d1c:	00002097          	auipc	ra,0x2
    3d20:	22a080e7          	jalr	554(ra) # 5f46 <printf>
=======
    3d0c:	85ca                	mv	a1,s2
    3d0e:	00004517          	auipc	a0,0x4
    3d12:	b0a50513          	addi	a0,a0,-1270 # 7818 <malloc+0x1862>
    3d16:	00002097          	auipc	ra,0x2
    3d1a:	1e8080e7          	jalr	488(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3d1e:	4505                	li	a0,1
    3d20:	00002097          	auipc	ra,0x2
    3d24:	e6e080e7          	jalr	-402(ra) # 5b8e <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
<<<<<<< HEAD
    3d2e:	85ca                	mv	a1,s2
    3d30:	00004517          	auipc	a0,0x4
    3d34:	b7850513          	addi	a0,a0,-1160 # 78a8 <malloc+0x18a4>
    3d38:	00002097          	auipc	ra,0x2
    3d3c:	20e080e7          	jalr	526(ra) # 5f46 <printf>
=======
    3d28:	85ca                	mv	a1,s2
    3d2a:	00004517          	auipc	a0,0x4
    3d2e:	b0e50513          	addi	a0,a0,-1266 # 7838 <malloc+0x1882>
    3d32:	00002097          	auipc	ra,0x2
    3d36:	1cc080e7          	jalr	460(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3d3a:	4505                	li	a0,1
    3d3c:	00002097          	auipc	ra,0x2
    3d40:	e52080e7          	jalr	-430(ra) # 5b8e <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
<<<<<<< HEAD
    3d4a:	85ca                	mv	a1,s2
    3d4c:	00004517          	auipc	a0,0x4
    3d50:	b7c50513          	addi	a0,a0,-1156 # 78c8 <malloc+0x18c4>
    3d54:	00002097          	auipc	ra,0x2
    3d58:	1f2080e7          	jalr	498(ra) # 5f46 <printf>
=======
    3d44:	85ca                	mv	a1,s2
    3d46:	00004517          	auipc	a0,0x4
    3d4a:	b1250513          	addi	a0,a0,-1262 # 7858 <malloc+0x18a2>
    3d4e:	00002097          	auipc	ra,0x2
    3d52:	1b0080e7          	jalr	432(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3d56:	4505                	li	a0,1
    3d58:	00002097          	auipc	ra,0x2
    3d5c:	e36080e7          	jalr	-458(ra) # 5b8e <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
<<<<<<< HEAD
    3d66:	85ca                	mv	a1,s2
    3d68:	00004517          	auipc	a0,0x4
    3d6c:	b8850513          	addi	a0,a0,-1144 # 78f0 <malloc+0x18ec>
    3d70:	00002097          	auipc	ra,0x2
    3d74:	1d6080e7          	jalr	470(ra) # 5f46 <printf>
=======
    3d60:	85ca                	mv	a1,s2
    3d62:	00004517          	auipc	a0,0x4
    3d66:	b1e50513          	addi	a0,a0,-1250 # 7880 <malloc+0x18ca>
    3d6a:	00002097          	auipc	ra,0x2
    3d6e:	194080e7          	jalr	404(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3d72:	4505                	li	a0,1
    3d74:	00002097          	auipc	ra,0x2
    3d78:	e1a080e7          	jalr	-486(ra) # 5b8e <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
<<<<<<< HEAD
    3d82:	85ca                	mv	a1,s2
    3d84:	00004517          	auipc	a0,0x4
    3d88:	b8c50513          	addi	a0,a0,-1140 # 7910 <malloc+0x190c>
    3d8c:	00002097          	auipc	ra,0x2
    3d90:	1ba080e7          	jalr	442(ra) # 5f46 <printf>
=======
    3d7c:	85ca                	mv	a1,s2
    3d7e:	00004517          	auipc	a0,0x4
    3d82:	b2250513          	addi	a0,a0,-1246 # 78a0 <malloc+0x18ea>
    3d86:	00002097          	auipc	ra,0x2
    3d8a:	178080e7          	jalr	376(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3d8e:	4505                	li	a0,1
    3d90:	00002097          	auipc	ra,0x2
    3d94:	dfe080e7          	jalr	-514(ra) # 5b8e <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
<<<<<<< HEAD
    3d9e:	85ca                	mv	a1,s2
    3da0:	00004517          	auipc	a0,0x4
    3da4:	b9050513          	addi	a0,a0,-1136 # 7930 <malloc+0x192c>
    3da8:	00002097          	auipc	ra,0x2
    3dac:	19e080e7          	jalr	414(ra) # 5f46 <printf>
=======
    3d98:	85ca                	mv	a1,s2
    3d9a:	00004517          	auipc	a0,0x4
    3d9e:	b2650513          	addi	a0,a0,-1242 # 78c0 <malloc+0x190a>
    3da2:	00002097          	auipc	ra,0x2
    3da6:	15c080e7          	jalr	348(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3daa:	4505                	li	a0,1
    3dac:	00002097          	auipc	ra,0x2
    3db0:	de2080e7          	jalr	-542(ra) # 5b8e <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
<<<<<<< HEAD
    3dba:	85ca                	mv	a1,s2
    3dbc:	00004517          	auipc	a0,0x4
    3dc0:	b9c50513          	addi	a0,a0,-1124 # 7958 <malloc+0x1954>
    3dc4:	00002097          	auipc	ra,0x2
    3dc8:	182080e7          	jalr	386(ra) # 5f46 <printf>
=======
    3db4:	85ca                	mv	a1,s2
    3db6:	00004517          	auipc	a0,0x4
    3dba:	b3250513          	addi	a0,a0,-1230 # 78e8 <malloc+0x1932>
    3dbe:	00002097          	auipc	ra,0x2
    3dc2:	140080e7          	jalr	320(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3dc6:	4505                	li	a0,1
    3dc8:	00002097          	auipc	ra,0x2
    3dcc:	dc6080e7          	jalr	-570(ra) # 5b8e <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
<<<<<<< HEAD
    3dd6:	85ca                	mv	a1,s2
    3dd8:	00004517          	auipc	a0,0x4
    3ddc:	81850513          	addi	a0,a0,-2024 # 75f0 <malloc+0x15ec>
    3de0:	00002097          	auipc	ra,0x2
    3de4:	166080e7          	jalr	358(ra) # 5f46 <printf>
=======
    3dd0:	85ca                	mv	a1,s2
    3dd2:	00003517          	auipc	a0,0x3
    3dd6:	7ae50513          	addi	a0,a0,1966 # 7580 <malloc+0x15ca>
    3dda:	00002097          	auipc	ra,0x2
    3dde:	124080e7          	jalr	292(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3de2:	4505                	li	a0,1
    3de4:	00002097          	auipc	ra,0x2
    3de8:	daa080e7          	jalr	-598(ra) # 5b8e <exit>
    printf("%s: unlink dd/ff failed\n", s);
<<<<<<< HEAD
    3df2:	85ca                	mv	a1,s2
    3df4:	00004517          	auipc	a0,0x4
    3df8:	b8450513          	addi	a0,a0,-1148 # 7978 <malloc+0x1974>
    3dfc:	00002097          	auipc	ra,0x2
    3e00:	14a080e7          	jalr	330(ra) # 5f46 <printf>
=======
    3dec:	85ca                	mv	a1,s2
    3dee:	00004517          	auipc	a0,0x4
    3df2:	b1a50513          	addi	a0,a0,-1254 # 7908 <malloc+0x1952>
    3df6:	00002097          	auipc	ra,0x2
    3dfa:	108080e7          	jalr	264(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3dfe:	4505                	li	a0,1
    3e00:	00002097          	auipc	ra,0x2
    3e04:	d8e080e7          	jalr	-626(ra) # 5b8e <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
<<<<<<< HEAD
    3e0e:	85ca                	mv	a1,s2
    3e10:	00004517          	auipc	a0,0x4
    3e14:	b8850513          	addi	a0,a0,-1144 # 7998 <malloc+0x1994>
    3e18:	00002097          	auipc	ra,0x2
    3e1c:	12e080e7          	jalr	302(ra) # 5f46 <printf>
=======
    3e08:	85ca                	mv	a1,s2
    3e0a:	00004517          	auipc	a0,0x4
    3e0e:	b1e50513          	addi	a0,a0,-1250 # 7928 <malloc+0x1972>
    3e12:	00002097          	auipc	ra,0x2
    3e16:	0ec080e7          	jalr	236(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3e1a:	4505                	li	a0,1
    3e1c:	00002097          	auipc	ra,0x2
    3e20:	d72080e7          	jalr	-654(ra) # 5b8e <exit>
    printf("%s: unlink dd/dd failed\n", s);
<<<<<<< HEAD
    3e2a:	85ca                	mv	a1,s2
    3e2c:	00004517          	auipc	a0,0x4
    3e30:	b9c50513          	addi	a0,a0,-1124 # 79c8 <malloc+0x19c4>
    3e34:	00002097          	auipc	ra,0x2
    3e38:	112080e7          	jalr	274(ra) # 5f46 <printf>
=======
    3e24:	85ca                	mv	a1,s2
    3e26:	00004517          	auipc	a0,0x4
    3e2a:	b3250513          	addi	a0,a0,-1230 # 7958 <malloc+0x19a2>
    3e2e:	00002097          	auipc	ra,0x2
    3e32:	0d0080e7          	jalr	208(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3e36:	4505                	li	a0,1
    3e38:	00002097          	auipc	ra,0x2
    3e3c:	d56080e7          	jalr	-682(ra) # 5b8e <exit>
    printf("%s: unlink dd failed\n", s);
<<<<<<< HEAD
    3e46:	85ca                	mv	a1,s2
    3e48:	00004517          	auipc	a0,0x4
    3e4c:	ba050513          	addi	a0,a0,-1120 # 79e8 <malloc+0x19e4>
    3e50:	00002097          	auipc	ra,0x2
    3e54:	0f6080e7          	jalr	246(ra) # 5f46 <printf>
=======
    3e40:	85ca                	mv	a1,s2
    3e42:	00004517          	auipc	a0,0x4
    3e46:	b3650513          	addi	a0,a0,-1226 # 7978 <malloc+0x19c2>
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	0b4080e7          	jalr	180(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3e52:	4505                	li	a0,1
    3e54:	00002097          	auipc	ra,0x2
    3e58:	d3a080e7          	jalr	-710(ra) # 5b8e <exit>

0000000000003e5c <rmdot>:
{
    3e5c:	1101                	addi	sp,sp,-32
    3e5e:	ec06                	sd	ra,24(sp)
    3e60:	e822                	sd	s0,16(sp)
    3e62:	e426                	sd	s1,8(sp)
    3e64:	1000                	addi	s0,sp,32
    3e66:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
<<<<<<< HEAD
    3e6e:	00004517          	auipc	a0,0x4
    3e72:	b9250513          	addi	a0,a0,-1134 # 7a00 <malloc+0x19fc>
    3e76:	00002097          	auipc	ra,0x2
    3e7a:	db8080e7          	jalr	-584(ra) # 5c2e <mkdir>
    3e7e:	e549                	bnez	a0,3f08 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3e80:	00004517          	auipc	a0,0x4
    3e84:	b8050513          	addi	a0,a0,-1152 # 7a00 <malloc+0x19fc>
    3e88:	00002097          	auipc	ra,0x2
    3e8c:	dae080e7          	jalr	-594(ra) # 5c36 <chdir>
    3e90:	e951                	bnez	a0,3f24 <rmdot+0xc2>
  if(unlink(".") == 0){
    3e92:	00003517          	auipc	a0,0x3
    3e96:	99e50513          	addi	a0,a0,-1634 # 6830 <malloc+0x82c>
    3e9a:	00002097          	auipc	ra,0x2
    3e9e:	d7c080e7          	jalr	-644(ra) # 5c16 <unlink>
    3ea2:	cd59                	beqz	a0,3f40 <rmdot+0xde>
  if(unlink("..") == 0){
    3ea4:	00003517          	auipc	a0,0x3
    3ea8:	5b450513          	addi	a0,a0,1460 # 7458 <malloc+0x1454>
    3eac:	00002097          	auipc	ra,0x2
    3eb0:	d6a080e7          	jalr	-662(ra) # 5c16 <unlink>
    3eb4:	c545                	beqz	a0,3f5c <rmdot+0xfa>
  if(chdir("/") != 0){
    3eb6:	00003517          	auipc	a0,0x3
    3eba:	54a50513          	addi	a0,a0,1354 # 7400 <malloc+0x13fc>
    3ebe:	00002097          	auipc	ra,0x2
    3ec2:	d78080e7          	jalr	-648(ra) # 5c36 <chdir>
    3ec6:	e94d                	bnez	a0,3f78 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3ec8:	00004517          	auipc	a0,0x4
    3ecc:	ba050513          	addi	a0,a0,-1120 # 7a68 <malloc+0x1a64>
    3ed0:	00002097          	auipc	ra,0x2
    3ed4:	d46080e7          	jalr	-698(ra) # 5c16 <unlink>
    3ed8:	cd55                	beqz	a0,3f94 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3eda:	00004517          	auipc	a0,0x4
    3ede:	bb650513          	addi	a0,a0,-1098 # 7a90 <malloc+0x1a8c>
    3ee2:	00002097          	auipc	ra,0x2
    3ee6:	d34080e7          	jalr	-716(ra) # 5c16 <unlink>
    3eea:	c179                	beqz	a0,3fb0 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3eec:	00004517          	auipc	a0,0x4
    3ef0:	b1450513          	addi	a0,a0,-1260 # 7a00 <malloc+0x19fc>
    3ef4:	00002097          	auipc	ra,0x2
    3ef8:	d22080e7          	jalr	-734(ra) # 5c16 <unlink>
    3efc:	e961                	bnez	a0,3fcc <rmdot+0x16a>
=======
    3e68:	00004517          	auipc	a0,0x4
    3e6c:	b2850513          	addi	a0,a0,-1240 # 7990 <malloc+0x19da>
    3e70:	00002097          	auipc	ra,0x2
    3e74:	d86080e7          	jalr	-634(ra) # 5bf6 <mkdir>
    3e78:	e549                	bnez	a0,3f02 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3e7a:	00004517          	auipc	a0,0x4
    3e7e:	b1650513          	addi	a0,a0,-1258 # 7990 <malloc+0x19da>
    3e82:	00002097          	auipc	ra,0x2
    3e86:	d7c080e7          	jalr	-644(ra) # 5bfe <chdir>
    3e8a:	e951                	bnez	a0,3f1e <rmdot+0xc2>
  if(unlink(".") == 0){
    3e8c:	00003517          	auipc	a0,0x3
    3e90:	93450513          	addi	a0,a0,-1740 # 67c0 <malloc+0x80a>
    3e94:	00002097          	auipc	ra,0x2
    3e98:	d4a080e7          	jalr	-694(ra) # 5bde <unlink>
    3e9c:	cd59                	beqz	a0,3f3a <rmdot+0xde>
  if(unlink("..") == 0){
    3e9e:	00003517          	auipc	a0,0x3
    3ea2:	54a50513          	addi	a0,a0,1354 # 73e8 <malloc+0x1432>
    3ea6:	00002097          	auipc	ra,0x2
    3eaa:	d38080e7          	jalr	-712(ra) # 5bde <unlink>
    3eae:	c545                	beqz	a0,3f56 <rmdot+0xfa>
  if(chdir("/") != 0){
    3eb0:	00003517          	auipc	a0,0x3
    3eb4:	4e050513          	addi	a0,a0,1248 # 7390 <malloc+0x13da>
    3eb8:	00002097          	auipc	ra,0x2
    3ebc:	d46080e7          	jalr	-698(ra) # 5bfe <chdir>
    3ec0:	e94d                	bnez	a0,3f72 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3ec2:	00004517          	auipc	a0,0x4
    3ec6:	b3650513          	addi	a0,a0,-1226 # 79f8 <malloc+0x1a42>
    3eca:	00002097          	auipc	ra,0x2
    3ece:	d14080e7          	jalr	-748(ra) # 5bde <unlink>
    3ed2:	cd55                	beqz	a0,3f8e <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3ed4:	00004517          	auipc	a0,0x4
    3ed8:	b4c50513          	addi	a0,a0,-1204 # 7a20 <malloc+0x1a6a>
    3edc:	00002097          	auipc	ra,0x2
    3ee0:	d02080e7          	jalr	-766(ra) # 5bde <unlink>
    3ee4:	c179                	beqz	a0,3faa <rmdot+0x14e>
  if(unlink("dots") != 0){
    3ee6:	00004517          	auipc	a0,0x4
    3eea:	aaa50513          	addi	a0,a0,-1366 # 7990 <malloc+0x19da>
    3eee:	00002097          	auipc	ra,0x2
    3ef2:	cf0080e7          	jalr	-784(ra) # 5bde <unlink>
    3ef6:	e961                	bnez	a0,3fc6 <rmdot+0x16a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    3ef8:	60e2                	ld	ra,24(sp)
    3efa:	6442                	ld	s0,16(sp)
    3efc:	64a2                	ld	s1,8(sp)
    3efe:	6105                	addi	sp,sp,32
    3f00:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
<<<<<<< HEAD
    3f08:	85a6                	mv	a1,s1
    3f0a:	00004517          	auipc	a0,0x4
    3f0e:	afe50513          	addi	a0,a0,-1282 # 7a08 <malloc+0x1a04>
    3f12:	00002097          	auipc	ra,0x2
    3f16:	034080e7          	jalr	52(ra) # 5f46 <printf>
=======
    3f02:	85a6                	mv	a1,s1
    3f04:	00004517          	auipc	a0,0x4
    3f08:	a9450513          	addi	a0,a0,-1388 # 7998 <malloc+0x19e2>
    3f0c:	00002097          	auipc	ra,0x2
    3f10:	ff2080e7          	jalr	-14(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3f14:	4505                	li	a0,1
    3f16:	00002097          	auipc	ra,0x2
    3f1a:	c78080e7          	jalr	-904(ra) # 5b8e <exit>
    printf("%s: chdir dots failed\n", s);
<<<<<<< HEAD
    3f24:	85a6                	mv	a1,s1
    3f26:	00004517          	auipc	a0,0x4
    3f2a:	afa50513          	addi	a0,a0,-1286 # 7a20 <malloc+0x1a1c>
    3f2e:	00002097          	auipc	ra,0x2
    3f32:	018080e7          	jalr	24(ra) # 5f46 <printf>
=======
    3f1e:	85a6                	mv	a1,s1
    3f20:	00004517          	auipc	a0,0x4
    3f24:	a9050513          	addi	a0,a0,-1392 # 79b0 <malloc+0x19fa>
    3f28:	00002097          	auipc	ra,0x2
    3f2c:	fd6080e7          	jalr	-42(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3f30:	4505                	li	a0,1
    3f32:	00002097          	auipc	ra,0x2
    3f36:	c5c080e7          	jalr	-932(ra) # 5b8e <exit>
    printf("%s: rm . worked!\n", s);
<<<<<<< HEAD
    3f40:	85a6                	mv	a1,s1
    3f42:	00004517          	auipc	a0,0x4
    3f46:	af650513          	addi	a0,a0,-1290 # 7a38 <malloc+0x1a34>
    3f4a:	00002097          	auipc	ra,0x2
    3f4e:	ffc080e7          	jalr	-4(ra) # 5f46 <printf>
=======
    3f3a:	85a6                	mv	a1,s1
    3f3c:	00004517          	auipc	a0,0x4
    3f40:	a8c50513          	addi	a0,a0,-1396 # 79c8 <malloc+0x1a12>
    3f44:	00002097          	auipc	ra,0x2
    3f48:	fba080e7          	jalr	-70(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3f4c:	4505                	li	a0,1
    3f4e:	00002097          	auipc	ra,0x2
    3f52:	c40080e7          	jalr	-960(ra) # 5b8e <exit>
    printf("%s: rm .. worked!\n", s);
<<<<<<< HEAD
    3f5c:	85a6                	mv	a1,s1
    3f5e:	00004517          	auipc	a0,0x4
    3f62:	af250513          	addi	a0,a0,-1294 # 7a50 <malloc+0x1a4c>
    3f66:	00002097          	auipc	ra,0x2
    3f6a:	fe0080e7          	jalr	-32(ra) # 5f46 <printf>
=======
    3f56:	85a6                	mv	a1,s1
    3f58:	00004517          	auipc	a0,0x4
    3f5c:	a8850513          	addi	a0,a0,-1400 # 79e0 <malloc+0x1a2a>
    3f60:	00002097          	auipc	ra,0x2
    3f64:	f9e080e7          	jalr	-98(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3f68:	4505                	li	a0,1
    3f6a:	00002097          	auipc	ra,0x2
    3f6e:	c24080e7          	jalr	-988(ra) # 5b8e <exit>
    printf("%s: chdir / failed\n", s);
<<<<<<< HEAD
    3f78:	85a6                	mv	a1,s1
    3f7a:	00003517          	auipc	a0,0x3
    3f7e:	48e50513          	addi	a0,a0,1166 # 7408 <malloc+0x1404>
    3f82:	00002097          	auipc	ra,0x2
    3f86:	fc4080e7          	jalr	-60(ra) # 5f46 <printf>
=======
    3f72:	85a6                	mv	a1,s1
    3f74:	00003517          	auipc	a0,0x3
    3f78:	42450513          	addi	a0,a0,1060 # 7398 <malloc+0x13e2>
    3f7c:	00002097          	auipc	ra,0x2
    3f80:	f82080e7          	jalr	-126(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3f84:	4505                	li	a0,1
    3f86:	00002097          	auipc	ra,0x2
    3f8a:	c08080e7          	jalr	-1016(ra) # 5b8e <exit>
    printf("%s: unlink dots/. worked!\n", s);
<<<<<<< HEAD
    3f94:	85a6                	mv	a1,s1
    3f96:	00004517          	auipc	a0,0x4
    3f9a:	ada50513          	addi	a0,a0,-1318 # 7a70 <malloc+0x1a6c>
    3f9e:	00002097          	auipc	ra,0x2
    3fa2:	fa8080e7          	jalr	-88(ra) # 5f46 <printf>
=======
    3f8e:	85a6                	mv	a1,s1
    3f90:	00004517          	auipc	a0,0x4
    3f94:	a7050513          	addi	a0,a0,-1424 # 7a00 <malloc+0x1a4a>
    3f98:	00002097          	auipc	ra,0x2
    3f9c:	f66080e7          	jalr	-154(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3fa0:	4505                	li	a0,1
    3fa2:	00002097          	auipc	ra,0x2
    3fa6:	bec080e7          	jalr	-1044(ra) # 5b8e <exit>
    printf("%s: unlink dots/.. worked!\n", s);
<<<<<<< HEAD
    3fb0:	85a6                	mv	a1,s1
    3fb2:	00004517          	auipc	a0,0x4
    3fb6:	ae650513          	addi	a0,a0,-1306 # 7a98 <malloc+0x1a94>
    3fba:	00002097          	auipc	ra,0x2
    3fbe:	f8c080e7          	jalr	-116(ra) # 5f46 <printf>
=======
    3faa:	85a6                	mv	a1,s1
    3fac:	00004517          	auipc	a0,0x4
    3fb0:	a7c50513          	addi	a0,a0,-1412 # 7a28 <malloc+0x1a72>
    3fb4:	00002097          	auipc	ra,0x2
    3fb8:	f4a080e7          	jalr	-182(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3fbc:	4505                	li	a0,1
    3fbe:	00002097          	auipc	ra,0x2
    3fc2:	bd0080e7          	jalr	-1072(ra) # 5b8e <exit>
    printf("%s: unlink dots failed!\n", s);
<<<<<<< HEAD
    3fcc:	85a6                	mv	a1,s1
    3fce:	00004517          	auipc	a0,0x4
    3fd2:	aea50513          	addi	a0,a0,-1302 # 7ab8 <malloc+0x1ab4>
    3fd6:	00002097          	auipc	ra,0x2
    3fda:	f70080e7          	jalr	-144(ra) # 5f46 <printf>
=======
    3fc6:	85a6                	mv	a1,s1
    3fc8:	00004517          	auipc	a0,0x4
    3fcc:	a8050513          	addi	a0,a0,-1408 # 7a48 <malloc+0x1a92>
    3fd0:	00002097          	auipc	ra,0x2
    3fd4:	f2e080e7          	jalr	-210(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    3fd8:	4505                	li	a0,1
    3fda:	00002097          	auipc	ra,0x2
    3fde:	bb4080e7          	jalr	-1100(ra) # 5b8e <exit>

0000000000003fe2 <dirfile>:
{
    3fe2:	1101                	addi	sp,sp,-32
    3fe4:	ec06                	sd	ra,24(sp)
    3fe6:	e822                	sd	s0,16(sp)
    3fe8:	e426                	sd	s1,8(sp)
    3fea:	e04a                	sd	s2,0(sp)
    3fec:	1000                	addi	s0,sp,32
    3fee:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
<<<<<<< HEAD
    3ff6:	20000593          	li	a1,512
    3ffa:	00004517          	auipc	a0,0x4
    3ffe:	ade50513          	addi	a0,a0,-1314 # 7ad8 <malloc+0x1ad4>
    4002:	00002097          	auipc	ra,0x2
    4006:	c04080e7          	jalr	-1020(ra) # 5c06 <open>
=======
    3ff0:	20000593          	li	a1,512
    3ff4:	00004517          	auipc	a0,0x4
    3ff8:	a7450513          	addi	a0,a0,-1420 # 7a68 <malloc+0x1ab2>
    3ffc:	00002097          	auipc	ra,0x2
    4000:	bd2080e7          	jalr	-1070(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd < 0){
    4004:	0e054d63          	bltz	a0,40fe <dirfile+0x11c>
  close(fd);
    4008:	00002097          	auipc	ra,0x2
    400c:	bae080e7          	jalr	-1106(ra) # 5bb6 <close>
  if(chdir("dirfile") == 0){
<<<<<<< HEAD
    4016:	00004517          	auipc	a0,0x4
    401a:	ac250513          	addi	a0,a0,-1342 # 7ad8 <malloc+0x1ad4>
    401e:	00002097          	auipc	ra,0x2
    4022:	c18080e7          	jalr	-1000(ra) # 5c36 <chdir>
    4026:	cd6d                	beqz	a0,4120 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    4028:	4581                	li	a1,0
    402a:	00004517          	auipc	a0,0x4
    402e:	af650513          	addi	a0,a0,-1290 # 7b20 <malloc+0x1b1c>
    4032:	00002097          	auipc	ra,0x2
    4036:	bd4080e7          	jalr	-1068(ra) # 5c06 <open>
=======
    4010:	00004517          	auipc	a0,0x4
    4014:	a5850513          	addi	a0,a0,-1448 # 7a68 <malloc+0x1ab2>
    4018:	00002097          	auipc	ra,0x2
    401c:	be6080e7          	jalr	-1050(ra) # 5bfe <chdir>
    4020:	cd6d                	beqz	a0,411a <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    4022:	4581                	li	a1,0
    4024:	00004517          	auipc	a0,0x4
    4028:	a8c50513          	addi	a0,a0,-1396 # 7ab0 <malloc+0x1afa>
    402c:	00002097          	auipc	ra,0x2
    4030:	ba2080e7          	jalr	-1118(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd >= 0){
    4034:	10055163          	bgez	a0,4136 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
<<<<<<< HEAD
    403e:	20000593          	li	a1,512
    4042:	00004517          	auipc	a0,0x4
    4046:	ade50513          	addi	a0,a0,-1314 # 7b20 <malloc+0x1b1c>
    404a:	00002097          	auipc	ra,0x2
    404e:	bbc080e7          	jalr	-1092(ra) # 5c06 <open>
=======
    4038:	20000593          	li	a1,512
    403c:	00004517          	auipc	a0,0x4
    4040:	a7450513          	addi	a0,a0,-1420 # 7ab0 <malloc+0x1afa>
    4044:	00002097          	auipc	ra,0x2
    4048:	b8a080e7          	jalr	-1142(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd >= 0){
    404c:	10055363          	bgez	a0,4152 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
<<<<<<< HEAD
    4056:	00004517          	auipc	a0,0x4
    405a:	aca50513          	addi	a0,a0,-1334 # 7b20 <malloc+0x1b1c>
    405e:	00002097          	auipc	ra,0x2
    4062:	bd0080e7          	jalr	-1072(ra) # 5c2e <mkdir>
    4066:	10050763          	beqz	a0,4174 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    406a:	00004517          	auipc	a0,0x4
    406e:	ab650513          	addi	a0,a0,-1354 # 7b20 <malloc+0x1b1c>
    4072:	00002097          	auipc	ra,0x2
    4076:	ba4080e7          	jalr	-1116(ra) # 5c16 <unlink>
    407a:	10050b63          	beqz	a0,4190 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    407e:	00004597          	auipc	a1,0x4
    4082:	aa258593          	addi	a1,a1,-1374 # 7b20 <malloc+0x1b1c>
    4086:	00002517          	auipc	a0,0x2
    408a:	29a50513          	addi	a0,a0,666 # 6320 <malloc+0x31c>
    408e:	00002097          	auipc	ra,0x2
    4092:	b98080e7          	jalr	-1128(ra) # 5c26 <link>
    4096:	10050b63          	beqz	a0,41ac <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    409a:	00004517          	auipc	a0,0x4
    409e:	a3e50513          	addi	a0,a0,-1474 # 7ad8 <malloc+0x1ad4>
    40a2:	00002097          	auipc	ra,0x2
    40a6:	b74080e7          	jalr	-1164(ra) # 5c16 <unlink>
    40aa:	10051f63          	bnez	a0,41c8 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    40ae:	4589                	li	a1,2
    40b0:	00002517          	auipc	a0,0x2
    40b4:	78050513          	addi	a0,a0,1920 # 6830 <malloc+0x82c>
    40b8:	00002097          	auipc	ra,0x2
    40bc:	b4e080e7          	jalr	-1202(ra) # 5c06 <open>
=======
    4050:	00004517          	auipc	a0,0x4
    4054:	a6050513          	addi	a0,a0,-1440 # 7ab0 <malloc+0x1afa>
    4058:	00002097          	auipc	ra,0x2
    405c:	b9e080e7          	jalr	-1122(ra) # 5bf6 <mkdir>
    4060:	10050763          	beqz	a0,416e <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    4064:	00004517          	auipc	a0,0x4
    4068:	a4c50513          	addi	a0,a0,-1460 # 7ab0 <malloc+0x1afa>
    406c:	00002097          	auipc	ra,0x2
    4070:	b72080e7          	jalr	-1166(ra) # 5bde <unlink>
    4074:	10050b63          	beqz	a0,418a <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    4078:	00004597          	auipc	a1,0x4
    407c:	a3858593          	addi	a1,a1,-1480 # 7ab0 <malloc+0x1afa>
    4080:	00002517          	auipc	a0,0x2
    4084:	23050513          	addi	a0,a0,560 # 62b0 <malloc+0x2fa>
    4088:	00002097          	auipc	ra,0x2
    408c:	b66080e7          	jalr	-1178(ra) # 5bee <link>
    4090:	10050b63          	beqz	a0,41a6 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    4094:	00004517          	auipc	a0,0x4
    4098:	9d450513          	addi	a0,a0,-1580 # 7a68 <malloc+0x1ab2>
    409c:	00002097          	auipc	ra,0x2
    40a0:	b42080e7          	jalr	-1214(ra) # 5bde <unlink>
    40a4:	10051f63          	bnez	a0,41c2 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    40a8:	4589                	li	a1,2
    40aa:	00002517          	auipc	a0,0x2
    40ae:	71650513          	addi	a0,a0,1814 # 67c0 <malloc+0x80a>
    40b2:	00002097          	auipc	ra,0x2
    40b6:	b1c080e7          	jalr	-1252(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if(fd >= 0){
    40ba:	12055263          	bgez	a0,41de <dirfile+0x1fc>
  fd = open(".", 0);
<<<<<<< HEAD
    40c4:	4581                	li	a1,0
    40c6:	00002517          	auipc	a0,0x2
    40ca:	76a50513          	addi	a0,a0,1898 # 6830 <malloc+0x82c>
    40ce:	00002097          	auipc	ra,0x2
    40d2:	b38080e7          	jalr	-1224(ra) # 5c06 <open>
    40d6:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    40d8:	4605                	li	a2,1
    40da:	00002597          	auipc	a1,0x2
    40de:	0de58593          	addi	a1,a1,222 # 61b8 <malloc+0x1b4>
    40e2:	00002097          	auipc	ra,0x2
    40e6:	b04080e7          	jalr	-1276(ra) # 5be6 <write>
    40ea:	10a04b63          	bgtz	a0,4200 <dirfile+0x218>
=======
    40be:	4581                	li	a1,0
    40c0:	00002517          	auipc	a0,0x2
    40c4:	70050513          	addi	a0,a0,1792 # 67c0 <malloc+0x80a>
    40c8:	00002097          	auipc	ra,0x2
    40cc:	b06080e7          	jalr	-1274(ra) # 5bce <open>
    40d0:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    40d2:	4605                	li	a2,1
    40d4:	00002597          	auipc	a1,0x2
    40d8:	07458593          	addi	a1,a1,116 # 6148 <malloc+0x192>
    40dc:	00002097          	auipc	ra,0x2
    40e0:	ad2080e7          	jalr	-1326(ra) # 5bae <write>
    40e4:	10a04b63          	bgtz	a0,41fa <dirfile+0x218>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  close(fd);
    40e8:	8526                	mv	a0,s1
    40ea:	00002097          	auipc	ra,0x2
    40ee:	acc080e7          	jalr	-1332(ra) # 5bb6 <close>
}
    40f2:	60e2                	ld	ra,24(sp)
    40f4:	6442                	ld	s0,16(sp)
    40f6:	64a2                	ld	s1,8(sp)
    40f8:	6902                	ld	s2,0(sp)
    40fa:	6105                	addi	sp,sp,32
    40fc:	8082                	ret
    printf("%s: create dirfile failed\n", s);
<<<<<<< HEAD
    4104:	85ca                	mv	a1,s2
    4106:	00004517          	auipc	a0,0x4
    410a:	9da50513          	addi	a0,a0,-1574 # 7ae0 <malloc+0x1adc>
    410e:	00002097          	auipc	ra,0x2
    4112:	e38080e7          	jalr	-456(ra) # 5f46 <printf>
=======
    40fe:	85ca                	mv	a1,s2
    4100:	00004517          	auipc	a0,0x4
    4104:	97050513          	addi	a0,a0,-1680 # 7a70 <malloc+0x1aba>
    4108:	00002097          	auipc	ra,0x2
    410c:	df6080e7          	jalr	-522(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4110:	4505                	li	a0,1
    4112:	00002097          	auipc	ra,0x2
    4116:	a7c080e7          	jalr	-1412(ra) # 5b8e <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
<<<<<<< HEAD
    4120:	85ca                	mv	a1,s2
    4122:	00004517          	auipc	a0,0x4
    4126:	9de50513          	addi	a0,a0,-1570 # 7b00 <malloc+0x1afc>
    412a:	00002097          	auipc	ra,0x2
    412e:	e1c080e7          	jalr	-484(ra) # 5f46 <printf>
=======
    411a:	85ca                	mv	a1,s2
    411c:	00004517          	auipc	a0,0x4
    4120:	97450513          	addi	a0,a0,-1676 # 7a90 <malloc+0x1ada>
    4124:	00002097          	auipc	ra,0x2
    4128:	dda080e7          	jalr	-550(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    412c:	4505                	li	a0,1
    412e:	00002097          	auipc	ra,0x2
    4132:	a60080e7          	jalr	-1440(ra) # 5b8e <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
<<<<<<< HEAD
    413c:	85ca                	mv	a1,s2
    413e:	00004517          	auipc	a0,0x4
    4142:	9f250513          	addi	a0,a0,-1550 # 7b30 <malloc+0x1b2c>
    4146:	00002097          	auipc	ra,0x2
    414a:	e00080e7          	jalr	-512(ra) # 5f46 <printf>
=======
    4136:	85ca                	mv	a1,s2
    4138:	00004517          	auipc	a0,0x4
    413c:	98850513          	addi	a0,a0,-1656 # 7ac0 <malloc+0x1b0a>
    4140:	00002097          	auipc	ra,0x2
    4144:	dbe080e7          	jalr	-578(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4148:	4505                	li	a0,1
    414a:	00002097          	auipc	ra,0x2
    414e:	a44080e7          	jalr	-1468(ra) # 5b8e <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
<<<<<<< HEAD
    4158:	85ca                	mv	a1,s2
    415a:	00004517          	auipc	a0,0x4
    415e:	9d650513          	addi	a0,a0,-1578 # 7b30 <malloc+0x1b2c>
    4162:	00002097          	auipc	ra,0x2
    4166:	de4080e7          	jalr	-540(ra) # 5f46 <printf>
=======
    4152:	85ca                	mv	a1,s2
    4154:	00004517          	auipc	a0,0x4
    4158:	96c50513          	addi	a0,a0,-1684 # 7ac0 <malloc+0x1b0a>
    415c:	00002097          	auipc	ra,0x2
    4160:	da2080e7          	jalr	-606(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4164:	4505                	li	a0,1
    4166:	00002097          	auipc	ra,0x2
    416a:	a28080e7          	jalr	-1496(ra) # 5b8e <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
<<<<<<< HEAD
    4174:	85ca                	mv	a1,s2
    4176:	00004517          	auipc	a0,0x4
    417a:	9e250513          	addi	a0,a0,-1566 # 7b58 <malloc+0x1b54>
    417e:	00002097          	auipc	ra,0x2
    4182:	dc8080e7          	jalr	-568(ra) # 5f46 <printf>
=======
    416e:	85ca                	mv	a1,s2
    4170:	00004517          	auipc	a0,0x4
    4174:	97850513          	addi	a0,a0,-1672 # 7ae8 <malloc+0x1b32>
    4178:	00002097          	auipc	ra,0x2
    417c:	d86080e7          	jalr	-634(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4180:	4505                	li	a0,1
    4182:	00002097          	auipc	ra,0x2
    4186:	a0c080e7          	jalr	-1524(ra) # 5b8e <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
<<<<<<< HEAD
    4190:	85ca                	mv	a1,s2
    4192:	00004517          	auipc	a0,0x4
    4196:	9ee50513          	addi	a0,a0,-1554 # 7b80 <malloc+0x1b7c>
    419a:	00002097          	auipc	ra,0x2
    419e:	dac080e7          	jalr	-596(ra) # 5f46 <printf>
=======
    418a:	85ca                	mv	a1,s2
    418c:	00004517          	auipc	a0,0x4
    4190:	98450513          	addi	a0,a0,-1660 # 7b10 <malloc+0x1b5a>
    4194:	00002097          	auipc	ra,0x2
    4198:	d6a080e7          	jalr	-662(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    419c:	4505                	li	a0,1
    419e:	00002097          	auipc	ra,0x2
    41a2:	9f0080e7          	jalr	-1552(ra) # 5b8e <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
<<<<<<< HEAD
    41ac:	85ca                	mv	a1,s2
    41ae:	00004517          	auipc	a0,0x4
    41b2:	9fa50513          	addi	a0,a0,-1542 # 7ba8 <malloc+0x1ba4>
    41b6:	00002097          	auipc	ra,0x2
    41ba:	d90080e7          	jalr	-624(ra) # 5f46 <printf>
=======
    41a6:	85ca                	mv	a1,s2
    41a8:	00004517          	auipc	a0,0x4
    41ac:	99050513          	addi	a0,a0,-1648 # 7b38 <malloc+0x1b82>
    41b0:	00002097          	auipc	ra,0x2
    41b4:	d4e080e7          	jalr	-690(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    41b8:	4505                	li	a0,1
    41ba:	00002097          	auipc	ra,0x2
    41be:	9d4080e7          	jalr	-1580(ra) # 5b8e <exit>
    printf("%s: unlink dirfile failed!\n", s);
<<<<<<< HEAD
    41c8:	85ca                	mv	a1,s2
    41ca:	00004517          	auipc	a0,0x4
    41ce:	a0650513          	addi	a0,a0,-1530 # 7bd0 <malloc+0x1bcc>
    41d2:	00002097          	auipc	ra,0x2
    41d6:	d74080e7          	jalr	-652(ra) # 5f46 <printf>
=======
    41c2:	85ca                	mv	a1,s2
    41c4:	00004517          	auipc	a0,0x4
    41c8:	99c50513          	addi	a0,a0,-1636 # 7b60 <malloc+0x1baa>
    41cc:	00002097          	auipc	ra,0x2
    41d0:	d32080e7          	jalr	-718(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    41d4:	4505                	li	a0,1
    41d6:	00002097          	auipc	ra,0x2
    41da:	9b8080e7          	jalr	-1608(ra) # 5b8e <exit>
    printf("%s: open . for writing succeeded!\n", s);
<<<<<<< HEAD
    41e4:	85ca                	mv	a1,s2
    41e6:	00004517          	auipc	a0,0x4
    41ea:	a0a50513          	addi	a0,a0,-1526 # 7bf0 <malloc+0x1bec>
    41ee:	00002097          	auipc	ra,0x2
    41f2:	d58080e7          	jalr	-680(ra) # 5f46 <printf>
=======
    41de:	85ca                	mv	a1,s2
    41e0:	00004517          	auipc	a0,0x4
    41e4:	9a050513          	addi	a0,a0,-1632 # 7b80 <malloc+0x1bca>
    41e8:	00002097          	auipc	ra,0x2
    41ec:	d16080e7          	jalr	-746(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    41f0:	4505                	li	a0,1
    41f2:	00002097          	auipc	ra,0x2
    41f6:	99c080e7          	jalr	-1636(ra) # 5b8e <exit>
    printf("%s: write . succeeded!\n", s);
<<<<<<< HEAD
    4200:	85ca                	mv	a1,s2
    4202:	00004517          	auipc	a0,0x4
    4206:	a1650513          	addi	a0,a0,-1514 # 7c18 <malloc+0x1c14>
    420a:	00002097          	auipc	ra,0x2
    420e:	d3c080e7          	jalr	-708(ra) # 5f46 <printf>
=======
    41fa:	85ca                	mv	a1,s2
    41fc:	00004517          	auipc	a0,0x4
    4200:	9ac50513          	addi	a0,a0,-1620 # 7ba8 <malloc+0x1bf2>
    4204:	00002097          	auipc	ra,0x2
    4208:	cfa080e7          	jalr	-774(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    420c:	4505                	li	a0,1
    420e:	00002097          	auipc	ra,0x2
    4212:	980080e7          	jalr	-1664(ra) # 5b8e <exit>

0000000000004216 <iref>:
{
    4216:	7139                	addi	sp,sp,-64
    4218:	fc06                	sd	ra,56(sp)
    421a:	f822                	sd	s0,48(sp)
    421c:	f426                	sd	s1,40(sp)
    421e:	f04a                	sd	s2,32(sp)
    4220:	ec4e                	sd	s3,24(sp)
    4222:	e852                	sd	s4,16(sp)
    4224:	e456                	sd	s5,8(sp)
    4226:	e05a                	sd	s6,0(sp)
    4228:	0080                	addi	s0,sp,64
    422a:	8b2a                	mv	s6,a0
    422c:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
<<<<<<< HEAD
    4236:	00004a17          	auipc	s4,0x4
    423a:	9faa0a13          	addi	s4,s4,-1542 # 7c30 <malloc+0x1c2c>
    mkdir("");
    423e:	00003497          	auipc	s1,0x3
    4242:	4fa48493          	addi	s1,s1,1274 # 7738 <malloc+0x1734>
    link("README", "");
    4246:	00002a97          	auipc	s5,0x2
    424a:	0daa8a93          	addi	s5,s5,218 # 6320 <malloc+0x31c>
    fd = open("xx", O_CREATE);
    424e:	00004997          	auipc	s3,0x4
    4252:	8da98993          	addi	s3,s3,-1830 # 7b28 <malloc+0x1b24>
    4256:	a891                	j	42aa <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    4258:	85da                	mv	a1,s6
    425a:	00004517          	auipc	a0,0x4
    425e:	9de50513          	addi	a0,a0,-1570 # 7c38 <malloc+0x1c34>
    4262:	00002097          	auipc	ra,0x2
    4266:	ce4080e7          	jalr	-796(ra) # 5f46 <printf>
=======
    4230:	00004a17          	auipc	s4,0x4
    4234:	990a0a13          	addi	s4,s4,-1648 # 7bc0 <malloc+0x1c0a>
    mkdir("");
    4238:	00003497          	auipc	s1,0x3
    423c:	49048493          	addi	s1,s1,1168 # 76c8 <malloc+0x1712>
    link("README", "");
    4240:	00002a97          	auipc	s5,0x2
    4244:	070a8a93          	addi	s5,s5,112 # 62b0 <malloc+0x2fa>
    fd = open("xx", O_CREATE);
    4248:	00004997          	auipc	s3,0x4
    424c:	87098993          	addi	s3,s3,-1936 # 7ab8 <malloc+0x1b02>
    4250:	a891                	j	42a4 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    4252:	85da                	mv	a1,s6
    4254:	00004517          	auipc	a0,0x4
    4258:	97450513          	addi	a0,a0,-1676 # 7bc8 <malloc+0x1c12>
    425c:	00002097          	auipc	ra,0x2
    4260:	ca2080e7          	jalr	-862(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    4264:	4505                	li	a0,1
    4266:	00002097          	auipc	ra,0x2
    426a:	928080e7          	jalr	-1752(ra) # 5b8e <exit>
      printf("%s: chdir irefd failed\n", s);
<<<<<<< HEAD
    4274:	85da                	mv	a1,s6
    4276:	00004517          	auipc	a0,0x4
    427a:	9da50513          	addi	a0,a0,-1574 # 7c50 <malloc+0x1c4c>
    427e:	00002097          	auipc	ra,0x2
    4282:	cc8080e7          	jalr	-824(ra) # 5f46 <printf>
=======
    426e:	85da                	mv	a1,s6
    4270:	00004517          	auipc	a0,0x4
    4274:	97050513          	addi	a0,a0,-1680 # 7be0 <malloc+0x1c2a>
    4278:	00002097          	auipc	ra,0x2
    427c:	c86080e7          	jalr	-890(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    4280:	4505                	li	a0,1
    4282:	00002097          	auipc	ra,0x2
    4286:	90c080e7          	jalr	-1780(ra) # 5b8e <exit>
      close(fd);
    428a:	00002097          	auipc	ra,0x2
    428e:	92c080e7          	jalr	-1748(ra) # 5bb6 <close>
    4292:	a889                	j	42e4 <iref+0xce>
    unlink("xx");
    4294:	854e                	mv	a0,s3
    4296:	00002097          	auipc	ra,0x2
    429a:	948080e7          	jalr	-1720(ra) # 5bde <unlink>
  for(i = 0; i < NINODE + 1; i++){
    429e:	397d                	addiw	s2,s2,-1
    42a0:	06090063          	beqz	s2,4300 <iref+0xea>
    if(mkdir("irefd") != 0){
    42a4:	8552                	mv	a0,s4
    42a6:	00002097          	auipc	ra,0x2
    42aa:	950080e7          	jalr	-1712(ra) # 5bf6 <mkdir>
    42ae:	f155                	bnez	a0,4252 <iref+0x3c>
    if(chdir("irefd") != 0){
    42b0:	8552                	mv	a0,s4
    42b2:	00002097          	auipc	ra,0x2
    42b6:	94c080e7          	jalr	-1716(ra) # 5bfe <chdir>
    42ba:	f955                	bnez	a0,426e <iref+0x58>
    mkdir("");
    42bc:	8526                	mv	a0,s1
    42be:	00002097          	auipc	ra,0x2
    42c2:	938080e7          	jalr	-1736(ra) # 5bf6 <mkdir>
    link("README", "");
    42c6:	85a6                	mv	a1,s1
    42c8:	8556                	mv	a0,s5
    42ca:	00002097          	auipc	ra,0x2
    42ce:	924080e7          	jalr	-1756(ra) # 5bee <link>
    fd = open("", O_CREATE);
    42d2:	20000593          	li	a1,512
    42d6:	8526                	mv	a0,s1
    42d8:	00002097          	auipc	ra,0x2
    42dc:	8f6080e7          	jalr	-1802(ra) # 5bce <open>
    if(fd >= 0)
    42e0:	fa0555e3          	bgez	a0,428a <iref+0x74>
    fd = open("xx", O_CREATE);
    42e4:	20000593          	li	a1,512
    42e8:	854e                	mv	a0,s3
    42ea:	00002097          	auipc	ra,0x2
    42ee:	8e4080e7          	jalr	-1820(ra) # 5bce <open>
    if(fd >= 0)
    42f2:	fa0541e3          	bltz	a0,4294 <iref+0x7e>
      close(fd);
    42f6:	00002097          	auipc	ra,0x2
    42fa:	8c0080e7          	jalr	-1856(ra) # 5bb6 <close>
    42fe:	bf59                	j	4294 <iref+0x7e>
    4300:	03300493          	li	s1,51
    chdir("..");
<<<<<<< HEAD
    430a:	00003997          	auipc	s3,0x3
    430e:	14e98993          	addi	s3,s3,334 # 7458 <malloc+0x1454>
    unlink("irefd");
    4312:	00004917          	auipc	s2,0x4
    4316:	91e90913          	addi	s2,s2,-1762 # 7c30 <malloc+0x1c2c>
=======
    4304:	00003997          	auipc	s3,0x3
    4308:	0e498993          	addi	s3,s3,228 # 73e8 <malloc+0x1432>
    unlink("irefd");
    430c:	00004917          	auipc	s2,0x4
    4310:	8b490913          	addi	s2,s2,-1868 # 7bc0 <malloc+0x1c0a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    chdir("..");
    4314:	854e                	mv	a0,s3
    4316:	00002097          	auipc	ra,0x2
    431a:	8e8080e7          	jalr	-1816(ra) # 5bfe <chdir>
    unlink("irefd");
    431e:	854a                	mv	a0,s2
    4320:	00002097          	auipc	ra,0x2
    4324:	8be080e7          	jalr	-1858(ra) # 5bde <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4328:	34fd                	addiw	s1,s1,-1
    432a:	f4ed                	bnez	s1,4314 <iref+0xfe>
  chdir("/");
<<<<<<< HEAD
    4332:	00003517          	auipc	a0,0x3
    4336:	0ce50513          	addi	a0,a0,206 # 7400 <malloc+0x13fc>
    433a:	00002097          	auipc	ra,0x2
    433e:	8fc080e7          	jalr	-1796(ra) # 5c36 <chdir>
=======
    432c:	00003517          	auipc	a0,0x3
    4330:	06450513          	addi	a0,a0,100 # 7390 <malloc+0x13da>
    4334:	00002097          	auipc	ra,0x2
    4338:	8ca080e7          	jalr	-1846(ra) # 5bfe <chdir>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    433c:	70e2                	ld	ra,56(sp)
    433e:	7442                	ld	s0,48(sp)
    4340:	74a2                	ld	s1,40(sp)
    4342:	7902                	ld	s2,32(sp)
    4344:	69e2                	ld	s3,24(sp)
    4346:	6a42                	ld	s4,16(sp)
    4348:	6aa2                	ld	s5,8(sp)
    434a:	6b02                	ld	s6,0(sp)
    434c:	6121                	addi	sp,sp,64
    434e:	8082                	ret

0000000000004350 <openiputtest>:
{
    4350:	7179                	addi	sp,sp,-48
    4352:	f406                	sd	ra,40(sp)
    4354:	f022                	sd	s0,32(sp)
    4356:	ec26                	sd	s1,24(sp)
    4358:	1800                	addi	s0,sp,48
    435a:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
<<<<<<< HEAD
    4362:	00004517          	auipc	a0,0x4
    4366:	90650513          	addi	a0,a0,-1786 # 7c68 <malloc+0x1c64>
    436a:	00002097          	auipc	ra,0x2
    436e:	8c4080e7          	jalr	-1852(ra) # 5c2e <mkdir>
    4372:	04054263          	bltz	a0,43b6 <openiputtest+0x60>
=======
    435c:	00004517          	auipc	a0,0x4
    4360:	89c50513          	addi	a0,a0,-1892 # 7bf8 <malloc+0x1c42>
    4364:	00002097          	auipc	ra,0x2
    4368:	892080e7          	jalr	-1902(ra) # 5bf6 <mkdir>
    436c:	04054263          	bltz	a0,43b0 <openiputtest+0x60>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  pid = fork();
    4370:	00002097          	auipc	ra,0x2
    4374:	816080e7          	jalr	-2026(ra) # 5b86 <fork>
  if(pid < 0){
    4378:	04054a63          	bltz	a0,43cc <openiputtest+0x7c>
  if(pid == 0){
    437c:	e93d                	bnez	a0,43f2 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
<<<<<<< HEAD
    4384:	4589                	li	a1,2
    4386:	00004517          	auipc	a0,0x4
    438a:	8e250513          	addi	a0,a0,-1822 # 7c68 <malloc+0x1c64>
    438e:	00002097          	auipc	ra,0x2
    4392:	878080e7          	jalr	-1928(ra) # 5c06 <open>
=======
    437e:	4589                	li	a1,2
    4380:	00004517          	auipc	a0,0x4
    4384:	87850513          	addi	a0,a0,-1928 # 7bf8 <malloc+0x1c42>
    4388:	00002097          	auipc	ra,0x2
    438c:	846080e7          	jalr	-1978(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(fd >= 0){
    4390:	04054c63          	bltz	a0,43e8 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
<<<<<<< HEAD
    439a:	85a6                	mv	a1,s1
    439c:	00004517          	auipc	a0,0x4
    43a0:	8ec50513          	addi	a0,a0,-1812 # 7c88 <malloc+0x1c84>
    43a4:	00002097          	auipc	ra,0x2
    43a8:	ba2080e7          	jalr	-1118(ra) # 5f46 <printf>
=======
    4394:	85a6                	mv	a1,s1
    4396:	00004517          	auipc	a0,0x4
    439a:	88250513          	addi	a0,a0,-1918 # 7c18 <malloc+0x1c62>
    439e:	00002097          	auipc	ra,0x2
    43a2:	b60080e7          	jalr	-1184(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    43a6:	4505                	li	a0,1
    43a8:	00001097          	auipc	ra,0x1
    43ac:	7e6080e7          	jalr	2022(ra) # 5b8e <exit>
    printf("%s: mkdir oidir failed\n", s);
<<<<<<< HEAD
    43b6:	85a6                	mv	a1,s1
    43b8:	00004517          	auipc	a0,0x4
    43bc:	8b850513          	addi	a0,a0,-1864 # 7c70 <malloc+0x1c6c>
    43c0:	00002097          	auipc	ra,0x2
    43c4:	b86080e7          	jalr	-1146(ra) # 5f46 <printf>
=======
    43b0:	85a6                	mv	a1,s1
    43b2:	00004517          	auipc	a0,0x4
    43b6:	84e50513          	addi	a0,a0,-1970 # 7c00 <malloc+0x1c4a>
    43ba:	00002097          	auipc	ra,0x2
    43be:	b44080e7          	jalr	-1212(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    43c2:	4505                	li	a0,1
    43c4:	00001097          	auipc	ra,0x1
    43c8:	7ca080e7          	jalr	1994(ra) # 5b8e <exit>
    printf("%s: fork failed\n", s);
<<<<<<< HEAD
    43d2:	85a6                	mv	a1,s1
    43d4:	00002517          	auipc	a0,0x2
    43d8:	5fc50513          	addi	a0,a0,1532 # 69d0 <malloc+0x9cc>
    43dc:	00002097          	auipc	ra,0x2
    43e0:	b6a080e7          	jalr	-1174(ra) # 5f46 <printf>
=======
    43cc:	85a6                	mv	a1,s1
    43ce:	00002517          	auipc	a0,0x2
    43d2:	59250513          	addi	a0,a0,1426 # 6960 <malloc+0x9aa>
    43d6:	00002097          	auipc	ra,0x2
    43da:	b28080e7          	jalr	-1240(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    43de:	4505                	li	a0,1
    43e0:	00001097          	auipc	ra,0x1
    43e4:	7ae080e7          	jalr	1966(ra) # 5b8e <exit>
    exit(0);
    43e8:	4501                	li	a0,0
    43ea:	00001097          	auipc	ra,0x1
    43ee:	7a4080e7          	jalr	1956(ra) # 5b8e <exit>
  sleep(1);
    43f2:	4505                	li	a0,1
    43f4:	00002097          	auipc	ra,0x2
    43f8:	82a080e7          	jalr	-2006(ra) # 5c1e <sleep>
  if(unlink("oidir") != 0){
<<<<<<< HEAD
    4402:	00004517          	auipc	a0,0x4
    4406:	86650513          	addi	a0,a0,-1946 # 7c68 <malloc+0x1c64>
    440a:	00002097          	auipc	ra,0x2
    440e:	80c080e7          	jalr	-2036(ra) # 5c16 <unlink>
    4412:	cd19                	beqz	a0,4430 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    4414:	85a6                	mv	a1,s1
    4416:	00002517          	auipc	a0,0x2
    441a:	7aa50513          	addi	a0,a0,1962 # 6bc0 <malloc+0xbbc>
    441e:	00002097          	auipc	ra,0x2
    4422:	b28080e7          	jalr	-1240(ra) # 5f46 <printf>
=======
    43fc:	00003517          	auipc	a0,0x3
    4400:	7fc50513          	addi	a0,a0,2044 # 7bf8 <malloc+0x1c42>
    4404:	00001097          	auipc	ra,0x1
    4408:	7da080e7          	jalr	2010(ra) # 5bde <unlink>
    440c:	cd19                	beqz	a0,442a <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    440e:	85a6                	mv	a1,s1
    4410:	00002517          	auipc	a0,0x2
    4414:	74050513          	addi	a0,a0,1856 # 6b50 <malloc+0xb9a>
    4418:	00002097          	auipc	ra,0x2
    441c:	ae6080e7          	jalr	-1306(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4420:	4505                	li	a0,1
    4422:	00001097          	auipc	ra,0x1
    4426:	76c080e7          	jalr	1900(ra) # 5b8e <exit>
  wait(&xstatus);
    442a:	fdc40513          	addi	a0,s0,-36
    442e:	00001097          	auipc	ra,0x1
    4432:	768080e7          	jalr	1896(ra) # 5b96 <wait>
  exit(xstatus);
    4436:	fdc42503          	lw	a0,-36(s0)
    443a:	00001097          	auipc	ra,0x1
    443e:	754080e7          	jalr	1876(ra) # 5b8e <exit>

0000000000004442 <forkforkfork>:
{
    4442:	1101                	addi	sp,sp,-32
    4444:	ec06                	sd	ra,24(sp)
    4446:	e822                	sd	s0,16(sp)
    4448:	e426                	sd	s1,8(sp)
    444a:	1000                	addi	s0,sp,32
    444c:	84aa                	mv	s1,a0
  unlink("stopforking");
<<<<<<< HEAD
    4454:	00004517          	auipc	a0,0x4
    4458:	85c50513          	addi	a0,a0,-1956 # 7cb0 <malloc+0x1cac>
    445c:	00001097          	auipc	ra,0x1
    4460:	7ba080e7          	jalr	1978(ra) # 5c16 <unlink>
=======
    444e:	00003517          	auipc	a0,0x3
    4452:	7f250513          	addi	a0,a0,2034 # 7c40 <malloc+0x1c8a>
    4456:	00001097          	auipc	ra,0x1
    445a:	788080e7          	jalr	1928(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  int pid = fork();
    445e:	00001097          	auipc	ra,0x1
    4462:	728080e7          	jalr	1832(ra) # 5b86 <fork>
  if(pid < 0){
    4466:	04054563          	bltz	a0,44b0 <forkforkfork+0x6e>
  if(pid == 0){
    446a:	c12d                	beqz	a0,44cc <forkforkfork+0x8a>
  sleep(20); // two seconds
    446c:	4551                	li	a0,20
    446e:	00001097          	auipc	ra,0x1
    4472:	7b0080e7          	jalr	1968(ra) # 5c1e <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
<<<<<<< HEAD
    447c:	20200593          	li	a1,514
    4480:	00004517          	auipc	a0,0x4
    4484:	83050513          	addi	a0,a0,-2000 # 7cb0 <malloc+0x1cac>
    4488:	00001097          	auipc	ra,0x1
    448c:	77e080e7          	jalr	1918(ra) # 5c06 <open>
    4490:	00001097          	auipc	ra,0x1
    4494:	75e080e7          	jalr	1886(ra) # 5bee <close>
=======
    4476:	20200593          	li	a1,514
    447a:	00003517          	auipc	a0,0x3
    447e:	7c650513          	addi	a0,a0,1990 # 7c40 <malloc+0x1c8a>
    4482:	00001097          	auipc	ra,0x1
    4486:	74c080e7          	jalr	1868(ra) # 5bce <open>
    448a:	00001097          	auipc	ra,0x1
    448e:	72c080e7          	jalr	1836(ra) # 5bb6 <close>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  wait(0);
    4492:	4501                	li	a0,0
    4494:	00001097          	auipc	ra,0x1
    4498:	702080e7          	jalr	1794(ra) # 5b96 <wait>
  sleep(10); // one second
    449c:	4529                	li	a0,10
    449e:	00001097          	auipc	ra,0x1
    44a2:	780080e7          	jalr	1920(ra) # 5c1e <sleep>
}
    44a6:	60e2                	ld	ra,24(sp)
    44a8:	6442                	ld	s0,16(sp)
    44aa:	64a2                	ld	s1,8(sp)
    44ac:	6105                	addi	sp,sp,32
    44ae:	8082                	ret
    printf("%s: fork failed", s);
<<<<<<< HEAD
    44b6:	85a6                	mv	a1,s1
    44b8:	00002517          	auipc	a0,0x2
    44bc:	6d850513          	addi	a0,a0,1752 # 6b90 <malloc+0xb8c>
    44c0:	00002097          	auipc	ra,0x2
    44c4:	a86080e7          	jalr	-1402(ra) # 5f46 <printf>
=======
    44b0:	85a6                	mv	a1,s1
    44b2:	00002517          	auipc	a0,0x2
    44b6:	66e50513          	addi	a0,a0,1646 # 6b20 <malloc+0xb6a>
    44ba:	00002097          	auipc	ra,0x2
    44be:	a44080e7          	jalr	-1468(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    44c2:	4505                	li	a0,1
    44c4:	00001097          	auipc	ra,0x1
    44c8:	6ca080e7          	jalr	1738(ra) # 5b8e <exit>
      int fd = open("stopforking", 0);
<<<<<<< HEAD
    44d2:	00003497          	auipc	s1,0x3
    44d6:	7de48493          	addi	s1,s1,2014 # 7cb0 <malloc+0x1cac>
    44da:	4581                	li	a1,0
    44dc:	8526                	mv	a0,s1
    44de:	00001097          	auipc	ra,0x1
    44e2:	728080e7          	jalr	1832(ra) # 5c06 <open>
=======
    44cc:	00003497          	auipc	s1,0x3
    44d0:	77448493          	addi	s1,s1,1908 # 7c40 <malloc+0x1c8a>
    44d4:	4581                	li	a1,0
    44d6:	8526                	mv	a0,s1
    44d8:	00001097          	auipc	ra,0x1
    44dc:	6f6080e7          	jalr	1782(ra) # 5bce <open>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      if(fd >= 0){
    44e0:	02055763          	bgez	a0,450e <forkforkfork+0xcc>
      if(fork() < 0){
    44e4:	00001097          	auipc	ra,0x1
    44e8:	6a2080e7          	jalr	1698(ra) # 5b86 <fork>
    44ec:	fe0554e3          	bgez	a0,44d4 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    44f0:	20200593          	li	a1,514
    44f4:	00003517          	auipc	a0,0x3
    44f8:	74c50513          	addi	a0,a0,1868 # 7c40 <malloc+0x1c8a>
    44fc:	00001097          	auipc	ra,0x1
    4500:	6d2080e7          	jalr	1746(ra) # 5bce <open>
    4504:	00001097          	auipc	ra,0x1
    4508:	6b2080e7          	jalr	1714(ra) # 5bb6 <close>
    450c:	b7e1                	j	44d4 <forkforkfork+0x92>
        exit(0);
    450e:	4501                	li	a0,0
    4510:	00001097          	auipc	ra,0x1
    4514:	67e080e7          	jalr	1662(ra) # 5b8e <exit>

0000000000004518 <killstatus>:
{
    4518:	7139                	addi	sp,sp,-64
    451a:	fc06                	sd	ra,56(sp)
    451c:	f822                	sd	s0,48(sp)
    451e:	f426                	sd	s1,40(sp)
    4520:	f04a                	sd	s2,32(sp)
    4522:	ec4e                	sd	s3,24(sp)
    4524:	e852                	sd	s4,16(sp)
    4526:	0080                	addi	s0,sp,64
    4528:	8a2a                	mv	s4,a0
    452a:	06400913          	li	s2,100
    if(xst != -1) {
    452e:	59fd                	li	s3,-1
    int pid1 = fork();
    4530:	00001097          	auipc	ra,0x1
    4534:	656080e7          	jalr	1622(ra) # 5b86 <fork>
    4538:	84aa                	mv	s1,a0
    if(pid1 < 0){
    453a:	02054f63          	bltz	a0,4578 <killstatus+0x60>
    if(pid1 == 0){
    453e:	c939                	beqz	a0,4594 <killstatus+0x7c>
    sleep(1);
    4540:	4505                	li	a0,1
    4542:	00001097          	auipc	ra,0x1
    4546:	6dc080e7          	jalr	1756(ra) # 5c1e <sleep>
    kill(pid1);
    454a:	8526                	mv	a0,s1
    454c:	00001097          	auipc	ra,0x1
    4550:	672080e7          	jalr	1650(ra) # 5bbe <kill>
    wait(&xst);
    4554:	fcc40513          	addi	a0,s0,-52
    4558:	00001097          	auipc	ra,0x1
    455c:	63e080e7          	jalr	1598(ra) # 5b96 <wait>
    if(xst != -1) {
    4560:	fcc42783          	lw	a5,-52(s0)
    4564:	03379d63          	bne	a5,s3,459e <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    4568:	397d                	addiw	s2,s2,-1
    456a:	fc0913e3          	bnez	s2,4530 <killstatus+0x18>
  exit(0);
    456e:	4501                	li	a0,0
    4570:	00001097          	auipc	ra,0x1
    4574:	61e080e7          	jalr	1566(ra) # 5b8e <exit>
      printf("%s: fork failed\n", s);
    4578:	85d2                	mv	a1,s4
    457a:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    457e:	45650513          	addi	a0,a0,1110 # 69d0 <malloc+0x9cc>
    4582:	00002097          	auipc	ra,0x2
    4586:	9c4080e7          	jalr	-1596(ra) # 5f46 <printf>
=======
    457e:	3e650513          	addi	a0,a0,998 # 6960 <malloc+0x9aa>
    4582:	00002097          	auipc	ra,0x2
    4586:	97c080e7          	jalr	-1668(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    458a:	4505                	li	a0,1
    458c:	00001097          	auipc	ra,0x1
    4590:	602080e7          	jalr	1538(ra) # 5b8e <exit>
        getpid();
    4594:	00001097          	auipc	ra,0x1
    4598:	67a080e7          	jalr	1658(ra) # 5c0e <getpid>
      while(1) {
    459c:	bfe5                	j	4594 <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    459e:	85d2                	mv	a1,s4
    45a0:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    45a4:	72050513          	addi	a0,a0,1824 # 7cc0 <malloc+0x1cbc>
    45a8:	00002097          	auipc	ra,0x2
    45ac:	99e080e7          	jalr	-1634(ra) # 5f46 <printf>
=======
    45a4:	6b050513          	addi	a0,a0,1712 # 7c50 <malloc+0x1c9a>
    45a8:	00002097          	auipc	ra,0x2
    45ac:	956080e7          	jalr	-1706(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
       exit(1);
    45b0:	4505                	li	a0,1
    45b2:	00001097          	auipc	ra,0x1
    45b6:	5dc080e7          	jalr	1500(ra) # 5b8e <exit>

00000000000045ba <preempt>:
{
    45ba:	7139                	addi	sp,sp,-64
    45bc:	fc06                	sd	ra,56(sp)
    45be:	f822                	sd	s0,48(sp)
    45c0:	f426                	sd	s1,40(sp)
    45c2:	f04a                	sd	s2,32(sp)
    45c4:	ec4e                	sd	s3,24(sp)
    45c6:	e852                	sd	s4,16(sp)
    45c8:	0080                	addi	s0,sp,64
    45ca:	892a                	mv	s2,a0
  pid1 = fork();
    45cc:	00001097          	auipc	ra,0x1
    45d0:	5ba080e7          	jalr	1466(ra) # 5b86 <fork>
  if(pid1 < 0) {
    45d4:	00054563          	bltz	a0,45de <preempt+0x24>
    45d8:	84aa                	mv	s1,a0
  if(pid1 == 0)
    45da:	e105                	bnez	a0,45fa <preempt+0x40>
    for(;;)
    45dc:	a001                	j	45dc <preempt+0x22>
    printf("%s: fork failed", s);
    45de:	85ca                	mv	a1,s2
    45e0:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    45e4:	5b050513          	addi	a0,a0,1456 # 6b90 <malloc+0xb8c>
    45e8:	00002097          	auipc	ra,0x2
    45ec:	95e080e7          	jalr	-1698(ra) # 5f46 <printf>
=======
    45e4:	54050513          	addi	a0,a0,1344 # 6b20 <malloc+0xb6a>
    45e8:	00002097          	auipc	ra,0x2
    45ec:	916080e7          	jalr	-1770(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    45f0:	4505                	li	a0,1
    45f2:	00001097          	auipc	ra,0x1
    45f6:	59c080e7          	jalr	1436(ra) # 5b8e <exit>
  pid2 = fork();
    45fa:	00001097          	auipc	ra,0x1
    45fe:	58c080e7          	jalr	1420(ra) # 5b86 <fork>
    4602:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4604:	00054463          	bltz	a0,460c <preempt+0x52>
  if(pid2 == 0)
    4608:	e105                	bnez	a0,4628 <preempt+0x6e>
    for(;;)
    460a:	a001                	j	460a <preempt+0x50>
    printf("%s: fork failed\n", s);
    460c:	85ca                	mv	a1,s2
    460e:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    4612:	3c250513          	addi	a0,a0,962 # 69d0 <malloc+0x9cc>
    4616:	00002097          	auipc	ra,0x2
    461a:	930080e7          	jalr	-1744(ra) # 5f46 <printf>
=======
    4612:	35250513          	addi	a0,a0,850 # 6960 <malloc+0x9aa>
    4616:	00002097          	auipc	ra,0x2
    461a:	8e8080e7          	jalr	-1816(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    461e:	4505                	li	a0,1
    4620:	00001097          	auipc	ra,0x1
    4624:	56e080e7          	jalr	1390(ra) # 5b8e <exit>
  pipe(pfds);
    4628:	fc840513          	addi	a0,s0,-56
    462c:	00001097          	auipc	ra,0x1
    4630:	572080e7          	jalr	1394(ra) # 5b9e <pipe>
  pid3 = fork();
    4634:	00001097          	auipc	ra,0x1
    4638:	552080e7          	jalr	1362(ra) # 5b86 <fork>
    463c:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    463e:	02054e63          	bltz	a0,467a <preempt+0xc0>
  if(pid3 == 0){
    4642:	e525                	bnez	a0,46aa <preempt+0xf0>
    close(pfds[0]);
    4644:	fc842503          	lw	a0,-56(s0)
    4648:	00001097          	auipc	ra,0x1
    464c:	56e080e7          	jalr	1390(ra) # 5bb6 <close>
    if(write(pfds[1], "x", 1) != 1)
    4650:	4605                	li	a2,1
    4652:	00002597          	auipc	a1,0x2
<<<<<<< HEAD
    4656:	b6658593          	addi	a1,a1,-1178 # 61b8 <malloc+0x1b4>
=======
    4656:	af658593          	addi	a1,a1,-1290 # 6148 <malloc+0x192>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    465a:	fcc42503          	lw	a0,-52(s0)
    465e:	00001097          	auipc	ra,0x1
    4662:	550080e7          	jalr	1360(ra) # 5bae <write>
    4666:	4785                	li	a5,1
    4668:	02f51763          	bne	a0,a5,4696 <preempt+0xdc>
    close(pfds[1]);
    466c:	fcc42503          	lw	a0,-52(s0)
    4670:	00001097          	auipc	ra,0x1
    4674:	546080e7          	jalr	1350(ra) # 5bb6 <close>
    for(;;)
    4678:	a001                	j	4678 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    467a:	85ca                	mv	a1,s2
    467c:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    4680:	35450513          	addi	a0,a0,852 # 69d0 <malloc+0x9cc>
    4684:	00002097          	auipc	ra,0x2
    4688:	8c2080e7          	jalr	-1854(ra) # 5f46 <printf>
=======
    4680:	2e450513          	addi	a0,a0,740 # 6960 <malloc+0x9aa>
    4684:	00002097          	auipc	ra,0x2
    4688:	87a080e7          	jalr	-1926(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     exit(1);
    468c:	4505                	li	a0,1
    468e:	00001097          	auipc	ra,0x1
    4692:	500080e7          	jalr	1280(ra) # 5b8e <exit>
      printf("%s: preempt write error", s);
    4696:	85ca                	mv	a1,s2
    4698:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    469c:	64850513          	addi	a0,a0,1608 # 7ce0 <malloc+0x1cdc>
    46a0:	00002097          	auipc	ra,0x2
    46a4:	8a6080e7          	jalr	-1882(ra) # 5f46 <printf>
=======
    469c:	5d850513          	addi	a0,a0,1496 # 7c70 <malloc+0x1cba>
    46a0:	00002097          	auipc	ra,0x2
    46a4:	85e080e7          	jalr	-1954(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    46a8:	b7d1                	j	466c <preempt+0xb2>
  close(pfds[1]);
    46aa:	fcc42503          	lw	a0,-52(s0)
    46ae:	00001097          	auipc	ra,0x1
    46b2:	508080e7          	jalr	1288(ra) # 5bb6 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    46b6:	660d                	lui	a2,0x3
    46b8:	00008597          	auipc	a1,0x8
    46bc:	5c058593          	addi	a1,a1,1472 # cc78 <buf>
    46c0:	fc842503          	lw	a0,-56(s0)
    46c4:	00001097          	auipc	ra,0x1
    46c8:	4e2080e7          	jalr	1250(ra) # 5ba6 <read>
    46cc:	4785                	li	a5,1
    46ce:	02f50363          	beq	a0,a5,46f4 <preempt+0x13a>
    printf("%s: preempt read error", s);
    46d2:	85ca                	mv	a1,s2
    46d4:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    46d8:	62450513          	addi	a0,a0,1572 # 7cf8 <malloc+0x1cf4>
    46dc:	00002097          	auipc	ra,0x2
    46e0:	86a080e7          	jalr	-1942(ra) # 5f46 <printf>
=======
    46d8:	5b450513          	addi	a0,a0,1460 # 7c88 <malloc+0x1cd2>
    46dc:	00002097          	auipc	ra,0x2
    46e0:	822080e7          	jalr	-2014(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    46e4:	70e2                	ld	ra,56(sp)
    46e6:	7442                	ld	s0,48(sp)
    46e8:	74a2                	ld	s1,40(sp)
    46ea:	7902                	ld	s2,32(sp)
    46ec:	69e2                	ld	s3,24(sp)
    46ee:	6a42                	ld	s4,16(sp)
    46f0:	6121                	addi	sp,sp,64
    46f2:	8082                	ret
  close(pfds[0]);
    46f4:	fc842503          	lw	a0,-56(s0)
    46f8:	00001097          	auipc	ra,0x1
    46fc:	4be080e7          	jalr	1214(ra) # 5bb6 <close>
  printf("kill... ");
    4700:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4704:	61050513          	addi	a0,a0,1552 # 7d10 <malloc+0x1d0c>
    4708:	00002097          	auipc	ra,0x2
    470c:	83e080e7          	jalr	-1986(ra) # 5f46 <printf>
=======
    4704:	5a050513          	addi	a0,a0,1440 # 7ca0 <malloc+0x1cea>
    4708:	00001097          	auipc	ra,0x1
    470c:	7f6080e7          	jalr	2038(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  kill(pid1);
    4710:	8526                	mv	a0,s1
    4712:	00001097          	auipc	ra,0x1
    4716:	4ac080e7          	jalr	1196(ra) # 5bbe <kill>
  kill(pid2);
    471a:	854e                	mv	a0,s3
    471c:	00001097          	auipc	ra,0x1
    4720:	4a2080e7          	jalr	1186(ra) # 5bbe <kill>
  kill(pid3);
    4724:	8552                	mv	a0,s4
    4726:	00001097          	auipc	ra,0x1
    472a:	498080e7          	jalr	1176(ra) # 5bbe <kill>
  printf("wait... ");
    472e:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4732:	5f250513          	addi	a0,a0,1522 # 7d20 <malloc+0x1d1c>
    4736:	00002097          	auipc	ra,0x2
    473a:	810080e7          	jalr	-2032(ra) # 5f46 <printf>
=======
    4732:	58250513          	addi	a0,a0,1410 # 7cb0 <malloc+0x1cfa>
    4736:	00001097          	auipc	ra,0x1
    473a:	7c8080e7          	jalr	1992(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  wait(0);
    473e:	4501                	li	a0,0
    4740:	00001097          	auipc	ra,0x1
    4744:	456080e7          	jalr	1110(ra) # 5b96 <wait>
  wait(0);
    4748:	4501                	li	a0,0
    474a:	00001097          	auipc	ra,0x1
    474e:	44c080e7          	jalr	1100(ra) # 5b96 <wait>
  wait(0);
    4752:	4501                	li	a0,0
    4754:	00001097          	auipc	ra,0x1
    4758:	442080e7          	jalr	1090(ra) # 5b96 <wait>
    475c:	b761                	j	46e4 <preempt+0x12a>

000000000000475e <reparent>:
{
    475e:	7179                	addi	sp,sp,-48
    4760:	f406                	sd	ra,40(sp)
    4762:	f022                	sd	s0,32(sp)
    4764:	ec26                	sd	s1,24(sp)
    4766:	e84a                	sd	s2,16(sp)
    4768:	e44e                	sd	s3,8(sp)
    476a:	e052                	sd	s4,0(sp)
    476c:	1800                	addi	s0,sp,48
    476e:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4770:	00001097          	auipc	ra,0x1
    4774:	49e080e7          	jalr	1182(ra) # 5c0e <getpid>
    4778:	8a2a                	mv	s4,a0
    477a:	0c800913          	li	s2,200
    int pid = fork();
    477e:	00001097          	auipc	ra,0x1
    4782:	408080e7          	jalr	1032(ra) # 5b86 <fork>
    4786:	84aa                	mv	s1,a0
    if(pid < 0){
    4788:	02054263          	bltz	a0,47ac <reparent+0x4e>
    if(pid){
    478c:	cd21                	beqz	a0,47e4 <reparent+0x86>
      if(wait(0) != pid){
    478e:	4501                	li	a0,0
    4790:	00001097          	auipc	ra,0x1
    4794:	406080e7          	jalr	1030(ra) # 5b96 <wait>
    4798:	02951863          	bne	a0,s1,47c8 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    479c:	397d                	addiw	s2,s2,-1
    479e:	fe0910e3          	bnez	s2,477e <reparent+0x20>
  exit(0);
    47a2:	4501                	li	a0,0
    47a4:	00001097          	auipc	ra,0x1
    47a8:	3ea080e7          	jalr	1002(ra) # 5b8e <exit>
      printf("%s: fork failed\n", s);
    47ac:	85ce                	mv	a1,s3
    47ae:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    47b2:	22250513          	addi	a0,a0,546 # 69d0 <malloc+0x9cc>
    47b6:	00001097          	auipc	ra,0x1
    47ba:	790080e7          	jalr	1936(ra) # 5f46 <printf>
=======
    47b2:	1b250513          	addi	a0,a0,434 # 6960 <malloc+0x9aa>
    47b6:	00001097          	auipc	ra,0x1
    47ba:	748080e7          	jalr	1864(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    47be:	4505                	li	a0,1
    47c0:	00001097          	auipc	ra,0x1
    47c4:	3ce080e7          	jalr	974(ra) # 5b8e <exit>
        printf("%s: wait wrong pid\n", s);
    47c8:	85ce                	mv	a1,s3
    47ca:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    47ce:	38e50513          	addi	a0,a0,910 # 6b58 <malloc+0xb54>
    47d2:	00001097          	auipc	ra,0x1
    47d6:	774080e7          	jalr	1908(ra) # 5f46 <printf>
=======
    47ce:	31e50513          	addi	a0,a0,798 # 6ae8 <malloc+0xb32>
    47d2:	00001097          	auipc	ra,0x1
    47d6:	72c080e7          	jalr	1836(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    47da:	4505                	li	a0,1
    47dc:	00001097          	auipc	ra,0x1
    47e0:	3b2080e7          	jalr	946(ra) # 5b8e <exit>
      int pid2 = fork();
    47e4:	00001097          	auipc	ra,0x1
    47e8:	3a2080e7          	jalr	930(ra) # 5b86 <fork>
      if(pid2 < 0){
    47ec:	00054763          	bltz	a0,47fa <reparent+0x9c>
      exit(0);
    47f0:	4501                	li	a0,0
    47f2:	00001097          	auipc	ra,0x1
    47f6:	39c080e7          	jalr	924(ra) # 5b8e <exit>
        kill(master_pid);
    47fa:	8552                	mv	a0,s4
    47fc:	00001097          	auipc	ra,0x1
    4800:	3c2080e7          	jalr	962(ra) # 5bbe <kill>
        exit(1);
    4804:	4505                	li	a0,1
    4806:	00001097          	auipc	ra,0x1
    480a:	388080e7          	jalr	904(ra) # 5b8e <exit>

000000000000480e <sbrkfail>:
{
    480e:	7119                	addi	sp,sp,-128
    4810:	fc86                	sd	ra,120(sp)
    4812:	f8a2                	sd	s0,112(sp)
    4814:	f4a6                	sd	s1,104(sp)
    4816:	f0ca                	sd	s2,96(sp)
    4818:	ecce                	sd	s3,88(sp)
    481a:	e8d2                	sd	s4,80(sp)
    481c:	e4d6                	sd	s5,72(sp)
    481e:	0100                	addi	s0,sp,128
    4820:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    4822:	fb040513          	addi	a0,s0,-80
    4826:	00001097          	auipc	ra,0x1
    482a:	378080e7          	jalr	888(ra) # 5b9e <pipe>
    482e:	e901                	bnez	a0,483e <sbrkfail+0x30>
    4830:	f8040493          	addi	s1,s0,-128
    4834:	fa840993          	addi	s3,s0,-88
    4838:	8926                	mv	s2,s1
    if(pids[i] != -1)
    483a:	5a7d                	li	s4,-1
    483c:	a085                	j	489c <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    483e:	85d6                	mv	a1,s5
    4840:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    4844:	29850513          	addi	a0,a0,664 # 6ad8 <malloc+0xad4>
    4848:	00001097          	auipc	ra,0x1
    484c:	6fe080e7          	jalr	1790(ra) # 5f46 <printf>
=======
    4844:	22850513          	addi	a0,a0,552 # 6a68 <malloc+0xab2>
    4848:	00001097          	auipc	ra,0x1
    484c:	6b6080e7          	jalr	1718(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4850:	4505                	li	a0,1
    4852:	00001097          	auipc	ra,0x1
    4856:	33c080e7          	jalr	828(ra) # 5b8e <exit>
      sbrk(BIG - (uint64)sbrk(0));
    485a:	00001097          	auipc	ra,0x1
    485e:	3bc080e7          	jalr	956(ra) # 5c16 <sbrk>
    4862:	064007b7          	lui	a5,0x6400
    4866:	40a7853b          	subw	a0,a5,a0
    486a:	00001097          	auipc	ra,0x1
    486e:	3ac080e7          	jalr	940(ra) # 5c16 <sbrk>
      write(fds[1], "x", 1);
    4872:	4605                	li	a2,1
    4874:	00002597          	auipc	a1,0x2
<<<<<<< HEAD
    4878:	94458593          	addi	a1,a1,-1724 # 61b8 <malloc+0x1b4>
=======
    4878:	8d458593          	addi	a1,a1,-1836 # 6148 <malloc+0x192>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    487c:	fb442503          	lw	a0,-76(s0)
    4880:	00001097          	auipc	ra,0x1
    4884:	32e080e7          	jalr	814(ra) # 5bae <write>
      for(;;) sleep(1000);
    4888:	3e800513          	li	a0,1000
    488c:	00001097          	auipc	ra,0x1
    4890:	392080e7          	jalr	914(ra) # 5c1e <sleep>
    4894:	bfd5                	j	4888 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4896:	0911                	addi	s2,s2,4
    4898:	03390563          	beq	s2,s3,48c2 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    489c:	00001097          	auipc	ra,0x1
    48a0:	2ea080e7          	jalr	746(ra) # 5b86 <fork>
    48a4:	00a92023          	sw	a0,0(s2)
    48a8:	d94d                	beqz	a0,485a <sbrkfail+0x4c>
    if(pids[i] != -1)
    48aa:	ff4506e3          	beq	a0,s4,4896 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    48ae:	4605                	li	a2,1
    48b0:	faf40593          	addi	a1,s0,-81
    48b4:	fb042503          	lw	a0,-80(s0)
    48b8:	00001097          	auipc	ra,0x1
    48bc:	2ee080e7          	jalr	750(ra) # 5ba6 <read>
    48c0:	bfd9                	j	4896 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    48c2:	6505                	lui	a0,0x1
    48c4:	00001097          	auipc	ra,0x1
    48c8:	352080e7          	jalr	850(ra) # 5c16 <sbrk>
    48cc:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    48ce:	597d                	li	s2,-1
    48d0:	a021                	j	48d8 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    48d2:	0491                	addi	s1,s1,4
    48d4:	01348f63          	beq	s1,s3,48f2 <sbrkfail+0xe4>
    if(pids[i] == -1)
    48d8:	4088                	lw	a0,0(s1)
    48da:	ff250ce3          	beq	a0,s2,48d2 <sbrkfail+0xc4>
    kill(pids[i]);
    48de:	00001097          	auipc	ra,0x1
    48e2:	2e0080e7          	jalr	736(ra) # 5bbe <kill>
    wait(0);
    48e6:	4501                	li	a0,0
    48e8:	00001097          	auipc	ra,0x1
    48ec:	2ae080e7          	jalr	686(ra) # 5b96 <wait>
    48f0:	b7cd                	j	48d2 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    48f2:	57fd                	li	a5,-1
    48f4:	04fa0163          	beq	s4,a5,4936 <sbrkfail+0x128>
  pid = fork();
    48f8:	00001097          	auipc	ra,0x1
    48fc:	28e080e7          	jalr	654(ra) # 5b86 <fork>
    4900:	84aa                	mv	s1,a0
  if(pid < 0){
    4902:	04054863          	bltz	a0,4952 <sbrkfail+0x144>
  if(pid == 0){
    4906:	c525                	beqz	a0,496e <sbrkfail+0x160>
  wait(&xstatus);
    4908:	fbc40513          	addi	a0,s0,-68
    490c:	00001097          	auipc	ra,0x1
    4910:	28a080e7          	jalr	650(ra) # 5b96 <wait>
  if(xstatus != -1 && xstatus != 2)
    4914:	fbc42783          	lw	a5,-68(s0)
    4918:	577d                	li	a4,-1
    491a:	00e78563          	beq	a5,a4,4924 <sbrkfail+0x116>
    491e:	4709                	li	a4,2
    4920:	08e79d63          	bne	a5,a4,49ba <sbrkfail+0x1ac>
}
    4924:	70e6                	ld	ra,120(sp)
    4926:	7446                	ld	s0,112(sp)
    4928:	74a6                	ld	s1,104(sp)
    492a:	7906                	ld	s2,96(sp)
    492c:	69e6                	ld	s3,88(sp)
    492e:	6a46                	ld	s4,80(sp)
    4930:	6aa6                	ld	s5,72(sp)
    4932:	6109                	addi	sp,sp,128
    4934:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4936:	85d6                	mv	a1,s5
    4938:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    493c:	3f850513          	addi	a0,a0,1016 # 7d30 <malloc+0x1d2c>
    4940:	00001097          	auipc	ra,0x1
    4944:	606080e7          	jalr	1542(ra) # 5f46 <printf>
=======
    493c:	38850513          	addi	a0,a0,904 # 7cc0 <malloc+0x1d0a>
    4940:	00001097          	auipc	ra,0x1
    4944:	5be080e7          	jalr	1470(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4948:	4505                	li	a0,1
    494a:	00001097          	auipc	ra,0x1
    494e:	244080e7          	jalr	580(ra) # 5b8e <exit>
    printf("%s: fork failed\n", s);
    4952:	85d6                	mv	a1,s5
    4954:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
    4958:	07c50513          	addi	a0,a0,124 # 69d0 <malloc+0x9cc>
    495c:	00001097          	auipc	ra,0x1
    4960:	5ea080e7          	jalr	1514(ra) # 5f46 <printf>
=======
    4958:	00c50513          	addi	a0,a0,12 # 6960 <malloc+0x9aa>
    495c:	00001097          	auipc	ra,0x1
    4960:	5a2080e7          	jalr	1442(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4964:	4505                	li	a0,1
    4966:	00001097          	auipc	ra,0x1
    496a:	228080e7          	jalr	552(ra) # 5b8e <exit>
    a = sbrk(0);
    496e:	4501                	li	a0,0
    4970:	00001097          	auipc	ra,0x1
    4974:	2a6080e7          	jalr	678(ra) # 5c16 <sbrk>
    4978:	892a                	mv	s2,a0
    sbrk(10*BIG);
    497a:	3e800537          	lui	a0,0x3e800
    497e:	00001097          	auipc	ra,0x1
    4982:	298080e7          	jalr	664(ra) # 5c16 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4986:	87ca                	mv	a5,s2
    4988:	3e800737          	lui	a4,0x3e800
    498c:	993a                	add	s2,s2,a4
    498e:	6705                	lui	a4,0x1
      n += *(a+i);
    4990:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63f0388>
    4994:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4996:	97ba                	add	a5,a5,a4
    4998:	ff279ce3          	bne	a5,s2,4990 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    499c:	8626                	mv	a2,s1
    499e:	85d6                	mv	a1,s5
    49a0:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    49a4:	3b050513          	addi	a0,a0,944 # 7d50 <malloc+0x1d4c>
    49a8:	00001097          	auipc	ra,0x1
    49ac:	59e080e7          	jalr	1438(ra) # 5f46 <printf>
=======
    49a4:	34050513          	addi	a0,a0,832 # 7ce0 <malloc+0x1d2a>
    49a8:	00001097          	auipc	ra,0x1
    49ac:	556080e7          	jalr	1366(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    49b0:	4505                	li	a0,1
    49b2:	00001097          	auipc	ra,0x1
    49b6:	1dc080e7          	jalr	476(ra) # 5b8e <exit>
    exit(1);
    49ba:	4505                	li	a0,1
    49bc:	00001097          	auipc	ra,0x1
    49c0:	1d2080e7          	jalr	466(ra) # 5b8e <exit>

00000000000049c4 <mem>:
{
    49c4:	7139                	addi	sp,sp,-64
    49c6:	fc06                	sd	ra,56(sp)
    49c8:	f822                	sd	s0,48(sp)
    49ca:	f426                	sd	s1,40(sp)
    49cc:	f04a                	sd	s2,32(sp)
    49ce:	ec4e                	sd	s3,24(sp)
    49d0:	0080                	addi	s0,sp,64
    49d2:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    49d4:	00001097          	auipc	ra,0x1
    49d8:	1b2080e7          	jalr	434(ra) # 5b86 <fork>
    m1 = 0;
    49dc:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    49de:	6909                	lui	s2,0x2
    49e0:	71190913          	addi	s2,s2,1809 # 2711 <copyinstr3+0x107>
  if((pid = fork()) == 0){
    49e4:	c115                	beqz	a0,4a08 <mem+0x44>
    wait(&xstatus);
    49e6:	fcc40513          	addi	a0,s0,-52
    49ea:	00001097          	auipc	ra,0x1
    49ee:	1ac080e7          	jalr	428(ra) # 5b96 <wait>
    if(xstatus == -1){
    49f2:	fcc42503          	lw	a0,-52(s0)
    49f6:	57fd                	li	a5,-1
    49f8:	06f50363          	beq	a0,a5,4a5e <mem+0x9a>
    exit(xstatus);
    49fc:	00001097          	auipc	ra,0x1
    4a00:	192080e7          	jalr	402(ra) # 5b8e <exit>
      *(char**)m2 = m1;
    4a04:	e104                	sd	s1,0(a0)
      m1 = m2;
    4a06:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    4a08:	854a                	mv	a0,s2
    4a0a:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
    4a0e:	5fa080e7          	jalr	1530(ra) # 6004 <malloc>
=======
    4a0e:	5ac080e7          	jalr	1452(ra) # 5fb6 <malloc>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    4a12:	f96d                	bnez	a0,4a04 <mem+0x40>
    while(m1){
    4a14:	c881                	beqz	s1,4a24 <mem+0x60>
      m2 = *(char**)m1;
    4a16:	8526                	mv	a0,s1
    4a18:	6084                	ld	s1,0(s1)
      free(m1);
    4a1a:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
    4a1e:	562080e7          	jalr	1378(ra) # 5f7c <free>
=======
    4a1e:	51a080e7          	jalr	1306(ra) # 5f34 <free>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    while(m1){
    4a22:	f8f5                	bnez	s1,4a16 <mem+0x52>
    m1 = malloc(1024*20);
    4a24:	6515                	lui	a0,0x5
    4a26:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
    4a2a:	5de080e7          	jalr	1502(ra) # 6004 <malloc>
=======
    4a2a:	590080e7          	jalr	1424(ra) # 5fb6 <malloc>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(m1 == 0){
    4a2e:	c911                	beqz	a0,4a42 <mem+0x7e>
    free(m1);
    4a30:	00001097          	auipc	ra,0x1
<<<<<<< HEAD
    4a34:	54c080e7          	jalr	1356(ra) # 5f7c <free>
=======
    4a34:	504080e7          	jalr	1284(ra) # 5f34 <free>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(0);
    4a38:	4501                	li	a0,0
    4a3a:	00001097          	auipc	ra,0x1
    4a3e:	154080e7          	jalr	340(ra) # 5b8e <exit>
      printf("couldn't allocate mem?!!\n", s);
    4a42:	85ce                	mv	a1,s3
    4a44:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4a48:	33c50513          	addi	a0,a0,828 # 7d80 <malloc+0x1d7c>
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	4fa080e7          	jalr	1274(ra) # 5f46 <printf>
=======
    4a48:	2cc50513          	addi	a0,a0,716 # 7d10 <malloc+0x1d5a>
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	4b2080e7          	jalr	1202(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    4a54:	4505                	li	a0,1
    4a56:	00001097          	auipc	ra,0x1
    4a5a:	138080e7          	jalr	312(ra) # 5b8e <exit>
      exit(0);
    4a5e:	4501                	li	a0,0
    4a60:	00001097          	auipc	ra,0x1
    4a64:	12e080e7          	jalr	302(ra) # 5b8e <exit>

0000000000004a68 <sharedfd>:
{
    4a68:	7159                	addi	sp,sp,-112
    4a6a:	f486                	sd	ra,104(sp)
    4a6c:	f0a2                	sd	s0,96(sp)
    4a6e:	eca6                	sd	s1,88(sp)
    4a70:	e8ca                	sd	s2,80(sp)
    4a72:	e4ce                	sd	s3,72(sp)
    4a74:	e0d2                	sd	s4,64(sp)
    4a76:	fc56                	sd	s5,56(sp)
    4a78:	f85a                	sd	s6,48(sp)
    4a7a:	f45e                	sd	s7,40(sp)
    4a7c:	1880                	addi	s0,sp,112
    4a7e:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4a80:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4a84:	32050513          	addi	a0,a0,800 # 7da0 <malloc+0x1d9c>
=======
    4a84:	2b050513          	addi	a0,a0,688 # 7d30 <malloc+0x1d7a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    4a88:	00001097          	auipc	ra,0x1
    4a8c:	156080e7          	jalr	342(ra) # 5bde <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4a90:	20200593          	li	a1,514
    4a94:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4a98:	30c50513          	addi	a0,a0,780 # 7da0 <malloc+0x1d9c>
=======
    4a98:	29c50513          	addi	a0,a0,668 # 7d30 <malloc+0x1d7a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    4a9c:	00001097          	auipc	ra,0x1
    4aa0:	132080e7          	jalr	306(ra) # 5bce <open>
  if(fd < 0){
    4aa4:	04054a63          	bltz	a0,4af8 <sharedfd+0x90>
    4aa8:	892a                	mv	s2,a0
  pid = fork();
    4aaa:	00001097          	auipc	ra,0x1
    4aae:	0dc080e7          	jalr	220(ra) # 5b86 <fork>
    4ab2:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4ab4:	07000593          	li	a1,112
    4ab8:	e119                	bnez	a0,4abe <sharedfd+0x56>
    4aba:	06300593          	li	a1,99
    4abe:	4629                	li	a2,10
    4ac0:	fa040513          	addi	a0,s0,-96
    4ac4:	00001097          	auipc	ra,0x1
    4ac8:	ed0080e7          	jalr	-304(ra) # 5994 <memset>
    4acc:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4ad0:	4629                	li	a2,10
    4ad2:	fa040593          	addi	a1,s0,-96
    4ad6:	854a                	mv	a0,s2
    4ad8:	00001097          	auipc	ra,0x1
    4adc:	0d6080e7          	jalr	214(ra) # 5bae <write>
    4ae0:	47a9                	li	a5,10
    4ae2:	02f51963          	bne	a0,a5,4b14 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4ae6:	34fd                	addiw	s1,s1,-1
    4ae8:	f4e5                	bnez	s1,4ad0 <sharedfd+0x68>
  if(pid == 0) {
    4aea:	04099363          	bnez	s3,4b30 <sharedfd+0xc8>
    exit(0);
    4aee:	4501                	li	a0,0
    4af0:	00001097          	auipc	ra,0x1
    4af4:	09e080e7          	jalr	158(ra) # 5b8e <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4af8:	85d2                	mv	a1,s4
    4afa:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4afe:	2b650513          	addi	a0,a0,694 # 7db0 <malloc+0x1dac>
    4b02:	00001097          	auipc	ra,0x1
    4b06:	444080e7          	jalr	1092(ra) # 5f46 <printf>
=======
    4afe:	24650513          	addi	a0,a0,582 # 7d40 <malloc+0x1d8a>
    4b02:	00001097          	auipc	ra,0x1
    4b06:	3fc080e7          	jalr	1020(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4b0a:	4505                	li	a0,1
    4b0c:	00001097          	auipc	ra,0x1
    4b10:	082080e7          	jalr	130(ra) # 5b8e <exit>
      printf("%s: write sharedfd failed\n", s);
    4b14:	85d2                	mv	a1,s4
    4b16:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4b1a:	2c250513          	addi	a0,a0,706 # 7dd8 <malloc+0x1dd4>
    4b1e:	00001097          	auipc	ra,0x1
    4b22:	428080e7          	jalr	1064(ra) # 5f46 <printf>
=======
    4b1a:	25250513          	addi	a0,a0,594 # 7d68 <malloc+0x1db2>
    4b1e:	00001097          	auipc	ra,0x1
    4b22:	3e0080e7          	jalr	992(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    4b26:	4505                	li	a0,1
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	066080e7          	jalr	102(ra) # 5b8e <exit>
    wait(&xstatus);
    4b30:	f9c40513          	addi	a0,s0,-100
    4b34:	00001097          	auipc	ra,0x1
    4b38:	062080e7          	jalr	98(ra) # 5b96 <wait>
    if(xstatus != 0)
    4b3c:	f9c42983          	lw	s3,-100(s0)
    4b40:	00098763          	beqz	s3,4b4e <sharedfd+0xe6>
      exit(xstatus);
    4b44:	854e                	mv	a0,s3
    4b46:	00001097          	auipc	ra,0x1
    4b4a:	048080e7          	jalr	72(ra) # 5b8e <exit>
  close(fd);
    4b4e:	854a                	mv	a0,s2
    4b50:	00001097          	auipc	ra,0x1
    4b54:	066080e7          	jalr	102(ra) # 5bb6 <close>
  fd = open("sharedfd", 0);
    4b58:	4581                	li	a1,0
    4b5a:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4b5e:	24650513          	addi	a0,a0,582 # 7da0 <malloc+0x1d9c>
=======
    4b5e:	1d650513          	addi	a0,a0,470 # 7d30 <malloc+0x1d7a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    4b62:	00001097          	auipc	ra,0x1
    4b66:	06c080e7          	jalr	108(ra) # 5bce <open>
    4b6a:	8baa                	mv	s7,a0
  nc = np = 0;
    4b6c:	8ace                	mv	s5,s3
  if(fd < 0){
    4b6e:	02054563          	bltz	a0,4b98 <sharedfd+0x130>
    4b72:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4b76:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4b7a:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4b7e:	4629                	li	a2,10
    4b80:	fa040593          	addi	a1,s0,-96
    4b84:	855e                	mv	a0,s7
    4b86:	00001097          	auipc	ra,0x1
    4b8a:	020080e7          	jalr	32(ra) # 5ba6 <read>
    4b8e:	02a05f63          	blez	a0,4bcc <sharedfd+0x164>
    4b92:	fa040793          	addi	a5,s0,-96
    4b96:	a01d                	j	4bbc <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4b98:	85d2                	mv	a1,s4
    4b9a:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4b9e:	25e50513          	addi	a0,a0,606 # 7df8 <malloc+0x1df4>
    4ba2:	00001097          	auipc	ra,0x1
    4ba6:	3a4080e7          	jalr	932(ra) # 5f46 <printf>
=======
    4b9e:	1ee50513          	addi	a0,a0,494 # 7d88 <malloc+0x1dd2>
    4ba2:	00001097          	auipc	ra,0x1
    4ba6:	35c080e7          	jalr	860(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4baa:	4505                	li	a0,1
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	fe2080e7          	jalr	-30(ra) # 5b8e <exit>
        nc++;
    4bb4:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4bb6:	0785                	addi	a5,a5,1
    4bb8:	fd2783e3          	beq	a5,s2,4b7e <sharedfd+0x116>
      if(buf[i] == 'c')
    4bbc:	0007c703          	lbu	a4,0(a5)
    4bc0:	fe970ae3          	beq	a4,s1,4bb4 <sharedfd+0x14c>
      if(buf[i] == 'p')
    4bc4:	ff6719e3          	bne	a4,s6,4bb6 <sharedfd+0x14e>
        np++;
    4bc8:	2a85                	addiw	s5,s5,1
    4bca:	b7f5                	j	4bb6 <sharedfd+0x14e>
  close(fd);
    4bcc:	855e                	mv	a0,s7
    4bce:	00001097          	auipc	ra,0x1
    4bd2:	fe8080e7          	jalr	-24(ra) # 5bb6 <close>
  unlink("sharedfd");
    4bd6:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4bda:	1ca50513          	addi	a0,a0,458 # 7da0 <malloc+0x1d9c>
=======
    4bda:	15a50513          	addi	a0,a0,346 # 7d30 <malloc+0x1d7a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    4bde:	00001097          	auipc	ra,0x1
    4be2:	000080e7          	jalr	ra # 5bde <unlink>
  if(nc == N*SZ && np == N*SZ){
    4be6:	6789                	lui	a5,0x2
    4be8:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0x106>
    4bec:	00f99763          	bne	s3,a5,4bfa <sharedfd+0x192>
    4bf0:	6789                	lui	a5,0x2
    4bf2:	71078793          	addi	a5,a5,1808 # 2710 <copyinstr3+0x106>
    4bf6:	02fa8063          	beq	s5,a5,4c16 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4bfa:	85d2                	mv	a1,s4
    4bfc:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    4c00:	22450513          	addi	a0,a0,548 # 7e20 <malloc+0x1e1c>
    4c04:	00001097          	auipc	ra,0x1
    4c08:	342080e7          	jalr	834(ra) # 5f46 <printf>
=======
    4c00:	1b450513          	addi	a0,a0,436 # 7db0 <malloc+0x1dfa>
    4c04:	00001097          	auipc	ra,0x1
    4c08:	2fa080e7          	jalr	762(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4c0c:	4505                	li	a0,1
    4c0e:	00001097          	auipc	ra,0x1
    4c12:	f80080e7          	jalr	-128(ra) # 5b8e <exit>
    exit(0);
    4c16:	4501                	li	a0,0
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	f76080e7          	jalr	-138(ra) # 5b8e <exit>

0000000000004c20 <fourfiles>:
{
    4c20:	7135                	addi	sp,sp,-160
    4c22:	ed06                	sd	ra,152(sp)
    4c24:	e922                	sd	s0,144(sp)
    4c26:	e526                	sd	s1,136(sp)
    4c28:	e14a                	sd	s2,128(sp)
    4c2a:	fcce                	sd	s3,120(sp)
    4c2c:	f8d2                	sd	s4,112(sp)
    4c2e:	f4d6                	sd	s5,104(sp)
    4c30:	f0da                	sd	s6,96(sp)
    4c32:	ecde                	sd	s7,88(sp)
    4c34:	e8e2                	sd	s8,80(sp)
    4c36:	e4e6                	sd	s9,72(sp)
    4c38:	e0ea                	sd	s10,64(sp)
    4c3a:	fc6e                	sd	s11,56(sp)
    4c3c:	1100                	addi	s0,sp,160
    4c3e:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
<<<<<<< HEAD
    4c42:	00001797          	auipc	a5,0x1
    4c46:	4ae78793          	addi	a5,a5,1198 # 60f0 <malloc+0xec>
    4c4a:	f6f43823          	sd	a5,-144(s0)
    4c4e:	00001797          	auipc	a5,0x1
    4c52:	4aa78793          	addi	a5,a5,1194 # 60f8 <malloc+0xf4>
    4c56:	f6f43c23          	sd	a5,-136(s0)
    4c5a:	00001797          	auipc	a5,0x1
    4c5e:	4a678793          	addi	a5,a5,1190 # 6100 <malloc+0xfc>
    4c62:	f8f43023          	sd	a5,-128(s0)
    4c66:	00001797          	auipc	a5,0x1
    4c6a:	4a278793          	addi	a5,a5,1186 # 6108 <malloc+0x104>
    4c6e:	f8f43423          	sd	a5,-120(s0)
=======
    4c40:	00003797          	auipc	a5,0x3
    4c44:	18878793          	addi	a5,a5,392 # 7dc8 <malloc+0x1e12>
    4c48:	f6f43823          	sd	a5,-144(s0)
    4c4c:	00003797          	auipc	a5,0x3
    4c50:	18478793          	addi	a5,a5,388 # 7dd0 <malloc+0x1e1a>
    4c54:	f6f43c23          	sd	a5,-136(s0)
    4c58:	00003797          	auipc	a5,0x3
    4c5c:	18078793          	addi	a5,a5,384 # 7dd8 <malloc+0x1e22>
    4c60:	f8f43023          	sd	a5,-128(s0)
    4c64:	00003797          	auipc	a5,0x3
    4c68:	17c78793          	addi	a5,a5,380 # 7de0 <malloc+0x1e2a>
    4c6c:	f8f43423          	sd	a5,-120(s0)
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(pi = 0; pi < NCHILD; pi++){
    4c70:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4c74:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4c76:	4481                	li	s1,0
    4c78:	4a11                	li	s4,4
    fname = names[pi];
    4c7a:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4c7e:	854e                	mv	a0,s3
    4c80:	00001097          	auipc	ra,0x1
    4c84:	f5e080e7          	jalr	-162(ra) # 5bde <unlink>
    pid = fork();
    4c88:	00001097          	auipc	ra,0x1
    4c8c:	efe080e7          	jalr	-258(ra) # 5b86 <fork>
    if(pid < 0){
    4c90:	04054063          	bltz	a0,4cd0 <fourfiles+0xb0>
    if(pid == 0){
    4c94:	cd21                	beqz	a0,4cec <fourfiles+0xcc>
  for(pi = 0; pi < NCHILD; pi++){
    4c96:	2485                	addiw	s1,s1,1
    4c98:	0921                	addi	s2,s2,8
    4c9a:	ff4490e3          	bne	s1,s4,4c7a <fourfiles+0x5a>
    4c9e:	4491                	li	s1,4
    wait(&xstatus);
    4ca0:	f6c40513          	addi	a0,s0,-148
    4ca4:	00001097          	auipc	ra,0x1
    4ca8:	ef2080e7          	jalr	-270(ra) # 5b96 <wait>
    if(xstatus != 0)
    4cac:	f6c42a83          	lw	s5,-148(s0)
    4cb0:	0c0a9863          	bnez	s5,4d80 <fourfiles+0x160>
  for(pi = 0; pi < NCHILD; pi++){
    4cb4:	34fd                	addiw	s1,s1,-1
    4cb6:	f4ed                	bnez	s1,4ca0 <fourfiles+0x80>
    4cb8:	03000b13          	li	s6,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4cbc:	00008a17          	auipc	s4,0x8
    4cc0:	fbca0a13          	addi	s4,s4,-68 # cc78 <buf>
    if(total != N*SZ){
    4cc4:	6d05                	lui	s10,0x1
    4cc6:	770d0d13          	addi	s10,s10,1904 # 1770 <exectest+0x30>
  for(i = 0; i < NCHILD; i++){
    4cca:	03400d93          	li	s11,52
    4cce:	a22d                	j	4df8 <fourfiles+0x1d8>
      printf("fork failed\n", s);
<<<<<<< HEAD
    4cda:	f5843583          	ld	a1,-168(s0)
    4cde:	00002517          	auipc	a0,0x2
    4ce2:	0fa50513          	addi	a0,a0,250 # 6dd8 <malloc+0xdd4>
    4ce6:	00001097          	auipc	ra,0x1
    4cea:	260080e7          	jalr	608(ra) # 5f46 <printf>
=======
    4cd0:	85e6                	mv	a1,s9
    4cd2:	00002517          	auipc	a0,0x2
    4cd6:	09650513          	addi	a0,a0,150 # 6d68 <malloc+0xdb2>
    4cda:	00001097          	auipc	ra,0x1
    4cde:	224080e7          	jalr	548(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    4ce2:	4505                	li	a0,1
    4ce4:	00001097          	auipc	ra,0x1
    4ce8:	eaa080e7          	jalr	-342(ra) # 5b8e <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4cec:	20200593          	li	a1,514
    4cf0:	854e                	mv	a0,s3
    4cf2:	00001097          	auipc	ra,0x1
    4cf6:	edc080e7          	jalr	-292(ra) # 5bce <open>
    4cfa:	892a                	mv	s2,a0
      if(fd < 0){
    4cfc:	04054763          	bltz	a0,4d4a <fourfiles+0x12a>
      memset(buf, '0'+pi, SZ);
    4d00:	1f400613          	li	a2,500
    4d04:	0304859b          	addiw	a1,s1,48
    4d08:	00008517          	auipc	a0,0x8
    4d0c:	f7050513          	addi	a0,a0,-144 # cc78 <buf>
    4d10:	00001097          	auipc	ra,0x1
    4d14:	c84080e7          	jalr	-892(ra) # 5994 <memset>
    4d18:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4d1a:	00008997          	auipc	s3,0x8
    4d1e:	f5e98993          	addi	s3,s3,-162 # cc78 <buf>
    4d22:	1f400613          	li	a2,500
    4d26:	85ce                	mv	a1,s3
    4d28:	854a                	mv	a0,s2
    4d2a:	00001097          	auipc	ra,0x1
    4d2e:	e84080e7          	jalr	-380(ra) # 5bae <write>
    4d32:	85aa                	mv	a1,a0
    4d34:	1f400793          	li	a5,500
    4d38:	02f51763          	bne	a0,a5,4d66 <fourfiles+0x146>
      for(i = 0; i < N; i++){
    4d3c:	34fd                	addiw	s1,s1,-1
    4d3e:	f0f5                	bnez	s1,4d22 <fourfiles+0x102>
      exit(0);
    4d40:	4501                	li	a0,0
    4d42:	00001097          	auipc	ra,0x1
    4d46:	e4c080e7          	jalr	-436(ra) # 5b8e <exit>
        printf("create failed\n", s);
<<<<<<< HEAD
    4d56:	f5843583          	ld	a1,-168(s0)
    4d5a:	00003517          	auipc	a0,0x3
    4d5e:	0de50513          	addi	a0,a0,222 # 7e38 <malloc+0x1e34>
    4d62:	00001097          	auipc	ra,0x1
    4d66:	1e4080e7          	jalr	484(ra) # 5f46 <printf>
=======
    4d4a:	85e6                	mv	a1,s9
    4d4c:	00003517          	auipc	a0,0x3
    4d50:	09c50513          	addi	a0,a0,156 # 7de8 <malloc+0x1e32>
    4d54:	00001097          	auipc	ra,0x1
    4d58:	1aa080e7          	jalr	426(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    4d5c:	4505                	li	a0,1
    4d5e:	00001097          	auipc	ra,0x1
    4d62:	e30080e7          	jalr	-464(ra) # 5b8e <exit>
          printf("write failed %d\n", n);
<<<<<<< HEAD
    4d74:	00003517          	auipc	a0,0x3
    4d78:	0d450513          	addi	a0,a0,212 # 7e48 <malloc+0x1e44>
    4d7c:	00001097          	auipc	ra,0x1
    4d80:	1ca080e7          	jalr	458(ra) # 5f46 <printf>
=======
    4d66:	00003517          	auipc	a0,0x3
    4d6a:	09250513          	addi	a0,a0,146 # 7df8 <malloc+0x1e42>
    4d6e:	00001097          	auipc	ra,0x1
    4d72:	190080e7          	jalr	400(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
          exit(1);
    4d76:	4505                	li	a0,1
    4d78:	00001097          	auipc	ra,0x1
    4d7c:	e16080e7          	jalr	-490(ra) # 5b8e <exit>
      exit(xstatus);
    4d80:	8556                	mv	a0,s5
    4d82:	00001097          	auipc	ra,0x1
    4d86:	e0c080e7          	jalr	-500(ra) # 5b8e <exit>
          printf("wrong char\n", s);
<<<<<<< HEAD
    4d98:	f5843583          	ld	a1,-168(s0)
    4d9c:	00003517          	auipc	a0,0x3
    4da0:	0c450513          	addi	a0,a0,196 # 7e60 <malloc+0x1e5c>
    4da4:	00001097          	auipc	ra,0x1
    4da8:	1a2080e7          	jalr	418(ra) # 5f46 <printf>
=======
    4d8a:	85e6                	mv	a1,s9
    4d8c:	00003517          	auipc	a0,0x3
    4d90:	08450513          	addi	a0,a0,132 # 7e10 <malloc+0x1e5a>
    4d94:	00001097          	auipc	ra,0x1
    4d98:	16a080e7          	jalr	362(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
          exit(1);
    4d9c:	4505                	li	a0,1
    4d9e:	00001097          	auipc	ra,0x1
    4da2:	df0080e7          	jalr	-528(ra) # 5b8e <exit>
      total += n;
    4da6:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4daa:	660d                	lui	a2,0x3
    4dac:	85d2                	mv	a1,s4
    4dae:	854e                	mv	a0,s3
    4db0:	00001097          	auipc	ra,0x1
    4db4:	df6080e7          	jalr	-522(ra) # 5ba6 <read>
    4db8:	02a05063          	blez	a0,4dd8 <fourfiles+0x1b8>
    4dbc:	00008797          	auipc	a5,0x8
    4dc0:	ebc78793          	addi	a5,a5,-324 # cc78 <buf>
    4dc4:	00f506b3          	add	a3,a0,a5
        if(buf[j] != '0'+i){
    4dc8:	0007c703          	lbu	a4,0(a5)
    4dcc:	fa971fe3          	bne	a4,s1,4d8a <fourfiles+0x16a>
      for(j = 0; j < n; j++){
    4dd0:	0785                	addi	a5,a5,1
    4dd2:	fed79be3          	bne	a5,a3,4dc8 <fourfiles+0x1a8>
    4dd6:	bfc1                	j	4da6 <fourfiles+0x186>
    close(fd);
    4dd8:	854e                	mv	a0,s3
    4dda:	00001097          	auipc	ra,0x1
    4dde:	ddc080e7          	jalr	-548(ra) # 5bb6 <close>
    if(total != N*SZ){
    4de2:	03a91863          	bne	s2,s10,4e12 <fourfiles+0x1f2>
    unlink(fname);
    4de6:	8562                	mv	a0,s8
    4de8:	00001097          	auipc	ra,0x1
    4dec:	df6080e7          	jalr	-522(ra) # 5bde <unlink>
  for(i = 0; i < NCHILD; i++){
    4df0:	0ba1                	addi	s7,s7,8
    4df2:	2b05                	addiw	s6,s6,1
    4df4:	03bb0d63          	beq	s6,s11,4e2e <fourfiles+0x20e>
    fname = names[i];
    4df8:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    4dfc:	4581                	li	a1,0
    4dfe:	8562                	mv	a0,s8
    4e00:	00001097          	auipc	ra,0x1
    4e04:	dce080e7          	jalr	-562(ra) # 5bce <open>
    4e08:	89aa                	mv	s3,a0
    total = 0;
    4e0a:	8956                	mv	s2,s5
        if(buf[j] != '0'+i){
    4e0c:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4e10:	bf69                	j	4daa <fourfiles+0x18a>
      printf("wrong length %d\n", total);
<<<<<<< HEAD
    4e28:	85ca                	mv	a1,s2
    4e2a:	00003517          	auipc	a0,0x3
    4e2e:	04650513          	addi	a0,a0,70 # 7e70 <malloc+0x1e6c>
    4e32:	00001097          	auipc	ra,0x1
    4e36:	114080e7          	jalr	276(ra) # 5f46 <printf>
=======
    4e12:	85ca                	mv	a1,s2
    4e14:	00003517          	auipc	a0,0x3
    4e18:	00c50513          	addi	a0,a0,12 # 7e20 <malloc+0x1e6a>
    4e1c:	00001097          	auipc	ra,0x1
    4e20:	0e2080e7          	jalr	226(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    4e24:	4505                	li	a0,1
    4e26:	00001097          	auipc	ra,0x1
    4e2a:	d68080e7          	jalr	-664(ra) # 5b8e <exit>
}
    4e2e:	60ea                	ld	ra,152(sp)
    4e30:	644a                	ld	s0,144(sp)
    4e32:	64aa                	ld	s1,136(sp)
    4e34:	690a                	ld	s2,128(sp)
    4e36:	79e6                	ld	s3,120(sp)
    4e38:	7a46                	ld	s4,112(sp)
    4e3a:	7aa6                	ld	s5,104(sp)
    4e3c:	7b06                	ld	s6,96(sp)
    4e3e:	6be6                	ld	s7,88(sp)
    4e40:	6c46                	ld	s8,80(sp)
    4e42:	6ca6                	ld	s9,72(sp)
    4e44:	6d06                	ld	s10,64(sp)
    4e46:	7de2                	ld	s11,56(sp)
    4e48:	610d                	addi	sp,sp,160
    4e4a:	8082                	ret

0000000000004e4c <concreate>:
{
    4e4c:	7135                	addi	sp,sp,-160
    4e4e:	ed06                	sd	ra,152(sp)
    4e50:	e922                	sd	s0,144(sp)
    4e52:	e526                	sd	s1,136(sp)
    4e54:	e14a                	sd	s2,128(sp)
    4e56:	fcce                	sd	s3,120(sp)
    4e58:	f8d2                	sd	s4,112(sp)
    4e5a:	f4d6                	sd	s5,104(sp)
    4e5c:	f0da                	sd	s6,96(sp)
    4e5e:	ecde                	sd	s7,88(sp)
    4e60:	1100                	addi	s0,sp,160
    4e62:	89aa                	mv	s3,a0
  file[0] = 'C';
    4e64:	04300793          	li	a5,67
    4e68:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4e6c:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4e70:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4e72:	4b0d                	li	s6,3
    4e74:	4a85                	li	s5,1
      link("C0", file);
<<<<<<< HEAD
    4e8c:	00003b97          	auipc	s7,0x3
    4e90:	ffcb8b93          	addi	s7,s7,-4 # 7e88 <malloc+0x1e84>
=======
    4e76:	00003b97          	auipc	s7,0x3
    4e7a:	fc2b8b93          	addi	s7,s7,-62 # 7e38 <malloc+0x1e82>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(i = 0; i < N; i++){
    4e7e:	02800a13          	li	s4,40
    4e82:	acc9                	j	5154 <concreate+0x308>
      link("C0", file);
    4e84:	fa840593          	addi	a1,s0,-88
    4e88:	855e                	mv	a0,s7
    4e8a:	00001097          	auipc	ra,0x1
    4e8e:	d64080e7          	jalr	-668(ra) # 5bee <link>
    if(pid == 0) {
    4e92:	a465                	j	513a <concreate+0x2ee>
    } else if(pid == 0 && (i % 5) == 1){
    4e94:	4795                	li	a5,5
    4e96:	02f9693b          	remw	s2,s2,a5
    4e9a:	4785                	li	a5,1
    4e9c:	02f90b63          	beq	s2,a5,4ed2 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4ea0:	20200593          	li	a1,514
    4ea4:	fa840513          	addi	a0,s0,-88
    4ea8:	00001097          	auipc	ra,0x1
    4eac:	d26080e7          	jalr	-730(ra) # 5bce <open>
      if(fd < 0){
    4eb0:	26055c63          	bgez	a0,5128 <concreate+0x2dc>
        printf("concreate create %s failed\n", file);
<<<<<<< HEAD
    4eca:	fa840593          	addi	a1,s0,-88
    4ece:	00003517          	auipc	a0,0x3
    4ed2:	fc250513          	addi	a0,a0,-62 # 7e90 <malloc+0x1e8c>
    4ed6:	00001097          	auipc	ra,0x1
    4eda:	070080e7          	jalr	112(ra) # 5f46 <printf>
=======
    4eb4:	fa840593          	addi	a1,s0,-88
    4eb8:	00003517          	auipc	a0,0x3
    4ebc:	f8850513          	addi	a0,a0,-120 # 7e40 <malloc+0x1e8a>
    4ec0:	00001097          	auipc	ra,0x1
    4ec4:	03e080e7          	jalr	62(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    4ec8:	4505                	li	a0,1
    4eca:	00001097          	auipc	ra,0x1
    4ece:	cc4080e7          	jalr	-828(ra) # 5b8e <exit>
      link("C0", file);
<<<<<<< HEAD
    4ee8:	fa840593          	addi	a1,s0,-88
    4eec:	00003517          	auipc	a0,0x3
    4ef0:	f9c50513          	addi	a0,a0,-100 # 7e88 <malloc+0x1e84>
    4ef4:	00001097          	auipc	ra,0x1
    4ef8:	d32080e7          	jalr	-718(ra) # 5c26 <link>
=======
    4ed2:	fa840593          	addi	a1,s0,-88
    4ed6:	00003517          	auipc	a0,0x3
    4eda:	f6250513          	addi	a0,a0,-158 # 7e38 <malloc+0x1e82>
    4ede:	00001097          	auipc	ra,0x1
    4ee2:	d10080e7          	jalr	-752(ra) # 5bee <link>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(0);
    4ee6:	4501                	li	a0,0
    4ee8:	00001097          	auipc	ra,0x1
    4eec:	ca6080e7          	jalr	-858(ra) # 5b8e <exit>
        exit(1);
    4ef0:	4505                	li	a0,1
    4ef2:	00001097          	auipc	ra,0x1
    4ef6:	c9c080e7          	jalr	-868(ra) # 5b8e <exit>
  memset(fa, 0, sizeof(fa));
    4efa:	02800613          	li	a2,40
    4efe:	4581                	li	a1,0
    4f00:	f8040513          	addi	a0,s0,-128
    4f04:	00001097          	auipc	ra,0x1
    4f08:	a90080e7          	jalr	-1392(ra) # 5994 <memset>
  fd = open(".", 0);
<<<<<<< HEAD
    4f22:	4581                	li	a1,0
    4f24:	00002517          	auipc	a0,0x2
    4f28:	90c50513          	addi	a0,a0,-1780 # 6830 <malloc+0x82c>
    4f2c:	00001097          	auipc	ra,0x1
    4f30:	cda080e7          	jalr	-806(ra) # 5c06 <open>
    4f34:	892a                	mv	s2,a0
=======
    4f0c:	4581                	li	a1,0
    4f0e:	00002517          	auipc	a0,0x2
    4f12:	8b250513          	addi	a0,a0,-1870 # 67c0 <malloc+0x80a>
    4f16:	00001097          	auipc	ra,0x1
    4f1a:	cb8080e7          	jalr	-840(ra) # 5bce <open>
    4f1e:	892a                	mv	s2,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  n = 0;
    4f20:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4f22:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4f26:	02700b13          	li	s6,39
      fa[i] = 1;
    4f2a:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4f2c:	4641                	li	a2,16
    4f2e:	f7040593          	addi	a1,s0,-144
    4f32:	854a                	mv	a0,s2
    4f34:	00001097          	auipc	ra,0x1
    4f38:	c72080e7          	jalr	-910(ra) # 5ba6 <read>
    4f3c:	08a05263          	blez	a0,4fc0 <concreate+0x174>
    if(de.inum == 0)
    4f40:	f7045783          	lhu	a5,-144(s0)
    4f44:	d7e5                	beqz	a5,4f2c <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4f46:	f7244783          	lbu	a5,-142(s0)
    4f4a:	ff4791e3          	bne	a5,s4,4f2c <concreate+0xe0>
    4f4e:	f7444783          	lbu	a5,-140(s0)
    4f52:	ffe9                	bnez	a5,4f2c <concreate+0xe0>
      i = de.name[1] - '0';
    4f54:	f7344783          	lbu	a5,-141(s0)
    4f58:	fd07879b          	addiw	a5,a5,-48
    4f5c:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4f60:	02eb6063          	bltu	s6,a4,4f80 <concreate+0x134>
      if(fa[i]){
    4f64:	fb070793          	addi	a5,a4,-80 # fb0 <linktest+0xbc>
    4f68:	97a2                	add	a5,a5,s0
    4f6a:	fd07c783          	lbu	a5,-48(a5)
    4f6e:	eb8d                	bnez	a5,4fa0 <concreate+0x154>
      fa[i] = 1;
    4f70:	fb070793          	addi	a5,a4,-80
    4f74:	00878733          	add	a4,a5,s0
    4f78:	fd770823          	sb	s7,-48(a4)
      n++;
    4f7c:	2a85                	addiw	s5,s5,1
    4f7e:	b77d                	j	4f2c <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
<<<<<<< HEAD
    4f94:	f7240613          	addi	a2,s0,-142
    4f98:	85ce                	mv	a1,s3
    4f9a:	00003517          	auipc	a0,0x3
    4f9e:	f1650513          	addi	a0,a0,-234 # 7eb0 <malloc+0x1eac>
    4fa2:	00001097          	auipc	ra,0x1
    4fa6:	fa4080e7          	jalr	-92(ra) # 5f46 <printf>
=======
    4f80:	f7240613          	addi	a2,s0,-142
    4f84:	85ce                	mv	a1,s3
    4f86:	00003517          	auipc	a0,0x3
    4f8a:	eda50513          	addi	a0,a0,-294 # 7e60 <malloc+0x1eaa>
    4f8e:	00001097          	auipc	ra,0x1
    4f92:	f70080e7          	jalr	-144(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    4f96:	4505                	li	a0,1
    4f98:	00001097          	auipc	ra,0x1
    4f9c:	bf6080e7          	jalr	-1034(ra) # 5b8e <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
<<<<<<< HEAD
    4fb4:	f7240613          	addi	a2,s0,-142
    4fb8:	85ce                	mv	a1,s3
    4fba:	00003517          	auipc	a0,0x3
    4fbe:	f1650513          	addi	a0,a0,-234 # 7ed0 <malloc+0x1ecc>
    4fc2:	00001097          	auipc	ra,0x1
    4fc6:	f84080e7          	jalr	-124(ra) # 5f46 <printf>
=======
    4fa0:	f7240613          	addi	a2,s0,-142
    4fa4:	85ce                	mv	a1,s3
    4fa6:	00003517          	auipc	a0,0x3
    4faa:	eda50513          	addi	a0,a0,-294 # 7e80 <malloc+0x1eca>
    4fae:	00001097          	auipc	ra,0x1
    4fb2:	f50080e7          	jalr	-176(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    4fb6:	4505                	li	a0,1
    4fb8:	00001097          	auipc	ra,0x1
    4fbc:	bd6080e7          	jalr	-1066(ra) # 5b8e <exit>
  close(fd);
    4fc0:	854a                	mv	a0,s2
    4fc2:	00001097          	auipc	ra,0x1
    4fc6:	bf4080e7          	jalr	-1036(ra) # 5bb6 <close>
  if(n != N){
    4fca:	02800793          	li	a5,40
    4fce:	00fa9763          	bne	s5,a5,4fdc <concreate+0x190>
    if(((i % 3) == 0 && pid == 0) ||
    4fd2:	4a8d                	li	s5,3
    4fd4:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4fd6:	02800a13          	li	s4,40
    4fda:	a8c9                	j	50ac <concreate+0x260>
    printf("%s: concreate not enough files in directory listing\n", s);
<<<<<<< HEAD
    4ff0:	85ce                	mv	a1,s3
    4ff2:	00003517          	auipc	a0,0x3
    4ff6:	f0650513          	addi	a0,a0,-250 # 7ef8 <malloc+0x1ef4>
    4ffa:	00001097          	auipc	ra,0x1
    4ffe:	f4c080e7          	jalr	-180(ra) # 5f46 <printf>
=======
    4fdc:	85ce                	mv	a1,s3
    4fde:	00003517          	auipc	a0,0x3
    4fe2:	eca50513          	addi	a0,a0,-310 # 7ea8 <malloc+0x1ef2>
    4fe6:	00001097          	auipc	ra,0x1
    4fea:	f18080e7          	jalr	-232(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    4fee:	4505                	li	a0,1
    4ff0:	00001097          	auipc	ra,0x1
    4ff4:	b9e080e7          	jalr	-1122(ra) # 5b8e <exit>
      printf("%s: fork failed\n", s);
<<<<<<< HEAD
    500c:	85ce                	mv	a1,s3
    500e:	00002517          	auipc	a0,0x2
    5012:	9c250513          	addi	a0,a0,-1598 # 69d0 <malloc+0x9cc>
    5016:	00001097          	auipc	ra,0x1
    501a:	f30080e7          	jalr	-208(ra) # 5f46 <printf>
=======
    4ff8:	85ce                	mv	a1,s3
    4ffa:	00002517          	auipc	a0,0x2
    4ffe:	96650513          	addi	a0,a0,-1690 # 6960 <malloc+0x9aa>
    5002:	00001097          	auipc	ra,0x1
    5006:	efc080e7          	jalr	-260(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    500a:	4505                	li	a0,1
    500c:	00001097          	auipc	ra,0x1
    5010:	b82080e7          	jalr	-1150(ra) # 5b8e <exit>
      close(open(file, 0));
    5014:	4581                	li	a1,0
    5016:	fa840513          	addi	a0,s0,-88
    501a:	00001097          	auipc	ra,0x1
    501e:	bb4080e7          	jalr	-1100(ra) # 5bce <open>
    5022:	00001097          	auipc	ra,0x1
    5026:	b94080e7          	jalr	-1132(ra) # 5bb6 <close>
      close(open(file, 0));
    502a:	4581                	li	a1,0
    502c:	fa840513          	addi	a0,s0,-88
    5030:	00001097          	auipc	ra,0x1
    5034:	b9e080e7          	jalr	-1122(ra) # 5bce <open>
    5038:	00001097          	auipc	ra,0x1
    503c:	b7e080e7          	jalr	-1154(ra) # 5bb6 <close>
      close(open(file, 0));
    5040:	4581                	li	a1,0
    5042:	fa840513          	addi	a0,s0,-88
    5046:	00001097          	auipc	ra,0x1
    504a:	b88080e7          	jalr	-1144(ra) # 5bce <open>
    504e:	00001097          	auipc	ra,0x1
    5052:	b68080e7          	jalr	-1176(ra) # 5bb6 <close>
      close(open(file, 0));
    5056:	4581                	li	a1,0
    5058:	fa840513          	addi	a0,s0,-88
    505c:	00001097          	auipc	ra,0x1
    5060:	b72080e7          	jalr	-1166(ra) # 5bce <open>
    5064:	00001097          	auipc	ra,0x1
    5068:	b52080e7          	jalr	-1198(ra) # 5bb6 <close>
      close(open(file, 0));
    506c:	4581                	li	a1,0
    506e:	fa840513          	addi	a0,s0,-88
    5072:	00001097          	auipc	ra,0x1
    5076:	b5c080e7          	jalr	-1188(ra) # 5bce <open>
    507a:	00001097          	auipc	ra,0x1
    507e:	b3c080e7          	jalr	-1220(ra) # 5bb6 <close>
      close(open(file, 0));
    5082:	4581                	li	a1,0
    5084:	fa840513          	addi	a0,s0,-88
    5088:	00001097          	auipc	ra,0x1
    508c:	b46080e7          	jalr	-1210(ra) # 5bce <open>
    5090:	00001097          	auipc	ra,0x1
    5094:	b26080e7          	jalr	-1242(ra) # 5bb6 <close>
    if(pid == 0)
    5098:	08090363          	beqz	s2,511e <concreate+0x2d2>
      wait(0);
    509c:	4501                	li	a0,0
    509e:	00001097          	auipc	ra,0x1
    50a2:	af8080e7          	jalr	-1288(ra) # 5b96 <wait>
  for(i = 0; i < N; i++){
    50a6:	2485                	addiw	s1,s1,1
    50a8:	0f448563          	beq	s1,s4,5192 <concreate+0x346>
    file[1] = '0' + i;
    50ac:	0304879b          	addiw	a5,s1,48
    50b0:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    50b4:	00001097          	auipc	ra,0x1
    50b8:	ad2080e7          	jalr	-1326(ra) # 5b86 <fork>
    50bc:	892a                	mv	s2,a0
    if(pid < 0){
    50be:	f2054de3          	bltz	a0,4ff8 <concreate+0x1ac>
    if(((i % 3) == 0 && pid == 0) ||
    50c2:	0354e73b          	remw	a4,s1,s5
    50c6:	00a767b3          	or	a5,a4,a0
    50ca:	2781                	sext.w	a5,a5
    50cc:	d7a1                	beqz	a5,5014 <concreate+0x1c8>
    50ce:	01671363          	bne	a4,s6,50d4 <concreate+0x288>
       ((i % 3) == 1 && pid != 0)){
    50d2:	f129                	bnez	a0,5014 <concreate+0x1c8>
      unlink(file);
    50d4:	fa840513          	addi	a0,s0,-88
    50d8:	00001097          	auipc	ra,0x1
    50dc:	b06080e7          	jalr	-1274(ra) # 5bde <unlink>
      unlink(file);
    50e0:	fa840513          	addi	a0,s0,-88
    50e4:	00001097          	auipc	ra,0x1
    50e8:	afa080e7          	jalr	-1286(ra) # 5bde <unlink>
      unlink(file);
    50ec:	fa840513          	addi	a0,s0,-88
    50f0:	00001097          	auipc	ra,0x1
    50f4:	aee080e7          	jalr	-1298(ra) # 5bde <unlink>
      unlink(file);
    50f8:	fa840513          	addi	a0,s0,-88
    50fc:	00001097          	auipc	ra,0x1
    5100:	ae2080e7          	jalr	-1310(ra) # 5bde <unlink>
      unlink(file);
    5104:	fa840513          	addi	a0,s0,-88
    5108:	00001097          	auipc	ra,0x1
    510c:	ad6080e7          	jalr	-1322(ra) # 5bde <unlink>
      unlink(file);
    5110:	fa840513          	addi	a0,s0,-88
    5114:	00001097          	auipc	ra,0x1
    5118:	aca080e7          	jalr	-1334(ra) # 5bde <unlink>
    511c:	bfb5                	j	5098 <concreate+0x24c>
      exit(0);
    511e:	4501                	li	a0,0
    5120:	00001097          	auipc	ra,0x1
    5124:	a6e080e7          	jalr	-1426(ra) # 5b8e <exit>
      close(fd);
    5128:	00001097          	auipc	ra,0x1
    512c:	a8e080e7          	jalr	-1394(ra) # 5bb6 <close>
    if(pid == 0) {
    5130:	bb5d                	j	4ee6 <concreate+0x9a>
      close(fd);
    5132:	00001097          	auipc	ra,0x1
    5136:	a84080e7          	jalr	-1404(ra) # 5bb6 <close>
      wait(&xstatus);
    513a:	f6c40513          	addi	a0,s0,-148
    513e:	00001097          	auipc	ra,0x1
    5142:	a58080e7          	jalr	-1448(ra) # 5b96 <wait>
      if(xstatus != 0)
    5146:	f6c42483          	lw	s1,-148(s0)
    514a:	da0493e3          	bnez	s1,4ef0 <concreate+0xa4>
  for(i = 0; i < N; i++){
    514e:	2905                	addiw	s2,s2,1
    5150:	db4905e3          	beq	s2,s4,4efa <concreate+0xae>
    file[1] = '0' + i;
    5154:	0309079b          	addiw	a5,s2,48
    5158:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    515c:	fa840513          	addi	a0,s0,-88
    5160:	00001097          	auipc	ra,0x1
    5164:	a7e080e7          	jalr	-1410(ra) # 5bde <unlink>
    pid = fork();
    5168:	00001097          	auipc	ra,0x1
    516c:	a1e080e7          	jalr	-1506(ra) # 5b86 <fork>
    if(pid && (i % 3) == 1){
    5170:	d20502e3          	beqz	a0,4e94 <concreate+0x48>
    5174:	036967bb          	remw	a5,s2,s6
    5178:	d15786e3          	beq	a5,s5,4e84 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    517c:	20200593          	li	a1,514
    5180:	fa840513          	addi	a0,s0,-88
    5184:	00001097          	auipc	ra,0x1
    5188:	a4a080e7          	jalr	-1462(ra) # 5bce <open>
      if(fd < 0){
    518c:	fa0553e3          	bgez	a0,5132 <concreate+0x2e6>
    5190:	b315                	j	4eb4 <concreate+0x68>
}
    5192:	60ea                	ld	ra,152(sp)
    5194:	644a                	ld	s0,144(sp)
    5196:	64aa                	ld	s1,136(sp)
    5198:	690a                	ld	s2,128(sp)
    519a:	79e6                	ld	s3,120(sp)
    519c:	7a46                	ld	s4,112(sp)
    519e:	7aa6                	ld	s5,104(sp)
    51a0:	7b06                	ld	s6,96(sp)
    51a2:	6be6                	ld	s7,88(sp)
    51a4:	610d                	addi	sp,sp,160
    51a6:	8082                	ret

00000000000051a8 <bigfile>:
{
    51a8:	7139                	addi	sp,sp,-64
    51aa:	fc06                	sd	ra,56(sp)
    51ac:	f822                	sd	s0,48(sp)
    51ae:	f426                	sd	s1,40(sp)
    51b0:	f04a                	sd	s2,32(sp)
    51b2:	ec4e                	sd	s3,24(sp)
    51b4:	e852                	sd	s4,16(sp)
    51b6:	e456                	sd	s5,8(sp)
    51b8:	0080                	addi	s0,sp,64
    51ba:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
<<<<<<< HEAD
    51d0:	00003517          	auipc	a0,0x3
    51d4:	d6050513          	addi	a0,a0,-672 # 7f30 <malloc+0x1f2c>
    51d8:	00001097          	auipc	ra,0x1
    51dc:	a3e080e7          	jalr	-1474(ra) # 5c16 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    51e0:	20200593          	li	a1,514
    51e4:	00003517          	auipc	a0,0x3
    51e8:	d4c50513          	addi	a0,a0,-692 # 7f30 <malloc+0x1f2c>
    51ec:	00001097          	auipc	ra,0x1
    51f0:	a1a080e7          	jalr	-1510(ra) # 5c06 <open>
    51f4:	89aa                	mv	s3,a0
=======
    51bc:	00003517          	auipc	a0,0x3
    51c0:	d2450513          	addi	a0,a0,-732 # 7ee0 <malloc+0x1f2a>
    51c4:	00001097          	auipc	ra,0x1
    51c8:	a1a080e7          	jalr	-1510(ra) # 5bde <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    51cc:	20200593          	li	a1,514
    51d0:	00003517          	auipc	a0,0x3
    51d4:	d1050513          	addi	a0,a0,-752 # 7ee0 <malloc+0x1f2a>
    51d8:	00001097          	auipc	ra,0x1
    51dc:	9f6080e7          	jalr	-1546(ra) # 5bce <open>
    51e0:	89aa                	mv	s3,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(i = 0; i < N; i++){
    51e2:	4481                	li	s1,0
    memset(buf, i, SZ);
    51e4:	00008917          	auipc	s2,0x8
    51e8:	a9490913          	addi	s2,s2,-1388 # cc78 <buf>
  for(i = 0; i < N; i++){
    51ec:	4a51                	li	s4,20
  if(fd < 0){
    51ee:	0a054063          	bltz	a0,528e <bigfile+0xe6>
    memset(buf, i, SZ);
    51f2:	25800613          	li	a2,600
    51f6:	85a6                	mv	a1,s1
    51f8:	854a                	mv	a0,s2
    51fa:	00000097          	auipc	ra,0x0
    51fe:	79a080e7          	jalr	1946(ra) # 5994 <memset>
    if(write(fd, buf, SZ) != SZ){
    5202:	25800613          	li	a2,600
    5206:	85ca                	mv	a1,s2
    5208:	854e                	mv	a0,s3
    520a:	00001097          	auipc	ra,0x1
    520e:	9a4080e7          	jalr	-1628(ra) # 5bae <write>
    5212:	25800793          	li	a5,600
    5216:	08f51a63          	bne	a0,a5,52aa <bigfile+0x102>
  for(i = 0; i < N; i++){
    521a:	2485                	addiw	s1,s1,1
    521c:	fd449be3          	bne	s1,s4,51f2 <bigfile+0x4a>
  close(fd);
    5220:	854e                	mv	a0,s3
    5222:	00001097          	auipc	ra,0x1
    5226:	994080e7          	jalr	-1644(ra) # 5bb6 <close>
  fd = open("bigfile.dat", 0);
<<<<<<< HEAD
    523e:	4581                	li	a1,0
    5240:	00003517          	auipc	a0,0x3
    5244:	cf050513          	addi	a0,a0,-784 # 7f30 <malloc+0x1f2c>
    5248:	00001097          	auipc	ra,0x1
    524c:	9be080e7          	jalr	-1602(ra) # 5c06 <open>
    5250:	8a2a                	mv	s4,a0
=======
    522a:	4581                	li	a1,0
    522c:	00003517          	auipc	a0,0x3
    5230:	cb450513          	addi	a0,a0,-844 # 7ee0 <malloc+0x1f2a>
    5234:	00001097          	auipc	ra,0x1
    5238:	99a080e7          	jalr	-1638(ra) # 5bce <open>
    523c:	8a2a                	mv	s4,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  total = 0;
    523e:	4981                	li	s3,0
  for(i = 0; ; i++){
    5240:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    5242:	00008917          	auipc	s2,0x8
    5246:	a3690913          	addi	s2,s2,-1482 # cc78 <buf>
  if(fd < 0){
    524a:	06054e63          	bltz	a0,52c6 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    524e:	12c00613          	li	a2,300
    5252:	85ca                	mv	a1,s2
    5254:	8552                	mv	a0,s4
    5256:	00001097          	auipc	ra,0x1
    525a:	950080e7          	jalr	-1712(ra) # 5ba6 <read>
    if(cc < 0){
    525e:	08054263          	bltz	a0,52e2 <bigfile+0x13a>
    if(cc == 0)
    5262:	c971                	beqz	a0,5336 <bigfile+0x18e>
    if(cc != SZ/2){
    5264:	12c00793          	li	a5,300
    5268:	08f51b63          	bne	a0,a5,52fe <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    526c:	01f4d79b          	srliw	a5,s1,0x1f
    5270:	9fa5                	addw	a5,a5,s1
    5272:	4017d79b          	sraiw	a5,a5,0x1
    5276:	00094703          	lbu	a4,0(s2)
    527a:	0af71063          	bne	a4,a5,531a <bigfile+0x172>
    527e:	12b94703          	lbu	a4,299(s2)
    5282:	08f71c63          	bne	a4,a5,531a <bigfile+0x172>
    total += cc;
    5286:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    528a:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    528c:	b7c9                	j	524e <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
<<<<<<< HEAD
    52a2:	85d6                	mv	a1,s5
    52a4:	00003517          	auipc	a0,0x3
    52a8:	c9c50513          	addi	a0,a0,-868 # 7f40 <malloc+0x1f3c>
    52ac:	00001097          	auipc	ra,0x1
    52b0:	c9a080e7          	jalr	-870(ra) # 5f46 <printf>
=======
    528e:	85d6                	mv	a1,s5
    5290:	00003517          	auipc	a0,0x3
    5294:	c6050513          	addi	a0,a0,-928 # 7ef0 <malloc+0x1f3a>
    5298:	00001097          	auipc	ra,0x1
    529c:	c66080e7          	jalr	-922(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    52a0:	4505                	li	a0,1
    52a2:	00001097          	auipc	ra,0x1
    52a6:	8ec080e7          	jalr	-1812(ra) # 5b8e <exit>
      printf("%s: write bigfile failed\n", s);
<<<<<<< HEAD
    52be:	85d6                	mv	a1,s5
    52c0:	00003517          	auipc	a0,0x3
    52c4:	ca050513          	addi	a0,a0,-864 # 7f60 <malloc+0x1f5c>
    52c8:	00001097          	auipc	ra,0x1
    52cc:	c7e080e7          	jalr	-898(ra) # 5f46 <printf>
=======
    52aa:	85d6                	mv	a1,s5
    52ac:	00003517          	auipc	a0,0x3
    52b0:	c6450513          	addi	a0,a0,-924 # 7f10 <malloc+0x1f5a>
    52b4:	00001097          	auipc	ra,0x1
    52b8:	c4a080e7          	jalr	-950(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    52bc:	4505                	li	a0,1
    52be:	00001097          	auipc	ra,0x1
    52c2:	8d0080e7          	jalr	-1840(ra) # 5b8e <exit>
    printf("%s: cannot open bigfile\n", s);
<<<<<<< HEAD
    52da:	85d6                	mv	a1,s5
    52dc:	00003517          	auipc	a0,0x3
    52e0:	ca450513          	addi	a0,a0,-860 # 7f80 <malloc+0x1f7c>
    52e4:	00001097          	auipc	ra,0x1
    52e8:	c62080e7          	jalr	-926(ra) # 5f46 <printf>
=======
    52c6:	85d6                	mv	a1,s5
    52c8:	00003517          	auipc	a0,0x3
    52cc:	c6850513          	addi	a0,a0,-920 # 7f30 <malloc+0x1f7a>
    52d0:	00001097          	auipc	ra,0x1
    52d4:	c2e080e7          	jalr	-978(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    52d8:	4505                	li	a0,1
    52da:	00001097          	auipc	ra,0x1
    52de:	8b4080e7          	jalr	-1868(ra) # 5b8e <exit>
      printf("%s: read bigfile failed\n", s);
<<<<<<< HEAD
    52f6:	85d6                	mv	a1,s5
    52f8:	00003517          	auipc	a0,0x3
    52fc:	ca850513          	addi	a0,a0,-856 # 7fa0 <malloc+0x1f9c>
    5300:	00001097          	auipc	ra,0x1
    5304:	c46080e7          	jalr	-954(ra) # 5f46 <printf>
=======
    52e2:	85d6                	mv	a1,s5
    52e4:	00003517          	auipc	a0,0x3
    52e8:	c6c50513          	addi	a0,a0,-916 # 7f50 <malloc+0x1f9a>
    52ec:	00001097          	auipc	ra,0x1
    52f0:	c12080e7          	jalr	-1006(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    52f4:	4505                	li	a0,1
    52f6:	00001097          	auipc	ra,0x1
    52fa:	898080e7          	jalr	-1896(ra) # 5b8e <exit>
      printf("%s: short read bigfile\n", s);
<<<<<<< HEAD
    5312:	85d6                	mv	a1,s5
    5314:	00003517          	auipc	a0,0x3
    5318:	cac50513          	addi	a0,a0,-852 # 7fc0 <malloc+0x1fbc>
    531c:	00001097          	auipc	ra,0x1
    5320:	c2a080e7          	jalr	-982(ra) # 5f46 <printf>
=======
    52fe:	85d6                	mv	a1,s5
    5300:	00003517          	auipc	a0,0x3
    5304:	c7050513          	addi	a0,a0,-912 # 7f70 <malloc+0x1fba>
    5308:	00001097          	auipc	ra,0x1
    530c:	bf6080e7          	jalr	-1034(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    5310:	4505                	li	a0,1
    5312:	00001097          	auipc	ra,0x1
    5316:	87c080e7          	jalr	-1924(ra) # 5b8e <exit>
      printf("%s: read bigfile wrong data\n", s);
<<<<<<< HEAD
    532e:	85d6                	mv	a1,s5
    5330:	00003517          	auipc	a0,0x3
    5334:	ca850513          	addi	a0,a0,-856 # 7fd8 <malloc+0x1fd4>
    5338:	00001097          	auipc	ra,0x1
    533c:	c0e080e7          	jalr	-1010(ra) # 5f46 <printf>
=======
    531a:	85d6                	mv	a1,s5
    531c:	00003517          	auipc	a0,0x3
    5320:	c6c50513          	addi	a0,a0,-916 # 7f88 <malloc+0x1fd2>
    5324:	00001097          	auipc	ra,0x1
    5328:	bda080e7          	jalr	-1062(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    532c:	4505                	li	a0,1
    532e:	00001097          	auipc	ra,0x1
    5332:	860080e7          	jalr	-1952(ra) # 5b8e <exit>
  close(fd);
    5336:	8552                	mv	a0,s4
    5338:	00001097          	auipc	ra,0x1
    533c:	87e080e7          	jalr	-1922(ra) # 5bb6 <close>
  if(total != N*SZ){
    5340:	678d                	lui	a5,0x3
    5342:	ee078793          	addi	a5,a5,-288 # 2ee0 <sbrklast+0x8e>
    5346:	02f99363          	bne	s3,a5,536c <bigfile+0x1c4>
  unlink("bigfile.dat");
<<<<<<< HEAD
    535e:	00003517          	auipc	a0,0x3
    5362:	bd250513          	addi	a0,a0,-1070 # 7f30 <malloc+0x1f2c>
    5366:	00001097          	auipc	ra,0x1
    536a:	8b0080e7          	jalr	-1872(ra) # 5c16 <unlink>
=======
    534a:	00003517          	auipc	a0,0x3
    534e:	b9650513          	addi	a0,a0,-1130 # 7ee0 <malloc+0x1f2a>
    5352:	00001097          	auipc	ra,0x1
    5356:	88c080e7          	jalr	-1908(ra) # 5bde <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    535a:	70e2                	ld	ra,56(sp)
    535c:	7442                	ld	s0,48(sp)
    535e:	74a2                	ld	s1,40(sp)
    5360:	7902                	ld	s2,32(sp)
    5362:	69e2                	ld	s3,24(sp)
    5364:	6a42                	ld	s4,16(sp)
    5366:	6aa2                	ld	s5,8(sp)
    5368:	6121                	addi	sp,sp,64
    536a:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
<<<<<<< HEAD
    5380:	85d6                	mv	a1,s5
    5382:	00003517          	auipc	a0,0x3
    5386:	c7650513          	addi	a0,a0,-906 # 7ff8 <malloc+0x1ff4>
    538a:	00001097          	auipc	ra,0x1
    538e:	bbc080e7          	jalr	-1092(ra) # 5f46 <printf>
=======
    536c:	85d6                	mv	a1,s5
    536e:	00003517          	auipc	a0,0x3
    5372:	c3a50513          	addi	a0,a0,-966 # 7fa8 <malloc+0x1ff2>
    5376:	00001097          	auipc	ra,0x1
    537a:	b88080e7          	jalr	-1144(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    537e:	4505                	li	a0,1
    5380:	00001097          	auipc	ra,0x1
    5384:	80e080e7          	jalr	-2034(ra) # 5b8e <exit>

0000000000005388 <fsfull>:
{
    5388:	7135                	addi	sp,sp,-160
    538a:	ed06                	sd	ra,152(sp)
    538c:	e922                	sd	s0,144(sp)
    538e:	e526                	sd	s1,136(sp)
    5390:	e14a                	sd	s2,128(sp)
    5392:	fcce                	sd	s3,120(sp)
    5394:	f8d2                	sd	s4,112(sp)
    5396:	f4d6                	sd	s5,104(sp)
    5398:	f0da                	sd	s6,96(sp)
    539a:	ecde                	sd	s7,88(sp)
    539c:	e8e2                	sd	s8,80(sp)
    539e:	e4e6                	sd	s9,72(sp)
    53a0:	e0ea                	sd	s10,64(sp)
    53a2:	1100                	addi	s0,sp,160
  printf("fsfull test\n");
<<<<<<< HEAD
    53ba:	00003517          	auipc	a0,0x3
    53be:	c5e50513          	addi	a0,a0,-930 # 8018 <malloc+0x2014>
    53c2:	00001097          	auipc	ra,0x1
    53c6:	b84080e7          	jalr	-1148(ra) # 5f46 <printf>
=======
    53a4:	00003517          	auipc	a0,0x3
    53a8:	c2450513          	addi	a0,a0,-988 # 7fc8 <malloc+0x2012>
    53ac:	00001097          	auipc	ra,0x1
    53b0:	b52080e7          	jalr	-1198(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  for(nfiles = 0; ; nfiles++){
    53b4:	4481                	li	s1,0
    name[0] = 'f';
    53b6:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    53ba:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    53be:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    53c2:	4b29                	li	s6,10
    printf("writing %s\n", name);
<<<<<<< HEAD
    53da:	00003c97          	auipc	s9,0x3
    53de:	c4ec8c93          	addi	s9,s9,-946 # 8028 <malloc+0x2024>
    int total = 0;
    53e2:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    53e4:	00008a17          	auipc	s4,0x8
    53e8:	894a0a13          	addi	s4,s4,-1900 # cc78 <buf>
=======
    53c4:	00003c97          	auipc	s9,0x3
    53c8:	c14c8c93          	addi	s9,s9,-1004 # 7fd8 <malloc+0x2022>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    name[0] = 'f';
    53cc:	f7a40023          	sb	s10,-160(s0)
    name[1] = '0' + nfiles / 1000;
    53d0:	0384c7bb          	divw	a5,s1,s8
    53d4:	0307879b          	addiw	a5,a5,48
    53d8:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    53dc:	0384e7bb          	remw	a5,s1,s8
    53e0:	0377c7bb          	divw	a5,a5,s7
    53e4:	0307879b          	addiw	a5,a5,48
    53e8:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    53ec:	0374e7bb          	remw	a5,s1,s7
    53f0:	0367c7bb          	divw	a5,a5,s6
    53f4:	0307879b          	addiw	a5,a5,48
    53f8:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    53fc:	0364e7bb          	remw	a5,s1,s6
    5400:	0307879b          	addiw	a5,a5,48
    5404:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    5408:	f60402a3          	sb	zero,-155(s0)
    printf("writing %s\n", name);
<<<<<<< HEAD
    542c:	f5040593          	addi	a1,s0,-176
    5430:	8566                	mv	a0,s9
    5432:	00001097          	auipc	ra,0x1
    5436:	b14080e7          	jalr	-1260(ra) # 5f46 <printf>
=======
    540c:	f6040593          	addi	a1,s0,-160
    5410:	8566                	mv	a0,s9
    5412:	00001097          	auipc	ra,0x1
    5416:	aec080e7          	jalr	-1300(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    int fd = open(name, O_CREATE|O_RDWR);
    541a:	20200593          	li	a1,514
    541e:	f6040513          	addi	a0,s0,-160
    5422:	00000097          	auipc	ra,0x0
    5426:	7ac080e7          	jalr	1964(ra) # 5bce <open>
    542a:	892a                	mv	s2,a0
    if(fd < 0){
    542c:	0a055563          	bgez	a0,54d6 <fsfull+0x14e>
      printf("open %s failed\n", name);
<<<<<<< HEAD
    5450:	f5040593          	addi	a1,s0,-176
    5454:	00003517          	auipc	a0,0x3
    5458:	be450513          	addi	a0,a0,-1052 # 8038 <malloc+0x2034>
    545c:	00001097          	auipc	ra,0x1
    5460:	aea080e7          	jalr	-1302(ra) # 5f46 <printf>
=======
    5430:	f6040593          	addi	a1,s0,-160
    5434:	00003517          	auipc	a0,0x3
    5438:	bb450513          	addi	a0,a0,-1100 # 7fe8 <malloc+0x2032>
    543c:	00001097          	auipc	ra,0x1
    5440:	ac2080e7          	jalr	-1342(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  while(nfiles >= 0){
    5444:	0604c363          	bltz	s1,54aa <fsfull+0x122>
    name[0] = 'f';
    5448:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    544c:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    5450:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    5454:	4929                	li	s2,10
  while(nfiles >= 0){
    5456:	5afd                	li	s5,-1
    name[0] = 'f';
    5458:	f7640023          	sb	s6,-160(s0)
    name[1] = '0' + nfiles / 1000;
    545c:	0344c7bb          	divw	a5,s1,s4
    5460:	0307879b          	addiw	a5,a5,48
    5464:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    5468:	0344e7bb          	remw	a5,s1,s4
    546c:	0337c7bb          	divw	a5,a5,s3
    5470:	0307879b          	addiw	a5,a5,48
    5474:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    5478:	0334e7bb          	remw	a5,s1,s3
    547c:	0327c7bb          	divw	a5,a5,s2
    5480:	0307879b          	addiw	a5,a5,48
    5484:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    5488:	0324e7bb          	remw	a5,s1,s2
    548c:	0307879b          	addiw	a5,a5,48
    5490:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    5494:	f60402a3          	sb	zero,-155(s0)
    unlink(name);
    5498:	f6040513          	addi	a0,s0,-160
    549c:	00000097          	auipc	ra,0x0
    54a0:	742080e7          	jalr	1858(ra) # 5bde <unlink>
    nfiles--;
    54a4:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    54a6:	fb5499e3          	bne	s1,s5,5458 <fsfull+0xd0>
  printf("fsfull test finished\n");
<<<<<<< HEAD
    54ca:	00003517          	auipc	a0,0x3
    54ce:	b8e50513          	addi	a0,a0,-1138 # 8058 <malloc+0x2054>
    54d2:	00001097          	auipc	ra,0x1
    54d6:	a74080e7          	jalr	-1420(ra) # 5f46 <printf>
=======
    54aa:	00003517          	auipc	a0,0x3
    54ae:	b5e50513          	addi	a0,a0,-1186 # 8008 <malloc+0x2052>
    54b2:	00001097          	auipc	ra,0x1
    54b6:	a4c080e7          	jalr	-1460(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}
    54ba:	60ea                	ld	ra,152(sp)
    54bc:	644a                	ld	s0,144(sp)
    54be:	64aa                	ld	s1,136(sp)
    54c0:	690a                	ld	s2,128(sp)
    54c2:	79e6                	ld	s3,120(sp)
    54c4:	7a46                	ld	s4,112(sp)
    54c6:	7aa6                	ld	s5,104(sp)
    54c8:	7b06                	ld	s6,96(sp)
    54ca:	6be6                	ld	s7,88(sp)
    54cc:	6c46                	ld	s8,80(sp)
    54ce:	6ca6                	ld	s9,72(sp)
    54d0:	6d06                	ld	s10,64(sp)
    54d2:	610d                	addi	sp,sp,160
    54d4:	8082                	ret
    int total = 0;
    54d6:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    54d8:	00007a97          	auipc	s5,0x7
    54dc:	7a0a8a93          	addi	s5,s5,1952 # cc78 <buf>
      if(cc < BSIZE)
    54e0:	3ff00a13          	li	s4,1023
      int cc = write(fd, buf, BSIZE);
    54e4:	40000613          	li	a2,1024
    54e8:	85d6                	mv	a1,s5
    54ea:	854a                	mv	a0,s2
    54ec:	00000097          	auipc	ra,0x0
    54f0:	6c2080e7          	jalr	1730(ra) # 5bae <write>
      if(cc < BSIZE)
    54f4:	00aa5563          	bge	s4,a0,54fe <fsfull+0x176>
      total += cc;
    54f8:	00a989bb          	addw	s3,s3,a0
    while(1){
    54fc:	b7e5                	j	54e4 <fsfull+0x15c>
    printf("wrote %d bytes\n", total);
<<<<<<< HEAD
    5518:	85ce                	mv	a1,s3
    551a:	00003517          	auipc	a0,0x3
    551e:	b2e50513          	addi	a0,a0,-1234 # 8048 <malloc+0x2044>
    5522:	00001097          	auipc	ra,0x1
    5526:	a24080e7          	jalr	-1500(ra) # 5f46 <printf>
=======
    54fe:	85ce                	mv	a1,s3
    5500:	00003517          	auipc	a0,0x3
    5504:	af850513          	addi	a0,a0,-1288 # 7ff8 <malloc+0x2042>
    5508:	00001097          	auipc	ra,0x1
    550c:	9f6080e7          	jalr	-1546(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    close(fd);
    5510:	854a                	mv	a0,s2
    5512:	00000097          	auipc	ra,0x0
    5516:	6a4080e7          	jalr	1700(ra) # 5bb6 <close>
    if(total == 0)
    551a:	f20985e3          	beqz	s3,5444 <fsfull+0xbc>
  for(nfiles = 0; ; nfiles++){
    551e:	2485                	addiw	s1,s1,1
    5520:	b575                	j	53cc <fsfull+0x44>

0000000000005522 <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5522:	7179                	addi	sp,sp,-48
    5524:	f406                	sd	ra,40(sp)
    5526:	f022                	sd	s0,32(sp)
    5528:	ec26                	sd	s1,24(sp)
    552a:	e84a                	sd	s2,16(sp)
    552c:	1800                	addi	s0,sp,48
    552e:	84aa                	mv	s1,a0
    5530:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
<<<<<<< HEAD
    554c:	00003517          	auipc	a0,0x3
    5550:	b2450513          	addi	a0,a0,-1244 # 8070 <malloc+0x206c>
    5554:	00001097          	auipc	ra,0x1
    5558:	9f2080e7          	jalr	-1550(ra) # 5f46 <printf>
=======
    5532:	00003517          	auipc	a0,0x3
    5536:	aee50513          	addi	a0,a0,-1298 # 8020 <malloc+0x206a>
    553a:	00001097          	auipc	ra,0x1
    553e:	9c4080e7          	jalr	-1596(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  if((pid = fork()) < 0) {
    5542:	00000097          	auipc	ra,0x0
    5546:	644080e7          	jalr	1604(ra) # 5b86 <fork>
    554a:	02054e63          	bltz	a0,5586 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    554e:	c929                	beqz	a0,55a0 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    5550:	fdc40513          	addi	a0,s0,-36
    5554:	00000097          	auipc	ra,0x0
    5558:	642080e7          	jalr	1602(ra) # 5b96 <wait>
    if(xstatus != 0) 
    555c:	fdc42783          	lw	a5,-36(s0)
    5560:	c7b9                	beqz	a5,55ae <run+0x8c>
      printf("FAILED\n");
<<<<<<< HEAD
    557c:	00003517          	auipc	a0,0x3
    5580:	b1c50513          	addi	a0,a0,-1252 # 8098 <malloc+0x2094>
    5584:	00001097          	auipc	ra,0x1
    5588:	9c2080e7          	jalr	-1598(ra) # 5f46 <printf>
=======
    5562:	00003517          	auipc	a0,0x3
    5566:	ae650513          	addi	a0,a0,-1306 # 8048 <malloc+0x2092>
    556a:	00001097          	auipc	ra,0x1
    556e:	994080e7          	jalr	-1644(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    else
      printf("OK\n");
    return xstatus == 0;
    5572:	fdc42503          	lw	a0,-36(s0)
  }
}
    5576:	00153513          	seqz	a0,a0
    557a:	70a2                	ld	ra,40(sp)
    557c:	7402                	ld	s0,32(sp)
    557e:	64e2                	ld	s1,24(sp)
    5580:	6942                	ld	s2,16(sp)
    5582:	6145                	addi	sp,sp,48
    5584:	8082                	ret
    printf("runtest: fork error\n");
<<<<<<< HEAD
    55a0:	00003517          	auipc	a0,0x3
    55a4:	ae050513          	addi	a0,a0,-1312 # 8080 <malloc+0x207c>
    55a8:	00001097          	auipc	ra,0x1
    55ac:	99e080e7          	jalr	-1634(ra) # 5f46 <printf>
=======
    5586:	00003517          	auipc	a0,0x3
    558a:	aaa50513          	addi	a0,a0,-1366 # 8030 <malloc+0x207a>
    558e:	00001097          	auipc	ra,0x1
    5592:	970080e7          	jalr	-1680(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
    5596:	4505                	li	a0,1
    5598:	00000097          	auipc	ra,0x0
    559c:	5f6080e7          	jalr	1526(ra) # 5b8e <exit>
    f(s);
    55a0:	854a                	mv	a0,s2
    55a2:	9482                	jalr	s1
    exit(0);
    55a4:	4501                	li	a0,0
    55a6:	00000097          	auipc	ra,0x0
    55aa:	5e8080e7          	jalr	1512(ra) # 5b8e <exit>
      printf("OK\n");
<<<<<<< HEAD
    55c8:	00003517          	auipc	a0,0x3
    55cc:	ad850513          	addi	a0,a0,-1320 # 80a0 <malloc+0x209c>
    55d0:	00001097          	auipc	ra,0x1
    55d4:	976080e7          	jalr	-1674(ra) # 5f46 <printf>
    55d8:	bf55                	j	558c <run+0x50>
=======
    55ae:	00003517          	auipc	a0,0x3
    55b2:	aa250513          	addi	a0,a0,-1374 # 8050 <malloc+0x209a>
    55b6:	00001097          	auipc	ra,0x1
    55ba:	948080e7          	jalr	-1720(ra) # 5efe <printf>
    55be:	bf55                	j	5572 <run+0x50>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

00000000000055c0 <runtests>:

int
runtests(struct test *tests, char *justone) {
    55c0:	1101                	addi	sp,sp,-32
    55c2:	ec06                	sd	ra,24(sp)
    55c4:	e822                	sd	s0,16(sp)
    55c6:	e426                	sd	s1,8(sp)
    55c8:	e04a                	sd	s2,0(sp)
    55ca:	1000                	addi	s0,sp,32
    55cc:	84aa                	mv	s1,a0
    55ce:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    55d0:	6508                	ld	a0,8(a0)
    55d2:	ed09                	bnez	a0,55ec <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    55d4:	4501                	li	a0,0
    55d6:	a82d                	j	5610 <runtests+0x50>
      if(!run(t->f, t->s)){
    55d8:	648c                	ld	a1,8(s1)
    55da:	6088                	ld	a0,0(s1)
    55dc:	00000097          	auipc	ra,0x0
    55e0:	f46080e7          	jalr	-186(ra) # 5522 <run>
    55e4:	cd09                	beqz	a0,55fe <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    55e6:	04c1                	addi	s1,s1,16
    55e8:	6488                	ld	a0,8(s1)
    55ea:	c11d                	beqz	a0,5610 <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    55ec:	fe0906e3          	beqz	s2,55d8 <runtests+0x18>
    55f0:	85ca                	mv	a1,s2
    55f2:	00000097          	auipc	ra,0x0
    55f6:	34c080e7          	jalr	844(ra) # 593e <strcmp>
    55fa:	f575                	bnez	a0,55e6 <runtests+0x26>
    55fc:	bff1                	j	55d8 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
<<<<<<< HEAD
    5618:	00003517          	auipc	a0,0x3
    561c:	a9050513          	addi	a0,a0,-1392 # 80a8 <malloc+0x20a4>
    5620:	00001097          	auipc	ra,0x1
    5624:	926080e7          	jalr	-1754(ra) # 5f46 <printf>
=======
    55fe:	00003517          	auipc	a0,0x3
    5602:	a5a50513          	addi	a0,a0,-1446 # 8058 <malloc+0x20a2>
    5606:	00001097          	auipc	ra,0x1
    560a:	8f8080e7          	jalr	-1800(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        return 1;
    560e:	4505                	li	a0,1
}
    5610:	60e2                	ld	ra,24(sp)
    5612:	6442                	ld	s0,16(sp)
    5614:	64a2                	ld	s1,8(sp)
    5616:	6902                	ld	s2,0(sp)
    5618:	6105                	addi	sp,sp,32
    561a:	8082                	ret

000000000000561c <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    561c:	7139                	addi	sp,sp,-64
    561e:	fc06                	sd	ra,56(sp)
    5620:	f822                	sd	s0,48(sp)
    5622:	f426                	sd	s1,40(sp)
    5624:	f04a                	sd	s2,32(sp)
    5626:	ec4e                	sd	s3,24(sp)
    5628:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    562a:	fc840513          	addi	a0,s0,-56
    562e:	00000097          	auipc	ra,0x0
    5632:	570080e7          	jalr	1392(ra) # 5b9e <pipe>
    5636:	06054763          	bltz	a0,56a4 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    563a:	00000097          	auipc	ra,0x0
    563e:	54c080e7          	jalr	1356(ra) # 5b86 <fork>

  if(pid < 0){
    5642:	06054e63          	bltz	a0,56be <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    5646:	ed51                	bnez	a0,56e2 <countfree+0xc6>
    close(fds[0]);
    5648:	fc842503          	lw	a0,-56(s0)
    564c:	00000097          	auipc	ra,0x0
    5650:	56a080e7          	jalr	1386(ra) # 5bb6 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    5654:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5656:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
<<<<<<< HEAD
    5672:	00001997          	auipc	s3,0x1
    5676:	b4698993          	addi	s3,s3,-1210 # 61b8 <malloc+0x1b4>
=======
    5658:	00001997          	auipc	s3,0x1
    565c:	af098993          	addi	s3,s3,-1296 # 6148 <malloc+0x192>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      uint64 a = (uint64) sbrk(4096);
    5660:	6505                	lui	a0,0x1
    5662:	00000097          	auipc	ra,0x0
    5666:	5b4080e7          	jalr	1460(ra) # 5c16 <sbrk>
      if(a == 0xffffffffffffffff){
    566a:	07250763          	beq	a0,s2,56d8 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    566e:	6785                	lui	a5,0x1
    5670:	97aa                	add	a5,a5,a0
    5672:	fe978fa3          	sb	s1,-1(a5) # fff <linktest+0x10b>
      if(write(fds[1], "x", 1) != 1){
    5676:	8626                	mv	a2,s1
    5678:	85ce                	mv	a1,s3
    567a:	fcc42503          	lw	a0,-52(s0)
    567e:	00000097          	auipc	ra,0x0
    5682:	530080e7          	jalr	1328(ra) # 5bae <write>
    5686:	fc950de3          	beq	a0,s1,5660 <countfree+0x44>
        printf("write() failed in countfree()\n");
<<<<<<< HEAD
    56a4:	00003517          	auipc	a0,0x3
    56a8:	a5c50513          	addi	a0,a0,-1444 # 8100 <malloc+0x20fc>
    56ac:	00001097          	auipc	ra,0x1
    56b0:	89a080e7          	jalr	-1894(ra) # 5f46 <printf>
=======
    568a:	00003517          	auipc	a0,0x3
    568e:	a2650513          	addi	a0,a0,-1498 # 80b0 <malloc+0x20fa>
    5692:	00001097          	auipc	ra,0x1
    5696:	86c080e7          	jalr	-1940(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
    569a:	4505                	li	a0,1
    569c:	00000097          	auipc	ra,0x0
    56a0:	4f2080e7          	jalr	1266(ra) # 5b8e <exit>
    printf("pipe() failed in countfree()\n");
    56a4:	00003517          	auipc	a0,0x3
    56a8:	9cc50513          	addi	a0,a0,-1588 # 8070 <malloc+0x20ba>
    56ac:	00001097          	auipc	ra,0x1
    56b0:	852080e7          	jalr	-1966(ra) # 5efe <printf>
    exit(1);
    56b4:	4505                	li	a0,1
    56b6:	00000097          	auipc	ra,0x0
    56ba:	4d8080e7          	jalr	1240(ra) # 5b8e <exit>
    printf("fork failed in countfree()\n");
    56be:	00003517          	auipc	a0,0x3
<<<<<<< HEAD
    56c2:	a0250513          	addi	a0,a0,-1534 # 80c0 <malloc+0x20bc>
    56c6:	00001097          	auipc	ra,0x1
    56ca:	880080e7          	jalr	-1920(ra) # 5f46 <printf>
    exit(1);
    56ce:	4505                	li	a0,1
    56d0:	00000097          	auipc	ra,0x0
    56d4:	4f6080e7          	jalr	1270(ra) # 5bc6 <exit>
    printf("fork failed in countfree()\n");
    56d8:	00003517          	auipc	a0,0x3
    56dc:	a0850513          	addi	a0,a0,-1528 # 80e0 <malloc+0x20dc>
    56e0:	00001097          	auipc	ra,0x1
    56e4:	866080e7          	jalr	-1946(ra) # 5f46 <printf>
    exit(1);
    56e8:	4505                	li	a0,1
    56ea:	00000097          	auipc	ra,0x0
    56ee:	4dc080e7          	jalr	1244(ra) # 5bc6 <exit>
=======
    56c2:	9d250513          	addi	a0,a0,-1582 # 8090 <malloc+0x20da>
    56c6:	00001097          	auipc	ra,0x1
    56ca:	838080e7          	jalr	-1992(ra) # 5efe <printf>
    exit(1);
    56ce:	4505                	li	a0,1
    56d0:	00000097          	auipc	ra,0x0
    56d4:	4be080e7          	jalr	1214(ra) # 5b8e <exit>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      }
    }

    exit(0);
    56d8:	4501                	li	a0,0
    56da:	00000097          	auipc	ra,0x0
    56de:	4b4080e7          	jalr	1204(ra) # 5b8e <exit>
  }

  close(fds[1]);
    56e2:	fcc42503          	lw	a0,-52(s0)
    56e6:	00000097          	auipc	ra,0x0
    56ea:	4d0080e7          	jalr	1232(ra) # 5bb6 <close>

  int n = 0;
    56ee:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    56f0:	4605                	li	a2,1
    56f2:	fc740593          	addi	a1,s0,-57
    56f6:	fc842503          	lw	a0,-56(s0)
    56fa:	00000097          	auipc	ra,0x0
    56fe:	4ac080e7          	jalr	1196(ra) # 5ba6 <read>
    if(cc < 0){
    5702:	00054563          	bltz	a0,570c <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5706:	c105                	beqz	a0,5726 <countfree+0x10a>
      break;
    n += 1;
    5708:	2485                	addiw	s1,s1,1
  while(1){
    570a:	b7dd                	j	56f0 <countfree+0xd4>
      printf("read() failed in countfree()\n");
<<<<<<< HEAD
    5726:	00003517          	auipc	a0,0x3
    572a:	9fa50513          	addi	a0,a0,-1542 # 8120 <malloc+0x211c>
    572e:	00001097          	auipc	ra,0x1
    5732:	818080e7          	jalr	-2024(ra) # 5f46 <printf>
=======
    570c:	00003517          	auipc	a0,0x3
    5710:	9c450513          	addi	a0,a0,-1596 # 80d0 <malloc+0x211a>
    5714:	00000097          	auipc	ra,0x0
    5718:	7ea080e7          	jalr	2026(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
    571c:	4505                	li	a0,1
    571e:	00000097          	auipc	ra,0x0
    5722:	470080e7          	jalr	1136(ra) # 5b8e <exit>
  }

  close(fds[0]);
    5726:	fc842503          	lw	a0,-56(s0)
    572a:	00000097          	auipc	ra,0x0
    572e:	48c080e7          	jalr	1164(ra) # 5bb6 <close>
  wait((int*)0);
    5732:	4501                	li	a0,0
    5734:	00000097          	auipc	ra,0x0
    5738:	462080e7          	jalr	1122(ra) # 5b96 <wait>
  
  return n;
}
    573c:	8526                	mv	a0,s1
    573e:	70e2                	ld	ra,56(sp)
    5740:	7442                	ld	s0,48(sp)
    5742:	74a2                	ld	s1,40(sp)
    5744:	7902                	ld	s2,32(sp)
    5746:	69e2                	ld	s3,24(sp)
    5748:	6121                	addi	sp,sp,64
    574a:	8082                	ret

000000000000574c <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    574c:	711d                	addi	sp,sp,-96
    574e:	ec86                	sd	ra,88(sp)
    5750:	e8a2                	sd	s0,80(sp)
    5752:	e4a6                	sd	s1,72(sp)
    5754:	e0ca                	sd	s2,64(sp)
    5756:	fc4e                	sd	s3,56(sp)
    5758:	f852                	sd	s4,48(sp)
    575a:	f456                	sd	s5,40(sp)
    575c:	f05a                	sd	s6,32(sp)
    575e:	ec5e                	sd	s7,24(sp)
    5760:	e862                	sd	s8,16(sp)
    5762:	e466                	sd	s9,8(sp)
    5764:	e06a                	sd	s10,0(sp)
    5766:	1080                	addi	s0,sp,96
    5768:	8aaa                	mv	s5,a0
    576a:	89ae                	mv	s3,a1
    576c:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
<<<<<<< HEAD
    5788:	00003b97          	auipc	s7,0x3
    578c:	9b8b8b93          	addi	s7,s7,-1608 # 8140 <malloc+0x213c>
=======
    576e:	00003b97          	auipc	s7,0x3
    5772:	982b8b93          	addi	s7,s7,-1662 # 80f0 <malloc+0x213a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    5776:	00004b17          	auipc	s6,0x4
    577a:	89ab0b13          	addi	s6,s6,-1894 # 9010 <quicktests>
      if(continuous != 2) {
    577e:	4a09                	li	s4,2
      }
    }
    if(!quick) {
      if (justone == 0)
        printf("usertests slow tests starting\n");
      if (runtests(slowtests, justone)) {
    5780:	00004c17          	auipc	s8,0x4
    5784:	c60c0c13          	addi	s8,s8,-928 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    5788:	00003d17          	auipc	s10,0x3
    578c:	980d0d13          	addi	s10,s10,-1664 # 8108 <malloc+0x2152>
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
<<<<<<< HEAD
    579a:	00003c97          	auipc	s9,0x3
    579e:	9dec8c93          	addi	s9,s9,-1570 # 8178 <malloc+0x2174>
      if (runtests(slowtests, justone)) {
    57a2:	00004c17          	auipc	s8,0x4
    57a6:	c3ec0c13          	addi	s8,s8,-962 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    57aa:	00003d17          	auipc	s10,0x3
    57ae:	9aed0d13          	addi	s10,s10,-1618 # 8158 <malloc+0x2154>
    57b2:	a839                	j	57d0 <drivetests+0x6a>
    57b4:	856a                	mv	a0,s10
    57b6:	00000097          	auipc	ra,0x0
    57ba:	790080e7          	jalr	1936(ra) # 5f46 <printf>
    57be:	a081                	j	57fe <drivetests+0x98>
=======
    5790:	00003c97          	auipc	s9,0x3
    5794:	998c8c93          	addi	s9,s9,-1640 # 8128 <malloc+0x2172>
    5798:	a839                	j	57b6 <drivetests+0x6a>
        printf("usertests slow tests starting\n");
    579a:	856a                	mv	a0,s10
    579c:	00000097          	auipc	ra,0x0
    57a0:	762080e7          	jalr	1890(ra) # 5efe <printf>
    57a4:	a081                	j	57e4 <drivetests+0x98>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if((free1 = countfree()) < free0) {
    57a6:	00000097          	auipc	ra,0x0
    57aa:	e76080e7          	jalr	-394(ra) # 561c <countfree>
    57ae:	04954663          	blt	a0,s1,57fa <drivetests+0xae>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    57b2:	06098163          	beqz	s3,5814 <drivetests+0xc8>
    printf("usertests starting\n");
<<<<<<< HEAD
    57d0:	855e                	mv	a0,s7
    57d2:	00000097          	auipc	ra,0x0
    57d6:	774080e7          	jalr	1908(ra) # 5f46 <printf>
=======
    57b6:	855e                	mv	a0,s7
    57b8:	00000097          	auipc	ra,0x0
    57bc:	746080e7          	jalr	1862(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    int free0 = countfree();
    57c0:	00000097          	auipc	ra,0x0
    57c4:	e5c080e7          	jalr	-420(ra) # 561c <countfree>
    57c8:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    57ca:	85ca                	mv	a1,s2
    57cc:	855a                	mv	a0,s6
    57ce:	00000097          	auipc	ra,0x0
    57d2:	df2080e7          	jalr	-526(ra) # 55c0 <runtests>
    57d6:	c119                	beqz	a0,57dc <drivetests+0x90>
      if(continuous != 2) {
    57d8:	03499c63          	bne	s3,s4,5810 <drivetests+0xc4>
    if(!quick) {
    57dc:	fc0a95e3          	bnez	s5,57a6 <drivetests+0x5a>
      if (justone == 0)
    57e0:	fa090de3          	beqz	s2,579a <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    57e4:	85ca                	mv	a1,s2
    57e6:	8562                	mv	a0,s8
    57e8:	00000097          	auipc	ra,0x0
    57ec:	dd8080e7          	jalr	-552(ra) # 55c0 <runtests>
    57f0:	d95d                	beqz	a0,57a6 <drivetests+0x5a>
        if(continuous != 2) {
<<<<<<< HEAD
    580c:	03599d63          	bne	s3,s5,5846 <drivetests+0xe0>
    if((free1 = countfree()) < free0) {
    5810:	00000097          	auipc	ra,0x0
    5814:	e26080e7          	jalr	-474(ra) # 5636 <countfree>
    5818:	fa955ae3          	bge	a0,s1,57cc <drivetests+0x66>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    581c:	8626                	mv	a2,s1
    581e:	85aa                	mv	a1,a0
    5820:	8566                	mv	a0,s9
    5822:	00000097          	auipc	ra,0x0
    5826:	724080e7          	jalr	1828(ra) # 5f46 <printf>
      if(continuous != 2) {
    582a:	b75d                	j	57d0 <drivetests+0x6a>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    582c:	8626                	mv	a2,s1
    582e:	85aa                	mv	a1,a0
    5830:	8566                	mv	a0,s9
    5832:	00000097          	auipc	ra,0x0
    5836:	714080e7          	jalr	1812(ra) # 5f46 <printf>
      if(continuous != 2) {
    583a:	f9598be3          	beq	s3,s5,57d0 <drivetests+0x6a>
        return 1;
    583e:	4505                	li	a0,1
    5840:	a031                	j	584c <drivetests+0xe6>
        return 1;
    5842:	4505                	li	a0,1
    5844:	a021                	j	584c <drivetests+0xe6>
=======
    57f2:	fb498ae3          	beq	s3,s4,57a6 <drivetests+0x5a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
          return 1;
    57f6:	4505                	li	a0,1
    57f8:	a839                	j	5816 <drivetests+0xca>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    57fa:	8626                	mv	a2,s1
    57fc:	85aa                	mv	a1,a0
    57fe:	8566                	mv	a0,s9
    5800:	00000097          	auipc	ra,0x0
    5804:	6fe080e7          	jalr	1790(ra) # 5efe <printf>
      if(continuous != 2) {
    5808:	fb4987e3          	beq	s3,s4,57b6 <drivetests+0x6a>
        return 1;
    580c:	4505                	li	a0,1
    580e:	a021                	j	5816 <drivetests+0xca>
        return 1;
    5810:	4505                	li	a0,1
    5812:	a011                	j	5816 <drivetests+0xca>
  return 0;
    5814:	854e                	mv	a0,s3
}
    5816:	60e6                	ld	ra,88(sp)
    5818:	6446                	ld	s0,80(sp)
    581a:	64a6                	ld	s1,72(sp)
    581c:	6906                	ld	s2,64(sp)
    581e:	79e2                	ld	s3,56(sp)
    5820:	7a42                	ld	s4,48(sp)
    5822:	7aa2                	ld	s5,40(sp)
    5824:	7b02                	ld	s6,32(sp)
    5826:	6be2                	ld	s7,24(sp)
    5828:	6c42                	ld	s8,16(sp)
    582a:	6ca2                	ld	s9,8(sp)
    582c:	6d02                	ld	s10,0(sp)
    582e:	6125                	addi	sp,sp,96
    5830:	8082                	ret

0000000000005832 <main>:

int
main(int argc, char *argv[])
{
    5832:	1101                	addi	sp,sp,-32
    5834:	ec06                	sd	ra,24(sp)
    5836:	e822                	sd	s0,16(sp)
    5838:	e426                	sd	s1,8(sp)
    583a:	e04a                	sd	s2,0(sp)
    583c:	1000                	addi	s0,sp,32
    583e:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    5840:	4789                	li	a5,2
    5842:	02f50263          	beq	a0,a5,5866 <main+0x34>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5846:	4785                	li	a5,1
    5848:	08a7c063          	blt	a5,a0,58c8 <main+0x96>
  char *justone = 0;
    584c:	4601                	li	a2,0
  int quick = 0;
    584e:	4501                	li	a0,0
  int continuous = 0;
    5850:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    5852:	00000097          	auipc	ra,0x0
    5856:	efa080e7          	jalr	-262(ra) # 574c <drivetests>
    585a:	c951                	beqz	a0,58ee <main+0xbc>
    exit(1);
    585c:	4505                	li	a0,1
    585e:	00000097          	auipc	ra,0x0
    5862:	330080e7          	jalr	816(ra) # 5b8e <exit>
    5866:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
<<<<<<< HEAD
    58a0:	00003597          	auipc	a1,0x3
    58a4:	90858593          	addi	a1,a1,-1784 # 81a8 <malloc+0x21a4>
    58a8:	00893503          	ld	a0,8(s2)
    58ac:	00000097          	auipc	ra,0x0
    58b0:	0c8080e7          	jalr	200(ra) # 5974 <strcmp>
    58b4:	cd39                	beqz	a0,5912 <main+0xaa>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    58b6:	00003597          	auipc	a1,0x3
    58ba:	94a58593          	addi	a1,a1,-1718 # 8200 <malloc+0x21fc>
    58be:	00893503          	ld	a0,8(s2)
    58c2:	00000097          	auipc	ra,0x0
    58c6:	0b2080e7          	jalr	178(ra) # 5974 <strcmp>
    58ca:	c931                	beqz	a0,591e <main+0xb6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    58cc:	00003597          	auipc	a1,0x3
    58d0:	92c58593          	addi	a1,a1,-1748 # 81f8 <malloc+0x21f4>
    58d4:	00893503          	ld	a0,8(s2)
    58d8:	00000097          	auipc	ra,0x0
    58dc:	09c080e7          	jalr	156(ra) # 5974 <strcmp>
    58e0:	cd0d                	beqz	a0,591a <main+0xb2>
  } else if(argc == 2 && argv[1][0] != '-'){
    58e2:	00893603          	ld	a2,8(s2)
    58e6:	00064703          	lbu	a4,0(a2) # 3000 <execout+0xa0>
    58ea:	02d00793          	li	a5,45
    58ee:	00f70563          	beq	a4,a5,58f8 <main+0x90>
  int quick = 0;
    58f2:	4501                	li	a0,0
  int continuous = 0;
    58f4:	4481                	li	s1,0
    58f6:	bf49                	j	5888 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    58f8:	00003517          	auipc	a0,0x3
    58fc:	8b850513          	addi	a0,a0,-1864 # 81b0 <malloc+0x21ac>
    5900:	00000097          	auipc	ra,0x0
    5904:	646080e7          	jalr	1606(ra) # 5f46 <printf>
    exit(1);
    5908:	4505                	li	a0,1
    590a:	00000097          	auipc	ra,0x0
    590e:	2bc080e7          	jalr	700(ra) # 5bc6 <exit>
  int continuous = 0;
    5912:	84aa                	mv	s1,a0
=======
    5868:	00003597          	auipc	a1,0x3
    586c:	8f058593          	addi	a1,a1,-1808 # 8158 <malloc+0x21a2>
    5870:	00893503          	ld	a0,8(s2)
    5874:	00000097          	auipc	ra,0x0
    5878:	0ca080e7          	jalr	202(ra) # 593e <strcmp>
    587c:	85aa                	mv	a1,a0
    587e:	e501                	bnez	a0,5886 <main+0x54>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  char *justone = 0;
    5880:	4601                	li	a2,0
    quick = 1;
    5882:	4505                	li	a0,1
    5884:	b7f9                	j	5852 <main+0x20>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5886:	00003597          	auipc	a1,0x3
    588a:	8da58593          	addi	a1,a1,-1830 # 8160 <malloc+0x21aa>
    588e:	00893503          	ld	a0,8(s2)
    5892:	00000097          	auipc	ra,0x0
    5896:	0ac080e7          	jalr	172(ra) # 593e <strcmp>
    589a:	c521                	beqz	a0,58e2 <main+0xb0>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    589c:	00003597          	auipc	a1,0x3
    58a0:	91458593          	addi	a1,a1,-1772 # 81b0 <malloc+0x21fa>
    58a4:	00893503          	ld	a0,8(s2)
    58a8:	00000097          	auipc	ra,0x0
    58ac:	096080e7          	jalr	150(ra) # 593e <strcmp>
    58b0:	cd05                	beqz	a0,58e8 <main+0xb6>
  } else if(argc == 2 && argv[1][0] != '-'){
    58b2:	00893603          	ld	a2,8(s2)
    58b6:	00064703          	lbu	a4,0(a2) # 3000 <execout+0xa6>
    58ba:	02d00793          	li	a5,45
    58be:	00f70563          	beq	a4,a5,58c8 <main+0x96>
  int quick = 0;
    58c2:	4501                	li	a0,0
  int continuous = 0;
    58c4:	4581                	li	a1,0
    58c6:	b771                	j	5852 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    58c8:	00003517          	auipc	a0,0x3
    58cc:	8a050513          	addi	a0,a0,-1888 # 8168 <malloc+0x21b2>
    58d0:	00000097          	auipc	ra,0x0
    58d4:	62e080e7          	jalr	1582(ra) # 5efe <printf>
    exit(1);
    58d8:	4505                	li	a0,1
    58da:	00000097          	auipc	ra,0x0
    58de:	2b4080e7          	jalr	692(ra) # 5b8e <exit>
  char *justone = 0;
    58e2:	4601                	li	a2,0
    continuous = 1;
    58e4:	4585                	li	a1,1
    58e6:	b7b5                	j	5852 <main+0x20>
    continuous = 2;
    58e8:	85a6                	mv	a1,s1
  char *justone = 0;
    58ea:	4601                	li	a2,0
    58ec:	b79d                	j	5852 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
<<<<<<< HEAD
    5924:	00003517          	auipc	a0,0x3
    5928:	8bc50513          	addi	a0,a0,-1860 # 81e0 <malloc+0x21dc>
    592c:	00000097          	auipc	ra,0x0
    5930:	61a080e7          	jalr	1562(ra) # 5f46 <printf>
=======
    58ee:	00003517          	auipc	a0,0x3
    58f2:	8aa50513          	addi	a0,a0,-1878 # 8198 <malloc+0x21e2>
    58f6:	00000097          	auipc	ra,0x0
    58fa:	608080e7          	jalr	1544(ra) # 5efe <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  exit(0);
    58fe:	4501                	li	a0,0
    5900:	00000097          	auipc	ra,0x0
    5904:	28e080e7          	jalr	654(ra) # 5b8e <exit>

0000000000005908 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    5908:	1141                	addi	sp,sp,-16
    590a:	e406                	sd	ra,8(sp)
    590c:	e022                	sd	s0,0(sp)
    590e:	0800                	addi	s0,sp,16
  extern int main();
  main();
    5910:	00000097          	auipc	ra,0x0
    5914:	f22080e7          	jalr	-222(ra) # 5832 <main>
  exit(0);
    5918:	4501                	li	a0,0
    591a:	00000097          	auipc	ra,0x0
    591e:	274080e7          	jalr	628(ra) # 5b8e <exit>

0000000000005922 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    5922:	1141                	addi	sp,sp,-16
    5924:	e422                	sd	s0,8(sp)
    5926:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5928:	87aa                	mv	a5,a0
    592a:	0585                	addi	a1,a1,1
    592c:	0785                	addi	a5,a5,1
    592e:	fff5c703          	lbu	a4,-1(a1)
    5932:	fee78fa3          	sb	a4,-1(a5)
    5936:	fb75                	bnez	a4,592a <strcpy+0x8>
    ;
  return os;
}
    5938:	6422                	ld	s0,8(sp)
    593a:	0141                	addi	sp,sp,16
    593c:	8082                	ret

000000000000593e <strcmp>:

int
strcmp(const char *p, const char *q)
{
    593e:	1141                	addi	sp,sp,-16
    5940:	e422                	sd	s0,8(sp)
    5942:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5944:	00054783          	lbu	a5,0(a0)
    5948:	cb91                	beqz	a5,595c <strcmp+0x1e>
    594a:	0005c703          	lbu	a4,0(a1)
    594e:	00f71763          	bne	a4,a5,595c <strcmp+0x1e>
    p++, q++;
    5952:	0505                	addi	a0,a0,1
    5954:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5956:	00054783          	lbu	a5,0(a0)
    595a:	fbe5                	bnez	a5,594a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    595c:	0005c503          	lbu	a0,0(a1)
}
    5960:	40a7853b          	subw	a0,a5,a0
    5964:	6422                	ld	s0,8(sp)
    5966:	0141                	addi	sp,sp,16
    5968:	8082                	ret

000000000000596a <strlen>:

uint
strlen(const char *s)
{
    596a:	1141                	addi	sp,sp,-16
    596c:	e422                	sd	s0,8(sp)
    596e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5970:	00054783          	lbu	a5,0(a0)
    5974:	cf91                	beqz	a5,5990 <strlen+0x26>
    5976:	0505                	addi	a0,a0,1
    5978:	87aa                	mv	a5,a0
    597a:	86be                	mv	a3,a5
    597c:	0785                	addi	a5,a5,1
    597e:	fff7c703          	lbu	a4,-1(a5)
    5982:	ff65                	bnez	a4,597a <strlen+0x10>
    5984:	40a6853b          	subw	a0,a3,a0
    5988:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    598a:	6422                	ld	s0,8(sp)
    598c:	0141                	addi	sp,sp,16
    598e:	8082                	ret
  for(n = 0; s[n]; n++)
    5990:	4501                	li	a0,0
    5992:	bfe5                	j	598a <strlen+0x20>

0000000000005994 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5994:	1141                	addi	sp,sp,-16
    5996:	e422                	sd	s0,8(sp)
    5998:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    599a:	ca19                	beqz	a2,59b0 <memset+0x1c>
    599c:	87aa                	mv	a5,a0
    599e:	1602                	slli	a2,a2,0x20
    59a0:	9201                	srli	a2,a2,0x20
    59a2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    59a6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    59aa:	0785                	addi	a5,a5,1
    59ac:	fee79de3          	bne	a5,a4,59a6 <memset+0x12>
  }
  return dst;
}
    59b0:	6422                	ld	s0,8(sp)
    59b2:	0141                	addi	sp,sp,16
    59b4:	8082                	ret

00000000000059b6 <strchr>:

char*
strchr(const char *s, char c)
{
    59b6:	1141                	addi	sp,sp,-16
    59b8:	e422                	sd	s0,8(sp)
    59ba:	0800                	addi	s0,sp,16
  for(; *s; s++)
    59bc:	00054783          	lbu	a5,0(a0)
    59c0:	cb99                	beqz	a5,59d6 <strchr+0x20>
    if(*s == c)
    59c2:	00f58763          	beq	a1,a5,59d0 <strchr+0x1a>
  for(; *s; s++)
    59c6:	0505                	addi	a0,a0,1
    59c8:	00054783          	lbu	a5,0(a0)
    59cc:	fbfd                	bnez	a5,59c2 <strchr+0xc>
      return (char*)s;
  return 0;
    59ce:	4501                	li	a0,0
}
    59d0:	6422                	ld	s0,8(sp)
    59d2:	0141                	addi	sp,sp,16
    59d4:	8082                	ret
  return 0;
    59d6:	4501                	li	a0,0
    59d8:	bfe5                	j	59d0 <strchr+0x1a>

00000000000059da <gets>:

char*
gets(char *buf, int max)
{
    59da:	711d                	addi	sp,sp,-96
    59dc:	ec86                	sd	ra,88(sp)
    59de:	e8a2                	sd	s0,80(sp)
    59e0:	e4a6                	sd	s1,72(sp)
    59e2:	e0ca                	sd	s2,64(sp)
    59e4:	fc4e                	sd	s3,56(sp)
    59e6:	f852                	sd	s4,48(sp)
    59e8:	f456                	sd	s5,40(sp)
    59ea:	f05a                	sd	s6,32(sp)
    59ec:	ec5e                	sd	s7,24(sp)
    59ee:	1080                	addi	s0,sp,96
    59f0:	8baa                	mv	s7,a0
    59f2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    59f4:	892a                	mv	s2,a0
    59f6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    59f8:	4aa9                	li	s5,10
    59fa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    59fc:	89a6                	mv	s3,s1
    59fe:	2485                	addiw	s1,s1,1
    5a00:	0344d863          	bge	s1,s4,5a30 <gets+0x56>
    cc = read(0, &c, 1);
    5a04:	4605                	li	a2,1
    5a06:	faf40593          	addi	a1,s0,-81
    5a0a:	4501                	li	a0,0
    5a0c:	00000097          	auipc	ra,0x0
    5a10:	19a080e7          	jalr	410(ra) # 5ba6 <read>
    if(cc < 1)
    5a14:	00a05e63          	blez	a0,5a30 <gets+0x56>
    buf[i++] = c;
    5a18:	faf44783          	lbu	a5,-81(s0)
    5a1c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5a20:	01578763          	beq	a5,s5,5a2e <gets+0x54>
    5a24:	0905                	addi	s2,s2,1
    5a26:	fd679be3          	bne	a5,s6,59fc <gets+0x22>
  for(i=0; i+1 < max; ){
    5a2a:	89a6                	mv	s3,s1
    5a2c:	a011                	j	5a30 <gets+0x56>
    5a2e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5a30:	99de                	add	s3,s3,s7
    5a32:	00098023          	sb	zero,0(s3)
  return buf;
}
    5a36:	855e                	mv	a0,s7
    5a38:	60e6                	ld	ra,88(sp)
    5a3a:	6446                	ld	s0,80(sp)
    5a3c:	64a6                	ld	s1,72(sp)
    5a3e:	6906                	ld	s2,64(sp)
    5a40:	79e2                	ld	s3,56(sp)
    5a42:	7a42                	ld	s4,48(sp)
    5a44:	7aa2                	ld	s5,40(sp)
    5a46:	7b02                	ld	s6,32(sp)
    5a48:	6be2                	ld	s7,24(sp)
    5a4a:	6125                	addi	sp,sp,96
    5a4c:	8082                	ret

0000000000005a4e <stat>:

int
stat(const char *n, struct stat *st)
{
    5a4e:	1101                	addi	sp,sp,-32
    5a50:	ec06                	sd	ra,24(sp)
    5a52:	e822                	sd	s0,16(sp)
    5a54:	e426                	sd	s1,8(sp)
    5a56:	e04a                	sd	s2,0(sp)
    5a58:	1000                	addi	s0,sp,32
    5a5a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5a5c:	4581                	li	a1,0
    5a5e:	00000097          	auipc	ra,0x0
    5a62:	170080e7          	jalr	368(ra) # 5bce <open>
  if(fd < 0)
    5a66:	02054563          	bltz	a0,5a90 <stat+0x42>
    5a6a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5a6c:	85ca                	mv	a1,s2
    5a6e:	00000097          	auipc	ra,0x0
    5a72:	178080e7          	jalr	376(ra) # 5be6 <fstat>
    5a76:	892a                	mv	s2,a0
  close(fd);
    5a78:	8526                	mv	a0,s1
    5a7a:	00000097          	auipc	ra,0x0
    5a7e:	13c080e7          	jalr	316(ra) # 5bb6 <close>
  return r;
}
    5a82:	854a                	mv	a0,s2
    5a84:	60e2                	ld	ra,24(sp)
    5a86:	6442                	ld	s0,16(sp)
    5a88:	64a2                	ld	s1,8(sp)
    5a8a:	6902                	ld	s2,0(sp)
    5a8c:	6105                	addi	sp,sp,32
    5a8e:	8082                	ret
    return -1;
    5a90:	597d                	li	s2,-1
    5a92:	bfc5                	j	5a82 <stat+0x34>

0000000000005a94 <atoi>:

int
atoi(const char *s)
{
    5a94:	1141                	addi	sp,sp,-16
    5a96:	e422                	sd	s0,8(sp)
    5a98:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5a9a:	00054683          	lbu	a3,0(a0)
    5a9e:	fd06879b          	addiw	a5,a3,-48
    5aa2:	0ff7f793          	zext.b	a5,a5
    5aa6:	4625                	li	a2,9
    5aa8:	02f66863          	bltu	a2,a5,5ad8 <atoi+0x44>
    5aac:	872a                	mv	a4,a0
  n = 0;
    5aae:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    5ab0:	0705                	addi	a4,a4,1
    5ab2:	0025179b          	slliw	a5,a0,0x2
    5ab6:	9fa9                	addw	a5,a5,a0
    5ab8:	0017979b          	slliw	a5,a5,0x1
    5abc:	9fb5                	addw	a5,a5,a3
    5abe:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5ac2:	00074683          	lbu	a3,0(a4)
    5ac6:	fd06879b          	addiw	a5,a3,-48
    5aca:	0ff7f793          	zext.b	a5,a5
    5ace:	fef671e3          	bgeu	a2,a5,5ab0 <atoi+0x1c>
  return n;
}
    5ad2:	6422                	ld	s0,8(sp)
    5ad4:	0141                	addi	sp,sp,16
    5ad6:	8082                	ret
  n = 0;
    5ad8:	4501                	li	a0,0
    5ada:	bfe5                	j	5ad2 <atoi+0x3e>

0000000000005adc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5adc:	1141                	addi	sp,sp,-16
    5ade:	e422                	sd	s0,8(sp)
    5ae0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5ae2:	02b57463          	bgeu	a0,a1,5b0a <memmove+0x2e>
    while(n-- > 0)
    5ae6:	00c05f63          	blez	a2,5b04 <memmove+0x28>
    5aea:	1602                	slli	a2,a2,0x20
    5aec:	9201                	srli	a2,a2,0x20
    5aee:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5af2:	872a                	mv	a4,a0
      *dst++ = *src++;
    5af4:	0585                	addi	a1,a1,1
    5af6:	0705                	addi	a4,a4,1
    5af8:	fff5c683          	lbu	a3,-1(a1)
    5afc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5b00:	fee79ae3          	bne	a5,a4,5af4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5b04:	6422                	ld	s0,8(sp)
    5b06:	0141                	addi	sp,sp,16
    5b08:	8082                	ret
    dst += n;
    5b0a:	00c50733          	add	a4,a0,a2
    src += n;
    5b0e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5b10:	fec05ae3          	blez	a2,5b04 <memmove+0x28>
    5b14:	fff6079b          	addiw	a5,a2,-1
    5b18:	1782                	slli	a5,a5,0x20
    5b1a:	9381                	srli	a5,a5,0x20
    5b1c:	fff7c793          	not	a5,a5
    5b20:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5b22:	15fd                	addi	a1,a1,-1
    5b24:	177d                	addi	a4,a4,-1
    5b26:	0005c683          	lbu	a3,0(a1)
    5b2a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5b2e:	fee79ae3          	bne	a5,a4,5b22 <memmove+0x46>
    5b32:	bfc9                	j	5b04 <memmove+0x28>

0000000000005b34 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5b34:	1141                	addi	sp,sp,-16
    5b36:	e422                	sd	s0,8(sp)
    5b38:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5b3a:	ca05                	beqz	a2,5b6a <memcmp+0x36>
    5b3c:	fff6069b          	addiw	a3,a2,-1
    5b40:	1682                	slli	a3,a3,0x20
    5b42:	9281                	srli	a3,a3,0x20
    5b44:	0685                	addi	a3,a3,1
    5b46:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5b48:	00054783          	lbu	a5,0(a0)
    5b4c:	0005c703          	lbu	a4,0(a1)
    5b50:	00e79863          	bne	a5,a4,5b60 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5b54:	0505                	addi	a0,a0,1
    p2++;
    5b56:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5b58:	fed518e3          	bne	a0,a3,5b48 <memcmp+0x14>
  }
  return 0;
    5b5c:	4501                	li	a0,0
    5b5e:	a019                	j	5b64 <memcmp+0x30>
      return *p1 - *p2;
    5b60:	40e7853b          	subw	a0,a5,a4
}
    5b64:	6422                	ld	s0,8(sp)
    5b66:	0141                	addi	sp,sp,16
    5b68:	8082                	ret
  return 0;
    5b6a:	4501                	li	a0,0
    5b6c:	bfe5                	j	5b64 <memcmp+0x30>

0000000000005b6e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5b6e:	1141                	addi	sp,sp,-16
    5b70:	e406                	sd	ra,8(sp)
    5b72:	e022                	sd	s0,0(sp)
    5b74:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5b76:	00000097          	auipc	ra,0x0
    5b7a:	f66080e7          	jalr	-154(ra) # 5adc <memmove>
}
    5b7e:	60a2                	ld	ra,8(sp)
    5b80:	6402                	ld	s0,0(sp)
    5b82:	0141                	addi	sp,sp,16
    5b84:	8082                	ret

0000000000005b86 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5b86:	4885                	li	a7,1
 ecall
    5b88:	00000073          	ecall
 ret
    5b8c:	8082                	ret

0000000000005b8e <exit>:
.global exit
exit:
 li a7, SYS_exit
    5b8e:	4889                	li	a7,2
 ecall
    5b90:	00000073          	ecall
 ret
    5b94:	8082                	ret

0000000000005b96 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5b96:	488d                	li	a7,3
 ecall
    5b98:	00000073          	ecall
 ret
    5b9c:	8082                	ret

0000000000005b9e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5b9e:	4891                	li	a7,4
 ecall
    5ba0:	00000073          	ecall
 ret
    5ba4:	8082                	ret

0000000000005ba6 <read>:
.global read
read:
 li a7, SYS_read
    5ba6:	4895                	li	a7,5
 ecall
    5ba8:	00000073          	ecall
 ret
    5bac:	8082                	ret

0000000000005bae <write>:
.global write
write:
 li a7, SYS_write
    5bae:	48c1                	li	a7,16
 ecall
    5bb0:	00000073          	ecall
 ret
    5bb4:	8082                	ret

0000000000005bb6 <close>:
.global close
close:
 li a7, SYS_close
    5bb6:	48d5                	li	a7,21
 ecall
    5bb8:	00000073          	ecall
 ret
    5bbc:	8082                	ret

0000000000005bbe <kill>:
.global kill
kill:
 li a7, SYS_kill
    5bbe:	4899                	li	a7,6
 ecall
    5bc0:	00000073          	ecall
 ret
    5bc4:	8082                	ret

0000000000005bc6 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5bc6:	489d                	li	a7,7
 ecall
    5bc8:	00000073          	ecall
 ret
    5bcc:	8082                	ret

0000000000005bce <open>:
.global open
open:
 li a7, SYS_open
    5bce:	48bd                	li	a7,15
 ecall
    5bd0:	00000073          	ecall
 ret
    5bd4:	8082                	ret

0000000000005bd6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5bd6:	48c5                	li	a7,17
 ecall
    5bd8:	00000073          	ecall
 ret
    5bdc:	8082                	ret

0000000000005bde <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5bde:	48c9                	li	a7,18
 ecall
    5be0:	00000073          	ecall
 ret
    5be4:	8082                	ret

0000000000005be6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5be6:	48a1                	li	a7,8
 ecall
    5be8:	00000073          	ecall
 ret
    5bec:	8082                	ret

0000000000005bee <link>:
.global link
link:
 li a7, SYS_link
    5bee:	48cd                	li	a7,19
 ecall
    5bf0:	00000073          	ecall
 ret
    5bf4:	8082                	ret

0000000000005bf6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5bf6:	48d1                	li	a7,20
 ecall
    5bf8:	00000073          	ecall
 ret
    5bfc:	8082                	ret

0000000000005bfe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5bfe:	48a5                	li	a7,9
 ecall
    5c00:	00000073          	ecall
 ret
    5c04:	8082                	ret

0000000000005c06 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5c06:	48a9                	li	a7,10
 ecall
    5c08:	00000073          	ecall
 ret
    5c0c:	8082                	ret

0000000000005c0e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5c0e:	48ad                	li	a7,11
 ecall
    5c10:	00000073          	ecall
 ret
    5c14:	8082                	ret

0000000000005c16 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5c16:	48b1                	li	a7,12
 ecall
    5c18:	00000073          	ecall
 ret
    5c1c:	8082                	ret

0000000000005c1e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5c1e:	48b5                	li	a7,13
 ecall
    5c20:	00000073          	ecall
 ret
    5c24:	8082                	ret

0000000000005c26 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5c26:	48b9                	li	a7,14
 ecall
    5c28:	00000073          	ecall
 ret
    5c2c:	8082                	ret

0000000000005c2e <trace>:
.global trace
trace:
 li a7, SYS_trace
    5c2e:	48d9                	li	a7,22
 ecall
    5c30:	00000073          	ecall
 ret
    5c34:	8082                	ret

<<<<<<< HEAD
0000000000005c36 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5c36:	48a5                	li	a7,9
 ecall
    5c38:	00000073          	ecall
 ret
    5c3c:	8082                	ret

0000000000005c3e <dup>:
.global dup
dup:
 li a7, SYS_dup
    5c3e:	48a9                	li	a7,10
 ecall
    5c40:	00000073          	ecall
 ret
    5c44:	8082                	ret

0000000000005c46 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5c46:	48ad                	li	a7,11
 ecall
    5c48:	00000073          	ecall
 ret
    5c4c:	8082                	ret

0000000000005c4e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5c4e:	48b1                	li	a7,12
 ecall
    5c50:	00000073          	ecall
 ret
    5c54:	8082                	ret

0000000000005c56 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5c56:	48b5                	li	a7,13
 ecall
    5c58:	00000073          	ecall
 ret
    5c5c:	8082                	ret

0000000000005c5e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5c5e:	48b9                	li	a7,14
 ecall
    5c60:	00000073          	ecall
 ret
    5c64:	8082                	ret

0000000000005c66 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
    5c66:	48d9                	li	a7,22
 ecall
    5c68:	00000073          	ecall
 ret
    5c6c:	8082                	ret

0000000000005c6e <putc>:
=======
0000000000005c36 <putc>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
<<<<<<< HEAD
    5c6e:	1101                	addi	sp,sp,-32
    5c70:	ec06                	sd	ra,24(sp)
    5c72:	e822                	sd	s0,16(sp)
    5c74:	1000                	addi	s0,sp,32
    5c76:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5c7a:	4605                	li	a2,1
    5c7c:	fef40593          	addi	a1,s0,-17
    5c80:	00000097          	auipc	ra,0x0
    5c84:	f66080e7          	jalr	-154(ra) # 5be6 <write>
}
    5c88:	60e2                	ld	ra,24(sp)
    5c8a:	6442                	ld	s0,16(sp)
    5c8c:	6105                	addi	sp,sp,32
    5c8e:	8082                	ret

0000000000005c90 <printint>:
=======
    5c36:	1101                	addi	sp,sp,-32
    5c38:	ec06                	sd	ra,24(sp)
    5c3a:	e822                	sd	s0,16(sp)
    5c3c:	1000                	addi	s0,sp,32
    5c3e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5c42:	4605                	li	a2,1
    5c44:	fef40593          	addi	a1,s0,-17
    5c48:	00000097          	auipc	ra,0x0
    5c4c:	f66080e7          	jalr	-154(ra) # 5bae <write>
}
    5c50:	60e2                	ld	ra,24(sp)
    5c52:	6442                	ld	s0,16(sp)
    5c54:	6105                	addi	sp,sp,32
    5c56:	8082                	ret

0000000000005c58 <printint>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

static void
printint(int fd, int xx, int base, int sgn)
{
<<<<<<< HEAD
    5c90:	7139                	addi	sp,sp,-64
    5c92:	fc06                	sd	ra,56(sp)
    5c94:	f822                	sd	s0,48(sp)
    5c96:	f426                	sd	s1,40(sp)
    5c98:	f04a                	sd	s2,32(sp)
    5c9a:	ec4e                	sd	s3,24(sp)
    5c9c:	0080                	addi	s0,sp,64
    5c9e:	84aa                	mv	s1,a0
=======
    5c58:	7139                	addi	sp,sp,-64
    5c5a:	fc06                	sd	ra,56(sp)
    5c5c:	f822                	sd	s0,48(sp)
    5c5e:	f426                	sd	s1,40(sp)
    5c60:	f04a                	sd	s2,32(sp)
    5c62:	ec4e                	sd	s3,24(sp)
    5c64:	0080                	addi	s0,sp,64
    5c66:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
<<<<<<< HEAD
    5ca0:	c299                	beqz	a3,5ca6 <printint+0x16>
    5ca2:	0805c863          	bltz	a1,5d32 <printint+0xa2>
=======
    5c68:	c299                	beqz	a3,5c6e <printint+0x16>
    5c6a:	0805c963          	bltz	a1,5cfc <printint+0xa4>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    neg = 1;
    x = -xx;
  } else {
    x = xx;
<<<<<<< HEAD
    5ca6:	2581                	sext.w	a1,a1
  neg = 0;
    5ca8:	4881                	li	a7,0
    5caa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5cae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5cb0:	2601                	sext.w	a2,a2
    5cb2:	00003517          	auipc	a0,0x3
    5cb6:	8be50513          	addi	a0,a0,-1858 # 8570 <digits>
    5cba:	883a                	mv	a6,a4
    5cbc:	2705                	addiw	a4,a4,1
    5cbe:	02c5f7bb          	remuw	a5,a1,a2
    5cc2:	1782                	slli	a5,a5,0x20
    5cc4:	9381                	srli	a5,a5,0x20
    5cc6:	97aa                	add	a5,a5,a0
    5cc8:	0007c783          	lbu	a5,0(a5)
    5ccc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5cd0:	0005879b          	sext.w	a5,a1
    5cd4:	02c5d5bb          	divuw	a1,a1,a2
    5cd8:	0685                	addi	a3,a3,1
    5cda:	fec7f0e3          	bgeu	a5,a2,5cba <printint+0x2a>
  if(neg)
    5cde:	00088b63          	beqz	a7,5cf4 <printint+0x64>
    buf[i++] = '-';
    5ce2:	fd040793          	addi	a5,s0,-48
    5ce6:	973e                	add	a4,a4,a5
    5ce8:	02d00793          	li	a5,45
    5cec:	fef70823          	sb	a5,-16(a4)
    5cf0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5cf4:	02e05863          	blez	a4,5d24 <printint+0x94>
    5cf8:	fc040793          	addi	a5,s0,-64
    5cfc:	00e78933          	add	s2,a5,a4
    5d00:	fff78993          	addi	s3,a5,-1
    5d04:	99ba                	add	s3,s3,a4
    5d06:	377d                	addiw	a4,a4,-1
    5d08:	1702                	slli	a4,a4,0x20
    5d0a:	9301                	srli	a4,a4,0x20
    5d0c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5d10:	fff94583          	lbu	a1,-1(s2)
    5d14:	8526                	mv	a0,s1
    5d16:	00000097          	auipc	ra,0x0
    5d1a:	f58080e7          	jalr	-168(ra) # 5c6e <putc>
  while(--i >= 0)
    5d1e:	197d                	addi	s2,s2,-1
    5d20:	ff3918e3          	bne	s2,s3,5d10 <printint+0x80>
}
    5d24:	70e2                	ld	ra,56(sp)
    5d26:	7442                	ld	s0,48(sp)
    5d28:	74a2                	ld	s1,40(sp)
    5d2a:	7902                	ld	s2,32(sp)
    5d2c:	69e2                	ld	s3,24(sp)
    5d2e:	6121                	addi	sp,sp,64
    5d30:	8082                	ret
    x = -xx;
    5d32:	40b005bb          	negw	a1,a1
    neg = 1;
    5d36:	4885                	li	a7,1
    x = -xx;
    5d38:	bf8d                	j	5caa <printint+0x1a>

0000000000005d3a <vprintf>:
=======
    5c6e:	2581                	sext.w	a1,a1
  neg = 0;
    5c70:	4881                	li	a7,0
    5c72:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5c76:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5c78:	2601                	sext.w	a2,a2
    5c7a:	00003517          	auipc	a0,0x3
    5c7e:	8fe50513          	addi	a0,a0,-1794 # 8578 <digits>
    5c82:	883a                	mv	a6,a4
    5c84:	2705                	addiw	a4,a4,1
    5c86:	02c5f7bb          	remuw	a5,a1,a2
    5c8a:	1782                	slli	a5,a5,0x20
    5c8c:	9381                	srli	a5,a5,0x20
    5c8e:	97aa                	add	a5,a5,a0
    5c90:	0007c783          	lbu	a5,0(a5)
    5c94:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5c98:	0005879b          	sext.w	a5,a1
    5c9c:	02c5d5bb          	divuw	a1,a1,a2
    5ca0:	0685                	addi	a3,a3,1
    5ca2:	fec7f0e3          	bgeu	a5,a2,5c82 <printint+0x2a>
  if(neg)
    5ca6:	00088c63          	beqz	a7,5cbe <printint+0x66>
    buf[i++] = '-';
    5caa:	fd070793          	addi	a5,a4,-48
    5cae:	00878733          	add	a4,a5,s0
    5cb2:	02d00793          	li	a5,45
    5cb6:	fef70823          	sb	a5,-16(a4)
    5cba:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5cbe:	02e05863          	blez	a4,5cee <printint+0x96>
    5cc2:	fc040793          	addi	a5,s0,-64
    5cc6:	00e78933          	add	s2,a5,a4
    5cca:	fff78993          	addi	s3,a5,-1
    5cce:	99ba                	add	s3,s3,a4
    5cd0:	377d                	addiw	a4,a4,-1
    5cd2:	1702                	slli	a4,a4,0x20
    5cd4:	9301                	srli	a4,a4,0x20
    5cd6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5cda:	fff94583          	lbu	a1,-1(s2)
    5cde:	8526                	mv	a0,s1
    5ce0:	00000097          	auipc	ra,0x0
    5ce4:	f56080e7          	jalr	-170(ra) # 5c36 <putc>
  while(--i >= 0)
    5ce8:	197d                	addi	s2,s2,-1
    5cea:	ff3918e3          	bne	s2,s3,5cda <printint+0x82>
}
    5cee:	70e2                	ld	ra,56(sp)
    5cf0:	7442                	ld	s0,48(sp)
    5cf2:	74a2                	ld	s1,40(sp)
    5cf4:	7902                	ld	s2,32(sp)
    5cf6:	69e2                	ld	s3,24(sp)
    5cf8:	6121                	addi	sp,sp,64
    5cfa:	8082                	ret
    x = -xx;
    5cfc:	40b005bb          	negw	a1,a1
    neg = 1;
    5d00:	4885                	li	a7,1
    x = -xx;
    5d02:	bf85                	j	5c72 <printint+0x1a>

0000000000005d04 <vprintf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
<<<<<<< HEAD
    5d3a:	7119                	addi	sp,sp,-128
    5d3c:	fc86                	sd	ra,120(sp)
    5d3e:	f8a2                	sd	s0,112(sp)
    5d40:	f4a6                	sd	s1,104(sp)
    5d42:	f0ca                	sd	s2,96(sp)
    5d44:	ecce                	sd	s3,88(sp)
    5d46:	e8d2                	sd	s4,80(sp)
    5d48:	e4d6                	sd	s5,72(sp)
    5d4a:	e0da                	sd	s6,64(sp)
    5d4c:	fc5e                	sd	s7,56(sp)
    5d4e:	f862                	sd	s8,48(sp)
    5d50:	f466                	sd	s9,40(sp)
    5d52:	f06a                	sd	s10,32(sp)
    5d54:	ec6e                	sd	s11,24(sp)
    5d56:	0100                	addi	s0,sp,128
=======
    5d04:	715d                	addi	sp,sp,-80
    5d06:	e486                	sd	ra,72(sp)
    5d08:	e0a2                	sd	s0,64(sp)
    5d0a:	fc26                	sd	s1,56(sp)
    5d0c:	f84a                	sd	s2,48(sp)
    5d0e:	f44e                	sd	s3,40(sp)
    5d10:	f052                	sd	s4,32(sp)
    5d12:	ec56                	sd	s5,24(sp)
    5d14:	e85a                	sd	s6,16(sp)
    5d16:	e45e                	sd	s7,8(sp)
    5d18:	e062                	sd	s8,0(sp)
    5d1a:	0880                	addi	s0,sp,80
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
<<<<<<< HEAD
    5d58:	0005c903          	lbu	s2,0(a1)
    5d5c:	18090f63          	beqz	s2,5efa <vprintf+0x1c0>
    5d60:	8aaa                	mv	s5,a0
    5d62:	8b32                	mv	s6,a2
    5d64:	00158493          	addi	s1,a1,1
  state = 0;
    5d68:	4981                	li	s3,0
=======
    5d1c:	0005c903          	lbu	s2,0(a1)
    5d20:	18090c63          	beqz	s2,5eb8 <vprintf+0x1b4>
    5d24:	8aaa                	mv	s5,a0
    5d26:	8bb2                	mv	s7,a2
    5d28:	00158493          	addi	s1,a1,1
  state = 0;
    5d2c:	4981                	li	s3,0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
<<<<<<< HEAD
    5d6a:	02500a13          	li	s4,37
      if(c == 'd'){
    5d6e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5d72:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5d76:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5d7a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5d7e:	00002b97          	auipc	s7,0x2
    5d82:	7f2b8b93          	addi	s7,s7,2034 # 8570 <digits>
    5d86:	a839                	j	5da4 <vprintf+0x6a>
        putc(fd, c);
    5d88:	85ca                	mv	a1,s2
    5d8a:	8556                	mv	a0,s5
    5d8c:	00000097          	auipc	ra,0x0
    5d90:	ee2080e7          	jalr	-286(ra) # 5c6e <putc>
    5d94:	a019                	j	5d9a <vprintf+0x60>
    } else if(state == '%'){
    5d96:	01498f63          	beq	s3,s4,5db4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5d9a:	0485                	addi	s1,s1,1
    5d9c:	fff4c903          	lbu	s2,-1(s1)
    5da0:	14090d63          	beqz	s2,5efa <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5da4:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5da8:	fe0997e3          	bnez	s3,5d96 <vprintf+0x5c>
      if(c == '%'){
    5dac:	fd479ee3          	bne	a5,s4,5d88 <vprintf+0x4e>
        state = '%';
    5db0:	89be                	mv	s3,a5
    5db2:	b7e5                	j	5d9a <vprintf+0x60>
      if(c == 'd'){
    5db4:	05878063          	beq	a5,s8,5df4 <vprintf+0xba>
      } else if(c == 'l') {
    5db8:	05978c63          	beq	a5,s9,5e10 <vprintf+0xd6>
      } else if(c == 'x') {
    5dbc:	07a78863          	beq	a5,s10,5e2c <vprintf+0xf2>
      } else if(c == 'p') {
    5dc0:	09b78463          	beq	a5,s11,5e48 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5dc4:	07300713          	li	a4,115
    5dc8:	0ce78663          	beq	a5,a4,5e94 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5dcc:	06300713          	li	a4,99
    5dd0:	0ee78e63          	beq	a5,a4,5ecc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5dd4:	11478863          	beq	a5,s4,5ee4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5dd8:	85d2                	mv	a1,s4
    5dda:	8556                	mv	a0,s5
    5ddc:	00000097          	auipc	ra,0x0
    5de0:	e92080e7          	jalr	-366(ra) # 5c6e <putc>
        putc(fd, c);
    5de4:	85ca                	mv	a1,s2
    5de6:	8556                	mv	a0,s5
    5de8:	00000097          	auipc	ra,0x0
    5dec:	e86080e7          	jalr	-378(ra) # 5c6e <putc>
      }
      state = 0;
    5df0:	4981                	li	s3,0
    5df2:	b765                	j	5d9a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5df4:	008b0913          	addi	s2,s6,8
    5df8:	4685                	li	a3,1
    5dfa:	4629                	li	a2,10
    5dfc:	000b2583          	lw	a1,0(s6)
    5e00:	8556                	mv	a0,s5
    5e02:	00000097          	auipc	ra,0x0
    5e06:	e8e080e7          	jalr	-370(ra) # 5c90 <printint>
    5e0a:	8b4a                	mv	s6,s2
      state = 0;
    5e0c:	4981                	li	s3,0
    5e0e:	b771                	j	5d9a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5e10:	008b0913          	addi	s2,s6,8
    5e14:	4681                	li	a3,0
    5e16:	4629                	li	a2,10
    5e18:	000b2583          	lw	a1,0(s6)
    5e1c:	8556                	mv	a0,s5
    5e1e:	00000097          	auipc	ra,0x0
    5e22:	e72080e7          	jalr	-398(ra) # 5c90 <printint>
    5e26:	8b4a                	mv	s6,s2
      state = 0;
    5e28:	4981                	li	s3,0
    5e2a:	bf85                	j	5d9a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5e2c:	008b0913          	addi	s2,s6,8
    5e30:	4681                	li	a3,0
    5e32:	4641                	li	a2,16
    5e34:	000b2583          	lw	a1,0(s6)
    5e38:	8556                	mv	a0,s5
    5e3a:	00000097          	auipc	ra,0x0
    5e3e:	e56080e7          	jalr	-426(ra) # 5c90 <printint>
    5e42:	8b4a                	mv	s6,s2
      state = 0;
    5e44:	4981                	li	s3,0
    5e46:	bf91                	j	5d9a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5e48:	008b0793          	addi	a5,s6,8
    5e4c:	f8f43423          	sd	a5,-120(s0)
    5e50:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5e54:	03000593          	li	a1,48
    5e58:	8556                	mv	a0,s5
    5e5a:	00000097          	auipc	ra,0x0
    5e5e:	e14080e7          	jalr	-492(ra) # 5c6e <putc>
  putc(fd, 'x');
    5e62:	85ea                	mv	a1,s10
    5e64:	8556                	mv	a0,s5
    5e66:	00000097          	auipc	ra,0x0
    5e6a:	e08080e7          	jalr	-504(ra) # 5c6e <putc>
    5e6e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5e70:	03c9d793          	srli	a5,s3,0x3c
    5e74:	97de                	add	a5,a5,s7
    5e76:	0007c583          	lbu	a1,0(a5)
    5e7a:	8556                	mv	a0,s5
    5e7c:	00000097          	auipc	ra,0x0
    5e80:	df2080e7          	jalr	-526(ra) # 5c6e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5e84:	0992                	slli	s3,s3,0x4
    5e86:	397d                	addiw	s2,s2,-1
    5e88:	fe0914e3          	bnez	s2,5e70 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5e8c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5e90:	4981                	li	s3,0
    5e92:	b721                	j	5d9a <vprintf+0x60>
        s = va_arg(ap, char*);
    5e94:	008b0993          	addi	s3,s6,8
    5e98:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5e9c:	02090163          	beqz	s2,5ebe <vprintf+0x184>
        while(*s != 0){
    5ea0:	00094583          	lbu	a1,0(s2)
    5ea4:	c9a1                	beqz	a1,5ef4 <vprintf+0x1ba>
          putc(fd, *s);
    5ea6:	8556                	mv	a0,s5
    5ea8:	00000097          	auipc	ra,0x0
    5eac:	dc6080e7          	jalr	-570(ra) # 5c6e <putc>
          s++;
    5eb0:	0905                	addi	s2,s2,1
        while(*s != 0){
    5eb2:	00094583          	lbu	a1,0(s2)
    5eb6:	f9e5                	bnez	a1,5ea6 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5eb8:	8b4e                	mv	s6,s3
      state = 0;
    5eba:	4981                	li	s3,0
    5ebc:	bdf9                	j	5d9a <vprintf+0x60>
          s = "(null)";
    5ebe:	00002917          	auipc	s2,0x2
    5ec2:	6aa90913          	addi	s2,s2,1706 # 8568 <malloc+0x2564>
        while(*s != 0){
    5ec6:	02800593          	li	a1,40
    5eca:	bff1                	j	5ea6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5ecc:	008b0913          	addi	s2,s6,8
    5ed0:	000b4583          	lbu	a1,0(s6)
    5ed4:	8556                	mv	a0,s5
    5ed6:	00000097          	auipc	ra,0x0
    5eda:	d98080e7          	jalr	-616(ra) # 5c6e <putc>
    5ede:	8b4a                	mv	s6,s2
      state = 0;
    5ee0:	4981                	li	s3,0
    5ee2:	bd65                	j	5d9a <vprintf+0x60>
        putc(fd, c);
    5ee4:	85d2                	mv	a1,s4
    5ee6:	8556                	mv	a0,s5
    5ee8:	00000097          	auipc	ra,0x0
    5eec:	d86080e7          	jalr	-634(ra) # 5c6e <putc>
      state = 0;
    5ef0:	4981                	li	s3,0
    5ef2:	b565                	j	5d9a <vprintf+0x60>
        s = va_arg(ap, char*);
    5ef4:	8b4e                	mv	s6,s3
      state = 0;
    5ef6:	4981                	li	s3,0
    5ef8:	b54d                	j	5d9a <vprintf+0x60>
    }
  }
}
    5efa:	70e6                	ld	ra,120(sp)
    5efc:	7446                	ld	s0,112(sp)
    5efe:	74a6                	ld	s1,104(sp)
    5f00:	7906                	ld	s2,96(sp)
    5f02:	69e6                	ld	s3,88(sp)
    5f04:	6a46                	ld	s4,80(sp)
    5f06:	6aa6                	ld	s5,72(sp)
    5f08:	6b06                	ld	s6,64(sp)
    5f0a:	7be2                	ld	s7,56(sp)
    5f0c:	7c42                	ld	s8,48(sp)
    5f0e:	7ca2                	ld	s9,40(sp)
    5f10:	7d02                	ld	s10,32(sp)
    5f12:	6de2                	ld	s11,24(sp)
    5f14:	6109                	addi	sp,sp,128
    5f16:	8082                	ret

0000000000005f18 <fprintf>:
=======
    5d2e:	02500a13          	li	s4,37
    5d32:	4b55                	li	s6,21
    5d34:	a839                	j	5d52 <vprintf+0x4e>
        putc(fd, c);
    5d36:	85ca                	mv	a1,s2
    5d38:	8556                	mv	a0,s5
    5d3a:	00000097          	auipc	ra,0x0
    5d3e:	efc080e7          	jalr	-260(ra) # 5c36 <putc>
    5d42:	a019                	j	5d48 <vprintf+0x44>
    } else if(state == '%'){
    5d44:	01498d63          	beq	s3,s4,5d5e <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
    5d48:	0485                	addi	s1,s1,1
    5d4a:	fff4c903          	lbu	s2,-1(s1)
    5d4e:	16090563          	beqz	s2,5eb8 <vprintf+0x1b4>
    if(state == 0){
    5d52:	fe0999e3          	bnez	s3,5d44 <vprintf+0x40>
      if(c == '%'){
    5d56:	ff4910e3          	bne	s2,s4,5d36 <vprintf+0x32>
        state = '%';
    5d5a:	89d2                	mv	s3,s4
    5d5c:	b7f5                	j	5d48 <vprintf+0x44>
      if(c == 'd'){
    5d5e:	13490263          	beq	s2,s4,5e82 <vprintf+0x17e>
    5d62:	f9d9079b          	addiw	a5,s2,-99
    5d66:	0ff7f793          	zext.b	a5,a5
    5d6a:	12fb6563          	bltu	s6,a5,5e94 <vprintf+0x190>
    5d6e:	f9d9079b          	addiw	a5,s2,-99
    5d72:	0ff7f713          	zext.b	a4,a5
    5d76:	10eb6f63          	bltu	s6,a4,5e94 <vprintf+0x190>
    5d7a:	00271793          	slli	a5,a4,0x2
    5d7e:	00002717          	auipc	a4,0x2
    5d82:	7a270713          	addi	a4,a4,1954 # 8520 <malloc+0x256a>
    5d86:	97ba                	add	a5,a5,a4
    5d88:	439c                	lw	a5,0(a5)
    5d8a:	97ba                	add	a5,a5,a4
    5d8c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    5d8e:	008b8913          	addi	s2,s7,8
    5d92:	4685                	li	a3,1
    5d94:	4629                	li	a2,10
    5d96:	000ba583          	lw	a1,0(s7)
    5d9a:	8556                	mv	a0,s5
    5d9c:	00000097          	auipc	ra,0x0
    5da0:	ebc080e7          	jalr	-324(ra) # 5c58 <printint>
    5da4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    5da6:	4981                	li	s3,0
    5da8:	b745                	j	5d48 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5daa:	008b8913          	addi	s2,s7,8
    5dae:	4681                	li	a3,0
    5db0:	4629                	li	a2,10
    5db2:	000ba583          	lw	a1,0(s7)
    5db6:	8556                	mv	a0,s5
    5db8:	00000097          	auipc	ra,0x0
    5dbc:	ea0080e7          	jalr	-352(ra) # 5c58 <printint>
    5dc0:	8bca                	mv	s7,s2
      state = 0;
    5dc2:	4981                	li	s3,0
    5dc4:	b751                	j	5d48 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
    5dc6:	008b8913          	addi	s2,s7,8
    5dca:	4681                	li	a3,0
    5dcc:	4641                	li	a2,16
    5dce:	000ba583          	lw	a1,0(s7)
    5dd2:	8556                	mv	a0,s5
    5dd4:	00000097          	auipc	ra,0x0
    5dd8:	e84080e7          	jalr	-380(ra) # 5c58 <printint>
    5ddc:	8bca                	mv	s7,s2
      state = 0;
    5dde:	4981                	li	s3,0
    5de0:	b7a5                	j	5d48 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
    5de2:	008b8c13          	addi	s8,s7,8
    5de6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    5dea:	03000593          	li	a1,48
    5dee:	8556                	mv	a0,s5
    5df0:	00000097          	auipc	ra,0x0
    5df4:	e46080e7          	jalr	-442(ra) # 5c36 <putc>
  putc(fd, 'x');
    5df8:	07800593          	li	a1,120
    5dfc:	8556                	mv	a0,s5
    5dfe:	00000097          	auipc	ra,0x0
    5e02:	e38080e7          	jalr	-456(ra) # 5c36 <putc>
    5e06:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5e08:	00002b97          	auipc	s7,0x2
    5e0c:	770b8b93          	addi	s7,s7,1904 # 8578 <digits>
    5e10:	03c9d793          	srli	a5,s3,0x3c
    5e14:	97de                	add	a5,a5,s7
    5e16:	0007c583          	lbu	a1,0(a5)
    5e1a:	8556                	mv	a0,s5
    5e1c:	00000097          	auipc	ra,0x0
    5e20:	e1a080e7          	jalr	-486(ra) # 5c36 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5e24:	0992                	slli	s3,s3,0x4
    5e26:	397d                	addiw	s2,s2,-1
    5e28:	fe0914e3          	bnez	s2,5e10 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    5e2c:	8be2                	mv	s7,s8
      state = 0;
    5e2e:	4981                	li	s3,0
    5e30:	bf21                	j	5d48 <vprintf+0x44>
        s = va_arg(ap, char*);
    5e32:	008b8993          	addi	s3,s7,8
    5e36:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    5e3a:	02090163          	beqz	s2,5e5c <vprintf+0x158>
        while(*s != 0){
    5e3e:	00094583          	lbu	a1,0(s2)
    5e42:	c9a5                	beqz	a1,5eb2 <vprintf+0x1ae>
          putc(fd, *s);
    5e44:	8556                	mv	a0,s5
    5e46:	00000097          	auipc	ra,0x0
    5e4a:	df0080e7          	jalr	-528(ra) # 5c36 <putc>
          s++;
    5e4e:	0905                	addi	s2,s2,1
        while(*s != 0){
    5e50:	00094583          	lbu	a1,0(s2)
    5e54:	f9e5                	bnez	a1,5e44 <vprintf+0x140>
        s = va_arg(ap, char*);
    5e56:	8bce                	mv	s7,s3
      state = 0;
    5e58:	4981                	li	s3,0
    5e5a:	b5fd                	j	5d48 <vprintf+0x44>
          s = "(null)";
    5e5c:	00002917          	auipc	s2,0x2
    5e60:	6bc90913          	addi	s2,s2,1724 # 8518 <malloc+0x2562>
        while(*s != 0){
    5e64:	02800593          	li	a1,40
    5e68:	bff1                	j	5e44 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
    5e6a:	008b8913          	addi	s2,s7,8
    5e6e:	000bc583          	lbu	a1,0(s7)
    5e72:	8556                	mv	a0,s5
    5e74:	00000097          	auipc	ra,0x0
    5e78:	dc2080e7          	jalr	-574(ra) # 5c36 <putc>
    5e7c:	8bca                	mv	s7,s2
      state = 0;
    5e7e:	4981                	li	s3,0
    5e80:	b5e1                	j	5d48 <vprintf+0x44>
        putc(fd, c);
    5e82:	02500593          	li	a1,37
    5e86:	8556                	mv	a0,s5
    5e88:	00000097          	auipc	ra,0x0
    5e8c:	dae080e7          	jalr	-594(ra) # 5c36 <putc>
      state = 0;
    5e90:	4981                	li	s3,0
    5e92:	bd5d                	j	5d48 <vprintf+0x44>
        putc(fd, '%');
    5e94:	02500593          	li	a1,37
    5e98:	8556                	mv	a0,s5
    5e9a:	00000097          	auipc	ra,0x0
    5e9e:	d9c080e7          	jalr	-612(ra) # 5c36 <putc>
        putc(fd, c);
    5ea2:	85ca                	mv	a1,s2
    5ea4:	8556                	mv	a0,s5
    5ea6:	00000097          	auipc	ra,0x0
    5eaa:	d90080e7          	jalr	-624(ra) # 5c36 <putc>
      state = 0;
    5eae:	4981                	li	s3,0
    5eb0:	bd61                	j	5d48 <vprintf+0x44>
        s = va_arg(ap, char*);
    5eb2:	8bce                	mv	s7,s3
      state = 0;
    5eb4:	4981                	li	s3,0
    5eb6:	bd49                	j	5d48 <vprintf+0x44>
    }
  }
}
    5eb8:	60a6                	ld	ra,72(sp)
    5eba:	6406                	ld	s0,64(sp)
    5ebc:	74e2                	ld	s1,56(sp)
    5ebe:	7942                	ld	s2,48(sp)
    5ec0:	79a2                	ld	s3,40(sp)
    5ec2:	7a02                	ld	s4,32(sp)
    5ec4:	6ae2                	ld	s5,24(sp)
    5ec6:	6b42                	ld	s6,16(sp)
    5ec8:	6ba2                	ld	s7,8(sp)
    5eca:	6c02                	ld	s8,0(sp)
    5ecc:	6161                	addi	sp,sp,80
    5ece:	8082                	ret

0000000000005ed0 <fprintf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

void
fprintf(int fd, const char *fmt, ...)
{
<<<<<<< HEAD
    5f18:	715d                	addi	sp,sp,-80
    5f1a:	ec06                	sd	ra,24(sp)
    5f1c:	e822                	sd	s0,16(sp)
    5f1e:	1000                	addi	s0,sp,32
    5f20:	e010                	sd	a2,0(s0)
    5f22:	e414                	sd	a3,8(s0)
    5f24:	e818                	sd	a4,16(s0)
    5f26:	ec1c                	sd	a5,24(s0)
    5f28:	03043023          	sd	a6,32(s0)
    5f2c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5f30:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5f34:	8622                	mv	a2,s0
    5f36:	00000097          	auipc	ra,0x0
    5f3a:	e04080e7          	jalr	-508(ra) # 5d3a <vprintf>
}
    5f3e:	60e2                	ld	ra,24(sp)
    5f40:	6442                	ld	s0,16(sp)
    5f42:	6161                	addi	sp,sp,80
    5f44:	8082                	ret

0000000000005f46 <printf>:
=======
    5ed0:	715d                	addi	sp,sp,-80
    5ed2:	ec06                	sd	ra,24(sp)
    5ed4:	e822                	sd	s0,16(sp)
    5ed6:	1000                	addi	s0,sp,32
    5ed8:	e010                	sd	a2,0(s0)
    5eda:	e414                	sd	a3,8(s0)
    5edc:	e818                	sd	a4,16(s0)
    5ede:	ec1c                	sd	a5,24(s0)
    5ee0:	03043023          	sd	a6,32(s0)
    5ee4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5ee8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5eec:	8622                	mv	a2,s0
    5eee:	00000097          	auipc	ra,0x0
    5ef2:	e16080e7          	jalr	-490(ra) # 5d04 <vprintf>
}
    5ef6:	60e2                	ld	ra,24(sp)
    5ef8:	6442                	ld	s0,16(sp)
    5efa:	6161                	addi	sp,sp,80
    5efc:	8082                	ret

0000000000005efe <printf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

void
printf(const char *fmt, ...)
{
<<<<<<< HEAD
    5f46:	711d                	addi	sp,sp,-96
    5f48:	ec06                	sd	ra,24(sp)
    5f4a:	e822                	sd	s0,16(sp)
    5f4c:	1000                	addi	s0,sp,32
    5f4e:	e40c                	sd	a1,8(s0)
    5f50:	e810                	sd	a2,16(s0)
    5f52:	ec14                	sd	a3,24(s0)
    5f54:	f018                	sd	a4,32(s0)
    5f56:	f41c                	sd	a5,40(s0)
    5f58:	03043823          	sd	a6,48(s0)
    5f5c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5f60:	00840613          	addi	a2,s0,8
    5f64:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5f68:	85aa                	mv	a1,a0
    5f6a:	4505                	li	a0,1
    5f6c:	00000097          	auipc	ra,0x0
    5f70:	dce080e7          	jalr	-562(ra) # 5d3a <vprintf>
}
    5f74:	60e2                	ld	ra,24(sp)
    5f76:	6442                	ld	s0,16(sp)
    5f78:	6125                	addi	sp,sp,96
    5f7a:	8082                	ret

0000000000005f7c <free>:
=======
    5efe:	711d                	addi	sp,sp,-96
    5f00:	ec06                	sd	ra,24(sp)
    5f02:	e822                	sd	s0,16(sp)
    5f04:	1000                	addi	s0,sp,32
    5f06:	e40c                	sd	a1,8(s0)
    5f08:	e810                	sd	a2,16(s0)
    5f0a:	ec14                	sd	a3,24(s0)
    5f0c:	f018                	sd	a4,32(s0)
    5f0e:	f41c                	sd	a5,40(s0)
    5f10:	03043823          	sd	a6,48(s0)
    5f14:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5f18:	00840613          	addi	a2,s0,8
    5f1c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5f20:	85aa                	mv	a1,a0
    5f22:	4505                	li	a0,1
    5f24:	00000097          	auipc	ra,0x0
    5f28:	de0080e7          	jalr	-544(ra) # 5d04 <vprintf>
}
    5f2c:	60e2                	ld	ra,24(sp)
    5f2e:	6442                	ld	s0,16(sp)
    5f30:	6125                	addi	sp,sp,96
    5f32:	8082                	ret

0000000000005f34 <free>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
static Header base;
static Header *freep;

void
free(void *ap)
{
<<<<<<< HEAD
    5f7c:	1141                	addi	sp,sp,-16
    5f7e:	e422                	sd	s0,8(sp)
    5f80:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5f82:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f86:	00003797          	auipc	a5,0x3
    5f8a:	4ca7b783          	ld	a5,1226(a5) # 9450 <freep>
    5f8e:	a805                	j	5fbe <free+0x42>
=======
    5f34:	1141                	addi	sp,sp,-16
    5f36:	e422                	sd	s0,8(sp)
    5f38:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5f3a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f3e:	00003797          	auipc	a5,0x3
    5f42:	5127b783          	ld	a5,1298(a5) # 9450 <freep>
    5f46:	a02d                	j	5f70 <free+0x3c>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
<<<<<<< HEAD
    5f90:	4618                	lw	a4,8(a2)
    5f92:	9db9                	addw	a1,a1,a4
    5f94:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5f98:	6398                	ld	a4,0(a5)
    5f9a:	6318                	ld	a4,0(a4)
    5f9c:	fee53823          	sd	a4,-16(a0)
    5fa0:	a091                	j	5fe4 <free+0x68>
=======
    5f48:	4618                	lw	a4,8(a2)
    5f4a:	9f2d                	addw	a4,a4,a1
    5f4c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5f50:	6398                	ld	a4,0(a5)
    5f52:	6310                	ld	a2,0(a4)
    5f54:	a83d                	j	5f92 <free+0x5e>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
<<<<<<< HEAD
    5fa2:	ff852703          	lw	a4,-8(a0)
    5fa6:	9e39                	addw	a2,a2,a4
    5fa8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5faa:	ff053703          	ld	a4,-16(a0)
    5fae:	e398                	sd	a4,0(a5)
    5fb0:	a099                	j	5ff6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5fb2:	6398                	ld	a4,0(a5)
    5fb4:	00e7e463          	bltu	a5,a4,5fbc <free+0x40>
    5fb8:	00e6ea63          	bltu	a3,a4,5fcc <free+0x50>
{
    5fbc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5fbe:	fed7fae3          	bgeu	a5,a3,5fb2 <free+0x36>
    5fc2:	6398                	ld	a4,0(a5)
    5fc4:	00e6e463          	bltu	a3,a4,5fcc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5fc8:	fee7eae3          	bltu	a5,a4,5fbc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5fcc:	ff852583          	lw	a1,-8(a0)
    5fd0:	6390                	ld	a2,0(a5)
    5fd2:	02059713          	slli	a4,a1,0x20
    5fd6:	9301                	srli	a4,a4,0x20
    5fd8:	0712                	slli	a4,a4,0x4
    5fda:	9736                	add	a4,a4,a3
    5fdc:	fae60ae3          	beq	a2,a4,5f90 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5fe0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5fe4:	4790                	lw	a2,8(a5)
    5fe6:	02061713          	slli	a4,a2,0x20
    5fea:	9301                	srli	a4,a4,0x20
    5fec:	0712                	slli	a4,a4,0x4
    5fee:	973e                	add	a4,a4,a5
    5ff0:	fae689e3          	beq	a3,a4,5fa2 <free+0x26>
  } else
    p->s.ptr = bp;
    5ff4:	e394                	sd	a3,0(a5)
  freep = p;
    5ff6:	00003717          	auipc	a4,0x3
    5ffa:	44f73d23          	sd	a5,1114(a4) # 9450 <freep>
}
    5ffe:	6422                	ld	s0,8(sp)
    6000:	0141                	addi	sp,sp,16
    6002:	8082                	ret

0000000000006004 <malloc>:
=======
    5f56:	ff852703          	lw	a4,-8(a0)
    5f5a:	9f31                	addw	a4,a4,a2
    5f5c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5f5e:	ff053683          	ld	a3,-16(a0)
    5f62:	a091                	j	5fa6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5f64:	6398                	ld	a4,0(a5)
    5f66:	00e7e463          	bltu	a5,a4,5f6e <free+0x3a>
    5f6a:	00e6ea63          	bltu	a3,a4,5f7e <free+0x4a>
{
    5f6e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5f70:	fed7fae3          	bgeu	a5,a3,5f64 <free+0x30>
    5f74:	6398                	ld	a4,0(a5)
    5f76:	00e6e463          	bltu	a3,a4,5f7e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5f7a:	fee7eae3          	bltu	a5,a4,5f6e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    5f7e:	ff852583          	lw	a1,-8(a0)
    5f82:	6390                	ld	a2,0(a5)
    5f84:	02059813          	slli	a6,a1,0x20
    5f88:	01c85713          	srli	a4,a6,0x1c
    5f8c:	9736                	add	a4,a4,a3
    5f8e:	fae60de3          	beq	a2,a4,5f48 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    5f92:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5f96:	4790                	lw	a2,8(a5)
    5f98:	02061593          	slli	a1,a2,0x20
    5f9c:	01c5d713          	srli	a4,a1,0x1c
    5fa0:	973e                	add	a4,a4,a5
    5fa2:	fae68ae3          	beq	a3,a4,5f56 <free+0x22>
    p->s.ptr = bp->s.ptr;
    5fa6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    5fa8:	00003717          	auipc	a4,0x3
    5fac:	4af73423          	sd	a5,1192(a4) # 9450 <freep>
}
    5fb0:	6422                	ld	s0,8(sp)
    5fb2:	0141                	addi	sp,sp,16
    5fb4:	8082                	ret

0000000000005fb6 <malloc>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  return freep;
}

void*
malloc(uint nbytes)
{
<<<<<<< HEAD
    6004:	7139                	addi	sp,sp,-64
    6006:	fc06                	sd	ra,56(sp)
    6008:	f822                	sd	s0,48(sp)
    600a:	f426                	sd	s1,40(sp)
    600c:	f04a                	sd	s2,32(sp)
    600e:	ec4e                	sd	s3,24(sp)
    6010:	e852                	sd	s4,16(sp)
    6012:	e456                	sd	s5,8(sp)
    6014:	e05a                	sd	s6,0(sp)
    6016:	0080                	addi	s0,sp,64
=======
    5fb6:	7139                	addi	sp,sp,-64
    5fb8:	fc06                	sd	ra,56(sp)
    5fba:	f822                	sd	s0,48(sp)
    5fbc:	f426                	sd	s1,40(sp)
    5fbe:	f04a                	sd	s2,32(sp)
    5fc0:	ec4e                	sd	s3,24(sp)
    5fc2:	e852                	sd	s4,16(sp)
    5fc4:	e456                	sd	s5,8(sp)
    5fc6:	e05a                	sd	s6,0(sp)
    5fc8:	0080                	addi	s0,sp,64
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
<<<<<<< HEAD
    6018:	02051493          	slli	s1,a0,0x20
    601c:	9081                	srli	s1,s1,0x20
    601e:	04bd                	addi	s1,s1,15
    6020:	8091                	srli	s1,s1,0x4
    6022:	0014899b          	addiw	s3,s1,1
    6026:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    6028:	00003517          	auipc	a0,0x3
    602c:	42853503          	ld	a0,1064(a0) # 9450 <freep>
    6030:	c515                	beqz	a0,605c <malloc+0x58>
=======
    5fca:	02051493          	slli	s1,a0,0x20
    5fce:	9081                	srli	s1,s1,0x20
    5fd0:	04bd                	addi	s1,s1,15
    5fd2:	8091                	srli	s1,s1,0x4
    5fd4:	0014899b          	addiw	s3,s1,1
    5fd8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5fda:	00003517          	auipc	a0,0x3
    5fde:	47653503          	ld	a0,1142(a0) # 9450 <freep>
    5fe2:	c515                	beqz	a0,600e <malloc+0x58>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
<<<<<<< HEAD
    6032:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    6034:	4798                	lw	a4,8(a5)
    6036:	02977f63          	bgeu	a4,s1,6074 <malloc+0x70>
    603a:	8a4e                	mv	s4,s3
    603c:	0009871b          	sext.w	a4,s3
    6040:	6685                	lui	a3,0x1
    6042:	00d77363          	bgeu	a4,a3,6048 <malloc+0x44>
    6046:	6a05                	lui	s4,0x1
    6048:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    604c:	004a1a1b          	slliw	s4,s4,0x4
=======
    5fe4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5fe6:	4798                	lw	a4,8(a5)
    5fe8:	02977f63          	bgeu	a4,s1,6026 <malloc+0x70>
  if(nu < 4096)
    5fec:	8a4e                	mv	s4,s3
    5fee:	0009871b          	sext.w	a4,s3
    5ff2:	6685                	lui	a3,0x1
    5ff4:	00d77363          	bgeu	a4,a3,5ffa <malloc+0x44>
    5ff8:	6a05                	lui	s4,0x1
    5ffa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5ffe:	004a1a1b          	slliw	s4,s4,0x4
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
<<<<<<< HEAD
    6050:	00003917          	auipc	s2,0x3
    6054:	40090913          	addi	s2,s2,1024 # 9450 <freep>
  if(p == (char*)-1)
    6058:	5afd                	li	s5,-1
    605a:	a88d                	j	60cc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    605c:	0000a797          	auipc	a5,0xa
    6060:	c1c78793          	addi	a5,a5,-996 # fc78 <base>
    6064:	00003717          	auipc	a4,0x3
    6068:	3ef73623          	sd	a5,1004(a4) # 9450 <freep>
    606c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    606e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    6072:	b7e1                	j	603a <malloc+0x36>
      if(p->s.size == nunits)
    6074:	02e48b63          	beq	s1,a4,60aa <malloc+0xa6>
        p->s.size -= nunits;
    6078:	4137073b          	subw	a4,a4,s3
    607c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    607e:	1702                	slli	a4,a4,0x20
    6080:	9301                	srli	a4,a4,0x20
    6082:	0712                	slli	a4,a4,0x4
    6084:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    6086:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    608a:	00003717          	auipc	a4,0x3
    608e:	3ca73323          	sd	a0,966(a4) # 9450 <freep>
      return (void*)(p + 1);
    6092:	01078513          	addi	a0,a5,16
=======
    6002:	00003917          	auipc	s2,0x3
    6006:	44e90913          	addi	s2,s2,1102 # 9450 <freep>
  if(p == (char*)-1)
    600a:	5afd                	li	s5,-1
    600c:	a895                	j	6080 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    600e:	0000a797          	auipc	a5,0xa
    6012:	c6a78793          	addi	a5,a5,-918 # fc78 <base>
    6016:	00003717          	auipc	a4,0x3
    601a:	42f73d23          	sd	a5,1082(a4) # 9450 <freep>
    601e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    6020:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    6024:	b7e1                	j	5fec <malloc+0x36>
      if(p->s.size == nunits)
    6026:	02e48c63          	beq	s1,a4,605e <malloc+0xa8>
        p->s.size -= nunits;
    602a:	4137073b          	subw	a4,a4,s3
    602e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    6030:	02071693          	slli	a3,a4,0x20
    6034:	01c6d713          	srli	a4,a3,0x1c
    6038:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    603a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    603e:	00003717          	auipc	a4,0x3
    6042:	40a73923          	sd	a0,1042(a4) # 9450 <freep>
      return (void*)(p + 1);
    6046:	01078513          	addi	a0,a5,16
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
<<<<<<< HEAD
    6096:	70e2                	ld	ra,56(sp)
    6098:	7442                	ld	s0,48(sp)
    609a:	74a2                	ld	s1,40(sp)
    609c:	7902                	ld	s2,32(sp)
    609e:	69e2                	ld	s3,24(sp)
    60a0:	6a42                	ld	s4,16(sp)
    60a2:	6aa2                	ld	s5,8(sp)
    60a4:	6b02                	ld	s6,0(sp)
    60a6:	6121                	addi	sp,sp,64
    60a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    60aa:	6398                	ld	a4,0(a5)
    60ac:	e118                	sd	a4,0(a0)
    60ae:	bff1                	j	608a <malloc+0x86>
  hp->s.size = nu;
    60b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    60b4:	0541                	addi	a0,a0,16
    60b6:	00000097          	auipc	ra,0x0
    60ba:	ec6080e7          	jalr	-314(ra) # 5f7c <free>
  return freep;
    60be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    60c2:	d971                	beqz	a0,6096 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    60c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    60c6:	4798                	lw	a4,8(a5)
    60c8:	fa9776e3          	bgeu	a4,s1,6074 <malloc+0x70>
    if(p == freep)
    60cc:	00093703          	ld	a4,0(s2)
    60d0:	853e                	mv	a0,a5
    60d2:	fef719e3          	bne	a4,a5,60c4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    60d6:	8552                	mv	a0,s4
    60d8:	00000097          	auipc	ra,0x0
    60dc:	b76080e7          	jalr	-1162(ra) # 5c4e <sbrk>
  if(p == (char*)-1)
    60e0:	fd5518e3          	bne	a0,s5,60b0 <malloc+0xac>
        return 0;
    60e4:	4501                	li	a0,0
    60e6:	bf45                	j	6096 <malloc+0x92>
=======
    604a:	70e2                	ld	ra,56(sp)
    604c:	7442                	ld	s0,48(sp)
    604e:	74a2                	ld	s1,40(sp)
    6050:	7902                	ld	s2,32(sp)
    6052:	69e2                	ld	s3,24(sp)
    6054:	6a42                	ld	s4,16(sp)
    6056:	6aa2                	ld	s5,8(sp)
    6058:	6b02                	ld	s6,0(sp)
    605a:	6121                	addi	sp,sp,64
    605c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    605e:	6398                	ld	a4,0(a5)
    6060:	e118                	sd	a4,0(a0)
    6062:	bff1                	j	603e <malloc+0x88>
  hp->s.size = nu;
    6064:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    6068:	0541                	addi	a0,a0,16
    606a:	00000097          	auipc	ra,0x0
    606e:	eca080e7          	jalr	-310(ra) # 5f34 <free>
  return freep;
    6072:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    6076:	d971                	beqz	a0,604a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6078:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    607a:	4798                	lw	a4,8(a5)
    607c:	fa9775e3          	bgeu	a4,s1,6026 <malloc+0x70>
    if(p == freep)
    6080:	00093703          	ld	a4,0(s2)
    6084:	853e                	mv	a0,a5
    6086:	fef719e3          	bne	a4,a5,6078 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    608a:	8552                	mv	a0,s4
    608c:	00000097          	auipc	ra,0x0
    6090:	b8a080e7          	jalr	-1142(ra) # 5c16 <sbrk>
  if(p == (char*)-1)
    6094:	fd5518e3          	bne	a0,s5,6064 <malloc+0xae>
        return 0;
    6098:	4501                	li	a0,0
    609a:	bf45                	j	604a <malloc+0x94>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
