
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	addi	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	e062                	sd	s8,0(sp)
 130:	0880                	addi	s0,sp,80
 132:	89aa                	mv	s3,a0
 134:	8b2e                	mv	s6,a1
  m = 0;
 136:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 138:	3ff00b93          	li	s7,1023
 13c:	00001a97          	auipc	s5,0x1
 140:	ed4a8a93          	addi	s5,s5,-300 # 1010 <buf>
 144:	a0a1                	j	18c <grep+0x72>
      p = q+1;
 146:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 14a:	45a9                	li	a1,10
 14c:	854a                	mv	a0,s2
 14e:	00000097          	auipc	ra,0x0
 152:	20a080e7          	jalr	522(ra) # 358 <strchr>
 156:	84aa                	mv	s1,a0
 158:	c905                	beqz	a0,188 <grep+0x6e>
      *q = 0;
 15a:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15e:	85ca                	mv	a1,s2
 160:	854e                	mv	a0,s3
 162:	00000097          	auipc	ra,0x0
 166:	f6a080e7          	jalr	-150(ra) # cc <match>
 16a:	dd71                	beqz	a0,146 <grep+0x2c>
        *q = '\n';
 16c:	47a9                	li	a5,10
 16e:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 172:	00148613          	addi	a2,s1,1
 176:	4126063b          	subw	a2,a2,s2
 17a:	85ca                	mv	a1,s2
 17c:	4505                	li	a0,1
 17e:	00000097          	auipc	ra,0x0
 182:	3d2080e7          	jalr	978(ra) # 550 <write>
 186:	b7c1                	j	146 <grep+0x2c>
    if(m > 0){
 188:	03404763          	bgtz	s4,1b6 <grep+0x9c>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18c:	414b863b          	subw	a2,s7,s4
 190:	014a85b3          	add	a1,s5,s4
 194:	855a                	mv	a0,s6
 196:	00000097          	auipc	ra,0x0
 19a:	3b2080e7          	jalr	946(ra) # 548 <read>
 19e:	02a05b63          	blez	a0,1d4 <grep+0xba>
    m += n;
 1a2:	00aa0c3b          	addw	s8,s4,a0
 1a6:	000c0a1b          	sext.w	s4,s8
    buf[m] = '\0';
 1aa:	014a87b3          	add	a5,s5,s4
 1ae:	00078023          	sb	zero,0(a5)
    p = buf;
 1b2:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1b4:	bf59                	j	14a <grep+0x30>
      m -= p - buf;
 1b6:	00001517          	auipc	a0,0x1
 1ba:	e5a50513          	addi	a0,a0,-422 # 1010 <buf>
 1be:	40a90a33          	sub	s4,s2,a0
 1c2:	414c0a3b          	subw	s4,s8,s4
      memmove(buf, p, m);
 1c6:	8652                	mv	a2,s4
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	2b4080e7          	jalr	692(ra) # 47e <memmove>
 1d2:	bf6d                	j	18c <grep+0x72>
}
 1d4:	60a6                	ld	ra,72(sp)
 1d6:	6406                	ld	s0,64(sp)
 1d8:	74e2                	ld	s1,56(sp)
 1da:	7942                	ld	s2,48(sp)
 1dc:	79a2                	ld	s3,40(sp)
 1de:	7a02                	ld	s4,32(sp)
 1e0:	6ae2                	ld	s5,24(sp)
 1e2:	6b42                	ld	s6,16(sp)
 1e4:	6ba2                	ld	s7,8(sp)
 1e6:	6c02                	ld	s8,0(sp)
 1e8:	6161                	addi	sp,sp,80
 1ea:	8082                	ret

