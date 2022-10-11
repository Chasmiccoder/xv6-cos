
user/_strace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  // if not enough arguments, print usage and exit
  if(argc < 3){
   a:	4789                	li	a5,2
   c:	02a7c063          	blt	a5,a0,2c <main+0x2c>
    fprintf(2, "usage: strace mask command args...\n");
  10:	00000597          	auipc	a1,0x0
  14:	7e058593          	addi	a1,a1,2016 # 7f0 <malloc+0xea>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	606080e7          	jalr	1542(ra) # 620 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2ba080e7          	jalr	698(ra) # 2de <exit>
  2c:	84ae                	mv	s1,a1
  }

  trace(atoi(argv[1])); // trace system calls with mask
  2e:	6588                	ld	a0,8(a1)
  30:	00000097          	auipc	ra,0x0
  34:	1b4080e7          	jalr	436(ra) # 1e4 <atoi>
  38:	00000097          	auipc	ra,0x0
  3c:	346080e7          	jalr	838(ra) # 37e <trace>
  exec(argv[2], &argv[2]);  // execute command
  40:	01048593          	addi	a1,s1,16
  44:	6888                	ld	a0,16(s1)
  46:	00000097          	auipc	ra,0x0
  4a:	2d0080e7          	jalr	720(ra) # 316 <exec>

  exit(0);
  4e:	4501                	li	a0,0
  50:	00000097          	auipc	ra,0x0
  54:	28e080e7          	jalr	654(ra) # 2de <exit>

0000000000000058 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  58:	1141                	addi	sp,sp,-16
  5a:	e406                	sd	ra,8(sp)
  5c:	e022                	sd	s0,0(sp)
  5e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  60:	00000097          	auipc	ra,0x0
  64:	fa0080e7          	jalr	-96(ra) # 0 <main>
  exit(0);
  68:	4501                	li	a0,0
  6a:	00000097          	auipc	ra,0x0
  6e:	274080e7          	jalr	628(ra) # 2de <exit>

0000000000000072 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  78:	87aa                	mv	a5,a0
  7a:	0585                	addi	a1,a1,1
  7c:	0785                	addi	a5,a5,1
  7e:	fff5c703          	lbu	a4,-1(a1)
  82:	fee78fa3          	sb	a4,-1(a5)
  86:	fb75                	bnez	a4,7a <strcpy+0x8>
    ;
  return os;
}
  88:	6422                	ld	s0,8(sp)
  8a:	0141                	addi	sp,sp,16
  8c:	8082                	ret

000000000000008e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  94:	00054783          	lbu	a5,0(a0)
  98:	cb91                	beqz	a5,ac <strcmp+0x1e>
  9a:	0005c703          	lbu	a4,0(a1)
  9e:	00f71763          	bne	a4,a5,ac <strcmp+0x1e>
    p++, q++;
  a2:	0505                	addi	a0,a0,1
  a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	fbe5                	bnez	a5,9a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ac:	0005c503          	lbu	a0,0(a1)
}
  b0:	40a7853b          	subw	a0,a5,a0
  b4:	6422                	ld	s0,8(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret

00000000000000ba <strlen>:

uint
strlen(const char *s)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	cf91                	beqz	a5,e0 <strlen+0x26>
  c6:	0505                	addi	a0,a0,1
  c8:	87aa                	mv	a5,a0
  ca:	86be                	mv	a3,a5
  cc:	0785                	addi	a5,a5,1
  ce:	fff7c703          	lbu	a4,-1(a5)
  d2:	ff65                	bnez	a4,ca <strlen+0x10>
  d4:	40a6853b          	subw	a0,a3,a0
  d8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  da:	6422                	ld	s0,8(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret
  for(n = 0; s[n]; n++)
  e0:	4501                	li	a0,0
  e2:	bfe5                	j	da <strlen+0x20>

00000000000000e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ea:	ca19                	beqz	a2,100 <memset+0x1c>
  ec:	87aa                	mv	a5,a0
  ee:	1602                	slli	a2,a2,0x20
  f0:	9201                	srli	a2,a2,0x20
  f2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  fa:	0785                	addi	a5,a5,1
  fc:	fee79de3          	bne	a5,a4,f6 <memset+0x12>
  }
  return dst;
}
 100:	6422                	ld	s0,8(sp)
 102:	0141                	addi	sp,sp,16
 104:	8082                	ret

0000000000000106 <strchr>:

