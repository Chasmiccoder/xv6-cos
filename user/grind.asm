
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	e26080e7          	jalr	-474(ra) # eb6 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
<<<<<<< HEAD
      9e:	32650513          	addi	a0,a0,806 # 13c0 <malloc+0xee>
=======
      9e:	2a650513          	addi	a0,a0,678 # 1340 <malloc+0xea>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      a2:	00001097          	auipc	ra,0x1
      a6:	df4080e7          	jalr	-524(ra) # e96 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
<<<<<<< HEAD
      ae:	31650513          	addi	a0,a0,790 # 13c0 <malloc+0xee>
=======
      ae:	29650513          	addi	a0,a0,662 # 1340 <malloc+0xea>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      b2:	00001097          	auipc	ra,0x1
      b6:	dec080e7          	jalr	-532(ra) # e9e <chdir>
      ba:	cd11                	beqz	a0,d6 <go+0x5e>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
<<<<<<< HEAD
      c0:	30c50513          	addi	a0,a0,780 # 13c8 <malloc+0xf6>
      c4:	00001097          	auipc	ra,0x1
      c8:	150080e7          	jalr	336(ra) # 1214 <printf>
=======
      c0:	28c50513          	addi	a0,a0,652 # 1348 <malloc+0xf2>
      c4:	00001097          	auipc	ra,0x1
      c8:	0da080e7          	jalr	218(ra) # 119e <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d60080e7          	jalr	-672(ra) # e2e <exit>
  }
  chdir("/");
      d6:	00001517          	auipc	a0,0x1
<<<<<<< HEAD
      da:	31250513          	addi	a0,a0,786 # 13e8 <malloc+0x116>
=======
      da:	29250513          	addi	a0,a0,658 # 1368 <malloc+0x112>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      de:	00001097          	auipc	ra,0x1
      e2:	dc0080e7          	jalr	-576(ra) # e9e <chdir>
      e6:	00001997          	auipc	s3,0x1
<<<<<<< HEAD
      ea:	31298993          	addi	s3,s3,786 # 13f8 <malloc+0x126>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	30098993          	addi	s3,s3,768 # 13f0 <malloc+0x11e>
    iters++;
      f8:	4485                	li	s1,1
=======
      ea:	29298993          	addi	s3,s3,658 # 1378 <malloc+0x122>
      ee:	c489                	beqz	s1,f8 <go+0x80>
      f0:	00001997          	auipc	s3,0x1
      f4:	28098993          	addi	s3,s3,640 # 1370 <malloc+0x11a>
  uint64 iters = 0;
      f8:	4481                	li	s1,0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  int fd = -1;
      fa:	5a7d                	li	s4,-1
      fc:	00001917          	auipc	s2,0x1
     100:	52c90913          	addi	s2,s2,1324 # 1628 <malloc+0x3d2>
     104:	a839                	j	122 <go+0xaa>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
     106:	20200593          	li	a1,514
     10a:	00001517          	auipc	a0,0x1
<<<<<<< HEAD
     10e:	2f650513          	addi	a0,a0,758 # 1400 <malloc+0x12e>