00000000000001ec <main>:
{
 1ec:	7179                	addi	sp,sp,-48
 1ee:	f406                	sd	ra,40(sp)
 1f0:	f022                	sd	s0,32(sp)
 1f2:	ec26                	sd	s1,24(sp)
 1f4:	e84a                	sd	s2,16(sp)
 1f6:	e44e                	sd	s3,8(sp)
 1f8:	e052                	sd	s4,0(sp)
 1fa:	1800                	addi	s0,sp,48
  if(argc <= 1){
 1fc:	4785                	li	a5,1
 1fe:	04a7de63          	bge	a5,a0,25a <main+0x6e>
  pattern = argv[1];
 202:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 206:	4789                	li	a5,2
 208:	06a7d763          	bge	a5,a0,276 <main+0x8a>
 20c:	01058913          	addi	s2,a1,16
 210:	ffd5099b          	addiw	s3,a0,-3
 214:	02099793          	slli	a5,s3,0x20
 218:	01d7d993          	srli	s3,a5,0x1d
 21c:	05e1                	addi	a1,a1,24
 21e:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 220:	4581                	li	a1,0
 222:	00093503          	ld	a0,0(s2)
 226:	00000097          	auipc	ra,0x0
 22a:	34a080e7          	jalr	842(ra) # 570 <open>
 22e:	84aa                	mv	s1,a0
 230:	04054e63          	bltz	a0,28c <main+0xa0>
    grep(pattern, fd);
 234:	85aa                	mv	a1,a0
 236:	8552                	mv	a0,s4
 238:	00000097          	auipc	ra,0x0
 23c:	ee2080e7          	jalr	-286(ra) # 11a <grep>
    close(fd);
 240:	8526                	mv	a0,s1
 242:	00000097          	auipc	ra,0x0
 246:	316080e7          	jalr	790(ra) # 558 <close>
  for(i = 2; i < argc; i++){
 24a:	0921                	addi	s2,s2,8
 24c:	fd391ae3          	bne	s2,s3,220 <main+0x34>
  exit(0);
 250:	4501                	li	a0,0
 252:	00000097          	auipc	ra,0x0
 256:	2de080e7          	jalr	734(ra) # 530 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
<<<<<<< HEAD
 24e:	00001597          	auipc	a1,0x1
 252:	80258593          	addi	a1,a1,-2046 # a50 <malloc+0xec>
 256:	4509                	li	a0,2
 258:	00000097          	auipc	ra,0x0
 25c:	620080e7          	jalr	1568(ra) # 878 <fprintf>
=======
 25a:	00000597          	auipc	a1,0x0
 25e:	7e658593          	addi	a1,a1,2022 # a40 <malloc+0xe8>
 262:	4509                	li	a0,2
 264:	00000097          	auipc	ra,0x0
 268:	60e080e7          	jalr	1550(ra) # 872 <fprintf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    exit(1);
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	2c2080e7          	jalr	706(ra) # 530 <exit>
    grep(pattern, 0);
 276:	4581                	li	a1,0
 278:	8552                	mv	a0,s4
 27a:	00000097          	auipc	ra,0x0
 27e:	ea0080e7          	jalr	-352(ra) # 11a <grep>
    exit(0);
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	2ac080e7          	jalr	684(ra) # 530 <exit>
      printf("grep: cannot open %s\n", argv[i]);
<<<<<<< HEAD
 280:	00093583          	ld	a1,0(s2)
 284:	00000517          	auipc	a0,0x0
 288:	7ec50513          	addi	a0,a0,2028 # a70 <malloc+0x10c>
 28c:	00000097          	auipc	ra,0x0
 290:	61a080e7          	jalr	1562(ra) # 8a6 <printf>
=======
 28c:	00093583          	ld	a1,0(s2)
 290:	00000517          	auipc	a0,0x0
 294:	7d050513          	addi	a0,a0,2000 # a60 <malloc+0x108>
 298:	00000097          	auipc	ra,0x0
 29c:	608080e7          	jalr	1544(ra) # 8a0 <printf>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      exit(1);
 2a0:	4505                	li	a0,1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	28e080e7          	jalr	654(ra) # 530 <exit>

00000000000002aa <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2b2:	00000097          	auipc	ra,0x0
 2b6:	f3a080e7          	jalr	-198(ra) # 1ec <main>
  exit(0);
 2ba:	4501                	li	a0,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	274080e7          	jalr	628(ra) # 530 <exit>

00000000000002c4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2ca:	87aa                	mv	a5,a0
 2cc:	0585                	addi	a1,a1,1
 2ce:	0785                	addi	a5,a5,1
 2d0:	fff5c703          	lbu	a4,-1(a1)
 2d4:	fee78fa3          	sb	a4,-1(a5)
 2d8:	fb75                	bnez	a4,2cc <strcpy+0x8>
    ;
  return os;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	cb91                	beqz	a5,2fe <strcmp+0x1e>
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00f71763          	bne	a4,a5,2fe <strcmp+0x1e>
    p++, q++;
 2f4:	0505                	addi	a0,a0,1
 2f6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	fbe5                	bnez	a5,2ec <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2fe:	0005c503          	lbu	a0,0(a1)
}
 302:	40a7853b          	subw	a0,a5,a0
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strlen>:

uint
strlen(const char *s)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cf91                	beqz	a5,332 <strlen+0x26>
 318:	0505                	addi	a0,a0,1
 31a:	87aa                	mv	a5,a0
 31c:	86be                	mv	a3,a5
 31e:	0785                	addi	a5,a5,1
 320:	fff7c703          	lbu	a4,-1(a5)
 324:	ff65                	bnez	a4,31c <strlen+0x10>
 326:	40a6853b          	subw	a0,a3,a0
 32a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  for(n = 0; s[n]; n++)
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <strlen+0x20>

0000000000000336 <memset>:

void*
memset(void *dst, int c, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 33c:	ca19                	beqz	a2,352 <memset+0x1c>
 33e:	87aa                	mv	a5,a0
 340:	1602                	slli	a2,a2,0x20
 342:	9201                	srli	a2,a2,0x20
 344:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 348:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 34c:	0785                	addi	a5,a5,1
 34e:	fee79de3          	bne	a5,a4,348 <memset+0x12>
  }
  return dst;
}
 352:	6422                	ld	s0,8(sp)
 354:	0141                	addi	sp,sp,16
 356:	8082                	ret

0000000000000358 <strchr>:

char*
strchr(const char *s, char c)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e422                	sd	s0,8(sp)
 35c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 35e:	00054783          	lbu	a5,0(a0)
 362:	cb99                	beqz	a5,378 <strchr+0x20>
    if(*s == c)
 364:	00f58763          	beq	a1,a5,372 <strchr+0x1a>
  for(; *s; s++)
 368:	0505                	addi	a0,a0,1
 36a:	00054783          	lbu	a5,0(a0)
 36e:	fbfd                	bnez	a5,364 <strchr+0xc>
      return (char*)s;
  return 0;
 370:	4501                	li	a0,0
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret
  return 0;
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <strchr+0x1a>

000000000000037c <gets>:

char*
gets(char *buf, int max)
{
 37c:	711d                	addi	sp,sp,-96
 37e:	ec86                	sd	ra,88(sp)
 380:	e8a2                	sd	s0,80(sp)
 382:	e4a6                	sd	s1,72(sp)
 384:	e0ca                	sd	s2,64(sp)
 386:	fc4e                	sd	s3,56(sp)
 388:	f852                	sd	s4,48(sp)
 38a:	f456                	sd	s5,40(sp)
 38c:	f05a                	sd	s6,32(sp)
 38e:	ec5e                	sd	s7,24(sp)
 390:	1080                	addi	s0,sp,96
 392:	8baa                	mv	s7,a0
 394:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 396:	892a                	mv	s2,a0
 398:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 39a:	4aa9                	li	s5,10
 39c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 39e:	89a6                	mv	s3,s1
 3a0:	2485                	addiw	s1,s1,1
 3a2:	0344d863          	bge	s1,s4,3d2 <gets+0x56>
    cc = read(0, &c, 1);
 3a6:	4605                	li	a2,1
 3a8:	faf40593          	addi	a1,s0,-81
 3ac:	4501                	li	a0,0
 3ae:	00000097          	auipc	ra,0x0
 3b2:	19a080e7          	jalr	410(ra) # 548 <read>
    if(cc < 1)
 3b6:	00a05e63          	blez	a0,3d2 <gets+0x56>
    buf[i++] = c;
 3ba:	faf44783          	lbu	a5,-81(s0)
 3be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3c2:	01578763          	beq	a5,s5,3d0 <gets+0x54>
 3c6:	0905                	addi	s2,s2,1
 3c8:	fd679be3          	bne	a5,s6,39e <gets+0x22>
  for(i=0; i+1 < max; ){
 3cc:	89a6                	mv	s3,s1
 3ce:	a011                	j	3d2 <gets+0x56>
 3d0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3d2:	99de                	add	s3,s3,s7
 3d4:	00098023          	sb	zero,0(s3)
  return buf;
}
 3d8:	855e                	mv	a0,s7
 3da:	60e6                	ld	ra,88(sp)
 3dc:	6446                	ld	s0,80(sp)
 3de:	64a6                	ld	s1,72(sp)
 3e0:	6906                	ld	s2,64(sp)
 3e2:	79e2                	ld	s3,56(sp)
 3e4:	7a42                	ld	s4,48(sp)
 3e6:	7aa2                	ld	s5,40(sp)
 3e8:	7b02                	ld	s6,32(sp)
 3ea:	6be2                	ld	s7,24(sp)
 3ec:	6125                	addi	sp,sp,96
 3ee:	8082                	ret

00000000000003f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3f0:	1101                	addi	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	e426                	sd	s1,8(sp)
 3f8:	e04a                	sd	s2,0(sp)
 3fa:	1000                	addi	s0,sp,32
 3fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fe:	4581                	li	a1,0
 400:	00000097          	auipc	ra,0x0
 404:	170080e7          	jalr	368(ra) # 570 <open>
  if(fd < 0)
 408:	02054563          	bltz	a0,432 <stat+0x42>
 40c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 40e:	85ca                	mv	a1,s2
 410:	00000097          	auipc	ra,0x0
 414:	178080e7          	jalr	376(ra) # 588 <fstat>
 418:	892a                	mv	s2,a0
  close(fd);
 41a:	8526                	mv	a0,s1
 41c:	00000097          	auipc	ra,0x0
 420:	13c080e7          	jalr	316(ra) # 558 <close>
  return r;
}
 424:	854a                	mv	a0,s2
 426:	60e2                	ld	ra,24(sp)
 428:	6442                	ld	s0,16(sp)
 42a:	64a2                	ld	s1,8(sp)
 42c:	6902                	ld	s2,0(sp)
 42e:	6105                	addi	sp,sp,32
 430:	8082                	ret
    return -1;
 432:	597d                	li	s2,-1
 434:	bfc5                	j	424 <stat+0x34>

0000000000000436 <atoi>:

int
atoi(const char *s)
{
 436:	1141                	addi	sp,sp,-16
 438:	e422                	sd	s0,8(sp)
 43a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 43c:	00054683          	lbu	a3,0(a0)
 440:	fd06879b          	addiw	a5,a3,-48
 444:	0ff7f793          	zext.b	a5,a5
 448:	4625                	li	a2,9
 44a:	02f66863          	bltu	a2,a5,47a <atoi+0x44>
 44e:	872a                	mv	a4,a0
  n = 0;
 450:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 452:	0705                	addi	a4,a4,1
 454:	0025179b          	slliw	a5,a0,0x2
 458:	9fa9                	addw	a5,a5,a0
 45a:	0017979b          	slliw	a5,a5,0x1
 45e:	9fb5                	addw	a5,a5,a3
 460:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 464:	00074683          	lbu	a3,0(a4)
 468:	fd06879b          	addiw	a5,a3,-48
 46c:	0ff7f793          	zext.b	a5,a5
 470:	fef671e3          	bgeu	a2,a5,452 <atoi+0x1c>
  return n;
}
 474:	6422                	ld	s0,8(sp)
 476:	0141                	addi	sp,sp,16
 478:	8082                	ret
  n = 0;
 47a:	4501                	li	a0,0
 47c:	bfe5                	j	474 <atoi+0x3e>

000000000000047e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 484:	02b57463          	bgeu	a0,a1,4ac <memmove+0x2e>
    while(n-- > 0)
 488:	00c05f63          	blez	a2,4a6 <memmove+0x28>
 48c:	1602                	slli	a2,a2,0x20
 48e:	9201                	srli	a2,a2,0x20
 490:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 494:	872a                	mv	a4,a0
      *dst++ = *src++;
 496:	0585                	addi	a1,a1,1
 498:	0705                	addi	a4,a4,1
 49a:	fff5c683          	lbu	a3,-1(a1)
 49e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4a2:	fee79ae3          	bne	a5,a4,496 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4a6:	6422                	ld	s0,8(sp)
 4a8:	0141                	addi	sp,sp,16
 4aa:	8082                	ret
    dst += n;
 4ac:	00c50733          	add	a4,a0,a2
    src += n;
 4b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4b2:	fec05ae3          	blez	a2,4a6 <memmove+0x28>
 4b6:	fff6079b          	addiw	a5,a2,-1
 4ba:	1782                	slli	a5,a5,0x20
 4bc:	9381                	srli	a5,a5,0x20
 4be:	fff7c793          	not	a5,a5
 4c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4c4:	15fd                	addi	a1,a1,-1
 4c6:	177d                	addi	a4,a4,-1
 4c8:	0005c683          	lbu	a3,0(a1)
 4cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4d0:	fee79ae3          	bne	a5,a4,4c4 <memmove+0x46>
 4d4:	bfc9                	j	4a6 <memmove+0x28>

00000000000004d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4d6:	1141                	addi	sp,sp,-16
 4d8:	e422                	sd	s0,8(sp)
 4da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4dc:	ca05                	beqz	a2,50c <memcmp+0x36>
 4de:	fff6069b          	addiw	a3,a2,-1
 4e2:	1682                	slli	a3,a3,0x20
 4e4:	9281                	srli	a3,a3,0x20
 4e6:	0685                	addi	a3,a3,1
 4e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4ea:	00054783          	lbu	a5,0(a0)
 4ee:	0005c703          	lbu	a4,0(a1)
 4f2:	00e79863          	bne	a5,a4,502 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4f6:	0505                	addi	a0,a0,1
    p2++;
 4f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4fa:	fed518e3          	bne	a0,a3,4ea <memcmp+0x14>
  }
  return 0;
 4fe:	4501                	li	a0,0
 500:	a019                	j	506 <memcmp+0x30>
      return *p1 - *p2;
 502:	40e7853b          	subw	a0,a5,a4
}
 506:	6422                	ld	s0,8(sp)
 508:	0141                	addi	sp,sp,16
 50a:	8082                	ret
  return 0;
 50c:	4501                	li	a0,0
 50e:	bfe5                	j	506 <memcmp+0x30>