char*
strchr(const char *s, char c)
{
 106:	1141                	addi	sp,sp,-16
 108:	e422                	sd	s0,8(sp)
 10a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 10c:	00054783          	lbu	a5,0(a0)
 110:	cb99                	beqz	a5,126 <strchr+0x20>
    if(*s == c)
 112:	00f58763          	beq	a1,a5,120 <strchr+0x1a>
  for(; *s; s++)
 116:	0505                	addi	a0,a0,1
 118:	00054783          	lbu	a5,0(a0)
 11c:	fbfd                	bnez	a5,112 <strchr+0xc>
      return (char*)s;
  return 0;
 11e:	4501                	li	a0,0
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret
  return 0;
 126:	4501                	li	a0,0
 128:	bfe5                	j	120 <strchr+0x1a>

000000000000012a <gets>:

char*
gets(char *buf, int max)
{
 12a:	711d                	addi	sp,sp,-96
 12c:	ec86                	sd	ra,88(sp)
 12e:	e8a2                	sd	s0,80(sp)
 130:	e4a6                	sd	s1,72(sp)
 132:	e0ca                	sd	s2,64(sp)
 134:	fc4e                	sd	s3,56(sp)
 136:	f852                	sd	s4,48(sp)
 138:	f456                	sd	s5,40(sp)
 13a:	f05a                	sd	s6,32(sp)
 13c:	ec5e                	sd	s7,24(sp)
 13e:	1080                	addi	s0,sp,96
 140:	8baa                	mv	s7,a0
 142:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 144:	892a                	mv	s2,a0
 146:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 148:	4aa9                	li	s5,10
 14a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 14c:	89a6                	mv	s3,s1
 14e:	2485                	addiw	s1,s1,1
 150:	0344d863          	bge	s1,s4,180 <gets+0x56>
    cc = read(0, &c, 1);
 154:	4605                	li	a2,1
 156:	faf40593          	addi	a1,s0,-81
 15a:	4501                	li	a0,0
 15c:	00000097          	auipc	ra,0x0
 160:	19a080e7          	jalr	410(ra) # 2f6 <read>
    if(cc < 1)
 164:	00a05e63          	blez	a0,180 <gets+0x56>
    buf[i++] = c;
 168:	faf44783          	lbu	a5,-81(s0)
 16c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 170:	01578763          	beq	a5,s5,17e <gets+0x54>
 174:	0905                	addi	s2,s2,1
 176:	fd679be3          	bne	a5,s6,14c <gets+0x22>
  for(i=0; i+1 < max; ){
 17a:	89a6                	mv	s3,s1
 17c:	a011                	j	180 <gets+0x56>
 17e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 180:	99de                	add	s3,s3,s7
 182:	00098023          	sb	zero,0(s3)
  return buf;
}
 186:	855e                	mv	a0,s7
 188:	60e6                	ld	ra,88(sp)
 18a:	6446                	ld	s0,80(sp)
 18c:	64a6                	ld	s1,72(sp)
 18e:	6906                	ld	s2,64(sp)
 190:	79e2                	ld	s3,56(sp)
 192:	7a42                	ld	s4,48(sp)
 194:	7aa2                	ld	s5,40(sp)
 196:	7b02                	ld	s6,32(sp)
 198:	6be2                	ld	s7,24(sp)
 19a:	6125                	addi	sp,sp,96
 19c:	8082                	ret

000000000000019e <stat>:

int
stat(const char *n, struct stat *st)
{
 19e:	1101                	addi	sp,sp,-32
 1a0:	ec06                	sd	ra,24(sp)
 1a2:	e822                	sd	s0,16(sp)
 1a4:	e426                	sd	s1,8(sp)
 1a6:	e04a                	sd	s2,0(sp)
 1a8:	1000                	addi	s0,sp,32
 1aa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ac:	4581                	li	a1,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	170080e7          	jalr	368(ra) # 31e <open>
  if(fd < 0)
 1b6:	02054563          	bltz	a0,1e0 <stat+0x42>
 1ba:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1bc:	85ca                	mv	a1,s2
 1be:	00000097          	auipc	ra,0x0
 1c2:	178080e7          	jalr	376(ra) # 336 <fstat>
 1c6:	892a                	mv	s2,a0
  close(fd);
 1c8:	8526                	mv	a0,s1
 1ca:	00000097          	auipc	ra,0x0
 1ce:	13c080e7          	jalr	316(ra) # 306 <close>
  return r;
}
 1d2:	854a                	mv	a0,s2
 1d4:	60e2                	ld	ra,24(sp)
 1d6:	6442                	ld	s0,16(sp)
 1d8:	64a2                	ld	s1,8(sp)
 1da:	6902                	ld	s2,0(sp)
 1dc:	6105                	addi	sp,sp,32
 1de:	8082                	ret
    return -1;
 1e0:	597d                	li	s2,-1
 1e2:	bfc5                	j	1d2 <stat+0x34>

00000000000001e4 <atoi>:

int
atoi(const char *s)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ea:	00054683          	lbu	a3,0(a0)
 1ee:	fd06879b          	addiw	a5,a3,-48
 1f2:	0ff7f793          	zext.b	a5,a5
 1f6:	4625                	li	a2,9
 1f8:	02f66863          	bltu	a2,a5,228 <atoi+0x44>
 1fc:	872a                	mv	a4,a0
  n = 0;
 1fe:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 200:	0705                	addi	a4,a4,1
 202:	0025179b          	slliw	a5,a0,0x2
 206:	9fa9                	addw	a5,a5,a0
 208:	0017979b          	slliw	a5,a5,0x1
 20c:	9fb5                	addw	a5,a5,a3
 20e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 212:	00074683          	lbu	a3,0(a4)
 216:	fd06879b          	addiw	a5,a3,-48
 21a:	0ff7f793          	zext.b	a5,a5
 21e:	fef671e3          	bgeu	a2,a5,200 <atoi+0x1c>
  return n;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
  n = 0;
 228:	4501                	li	a0,0
 22a:	bfe5                	j	222 <atoi+0x3e>

000000000000022c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 232:	02b57463          	bgeu	a0,a1,25a <memmove+0x2e>
    while(n-- > 0)
 236:	00c05f63          	blez	a2,254 <memmove+0x28>
 23a:	1602                	slli	a2,a2,0x20
 23c:	9201                	srli	a2,a2,0x20
 23e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 242:	872a                	mv	a4,a0
      *dst++ = *src++;
 244:	0585                	addi	a1,a1,1
 246:	0705                	addi	a4,a4,1
 248:	fff5c683          	lbu	a3,-1(a1)
 24c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 250:	fee79ae3          	bne	a5,a4,244 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
    dst += n;
 25a:	00c50733          	add	a4,a0,a2
    src += n;
 25e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 260:	fec05ae3          	blez	a2,254 <memmove+0x28>
 264:	fff6079b          	addiw	a5,a2,-1
 268:	1782                	slli	a5,a5,0x20
 26a:	9381                	srli	a5,a5,0x20
 26c:	fff7c793          	not	a5,a5
 270:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 272:	15fd                	addi	a1,a1,-1
 274:	177d                	addi	a4,a4,-1
 276:	0005c683          	lbu	a3,0(a1)
 27a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 27e:	fee79ae3          	bne	a5,a4,272 <memmove+0x46>
 282:	bfc9                	j	254 <memmove+0x28>

0000000000000284 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 28a:	ca05                	beqz	a2,2ba <memcmp+0x36>
 28c:	fff6069b          	addiw	a3,a2,-1
 290:	1682                	slli	a3,a3,0x20
 292:	9281                	srli	a3,a3,0x20
 294:	0685                	addi	a3,a3,1
 296:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 298:	00054783          	lbu	a5,0(a0)
 29c:	0005c703          	lbu	a4,0(a1)
 2a0:	00e79863          	bne	a5,a4,2b0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2a4:	0505                	addi	a0,a0,1
    p2++;
 2a6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2a8:	fed518e3          	bne	a0,a3,298 <memcmp+0x14>
  }
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	a019                	j	2b4 <memcmp+0x30>
      return *p1 - *p2;
 2b0:	40e7853b          	subw	a0,a5,a4
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
  return 0;
 2ba:	4501                	li	a0,0
 2bc:	bfe5                	j	2b4 <memcmp+0x30>

00000000000002be <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e406                	sd	ra,8(sp)
 2c2:	e022                	sd	s0,0(sp)
 2c4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2c6:	00000097          	auipc	ra,0x0
 2ca:	f66080e7          	jalr	-154(ra) # 22c <memmove>
}
 2ce:	60a2                	ld	ra,8(sp)
 2d0:	6402                	ld	s0,0(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret

00000000000002d6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2d6:	4885                	li	a7,1
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <exit>:
.global exit
exit:
 li a7, SYS_exit
 2de:	4889                	li	a7,2
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2e6:	488d                	li	a7,3
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ee:	4891                	li	a7,4
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <read>:
.global read
read:
 li a7, SYS_read
 2f6:	4895                	li	a7,5
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <write>:
.global write
write:
 li a7, SYS_write
 2fe:	48c1                	li	a7,16
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <close>:
.global close
close:
 li a7, SYS_close
 306:	48d5                	li	a7,21
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <kill>:
.global kill
kill:
 li a7, SYS_kill
 30e:	4899                	li	a7,6
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <exec>:
.global exec
exec:
 li a7, SYS_exec
 316:	489d                	li	a7,7
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <open>:
.global open
open:
 li a7, SYS_open
 31e:	48bd                	li	a7,15
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 326:	48c5                	li	a7,17
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 32e:	48c9                	li	a7,18
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 336:	48a1                	li	a7,8
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <link>:
.global link
link:
 li a7, SYS_link
 33e:	48cd                	li	a7,19
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 346:	48d1                	li	a7,20
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 34e:	48a5                	li	a7,9
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <dup>:
.global dup
dup:
 li a7, SYS_dup
 356:	48a9                	li	a7,10
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 35e:	48ad                	li	a7,11
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 366:	48b1                	li	a7,12
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 36e:	48b5                	li	a7,13
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 376:	48b9                	li	a7,14
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <trace>:
.global trace
trace:
 li a7, SYS_trace
 37e:	48d9                	li	a7,22
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 386:	1101                	addi	sp,sp,-32
 388:	ec06                	sd	ra,24(sp)
 38a:	e822                	sd	s0,16(sp)
 38c:	1000                	addi	s0,sp,32
 38e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 392:	4605                	li	a2,1
 394:	fef40593          	addi	a1,s0,-17
 398:	00000097          	auipc	ra,0x0
 39c:	f66080e7          	jalr	-154(ra) # 2fe <write>
}
 3a0:	60e2                	ld	ra,24(sp)
 3a2:	6442                	ld	s0,16(sp)
 3a4:	6105                	addi	sp,sp,32
 3a6:	8082                	ret