=======
     10e:	27650513          	addi	a0,a0,630 # 1380 <malloc+0x12a>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
     112:	00001097          	auipc	ra,0x1
     116:	d5c080e7          	jalr	-676(ra) # e6e <open>
     11a:	00001097          	auipc	ra,0x1
     11e:	d3c080e7          	jalr	-708(ra) # e56 <close>
    iters++;
     122:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     124:	1f400793          	li	a5,500
     128:	02f4f7b3          	remu	a5,s1,a5
     12c:	eb81                	bnez	a5,13c <go+0xc4>
      write(1, which_child?"B":"A", 1);
     12e:	4605                	li	a2,1
     130:	85ce                	mv	a1,s3
     132:	4505                	li	a0,1
     134:	00001097          	auipc	ra,0x1
     138:	d1a080e7          	jalr	-742(ra) # e4e <write>
    int what = rand() % 23;
     13c:	00000097          	auipc	ra,0x0
     140:	f1c080e7          	jalr	-228(ra) # 58 <rand>
     144:	47dd                	li	a5,23
     146:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     14a:	4785                	li	a5,1
     14c:	faf50de3          	beq	a0,a5,106 <go+0x8e>
    } else if(what == 2){
     150:	47d9                	li	a5,22
     152:	fca7e8e3          	bltu	a5,a0,122 <go+0xaa>
     156:	050a                	slli	a0,a0,0x2
     158:	954a                	add	a0,a0,s2
     15a:	411c                	lw	a5,0(a0)
     15c:	97ca                	add	a5,a5,s2
     15e:	8782                	jr	a5
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     160:	20200593          	li	a1,514
     164:	00001517          	auipc	a0,0x1
     168:	22c50513          	addi	a0,a0,556 # 1390 <malloc+0x13a>
     16c:	00001097          	auipc	ra,0x1
     170:	d02080e7          	jalr	-766(ra) # e6e <open>
     174:	00001097          	auipc	ra,0x1
     178:	ce2080e7          	jalr	-798(ra) # e56 <close>
     17c:	b75d                	j	122 <go+0xaa>
    } else if(what == 3){
      unlink("grindir/../a");
     17e:	00001517          	auipc	a0,0x1
     182:	20250513          	addi	a0,a0,514 # 1380 <malloc+0x12a>
     186:	00001097          	auipc	ra,0x1
     18a:	cf8080e7          	jalr	-776(ra) # e7e <unlink>
     18e:	bf51                	j	122 <go+0xaa>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     190:	00001517          	auipc	a0,0x1
     194:	1b050513          	addi	a0,a0,432 # 1340 <malloc+0xea>
     198:	00001097          	auipc	ra,0x1
     19c:	d06080e7          	jalr	-762(ra) # e9e <chdir>
     1a0:	e115                	bnez	a0,1c4 <go+0x14c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     1a2:	00001517          	auipc	a0,0x1
     1a6:	20650513          	addi	a0,a0,518 # 13a8 <malloc+0x152>
     1aa:	00001097          	auipc	ra,0x1
     1ae:	cd4080e7          	jalr	-812(ra) # e7e <unlink>
      chdir("/");
     1b2:	00001517          	auipc	a0,0x1
     1b6:	1b650513          	addi	a0,a0,438 # 1368 <malloc+0x112>
     1ba:	00001097          	auipc	ra,0x1
     1be:	ce4080e7          	jalr	-796(ra) # e9e <chdir>
     1c2:	b785                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     1c4:	00001517          	auipc	a0,0x1
     1c8:	18450513          	addi	a0,a0,388 # 1348 <malloc+0xf2>
     1cc:	00001097          	auipc	ra,0x1
     1d0:	fd2080e7          	jalr	-46(ra) # 119e <printf>
        exit(1);
     1d4:	4505                	li	a0,1
     1d6:	00001097          	auipc	ra,0x1
     1da:	c58080e7          	jalr	-936(ra) # e2e <exit>
    } else if(what == 5){
      close(fd);
     1de:	8552                	mv	a0,s4
     1e0:	00001097          	auipc	ra,0x1
     1e4:	c76080e7          	jalr	-906(ra) # e56 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1e8:	20200593          	li	a1,514
     1ec:	00001517          	auipc	a0,0x1
     1f0:	1c450513          	addi	a0,a0,452 # 13b0 <malloc+0x15a>
     1f4:	00001097          	auipc	ra,0x1
     1f8:	c7a080e7          	jalr	-902(ra) # e6e <open>
     1fc:	8a2a                	mv	s4,a0
     1fe:	b715                	j	122 <go+0xaa>
    } else if(what == 6){
      close(fd);
     200:	8552                	mv	a0,s4
     202:	00001097          	auipc	ra,0x1
     206:	c54080e7          	jalr	-940(ra) # e56 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     20a:	20200593          	li	a1,514
     20e:	00001517          	auipc	a0,0x1
     212:	1b250513          	addi	a0,a0,434 # 13c0 <malloc+0x16a>
     216:	00001097          	auipc	ra,0x1
     21a:	c58080e7          	jalr	-936(ra) # e6e <open>
     21e:	8a2a                	mv	s4,a0
     220:	b709                	j	122 <go+0xaa>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     222:	3e700613          	li	a2,999
     226:	00002597          	auipc	a1,0x2
     22a:	dfa58593          	addi	a1,a1,-518 # 2020 <buf.0>
     22e:	8552                	mv	a0,s4
     230:	00001097          	auipc	ra,0x1
     234:	c1e080e7          	jalr	-994(ra) # e4e <write>
     238:	b5ed                	j	122 <go+0xaa>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     23a:	3e700613          	li	a2,999
     23e:	00002597          	auipc	a1,0x2
     242:	de258593          	addi	a1,a1,-542 # 2020 <buf.0>
     246:	8552                	mv	a0,s4
     248:	00001097          	auipc	ra,0x1
     24c:	bfe080e7          	jalr	-1026(ra) # e46 <read>
     250:	bdc9                	j	122 <go+0xaa>
    } else if(what == 9){
      mkdir("grindir/../a");
     252:	00001517          	auipc	a0,0x1
     256:	12e50513          	addi	a0,a0,302 # 1380 <malloc+0x12a>
     25a:	00001097          	auipc	ra,0x1
     25e:	c3c080e7          	jalr	-964(ra) # e96 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     262:	20200593          	li	a1,514
     266:	00001517          	auipc	a0,0x1
     26a:	17250513          	addi	a0,a0,370 # 13d8 <malloc+0x182>
     26e:	00001097          	auipc	ra,0x1
     272:	c00080e7          	jalr	-1024(ra) # e6e <open>
     276:	00001097          	auipc	ra,0x1
     27a:	be0080e7          	jalr	-1056(ra) # e56 <close>
      unlink("a/a");
     27e:	00001517          	auipc	a0,0x1
     282:	16a50513          	addi	a0,a0,362 # 13e8 <malloc+0x192>
     286:	00001097          	auipc	ra,0x1
     28a:	bf8080e7          	jalr	-1032(ra) # e7e <unlink>
     28e:	bd51                	j	122 <go+0xaa>
    } else if(what == 10){
      mkdir("/../b");
     290:	00001517          	auipc	a0,0x1
     294:	16050513          	addi	a0,a0,352 # 13f0 <malloc+0x19a>
     298:	00001097          	auipc	ra,0x1
     29c:	bfe080e7          	jalr	-1026(ra) # e96 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     2a0:	20200593          	li	a1,514
     2a4:	00001517          	auipc	a0,0x1
     2a8:	15450513          	addi	a0,a0,340 # 13f8 <malloc+0x1a2>
     2ac:	00001097          	auipc	ra,0x1
     2b0:	bc2080e7          	jalr	-1086(ra) # e6e <open>
     2b4:	00001097          	auipc	ra,0x1
     2b8:	ba2080e7          	jalr	-1118(ra) # e56 <close>
      unlink("b/b");
     2bc:	00001517          	auipc	a0,0x1
     2c0:	14c50513          	addi	a0,a0,332 # 1408 <malloc+0x1b2>
     2c4:	00001097          	auipc	ra,0x1
     2c8:	bba080e7          	jalr	-1094(ra) # e7e <unlink>
     2cc:	bd99                	j	122 <go+0xaa>
    } else if(what == 11){
      unlink("b");
     2ce:	00001517          	auipc	a0,0x1
     2d2:	10250513          	addi	a0,a0,258 # 13d0 <malloc+0x17a>
     2d6:	00001097          	auipc	ra,0x1
     2da:	ba8080e7          	jalr	-1112(ra) # e7e <unlink>
      link("../grindir/./../a", "../b");
     2de:	00001597          	auipc	a1,0x1
     2e2:	0ca58593          	addi	a1,a1,202 # 13a8 <malloc+0x152>
     2e6:	00001517          	auipc	a0,0x1
     2ea:	12a50513          	addi	a0,a0,298 # 1410 <malloc+0x1ba>
     2ee:	00001097          	auipc	ra,0x1
     2f2:	ba0080e7          	jalr	-1120(ra) # e8e <link>
     2f6:	b535                	j	122 <go+0xaa>
    } else if(what == 12){
      unlink("../grindir/../a");
     2f8:	00001517          	auipc	a0,0x1
     2fc:	13050513          	addi	a0,a0,304 # 1428 <malloc+0x1d2>
     300:	00001097          	auipc	ra,0x1
     304:	b7e080e7          	jalr	-1154(ra) # e7e <unlink>
      link(".././b", "/grindir/../a");
     308:	00001597          	auipc	a1,0x1
     30c:	0a858593          	addi	a1,a1,168 # 13b0 <malloc+0x15a>
     310:	00001517          	auipc	a0,0x1
     314:	12850513          	addi	a0,a0,296 # 1438 <malloc+0x1e2>
     318:	00001097          	auipc	ra,0x1
     31c:	b76080e7          	jalr	-1162(ra) # e8e <link>
     320:	b509                	j	122 <go+0xaa>
    } else if(what == 13){
      int pid = fork();
     322:	00001097          	auipc	ra,0x1
     326:	b04080e7          	jalr	-1276(ra) # e26 <fork>
      if(pid == 0){
     32a:	c909                	beqz	a0,33c <go+0x2c4>
        exit(0);
      } else if(pid < 0){
     32c:	00054c63          	bltz	a0,344 <go+0x2cc>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     330:	4501                	li	a0,0
     332:	00001097          	auipc	ra,0x1
     336:	b04080e7          	jalr	-1276(ra) # e36 <wait>
     33a:	b3e5                	j	122 <go+0xaa>
        exit(0);
     33c:	00001097          	auipc	ra,0x1
     340:	af2080e7          	jalr	-1294(ra) # e2e <exit>
        printf("grind: fork failed\n");
     344:	00001517          	auipc	a0,0x1
     348:	0fc50513          	addi	a0,a0,252 # 1440 <malloc+0x1ea>
     34c:	00001097          	auipc	ra,0x1
     350:	e52080e7          	jalr	-430(ra) # 119e <printf>
        exit(1);
     354:	4505                	li	a0,1
     356:	00001097          	auipc	ra,0x1
     35a:	ad8080e7          	jalr	-1320(ra) # e2e <exit>
    } else if(what == 14){
      int pid = fork();
     35e:	00001097          	auipc	ra,0x1
     362:	ac8080e7          	jalr	-1336(ra) # e26 <fork>
      if(pid == 0){
     366:	c909                	beqz	a0,378 <go+0x300>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     368:	02054563          	bltz	a0,392 <go+0x31a>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     36c:	4501                	li	a0,0
     36e:	00001097          	auipc	ra,0x1
     372:	ac8080e7          	jalr	-1336(ra) # e36 <wait>
     376:	b375                	j	122 <go+0xaa>
        fork();
     378:	00001097          	auipc	ra,0x1
     37c:	aae080e7          	jalr	-1362(ra) # e26 <fork>
        fork();
     380:	00001097          	auipc	ra,0x1
     384:	aa6080e7          	jalr	-1370(ra) # e26 <fork>
        exit(0);
     388:	4501                	li	a0,0
     38a:	00001097          	auipc	ra,0x1
     38e:	aa4080e7          	jalr	-1372(ra) # e2e <exit>
        printf("grind: fork failed\n");
     392:	00001517          	auipc	a0,0x1
     396:	0ae50513          	addi	a0,a0,174 # 1440 <malloc+0x1ea>
     39a:	00001097          	auipc	ra,0x1
     39e:	e04080e7          	jalr	-508(ra) # 119e <printf>
        exit(1);
     3a2:	4505                	li	a0,1
     3a4:	00001097          	auipc	ra,0x1
     3a8:	a8a080e7          	jalr	-1398(ra) # e2e <exit>
    } else if(what == 15){
      sbrk(6011);
     3ac:	6505                	lui	a0,0x1
     3ae:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x93>
     3b2:	00001097          	auipc	ra,0x1
     3b6:	b04080e7          	jalr	-1276(ra) # eb6 <sbrk>
     3ba:	b3a5                	j	122 <go+0xaa>
    } else if(what == 16){
      if(sbrk(0) > break0)
     3bc:	4501                	li	a0,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	af8080e7          	jalr	-1288(ra) # eb6 <sbrk>
     3c6:	d4aafee3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     3ca:	4501                	li	a0,0
     3cc:	00001097          	auipc	ra,0x1
     3d0:	aea080e7          	jalr	-1302(ra) # eb6 <sbrk>
     3d4:	40aa853b          	subw	a0,s5,a0
     3d8:	00001097          	auipc	ra,0x1
     3dc:	ade080e7          	jalr	-1314(ra) # eb6 <sbrk>
     3e0:	b389                	j	122 <go+0xaa>
    } else if(what == 17){
      int pid = fork();
     3e2:	00001097          	auipc	ra,0x1
     3e6:	a44080e7          	jalr	-1468(ra) # e26 <fork>
     3ea:	8b2a                	mv	s6,a0
      if(pid == 0){
     3ec:	c51d                	beqz	a0,41a <go+0x3a2>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     3ee:	04054963          	bltz	a0,440 <go+0x3c8>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     3f2:	00001517          	auipc	a0,0x1
     3f6:	06650513          	addi	a0,a0,102 # 1458 <malloc+0x202>
     3fa:	00001097          	auipc	ra,0x1
     3fe:	aa4080e7          	jalr	-1372(ra) # e9e <chdir>
     402:	ed21                	bnez	a0,45a <go+0x3e2>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     404:	855a                	mv	a0,s6
     406:	00001097          	auipc	ra,0x1
     40a:	a58080e7          	jalr	-1448(ra) # e5e <kill>
      wait(0);
     40e:	4501                	li	a0,0
     410:	00001097          	auipc	ra,0x1
     414:	a26080e7          	jalr	-1498(ra) # e36 <wait>
     418:	b329                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     41a:	20200593          	li	a1,514
     41e:	00001517          	auipc	a0,0x1
     422:	00250513          	addi	a0,a0,2 # 1420 <malloc+0x1ca>
     426:	00001097          	auipc	ra,0x1
     42a:	a48080e7          	jalr	-1464(ra) # e6e <open>
     42e:	00001097          	auipc	ra,0x1
     432:	a28080e7          	jalr	-1496(ra) # e56 <close>
        exit(0);
     436:	4501                	li	a0,0
     438:	00001097          	auipc	ra,0x1
     43c:	9f6080e7          	jalr	-1546(ra) # e2e <exit>
        printf("grind: fork failed\n");
     440:	00001517          	auipc	a0,0x1
     444:	00050513          	mv	a0,a0
     448:	00001097          	auipc	ra,0x1
     44c:	d56080e7          	jalr	-682(ra) # 119e <printf>
        exit(1);
     450:	4505                	li	a0,1
     452:	00001097          	auipc	ra,0x1
     456:	9dc080e7          	jalr	-1572(ra) # e2e <exit>
        printf("grind: chdir failed\n");
     45a:	00001517          	auipc	a0,0x1
     45e:	00e50513          	addi	a0,a0,14 # 1468 <malloc+0x212>
     462:	00001097          	auipc	ra,0x1
     466:	d3c080e7          	jalr	-708(ra) # 119e <printf>
        exit(1);
     46a:	4505                	li	a0,1
     46c:	00001097          	auipc	ra,0x1
     470:	9c2080e7          	jalr	-1598(ra) # e2e <exit>
    } else if(what == 18){
      int pid = fork();
     474:	00001097          	auipc	ra,0x1
     478:	9b2080e7          	jalr	-1614(ra) # e26 <fork>
      if(pid == 0){
     47c:	c909                	beqz	a0,48e <go+0x416>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     47e:	02054563          	bltz	a0,4a8 <go+0x430>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     482:	4501                	li	a0,0
     484:	00001097          	auipc	ra,0x1
     488:	9b2080e7          	jalr	-1614(ra) # e36 <wait>
     48c:	b959                	j	122 <go+0xaa>
        kill(getpid());
     48e:	00001097          	auipc	ra,0x1
     492:	a20080e7          	jalr	-1504(ra) # eae <getpid>
     496:	00001097          	auipc	ra,0x1
     49a:	9c8080e7          	jalr	-1592(ra) # e5e <kill>
        exit(0);
     49e:	4501                	li	a0,0
     4a0:	00001097          	auipc	ra,0x1
     4a4:	98e080e7          	jalr	-1650(ra) # e2e <exit>
        printf("grind: fork failed\n");
     4a8:	00001517          	auipc	a0,0x1
     4ac:	f9850513          	addi	a0,a0,-104 # 1440 <malloc+0x1ea>
     4b0:	00001097          	auipc	ra,0x1
     4b4:	cee080e7          	jalr	-786(ra) # 119e <printf>
        exit(1);
     4b8:	4505                	li	a0,1
     4ba:	00001097          	auipc	ra,0x1
     4be:	974080e7          	jalr	-1676(ra) # e2e <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     4c2:	fa840513          	addi	a0,s0,-88
     4c6:	00001097          	auipc	ra,0x1
     4ca:	978080e7          	jalr	-1672(ra) # e3e <pipe>
     4ce:	02054b63          	bltz	a0,504 <go+0x48c>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     4d2:	00001097          	auipc	ra,0x1
     4d6:	954080e7          	jalr	-1708(ra) # e26 <fork>
      if(pid == 0){
     4da:	c131                	beqz	a0,51e <go+0x4a6>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     4dc:	0a054a63          	bltz	a0,590 <go+0x518>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     4e0:	fa842503          	lw	a0,-88(s0)
     4e4:	00001097          	auipc	ra,0x1
     4e8:	972080e7          	jalr	-1678(ra) # e56 <close>
      close(fds[1]);
     4ec:	fac42503          	lw	a0,-84(s0)
     4f0:	00001097          	auipc	ra,0x1
     4f4:	966080e7          	jalr	-1690(ra) # e56 <close>
      wait(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	93c080e7          	jalr	-1732(ra) # e36 <wait>
     502:	b105                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     504:	00001517          	auipc	a0,0x1
     508:	f7c50513          	addi	a0,a0,-132 # 1480 <malloc+0x22a>
     50c:	00001097          	auipc	ra,0x1
     510:	c92080e7          	jalr	-878(ra) # 119e <printf>
        exit(1);
     514:	4505                	li	a0,1
     516:	00001097          	auipc	ra,0x1
     51a:	918080e7          	jalr	-1768(ra) # e2e <exit>
        fork();
     51e:	00001097          	auipc	ra,0x1
     522:	908080e7          	jalr	-1784(ra) # e26 <fork>
        fork();
     526:	00001097          	auipc	ra,0x1
     52a:	900080e7          	jalr	-1792(ra) # e26 <fork>
        if(write(fds[1], "x", 1) != 1)
     52e:	4605                	li	a2,1
     530:	00001597          	auipc	a1,0x1
     534:	f6858593          	addi	a1,a1,-152 # 1498 <malloc+0x242>
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00001097          	auipc	ra,0x1
     540:	912080e7          	jalr	-1774(ra) # e4e <write>
     544:	4785                	li	a5,1
     546:	02f51363          	bne	a0,a5,56c <go+0x4f4>
        if(read(fds[0], &c, 1) != 1)
     54a:	4605                	li	a2,1
     54c:	fa040593          	addi	a1,s0,-96
     550:	fa842503          	lw	a0,-88(s0)
     554:	00001097          	auipc	ra,0x1
     558:	8f2080e7          	jalr	-1806(ra) # e46 <read>
     55c:	4785                	li	a5,1
     55e:	02f51063          	bne	a0,a5,57e <go+0x506>
        exit(0);
     562:	4501                	li	a0,0
     564:	00001097          	auipc	ra,0x1
     568:	8ca080e7          	jalr	-1846(ra) # e2e <exit>
          printf("grind: pipe write failed\n");
     56c:	00001517          	auipc	a0,0x1
     570:	f3450513          	addi	a0,a0,-204 # 14a0 <malloc+0x24a>
     574:	00001097          	auipc	ra,0x1
     578:	c2a080e7          	jalr	-982(ra) # 119e <printf>
     57c:	b7f9                	j	54a <go+0x4d2>
          printf("grind: pipe read failed\n");
     57e:	00001517          	auipc	a0,0x1
     582:	f4250513          	addi	a0,a0,-190 # 14c0 <malloc+0x26a>
     586:	00001097          	auipc	ra,0x1
     58a:	c18080e7          	jalr	-1000(ra) # 119e <printf>
     58e:	bfd1                	j	562 <go+0x4ea>
        printf("grind: fork failed\n");
     590:	00001517          	auipc	a0,0x1
     594:	eb050513          	addi	a0,a0,-336 # 1440 <malloc+0x1ea>
     598:	00001097          	auipc	ra,0x1
     59c:	c06080e7          	jalr	-1018(ra) # 119e <printf>
        exit(1);
     5a0:	4505                	li	a0,1
     5a2:	00001097          	auipc	ra,0x1
     5a6:	88c080e7          	jalr	-1908(ra) # e2e <exit>
    } else if(what == 20){
      int pid = fork();
     5aa:	00001097          	auipc	ra,0x1
     5ae:	87c080e7          	jalr	-1924(ra) # e26 <fork>
      if(pid == 0){
     5b2:	c909                	beqz	a0,5c4 <go+0x54c>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     5b4:	06054f63          	bltz	a0,632 <go+0x5ba>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     5b8:	4501                	li	a0,0
     5ba:	00001097          	auipc	ra,0x1
     5be:	87c080e7          	jalr	-1924(ra) # e36 <wait>
     5c2:	b685                	j	122 <go+0xaa>
        unlink("a");
     5c4:	00001517          	auipc	a0,0x1
     5c8:	e5c50513          	addi	a0,a0,-420 # 1420 <malloc+0x1ca>
     5cc:	00001097          	auipc	ra,0x1
     5d0:	8b2080e7          	jalr	-1870(ra) # e7e <unlink>
        mkdir("a");
     5d4:	00001517          	auipc	a0,0x1
     5d8:	e4c50513          	addi	a0,a0,-436 # 1420 <malloc+0x1ca>
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8ba080e7          	jalr	-1862(ra) # e96 <mkdir>
        chdir("a");
     5e4:	00001517          	auipc	a0,0x1
     5e8:	e3c50513          	addi	a0,a0,-452 # 1420 <malloc+0x1ca>
     5ec:	00001097          	auipc	ra,0x1
     5f0:	8b2080e7          	jalr	-1870(ra) # e9e <chdir>
        unlink("../a");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	d9450513          	addi	a0,a0,-620 # 1388 <malloc+0x132>
     5fc:	00001097          	auipc	ra,0x1
     600:	882080e7          	jalr	-1918(ra) # e7e <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     604:	20200593          	li	a1,514
     608:	00001517          	auipc	a0,0x1
     60c:	e9050513          	addi	a0,a0,-368 # 1498 <malloc+0x242>
     610:	00001097          	auipc	ra,0x1
     614:	85e080e7          	jalr	-1954(ra) # e6e <open>
        unlink("x");
     618:	00001517          	auipc	a0,0x1
     61c:	e8050513          	addi	a0,a0,-384 # 1498 <malloc+0x242>
     620:	00001097          	auipc	ra,0x1
     624:	85e080e7          	jalr	-1954(ra) # e7e <unlink>
        exit(0);
     628:	4501                	li	a0,0
     62a:	00001097          	auipc	ra,0x1
     62e:	804080e7          	jalr	-2044(ra) # e2e <exit>
        printf("grind: fork failed\n");
     632:	00001517          	auipc	a0,0x1
     636:	e0e50513          	addi	a0,a0,-498 # 1440 <malloc+0x1ea>
     63a:	00001097          	auipc	ra,0x1
     63e:	b64080e7          	jalr	-1180(ra) # 119e <printf>
        exit(1);
     642:	4505                	li	a0,1
     644:	00000097          	auipc	ra,0x0
     648:	7ea080e7          	jalr	2026(ra) # e2e <exit>
    } else if(what == 21){
      unlink("c");
     64c:	00001517          	auipc	a0,0x1
     650:	e9450513          	addi	a0,a0,-364 # 14e0 <malloc+0x28a>
     654:	00001097          	auipc	ra,0x1
     658:	82a080e7          	jalr	-2006(ra) # e7e <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     65c:	20200593          	li	a1,514
     660:	00001517          	auipc	a0,0x1
     664:	e8050513          	addi	a0,a0,-384 # 14e0 <malloc+0x28a>
     668:	00001097          	auipc	ra,0x1
     66c:	806080e7          	jalr	-2042(ra) # e6e <open>
     670:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     672:	04054f63          	bltz	a0,6d0 <go+0x658>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     676:	4605                	li	a2,1
     678:	00001597          	auipc	a1,0x1
     67c:	e2058593          	addi	a1,a1,-480 # 1498 <malloc+0x242>
     680:	00000097          	auipc	ra,0x0
     684:	7ce080e7          	jalr	1998(ra) # e4e <write>
     688:	4785                	li	a5,1
     68a:	06f51063          	bne	a0,a5,6ea <go+0x672>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     68e:	fa840593          	addi	a1,s0,-88
     692:	855a                	mv	a0,s6
     694:	00000097          	auipc	ra,0x0
     698:	7f2080e7          	jalr	2034(ra) # e86 <fstat>
     69c:	e525                	bnez	a0,704 <go+0x68c>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     69e:	fb843583          	ld	a1,-72(s0)
     6a2:	4785                	li	a5,1
     6a4:	06f59d63          	bne	a1,a5,71e <go+0x6a6>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     6a8:	fac42583          	lw	a1,-84(s0)
     6ac:	0c800793          	li	a5,200
     6b0:	08b7e563          	bltu	a5,a1,73a <go+0x6c2>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     6b4:	855a                	mv	a0,s6
     6b6:	00000097          	auipc	ra,0x0
     6ba:	7a0080e7          	jalr	1952(ra) # e56 <close>
      unlink("c");
     6be:	00001517          	auipc	a0,0x1
     6c2:	e2250513          	addi	a0,a0,-478 # 14e0 <malloc+0x28a>
     6c6:	00000097          	auipc	ra,0x0
     6ca:	7b8080e7          	jalr	1976(ra) # e7e <unlink>
     6ce:	bc91                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     6d0:	00001517          	auipc	a0,0x1
     6d4:	e1850513          	addi	a0,a0,-488 # 14e8 <malloc+0x292>
     6d8:	00001097          	auipc	ra,0x1
     6dc:	ac6080e7          	jalr	-1338(ra) # 119e <printf>
        exit(1);
     6e0:	4505                	li	a0,1
     6e2:	00000097          	auipc	ra,0x0
     6e6:	74c080e7          	jalr	1868(ra) # e2e <exit>
        printf("grind: write c failed\n");
     6ea:	00001517          	auipc	a0,0x1
     6ee:	e1650513          	addi	a0,a0,-490 # 1500 <malloc+0x2aa>
     6f2:	00001097          	auipc	ra,0x1
     6f6:	aac080e7          	jalr	-1364(ra) # 119e <printf>
        exit(1);
     6fa:	4505                	li	a0,1
     6fc:	00000097          	auipc	ra,0x0
     700:	732080e7          	jalr	1842(ra) # e2e <exit>
        printf("grind: fstat failed\n");
     704:	00001517          	auipc	a0,0x1
     708:	e1450513          	addi	a0,a0,-492 # 1518 <malloc+0x2c2>
     70c:	00001097          	auipc	ra,0x1
     710:	a92080e7          	jalr	-1390(ra) # 119e <printf>
        exit(1);
     714:	4505                	li	a0,1
     716:	00000097          	auipc	ra,0x0
     71a:	718080e7          	jalr	1816(ra) # e2e <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     71e:	2581                	sext.w	a1,a1
     720:	00001517          	auipc	a0,0x1
     724:	e1050513          	addi	a0,a0,-496 # 1530 <malloc+0x2da>
     728:	00001097          	auipc	ra,0x1
     72c:	a76080e7          	jalr	-1418(ra) # 119e <printf>
        exit(1);
     730:	4505                	li	a0,1
     732:	00000097          	auipc	ra,0x0
     736:	6fc080e7          	jalr	1788(ra) # e2e <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     73a:	00001517          	auipc	a0,0x1
     73e:	e1e50513          	addi	a0,a0,-482 # 1558 <malloc+0x302>
     742:	00001097          	auipc	ra,0x1
     746:	a5c080e7          	jalr	-1444(ra) # 119e <printf>
        exit(1);
     74a:	4505                	li	a0,1
     74c:	00000097          	auipc	ra,0x0
     750:	6e2080e7          	jalr	1762(ra) # e2e <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     754:	f9840513          	addi	a0,s0,-104
     758:	00000097          	auipc	ra,0x0
     75c:	6e6080e7          	jalr	1766(ra) # e3e <pipe>
     760:	10054063          	bltz	a0,860 <go+0x7e8>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     764:	fa040513          	addi	a0,s0,-96
     768:	00000097          	auipc	ra,0x0
     76c:	6d6080e7          	jalr	1750(ra) # e3e <pipe>
     770:	10054663          	bltz	a0,87c <go+0x804>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     774:	00000097          	auipc	ra,0x0
     778:	6b2080e7          	jalr	1714(ra) # e26 <fork>
      if(pid1 == 0){
     77c:	10050e63          	beqz	a0,898 <go+0x820>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     780:	1c054663          	bltz	a0,94c <go+0x8d4>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     784:	00000097          	auipc	ra,0x0
     788:	6a2080e7          	jalr	1698(ra) # e26 <fork>
      if(pid2 == 0){
     78c:	1c050e63          	beqz	a0,968 <go+0x8f0>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     790:	2a054a63          	bltz	a0,a44 <go+0x9cc>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     794:	f9842503          	lw	a0,-104(s0)
     798:	00000097          	auipc	ra,0x0
     79c:	6be080e7          	jalr	1726(ra) # e56 <close>
      close(aa[1]);
     7a0:	f9c42503          	lw	a0,-100(s0)
     7a4:	00000097          	auipc	ra,0x0
     7a8:	6b2080e7          	jalr	1714(ra) # e56 <close>
      close(bb[1]);
     7ac:	fa442503          	lw	a0,-92(s0)
     7b0:	00000097          	auipc	ra,0x0
     7b4:	6a6080e7          	jalr	1702(ra) # e56 <close>
      char buf[4] = { 0, 0, 0, 0 };
     7b8:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     7bc:	4605                	li	a2,1
     7be:	f9040593          	addi	a1,s0,-112
     7c2:	fa042503          	lw	a0,-96(s0)
     7c6:	00000097          	auipc	ra,0x0
     7ca:	680080e7          	jalr	1664(ra) # e46 <read>
      read(bb[0], buf+1, 1);
     7ce:	4605                	li	a2,1
     7d0:	f9140593          	addi	a1,s0,-111
     7d4:	fa042503          	lw	a0,-96(s0)
     7d8:	00000097          	auipc	ra,0x0
     7dc:	66e080e7          	jalr	1646(ra) # e46 <read>
      read(bb[0], buf+2, 1);
     7e0:	4605                	li	a2,1
     7e2:	f9240593          	addi	a1,s0,-110
     7e6:	fa042503          	lw	a0,-96(s0)
     7ea:	00000097          	auipc	ra,0x0
     7ee:	65c080e7          	jalr	1628(ra) # e46 <read>
      close(bb[0]);
     7f2:	fa042503          	lw	a0,-96(s0)
     7f6:	00000097          	auipc	ra,0x0
     7fa:	660080e7          	jalr	1632(ra) # e56 <close>
      int st1, st2;
      wait(&st1);
     7fe:	f9440513          	addi	a0,s0,-108
     802:	00000097          	auipc	ra,0x0
     806:	634080e7          	jalr	1588(ra) # e36 <wait>
      wait(&st2);
     80a:	fa840513          	addi	a0,s0,-88
     80e:	00000097          	auipc	ra,0x0
     812:	628080e7          	jalr	1576(ra) # e36 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
<<<<<<< HEAD
     290:	f9442783          	lw	a5,-108(s0)
     294:	fa842703          	lw	a4,-88(s0)
     298:	8fd9                	or	a5,a5,a4
     29a:	2781                	sext.w	a5,a5
     29c:	ef89                	bnez	a5,2b6 <go+0x23e>
     29e:	00001597          	auipc	a1,0x1
     2a2:	3da58593          	addi	a1,a1,986 # 1678 <malloc+0x3a6>
     2a6:	f9040513          	addi	a0,s0,-112
     2aa:	00001097          	auipc	ra,0x1
     2ae:	998080e7          	jalr	-1640(ra) # c42 <strcmp>
     2b2:	e60508e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2b6:	f9040693          	addi	a3,s0,-112
     2ba:	fa842603          	lw	a2,-88(s0)
     2be:	f9442583          	lw	a1,-108(s0)
     2c2:	00001517          	auipc	a0,0x1
     2c6:	3be50513          	addi	a0,a0,958 # 1680 <malloc+0x3ae>
     2ca:	00001097          	auipc	ra,0x1
     2ce:	f4a080e7          	jalr	-182(ra) # 1214 <printf>
        exit(1);
     2d2:	4505                	li	a0,1
     2d4:	00001097          	auipc	ra,0x1
     2d8:	bc0080e7          	jalr	-1088(ra) # e94 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2dc:	20200593          	li	a1,514
     2e0:	00001517          	auipc	a0,0x1
     2e4:	13050513          	addi	a0,a0,304 # 1410 <malloc+0x13e>
     2e8:	00001097          	auipc	ra,0x1
     2ec:	bec080e7          	jalr	-1044(ra) # ed4 <open>
     2f0:	00001097          	auipc	ra,0x1
     2f4:	bcc080e7          	jalr	-1076(ra) # ebc <close>
     2f8:	b52d                	j	122 <go+0xaa>
      unlink("grindir/../a");
     2fa:	00001517          	auipc	a0,0x1
     2fe:	10650513          	addi	a0,a0,262 # 1400 <malloc+0x12e>
     302:	00001097          	auipc	ra,0x1
     306:	be2080e7          	jalr	-1054(ra) # ee4 <unlink>
     30a:	bd21                	j	122 <go+0xaa>
      if(chdir("grindir") != 0){
     30c:	00001517          	auipc	a0,0x1
     310:	0b450513          	addi	a0,a0,180 # 13c0 <malloc+0xee>
     314:	00001097          	auipc	ra,0x1
     318:	bf0080e7          	jalr	-1040(ra) # f04 <chdir>
     31c:	e115                	bnez	a0,340 <go+0x2c8>
      unlink("../b");
     31e:	00001517          	auipc	a0,0x1
     322:	10a50513          	addi	a0,a0,266 # 1428 <malloc+0x156>
     326:	00001097          	auipc	ra,0x1
     32a:	bbe080e7          	jalr	-1090(ra) # ee4 <unlink>
      chdir("/");
     32e:	00001517          	auipc	a0,0x1
     332:	0ba50513          	addi	a0,a0,186 # 13e8 <malloc+0x116>
     336:	00001097          	auipc	ra,0x1
     33a:	bce080e7          	jalr	-1074(ra) # f04 <chdir>
     33e:	b3d5                	j	122 <go+0xaa>
        printf("grind: chdir grindir failed\n");
     340:	00001517          	auipc	a0,0x1
     344:	08850513          	addi	a0,a0,136 # 13c8 <malloc+0xf6>
     348:	00001097          	auipc	ra,0x1
     34c:	ecc080e7          	jalr	-308(ra) # 1214 <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00001097          	auipc	ra,0x1
     356:	b42080e7          	jalr	-1214(ra) # e94 <exit>
      close(fd);
     35a:	854a                	mv	a0,s2
     35c:	00001097          	auipc	ra,0x1
     360:	b60080e7          	jalr	-1184(ra) # ebc <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     364:	20200593          	li	a1,514
     368:	00001517          	auipc	a0,0x1
     36c:	0c850513          	addi	a0,a0,200 # 1430 <malloc+0x15e>
     370:	00001097          	auipc	ra,0x1
     374:	b64080e7          	jalr	-1180(ra) # ed4 <open>
     378:	892a                	mv	s2,a0
     37a:	b365                	j	122 <go+0xaa>
      close(fd);
     37c:	854a                	mv	a0,s2
     37e:	00001097          	auipc	ra,0x1
     382:	b3e080e7          	jalr	-1218(ra) # ebc <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     386:	20200593          	li	a1,514
     38a:	00001517          	auipc	a0,0x1
     38e:	0b650513          	addi	a0,a0,182 # 1440 <malloc+0x16e>
     392:	00001097          	auipc	ra,0x1
     396:	b42080e7          	jalr	-1214(ra) # ed4 <open>
     39a:	892a                	mv	s2,a0
     39c:	b359                	j	122 <go+0xaa>
      write(fd, buf, sizeof(buf));
     39e:	3e700613          	li	a2,999
     3a2:	85d2                	mv	a1,s4
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	b0e080e7          	jalr	-1266(ra) # eb4 <write>
     3ae:	bb95                	j	122 <go+0xaa>
      read(fd, buf, sizeof(buf));
     3b0:	3e700613          	li	a2,999
     3b4:	85d2                	mv	a1,s4
     3b6:	854a                	mv	a0,s2
     3b8:	00001097          	auipc	ra,0x1
     3bc:	af4080e7          	jalr	-1292(ra) # eac <read>
     3c0:	b38d                	j	122 <go+0xaa>
      mkdir("grindir/../a");
     3c2:	00001517          	auipc	a0,0x1
     3c6:	03e50513          	addi	a0,a0,62 # 1400 <malloc+0x12e>
     3ca:	00001097          	auipc	ra,0x1
     3ce:	b32080e7          	jalr	-1230(ra) # efc <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3d2:	20200593          	li	a1,514
     3d6:	00001517          	auipc	a0,0x1
     3da:	08250513          	addi	a0,a0,130 # 1458 <malloc+0x186>
     3de:	00001097          	auipc	ra,0x1
     3e2:	af6080e7          	jalr	-1290(ra) # ed4 <open>
     3e6:	00001097          	auipc	ra,0x1
     3ea:	ad6080e7          	jalr	-1322(ra) # ebc <close>
      unlink("a/a");
     3ee:	00001517          	auipc	a0,0x1
     3f2:	07a50513          	addi	a0,a0,122 # 1468 <malloc+0x196>
     3f6:	00001097          	auipc	ra,0x1
     3fa:	aee080e7          	jalr	-1298(ra) # ee4 <unlink>
     3fe:	b315                	j	122 <go+0xaa>
      mkdir("/../b");
     400:	00001517          	auipc	a0,0x1
     404:	07050513          	addi	a0,a0,112 # 1470 <malloc+0x19e>
     408:	00001097          	auipc	ra,0x1
     40c:	af4080e7          	jalr	-1292(ra) # efc <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     410:	20200593          	li	a1,514
     414:	00001517          	auipc	a0,0x1
     418:	06450513          	addi	a0,a0,100 # 1478 <malloc+0x1a6>
     41c:	00001097          	auipc	ra,0x1
     420:	ab8080e7          	jalr	-1352(ra) # ed4 <open>
     424:	00001097          	auipc	ra,0x1
     428:	a98080e7          	jalr	-1384(ra) # ebc <close>
      unlink("b/b");
     42c:	00001517          	auipc	a0,0x1
     430:	05c50513          	addi	a0,a0,92 # 1488 <malloc+0x1b6>
     434:	00001097          	auipc	ra,0x1
     438:	ab0080e7          	jalr	-1360(ra) # ee4 <unlink>
     43c:	b1dd                	j	122 <go+0xaa>
      unlink("b");
     43e:	00001517          	auipc	a0,0x1
     442:	01250513          	addi	a0,a0,18 # 1450 <malloc+0x17e>
     446:	00001097          	auipc	ra,0x1
     44a:	a9e080e7          	jalr	-1378(ra) # ee4 <unlink>
      link("../grindir/./../a", "../b");
     44e:	00001597          	auipc	a1,0x1
     452:	fda58593          	addi	a1,a1,-38 # 1428 <malloc+0x156>
     456:	00001517          	auipc	a0,0x1
     45a:	03a50513          	addi	a0,a0,58 # 1490 <malloc+0x1be>
     45e:	00001097          	auipc	ra,0x1
     462:	a96080e7          	jalr	-1386(ra) # ef4 <link>
     466:	b975                	j	122 <go+0xaa>
      unlink("../grindir/../a");
     468:	00001517          	auipc	a0,0x1
     46c:	04050513          	addi	a0,a0,64 # 14a8 <malloc+0x1d6>
     470:	00001097          	auipc	ra,0x1
     474:	a74080e7          	jalr	-1420(ra) # ee4 <unlink>
      link(".././b", "/grindir/../a");
     478:	00001597          	auipc	a1,0x1
     47c:	fb858593          	addi	a1,a1,-72 # 1430 <malloc+0x15e>
     480:	00001517          	auipc	a0,0x1
     484:	03850513          	addi	a0,a0,56 # 14b8 <malloc+0x1e6>
     488:	00001097          	auipc	ra,0x1
     48c:	a6c080e7          	jalr	-1428(ra) # ef4 <link>
     490:	b949                	j	122 <go+0xaa>
      int pid = fork();
     492:	00001097          	auipc	ra,0x1
     496:	9fa080e7          	jalr	-1542(ra) # e8c <fork>
      if(pid == 0){
     49a:	c909                	beqz	a0,4ac <go+0x434>
      } else if(pid < 0){
     49c:	00054c63          	bltz	a0,4b4 <go+0x43c>
      wait(0);
     4a0:	4501                	li	a0,0
     4a2:	00001097          	auipc	ra,0x1
     4a6:	9fa080e7          	jalr	-1542(ra) # e9c <wait>
     4aa:	b9a5                	j	122 <go+0xaa>
        exit(0);
     4ac:	00001097          	auipc	ra,0x1
     4b0:	9e8080e7          	jalr	-1560(ra) # e94 <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	00c50513          	addi	a0,a0,12 # 14c0 <malloc+0x1ee>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	d58080e7          	jalr	-680(ra) # 1214 <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	9ce080e7          	jalr	-1586(ra) # e94 <exit>
      int pid = fork();
     4ce:	00001097          	auipc	ra,0x1
     4d2:	9be080e7          	jalr	-1602(ra) # e8c <fork>
      if(pid == 0){
     4d6:	c909                	beqz	a0,4e8 <go+0x470>
      } else if(pid < 0){
     4d8:	02054563          	bltz	a0,502 <go+0x48a>
      wait(0);
     4dc:	4501                	li	a0,0
     4de:	00001097          	auipc	ra,0x1
     4e2:	9be080e7          	jalr	-1602(ra) # e9c <wait>
     4e6:	b935                	j	122 <go+0xaa>
        fork();
     4e8:	00001097          	auipc	ra,0x1
     4ec:	9a4080e7          	jalr	-1628(ra) # e8c <fork>
        fork();
     4f0:	00001097          	auipc	ra,0x1
     4f4:	99c080e7          	jalr	-1636(ra) # e8c <fork>
        exit(0);
     4f8:	4501                	li	a0,0
     4fa:	00001097          	auipc	ra,0x1
     4fe:	99a080e7          	jalr	-1638(ra) # e94 <exit>
        printf("grind: fork failed\n");
     502:	00001517          	auipc	a0,0x1
     506:	fbe50513          	addi	a0,a0,-66 # 14c0 <malloc+0x1ee>
     50a:	00001097          	auipc	ra,0x1
     50e:	d0a080e7          	jalr	-758(ra) # 1214 <printf>
        exit(1);
     512:	4505                	li	a0,1
     514:	00001097          	auipc	ra,0x1
     518:	980080e7          	jalr	-1664(ra) # e94 <exit>
      sbrk(6011);
     51c:	6505                	lui	a0,0x1
     51e:	77b50513          	addi	a0,a0,1915 # 177b <digits+0xcb>
     522:	00001097          	auipc	ra,0x1
     526:	9fa080e7          	jalr	-1542(ra) # f1c <sbrk>
     52a:	bee5                	j	122 <go+0xaa>
      if(sbrk(0) > break0)
     52c:	4501                	li	a0,0
     52e:	00001097          	auipc	ra,0x1
     532:	9ee080e7          	jalr	-1554(ra) # f1c <sbrk>
     536:	beaaf6e3          	bgeu	s5,a0,122 <go+0xaa>
        sbrk(-(sbrk(0) - break0));
     53a:	4501                	li	a0,0
     53c:	00001097          	auipc	ra,0x1
     540:	9e0080e7          	jalr	-1568(ra) # f1c <sbrk>
     544:	40aa853b          	subw	a0,s5,a0
     548:	00001097          	auipc	ra,0x1
     54c:	9d4080e7          	jalr	-1580(ra) # f1c <sbrk>
     550:	bec9                	j	122 <go+0xaa>
      int pid = fork();
     552:	00001097          	auipc	ra,0x1
     556:	93a080e7          	jalr	-1734(ra) # e8c <fork>
     55a:	8b2a                	mv	s6,a0
      if(pid == 0){
     55c:	c51d                	beqz	a0,58a <go+0x512>
      } else if(pid < 0){
     55e:	04054963          	bltz	a0,5b0 <go+0x538>
      if(chdir("../grindir/..") != 0){
     562:	00001517          	auipc	a0,0x1
     566:	f7650513          	addi	a0,a0,-138 # 14d8 <malloc+0x206>
     56a:	00001097          	auipc	ra,0x1
     56e:	99a080e7          	jalr	-1638(ra) # f04 <chdir>
     572:	ed21                	bnez	a0,5ca <go+0x552>
      kill(pid);
     574:	855a                	mv	a0,s6
     576:	00001097          	auipc	ra,0x1
     57a:	94e080e7          	jalr	-1714(ra) # ec4 <kill>
      wait(0);
     57e:	4501                	li	a0,0
     580:	00001097          	auipc	ra,0x1
     584:	91c080e7          	jalr	-1764(ra) # e9c <wait>
     588:	be69                	j	122 <go+0xaa>
        close(open("a", O_CREATE|O_RDWR));
     58a:	20200593          	li	a1,514
     58e:	00001517          	auipc	a0,0x1
     592:	f1250513          	addi	a0,a0,-238 # 14a0 <malloc+0x1ce>
     596:	00001097          	auipc	ra,0x1
     59a:	93e080e7          	jalr	-1730(ra) # ed4 <open>
     59e:	00001097          	auipc	ra,0x1
     5a2:	91e080e7          	jalr	-1762(ra) # ebc <close>
        exit(0);
     5a6:	4501                	li	a0,0
     5a8:	00001097          	auipc	ra,0x1
     5ac:	8ec080e7          	jalr	-1812(ra) # e94 <exit>
        printf("grind: fork failed\n");
     5b0:	00001517          	auipc	a0,0x1
     5b4:	f1050513          	addi	a0,a0,-240 # 14c0 <malloc+0x1ee>
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c5c080e7          	jalr	-932(ra) # 1214 <printf>
        exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00001097          	auipc	ra,0x1
     5c6:	8d2080e7          	jalr	-1838(ra) # e94 <exit>
        printf("grind: chdir failed\n");
     5ca:	00001517          	auipc	a0,0x1
     5ce:	f1e50513          	addi	a0,a0,-226 # 14e8 <malloc+0x216>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	c42080e7          	jalr	-958(ra) # 1214 <printf>
        exit(1);
     5da:	4505                	li	a0,1
     5dc:	00001097          	auipc	ra,0x1
     5e0:	8b8080e7          	jalr	-1864(ra) # e94 <exit>
      int pid = fork();
     5e4:	00001097          	auipc	ra,0x1
     5e8:	8a8080e7          	jalr	-1880(ra) # e8c <fork>
      if(pid == 0){
     5ec:	c909                	beqz	a0,5fe <go+0x586>
      } else if(pid < 0){
     5ee:	02054563          	bltz	a0,618 <go+0x5a0>
      wait(0);
     5f2:	4501                	li	a0,0
     5f4:	00001097          	auipc	ra,0x1
     5f8:	8a8080e7          	jalr	-1880(ra) # e9c <wait>
     5fc:	b61d                	j	122 <go+0xaa>
        kill(getpid());
     5fe:	00001097          	auipc	ra,0x1
     602:	916080e7          	jalr	-1770(ra) # f14 <getpid>
     606:	00001097          	auipc	ra,0x1
     60a:	8be080e7          	jalr	-1858(ra) # ec4 <kill>
        exit(0);
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	884080e7          	jalr	-1916(ra) # e94 <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	ea850513          	addi	a0,a0,-344 # 14c0 <malloc+0x1ee>
     620:	00001097          	auipc	ra,0x1
     624:	bf4080e7          	jalr	-1036(ra) # 1214 <printf>
        exit(1);
     628:	4505                	li	a0,1
     62a:	00001097          	auipc	ra,0x1
     62e:	86a080e7          	jalr	-1942(ra) # e94 <exit>
      if(pipe(fds) < 0){
     632:	fa840513          	addi	a0,s0,-88
     636:	00001097          	auipc	ra,0x1
     63a:	86e080e7          	jalr	-1938(ra) # ea4 <pipe>
     63e:	02054b63          	bltz	a0,674 <go+0x5fc>
      int pid = fork();
     642:	00001097          	auipc	ra,0x1
     646:	84a080e7          	jalr	-1974(ra) # e8c <fork>
      if(pid == 0){
     64a:	c131                	beqz	a0,68e <go+0x616>
      } else if(pid < 0){
     64c:	0a054a63          	bltz	a0,700 <go+0x688>
      close(fds[0]);
     650:	fa842503          	lw	a0,-88(s0)
     654:	00001097          	auipc	ra,0x1
     658:	868080e7          	jalr	-1944(ra) # ebc <close>
      close(fds[1]);
     65c:	fac42503          	lw	a0,-84(s0)
     660:	00001097          	auipc	ra,0x1
     664:	85c080e7          	jalr	-1956(ra) # ebc <close>
      wait(0);
     668:	4501                	li	a0,0
     66a:	00001097          	auipc	ra,0x1
     66e:	832080e7          	jalr	-1998(ra) # e9c <wait>
     672:	bc45                	j	122 <go+0xaa>
        printf("grind: pipe failed\n");
     674:	00001517          	auipc	a0,0x1
     678:	e8c50513          	addi	a0,a0,-372 # 1500 <malloc+0x22e>
     67c:	00001097          	auipc	ra,0x1
     680:	b98080e7          	jalr	-1128(ra) # 1214 <printf>
        exit(1);
     684:	4505                	li	a0,1
     686:	00001097          	auipc	ra,0x1
     68a:	80e080e7          	jalr	-2034(ra) # e94 <exit>
        fork();
     68e:	00000097          	auipc	ra,0x0
     692:	7fe080e7          	jalr	2046(ra) # e8c <fork>
        fork();
     696:	00000097          	auipc	ra,0x0
     69a:	7f6080e7          	jalr	2038(ra) # e8c <fork>
        if(write(fds[1], "x", 1) != 1)
     69e:	4605                	li	a2,1
     6a0:	00001597          	auipc	a1,0x1
     6a4:	e7858593          	addi	a1,a1,-392 # 1518 <malloc+0x246>
     6a8:	fac42503          	lw	a0,-84(s0)
     6ac:	00001097          	auipc	ra,0x1
     6b0:	808080e7          	jalr	-2040(ra) # eb4 <write>
     6b4:	4785                	li	a5,1
     6b6:	02f51363          	bne	a0,a5,6dc <go+0x664>
        if(read(fds[0], &c, 1) != 1)
     6ba:	4605                	li	a2,1
     6bc:	fa040593          	addi	a1,s0,-96
     6c0:	fa842503          	lw	a0,-88(s0)
     6c4:	00000097          	auipc	ra,0x0
     6c8:	7e8080e7          	jalr	2024(ra) # eac <read>
     6cc:	4785                	li	a5,1
     6ce:	02f51063          	bne	a0,a5,6ee <go+0x676>
        exit(0);
     6d2:	4501                	li	a0,0
     6d4:	00000097          	auipc	ra,0x0
     6d8:	7c0080e7          	jalr	1984(ra) # e94 <exit>
          printf("grind: pipe write failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e4450513          	addi	a0,a0,-444 # 1520 <malloc+0x24e>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	b30080e7          	jalr	-1232(ra) # 1214 <printf>
     6ec:	b7f9                	j	6ba <go+0x642>
          printf("grind: pipe read failed\n");
     6ee:	00001517          	auipc	a0,0x1
     6f2:	e5250513          	addi	a0,a0,-430 # 1540 <malloc+0x26e>
     6f6:	00001097          	auipc	ra,0x1
     6fa:	b1e080e7          	jalr	-1250(ra) # 1214 <printf>
     6fe:	bfd1                	j	6d2 <go+0x65a>
        printf("grind: fork failed\n");
     700:	00001517          	auipc	a0,0x1
     704:	dc050513          	addi	a0,a0,-576 # 14c0 <malloc+0x1ee>
     708:	00001097          	auipc	ra,0x1
     70c:	b0c080e7          	jalr	-1268(ra) # 1214 <printf>
        exit(1);
     710:	4505                	li	a0,1
     712:	00000097          	auipc	ra,0x0
     716:	782080e7          	jalr	1922(ra) # e94 <exit>
      int pid = fork();
     71a:	00000097          	auipc	ra,0x0
     71e:	772080e7          	jalr	1906(ra) # e8c <fork>
      if(pid == 0){
     722:	c909                	beqz	a0,734 <go+0x6bc>
      } else if(pid < 0){
     724:	06054f63          	bltz	a0,7a2 <go+0x72a>
      wait(0);
     728:	4501                	li	a0,0
     72a:	00000097          	auipc	ra,0x0
     72e:	772080e7          	jalr	1906(ra) # e9c <wait>
     732:	bac5                	j	122 <go+0xaa>
        unlink("a");
     734:	00001517          	auipc	a0,0x1
     738:	d6c50513          	addi	a0,a0,-660 # 14a0 <malloc+0x1ce>
     73c:	00000097          	auipc	ra,0x0
     740:	7a8080e7          	jalr	1960(ra) # ee4 <unlink>
        mkdir("a");
     744:	00001517          	auipc	a0,0x1
     748:	d5c50513          	addi	a0,a0,-676 # 14a0 <malloc+0x1ce>
     74c:	00000097          	auipc	ra,0x0
     750:	7b0080e7          	jalr	1968(ra) # efc <mkdir>
        chdir("a");
     754:	00001517          	auipc	a0,0x1
     758:	d4c50513          	addi	a0,a0,-692 # 14a0 <malloc+0x1ce>
     75c:	00000097          	auipc	ra,0x0
     760:	7a8080e7          	jalr	1960(ra) # f04 <chdir>
        unlink("../a");
     764:	00001517          	auipc	a0,0x1
     768:	ca450513          	addi	a0,a0,-860 # 1408 <malloc+0x136>
     76c:	00000097          	auipc	ra,0x0
     770:	778080e7          	jalr	1912(ra) # ee4 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     774:	20200593          	li	a1,514
     778:	00001517          	auipc	a0,0x1
     77c:	da050513          	addi	a0,a0,-608 # 1518 <malloc+0x246>
     780:	00000097          	auipc	ra,0x0
     784:	754080e7          	jalr	1876(ra) # ed4 <open>
        unlink("x");
     788:	00001517          	auipc	a0,0x1
     78c:	d9050513          	addi	a0,a0,-624 # 1518 <malloc+0x246>
     790:	00000097          	auipc	ra,0x0
     794:	754080e7          	jalr	1876(ra) # ee4 <unlink>
        exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	6fa080e7          	jalr	1786(ra) # e94 <exit>
        printf("grind: fork failed\n");
     7a2:	00001517          	auipc	a0,0x1
     7a6:	d1e50513          	addi	a0,a0,-738 # 14c0 <malloc+0x1ee>
     7aa:	00001097          	auipc	ra,0x1
     7ae:	a6a080e7          	jalr	-1430(ra) # 1214 <printf>
        exit(1);
     7b2:	4505                	li	a0,1
     7b4:	00000097          	auipc	ra,0x0
     7b8:	6e0080e7          	jalr	1760(ra) # e94 <exit>
      unlink("c");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	da450513          	addi	a0,a0,-604 # 1560 <malloc+0x28e>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	720080e7          	jalr	1824(ra) # ee4 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     7cc:	20200593          	li	a1,514
     7d0:	00001517          	auipc	a0,0x1
     7d4:	d9050513          	addi	a0,a0,-624 # 1560 <malloc+0x28e>
     7d8:	00000097          	auipc	ra,0x0
     7dc:	6fc080e7          	jalr	1788(ra) # ed4 <open>
     7e0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     7e2:	04054f63          	bltz	a0,840 <go+0x7c8>
      if(write(fd1, "x", 1) != 1){
     7e6:	4605                	li	a2,1
     7e8:	00001597          	auipc	a1,0x1
     7ec:	d3058593          	addi	a1,a1,-720 # 1518 <malloc+0x246>
     7f0:	00000097          	auipc	ra,0x0
     7f4:	6c4080e7          	jalr	1732(ra) # eb4 <write>
     7f8:	4785                	li	a5,1
     7fa:	06f51063          	bne	a0,a5,85a <go+0x7e2>
      if(fstat(fd1, &st) != 0){
     7fe:	fa840593          	addi	a1,s0,-88
     802:	855a                	mv	a0,s6
     804:	00000097          	auipc	ra,0x0
     808:	6e8080e7          	jalr	1768(ra) # eec <fstat>
     80c:	e525                	bnez	a0,874 <go+0x7fc>
      if(st.size != 1){
     80e:	fb843583          	ld	a1,-72(s0)
     812:	4785                	li	a5,1
     814:	06f59d63          	bne	a1,a5,88e <go+0x816>
      if(st.ino > 200){
     818:	fac42583          	lw	a1,-84(s0)
     81c:	0c800793          	li	a5,200
     820:	08b7e563          	bltu	a5,a1,8aa <go+0x832>
      close(fd1);
     824:	855a                	mv	a0,s6
     826:	00000097          	auipc	ra,0x0
     82a:	696080e7          	jalr	1686(ra) # ebc <close>
      unlink("c");
     82e:	00001517          	auipc	a0,0x1
     832:	d3250513          	addi	a0,a0,-718 # 1560 <malloc+0x28e>
     836:	00000097          	auipc	ra,0x0
     83a:	6ae080e7          	jalr	1710(ra) # ee4 <unlink>
     83e:	b0d5                	j	122 <go+0xaa>
        printf("grind: create c failed\n");
     840:	00001517          	auipc	a0,0x1
     844:	d2850513          	addi	a0,a0,-728 # 1568 <malloc+0x296>
     848:	00001097          	auipc	ra,0x1
     84c:	9cc080e7          	jalr	-1588(ra) # 1214 <printf>
        exit(1);
     850:	4505                	li	a0,1
     852:	00000097          	auipc	ra,0x0
     856:	642080e7          	jalr	1602(ra) # e94 <exit>
        printf("grind: write c failed\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	d2650513          	addi	a0,a0,-730 # 1580 <malloc+0x2ae>
     862:	00001097          	auipc	ra,0x1
     866:	9b2080e7          	jalr	-1614(ra) # 1214 <printf>
        exit(1);
     86a:	4505                	li	a0,1
     86c:	00000097          	auipc	ra,0x0
     870:	628080e7          	jalr	1576(ra) # e94 <exit>
        printf("grind: fstat failed\n");
     874:	00001517          	auipc	a0,0x1
     878:	d2450513          	addi	a0,a0,-732 # 1598 <malloc+0x2c6>
     87c:	00001097          	auipc	ra,0x1
     880:	998080e7          	jalr	-1640(ra) # 1214 <printf>
        exit(1);
     884:	4505                	li	a0,1
     886:	00000097          	auipc	ra,0x0
     88a:	60e080e7          	jalr	1550(ra) # e94 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     88e:	2581                	sext.w	a1,a1
     890:	00001517          	auipc	a0,0x1
     894:	d2050513          	addi	a0,a0,-736 # 15b0 <malloc+0x2de>
     898:	00001097          	auipc	ra,0x1
     89c:	97c080e7          	jalr	-1668(ra) # 1214 <printf>
        exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00000097          	auipc	ra,0x0
     8a6:	5f2080e7          	jalr	1522(ra) # e94 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     8aa:	00001517          	auipc	a0,0x1
     8ae:	d2e50513          	addi	a0,a0,-722 # 15d8 <malloc+0x306>
     8b2:	00001097          	auipc	ra,0x1
     8b6:	962080e7          	jalr	-1694(ra) # 1214 <printf>
        exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00000097          	auipc	ra,0x0
     8c0:	5d8080e7          	jalr	1496(ra) # e94 <exit>
        fprintf(2, "grind: pipe failed\n");
     8c4:	00001597          	auipc	a1,0x1
     8c8:	c3c58593          	addi	a1,a1,-964 # 1500 <malloc+0x22e>
     8cc:	4509                	li	a0,2
     8ce:	00001097          	auipc	ra,0x1
     8d2:	918080e7          	jalr	-1768(ra) # 11e6 <fprintf>
=======
     816:	f9442783          	lw	a5,-108(s0)
     81a:	fa842703          	lw	a4,-88(s0)
     81e:	8fd9                	or	a5,a5,a4
     820:	ef89                	bnez	a5,83a <go+0x7c2>
     822:	00001597          	auipc	a1,0x1
     826:	dd658593          	addi	a1,a1,-554 # 15f8 <malloc+0x3a2>
     82a:	f9040513          	addi	a0,s0,-112
     82e:	00000097          	auipc	ra,0x0
     832:	3b0080e7          	jalr	944(ra) # bde <strcmp>
     836:	8e0506e3          	beqz	a0,122 <go+0xaa>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     83a:	f9040693          	addi	a3,s0,-112
     83e:	fa842603          	lw	a2,-88(s0)
     842:	f9442583          	lw	a1,-108(s0)
     846:	00001517          	auipc	a0,0x1
     84a:	dba50513          	addi	a0,a0,-582 # 1600 <malloc+0x3aa>
     84e:	00001097          	auipc	ra,0x1
     852:	950080e7          	jalr	-1712(ra) # 119e <printf>
        exit(1);
     856:	4505                	li	a0,1
     858:	00000097          	auipc	ra,0x0
     85c:	5d6080e7          	jalr	1494(ra) # e2e <exit>
        fprintf(2, "grind: pipe failed\n");
     860:	00001597          	auipc	a1,0x1
     864:	c2058593          	addi	a1,a1,-992 # 1480 <malloc+0x22a>
     868:	4509                	li	a0,2
     86a:	00001097          	auipc	ra,0x1
     86e:	906080e7          	jalr	-1786(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
     872:	4505                	li	a0,1
     874:	00000097          	auipc	ra,0x0
     878:	5ba080e7          	jalr	1466(ra) # e2e <exit>
        fprintf(2, "grind: pipe failed\n");
<<<<<<< HEAD
     8e0:	00001597          	auipc	a1,0x1
     8e4:	c2058593          	addi	a1,a1,-992 # 1500 <malloc+0x22e>
     8e8:	4509                	li	a0,2
     8ea:	00001097          	auipc	ra,0x1
     8ee:	8fc080e7          	jalr	-1796(ra) # 11e6 <fprintf>
=======
     87c:	00001597          	auipc	a1,0x1
     880:	c0458593          	addi	a1,a1,-1020 # 1480 <malloc+0x22a>
     884:	4509                	li	a0,2
     886:	00001097          	auipc	ra,0x1
     88a:	8ea080e7          	jalr	-1814(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(1);
     88e:	4505                	li	a0,1
     890:	00000097          	auipc	ra,0x0
     894:	59e080e7          	jalr	1438(ra) # e2e <exit>
        close(bb[0]);
     898:	fa042503          	lw	a0,-96(s0)
     89c:	00000097          	auipc	ra,0x0
     8a0:	5ba080e7          	jalr	1466(ra) # e56 <close>
        close(bb[1]);
     8a4:	fa442503          	lw	a0,-92(s0)
     8a8:	00000097          	auipc	ra,0x0
     8ac:	5ae080e7          	jalr	1454(ra) # e56 <close>
        close(aa[0]);
     8b0:	f9842503          	lw	a0,-104(s0)
     8b4:	00000097          	auipc	ra,0x0
     8b8:	5a2080e7          	jalr	1442(ra) # e56 <close>
        close(1);
     8bc:	4505                	li	a0,1
     8be:	00000097          	auipc	ra,0x0
     8c2:	598080e7          	jalr	1432(ra) # e56 <close>
        if(dup(aa[1]) != 1){
     8c6:	f9c42503          	lw	a0,-100(s0)
     8ca:	00000097          	auipc	ra,0x0
     8ce:	5dc080e7          	jalr	1500(ra) # ea6 <dup>
     8d2:	4785                	li	a5,1
     8d4:	02f50063          	beq	a0,a5,8f4 <go+0x87c>
          fprintf(2, "grind: dup failed\n");
<<<<<<< HEAD
     93c:	00001597          	auipc	a1,0x1
     940:	cc458593          	addi	a1,a1,-828 # 1600 <malloc+0x32e>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	8a0080e7          	jalr	-1888(ra) # 11e6 <fprintf>
=======
     8d8:	00001597          	auipc	a1,0x1
     8dc:	ca858593          	addi	a1,a1,-856 # 1580 <malloc+0x32a>
     8e0:	4509                	li	a0,2
     8e2:	00001097          	auipc	ra,0x1
     8e6:	88e080e7          	jalr	-1906(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
          exit(1);
     8ea:	4505                	li	a0,1
     8ec:	00000097          	auipc	ra,0x0
     8f0:	542080e7          	jalr	1346(ra) # e2e <exit>
        close(aa[1]);
     8f4:	f9c42503          	lw	a0,-100(s0)
     8f8:	00000097          	auipc	ra,0x0
     8fc:	55e080e7          	jalr	1374(ra) # e56 <close>
        char *args[3] = { "echo", "hi", 0 };
<<<<<<< HEAD
     964:	00001797          	auipc	a5,0x1
     968:	cb478793          	addi	a5,a5,-844 # 1618 <malloc+0x346>
     96c:	faf43423          	sd	a5,-88(s0)
     970:	00001797          	auipc	a5,0x1
     974:	cb078793          	addi	a5,a5,-848 # 1620 <malloc+0x34e>
     978:	faf43823          	sd	a5,-80(s0)
     97c:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     980:	fa840593          	addi	a1,s0,-88
     984:	00001517          	auipc	a0,0x1
     988:	ca450513          	addi	a0,a0,-860 # 1628 <malloc+0x356>
     98c:	00000097          	auipc	ra,0x0
     990:	540080e7          	jalr	1344(ra) # ecc <exec>
        fprintf(2, "grind: echo: not found\n");
     994:	00001597          	auipc	a1,0x1
     998:	ca458593          	addi	a1,a1,-860 # 1638 <malloc+0x366>
     99c:	4509                	li	a0,2
     99e:	00001097          	auipc	ra,0x1
     9a2:	848080e7          	jalr	-1976(ra) # 11e6 <fprintf>
=======
     900:	00001797          	auipc	a5,0x1
     904:	c9878793          	addi	a5,a5,-872 # 1598 <malloc+0x342>
     908:	faf43423          	sd	a5,-88(s0)
     90c:	00001797          	auipc	a5,0x1
     910:	c9478793          	addi	a5,a5,-876 # 15a0 <malloc+0x34a>
     914:	faf43823          	sd	a5,-80(s0)
     918:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     91c:	fa840593          	addi	a1,s0,-88
     920:	00001517          	auipc	a0,0x1
     924:	c8850513          	addi	a0,a0,-888 # 15a8 <malloc+0x352>
     928:	00000097          	auipc	ra,0x0
     92c:	53e080e7          	jalr	1342(ra) # e66 <exec>
        fprintf(2, "grind: echo: not found\n");
     930:	00001597          	auipc	a1,0x1
     934:	c8858593          	addi	a1,a1,-888 # 15b8 <malloc+0x362>
     938:	4509                	li	a0,2
     93a:	00001097          	auipc	ra,0x1
     93e:	836080e7          	jalr	-1994(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(2);
     942:	4509                	li	a0,2
     944:	00000097          	auipc	ra,0x0
     948:	4ea080e7          	jalr	1258(ra) # e2e <exit>
        fprintf(2, "grind: fork failed\n");
<<<<<<< HEAD
     9b0:	00001597          	auipc	a1,0x1
     9b4:	b1058593          	addi	a1,a1,-1264 # 14c0 <malloc+0x1ee>
     9b8:	4509                	li	a0,2
     9ba:	00001097          	auipc	ra,0x1
     9be:	82c080e7          	jalr	-2004(ra) # 11e6 <fprintf>
=======
     94c:	00001597          	auipc	a1,0x1
     950:	af458593          	addi	a1,a1,-1292 # 1440 <malloc+0x1ea>
     954:	4509                	li	a0,2
     956:	00001097          	auipc	ra,0x1
     95a:	81a080e7          	jalr	-2022(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(3);
     95e:	450d                	li	a0,3
     960:	00000097          	auipc	ra,0x0
     964:	4ce080e7          	jalr	1230(ra) # e2e <exit>
        close(aa[1]);
     968:	f9c42503          	lw	a0,-100(s0)
     96c:	00000097          	auipc	ra,0x0
     970:	4ea080e7          	jalr	1258(ra) # e56 <close>
        close(bb[0]);
     974:	fa042503          	lw	a0,-96(s0)
     978:	00000097          	auipc	ra,0x0
     97c:	4de080e7          	jalr	1246(ra) # e56 <close>
        close(0);
     980:	4501                	li	a0,0
     982:	00000097          	auipc	ra,0x0
     986:	4d4080e7          	jalr	1236(ra) # e56 <close>
        if(dup(aa[0]) != 0){
     98a:	f9842503          	lw	a0,-104(s0)
     98e:	00000097          	auipc	ra,0x0
     992:	518080e7          	jalr	1304(ra) # ea6 <dup>
     996:	cd19                	beqz	a0,9b4 <go+0x93c>
          fprintf(2, "grind: dup failed\n");
<<<<<<< HEAD
     9fc:	00001597          	auipc	a1,0x1
     a00:	c0458593          	addi	a1,a1,-1020 # 1600 <malloc+0x32e>
     a04:	4509                	li	a0,2
     a06:	00000097          	auipc	ra,0x0
     a0a:	7e0080e7          	jalr	2016(ra) # 11e6 <fprintf>
=======
     998:	00001597          	auipc	a1,0x1
     99c:	be858593          	addi	a1,a1,-1048 # 1580 <malloc+0x32a>
     9a0:	4509                	li	a0,2
     9a2:	00000097          	auipc	ra,0x0
     9a6:	7ce080e7          	jalr	1998(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
          exit(4);
     9aa:	4511                	li	a0,4
     9ac:	00000097          	auipc	ra,0x0
     9b0:	482080e7          	jalr	1154(ra) # e2e <exit>
        close(aa[0]);
     9b4:	f9842503          	lw	a0,-104(s0)
     9b8:	00000097          	auipc	ra,0x0
     9bc:	49e080e7          	jalr	1182(ra) # e56 <close>
        close(1);
     9c0:	4505                	li	a0,1
     9c2:	00000097          	auipc	ra,0x0
     9c6:	494080e7          	jalr	1172(ra) # e56 <close>
        if(dup(bb[1]) != 1){
     9ca:	fa442503          	lw	a0,-92(s0)
     9ce:	00000097          	auipc	ra,0x0
     9d2:	4d8080e7          	jalr	1240(ra) # ea6 <dup>
     9d6:	4785                	li	a5,1
     9d8:	02f50063          	beq	a0,a5,9f8 <go+0x980>
          fprintf(2, "grind: dup failed\n");
<<<<<<< HEAD
     a40:	00001597          	auipc	a1,0x1
     a44:	bc058593          	addi	a1,a1,-1088 # 1600 <malloc+0x32e>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	79c080e7          	jalr	1948(ra) # 11e6 <fprintf>
=======
     9dc:	00001597          	auipc	a1,0x1
     9e0:	ba458593          	addi	a1,a1,-1116 # 1580 <malloc+0x32a>
     9e4:	4509                	li	a0,2
     9e6:	00000097          	auipc	ra,0x0
     9ea:	78a080e7          	jalr	1930(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
          exit(5);
     9ee:	4515                	li	a0,5
     9f0:	00000097          	auipc	ra,0x0
     9f4:	43e080e7          	jalr	1086(ra) # e2e <exit>
        close(bb[1]);
     9f8:	fa442503          	lw	a0,-92(s0)
     9fc:	00000097          	auipc	ra,0x0
     a00:	45a080e7          	jalr	1114(ra) # e56 <close>
        char *args[2] = { "cat", 0 };
<<<<<<< HEAD
     a68:	00001797          	auipc	a5,0x1
     a6c:	be878793          	addi	a5,a5,-1048 # 1650 <malloc+0x37e>
     a70:	faf43423          	sd	a5,-88(s0)
     a74:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a78:	fa840593          	addi	a1,s0,-88
     a7c:	00001517          	auipc	a0,0x1
     a80:	bdc50513          	addi	a0,a0,-1060 # 1658 <malloc+0x386>
     a84:	00000097          	auipc	ra,0x0
     a88:	448080e7          	jalr	1096(ra) # ecc <exec>
        fprintf(2, "grind: cat: not found\n");
     a8c:	00001597          	auipc	a1,0x1
     a90:	bd458593          	addi	a1,a1,-1068 # 1660 <malloc+0x38e>
     a94:	4509                	li	a0,2
     a96:	00000097          	auipc	ra,0x0
     a9a:	750080e7          	jalr	1872(ra) # 11e6 <fprintf>
=======
     a04:	00001797          	auipc	a5,0x1
     a08:	bcc78793          	addi	a5,a5,-1076 # 15d0 <malloc+0x37a>
     a0c:	faf43423          	sd	a5,-88(s0)
     a10:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a14:	fa840593          	addi	a1,s0,-88
     a18:	00001517          	auipc	a0,0x1
     a1c:	bc050513          	addi	a0,a0,-1088 # 15d8 <malloc+0x382>
     a20:	00000097          	auipc	ra,0x0
     a24:	446080e7          	jalr	1094(ra) # e66 <exec>
        fprintf(2, "grind: cat: not found\n");
     a28:	00001597          	auipc	a1,0x1
     a2c:	bb858593          	addi	a1,a1,-1096 # 15e0 <malloc+0x38a>
     a30:	4509                	li	a0,2
     a32:	00000097          	auipc	ra,0x0
     a36:	73e080e7          	jalr	1854(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(6);
     a3a:	4519                	li	a0,6
     a3c:	00000097          	auipc	ra,0x0
     a40:	3f2080e7          	jalr	1010(ra) # e2e <exit>
        fprintf(2, "grind: fork failed\n");
<<<<<<< HEAD
     aa8:	00001597          	auipc	a1,0x1
     aac:	a1858593          	addi	a1,a1,-1512 # 14c0 <malloc+0x1ee>
     ab0:	4509                	li	a0,2
     ab2:	00000097          	auipc	ra,0x0
     ab6:	734080e7          	jalr	1844(ra) # 11e6 <fprintf>
=======
     a44:	00001597          	auipc	a1,0x1
     a48:	9fc58593          	addi	a1,a1,-1540 # 1440 <malloc+0x1ea>
     a4c:	4509                	li	a0,2
     a4e:	00000097          	auipc	ra,0x0
     a52:	722080e7          	jalr	1826(ra) # 1170 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        exit(7);
     a56:	451d                	li	a0,7
     a58:	00000097          	auipc	ra,0x0
     a5c:	3d6080e7          	jalr	982(ra) # e2e <exit>

0000000000000a60 <iter>:
  }
}

void
iter()
{
     a60:	7179                	addi	sp,sp,-48
     a62:	f406                	sd	ra,40(sp)
     a64:	f022                	sd	s0,32(sp)
     a66:	ec26                	sd	s1,24(sp)
     a68:	e84a                	sd	s2,16(sp)
     a6a:	1800                	addi	s0,sp,48
  unlink("a");
<<<<<<< HEAD
     ad0:	00001517          	auipc	a0,0x1
     ad4:	9d050513          	addi	a0,a0,-1584 # 14a0 <malloc+0x1ce>
     ad8:	00000097          	auipc	ra,0x0
     adc:	40c080e7          	jalr	1036(ra) # ee4 <unlink>
  unlink("b");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	97050513          	addi	a0,a0,-1680 # 1450 <malloc+0x17e>
     ae8:	00000097          	auipc	ra,0x0
     aec:	3fc080e7          	jalr	1020(ra) # ee4 <unlink>
=======
     a6c:	00001517          	auipc	a0,0x1
     a70:	9b450513          	addi	a0,a0,-1612 # 1420 <malloc+0x1ca>
     a74:	00000097          	auipc	ra,0x0
     a78:	40a080e7          	jalr	1034(ra) # e7e <unlink>
  unlink("b");
     a7c:	00001517          	auipc	a0,0x1
     a80:	95450513          	addi	a0,a0,-1708 # 13d0 <malloc+0x17a>
     a84:	00000097          	auipc	ra,0x0
     a88:	3fa080e7          	jalr	1018(ra) # e7e <unlink>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  
  int pid1 = fork();
     a8c:	00000097          	auipc	ra,0x0
     a90:	39a080e7          	jalr	922(ra) # e26 <fork>
  if(pid1 < 0){
     a94:	02054163          	bltz	a0,ab6 <iter+0x56>
     a98:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     a9a:	e91d                	bnez	a0,ad0 <iter+0x70>
    rand_next ^= 31;
     a9c:	00001717          	auipc	a4,0x1
     aa0:	56470713          	addi	a4,a4,1380 # 2000 <rand_next>
     aa4:	631c                	ld	a5,0(a4)
     aa6:	01f7c793          	xori	a5,a5,31
     aaa:	e31c                	sd	a5,0(a4)
    go(0);
     aac:	4501                	li	a0,0
     aae:	fffff097          	auipc	ra,0xfffff
     ab2:	5ca080e7          	jalr	1482(ra) # 78 <go>
    printf("grind: fork failed\n");
<<<<<<< HEAD
     b1a:	00001517          	auipc	a0,0x1
     b1e:	9a650513          	addi	a0,a0,-1626 # 14c0 <malloc+0x1ee>
     b22:	00000097          	auipc	ra,0x0
     b26:	6f2080e7          	jalr	1778(ra) # 1214 <printf>
=======
     ab6:	00001517          	auipc	a0,0x1
     aba:	98a50513          	addi	a0,a0,-1654 # 1440 <malloc+0x1ea>
     abe:	00000097          	auipc	ra,0x0
     ac2:	6e0080e7          	jalr	1760(ra) # 119e <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     ac6:	4505                	li	a0,1
     ac8:	00000097          	auipc	ra,0x0
     acc:	366080e7          	jalr	870(ra) # e2e <exit>
    exit(0);
  }

  int pid2 = fork();
     ad0:	00000097          	auipc	ra,0x0
     ad4:	356080e7          	jalr	854(ra) # e26 <fork>
     ad8:	892a                	mv	s2,a0
  if(pid2 < 0){
     ada:	02054263          	bltz	a0,afe <iter+0x9e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     ade:	ed0d                	bnez	a0,b18 <iter+0xb8>
    rand_next ^= 7177;
<<<<<<< HEAD
     b44:	00001697          	auipc	a3,0x1
     b48:	4bc68693          	addi	a3,a3,1212 # 2000 <rand_next>
     b4c:	629c                	ld	a5,0(a3)
     b4e:	6709                	lui	a4,0x2
     b50:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x559>
     b54:	8fb9                	xor	a5,a5,a4
     b56:	e29c                	sd	a5,0(a3)
=======
     ae0:	00001697          	auipc	a3,0x1
     ae4:	52068693          	addi	a3,a3,1312 # 2000 <rand_next>
     ae8:	629c                	ld	a5,0(a3)
     aea:	6709                	lui	a4,0x2
     aec:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x521>
     af0:	8fb9                	xor	a5,a5,a4
     af2:	e29c                	sd	a5,0(a3)
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    go(1);
     af4:	4505                	li	a0,1
     af6:	fffff097          	auipc	ra,0xfffff
     afa:	582080e7          	jalr	1410(ra) # 78 <go>
    printf("grind: fork failed\n");
<<<<<<< HEAD
     b62:	00001517          	auipc	a0,0x1
     b66:	95e50513          	addi	a0,a0,-1698 # 14c0 <malloc+0x1ee>
     b6a:	00000097          	auipc	ra,0x0
     b6e:	6aa080e7          	jalr	1706(ra) # 1214 <printf>
=======
     afe:	00001517          	auipc	a0,0x1
     b02:	94250513          	addi	a0,a0,-1726 # 1440 <malloc+0x1ea>
     b06:	00000097          	auipc	ra,0x0
     b0a:	698080e7          	jalr	1688(ra) # 119e <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
     b0e:	4505                	li	a0,1
     b10:	00000097          	auipc	ra,0x0
     b14:	31e080e7          	jalr	798(ra) # e2e <exit>
    exit(0);
  }

  int st1 = -1;
     b18:	57fd                	li	a5,-1
     b1a:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b1e:	fdc40513          	addi	a0,s0,-36
     b22:	00000097          	auipc	ra,0x0
     b26:	314080e7          	jalr	788(ra) # e36 <wait>
  if(st1 != 0){
     b2a:	fdc42783          	lw	a5,-36(s0)
     b2e:	ef99                	bnez	a5,b4c <iter+0xec>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b30:	57fd                	li	a5,-1
     b32:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b36:	fd840513          	addi	a0,s0,-40
     b3a:	00000097          	auipc	ra,0x0
     b3e:	2fc080e7          	jalr	764(ra) # e36 <wait>

  exit(0);
     b42:	4501                	li	a0,0
     b44:	00000097          	auipc	ra,0x0
     b48:	2ea080e7          	jalr	746(ra) # e2e <exit>
    kill(pid1);
     b4c:	8526                	mv	a0,s1
     b4e:	00000097          	auipc	ra,0x0
     b52:	310080e7          	jalr	784(ra) # e5e <kill>
    kill(pid2);
     b56:	854a                	mv	a0,s2
     b58:	00000097          	auipc	ra,0x0
     b5c:	306080e7          	jalr	774(ra) # e5e <kill>
     b60:	bfc1                	j	b30 <iter+0xd0>

0000000000000b62 <main>:
}

int
main()
{
     b62:	1101                	addi	sp,sp,-32
     b64:	ec06                	sd	ra,24(sp)
     b66:	e822                	sd	s0,16(sp)
     b68:	e426                	sd	s1,8(sp)
     b6a:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     b6c:	00001497          	auipc	s1,0x1
     b70:	49448493          	addi	s1,s1,1172 # 2000 <rand_next>
     b74:	a829                	j	b8e <main+0x2c>
      iter();
     b76:	00000097          	auipc	ra,0x0
     b7a:	eea080e7          	jalr	-278(ra) # a60 <iter>
    sleep(20);
     b7e:	4551                	li	a0,20
     b80:	00000097          	auipc	ra,0x0
     b84:	33e080e7          	jalr	830(ra) # ebe <sleep>
    rand_next += 1;
     b88:	609c                	ld	a5,0(s1)
     b8a:	0785                	addi	a5,a5,1
     b8c:	e09c                	sd	a5,0(s1)
    int pid = fork();
     b8e:	00000097          	auipc	ra,0x0
     b92:	298080e7          	jalr	664(ra) # e26 <fork>
    if(pid == 0){
     b96:	d165                	beqz	a0,b76 <main+0x14>
    if(pid > 0){
     b98:	fea053e3          	blez	a0,b7e <main+0x1c>
      wait(0);
     b9c:	4501                	li	a0,0
     b9e:	00000097          	auipc	ra,0x0
     ba2:	298080e7          	jalr	664(ra) # e36 <wait>
     ba6:	bfe1                	j	b7e <main+0x1c>

0000000000000ba8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     ba8:	1141                	addi	sp,sp,-16
     baa:	e406                	sd	ra,8(sp)
     bac:	e022                	sd	s0,0(sp)
     bae:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bb0:	00000097          	auipc	ra,0x0
     bb4:	fb2080e7          	jalr	-78(ra) # b62 <main>
  exit(0);
     bb8:	4501                	li	a0,0
     bba:	00000097          	auipc	ra,0x0
     bbe:	274080e7          	jalr	628(ra) # e2e <exit>

0000000000000bc2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     bc2:	1141                	addi	sp,sp,-16
     bc4:	e422                	sd	s0,8(sp)
     bc6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bc8:	87aa                	mv	a5,a0
     bca:	0585                	addi	a1,a1,1
     bcc:	0785                	addi	a5,a5,1
     bce:	fff5c703          	lbu	a4,-1(a1)
     bd2:	fee78fa3          	sb	a4,-1(a5)
     bd6:	fb75                	bnez	a4,bca <strcpy+0x8>
    ;
  return os;
}
     bd8:	6422                	ld	s0,8(sp)
     bda:	0141                	addi	sp,sp,16
     bdc:	8082                	ret

0000000000000bde <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bde:	1141                	addi	sp,sp,-16
     be0:	e422                	sd	s0,8(sp)
     be2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     be4:	00054783          	lbu	a5,0(a0)
     be8:	cb91                	beqz	a5,bfc <strcmp+0x1e>
     bea:	0005c703          	lbu	a4,0(a1)
     bee:	00f71763          	bne	a4,a5,bfc <strcmp+0x1e>
    p++, q++;
     bf2:	0505                	addi	a0,a0,1
     bf4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bf6:	00054783          	lbu	a5,0(a0)
     bfa:	fbe5                	bnez	a5,bea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bfc:	0005c503          	lbu	a0,0(a1)
}
     c00:	40a7853b          	subw	a0,a5,a0
     c04:	6422                	ld	s0,8(sp)
     c06:	0141                	addi	sp,sp,16
     c08:	8082                	ret

0000000000000c0a <strlen>:

uint
strlen(const char *s)
{
     c0a:	1141                	addi	sp,sp,-16
     c0c:	e422                	sd	s0,8(sp)
     c0e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c10:	00054783          	lbu	a5,0(a0)
     c14:	cf91                	beqz	a5,c30 <strlen+0x26>
     c16:	0505                	addi	a0,a0,1
     c18:	87aa                	mv	a5,a0
     c1a:	86be                	mv	a3,a5
     c1c:	0785                	addi	a5,a5,1
     c1e:	fff7c703          	lbu	a4,-1(a5)
     c22:	ff65                	bnez	a4,c1a <strlen+0x10>
     c24:	40a6853b          	subw	a0,a3,a0
     c28:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     c2a:	6422                	ld	s0,8(sp)
     c2c:	0141                	addi	sp,sp,16
     c2e:	8082                	ret
  for(n = 0; s[n]; n++)
     c30:	4501                	li	a0,0
     c32:	bfe5                	j	c2a <strlen+0x20>

0000000000000c34 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c34:	1141                	addi	sp,sp,-16
     c36:	e422                	sd	s0,8(sp)
     c38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c3a:	ca19                	beqz	a2,c50 <memset+0x1c>
     c3c:	87aa                	mv	a5,a0
     c3e:	1602                	slli	a2,a2,0x20
     c40:	9201                	srli	a2,a2,0x20
     c42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c4a:	0785                	addi	a5,a5,1
     c4c:	fee79de3          	bne	a5,a4,c46 <memset+0x12>
  }
  return dst;
}
     c50:	6422                	ld	s0,8(sp)
     c52:	0141                	addi	sp,sp,16
     c54:	8082                	ret

0000000000000c56 <strchr>:

char*
strchr(const char *s, char c)
{
     c56:	1141                	addi	sp,sp,-16
     c58:	e422                	sd	s0,8(sp)
     c5a:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c5c:	00054783          	lbu	a5,0(a0)
     c60:	cb99                	beqz	a5,c76 <strchr+0x20>
    if(*s == c)
     c62:	00f58763          	beq	a1,a5,c70 <strchr+0x1a>
  for(; *s; s++)
     c66:	0505                	addi	a0,a0,1
     c68:	00054783          	lbu	a5,0(a0)
     c6c:	fbfd                	bnez	a5,c62 <strchr+0xc>
      return (char*)s;
  return 0;
     c6e:	4501                	li	a0,0
}
     c70:	6422                	ld	s0,8(sp)
     c72:	0141                	addi	sp,sp,16
     c74:	8082                	ret
  return 0;
     c76:	4501                	li	a0,0
     c78:	bfe5                	j	c70 <strchr+0x1a>

0000000000000c7a <gets>:

char*
gets(char *buf, int max)
{
     c7a:	711d                	addi	sp,sp,-96
     c7c:	ec86                	sd	ra,88(sp)
     c7e:	e8a2                	sd	s0,80(sp)
     c80:	e4a6                	sd	s1,72(sp)
     c82:	e0ca                	sd	s2,64(sp)
     c84:	fc4e                	sd	s3,56(sp)
     c86:	f852                	sd	s4,48(sp)
     c88:	f456                	sd	s5,40(sp)
     c8a:	f05a                	sd	s6,32(sp)
     c8c:	ec5e                	sd	s7,24(sp)
     c8e:	1080                	addi	s0,sp,96
     c90:	8baa                	mv	s7,a0
     c92:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c94:	892a                	mv	s2,a0
     c96:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c98:	4aa9                	li	s5,10
     c9a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c9c:	89a6                	mv	s3,s1
     c9e:	2485                	addiw	s1,s1,1
     ca0:	0344d863          	bge	s1,s4,cd0 <gets+0x56>
    cc = read(0, &c, 1);
     ca4:	4605                	li	a2,1
     ca6:	faf40593          	addi	a1,s0,-81
     caa:	4501                	li	a0,0
     cac:	00000097          	auipc	ra,0x0
     cb0:	19a080e7          	jalr	410(ra) # e46 <read>
    if(cc < 1)
     cb4:	00a05e63          	blez	a0,cd0 <gets+0x56>
    buf[i++] = c;
     cb8:	faf44783          	lbu	a5,-81(s0)
     cbc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cc0:	01578763          	beq	a5,s5,cce <gets+0x54>
     cc4:	0905                	addi	s2,s2,1
     cc6:	fd679be3          	bne	a5,s6,c9c <gets+0x22>
  for(i=0; i+1 < max; ){
     cca:	89a6                	mv	s3,s1
     ccc:	a011                	j	cd0 <gets+0x56>
     cce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cd0:	99de                	add	s3,s3,s7
     cd2:	00098023          	sb	zero,0(s3)
  return buf;
}
     cd6:	855e                	mv	a0,s7
     cd8:	60e6                	ld	ra,88(sp)
     cda:	6446                	ld	s0,80(sp)
     cdc:	64a6                	ld	s1,72(sp)
     cde:	6906                	ld	s2,64(sp)
     ce0:	79e2                	ld	s3,56(sp)
     ce2:	7a42                	ld	s4,48(sp)
     ce4:	7aa2                	ld	s5,40(sp)
     ce6:	7b02                	ld	s6,32(sp)
     ce8:	6be2                	ld	s7,24(sp)
     cea:	6125                	addi	sp,sp,96
     cec:	8082                	ret

0000000000000cee <stat>:

int
stat(const char *n, struct stat *st)
{
     cee:	1101                	addi	sp,sp,-32
     cf0:	ec06                	sd	ra,24(sp)
     cf2:	e822                	sd	s0,16(sp)
     cf4:	e426                	sd	s1,8(sp)
     cf6:	e04a                	sd	s2,0(sp)
     cf8:	1000                	addi	s0,sp,32
     cfa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cfc:	4581                	li	a1,0
     cfe:	00000097          	auipc	ra,0x0
     d02:	170080e7          	jalr	368(ra) # e6e <open>
  if(fd < 0)
     d06:	02054563          	bltz	a0,d30 <stat+0x42>
     d0a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d0c:	85ca                	mv	a1,s2
     d0e:	00000097          	auipc	ra,0x0
     d12:	178080e7          	jalr	376(ra) # e86 <fstat>
     d16:	892a                	mv	s2,a0
  close(fd);
     d18:	8526                	mv	a0,s1
     d1a:	00000097          	auipc	ra,0x0
     d1e:	13c080e7          	jalr	316(ra) # e56 <close>
  return r;
}
     d22:	854a                	mv	a0,s2
     d24:	60e2                	ld	ra,24(sp)
     d26:	6442                	ld	s0,16(sp)
     d28:	64a2                	ld	s1,8(sp)
     d2a:	6902                	ld	s2,0(sp)
     d2c:	6105                	addi	sp,sp,32
     d2e:	8082                	ret
    return -1;
     d30:	597d                	li	s2,-1
     d32:	bfc5                	j	d22 <stat+0x34>

0000000000000d34 <atoi>:

int
atoi(const char *s)
{
     d34:	1141                	addi	sp,sp,-16
     d36:	e422                	sd	s0,8(sp)
     d38:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d3a:	00054683          	lbu	a3,0(a0)
     d3e:	fd06879b          	addiw	a5,a3,-48
     d42:	0ff7f793          	zext.b	a5,a5
     d46:	4625                	li	a2,9
     d48:	02f66863          	bltu	a2,a5,d78 <atoi+0x44>
     d4c:	872a                	mv	a4,a0
  n = 0;
     d4e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d50:	0705                	addi	a4,a4,1
     d52:	0025179b          	slliw	a5,a0,0x2
     d56:	9fa9                	addw	a5,a5,a0
     d58:	0017979b          	slliw	a5,a5,0x1
     d5c:	9fb5                	addw	a5,a5,a3
     d5e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d62:	00074683          	lbu	a3,0(a4)
     d66:	fd06879b          	addiw	a5,a3,-48
     d6a:	0ff7f793          	zext.b	a5,a5
     d6e:	fef671e3          	bgeu	a2,a5,d50 <atoi+0x1c>
  return n;
}
     d72:	6422                	ld	s0,8(sp)
     d74:	0141                	addi	sp,sp,16
     d76:	8082                	ret
  n = 0;
     d78:	4501                	li	a0,0
     d7a:	bfe5                	j	d72 <atoi+0x3e>

0000000000000d7c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d7c:	1141                	addi	sp,sp,-16
     d7e:	e422                	sd	s0,8(sp)
     d80:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d82:	02b57463          	bgeu	a0,a1,daa <memmove+0x2e>
    while(n-- > 0)
     d86:	00c05f63          	blez	a2,da4 <memmove+0x28>
     d8a:	1602                	slli	a2,a2,0x20
     d8c:	9201                	srli	a2,a2,0x20
     d8e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     d92:	872a                	mv	a4,a0
      *dst++ = *src++;
     d94:	0585                	addi	a1,a1,1
     d96:	0705                	addi	a4,a4,1
     d98:	fff5c683          	lbu	a3,-1(a1)
     d9c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     da0:	fee79ae3          	bne	a5,a4,d94 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     da4:	6422                	ld	s0,8(sp)
     da6:	0141                	addi	sp,sp,16
     da8:	8082                	ret
    dst += n;
     daa:	00c50733          	add	a4,a0,a2
    src += n;
     dae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     db0:	fec05ae3          	blez	a2,da4 <memmove+0x28>
     db4:	fff6079b          	addiw	a5,a2,-1
     db8:	1782                	slli	a5,a5,0x20
     dba:	9381                	srli	a5,a5,0x20
     dbc:	fff7c793          	not	a5,a5
     dc0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dc2:	15fd                	addi	a1,a1,-1
     dc4:	177d                	addi	a4,a4,-1
     dc6:	0005c683          	lbu	a3,0(a1)
     dca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     dce:	fee79ae3          	bne	a5,a4,dc2 <memmove+0x46>
     dd2:	bfc9                	j	da4 <memmove+0x28>

0000000000000dd4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     dd4:	1141                	addi	sp,sp,-16
     dd6:	e422                	sd	s0,8(sp)
     dd8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     dda:	ca05                	beqz	a2,e0a <memcmp+0x36>
     ddc:	fff6069b          	addiw	a3,a2,-1
     de0:	1682                	slli	a3,a3,0x20
     de2:	9281                	srli	a3,a3,0x20
     de4:	0685                	addi	a3,a3,1
     de6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     de8:	00054783          	lbu	a5,0(a0)
     dec:	0005c703          	lbu	a4,0(a1)
     df0:	00e79863          	bne	a5,a4,e00 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     df4:	0505                	addi	a0,a0,1
    p2++;
     df6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     df8:	fed518e3          	bne	a0,a3,de8 <memcmp+0x14>
  }
  return 0;
     dfc:	4501                	li	a0,0
     dfe:	a019                	j	e04 <memcmp+0x30>
      return *p1 - *p2;
     e00:	40e7853b          	subw	a0,a5,a4
}
     e04:	6422                	ld	s0,8(sp)
     e06:	0141                	addi	sp,sp,16
     e08:	8082                	ret
  return 0;
     e0a:	4501                	li	a0,0
     e0c:	bfe5                	j	e04 <memcmp+0x30>

0000000000000e0e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e0e:	1141                	addi	sp,sp,-16
     e10:	e406                	sd	ra,8(sp)
     e12:	e022                	sd	s0,0(sp)
     e14:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e16:	00000097          	auipc	ra,0x0
     e1a:	f66080e7          	jalr	-154(ra) # d7c <memmove>
}
     e1e:	60a2                	ld	ra,8(sp)
     e20:	6402                	ld	s0,0(sp)
     e22:	0141                	addi	sp,sp,16
     e24:	8082                	ret

0000000000000e26 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e26:	4885                	li	a7,1
 ecall
     e28:	00000073          	ecall
 ret
     e2c:	8082                	ret

0000000000000e2e <exit>:
.global exit
exit:
 li a7, SYS_exit
     e2e:	4889                	li	a7,2
 ecall
     e30:	00000073          	ecall
 ret
     e34:	8082                	ret

0000000000000e36 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e36:	488d                	li	a7,3
 ecall
     e38:	00000073          	ecall
 ret
     e3c:	8082                	ret

0000000000000e3e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e3e:	4891                	li	a7,4
 ecall
     e40:	00000073          	ecall
 ret
     e44:	8082                	ret

0000000000000e46 <read>:
.global read
read:
 li a7, SYS_read
     e46:	4895                	li	a7,5
 ecall
     e48:	00000073          	ecall
 ret
     e4c:	8082                	ret

0000000000000e4e <write>:
.global write
write:
 li a7, SYS_write
     e4e:	48c1                	li	a7,16
 ecall
     e50:	00000073          	ecall
 ret
     e54:	8082                	ret

0000000000000e56 <close>:
.global close
close:
 li a7, SYS_close
     e56:	48d5                	li	a7,21
 ecall
     e58:	00000073          	ecall
 ret
     e5c:	8082                	ret

0000000000000e5e <kill>:
.global kill
kill:
 li a7, SYS_kill
     e5e:	4899                	li	a7,6
 ecall
     e60:	00000073          	ecall
 ret
     e64:	8082                	ret

0000000000000e66 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e66:	489d                	li	a7,7
 ecall
     e68:	00000073          	ecall
 ret
     e6c:	8082                	ret

0000000000000e6e <open>:
.global open
open:
 li a7, SYS_open
     e6e:	48bd                	li	a7,15
 ecall
     e70:	00000073          	ecall
 ret
     e74:	8082                	ret

0000000000000e76 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e76:	48c5                	li	a7,17
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e7e:	48c9                	li	a7,18
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e86:	48a1                	li	a7,8
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <link>:
.global link
link:
 li a7, SYS_link
     e8e:	48cd                	li	a7,19
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     e96:	48d1                	li	a7,20
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     e9e:	48a5                	li	a7,9
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ea6:	48a9                	li	a7,10
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     eae:	48ad                	li	a7,11
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     eb6:	48b1                	li	a7,12
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ebe:	48b5                	li	a7,13
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ec6:	48b9                	li	a7,14
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

<<<<<<< HEAD
0000000000000f34 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
     f34:	48d9                	li	a7,22
 ecall
     f36:	00000073          	ecall
 ret
     f3a:	8082                	ret

0000000000000f3c <putc>:
=======
0000000000000ece <trace>:
.global trace
trace:
 li a7, SYS_trace
     ece:	48d9                	li	a7,22
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <putc>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
<<<<<<< HEAD
     f3c:	1101                	addi	sp,sp,-32
     f3e:	ec06                	sd	ra,24(sp)
     f40:	e822                	sd	s0,16(sp)
     f42:	1000                	addi	s0,sp,32
     f44:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f48:	4605                	li	a2,1
     f4a:	fef40593          	addi	a1,s0,-17
     f4e:	00000097          	auipc	ra,0x0
     f52:	f66080e7          	jalr	-154(ra) # eb4 <write>
}
     f56:	60e2                	ld	ra,24(sp)
     f58:	6442                	ld	s0,16(sp)
     f5a:	6105                	addi	sp,sp,32
     f5c:	8082                	ret

0000000000000f5e <printint>:
=======
     ed6:	1101                	addi	sp,sp,-32
     ed8:	ec06                	sd	ra,24(sp)
     eda:	e822                	sd	s0,16(sp)
     edc:	1000                	addi	s0,sp,32
     ede:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     ee2:	4605                	li	a2,1
     ee4:	fef40593          	addi	a1,s0,-17
     ee8:	00000097          	auipc	ra,0x0
     eec:	f66080e7          	jalr	-154(ra) # e4e <write>
}
     ef0:	60e2                	ld	ra,24(sp)
     ef2:	6442                	ld	s0,16(sp)
     ef4:	6105                	addi	sp,sp,32
     ef6:	8082                	ret

0000000000000ef8 <printint>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

static void
printint(int fd, int xx, int base, int sgn)
{
<<<<<<< HEAD
     f5e:	7139                	addi	sp,sp,-64
     f60:	fc06                	sd	ra,56(sp)
     f62:	f822                	sd	s0,48(sp)
     f64:	f426                	sd	s1,40(sp)
     f66:	f04a                	sd	s2,32(sp)
     f68:	ec4e                	sd	s3,24(sp)
     f6a:	0080                	addi	s0,sp,64
     f6c:	84aa                	mv	s1,a0
=======
     ef8:	7139                	addi	sp,sp,-64
     efa:	fc06                	sd	ra,56(sp)
     efc:	f822                	sd	s0,48(sp)
     efe:	f426                	sd	s1,40(sp)
     f00:	f04a                	sd	s2,32(sp)
     f02:	ec4e                	sd	s3,24(sp)
     f04:	0080                	addi	s0,sp,64
     f06:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
<<<<<<< HEAD
     f6e:	c299                	beqz	a3,f74 <printint+0x16>
     f70:	0805c863          	bltz	a1,1000 <printint+0xa2>
=======
     f08:	c299                	beqz	a3,f0e <printint+0x16>
     f0a:	0805c963          	bltz	a1,f9c <printint+0xa4>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    neg = 1;
    x = -xx;
  } else {
    x = xx;
<<<<<<< HEAD
     f74:	2581                	sext.w	a1,a1
  neg = 0;
     f76:	4881                	li	a7,0
     f78:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f7c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f7e:	2601                	sext.w	a2,a2
     f80:	00000517          	auipc	a0,0x0
     f84:	73050513          	addi	a0,a0,1840 # 16b0 <digits>
     f88:	883a                	mv	a6,a4
     f8a:	2705                	addiw	a4,a4,1
     f8c:	02c5f7bb          	remuw	a5,a1,a2
     f90:	1782                	slli	a5,a5,0x20
     f92:	9381                	srli	a5,a5,0x20
     f94:	97aa                	add	a5,a5,a0
     f96:	0007c783          	lbu	a5,0(a5)
     f9a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f9e:	0005879b          	sext.w	a5,a1
     fa2:	02c5d5bb          	divuw	a1,a1,a2
     fa6:	0685                	addi	a3,a3,1
     fa8:	fec7f0e3          	bgeu	a5,a2,f88 <printint+0x2a>
  if(neg)
     fac:	00088b63          	beqz	a7,fc2 <printint+0x64>
    buf[i++] = '-';
     fb0:	fd040793          	addi	a5,s0,-48
     fb4:	973e                	add	a4,a4,a5
     fb6:	02d00793          	li	a5,45
     fba:	fef70823          	sb	a5,-16(a4)
     fbe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fc2:	02e05863          	blez	a4,ff2 <printint+0x94>
     fc6:	fc040793          	addi	a5,s0,-64
     fca:	00e78933          	add	s2,a5,a4
     fce:	fff78993          	addi	s3,a5,-1
     fd2:	99ba                	add	s3,s3,a4
     fd4:	377d                	addiw	a4,a4,-1
     fd6:	1702                	slli	a4,a4,0x20
     fd8:	9301                	srli	a4,a4,0x20
     fda:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fde:	fff94583          	lbu	a1,-1(s2)
     fe2:	8526                	mv	a0,s1
     fe4:	00000097          	auipc	ra,0x0
     fe8:	f58080e7          	jalr	-168(ra) # f3c <putc>
  while(--i >= 0)
     fec:	197d                	addi	s2,s2,-1
     fee:	ff3918e3          	bne	s2,s3,fde <printint+0x80>
}
     ff2:	70e2                	ld	ra,56(sp)
     ff4:	7442                	ld	s0,48(sp)
     ff6:	74a2                	ld	s1,40(sp)
     ff8:	7902                	ld	s2,32(sp)
     ffa:	69e2                	ld	s3,24(sp)
     ffc:	6121                	addi	sp,sp,64
     ffe:	8082                	ret
    x = -xx;
    1000:	40b005bb          	negw	a1,a1
    neg = 1;
    1004:	4885                	li	a7,1
    x = -xx;
    1006:	bf8d                	j	f78 <printint+0x1a>

0000000000001008 <vprintf>:
=======
     f0e:	2581                	sext.w	a1,a1
  neg = 0;
     f10:	4881                	li	a7,0
     f12:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f16:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f18:	2601                	sext.w	a2,a2
     f1a:	00000517          	auipc	a0,0x0
     f1e:	7ce50513          	addi	a0,a0,1998 # 16e8 <digits>
     f22:	883a                	mv	a6,a4
     f24:	2705                	addiw	a4,a4,1
     f26:	02c5f7bb          	remuw	a5,a1,a2
     f2a:	1782                	slli	a5,a5,0x20
     f2c:	9381                	srli	a5,a5,0x20
     f2e:	97aa                	add	a5,a5,a0
     f30:	0007c783          	lbu	a5,0(a5)
     f34:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f38:	0005879b          	sext.w	a5,a1
     f3c:	02c5d5bb          	divuw	a1,a1,a2
     f40:	0685                	addi	a3,a3,1
     f42:	fec7f0e3          	bgeu	a5,a2,f22 <printint+0x2a>
  if(neg)
     f46:	00088c63          	beqz	a7,f5e <printint+0x66>
    buf[i++] = '-';
     f4a:	fd070793          	addi	a5,a4,-48
     f4e:	00878733          	add	a4,a5,s0
     f52:	02d00793          	li	a5,45
     f56:	fef70823          	sb	a5,-16(a4)
     f5a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f5e:	02e05863          	blez	a4,f8e <printint+0x96>
     f62:	fc040793          	addi	a5,s0,-64
     f66:	00e78933          	add	s2,a5,a4
     f6a:	fff78993          	addi	s3,a5,-1
     f6e:	99ba                	add	s3,s3,a4
     f70:	377d                	addiw	a4,a4,-1
     f72:	1702                	slli	a4,a4,0x20
     f74:	9301                	srli	a4,a4,0x20
     f76:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f7a:	fff94583          	lbu	a1,-1(s2)
     f7e:	8526                	mv	a0,s1
     f80:	00000097          	auipc	ra,0x0
     f84:	f56080e7          	jalr	-170(ra) # ed6 <putc>
  while(--i >= 0)
     f88:	197d                	addi	s2,s2,-1
     f8a:	ff3918e3          	bne	s2,s3,f7a <printint+0x82>
}
     f8e:	70e2                	ld	ra,56(sp)
     f90:	7442                	ld	s0,48(sp)
     f92:	74a2                	ld	s1,40(sp)
     f94:	7902                	ld	s2,32(sp)
     f96:	69e2                	ld	s3,24(sp)
     f98:	6121                	addi	sp,sp,64
     f9a:	8082                	ret
    x = -xx;
     f9c:	40b005bb          	negw	a1,a1
    neg = 1;
     fa0:	4885                	li	a7,1
    x = -xx;
     fa2:	bf85                	j	f12 <printint+0x1a>

0000000000000fa4 <vprintf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
<<<<<<< HEAD
    1008:	7119                	addi	sp,sp,-128
    100a:	fc86                	sd	ra,120(sp)
    100c:	f8a2                	sd	s0,112(sp)
    100e:	f4a6                	sd	s1,104(sp)
    1010:	f0ca                	sd	s2,96(sp)
    1012:	ecce                	sd	s3,88(sp)
    1014:	e8d2                	sd	s4,80(sp)
    1016:	e4d6                	sd	s5,72(sp)
    1018:	e0da                	sd	s6,64(sp)
    101a:	fc5e                	sd	s7,56(sp)
    101c:	f862                	sd	s8,48(sp)
    101e:	f466                	sd	s9,40(sp)
    1020:	f06a                	sd	s10,32(sp)
    1022:	ec6e                	sd	s11,24(sp)
    1024:	0100                	addi	s0,sp,128
=======
     fa4:	715d                	addi	sp,sp,-80
     fa6:	e486                	sd	ra,72(sp)
     fa8:	e0a2                	sd	s0,64(sp)
     faa:	fc26                	sd	s1,56(sp)
     fac:	f84a                	sd	s2,48(sp)
     fae:	f44e                	sd	s3,40(sp)
     fb0:	f052                	sd	s4,32(sp)
     fb2:	ec56                	sd	s5,24(sp)
     fb4:	e85a                	sd	s6,16(sp)
     fb6:	e45e                	sd	s7,8(sp)
     fb8:	e062                	sd	s8,0(sp)
     fba:	0880                	addi	s0,sp,80
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
<<<<<<< HEAD
    1026:	0005c903          	lbu	s2,0(a1)
    102a:	18090f63          	beqz	s2,11c8 <vprintf+0x1c0>
    102e:	8aaa                	mv	s5,a0
    1030:	8b32                	mv	s6,a2
    1032:	00158493          	addi	s1,a1,1
  state = 0;
    1036:	4981                	li	s3,0
=======
     fbc:	0005c903          	lbu	s2,0(a1)
     fc0:	18090c63          	beqz	s2,1158 <vprintf+0x1b4>
     fc4:	8aaa                	mv	s5,a0
     fc6:	8bb2                	mv	s7,a2
     fc8:	00158493          	addi	s1,a1,1
  state = 0;
     fcc:	4981                	li	s3,0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
<<<<<<< HEAD
    1038:	02500a13          	li	s4,37
      if(c == 'd'){
    103c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1040:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1044:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1048:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    104c:	00000b97          	auipc	s7,0x0
    1050:	664b8b93          	addi	s7,s7,1636 # 16b0 <digits>
    1054:	a839                	j	1072 <vprintf+0x6a>
        putc(fd, c);
    1056:	85ca                	mv	a1,s2
    1058:	8556                	mv	a0,s5
    105a:	00000097          	auipc	ra,0x0
    105e:	ee2080e7          	jalr	-286(ra) # f3c <putc>
    1062:	a019                	j	1068 <vprintf+0x60>
    } else if(state == '%'){
    1064:	01498f63          	beq	s3,s4,1082 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1068:	0485                	addi	s1,s1,1
    106a:	fff4c903          	lbu	s2,-1(s1)
    106e:	14090d63          	beqz	s2,11c8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1072:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1076:	fe0997e3          	bnez	s3,1064 <vprintf+0x5c>
      if(c == '%'){
    107a:	fd479ee3          	bne	a5,s4,1056 <vprintf+0x4e>
        state = '%';
    107e:	89be                	mv	s3,a5
    1080:	b7e5                	j	1068 <vprintf+0x60>
      if(c == 'd'){
    1082:	05878063          	beq	a5,s8,10c2 <vprintf+0xba>
      } else if(c == 'l') {
    1086:	05978c63          	beq	a5,s9,10de <vprintf+0xd6>
      } else if(c == 'x') {
    108a:	07a78863          	beq	a5,s10,10fa <vprintf+0xf2>
      } else if(c == 'p') {
    108e:	09b78463          	beq	a5,s11,1116 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1092:	07300713          	li	a4,115
    1096:	0ce78663          	beq	a5,a4,1162 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    109a:	06300713          	li	a4,99
    109e:	0ee78e63          	beq	a5,a4,119a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10a2:	11478863          	beq	a5,s4,11b2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10a6:	85d2                	mv	a1,s4
    10a8:	8556                	mv	a0,s5
    10aa:	00000097          	auipc	ra,0x0
    10ae:	e92080e7          	jalr	-366(ra) # f3c <putc>
        putc(fd, c);
    10b2:	85ca                	mv	a1,s2
    10b4:	8556                	mv	a0,s5
    10b6:	00000097          	auipc	ra,0x0
    10ba:	e86080e7          	jalr	-378(ra) # f3c <putc>
      }
      state = 0;
    10be:	4981                	li	s3,0
    10c0:	b765                	j	1068 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10c2:	008b0913          	addi	s2,s6,8
    10c6:	4685                	li	a3,1
    10c8:	4629                	li	a2,10
    10ca:	000b2583          	lw	a1,0(s6)
    10ce:	8556                	mv	a0,s5
    10d0:	00000097          	auipc	ra,0x0
    10d4:	e8e080e7          	jalr	-370(ra) # f5e <printint>
    10d8:	8b4a                	mv	s6,s2
      state = 0;
    10da:	4981                	li	s3,0
    10dc:	b771                	j	1068 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10de:	008b0913          	addi	s2,s6,8
    10e2:	4681                	li	a3,0
    10e4:	4629                	li	a2,10
    10e6:	000b2583          	lw	a1,0(s6)
    10ea:	8556                	mv	a0,s5
    10ec:	00000097          	auipc	ra,0x0
    10f0:	e72080e7          	jalr	-398(ra) # f5e <printint>
    10f4:	8b4a                	mv	s6,s2
      state = 0;
    10f6:	4981                	li	s3,0
    10f8:	bf85                	j	1068 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10fa:	008b0913          	addi	s2,s6,8
    10fe:	4681                	li	a3,0
    1100:	4641                	li	a2,16
    1102:	000b2583          	lw	a1,0(s6)
    1106:	8556                	mv	a0,s5
    1108:	00000097          	auipc	ra,0x0
    110c:	e56080e7          	jalr	-426(ra) # f5e <printint>
    1110:	8b4a                	mv	s6,s2
      state = 0;
    1112:	4981                	li	s3,0
    1114:	bf91                	j	1068 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1116:	008b0793          	addi	a5,s6,8
    111a:	f8f43423          	sd	a5,-120(s0)
    111e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1122:	03000593          	li	a1,48
    1126:	8556                	mv	a0,s5
    1128:	00000097          	auipc	ra,0x0
    112c:	e14080e7          	jalr	-492(ra) # f3c <putc>
  putc(fd, 'x');
    1130:	85ea                	mv	a1,s10
    1132:	8556                	mv	a0,s5
    1134:	00000097          	auipc	ra,0x0
    1138:	e08080e7          	jalr	-504(ra) # f3c <putc>
    113c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    113e:	03c9d793          	srli	a5,s3,0x3c
    1142:	97de                	add	a5,a5,s7
    1144:	0007c583          	lbu	a1,0(a5)
    1148:	8556                	mv	a0,s5
    114a:	00000097          	auipc	ra,0x0
    114e:	df2080e7          	jalr	-526(ra) # f3c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1152:	0992                	slli	s3,s3,0x4
    1154:	397d                	addiw	s2,s2,-1
    1156:	fe0914e3          	bnez	s2,113e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    115a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    115e:	4981                	li	s3,0
    1160:	b721                	j	1068 <vprintf+0x60>
        s = va_arg(ap, char*);
    1162:	008b0993          	addi	s3,s6,8
    1166:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    116a:	02090163          	beqz	s2,118c <vprintf+0x184>
        while(*s != 0){
    116e:	00094583          	lbu	a1,0(s2)
    1172:	c9a1                	beqz	a1,11c2 <vprintf+0x1ba>
          putc(fd, *s);
    1174:	8556                	mv	a0,s5
    1176:	00000097          	auipc	ra,0x0
    117a:	dc6080e7          	jalr	-570(ra) # f3c <putc>
          s++;
    117e:	0905                	addi	s2,s2,1
        while(*s != 0){
    1180:	00094583          	lbu	a1,0(s2)
    1184:	f9e5                	bnez	a1,1174 <vprintf+0x16c>
        s = va_arg(ap, char*);
    1186:	8b4e                	mv	s6,s3
      state = 0;
    1188:	4981                	li	s3,0
    118a:	bdf9                	j	1068 <vprintf+0x60>
          s = "(null)";
    118c:	00000917          	auipc	s2,0x0
    1190:	51c90913          	addi	s2,s2,1308 # 16a8 <malloc+0x3d6>
        while(*s != 0){
    1194:	02800593          	li	a1,40
    1198:	bff1                	j	1174 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    119a:	008b0913          	addi	s2,s6,8
    119e:	000b4583          	lbu	a1,0(s6)
    11a2:	8556                	mv	a0,s5
    11a4:	00000097          	auipc	ra,0x0
    11a8:	d98080e7          	jalr	-616(ra) # f3c <putc>
    11ac:	8b4a                	mv	s6,s2
      state = 0;
    11ae:	4981                	li	s3,0
    11b0:	bd65                	j	1068 <vprintf+0x60>
        putc(fd, c);
    11b2:	85d2                	mv	a1,s4
    11b4:	8556                	mv	a0,s5
    11b6:	00000097          	auipc	ra,0x0
    11ba:	d86080e7          	jalr	-634(ra) # f3c <putc>
      state = 0;
    11be:	4981                	li	s3,0
    11c0:	b565                	j	1068 <vprintf+0x60>
        s = va_arg(ap, char*);
    11c2:	8b4e                	mv	s6,s3
      state = 0;
    11c4:	4981                	li	s3,0
    11c6:	b54d                	j	1068 <vprintf+0x60>
    }
  }
}
    11c8:	70e6                	ld	ra,120(sp)
    11ca:	7446                	ld	s0,112(sp)
    11cc:	74a6                	ld	s1,104(sp)
    11ce:	7906                	ld	s2,96(sp)
    11d0:	69e6                	ld	s3,88(sp)
    11d2:	6a46                	ld	s4,80(sp)
    11d4:	6aa6                	ld	s5,72(sp)
    11d6:	6b06                	ld	s6,64(sp)
    11d8:	7be2                	ld	s7,56(sp)
    11da:	7c42                	ld	s8,48(sp)
    11dc:	7ca2                	ld	s9,40(sp)
    11de:	7d02                	ld	s10,32(sp)
    11e0:	6de2                	ld	s11,24(sp)
    11e2:	6109                	addi	sp,sp,128
    11e4:	8082                	ret

00000000000011e6 <fprintf>:
=======
     fce:	02500a13          	li	s4,37
     fd2:	4b55                	li	s6,21
     fd4:	a839                	j	ff2 <vprintf+0x4e>
        putc(fd, c);
     fd6:	85ca                	mv	a1,s2
     fd8:	8556                	mv	a0,s5
     fda:	00000097          	auipc	ra,0x0
     fde:	efc080e7          	jalr	-260(ra) # ed6 <putc>
     fe2:	a019                	j	fe8 <vprintf+0x44>
    } else if(state == '%'){
     fe4:	01498d63          	beq	s3,s4,ffe <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
     fe8:	0485                	addi	s1,s1,1
     fea:	fff4c903          	lbu	s2,-1(s1)
     fee:	16090563          	beqz	s2,1158 <vprintf+0x1b4>
    if(state == 0){
     ff2:	fe0999e3          	bnez	s3,fe4 <vprintf+0x40>
      if(c == '%'){
     ff6:	ff4910e3          	bne	s2,s4,fd6 <vprintf+0x32>
        state = '%';
     ffa:	89d2                	mv	s3,s4
     ffc:	b7f5                	j	fe8 <vprintf+0x44>
      if(c == 'd'){
     ffe:	13490263          	beq	s2,s4,1122 <vprintf+0x17e>
    1002:	f9d9079b          	addiw	a5,s2,-99
    1006:	0ff7f793          	zext.b	a5,a5
    100a:	12fb6563          	bltu	s6,a5,1134 <vprintf+0x190>
    100e:	f9d9079b          	addiw	a5,s2,-99
    1012:	0ff7f713          	zext.b	a4,a5
    1016:	10eb6f63          	bltu	s6,a4,1134 <vprintf+0x190>
    101a:	00271793          	slli	a5,a4,0x2
    101e:	00000717          	auipc	a4,0x0
    1022:	67270713          	addi	a4,a4,1650 # 1690 <malloc+0x43a>
    1026:	97ba                	add	a5,a5,a4
    1028:	439c                	lw	a5,0(a5)
    102a:	97ba                	add	a5,a5,a4
    102c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    102e:	008b8913          	addi	s2,s7,8
    1032:	4685                	li	a3,1
    1034:	4629                	li	a2,10
    1036:	000ba583          	lw	a1,0(s7)
    103a:	8556                	mv	a0,s5
    103c:	00000097          	auipc	ra,0x0
    1040:	ebc080e7          	jalr	-324(ra) # ef8 <printint>
    1044:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1046:	4981                	li	s3,0
    1048:	b745                	j	fe8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    104a:	008b8913          	addi	s2,s7,8
    104e:	4681                	li	a3,0
    1050:	4629                	li	a2,10
    1052:	000ba583          	lw	a1,0(s7)
    1056:	8556                	mv	a0,s5
    1058:	00000097          	auipc	ra,0x0
    105c:	ea0080e7          	jalr	-352(ra) # ef8 <printint>
    1060:	8bca                	mv	s7,s2
      state = 0;
    1062:	4981                	li	s3,0
    1064:	b751                	j	fe8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
    1066:	008b8913          	addi	s2,s7,8
    106a:	4681                	li	a3,0
    106c:	4641                	li	a2,16
    106e:	000ba583          	lw	a1,0(s7)
    1072:	8556                	mv	a0,s5
    1074:	00000097          	auipc	ra,0x0
    1078:	e84080e7          	jalr	-380(ra) # ef8 <printint>
    107c:	8bca                	mv	s7,s2
      state = 0;
    107e:	4981                	li	s3,0
    1080:	b7a5                	j	fe8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
    1082:	008b8c13          	addi	s8,s7,8
    1086:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    108a:	03000593          	li	a1,48
    108e:	8556                	mv	a0,s5
    1090:	00000097          	auipc	ra,0x0
    1094:	e46080e7          	jalr	-442(ra) # ed6 <putc>
  putc(fd, 'x');
    1098:	07800593          	li	a1,120
    109c:	8556                	mv	a0,s5
    109e:	00000097          	auipc	ra,0x0
    10a2:	e38080e7          	jalr	-456(ra) # ed6 <putc>
    10a6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10a8:	00000b97          	auipc	s7,0x0
    10ac:	640b8b93          	addi	s7,s7,1600 # 16e8 <digits>
    10b0:	03c9d793          	srli	a5,s3,0x3c
    10b4:	97de                	add	a5,a5,s7
    10b6:	0007c583          	lbu	a1,0(a5)
    10ba:	8556                	mv	a0,s5
    10bc:	00000097          	auipc	ra,0x0
    10c0:	e1a080e7          	jalr	-486(ra) # ed6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    10c4:	0992                	slli	s3,s3,0x4
    10c6:	397d                	addiw	s2,s2,-1
    10c8:	fe0914e3          	bnez	s2,10b0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    10cc:	8be2                	mv	s7,s8
      state = 0;
    10ce:	4981                	li	s3,0
    10d0:	bf21                	j	fe8 <vprintf+0x44>
        s = va_arg(ap, char*);
    10d2:	008b8993          	addi	s3,s7,8
    10d6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    10da:	02090163          	beqz	s2,10fc <vprintf+0x158>
        while(*s != 0){
    10de:	00094583          	lbu	a1,0(s2)
    10e2:	c9a5                	beqz	a1,1152 <vprintf+0x1ae>
          putc(fd, *s);
    10e4:	8556                	mv	a0,s5
    10e6:	00000097          	auipc	ra,0x0
    10ea:	df0080e7          	jalr	-528(ra) # ed6 <putc>
          s++;
    10ee:	0905                	addi	s2,s2,1
        while(*s != 0){
    10f0:	00094583          	lbu	a1,0(s2)
    10f4:	f9e5                	bnez	a1,10e4 <vprintf+0x140>
        s = va_arg(ap, char*);
    10f6:	8bce                	mv	s7,s3
      state = 0;
    10f8:	4981                	li	s3,0
    10fa:	b5fd                	j	fe8 <vprintf+0x44>
          s = "(null)";
    10fc:	00000917          	auipc	s2,0x0
    1100:	58c90913          	addi	s2,s2,1420 # 1688 <malloc+0x432>
        while(*s != 0){
    1104:	02800593          	li	a1,40
    1108:	bff1                	j	10e4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
    110a:	008b8913          	addi	s2,s7,8
    110e:	000bc583          	lbu	a1,0(s7)
    1112:	8556                	mv	a0,s5
    1114:	00000097          	auipc	ra,0x0
    1118:	dc2080e7          	jalr	-574(ra) # ed6 <putc>
    111c:	8bca                	mv	s7,s2
      state = 0;
    111e:	4981                	li	s3,0
    1120:	b5e1                	j	fe8 <vprintf+0x44>
        putc(fd, c);
    1122:	02500593          	li	a1,37
    1126:	8556                	mv	a0,s5
    1128:	00000097          	auipc	ra,0x0
    112c:	dae080e7          	jalr	-594(ra) # ed6 <putc>
      state = 0;
    1130:	4981                	li	s3,0
    1132:	bd5d                	j	fe8 <vprintf+0x44>
        putc(fd, '%');
    1134:	02500593          	li	a1,37
    1138:	8556                	mv	a0,s5
    113a:	00000097          	auipc	ra,0x0
    113e:	d9c080e7          	jalr	-612(ra) # ed6 <putc>
        putc(fd, c);
    1142:	85ca                	mv	a1,s2
    1144:	8556                	mv	a0,s5
    1146:	00000097          	auipc	ra,0x0
    114a:	d90080e7          	jalr	-624(ra) # ed6 <putc>
      state = 0;
    114e:	4981                	li	s3,0
    1150:	bd61                	j	fe8 <vprintf+0x44>
        s = va_arg(ap, char*);
    1152:	8bce                	mv	s7,s3
      state = 0;
    1154:	4981                	li	s3,0
    1156:	bd49                	j	fe8 <vprintf+0x44>
    }
  }
}
    1158:	60a6                	ld	ra,72(sp)
    115a:	6406                	ld	s0,64(sp)
    115c:	74e2                	ld	s1,56(sp)
    115e:	7942                	ld	s2,48(sp)
    1160:	79a2                	ld	s3,40(sp)
    1162:	7a02                	ld	s4,32(sp)
    1164:	6ae2                	ld	s5,24(sp)
    1166:	6b42                	ld	s6,16(sp)
    1168:	6ba2                	ld	s7,8(sp)
    116a:	6c02                	ld	s8,0(sp)
    116c:	6161                	addi	sp,sp,80
    116e:	8082                	ret

0000000000001170 <fprintf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

void
fprintf(int fd, const char *fmt, ...)
{
<<<<<<< HEAD
    11e6:	715d                	addi	sp,sp,-80
    11e8:	ec06                	sd	ra,24(sp)
    11ea:	e822                	sd	s0,16(sp)
    11ec:	1000                	addi	s0,sp,32
    11ee:	e010                	sd	a2,0(s0)
    11f0:	e414                	sd	a3,8(s0)
    11f2:	e818                	sd	a4,16(s0)
    11f4:	ec1c                	sd	a5,24(s0)
    11f6:	03043023          	sd	a6,32(s0)
    11fa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11fe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1202:	8622                	mv	a2,s0
    1204:	00000097          	auipc	ra,0x0
    1208:	e04080e7          	jalr	-508(ra) # 1008 <vprintf>
}
    120c:	60e2                	ld	ra,24(sp)
    120e:	6442                	ld	s0,16(sp)
    1210:	6161                	addi	sp,sp,80
    1212:	8082                	ret

0000000000001214 <printf>:
=======
    1170:	715d                	addi	sp,sp,-80
    1172:	ec06                	sd	ra,24(sp)
    1174:	e822                	sd	s0,16(sp)
    1176:	1000                	addi	s0,sp,32
    1178:	e010                	sd	a2,0(s0)
    117a:	e414                	sd	a3,8(s0)
    117c:	e818                	sd	a4,16(s0)
    117e:	ec1c                	sd	a5,24(s0)
    1180:	03043023          	sd	a6,32(s0)
    1184:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1188:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    118c:	8622                	mv	a2,s0
    118e:	00000097          	auipc	ra,0x0
    1192:	e16080e7          	jalr	-490(ra) # fa4 <vprintf>
}
    1196:	60e2                	ld	ra,24(sp)
    1198:	6442                	ld	s0,16(sp)
    119a:	6161                	addi	sp,sp,80
    119c:	8082                	ret

000000000000119e <printf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

void
printf(const char *fmt, ...)
{
<<<<<<< HEAD
    1214:	711d                	addi	sp,sp,-96
    1216:	ec06                	sd	ra,24(sp)
    1218:	e822                	sd	s0,16(sp)
    121a:	1000                	addi	s0,sp,32
    121c:	e40c                	sd	a1,8(s0)
    121e:	e810                	sd	a2,16(s0)
    1220:	ec14                	sd	a3,24(s0)
    1222:	f018                	sd	a4,32(s0)
    1224:	f41c                	sd	a5,40(s0)
    1226:	03043823          	sd	a6,48(s0)
    122a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    122e:	00840613          	addi	a2,s0,8
    1232:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1236:	85aa                	mv	a1,a0
    1238:	4505                	li	a0,1
    123a:	00000097          	auipc	ra,0x0
    123e:	dce080e7          	jalr	-562(ra) # 1008 <vprintf>
}
    1242:	60e2                	ld	ra,24(sp)
    1244:	6442                	ld	s0,16(sp)
    1246:	6125                	addi	sp,sp,96
    1248:	8082                	ret

000000000000124a <free>:
=======
    119e:	711d                	addi	sp,sp,-96
    11a0:	ec06                	sd	ra,24(sp)
    11a2:	e822                	sd	s0,16(sp)
    11a4:	1000                	addi	s0,sp,32
    11a6:	e40c                	sd	a1,8(s0)
    11a8:	e810                	sd	a2,16(s0)
    11aa:	ec14                	sd	a3,24(s0)
    11ac:	f018                	sd	a4,32(s0)
    11ae:	f41c                	sd	a5,40(s0)
    11b0:	03043823          	sd	a6,48(s0)
    11b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11b8:	00840613          	addi	a2,s0,8
    11bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11c0:	85aa                	mv	a1,a0
    11c2:	4505                	li	a0,1
    11c4:	00000097          	auipc	ra,0x0
    11c8:	de0080e7          	jalr	-544(ra) # fa4 <vprintf>
}
    11cc:	60e2                	ld	ra,24(sp)
    11ce:	6442                	ld	s0,16(sp)
    11d0:	6125                	addi	sp,sp,96
    11d2:	8082                	ret

00000000000011d4 <free>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
static Header base;
static Header *freep;

void
free(void *ap)
{
<<<<<<< HEAD
    124a:	1141                	addi	sp,sp,-16
    124c:	e422                	sd	s0,8(sp)
    124e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1250:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1254:	00001797          	auipc	a5,0x1
    1258:	dbc7b783          	ld	a5,-580(a5) # 2010 <freep>
    125c:	a805                	j	128c <free+0x42>
=======
    11d4:	1141                	addi	sp,sp,-16
    11d6:	e422                	sd	s0,8(sp)
    11d8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11da:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11de:	00001797          	auipc	a5,0x1
    11e2:	e327b783          	ld	a5,-462(a5) # 2010 <freep>
    11e6:	a02d                	j	1210 <free+0x3c>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
<<<<<<< HEAD
    125e:	4618                	lw	a4,8(a2)
    1260:	9db9                	addw	a1,a1,a4
    1262:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1266:	6398                	ld	a4,0(a5)
    1268:	6318                	ld	a4,0(a4)
    126a:	fee53823          	sd	a4,-16(a0)
    126e:	a091                	j	12b2 <free+0x68>
=======
    11e8:	4618                	lw	a4,8(a2)
    11ea:	9f2d                	addw	a4,a4,a1
    11ec:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11f0:	6398                	ld	a4,0(a5)
    11f2:	6310                	ld	a2,0(a4)
    11f4:	a83d                	j	1232 <free+0x5e>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
<<<<<<< HEAD
    1270:	ff852703          	lw	a4,-8(a0)
    1274:	9e39                	addw	a2,a2,a4
    1276:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1278:	ff053703          	ld	a4,-16(a0)
    127c:	e398                	sd	a4,0(a5)
    127e:	a099                	j	12c4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1280:	6398                	ld	a4,0(a5)
    1282:	00e7e463          	bltu	a5,a4,128a <free+0x40>
    1286:	00e6ea63          	bltu	a3,a4,129a <free+0x50>
{
    128a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    128c:	fed7fae3          	bgeu	a5,a3,1280 <free+0x36>
    1290:	6398                	ld	a4,0(a5)
    1292:	00e6e463          	bltu	a3,a4,129a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1296:	fee7eae3          	bltu	a5,a4,128a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    129a:	ff852583          	lw	a1,-8(a0)
    129e:	6390                	ld	a2,0(a5)
    12a0:	02059713          	slli	a4,a1,0x20
    12a4:	9301                	srli	a4,a4,0x20
    12a6:	0712                	slli	a4,a4,0x4
    12a8:	9736                	add	a4,a4,a3
    12aa:	fae60ae3          	beq	a2,a4,125e <free+0x14>
    bp->s.ptr = p->s.ptr;
    12ae:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12b2:	4790                	lw	a2,8(a5)
    12b4:	02061713          	slli	a4,a2,0x20
    12b8:	9301                	srli	a4,a4,0x20
    12ba:	0712                	slli	a4,a4,0x4
    12bc:	973e                	add	a4,a4,a5
    12be:	fae689e3          	beq	a3,a4,1270 <free+0x26>
  } else
    p->s.ptr = bp;
    12c2:	e394                	sd	a3,0(a5)
  freep = p;
    12c4:	00001717          	auipc	a4,0x1
    12c8:	d4f73623          	sd	a5,-692(a4) # 2010 <freep>
}
    12cc:	6422                	ld	s0,8(sp)
    12ce:	0141                	addi	sp,sp,16
    12d0:	8082                	ret

00000000000012d2 <malloc>:
=======
    11f6:	ff852703          	lw	a4,-8(a0)
    11fa:	9f31                	addw	a4,a4,a2
    11fc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11fe:	ff053683          	ld	a3,-16(a0)
    1202:	a091                	j	1246 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1204:	6398                	ld	a4,0(a5)
    1206:	00e7e463          	bltu	a5,a4,120e <free+0x3a>
    120a:	00e6ea63          	bltu	a3,a4,121e <free+0x4a>
{
    120e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1210:	fed7fae3          	bgeu	a5,a3,1204 <free+0x30>
    1214:	6398                	ld	a4,0(a5)
    1216:	00e6e463          	bltu	a3,a4,121e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    121a:	fee7eae3          	bltu	a5,a4,120e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    121e:	ff852583          	lw	a1,-8(a0)
    1222:	6390                	ld	a2,0(a5)
    1224:	02059813          	slli	a6,a1,0x20
    1228:	01c85713          	srli	a4,a6,0x1c
    122c:	9736                	add	a4,a4,a3
    122e:	fae60de3          	beq	a2,a4,11e8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1232:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1236:	4790                	lw	a2,8(a5)
    1238:	02061593          	slli	a1,a2,0x20
    123c:	01c5d713          	srli	a4,a1,0x1c
    1240:	973e                	add	a4,a4,a5
    1242:	fae68ae3          	beq	a3,a4,11f6 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1246:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1248:	00001717          	auipc	a4,0x1
    124c:	dcf73423          	sd	a5,-568(a4) # 2010 <freep>
}
    1250:	6422                	ld	s0,8(sp)
    1252:	0141                	addi	sp,sp,16
    1254:	8082                	ret

0000000000001256 <malloc>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  return freep;
}

void*
malloc(uint nbytes)
{
<<<<<<< HEAD
    12d2:	7139                	addi	sp,sp,-64
    12d4:	fc06                	sd	ra,56(sp)
    12d6:	f822                	sd	s0,48(sp)
    12d8:	f426                	sd	s1,40(sp)
    12da:	f04a                	sd	s2,32(sp)
    12dc:	ec4e                	sd	s3,24(sp)
    12de:	e852                	sd	s4,16(sp)
    12e0:	e456                	sd	s5,8(sp)
    12e2:	e05a                	sd	s6,0(sp)
    12e4:	0080                	addi	s0,sp,64
=======
    1256:	7139                	addi	sp,sp,-64
    1258:	fc06                	sd	ra,56(sp)
    125a:	f822                	sd	s0,48(sp)
    125c:	f426                	sd	s1,40(sp)
    125e:	f04a                	sd	s2,32(sp)
    1260:	ec4e                	sd	s3,24(sp)
    1262:	e852                	sd	s4,16(sp)
    1264:	e456                	sd	s5,8(sp)
    1266:	e05a                	sd	s6,0(sp)
    1268:	0080                	addi	s0,sp,64
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
<<<<<<< HEAD
    12e6:	02051493          	slli	s1,a0,0x20
    12ea:	9081                	srli	s1,s1,0x20
    12ec:	04bd                	addi	s1,s1,15
    12ee:	8091                	srli	s1,s1,0x4
    12f0:	0014899b          	addiw	s3,s1,1
    12f4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12f6:	00001517          	auipc	a0,0x1
    12fa:	d1a53503          	ld	a0,-742(a0) # 2010 <freep>
    12fe:	c515                	beqz	a0,132a <malloc+0x58>
=======
    126a:	02051493          	slli	s1,a0,0x20
    126e:	9081                	srli	s1,s1,0x20
    1270:	04bd                	addi	s1,s1,15
    1272:	8091                	srli	s1,s1,0x4
    1274:	0014899b          	addiw	s3,s1,1
    1278:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    127a:	00001517          	auipc	a0,0x1
    127e:	d9653503          	ld	a0,-618(a0) # 2010 <freep>
    1282:	c515                	beqz	a0,12ae <malloc+0x58>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
<<<<<<< HEAD
    1300:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1302:	4798                	lw	a4,8(a5)
    1304:	02977f63          	bgeu	a4,s1,1342 <malloc+0x70>
    1308:	8a4e                	mv	s4,s3
    130a:	0009871b          	sext.w	a4,s3
    130e:	6685                	lui	a3,0x1
    1310:	00d77363          	bgeu	a4,a3,1316 <malloc+0x44>
    1314:	6a05                	lui	s4,0x1
    1316:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    131a:	004a1a1b          	slliw	s4,s4,0x4
=======
    1284:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1286:	4798                	lw	a4,8(a5)
    1288:	02977f63          	bgeu	a4,s1,12c6 <malloc+0x70>
  if(nu < 4096)
    128c:	8a4e                	mv	s4,s3
    128e:	0009871b          	sext.w	a4,s3
    1292:	6685                	lui	a3,0x1
    1294:	00d77363          	bgeu	a4,a3,129a <malloc+0x44>
    1298:	6a05                	lui	s4,0x1
    129a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    129e:	004a1a1b          	slliw	s4,s4,0x4
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
<<<<<<< HEAD
    131e:	00001917          	auipc	s2,0x1
    1322:	cf290913          	addi	s2,s2,-782 # 2010 <freep>
  if(p == (char*)-1)
    1326:	5afd                	li	s5,-1
    1328:	a88d                	j	139a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    132a:	00001797          	auipc	a5,0x1
    132e:	0de78793          	addi	a5,a5,222 # 2408 <base>
    1332:	00001717          	auipc	a4,0x1
    1336:	ccf73f23          	sd	a5,-802(a4) # 2010 <freep>
    133a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    133c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1340:	b7e1                	j	1308 <malloc+0x36>
      if(p->s.size == nunits)
    1342:	02e48b63          	beq	s1,a4,1378 <malloc+0xa6>
        p->s.size -= nunits;
    1346:	4137073b          	subw	a4,a4,s3
    134a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    134c:	1702                	slli	a4,a4,0x20
    134e:	9301                	srli	a4,a4,0x20
    1350:	0712                	slli	a4,a4,0x4
    1352:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1354:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1358:	00001717          	auipc	a4,0x1
    135c:	caa73c23          	sd	a0,-840(a4) # 2010 <freep>
      return (void*)(p + 1);
    1360:	01078513          	addi	a0,a5,16
=======
    12a2:	00001917          	auipc	s2,0x1
    12a6:	d6e90913          	addi	s2,s2,-658 # 2010 <freep>
  if(p == (char*)-1)
    12aa:	5afd                	li	s5,-1
    12ac:	a895                	j	1320 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    12ae:	00001797          	auipc	a5,0x1
    12b2:	15a78793          	addi	a5,a5,346 # 2408 <base>
    12b6:	00001717          	auipc	a4,0x1
    12ba:	d4f73d23          	sd	a5,-678(a4) # 2010 <freep>
    12be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12c4:	b7e1                	j	128c <malloc+0x36>
      if(p->s.size == nunits)
    12c6:	02e48c63          	beq	s1,a4,12fe <malloc+0xa8>
        p->s.size -= nunits;
    12ca:	4137073b          	subw	a4,a4,s3
    12ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
    12d0:	02071693          	slli	a3,a4,0x20
    12d4:	01c6d713          	srli	a4,a3,0x1c
    12d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    12da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    12de:	00001717          	auipc	a4,0x1
    12e2:	d2a73923          	sd	a0,-718(a4) # 2010 <freep>
      return (void*)(p + 1);
    12e6:	01078513          	addi	a0,a5,16
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
<<<<<<< HEAD
    1364:	70e2                	ld	ra,56(sp)
    1366:	7442                	ld	s0,48(sp)
    1368:	74a2                	ld	s1,40(sp)
    136a:	7902                	ld	s2,32(sp)
    136c:	69e2                	ld	s3,24(sp)
    136e:	6a42                	ld	s4,16(sp)
    1370:	6aa2                	ld	s5,8(sp)
    1372:	6b02                	ld	s6,0(sp)
    1374:	6121                	addi	sp,sp,64
    1376:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1378:	6398                	ld	a4,0(a5)
    137a:	e118                	sd	a4,0(a0)
    137c:	bff1                	j	1358 <malloc+0x86>
  hp->s.size = nu;
    137e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1382:	0541                	addi	a0,a0,16
    1384:	00000097          	auipc	ra,0x0
    1388:	ec6080e7          	jalr	-314(ra) # 124a <free>
  return freep;
    138c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1390:	d971                	beqz	a0,1364 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1392:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1394:	4798                	lw	a4,8(a5)
    1396:	fa9776e3          	bgeu	a4,s1,1342 <malloc+0x70>
    if(p == freep)
    139a:	00093703          	ld	a4,0(s2)
    139e:	853e                	mv	a0,a5
    13a0:	fef719e3          	bne	a4,a5,1392 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    13a4:	8552                	mv	a0,s4
    13a6:	00000097          	auipc	ra,0x0
    13aa:	b76080e7          	jalr	-1162(ra) # f1c <sbrk>
  if(p == (char*)-1)
    13ae:	fd5518e3          	bne	a0,s5,137e <malloc+0xac>
        return 0;
    13b2:	4501                	li	a0,0
    13b4:	bf45                	j	1364 <malloc+0x92>
=======
    12ea:	70e2                	ld	ra,56(sp)
    12ec:	7442                	ld	s0,48(sp)
    12ee:	74a2                	ld	s1,40(sp)
    12f0:	7902                	ld	s2,32(sp)
    12f2:	69e2                	ld	s3,24(sp)
    12f4:	6a42                	ld	s4,16(sp)
    12f6:	6aa2                	ld	s5,8(sp)
    12f8:	6b02                	ld	s6,0(sp)
    12fa:	6121                	addi	sp,sp,64
    12fc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    12fe:	6398                	ld	a4,0(a5)
    1300:	e118                	sd	a4,0(a0)
    1302:	bff1                	j	12de <malloc+0x88>
  hp->s.size = nu;
    1304:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1308:	0541                	addi	a0,a0,16
    130a:	00000097          	auipc	ra,0x0
    130e:	eca080e7          	jalr	-310(ra) # 11d4 <free>
  return freep;
    1312:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1316:	d971                	beqz	a0,12ea <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1318:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    131a:	4798                	lw	a4,8(a5)
    131c:	fa9775e3          	bgeu	a4,s1,12c6 <malloc+0x70>
    if(p == freep)
    1320:	00093703          	ld	a4,0(s2)
    1324:	853e                	mv	a0,a5
    1326:	fef719e3          	bne	a4,a5,1318 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    132a:	8552                	mv	a0,s4
    132c:	00000097          	auipc	ra,0x0
    1330:	b8a080e7          	jalr	-1142(ra) # eb6 <sbrk>
  if(p == (char*)-1)
    1334:	fd5518e3          	bne	a0,s5,1304 <malloc+0xae>
        return 0;
    1338:	4501                	li	a0,0
    133a:	bf45                	j	12ea <malloc+0x94>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