0000000000000510 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 510:	1141                	addi	sp,sp,-16
 512:	e406                	sd	ra,8(sp)
 514:	e022                	sd	s0,0(sp)
 516:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 518:	00000097          	auipc	ra,0x0
 51c:	f66080e7          	jalr	-154(ra) # 47e <memmove>
}
 520:	60a2                	ld	ra,8(sp)
 522:	6402                	ld	s0,0(sp)
 524:	0141                	addi	sp,sp,16
 526:	8082                	ret

0000000000000528 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 528:	4885                	li	a7,1
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <exit>:
.global exit
exit:
 li a7, SYS_exit
 530:	4889                	li	a7,2
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <wait>:
.global wait
wait:
 li a7, SYS_wait
 538:	488d                	li	a7,3
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 540:	4891                	li	a7,4
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <read>:
.global read
read:
 li a7, SYS_read
 548:	4895                	li	a7,5
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <write>:
.global write
write:
 li a7, SYS_write
 550:	48c1                	li	a7,16
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <close>:
.global close
close:
 li a7, SYS_close
 558:	48d5                	li	a7,21
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <kill>:
.global kill
kill:
 li a7, SYS_kill
 560:	4899                	li	a7,6
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <exec>:
.global exec
exec:
 li a7, SYS_exec
 568:	489d                	li	a7,7
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <open>:
.global open
open:
 li a7, SYS_open
 570:	48bd                	li	a7,15
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 578:	48c5                	li	a7,17
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 580:	48c9                	li	a7,18
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 588:	48a1                	li	a7,8
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <link>:
.global link
link:
 li a7, SYS_link
 590:	48cd                	li	a7,19
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 598:	48d1                	li	a7,20
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5a0:	48a5                	li	a7,9
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5a8:	48a9                	li	a7,10
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5b0:	48ad                	li	a7,11
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5b8:	48b1                	li	a7,12
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5c0:	48b5                	li	a7,13
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5c8:	48b9                	li	a7,14
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

<<<<<<< HEAD
00000000000005c6 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 5c6:	48d9                	li	a7,22
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <putc>:
=======
00000000000005d0 <trace>:
.global trace
trace:
 li a7, SYS_trace
 5d0:	48d9                	li	a7,22
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <putc>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
<<<<<<< HEAD
 5ce:	1101                	addi	sp,sp,-32
 5d0:	ec06                	sd	ra,24(sp)
 5d2:	e822                	sd	s0,16(sp)
 5d4:	1000                	addi	s0,sp,32
 5d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5da:	4605                	li	a2,1
 5dc:	fef40593          	addi	a1,s0,-17
 5e0:	00000097          	auipc	ra,0x0
 5e4:	f66080e7          	jalr	-154(ra) # 546 <write>
}
 5e8:	60e2                	ld	ra,24(sp)
 5ea:	6442                	ld	s0,16(sp)
 5ec:	6105                	addi	sp,sp,32
 5ee:	8082                	ret

00000000000005f0 <printint>:
=======
 5d8:	1101                	addi	sp,sp,-32
 5da:	ec06                	sd	ra,24(sp)
 5dc:	e822                	sd	s0,16(sp)
 5de:	1000                	addi	s0,sp,32
 5e0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5e4:	4605                	li	a2,1
 5e6:	fef40593          	addi	a1,s0,-17
 5ea:	00000097          	auipc	ra,0x0
 5ee:	f66080e7          	jalr	-154(ra) # 550 <write>
}
 5f2:	60e2                	ld	ra,24(sp)
 5f4:	6442                	ld	s0,16(sp)
 5f6:	6105                	addi	sp,sp,32
 5f8:	8082                	ret

00000000000005fa <printint>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

static void
printint(int fd, int xx, int base, int sgn)
{
<<<<<<< HEAD
 5f0:	7139                	addi	sp,sp,-64
 5f2:	fc06                	sd	ra,56(sp)
 5f4:	f822                	sd	s0,48(sp)
 5f6:	f426                	sd	s1,40(sp)
 5f8:	f04a                	sd	s2,32(sp)
 5fa:	ec4e                	sd	s3,24(sp)
 5fc:	0080                	addi	s0,sp,64
 5fe:	84aa                	mv	s1,a0
=======
 5fa:	7139                	addi	sp,sp,-64
 5fc:	fc06                	sd	ra,56(sp)
 5fe:	f822                	sd	s0,48(sp)
 600:	f426                	sd	s1,40(sp)
 602:	f04a                	sd	s2,32(sp)
 604:	ec4e                	sd	s3,24(sp)
 606:	0080                	addi	s0,sp,64
 608:	84aa                	mv	s1,a0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
<<<<<<< HEAD
 600:	c299                	beqz	a3,606 <printint+0x16>
 602:	0805c863          	bltz	a1,692 <printint+0xa2>
=======
 60a:	c299                	beqz	a3,610 <printint+0x16>
 60c:	0805c963          	bltz	a1,69e <printint+0xa4>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    neg = 1;
    x = -xx;
  } else {
    x = xx;
<<<<<<< HEAD
 606:	2581                	sext.w	a1,a1
  neg = 0;
 608:	4881                	li	a7,0
 60a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 60e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 610:	2601                	sext.w	a2,a2
 612:	00000517          	auipc	a0,0x0
 616:	47e50513          	addi	a0,a0,1150 # a90 <digits>
 61a:	883a                	mv	a6,a4
 61c:	2705                	addiw	a4,a4,1
 61e:	02c5f7bb          	remuw	a5,a1,a2
 622:	1782                	slli	a5,a5,0x20
 624:	9381                	srli	a5,a5,0x20
 626:	97aa                	add	a5,a5,a0
 628:	0007c783          	lbu	a5,0(a5)
 62c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 630:	0005879b          	sext.w	a5,a1
 634:	02c5d5bb          	divuw	a1,a1,a2
 638:	0685                	addi	a3,a3,1
 63a:	fec7f0e3          	bgeu	a5,a2,61a <printint+0x2a>
  if(neg)
 63e:	00088b63          	beqz	a7,654 <printint+0x64>
    buf[i++] = '-';
 642:	fd040793          	addi	a5,s0,-48
 646:	973e                	add	a4,a4,a5
 648:	02d00793          	li	a5,45
 64c:	fef70823          	sb	a5,-16(a4)
 650:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 654:	02e05863          	blez	a4,684 <printint+0x94>
 658:	fc040793          	addi	a5,s0,-64
 65c:	00e78933          	add	s2,a5,a4
 660:	fff78993          	addi	s3,a5,-1
 664:	99ba                	add	s3,s3,a4
 666:	377d                	addiw	a4,a4,-1
 668:	1702                	slli	a4,a4,0x20
 66a:	9301                	srli	a4,a4,0x20
 66c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 670:	fff94583          	lbu	a1,-1(s2)
 674:	8526                	mv	a0,s1
 676:	00000097          	auipc	ra,0x0
 67a:	f58080e7          	jalr	-168(ra) # 5ce <putc>
  while(--i >= 0)
 67e:	197d                	addi	s2,s2,-1
 680:	ff3918e3          	bne	s2,s3,670 <printint+0x80>
}
 684:	70e2                	ld	ra,56(sp)
 686:	7442                	ld	s0,48(sp)
 688:	74a2                	ld	s1,40(sp)
 68a:	7902                	ld	s2,32(sp)
 68c:	69e2                	ld	s3,24(sp)
 68e:	6121                	addi	sp,sp,64
 690:	8082                	ret
    x = -xx;
 692:	40b005bb          	negw	a1,a1
    neg = 1;
 696:	4885                	li	a7,1
    x = -xx;
 698:	bf8d                	j	60a <printint+0x1a>