00000000000003a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a8:	7139                	addi	sp,sp,-64
 3aa:	fc06                	sd	ra,56(sp)
 3ac:	f822                	sd	s0,48(sp)
 3ae:	f426                	sd	s1,40(sp)
 3b0:	f04a                	sd	s2,32(sp)
 3b2:	ec4e                	sd	s3,24(sp)
 3b4:	0080                	addi	s0,sp,64
 3b6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b8:	c299                	beqz	a3,3be <printint+0x16>
 3ba:	0805c963          	bltz	a1,44c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3be:	2581                	sext.w	a1,a1
  neg = 0;
 3c0:	4881                	li	a7,0
 3c2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3c6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3c8:	2601                	sext.w	a2,a2
 3ca:	00000517          	auipc	a0,0x0
 3ce:	4ae50513          	addi	a0,a0,1198 # 878 <digits>
 3d2:	883a                	mv	a6,a4
 3d4:	2705                	addiw	a4,a4,1
 3d6:	02c5f7bb          	remuw	a5,a1,a2
 3da:	1782                	slli	a5,a5,0x20
 3dc:	9381                	srli	a5,a5,0x20
 3de:	97aa                	add	a5,a5,a0
 3e0:	0007c783          	lbu	a5,0(a5)
 3e4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3e8:	0005879b          	sext.w	a5,a1
 3ec:	02c5d5bb          	divuw	a1,a1,a2
 3f0:	0685                	addi	a3,a3,1
 3f2:	fec7f0e3          	bgeu	a5,a2,3d2 <printint+0x2a>
  if(neg)
 3f6:	00088c63          	beqz	a7,40e <printint+0x66>
    buf[i++] = '-';
 3fa:	fd070793          	addi	a5,a4,-48
 3fe:	00878733          	add	a4,a5,s0
 402:	02d00793          	li	a5,45
 406:	fef70823          	sb	a5,-16(a4)
 40a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 40e:	02e05863          	blez	a4,43e <printint+0x96>
 412:	fc040793          	addi	a5,s0,-64
 416:	00e78933          	add	s2,a5,a4
 41a:	fff78993          	addi	s3,a5,-1
 41e:	99ba                	add	s3,s3,a4
 420:	377d                	addiw	a4,a4,-1
 422:	1702                	slli	a4,a4,0x20
 424:	9301                	srli	a4,a4,0x20
 426:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 42a:	fff94583          	lbu	a1,-1(s2)
 42e:	8526                	mv	a0,s1
 430:	00000097          	auipc	ra,0x0
 434:	f56080e7          	jalr	-170(ra) # 386 <putc>
  while(--i >= 0)
 438:	197d                	addi	s2,s2,-1
 43a:	ff3918e3          	bne	s2,s3,42a <printint+0x82>
}
 43e:	70e2                	ld	ra,56(sp)
 440:	7442                	ld	s0,48(sp)
 442:	74a2                	ld	s1,40(sp)
 444:	7902                	ld	s2,32(sp)
 446:	69e2                	ld	s3,24(sp)
 448:	6121                	addi	sp,sp,64
 44a:	8082                	ret
    x = -xx;
 44c:	40b005bb          	negw	a1,a1
    neg = 1;
 450:	4885                	li	a7,1
    x = -xx;
 452:	bf85                	j	3c2 <printint+0x1a>