000000000000069a <vprintf>:
=======
 610:	2581                	sext.w	a1,a1
  neg = 0;
 612:	4881                	li	a7,0
 614:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 618:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 61a:	2601                	sext.w	a2,a2
 61c:	00000517          	auipc	a0,0x0
 620:	4bc50513          	addi	a0,a0,1212 # ad8 <digits>
 624:	883a                	mv	a6,a4
 626:	2705                	addiw	a4,a4,1
 628:	02c5f7bb          	remuw	a5,a1,a2
 62c:	1782                	slli	a5,a5,0x20
 62e:	9381                	srli	a5,a5,0x20
 630:	97aa                	add	a5,a5,a0
 632:	0007c783          	lbu	a5,0(a5)
 636:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 63a:	0005879b          	sext.w	a5,a1
 63e:	02c5d5bb          	divuw	a1,a1,a2
 642:	0685                	addi	a3,a3,1
 644:	fec7f0e3          	bgeu	a5,a2,624 <printint+0x2a>
  if(neg)
 648:	00088c63          	beqz	a7,660 <printint+0x66>
    buf[i++] = '-';
 64c:	fd070793          	addi	a5,a4,-48
 650:	00878733          	add	a4,a5,s0
 654:	02d00793          	li	a5,45
 658:	fef70823          	sb	a5,-16(a4)
 65c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 660:	02e05863          	blez	a4,690 <printint+0x96>
 664:	fc040793          	addi	a5,s0,-64
 668:	00e78933          	add	s2,a5,a4
 66c:	fff78993          	addi	s3,a5,-1
 670:	99ba                	add	s3,s3,a4
 672:	377d                	addiw	a4,a4,-1
 674:	1702                	slli	a4,a4,0x20
 676:	9301                	srli	a4,a4,0x20
 678:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 67c:	fff94583          	lbu	a1,-1(s2)
 680:	8526                	mv	a0,s1
 682:	00000097          	auipc	ra,0x0
 686:	f56080e7          	jalr	-170(ra) # 5d8 <putc>
  while(--i >= 0)
 68a:	197d                	addi	s2,s2,-1
 68c:	ff3918e3          	bne	s2,s3,67c <printint+0x82>
}
 690:	70e2                	ld	ra,56(sp)
 692:	7442                	ld	s0,48(sp)
 694:	74a2                	ld	s1,40(sp)
 696:	7902                	ld	s2,32(sp)
 698:	69e2                	ld	s3,24(sp)
 69a:	6121                	addi	sp,sp,64
 69c:	8082                	ret
    x = -xx;
 69e:	40b005bb          	negw	a1,a1
    neg = 1;
 6a2:	4885                	li	a7,1
    x = -xx;
 6a4:	bf85                	j	614 <printint+0x1a>

00000000000006a6 <vprintf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
<<<<<<< HEAD
 69a:	7119                	addi	sp,sp,-128
 69c:	fc86                	sd	ra,120(sp)
 69e:	f8a2                	sd	s0,112(sp)
 6a0:	f4a6                	sd	s1,104(sp)
 6a2:	f0ca                	sd	s2,96(sp)
 6a4:	ecce                	sd	s3,88(sp)
 6a6:	e8d2                	sd	s4,80(sp)
 6a8:	e4d6                	sd	s5,72(sp)
 6aa:	e0da                	sd	s6,64(sp)
 6ac:	fc5e                	sd	s7,56(sp)
 6ae:	f862                	sd	s8,48(sp)
 6b0:	f466                	sd	s9,40(sp)
 6b2:	f06a                	sd	s10,32(sp)
 6b4:	ec6e                	sd	s11,24(sp)
 6b6:	0100                	addi	s0,sp,128
=======
 6a6:	715d                	addi	sp,sp,-80
 6a8:	e486                	sd	ra,72(sp)
 6aa:	e0a2                	sd	s0,64(sp)
 6ac:	fc26                	sd	s1,56(sp)
 6ae:	f84a                	sd	s2,48(sp)
 6b0:	f44e                	sd	s3,40(sp)
 6b2:	f052                	sd	s4,32(sp)
 6b4:	ec56                	sd	s5,24(sp)
 6b6:	e85a                	sd	s6,16(sp)
 6b8:	e45e                	sd	s7,8(sp)
 6ba:	e062                	sd	s8,0(sp)
 6bc:	0880                	addi	s0,sp,80
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
<<<<<<< HEAD
 6b8:	0005c903          	lbu	s2,0(a1)
 6bc:	18090f63          	beqz	s2,85a <vprintf+0x1c0>
 6c0:	8aaa                	mv	s5,a0
 6c2:	8b32                	mv	s6,a2
 6c4:	00158493          	addi	s1,a1,1
  state = 0;
 6c8:	4981                	li	s3,0
=======
 6be:	0005c903          	lbu	s2,0(a1)
 6c2:	18090c63          	beqz	s2,85a <vprintf+0x1b4>
 6c6:	8aaa                	mv	s5,a0
 6c8:	8bb2                	mv	s7,a2
 6ca:	00158493          	addi	s1,a1,1
  state = 0;
 6ce:	4981                	li	s3,0
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
<<<<<<< HEAD
 6ca:	02500a13          	li	s4,37
      if(c == 'd'){
 6ce:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6d2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6d6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6da:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6de:	00000b97          	auipc	s7,0x0
 6e2:	3b2b8b93          	addi	s7,s7,946 # a90 <digits>
 6e6:	a839                	j	704 <vprintf+0x6a>
        putc(fd, c);
 6e8:	85ca                	mv	a1,s2
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	ee2080e7          	jalr	-286(ra) # 5ce <putc>
 6f4:	a019                	j	6fa <vprintf+0x60>
    } else if(state == '%'){
 6f6:	01498f63          	beq	s3,s4,714 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6fa:	0485                	addi	s1,s1,1
 6fc:	fff4c903          	lbu	s2,-1(s1)
 700:	14090d63          	beqz	s2,85a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 704:	0009079b          	sext.w	a5,s2
    if(state == 0){
 708:	fe0997e3          	bnez	s3,6f6 <vprintf+0x5c>
      if(c == '%'){
 70c:	fd479ee3          	bne	a5,s4,6e8 <vprintf+0x4e>
        state = '%';
 710:	89be                	mv	s3,a5
 712:	b7e5                	j	6fa <vprintf+0x60>
      if(c == 'd'){
 714:	05878063          	beq	a5,s8,754 <vprintf+0xba>
      } else if(c == 'l') {
 718:	05978c63          	beq	a5,s9,770 <vprintf+0xd6>
      } else if(c == 'x') {
 71c:	07a78863          	beq	a5,s10,78c <vprintf+0xf2>
      } else if(c == 'p') {
 720:	09b78463          	beq	a5,s11,7a8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 724:	07300713          	li	a4,115
 728:	0ce78663          	beq	a5,a4,7f4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 72c:	06300713          	li	a4,99
 730:	0ee78e63          	beq	a5,a4,82c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 734:	11478863          	beq	a5,s4,844 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 738:	85d2                	mv	a1,s4
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	e92080e7          	jalr	-366(ra) # 5ce <putc>
        putc(fd, c);
 744:	85ca                	mv	a1,s2
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	e86080e7          	jalr	-378(ra) # 5ce <putc>
      }
      state = 0;
 750:	4981                	li	s3,0
 752:	b765                	j	6fa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 754:	008b0913          	addi	s2,s6,8
 758:	4685                	li	a3,1
 75a:	4629                	li	a2,10
 75c:	000b2583          	lw	a1,0(s6)
 760:	8556                	mv	a0,s5
 762:	00000097          	auipc	ra,0x0
 766:	e8e080e7          	jalr	-370(ra) # 5f0 <printint>
 76a:	8b4a                	mv	s6,s2
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b771                	j	6fa <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 770:	008b0913          	addi	s2,s6,8
 774:	4681                	li	a3,0
 776:	4629                	li	a2,10
 778:	000b2583          	lw	a1,0(s6)
 77c:	8556                	mv	a0,s5
 77e:	00000097          	auipc	ra,0x0
 782:	e72080e7          	jalr	-398(ra) # 5f0 <printint>
 786:	8b4a                	mv	s6,s2
      state = 0;
 788:	4981                	li	s3,0
 78a:	bf85                	j	6fa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 78c:	008b0913          	addi	s2,s6,8
 790:	4681                	li	a3,0
 792:	4641                	li	a2,16
 794:	000b2583          	lw	a1,0(s6)
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	e56080e7          	jalr	-426(ra) # 5f0 <printint>
 7a2:	8b4a                	mv	s6,s2
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	bf91                	j	6fa <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7a8:	008b0793          	addi	a5,s6,8
 7ac:	f8f43423          	sd	a5,-120(s0)
 7b0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7b4:	03000593          	li	a1,48
 7b8:	8556                	mv	a0,s5
 7ba:	00000097          	auipc	ra,0x0
 7be:	e14080e7          	jalr	-492(ra) # 5ce <putc>
  putc(fd, 'x');
 7c2:	85ea                	mv	a1,s10
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	e08080e7          	jalr	-504(ra) # 5ce <putc>
 7ce:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d0:	03c9d793          	srli	a5,s3,0x3c
 7d4:	97de                	add	a5,a5,s7
 7d6:	0007c583          	lbu	a1,0(a5)
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	df2080e7          	jalr	-526(ra) # 5ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7e4:	0992                	slli	s3,s3,0x4
 7e6:	397d                	addiw	s2,s2,-1
 7e8:	fe0914e3          	bnez	s2,7d0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7ec:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	b721                	j	6fa <vprintf+0x60>
        s = va_arg(ap, char*);
 7f4:	008b0993          	addi	s3,s6,8
 7f8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7fc:	02090163          	beqz	s2,81e <vprintf+0x184>
        while(*s != 0){
 800:	00094583          	lbu	a1,0(s2)
 804:	c9a1                	beqz	a1,854 <vprintf+0x1ba>
          putc(fd, *s);
 806:	8556                	mv	a0,s5
 808:	00000097          	auipc	ra,0x0
 80c:	dc6080e7          	jalr	-570(ra) # 5ce <putc>
          s++;
 810:	0905                	addi	s2,s2,1
        while(*s != 0){
 812:	00094583          	lbu	a1,0(s2)
 816:	f9e5                	bnez	a1,806 <vprintf+0x16c>
        s = va_arg(ap, char*);
 818:	8b4e                	mv	s6,s3
      state = 0;
 81a:	4981                	li	s3,0
 81c:	bdf9                	j	6fa <vprintf+0x60>
          s = "(null)";
 81e:	00000917          	auipc	s2,0x0
 822:	26a90913          	addi	s2,s2,618 # a88 <malloc+0x124>
        while(*s != 0){
 826:	02800593          	li	a1,40
 82a:	bff1                	j	806 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 82c:	008b0913          	addi	s2,s6,8
 830:	000b4583          	lbu	a1,0(s6)
 834:	8556                	mv	a0,s5
 836:	00000097          	auipc	ra,0x0
 83a:	d98080e7          	jalr	-616(ra) # 5ce <putc>
 83e:	8b4a                	mv	s6,s2
      state = 0;
 840:	4981                	li	s3,0
 842:	bd65                	j	6fa <vprintf+0x60>
        putc(fd, c);
 844:	85d2                	mv	a1,s4
 846:	8556                	mv	a0,s5
 848:	00000097          	auipc	ra,0x0
 84c:	d86080e7          	jalr	-634(ra) # 5ce <putc>
      state = 0;
 850:	4981                	li	s3,0
 852:	b565                	j	6fa <vprintf+0x60>
        s = va_arg(ap, char*);
 854:	8b4e                	mv	s6,s3
      state = 0;
 856:	4981                	li	s3,0
 858:	b54d                	j	6fa <vprintf+0x60>
    }
  }
}
 85a:	70e6                	ld	ra,120(sp)
 85c:	7446                	ld	s0,112(sp)
 85e:	74a6                	ld	s1,104(sp)
 860:	7906                	ld	s2,96(sp)
 862:	69e6                	ld	s3,88(sp)
 864:	6a46                	ld	s4,80(sp)
 866:	6aa6                	ld	s5,72(sp)
 868:	6b06                	ld	s6,64(sp)
 86a:	7be2                	ld	s7,56(sp)
 86c:	7c42                	ld	s8,48(sp)
 86e:	7ca2                	ld	s9,40(sp)
 870:	7d02                	ld	s10,32(sp)
 872:	6de2                	ld	s11,24(sp)
 874:	6109                	addi	sp,sp,128
 876:	8082                	ret

0000000000000878 <fprintf>:
=======
 6d0:	02500a13          	li	s4,37
 6d4:	4b55                	li	s6,21
 6d6:	a839                	j	6f4 <vprintf+0x4e>
        putc(fd, c);
 6d8:	85ca                	mv	a1,s2
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	efc080e7          	jalr	-260(ra) # 5d8 <putc>
 6e4:	a019                	j	6ea <vprintf+0x44>
    } else if(state == '%'){
 6e6:	01498d63          	beq	s3,s4,700 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 6ea:	0485                	addi	s1,s1,1
 6ec:	fff4c903          	lbu	s2,-1(s1)
 6f0:	16090563          	beqz	s2,85a <vprintf+0x1b4>
    if(state == 0){
 6f4:	fe0999e3          	bnez	s3,6e6 <vprintf+0x40>
      if(c == '%'){
 6f8:	ff4910e3          	bne	s2,s4,6d8 <vprintf+0x32>
        state = '%';
 6fc:	89d2                	mv	s3,s4
 6fe:	b7f5                	j	6ea <vprintf+0x44>
      if(c == 'd'){
 700:	13490263          	beq	s2,s4,824 <vprintf+0x17e>
 704:	f9d9079b          	addiw	a5,s2,-99
 708:	0ff7f793          	zext.b	a5,a5
 70c:	12fb6563          	bltu	s6,a5,836 <vprintf+0x190>
 710:	f9d9079b          	addiw	a5,s2,-99
 714:	0ff7f713          	zext.b	a4,a5
 718:	10eb6f63          	bltu	s6,a4,836 <vprintf+0x190>
 71c:	00271793          	slli	a5,a4,0x2
 720:	00000717          	auipc	a4,0x0
 724:	36070713          	addi	a4,a4,864 # a80 <malloc+0x128>
 728:	97ba                	add	a5,a5,a4
 72a:	439c                	lw	a5,0(a5)
 72c:	97ba                	add	a5,a5,a4
 72e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 730:	008b8913          	addi	s2,s7,8
 734:	4685                	li	a3,1
 736:	4629                	li	a2,10
 738:	000ba583          	lw	a1,0(s7)
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	ebc080e7          	jalr	-324(ra) # 5fa <printint>
 746:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 748:	4981                	li	s3,0
 74a:	b745                	j	6ea <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 74c:	008b8913          	addi	s2,s7,8
 750:	4681                	li	a3,0
 752:	4629                	li	a2,10
 754:	000ba583          	lw	a1,0(s7)
 758:	8556                	mv	a0,s5
 75a:	00000097          	auipc	ra,0x0
 75e:	ea0080e7          	jalr	-352(ra) # 5fa <printint>
 762:	8bca                	mv	s7,s2
      state = 0;
 764:	4981                	li	s3,0
 766:	b751                	j	6ea <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 768:	008b8913          	addi	s2,s7,8
 76c:	4681                	li	a3,0
 76e:	4641                	li	a2,16
 770:	000ba583          	lw	a1,0(s7)
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	e84080e7          	jalr	-380(ra) # 5fa <printint>
 77e:	8bca                	mv	s7,s2
      state = 0;
 780:	4981                	li	s3,0
 782:	b7a5                	j	6ea <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 784:	008b8c13          	addi	s8,s7,8
 788:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 78c:	03000593          	li	a1,48
 790:	8556                	mv	a0,s5
 792:	00000097          	auipc	ra,0x0
 796:	e46080e7          	jalr	-442(ra) # 5d8 <putc>
  putc(fd, 'x');
 79a:	07800593          	li	a1,120
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e38080e7          	jalr	-456(ra) # 5d8 <putc>
 7a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7aa:	00000b97          	auipc	s7,0x0
 7ae:	32eb8b93          	addi	s7,s7,814 # ad8 <digits>
 7b2:	03c9d793          	srli	a5,s3,0x3c
 7b6:	97de                	add	a5,a5,s7
 7b8:	0007c583          	lbu	a1,0(a5)
 7bc:	8556                	mv	a0,s5
 7be:	00000097          	auipc	ra,0x0
 7c2:	e1a080e7          	jalr	-486(ra) # 5d8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7c6:	0992                	slli	s3,s3,0x4
 7c8:	397d                	addiw	s2,s2,-1
 7ca:	fe0914e3          	bnez	s2,7b2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 7ce:	8be2                	mv	s7,s8
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	bf21                	j	6ea <vprintf+0x44>
        s = va_arg(ap, char*);
 7d4:	008b8993          	addi	s3,s7,8
 7d8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 7dc:	02090163          	beqz	s2,7fe <vprintf+0x158>
        while(*s != 0){
 7e0:	00094583          	lbu	a1,0(s2)
 7e4:	c9a5                	beqz	a1,854 <vprintf+0x1ae>
          putc(fd, *s);
 7e6:	8556                	mv	a0,s5
 7e8:	00000097          	auipc	ra,0x0
 7ec:	df0080e7          	jalr	-528(ra) # 5d8 <putc>
          s++;
 7f0:	0905                	addi	s2,s2,1
        while(*s != 0){
 7f2:	00094583          	lbu	a1,0(s2)
 7f6:	f9e5                	bnez	a1,7e6 <vprintf+0x140>
        s = va_arg(ap, char*);
 7f8:	8bce                	mv	s7,s3
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b5fd                	j	6ea <vprintf+0x44>
          s = "(null)";
 7fe:	00000917          	auipc	s2,0x0
 802:	27a90913          	addi	s2,s2,634 # a78 <malloc+0x120>
        while(*s != 0){
 806:	02800593          	li	a1,40
 80a:	bff1                	j	7e6 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 80c:	008b8913          	addi	s2,s7,8
 810:	000bc583          	lbu	a1,0(s7)
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	dc2080e7          	jalr	-574(ra) # 5d8 <putc>
 81e:	8bca                	mv	s7,s2
      state = 0;
 820:	4981                	li	s3,0
 822:	b5e1                	j	6ea <vprintf+0x44>
        putc(fd, c);
 824:	02500593          	li	a1,37
 828:	8556                	mv	a0,s5
 82a:	00000097          	auipc	ra,0x0
 82e:	dae080e7          	jalr	-594(ra) # 5d8 <putc>
      state = 0;
 832:	4981                	li	s3,0
 834:	bd5d                	j	6ea <vprintf+0x44>
        putc(fd, '%');
 836:	02500593          	li	a1,37
 83a:	8556                	mv	a0,s5
 83c:	00000097          	auipc	ra,0x0
 840:	d9c080e7          	jalr	-612(ra) # 5d8 <putc>
        putc(fd, c);
 844:	85ca                	mv	a1,s2
 846:	8556                	mv	a0,s5
 848:	00000097          	auipc	ra,0x0
 84c:	d90080e7          	jalr	-624(ra) # 5d8 <putc>
      state = 0;
 850:	4981                	li	s3,0
 852:	bd61                	j	6ea <vprintf+0x44>
        s = va_arg(ap, char*);
 854:	8bce                	mv	s7,s3
      state = 0;
 856:	4981                	li	s3,0
 858:	bd49                	j	6ea <vprintf+0x44>
    }
  }
}
 85a:	60a6                	ld	ra,72(sp)
 85c:	6406                	ld	s0,64(sp)
 85e:	74e2                	ld	s1,56(sp)
 860:	7942                	ld	s2,48(sp)
 862:	79a2                	ld	s3,40(sp)
 864:	7a02                	ld	s4,32(sp)
 866:	6ae2                	ld	s5,24(sp)
 868:	6b42                	ld	s6,16(sp)
 86a:	6ba2                	ld	s7,8(sp)
 86c:	6c02                	ld	s8,0(sp)
 86e:	6161                	addi	sp,sp,80
 870:	8082                	ret

0000000000000872 <fprintf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

void
fprintf(int fd, const char *fmt, ...)
{
<<<<<<< HEAD
 878:	715d                	addi	sp,sp,-80
 87a:	ec06                	sd	ra,24(sp)
 87c:	e822                	sd	s0,16(sp)
 87e:	1000                	addi	s0,sp,32
 880:	e010                	sd	a2,0(s0)
 882:	e414                	sd	a3,8(s0)
 884:	e818                	sd	a4,16(s0)
 886:	ec1c                	sd	a5,24(s0)
 888:	03043023          	sd	a6,32(s0)
 88c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 890:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 894:	8622                	mv	a2,s0
 896:	00000097          	auipc	ra,0x0
 89a:	e04080e7          	jalr	-508(ra) # 69a <vprintf>
}
 89e:	60e2                	ld	ra,24(sp)
 8a0:	6442                	ld	s0,16(sp)
 8a2:	6161                	addi	sp,sp,80
 8a4:	8082                	ret

00000000000008a6 <printf>:
=======
 872:	715d                	addi	sp,sp,-80
 874:	ec06                	sd	ra,24(sp)
 876:	e822                	sd	s0,16(sp)
 878:	1000                	addi	s0,sp,32
 87a:	e010                	sd	a2,0(s0)
 87c:	e414                	sd	a3,8(s0)
 87e:	e818                	sd	a4,16(s0)
 880:	ec1c                	sd	a5,24(s0)
 882:	03043023          	sd	a6,32(s0)
 886:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 88a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 88e:	8622                	mv	a2,s0
 890:	00000097          	auipc	ra,0x0
 894:	e16080e7          	jalr	-490(ra) # 6a6 <vprintf>
}
 898:	60e2                	ld	ra,24(sp)
 89a:	6442                	ld	s0,16(sp)
 89c:	6161                	addi	sp,sp,80
 89e:	8082                	ret

00000000000008a0 <printf>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f

void
printf(const char *fmt, ...)
{
<<<<<<< HEAD
 8a6:	711d                	addi	sp,sp,-96
 8a8:	ec06                	sd	ra,24(sp)
 8aa:	e822                	sd	s0,16(sp)
 8ac:	1000                	addi	s0,sp,32
 8ae:	e40c                	sd	a1,8(s0)
 8b0:	e810                	sd	a2,16(s0)
 8b2:	ec14                	sd	a3,24(s0)
 8b4:	f018                	sd	a4,32(s0)
 8b6:	f41c                	sd	a5,40(s0)
 8b8:	03043823          	sd	a6,48(s0)
 8bc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8c0:	00840613          	addi	a2,s0,8
 8c4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8c8:	85aa                	mv	a1,a0
 8ca:	4505                	li	a0,1
 8cc:	00000097          	auipc	ra,0x0
 8d0:	dce080e7          	jalr	-562(ra) # 69a <vprintf>
}
 8d4:	60e2                	ld	ra,24(sp)
 8d6:	6442                	ld	s0,16(sp)
 8d8:	6125                	addi	sp,sp,96
 8da:	8082                	ret

00000000000008dc <free>:
=======
 8a0:	711d                	addi	sp,sp,-96
 8a2:	ec06                	sd	ra,24(sp)
 8a4:	e822                	sd	s0,16(sp)
 8a6:	1000                	addi	s0,sp,32
 8a8:	e40c                	sd	a1,8(s0)
 8aa:	e810                	sd	a2,16(s0)
 8ac:	ec14                	sd	a3,24(s0)
 8ae:	f018                	sd	a4,32(s0)
 8b0:	f41c                	sd	a5,40(s0)
 8b2:	03043823          	sd	a6,48(s0)
 8b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ba:	00840613          	addi	a2,s0,8
 8be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8c2:	85aa                	mv	a1,a0
 8c4:	4505                	li	a0,1
 8c6:	00000097          	auipc	ra,0x0
 8ca:	de0080e7          	jalr	-544(ra) # 6a6 <vprintf>
}
 8ce:	60e2                	ld	ra,24(sp)
 8d0:	6442                	ld	s0,16(sp)
 8d2:	6125                	addi	sp,sp,96
 8d4:	8082                	ret

00000000000008d6 <free>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
static Header base;
static Header *freep;

void
free(void *ap)
{
<<<<<<< HEAD
 8dc:	1141                	addi	sp,sp,-16
 8de:	e422                	sd	s0,8(sp)
 8e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e6:	00000797          	auipc	a5,0x0
 8ea:	71a7b783          	ld	a5,1818(a5) # 1000 <freep>
 8ee:	a805                	j	91e <free+0x42>
=======
 8d6:	1141                	addi	sp,sp,-16
 8d8:	e422                	sd	s0,8(sp)
 8da:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8dc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e0:	00000797          	auipc	a5,0x0
 8e4:	7207b783          	ld	a5,1824(a5) # 1000 <freep>
 8e8:	a02d                	j	912 <free+0x3c>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
<<<<<<< HEAD
 8f0:	4618                	lw	a4,8(a2)
 8f2:	9db9                	addw	a1,a1,a4
 8f4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f8:	6398                	ld	a4,0(a5)
 8fa:	6318                	ld	a4,0(a4)
 8fc:	fee53823          	sd	a4,-16(a0)
 900:	a091                	j	944 <free+0x68>
=======
 8ea:	4618                	lw	a4,8(a2)
 8ec:	9f2d                	addw	a4,a4,a1
 8ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	6310                	ld	a2,0(a4)
 8f6:	a83d                	j	934 <free+0x5e>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
<<<<<<< HEAD
 902:	ff852703          	lw	a4,-8(a0)
 906:	9e39                	addw	a2,a2,a4
 908:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 90a:	ff053703          	ld	a4,-16(a0)
 90e:	e398                	sd	a4,0(a5)
 910:	a099                	j	956 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 912:	6398                	ld	a4,0(a5)
 914:	00e7e463          	bltu	a5,a4,91c <free+0x40>
 918:	00e6ea63          	bltu	a3,a4,92c <free+0x50>
{
 91c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91e:	fed7fae3          	bgeu	a5,a3,912 <free+0x36>
 922:	6398                	ld	a4,0(a5)
 924:	00e6e463          	bltu	a3,a4,92c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 928:	fee7eae3          	bltu	a5,a4,91c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 92c:	ff852583          	lw	a1,-8(a0)
 930:	6390                	ld	a2,0(a5)
 932:	02059713          	slli	a4,a1,0x20
 936:	9301                	srli	a4,a4,0x20
 938:	0712                	slli	a4,a4,0x4
 93a:	9736                	add	a4,a4,a3
 93c:	fae60ae3          	beq	a2,a4,8f0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 940:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 944:	4790                	lw	a2,8(a5)
 946:	02061713          	slli	a4,a2,0x20
 94a:	9301                	srli	a4,a4,0x20
 94c:	0712                	slli	a4,a4,0x4
 94e:	973e                	add	a4,a4,a5
 950:	fae689e3          	beq	a3,a4,902 <free+0x26>
  } else
    p->s.ptr = bp;
 954:	e394                	sd	a3,0(a5)
  freep = p;
 956:	00000717          	auipc	a4,0x0
 95a:	6af73523          	sd	a5,1706(a4) # 1000 <freep>
}
 95e:	6422                	ld	s0,8(sp)
 960:	0141                	addi	sp,sp,16
 962:	8082                	ret

0000000000000964 <malloc>:
=======
 8f8:	ff852703          	lw	a4,-8(a0)
 8fc:	9f31                	addw	a4,a4,a2
 8fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 900:	ff053683          	ld	a3,-16(a0)
 904:	a091                	j	948 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 906:	6398                	ld	a4,0(a5)
 908:	00e7e463          	bltu	a5,a4,910 <free+0x3a>
 90c:	00e6ea63          	bltu	a3,a4,920 <free+0x4a>
{
 910:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 912:	fed7fae3          	bgeu	a5,a3,906 <free+0x30>
 916:	6398                	ld	a4,0(a5)
 918:	00e6e463          	bltu	a3,a4,920 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91c:	fee7eae3          	bltu	a5,a4,910 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 920:	ff852583          	lw	a1,-8(a0)
 924:	6390                	ld	a2,0(a5)
 926:	02059813          	slli	a6,a1,0x20
 92a:	01c85713          	srli	a4,a6,0x1c
 92e:	9736                	add	a4,a4,a3
 930:	fae60de3          	beq	a2,a4,8ea <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 934:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 938:	4790                	lw	a2,8(a5)
 93a:	02061593          	slli	a1,a2,0x20
 93e:	01c5d713          	srli	a4,a1,0x1c
 942:	973e                	add	a4,a4,a5
 944:	fae68ae3          	beq	a3,a4,8f8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 948:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 94a:	00000717          	auipc	a4,0x0
 94e:	6af73b23          	sd	a5,1718(a4) # 1000 <freep>
}
 952:	6422                	ld	s0,8(sp)
 954:	0141                	addi	sp,sp,16
 956:	8082                	ret

0000000000000958 <malloc>:
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  return freep;
}

void*
malloc(uint nbytes)
{
<<<<<<< HEAD
 964:	7139                	addi	sp,sp,-64
 966:	fc06                	sd	ra,56(sp)
 968:	f822                	sd	s0,48(sp)
 96a:	f426                	sd	s1,40(sp)
 96c:	f04a                	sd	s2,32(sp)
 96e:	ec4e                	sd	s3,24(sp)
 970:	e852                	sd	s4,16(sp)
 972:	e456                	sd	s5,8(sp)
 974:	e05a                	sd	s6,0(sp)
 976:	0080                	addi	s0,sp,64
=======
 958:	7139                	addi	sp,sp,-64
 95a:	fc06                	sd	ra,56(sp)
 95c:	f822                	sd	s0,48(sp)
 95e:	f426                	sd	s1,40(sp)
 960:	f04a                	sd	s2,32(sp)
 962:	ec4e                	sd	s3,24(sp)
 964:	e852                	sd	s4,16(sp)
 966:	e456                	sd	s5,8(sp)
 968:	e05a                	sd	s6,0(sp)
 96a:	0080                	addi	s0,sp,64
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
<<<<<<< HEAD
 978:	02051493          	slli	s1,a0,0x20
 97c:	9081                	srli	s1,s1,0x20
 97e:	04bd                	addi	s1,s1,15
 980:	8091                	srli	s1,s1,0x4
 982:	0014899b          	addiw	s3,s1,1
 986:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 988:	00000517          	auipc	a0,0x0
 98c:	67853503          	ld	a0,1656(a0) # 1000 <freep>
 990:	c515                	beqz	a0,9bc <malloc+0x58>
=======
 96c:	02051493          	slli	s1,a0,0x20
 970:	9081                	srli	s1,s1,0x20
 972:	04bd                	addi	s1,s1,15
 974:	8091                	srli	s1,s1,0x4
 976:	0014899b          	addiw	s3,s1,1
 97a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 97c:	00000517          	auipc	a0,0x0
 980:	68453503          	ld	a0,1668(a0) # 1000 <freep>
 984:	c515                	beqz	a0,9b0 <malloc+0x58>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
<<<<<<< HEAD
 992:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 994:	4798                	lw	a4,8(a5)
 996:	02977f63          	bgeu	a4,s1,9d4 <malloc+0x70>
 99a:	8a4e                	mv	s4,s3
 99c:	0009871b          	sext.w	a4,s3
 9a0:	6685                	lui	a3,0x1
 9a2:	00d77363          	bgeu	a4,a3,9a8 <malloc+0x44>
 9a6:	6a05                	lui	s4,0x1
 9a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ac:	004a1a1b          	slliw	s4,s4,0x4
=======
 986:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 988:	4798                	lw	a4,8(a5)
 98a:	02977f63          	bgeu	a4,s1,9c8 <malloc+0x70>
  if(nu < 4096)
 98e:	8a4e                	mv	s4,s3
 990:	0009871b          	sext.w	a4,s3
 994:	6685                	lui	a3,0x1
 996:	00d77363          	bgeu	a4,a3,99c <malloc+0x44>
 99a:	6a05                	lui	s4,0x1
 99c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9a0:	004a1a1b          	slliw	s4,s4,0x4
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
<<<<<<< HEAD
 9b0:	00000917          	auipc	s2,0x0
 9b4:	65090913          	addi	s2,s2,1616 # 1000 <freep>
  if(p == (char*)-1)
 9b8:	5afd                	li	s5,-1
 9ba:	a88d                	j	a2c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9bc:	00001797          	auipc	a5,0x1
 9c0:	a5478793          	addi	a5,a5,-1452 # 1410 <base>
 9c4:	00000717          	auipc	a4,0x0
 9c8:	62f73e23          	sd	a5,1596(a4) # 1000 <freep>
 9cc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9ce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9d2:	b7e1                	j	99a <malloc+0x36>
      if(p->s.size == nunits)
 9d4:	02e48b63          	beq	s1,a4,a0a <malloc+0xa6>
        p->s.size -= nunits;
 9d8:	4137073b          	subw	a4,a4,s3
 9dc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9de:	1702                	slli	a4,a4,0x20
 9e0:	9301                	srli	a4,a4,0x20
 9e2:	0712                	slli	a4,a4,0x4
 9e4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9e6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9ea:	00000717          	auipc	a4,0x0
 9ee:	60a73b23          	sd	a0,1558(a4) # 1000 <freep>
      return (void*)(p + 1);
 9f2:	01078513          	addi	a0,a5,16
=======
 9a4:	00000917          	auipc	s2,0x0
 9a8:	65c90913          	addi	s2,s2,1628 # 1000 <freep>
  if(p == (char*)-1)
 9ac:	5afd                	li	s5,-1
 9ae:	a895                	j	a22 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9b0:	00001797          	auipc	a5,0x1
 9b4:	a6078793          	addi	a5,a5,-1440 # 1410 <base>
 9b8:	00000717          	auipc	a4,0x0
 9bc:	64f73423          	sd	a5,1608(a4) # 1000 <freep>
 9c0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9c6:	b7e1                	j	98e <malloc+0x36>
      if(p->s.size == nunits)
 9c8:	02e48c63          	beq	s1,a4,a00 <malloc+0xa8>
        p->s.size -= nunits;
 9cc:	4137073b          	subw	a4,a4,s3
 9d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d2:	02071693          	slli	a3,a4,0x20
 9d6:	01c6d713          	srli	a4,a3,0x1c
 9da:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9dc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e0:	00000717          	auipc	a4,0x0
 9e4:	62a73023          	sd	a0,1568(a4) # 1000 <freep>
      return (void*)(p + 1);
 9e8:	01078513          	addi	a0,a5,16
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
<<<<<<< HEAD
 9f6:	70e2                	ld	ra,56(sp)
 9f8:	7442                	ld	s0,48(sp)
 9fa:	74a2                	ld	s1,40(sp)
 9fc:	7902                	ld	s2,32(sp)
 9fe:	69e2                	ld	s3,24(sp)
 a00:	6a42                	ld	s4,16(sp)
 a02:	6aa2                	ld	s5,8(sp)
 a04:	6b02                	ld	s6,0(sp)
 a06:	6121                	addi	sp,sp,64
 a08:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a0a:	6398                	ld	a4,0(a5)
 a0c:	e118                	sd	a4,0(a0)
 a0e:	bff1                	j	9ea <malloc+0x86>
  hp->s.size = nu;
 a10:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a14:	0541                	addi	a0,a0,16
 a16:	00000097          	auipc	ra,0x0
 a1a:	ec6080e7          	jalr	-314(ra) # 8dc <free>
  return freep;
 a1e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a22:	d971                	beqz	a0,9f6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a24:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a26:	4798                	lw	a4,8(a5)
 a28:	fa9776e3          	bgeu	a4,s1,9d4 <malloc+0x70>
    if(p == freep)
 a2c:	00093703          	ld	a4,0(s2)
 a30:	853e                	mv	a0,a5
 a32:	fef719e3          	bne	a4,a5,a24 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a36:	8552                	mv	a0,s4
 a38:	00000097          	auipc	ra,0x0
 a3c:	b76080e7          	jalr	-1162(ra) # 5ae <sbrk>
  if(p == (char*)-1)
 a40:	fd5518e3          	bne	a0,s5,a10 <malloc+0xac>
        return 0;
 a44:	4501                	li	a0,0
 a46:	bf45                	j	9f6 <malloc+0x92>
=======
 9ec:	70e2                	ld	ra,56(sp)
 9ee:	7442                	ld	s0,48(sp)
 9f0:	74a2                	ld	s1,40(sp)
 9f2:	7902                	ld	s2,32(sp)
 9f4:	69e2                	ld	s3,24(sp)
 9f6:	6a42                	ld	s4,16(sp)
 9f8:	6aa2                	ld	s5,8(sp)
 9fa:	6b02                	ld	s6,0(sp)
 9fc:	6121                	addi	sp,sp,64
 9fe:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a00:	6398                	ld	a4,0(a5)
 a02:	e118                	sd	a4,0(a0)
 a04:	bff1                	j	9e0 <malloc+0x88>
  hp->s.size = nu;
 a06:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a0a:	0541                	addi	a0,a0,16
 a0c:	00000097          	auipc	ra,0x0
 a10:	eca080e7          	jalr	-310(ra) # 8d6 <free>
  return freep;
 a14:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a18:	d971                	beqz	a0,9ec <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a1c:	4798                	lw	a4,8(a5)
 a1e:	fa9775e3          	bgeu	a4,s1,9c8 <malloc+0x70>
    if(p == freep)
 a22:	00093703          	ld	a4,0(s2)
 a26:	853e                	mv	a0,a5
 a28:	fef719e3          	bne	a4,a5,a1a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a2c:	8552                	mv	a0,s4
 a2e:	00000097          	auipc	ra,0x0
 a32:	b8a080e7          	jalr	-1142(ra) # 5b8 <sbrk>
  if(p == (char*)-1)
 a36:	fd5518e3          	bne	a0,s5,a06 <malloc+0xae>
        return 0;
 a3a:	4501                	li	a0,0
 a3c:	bf45                	j	9ec <malloc+0x94>
>>>>>>> a622407307e2bc29b2939c50c428d8cf14044b9f