0000000000000454 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 454:	715d                	addi	sp,sp,-80
 456:	e486                	sd	ra,72(sp)
 458:	e0a2                	sd	s0,64(sp)
 45a:	fc26                	sd	s1,56(sp)
 45c:	f84a                	sd	s2,48(sp)
 45e:	f44e                	sd	s3,40(sp)
 460:	f052                	sd	s4,32(sp)
 462:	ec56                	sd	s5,24(sp)
 464:	e85a                	sd	s6,16(sp)
 466:	e45e                	sd	s7,8(sp)
 468:	e062                	sd	s8,0(sp)
 46a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46c:	0005c903          	lbu	s2,0(a1)
 470:	18090c63          	beqz	s2,608 <vprintf+0x1b4>
 474:	8aaa                	mv	s5,a0
 476:	8bb2                	mv	s7,a2
 478:	00158493          	addi	s1,a1,1
  state = 0;
 47c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 47e:	02500a13          	li	s4,37
 482:	4b55                	li	s6,21
 484:	a839                	j	4a2 <vprintf+0x4e>
        putc(fd, c);
 486:	85ca                	mv	a1,s2
 488:	8556                	mv	a0,s5
 48a:	00000097          	auipc	ra,0x0
 48e:	efc080e7          	jalr	-260(ra) # 386 <putc>
 492:	a019                	j	498 <vprintf+0x44>
    } else if(state == '%'){
 494:	01498d63          	beq	s3,s4,4ae <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 498:	0485                	addi	s1,s1,1
 49a:	fff4c903          	lbu	s2,-1(s1)
 49e:	16090563          	beqz	s2,608 <vprintf+0x1b4>
    if(state == 0){
 4a2:	fe0999e3          	bnez	s3,494 <vprintf+0x40>
      if(c == '%'){
 4a6:	ff4910e3          	bne	s2,s4,486 <vprintf+0x32>
        state = '%';
 4aa:	89d2                	mv	s3,s4
 4ac:	b7f5                	j	498 <vprintf+0x44>
      if(c == 'd'){
 4ae:	13490263          	beq	s2,s4,5d2 <vprintf+0x17e>
 4b2:	f9d9079b          	addiw	a5,s2,-99
 4b6:	0ff7f793          	zext.b	a5,a5
 4ba:	12fb6563          	bltu	s6,a5,5e4 <vprintf+0x190>
 4be:	f9d9079b          	addiw	a5,s2,-99
 4c2:	0ff7f713          	zext.b	a4,a5
 4c6:	10eb6f63          	bltu	s6,a4,5e4 <vprintf+0x190>
 4ca:	00271793          	slli	a5,a4,0x2
 4ce:	00000717          	auipc	a4,0x0
 4d2:	35270713          	addi	a4,a4,850 # 820 <malloc+0x11a>
 4d6:	97ba                	add	a5,a5,a4
 4d8:	439c                	lw	a5,0(a5)
 4da:	97ba                	add	a5,a5,a4
 4dc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4de:	008b8913          	addi	s2,s7,8
 4e2:	4685                	li	a3,1
 4e4:	4629                	li	a2,10
 4e6:	000ba583          	lw	a1,0(s7)
 4ea:	8556                	mv	a0,s5
 4ec:	00000097          	auipc	ra,0x0
 4f0:	ebc080e7          	jalr	-324(ra) # 3a8 <printint>
 4f4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4f6:	4981                	li	s3,0
 4f8:	b745                	j	498 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4fa:	008b8913          	addi	s2,s7,8
 4fe:	4681                	li	a3,0
 500:	4629                	li	a2,10
 502:	000ba583          	lw	a1,0(s7)
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	ea0080e7          	jalr	-352(ra) # 3a8 <printint>
 510:	8bca                	mv	s7,s2
      state = 0;
 512:	4981                	li	s3,0
 514:	b751                	j	498 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 516:	008b8913          	addi	s2,s7,8
 51a:	4681                	li	a3,0
 51c:	4641                	li	a2,16
 51e:	000ba583          	lw	a1,0(s7)
 522:	8556                	mv	a0,s5
 524:	00000097          	auipc	ra,0x0
 528:	e84080e7          	jalr	-380(ra) # 3a8 <printint>
 52c:	8bca                	mv	s7,s2
      state = 0;
 52e:	4981                	li	s3,0
 530:	b7a5                	j	498 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 532:	008b8c13          	addi	s8,s7,8
 536:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 53a:	03000593          	li	a1,48
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e46080e7          	jalr	-442(ra) # 386 <putc>
  putc(fd, 'x');
 548:	07800593          	li	a1,120
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	e38080e7          	jalr	-456(ra) # 386 <putc>
 556:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 558:	00000b97          	auipc	s7,0x0
 55c:	320b8b93          	addi	s7,s7,800 # 878 <digits>
 560:	03c9d793          	srli	a5,s3,0x3c
 564:	97de                	add	a5,a5,s7
 566:	0007c583          	lbu	a1,0(a5)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e1a080e7          	jalr	-486(ra) # 386 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 574:	0992                	slli	s3,s3,0x4
 576:	397d                	addiw	s2,s2,-1
 578:	fe0914e3          	bnez	s2,560 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 57c:	8be2                	mv	s7,s8
      state = 0;
 57e:	4981                	li	s3,0
 580:	bf21                	j	498 <vprintf+0x44>
        s = va_arg(ap, char*);
 582:	008b8993          	addi	s3,s7,8
 586:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 58a:	02090163          	beqz	s2,5ac <vprintf+0x158>
        while(*s != 0){
 58e:	00094583          	lbu	a1,0(s2)
 592:	c9a5                	beqz	a1,602 <vprintf+0x1ae>
          putc(fd, *s);
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	df0080e7          	jalr	-528(ra) # 386 <putc>
          s++;
 59e:	0905                	addi	s2,s2,1
        while(*s != 0){
 5a0:	00094583          	lbu	a1,0(s2)
 5a4:	f9e5                	bnez	a1,594 <vprintf+0x140>
        s = va_arg(ap, char*);
 5a6:	8bce                	mv	s7,s3
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	b5fd                	j	498 <vprintf+0x44>
          s = "(null)";
 5ac:	00000917          	auipc	s2,0x0
 5b0:	26c90913          	addi	s2,s2,620 # 818 <malloc+0x112>
        while(*s != 0){
 5b4:	02800593          	li	a1,40
 5b8:	bff1                	j	594 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5ba:	008b8913          	addi	s2,s7,8
 5be:	000bc583          	lbu	a1,0(s7)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	dc2080e7          	jalr	-574(ra) # 386 <putc>
 5cc:	8bca                	mv	s7,s2
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b5e1                	j	498 <vprintf+0x44>
        putc(fd, c);
 5d2:	02500593          	li	a1,37
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	dae080e7          	jalr	-594(ra) # 386 <putc>
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bd5d                	j	498 <vprintf+0x44>
        putc(fd, '%');
 5e4:	02500593          	li	a1,37
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	d9c080e7          	jalr	-612(ra) # 386 <putc>
        putc(fd, c);
 5f2:	85ca                	mv	a1,s2
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	d90080e7          	jalr	-624(ra) # 386 <putc>
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bd61                	j	498 <vprintf+0x44>
        s = va_arg(ap, char*);
 602:	8bce                	mv	s7,s3
      state = 0;
 604:	4981                	li	s3,0
 606:	bd49                	j	498 <vprintf+0x44>
    }
  }
}
 608:	60a6                	ld	ra,72(sp)
 60a:	6406                	ld	s0,64(sp)
 60c:	74e2                	ld	s1,56(sp)
 60e:	7942                	ld	s2,48(sp)
 610:	79a2                	ld	s3,40(sp)
 612:	7a02                	ld	s4,32(sp)
 614:	6ae2                	ld	s5,24(sp)
 616:	6b42                	ld	s6,16(sp)
 618:	6ba2                	ld	s7,8(sp)
 61a:	6c02                	ld	s8,0(sp)
 61c:	6161                	addi	sp,sp,80
 61e:	8082                	ret

0000000000000620 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 620:	715d                	addi	sp,sp,-80
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	1000                	addi	s0,sp,32
 628:	e010                	sd	a2,0(s0)
 62a:	e414                	sd	a3,8(s0)
 62c:	e818                	sd	a4,16(s0)
 62e:	ec1c                	sd	a5,24(s0)
 630:	03043023          	sd	a6,32(s0)
 634:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 638:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 63c:	8622                	mv	a2,s0
 63e:	00000097          	auipc	ra,0x0
 642:	e16080e7          	jalr	-490(ra) # 454 <vprintf>
}
 646:	60e2                	ld	ra,24(sp)
 648:	6442                	ld	s0,16(sp)
 64a:	6161                	addi	sp,sp,80
 64c:	8082                	ret

000000000000064e <printf>:

void
printf(const char *fmt, ...)
{
 64e:	711d                	addi	sp,sp,-96
 650:	ec06                	sd	ra,24(sp)
 652:	e822                	sd	s0,16(sp)
 654:	1000                	addi	s0,sp,32
 656:	e40c                	sd	a1,8(s0)
 658:	e810                	sd	a2,16(s0)
 65a:	ec14                	sd	a3,24(s0)
 65c:	f018                	sd	a4,32(s0)
 65e:	f41c                	sd	a5,40(s0)
 660:	03043823          	sd	a6,48(s0)
 664:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 668:	00840613          	addi	a2,s0,8
 66c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 670:	85aa                	mv	a1,a0
 672:	4505                	li	a0,1
 674:	00000097          	auipc	ra,0x0
 678:	de0080e7          	jalr	-544(ra) # 454 <vprintf>
}
 67c:	60e2                	ld	ra,24(sp)
 67e:	6442                	ld	s0,16(sp)
 680:	6125                	addi	sp,sp,96
 682:	8082                	ret

0000000000000684 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 684:	1141                	addi	sp,sp,-16
 686:	e422                	sd	s0,8(sp)
 688:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 68a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68e:	00001797          	auipc	a5,0x1
 692:	9727b783          	ld	a5,-1678(a5) # 1000 <freep>
 696:	a02d                	j	6c0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 698:	4618                	lw	a4,8(a2)
 69a:	9f2d                	addw	a4,a4,a1
 69c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a0:	6398                	ld	a4,0(a5)
 6a2:	6310                	ld	a2,0(a4)
 6a4:	a83d                	j	6e2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a6:	ff852703          	lw	a4,-8(a0)
 6aa:	9f31                	addw	a4,a4,a2
 6ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ae:	ff053683          	ld	a3,-16(a0)
 6b2:	a091                	j	6f6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b4:	6398                	ld	a4,0(a5)
 6b6:	00e7e463          	bltu	a5,a4,6be <free+0x3a>
 6ba:	00e6ea63          	bltu	a3,a4,6ce <free+0x4a>
{
 6be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c0:	fed7fae3          	bgeu	a5,a3,6b4 <free+0x30>
 6c4:	6398                	ld	a4,0(a5)
 6c6:	00e6e463          	bltu	a3,a4,6ce <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ca:	fee7eae3          	bltu	a5,a4,6be <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6ce:	ff852583          	lw	a1,-8(a0)
 6d2:	6390                	ld	a2,0(a5)
 6d4:	02059813          	slli	a6,a1,0x20
 6d8:	01c85713          	srli	a4,a6,0x1c
 6dc:	9736                	add	a4,a4,a3
 6de:	fae60de3          	beq	a2,a4,698 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e6:	4790                	lw	a2,8(a5)
 6e8:	02061593          	slli	a1,a2,0x20
 6ec:	01c5d713          	srli	a4,a1,0x1c
 6f0:	973e                	add	a4,a4,a5
 6f2:	fae68ae3          	beq	a3,a4,6a6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6f6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6f8:	00001717          	auipc	a4,0x1
 6fc:	90f73423          	sd	a5,-1784(a4) # 1000 <freep>
}
 700:	6422                	ld	s0,8(sp)
 702:	0141                	addi	sp,sp,16
 704:	8082                	ret

0000000000000706 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 706:	7139                	addi	sp,sp,-64
 708:	fc06                	sd	ra,56(sp)
 70a:	f822                	sd	s0,48(sp)
 70c:	f426                	sd	s1,40(sp)
 70e:	f04a                	sd	s2,32(sp)
 710:	ec4e                	sd	s3,24(sp)
 712:	e852                	sd	s4,16(sp)
 714:	e456                	sd	s5,8(sp)
 716:	e05a                	sd	s6,0(sp)
 718:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 71a:	02051493          	slli	s1,a0,0x20
 71e:	9081                	srli	s1,s1,0x20
 720:	04bd                	addi	s1,s1,15
 722:	8091                	srli	s1,s1,0x4
 724:	0014899b          	addiw	s3,s1,1
 728:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 72a:	00001517          	auipc	a0,0x1
 72e:	8d653503          	ld	a0,-1834(a0) # 1000 <freep>
 732:	c515                	beqz	a0,75e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 734:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 736:	4798                	lw	a4,8(a5)
 738:	02977f63          	bgeu	a4,s1,776 <malloc+0x70>
  if(nu < 4096)
 73c:	8a4e                	mv	s4,s3
 73e:	0009871b          	sext.w	a4,s3
 742:	6685                	lui	a3,0x1
 744:	00d77363          	bgeu	a4,a3,74a <malloc+0x44>
 748:	6a05                	lui	s4,0x1
 74a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 74e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 752:	00001917          	auipc	s2,0x1
 756:	8ae90913          	addi	s2,s2,-1874 # 1000 <freep>
  if(p == (char*)-1)
 75a:	5afd                	li	s5,-1
 75c:	a895                	j	7d0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 75e:	00001797          	auipc	a5,0x1
 762:	8b278793          	addi	a5,a5,-1870 # 1010 <base>
 766:	00001717          	auipc	a4,0x1
 76a:	88f73d23          	sd	a5,-1894(a4) # 1000 <freep>
 76e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 770:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 774:	b7e1                	j	73c <malloc+0x36>
      if(p->s.size == nunits)
 776:	02e48c63          	beq	s1,a4,7ae <malloc+0xa8>
        p->s.size -= nunits;
 77a:	4137073b          	subw	a4,a4,s3
 77e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 780:	02071693          	slli	a3,a4,0x20
 784:	01c6d713          	srli	a4,a3,0x1c
 788:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 78a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 78e:	00001717          	auipc	a4,0x1
 792:	86a73923          	sd	a0,-1934(a4) # 1000 <freep>
      return (void*)(p + 1);
 796:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 79a:	70e2                	ld	ra,56(sp)
 79c:	7442                	ld	s0,48(sp)
 79e:	74a2                	ld	s1,40(sp)
 7a0:	7902                	ld	s2,32(sp)
 7a2:	69e2                	ld	s3,24(sp)
 7a4:	6a42                	ld	s4,16(sp)
 7a6:	6aa2                	ld	s5,8(sp)
 7a8:	6b02                	ld	s6,0(sp)
 7aa:	6121                	addi	sp,sp,64
 7ac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ae:	6398                	ld	a4,0(a5)
 7b0:	e118                	sd	a4,0(a0)
 7b2:	bff1                	j	78e <malloc+0x88>
  hp->s.size = nu;
 7b4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b8:	0541                	addi	a0,a0,16
 7ba:	00000097          	auipc	ra,0x0
 7be:	eca080e7          	jalr	-310(ra) # 684 <free>
  return freep;
 7c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c6:	d971                	beqz	a0,79a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ca:	4798                	lw	a4,8(a5)
 7cc:	fa9775e3          	bgeu	a4,s1,776 <malloc+0x70>
    if(p == freep)
 7d0:	00093703          	ld	a4,0(s2)
 7d4:	853e                	mv	a0,a5
 7d6:	fef719e3          	bne	a4,a5,7c8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7da:	8552                	mv	a0,s4
 7dc:	00000097          	auipc	ra,0x0
 7e0:	b8a080e7          	jalr	-1142(ra) # 366 <sbrk>
  if(p == (char*)-1)
 7e4:	fd5518e3          	bne	a0,s5,7b4 <malloc+0xae>
        return 0;
 7e8:	4501                	li	a0,0
 7ea:	bf45                	j	79a <malloc+0x94>
