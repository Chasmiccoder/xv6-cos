
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b1013103          	ld	sp,-1264(sp) # 80008b10 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	b2070713          	addi	a4,a4,-1248 # 80008b70 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	c1e78793          	addi	a5,a5,-994 # 80005c80 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc61f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	39e080e7          	jalr	926(ra) # 800024c8 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	b2c50513          	addi	a0,a0,-1236 # 80010cb0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	b1c48493          	addi	s1,s1,-1252 # 80010cb0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	bac90913          	addi	s2,s2,-1108 # 80010d48 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	802080e7          	jalr	-2046(ra) # 800019b6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	156080e7          	jalr	342(ra) # 80002312 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	ea0080e7          	jalr	-352(ra) # 8000206a <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	ad270713          	addi	a4,a4,-1326 # 80010cb0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	262080e7          	jalr	610(ra) # 80002472 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	a8850513          	addi	a0,a0,-1400 # 80010cb0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	a7250513          	addi	a0,a0,-1422 # 80010cb0 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	acf72d23          	sw	a5,-1318(a4) # 80010d48 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	9e850513          	addi	a0,a0,-1560 # 80010cb0 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	230080e7          	jalr	560(ra) # 8000251e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	9ba50513          	addi	a0,a0,-1606 # 80010cb0 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	99670713          	addi	a4,a4,-1642 # 80010cb0 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	96c78793          	addi	a5,a5,-1684 # 80010cb0 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	9d67a783          	lw	a5,-1578(a5) # 80010d48 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	92a70713          	addi	a4,a4,-1750 # 80010cb0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	91a48493          	addi	s1,s1,-1766 # 80010cb0 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00011717          	auipc	a4,0x11
    800003d6:	8de70713          	addi	a4,a4,-1826 # 80010cb0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	96f72423          	sw	a5,-1688(a4) # 80010d50 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00011797          	auipc	a5,0x11
    80000412:	8a278793          	addi	a5,a5,-1886 # 80010cb0 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	90c7ad23          	sw	a2,-1766(a5) # 80010d4c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	90e50513          	addi	a0,a0,-1778 # 80010d48 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	c8c080e7          	jalr	-884(ra) # 800020ce <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00011517          	auipc	a0,0x11
    80000460:	85450513          	addi	a0,a0,-1964 # 80010cb0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	bd478793          	addi	a5,a5,-1068 # 80021048 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00011797          	auipc	a5,0x11
    8000054c:	8207a423          	sw	zero,-2008(a5) # 80010d70 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b8650513          	addi	a0,a0,-1146 # 800080f0 <digits+0xb0>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	5af72a23          	sw	a5,1460(a4) # 80008b30 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	7b8dad83          	lw	s11,1976(s11) # 80010d70 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	76250513          	addi	a0,a0,1890 # 80010d58 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	60450513          	addi	a0,a0,1540 # 80010d58 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	5e848493          	addi	s1,s1,1512 # 80010d58 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	5a850513          	addi	a0,a0,1448 # 80010d78 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	3347a783          	lw	a5,820(a5) # 80008b30 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	3047b783          	ld	a5,772(a5) # 80008b38 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	30473703          	ld	a4,772(a4) # 80008b40 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	51aa0a13          	addi	s4,s4,1306 # 80010d78 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	2d248493          	addi	s1,s1,722 # 80008b38 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	2d298993          	addi	s3,s3,722 # 80008b40 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	83e080e7          	jalr	-1986(ra) # 800020ce <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	4ac50513          	addi	a0,a0,1196 # 80010d78 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	2547a783          	lw	a5,596(a5) # 80008b30 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	25a73703          	ld	a4,602(a4) # 80008b40 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	24a7b783          	ld	a5,586(a5) # 80008b38 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	47e98993          	addi	s3,s3,1150 # 80010d78 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	23648493          	addi	s1,s1,566 # 80008b38 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	23690913          	addi	s2,s2,566 # 80008b40 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	750080e7          	jalr	1872(ra) # 8000206a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	44848493          	addi	s1,s1,1096 # 80010d78 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	1ee7be23          	sd	a4,508(a5) # 80008b40 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	3c248493          	addi	s1,s1,962 # 80010d78 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	7e878793          	addi	a5,a5,2024 # 800221e0 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	39890913          	addi	s2,s2,920 # 80010db0 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	2fa50513          	addi	a0,a0,762 # 80010db0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	71650513          	addi	a0,a0,1814 # 800221e0 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	2c448493          	addi	s1,s1,708 # 80010db0 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	2ac50513          	addi	a0,a0,684 # 80010db0 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	28050513          	addi	a0,a0,640 # 80010db0 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e2e080e7          	jalr	-466(ra) # 8000199a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dfc080e7          	jalr	-516(ra) # 8000199a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	df0080e7          	jalr	-528(ra) # 8000199a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dd8080e7          	jalr	-552(ra) # 8000199a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d98080e7          	jalr	-616(ra) # 8000199a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d6c080e7          	jalr	-660(ra) # 8000199a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdce21>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b10080e7          	jalr	-1264(ra) # 8000198a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	cc670713          	addi	a4,a4,-826 # 80008b48 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	af4080e7          	jalr	-1292(ra) # 8000198a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	24050513          	addi	a0,a0,576 # 800080e0 <digits+0xa0>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0e8080e7          	jalr	232(ra) # 80000f98 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	7a8080e7          	jalr	1960(ra) # 80002660 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e00080e7          	jalr	-512(ra) # 80005cc0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	ff0080e7          	jalr	-16(ra) # 80001eb8 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	21050513          	addi	a0,a0,528 # 800080f0 <digits+0xb0>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("=== Welcome to xv6-cos ===\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("The xv6-cos kernel is booting\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c050513          	addi	a0,a0,448 # 800080c0 <digits+0x80>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    printf("\n");
    80000f10:	00007517          	auipc	a0,0x7
    80000f14:	1e050513          	addi	a0,a0,480 # 800080f0 <digits+0xb0>
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	66e080e7          	jalr	1646(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	b86080e7          	jalr	-1146(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f28:	00000097          	auipc	ra,0x0
    80000f2c:	326080e7          	jalr	806(ra) # 8000124e <kvminit>
    kvminithart();   // turn on paging
    80000f30:	00000097          	auipc	ra,0x0
    80000f34:	068080e7          	jalr	104(ra) # 80000f98 <kvminithart>
    procinit();      // process table
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	99e080e7          	jalr	-1634(ra) # 800018d6 <procinit>
    trapinit();      // trap vectors
    80000f40:	00001097          	auipc	ra,0x1
    80000f44:	6f8080e7          	jalr	1784(ra) # 80002638 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	718080e7          	jalr	1816(ra) # 80002660 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f50:	00005097          	auipc	ra,0x5
    80000f54:	d5a080e7          	jalr	-678(ra) # 80005caa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f58:	00005097          	auipc	ra,0x5
    80000f5c:	d68080e7          	jalr	-664(ra) # 80005cc0 <plicinithart>
    binit();         // buffer cache
    80000f60:	00002097          	auipc	ra,0x2
    80000f64:	f68080e7          	jalr	-152(ra) # 80002ec8 <binit>
    iinit();         // inode table
    80000f68:	00002097          	auipc	ra,0x2
    80000f6c:	606080e7          	jalr	1542(ra) # 8000356e <iinit>
    fileinit();      // file table
    80000f70:	00003097          	auipc	ra,0x3
    80000f74:	57c080e7          	jalr	1404(ra) # 800044ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f78:	00005097          	auipc	ra,0x5
    80000f7c:	e50080e7          	jalr	-432(ra) # 80005dc8 <virtio_disk_init>
    userinit();      // first user process
    80000f80:	00001097          	auipc	ra,0x1
    80000f84:	d12080e7          	jalr	-750(ra) # 80001c92 <userinit>
    __sync_synchronize();
    80000f88:	0ff0000f          	fence
    started = 1;
    80000f8c:	4785                	li	a5,1
    80000f8e:	00008717          	auipc	a4,0x8
    80000f92:	baf72d23          	sw	a5,-1094(a4) # 80008b48 <started>
    80000f96:	bf0d                	j	80000ec8 <main+0x56>

0000000080000f98 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f98:	1141                	addi	sp,sp,-16
    80000f9a:	e422                	sd	s0,8(sp)
    80000f9c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa2:	00008797          	auipc	a5,0x8
    80000fa6:	bae7b783          	ld	a5,-1106(a5) # 80008b50 <kernel_pagetable>
    80000faa:	83b1                	srli	a5,a5,0xc
    80000fac:	577d                	li	a4,-1
    80000fae:	177e                	slli	a4,a4,0x3f
    80000fb0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fb6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fba:	6422                	ld	s0,8(sp)
    80000fbc:	0141                	addi	sp,sp,16
    80000fbe:	8082                	ret

0000000080000fc0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc0:	7139                	addi	sp,sp,-64
    80000fc2:	fc06                	sd	ra,56(sp)
    80000fc4:	f822                	sd	s0,48(sp)
    80000fc6:	f426                	sd	s1,40(sp)
    80000fc8:	f04a                	sd	s2,32(sp)
    80000fca:	ec4e                	sd	s3,24(sp)
    80000fcc:	e852                	sd	s4,16(sp)
    80000fce:	e456                	sd	s5,8(sp)
    80000fd0:	e05a                	sd	s6,0(sp)
    80000fd2:	0080                	addi	s0,sp,64
    80000fd4:	84aa                	mv	s1,a0
    80000fd6:	89ae                	mv	s3,a1
    80000fd8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fda:	57fd                	li	a5,-1
    80000fdc:	83e9                	srli	a5,a5,0x1a
    80000fde:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe2:	04b7f263          	bgeu	a5,a1,80001026 <walk+0x66>
    panic("walk");
    80000fe6:	00007517          	auipc	a0,0x7
    80000fea:	11250513          	addi	a0,a0,274 # 800080f8 <digits+0xb8>
    80000fee:	fffff097          	auipc	ra,0xfffff
    80000ff2:	54e080e7          	jalr	1358(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff6:	060a8663          	beqz	s5,80001062 <walk+0xa2>
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	ae8080e7          	jalr	-1304(ra) # 80000ae2 <kalloc>
    80001002:	84aa                	mv	s1,a0
    80001004:	c529                	beqz	a0,8000104e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001006:	6605                	lui	a2,0x1
    80001008:	4581                	li	a1,0
    8000100a:	00000097          	auipc	ra,0x0
    8000100e:	cc4080e7          	jalr	-828(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001020:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdce17>
    80001022:	036a0063          	beq	s4,s6,80001042 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001026:	0149d933          	srl	s2,s3,s4
    8000102a:	1ff97913          	andi	s2,s2,511
    8000102e:	090e                	slli	s2,s2,0x3
    80001030:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001032:	00093483          	ld	s1,0(s2)
    80001036:	0014f793          	andi	a5,s1,1
    8000103a:	dfd5                	beqz	a5,80000ff6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103c:	80a9                	srli	s1,s1,0xa
    8000103e:	04b2                	slli	s1,s1,0xc
    80001040:	b7c5                	j	80001020 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001042:	00c9d513          	srli	a0,s3,0xc
    80001046:	1ff57513          	andi	a0,a0,511
    8000104a:	050e                	slli	a0,a0,0x3
    8000104c:	9526                	add	a0,a0,s1
}
    8000104e:	70e2                	ld	ra,56(sp)
    80001050:	7442                	ld	s0,48(sp)
    80001052:	74a2                	ld	s1,40(sp)
    80001054:	7902                	ld	s2,32(sp)
    80001056:	69e2                	ld	s3,24(sp)
    80001058:	6a42                	ld	s4,16(sp)
    8000105a:	6aa2                	ld	s5,8(sp)
    8000105c:	6b02                	ld	s6,0(sp)
    8000105e:	6121                	addi	sp,sp,64
    80001060:	8082                	ret
        return 0;
    80001062:	4501                	li	a0,0
    80001064:	b7ed                	j	8000104e <walk+0x8e>

0000000080001066 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001066:	57fd                	li	a5,-1
    80001068:	83e9                	srli	a5,a5,0x1a
    8000106a:	00b7f463          	bgeu	a5,a1,80001072 <walkaddr+0xc>
    return 0;
    8000106e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001070:	8082                	ret
{
    80001072:	1141                	addi	sp,sp,-16
    80001074:	e406                	sd	ra,8(sp)
    80001076:	e022                	sd	s0,0(sp)
    80001078:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000107a:	4601                	li	a2,0
    8000107c:	00000097          	auipc	ra,0x0
    80001080:	f44080e7          	jalr	-188(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001084:	c105                	beqz	a0,800010a4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001086:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001088:	0117f693          	andi	a3,a5,17
    8000108c:	4745                	li	a4,17
    return 0;
    8000108e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001090:	00e68663          	beq	a3,a4,8000109c <walkaddr+0x36>
}
    80001094:	60a2                	ld	ra,8(sp)
    80001096:	6402                	ld	s0,0(sp)
    80001098:	0141                	addi	sp,sp,16
    8000109a:	8082                	ret
  pa = PTE2PA(*pte);
    8000109c:	83a9                	srli	a5,a5,0xa
    8000109e:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010a2:	bfcd                	j	80001094 <walkaddr+0x2e>
    return 0;
    800010a4:	4501                	li	a0,0
    800010a6:	b7fd                	j	80001094 <walkaddr+0x2e>

00000000800010a8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a8:	715d                	addi	sp,sp,-80
    800010aa:	e486                	sd	ra,72(sp)
    800010ac:	e0a2                	sd	s0,64(sp)
    800010ae:	fc26                	sd	s1,56(sp)
    800010b0:	f84a                	sd	s2,48(sp)
    800010b2:	f44e                	sd	s3,40(sp)
    800010b4:	f052                	sd	s4,32(sp)
    800010b6:	ec56                	sd	s5,24(sp)
    800010b8:	e85a                	sd	s6,16(sp)
    800010ba:	e45e                	sd	s7,8(sp)
    800010bc:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010be:	c639                	beqz	a2,8000110c <mappages+0x64>
    800010c0:	8aaa                	mv	s5,a0
    800010c2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010c4:	777d                	lui	a4,0xfffff
    800010c6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ca:	fff58993          	addi	s3,a1,-1
    800010ce:	99b2                	add	s3,s3,a2
    800010d0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010d4:	893e                	mv	s2,a5
    800010d6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010da:	6b85                	lui	s7,0x1
    800010dc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e0:	4605                	li	a2,1
    800010e2:	85ca                	mv	a1,s2
    800010e4:	8556                	mv	a0,s5
    800010e6:	00000097          	auipc	ra,0x0
    800010ea:	eda080e7          	jalr	-294(ra) # 80000fc0 <walk>
    800010ee:	cd1d                	beqz	a0,8000112c <mappages+0x84>
    if(*pte & PTE_V)
    800010f0:	611c                	ld	a5,0(a0)
    800010f2:	8b85                	andi	a5,a5,1
    800010f4:	e785                	bnez	a5,8000111c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f6:	80b1                	srli	s1,s1,0xc
    800010f8:	04aa                	slli	s1,s1,0xa
    800010fa:	0164e4b3          	or	s1,s1,s6
    800010fe:	0014e493          	ori	s1,s1,1
    80001102:	e104                	sd	s1,0(a0)
    if(a == last)
    80001104:	05390063          	beq	s2,s3,80001144 <mappages+0x9c>
    a += PGSIZE;
    80001108:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110a:	bfc9                	j	800010dc <mappages+0x34>
    panic("mappages: size");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	ff450513          	addi	a0,a0,-12 # 80008100 <digits+0xc0>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000111c:	00007517          	auipc	a0,0x7
    80001120:	ff450513          	addi	a0,a0,-12 # 80008110 <digits+0xd0>
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	418080e7          	jalr	1048(ra) # 8000053c <panic>
      return -1;
    8000112c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000112e:	60a6                	ld	ra,72(sp)
    80001130:	6406                	ld	s0,64(sp)
    80001132:	74e2                	ld	s1,56(sp)
    80001134:	7942                	ld	s2,48(sp)
    80001136:	79a2                	ld	s3,40(sp)
    80001138:	7a02                	ld	s4,32(sp)
    8000113a:	6ae2                	ld	s5,24(sp)
    8000113c:	6b42                	ld	s6,16(sp)
    8000113e:	6ba2                	ld	s7,8(sp)
    80001140:	6161                	addi	sp,sp,80
    80001142:	8082                	ret
  return 0;
    80001144:	4501                	li	a0,0
    80001146:	b7e5                	j	8000112e <mappages+0x86>

0000000080001148 <kvmmap>:
{
    80001148:	1141                	addi	sp,sp,-16
    8000114a:	e406                	sd	ra,8(sp)
    8000114c:	e022                	sd	s0,0(sp)
    8000114e:	0800                	addi	s0,sp,16
    80001150:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001152:	86b2                	mv	a3,a2
    80001154:	863e                	mv	a2,a5
    80001156:	00000097          	auipc	ra,0x0
    8000115a:	f52080e7          	jalr	-174(ra) # 800010a8 <mappages>
    8000115e:	e509                	bnez	a0,80001168 <kvmmap+0x20>
}
    80001160:	60a2                	ld	ra,8(sp)
    80001162:	6402                	ld	s0,0(sp)
    80001164:	0141                	addi	sp,sp,16
    80001166:	8082                	ret
    panic("kvmmap");
    80001168:	00007517          	auipc	a0,0x7
    8000116c:	fb850513          	addi	a0,a0,-72 # 80008120 <digits+0xe0>
    80001170:	fffff097          	auipc	ra,0xfffff
    80001174:	3cc080e7          	jalr	972(ra) # 8000053c <panic>

0000000080001178 <kvmmake>:
{
    80001178:	1101                	addi	sp,sp,-32
    8000117a:	ec06                	sd	ra,24(sp)
    8000117c:	e822                	sd	s0,16(sp)
    8000117e:	e426                	sd	s1,8(sp)
    80001180:	e04a                	sd	s2,0(sp)
    80001182:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001184:	00000097          	auipc	ra,0x0
    80001188:	95e080e7          	jalr	-1698(ra) # 80000ae2 <kalloc>
    8000118c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118e:	6605                	lui	a2,0x1
    80001190:	4581                	li	a1,0
    80001192:	00000097          	auipc	ra,0x0
    80001196:	b3c080e7          	jalr	-1220(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	6685                	lui	a3,0x1
    8000119e:	10000637          	lui	a2,0x10000
    800011a2:	100005b7          	lui	a1,0x10000
    800011a6:	8526                	mv	a0,s1
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	fa0080e7          	jalr	-96(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	6685                	lui	a3,0x1
    800011b4:	10001637          	lui	a2,0x10001
    800011b8:	100015b7          	lui	a1,0x10001
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	f8a080e7          	jalr	-118(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c6:	4719                	li	a4,6
    800011c8:	004006b7          	lui	a3,0x400
    800011cc:	0c000637          	lui	a2,0xc000
    800011d0:	0c0005b7          	lui	a1,0xc000
    800011d4:	8526                	mv	a0,s1
    800011d6:	00000097          	auipc	ra,0x0
    800011da:	f72080e7          	jalr	-142(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011de:	00007917          	auipc	s2,0x7
    800011e2:	e2290913          	addi	s2,s2,-478 # 80008000 <etext>
    800011e6:	4729                	li	a4,10
    800011e8:	80007697          	auipc	a3,0x80007
    800011ec:	e1868693          	addi	a3,a3,-488 # 8000 <_entry-0x7fff8000>
    800011f0:	4605                	li	a2,1
    800011f2:	067e                	slli	a2,a2,0x1f
    800011f4:	85b2                	mv	a1,a2
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	f50080e7          	jalr	-176(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	46c5                	li	a3,17
    80001204:	06ee                	slli	a3,a3,0x1b
    80001206:	412686b3          	sub	a3,a3,s2
    8000120a:	864a                	mv	a2,s2
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8526                	mv	a0,s1
    80001210:	00000097          	auipc	ra,0x0
    80001214:	f38080e7          	jalr	-200(ra) # 80001148 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001218:	4729                	li	a4,10
    8000121a:	6685                	lui	a3,0x1
    8000121c:	00006617          	auipc	a2,0x6
    80001220:	de460613          	addi	a2,a2,-540 # 80007000 <_trampoline>
    80001224:	040005b7          	lui	a1,0x4000
    80001228:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000122a:	05b2                	slli	a1,a1,0xc
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f1a080e7          	jalr	-230(ra) # 80001148 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001236:	8526                	mv	a0,s1
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	608080e7          	jalr	1544(ra) # 80001840 <proc_mapstacks>
}
    80001240:	8526                	mv	a0,s1
    80001242:	60e2                	ld	ra,24(sp)
    80001244:	6442                	ld	s0,16(sp)
    80001246:	64a2                	ld	s1,8(sp)
    80001248:	6902                	ld	s2,0(sp)
    8000124a:	6105                	addi	sp,sp,32
    8000124c:	8082                	ret

000000008000124e <kvminit>:
{
    8000124e:	1141                	addi	sp,sp,-16
    80001250:	e406                	sd	ra,8(sp)
    80001252:	e022                	sd	s0,0(sp)
    80001254:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	f22080e7          	jalr	-222(ra) # 80001178 <kvmmake>
    8000125e:	00008797          	auipc	a5,0x8
    80001262:	8ea7b923          	sd	a0,-1806(a5) # 80008b50 <kernel_pagetable>
}
    80001266:	60a2                	ld	ra,8(sp)
    80001268:	6402                	ld	s0,0(sp)
    8000126a:	0141                	addi	sp,sp,16
    8000126c:	8082                	ret

000000008000126e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000126e:	715d                	addi	sp,sp,-80
    80001270:	e486                	sd	ra,72(sp)
    80001272:	e0a2                	sd	s0,64(sp)
    80001274:	fc26                	sd	s1,56(sp)
    80001276:	f84a                	sd	s2,48(sp)
    80001278:	f44e                	sd	s3,40(sp)
    8000127a:	f052                	sd	s4,32(sp)
    8000127c:	ec56                	sd	s5,24(sp)
    8000127e:	e85a                	sd	s6,16(sp)
    80001280:	e45e                	sd	s7,8(sp)
    80001282:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001284:	03459793          	slli	a5,a1,0x34
    80001288:	e795                	bnez	a5,800012b4 <uvmunmap+0x46>
    8000128a:	8a2a                	mv	s4,a0
    8000128c:	892e                	mv	s2,a1
    8000128e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001290:	0632                	slli	a2,a2,0xc
    80001292:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001296:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	6b05                	lui	s6,0x1
    8000129a:	0735e263          	bltu	a1,s3,800012fe <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000129e:	60a6                	ld	ra,72(sp)
    800012a0:	6406                	ld	s0,64(sp)
    800012a2:	74e2                	ld	s1,56(sp)
    800012a4:	7942                	ld	s2,48(sp)
    800012a6:	79a2                	ld	s3,40(sp)
    800012a8:	7a02                	ld	s4,32(sp)
    800012aa:	6ae2                	ld	s5,24(sp)
    800012ac:	6b42                	ld	s6,16(sp)
    800012ae:	6ba2                	ld	s7,8(sp)
    800012b0:	6161                	addi	sp,sp,80
    800012b2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e7450513          	addi	a0,a0,-396 # 80008128 <digits+0xe8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e7c50513          	addi	a0,a0,-388 # 80008140 <digits+0x100>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e7c50513          	addi	a0,a0,-388 # 80008150 <digits+0x110>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012e4:	00007517          	auipc	a0,0x7
    800012e8:	e8450513          	addi	a0,a0,-380 # 80008168 <digits+0x128>
    800012ec:	fffff097          	auipc	ra,0xfffff
    800012f0:	250080e7          	jalr	592(ra) # 8000053c <panic>
    *pte = 0;
    800012f4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f8:	995a                	add	s2,s2,s6
    800012fa:	fb3972e3          	bgeu	s2,s3,8000129e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012fe:	4601                	li	a2,0
    80001300:	85ca                	mv	a1,s2
    80001302:	8552                	mv	a0,s4
    80001304:	00000097          	auipc	ra,0x0
    80001308:	cbc080e7          	jalr	-836(ra) # 80000fc0 <walk>
    8000130c:	84aa                	mv	s1,a0
    8000130e:	d95d                	beqz	a0,800012c4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001310:	6108                	ld	a0,0(a0)
    80001312:	00157793          	andi	a5,a0,1
    80001316:	dfdd                	beqz	a5,800012d4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001318:	3ff57793          	andi	a5,a0,1023
    8000131c:	fd7784e3          	beq	a5,s7,800012e4 <uvmunmap+0x76>
    if(do_free){
    80001320:	fc0a8ae3          	beqz	s5,800012f4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001324:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001326:	0532                	slli	a0,a0,0xc
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	6bc080e7          	jalr	1724(ra) # 800009e4 <kfree>
    80001330:	b7d1                	j	800012f4 <uvmunmap+0x86>

0000000080001332 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001332:	1101                	addi	sp,sp,-32
    80001334:	ec06                	sd	ra,24(sp)
    80001336:	e822                	sd	s0,16(sp)
    80001338:	e426                	sd	s1,8(sp)
    8000133a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133c:	fffff097          	auipc	ra,0xfffff
    80001340:	7a6080e7          	jalr	1958(ra) # 80000ae2 <kalloc>
    80001344:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001346:	c519                	beqz	a0,80001354 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001348:	6605                	lui	a2,0x1
    8000134a:	4581                	li	a1,0
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	982080e7          	jalr	-1662(ra) # 80000cce <memset>
  return pagetable;
}
    80001354:	8526                	mv	a0,s1
    80001356:	60e2                	ld	ra,24(sp)
    80001358:	6442                	ld	s0,16(sp)
    8000135a:	64a2                	ld	s1,8(sp)
    8000135c:	6105                	addi	sp,sp,32
    8000135e:	8082                	ret

0000000080001360 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001360:	7179                	addi	sp,sp,-48
    80001362:	f406                	sd	ra,40(sp)
    80001364:	f022                	sd	s0,32(sp)
    80001366:	ec26                	sd	s1,24(sp)
    80001368:	e84a                	sd	s2,16(sp)
    8000136a:	e44e                	sd	s3,8(sp)
    8000136c:	e052                	sd	s4,0(sp)
    8000136e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001370:	6785                	lui	a5,0x1
    80001372:	04f67863          	bgeu	a2,a5,800013c2 <uvmfirst+0x62>
    80001376:	8a2a                	mv	s4,a0
    80001378:	89ae                	mv	s3,a1
    8000137a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000137c:	fffff097          	auipc	ra,0xfffff
    80001380:	766080e7          	jalr	1894(ra) # 80000ae2 <kalloc>
    80001384:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	944080e7          	jalr	-1724(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001392:	4779                	li	a4,30
    80001394:	86ca                	mv	a3,s2
    80001396:	6605                	lui	a2,0x1
    80001398:	4581                	li	a1,0
    8000139a:	8552                	mv	a0,s4
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	d0c080e7          	jalr	-756(ra) # 800010a8 <mappages>
  memmove(mem, src, sz);
    800013a4:	8626                	mv	a2,s1
    800013a6:	85ce                	mv	a1,s3
    800013a8:	854a                	mv	a0,s2
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	980080e7          	jalr	-1664(ra) # 80000d2a <memmove>
}
    800013b2:	70a2                	ld	ra,40(sp)
    800013b4:	7402                	ld	s0,32(sp)
    800013b6:	64e2                	ld	s1,24(sp)
    800013b8:	6942                	ld	s2,16(sp)
    800013ba:	69a2                	ld	s3,8(sp)
    800013bc:	6a02                	ld	s4,0(sp)
    800013be:	6145                	addi	sp,sp,48
    800013c0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013c2:	00007517          	auipc	a0,0x7
    800013c6:	dbe50513          	addi	a0,a0,-578 # 80008180 <digits+0x140>
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	172080e7          	jalr	370(ra) # 8000053c <panic>

00000000800013d2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d2:	1101                	addi	sp,sp,-32
    800013d4:	ec06                	sd	ra,24(sp)
    800013d6:	e822                	sd	s0,16(sp)
    800013d8:	e426                	sd	s1,8(sp)
    800013da:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013dc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013de:	00b67d63          	bgeu	a2,a1,800013f8 <uvmdealloc+0x26>
    800013e2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013e4:	6785                	lui	a5,0x1
    800013e6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013e8:	00f60733          	add	a4,a2,a5
    800013ec:	76fd                	lui	a3,0xfffff
    800013ee:	8f75                	and	a4,a4,a3
    800013f0:	97ae                	add	a5,a5,a1
    800013f2:	8ff5                	and	a5,a5,a3
    800013f4:	00f76863          	bltu	a4,a5,80001404 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f8:	8526                	mv	a0,s1
    800013fa:	60e2                	ld	ra,24(sp)
    800013fc:	6442                	ld	s0,16(sp)
    800013fe:	64a2                	ld	s1,8(sp)
    80001400:	6105                	addi	sp,sp,32
    80001402:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001404:	8f99                	sub	a5,a5,a4
    80001406:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001408:	4685                	li	a3,1
    8000140a:	0007861b          	sext.w	a2,a5
    8000140e:	85ba                	mv	a1,a4
    80001410:	00000097          	auipc	ra,0x0
    80001414:	e5e080e7          	jalr	-418(ra) # 8000126e <uvmunmap>
    80001418:	b7c5                	j	800013f8 <uvmdealloc+0x26>

000000008000141a <uvmalloc>:
  if(newsz < oldsz)
    8000141a:	0ab66563          	bltu	a2,a1,800014c4 <uvmalloc+0xaa>
{
    8000141e:	7139                	addi	sp,sp,-64
    80001420:	fc06                	sd	ra,56(sp)
    80001422:	f822                	sd	s0,48(sp)
    80001424:	f426                	sd	s1,40(sp)
    80001426:	f04a                	sd	s2,32(sp)
    80001428:	ec4e                	sd	s3,24(sp)
    8000142a:	e852                	sd	s4,16(sp)
    8000142c:	e456                	sd	s5,8(sp)
    8000142e:	e05a                	sd	s6,0(sp)
    80001430:	0080                	addi	s0,sp,64
    80001432:	8aaa                	mv	s5,a0
    80001434:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001436:	6785                	lui	a5,0x1
    80001438:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000143a:	95be                	add	a1,a1,a5
    8000143c:	77fd                	lui	a5,0xfffff
    8000143e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001442:	08c9f363          	bgeu	s3,a2,800014c8 <uvmalloc+0xae>
    80001446:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001448:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	696080e7          	jalr	1686(ra) # 80000ae2 <kalloc>
    80001454:	84aa                	mv	s1,a0
    if(mem == 0){
    80001456:	c51d                	beqz	a0,80001484 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001458:	6605                	lui	a2,0x1
    8000145a:	4581                	li	a1,0
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	872080e7          	jalr	-1934(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001464:	875a                	mv	a4,s6
    80001466:	86a6                	mv	a3,s1
    80001468:	6605                	lui	a2,0x1
    8000146a:	85ca                	mv	a1,s2
    8000146c:	8556                	mv	a0,s5
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	c3a080e7          	jalr	-966(ra) # 800010a8 <mappages>
    80001476:	e90d                	bnez	a0,800014a8 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001478:	6785                	lui	a5,0x1
    8000147a:	993e                	add	s2,s2,a5
    8000147c:	fd4968e3          	bltu	s2,s4,8000144c <uvmalloc+0x32>
  return newsz;
    80001480:	8552                	mv	a0,s4
    80001482:	a809                	j	80001494 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001484:	864e                	mv	a2,s3
    80001486:	85ca                	mv	a1,s2
    80001488:	8556                	mv	a0,s5
    8000148a:	00000097          	auipc	ra,0x0
    8000148e:	f48080e7          	jalr	-184(ra) # 800013d2 <uvmdealloc>
      return 0;
    80001492:	4501                	li	a0,0
}
    80001494:	70e2                	ld	ra,56(sp)
    80001496:	7442                	ld	s0,48(sp)
    80001498:	74a2                	ld	s1,40(sp)
    8000149a:	7902                	ld	s2,32(sp)
    8000149c:	69e2                	ld	s3,24(sp)
    8000149e:	6a42                	ld	s4,16(sp)
    800014a0:	6aa2                	ld	s5,8(sp)
    800014a2:	6b02                	ld	s6,0(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	53a080e7          	jalr	1338(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f1a080e7          	jalr	-230(ra) # 800013d2 <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfc9                	j	80001494 <uvmalloc+0x7a>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7e9                	j	80001494 <uvmalloc+0x7a>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a829                	j	80001500 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014ea:	00c79513          	slli	a0,a5,0xc
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	fde080e7          	jalr	-34(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014fa:	04a1                	addi	s1,s1,8
    800014fc:	03248163          	beq	s1,s2,8000151e <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001500:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001502:	00f7f713          	andi	a4,a5,15
    80001506:	ff3701e3          	beq	a4,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000150a:	8b85                	andi	a5,a5,1
    8000150c:	d7fd                	beqz	a5,800014fa <freewalk+0x2e>
      panic("freewalk: leaf");
    8000150e:	00007517          	auipc	a0,0x7
    80001512:	c9250513          	addi	a0,a0,-878 # 800081a0 <digits+0x160>
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	026080e7          	jalr	38(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000151e:	8552                	mv	a0,s4
    80001520:	fffff097          	auipc	ra,0xfffff
    80001524:	4c4080e7          	jalr	1220(ra) # 800009e4 <kfree>
}
    80001528:	70a2                	ld	ra,40(sp)
    8000152a:	7402                	ld	s0,32(sp)
    8000152c:	64e2                	ld	s1,24(sp)
    8000152e:	6942                	ld	s2,16(sp)
    80001530:	69a2                	ld	s3,8(sp)
    80001532:	6a02                	ld	s4,0(sp)
    80001534:	6145                	addi	sp,sp,48
    80001536:	8082                	ret

0000000080001538 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001538:	1101                	addi	sp,sp,-32
    8000153a:	ec06                	sd	ra,24(sp)
    8000153c:	e822                	sd	s0,16(sp)
    8000153e:	e426                	sd	s1,8(sp)
    80001540:	1000                	addi	s0,sp,32
    80001542:	84aa                	mv	s1,a0
  if(sz > 0)
    80001544:	e999                	bnez	a1,8000155a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001546:	8526                	mv	a0,s1
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	f84080e7          	jalr	-124(ra) # 800014cc <freewalk>
}
    80001550:	60e2                	ld	ra,24(sp)
    80001552:	6442                	ld	s0,16(sp)
    80001554:	64a2                	ld	s1,8(sp)
    80001556:	6105                	addi	sp,sp,32
    80001558:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000155a:	6785                	lui	a5,0x1
    8000155c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000155e:	95be                	add	a1,a1,a5
    80001560:	4685                	li	a3,1
    80001562:	00c5d613          	srli	a2,a1,0xc
    80001566:	4581                	li	a1,0
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	d06080e7          	jalr	-762(ra) # 8000126e <uvmunmap>
    80001570:	bfd9                	j	80001546 <uvmfree+0xe>

0000000080001572 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001572:	c679                	beqz	a2,80001640 <uvmcopy+0xce>
{
    80001574:	715d                	addi	sp,sp,-80
    80001576:	e486                	sd	ra,72(sp)
    80001578:	e0a2                	sd	s0,64(sp)
    8000157a:	fc26                	sd	s1,56(sp)
    8000157c:	f84a                	sd	s2,48(sp)
    8000157e:	f44e                	sd	s3,40(sp)
    80001580:	f052                	sd	s4,32(sp)
    80001582:	ec56                	sd	s5,24(sp)
    80001584:	e85a                	sd	s6,16(sp)
    80001586:	e45e                	sd	s7,8(sp)
    80001588:	0880                	addi	s0,sp,80
    8000158a:	8b2a                	mv	s6,a0
    8000158c:	8aae                	mv	s5,a1
    8000158e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001590:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001592:	4601                	li	a2,0
    80001594:	85ce                	mv	a1,s3
    80001596:	855a                	mv	a0,s6
    80001598:	00000097          	auipc	ra,0x0
    8000159c:	a28080e7          	jalr	-1496(ra) # 80000fc0 <walk>
    800015a0:	c531                	beqz	a0,800015ec <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015a2:	6118                	ld	a4,0(a0)
    800015a4:	00177793          	andi	a5,a4,1
    800015a8:	cbb1                	beqz	a5,800015fc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015aa:	00a75593          	srli	a1,a4,0xa
    800015ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	52c080e7          	jalr	1324(ra) # 80000ae2 <kalloc>
    800015be:	892a                	mv	s2,a0
    800015c0:	c939                	beqz	a0,80001616 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85de                	mv	a1,s7
    800015c6:	fffff097          	auipc	ra,0xfffff
    800015ca:	764080e7          	jalr	1892(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ce:	8726                	mv	a4,s1
    800015d0:	86ca                	mv	a3,s2
    800015d2:	6605                	lui	a2,0x1
    800015d4:	85ce                	mv	a1,s3
    800015d6:	8556                	mv	a0,s5
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	ad0080e7          	jalr	-1328(ra) # 800010a8 <mappages>
    800015e0:	e515                	bnez	a0,8000160c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015e2:	6785                	lui	a5,0x1
    800015e4:	99be                	add	s3,s3,a5
    800015e6:	fb49e6e3          	bltu	s3,s4,80001592 <uvmcopy+0x20>
    800015ea:	a081                	j	8000162a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bc450513          	addi	a0,a0,-1084 # 800081b0 <digits+0x170>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015fc:	00007517          	auipc	a0,0x7
    80001600:	bd450513          	addi	a0,a0,-1068 # 800081d0 <digits+0x190>
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	f38080e7          	jalr	-200(ra) # 8000053c <panic>
      kfree(mem);
    8000160c:	854a                	mv	a0,s2
    8000160e:	fffff097          	auipc	ra,0xfffff
    80001612:	3d6080e7          	jalr	982(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001616:	4685                	li	a3,1
    80001618:	00c9d613          	srli	a2,s3,0xc
    8000161c:	4581                	li	a1,0
    8000161e:	8556                	mv	a0,s5
    80001620:	00000097          	auipc	ra,0x0
    80001624:	c4e080e7          	jalr	-946(ra) # 8000126e <uvmunmap>
  return -1;
    80001628:	557d                	li	a0,-1
}
    8000162a:	60a6                	ld	ra,72(sp)
    8000162c:	6406                	ld	s0,64(sp)
    8000162e:	74e2                	ld	s1,56(sp)
    80001630:	7942                	ld	s2,48(sp)
    80001632:	79a2                	ld	s3,40(sp)
    80001634:	7a02                	ld	s4,32(sp)
    80001636:	6ae2                	ld	s5,24(sp)
    80001638:	6b42                	ld	s6,16(sp)
    8000163a:	6ba2                	ld	s7,8(sp)
    8000163c:	6161                	addi	sp,sp,80
    8000163e:	8082                	ret
  return 0;
    80001640:	4501                	li	a0,0
}
    80001642:	8082                	ret

0000000080001644 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001644:	1141                	addi	sp,sp,-16
    80001646:	e406                	sd	ra,8(sp)
    80001648:	e022                	sd	s0,0(sp)
    8000164a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000164c:	4601                	li	a2,0
    8000164e:	00000097          	auipc	ra,0x0
    80001652:	972080e7          	jalr	-1678(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001656:	c901                	beqz	a0,80001666 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001658:	611c                	ld	a5,0(a0)
    8000165a:	9bbd                	andi	a5,a5,-17
    8000165c:	e11c                	sd	a5,0(a0)
}
    8000165e:	60a2                	ld	ra,8(sp)
    80001660:	6402                	ld	s0,0(sp)
    80001662:	0141                	addi	sp,sp,16
    80001664:	8082                	ret
    panic("uvmclear");
    80001666:	00007517          	auipc	a0,0x7
    8000166a:	b8a50513          	addi	a0,a0,-1142 # 800081f0 <digits+0x1b0>
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	ece080e7          	jalr	-306(ra) # 8000053c <panic>

0000000080001676 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001676:	c6bd                	beqz	a3,800016e4 <copyout+0x6e>
{
    80001678:	715d                	addi	sp,sp,-80
    8000167a:	e486                	sd	ra,72(sp)
    8000167c:	e0a2                	sd	s0,64(sp)
    8000167e:	fc26                	sd	s1,56(sp)
    80001680:	f84a                	sd	s2,48(sp)
    80001682:	f44e                	sd	s3,40(sp)
    80001684:	f052                	sd	s4,32(sp)
    80001686:	ec56                	sd	s5,24(sp)
    80001688:	e85a                	sd	s6,16(sp)
    8000168a:	e45e                	sd	s7,8(sp)
    8000168c:	e062                	sd	s8,0(sp)
    8000168e:	0880                	addi	s0,sp,80
    80001690:	8b2a                	mv	s6,a0
    80001692:	8c2e                	mv	s8,a1
    80001694:	8a32                	mv	s4,a2
    80001696:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001698:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000169a:	6a85                	lui	s5,0x1
    8000169c:	a015                	j	800016c0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169e:	9562                	add	a0,a0,s8
    800016a0:	0004861b          	sext.w	a2,s1
    800016a4:	85d2                	mv	a1,s4
    800016a6:	41250533          	sub	a0,a0,s2
    800016aa:	fffff097          	auipc	ra,0xfffff
    800016ae:	680080e7          	jalr	1664(ra) # 80000d2a <memmove>

    len -= n;
    800016b2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016bc:	02098263          	beqz	s3,800016e0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016c0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c4:	85ca                	mv	a1,s2
    800016c6:	855a                	mv	a0,s6
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	99e080e7          	jalr	-1634(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800016d0:	cd01                	beqz	a0,800016e8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016d2:	418904b3          	sub	s1,s2,s8
    800016d6:	94d6                	add	s1,s1,s5
    800016d8:	fc99f3e3          	bgeu	s3,s1,8000169e <copyout+0x28>
    800016dc:	84ce                	mv	s1,s3
    800016de:	b7c1                	j	8000169e <copyout+0x28>
  }
  return 0;
    800016e0:	4501                	li	a0,0
    800016e2:	a021                	j	800016ea <copyout+0x74>
    800016e4:	4501                	li	a0,0
}
    800016e6:	8082                	ret
      return -1;
    800016e8:	557d                	li	a0,-1
}
    800016ea:	60a6                	ld	ra,72(sp)
    800016ec:	6406                	ld	s0,64(sp)
    800016ee:	74e2                	ld	s1,56(sp)
    800016f0:	7942                	ld	s2,48(sp)
    800016f2:	79a2                	ld	s3,40(sp)
    800016f4:	7a02                	ld	s4,32(sp)
    800016f6:	6ae2                	ld	s5,24(sp)
    800016f8:	6b42                	ld	s6,16(sp)
    800016fa:	6ba2                	ld	s7,8(sp)
    800016fc:	6c02                	ld	s8,0(sp)
    800016fe:	6161                	addi	sp,sp,80
    80001700:	8082                	ret

0000000080001702 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001702:	caa5                	beqz	a3,80001772 <copyin+0x70>
{
    80001704:	715d                	addi	sp,sp,-80
    80001706:	e486                	sd	ra,72(sp)
    80001708:	e0a2                	sd	s0,64(sp)
    8000170a:	fc26                	sd	s1,56(sp)
    8000170c:	f84a                	sd	s2,48(sp)
    8000170e:	f44e                	sd	s3,40(sp)
    80001710:	f052                	sd	s4,32(sp)
    80001712:	ec56                	sd	s5,24(sp)
    80001714:	e85a                	sd	s6,16(sp)
    80001716:	e45e                	sd	s7,8(sp)
    80001718:	e062                	sd	s8,0(sp)
    8000171a:	0880                	addi	s0,sp,80
    8000171c:	8b2a                	mv	s6,a0
    8000171e:	8a2e                	mv	s4,a1
    80001720:	8c32                	mv	s8,a2
    80001722:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001724:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001726:	6a85                	lui	s5,0x1
    80001728:	a01d                	j	8000174e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000172a:	018505b3          	add	a1,a0,s8
    8000172e:	0004861b          	sext.w	a2,s1
    80001732:	412585b3          	sub	a1,a1,s2
    80001736:	8552                	mv	a0,s4
    80001738:	fffff097          	auipc	ra,0xfffff
    8000173c:	5f2080e7          	jalr	1522(ra) # 80000d2a <memmove>

    len -= n;
    80001740:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001744:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001746:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000174a:	02098263          	beqz	s3,8000176e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000174e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001752:	85ca                	mv	a1,s2
    80001754:	855a                	mv	a0,s6
    80001756:	00000097          	auipc	ra,0x0
    8000175a:	910080e7          	jalr	-1776(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    8000175e:	cd01                	beqz	a0,80001776 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001760:	418904b3          	sub	s1,s2,s8
    80001764:	94d6                	add	s1,s1,s5
    80001766:	fc99f2e3          	bgeu	s3,s1,8000172a <copyin+0x28>
    8000176a:	84ce                	mv	s1,s3
    8000176c:	bf7d                	j	8000172a <copyin+0x28>
  }
  return 0;
    8000176e:	4501                	li	a0,0
    80001770:	a021                	j	80001778 <copyin+0x76>
    80001772:	4501                	li	a0,0
}
    80001774:	8082                	ret
      return -1;
    80001776:	557d                	li	a0,-1
}
    80001778:	60a6                	ld	ra,72(sp)
    8000177a:	6406                	ld	s0,64(sp)
    8000177c:	74e2                	ld	s1,56(sp)
    8000177e:	7942                	ld	s2,48(sp)
    80001780:	79a2                	ld	s3,40(sp)
    80001782:	7a02                	ld	s4,32(sp)
    80001784:	6ae2                	ld	s5,24(sp)
    80001786:	6b42                	ld	s6,16(sp)
    80001788:	6ba2                	ld	s7,8(sp)
    8000178a:	6c02                	ld	s8,0(sp)
    8000178c:	6161                	addi	sp,sp,80
    8000178e:	8082                	ret

0000000080001790 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001790:	c2dd                	beqz	a3,80001836 <copyinstr+0xa6>
{
    80001792:	715d                	addi	sp,sp,-80
    80001794:	e486                	sd	ra,72(sp)
    80001796:	e0a2                	sd	s0,64(sp)
    80001798:	fc26                	sd	s1,56(sp)
    8000179a:	f84a                	sd	s2,48(sp)
    8000179c:	f44e                	sd	s3,40(sp)
    8000179e:	f052                	sd	s4,32(sp)
    800017a0:	ec56                	sd	s5,24(sp)
    800017a2:	e85a                	sd	s6,16(sp)
    800017a4:	e45e                	sd	s7,8(sp)
    800017a6:	0880                	addi	s0,sp,80
    800017a8:	8a2a                	mv	s4,a0
    800017aa:	8b2e                	mv	s6,a1
    800017ac:	8bb2                	mv	s7,a2
    800017ae:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017b0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017b2:	6985                	lui	s3,0x1
    800017b4:	a02d                	j	800017de <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ba:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017bc:	37fd                	addiw	a5,a5,-1
    800017be:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017c2:	60a6                	ld	ra,72(sp)
    800017c4:	6406                	ld	s0,64(sp)
    800017c6:	74e2                	ld	s1,56(sp)
    800017c8:	7942                	ld	s2,48(sp)
    800017ca:	79a2                	ld	s3,40(sp)
    800017cc:	7a02                	ld	s4,32(sp)
    800017ce:	6ae2                	ld	s5,24(sp)
    800017d0:	6b42                	ld	s6,16(sp)
    800017d2:	6ba2                	ld	s7,8(sp)
    800017d4:	6161                	addi	sp,sp,80
    800017d6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017dc:	c8a9                	beqz	s1,8000182e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017de:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017e2:	85ca                	mv	a1,s2
    800017e4:	8552                	mv	a0,s4
    800017e6:	00000097          	auipc	ra,0x0
    800017ea:	880080e7          	jalr	-1920(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800017ee:	c131                	beqz	a0,80001832 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017f0:	417906b3          	sub	a3,s2,s7
    800017f4:	96ce                	add	a3,a3,s3
    800017f6:	00d4f363          	bgeu	s1,a3,800017fc <copyinstr+0x6c>
    800017fa:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017fc:	955e                	add	a0,a0,s7
    800017fe:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001802:	daf9                	beqz	a3,800017d8 <copyinstr+0x48>
    80001804:	87da                	mv	a5,s6
    80001806:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001808:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000180c:	96da                	add	a3,a3,s6
    8000180e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001810:	00f60733          	add	a4,a2,a5
    80001814:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdce20>
    80001818:	df59                	beqz	a4,800017b6 <copyinstr+0x26>
        *dst = *p;
    8000181a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000181e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001820:	fed797e3          	bne	a5,a3,8000180e <copyinstr+0x7e>
    80001824:	14fd                	addi	s1,s1,-1
    80001826:	94c2                	add	s1,s1,a6
      --max;
    80001828:	8c8d                	sub	s1,s1,a1
      dst++;
    8000182a:	8b3e                	mv	s6,a5
    8000182c:	b775                	j	800017d8 <copyinstr+0x48>
    8000182e:	4781                	li	a5,0
    80001830:	b771                	j	800017bc <copyinstr+0x2c>
      return -1;
    80001832:	557d                	li	a0,-1
    80001834:	b779                	j	800017c2 <copyinstr+0x32>
  int got_null = 0;
    80001836:	4781                	li	a5,0
  if(got_null){
    80001838:	37fd                	addiw	a5,a5,-1
    8000183a:	0007851b          	sext.w	a0,a5
}
    8000183e:	8082                	ret

0000000080001840 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001840:	7139                	addi	sp,sp,-64
    80001842:	fc06                	sd	ra,56(sp)
    80001844:	f822                	sd	s0,48(sp)
    80001846:	f426                	sd	s1,40(sp)
    80001848:	f04a                	sd	s2,32(sp)
    8000184a:	ec4e                	sd	s3,24(sp)
    8000184c:	e852                	sd	s4,16(sp)
    8000184e:	e456                	sd	s5,8(sp)
    80001850:	e05a                	sd	s6,0(sp)
    80001852:	0080                	addi	s0,sp,64
    80001854:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001856:	00010497          	auipc	s1,0x10
    8000185a:	9aa48493          	addi	s1,s1,-1622 # 80011200 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185e:	8b26                	mv	s6,s1
    80001860:	00006a97          	auipc	s5,0x6
    80001864:	7a0a8a93          	addi	s5,s5,1952 # 80008000 <etext>
    80001868:	04000937          	lui	s2,0x4000
    8000186c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000186e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001870:	00015a17          	auipc	s4,0x15
    80001874:	590a0a13          	addi	s4,s4,1424 # 80016e00 <tickslock>
    char *pa = kalloc();
    80001878:	fffff097          	auipc	ra,0xfffff
    8000187c:	26a080e7          	jalr	618(ra) # 80000ae2 <kalloc>
    80001880:	862a                	mv	a2,a0
    if(pa == 0)
    80001882:	c131                	beqz	a0,800018c6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001884:	416485b3          	sub	a1,s1,s6
    80001888:	8591                	srai	a1,a1,0x4
    8000188a:	000ab783          	ld	a5,0(s5)
    8000188e:	02f585b3          	mul	a1,a1,a5
    80001892:	2585                	addiw	a1,a1,1
    80001894:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001898:	4719                	li	a4,6
    8000189a:	6685                	lui	a3,0x1
    8000189c:	40b905b3          	sub	a1,s2,a1
    800018a0:	854e                	mv	a0,s3
    800018a2:	00000097          	auipc	ra,0x0
    800018a6:	8a6080e7          	jalr	-1882(ra) # 80001148 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018aa:	17048493          	addi	s1,s1,368
    800018ae:	fd4495e3          	bne	s1,s4,80001878 <proc_mapstacks+0x38>
  }
}
    800018b2:	70e2                	ld	ra,56(sp)
    800018b4:	7442                	ld	s0,48(sp)
    800018b6:	74a2                	ld	s1,40(sp)
    800018b8:	7902                	ld	s2,32(sp)
    800018ba:	69e2                	ld	s3,24(sp)
    800018bc:	6a42                	ld	s4,16(sp)
    800018be:	6aa2                	ld	s5,8(sp)
    800018c0:	6b02                	ld	s6,0(sp)
    800018c2:	6121                	addi	sp,sp,64
    800018c4:	8082                	ret
      panic("kalloc");
    800018c6:	00007517          	auipc	a0,0x7
    800018ca:	93a50513          	addi	a0,a0,-1734 # 80008200 <digits+0x1c0>
    800018ce:	fffff097          	auipc	ra,0xfffff
    800018d2:	c6e080e7          	jalr	-914(ra) # 8000053c <panic>

00000000800018d6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018d6:	7139                	addi	sp,sp,-64
    800018d8:	fc06                	sd	ra,56(sp)
    800018da:	f822                	sd	s0,48(sp)
    800018dc:	f426                	sd	s1,40(sp)
    800018de:	f04a                	sd	s2,32(sp)
    800018e0:	ec4e                	sd	s3,24(sp)
    800018e2:	e852                	sd	s4,16(sp)
    800018e4:	e456                	sd	s5,8(sp)
    800018e6:	e05a                	sd	s6,0(sp)
    800018e8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018ea:	00007597          	auipc	a1,0x7
    800018ee:	91e58593          	addi	a1,a1,-1762 # 80008208 <digits+0x1c8>
    800018f2:	0000f517          	auipc	a0,0xf
    800018f6:	4de50513          	addi	a0,a0,1246 # 80010dd0 <pid_lock>
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	248080e7          	jalr	584(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001902:	00007597          	auipc	a1,0x7
    80001906:	90e58593          	addi	a1,a1,-1778 # 80008210 <digits+0x1d0>
    8000190a:	0000f517          	auipc	a0,0xf
    8000190e:	4de50513          	addi	a0,a0,1246 # 80010de8 <wait_lock>
    80001912:	fffff097          	auipc	ra,0xfffff
    80001916:	230080e7          	jalr	560(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191a:	00010497          	auipc	s1,0x10
    8000191e:	8e648493          	addi	s1,s1,-1818 # 80011200 <proc>
      initlock(&p->lock, "proc");
    80001922:	00007b17          	auipc	s6,0x7
    80001926:	8feb0b13          	addi	s6,s6,-1794 # 80008220 <digits+0x1e0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000192a:	8aa6                	mv	s5,s1
    8000192c:	00006a17          	auipc	s4,0x6
    80001930:	6d4a0a13          	addi	s4,s4,1748 # 80008000 <etext>
    80001934:	04000937          	lui	s2,0x4000
    80001938:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000193a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193c:	00015997          	auipc	s3,0x15
    80001940:	4c498993          	addi	s3,s3,1220 # 80016e00 <tickslock>
      initlock(&p->lock, "proc");
    80001944:	85da                	mv	a1,s6
    80001946:	8526                	mv	a0,s1
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	1fa080e7          	jalr	506(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001950:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001954:	415487b3          	sub	a5,s1,s5
    80001958:	8791                	srai	a5,a5,0x4
    8000195a:	000a3703          	ld	a4,0(s4)
    8000195e:	02e787b3          	mul	a5,a5,a4
    80001962:	2785                	addiw	a5,a5,1
    80001964:	00d7979b          	slliw	a5,a5,0xd
    80001968:	40f907b3          	sub	a5,s2,a5
    8000196c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000196e:	17048493          	addi	s1,s1,368
    80001972:	fd3499e3          	bne	s1,s3,80001944 <procinit+0x6e>
  }
}
    80001976:	70e2                	ld	ra,56(sp)
    80001978:	7442                	ld	s0,48(sp)
    8000197a:	74a2                	ld	s1,40(sp)
    8000197c:	7902                	ld	s2,32(sp)
    8000197e:	69e2                	ld	s3,24(sp)
    80001980:	6a42                	ld	s4,16(sp)
    80001982:	6aa2                	ld	s5,8(sp)
    80001984:	6b02                	ld	s6,0(sp)
    80001986:	6121                	addi	sp,sp,64
    80001988:	8082                	ret

000000008000198a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000198a:	1141                	addi	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001990:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001992:	2501                	sext.w	a0,a0
    80001994:	6422                	ld	s0,8(sp)
    80001996:	0141                	addi	sp,sp,16
    80001998:	8082                	ret

000000008000199a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000199a:	1141                	addi	sp,sp,-16
    8000199c:	e422                	sd	s0,8(sp)
    8000199e:	0800                	addi	s0,sp,16
    800019a0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a2:	2781                	sext.w	a5,a5
    800019a4:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a6:	0000f517          	auipc	a0,0xf
    800019aa:	45a50513          	addi	a0,a0,1114 # 80010e00 <cpus>
    800019ae:	953e                	add	a0,a0,a5
    800019b0:	6422                	ld	s0,8(sp)
    800019b2:	0141                	addi	sp,sp,16
    800019b4:	8082                	ret

00000000800019b6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019b6:	1101                	addi	sp,sp,-32
    800019b8:	ec06                	sd	ra,24(sp)
    800019ba:	e822                	sd	s0,16(sp)
    800019bc:	e426                	sd	s1,8(sp)
    800019be:	1000                	addi	s0,sp,32
  push_off();
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	1c6080e7          	jalr	454(ra) # 80000b86 <push_off>
    800019c8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ca:	2781                	sext.w	a5,a5
    800019cc:	079e                	slli	a5,a5,0x7
    800019ce:	0000f717          	auipc	a4,0xf
    800019d2:	40270713          	addi	a4,a4,1026 # 80010dd0 <pid_lock>
    800019d6:	97ba                	add	a5,a5,a4
    800019d8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	24c080e7          	jalr	588(ra) # 80000c26 <pop_off>
  return p;
}
    800019e2:	8526                	mv	a0,s1
    800019e4:	60e2                	ld	ra,24(sp)
    800019e6:	6442                	ld	s0,16(sp)
    800019e8:	64a2                	ld	s1,8(sp)
    800019ea:	6105                	addi	sp,sp,32
    800019ec:	8082                	ret

00000000800019ee <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ee:	1141                	addi	sp,sp,-16
    800019f0:	e406                	sd	ra,8(sp)
    800019f2:	e022                	sd	s0,0(sp)
    800019f4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f6:	00000097          	auipc	ra,0x0
    800019fa:	fc0080e7          	jalr	-64(ra) # 800019b6 <myproc>
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	288080e7          	jalr	648(ra) # 80000c86 <release>

  if (first) {
    80001a06:	00007797          	auipc	a5,0x7
    80001a0a:	f4a7a783          	lw	a5,-182(a5) # 80008950 <first.1>
    80001a0e:	eb89                	bnez	a5,80001a20 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a10:	00001097          	auipc	ra,0x1
    80001a14:	c68080e7          	jalr	-920(ra) # 80002678 <usertrapret>
}
    80001a18:	60a2                	ld	ra,8(sp)
    80001a1a:	6402                	ld	s0,0(sp)
    80001a1c:	0141                	addi	sp,sp,16
    80001a1e:	8082                	ret
    first = 0;
    80001a20:	00007797          	auipc	a5,0x7
    80001a24:	f207a823          	sw	zero,-208(a5) # 80008950 <first.1>
    fsinit(ROOTDEV);
    80001a28:	4505                	li	a0,1
    80001a2a:	00002097          	auipc	ra,0x2
    80001a2e:	ac4080e7          	jalr	-1340(ra) # 800034ee <fsinit>
    80001a32:	bff9                	j	80001a10 <forkret+0x22>

0000000080001a34 <allocpid>:
{
    80001a34:	1101                	addi	sp,sp,-32
    80001a36:	ec06                	sd	ra,24(sp)
    80001a38:	e822                	sd	s0,16(sp)
    80001a3a:	e426                	sd	s1,8(sp)
    80001a3c:	e04a                	sd	s2,0(sp)
    80001a3e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a40:	0000f917          	auipc	s2,0xf
    80001a44:	39090913          	addi	s2,s2,912 # 80010dd0 <pid_lock>
    80001a48:	854a                	mv	a0,s2
    80001a4a:	fffff097          	auipc	ra,0xfffff
    80001a4e:	188080e7          	jalr	392(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a52:	00007797          	auipc	a5,0x7
    80001a56:	f0278793          	addi	a5,a5,-254 # 80008954 <nextpid>
    80001a5a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a5c:	0014871b          	addiw	a4,s1,1
    80001a60:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a62:	854a                	mv	a0,s2
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	222080e7          	jalr	546(ra) # 80000c86 <release>
}
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	60e2                	ld	ra,24(sp)
    80001a70:	6442                	ld	s0,16(sp)
    80001a72:	64a2                	ld	s1,8(sp)
    80001a74:	6902                	ld	s2,0(sp)
    80001a76:	6105                	addi	sp,sp,32
    80001a78:	8082                	ret

0000000080001a7a <proc_pagetable>:
{
    80001a7a:	1101                	addi	sp,sp,-32
    80001a7c:	ec06                	sd	ra,24(sp)
    80001a7e:	e822                	sd	s0,16(sp)
    80001a80:	e426                	sd	s1,8(sp)
    80001a82:	e04a                	sd	s2,0(sp)
    80001a84:	1000                	addi	s0,sp,32
    80001a86:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a88:	00000097          	auipc	ra,0x0
    80001a8c:	8aa080e7          	jalr	-1878(ra) # 80001332 <uvmcreate>
    80001a90:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a92:	c121                	beqz	a0,80001ad2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a94:	4729                	li	a4,10
    80001a96:	00005697          	auipc	a3,0x5
    80001a9a:	56a68693          	addi	a3,a3,1386 # 80007000 <_trampoline>
    80001a9e:	6605                	lui	a2,0x1
    80001aa0:	040005b7          	lui	a1,0x4000
    80001aa4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa6:	05b2                	slli	a1,a1,0xc
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	600080e7          	jalr	1536(ra) # 800010a8 <mappages>
    80001ab0:	02054863          	bltz	a0,80001ae0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ab4:	4719                	li	a4,6
    80001ab6:	05893683          	ld	a3,88(s2)
    80001aba:	6605                	lui	a2,0x1
    80001abc:	020005b7          	lui	a1,0x2000
    80001ac0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac2:	05b6                	slli	a1,a1,0xd
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	5e2080e7          	jalr	1506(ra) # 800010a8 <mappages>
    80001ace:	02054163          	bltz	a0,80001af0 <proc_pagetable+0x76>
}
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	60e2                	ld	ra,24(sp)
    80001ad6:	6442                	ld	s0,16(sp)
    80001ad8:	64a2                	ld	s1,8(sp)
    80001ada:	6902                	ld	s2,0(sp)
    80001adc:	6105                	addi	sp,sp,32
    80001ade:	8082                	ret
    uvmfree(pagetable, 0);
    80001ae0:	4581                	li	a1,0
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	00000097          	auipc	ra,0x0
    80001ae8:	a54080e7          	jalr	-1452(ra) # 80001538 <uvmfree>
    return 0;
    80001aec:	4481                	li	s1,0
    80001aee:	b7d5                	j	80001ad2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001af0:	4681                	li	a3,0
    80001af2:	4605                	li	a2,1
    80001af4:	040005b7          	lui	a1,0x4000
    80001af8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001afa:	05b2                	slli	a1,a1,0xc
    80001afc:	8526                	mv	a0,s1
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	770080e7          	jalr	1904(ra) # 8000126e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b06:	4581                	li	a1,0
    80001b08:	8526                	mv	a0,s1
    80001b0a:	00000097          	auipc	ra,0x0
    80001b0e:	a2e080e7          	jalr	-1490(ra) # 80001538 <uvmfree>
    return 0;
    80001b12:	4481                	li	s1,0
    80001b14:	bf7d                	j	80001ad2 <proc_pagetable+0x58>

0000000080001b16 <proc_freepagetable>:
{
    80001b16:	1101                	addi	sp,sp,-32
    80001b18:	ec06                	sd	ra,24(sp)
    80001b1a:	e822                	sd	s0,16(sp)
    80001b1c:	e426                	sd	s1,8(sp)
    80001b1e:	e04a                	sd	s2,0(sp)
    80001b20:	1000                	addi	s0,sp,32
    80001b22:	84aa                	mv	s1,a0
    80001b24:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b26:	4681                	li	a3,0
    80001b28:	4605                	li	a2,1
    80001b2a:	040005b7          	lui	a1,0x4000
    80001b2e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b30:	05b2                	slli	a1,a1,0xc
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	73c080e7          	jalr	1852(ra) # 8000126e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b3a:	4681                	li	a3,0
    80001b3c:	4605                	li	a2,1
    80001b3e:	020005b7          	lui	a1,0x2000
    80001b42:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b44:	05b6                	slli	a1,a1,0xd
    80001b46:	8526                	mv	a0,s1
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	726080e7          	jalr	1830(ra) # 8000126e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b50:	85ca                	mv	a1,s2
    80001b52:	8526                	mv	a0,s1
    80001b54:	00000097          	auipc	ra,0x0
    80001b58:	9e4080e7          	jalr	-1564(ra) # 80001538 <uvmfree>
}
    80001b5c:	60e2                	ld	ra,24(sp)
    80001b5e:	6442                	ld	s0,16(sp)
    80001b60:	64a2                	ld	s1,8(sp)
    80001b62:	6902                	ld	s2,0(sp)
    80001b64:	6105                	addi	sp,sp,32
    80001b66:	8082                	ret

0000000080001b68 <freeproc>:
{
    80001b68:	1101                	addi	sp,sp,-32
    80001b6a:	ec06                	sd	ra,24(sp)
    80001b6c:	e822                	sd	s0,16(sp)
    80001b6e:	e426                	sd	s1,8(sp)
    80001b70:	1000                	addi	s0,sp,32
    80001b72:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b74:	6d28                	ld	a0,88(a0)
    80001b76:	c509                	beqz	a0,80001b80 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	e6c080e7          	jalr	-404(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b80:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b84:	68a8                	ld	a0,80(s1)
    80001b86:	c511                	beqz	a0,80001b92 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b88:	64ac                	ld	a1,72(s1)
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	f8c080e7          	jalr	-116(ra) # 80001b16 <proc_freepagetable>
  p->pagetable = 0;
    80001b92:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b96:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b9a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b9e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001baa:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bae:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb2:	0004ac23          	sw	zero,24(s1)
  p->trace_mask = 0;
    80001bb6:	1604a423          	sw	zero,360(s1)
}
    80001bba:	60e2                	ld	ra,24(sp)
    80001bbc:	6442                	ld	s0,16(sp)
    80001bbe:	64a2                	ld	s1,8(sp)
    80001bc0:	6105                	addi	sp,sp,32
    80001bc2:	8082                	ret

0000000080001bc4 <allocproc>:
{
    80001bc4:	1101                	addi	sp,sp,-32
    80001bc6:	ec06                	sd	ra,24(sp)
    80001bc8:	e822                	sd	s0,16(sp)
    80001bca:	e426                	sd	s1,8(sp)
    80001bcc:	e04a                	sd	s2,0(sp)
    80001bce:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd0:	0000f497          	auipc	s1,0xf
    80001bd4:	63048493          	addi	s1,s1,1584 # 80011200 <proc>
    80001bd8:	00015917          	auipc	s2,0x15
    80001bdc:	22890913          	addi	s2,s2,552 # 80016e00 <tickslock>
    acquire(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	ff0080e7          	jalr	-16(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bea:	4c9c                	lw	a5,24(s1)
    80001bec:	cf81                	beqz	a5,80001c04 <allocproc+0x40>
      release(&p->lock);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	096080e7          	jalr	150(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf8:	17048493          	addi	s1,s1,368
    80001bfc:	ff2492e3          	bne	s1,s2,80001be0 <allocproc+0x1c>
  return 0;
    80001c00:	4481                	li	s1,0
    80001c02:	a889                	j	80001c54 <allocproc+0x90>
  p->pid = allocpid();
    80001c04:	00000097          	auipc	ra,0x0
    80001c08:	e30080e7          	jalr	-464(ra) # 80001a34 <allocpid>
    80001c0c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c0e:	4785                	li	a5,1
    80001c10:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	ed0080e7          	jalr	-304(ra) # 80000ae2 <kalloc>
    80001c1a:	892a                	mv	s2,a0
    80001c1c:	eca8                	sd	a0,88(s1)
    80001c1e:	c131                	beqz	a0,80001c62 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c20:	8526                	mv	a0,s1
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	e58080e7          	jalr	-424(ra) # 80001a7a <proc_pagetable>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c2e:	c531                	beqz	a0,80001c7a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c30:	07000613          	li	a2,112
    80001c34:	4581                	li	a1,0
    80001c36:	06048513          	addi	a0,s1,96
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	094080e7          	jalr	148(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c42:	00000797          	auipc	a5,0x0
    80001c46:	dac78793          	addi	a5,a5,-596 # 800019ee <forkret>
    80001c4a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4c:	60bc                	ld	a5,64(s1)
    80001c4e:	6705                	lui	a4,0x1
    80001c50:	97ba                	add	a5,a5,a4
    80001c52:	f4bc                	sd	a5,104(s1)
}
    80001c54:	8526                	mv	a0,s1
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6902                	ld	s2,0(sp)
    80001c5e:	6105                	addi	sp,sp,32
    80001c60:	8082                	ret
    freeproc(p);
    80001c62:	8526                	mv	a0,s1
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	f04080e7          	jalr	-252(ra) # 80001b68 <freeproc>
    release(&p->lock);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	fffff097          	auipc	ra,0xfffff
    80001c72:	018080e7          	jalr	24(ra) # 80000c86 <release>
    return 0;
    80001c76:	84ca                	mv	s1,s2
    80001c78:	bff1                	j	80001c54 <allocproc+0x90>
    freeproc(p);
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	00000097          	auipc	ra,0x0
    80001c80:	eec080e7          	jalr	-276(ra) # 80001b68 <freeproc>
    release(&p->lock);
    80001c84:	8526                	mv	a0,s1
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	000080e7          	jalr	ra # 80000c86 <release>
    return 0;
    80001c8e:	84ca                	mv	s1,s2
    80001c90:	b7d1                	j	80001c54 <allocproc+0x90>

0000000080001c92 <userinit>:
{
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	f28080e7          	jalr	-216(ra) # 80001bc4 <allocproc>
    80001ca4:	84aa                	mv	s1,a0
  initproc = p;
    80001ca6:	00007797          	auipc	a5,0x7
    80001caa:	eaa7b923          	sd	a0,-334(a5) # 80008b58 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cae:	03400613          	li	a2,52
    80001cb2:	00007597          	auipc	a1,0x7
    80001cb6:	cae58593          	addi	a1,a1,-850 # 80008960 <initcode>
    80001cba:	6928                	ld	a0,80(a0)
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	6a4080e7          	jalr	1700(ra) # 80001360 <uvmfirst>
  p->sz = PGSIZE;
    80001cc4:	6785                	lui	a5,0x1
    80001cc6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cc8:	6cb8                	ld	a4,88(s1)
    80001cca:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cce:	6cb8                	ld	a4,88(s1)
    80001cd0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cd2:	4641                	li	a2,16
    80001cd4:	00006597          	auipc	a1,0x6
    80001cd8:	55458593          	addi	a1,a1,1364 # 80008228 <digits+0x1e8>
    80001cdc:	15848513          	addi	a0,s1,344
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	136080e7          	jalr	310(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001ce8:	00006517          	auipc	a0,0x6
    80001cec:	55050513          	addi	a0,a0,1360 # 80008238 <digits+0x1f8>
    80001cf0:	00002097          	auipc	ra,0x2
    80001cf4:	21c080e7          	jalr	540(ra) # 80003f0c <namei>
    80001cf8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cfc:	478d                	li	a5,3
    80001cfe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	f84080e7          	jalr	-124(ra) # 80000c86 <release>
}
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6105                	addi	sp,sp,32
    80001d12:	8082                	ret

0000000080001d14 <growproc>:
{
    80001d14:	1101                	addi	sp,sp,-32
    80001d16:	ec06                	sd	ra,24(sp)
    80001d18:	e822                	sd	s0,16(sp)
    80001d1a:	e426                	sd	s1,8(sp)
    80001d1c:	e04a                	sd	s2,0(sp)
    80001d1e:	1000                	addi	s0,sp,32
    80001d20:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d22:	00000097          	auipc	ra,0x0
    80001d26:	c94080e7          	jalr	-876(ra) # 800019b6 <myproc>
    80001d2a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d2c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d2e:	01204c63          	bgtz	s2,80001d46 <growproc+0x32>
  } else if(n < 0){
    80001d32:	02094663          	bltz	s2,80001d5e <growproc+0x4a>
  p->sz = sz;
    80001d36:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d38:	4501                	li	a0,0
}
    80001d3a:	60e2                	ld	ra,24(sp)
    80001d3c:	6442                	ld	s0,16(sp)
    80001d3e:	64a2                	ld	s1,8(sp)
    80001d40:	6902                	ld	s2,0(sp)
    80001d42:	6105                	addi	sp,sp,32
    80001d44:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d46:	4691                	li	a3,4
    80001d48:	00b90633          	add	a2,s2,a1
    80001d4c:	6928                	ld	a0,80(a0)
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	6cc080e7          	jalr	1740(ra) # 8000141a <uvmalloc>
    80001d56:	85aa                	mv	a1,a0
    80001d58:	fd79                	bnez	a0,80001d36 <growproc+0x22>
      return -1;
    80001d5a:	557d                	li	a0,-1
    80001d5c:	bff9                	j	80001d3a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d5e:	00b90633          	add	a2,s2,a1
    80001d62:	6928                	ld	a0,80(a0)
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	66e080e7          	jalr	1646(ra) # 800013d2 <uvmdealloc>
    80001d6c:	85aa                	mv	a1,a0
    80001d6e:	b7e1                	j	80001d36 <growproc+0x22>

0000000080001d70 <fork>:
{
    80001d70:	7139                	addi	sp,sp,-64
    80001d72:	fc06                	sd	ra,56(sp)
    80001d74:	f822                	sd	s0,48(sp)
    80001d76:	f426                	sd	s1,40(sp)
    80001d78:	f04a                	sd	s2,32(sp)
    80001d7a:	ec4e                	sd	s3,24(sp)
    80001d7c:	e852                	sd	s4,16(sp)
    80001d7e:	e456                	sd	s5,8(sp)
    80001d80:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	c34080e7          	jalr	-972(ra) # 800019b6 <myproc>
    80001d8a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d8c:	00000097          	auipc	ra,0x0
    80001d90:	e38080e7          	jalr	-456(ra) # 80001bc4 <allocproc>
    80001d94:	12050063          	beqz	a0,80001eb4 <fork+0x144>
    80001d98:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d9a:	048ab603          	ld	a2,72(s5)
    80001d9e:	692c                	ld	a1,80(a0)
    80001da0:	050ab503          	ld	a0,80(s5)
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	7ce080e7          	jalr	1998(ra) # 80001572 <uvmcopy>
    80001dac:	04054863          	bltz	a0,80001dfc <fork+0x8c>
  np->sz = p->sz;
    80001db0:	048ab783          	ld	a5,72(s5)
    80001db4:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001db8:	058ab683          	ld	a3,88(s5)
    80001dbc:	87b6                	mv	a5,a3
    80001dbe:	0589b703          	ld	a4,88(s3)
    80001dc2:	12068693          	addi	a3,a3,288
    80001dc6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dca:	6788                	ld	a0,8(a5)
    80001dcc:	6b8c                	ld	a1,16(a5)
    80001dce:	6f90                	ld	a2,24(a5)
    80001dd0:	01073023          	sd	a6,0(a4)
    80001dd4:	e708                	sd	a0,8(a4)
    80001dd6:	eb0c                	sd	a1,16(a4)
    80001dd8:	ef10                	sd	a2,24(a4)
    80001dda:	02078793          	addi	a5,a5,32
    80001dde:	02070713          	addi	a4,a4,32
    80001de2:	fed792e3          	bne	a5,a3,80001dc6 <fork+0x56>
  np->trapframe->a0 = 0;
    80001de6:	0589b783          	ld	a5,88(s3)
    80001dea:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dee:	0d0a8493          	addi	s1,s5,208
    80001df2:	0d098913          	addi	s2,s3,208
    80001df6:	150a8a13          	addi	s4,s5,336
    80001dfa:	a00d                	j	80001e1c <fork+0xac>
    freeproc(np);
    80001dfc:	854e                	mv	a0,s3
    80001dfe:	00000097          	auipc	ra,0x0
    80001e02:	d6a080e7          	jalr	-662(ra) # 80001b68 <freeproc>
    release(&np->lock);
    80001e06:	854e                	mv	a0,s3
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	e7e080e7          	jalr	-386(ra) # 80000c86 <release>
    return -1;
    80001e10:	597d                	li	s2,-1
    80001e12:	a079                	j	80001ea0 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e14:	04a1                	addi	s1,s1,8
    80001e16:	0921                	addi	s2,s2,8
    80001e18:	01448b63          	beq	s1,s4,80001e2e <fork+0xbe>
    if(p->ofile[i])
    80001e1c:	6088                	ld	a0,0(s1)
    80001e1e:	d97d                	beqz	a0,80001e14 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e20:	00002097          	auipc	ra,0x2
    80001e24:	75e080e7          	jalr	1886(ra) # 8000457e <filedup>
    80001e28:	00a93023          	sd	a0,0(s2)
    80001e2c:	b7e5                	j	80001e14 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e2e:	150ab503          	ld	a0,336(s5)
    80001e32:	00002097          	auipc	ra,0x2
    80001e36:	8f6080e7          	jalr	-1802(ra) # 80003728 <idup>
    80001e3a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e3e:	4641                	li	a2,16
    80001e40:	158a8593          	addi	a1,s5,344
    80001e44:	15898513          	addi	a0,s3,344
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	fce080e7          	jalr	-50(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e50:	0309a903          	lw	s2,48(s3)
  np->trace_mask = p->trace_mask;
    80001e54:	168aa783          	lw	a5,360(s5)
    80001e58:	16f9a423          	sw	a5,360(s3)
  release(&np->lock);
    80001e5c:	854e                	mv	a0,s3
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	e28080e7          	jalr	-472(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e66:	0000f497          	auipc	s1,0xf
    80001e6a:	f8248493          	addi	s1,s1,-126 # 80010de8 <wait_lock>
    80001e6e:	8526                	mv	a0,s1
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	d62080e7          	jalr	-670(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e78:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	e08080e7          	jalr	-504(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e86:	854e                	mv	a0,s3
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	d4a080e7          	jalr	-694(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e90:	478d                	li	a5,3
    80001e92:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e96:	854e                	mv	a0,s3
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	dee080e7          	jalr	-530(ra) # 80000c86 <release>
}
    80001ea0:	854a                	mv	a0,s2
    80001ea2:	70e2                	ld	ra,56(sp)
    80001ea4:	7442                	ld	s0,48(sp)
    80001ea6:	74a2                	ld	s1,40(sp)
    80001ea8:	7902                	ld	s2,32(sp)
    80001eaa:	69e2                	ld	s3,24(sp)
    80001eac:	6a42                	ld	s4,16(sp)
    80001eae:	6aa2                	ld	s5,8(sp)
    80001eb0:	6121                	addi	sp,sp,64
    80001eb2:	8082                	ret
    return -1;
    80001eb4:	597d                	li	s2,-1
    80001eb6:	b7ed                	j	80001ea0 <fork+0x130>

0000000080001eb8 <scheduler>:
{
    80001eb8:	7139                	addi	sp,sp,-64
    80001eba:	fc06                	sd	ra,56(sp)
    80001ebc:	f822                	sd	s0,48(sp)
    80001ebe:	f426                	sd	s1,40(sp)
    80001ec0:	f04a                	sd	s2,32(sp)
    80001ec2:	ec4e                	sd	s3,24(sp)
    80001ec4:	e852                	sd	s4,16(sp)
    80001ec6:	e456                	sd	s5,8(sp)
    80001ec8:	e05a                	sd	s6,0(sp)
    80001eca:	0080                	addi	s0,sp,64
    80001ecc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ece:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ed0:	00779a93          	slli	s5,a5,0x7
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	efc70713          	addi	a4,a4,-260 # 80010dd0 <pid_lock>
    80001edc:	9756                	add	a4,a4,s5
    80001ede:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ee2:	0000f717          	auipc	a4,0xf
    80001ee6:	f2670713          	addi	a4,a4,-218 # 80010e08 <cpus+0x8>
    80001eea:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001eec:	498d                	li	s3,3
        p->state = RUNNING;
    80001eee:	4b11                	li	s6,4
        c->proc = p;
    80001ef0:	079e                	slli	a5,a5,0x7
    80001ef2:	0000fa17          	auipc	s4,0xf
    80001ef6:	edea0a13          	addi	s4,s4,-290 # 80010dd0 <pid_lock>
    80001efa:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001efc:	00015917          	auipc	s2,0x15
    80001f00:	f0490913          	addi	s2,s2,-252 # 80016e00 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f04:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f08:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f0c:	10079073          	csrw	sstatus,a5
    80001f10:	0000f497          	auipc	s1,0xf
    80001f14:	2f048493          	addi	s1,s1,752 # 80011200 <proc>
    80001f18:	a811                	j	80001f2c <scheduler+0x74>
      release(&p->lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	d6a080e7          	jalr	-662(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f24:	17048493          	addi	s1,s1,368
    80001f28:	fd248ee3          	beq	s1,s2,80001f04 <scheduler+0x4c>
      acquire(&p->lock);
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	fffff097          	auipc	ra,0xfffff
    80001f32:	ca4080e7          	jalr	-860(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f36:	4c9c                	lw	a5,24(s1)
    80001f38:	ff3791e3          	bne	a5,s3,80001f1a <scheduler+0x62>
        p->state = RUNNING;
    80001f3c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f40:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f44:	06048593          	addi	a1,s1,96
    80001f48:	8556                	mv	a0,s5
    80001f4a:	00000097          	auipc	ra,0x0
    80001f4e:	684080e7          	jalr	1668(ra) # 800025ce <swtch>
        c->proc = 0;
    80001f52:	020a3823          	sd	zero,48(s4)
    80001f56:	b7d1                	j	80001f1a <scheduler+0x62>

0000000080001f58 <sched>:
{
    80001f58:	7179                	addi	sp,sp,-48
    80001f5a:	f406                	sd	ra,40(sp)
    80001f5c:	f022                	sd	s0,32(sp)
    80001f5e:	ec26                	sd	s1,24(sp)
    80001f60:	e84a                	sd	s2,16(sp)
    80001f62:	e44e                	sd	s3,8(sp)
    80001f64:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f66:	00000097          	auipc	ra,0x0
    80001f6a:	a50080e7          	jalr	-1456(ra) # 800019b6 <myproc>
    80001f6e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	be8080e7          	jalr	-1048(ra) # 80000b58 <holding>
    80001f78:	c93d                	beqz	a0,80001fee <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f7a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f7c:	2781                	sext.w	a5,a5
    80001f7e:	079e                	slli	a5,a5,0x7
    80001f80:	0000f717          	auipc	a4,0xf
    80001f84:	e5070713          	addi	a4,a4,-432 # 80010dd0 <pid_lock>
    80001f88:	97ba                	add	a5,a5,a4
    80001f8a:	0a87a703          	lw	a4,168(a5)
    80001f8e:	4785                	li	a5,1
    80001f90:	06f71763          	bne	a4,a5,80001ffe <sched+0xa6>
  if(p->state == RUNNING)
    80001f94:	4c98                	lw	a4,24(s1)
    80001f96:	4791                	li	a5,4
    80001f98:	06f70b63          	beq	a4,a5,8000200e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fa0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fa2:	efb5                	bnez	a5,8000201e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fa6:	0000f917          	auipc	s2,0xf
    80001faa:	e2a90913          	addi	s2,s2,-470 # 80010dd0 <pid_lock>
    80001fae:	2781                	sext.w	a5,a5
    80001fb0:	079e                	slli	a5,a5,0x7
    80001fb2:	97ca                	add	a5,a5,s2
    80001fb4:	0ac7a983          	lw	s3,172(a5)
    80001fb8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fba:	2781                	sext.w	a5,a5
    80001fbc:	079e                	slli	a5,a5,0x7
    80001fbe:	0000f597          	auipc	a1,0xf
    80001fc2:	e4a58593          	addi	a1,a1,-438 # 80010e08 <cpus+0x8>
    80001fc6:	95be                	add	a1,a1,a5
    80001fc8:	06048513          	addi	a0,s1,96
    80001fcc:	00000097          	auipc	ra,0x0
    80001fd0:	602080e7          	jalr	1538(ra) # 800025ce <swtch>
    80001fd4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fd6:	2781                	sext.w	a5,a5
    80001fd8:	079e                	slli	a5,a5,0x7
    80001fda:	993e                	add	s2,s2,a5
    80001fdc:	0b392623          	sw	s3,172(s2)
}
    80001fe0:	70a2                	ld	ra,40(sp)
    80001fe2:	7402                	ld	s0,32(sp)
    80001fe4:	64e2                	ld	s1,24(sp)
    80001fe6:	6942                	ld	s2,16(sp)
    80001fe8:	69a2                	ld	s3,8(sp)
    80001fea:	6145                	addi	sp,sp,48
    80001fec:	8082                	ret
    panic("sched p->lock");
    80001fee:	00006517          	auipc	a0,0x6
    80001ff2:	25250513          	addi	a0,a0,594 # 80008240 <digits+0x200>
    80001ff6:	ffffe097          	auipc	ra,0xffffe
    80001ffa:	546080e7          	jalr	1350(ra) # 8000053c <panic>
    panic("sched locks");
    80001ffe:	00006517          	auipc	a0,0x6
    80002002:	25250513          	addi	a0,a0,594 # 80008250 <digits+0x210>
    80002006:	ffffe097          	auipc	ra,0xffffe
    8000200a:	536080e7          	jalr	1334(ra) # 8000053c <panic>
    panic("sched running");
    8000200e:	00006517          	auipc	a0,0x6
    80002012:	25250513          	addi	a0,a0,594 # 80008260 <digits+0x220>
    80002016:	ffffe097          	auipc	ra,0xffffe
    8000201a:	526080e7          	jalr	1318(ra) # 8000053c <panic>
    panic("sched interruptible");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	25250513          	addi	a0,a0,594 # 80008270 <digits+0x230>
    80002026:	ffffe097          	auipc	ra,0xffffe
    8000202a:	516080e7          	jalr	1302(ra) # 8000053c <panic>

000000008000202e <yield>:
{
    8000202e:	1101                	addi	sp,sp,-32
    80002030:	ec06                	sd	ra,24(sp)
    80002032:	e822                	sd	s0,16(sp)
    80002034:	e426                	sd	s1,8(sp)
    80002036:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	97e080e7          	jalr	-1666(ra) # 800019b6 <myproc>
    80002040:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	b90080e7          	jalr	-1136(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000204a:	478d                	li	a5,3
    8000204c:	cc9c                	sw	a5,24(s1)
  sched();
    8000204e:	00000097          	auipc	ra,0x0
    80002052:	f0a080e7          	jalr	-246(ra) # 80001f58 <sched>
  release(&p->lock);
    80002056:	8526                	mv	a0,s1
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	c2e080e7          	jalr	-978(ra) # 80000c86 <release>
}
    80002060:	60e2                	ld	ra,24(sp)
    80002062:	6442                	ld	s0,16(sp)
    80002064:	64a2                	ld	s1,8(sp)
    80002066:	6105                	addi	sp,sp,32
    80002068:	8082                	ret

000000008000206a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000206a:	7179                	addi	sp,sp,-48
    8000206c:	f406                	sd	ra,40(sp)
    8000206e:	f022                	sd	s0,32(sp)
    80002070:	ec26                	sd	s1,24(sp)
    80002072:	e84a                	sd	s2,16(sp)
    80002074:	e44e                	sd	s3,8(sp)
    80002076:	1800                	addi	s0,sp,48
    80002078:	89aa                	mv	s3,a0
    8000207a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000207c:	00000097          	auipc	ra,0x0
    80002080:	93a080e7          	jalr	-1734(ra) # 800019b6 <myproc>
    80002084:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	b4c080e7          	jalr	-1204(ra) # 80000bd2 <acquire>
  release(lk);
    8000208e:	854a                	mv	a0,s2
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	bf6080e7          	jalr	-1034(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    80002098:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000209c:	4789                	li	a5,2
    8000209e:	cc9c                	sw	a5,24(s1)

  sched();
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	eb8080e7          	jalr	-328(ra) # 80001f58 <sched>

  // Tidy up.
  p->chan = 0;
    800020a8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	bd8080e7          	jalr	-1064(ra) # 80000c86 <release>
  acquire(lk);
    800020b6:	854a                	mv	a0,s2
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	b1a080e7          	jalr	-1254(ra) # 80000bd2 <acquire>
}
    800020c0:	70a2                	ld	ra,40(sp)
    800020c2:	7402                	ld	s0,32(sp)
    800020c4:	64e2                	ld	s1,24(sp)
    800020c6:	6942                	ld	s2,16(sp)
    800020c8:	69a2                	ld	s3,8(sp)
    800020ca:	6145                	addi	sp,sp,48
    800020cc:	8082                	ret

00000000800020ce <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020ce:	7139                	addi	sp,sp,-64
    800020d0:	fc06                	sd	ra,56(sp)
    800020d2:	f822                	sd	s0,48(sp)
    800020d4:	f426                	sd	s1,40(sp)
    800020d6:	f04a                	sd	s2,32(sp)
    800020d8:	ec4e                	sd	s3,24(sp)
    800020da:	e852                	sd	s4,16(sp)
    800020dc:	e456                	sd	s5,8(sp)
    800020de:	0080                	addi	s0,sp,64
    800020e0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020e2:	0000f497          	auipc	s1,0xf
    800020e6:	11e48493          	addi	s1,s1,286 # 80011200 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ea:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020ec:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ee:	00015917          	auipc	s2,0x15
    800020f2:	d1290913          	addi	s2,s2,-750 # 80016e00 <tickslock>
    800020f6:	a811                	j	8000210a <wakeup+0x3c>
      }
      release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	b8c080e7          	jalr	-1140(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002102:	17048493          	addi	s1,s1,368
    80002106:	03248663          	beq	s1,s2,80002132 <wakeup+0x64>
    if(p != myproc()){
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	8ac080e7          	jalr	-1876(ra) # 800019b6 <myproc>
    80002112:	fea488e3          	beq	s1,a0,80002102 <wakeup+0x34>
      acquire(&p->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	aba080e7          	jalr	-1350(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002120:	4c9c                	lw	a5,24(s1)
    80002122:	fd379be3          	bne	a5,s3,800020f8 <wakeup+0x2a>
    80002126:	709c                	ld	a5,32(s1)
    80002128:	fd4798e3          	bne	a5,s4,800020f8 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000212c:	0154ac23          	sw	s5,24(s1)
    80002130:	b7e1                	j	800020f8 <wakeup+0x2a>
    }
  }
}
    80002132:	70e2                	ld	ra,56(sp)
    80002134:	7442                	ld	s0,48(sp)
    80002136:	74a2                	ld	s1,40(sp)
    80002138:	7902                	ld	s2,32(sp)
    8000213a:	69e2                	ld	s3,24(sp)
    8000213c:	6a42                	ld	s4,16(sp)
    8000213e:	6aa2                	ld	s5,8(sp)
    80002140:	6121                	addi	sp,sp,64
    80002142:	8082                	ret

0000000080002144 <reparent>:
{
    80002144:	7179                	addi	sp,sp,-48
    80002146:	f406                	sd	ra,40(sp)
    80002148:	f022                	sd	s0,32(sp)
    8000214a:	ec26                	sd	s1,24(sp)
    8000214c:	e84a                	sd	s2,16(sp)
    8000214e:	e44e                	sd	s3,8(sp)
    80002150:	e052                	sd	s4,0(sp)
    80002152:	1800                	addi	s0,sp,48
    80002154:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002156:	0000f497          	auipc	s1,0xf
    8000215a:	0aa48493          	addi	s1,s1,170 # 80011200 <proc>
      pp->parent = initproc;
    8000215e:	00007a17          	auipc	s4,0x7
    80002162:	9faa0a13          	addi	s4,s4,-1542 # 80008b58 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002166:	00015997          	auipc	s3,0x15
    8000216a:	c9a98993          	addi	s3,s3,-870 # 80016e00 <tickslock>
    8000216e:	a029                	j	80002178 <reparent+0x34>
    80002170:	17048493          	addi	s1,s1,368
    80002174:	01348d63          	beq	s1,s3,8000218e <reparent+0x4a>
    if(pp->parent == p){
    80002178:	7c9c                	ld	a5,56(s1)
    8000217a:	ff279be3          	bne	a5,s2,80002170 <reparent+0x2c>
      pp->parent = initproc;
    8000217e:	000a3503          	ld	a0,0(s4)
    80002182:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002184:	00000097          	auipc	ra,0x0
    80002188:	f4a080e7          	jalr	-182(ra) # 800020ce <wakeup>
    8000218c:	b7d5                	j	80002170 <reparent+0x2c>
}
    8000218e:	70a2                	ld	ra,40(sp)
    80002190:	7402                	ld	s0,32(sp)
    80002192:	64e2                	ld	s1,24(sp)
    80002194:	6942                	ld	s2,16(sp)
    80002196:	69a2                	ld	s3,8(sp)
    80002198:	6a02                	ld	s4,0(sp)
    8000219a:	6145                	addi	sp,sp,48
    8000219c:	8082                	ret

000000008000219e <exit>:
{
    8000219e:	7179                	addi	sp,sp,-48
    800021a0:	f406                	sd	ra,40(sp)
    800021a2:	f022                	sd	s0,32(sp)
    800021a4:	ec26                	sd	s1,24(sp)
    800021a6:	e84a                	sd	s2,16(sp)
    800021a8:	e44e                	sd	s3,8(sp)
    800021aa:	e052                	sd	s4,0(sp)
    800021ac:	1800                	addi	s0,sp,48
    800021ae:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021b0:	00000097          	auipc	ra,0x0
    800021b4:	806080e7          	jalr	-2042(ra) # 800019b6 <myproc>
    800021b8:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ba:	00007797          	auipc	a5,0x7
    800021be:	99e7b783          	ld	a5,-1634(a5) # 80008b58 <initproc>
    800021c2:	0d050493          	addi	s1,a0,208
    800021c6:	15050913          	addi	s2,a0,336
    800021ca:	02a79363          	bne	a5,a0,800021f0 <exit+0x52>
    panic("init exiting");
    800021ce:	00006517          	auipc	a0,0x6
    800021d2:	0ba50513          	addi	a0,a0,186 # 80008288 <digits+0x248>
    800021d6:	ffffe097          	auipc	ra,0xffffe
    800021da:	366080e7          	jalr	870(ra) # 8000053c <panic>
      fileclose(f);
    800021de:	00002097          	auipc	ra,0x2
    800021e2:	3f2080e7          	jalr	1010(ra) # 800045d0 <fileclose>
      p->ofile[fd] = 0;
    800021e6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021ea:	04a1                	addi	s1,s1,8
    800021ec:	01248563          	beq	s1,s2,800021f6 <exit+0x58>
    if(p->ofile[fd]){
    800021f0:	6088                	ld	a0,0(s1)
    800021f2:	f575                	bnez	a0,800021de <exit+0x40>
    800021f4:	bfdd                	j	800021ea <exit+0x4c>
  begin_op();
    800021f6:	00002097          	auipc	ra,0x2
    800021fa:	f16080e7          	jalr	-234(ra) # 8000410c <begin_op>
  iput(p->cwd);
    800021fe:	1509b503          	ld	a0,336(s3)
    80002202:	00001097          	auipc	ra,0x1
    80002206:	71e080e7          	jalr	1822(ra) # 80003920 <iput>
  end_op();
    8000220a:	00002097          	auipc	ra,0x2
    8000220e:	f7c080e7          	jalr	-132(ra) # 80004186 <end_op>
  p->cwd = 0;
    80002212:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002216:	0000f497          	auipc	s1,0xf
    8000221a:	bd248493          	addi	s1,s1,-1070 # 80010de8 <wait_lock>
    8000221e:	8526                	mv	a0,s1
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	9b2080e7          	jalr	-1614(ra) # 80000bd2 <acquire>
  reparent(p);
    80002228:	854e                	mv	a0,s3
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	f1a080e7          	jalr	-230(ra) # 80002144 <reparent>
  wakeup(p->parent);
    80002232:	0389b503          	ld	a0,56(s3)
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	e98080e7          	jalr	-360(ra) # 800020ce <wakeup>
  acquire(&p->lock);
    8000223e:	854e                	mv	a0,s3
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	992080e7          	jalr	-1646(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002248:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000224c:	4795                	li	a5,5
    8000224e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002252:	8526                	mv	a0,s1
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	a32080e7          	jalr	-1486(ra) # 80000c86 <release>
  sched();
    8000225c:	00000097          	auipc	ra,0x0
    80002260:	cfc080e7          	jalr	-772(ra) # 80001f58 <sched>
  panic("zombie exit");
    80002264:	00006517          	auipc	a0,0x6
    80002268:	03450513          	addi	a0,a0,52 # 80008298 <digits+0x258>
    8000226c:	ffffe097          	auipc	ra,0xffffe
    80002270:	2d0080e7          	jalr	720(ra) # 8000053c <panic>

0000000080002274 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002274:	7179                	addi	sp,sp,-48
    80002276:	f406                	sd	ra,40(sp)
    80002278:	f022                	sd	s0,32(sp)
    8000227a:	ec26                	sd	s1,24(sp)
    8000227c:	e84a                	sd	s2,16(sp)
    8000227e:	e44e                	sd	s3,8(sp)
    80002280:	1800                	addi	s0,sp,48
    80002282:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002284:	0000f497          	auipc	s1,0xf
    80002288:	f7c48493          	addi	s1,s1,-132 # 80011200 <proc>
    8000228c:	00015997          	auipc	s3,0x15
    80002290:	b7498993          	addi	s3,s3,-1164 # 80016e00 <tickslock>
    acquire(&p->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	93c080e7          	jalr	-1732(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    8000229e:	589c                	lw	a5,48(s1)
    800022a0:	01278d63          	beq	a5,s2,800022ba <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022a4:	8526                	mv	a0,s1
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	9e0080e7          	jalr	-1568(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ae:	17048493          	addi	s1,s1,368
    800022b2:	ff3491e3          	bne	s1,s3,80002294 <kill+0x20>
  }
  return -1;
    800022b6:	557d                	li	a0,-1
    800022b8:	a829                	j	800022d2 <kill+0x5e>
      p->killed = 1;
    800022ba:	4785                	li	a5,1
    800022bc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022be:	4c98                	lw	a4,24(s1)
    800022c0:	4789                	li	a5,2
    800022c2:	00f70f63          	beq	a4,a5,800022e0 <kill+0x6c>
      release(&p->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	9be080e7          	jalr	-1602(ra) # 80000c86 <release>
      return 0;
    800022d0:	4501                	li	a0,0
}
    800022d2:	70a2                	ld	ra,40(sp)
    800022d4:	7402                	ld	s0,32(sp)
    800022d6:	64e2                	ld	s1,24(sp)
    800022d8:	6942                	ld	s2,16(sp)
    800022da:	69a2                	ld	s3,8(sp)
    800022dc:	6145                	addi	sp,sp,48
    800022de:	8082                	ret
        p->state = RUNNABLE;
    800022e0:	478d                	li	a5,3
    800022e2:	cc9c                	sw	a5,24(s1)
    800022e4:	b7cd                	j	800022c6 <kill+0x52>

00000000800022e6 <setkilled>:

void
setkilled(struct proc *p)
{
    800022e6:	1101                	addi	sp,sp,-32
    800022e8:	ec06                	sd	ra,24(sp)
    800022ea:	e822                	sd	s0,16(sp)
    800022ec:	e426                	sd	s1,8(sp)
    800022ee:	1000                	addi	s0,sp,32
    800022f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	8e0080e7          	jalr	-1824(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800022fa:	4785                	li	a5,1
    800022fc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022fe:	8526                	mv	a0,s1
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	986080e7          	jalr	-1658(ra) # 80000c86 <release>
}
    80002308:	60e2                	ld	ra,24(sp)
    8000230a:	6442                	ld	s0,16(sp)
    8000230c:	64a2                	ld	s1,8(sp)
    8000230e:	6105                	addi	sp,sp,32
    80002310:	8082                	ret

0000000080002312 <killed>:

int
killed(struct proc *p)
{
    80002312:	1101                	addi	sp,sp,-32
    80002314:	ec06                	sd	ra,24(sp)
    80002316:	e822                	sd	s0,16(sp)
    80002318:	e426                	sd	s1,8(sp)
    8000231a:	e04a                	sd	s2,0(sp)
    8000231c:	1000                	addi	s0,sp,32
    8000231e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	8b2080e7          	jalr	-1870(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002328:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	958080e7          	jalr	-1704(ra) # 80000c86 <release>
  return k;
}
    80002336:	854a                	mv	a0,s2
    80002338:	60e2                	ld	ra,24(sp)
    8000233a:	6442                	ld	s0,16(sp)
    8000233c:	64a2                	ld	s1,8(sp)
    8000233e:	6902                	ld	s2,0(sp)
    80002340:	6105                	addi	sp,sp,32
    80002342:	8082                	ret

0000000080002344 <wait>:
{
    80002344:	715d                	addi	sp,sp,-80
    80002346:	e486                	sd	ra,72(sp)
    80002348:	e0a2                	sd	s0,64(sp)
    8000234a:	fc26                	sd	s1,56(sp)
    8000234c:	f84a                	sd	s2,48(sp)
    8000234e:	f44e                	sd	s3,40(sp)
    80002350:	f052                	sd	s4,32(sp)
    80002352:	ec56                	sd	s5,24(sp)
    80002354:	e85a                	sd	s6,16(sp)
    80002356:	e45e                	sd	s7,8(sp)
    80002358:	e062                	sd	s8,0(sp)
    8000235a:	0880                	addi	s0,sp,80
    8000235c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	658080e7          	jalr	1624(ra) # 800019b6 <myproc>
    80002366:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002368:	0000f517          	auipc	a0,0xf
    8000236c:	a8050513          	addi	a0,a0,-1408 # 80010de8 <wait_lock>
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	862080e7          	jalr	-1950(ra) # 80000bd2 <acquire>
    havekids = 0;
    80002378:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000237a:	4a15                	li	s4,5
        havekids = 1;
    8000237c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000237e:	00015997          	auipc	s3,0x15
    80002382:	a8298993          	addi	s3,s3,-1406 # 80016e00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002386:	0000fc17          	auipc	s8,0xf
    8000238a:	a62c0c13          	addi	s8,s8,-1438 # 80010de8 <wait_lock>
    8000238e:	a0d1                	j	80002452 <wait+0x10e>
          pid = pp->pid;
    80002390:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002394:	000b0e63          	beqz	s6,800023b0 <wait+0x6c>
    80002398:	4691                	li	a3,4
    8000239a:	02c48613          	addi	a2,s1,44
    8000239e:	85da                	mv	a1,s6
    800023a0:	05093503          	ld	a0,80(s2)
    800023a4:	fffff097          	auipc	ra,0xfffff
    800023a8:	2d2080e7          	jalr	722(ra) # 80001676 <copyout>
    800023ac:	04054163          	bltz	a0,800023ee <wait+0xaa>
          freeproc(pp);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	7b6080e7          	jalr	1974(ra) # 80001b68 <freeproc>
          release(&pp->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	8ca080e7          	jalr	-1846(ra) # 80000c86 <release>
          release(&wait_lock);
    800023c4:	0000f517          	auipc	a0,0xf
    800023c8:	a2450513          	addi	a0,a0,-1500 # 80010de8 <wait_lock>
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8ba080e7          	jalr	-1862(ra) # 80000c86 <release>
}
    800023d4:	854e                	mv	a0,s3
    800023d6:	60a6                	ld	ra,72(sp)
    800023d8:	6406                	ld	s0,64(sp)
    800023da:	74e2                	ld	s1,56(sp)
    800023dc:	7942                	ld	s2,48(sp)
    800023de:	79a2                	ld	s3,40(sp)
    800023e0:	7a02                	ld	s4,32(sp)
    800023e2:	6ae2                	ld	s5,24(sp)
    800023e4:	6b42                	ld	s6,16(sp)
    800023e6:	6ba2                	ld	s7,8(sp)
    800023e8:	6c02                	ld	s8,0(sp)
    800023ea:	6161                	addi	sp,sp,80
    800023ec:	8082                	ret
            release(&pp->lock);
    800023ee:	8526                	mv	a0,s1
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	896080e7          	jalr	-1898(ra) # 80000c86 <release>
            release(&wait_lock);
    800023f8:	0000f517          	auipc	a0,0xf
    800023fc:	9f050513          	addi	a0,a0,-1552 # 80010de8 <wait_lock>
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	886080e7          	jalr	-1914(ra) # 80000c86 <release>
            return -1;
    80002408:	59fd                	li	s3,-1
    8000240a:	b7e9                	j	800023d4 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000240c:	17048493          	addi	s1,s1,368
    80002410:	03348463          	beq	s1,s3,80002438 <wait+0xf4>
      if(pp->parent == p){
    80002414:	7c9c                	ld	a5,56(s1)
    80002416:	ff279be3          	bne	a5,s2,8000240c <wait+0xc8>
        acquire(&pp->lock);
    8000241a:	8526                	mv	a0,s1
    8000241c:	ffffe097          	auipc	ra,0xffffe
    80002420:	7b6080e7          	jalr	1974(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002424:	4c9c                	lw	a5,24(s1)
    80002426:	f74785e3          	beq	a5,s4,80002390 <wait+0x4c>
        release(&pp->lock);
    8000242a:	8526                	mv	a0,s1
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	85a080e7          	jalr	-1958(ra) # 80000c86 <release>
        havekids = 1;
    80002434:	8756                	mv	a4,s5
    80002436:	bfd9                	j	8000240c <wait+0xc8>
    if(!havekids || killed(p)){
    80002438:	c31d                	beqz	a4,8000245e <wait+0x11a>
    8000243a:	854a                	mv	a0,s2
    8000243c:	00000097          	auipc	ra,0x0
    80002440:	ed6080e7          	jalr	-298(ra) # 80002312 <killed>
    80002444:	ed09                	bnez	a0,8000245e <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002446:	85e2                	mv	a1,s8
    80002448:	854a                	mv	a0,s2
    8000244a:	00000097          	auipc	ra,0x0
    8000244e:	c20080e7          	jalr	-992(ra) # 8000206a <sleep>
    havekids = 0;
    80002452:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002454:	0000f497          	auipc	s1,0xf
    80002458:	dac48493          	addi	s1,s1,-596 # 80011200 <proc>
    8000245c:	bf65                	j	80002414 <wait+0xd0>
      release(&wait_lock);
    8000245e:	0000f517          	auipc	a0,0xf
    80002462:	98a50513          	addi	a0,a0,-1654 # 80010de8 <wait_lock>
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	820080e7          	jalr	-2016(ra) # 80000c86 <release>
      return -1;
    8000246e:	59fd                	li	s3,-1
    80002470:	b795                	j	800023d4 <wait+0x90>

0000000080002472 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002472:	7179                	addi	sp,sp,-48
    80002474:	f406                	sd	ra,40(sp)
    80002476:	f022                	sd	s0,32(sp)
    80002478:	ec26                	sd	s1,24(sp)
    8000247a:	e84a                	sd	s2,16(sp)
    8000247c:	e44e                	sd	s3,8(sp)
    8000247e:	e052                	sd	s4,0(sp)
    80002480:	1800                	addi	s0,sp,48
    80002482:	84aa                	mv	s1,a0
    80002484:	892e                	mv	s2,a1
    80002486:	89b2                	mv	s3,a2
    80002488:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	52c080e7          	jalr	1324(ra) # 800019b6 <myproc>
  if(user_dst){
    80002492:	c08d                	beqz	s1,800024b4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002494:	86d2                	mv	a3,s4
    80002496:	864e                	mv	a2,s3
    80002498:	85ca                	mv	a1,s2
    8000249a:	6928                	ld	a0,80(a0)
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	1da080e7          	jalr	474(ra) # 80001676 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024a4:	70a2                	ld	ra,40(sp)
    800024a6:	7402                	ld	s0,32(sp)
    800024a8:	64e2                	ld	s1,24(sp)
    800024aa:	6942                	ld	s2,16(sp)
    800024ac:	69a2                	ld	s3,8(sp)
    800024ae:	6a02                	ld	s4,0(sp)
    800024b0:	6145                	addi	sp,sp,48
    800024b2:	8082                	ret
    memmove((char *)dst, src, len);
    800024b4:	000a061b          	sext.w	a2,s4
    800024b8:	85ce                	mv	a1,s3
    800024ba:	854a                	mv	a0,s2
    800024bc:	fffff097          	auipc	ra,0xfffff
    800024c0:	86e080e7          	jalr	-1938(ra) # 80000d2a <memmove>
    return 0;
    800024c4:	8526                	mv	a0,s1
    800024c6:	bff9                	j	800024a4 <either_copyout+0x32>

00000000800024c8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024c8:	7179                	addi	sp,sp,-48
    800024ca:	f406                	sd	ra,40(sp)
    800024cc:	f022                	sd	s0,32(sp)
    800024ce:	ec26                	sd	s1,24(sp)
    800024d0:	e84a                	sd	s2,16(sp)
    800024d2:	e44e                	sd	s3,8(sp)
    800024d4:	e052                	sd	s4,0(sp)
    800024d6:	1800                	addi	s0,sp,48
    800024d8:	892a                	mv	s2,a0
    800024da:	84ae                	mv	s1,a1
    800024dc:	89b2                	mv	s3,a2
    800024de:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024e0:	fffff097          	auipc	ra,0xfffff
    800024e4:	4d6080e7          	jalr	1238(ra) # 800019b6 <myproc>
  if(user_src){
    800024e8:	c08d                	beqz	s1,8000250a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ea:	86d2                	mv	a3,s4
    800024ec:	864e                	mv	a2,s3
    800024ee:	85ca                	mv	a1,s2
    800024f0:	6928                	ld	a0,80(a0)
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	210080e7          	jalr	528(ra) # 80001702 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024fa:	70a2                	ld	ra,40(sp)
    800024fc:	7402                	ld	s0,32(sp)
    800024fe:	64e2                	ld	s1,24(sp)
    80002500:	6942                	ld	s2,16(sp)
    80002502:	69a2                	ld	s3,8(sp)
    80002504:	6a02                	ld	s4,0(sp)
    80002506:	6145                	addi	sp,sp,48
    80002508:	8082                	ret
    memmove(dst, (char*)src, len);
    8000250a:	000a061b          	sext.w	a2,s4
    8000250e:	85ce                	mv	a1,s3
    80002510:	854a                	mv	a0,s2
    80002512:	fffff097          	auipc	ra,0xfffff
    80002516:	818080e7          	jalr	-2024(ra) # 80000d2a <memmove>
    return 0;
    8000251a:	8526                	mv	a0,s1
    8000251c:	bff9                	j	800024fa <either_copyin+0x32>

000000008000251e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000251e:	715d                	addi	sp,sp,-80
    80002520:	e486                	sd	ra,72(sp)
    80002522:	e0a2                	sd	s0,64(sp)
    80002524:	fc26                	sd	s1,56(sp)
    80002526:	f84a                	sd	s2,48(sp)
    80002528:	f44e                	sd	s3,40(sp)
    8000252a:	f052                	sd	s4,32(sp)
    8000252c:	ec56                	sd	s5,24(sp)
    8000252e:	e85a                	sd	s6,16(sp)
    80002530:	e45e                	sd	s7,8(sp)
    80002532:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002534:	00006517          	auipc	a0,0x6
    80002538:	bbc50513          	addi	a0,a0,-1092 # 800080f0 <digits+0xb0>
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	04a080e7          	jalr	74(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002544:	0000f497          	auipc	s1,0xf
    80002548:	e1448493          	addi	s1,s1,-492 # 80011358 <proc+0x158>
    8000254c:	00015917          	auipc	s2,0x15
    80002550:	a0c90913          	addi	s2,s2,-1524 # 80016f58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002554:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002556:	00006997          	auipc	s3,0x6
    8000255a:	d5298993          	addi	s3,s3,-686 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    8000255e:	00006a97          	auipc	s5,0x6
    80002562:	d52a8a93          	addi	s5,s5,-686 # 800082b0 <digits+0x270>
    printf("\n");
    80002566:	00006a17          	auipc	s4,0x6
    8000256a:	b8aa0a13          	addi	s4,s4,-1142 # 800080f0 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000256e:	00006b97          	auipc	s7,0x6
    80002572:	d82b8b93          	addi	s7,s7,-638 # 800082f0 <states.0>
    80002576:	a00d                	j	80002598 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002578:	ed86a583          	lw	a1,-296(a3)
    8000257c:	8556                	mv	a0,s5
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	008080e7          	jalr	8(ra) # 80000586 <printf>
    printf("\n");
    80002586:	8552                	mv	a0,s4
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	ffe080e7          	jalr	-2(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002590:	17048493          	addi	s1,s1,368
    80002594:	03248263          	beq	s1,s2,800025b8 <procdump+0x9a>
    if(p->state == UNUSED)
    80002598:	86a6                	mv	a3,s1
    8000259a:	ec04a783          	lw	a5,-320(s1)
    8000259e:	dbed                	beqz	a5,80002590 <procdump+0x72>
      state = "???";
    800025a0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a2:	fcfb6be3          	bltu	s6,a5,80002578 <procdump+0x5a>
    800025a6:	02079713          	slli	a4,a5,0x20
    800025aa:	01d75793          	srli	a5,a4,0x1d
    800025ae:	97de                	add	a5,a5,s7
    800025b0:	6390                	ld	a2,0(a5)
    800025b2:	f279                	bnez	a2,80002578 <procdump+0x5a>
      state = "???";
    800025b4:	864e                	mv	a2,s3
    800025b6:	b7c9                	j	80002578 <procdump+0x5a>
  }
}
    800025b8:	60a6                	ld	ra,72(sp)
    800025ba:	6406                	ld	s0,64(sp)
    800025bc:	74e2                	ld	s1,56(sp)
    800025be:	7942                	ld	s2,48(sp)
    800025c0:	79a2                	ld	s3,40(sp)
    800025c2:	7a02                	ld	s4,32(sp)
    800025c4:	6ae2                	ld	s5,24(sp)
    800025c6:	6b42                	ld	s6,16(sp)
    800025c8:	6ba2                	ld	s7,8(sp)
    800025ca:	6161                	addi	sp,sp,80
    800025cc:	8082                	ret

00000000800025ce <swtch>:
    800025ce:	00153023          	sd	ra,0(a0)
    800025d2:	00253423          	sd	sp,8(a0)
    800025d6:	e900                	sd	s0,16(a0)
    800025d8:	ed04                	sd	s1,24(a0)
    800025da:	03253023          	sd	s2,32(a0)
    800025de:	03353423          	sd	s3,40(a0)
    800025e2:	03453823          	sd	s4,48(a0)
    800025e6:	03553c23          	sd	s5,56(a0)
    800025ea:	05653023          	sd	s6,64(a0)
    800025ee:	05753423          	sd	s7,72(a0)
    800025f2:	05853823          	sd	s8,80(a0)
    800025f6:	05953c23          	sd	s9,88(a0)
    800025fa:	07a53023          	sd	s10,96(a0)
    800025fe:	07b53423          	sd	s11,104(a0)
    80002602:	0005b083          	ld	ra,0(a1)
    80002606:	0085b103          	ld	sp,8(a1)
    8000260a:	6980                	ld	s0,16(a1)
    8000260c:	6d84                	ld	s1,24(a1)
    8000260e:	0205b903          	ld	s2,32(a1)
    80002612:	0285b983          	ld	s3,40(a1)
    80002616:	0305ba03          	ld	s4,48(a1)
    8000261a:	0385ba83          	ld	s5,56(a1)
    8000261e:	0405bb03          	ld	s6,64(a1)
    80002622:	0485bb83          	ld	s7,72(a1)
    80002626:	0505bc03          	ld	s8,80(a1)
    8000262a:	0585bc83          	ld	s9,88(a1)
    8000262e:	0605bd03          	ld	s10,96(a1)
    80002632:	0685bd83          	ld	s11,104(a1)
    80002636:	8082                	ret

0000000080002638 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002638:	1141                	addi	sp,sp,-16
    8000263a:	e406                	sd	ra,8(sp)
    8000263c:	e022                	sd	s0,0(sp)
    8000263e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002640:	00006597          	auipc	a1,0x6
    80002644:	ce058593          	addi	a1,a1,-800 # 80008320 <states.0+0x30>
    80002648:	00014517          	auipc	a0,0x14
    8000264c:	7b850513          	addi	a0,a0,1976 # 80016e00 <tickslock>
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	4f2080e7          	jalr	1266(ra) # 80000b42 <initlock>
}
    80002658:	60a2                	ld	ra,8(sp)
    8000265a:	6402                	ld	s0,0(sp)
    8000265c:	0141                	addi	sp,sp,16
    8000265e:	8082                	ret

0000000080002660 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002660:	1141                	addi	sp,sp,-16
    80002662:	e422                	sd	s0,8(sp)
    80002664:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002666:	00003797          	auipc	a5,0x3
    8000266a:	58a78793          	addi	a5,a5,1418 # 80005bf0 <kernelvec>
    8000266e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002672:	6422                	ld	s0,8(sp)
    80002674:	0141                	addi	sp,sp,16
    80002676:	8082                	ret

0000000080002678 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002678:	1141                	addi	sp,sp,-16
    8000267a:	e406                	sd	ra,8(sp)
    8000267c:	e022                	sd	s0,0(sp)
    8000267e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002680:	fffff097          	auipc	ra,0xfffff
    80002684:	336080e7          	jalr	822(ra) # 800019b6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002688:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000268c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000268e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002692:	00005697          	auipc	a3,0x5
    80002696:	96e68693          	addi	a3,a3,-1682 # 80007000 <_trampoline>
    8000269a:	00005717          	auipc	a4,0x5
    8000269e:	96670713          	addi	a4,a4,-1690 # 80007000 <_trampoline>
    800026a2:	8f15                	sub	a4,a4,a3
    800026a4:	040007b7          	lui	a5,0x4000
    800026a8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026aa:	07b2                	slli	a5,a5,0xc
    800026ac:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ae:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026b2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026b4:	18002673          	csrr	a2,satp
    800026b8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ba:	6d30                	ld	a2,88(a0)
    800026bc:	6138                	ld	a4,64(a0)
    800026be:	6585                	lui	a1,0x1
    800026c0:	972e                	add	a4,a4,a1
    800026c2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026c4:	6d38                	ld	a4,88(a0)
    800026c6:	00000617          	auipc	a2,0x0
    800026ca:	13460613          	addi	a2,a2,308 # 800027fa <usertrap>
    800026ce:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026d0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026d2:	8612                	mv	a2,tp
    800026d4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026da:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026de:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026e6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026e8:	6f18                	ld	a4,24(a4)
    800026ea:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026ee:	6928                	ld	a0,80(a0)
    800026f0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026f2:	00005717          	auipc	a4,0x5
    800026f6:	9aa70713          	addi	a4,a4,-1622 # 8000709c <userret>
    800026fa:	8f15                	sub	a4,a4,a3
    800026fc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026fe:	577d                	li	a4,-1
    80002700:	177e                	slli	a4,a4,0x3f
    80002702:	8d59                	or	a0,a0,a4
    80002704:	9782                	jalr	a5
}
    80002706:	60a2                	ld	ra,8(sp)
    80002708:	6402                	ld	s0,0(sp)
    8000270a:	0141                	addi	sp,sp,16
    8000270c:	8082                	ret

000000008000270e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000270e:	1101                	addi	sp,sp,-32
    80002710:	ec06                	sd	ra,24(sp)
    80002712:	e822                	sd	s0,16(sp)
    80002714:	e426                	sd	s1,8(sp)
    80002716:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002718:	00014497          	auipc	s1,0x14
    8000271c:	6e848493          	addi	s1,s1,1768 # 80016e00 <tickslock>
    80002720:	8526                	mv	a0,s1
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	4b0080e7          	jalr	1200(ra) # 80000bd2 <acquire>
  ticks++;
    8000272a:	00006517          	auipc	a0,0x6
    8000272e:	43650513          	addi	a0,a0,1078 # 80008b60 <ticks>
    80002732:	411c                	lw	a5,0(a0)
    80002734:	2785                	addiw	a5,a5,1
    80002736:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002738:	00000097          	auipc	ra,0x0
    8000273c:	996080e7          	jalr	-1642(ra) # 800020ce <wakeup>
  release(&tickslock);
    80002740:	8526                	mv	a0,s1
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	544080e7          	jalr	1348(ra) # 80000c86 <release>
}
    8000274a:	60e2                	ld	ra,24(sp)
    8000274c:	6442                	ld	s0,16(sp)
    8000274e:	64a2                	ld	s1,8(sp)
    80002750:	6105                	addi	sp,sp,32
    80002752:	8082                	ret

0000000080002754 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002754:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002758:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000275a:	0807df63          	bgez	a5,800027f8 <devintr+0xa4>
{
    8000275e:	1101                	addi	sp,sp,-32
    80002760:	ec06                	sd	ra,24(sp)
    80002762:	e822                	sd	s0,16(sp)
    80002764:	e426                	sd	s1,8(sp)
    80002766:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002768:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000276c:	46a5                	li	a3,9
    8000276e:	00d70d63          	beq	a4,a3,80002788 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002772:	577d                	li	a4,-1
    80002774:	177e                	slli	a4,a4,0x3f
    80002776:	0705                	addi	a4,a4,1
    return 0;
    80002778:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000277a:	04e78e63          	beq	a5,a4,800027d6 <devintr+0x82>
  }
}
    8000277e:	60e2                	ld	ra,24(sp)
    80002780:	6442                	ld	s0,16(sp)
    80002782:	64a2                	ld	s1,8(sp)
    80002784:	6105                	addi	sp,sp,32
    80002786:	8082                	ret
    int irq = plic_claim();
    80002788:	00003097          	auipc	ra,0x3
    8000278c:	570080e7          	jalr	1392(ra) # 80005cf8 <plic_claim>
    80002790:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002792:	47a9                	li	a5,10
    80002794:	02f50763          	beq	a0,a5,800027c2 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002798:	4785                	li	a5,1
    8000279a:	02f50963          	beq	a0,a5,800027cc <devintr+0x78>
    return 1;
    8000279e:	4505                	li	a0,1
    } else if(irq){
    800027a0:	dcf9                	beqz	s1,8000277e <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800027a2:	85a6                	mv	a1,s1
    800027a4:	00006517          	auipc	a0,0x6
    800027a8:	b8450513          	addi	a0,a0,-1148 # 80008328 <states.0+0x38>
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	dda080e7          	jalr	-550(ra) # 80000586 <printf>
      plic_complete(irq);
    800027b4:	8526                	mv	a0,s1
    800027b6:	00003097          	auipc	ra,0x3
    800027ba:	566080e7          	jalr	1382(ra) # 80005d1c <plic_complete>
    return 1;
    800027be:	4505                	li	a0,1
    800027c0:	bf7d                	j	8000277e <devintr+0x2a>
      uartintr();
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	1d2080e7          	jalr	466(ra) # 80000994 <uartintr>
    if(irq)
    800027ca:	b7ed                	j	800027b4 <devintr+0x60>
      virtio_disk_intr();
    800027cc:	00004097          	auipc	ra,0x4
    800027d0:	a16080e7          	jalr	-1514(ra) # 800061e2 <virtio_disk_intr>
    if(irq)
    800027d4:	b7c5                	j	800027b4 <devintr+0x60>
    if(cpuid() == 0){
    800027d6:	fffff097          	auipc	ra,0xfffff
    800027da:	1b4080e7          	jalr	436(ra) # 8000198a <cpuid>
    800027de:	c901                	beqz	a0,800027ee <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027e0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027e4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027e6:	14479073          	csrw	sip,a5
    return 2;
    800027ea:	4509                	li	a0,2
    800027ec:	bf49                	j	8000277e <devintr+0x2a>
      clockintr();
    800027ee:	00000097          	auipc	ra,0x0
    800027f2:	f20080e7          	jalr	-224(ra) # 8000270e <clockintr>
    800027f6:	b7ed                	j	800027e0 <devintr+0x8c>
}
    800027f8:	8082                	ret

00000000800027fa <usertrap>:
{
    800027fa:	1101                	addi	sp,sp,-32
    800027fc:	ec06                	sd	ra,24(sp)
    800027fe:	e822                	sd	s0,16(sp)
    80002800:	e426                	sd	s1,8(sp)
    80002802:	e04a                	sd	s2,0(sp)
    80002804:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002806:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000280a:	1007f793          	andi	a5,a5,256
    8000280e:	e3b1                	bnez	a5,80002852 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002810:	00003797          	auipc	a5,0x3
    80002814:	3e078793          	addi	a5,a5,992 # 80005bf0 <kernelvec>
    80002818:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000281c:	fffff097          	auipc	ra,0xfffff
    80002820:	19a080e7          	jalr	410(ra) # 800019b6 <myproc>
    80002824:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002826:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002828:	14102773          	csrr	a4,sepc
    8000282c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000282e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002832:	47a1                	li	a5,8
    80002834:	02f70763          	beq	a4,a5,80002862 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002838:	00000097          	auipc	ra,0x0
    8000283c:	f1c080e7          	jalr	-228(ra) # 80002754 <devintr>
    80002840:	892a                	mv	s2,a0
    80002842:	c151                	beqz	a0,800028c6 <usertrap+0xcc>
  if(killed(p))
    80002844:	8526                	mv	a0,s1
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	acc080e7          	jalr	-1332(ra) # 80002312 <killed>
    8000284e:	c929                	beqz	a0,800028a0 <usertrap+0xa6>
    80002850:	a099                	j	80002896 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002852:	00006517          	auipc	a0,0x6
    80002856:	af650513          	addi	a0,a0,-1290 # 80008348 <states.0+0x58>
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	ce2080e7          	jalr	-798(ra) # 8000053c <panic>
    if(killed(p))
    80002862:	00000097          	auipc	ra,0x0
    80002866:	ab0080e7          	jalr	-1360(ra) # 80002312 <killed>
    8000286a:	e921                	bnez	a0,800028ba <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000286c:	6cb8                	ld	a4,88(s1)
    8000286e:	6f1c                	ld	a5,24(a4)
    80002870:	0791                	addi	a5,a5,4
    80002872:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002874:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002878:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000287c:	10079073          	csrw	sstatus,a5
    syscall();
    80002880:	00000097          	auipc	ra,0x0
    80002884:	3ae080e7          	jalr	942(ra) # 80002c2e <syscall>
  if(killed(p))
    80002888:	8526                	mv	a0,s1
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	a88080e7          	jalr	-1400(ra) # 80002312 <killed>
    80002892:	c911                	beqz	a0,800028a6 <usertrap+0xac>
    80002894:	4901                	li	s2,0
    exit(-1);
    80002896:	557d                	li	a0,-1
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	906080e7          	jalr	-1786(ra) # 8000219e <exit>
  if(which_dev == 2)
    800028a0:	4789                	li	a5,2
    800028a2:	04f90f63          	beq	s2,a5,80002900 <usertrap+0x106>
  usertrapret();
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	dd2080e7          	jalr	-558(ra) # 80002678 <usertrapret>
}
    800028ae:	60e2                	ld	ra,24(sp)
    800028b0:	6442                	ld	s0,16(sp)
    800028b2:	64a2                	ld	s1,8(sp)
    800028b4:	6902                	ld	s2,0(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret
      exit(-1);
    800028ba:	557d                	li	a0,-1
    800028bc:	00000097          	auipc	ra,0x0
    800028c0:	8e2080e7          	jalr	-1822(ra) # 8000219e <exit>
    800028c4:	b765                	j	8000286c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028c6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028ca:	5890                	lw	a2,48(s1)
    800028cc:	00006517          	auipc	a0,0x6
    800028d0:	a9c50513          	addi	a0,a0,-1380 # 80008368 <states.0+0x78>
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	cb2080e7          	jalr	-846(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028dc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028e0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028e4:	00006517          	auipc	a0,0x6
    800028e8:	ab450513          	addi	a0,a0,-1356 # 80008398 <states.0+0xa8>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	c9a080e7          	jalr	-870(ra) # 80000586 <printf>
    setkilled(p);
    800028f4:	8526                	mv	a0,s1
    800028f6:	00000097          	auipc	ra,0x0
    800028fa:	9f0080e7          	jalr	-1552(ra) # 800022e6 <setkilled>
    800028fe:	b769                	j	80002888 <usertrap+0x8e>
    yield();
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	72e080e7          	jalr	1838(ra) # 8000202e <yield>
    80002908:	bf79                	j	800028a6 <usertrap+0xac>

000000008000290a <kerneltrap>:
{
    8000290a:	7179                	addi	sp,sp,-48
    8000290c:	f406                	sd	ra,40(sp)
    8000290e:	f022                	sd	s0,32(sp)
    80002910:	ec26                	sd	s1,24(sp)
    80002912:	e84a                	sd	s2,16(sp)
    80002914:	e44e                	sd	s3,8(sp)
    80002916:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002918:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002920:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002924:	1004f793          	andi	a5,s1,256
    80002928:	cb85                	beqz	a5,80002958 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000292e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002930:	ef85                	bnez	a5,80002968 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002932:	00000097          	auipc	ra,0x0
    80002936:	e22080e7          	jalr	-478(ra) # 80002754 <devintr>
    8000293a:	cd1d                	beqz	a0,80002978 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000293c:	4789                	li	a5,2
    8000293e:	06f50a63          	beq	a0,a5,800029b2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002942:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002946:	10049073          	csrw	sstatus,s1
}
    8000294a:	70a2                	ld	ra,40(sp)
    8000294c:	7402                	ld	s0,32(sp)
    8000294e:	64e2                	ld	s1,24(sp)
    80002950:	6942                	ld	s2,16(sp)
    80002952:	69a2                	ld	s3,8(sp)
    80002954:	6145                	addi	sp,sp,48
    80002956:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002958:	00006517          	auipc	a0,0x6
    8000295c:	a6050513          	addi	a0,a0,-1440 # 800083b8 <states.0+0xc8>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	bdc080e7          	jalr	-1060(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002968:	00006517          	auipc	a0,0x6
    8000296c:	a7850513          	addi	a0,a0,-1416 # 800083e0 <states.0+0xf0>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	bcc080e7          	jalr	-1076(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002978:	85ce                	mv	a1,s3
    8000297a:	00006517          	auipc	a0,0x6
    8000297e:	a8650513          	addi	a0,a0,-1402 # 80008400 <states.0+0x110>
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	c04080e7          	jalr	-1020(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000298e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002992:	00006517          	auipc	a0,0x6
    80002996:	a7e50513          	addi	a0,a0,-1410 # 80008410 <states.0+0x120>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	bec080e7          	jalr	-1044(ra) # 80000586 <printf>
    panic("kerneltrap");
    800029a2:	00006517          	auipc	a0,0x6
    800029a6:	a8650513          	addi	a0,a0,-1402 # 80008428 <states.0+0x138>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	b92080e7          	jalr	-1134(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029b2:	fffff097          	auipc	ra,0xfffff
    800029b6:	004080e7          	jalr	4(ra) # 800019b6 <myproc>
    800029ba:	d541                	beqz	a0,80002942 <kerneltrap+0x38>
    800029bc:	fffff097          	auipc	ra,0xfffff
    800029c0:	ffa080e7          	jalr	-6(ra) # 800019b6 <myproc>
    800029c4:	4d18                	lw	a4,24(a0)
    800029c6:	4791                	li	a5,4
    800029c8:	f6f71de3          	bne	a4,a5,80002942 <kerneltrap+0x38>
    yield();
    800029cc:	fffff097          	auipc	ra,0xfffff
    800029d0:	662080e7          	jalr	1634(ra) # 8000202e <yield>
    800029d4:	b7bd                	j	80002942 <kerneltrap+0x38>

00000000800029d6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029d6:	1101                	addi	sp,sp,-32
    800029d8:	ec06                	sd	ra,24(sp)
    800029da:	e822                	sd	s0,16(sp)
    800029dc:	e426                	sd	s1,8(sp)
    800029de:	1000                	addi	s0,sp,32
    800029e0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029e2:	fffff097          	auipc	ra,0xfffff
    800029e6:	fd4080e7          	jalr	-44(ra) # 800019b6 <myproc>
  switch (n) {
    800029ea:	4795                	li	a5,5
    800029ec:	0497e163          	bltu	a5,s1,80002a2e <argraw+0x58>
    800029f0:	048a                	slli	s1,s1,0x2
    800029f2:	00006717          	auipc	a4,0x6
    800029f6:	b4e70713          	addi	a4,a4,-1202 # 80008540 <states.0+0x250>
    800029fa:	94ba                	add	s1,s1,a4
    800029fc:	409c                	lw	a5,0(s1)
    800029fe:	97ba                	add	a5,a5,a4
    80002a00:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a02:	6d3c                	ld	a5,88(a0)
    80002a04:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a06:	60e2                	ld	ra,24(sp)
    80002a08:	6442                	ld	s0,16(sp)
    80002a0a:	64a2                	ld	s1,8(sp)
    80002a0c:	6105                	addi	sp,sp,32
    80002a0e:	8082                	ret
    return p->trapframe->a1;
    80002a10:	6d3c                	ld	a5,88(a0)
    80002a12:	7fa8                	ld	a0,120(a5)
    80002a14:	bfcd                	j	80002a06 <argraw+0x30>
    return p->trapframe->a2;
    80002a16:	6d3c                	ld	a5,88(a0)
    80002a18:	63c8                	ld	a0,128(a5)
    80002a1a:	b7f5                	j	80002a06 <argraw+0x30>
    return p->trapframe->a3;
    80002a1c:	6d3c                	ld	a5,88(a0)
    80002a1e:	67c8                	ld	a0,136(a5)
    80002a20:	b7dd                	j	80002a06 <argraw+0x30>
    return p->trapframe->a4;
    80002a22:	6d3c                	ld	a5,88(a0)
    80002a24:	6bc8                	ld	a0,144(a5)
    80002a26:	b7c5                	j	80002a06 <argraw+0x30>
    return p->trapframe->a5;
    80002a28:	6d3c                	ld	a5,88(a0)
    80002a2a:	6fc8                	ld	a0,152(a5)
    80002a2c:	bfe9                	j	80002a06 <argraw+0x30>
  panic("argraw");
    80002a2e:	00006517          	auipc	a0,0x6
    80002a32:	a0a50513          	addi	a0,a0,-1526 # 80008438 <states.0+0x148>
    80002a36:	ffffe097          	auipc	ra,0xffffe
    80002a3a:	b06080e7          	jalr	-1274(ra) # 8000053c <panic>

0000000080002a3e <fetchaddr>:
{
    80002a3e:	1101                	addi	sp,sp,-32
    80002a40:	ec06                	sd	ra,24(sp)
    80002a42:	e822                	sd	s0,16(sp)
    80002a44:	e426                	sd	s1,8(sp)
    80002a46:	e04a                	sd	s2,0(sp)
    80002a48:	1000                	addi	s0,sp,32
    80002a4a:	84aa                	mv	s1,a0
    80002a4c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a4e:	fffff097          	auipc	ra,0xfffff
    80002a52:	f68080e7          	jalr	-152(ra) # 800019b6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a56:	653c                	ld	a5,72(a0)
    80002a58:	02f4f863          	bgeu	s1,a5,80002a88 <fetchaddr+0x4a>
    80002a5c:	00848713          	addi	a4,s1,8
    80002a60:	02e7e663          	bltu	a5,a4,80002a8c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a64:	46a1                	li	a3,8
    80002a66:	8626                	mv	a2,s1
    80002a68:	85ca                	mv	a1,s2
    80002a6a:	6928                	ld	a0,80(a0)
    80002a6c:	fffff097          	auipc	ra,0xfffff
    80002a70:	c96080e7          	jalr	-874(ra) # 80001702 <copyin>
    80002a74:	00a03533          	snez	a0,a0
    80002a78:	40a00533          	neg	a0,a0
}
    80002a7c:	60e2                	ld	ra,24(sp)
    80002a7e:	6442                	ld	s0,16(sp)
    80002a80:	64a2                	ld	s1,8(sp)
    80002a82:	6902                	ld	s2,0(sp)
    80002a84:	6105                	addi	sp,sp,32
    80002a86:	8082                	ret
    return -1;
    80002a88:	557d                	li	a0,-1
    80002a8a:	bfcd                	j	80002a7c <fetchaddr+0x3e>
    80002a8c:	557d                	li	a0,-1
    80002a8e:	b7fd                	j	80002a7c <fetchaddr+0x3e>

0000000080002a90 <fetchstr>:
{
    80002a90:	7179                	addi	sp,sp,-48
    80002a92:	f406                	sd	ra,40(sp)
    80002a94:	f022                	sd	s0,32(sp)
    80002a96:	ec26                	sd	s1,24(sp)
    80002a98:	e84a                	sd	s2,16(sp)
    80002a9a:	e44e                	sd	s3,8(sp)
    80002a9c:	1800                	addi	s0,sp,48
    80002a9e:	892a                	mv	s2,a0
    80002aa0:	84ae                	mv	s1,a1
    80002aa2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002aa4:	fffff097          	auipc	ra,0xfffff
    80002aa8:	f12080e7          	jalr	-238(ra) # 800019b6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002aac:	86ce                	mv	a3,s3
    80002aae:	864a                	mv	a2,s2
    80002ab0:	85a6                	mv	a1,s1
    80002ab2:	6928                	ld	a0,80(a0)
    80002ab4:	fffff097          	auipc	ra,0xfffff
    80002ab8:	cdc080e7          	jalr	-804(ra) # 80001790 <copyinstr>
    80002abc:	00054e63          	bltz	a0,80002ad8 <fetchstr+0x48>
  return strlen(buf);
    80002ac0:	8526                	mv	a0,s1
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	386080e7          	jalr	902(ra) # 80000e48 <strlen>
}
    80002aca:	70a2                	ld	ra,40(sp)
    80002acc:	7402                	ld	s0,32(sp)
    80002ace:	64e2                	ld	s1,24(sp)
    80002ad0:	6942                	ld	s2,16(sp)
    80002ad2:	69a2                	ld	s3,8(sp)
    80002ad4:	6145                	addi	sp,sp,48
    80002ad6:	8082                	ret
    return -1;
    80002ad8:	557d                	li	a0,-1
    80002ada:	bfc5                	j	80002aca <fetchstr+0x3a>

0000000080002adc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	e426                	sd	s1,8(sp)
    80002ae4:	1000                	addi	s0,sp,32
    80002ae6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ae8:	00000097          	auipc	ra,0x0
    80002aec:	eee080e7          	jalr	-274(ra) # 800029d6 <argraw>
    80002af0:	c088                	sw	a0,0(s1)
}
    80002af2:	60e2                	ld	ra,24(sp)
    80002af4:	6442                	ld	s0,16(sp)
    80002af6:	64a2                	ld	s1,8(sp)
    80002af8:	6105                	addi	sp,sp,32
    80002afa:	8082                	ret

0000000080002afc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002afc:	1101                	addi	sp,sp,-32
    80002afe:	ec06                	sd	ra,24(sp)
    80002b00:	e822                	sd	s0,16(sp)
    80002b02:	e426                	sd	s1,8(sp)
    80002b04:	1000                	addi	s0,sp,32
    80002b06:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b08:	00000097          	auipc	ra,0x0
    80002b0c:	ece080e7          	jalr	-306(ra) # 800029d6 <argraw>
    80002b10:	e088                	sd	a0,0(s1)
}
    80002b12:	60e2                	ld	ra,24(sp)
    80002b14:	6442                	ld	s0,16(sp)
    80002b16:	64a2                	ld	s1,8(sp)
    80002b18:	6105                	addi	sp,sp,32
    80002b1a:	8082                	ret

0000000080002b1c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b1c:	7179                	addi	sp,sp,-48
    80002b1e:	f406                	sd	ra,40(sp)
    80002b20:	f022                	sd	s0,32(sp)
    80002b22:	ec26                	sd	s1,24(sp)
    80002b24:	e84a                	sd	s2,16(sp)
    80002b26:	1800                	addi	s0,sp,48
    80002b28:	84ae                	mv	s1,a1
    80002b2a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b2c:	fd840593          	addi	a1,s0,-40
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	fcc080e7          	jalr	-52(ra) # 80002afc <argaddr>
  return fetchstr(addr, buf, max);
    80002b38:	864a                	mv	a2,s2
    80002b3a:	85a6                	mv	a1,s1
    80002b3c:	fd843503          	ld	a0,-40(s0)
    80002b40:	00000097          	auipc	ra,0x0
    80002b44:	f50080e7          	jalr	-176(ra) # 80002a90 <fetchstr>
}
    80002b48:	70a2                	ld	ra,40(sp)
    80002b4a:	7402                	ld	s0,32(sp)
    80002b4c:	64e2                	ld	s1,24(sp)
    80002b4e:	6942                	ld	s2,16(sp)
    80002b50:	6145                	addi	sp,sp,48
    80002b52:	8082                	ret

0000000080002b54 <print_trace>:
};

// Function called to print trace info
void 
print_trace(struct proc* p, int syscall_num)
{
    80002b54:	715d                	addi	sp,sp,-80
    80002b56:	e486                	sd	ra,72(sp)
    80002b58:	e0a2                	sd	s0,64(sp)
    80002b5a:	fc26                	sd	s1,56(sp)
    80002b5c:	f84a                	sd	s2,48(sp)
    80002b5e:	f44e                	sd	s3,40(sp)
    80002b60:	f052                	sd	s4,32(sp)
    80002b62:	ec56                	sd	s5,24(sp)
    80002b64:	e85a                	sd	s6,16(sp)
    80002b66:	0880                	addi	s0,sp,80
    80002b68:	8a2a                	mv	s4,a0
    80002b6a:	892e                	mv	s2,a1
  printf("%d: syscall %s (", p->pid, syscall_structs[syscall_num].name);
    80002b6c:	00459793          	slli	a5,a1,0x4
    80002b70:	00006497          	auipc	s1,0x6
    80002b74:	e2848493          	addi	s1,s1,-472 # 80008998 <syscall_structs>
    80002b78:	94be                	add	s1,s1,a5
    80002b7a:	6490                	ld	a2,8(s1)
    80002b7c:	590c                	lw	a1,48(a0)
    80002b7e:	00006517          	auipc	a0,0x6
    80002b82:	8c250513          	addi	a0,a0,-1854 # 80008440 <states.0+0x150>
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	a00080e7          	jalr	-1536(ra) # 80000586 <printf>
  
  int curr_arg;
  // Print arguments
  for(int i=0; i<syscall_structs[syscall_num].num_args; i++)
    80002b8e:	40dc                	lw	a5,4(s1)
    80002b90:	06f05a63          	blez	a5,80002c04 <print_trace+0xb0>
    80002b94:	4481                	li	s1,0
  {
    argint(i, &curr_arg);
    printf("%d", curr_arg);
    80002b96:	00006997          	auipc	s3,0x6
    80002b9a:	8c298993          	addi	s3,s3,-1854 # 80008458 <states.0+0x168>
    if (i != syscall_structs[syscall_num].num_args - 1) {
    80002b9e:	00491593          	slli	a1,s2,0x4
    80002ba2:	00006917          	auipc	s2,0x6
    80002ba6:	df690913          	addi	s2,s2,-522 # 80008998 <syscall_structs>
    80002baa:	992e                	add	s2,s2,a1
      printf(" ");
    }
    else
    {
      printf(")");
    80002bac:	00006b17          	auipc	s6,0x6
    80002bb0:	8bcb0b13          	addi	s6,s6,-1860 # 80008468 <states.0+0x178>
      printf(" ");
    80002bb4:	00006a97          	auipc	s5,0x6
    80002bb8:	8aca8a93          	addi	s5,s5,-1876 # 80008460 <states.0+0x170>
    80002bbc:	a819                	j	80002bd2 <print_trace+0x7e>
      printf(")");
    80002bbe:	855a                	mv	a0,s6
    80002bc0:	ffffe097          	auipc	ra,0xffffe
    80002bc4:	9c6080e7          	jalr	-1594(ra) # 80000586 <printf>
  for(int i=0; i<syscall_structs[syscall_num].num_args; i++)
    80002bc8:	2485                	addiw	s1,s1,1
    80002bca:	00492783          	lw	a5,4(s2)
    80002bce:	02f4db63          	bge	s1,a5,80002c04 <print_trace+0xb0>
    argint(i, &curr_arg);
    80002bd2:	fbc40593          	addi	a1,s0,-68
    80002bd6:	8526                	mv	a0,s1
    80002bd8:	00000097          	auipc	ra,0x0
    80002bdc:	f04080e7          	jalr	-252(ra) # 80002adc <argint>
    printf("%d", curr_arg);
    80002be0:	fbc42583          	lw	a1,-68(s0)
    80002be4:	854e                	mv	a0,s3
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	9a0080e7          	jalr	-1632(ra) # 80000586 <printf>
    if (i != syscall_structs[syscall_num].num_args - 1) {
    80002bee:	00492783          	lw	a5,4(s2)
    80002bf2:	37fd                	addiw	a5,a5,-1
    80002bf4:	fc9785e3          	beq	a5,s1,80002bbe <print_trace+0x6a>
      printf(" ");
    80002bf8:	8556                	mv	a0,s5
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	98c080e7          	jalr	-1652(ra) # 80000586 <printf>
    80002c02:	b7d9                	j	80002bc8 <print_trace+0x74>
    }
  }
  printf(" -> %d\n", p->trapframe->a0);
    80002c04:	058a3783          	ld	a5,88(s4)
    80002c08:	7bac                	ld	a1,112(a5)
    80002c0a:	00006517          	auipc	a0,0x6
    80002c0e:	86650513          	addi	a0,a0,-1946 # 80008470 <states.0+0x180>
    80002c12:	ffffe097          	auipc	ra,0xffffe
    80002c16:	974080e7          	jalr	-1676(ra) # 80000586 <printf>
}
    80002c1a:	60a6                	ld	ra,72(sp)
    80002c1c:	6406                	ld	s0,64(sp)
    80002c1e:	74e2                	ld	s1,56(sp)
    80002c20:	7942                	ld	s2,48(sp)
    80002c22:	79a2                	ld	s3,40(sp)
    80002c24:	7a02                	ld	s4,32(sp)
    80002c26:	6ae2                	ld	s5,24(sp)
    80002c28:	6b42                	ld	s6,16(sp)
    80002c2a:	6161                	addi	sp,sp,80
    80002c2c:	8082                	ret

0000000080002c2e <syscall>:

void
syscall(void)
{
    80002c2e:	7179                	addi	sp,sp,-48
    80002c30:	f406                	sd	ra,40(sp)
    80002c32:	f022                	sd	s0,32(sp)
    80002c34:	ec26                	sd	s1,24(sp)
    80002c36:	e84a                	sd	s2,16(sp)
    80002c38:	e44e                	sd	s3,8(sp)
    80002c3a:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002c3c:	fffff097          	auipc	ra,0xfffff
    80002c40:	d7a080e7          	jalr	-646(ra) # 800019b6 <myproc>
    80002c44:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c46:	05853903          	ld	s2,88(a0)
    80002c4a:	0a893783          	ld	a5,168(s2)
    80002c4e:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c52:	37fd                	addiw	a5,a5,-1
    80002c54:	4755                	li	a4,21
    80002c56:	02f76b63          	bltu	a4,a5,80002c8c <syscall+0x5e>
    80002c5a:	00399713          	slli	a4,s3,0x3
    80002c5e:	00006797          	auipc	a5,0x6
    80002c62:	8fa78793          	addi	a5,a5,-1798 # 80008558 <syscalls>
    80002c66:	97ba                	add	a5,a5,a4
    80002c68:	639c                	ld	a5,0(a5)
    80002c6a:	c38d                	beqz	a5,80002c8c <syscall+0x5e>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c6c:	9782                	jalr	a5
    80002c6e:	06a93823          	sd	a0,112(s2)
    if ((p->trace_mask & (1<<num)) !=0)
    80002c72:	1684a783          	lw	a5,360(s1)
    80002c76:	4137d7bb          	sraw	a5,a5,s3
    80002c7a:	8b85                	andi	a5,a5,1
    80002c7c:	c79d                	beqz	a5,80002caa <syscall+0x7c>
    {
      print_trace(p, num);
    80002c7e:	85ce                	mv	a1,s3
    80002c80:	8526                	mv	a0,s1
    80002c82:	00000097          	auipc	ra,0x0
    80002c86:	ed2080e7          	jalr	-302(ra) # 80002b54 <print_trace>
    80002c8a:	a005                	j	80002caa <syscall+0x7c>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c8c:	86ce                	mv	a3,s3
    80002c8e:	15848613          	addi	a2,s1,344
    80002c92:	588c                	lw	a1,48(s1)
    80002c94:	00005517          	auipc	a0,0x5
    80002c98:	7e450513          	addi	a0,a0,2020 # 80008478 <states.0+0x188>
    80002c9c:	ffffe097          	auipc	ra,0xffffe
    80002ca0:	8ea080e7          	jalr	-1814(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ca4:	6cbc                	ld	a5,88(s1)
    80002ca6:	577d                	li	a4,-1
    80002ca8:	fbb8                	sd	a4,112(a5)
  }
}
    80002caa:	70a2                	ld	ra,40(sp)
    80002cac:	7402                	ld	s0,32(sp)
    80002cae:	64e2                	ld	s1,24(sp)
    80002cb0:	6942                	ld	s2,16(sp)
    80002cb2:	69a2                	ld	s3,8(sp)
    80002cb4:	6145                	addi	sp,sp,48
    80002cb6:	8082                	ret

0000000080002cb8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002cc0:	fec40593          	addi	a1,s0,-20
    80002cc4:	4501                	li	a0,0
    80002cc6:	00000097          	auipc	ra,0x0
    80002cca:	e16080e7          	jalr	-490(ra) # 80002adc <argint>
  exit(n);
    80002cce:	fec42503          	lw	a0,-20(s0)
    80002cd2:	fffff097          	auipc	ra,0xfffff
    80002cd6:	4cc080e7          	jalr	1228(ra) # 8000219e <exit>
  return 0;  // not reached
}
    80002cda:	4501                	li	a0,0
    80002cdc:	60e2                	ld	ra,24(sp)
    80002cde:	6442                	ld	s0,16(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret

0000000080002ce4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ce4:	1141                	addi	sp,sp,-16
    80002ce6:	e406                	sd	ra,8(sp)
    80002ce8:	e022                	sd	s0,0(sp)
    80002cea:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	cca080e7          	jalr	-822(ra) # 800019b6 <myproc>
}
    80002cf4:	5908                	lw	a0,48(a0)
    80002cf6:	60a2                	ld	ra,8(sp)
    80002cf8:	6402                	ld	s0,0(sp)
    80002cfa:	0141                	addi	sp,sp,16
    80002cfc:	8082                	ret

0000000080002cfe <sys_fork>:

uint64
sys_fork(void)
{
    80002cfe:	1141                	addi	sp,sp,-16
    80002d00:	e406                	sd	ra,8(sp)
    80002d02:	e022                	sd	s0,0(sp)
    80002d04:	0800                	addi	s0,sp,16
  return fork();
    80002d06:	fffff097          	auipc	ra,0xfffff
    80002d0a:	06a080e7          	jalr	106(ra) # 80001d70 <fork>
}
    80002d0e:	60a2                	ld	ra,8(sp)
    80002d10:	6402                	ld	s0,0(sp)
    80002d12:	0141                	addi	sp,sp,16
    80002d14:	8082                	ret

0000000080002d16 <sys_wait>:

uint64
sys_wait(void)
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d1e:	fe840593          	addi	a1,s0,-24
    80002d22:	4501                	li	a0,0
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	dd8080e7          	jalr	-552(ra) # 80002afc <argaddr>
  return wait(p);
    80002d2c:	fe843503          	ld	a0,-24(s0)
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	614080e7          	jalr	1556(ra) # 80002344 <wait>
}
    80002d38:	60e2                	ld	ra,24(sp)
    80002d3a:	6442                	ld	s0,16(sp)
    80002d3c:	6105                	addi	sp,sp,32
    80002d3e:	8082                	ret

0000000080002d40 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d40:	7179                	addi	sp,sp,-48
    80002d42:	f406                	sd	ra,40(sp)
    80002d44:	f022                	sd	s0,32(sp)
    80002d46:	ec26                	sd	s1,24(sp)
    80002d48:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d4a:	fdc40593          	addi	a1,s0,-36
    80002d4e:	4501                	li	a0,0
    80002d50:	00000097          	auipc	ra,0x0
    80002d54:	d8c080e7          	jalr	-628(ra) # 80002adc <argint>
  addr = myproc()->sz;
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	c5e080e7          	jalr	-930(ra) # 800019b6 <myproc>
    80002d60:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d62:	fdc42503          	lw	a0,-36(s0)
    80002d66:	fffff097          	auipc	ra,0xfffff
    80002d6a:	fae080e7          	jalr	-82(ra) # 80001d14 <growproc>
    80002d6e:	00054863          	bltz	a0,80002d7e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d72:	8526                	mv	a0,s1
    80002d74:	70a2                	ld	ra,40(sp)
    80002d76:	7402                	ld	s0,32(sp)
    80002d78:	64e2                	ld	s1,24(sp)
    80002d7a:	6145                	addi	sp,sp,48
    80002d7c:	8082                	ret
    return -1;
    80002d7e:	54fd                	li	s1,-1
    80002d80:	bfcd                	j	80002d72 <sys_sbrk+0x32>

0000000080002d82 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d82:	7139                	addi	sp,sp,-64
    80002d84:	fc06                	sd	ra,56(sp)
    80002d86:	f822                	sd	s0,48(sp)
    80002d88:	f426                	sd	s1,40(sp)
    80002d8a:	f04a                	sd	s2,32(sp)
    80002d8c:	ec4e                	sd	s3,24(sp)
    80002d8e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d90:	fcc40593          	addi	a1,s0,-52
    80002d94:	4501                	li	a0,0
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	d46080e7          	jalr	-698(ra) # 80002adc <argint>
  acquire(&tickslock);
    80002d9e:	00014517          	auipc	a0,0x14
    80002da2:	06250513          	addi	a0,a0,98 # 80016e00 <tickslock>
    80002da6:	ffffe097          	auipc	ra,0xffffe
    80002daa:	e2c080e7          	jalr	-468(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002dae:	00006917          	auipc	s2,0x6
    80002db2:	db292903          	lw	s2,-590(s2) # 80008b60 <ticks>
  while(ticks - ticks0 < n){
    80002db6:	fcc42783          	lw	a5,-52(s0)
    80002dba:	cf9d                	beqz	a5,80002df8 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dbc:	00014997          	auipc	s3,0x14
    80002dc0:	04498993          	addi	s3,s3,68 # 80016e00 <tickslock>
    80002dc4:	00006497          	auipc	s1,0x6
    80002dc8:	d9c48493          	addi	s1,s1,-612 # 80008b60 <ticks>
    if(killed(myproc())){
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	bea080e7          	jalr	-1046(ra) # 800019b6 <myproc>
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	53e080e7          	jalr	1342(ra) # 80002312 <killed>
    80002ddc:	ed15                	bnez	a0,80002e18 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002dde:	85ce                	mv	a1,s3
    80002de0:	8526                	mv	a0,s1
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	288080e7          	jalr	648(ra) # 8000206a <sleep>
  while(ticks - ticks0 < n){
    80002dea:	409c                	lw	a5,0(s1)
    80002dec:	412787bb          	subw	a5,a5,s2
    80002df0:	fcc42703          	lw	a4,-52(s0)
    80002df4:	fce7ece3          	bltu	a5,a4,80002dcc <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002df8:	00014517          	auipc	a0,0x14
    80002dfc:	00850513          	addi	a0,a0,8 # 80016e00 <tickslock>
    80002e00:	ffffe097          	auipc	ra,0xffffe
    80002e04:	e86080e7          	jalr	-378(ra) # 80000c86 <release>
  return 0;
    80002e08:	4501                	li	a0,0
}
    80002e0a:	70e2                	ld	ra,56(sp)
    80002e0c:	7442                	ld	s0,48(sp)
    80002e0e:	74a2                	ld	s1,40(sp)
    80002e10:	7902                	ld	s2,32(sp)
    80002e12:	69e2                	ld	s3,24(sp)
    80002e14:	6121                	addi	sp,sp,64
    80002e16:	8082                	ret
      release(&tickslock);
    80002e18:	00014517          	auipc	a0,0x14
    80002e1c:	fe850513          	addi	a0,a0,-24 # 80016e00 <tickslock>
    80002e20:	ffffe097          	auipc	ra,0xffffe
    80002e24:	e66080e7          	jalr	-410(ra) # 80000c86 <release>
      return -1;
    80002e28:	557d                	li	a0,-1
    80002e2a:	b7c5                	j	80002e0a <sys_sleep+0x88>

0000000080002e2c <sys_kill>:

uint64
sys_kill(void)
{
    80002e2c:	1101                	addi	sp,sp,-32
    80002e2e:	ec06                	sd	ra,24(sp)
    80002e30:	e822                	sd	s0,16(sp)
    80002e32:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e34:	fec40593          	addi	a1,s0,-20
    80002e38:	4501                	li	a0,0
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	ca2080e7          	jalr	-862(ra) # 80002adc <argint>
  return kill(pid);
    80002e42:	fec42503          	lw	a0,-20(s0)
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	42e080e7          	jalr	1070(ra) # 80002274 <kill>
}
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	6105                	addi	sp,sp,32
    80002e54:	8082                	ret

0000000080002e56 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e56:	1101                	addi	sp,sp,-32
    80002e58:	ec06                	sd	ra,24(sp)
    80002e5a:	e822                	sd	s0,16(sp)
    80002e5c:	e426                	sd	s1,8(sp)
    80002e5e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e60:	00014517          	auipc	a0,0x14
    80002e64:	fa050513          	addi	a0,a0,-96 # 80016e00 <tickslock>
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	d6a080e7          	jalr	-662(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002e70:	00006497          	auipc	s1,0x6
    80002e74:	cf04a483          	lw	s1,-784(s1) # 80008b60 <ticks>
  release(&tickslock);
    80002e78:	00014517          	auipc	a0,0x14
    80002e7c:	f8850513          	addi	a0,a0,-120 # 80016e00 <tickslock>
    80002e80:	ffffe097          	auipc	ra,0xffffe
    80002e84:	e06080e7          	jalr	-506(ra) # 80000c86 <release>
  return xticks;
}
    80002e88:	02049513          	slli	a0,s1,0x20
    80002e8c:	9101                	srli	a0,a0,0x20
    80002e8e:	60e2                	ld	ra,24(sp)
    80002e90:	6442                	ld	s0,16(sp)
    80002e92:	64a2                	ld	s1,8(sp)
    80002e94:	6105                	addi	sp,sp,32
    80002e96:	8082                	ret

0000000080002e98 <sys_trace>:

// adding trace syscall
uint64
sys_trace(void)
{
    80002e98:	1101                	addi	sp,sp,-32
    80002e9a:	ec06                	sd	ra,24(sp)
    80002e9c:	e822                	sd	s0,16(sp)
    80002e9e:	1000                	addi	s0,sp,32
  // set trace mask as the 0th argument
  int mask; 
  argint(0, &mask);
    80002ea0:	fec40593          	addi	a1,s0,-20
    80002ea4:	4501                	li	a0,0
    80002ea6:	00000097          	auipc	ra,0x0
    80002eaa:	c36080e7          	jalr	-970(ra) # 80002adc <argint>
  myproc()->trace_mask = mask;
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	b08080e7          	jalr	-1272(ra) # 800019b6 <myproc>
    80002eb6:	fec42783          	lw	a5,-20(s0)
    80002eba:	16f52423          	sw	a5,360(a0)
  return 0;
    80002ebe:	4501                	li	a0,0
    80002ec0:	60e2                	ld	ra,24(sp)
    80002ec2:	6442                	ld	s0,16(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret

0000000080002ec8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ec8:	7179                	addi	sp,sp,-48
    80002eca:	f406                	sd	ra,40(sp)
    80002ecc:	f022                	sd	s0,32(sp)
    80002ece:	ec26                	sd	s1,24(sp)
    80002ed0:	e84a                	sd	s2,16(sp)
    80002ed2:	e44e                	sd	s3,8(sp)
    80002ed4:	e052                	sd	s4,0(sp)
    80002ed6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ed8:	00005597          	auipc	a1,0x5
    80002edc:	73858593          	addi	a1,a1,1848 # 80008610 <syscalls+0xb8>
    80002ee0:	00014517          	auipc	a0,0x14
    80002ee4:	f3850513          	addi	a0,a0,-200 # 80016e18 <bcache>
    80002ee8:	ffffe097          	auipc	ra,0xffffe
    80002eec:	c5a080e7          	jalr	-934(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ef0:	0001c797          	auipc	a5,0x1c
    80002ef4:	f2878793          	addi	a5,a5,-216 # 8001ee18 <bcache+0x8000>
    80002ef8:	0001c717          	auipc	a4,0x1c
    80002efc:	18870713          	addi	a4,a4,392 # 8001f080 <bcache+0x8268>
    80002f00:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f04:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f08:	00014497          	auipc	s1,0x14
    80002f0c:	f2848493          	addi	s1,s1,-216 # 80016e30 <bcache+0x18>
    b->next = bcache.head.next;
    80002f10:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f12:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f14:	00005a17          	auipc	s4,0x5
    80002f18:	704a0a13          	addi	s4,s4,1796 # 80008618 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002f1c:	2b893783          	ld	a5,696(s2)
    80002f20:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f22:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f26:	85d2                	mv	a1,s4
    80002f28:	01048513          	addi	a0,s1,16
    80002f2c:	00001097          	auipc	ra,0x1
    80002f30:	496080e7          	jalr	1174(ra) # 800043c2 <initsleeplock>
    bcache.head.next->prev = b;
    80002f34:	2b893783          	ld	a5,696(s2)
    80002f38:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f3a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f3e:	45848493          	addi	s1,s1,1112
    80002f42:	fd349de3          	bne	s1,s3,80002f1c <binit+0x54>
  }
}
    80002f46:	70a2                	ld	ra,40(sp)
    80002f48:	7402                	ld	s0,32(sp)
    80002f4a:	64e2                	ld	s1,24(sp)
    80002f4c:	6942                	ld	s2,16(sp)
    80002f4e:	69a2                	ld	s3,8(sp)
    80002f50:	6a02                	ld	s4,0(sp)
    80002f52:	6145                	addi	sp,sp,48
    80002f54:	8082                	ret

0000000080002f56 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f56:	7179                	addi	sp,sp,-48
    80002f58:	f406                	sd	ra,40(sp)
    80002f5a:	f022                	sd	s0,32(sp)
    80002f5c:	ec26                	sd	s1,24(sp)
    80002f5e:	e84a                	sd	s2,16(sp)
    80002f60:	e44e                	sd	s3,8(sp)
    80002f62:	1800                	addi	s0,sp,48
    80002f64:	892a                	mv	s2,a0
    80002f66:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f68:	00014517          	auipc	a0,0x14
    80002f6c:	eb050513          	addi	a0,a0,-336 # 80016e18 <bcache>
    80002f70:	ffffe097          	auipc	ra,0xffffe
    80002f74:	c62080e7          	jalr	-926(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f78:	0001c497          	auipc	s1,0x1c
    80002f7c:	1584b483          	ld	s1,344(s1) # 8001f0d0 <bcache+0x82b8>
    80002f80:	0001c797          	auipc	a5,0x1c
    80002f84:	10078793          	addi	a5,a5,256 # 8001f080 <bcache+0x8268>
    80002f88:	02f48f63          	beq	s1,a5,80002fc6 <bread+0x70>
    80002f8c:	873e                	mv	a4,a5
    80002f8e:	a021                	j	80002f96 <bread+0x40>
    80002f90:	68a4                	ld	s1,80(s1)
    80002f92:	02e48a63          	beq	s1,a4,80002fc6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f96:	449c                	lw	a5,8(s1)
    80002f98:	ff279ce3          	bne	a5,s2,80002f90 <bread+0x3a>
    80002f9c:	44dc                	lw	a5,12(s1)
    80002f9e:	ff3799e3          	bne	a5,s3,80002f90 <bread+0x3a>
      b->refcnt++;
    80002fa2:	40bc                	lw	a5,64(s1)
    80002fa4:	2785                	addiw	a5,a5,1
    80002fa6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fa8:	00014517          	auipc	a0,0x14
    80002fac:	e7050513          	addi	a0,a0,-400 # 80016e18 <bcache>
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	cd6080e7          	jalr	-810(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002fb8:	01048513          	addi	a0,s1,16
    80002fbc:	00001097          	auipc	ra,0x1
    80002fc0:	440080e7          	jalr	1088(ra) # 800043fc <acquiresleep>
      return b;
    80002fc4:	a8b9                	j	80003022 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fc6:	0001c497          	auipc	s1,0x1c
    80002fca:	1024b483          	ld	s1,258(s1) # 8001f0c8 <bcache+0x82b0>
    80002fce:	0001c797          	auipc	a5,0x1c
    80002fd2:	0b278793          	addi	a5,a5,178 # 8001f080 <bcache+0x8268>
    80002fd6:	00f48863          	beq	s1,a5,80002fe6 <bread+0x90>
    80002fda:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fdc:	40bc                	lw	a5,64(s1)
    80002fde:	cf81                	beqz	a5,80002ff6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fe0:	64a4                	ld	s1,72(s1)
    80002fe2:	fee49de3          	bne	s1,a4,80002fdc <bread+0x86>
  panic("bget: no buffers");
    80002fe6:	00005517          	auipc	a0,0x5
    80002fea:	63a50513          	addi	a0,a0,1594 # 80008620 <syscalls+0xc8>
    80002fee:	ffffd097          	auipc	ra,0xffffd
    80002ff2:	54e080e7          	jalr	1358(ra) # 8000053c <panic>
      b->dev = dev;
    80002ff6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ffa:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ffe:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003002:	4785                	li	a5,1
    80003004:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003006:	00014517          	auipc	a0,0x14
    8000300a:	e1250513          	addi	a0,a0,-494 # 80016e18 <bcache>
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	c78080e7          	jalr	-904(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003016:	01048513          	addi	a0,s1,16
    8000301a:	00001097          	auipc	ra,0x1
    8000301e:	3e2080e7          	jalr	994(ra) # 800043fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003022:	409c                	lw	a5,0(s1)
    80003024:	cb89                	beqz	a5,80003036 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003026:	8526                	mv	a0,s1
    80003028:	70a2                	ld	ra,40(sp)
    8000302a:	7402                	ld	s0,32(sp)
    8000302c:	64e2                	ld	s1,24(sp)
    8000302e:	6942                	ld	s2,16(sp)
    80003030:	69a2                	ld	s3,8(sp)
    80003032:	6145                	addi	sp,sp,48
    80003034:	8082                	ret
    virtio_disk_rw(b, 0);
    80003036:	4581                	li	a1,0
    80003038:	8526                	mv	a0,s1
    8000303a:	00003097          	auipc	ra,0x3
    8000303e:	f78080e7          	jalr	-136(ra) # 80005fb2 <virtio_disk_rw>
    b->valid = 1;
    80003042:	4785                	li	a5,1
    80003044:	c09c                	sw	a5,0(s1)
  return b;
    80003046:	b7c5                	j	80003026 <bread+0xd0>

0000000080003048 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003048:	1101                	addi	sp,sp,-32
    8000304a:	ec06                	sd	ra,24(sp)
    8000304c:	e822                	sd	s0,16(sp)
    8000304e:	e426                	sd	s1,8(sp)
    80003050:	1000                	addi	s0,sp,32
    80003052:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003054:	0541                	addi	a0,a0,16
    80003056:	00001097          	auipc	ra,0x1
    8000305a:	440080e7          	jalr	1088(ra) # 80004496 <holdingsleep>
    8000305e:	cd01                	beqz	a0,80003076 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003060:	4585                	li	a1,1
    80003062:	8526                	mv	a0,s1
    80003064:	00003097          	auipc	ra,0x3
    80003068:	f4e080e7          	jalr	-178(ra) # 80005fb2 <virtio_disk_rw>
}
    8000306c:	60e2                	ld	ra,24(sp)
    8000306e:	6442                	ld	s0,16(sp)
    80003070:	64a2                	ld	s1,8(sp)
    80003072:	6105                	addi	sp,sp,32
    80003074:	8082                	ret
    panic("bwrite");
    80003076:	00005517          	auipc	a0,0x5
    8000307a:	5c250513          	addi	a0,a0,1474 # 80008638 <syscalls+0xe0>
    8000307e:	ffffd097          	auipc	ra,0xffffd
    80003082:	4be080e7          	jalr	1214(ra) # 8000053c <panic>

0000000080003086 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003086:	1101                	addi	sp,sp,-32
    80003088:	ec06                	sd	ra,24(sp)
    8000308a:	e822                	sd	s0,16(sp)
    8000308c:	e426                	sd	s1,8(sp)
    8000308e:	e04a                	sd	s2,0(sp)
    80003090:	1000                	addi	s0,sp,32
    80003092:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003094:	01050913          	addi	s2,a0,16
    80003098:	854a                	mv	a0,s2
    8000309a:	00001097          	auipc	ra,0x1
    8000309e:	3fc080e7          	jalr	1020(ra) # 80004496 <holdingsleep>
    800030a2:	c925                	beqz	a0,80003112 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030a4:	854a                	mv	a0,s2
    800030a6:	00001097          	auipc	ra,0x1
    800030aa:	3ac080e7          	jalr	940(ra) # 80004452 <releasesleep>

  acquire(&bcache.lock);
    800030ae:	00014517          	auipc	a0,0x14
    800030b2:	d6a50513          	addi	a0,a0,-662 # 80016e18 <bcache>
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	b1c080e7          	jalr	-1252(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800030be:	40bc                	lw	a5,64(s1)
    800030c0:	37fd                	addiw	a5,a5,-1
    800030c2:	0007871b          	sext.w	a4,a5
    800030c6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030c8:	e71d                	bnez	a4,800030f6 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030ca:	68b8                	ld	a4,80(s1)
    800030cc:	64bc                	ld	a5,72(s1)
    800030ce:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030d0:	68b8                	ld	a4,80(s1)
    800030d2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030d4:	0001c797          	auipc	a5,0x1c
    800030d8:	d4478793          	addi	a5,a5,-700 # 8001ee18 <bcache+0x8000>
    800030dc:	2b87b703          	ld	a4,696(a5)
    800030e0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030e2:	0001c717          	auipc	a4,0x1c
    800030e6:	f9e70713          	addi	a4,a4,-98 # 8001f080 <bcache+0x8268>
    800030ea:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030ec:	2b87b703          	ld	a4,696(a5)
    800030f0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030f2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030f6:	00014517          	auipc	a0,0x14
    800030fa:	d2250513          	addi	a0,a0,-734 # 80016e18 <bcache>
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	b88080e7          	jalr	-1144(ra) # 80000c86 <release>
}
    80003106:	60e2                	ld	ra,24(sp)
    80003108:	6442                	ld	s0,16(sp)
    8000310a:	64a2                	ld	s1,8(sp)
    8000310c:	6902                	ld	s2,0(sp)
    8000310e:	6105                	addi	sp,sp,32
    80003110:	8082                	ret
    panic("brelse");
    80003112:	00005517          	auipc	a0,0x5
    80003116:	52e50513          	addi	a0,a0,1326 # 80008640 <syscalls+0xe8>
    8000311a:	ffffd097          	auipc	ra,0xffffd
    8000311e:	422080e7          	jalr	1058(ra) # 8000053c <panic>

0000000080003122 <bpin>:

void
bpin(struct buf *b) {
    80003122:	1101                	addi	sp,sp,-32
    80003124:	ec06                	sd	ra,24(sp)
    80003126:	e822                	sd	s0,16(sp)
    80003128:	e426                	sd	s1,8(sp)
    8000312a:	1000                	addi	s0,sp,32
    8000312c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000312e:	00014517          	auipc	a0,0x14
    80003132:	cea50513          	addi	a0,a0,-790 # 80016e18 <bcache>
    80003136:	ffffe097          	auipc	ra,0xffffe
    8000313a:	a9c080e7          	jalr	-1380(ra) # 80000bd2 <acquire>
  b->refcnt++;
    8000313e:	40bc                	lw	a5,64(s1)
    80003140:	2785                	addiw	a5,a5,1
    80003142:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003144:	00014517          	auipc	a0,0x14
    80003148:	cd450513          	addi	a0,a0,-812 # 80016e18 <bcache>
    8000314c:	ffffe097          	auipc	ra,0xffffe
    80003150:	b3a080e7          	jalr	-1222(ra) # 80000c86 <release>
}
    80003154:	60e2                	ld	ra,24(sp)
    80003156:	6442                	ld	s0,16(sp)
    80003158:	64a2                	ld	s1,8(sp)
    8000315a:	6105                	addi	sp,sp,32
    8000315c:	8082                	ret

000000008000315e <bunpin>:

void
bunpin(struct buf *b) {
    8000315e:	1101                	addi	sp,sp,-32
    80003160:	ec06                	sd	ra,24(sp)
    80003162:	e822                	sd	s0,16(sp)
    80003164:	e426                	sd	s1,8(sp)
    80003166:	1000                	addi	s0,sp,32
    80003168:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000316a:	00014517          	auipc	a0,0x14
    8000316e:	cae50513          	addi	a0,a0,-850 # 80016e18 <bcache>
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	a60080e7          	jalr	-1440(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000317a:	40bc                	lw	a5,64(s1)
    8000317c:	37fd                	addiw	a5,a5,-1
    8000317e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003180:	00014517          	auipc	a0,0x14
    80003184:	c9850513          	addi	a0,a0,-872 # 80016e18 <bcache>
    80003188:	ffffe097          	auipc	ra,0xffffe
    8000318c:	afe080e7          	jalr	-1282(ra) # 80000c86 <release>
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret

000000008000319a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	e426                	sd	s1,8(sp)
    800031a2:	e04a                	sd	s2,0(sp)
    800031a4:	1000                	addi	s0,sp,32
    800031a6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031a8:	00d5d59b          	srliw	a1,a1,0xd
    800031ac:	0001c797          	auipc	a5,0x1c
    800031b0:	3487a783          	lw	a5,840(a5) # 8001f4f4 <sb+0x1c>
    800031b4:	9dbd                	addw	a1,a1,a5
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	da0080e7          	jalr	-608(ra) # 80002f56 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031be:	0074f713          	andi	a4,s1,7
    800031c2:	4785                	li	a5,1
    800031c4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031c8:	14ce                	slli	s1,s1,0x33
    800031ca:	90d9                	srli	s1,s1,0x36
    800031cc:	00950733          	add	a4,a0,s1
    800031d0:	05874703          	lbu	a4,88(a4)
    800031d4:	00e7f6b3          	and	a3,a5,a4
    800031d8:	c69d                	beqz	a3,80003206 <bfree+0x6c>
    800031da:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031dc:	94aa                	add	s1,s1,a0
    800031de:	fff7c793          	not	a5,a5
    800031e2:	8f7d                	and	a4,a4,a5
    800031e4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031e8:	00001097          	auipc	ra,0x1
    800031ec:	0f6080e7          	jalr	246(ra) # 800042de <log_write>
  brelse(bp);
    800031f0:	854a                	mv	a0,s2
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	e94080e7          	jalr	-364(ra) # 80003086 <brelse>
}
    800031fa:	60e2                	ld	ra,24(sp)
    800031fc:	6442                	ld	s0,16(sp)
    800031fe:	64a2                	ld	s1,8(sp)
    80003200:	6902                	ld	s2,0(sp)
    80003202:	6105                	addi	sp,sp,32
    80003204:	8082                	ret
    panic("freeing free block");
    80003206:	00005517          	auipc	a0,0x5
    8000320a:	44250513          	addi	a0,a0,1090 # 80008648 <syscalls+0xf0>
    8000320e:	ffffd097          	auipc	ra,0xffffd
    80003212:	32e080e7          	jalr	814(ra) # 8000053c <panic>

0000000080003216 <balloc>:
{
    80003216:	711d                	addi	sp,sp,-96
    80003218:	ec86                	sd	ra,88(sp)
    8000321a:	e8a2                	sd	s0,80(sp)
    8000321c:	e4a6                	sd	s1,72(sp)
    8000321e:	e0ca                	sd	s2,64(sp)
    80003220:	fc4e                	sd	s3,56(sp)
    80003222:	f852                	sd	s4,48(sp)
    80003224:	f456                	sd	s5,40(sp)
    80003226:	f05a                	sd	s6,32(sp)
    80003228:	ec5e                	sd	s7,24(sp)
    8000322a:	e862                	sd	s8,16(sp)
    8000322c:	e466                	sd	s9,8(sp)
    8000322e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003230:	0001c797          	auipc	a5,0x1c
    80003234:	2ac7a783          	lw	a5,684(a5) # 8001f4dc <sb+0x4>
    80003238:	cff5                	beqz	a5,80003334 <balloc+0x11e>
    8000323a:	8baa                	mv	s7,a0
    8000323c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000323e:	0001cb17          	auipc	s6,0x1c
    80003242:	29ab0b13          	addi	s6,s6,666 # 8001f4d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003246:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003248:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000324a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000324c:	6c89                	lui	s9,0x2
    8000324e:	a061                	j	800032d6 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003250:	97ca                	add	a5,a5,s2
    80003252:	8e55                	or	a2,a2,a3
    80003254:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003258:	854a                	mv	a0,s2
    8000325a:	00001097          	auipc	ra,0x1
    8000325e:	084080e7          	jalr	132(ra) # 800042de <log_write>
        brelse(bp);
    80003262:	854a                	mv	a0,s2
    80003264:	00000097          	auipc	ra,0x0
    80003268:	e22080e7          	jalr	-478(ra) # 80003086 <brelse>
  bp = bread(dev, bno);
    8000326c:	85a6                	mv	a1,s1
    8000326e:	855e                	mv	a0,s7
    80003270:	00000097          	auipc	ra,0x0
    80003274:	ce6080e7          	jalr	-794(ra) # 80002f56 <bread>
    80003278:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000327a:	40000613          	li	a2,1024
    8000327e:	4581                	li	a1,0
    80003280:	05850513          	addi	a0,a0,88
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	a4a080e7          	jalr	-1462(ra) # 80000cce <memset>
  log_write(bp);
    8000328c:	854a                	mv	a0,s2
    8000328e:	00001097          	auipc	ra,0x1
    80003292:	050080e7          	jalr	80(ra) # 800042de <log_write>
  brelse(bp);
    80003296:	854a                	mv	a0,s2
    80003298:	00000097          	auipc	ra,0x0
    8000329c:	dee080e7          	jalr	-530(ra) # 80003086 <brelse>
}
    800032a0:	8526                	mv	a0,s1
    800032a2:	60e6                	ld	ra,88(sp)
    800032a4:	6446                	ld	s0,80(sp)
    800032a6:	64a6                	ld	s1,72(sp)
    800032a8:	6906                	ld	s2,64(sp)
    800032aa:	79e2                	ld	s3,56(sp)
    800032ac:	7a42                	ld	s4,48(sp)
    800032ae:	7aa2                	ld	s5,40(sp)
    800032b0:	7b02                	ld	s6,32(sp)
    800032b2:	6be2                	ld	s7,24(sp)
    800032b4:	6c42                	ld	s8,16(sp)
    800032b6:	6ca2                	ld	s9,8(sp)
    800032b8:	6125                	addi	sp,sp,96
    800032ba:	8082                	ret
    brelse(bp);
    800032bc:	854a                	mv	a0,s2
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	dc8080e7          	jalr	-568(ra) # 80003086 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032c6:	015c87bb          	addw	a5,s9,s5
    800032ca:	00078a9b          	sext.w	s5,a5
    800032ce:	004b2703          	lw	a4,4(s6)
    800032d2:	06eaf163          	bgeu	s5,a4,80003334 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800032d6:	41fad79b          	sraiw	a5,s5,0x1f
    800032da:	0137d79b          	srliw	a5,a5,0x13
    800032de:	015787bb          	addw	a5,a5,s5
    800032e2:	40d7d79b          	sraiw	a5,a5,0xd
    800032e6:	01cb2583          	lw	a1,28(s6)
    800032ea:	9dbd                	addw	a1,a1,a5
    800032ec:	855e                	mv	a0,s7
    800032ee:	00000097          	auipc	ra,0x0
    800032f2:	c68080e7          	jalr	-920(ra) # 80002f56 <bread>
    800032f6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032f8:	004b2503          	lw	a0,4(s6)
    800032fc:	000a849b          	sext.w	s1,s5
    80003300:	8762                	mv	a4,s8
    80003302:	faa4fde3          	bgeu	s1,a0,800032bc <balloc+0xa6>
      m = 1 << (bi % 8);
    80003306:	00777693          	andi	a3,a4,7
    8000330a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000330e:	41f7579b          	sraiw	a5,a4,0x1f
    80003312:	01d7d79b          	srliw	a5,a5,0x1d
    80003316:	9fb9                	addw	a5,a5,a4
    80003318:	4037d79b          	sraiw	a5,a5,0x3
    8000331c:	00f90633          	add	a2,s2,a5
    80003320:	05864603          	lbu	a2,88(a2)
    80003324:	00c6f5b3          	and	a1,a3,a2
    80003328:	d585                	beqz	a1,80003250 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000332a:	2705                	addiw	a4,a4,1
    8000332c:	2485                	addiw	s1,s1,1
    8000332e:	fd471ae3          	bne	a4,s4,80003302 <balloc+0xec>
    80003332:	b769                	j	800032bc <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003334:	00005517          	auipc	a0,0x5
    80003338:	32c50513          	addi	a0,a0,812 # 80008660 <syscalls+0x108>
    8000333c:	ffffd097          	auipc	ra,0xffffd
    80003340:	24a080e7          	jalr	586(ra) # 80000586 <printf>
  return 0;
    80003344:	4481                	li	s1,0
    80003346:	bfa9                	j	800032a0 <balloc+0x8a>

0000000080003348 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003348:	7179                	addi	sp,sp,-48
    8000334a:	f406                	sd	ra,40(sp)
    8000334c:	f022                	sd	s0,32(sp)
    8000334e:	ec26                	sd	s1,24(sp)
    80003350:	e84a                	sd	s2,16(sp)
    80003352:	e44e                	sd	s3,8(sp)
    80003354:	e052                	sd	s4,0(sp)
    80003356:	1800                	addi	s0,sp,48
    80003358:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000335a:	47ad                	li	a5,11
    8000335c:	02b7e863          	bltu	a5,a1,8000338c <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003360:	02059793          	slli	a5,a1,0x20
    80003364:	01e7d593          	srli	a1,a5,0x1e
    80003368:	00b504b3          	add	s1,a0,a1
    8000336c:	0504a903          	lw	s2,80(s1)
    80003370:	06091e63          	bnez	s2,800033ec <bmap+0xa4>
      addr = balloc(ip->dev);
    80003374:	4108                	lw	a0,0(a0)
    80003376:	00000097          	auipc	ra,0x0
    8000337a:	ea0080e7          	jalr	-352(ra) # 80003216 <balloc>
    8000337e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003382:	06090563          	beqz	s2,800033ec <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003386:	0524a823          	sw	s2,80(s1)
    8000338a:	a08d                	j	800033ec <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000338c:	ff45849b          	addiw	s1,a1,-12
    80003390:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003394:	0ff00793          	li	a5,255
    80003398:	08e7e563          	bltu	a5,a4,80003422 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000339c:	08052903          	lw	s2,128(a0)
    800033a0:	00091d63          	bnez	s2,800033ba <bmap+0x72>
      addr = balloc(ip->dev);
    800033a4:	4108                	lw	a0,0(a0)
    800033a6:	00000097          	auipc	ra,0x0
    800033aa:	e70080e7          	jalr	-400(ra) # 80003216 <balloc>
    800033ae:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033b2:	02090d63          	beqz	s2,800033ec <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033b6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800033ba:	85ca                	mv	a1,s2
    800033bc:	0009a503          	lw	a0,0(s3)
    800033c0:	00000097          	auipc	ra,0x0
    800033c4:	b96080e7          	jalr	-1130(ra) # 80002f56 <bread>
    800033c8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033ca:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033ce:	02049713          	slli	a4,s1,0x20
    800033d2:	01e75593          	srli	a1,a4,0x1e
    800033d6:	00b784b3          	add	s1,a5,a1
    800033da:	0004a903          	lw	s2,0(s1)
    800033de:	02090063          	beqz	s2,800033fe <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033e2:	8552                	mv	a0,s4
    800033e4:	00000097          	auipc	ra,0x0
    800033e8:	ca2080e7          	jalr	-862(ra) # 80003086 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033ec:	854a                	mv	a0,s2
    800033ee:	70a2                	ld	ra,40(sp)
    800033f0:	7402                	ld	s0,32(sp)
    800033f2:	64e2                	ld	s1,24(sp)
    800033f4:	6942                	ld	s2,16(sp)
    800033f6:	69a2                	ld	s3,8(sp)
    800033f8:	6a02                	ld	s4,0(sp)
    800033fa:	6145                	addi	sp,sp,48
    800033fc:	8082                	ret
      addr = balloc(ip->dev);
    800033fe:	0009a503          	lw	a0,0(s3)
    80003402:	00000097          	auipc	ra,0x0
    80003406:	e14080e7          	jalr	-492(ra) # 80003216 <balloc>
    8000340a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000340e:	fc090ae3          	beqz	s2,800033e2 <bmap+0x9a>
        a[bn] = addr;
    80003412:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003416:	8552                	mv	a0,s4
    80003418:	00001097          	auipc	ra,0x1
    8000341c:	ec6080e7          	jalr	-314(ra) # 800042de <log_write>
    80003420:	b7c9                	j	800033e2 <bmap+0x9a>
  panic("bmap: out of range");
    80003422:	00005517          	auipc	a0,0x5
    80003426:	25650513          	addi	a0,a0,598 # 80008678 <syscalls+0x120>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	112080e7          	jalr	274(ra) # 8000053c <panic>

0000000080003432 <iget>:
{
    80003432:	7179                	addi	sp,sp,-48
    80003434:	f406                	sd	ra,40(sp)
    80003436:	f022                	sd	s0,32(sp)
    80003438:	ec26                	sd	s1,24(sp)
    8000343a:	e84a                	sd	s2,16(sp)
    8000343c:	e44e                	sd	s3,8(sp)
    8000343e:	e052                	sd	s4,0(sp)
    80003440:	1800                	addi	s0,sp,48
    80003442:	89aa                	mv	s3,a0
    80003444:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003446:	0001c517          	auipc	a0,0x1c
    8000344a:	0b250513          	addi	a0,a0,178 # 8001f4f8 <itable>
    8000344e:	ffffd097          	auipc	ra,0xffffd
    80003452:	784080e7          	jalr	1924(ra) # 80000bd2 <acquire>
  empty = 0;
    80003456:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003458:	0001c497          	auipc	s1,0x1c
    8000345c:	0b848493          	addi	s1,s1,184 # 8001f510 <itable+0x18>
    80003460:	0001e697          	auipc	a3,0x1e
    80003464:	b4068693          	addi	a3,a3,-1216 # 80020fa0 <log>
    80003468:	a039                	j	80003476 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000346a:	02090b63          	beqz	s2,800034a0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000346e:	08848493          	addi	s1,s1,136
    80003472:	02d48a63          	beq	s1,a3,800034a6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003476:	449c                	lw	a5,8(s1)
    80003478:	fef059e3          	blez	a5,8000346a <iget+0x38>
    8000347c:	4098                	lw	a4,0(s1)
    8000347e:	ff3716e3          	bne	a4,s3,8000346a <iget+0x38>
    80003482:	40d8                	lw	a4,4(s1)
    80003484:	ff4713e3          	bne	a4,s4,8000346a <iget+0x38>
      ip->ref++;
    80003488:	2785                	addiw	a5,a5,1
    8000348a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000348c:	0001c517          	auipc	a0,0x1c
    80003490:	06c50513          	addi	a0,a0,108 # 8001f4f8 <itable>
    80003494:	ffffd097          	auipc	ra,0xffffd
    80003498:	7f2080e7          	jalr	2034(ra) # 80000c86 <release>
      return ip;
    8000349c:	8926                	mv	s2,s1
    8000349e:	a03d                	j	800034cc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034a0:	f7f9                	bnez	a5,8000346e <iget+0x3c>
    800034a2:	8926                	mv	s2,s1
    800034a4:	b7e9                	j	8000346e <iget+0x3c>
  if(empty == 0)
    800034a6:	02090c63          	beqz	s2,800034de <iget+0xac>
  ip->dev = dev;
    800034aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034b2:	4785                	li	a5,1
    800034b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034b8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034bc:	0001c517          	auipc	a0,0x1c
    800034c0:	03c50513          	addi	a0,a0,60 # 8001f4f8 <itable>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	7c2080e7          	jalr	1986(ra) # 80000c86 <release>
}
    800034cc:	854a                	mv	a0,s2
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6a02                	ld	s4,0(sp)
    800034da:	6145                	addi	sp,sp,48
    800034dc:	8082                	ret
    panic("iget: no inodes");
    800034de:	00005517          	auipc	a0,0x5
    800034e2:	1b250513          	addi	a0,a0,434 # 80008690 <syscalls+0x138>
    800034e6:	ffffd097          	auipc	ra,0xffffd
    800034ea:	056080e7          	jalr	86(ra) # 8000053c <panic>

00000000800034ee <fsinit>:
fsinit(int dev) {
    800034ee:	7179                	addi	sp,sp,-48
    800034f0:	f406                	sd	ra,40(sp)
    800034f2:	f022                	sd	s0,32(sp)
    800034f4:	ec26                	sd	s1,24(sp)
    800034f6:	e84a                	sd	s2,16(sp)
    800034f8:	e44e                	sd	s3,8(sp)
    800034fa:	1800                	addi	s0,sp,48
    800034fc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034fe:	4585                	li	a1,1
    80003500:	00000097          	auipc	ra,0x0
    80003504:	a56080e7          	jalr	-1450(ra) # 80002f56 <bread>
    80003508:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000350a:	0001c997          	auipc	s3,0x1c
    8000350e:	fce98993          	addi	s3,s3,-50 # 8001f4d8 <sb>
    80003512:	02000613          	li	a2,32
    80003516:	05850593          	addi	a1,a0,88
    8000351a:	854e                	mv	a0,s3
    8000351c:	ffffe097          	auipc	ra,0xffffe
    80003520:	80e080e7          	jalr	-2034(ra) # 80000d2a <memmove>
  brelse(bp);
    80003524:	8526                	mv	a0,s1
    80003526:	00000097          	auipc	ra,0x0
    8000352a:	b60080e7          	jalr	-1184(ra) # 80003086 <brelse>
  if(sb.magic != FSMAGIC)
    8000352e:	0009a703          	lw	a4,0(s3)
    80003532:	102037b7          	lui	a5,0x10203
    80003536:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000353a:	02f71263          	bne	a4,a5,8000355e <fsinit+0x70>
  initlog(dev, &sb);
    8000353e:	0001c597          	auipc	a1,0x1c
    80003542:	f9a58593          	addi	a1,a1,-102 # 8001f4d8 <sb>
    80003546:	854a                	mv	a0,s2
    80003548:	00001097          	auipc	ra,0x1
    8000354c:	b2c080e7          	jalr	-1236(ra) # 80004074 <initlog>
}
    80003550:	70a2                	ld	ra,40(sp)
    80003552:	7402                	ld	s0,32(sp)
    80003554:	64e2                	ld	s1,24(sp)
    80003556:	6942                	ld	s2,16(sp)
    80003558:	69a2                	ld	s3,8(sp)
    8000355a:	6145                	addi	sp,sp,48
    8000355c:	8082                	ret
    panic("invalid file system");
    8000355e:	00005517          	auipc	a0,0x5
    80003562:	14250513          	addi	a0,a0,322 # 800086a0 <syscalls+0x148>
    80003566:	ffffd097          	auipc	ra,0xffffd
    8000356a:	fd6080e7          	jalr	-42(ra) # 8000053c <panic>

000000008000356e <iinit>:
{
    8000356e:	7179                	addi	sp,sp,-48
    80003570:	f406                	sd	ra,40(sp)
    80003572:	f022                	sd	s0,32(sp)
    80003574:	ec26                	sd	s1,24(sp)
    80003576:	e84a                	sd	s2,16(sp)
    80003578:	e44e                	sd	s3,8(sp)
    8000357a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000357c:	00005597          	auipc	a1,0x5
    80003580:	13c58593          	addi	a1,a1,316 # 800086b8 <syscalls+0x160>
    80003584:	0001c517          	auipc	a0,0x1c
    80003588:	f7450513          	addi	a0,a0,-140 # 8001f4f8 <itable>
    8000358c:	ffffd097          	auipc	ra,0xffffd
    80003590:	5b6080e7          	jalr	1462(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003594:	0001c497          	auipc	s1,0x1c
    80003598:	f8c48493          	addi	s1,s1,-116 # 8001f520 <itable+0x28>
    8000359c:	0001e997          	auipc	s3,0x1e
    800035a0:	a1498993          	addi	s3,s3,-1516 # 80020fb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035a4:	00005917          	auipc	s2,0x5
    800035a8:	11c90913          	addi	s2,s2,284 # 800086c0 <syscalls+0x168>
    800035ac:	85ca                	mv	a1,s2
    800035ae:	8526                	mv	a0,s1
    800035b0:	00001097          	auipc	ra,0x1
    800035b4:	e12080e7          	jalr	-494(ra) # 800043c2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035b8:	08848493          	addi	s1,s1,136
    800035bc:	ff3498e3          	bne	s1,s3,800035ac <iinit+0x3e>
}
    800035c0:	70a2                	ld	ra,40(sp)
    800035c2:	7402                	ld	s0,32(sp)
    800035c4:	64e2                	ld	s1,24(sp)
    800035c6:	6942                	ld	s2,16(sp)
    800035c8:	69a2                	ld	s3,8(sp)
    800035ca:	6145                	addi	sp,sp,48
    800035cc:	8082                	ret

00000000800035ce <ialloc>:
{
    800035ce:	7139                	addi	sp,sp,-64
    800035d0:	fc06                	sd	ra,56(sp)
    800035d2:	f822                	sd	s0,48(sp)
    800035d4:	f426                	sd	s1,40(sp)
    800035d6:	f04a                	sd	s2,32(sp)
    800035d8:	ec4e                	sd	s3,24(sp)
    800035da:	e852                	sd	s4,16(sp)
    800035dc:	e456                	sd	s5,8(sp)
    800035de:	e05a                	sd	s6,0(sp)
    800035e0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035e2:	0001c717          	auipc	a4,0x1c
    800035e6:	f0272703          	lw	a4,-254(a4) # 8001f4e4 <sb+0xc>
    800035ea:	4785                	li	a5,1
    800035ec:	04e7f863          	bgeu	a5,a4,8000363c <ialloc+0x6e>
    800035f0:	8aaa                	mv	s5,a0
    800035f2:	8b2e                	mv	s6,a1
    800035f4:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035f6:	0001ca17          	auipc	s4,0x1c
    800035fa:	ee2a0a13          	addi	s4,s4,-286 # 8001f4d8 <sb>
    800035fe:	00495593          	srli	a1,s2,0x4
    80003602:	018a2783          	lw	a5,24(s4)
    80003606:	9dbd                	addw	a1,a1,a5
    80003608:	8556                	mv	a0,s5
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	94c080e7          	jalr	-1716(ra) # 80002f56 <bread>
    80003612:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003614:	05850993          	addi	s3,a0,88
    80003618:	00f97793          	andi	a5,s2,15
    8000361c:	079a                	slli	a5,a5,0x6
    8000361e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003620:	00099783          	lh	a5,0(s3)
    80003624:	cf9d                	beqz	a5,80003662 <ialloc+0x94>
    brelse(bp);
    80003626:	00000097          	auipc	ra,0x0
    8000362a:	a60080e7          	jalr	-1440(ra) # 80003086 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000362e:	0905                	addi	s2,s2,1
    80003630:	00ca2703          	lw	a4,12(s4)
    80003634:	0009079b          	sext.w	a5,s2
    80003638:	fce7e3e3          	bltu	a5,a4,800035fe <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000363c:	00005517          	auipc	a0,0x5
    80003640:	08c50513          	addi	a0,a0,140 # 800086c8 <syscalls+0x170>
    80003644:	ffffd097          	auipc	ra,0xffffd
    80003648:	f42080e7          	jalr	-190(ra) # 80000586 <printf>
  return 0;
    8000364c:	4501                	li	a0,0
}
    8000364e:	70e2                	ld	ra,56(sp)
    80003650:	7442                	ld	s0,48(sp)
    80003652:	74a2                	ld	s1,40(sp)
    80003654:	7902                	ld	s2,32(sp)
    80003656:	69e2                	ld	s3,24(sp)
    80003658:	6a42                	ld	s4,16(sp)
    8000365a:	6aa2                	ld	s5,8(sp)
    8000365c:	6b02                	ld	s6,0(sp)
    8000365e:	6121                	addi	sp,sp,64
    80003660:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003662:	04000613          	li	a2,64
    80003666:	4581                	li	a1,0
    80003668:	854e                	mv	a0,s3
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	664080e7          	jalr	1636(ra) # 80000cce <memset>
      dip->type = type;
    80003672:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003676:	8526                	mv	a0,s1
    80003678:	00001097          	auipc	ra,0x1
    8000367c:	c66080e7          	jalr	-922(ra) # 800042de <log_write>
      brelse(bp);
    80003680:	8526                	mv	a0,s1
    80003682:	00000097          	auipc	ra,0x0
    80003686:	a04080e7          	jalr	-1532(ra) # 80003086 <brelse>
      return iget(dev, inum);
    8000368a:	0009059b          	sext.w	a1,s2
    8000368e:	8556                	mv	a0,s5
    80003690:	00000097          	auipc	ra,0x0
    80003694:	da2080e7          	jalr	-606(ra) # 80003432 <iget>
    80003698:	bf5d                	j	8000364e <ialloc+0x80>

000000008000369a <iupdate>:
{
    8000369a:	1101                	addi	sp,sp,-32
    8000369c:	ec06                	sd	ra,24(sp)
    8000369e:	e822                	sd	s0,16(sp)
    800036a0:	e426                	sd	s1,8(sp)
    800036a2:	e04a                	sd	s2,0(sp)
    800036a4:	1000                	addi	s0,sp,32
    800036a6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036a8:	415c                	lw	a5,4(a0)
    800036aa:	0047d79b          	srliw	a5,a5,0x4
    800036ae:	0001c597          	auipc	a1,0x1c
    800036b2:	e425a583          	lw	a1,-446(a1) # 8001f4f0 <sb+0x18>
    800036b6:	9dbd                	addw	a1,a1,a5
    800036b8:	4108                	lw	a0,0(a0)
    800036ba:	00000097          	auipc	ra,0x0
    800036be:	89c080e7          	jalr	-1892(ra) # 80002f56 <bread>
    800036c2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036c4:	05850793          	addi	a5,a0,88
    800036c8:	40d8                	lw	a4,4(s1)
    800036ca:	8b3d                	andi	a4,a4,15
    800036cc:	071a                	slli	a4,a4,0x6
    800036ce:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036d0:	04449703          	lh	a4,68(s1)
    800036d4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036d8:	04649703          	lh	a4,70(s1)
    800036dc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036e0:	04849703          	lh	a4,72(s1)
    800036e4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036e8:	04a49703          	lh	a4,74(s1)
    800036ec:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036f0:	44f8                	lw	a4,76(s1)
    800036f2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036f4:	03400613          	li	a2,52
    800036f8:	05048593          	addi	a1,s1,80
    800036fc:	00c78513          	addi	a0,a5,12
    80003700:	ffffd097          	auipc	ra,0xffffd
    80003704:	62a080e7          	jalr	1578(ra) # 80000d2a <memmove>
  log_write(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	00001097          	auipc	ra,0x1
    8000370e:	bd4080e7          	jalr	-1068(ra) # 800042de <log_write>
  brelse(bp);
    80003712:	854a                	mv	a0,s2
    80003714:	00000097          	auipc	ra,0x0
    80003718:	972080e7          	jalr	-1678(ra) # 80003086 <brelse>
}
    8000371c:	60e2                	ld	ra,24(sp)
    8000371e:	6442                	ld	s0,16(sp)
    80003720:	64a2                	ld	s1,8(sp)
    80003722:	6902                	ld	s2,0(sp)
    80003724:	6105                	addi	sp,sp,32
    80003726:	8082                	ret

0000000080003728 <idup>:
{
    80003728:	1101                	addi	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	1000                	addi	s0,sp,32
    80003732:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003734:	0001c517          	auipc	a0,0x1c
    80003738:	dc450513          	addi	a0,a0,-572 # 8001f4f8 <itable>
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	496080e7          	jalr	1174(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003744:	449c                	lw	a5,8(s1)
    80003746:	2785                	addiw	a5,a5,1
    80003748:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000374a:	0001c517          	auipc	a0,0x1c
    8000374e:	dae50513          	addi	a0,a0,-594 # 8001f4f8 <itable>
    80003752:	ffffd097          	auipc	ra,0xffffd
    80003756:	534080e7          	jalr	1332(ra) # 80000c86 <release>
}
    8000375a:	8526                	mv	a0,s1
    8000375c:	60e2                	ld	ra,24(sp)
    8000375e:	6442                	ld	s0,16(sp)
    80003760:	64a2                	ld	s1,8(sp)
    80003762:	6105                	addi	sp,sp,32
    80003764:	8082                	ret

0000000080003766 <ilock>:
{
    80003766:	1101                	addi	sp,sp,-32
    80003768:	ec06                	sd	ra,24(sp)
    8000376a:	e822                	sd	s0,16(sp)
    8000376c:	e426                	sd	s1,8(sp)
    8000376e:	e04a                	sd	s2,0(sp)
    80003770:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003772:	c115                	beqz	a0,80003796 <ilock+0x30>
    80003774:	84aa                	mv	s1,a0
    80003776:	451c                	lw	a5,8(a0)
    80003778:	00f05f63          	blez	a5,80003796 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000377c:	0541                	addi	a0,a0,16
    8000377e:	00001097          	auipc	ra,0x1
    80003782:	c7e080e7          	jalr	-898(ra) # 800043fc <acquiresleep>
  if(ip->valid == 0){
    80003786:	40bc                	lw	a5,64(s1)
    80003788:	cf99                	beqz	a5,800037a6 <ilock+0x40>
}
    8000378a:	60e2                	ld	ra,24(sp)
    8000378c:	6442                	ld	s0,16(sp)
    8000378e:	64a2                	ld	s1,8(sp)
    80003790:	6902                	ld	s2,0(sp)
    80003792:	6105                	addi	sp,sp,32
    80003794:	8082                	ret
    panic("ilock");
    80003796:	00005517          	auipc	a0,0x5
    8000379a:	f4a50513          	addi	a0,a0,-182 # 800086e0 <syscalls+0x188>
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	d9e080e7          	jalr	-610(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037a6:	40dc                	lw	a5,4(s1)
    800037a8:	0047d79b          	srliw	a5,a5,0x4
    800037ac:	0001c597          	auipc	a1,0x1c
    800037b0:	d445a583          	lw	a1,-700(a1) # 8001f4f0 <sb+0x18>
    800037b4:	9dbd                	addw	a1,a1,a5
    800037b6:	4088                	lw	a0,0(s1)
    800037b8:	fffff097          	auipc	ra,0xfffff
    800037bc:	79e080e7          	jalr	1950(ra) # 80002f56 <bread>
    800037c0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037c2:	05850593          	addi	a1,a0,88
    800037c6:	40dc                	lw	a5,4(s1)
    800037c8:	8bbd                	andi	a5,a5,15
    800037ca:	079a                	slli	a5,a5,0x6
    800037cc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037ce:	00059783          	lh	a5,0(a1)
    800037d2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037d6:	00259783          	lh	a5,2(a1)
    800037da:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037de:	00459783          	lh	a5,4(a1)
    800037e2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037e6:	00659783          	lh	a5,6(a1)
    800037ea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037ee:	459c                	lw	a5,8(a1)
    800037f0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037f2:	03400613          	li	a2,52
    800037f6:	05b1                	addi	a1,a1,12
    800037f8:	05048513          	addi	a0,s1,80
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	52e080e7          	jalr	1326(ra) # 80000d2a <memmove>
    brelse(bp);
    80003804:	854a                	mv	a0,s2
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	880080e7          	jalr	-1920(ra) # 80003086 <brelse>
    ip->valid = 1;
    8000380e:	4785                	li	a5,1
    80003810:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003812:	04449783          	lh	a5,68(s1)
    80003816:	fbb5                	bnez	a5,8000378a <ilock+0x24>
      panic("ilock: no type");
    80003818:	00005517          	auipc	a0,0x5
    8000381c:	ed050513          	addi	a0,a0,-304 # 800086e8 <syscalls+0x190>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	d1c080e7          	jalr	-740(ra) # 8000053c <panic>

0000000080003828 <iunlock>:
{
    80003828:	1101                	addi	sp,sp,-32
    8000382a:	ec06                	sd	ra,24(sp)
    8000382c:	e822                	sd	s0,16(sp)
    8000382e:	e426                	sd	s1,8(sp)
    80003830:	e04a                	sd	s2,0(sp)
    80003832:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003834:	c905                	beqz	a0,80003864 <iunlock+0x3c>
    80003836:	84aa                	mv	s1,a0
    80003838:	01050913          	addi	s2,a0,16
    8000383c:	854a                	mv	a0,s2
    8000383e:	00001097          	auipc	ra,0x1
    80003842:	c58080e7          	jalr	-936(ra) # 80004496 <holdingsleep>
    80003846:	cd19                	beqz	a0,80003864 <iunlock+0x3c>
    80003848:	449c                	lw	a5,8(s1)
    8000384a:	00f05d63          	blez	a5,80003864 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000384e:	854a                	mv	a0,s2
    80003850:	00001097          	auipc	ra,0x1
    80003854:	c02080e7          	jalr	-1022(ra) # 80004452 <releasesleep>
}
    80003858:	60e2                	ld	ra,24(sp)
    8000385a:	6442                	ld	s0,16(sp)
    8000385c:	64a2                	ld	s1,8(sp)
    8000385e:	6902                	ld	s2,0(sp)
    80003860:	6105                	addi	sp,sp,32
    80003862:	8082                	ret
    panic("iunlock");
    80003864:	00005517          	auipc	a0,0x5
    80003868:	e9450513          	addi	a0,a0,-364 # 800086f8 <syscalls+0x1a0>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	cd0080e7          	jalr	-816(ra) # 8000053c <panic>

0000000080003874 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003874:	7179                	addi	sp,sp,-48
    80003876:	f406                	sd	ra,40(sp)
    80003878:	f022                	sd	s0,32(sp)
    8000387a:	ec26                	sd	s1,24(sp)
    8000387c:	e84a                	sd	s2,16(sp)
    8000387e:	e44e                	sd	s3,8(sp)
    80003880:	e052                	sd	s4,0(sp)
    80003882:	1800                	addi	s0,sp,48
    80003884:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003886:	05050493          	addi	s1,a0,80
    8000388a:	08050913          	addi	s2,a0,128
    8000388e:	a021                	j	80003896 <itrunc+0x22>
    80003890:	0491                	addi	s1,s1,4
    80003892:	01248d63          	beq	s1,s2,800038ac <itrunc+0x38>
    if(ip->addrs[i]){
    80003896:	408c                	lw	a1,0(s1)
    80003898:	dde5                	beqz	a1,80003890 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000389a:	0009a503          	lw	a0,0(s3)
    8000389e:	00000097          	auipc	ra,0x0
    800038a2:	8fc080e7          	jalr	-1796(ra) # 8000319a <bfree>
      ip->addrs[i] = 0;
    800038a6:	0004a023          	sw	zero,0(s1)
    800038aa:	b7dd                	j	80003890 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038ac:	0809a583          	lw	a1,128(s3)
    800038b0:	e185                	bnez	a1,800038d0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038b6:	854e                	mv	a0,s3
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	de2080e7          	jalr	-542(ra) # 8000369a <iupdate>
}
    800038c0:	70a2                	ld	ra,40(sp)
    800038c2:	7402                	ld	s0,32(sp)
    800038c4:	64e2                	ld	s1,24(sp)
    800038c6:	6942                	ld	s2,16(sp)
    800038c8:	69a2                	ld	s3,8(sp)
    800038ca:	6a02                	ld	s4,0(sp)
    800038cc:	6145                	addi	sp,sp,48
    800038ce:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038d0:	0009a503          	lw	a0,0(s3)
    800038d4:	fffff097          	auipc	ra,0xfffff
    800038d8:	682080e7          	jalr	1666(ra) # 80002f56 <bread>
    800038dc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038de:	05850493          	addi	s1,a0,88
    800038e2:	45850913          	addi	s2,a0,1112
    800038e6:	a021                	j	800038ee <itrunc+0x7a>
    800038e8:	0491                	addi	s1,s1,4
    800038ea:	01248b63          	beq	s1,s2,80003900 <itrunc+0x8c>
      if(a[j])
    800038ee:	408c                	lw	a1,0(s1)
    800038f0:	dde5                	beqz	a1,800038e8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800038f2:	0009a503          	lw	a0,0(s3)
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	8a4080e7          	jalr	-1884(ra) # 8000319a <bfree>
    800038fe:	b7ed                	j	800038e8 <itrunc+0x74>
    brelse(bp);
    80003900:	8552                	mv	a0,s4
    80003902:	fffff097          	auipc	ra,0xfffff
    80003906:	784080e7          	jalr	1924(ra) # 80003086 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000390a:	0809a583          	lw	a1,128(s3)
    8000390e:	0009a503          	lw	a0,0(s3)
    80003912:	00000097          	auipc	ra,0x0
    80003916:	888080e7          	jalr	-1912(ra) # 8000319a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000391a:	0809a023          	sw	zero,128(s3)
    8000391e:	bf51                	j	800038b2 <itrunc+0x3e>

0000000080003920 <iput>:
{
    80003920:	1101                	addi	sp,sp,-32
    80003922:	ec06                	sd	ra,24(sp)
    80003924:	e822                	sd	s0,16(sp)
    80003926:	e426                	sd	s1,8(sp)
    80003928:	e04a                	sd	s2,0(sp)
    8000392a:	1000                	addi	s0,sp,32
    8000392c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000392e:	0001c517          	auipc	a0,0x1c
    80003932:	bca50513          	addi	a0,a0,-1078 # 8001f4f8 <itable>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	29c080e7          	jalr	668(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000393e:	4498                	lw	a4,8(s1)
    80003940:	4785                	li	a5,1
    80003942:	02f70363          	beq	a4,a5,80003968 <iput+0x48>
  ip->ref--;
    80003946:	449c                	lw	a5,8(s1)
    80003948:	37fd                	addiw	a5,a5,-1
    8000394a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000394c:	0001c517          	auipc	a0,0x1c
    80003950:	bac50513          	addi	a0,a0,-1108 # 8001f4f8 <itable>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	332080e7          	jalr	818(ra) # 80000c86 <release>
}
    8000395c:	60e2                	ld	ra,24(sp)
    8000395e:	6442                	ld	s0,16(sp)
    80003960:	64a2                	ld	s1,8(sp)
    80003962:	6902                	ld	s2,0(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003968:	40bc                	lw	a5,64(s1)
    8000396a:	dff1                	beqz	a5,80003946 <iput+0x26>
    8000396c:	04a49783          	lh	a5,74(s1)
    80003970:	fbf9                	bnez	a5,80003946 <iput+0x26>
    acquiresleep(&ip->lock);
    80003972:	01048913          	addi	s2,s1,16
    80003976:	854a                	mv	a0,s2
    80003978:	00001097          	auipc	ra,0x1
    8000397c:	a84080e7          	jalr	-1404(ra) # 800043fc <acquiresleep>
    release(&itable.lock);
    80003980:	0001c517          	auipc	a0,0x1c
    80003984:	b7850513          	addi	a0,a0,-1160 # 8001f4f8 <itable>
    80003988:	ffffd097          	auipc	ra,0xffffd
    8000398c:	2fe080e7          	jalr	766(ra) # 80000c86 <release>
    itrunc(ip);
    80003990:	8526                	mv	a0,s1
    80003992:	00000097          	auipc	ra,0x0
    80003996:	ee2080e7          	jalr	-286(ra) # 80003874 <itrunc>
    ip->type = 0;
    8000399a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000399e:	8526                	mv	a0,s1
    800039a0:	00000097          	auipc	ra,0x0
    800039a4:	cfa080e7          	jalr	-774(ra) # 8000369a <iupdate>
    ip->valid = 0;
    800039a8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039ac:	854a                	mv	a0,s2
    800039ae:	00001097          	auipc	ra,0x1
    800039b2:	aa4080e7          	jalr	-1372(ra) # 80004452 <releasesleep>
    acquire(&itable.lock);
    800039b6:	0001c517          	auipc	a0,0x1c
    800039ba:	b4250513          	addi	a0,a0,-1214 # 8001f4f8 <itable>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	214080e7          	jalr	532(ra) # 80000bd2 <acquire>
    800039c6:	b741                	j	80003946 <iput+0x26>

00000000800039c8 <iunlockput>:
{
    800039c8:	1101                	addi	sp,sp,-32
    800039ca:	ec06                	sd	ra,24(sp)
    800039cc:	e822                	sd	s0,16(sp)
    800039ce:	e426                	sd	s1,8(sp)
    800039d0:	1000                	addi	s0,sp,32
    800039d2:	84aa                	mv	s1,a0
  iunlock(ip);
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	e54080e7          	jalr	-428(ra) # 80003828 <iunlock>
  iput(ip);
    800039dc:	8526                	mv	a0,s1
    800039de:	00000097          	auipc	ra,0x0
    800039e2:	f42080e7          	jalr	-190(ra) # 80003920 <iput>
}
    800039e6:	60e2                	ld	ra,24(sp)
    800039e8:	6442                	ld	s0,16(sp)
    800039ea:	64a2                	ld	s1,8(sp)
    800039ec:	6105                	addi	sp,sp,32
    800039ee:	8082                	ret

00000000800039f0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039f0:	1141                	addi	sp,sp,-16
    800039f2:	e422                	sd	s0,8(sp)
    800039f4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039f6:	411c                	lw	a5,0(a0)
    800039f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039fa:	415c                	lw	a5,4(a0)
    800039fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039fe:	04451783          	lh	a5,68(a0)
    80003a02:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a06:	04a51783          	lh	a5,74(a0)
    80003a0a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a0e:	04c56783          	lwu	a5,76(a0)
    80003a12:	e99c                	sd	a5,16(a1)
}
    80003a14:	6422                	ld	s0,8(sp)
    80003a16:	0141                	addi	sp,sp,16
    80003a18:	8082                	ret

0000000080003a1a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a1a:	457c                	lw	a5,76(a0)
    80003a1c:	0ed7e963          	bltu	a5,a3,80003b0e <readi+0xf4>
{
    80003a20:	7159                	addi	sp,sp,-112
    80003a22:	f486                	sd	ra,104(sp)
    80003a24:	f0a2                	sd	s0,96(sp)
    80003a26:	eca6                	sd	s1,88(sp)
    80003a28:	e8ca                	sd	s2,80(sp)
    80003a2a:	e4ce                	sd	s3,72(sp)
    80003a2c:	e0d2                	sd	s4,64(sp)
    80003a2e:	fc56                	sd	s5,56(sp)
    80003a30:	f85a                	sd	s6,48(sp)
    80003a32:	f45e                	sd	s7,40(sp)
    80003a34:	f062                	sd	s8,32(sp)
    80003a36:	ec66                	sd	s9,24(sp)
    80003a38:	e86a                	sd	s10,16(sp)
    80003a3a:	e46e                	sd	s11,8(sp)
    80003a3c:	1880                	addi	s0,sp,112
    80003a3e:	8b2a                	mv	s6,a0
    80003a40:	8bae                	mv	s7,a1
    80003a42:	8a32                	mv	s4,a2
    80003a44:	84b6                	mv	s1,a3
    80003a46:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a48:	9f35                	addw	a4,a4,a3
    return 0;
    80003a4a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a4c:	0ad76063          	bltu	a4,a3,80003aec <readi+0xd2>
  if(off + n > ip->size)
    80003a50:	00e7f463          	bgeu	a5,a4,80003a58 <readi+0x3e>
    n = ip->size - off;
    80003a54:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a58:	0a0a8963          	beqz	s5,80003b0a <readi+0xf0>
    80003a5c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a5e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a62:	5c7d                	li	s8,-1
    80003a64:	a82d                	j	80003a9e <readi+0x84>
    80003a66:	020d1d93          	slli	s11,s10,0x20
    80003a6a:	020ddd93          	srli	s11,s11,0x20
    80003a6e:	05890613          	addi	a2,s2,88
    80003a72:	86ee                	mv	a3,s11
    80003a74:	963a                	add	a2,a2,a4
    80003a76:	85d2                	mv	a1,s4
    80003a78:	855e                	mv	a0,s7
    80003a7a:	fffff097          	auipc	ra,0xfffff
    80003a7e:	9f8080e7          	jalr	-1544(ra) # 80002472 <either_copyout>
    80003a82:	05850d63          	beq	a0,s8,80003adc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a86:	854a                	mv	a0,s2
    80003a88:	fffff097          	auipc	ra,0xfffff
    80003a8c:	5fe080e7          	jalr	1534(ra) # 80003086 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a90:	013d09bb          	addw	s3,s10,s3
    80003a94:	009d04bb          	addw	s1,s10,s1
    80003a98:	9a6e                	add	s4,s4,s11
    80003a9a:	0559f763          	bgeu	s3,s5,80003ae8 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a9e:	00a4d59b          	srliw	a1,s1,0xa
    80003aa2:	855a                	mv	a0,s6
    80003aa4:	00000097          	auipc	ra,0x0
    80003aa8:	8a4080e7          	jalr	-1884(ra) # 80003348 <bmap>
    80003aac:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ab0:	cd85                	beqz	a1,80003ae8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ab2:	000b2503          	lw	a0,0(s6)
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	4a0080e7          	jalr	1184(ra) # 80002f56 <bread>
    80003abe:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ac0:	3ff4f713          	andi	a4,s1,1023
    80003ac4:	40ec87bb          	subw	a5,s9,a4
    80003ac8:	413a86bb          	subw	a3,s5,s3
    80003acc:	8d3e                	mv	s10,a5
    80003ace:	2781                	sext.w	a5,a5
    80003ad0:	0006861b          	sext.w	a2,a3
    80003ad4:	f8f679e3          	bgeu	a2,a5,80003a66 <readi+0x4c>
    80003ad8:	8d36                	mv	s10,a3
    80003ada:	b771                	j	80003a66 <readi+0x4c>
      brelse(bp);
    80003adc:	854a                	mv	a0,s2
    80003ade:	fffff097          	auipc	ra,0xfffff
    80003ae2:	5a8080e7          	jalr	1448(ra) # 80003086 <brelse>
      tot = -1;
    80003ae6:	59fd                	li	s3,-1
  }
  return tot;
    80003ae8:	0009851b          	sext.w	a0,s3
}
    80003aec:	70a6                	ld	ra,104(sp)
    80003aee:	7406                	ld	s0,96(sp)
    80003af0:	64e6                	ld	s1,88(sp)
    80003af2:	6946                	ld	s2,80(sp)
    80003af4:	69a6                	ld	s3,72(sp)
    80003af6:	6a06                	ld	s4,64(sp)
    80003af8:	7ae2                	ld	s5,56(sp)
    80003afa:	7b42                	ld	s6,48(sp)
    80003afc:	7ba2                	ld	s7,40(sp)
    80003afe:	7c02                	ld	s8,32(sp)
    80003b00:	6ce2                	ld	s9,24(sp)
    80003b02:	6d42                	ld	s10,16(sp)
    80003b04:	6da2                	ld	s11,8(sp)
    80003b06:	6165                	addi	sp,sp,112
    80003b08:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b0a:	89d6                	mv	s3,s5
    80003b0c:	bff1                	j	80003ae8 <readi+0xce>
    return 0;
    80003b0e:	4501                	li	a0,0
}
    80003b10:	8082                	ret

0000000080003b12 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b12:	457c                	lw	a5,76(a0)
    80003b14:	10d7e863          	bltu	a5,a3,80003c24 <writei+0x112>
{
    80003b18:	7159                	addi	sp,sp,-112
    80003b1a:	f486                	sd	ra,104(sp)
    80003b1c:	f0a2                	sd	s0,96(sp)
    80003b1e:	eca6                	sd	s1,88(sp)
    80003b20:	e8ca                	sd	s2,80(sp)
    80003b22:	e4ce                	sd	s3,72(sp)
    80003b24:	e0d2                	sd	s4,64(sp)
    80003b26:	fc56                	sd	s5,56(sp)
    80003b28:	f85a                	sd	s6,48(sp)
    80003b2a:	f45e                	sd	s7,40(sp)
    80003b2c:	f062                	sd	s8,32(sp)
    80003b2e:	ec66                	sd	s9,24(sp)
    80003b30:	e86a                	sd	s10,16(sp)
    80003b32:	e46e                	sd	s11,8(sp)
    80003b34:	1880                	addi	s0,sp,112
    80003b36:	8aaa                	mv	s5,a0
    80003b38:	8bae                	mv	s7,a1
    80003b3a:	8a32                	mv	s4,a2
    80003b3c:	8936                	mv	s2,a3
    80003b3e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b40:	00e687bb          	addw	a5,a3,a4
    80003b44:	0ed7e263          	bltu	a5,a3,80003c28 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b48:	00043737          	lui	a4,0x43
    80003b4c:	0ef76063          	bltu	a4,a5,80003c2c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b50:	0c0b0863          	beqz	s6,80003c20 <writei+0x10e>
    80003b54:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b56:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b5a:	5c7d                	li	s8,-1
    80003b5c:	a091                	j	80003ba0 <writei+0x8e>
    80003b5e:	020d1d93          	slli	s11,s10,0x20
    80003b62:	020ddd93          	srli	s11,s11,0x20
    80003b66:	05848513          	addi	a0,s1,88
    80003b6a:	86ee                	mv	a3,s11
    80003b6c:	8652                	mv	a2,s4
    80003b6e:	85de                	mv	a1,s7
    80003b70:	953a                	add	a0,a0,a4
    80003b72:	fffff097          	auipc	ra,0xfffff
    80003b76:	956080e7          	jalr	-1706(ra) # 800024c8 <either_copyin>
    80003b7a:	07850263          	beq	a0,s8,80003bde <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b7e:	8526                	mv	a0,s1
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	75e080e7          	jalr	1886(ra) # 800042de <log_write>
    brelse(bp);
    80003b88:	8526                	mv	a0,s1
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	4fc080e7          	jalr	1276(ra) # 80003086 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b92:	013d09bb          	addw	s3,s10,s3
    80003b96:	012d093b          	addw	s2,s10,s2
    80003b9a:	9a6e                	add	s4,s4,s11
    80003b9c:	0569f663          	bgeu	s3,s6,80003be8 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003ba0:	00a9559b          	srliw	a1,s2,0xa
    80003ba4:	8556                	mv	a0,s5
    80003ba6:	fffff097          	auipc	ra,0xfffff
    80003baa:	7a2080e7          	jalr	1954(ra) # 80003348 <bmap>
    80003bae:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bb2:	c99d                	beqz	a1,80003be8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003bb4:	000aa503          	lw	a0,0(s5)
    80003bb8:	fffff097          	auipc	ra,0xfffff
    80003bbc:	39e080e7          	jalr	926(ra) # 80002f56 <bread>
    80003bc0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bc2:	3ff97713          	andi	a4,s2,1023
    80003bc6:	40ec87bb          	subw	a5,s9,a4
    80003bca:	413b06bb          	subw	a3,s6,s3
    80003bce:	8d3e                	mv	s10,a5
    80003bd0:	2781                	sext.w	a5,a5
    80003bd2:	0006861b          	sext.w	a2,a3
    80003bd6:	f8f674e3          	bgeu	a2,a5,80003b5e <writei+0x4c>
    80003bda:	8d36                	mv	s10,a3
    80003bdc:	b749                	j	80003b5e <writei+0x4c>
      brelse(bp);
    80003bde:	8526                	mv	a0,s1
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	4a6080e7          	jalr	1190(ra) # 80003086 <brelse>
  }

  if(off > ip->size)
    80003be8:	04caa783          	lw	a5,76(s5)
    80003bec:	0127f463          	bgeu	a5,s2,80003bf4 <writei+0xe2>
    ip->size = off;
    80003bf0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003bf4:	8556                	mv	a0,s5
    80003bf6:	00000097          	auipc	ra,0x0
    80003bfa:	aa4080e7          	jalr	-1372(ra) # 8000369a <iupdate>

  return tot;
    80003bfe:	0009851b          	sext.w	a0,s3
}
    80003c02:	70a6                	ld	ra,104(sp)
    80003c04:	7406                	ld	s0,96(sp)
    80003c06:	64e6                	ld	s1,88(sp)
    80003c08:	6946                	ld	s2,80(sp)
    80003c0a:	69a6                	ld	s3,72(sp)
    80003c0c:	6a06                	ld	s4,64(sp)
    80003c0e:	7ae2                	ld	s5,56(sp)
    80003c10:	7b42                	ld	s6,48(sp)
    80003c12:	7ba2                	ld	s7,40(sp)
    80003c14:	7c02                	ld	s8,32(sp)
    80003c16:	6ce2                	ld	s9,24(sp)
    80003c18:	6d42                	ld	s10,16(sp)
    80003c1a:	6da2                	ld	s11,8(sp)
    80003c1c:	6165                	addi	sp,sp,112
    80003c1e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c20:	89da                	mv	s3,s6
    80003c22:	bfc9                	j	80003bf4 <writei+0xe2>
    return -1;
    80003c24:	557d                	li	a0,-1
}
    80003c26:	8082                	ret
    return -1;
    80003c28:	557d                	li	a0,-1
    80003c2a:	bfe1                	j	80003c02 <writei+0xf0>
    return -1;
    80003c2c:	557d                	li	a0,-1
    80003c2e:	bfd1                	j	80003c02 <writei+0xf0>

0000000080003c30 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c30:	1141                	addi	sp,sp,-16
    80003c32:	e406                	sd	ra,8(sp)
    80003c34:	e022                	sd	s0,0(sp)
    80003c36:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c38:	4639                	li	a2,14
    80003c3a:	ffffd097          	auipc	ra,0xffffd
    80003c3e:	164080e7          	jalr	356(ra) # 80000d9e <strncmp>
}
    80003c42:	60a2                	ld	ra,8(sp)
    80003c44:	6402                	ld	s0,0(sp)
    80003c46:	0141                	addi	sp,sp,16
    80003c48:	8082                	ret

0000000080003c4a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c4a:	7139                	addi	sp,sp,-64
    80003c4c:	fc06                	sd	ra,56(sp)
    80003c4e:	f822                	sd	s0,48(sp)
    80003c50:	f426                	sd	s1,40(sp)
    80003c52:	f04a                	sd	s2,32(sp)
    80003c54:	ec4e                	sd	s3,24(sp)
    80003c56:	e852                	sd	s4,16(sp)
    80003c58:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c5a:	04451703          	lh	a4,68(a0)
    80003c5e:	4785                	li	a5,1
    80003c60:	00f71a63          	bne	a4,a5,80003c74 <dirlookup+0x2a>
    80003c64:	892a                	mv	s2,a0
    80003c66:	89ae                	mv	s3,a1
    80003c68:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c6a:	457c                	lw	a5,76(a0)
    80003c6c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c6e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c70:	e79d                	bnez	a5,80003c9e <dirlookup+0x54>
    80003c72:	a8a5                	j	80003cea <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c74:	00005517          	auipc	a0,0x5
    80003c78:	a8c50513          	addi	a0,a0,-1396 # 80008700 <syscalls+0x1a8>
    80003c7c:	ffffd097          	auipc	ra,0xffffd
    80003c80:	8c0080e7          	jalr	-1856(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003c84:	00005517          	auipc	a0,0x5
    80003c88:	a9450513          	addi	a0,a0,-1388 # 80008718 <syscalls+0x1c0>
    80003c8c:	ffffd097          	auipc	ra,0xffffd
    80003c90:	8b0080e7          	jalr	-1872(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c94:	24c1                	addiw	s1,s1,16
    80003c96:	04c92783          	lw	a5,76(s2)
    80003c9a:	04f4f763          	bgeu	s1,a5,80003ce8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c9e:	4741                	li	a4,16
    80003ca0:	86a6                	mv	a3,s1
    80003ca2:	fc040613          	addi	a2,s0,-64
    80003ca6:	4581                	li	a1,0
    80003ca8:	854a                	mv	a0,s2
    80003caa:	00000097          	auipc	ra,0x0
    80003cae:	d70080e7          	jalr	-656(ra) # 80003a1a <readi>
    80003cb2:	47c1                	li	a5,16
    80003cb4:	fcf518e3          	bne	a0,a5,80003c84 <dirlookup+0x3a>
    if(de.inum == 0)
    80003cb8:	fc045783          	lhu	a5,-64(s0)
    80003cbc:	dfe1                	beqz	a5,80003c94 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cbe:	fc240593          	addi	a1,s0,-62
    80003cc2:	854e                	mv	a0,s3
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	f6c080e7          	jalr	-148(ra) # 80003c30 <namecmp>
    80003ccc:	f561                	bnez	a0,80003c94 <dirlookup+0x4a>
      if(poff)
    80003cce:	000a0463          	beqz	s4,80003cd6 <dirlookup+0x8c>
        *poff = off;
    80003cd2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cd6:	fc045583          	lhu	a1,-64(s0)
    80003cda:	00092503          	lw	a0,0(s2)
    80003cde:	fffff097          	auipc	ra,0xfffff
    80003ce2:	754080e7          	jalr	1876(ra) # 80003432 <iget>
    80003ce6:	a011                	j	80003cea <dirlookup+0xa0>
  return 0;
    80003ce8:	4501                	li	a0,0
}
    80003cea:	70e2                	ld	ra,56(sp)
    80003cec:	7442                	ld	s0,48(sp)
    80003cee:	74a2                	ld	s1,40(sp)
    80003cf0:	7902                	ld	s2,32(sp)
    80003cf2:	69e2                	ld	s3,24(sp)
    80003cf4:	6a42                	ld	s4,16(sp)
    80003cf6:	6121                	addi	sp,sp,64
    80003cf8:	8082                	ret

0000000080003cfa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cfa:	711d                	addi	sp,sp,-96
    80003cfc:	ec86                	sd	ra,88(sp)
    80003cfe:	e8a2                	sd	s0,80(sp)
    80003d00:	e4a6                	sd	s1,72(sp)
    80003d02:	e0ca                	sd	s2,64(sp)
    80003d04:	fc4e                	sd	s3,56(sp)
    80003d06:	f852                	sd	s4,48(sp)
    80003d08:	f456                	sd	s5,40(sp)
    80003d0a:	f05a                	sd	s6,32(sp)
    80003d0c:	ec5e                	sd	s7,24(sp)
    80003d0e:	e862                	sd	s8,16(sp)
    80003d10:	e466                	sd	s9,8(sp)
    80003d12:	1080                	addi	s0,sp,96
    80003d14:	84aa                	mv	s1,a0
    80003d16:	8b2e                	mv	s6,a1
    80003d18:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d1a:	00054703          	lbu	a4,0(a0)
    80003d1e:	02f00793          	li	a5,47
    80003d22:	02f70263          	beq	a4,a5,80003d46 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d26:	ffffe097          	auipc	ra,0xffffe
    80003d2a:	c90080e7          	jalr	-880(ra) # 800019b6 <myproc>
    80003d2e:	15053503          	ld	a0,336(a0)
    80003d32:	00000097          	auipc	ra,0x0
    80003d36:	9f6080e7          	jalr	-1546(ra) # 80003728 <idup>
    80003d3a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d3c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d40:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d42:	4b85                	li	s7,1
    80003d44:	a875                	j	80003e00 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d46:	4585                	li	a1,1
    80003d48:	4505                	li	a0,1
    80003d4a:	fffff097          	auipc	ra,0xfffff
    80003d4e:	6e8080e7          	jalr	1768(ra) # 80003432 <iget>
    80003d52:	8a2a                	mv	s4,a0
    80003d54:	b7e5                	j	80003d3c <namex+0x42>
      iunlockput(ip);
    80003d56:	8552                	mv	a0,s4
    80003d58:	00000097          	auipc	ra,0x0
    80003d5c:	c70080e7          	jalr	-912(ra) # 800039c8 <iunlockput>
      return 0;
    80003d60:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d62:	8552                	mv	a0,s4
    80003d64:	60e6                	ld	ra,88(sp)
    80003d66:	6446                	ld	s0,80(sp)
    80003d68:	64a6                	ld	s1,72(sp)
    80003d6a:	6906                	ld	s2,64(sp)
    80003d6c:	79e2                	ld	s3,56(sp)
    80003d6e:	7a42                	ld	s4,48(sp)
    80003d70:	7aa2                	ld	s5,40(sp)
    80003d72:	7b02                	ld	s6,32(sp)
    80003d74:	6be2                	ld	s7,24(sp)
    80003d76:	6c42                	ld	s8,16(sp)
    80003d78:	6ca2                	ld	s9,8(sp)
    80003d7a:	6125                	addi	sp,sp,96
    80003d7c:	8082                	ret
      iunlock(ip);
    80003d7e:	8552                	mv	a0,s4
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	aa8080e7          	jalr	-1368(ra) # 80003828 <iunlock>
      return ip;
    80003d88:	bfe9                	j	80003d62 <namex+0x68>
      iunlockput(ip);
    80003d8a:	8552                	mv	a0,s4
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	c3c080e7          	jalr	-964(ra) # 800039c8 <iunlockput>
      return 0;
    80003d94:	8a4e                	mv	s4,s3
    80003d96:	b7f1                	j	80003d62 <namex+0x68>
  len = path - s;
    80003d98:	40998633          	sub	a2,s3,s1
    80003d9c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003da0:	099c5863          	bge	s8,s9,80003e30 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003da4:	4639                	li	a2,14
    80003da6:	85a6                	mv	a1,s1
    80003da8:	8556                	mv	a0,s5
    80003daa:	ffffd097          	auipc	ra,0xffffd
    80003dae:	f80080e7          	jalr	-128(ra) # 80000d2a <memmove>
    80003db2:	84ce                	mv	s1,s3
  while(*path == '/')
    80003db4:	0004c783          	lbu	a5,0(s1)
    80003db8:	01279763          	bne	a5,s2,80003dc6 <namex+0xcc>
    path++;
    80003dbc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dbe:	0004c783          	lbu	a5,0(s1)
    80003dc2:	ff278de3          	beq	a5,s2,80003dbc <namex+0xc2>
    ilock(ip);
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	99e080e7          	jalr	-1634(ra) # 80003766 <ilock>
    if(ip->type != T_DIR){
    80003dd0:	044a1783          	lh	a5,68(s4)
    80003dd4:	f97791e3          	bne	a5,s7,80003d56 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003dd8:	000b0563          	beqz	s6,80003de2 <namex+0xe8>
    80003ddc:	0004c783          	lbu	a5,0(s1)
    80003de0:	dfd9                	beqz	a5,80003d7e <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003de2:	4601                	li	a2,0
    80003de4:	85d6                	mv	a1,s5
    80003de6:	8552                	mv	a0,s4
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	e62080e7          	jalr	-414(ra) # 80003c4a <dirlookup>
    80003df0:	89aa                	mv	s3,a0
    80003df2:	dd41                	beqz	a0,80003d8a <namex+0x90>
    iunlockput(ip);
    80003df4:	8552                	mv	a0,s4
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	bd2080e7          	jalr	-1070(ra) # 800039c8 <iunlockput>
    ip = next;
    80003dfe:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e00:	0004c783          	lbu	a5,0(s1)
    80003e04:	01279763          	bne	a5,s2,80003e12 <namex+0x118>
    path++;
    80003e08:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e0a:	0004c783          	lbu	a5,0(s1)
    80003e0e:	ff278de3          	beq	a5,s2,80003e08 <namex+0x10e>
  if(*path == 0)
    80003e12:	cb9d                	beqz	a5,80003e48 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e14:	0004c783          	lbu	a5,0(s1)
    80003e18:	89a6                	mv	s3,s1
  len = path - s;
    80003e1a:	4c81                	li	s9,0
    80003e1c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e1e:	01278963          	beq	a5,s2,80003e30 <namex+0x136>
    80003e22:	dbbd                	beqz	a5,80003d98 <namex+0x9e>
    path++;
    80003e24:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e26:	0009c783          	lbu	a5,0(s3)
    80003e2a:	ff279ce3          	bne	a5,s2,80003e22 <namex+0x128>
    80003e2e:	b7ad                	j	80003d98 <namex+0x9e>
    memmove(name, s, len);
    80003e30:	2601                	sext.w	a2,a2
    80003e32:	85a6                	mv	a1,s1
    80003e34:	8556                	mv	a0,s5
    80003e36:	ffffd097          	auipc	ra,0xffffd
    80003e3a:	ef4080e7          	jalr	-268(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003e3e:	9cd6                	add	s9,s9,s5
    80003e40:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e44:	84ce                	mv	s1,s3
    80003e46:	b7bd                	j	80003db4 <namex+0xba>
  if(nameiparent){
    80003e48:	f00b0de3          	beqz	s6,80003d62 <namex+0x68>
    iput(ip);
    80003e4c:	8552                	mv	a0,s4
    80003e4e:	00000097          	auipc	ra,0x0
    80003e52:	ad2080e7          	jalr	-1326(ra) # 80003920 <iput>
    return 0;
    80003e56:	4a01                	li	s4,0
    80003e58:	b729                	j	80003d62 <namex+0x68>

0000000080003e5a <dirlink>:
{
    80003e5a:	7139                	addi	sp,sp,-64
    80003e5c:	fc06                	sd	ra,56(sp)
    80003e5e:	f822                	sd	s0,48(sp)
    80003e60:	f426                	sd	s1,40(sp)
    80003e62:	f04a                	sd	s2,32(sp)
    80003e64:	ec4e                	sd	s3,24(sp)
    80003e66:	e852                	sd	s4,16(sp)
    80003e68:	0080                	addi	s0,sp,64
    80003e6a:	892a                	mv	s2,a0
    80003e6c:	8a2e                	mv	s4,a1
    80003e6e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e70:	4601                	li	a2,0
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	dd8080e7          	jalr	-552(ra) # 80003c4a <dirlookup>
    80003e7a:	e93d                	bnez	a0,80003ef0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e7c:	04c92483          	lw	s1,76(s2)
    80003e80:	c49d                	beqz	s1,80003eae <dirlink+0x54>
    80003e82:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e84:	4741                	li	a4,16
    80003e86:	86a6                	mv	a3,s1
    80003e88:	fc040613          	addi	a2,s0,-64
    80003e8c:	4581                	li	a1,0
    80003e8e:	854a                	mv	a0,s2
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	b8a080e7          	jalr	-1142(ra) # 80003a1a <readi>
    80003e98:	47c1                	li	a5,16
    80003e9a:	06f51163          	bne	a0,a5,80003efc <dirlink+0xa2>
    if(de.inum == 0)
    80003e9e:	fc045783          	lhu	a5,-64(s0)
    80003ea2:	c791                	beqz	a5,80003eae <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea4:	24c1                	addiw	s1,s1,16
    80003ea6:	04c92783          	lw	a5,76(s2)
    80003eaa:	fcf4ede3          	bltu	s1,a5,80003e84 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003eae:	4639                	li	a2,14
    80003eb0:	85d2                	mv	a1,s4
    80003eb2:	fc240513          	addi	a0,s0,-62
    80003eb6:	ffffd097          	auipc	ra,0xffffd
    80003eba:	f24080e7          	jalr	-220(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003ebe:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ec2:	4741                	li	a4,16
    80003ec4:	86a6                	mv	a3,s1
    80003ec6:	fc040613          	addi	a2,s0,-64
    80003eca:	4581                	li	a1,0
    80003ecc:	854a                	mv	a0,s2
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	c44080e7          	jalr	-956(ra) # 80003b12 <writei>
    80003ed6:	1541                	addi	a0,a0,-16
    80003ed8:	00a03533          	snez	a0,a0
    80003edc:	40a00533          	neg	a0,a0
}
    80003ee0:	70e2                	ld	ra,56(sp)
    80003ee2:	7442                	ld	s0,48(sp)
    80003ee4:	74a2                	ld	s1,40(sp)
    80003ee6:	7902                	ld	s2,32(sp)
    80003ee8:	69e2                	ld	s3,24(sp)
    80003eea:	6a42                	ld	s4,16(sp)
    80003eec:	6121                	addi	sp,sp,64
    80003eee:	8082                	ret
    iput(ip);
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	a30080e7          	jalr	-1488(ra) # 80003920 <iput>
    return -1;
    80003ef8:	557d                	li	a0,-1
    80003efa:	b7dd                	j	80003ee0 <dirlink+0x86>
      panic("dirlink read");
    80003efc:	00005517          	auipc	a0,0x5
    80003f00:	82c50513          	addi	a0,a0,-2004 # 80008728 <syscalls+0x1d0>
    80003f04:	ffffc097          	auipc	ra,0xffffc
    80003f08:	638080e7          	jalr	1592(ra) # 8000053c <panic>

0000000080003f0c <namei>:

struct inode*
namei(char *path)
{
    80003f0c:	1101                	addi	sp,sp,-32
    80003f0e:	ec06                	sd	ra,24(sp)
    80003f10:	e822                	sd	s0,16(sp)
    80003f12:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f14:	fe040613          	addi	a2,s0,-32
    80003f18:	4581                	li	a1,0
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	de0080e7          	jalr	-544(ra) # 80003cfa <namex>
}
    80003f22:	60e2                	ld	ra,24(sp)
    80003f24:	6442                	ld	s0,16(sp)
    80003f26:	6105                	addi	sp,sp,32
    80003f28:	8082                	ret

0000000080003f2a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f2a:	1141                	addi	sp,sp,-16
    80003f2c:	e406                	sd	ra,8(sp)
    80003f2e:	e022                	sd	s0,0(sp)
    80003f30:	0800                	addi	s0,sp,16
    80003f32:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f34:	4585                	li	a1,1
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	dc4080e7          	jalr	-572(ra) # 80003cfa <namex>
}
    80003f3e:	60a2                	ld	ra,8(sp)
    80003f40:	6402                	ld	s0,0(sp)
    80003f42:	0141                	addi	sp,sp,16
    80003f44:	8082                	ret

0000000080003f46 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f46:	1101                	addi	sp,sp,-32
    80003f48:	ec06                	sd	ra,24(sp)
    80003f4a:	e822                	sd	s0,16(sp)
    80003f4c:	e426                	sd	s1,8(sp)
    80003f4e:	e04a                	sd	s2,0(sp)
    80003f50:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f52:	0001d917          	auipc	s2,0x1d
    80003f56:	04e90913          	addi	s2,s2,78 # 80020fa0 <log>
    80003f5a:	01892583          	lw	a1,24(s2)
    80003f5e:	02892503          	lw	a0,40(s2)
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	ff4080e7          	jalr	-12(ra) # 80002f56 <bread>
    80003f6a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f6c:	02c92603          	lw	a2,44(s2)
    80003f70:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f72:	00c05f63          	blez	a2,80003f90 <write_head+0x4a>
    80003f76:	0001d717          	auipc	a4,0x1d
    80003f7a:	05a70713          	addi	a4,a4,90 # 80020fd0 <log+0x30>
    80003f7e:	87aa                	mv	a5,a0
    80003f80:	060a                	slli	a2,a2,0x2
    80003f82:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f84:	4314                	lw	a3,0(a4)
    80003f86:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f88:	0711                	addi	a4,a4,4
    80003f8a:	0791                	addi	a5,a5,4
    80003f8c:	fec79ce3          	bne	a5,a2,80003f84 <write_head+0x3e>
  }
  bwrite(buf);
    80003f90:	8526                	mv	a0,s1
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	0b6080e7          	jalr	182(ra) # 80003048 <bwrite>
  brelse(buf);
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	fffff097          	auipc	ra,0xfffff
    80003fa0:	0ea080e7          	jalr	234(ra) # 80003086 <brelse>
}
    80003fa4:	60e2                	ld	ra,24(sp)
    80003fa6:	6442                	ld	s0,16(sp)
    80003fa8:	64a2                	ld	s1,8(sp)
    80003faa:	6902                	ld	s2,0(sp)
    80003fac:	6105                	addi	sp,sp,32
    80003fae:	8082                	ret

0000000080003fb0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb0:	0001d797          	auipc	a5,0x1d
    80003fb4:	01c7a783          	lw	a5,28(a5) # 80020fcc <log+0x2c>
    80003fb8:	0af05d63          	blez	a5,80004072 <install_trans+0xc2>
{
    80003fbc:	7139                	addi	sp,sp,-64
    80003fbe:	fc06                	sd	ra,56(sp)
    80003fc0:	f822                	sd	s0,48(sp)
    80003fc2:	f426                	sd	s1,40(sp)
    80003fc4:	f04a                	sd	s2,32(sp)
    80003fc6:	ec4e                	sd	s3,24(sp)
    80003fc8:	e852                	sd	s4,16(sp)
    80003fca:	e456                	sd	s5,8(sp)
    80003fcc:	e05a                	sd	s6,0(sp)
    80003fce:	0080                	addi	s0,sp,64
    80003fd0:	8b2a                	mv	s6,a0
    80003fd2:	0001da97          	auipc	s5,0x1d
    80003fd6:	ffea8a93          	addi	s5,s5,-2 # 80020fd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fda:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fdc:	0001d997          	auipc	s3,0x1d
    80003fe0:	fc498993          	addi	s3,s3,-60 # 80020fa0 <log>
    80003fe4:	a00d                	j	80004006 <install_trans+0x56>
    brelse(lbuf);
    80003fe6:	854a                	mv	a0,s2
    80003fe8:	fffff097          	auipc	ra,0xfffff
    80003fec:	09e080e7          	jalr	158(ra) # 80003086 <brelse>
    brelse(dbuf);
    80003ff0:	8526                	mv	a0,s1
    80003ff2:	fffff097          	auipc	ra,0xfffff
    80003ff6:	094080e7          	jalr	148(ra) # 80003086 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ffa:	2a05                	addiw	s4,s4,1
    80003ffc:	0a91                	addi	s5,s5,4
    80003ffe:	02c9a783          	lw	a5,44(s3)
    80004002:	04fa5e63          	bge	s4,a5,8000405e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004006:	0189a583          	lw	a1,24(s3)
    8000400a:	014585bb          	addw	a1,a1,s4
    8000400e:	2585                	addiw	a1,a1,1
    80004010:	0289a503          	lw	a0,40(s3)
    80004014:	fffff097          	auipc	ra,0xfffff
    80004018:	f42080e7          	jalr	-190(ra) # 80002f56 <bread>
    8000401c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000401e:	000aa583          	lw	a1,0(s5)
    80004022:	0289a503          	lw	a0,40(s3)
    80004026:	fffff097          	auipc	ra,0xfffff
    8000402a:	f30080e7          	jalr	-208(ra) # 80002f56 <bread>
    8000402e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004030:	40000613          	li	a2,1024
    80004034:	05890593          	addi	a1,s2,88
    80004038:	05850513          	addi	a0,a0,88
    8000403c:	ffffd097          	auipc	ra,0xffffd
    80004040:	cee080e7          	jalr	-786(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004044:	8526                	mv	a0,s1
    80004046:	fffff097          	auipc	ra,0xfffff
    8000404a:	002080e7          	jalr	2(ra) # 80003048 <bwrite>
    if(recovering == 0)
    8000404e:	f80b1ce3          	bnez	s6,80003fe6 <install_trans+0x36>
      bunpin(dbuf);
    80004052:	8526                	mv	a0,s1
    80004054:	fffff097          	auipc	ra,0xfffff
    80004058:	10a080e7          	jalr	266(ra) # 8000315e <bunpin>
    8000405c:	b769                	j	80003fe6 <install_trans+0x36>
}
    8000405e:	70e2                	ld	ra,56(sp)
    80004060:	7442                	ld	s0,48(sp)
    80004062:	74a2                	ld	s1,40(sp)
    80004064:	7902                	ld	s2,32(sp)
    80004066:	69e2                	ld	s3,24(sp)
    80004068:	6a42                	ld	s4,16(sp)
    8000406a:	6aa2                	ld	s5,8(sp)
    8000406c:	6b02                	ld	s6,0(sp)
    8000406e:	6121                	addi	sp,sp,64
    80004070:	8082                	ret
    80004072:	8082                	ret

0000000080004074 <initlog>:
{
    80004074:	7179                	addi	sp,sp,-48
    80004076:	f406                	sd	ra,40(sp)
    80004078:	f022                	sd	s0,32(sp)
    8000407a:	ec26                	sd	s1,24(sp)
    8000407c:	e84a                	sd	s2,16(sp)
    8000407e:	e44e                	sd	s3,8(sp)
    80004080:	1800                	addi	s0,sp,48
    80004082:	892a                	mv	s2,a0
    80004084:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004086:	0001d497          	auipc	s1,0x1d
    8000408a:	f1a48493          	addi	s1,s1,-230 # 80020fa0 <log>
    8000408e:	00004597          	auipc	a1,0x4
    80004092:	6aa58593          	addi	a1,a1,1706 # 80008738 <syscalls+0x1e0>
    80004096:	8526                	mv	a0,s1
    80004098:	ffffd097          	auipc	ra,0xffffd
    8000409c:	aaa080e7          	jalr	-1366(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800040a0:	0149a583          	lw	a1,20(s3)
    800040a4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040a6:	0109a783          	lw	a5,16(s3)
    800040aa:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040ac:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040b0:	854a                	mv	a0,s2
    800040b2:	fffff097          	auipc	ra,0xfffff
    800040b6:	ea4080e7          	jalr	-348(ra) # 80002f56 <bread>
  log.lh.n = lh->n;
    800040ba:	4d30                	lw	a2,88(a0)
    800040bc:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040be:	00c05f63          	blez	a2,800040dc <initlog+0x68>
    800040c2:	87aa                	mv	a5,a0
    800040c4:	0001d717          	auipc	a4,0x1d
    800040c8:	f0c70713          	addi	a4,a4,-244 # 80020fd0 <log+0x30>
    800040cc:	060a                	slli	a2,a2,0x2
    800040ce:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040d0:	4ff4                	lw	a3,92(a5)
    800040d2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040d4:	0791                	addi	a5,a5,4
    800040d6:	0711                	addi	a4,a4,4
    800040d8:	fec79ce3          	bne	a5,a2,800040d0 <initlog+0x5c>
  brelse(buf);
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	faa080e7          	jalr	-86(ra) # 80003086 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040e4:	4505                	li	a0,1
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	eca080e7          	jalr	-310(ra) # 80003fb0 <install_trans>
  log.lh.n = 0;
    800040ee:	0001d797          	auipc	a5,0x1d
    800040f2:	ec07af23          	sw	zero,-290(a5) # 80020fcc <log+0x2c>
  write_head(); // clear the log
    800040f6:	00000097          	auipc	ra,0x0
    800040fa:	e50080e7          	jalr	-432(ra) # 80003f46 <write_head>
}
    800040fe:	70a2                	ld	ra,40(sp)
    80004100:	7402                	ld	s0,32(sp)
    80004102:	64e2                	ld	s1,24(sp)
    80004104:	6942                	ld	s2,16(sp)
    80004106:	69a2                	ld	s3,8(sp)
    80004108:	6145                	addi	sp,sp,48
    8000410a:	8082                	ret

000000008000410c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000410c:	1101                	addi	sp,sp,-32
    8000410e:	ec06                	sd	ra,24(sp)
    80004110:	e822                	sd	s0,16(sp)
    80004112:	e426                	sd	s1,8(sp)
    80004114:	e04a                	sd	s2,0(sp)
    80004116:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004118:	0001d517          	auipc	a0,0x1d
    8000411c:	e8850513          	addi	a0,a0,-376 # 80020fa0 <log>
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	ab2080e7          	jalr	-1358(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004128:	0001d497          	auipc	s1,0x1d
    8000412c:	e7848493          	addi	s1,s1,-392 # 80020fa0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004130:	4979                	li	s2,30
    80004132:	a039                	j	80004140 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004134:	85a6                	mv	a1,s1
    80004136:	8526                	mv	a0,s1
    80004138:	ffffe097          	auipc	ra,0xffffe
    8000413c:	f32080e7          	jalr	-206(ra) # 8000206a <sleep>
    if(log.committing){
    80004140:	50dc                	lw	a5,36(s1)
    80004142:	fbed                	bnez	a5,80004134 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004144:	5098                	lw	a4,32(s1)
    80004146:	2705                	addiw	a4,a4,1
    80004148:	0027179b          	slliw	a5,a4,0x2
    8000414c:	9fb9                	addw	a5,a5,a4
    8000414e:	0017979b          	slliw	a5,a5,0x1
    80004152:	54d4                	lw	a3,44(s1)
    80004154:	9fb5                	addw	a5,a5,a3
    80004156:	00f95963          	bge	s2,a5,80004168 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000415a:	85a6                	mv	a1,s1
    8000415c:	8526                	mv	a0,s1
    8000415e:	ffffe097          	auipc	ra,0xffffe
    80004162:	f0c080e7          	jalr	-244(ra) # 8000206a <sleep>
    80004166:	bfe9                	j	80004140 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004168:	0001d517          	auipc	a0,0x1d
    8000416c:	e3850513          	addi	a0,a0,-456 # 80020fa0 <log>
    80004170:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004172:	ffffd097          	auipc	ra,0xffffd
    80004176:	b14080e7          	jalr	-1260(ra) # 80000c86 <release>
      break;
    }
  }
}
    8000417a:	60e2                	ld	ra,24(sp)
    8000417c:	6442                	ld	s0,16(sp)
    8000417e:	64a2                	ld	s1,8(sp)
    80004180:	6902                	ld	s2,0(sp)
    80004182:	6105                	addi	sp,sp,32
    80004184:	8082                	ret

0000000080004186 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004186:	7139                	addi	sp,sp,-64
    80004188:	fc06                	sd	ra,56(sp)
    8000418a:	f822                	sd	s0,48(sp)
    8000418c:	f426                	sd	s1,40(sp)
    8000418e:	f04a                	sd	s2,32(sp)
    80004190:	ec4e                	sd	s3,24(sp)
    80004192:	e852                	sd	s4,16(sp)
    80004194:	e456                	sd	s5,8(sp)
    80004196:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004198:	0001d497          	auipc	s1,0x1d
    8000419c:	e0848493          	addi	s1,s1,-504 # 80020fa0 <log>
    800041a0:	8526                	mv	a0,s1
    800041a2:	ffffd097          	auipc	ra,0xffffd
    800041a6:	a30080e7          	jalr	-1488(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800041aa:	509c                	lw	a5,32(s1)
    800041ac:	37fd                	addiw	a5,a5,-1
    800041ae:	0007891b          	sext.w	s2,a5
    800041b2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041b4:	50dc                	lw	a5,36(s1)
    800041b6:	e7b9                	bnez	a5,80004204 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041b8:	04091e63          	bnez	s2,80004214 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041bc:	0001d497          	auipc	s1,0x1d
    800041c0:	de448493          	addi	s1,s1,-540 # 80020fa0 <log>
    800041c4:	4785                	li	a5,1
    800041c6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041c8:	8526                	mv	a0,s1
    800041ca:	ffffd097          	auipc	ra,0xffffd
    800041ce:	abc080e7          	jalr	-1348(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041d2:	54dc                	lw	a5,44(s1)
    800041d4:	06f04763          	bgtz	a5,80004242 <end_op+0xbc>
    acquire(&log.lock);
    800041d8:	0001d497          	auipc	s1,0x1d
    800041dc:	dc848493          	addi	s1,s1,-568 # 80020fa0 <log>
    800041e0:	8526                	mv	a0,s1
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	9f0080e7          	jalr	-1552(ra) # 80000bd2 <acquire>
    log.committing = 0;
    800041ea:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041ee:	8526                	mv	a0,s1
    800041f0:	ffffe097          	auipc	ra,0xffffe
    800041f4:	ede080e7          	jalr	-290(ra) # 800020ce <wakeup>
    release(&log.lock);
    800041f8:	8526                	mv	a0,s1
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	a8c080e7          	jalr	-1396(ra) # 80000c86 <release>
}
    80004202:	a03d                	j	80004230 <end_op+0xaa>
    panic("log.committing");
    80004204:	00004517          	auipc	a0,0x4
    80004208:	53c50513          	addi	a0,a0,1340 # 80008740 <syscalls+0x1e8>
    8000420c:	ffffc097          	auipc	ra,0xffffc
    80004210:	330080e7          	jalr	816(ra) # 8000053c <panic>
    wakeup(&log);
    80004214:	0001d497          	auipc	s1,0x1d
    80004218:	d8c48493          	addi	s1,s1,-628 # 80020fa0 <log>
    8000421c:	8526                	mv	a0,s1
    8000421e:	ffffe097          	auipc	ra,0xffffe
    80004222:	eb0080e7          	jalr	-336(ra) # 800020ce <wakeup>
  release(&log.lock);
    80004226:	8526                	mv	a0,s1
    80004228:	ffffd097          	auipc	ra,0xffffd
    8000422c:	a5e080e7          	jalr	-1442(ra) # 80000c86 <release>
}
    80004230:	70e2                	ld	ra,56(sp)
    80004232:	7442                	ld	s0,48(sp)
    80004234:	74a2                	ld	s1,40(sp)
    80004236:	7902                	ld	s2,32(sp)
    80004238:	69e2                	ld	s3,24(sp)
    8000423a:	6a42                	ld	s4,16(sp)
    8000423c:	6aa2                	ld	s5,8(sp)
    8000423e:	6121                	addi	sp,sp,64
    80004240:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004242:	0001da97          	auipc	s5,0x1d
    80004246:	d8ea8a93          	addi	s5,s5,-626 # 80020fd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000424a:	0001da17          	auipc	s4,0x1d
    8000424e:	d56a0a13          	addi	s4,s4,-682 # 80020fa0 <log>
    80004252:	018a2583          	lw	a1,24(s4)
    80004256:	012585bb          	addw	a1,a1,s2
    8000425a:	2585                	addiw	a1,a1,1
    8000425c:	028a2503          	lw	a0,40(s4)
    80004260:	fffff097          	auipc	ra,0xfffff
    80004264:	cf6080e7          	jalr	-778(ra) # 80002f56 <bread>
    80004268:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000426a:	000aa583          	lw	a1,0(s5)
    8000426e:	028a2503          	lw	a0,40(s4)
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	ce4080e7          	jalr	-796(ra) # 80002f56 <bread>
    8000427a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000427c:	40000613          	li	a2,1024
    80004280:	05850593          	addi	a1,a0,88
    80004284:	05848513          	addi	a0,s1,88
    80004288:	ffffd097          	auipc	ra,0xffffd
    8000428c:	aa2080e7          	jalr	-1374(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004290:	8526                	mv	a0,s1
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	db6080e7          	jalr	-586(ra) # 80003048 <bwrite>
    brelse(from);
    8000429a:	854e                	mv	a0,s3
    8000429c:	fffff097          	auipc	ra,0xfffff
    800042a0:	dea080e7          	jalr	-534(ra) # 80003086 <brelse>
    brelse(to);
    800042a4:	8526                	mv	a0,s1
    800042a6:	fffff097          	auipc	ra,0xfffff
    800042aa:	de0080e7          	jalr	-544(ra) # 80003086 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ae:	2905                	addiw	s2,s2,1
    800042b0:	0a91                	addi	s5,s5,4
    800042b2:	02ca2783          	lw	a5,44(s4)
    800042b6:	f8f94ee3          	blt	s2,a5,80004252 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042ba:	00000097          	auipc	ra,0x0
    800042be:	c8c080e7          	jalr	-884(ra) # 80003f46 <write_head>
    install_trans(0); // Now install writes to home locations
    800042c2:	4501                	li	a0,0
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	cec080e7          	jalr	-788(ra) # 80003fb0 <install_trans>
    log.lh.n = 0;
    800042cc:	0001d797          	auipc	a5,0x1d
    800042d0:	d007a023          	sw	zero,-768(a5) # 80020fcc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	c72080e7          	jalr	-910(ra) # 80003f46 <write_head>
    800042dc:	bdf5                	j	800041d8 <end_op+0x52>

00000000800042de <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042de:	1101                	addi	sp,sp,-32
    800042e0:	ec06                	sd	ra,24(sp)
    800042e2:	e822                	sd	s0,16(sp)
    800042e4:	e426                	sd	s1,8(sp)
    800042e6:	e04a                	sd	s2,0(sp)
    800042e8:	1000                	addi	s0,sp,32
    800042ea:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042ec:	0001d917          	auipc	s2,0x1d
    800042f0:	cb490913          	addi	s2,s2,-844 # 80020fa0 <log>
    800042f4:	854a                	mv	a0,s2
    800042f6:	ffffd097          	auipc	ra,0xffffd
    800042fa:	8dc080e7          	jalr	-1828(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042fe:	02c92603          	lw	a2,44(s2)
    80004302:	47f5                	li	a5,29
    80004304:	06c7c563          	blt	a5,a2,8000436e <log_write+0x90>
    80004308:	0001d797          	auipc	a5,0x1d
    8000430c:	cb47a783          	lw	a5,-844(a5) # 80020fbc <log+0x1c>
    80004310:	37fd                	addiw	a5,a5,-1
    80004312:	04f65e63          	bge	a2,a5,8000436e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004316:	0001d797          	auipc	a5,0x1d
    8000431a:	caa7a783          	lw	a5,-854(a5) # 80020fc0 <log+0x20>
    8000431e:	06f05063          	blez	a5,8000437e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004322:	4781                	li	a5,0
    80004324:	06c05563          	blez	a2,8000438e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004328:	44cc                	lw	a1,12(s1)
    8000432a:	0001d717          	auipc	a4,0x1d
    8000432e:	ca670713          	addi	a4,a4,-858 # 80020fd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004332:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004334:	4314                	lw	a3,0(a4)
    80004336:	04b68c63          	beq	a3,a1,8000438e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000433a:	2785                	addiw	a5,a5,1
    8000433c:	0711                	addi	a4,a4,4
    8000433e:	fef61be3          	bne	a2,a5,80004334 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004342:	0621                	addi	a2,a2,8
    80004344:	060a                	slli	a2,a2,0x2
    80004346:	0001d797          	auipc	a5,0x1d
    8000434a:	c5a78793          	addi	a5,a5,-934 # 80020fa0 <log>
    8000434e:	97b2                	add	a5,a5,a2
    80004350:	44d8                	lw	a4,12(s1)
    80004352:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004354:	8526                	mv	a0,s1
    80004356:	fffff097          	auipc	ra,0xfffff
    8000435a:	dcc080e7          	jalr	-564(ra) # 80003122 <bpin>
    log.lh.n++;
    8000435e:	0001d717          	auipc	a4,0x1d
    80004362:	c4270713          	addi	a4,a4,-958 # 80020fa0 <log>
    80004366:	575c                	lw	a5,44(a4)
    80004368:	2785                	addiw	a5,a5,1
    8000436a:	d75c                	sw	a5,44(a4)
    8000436c:	a82d                	j	800043a6 <log_write+0xc8>
    panic("too big a transaction");
    8000436e:	00004517          	auipc	a0,0x4
    80004372:	3e250513          	addi	a0,a0,994 # 80008750 <syscalls+0x1f8>
    80004376:	ffffc097          	auipc	ra,0xffffc
    8000437a:	1c6080e7          	jalr	454(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    8000437e:	00004517          	auipc	a0,0x4
    80004382:	3ea50513          	addi	a0,a0,1002 # 80008768 <syscalls+0x210>
    80004386:	ffffc097          	auipc	ra,0xffffc
    8000438a:	1b6080e7          	jalr	438(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    8000438e:	00878693          	addi	a3,a5,8
    80004392:	068a                	slli	a3,a3,0x2
    80004394:	0001d717          	auipc	a4,0x1d
    80004398:	c0c70713          	addi	a4,a4,-1012 # 80020fa0 <log>
    8000439c:	9736                	add	a4,a4,a3
    8000439e:	44d4                	lw	a3,12(s1)
    800043a0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043a2:	faf609e3          	beq	a2,a5,80004354 <log_write+0x76>
  }
  release(&log.lock);
    800043a6:	0001d517          	auipc	a0,0x1d
    800043aa:	bfa50513          	addi	a0,a0,-1030 # 80020fa0 <log>
    800043ae:	ffffd097          	auipc	ra,0xffffd
    800043b2:	8d8080e7          	jalr	-1832(ra) # 80000c86 <release>
}
    800043b6:	60e2                	ld	ra,24(sp)
    800043b8:	6442                	ld	s0,16(sp)
    800043ba:	64a2                	ld	s1,8(sp)
    800043bc:	6902                	ld	s2,0(sp)
    800043be:	6105                	addi	sp,sp,32
    800043c0:	8082                	ret

00000000800043c2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043c2:	1101                	addi	sp,sp,-32
    800043c4:	ec06                	sd	ra,24(sp)
    800043c6:	e822                	sd	s0,16(sp)
    800043c8:	e426                	sd	s1,8(sp)
    800043ca:	e04a                	sd	s2,0(sp)
    800043cc:	1000                	addi	s0,sp,32
    800043ce:	84aa                	mv	s1,a0
    800043d0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043d2:	00004597          	auipc	a1,0x4
    800043d6:	3b658593          	addi	a1,a1,950 # 80008788 <syscalls+0x230>
    800043da:	0521                	addi	a0,a0,8
    800043dc:	ffffc097          	auipc	ra,0xffffc
    800043e0:	766080e7          	jalr	1894(ra) # 80000b42 <initlock>
  lk->name = name;
    800043e4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043ec:	0204a423          	sw	zero,40(s1)
}
    800043f0:	60e2                	ld	ra,24(sp)
    800043f2:	6442                	ld	s0,16(sp)
    800043f4:	64a2                	ld	s1,8(sp)
    800043f6:	6902                	ld	s2,0(sp)
    800043f8:	6105                	addi	sp,sp,32
    800043fa:	8082                	ret

00000000800043fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043fc:	1101                	addi	sp,sp,-32
    800043fe:	ec06                	sd	ra,24(sp)
    80004400:	e822                	sd	s0,16(sp)
    80004402:	e426                	sd	s1,8(sp)
    80004404:	e04a                	sd	s2,0(sp)
    80004406:	1000                	addi	s0,sp,32
    80004408:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000440a:	00850913          	addi	s2,a0,8
    8000440e:	854a                	mv	a0,s2
    80004410:	ffffc097          	auipc	ra,0xffffc
    80004414:	7c2080e7          	jalr	1986(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004418:	409c                	lw	a5,0(s1)
    8000441a:	cb89                	beqz	a5,8000442c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000441c:	85ca                	mv	a1,s2
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffe097          	auipc	ra,0xffffe
    80004424:	c4a080e7          	jalr	-950(ra) # 8000206a <sleep>
  while (lk->locked) {
    80004428:	409c                	lw	a5,0(s1)
    8000442a:	fbed                	bnez	a5,8000441c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000442c:	4785                	li	a5,1
    8000442e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004430:	ffffd097          	auipc	ra,0xffffd
    80004434:	586080e7          	jalr	1414(ra) # 800019b6 <myproc>
    80004438:	591c                	lw	a5,48(a0)
    8000443a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000443c:	854a                	mv	a0,s2
    8000443e:	ffffd097          	auipc	ra,0xffffd
    80004442:	848080e7          	jalr	-1976(ra) # 80000c86 <release>
}
    80004446:	60e2                	ld	ra,24(sp)
    80004448:	6442                	ld	s0,16(sp)
    8000444a:	64a2                	ld	s1,8(sp)
    8000444c:	6902                	ld	s2,0(sp)
    8000444e:	6105                	addi	sp,sp,32
    80004450:	8082                	ret

0000000080004452 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004452:	1101                	addi	sp,sp,-32
    80004454:	ec06                	sd	ra,24(sp)
    80004456:	e822                	sd	s0,16(sp)
    80004458:	e426                	sd	s1,8(sp)
    8000445a:	e04a                	sd	s2,0(sp)
    8000445c:	1000                	addi	s0,sp,32
    8000445e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004460:	00850913          	addi	s2,a0,8
    80004464:	854a                	mv	a0,s2
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	76c080e7          	jalr	1900(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    8000446e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004472:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004476:	8526                	mv	a0,s1
    80004478:	ffffe097          	auipc	ra,0xffffe
    8000447c:	c56080e7          	jalr	-938(ra) # 800020ce <wakeup>
  release(&lk->lk);
    80004480:	854a                	mv	a0,s2
    80004482:	ffffd097          	auipc	ra,0xffffd
    80004486:	804080e7          	jalr	-2044(ra) # 80000c86 <release>
}
    8000448a:	60e2                	ld	ra,24(sp)
    8000448c:	6442                	ld	s0,16(sp)
    8000448e:	64a2                	ld	s1,8(sp)
    80004490:	6902                	ld	s2,0(sp)
    80004492:	6105                	addi	sp,sp,32
    80004494:	8082                	ret

0000000080004496 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004496:	7179                	addi	sp,sp,-48
    80004498:	f406                	sd	ra,40(sp)
    8000449a:	f022                	sd	s0,32(sp)
    8000449c:	ec26                	sd	s1,24(sp)
    8000449e:	e84a                	sd	s2,16(sp)
    800044a0:	e44e                	sd	s3,8(sp)
    800044a2:	1800                	addi	s0,sp,48
    800044a4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044a6:	00850913          	addi	s2,a0,8
    800044aa:	854a                	mv	a0,s2
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	726080e7          	jalr	1830(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044b4:	409c                	lw	a5,0(s1)
    800044b6:	ef99                	bnez	a5,800044d4 <holdingsleep+0x3e>
    800044b8:	4481                	li	s1,0
  release(&lk->lk);
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	7ca080e7          	jalr	1994(ra) # 80000c86 <release>
  return r;
}
    800044c4:	8526                	mv	a0,s1
    800044c6:	70a2                	ld	ra,40(sp)
    800044c8:	7402                	ld	s0,32(sp)
    800044ca:	64e2                	ld	s1,24(sp)
    800044cc:	6942                	ld	s2,16(sp)
    800044ce:	69a2                	ld	s3,8(sp)
    800044d0:	6145                	addi	sp,sp,48
    800044d2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044d4:	0284a983          	lw	s3,40(s1)
    800044d8:	ffffd097          	auipc	ra,0xffffd
    800044dc:	4de080e7          	jalr	1246(ra) # 800019b6 <myproc>
    800044e0:	5904                	lw	s1,48(a0)
    800044e2:	413484b3          	sub	s1,s1,s3
    800044e6:	0014b493          	seqz	s1,s1
    800044ea:	bfc1                	j	800044ba <holdingsleep+0x24>

00000000800044ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044ec:	1141                	addi	sp,sp,-16
    800044ee:	e406                	sd	ra,8(sp)
    800044f0:	e022                	sd	s0,0(sp)
    800044f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044f4:	00004597          	auipc	a1,0x4
    800044f8:	2a458593          	addi	a1,a1,676 # 80008798 <syscalls+0x240>
    800044fc:	0001d517          	auipc	a0,0x1d
    80004500:	bec50513          	addi	a0,a0,-1044 # 800210e8 <ftable>
    80004504:	ffffc097          	auipc	ra,0xffffc
    80004508:	63e080e7          	jalr	1598(ra) # 80000b42 <initlock>
}
    8000450c:	60a2                	ld	ra,8(sp)
    8000450e:	6402                	ld	s0,0(sp)
    80004510:	0141                	addi	sp,sp,16
    80004512:	8082                	ret

0000000080004514 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004514:	1101                	addi	sp,sp,-32
    80004516:	ec06                	sd	ra,24(sp)
    80004518:	e822                	sd	s0,16(sp)
    8000451a:	e426                	sd	s1,8(sp)
    8000451c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000451e:	0001d517          	auipc	a0,0x1d
    80004522:	bca50513          	addi	a0,a0,-1078 # 800210e8 <ftable>
    80004526:	ffffc097          	auipc	ra,0xffffc
    8000452a:	6ac080e7          	jalr	1708(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000452e:	0001d497          	auipc	s1,0x1d
    80004532:	bd248493          	addi	s1,s1,-1070 # 80021100 <ftable+0x18>
    80004536:	0001e717          	auipc	a4,0x1e
    8000453a:	b6a70713          	addi	a4,a4,-1174 # 800220a0 <disk>
    if(f->ref == 0){
    8000453e:	40dc                	lw	a5,4(s1)
    80004540:	cf99                	beqz	a5,8000455e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004542:	02848493          	addi	s1,s1,40
    80004546:	fee49ce3          	bne	s1,a4,8000453e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000454a:	0001d517          	auipc	a0,0x1d
    8000454e:	b9e50513          	addi	a0,a0,-1122 # 800210e8 <ftable>
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	734080e7          	jalr	1844(ra) # 80000c86 <release>
  return 0;
    8000455a:	4481                	li	s1,0
    8000455c:	a819                	j	80004572 <filealloc+0x5e>
      f->ref = 1;
    8000455e:	4785                	li	a5,1
    80004560:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004562:	0001d517          	auipc	a0,0x1d
    80004566:	b8650513          	addi	a0,a0,-1146 # 800210e8 <ftable>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	71c080e7          	jalr	1820(ra) # 80000c86 <release>
}
    80004572:	8526                	mv	a0,s1
    80004574:	60e2                	ld	ra,24(sp)
    80004576:	6442                	ld	s0,16(sp)
    80004578:	64a2                	ld	s1,8(sp)
    8000457a:	6105                	addi	sp,sp,32
    8000457c:	8082                	ret

000000008000457e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000457e:	1101                	addi	sp,sp,-32
    80004580:	ec06                	sd	ra,24(sp)
    80004582:	e822                	sd	s0,16(sp)
    80004584:	e426                	sd	s1,8(sp)
    80004586:	1000                	addi	s0,sp,32
    80004588:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000458a:	0001d517          	auipc	a0,0x1d
    8000458e:	b5e50513          	addi	a0,a0,-1186 # 800210e8 <ftable>
    80004592:	ffffc097          	auipc	ra,0xffffc
    80004596:	640080e7          	jalr	1600(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000459a:	40dc                	lw	a5,4(s1)
    8000459c:	02f05263          	blez	a5,800045c0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045a0:	2785                	addiw	a5,a5,1
    800045a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045a4:	0001d517          	auipc	a0,0x1d
    800045a8:	b4450513          	addi	a0,a0,-1212 # 800210e8 <ftable>
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	6da080e7          	jalr	1754(ra) # 80000c86 <release>
  return f;
}
    800045b4:	8526                	mv	a0,s1
    800045b6:	60e2                	ld	ra,24(sp)
    800045b8:	6442                	ld	s0,16(sp)
    800045ba:	64a2                	ld	s1,8(sp)
    800045bc:	6105                	addi	sp,sp,32
    800045be:	8082                	ret
    panic("filedup");
    800045c0:	00004517          	auipc	a0,0x4
    800045c4:	1e050513          	addi	a0,a0,480 # 800087a0 <syscalls+0x248>
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	f74080e7          	jalr	-140(ra) # 8000053c <panic>

00000000800045d0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045d0:	7139                	addi	sp,sp,-64
    800045d2:	fc06                	sd	ra,56(sp)
    800045d4:	f822                	sd	s0,48(sp)
    800045d6:	f426                	sd	s1,40(sp)
    800045d8:	f04a                	sd	s2,32(sp)
    800045da:	ec4e                	sd	s3,24(sp)
    800045dc:	e852                	sd	s4,16(sp)
    800045de:	e456                	sd	s5,8(sp)
    800045e0:	0080                	addi	s0,sp,64
    800045e2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045e4:	0001d517          	auipc	a0,0x1d
    800045e8:	b0450513          	addi	a0,a0,-1276 # 800210e8 <ftable>
    800045ec:	ffffc097          	auipc	ra,0xffffc
    800045f0:	5e6080e7          	jalr	1510(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045f4:	40dc                	lw	a5,4(s1)
    800045f6:	06f05163          	blez	a5,80004658 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045fa:	37fd                	addiw	a5,a5,-1
    800045fc:	0007871b          	sext.w	a4,a5
    80004600:	c0dc                	sw	a5,4(s1)
    80004602:	06e04363          	bgtz	a4,80004668 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004606:	0004a903          	lw	s2,0(s1)
    8000460a:	0094ca83          	lbu	s5,9(s1)
    8000460e:	0104ba03          	ld	s4,16(s1)
    80004612:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004616:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000461a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000461e:	0001d517          	auipc	a0,0x1d
    80004622:	aca50513          	addi	a0,a0,-1334 # 800210e8 <ftable>
    80004626:	ffffc097          	auipc	ra,0xffffc
    8000462a:	660080e7          	jalr	1632(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    8000462e:	4785                	li	a5,1
    80004630:	04f90d63          	beq	s2,a5,8000468a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004634:	3979                	addiw	s2,s2,-2
    80004636:	4785                	li	a5,1
    80004638:	0527e063          	bltu	a5,s2,80004678 <fileclose+0xa8>
    begin_op();
    8000463c:	00000097          	auipc	ra,0x0
    80004640:	ad0080e7          	jalr	-1328(ra) # 8000410c <begin_op>
    iput(ff.ip);
    80004644:	854e                	mv	a0,s3
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	2da080e7          	jalr	730(ra) # 80003920 <iput>
    end_op();
    8000464e:	00000097          	auipc	ra,0x0
    80004652:	b38080e7          	jalr	-1224(ra) # 80004186 <end_op>
    80004656:	a00d                	j	80004678 <fileclose+0xa8>
    panic("fileclose");
    80004658:	00004517          	auipc	a0,0x4
    8000465c:	15050513          	addi	a0,a0,336 # 800087a8 <syscalls+0x250>
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	edc080e7          	jalr	-292(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004668:	0001d517          	auipc	a0,0x1d
    8000466c:	a8050513          	addi	a0,a0,-1408 # 800210e8 <ftable>
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	616080e7          	jalr	1558(ra) # 80000c86 <release>
  }
}
    80004678:	70e2                	ld	ra,56(sp)
    8000467a:	7442                	ld	s0,48(sp)
    8000467c:	74a2                	ld	s1,40(sp)
    8000467e:	7902                	ld	s2,32(sp)
    80004680:	69e2                	ld	s3,24(sp)
    80004682:	6a42                	ld	s4,16(sp)
    80004684:	6aa2                	ld	s5,8(sp)
    80004686:	6121                	addi	sp,sp,64
    80004688:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000468a:	85d6                	mv	a1,s5
    8000468c:	8552                	mv	a0,s4
    8000468e:	00000097          	auipc	ra,0x0
    80004692:	348080e7          	jalr	840(ra) # 800049d6 <pipeclose>
    80004696:	b7cd                	j	80004678 <fileclose+0xa8>

0000000080004698 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004698:	715d                	addi	sp,sp,-80
    8000469a:	e486                	sd	ra,72(sp)
    8000469c:	e0a2                	sd	s0,64(sp)
    8000469e:	fc26                	sd	s1,56(sp)
    800046a0:	f84a                	sd	s2,48(sp)
    800046a2:	f44e                	sd	s3,40(sp)
    800046a4:	0880                	addi	s0,sp,80
    800046a6:	84aa                	mv	s1,a0
    800046a8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046aa:	ffffd097          	auipc	ra,0xffffd
    800046ae:	30c080e7          	jalr	780(ra) # 800019b6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046b2:	409c                	lw	a5,0(s1)
    800046b4:	37f9                	addiw	a5,a5,-2
    800046b6:	4705                	li	a4,1
    800046b8:	04f76763          	bltu	a4,a5,80004706 <filestat+0x6e>
    800046bc:	892a                	mv	s2,a0
    ilock(f->ip);
    800046be:	6c88                	ld	a0,24(s1)
    800046c0:	fffff097          	auipc	ra,0xfffff
    800046c4:	0a6080e7          	jalr	166(ra) # 80003766 <ilock>
    stati(f->ip, &st);
    800046c8:	fb840593          	addi	a1,s0,-72
    800046cc:	6c88                	ld	a0,24(s1)
    800046ce:	fffff097          	auipc	ra,0xfffff
    800046d2:	322080e7          	jalr	802(ra) # 800039f0 <stati>
    iunlock(f->ip);
    800046d6:	6c88                	ld	a0,24(s1)
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	150080e7          	jalr	336(ra) # 80003828 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046e0:	46e1                	li	a3,24
    800046e2:	fb840613          	addi	a2,s0,-72
    800046e6:	85ce                	mv	a1,s3
    800046e8:	05093503          	ld	a0,80(s2)
    800046ec:	ffffd097          	auipc	ra,0xffffd
    800046f0:	f8a080e7          	jalr	-118(ra) # 80001676 <copyout>
    800046f4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046f8:	60a6                	ld	ra,72(sp)
    800046fa:	6406                	ld	s0,64(sp)
    800046fc:	74e2                	ld	s1,56(sp)
    800046fe:	7942                	ld	s2,48(sp)
    80004700:	79a2                	ld	s3,40(sp)
    80004702:	6161                	addi	sp,sp,80
    80004704:	8082                	ret
  return -1;
    80004706:	557d                	li	a0,-1
    80004708:	bfc5                	j	800046f8 <filestat+0x60>

000000008000470a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000470a:	7179                	addi	sp,sp,-48
    8000470c:	f406                	sd	ra,40(sp)
    8000470e:	f022                	sd	s0,32(sp)
    80004710:	ec26                	sd	s1,24(sp)
    80004712:	e84a                	sd	s2,16(sp)
    80004714:	e44e                	sd	s3,8(sp)
    80004716:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004718:	00854783          	lbu	a5,8(a0)
    8000471c:	c3d5                	beqz	a5,800047c0 <fileread+0xb6>
    8000471e:	84aa                	mv	s1,a0
    80004720:	89ae                	mv	s3,a1
    80004722:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004724:	411c                	lw	a5,0(a0)
    80004726:	4705                	li	a4,1
    80004728:	04e78963          	beq	a5,a4,8000477a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000472c:	470d                	li	a4,3
    8000472e:	04e78d63          	beq	a5,a4,80004788 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004732:	4709                	li	a4,2
    80004734:	06e79e63          	bne	a5,a4,800047b0 <fileread+0xa6>
    ilock(f->ip);
    80004738:	6d08                	ld	a0,24(a0)
    8000473a:	fffff097          	auipc	ra,0xfffff
    8000473e:	02c080e7          	jalr	44(ra) # 80003766 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004742:	874a                	mv	a4,s2
    80004744:	5094                	lw	a3,32(s1)
    80004746:	864e                	mv	a2,s3
    80004748:	4585                	li	a1,1
    8000474a:	6c88                	ld	a0,24(s1)
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	2ce080e7          	jalr	718(ra) # 80003a1a <readi>
    80004754:	892a                	mv	s2,a0
    80004756:	00a05563          	blez	a0,80004760 <fileread+0x56>
      f->off += r;
    8000475a:	509c                	lw	a5,32(s1)
    8000475c:	9fa9                	addw	a5,a5,a0
    8000475e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004760:	6c88                	ld	a0,24(s1)
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	0c6080e7          	jalr	198(ra) # 80003828 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000476a:	854a                	mv	a0,s2
    8000476c:	70a2                	ld	ra,40(sp)
    8000476e:	7402                	ld	s0,32(sp)
    80004770:	64e2                	ld	s1,24(sp)
    80004772:	6942                	ld	s2,16(sp)
    80004774:	69a2                	ld	s3,8(sp)
    80004776:	6145                	addi	sp,sp,48
    80004778:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000477a:	6908                	ld	a0,16(a0)
    8000477c:	00000097          	auipc	ra,0x0
    80004780:	3c2080e7          	jalr	962(ra) # 80004b3e <piperead>
    80004784:	892a                	mv	s2,a0
    80004786:	b7d5                	j	8000476a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004788:	02451783          	lh	a5,36(a0)
    8000478c:	03079693          	slli	a3,a5,0x30
    80004790:	92c1                	srli	a3,a3,0x30
    80004792:	4725                	li	a4,9
    80004794:	02d76863          	bltu	a4,a3,800047c4 <fileread+0xba>
    80004798:	0792                	slli	a5,a5,0x4
    8000479a:	0001d717          	auipc	a4,0x1d
    8000479e:	8ae70713          	addi	a4,a4,-1874 # 80021048 <devsw>
    800047a2:	97ba                	add	a5,a5,a4
    800047a4:	639c                	ld	a5,0(a5)
    800047a6:	c38d                	beqz	a5,800047c8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047a8:	4505                	li	a0,1
    800047aa:	9782                	jalr	a5
    800047ac:	892a                	mv	s2,a0
    800047ae:	bf75                	j	8000476a <fileread+0x60>
    panic("fileread");
    800047b0:	00004517          	auipc	a0,0x4
    800047b4:	00850513          	addi	a0,a0,8 # 800087b8 <syscalls+0x260>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	d84080e7          	jalr	-636(ra) # 8000053c <panic>
    return -1;
    800047c0:	597d                	li	s2,-1
    800047c2:	b765                	j	8000476a <fileread+0x60>
      return -1;
    800047c4:	597d                	li	s2,-1
    800047c6:	b755                	j	8000476a <fileread+0x60>
    800047c8:	597d                	li	s2,-1
    800047ca:	b745                	j	8000476a <fileread+0x60>

00000000800047cc <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047cc:	00954783          	lbu	a5,9(a0)
    800047d0:	10078e63          	beqz	a5,800048ec <filewrite+0x120>
{
    800047d4:	715d                	addi	sp,sp,-80
    800047d6:	e486                	sd	ra,72(sp)
    800047d8:	e0a2                	sd	s0,64(sp)
    800047da:	fc26                	sd	s1,56(sp)
    800047dc:	f84a                	sd	s2,48(sp)
    800047de:	f44e                	sd	s3,40(sp)
    800047e0:	f052                	sd	s4,32(sp)
    800047e2:	ec56                	sd	s5,24(sp)
    800047e4:	e85a                	sd	s6,16(sp)
    800047e6:	e45e                	sd	s7,8(sp)
    800047e8:	e062                	sd	s8,0(sp)
    800047ea:	0880                	addi	s0,sp,80
    800047ec:	892a                	mv	s2,a0
    800047ee:	8b2e                	mv	s6,a1
    800047f0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047f2:	411c                	lw	a5,0(a0)
    800047f4:	4705                	li	a4,1
    800047f6:	02e78263          	beq	a5,a4,8000481a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047fa:	470d                	li	a4,3
    800047fc:	02e78563          	beq	a5,a4,80004826 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004800:	4709                	li	a4,2
    80004802:	0ce79d63          	bne	a5,a4,800048dc <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004806:	0ac05b63          	blez	a2,800048bc <filewrite+0xf0>
    int i = 0;
    8000480a:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000480c:	6b85                	lui	s7,0x1
    8000480e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004812:	6c05                	lui	s8,0x1
    80004814:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004818:	a851                	j	800048ac <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000481a:	6908                	ld	a0,16(a0)
    8000481c:	00000097          	auipc	ra,0x0
    80004820:	22a080e7          	jalr	554(ra) # 80004a46 <pipewrite>
    80004824:	a045                	j	800048c4 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004826:	02451783          	lh	a5,36(a0)
    8000482a:	03079693          	slli	a3,a5,0x30
    8000482e:	92c1                	srli	a3,a3,0x30
    80004830:	4725                	li	a4,9
    80004832:	0ad76f63          	bltu	a4,a3,800048f0 <filewrite+0x124>
    80004836:	0792                	slli	a5,a5,0x4
    80004838:	0001d717          	auipc	a4,0x1d
    8000483c:	81070713          	addi	a4,a4,-2032 # 80021048 <devsw>
    80004840:	97ba                	add	a5,a5,a4
    80004842:	679c                	ld	a5,8(a5)
    80004844:	cbc5                	beqz	a5,800048f4 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004846:	4505                	li	a0,1
    80004848:	9782                	jalr	a5
    8000484a:	a8ad                	j	800048c4 <filewrite+0xf8>
      if(n1 > max)
    8000484c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004850:	00000097          	auipc	ra,0x0
    80004854:	8bc080e7          	jalr	-1860(ra) # 8000410c <begin_op>
      ilock(f->ip);
    80004858:	01893503          	ld	a0,24(s2)
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	f0a080e7          	jalr	-246(ra) # 80003766 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004864:	8756                	mv	a4,s5
    80004866:	02092683          	lw	a3,32(s2)
    8000486a:	01698633          	add	a2,s3,s6
    8000486e:	4585                	li	a1,1
    80004870:	01893503          	ld	a0,24(s2)
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	29e080e7          	jalr	670(ra) # 80003b12 <writei>
    8000487c:	84aa                	mv	s1,a0
    8000487e:	00a05763          	blez	a0,8000488c <filewrite+0xc0>
        f->off += r;
    80004882:	02092783          	lw	a5,32(s2)
    80004886:	9fa9                	addw	a5,a5,a0
    80004888:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000488c:	01893503          	ld	a0,24(s2)
    80004890:	fffff097          	auipc	ra,0xfffff
    80004894:	f98080e7          	jalr	-104(ra) # 80003828 <iunlock>
      end_op();
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	8ee080e7          	jalr	-1810(ra) # 80004186 <end_op>

      if(r != n1){
    800048a0:	009a9f63          	bne	s5,s1,800048be <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800048a4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048a8:	0149db63          	bge	s3,s4,800048be <filewrite+0xf2>
      int n1 = n - i;
    800048ac:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048b0:	0004879b          	sext.w	a5,s1
    800048b4:	f8fbdce3          	bge	s7,a5,8000484c <filewrite+0x80>
    800048b8:	84e2                	mv	s1,s8
    800048ba:	bf49                	j	8000484c <filewrite+0x80>
    int i = 0;
    800048bc:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048be:	033a1d63          	bne	s4,s3,800048f8 <filewrite+0x12c>
    800048c2:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048c4:	60a6                	ld	ra,72(sp)
    800048c6:	6406                	ld	s0,64(sp)
    800048c8:	74e2                	ld	s1,56(sp)
    800048ca:	7942                	ld	s2,48(sp)
    800048cc:	79a2                	ld	s3,40(sp)
    800048ce:	7a02                	ld	s4,32(sp)
    800048d0:	6ae2                	ld	s5,24(sp)
    800048d2:	6b42                	ld	s6,16(sp)
    800048d4:	6ba2                	ld	s7,8(sp)
    800048d6:	6c02                	ld	s8,0(sp)
    800048d8:	6161                	addi	sp,sp,80
    800048da:	8082                	ret
    panic("filewrite");
    800048dc:	00004517          	auipc	a0,0x4
    800048e0:	eec50513          	addi	a0,a0,-276 # 800087c8 <syscalls+0x270>
    800048e4:	ffffc097          	auipc	ra,0xffffc
    800048e8:	c58080e7          	jalr	-936(ra) # 8000053c <panic>
    return -1;
    800048ec:	557d                	li	a0,-1
}
    800048ee:	8082                	ret
      return -1;
    800048f0:	557d                	li	a0,-1
    800048f2:	bfc9                	j	800048c4 <filewrite+0xf8>
    800048f4:	557d                	li	a0,-1
    800048f6:	b7f9                	j	800048c4 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    800048f8:	557d                	li	a0,-1
    800048fa:	b7e9                	j	800048c4 <filewrite+0xf8>

00000000800048fc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048fc:	7179                	addi	sp,sp,-48
    800048fe:	f406                	sd	ra,40(sp)
    80004900:	f022                	sd	s0,32(sp)
    80004902:	ec26                	sd	s1,24(sp)
    80004904:	e84a                	sd	s2,16(sp)
    80004906:	e44e                	sd	s3,8(sp)
    80004908:	e052                	sd	s4,0(sp)
    8000490a:	1800                	addi	s0,sp,48
    8000490c:	84aa                	mv	s1,a0
    8000490e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004910:	0005b023          	sd	zero,0(a1)
    80004914:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004918:	00000097          	auipc	ra,0x0
    8000491c:	bfc080e7          	jalr	-1028(ra) # 80004514 <filealloc>
    80004920:	e088                	sd	a0,0(s1)
    80004922:	c551                	beqz	a0,800049ae <pipealloc+0xb2>
    80004924:	00000097          	auipc	ra,0x0
    80004928:	bf0080e7          	jalr	-1040(ra) # 80004514 <filealloc>
    8000492c:	00aa3023          	sd	a0,0(s4)
    80004930:	c92d                	beqz	a0,800049a2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	1b0080e7          	jalr	432(ra) # 80000ae2 <kalloc>
    8000493a:	892a                	mv	s2,a0
    8000493c:	c125                	beqz	a0,8000499c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000493e:	4985                	li	s3,1
    80004940:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004944:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004948:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000494c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004950:	00004597          	auipc	a1,0x4
    80004954:	b6058593          	addi	a1,a1,-1184 # 800084b0 <states.0+0x1c0>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	1ea080e7          	jalr	490(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004960:	609c                	ld	a5,0(s1)
    80004962:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004966:	609c                	ld	a5,0(s1)
    80004968:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000496c:	609c                	ld	a5,0(s1)
    8000496e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004972:	609c                	ld	a5,0(s1)
    80004974:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004978:	000a3783          	ld	a5,0(s4)
    8000497c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004980:	000a3783          	ld	a5,0(s4)
    80004984:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004988:	000a3783          	ld	a5,0(s4)
    8000498c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004990:	000a3783          	ld	a5,0(s4)
    80004994:	0127b823          	sd	s2,16(a5)
  return 0;
    80004998:	4501                	li	a0,0
    8000499a:	a025                	j	800049c2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000499c:	6088                	ld	a0,0(s1)
    8000499e:	e501                	bnez	a0,800049a6 <pipealloc+0xaa>
    800049a0:	a039                	j	800049ae <pipealloc+0xb2>
    800049a2:	6088                	ld	a0,0(s1)
    800049a4:	c51d                	beqz	a0,800049d2 <pipealloc+0xd6>
    fileclose(*f0);
    800049a6:	00000097          	auipc	ra,0x0
    800049aa:	c2a080e7          	jalr	-982(ra) # 800045d0 <fileclose>
  if(*f1)
    800049ae:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049b2:	557d                	li	a0,-1
  if(*f1)
    800049b4:	c799                	beqz	a5,800049c2 <pipealloc+0xc6>
    fileclose(*f1);
    800049b6:	853e                	mv	a0,a5
    800049b8:	00000097          	auipc	ra,0x0
    800049bc:	c18080e7          	jalr	-1000(ra) # 800045d0 <fileclose>
  return -1;
    800049c0:	557d                	li	a0,-1
}
    800049c2:	70a2                	ld	ra,40(sp)
    800049c4:	7402                	ld	s0,32(sp)
    800049c6:	64e2                	ld	s1,24(sp)
    800049c8:	6942                	ld	s2,16(sp)
    800049ca:	69a2                	ld	s3,8(sp)
    800049cc:	6a02                	ld	s4,0(sp)
    800049ce:	6145                	addi	sp,sp,48
    800049d0:	8082                	ret
  return -1;
    800049d2:	557d                	li	a0,-1
    800049d4:	b7fd                	j	800049c2 <pipealloc+0xc6>

00000000800049d6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049d6:	1101                	addi	sp,sp,-32
    800049d8:	ec06                	sd	ra,24(sp)
    800049da:	e822                	sd	s0,16(sp)
    800049dc:	e426                	sd	s1,8(sp)
    800049de:	e04a                	sd	s2,0(sp)
    800049e0:	1000                	addi	s0,sp,32
    800049e2:	84aa                	mv	s1,a0
    800049e4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	1ec080e7          	jalr	492(ra) # 80000bd2 <acquire>
  if(writable){
    800049ee:	02090d63          	beqz	s2,80004a28 <pipeclose+0x52>
    pi->writeopen = 0;
    800049f2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049f6:	21848513          	addi	a0,s1,536
    800049fa:	ffffd097          	auipc	ra,0xffffd
    800049fe:	6d4080e7          	jalr	1748(ra) # 800020ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a02:	2204b783          	ld	a5,544(s1)
    80004a06:	eb95                	bnez	a5,80004a3a <pipeclose+0x64>
    release(&pi->lock);
    80004a08:	8526                	mv	a0,s1
    80004a0a:	ffffc097          	auipc	ra,0xffffc
    80004a0e:	27c080e7          	jalr	636(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004a12:	8526                	mv	a0,s1
    80004a14:	ffffc097          	auipc	ra,0xffffc
    80004a18:	fd0080e7          	jalr	-48(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004a1c:	60e2                	ld	ra,24(sp)
    80004a1e:	6442                	ld	s0,16(sp)
    80004a20:	64a2                	ld	s1,8(sp)
    80004a22:	6902                	ld	s2,0(sp)
    80004a24:	6105                	addi	sp,sp,32
    80004a26:	8082                	ret
    pi->readopen = 0;
    80004a28:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a2c:	21c48513          	addi	a0,s1,540
    80004a30:	ffffd097          	auipc	ra,0xffffd
    80004a34:	69e080e7          	jalr	1694(ra) # 800020ce <wakeup>
    80004a38:	b7e9                	j	80004a02 <pipeclose+0x2c>
    release(&pi->lock);
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	24a080e7          	jalr	586(ra) # 80000c86 <release>
}
    80004a44:	bfe1                	j	80004a1c <pipeclose+0x46>

0000000080004a46 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a46:	711d                	addi	sp,sp,-96
    80004a48:	ec86                	sd	ra,88(sp)
    80004a4a:	e8a2                	sd	s0,80(sp)
    80004a4c:	e4a6                	sd	s1,72(sp)
    80004a4e:	e0ca                	sd	s2,64(sp)
    80004a50:	fc4e                	sd	s3,56(sp)
    80004a52:	f852                	sd	s4,48(sp)
    80004a54:	f456                	sd	s5,40(sp)
    80004a56:	f05a                	sd	s6,32(sp)
    80004a58:	ec5e                	sd	s7,24(sp)
    80004a5a:	e862                	sd	s8,16(sp)
    80004a5c:	1080                	addi	s0,sp,96
    80004a5e:	84aa                	mv	s1,a0
    80004a60:	8aae                	mv	s5,a1
    80004a62:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a64:	ffffd097          	auipc	ra,0xffffd
    80004a68:	f52080e7          	jalr	-174(ra) # 800019b6 <myproc>
    80004a6c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a6e:	8526                	mv	a0,s1
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	162080e7          	jalr	354(ra) # 80000bd2 <acquire>
  while(i < n){
    80004a78:	0b405663          	blez	s4,80004b24 <pipewrite+0xde>
  int i = 0;
    80004a7c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a7e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a80:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a84:	21c48b93          	addi	s7,s1,540
    80004a88:	a089                	j	80004aca <pipewrite+0x84>
      release(&pi->lock);
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	1fa080e7          	jalr	506(ra) # 80000c86 <release>
      return -1;
    80004a94:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a96:	854a                	mv	a0,s2
    80004a98:	60e6                	ld	ra,88(sp)
    80004a9a:	6446                	ld	s0,80(sp)
    80004a9c:	64a6                	ld	s1,72(sp)
    80004a9e:	6906                	ld	s2,64(sp)
    80004aa0:	79e2                	ld	s3,56(sp)
    80004aa2:	7a42                	ld	s4,48(sp)
    80004aa4:	7aa2                	ld	s5,40(sp)
    80004aa6:	7b02                	ld	s6,32(sp)
    80004aa8:	6be2                	ld	s7,24(sp)
    80004aaa:	6c42                	ld	s8,16(sp)
    80004aac:	6125                	addi	sp,sp,96
    80004aae:	8082                	ret
      wakeup(&pi->nread);
    80004ab0:	8562                	mv	a0,s8
    80004ab2:	ffffd097          	auipc	ra,0xffffd
    80004ab6:	61c080e7          	jalr	1564(ra) # 800020ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004aba:	85a6                	mv	a1,s1
    80004abc:	855e                	mv	a0,s7
    80004abe:	ffffd097          	auipc	ra,0xffffd
    80004ac2:	5ac080e7          	jalr	1452(ra) # 8000206a <sleep>
  while(i < n){
    80004ac6:	07495063          	bge	s2,s4,80004b26 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004aca:	2204a783          	lw	a5,544(s1)
    80004ace:	dfd5                	beqz	a5,80004a8a <pipewrite+0x44>
    80004ad0:	854e                	mv	a0,s3
    80004ad2:	ffffe097          	auipc	ra,0xffffe
    80004ad6:	840080e7          	jalr	-1984(ra) # 80002312 <killed>
    80004ada:	f945                	bnez	a0,80004a8a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004adc:	2184a783          	lw	a5,536(s1)
    80004ae0:	21c4a703          	lw	a4,540(s1)
    80004ae4:	2007879b          	addiw	a5,a5,512
    80004ae8:	fcf704e3          	beq	a4,a5,80004ab0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aec:	4685                	li	a3,1
    80004aee:	01590633          	add	a2,s2,s5
    80004af2:	faf40593          	addi	a1,s0,-81
    80004af6:	0509b503          	ld	a0,80(s3)
    80004afa:	ffffd097          	auipc	ra,0xffffd
    80004afe:	c08080e7          	jalr	-1016(ra) # 80001702 <copyin>
    80004b02:	03650263          	beq	a0,s6,80004b26 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b06:	21c4a783          	lw	a5,540(s1)
    80004b0a:	0017871b          	addiw	a4,a5,1
    80004b0e:	20e4ae23          	sw	a4,540(s1)
    80004b12:	1ff7f793          	andi	a5,a5,511
    80004b16:	97a6                	add	a5,a5,s1
    80004b18:	faf44703          	lbu	a4,-81(s0)
    80004b1c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b20:	2905                	addiw	s2,s2,1
    80004b22:	b755                	j	80004ac6 <pipewrite+0x80>
  int i = 0;
    80004b24:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b26:	21848513          	addi	a0,s1,536
    80004b2a:	ffffd097          	auipc	ra,0xffffd
    80004b2e:	5a4080e7          	jalr	1444(ra) # 800020ce <wakeup>
  release(&pi->lock);
    80004b32:	8526                	mv	a0,s1
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	152080e7          	jalr	338(ra) # 80000c86 <release>
  return i;
    80004b3c:	bfa9                	j	80004a96 <pipewrite+0x50>

0000000080004b3e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b3e:	715d                	addi	sp,sp,-80
    80004b40:	e486                	sd	ra,72(sp)
    80004b42:	e0a2                	sd	s0,64(sp)
    80004b44:	fc26                	sd	s1,56(sp)
    80004b46:	f84a                	sd	s2,48(sp)
    80004b48:	f44e                	sd	s3,40(sp)
    80004b4a:	f052                	sd	s4,32(sp)
    80004b4c:	ec56                	sd	s5,24(sp)
    80004b4e:	e85a                	sd	s6,16(sp)
    80004b50:	0880                	addi	s0,sp,80
    80004b52:	84aa                	mv	s1,a0
    80004b54:	892e                	mv	s2,a1
    80004b56:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b58:	ffffd097          	auipc	ra,0xffffd
    80004b5c:	e5e080e7          	jalr	-418(ra) # 800019b6 <myproc>
    80004b60:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b62:	8526                	mv	a0,s1
    80004b64:	ffffc097          	auipc	ra,0xffffc
    80004b68:	06e080e7          	jalr	110(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b6c:	2184a703          	lw	a4,536(s1)
    80004b70:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b74:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b78:	02f71763          	bne	a4,a5,80004ba6 <piperead+0x68>
    80004b7c:	2244a783          	lw	a5,548(s1)
    80004b80:	c39d                	beqz	a5,80004ba6 <piperead+0x68>
    if(killed(pr)){
    80004b82:	8552                	mv	a0,s4
    80004b84:	ffffd097          	auipc	ra,0xffffd
    80004b88:	78e080e7          	jalr	1934(ra) # 80002312 <killed>
    80004b8c:	e949                	bnez	a0,80004c1e <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b8e:	85a6                	mv	a1,s1
    80004b90:	854e                	mv	a0,s3
    80004b92:	ffffd097          	auipc	ra,0xffffd
    80004b96:	4d8080e7          	jalr	1240(ra) # 8000206a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b9a:	2184a703          	lw	a4,536(s1)
    80004b9e:	21c4a783          	lw	a5,540(s1)
    80004ba2:	fcf70de3          	beq	a4,a5,80004b7c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ba6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ba8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004baa:	05505463          	blez	s5,80004bf2 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004bae:	2184a783          	lw	a5,536(s1)
    80004bb2:	21c4a703          	lw	a4,540(s1)
    80004bb6:	02f70e63          	beq	a4,a5,80004bf2 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bba:	0017871b          	addiw	a4,a5,1
    80004bbe:	20e4ac23          	sw	a4,536(s1)
    80004bc2:	1ff7f793          	andi	a5,a5,511
    80004bc6:	97a6                	add	a5,a5,s1
    80004bc8:	0187c783          	lbu	a5,24(a5)
    80004bcc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bd0:	4685                	li	a3,1
    80004bd2:	fbf40613          	addi	a2,s0,-65
    80004bd6:	85ca                	mv	a1,s2
    80004bd8:	050a3503          	ld	a0,80(s4)
    80004bdc:	ffffd097          	auipc	ra,0xffffd
    80004be0:	a9a080e7          	jalr	-1382(ra) # 80001676 <copyout>
    80004be4:	01650763          	beq	a0,s6,80004bf2 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004be8:	2985                	addiw	s3,s3,1
    80004bea:	0905                	addi	s2,s2,1
    80004bec:	fd3a91e3          	bne	s5,s3,80004bae <piperead+0x70>
    80004bf0:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bf2:	21c48513          	addi	a0,s1,540
    80004bf6:	ffffd097          	auipc	ra,0xffffd
    80004bfa:	4d8080e7          	jalr	1240(ra) # 800020ce <wakeup>
  release(&pi->lock);
    80004bfe:	8526                	mv	a0,s1
    80004c00:	ffffc097          	auipc	ra,0xffffc
    80004c04:	086080e7          	jalr	134(ra) # 80000c86 <release>
  return i;
}
    80004c08:	854e                	mv	a0,s3
    80004c0a:	60a6                	ld	ra,72(sp)
    80004c0c:	6406                	ld	s0,64(sp)
    80004c0e:	74e2                	ld	s1,56(sp)
    80004c10:	7942                	ld	s2,48(sp)
    80004c12:	79a2                	ld	s3,40(sp)
    80004c14:	7a02                	ld	s4,32(sp)
    80004c16:	6ae2                	ld	s5,24(sp)
    80004c18:	6b42                	ld	s6,16(sp)
    80004c1a:	6161                	addi	sp,sp,80
    80004c1c:	8082                	ret
      release(&pi->lock);
    80004c1e:	8526                	mv	a0,s1
    80004c20:	ffffc097          	auipc	ra,0xffffc
    80004c24:	066080e7          	jalr	102(ra) # 80000c86 <release>
      return -1;
    80004c28:	59fd                	li	s3,-1
    80004c2a:	bff9                	j	80004c08 <piperead+0xca>

0000000080004c2c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c2c:	1141                	addi	sp,sp,-16
    80004c2e:	e422                	sd	s0,8(sp)
    80004c30:	0800                	addi	s0,sp,16
    80004c32:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c34:	8905                	andi	a0,a0,1
    80004c36:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c38:	8b89                	andi	a5,a5,2
    80004c3a:	c399                	beqz	a5,80004c40 <flags2perm+0x14>
      perm |= PTE_W;
    80004c3c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c40:	6422                	ld	s0,8(sp)
    80004c42:	0141                	addi	sp,sp,16
    80004c44:	8082                	ret

0000000080004c46 <exec>:

int
exec(char *path, char **argv)
{
    80004c46:	df010113          	addi	sp,sp,-528
    80004c4a:	20113423          	sd	ra,520(sp)
    80004c4e:	20813023          	sd	s0,512(sp)
    80004c52:	ffa6                	sd	s1,504(sp)
    80004c54:	fbca                	sd	s2,496(sp)
    80004c56:	f7ce                	sd	s3,488(sp)
    80004c58:	f3d2                	sd	s4,480(sp)
    80004c5a:	efd6                	sd	s5,472(sp)
    80004c5c:	ebda                	sd	s6,464(sp)
    80004c5e:	e7de                	sd	s7,456(sp)
    80004c60:	e3e2                	sd	s8,448(sp)
    80004c62:	ff66                	sd	s9,440(sp)
    80004c64:	fb6a                	sd	s10,432(sp)
    80004c66:	f76e                	sd	s11,424(sp)
    80004c68:	0c00                	addi	s0,sp,528
    80004c6a:	892a                	mv	s2,a0
    80004c6c:	dea43c23          	sd	a0,-520(s0)
    80004c70:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c74:	ffffd097          	auipc	ra,0xffffd
    80004c78:	d42080e7          	jalr	-702(ra) # 800019b6 <myproc>
    80004c7c:	84aa                	mv	s1,a0

  begin_op();
    80004c7e:	fffff097          	auipc	ra,0xfffff
    80004c82:	48e080e7          	jalr	1166(ra) # 8000410c <begin_op>

  if((ip = namei(path)) == 0){
    80004c86:	854a                	mv	a0,s2
    80004c88:	fffff097          	auipc	ra,0xfffff
    80004c8c:	284080e7          	jalr	644(ra) # 80003f0c <namei>
    80004c90:	c92d                	beqz	a0,80004d02 <exec+0xbc>
    80004c92:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c94:	fffff097          	auipc	ra,0xfffff
    80004c98:	ad2080e7          	jalr	-1326(ra) # 80003766 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c9c:	04000713          	li	a4,64
    80004ca0:	4681                	li	a3,0
    80004ca2:	e5040613          	addi	a2,s0,-432
    80004ca6:	4581                	li	a1,0
    80004ca8:	8552                	mv	a0,s4
    80004caa:	fffff097          	auipc	ra,0xfffff
    80004cae:	d70080e7          	jalr	-656(ra) # 80003a1a <readi>
    80004cb2:	04000793          	li	a5,64
    80004cb6:	00f51a63          	bne	a0,a5,80004cca <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004cba:	e5042703          	lw	a4,-432(s0)
    80004cbe:	464c47b7          	lui	a5,0x464c4
    80004cc2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cc6:	04f70463          	beq	a4,a5,80004d0e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cca:	8552                	mv	a0,s4
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	cfc080e7          	jalr	-772(ra) # 800039c8 <iunlockput>
    end_op();
    80004cd4:	fffff097          	auipc	ra,0xfffff
    80004cd8:	4b2080e7          	jalr	1202(ra) # 80004186 <end_op>
  }
  return -1;
    80004cdc:	557d                	li	a0,-1
}
    80004cde:	20813083          	ld	ra,520(sp)
    80004ce2:	20013403          	ld	s0,512(sp)
    80004ce6:	74fe                	ld	s1,504(sp)
    80004ce8:	795e                	ld	s2,496(sp)
    80004cea:	79be                	ld	s3,488(sp)
    80004cec:	7a1e                	ld	s4,480(sp)
    80004cee:	6afe                	ld	s5,472(sp)
    80004cf0:	6b5e                	ld	s6,464(sp)
    80004cf2:	6bbe                	ld	s7,456(sp)
    80004cf4:	6c1e                	ld	s8,448(sp)
    80004cf6:	7cfa                	ld	s9,440(sp)
    80004cf8:	7d5a                	ld	s10,432(sp)
    80004cfa:	7dba                	ld	s11,424(sp)
    80004cfc:	21010113          	addi	sp,sp,528
    80004d00:	8082                	ret
    end_op();
    80004d02:	fffff097          	auipc	ra,0xfffff
    80004d06:	484080e7          	jalr	1156(ra) # 80004186 <end_op>
    return -1;
    80004d0a:	557d                	li	a0,-1
    80004d0c:	bfc9                	j	80004cde <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d0e:	8526                	mv	a0,s1
    80004d10:	ffffd097          	auipc	ra,0xffffd
    80004d14:	d6a080e7          	jalr	-662(ra) # 80001a7a <proc_pagetable>
    80004d18:	8b2a                	mv	s6,a0
    80004d1a:	d945                	beqz	a0,80004cca <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d1c:	e7042d03          	lw	s10,-400(s0)
    80004d20:	e8845783          	lhu	a5,-376(s0)
    80004d24:	10078463          	beqz	a5,80004e2c <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d28:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d2a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d2c:	6c85                	lui	s9,0x1
    80004d2e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d32:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d36:	6a85                	lui	s5,0x1
    80004d38:	a0b5                	j	80004da4 <exec+0x15e>
      panic("loadseg: address should exist");
    80004d3a:	00004517          	auipc	a0,0x4
    80004d3e:	a9e50513          	addi	a0,a0,-1378 # 800087d8 <syscalls+0x280>
    80004d42:	ffffb097          	auipc	ra,0xffffb
    80004d46:	7fa080e7          	jalr	2042(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004d4a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d4c:	8726                	mv	a4,s1
    80004d4e:	012c06bb          	addw	a3,s8,s2
    80004d52:	4581                	li	a1,0
    80004d54:	8552                	mv	a0,s4
    80004d56:	fffff097          	auipc	ra,0xfffff
    80004d5a:	cc4080e7          	jalr	-828(ra) # 80003a1a <readi>
    80004d5e:	2501                	sext.w	a0,a0
    80004d60:	24a49863          	bne	s1,a0,80004fb0 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004d64:	012a893b          	addw	s2,s5,s2
    80004d68:	03397563          	bgeu	s2,s3,80004d92 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004d6c:	02091593          	slli	a1,s2,0x20
    80004d70:	9181                	srli	a1,a1,0x20
    80004d72:	95de                	add	a1,a1,s7
    80004d74:	855a                	mv	a0,s6
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	2f0080e7          	jalr	752(ra) # 80001066 <walkaddr>
    80004d7e:	862a                	mv	a2,a0
    if(pa == 0)
    80004d80:	dd4d                	beqz	a0,80004d3a <exec+0xf4>
    if(sz - i < PGSIZE)
    80004d82:	412984bb          	subw	s1,s3,s2
    80004d86:	0004879b          	sext.w	a5,s1
    80004d8a:	fcfcf0e3          	bgeu	s9,a5,80004d4a <exec+0x104>
    80004d8e:	84d6                	mv	s1,s5
    80004d90:	bf6d                	j	80004d4a <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d92:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d96:	2d85                	addiw	s11,s11,1
    80004d98:	038d0d1b          	addiw	s10,s10,56
    80004d9c:	e8845783          	lhu	a5,-376(s0)
    80004da0:	08fdd763          	bge	s11,a5,80004e2e <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004da4:	2d01                	sext.w	s10,s10
    80004da6:	03800713          	li	a4,56
    80004daa:	86ea                	mv	a3,s10
    80004dac:	e1840613          	addi	a2,s0,-488
    80004db0:	4581                	li	a1,0
    80004db2:	8552                	mv	a0,s4
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	c66080e7          	jalr	-922(ra) # 80003a1a <readi>
    80004dbc:	03800793          	li	a5,56
    80004dc0:	1ef51663          	bne	a0,a5,80004fac <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004dc4:	e1842783          	lw	a5,-488(s0)
    80004dc8:	4705                	li	a4,1
    80004dca:	fce796e3          	bne	a5,a4,80004d96 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004dce:	e4043483          	ld	s1,-448(s0)
    80004dd2:	e3843783          	ld	a5,-456(s0)
    80004dd6:	1ef4e863          	bltu	s1,a5,80004fc6 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004dda:	e2843783          	ld	a5,-472(s0)
    80004dde:	94be                	add	s1,s1,a5
    80004de0:	1ef4e663          	bltu	s1,a5,80004fcc <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004de4:	df043703          	ld	a4,-528(s0)
    80004de8:	8ff9                	and	a5,a5,a4
    80004dea:	1e079463          	bnez	a5,80004fd2 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dee:	e1c42503          	lw	a0,-484(s0)
    80004df2:	00000097          	auipc	ra,0x0
    80004df6:	e3a080e7          	jalr	-454(ra) # 80004c2c <flags2perm>
    80004dfa:	86aa                	mv	a3,a0
    80004dfc:	8626                	mv	a2,s1
    80004dfe:	85ca                	mv	a1,s2
    80004e00:	855a                	mv	a0,s6
    80004e02:	ffffc097          	auipc	ra,0xffffc
    80004e06:	618080e7          	jalr	1560(ra) # 8000141a <uvmalloc>
    80004e0a:	e0a43423          	sd	a0,-504(s0)
    80004e0e:	1c050563          	beqz	a0,80004fd8 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e12:	e2843b83          	ld	s7,-472(s0)
    80004e16:	e2042c03          	lw	s8,-480(s0)
    80004e1a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e1e:	00098463          	beqz	s3,80004e26 <exec+0x1e0>
    80004e22:	4901                	li	s2,0
    80004e24:	b7a1                	j	80004d6c <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e26:	e0843903          	ld	s2,-504(s0)
    80004e2a:	b7b5                	j	80004d96 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e2c:	4901                	li	s2,0
  iunlockput(ip);
    80004e2e:	8552                	mv	a0,s4
    80004e30:	fffff097          	auipc	ra,0xfffff
    80004e34:	b98080e7          	jalr	-1128(ra) # 800039c8 <iunlockput>
  end_op();
    80004e38:	fffff097          	auipc	ra,0xfffff
    80004e3c:	34e080e7          	jalr	846(ra) # 80004186 <end_op>
  p = myproc();
    80004e40:	ffffd097          	auipc	ra,0xffffd
    80004e44:	b76080e7          	jalr	-1162(ra) # 800019b6 <myproc>
    80004e48:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e4a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e4e:	6985                	lui	s3,0x1
    80004e50:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e52:	99ca                	add	s3,s3,s2
    80004e54:	77fd                	lui	a5,0xfffff
    80004e56:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e5a:	4691                	li	a3,4
    80004e5c:	6609                	lui	a2,0x2
    80004e5e:	964e                	add	a2,a2,s3
    80004e60:	85ce                	mv	a1,s3
    80004e62:	855a                	mv	a0,s6
    80004e64:	ffffc097          	auipc	ra,0xffffc
    80004e68:	5b6080e7          	jalr	1462(ra) # 8000141a <uvmalloc>
    80004e6c:	892a                	mv	s2,a0
    80004e6e:	e0a43423          	sd	a0,-504(s0)
    80004e72:	e509                	bnez	a0,80004e7c <exec+0x236>
  if(pagetable)
    80004e74:	e1343423          	sd	s3,-504(s0)
    80004e78:	4a01                	li	s4,0
    80004e7a:	aa1d                	j	80004fb0 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e7c:	75f9                	lui	a1,0xffffe
    80004e7e:	95aa                	add	a1,a1,a0
    80004e80:	855a                	mv	a0,s6
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	7c2080e7          	jalr	1986(ra) # 80001644 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e8a:	7bfd                	lui	s7,0xfffff
    80004e8c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004e8e:	e0043783          	ld	a5,-512(s0)
    80004e92:	6388                	ld	a0,0(a5)
    80004e94:	c52d                	beqz	a0,80004efe <exec+0x2b8>
    80004e96:	e9040993          	addi	s3,s0,-368
    80004e9a:	f9040c13          	addi	s8,s0,-112
    80004e9e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ea0:	ffffc097          	auipc	ra,0xffffc
    80004ea4:	fa8080e7          	jalr	-88(ra) # 80000e48 <strlen>
    80004ea8:	0015079b          	addiw	a5,a0,1
    80004eac:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004eb0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004eb4:	13796563          	bltu	s2,s7,80004fde <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004eb8:	e0043d03          	ld	s10,-512(s0)
    80004ebc:	000d3a03          	ld	s4,0(s10)
    80004ec0:	8552                	mv	a0,s4
    80004ec2:	ffffc097          	auipc	ra,0xffffc
    80004ec6:	f86080e7          	jalr	-122(ra) # 80000e48 <strlen>
    80004eca:	0015069b          	addiw	a3,a0,1
    80004ece:	8652                	mv	a2,s4
    80004ed0:	85ca                	mv	a1,s2
    80004ed2:	855a                	mv	a0,s6
    80004ed4:	ffffc097          	auipc	ra,0xffffc
    80004ed8:	7a2080e7          	jalr	1954(ra) # 80001676 <copyout>
    80004edc:	10054363          	bltz	a0,80004fe2 <exec+0x39c>
    ustack[argc] = sp;
    80004ee0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ee4:	0485                	addi	s1,s1,1
    80004ee6:	008d0793          	addi	a5,s10,8
    80004eea:	e0f43023          	sd	a5,-512(s0)
    80004eee:	008d3503          	ld	a0,8(s10)
    80004ef2:	c909                	beqz	a0,80004f04 <exec+0x2be>
    if(argc >= MAXARG)
    80004ef4:	09a1                	addi	s3,s3,8
    80004ef6:	fb8995e3          	bne	s3,s8,80004ea0 <exec+0x25a>
  ip = 0;
    80004efa:	4a01                	li	s4,0
    80004efc:	a855                	j	80004fb0 <exec+0x36a>
  sp = sz;
    80004efe:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f02:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f04:	00349793          	slli	a5,s1,0x3
    80004f08:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdcdb0>
    80004f0c:	97a2                	add	a5,a5,s0
    80004f0e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f12:	00148693          	addi	a3,s1,1
    80004f16:	068e                	slli	a3,a3,0x3
    80004f18:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f1c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f20:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f24:	f57968e3          	bltu	s2,s7,80004e74 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f28:	e9040613          	addi	a2,s0,-368
    80004f2c:	85ca                	mv	a1,s2
    80004f2e:	855a                	mv	a0,s6
    80004f30:	ffffc097          	auipc	ra,0xffffc
    80004f34:	746080e7          	jalr	1862(ra) # 80001676 <copyout>
    80004f38:	0a054763          	bltz	a0,80004fe6 <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004f3c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f40:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f44:	df843783          	ld	a5,-520(s0)
    80004f48:	0007c703          	lbu	a4,0(a5)
    80004f4c:	cf11                	beqz	a4,80004f68 <exec+0x322>
    80004f4e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f50:	02f00693          	li	a3,47
    80004f54:	a039                	j	80004f62 <exec+0x31c>
      last = s+1;
    80004f56:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f5a:	0785                	addi	a5,a5,1
    80004f5c:	fff7c703          	lbu	a4,-1(a5)
    80004f60:	c701                	beqz	a4,80004f68 <exec+0x322>
    if(*s == '/')
    80004f62:	fed71ce3          	bne	a4,a3,80004f5a <exec+0x314>
    80004f66:	bfc5                	j	80004f56 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f68:	4641                	li	a2,16
    80004f6a:	df843583          	ld	a1,-520(s0)
    80004f6e:	158a8513          	addi	a0,s5,344
    80004f72:	ffffc097          	auipc	ra,0xffffc
    80004f76:	ea4080e7          	jalr	-348(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f7a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f7e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f82:	e0843783          	ld	a5,-504(s0)
    80004f86:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f8a:	058ab783          	ld	a5,88(s5)
    80004f8e:	e6843703          	ld	a4,-408(s0)
    80004f92:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f94:	058ab783          	ld	a5,88(s5)
    80004f98:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f9c:	85e6                	mv	a1,s9
    80004f9e:	ffffd097          	auipc	ra,0xffffd
    80004fa2:	b78080e7          	jalr	-1160(ra) # 80001b16 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fa6:	0004851b          	sext.w	a0,s1
    80004faa:	bb15                	j	80004cde <exec+0x98>
    80004fac:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004fb0:	e0843583          	ld	a1,-504(s0)
    80004fb4:	855a                	mv	a0,s6
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	b60080e7          	jalr	-1184(ra) # 80001b16 <proc_freepagetable>
  return -1;
    80004fbe:	557d                	li	a0,-1
  if(ip){
    80004fc0:	d00a0fe3          	beqz	s4,80004cde <exec+0x98>
    80004fc4:	b319                	j	80004cca <exec+0x84>
    80004fc6:	e1243423          	sd	s2,-504(s0)
    80004fca:	b7dd                	j	80004fb0 <exec+0x36a>
    80004fcc:	e1243423          	sd	s2,-504(s0)
    80004fd0:	b7c5                	j	80004fb0 <exec+0x36a>
    80004fd2:	e1243423          	sd	s2,-504(s0)
    80004fd6:	bfe9                	j	80004fb0 <exec+0x36a>
    80004fd8:	e1243423          	sd	s2,-504(s0)
    80004fdc:	bfd1                	j	80004fb0 <exec+0x36a>
  ip = 0;
    80004fde:	4a01                	li	s4,0
    80004fe0:	bfc1                	j	80004fb0 <exec+0x36a>
    80004fe2:	4a01                	li	s4,0
  if(pagetable)
    80004fe4:	b7f1                	j	80004fb0 <exec+0x36a>
  sz = sz1;
    80004fe6:	e0843983          	ld	s3,-504(s0)
    80004fea:	b569                	j	80004e74 <exec+0x22e>

0000000080004fec <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fec:	7179                	addi	sp,sp,-48
    80004fee:	f406                	sd	ra,40(sp)
    80004ff0:	f022                	sd	s0,32(sp)
    80004ff2:	ec26                	sd	s1,24(sp)
    80004ff4:	e84a                	sd	s2,16(sp)
    80004ff6:	1800                	addi	s0,sp,48
    80004ff8:	892e                	mv	s2,a1
    80004ffa:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ffc:	fdc40593          	addi	a1,s0,-36
    80005000:	ffffe097          	auipc	ra,0xffffe
    80005004:	adc080e7          	jalr	-1316(ra) # 80002adc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005008:	fdc42703          	lw	a4,-36(s0)
    8000500c:	47bd                	li	a5,15
    8000500e:	02e7eb63          	bltu	a5,a4,80005044 <argfd+0x58>
    80005012:	ffffd097          	auipc	ra,0xffffd
    80005016:	9a4080e7          	jalr	-1628(ra) # 800019b6 <myproc>
    8000501a:	fdc42703          	lw	a4,-36(s0)
    8000501e:	01a70793          	addi	a5,a4,26
    80005022:	078e                	slli	a5,a5,0x3
    80005024:	953e                	add	a0,a0,a5
    80005026:	611c                	ld	a5,0(a0)
    80005028:	c385                	beqz	a5,80005048 <argfd+0x5c>
    return -1;
  if(pfd)
    8000502a:	00090463          	beqz	s2,80005032 <argfd+0x46>
    *pfd = fd;
    8000502e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005032:	4501                	li	a0,0
  if(pf)
    80005034:	c091                	beqz	s1,80005038 <argfd+0x4c>
    *pf = f;
    80005036:	e09c                	sd	a5,0(s1)
}
    80005038:	70a2                	ld	ra,40(sp)
    8000503a:	7402                	ld	s0,32(sp)
    8000503c:	64e2                	ld	s1,24(sp)
    8000503e:	6942                	ld	s2,16(sp)
    80005040:	6145                	addi	sp,sp,48
    80005042:	8082                	ret
    return -1;
    80005044:	557d                	li	a0,-1
    80005046:	bfcd                	j	80005038 <argfd+0x4c>
    80005048:	557d                	li	a0,-1
    8000504a:	b7fd                	j	80005038 <argfd+0x4c>

000000008000504c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000504c:	1101                	addi	sp,sp,-32
    8000504e:	ec06                	sd	ra,24(sp)
    80005050:	e822                	sd	s0,16(sp)
    80005052:	e426                	sd	s1,8(sp)
    80005054:	1000                	addi	s0,sp,32
    80005056:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005058:	ffffd097          	auipc	ra,0xffffd
    8000505c:	95e080e7          	jalr	-1698(ra) # 800019b6 <myproc>
    80005060:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005062:	0d050793          	addi	a5,a0,208
    80005066:	4501                	li	a0,0
    80005068:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000506a:	6398                	ld	a4,0(a5)
    8000506c:	cb19                	beqz	a4,80005082 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000506e:	2505                	addiw	a0,a0,1
    80005070:	07a1                	addi	a5,a5,8
    80005072:	fed51ce3          	bne	a0,a3,8000506a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005076:	557d                	li	a0,-1
}
    80005078:	60e2                	ld	ra,24(sp)
    8000507a:	6442                	ld	s0,16(sp)
    8000507c:	64a2                	ld	s1,8(sp)
    8000507e:	6105                	addi	sp,sp,32
    80005080:	8082                	ret
      p->ofile[fd] = f;
    80005082:	01a50793          	addi	a5,a0,26
    80005086:	078e                	slli	a5,a5,0x3
    80005088:	963e                	add	a2,a2,a5
    8000508a:	e204                	sd	s1,0(a2)
      return fd;
    8000508c:	b7f5                	j	80005078 <fdalloc+0x2c>

000000008000508e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000508e:	715d                	addi	sp,sp,-80
    80005090:	e486                	sd	ra,72(sp)
    80005092:	e0a2                	sd	s0,64(sp)
    80005094:	fc26                	sd	s1,56(sp)
    80005096:	f84a                	sd	s2,48(sp)
    80005098:	f44e                	sd	s3,40(sp)
    8000509a:	f052                	sd	s4,32(sp)
    8000509c:	ec56                	sd	s5,24(sp)
    8000509e:	e85a                	sd	s6,16(sp)
    800050a0:	0880                	addi	s0,sp,80
    800050a2:	8b2e                	mv	s6,a1
    800050a4:	89b2                	mv	s3,a2
    800050a6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050a8:	fb040593          	addi	a1,s0,-80
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	e7e080e7          	jalr	-386(ra) # 80003f2a <nameiparent>
    800050b4:	84aa                	mv	s1,a0
    800050b6:	14050b63          	beqz	a0,8000520c <create+0x17e>
    return 0;

  ilock(dp);
    800050ba:	ffffe097          	auipc	ra,0xffffe
    800050be:	6ac080e7          	jalr	1708(ra) # 80003766 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050c2:	4601                	li	a2,0
    800050c4:	fb040593          	addi	a1,s0,-80
    800050c8:	8526                	mv	a0,s1
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	b80080e7          	jalr	-1152(ra) # 80003c4a <dirlookup>
    800050d2:	8aaa                	mv	s5,a0
    800050d4:	c921                	beqz	a0,80005124 <create+0x96>
    iunlockput(dp);
    800050d6:	8526                	mv	a0,s1
    800050d8:	fffff097          	auipc	ra,0xfffff
    800050dc:	8f0080e7          	jalr	-1808(ra) # 800039c8 <iunlockput>
    ilock(ip);
    800050e0:	8556                	mv	a0,s5
    800050e2:	ffffe097          	auipc	ra,0xffffe
    800050e6:	684080e7          	jalr	1668(ra) # 80003766 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050ea:	4789                	li	a5,2
    800050ec:	02fb1563          	bne	s6,a5,80005116 <create+0x88>
    800050f0:	044ad783          	lhu	a5,68(s5)
    800050f4:	37f9                	addiw	a5,a5,-2
    800050f6:	17c2                	slli	a5,a5,0x30
    800050f8:	93c1                	srli	a5,a5,0x30
    800050fa:	4705                	li	a4,1
    800050fc:	00f76d63          	bltu	a4,a5,80005116 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005100:	8556                	mv	a0,s5
    80005102:	60a6                	ld	ra,72(sp)
    80005104:	6406                	ld	s0,64(sp)
    80005106:	74e2                	ld	s1,56(sp)
    80005108:	7942                	ld	s2,48(sp)
    8000510a:	79a2                	ld	s3,40(sp)
    8000510c:	7a02                	ld	s4,32(sp)
    8000510e:	6ae2                	ld	s5,24(sp)
    80005110:	6b42                	ld	s6,16(sp)
    80005112:	6161                	addi	sp,sp,80
    80005114:	8082                	ret
    iunlockput(ip);
    80005116:	8556                	mv	a0,s5
    80005118:	fffff097          	auipc	ra,0xfffff
    8000511c:	8b0080e7          	jalr	-1872(ra) # 800039c8 <iunlockput>
    return 0;
    80005120:	4a81                	li	s5,0
    80005122:	bff9                	j	80005100 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005124:	85da                	mv	a1,s6
    80005126:	4088                	lw	a0,0(s1)
    80005128:	ffffe097          	auipc	ra,0xffffe
    8000512c:	4a6080e7          	jalr	1190(ra) # 800035ce <ialloc>
    80005130:	8a2a                	mv	s4,a0
    80005132:	c529                	beqz	a0,8000517c <create+0xee>
  ilock(ip);
    80005134:	ffffe097          	auipc	ra,0xffffe
    80005138:	632080e7          	jalr	1586(ra) # 80003766 <ilock>
  ip->major = major;
    8000513c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005140:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005144:	4905                	li	s2,1
    80005146:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000514a:	8552                	mv	a0,s4
    8000514c:	ffffe097          	auipc	ra,0xffffe
    80005150:	54e080e7          	jalr	1358(ra) # 8000369a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005154:	032b0b63          	beq	s6,s2,8000518a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005158:	004a2603          	lw	a2,4(s4)
    8000515c:	fb040593          	addi	a1,s0,-80
    80005160:	8526                	mv	a0,s1
    80005162:	fffff097          	auipc	ra,0xfffff
    80005166:	cf8080e7          	jalr	-776(ra) # 80003e5a <dirlink>
    8000516a:	06054f63          	bltz	a0,800051e8 <create+0x15a>
  iunlockput(dp);
    8000516e:	8526                	mv	a0,s1
    80005170:	fffff097          	auipc	ra,0xfffff
    80005174:	858080e7          	jalr	-1960(ra) # 800039c8 <iunlockput>
  return ip;
    80005178:	8ad2                	mv	s5,s4
    8000517a:	b759                	j	80005100 <create+0x72>
    iunlockput(dp);
    8000517c:	8526                	mv	a0,s1
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	84a080e7          	jalr	-1974(ra) # 800039c8 <iunlockput>
    return 0;
    80005186:	8ad2                	mv	s5,s4
    80005188:	bfa5                	j	80005100 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000518a:	004a2603          	lw	a2,4(s4)
    8000518e:	00003597          	auipc	a1,0x3
    80005192:	66a58593          	addi	a1,a1,1642 # 800087f8 <syscalls+0x2a0>
    80005196:	8552                	mv	a0,s4
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	cc2080e7          	jalr	-830(ra) # 80003e5a <dirlink>
    800051a0:	04054463          	bltz	a0,800051e8 <create+0x15a>
    800051a4:	40d0                	lw	a2,4(s1)
    800051a6:	00003597          	auipc	a1,0x3
    800051aa:	65a58593          	addi	a1,a1,1626 # 80008800 <syscalls+0x2a8>
    800051ae:	8552                	mv	a0,s4
    800051b0:	fffff097          	auipc	ra,0xfffff
    800051b4:	caa080e7          	jalr	-854(ra) # 80003e5a <dirlink>
    800051b8:	02054863          	bltz	a0,800051e8 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800051bc:	004a2603          	lw	a2,4(s4)
    800051c0:	fb040593          	addi	a1,s0,-80
    800051c4:	8526                	mv	a0,s1
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	c94080e7          	jalr	-876(ra) # 80003e5a <dirlink>
    800051ce:	00054d63          	bltz	a0,800051e8 <create+0x15a>
    dp->nlink++;  // for ".."
    800051d2:	04a4d783          	lhu	a5,74(s1)
    800051d6:	2785                	addiw	a5,a5,1
    800051d8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051dc:	8526                	mv	a0,s1
    800051de:	ffffe097          	auipc	ra,0xffffe
    800051e2:	4bc080e7          	jalr	1212(ra) # 8000369a <iupdate>
    800051e6:	b761                	j	8000516e <create+0xe0>
  ip->nlink = 0;
    800051e8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800051ec:	8552                	mv	a0,s4
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	4ac080e7          	jalr	1196(ra) # 8000369a <iupdate>
  iunlockput(ip);
    800051f6:	8552                	mv	a0,s4
    800051f8:	ffffe097          	auipc	ra,0xffffe
    800051fc:	7d0080e7          	jalr	2000(ra) # 800039c8 <iunlockput>
  iunlockput(dp);
    80005200:	8526                	mv	a0,s1
    80005202:	ffffe097          	auipc	ra,0xffffe
    80005206:	7c6080e7          	jalr	1990(ra) # 800039c8 <iunlockput>
  return 0;
    8000520a:	bddd                	j	80005100 <create+0x72>
    return 0;
    8000520c:	8aaa                	mv	s5,a0
    8000520e:	bdcd                	j	80005100 <create+0x72>

0000000080005210 <sys_dup>:
{
    80005210:	7179                	addi	sp,sp,-48
    80005212:	f406                	sd	ra,40(sp)
    80005214:	f022                	sd	s0,32(sp)
    80005216:	ec26                	sd	s1,24(sp)
    80005218:	e84a                	sd	s2,16(sp)
    8000521a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000521c:	fd840613          	addi	a2,s0,-40
    80005220:	4581                	li	a1,0
    80005222:	4501                	li	a0,0
    80005224:	00000097          	auipc	ra,0x0
    80005228:	dc8080e7          	jalr	-568(ra) # 80004fec <argfd>
    return -1;
    8000522c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000522e:	02054363          	bltz	a0,80005254 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005232:	fd843903          	ld	s2,-40(s0)
    80005236:	854a                	mv	a0,s2
    80005238:	00000097          	auipc	ra,0x0
    8000523c:	e14080e7          	jalr	-492(ra) # 8000504c <fdalloc>
    80005240:	84aa                	mv	s1,a0
    return -1;
    80005242:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005244:	00054863          	bltz	a0,80005254 <sys_dup+0x44>
  filedup(f);
    80005248:	854a                	mv	a0,s2
    8000524a:	fffff097          	auipc	ra,0xfffff
    8000524e:	334080e7          	jalr	820(ra) # 8000457e <filedup>
  return fd;
    80005252:	87a6                	mv	a5,s1
}
    80005254:	853e                	mv	a0,a5
    80005256:	70a2                	ld	ra,40(sp)
    80005258:	7402                	ld	s0,32(sp)
    8000525a:	64e2                	ld	s1,24(sp)
    8000525c:	6942                	ld	s2,16(sp)
    8000525e:	6145                	addi	sp,sp,48
    80005260:	8082                	ret

0000000080005262 <sys_read>:
{
    80005262:	7179                	addi	sp,sp,-48
    80005264:	f406                	sd	ra,40(sp)
    80005266:	f022                	sd	s0,32(sp)
    80005268:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000526a:	fd840593          	addi	a1,s0,-40
    8000526e:	4505                	li	a0,1
    80005270:	ffffe097          	auipc	ra,0xffffe
    80005274:	88c080e7          	jalr	-1908(ra) # 80002afc <argaddr>
  argint(2, &n);
    80005278:	fe440593          	addi	a1,s0,-28
    8000527c:	4509                	li	a0,2
    8000527e:	ffffe097          	auipc	ra,0xffffe
    80005282:	85e080e7          	jalr	-1954(ra) # 80002adc <argint>
  if(argfd(0, 0, &f) < 0)
    80005286:	fe840613          	addi	a2,s0,-24
    8000528a:	4581                	li	a1,0
    8000528c:	4501                	li	a0,0
    8000528e:	00000097          	auipc	ra,0x0
    80005292:	d5e080e7          	jalr	-674(ra) # 80004fec <argfd>
    80005296:	87aa                	mv	a5,a0
    return -1;
    80005298:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000529a:	0007cc63          	bltz	a5,800052b2 <sys_read+0x50>
  return fileread(f, p, n);
    8000529e:	fe442603          	lw	a2,-28(s0)
    800052a2:	fd843583          	ld	a1,-40(s0)
    800052a6:	fe843503          	ld	a0,-24(s0)
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	460080e7          	jalr	1120(ra) # 8000470a <fileread>
}
    800052b2:	70a2                	ld	ra,40(sp)
    800052b4:	7402                	ld	s0,32(sp)
    800052b6:	6145                	addi	sp,sp,48
    800052b8:	8082                	ret

00000000800052ba <sys_write>:
{
    800052ba:	7179                	addi	sp,sp,-48
    800052bc:	f406                	sd	ra,40(sp)
    800052be:	f022                	sd	s0,32(sp)
    800052c0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052c2:	fd840593          	addi	a1,s0,-40
    800052c6:	4505                	li	a0,1
    800052c8:	ffffe097          	auipc	ra,0xffffe
    800052cc:	834080e7          	jalr	-1996(ra) # 80002afc <argaddr>
  argint(2, &n);
    800052d0:	fe440593          	addi	a1,s0,-28
    800052d4:	4509                	li	a0,2
    800052d6:	ffffe097          	auipc	ra,0xffffe
    800052da:	806080e7          	jalr	-2042(ra) # 80002adc <argint>
  if(argfd(0, 0, &f) < 0)
    800052de:	fe840613          	addi	a2,s0,-24
    800052e2:	4581                	li	a1,0
    800052e4:	4501                	li	a0,0
    800052e6:	00000097          	auipc	ra,0x0
    800052ea:	d06080e7          	jalr	-762(ra) # 80004fec <argfd>
    800052ee:	87aa                	mv	a5,a0
    return -1;
    800052f0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052f2:	0007cc63          	bltz	a5,8000530a <sys_write+0x50>
  return filewrite(f, p, n);
    800052f6:	fe442603          	lw	a2,-28(s0)
    800052fa:	fd843583          	ld	a1,-40(s0)
    800052fe:	fe843503          	ld	a0,-24(s0)
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	4ca080e7          	jalr	1226(ra) # 800047cc <filewrite>
}
    8000530a:	70a2                	ld	ra,40(sp)
    8000530c:	7402                	ld	s0,32(sp)
    8000530e:	6145                	addi	sp,sp,48
    80005310:	8082                	ret

0000000080005312 <sys_close>:
{
    80005312:	1101                	addi	sp,sp,-32
    80005314:	ec06                	sd	ra,24(sp)
    80005316:	e822                	sd	s0,16(sp)
    80005318:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000531a:	fe040613          	addi	a2,s0,-32
    8000531e:	fec40593          	addi	a1,s0,-20
    80005322:	4501                	li	a0,0
    80005324:	00000097          	auipc	ra,0x0
    80005328:	cc8080e7          	jalr	-824(ra) # 80004fec <argfd>
    return -1;
    8000532c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000532e:	02054463          	bltz	a0,80005356 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005332:	ffffc097          	auipc	ra,0xffffc
    80005336:	684080e7          	jalr	1668(ra) # 800019b6 <myproc>
    8000533a:	fec42783          	lw	a5,-20(s0)
    8000533e:	07e9                	addi	a5,a5,26
    80005340:	078e                	slli	a5,a5,0x3
    80005342:	953e                	add	a0,a0,a5
    80005344:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005348:	fe043503          	ld	a0,-32(s0)
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	284080e7          	jalr	644(ra) # 800045d0 <fileclose>
  return 0;
    80005354:	4781                	li	a5,0
}
    80005356:	853e                	mv	a0,a5
    80005358:	60e2                	ld	ra,24(sp)
    8000535a:	6442                	ld	s0,16(sp)
    8000535c:	6105                	addi	sp,sp,32
    8000535e:	8082                	ret

0000000080005360 <sys_fstat>:
{
    80005360:	1101                	addi	sp,sp,-32
    80005362:	ec06                	sd	ra,24(sp)
    80005364:	e822                	sd	s0,16(sp)
    80005366:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005368:	fe040593          	addi	a1,s0,-32
    8000536c:	4505                	li	a0,1
    8000536e:	ffffd097          	auipc	ra,0xffffd
    80005372:	78e080e7          	jalr	1934(ra) # 80002afc <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005376:	fe840613          	addi	a2,s0,-24
    8000537a:	4581                	li	a1,0
    8000537c:	4501                	li	a0,0
    8000537e:	00000097          	auipc	ra,0x0
    80005382:	c6e080e7          	jalr	-914(ra) # 80004fec <argfd>
    80005386:	87aa                	mv	a5,a0
    return -1;
    80005388:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000538a:	0007ca63          	bltz	a5,8000539e <sys_fstat+0x3e>
  return filestat(f, st);
    8000538e:	fe043583          	ld	a1,-32(s0)
    80005392:	fe843503          	ld	a0,-24(s0)
    80005396:	fffff097          	auipc	ra,0xfffff
    8000539a:	302080e7          	jalr	770(ra) # 80004698 <filestat>
}
    8000539e:	60e2                	ld	ra,24(sp)
    800053a0:	6442                	ld	s0,16(sp)
    800053a2:	6105                	addi	sp,sp,32
    800053a4:	8082                	ret

00000000800053a6 <sys_link>:
{
    800053a6:	7169                	addi	sp,sp,-304
    800053a8:	f606                	sd	ra,296(sp)
    800053aa:	f222                	sd	s0,288(sp)
    800053ac:	ee26                	sd	s1,280(sp)
    800053ae:	ea4a                	sd	s2,272(sp)
    800053b0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053b2:	08000613          	li	a2,128
    800053b6:	ed040593          	addi	a1,s0,-304
    800053ba:	4501                	li	a0,0
    800053bc:	ffffd097          	auipc	ra,0xffffd
    800053c0:	760080e7          	jalr	1888(ra) # 80002b1c <argstr>
    return -1;
    800053c4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053c6:	10054e63          	bltz	a0,800054e2 <sys_link+0x13c>
    800053ca:	08000613          	li	a2,128
    800053ce:	f5040593          	addi	a1,s0,-176
    800053d2:	4505                	li	a0,1
    800053d4:	ffffd097          	auipc	ra,0xffffd
    800053d8:	748080e7          	jalr	1864(ra) # 80002b1c <argstr>
    return -1;
    800053dc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053de:	10054263          	bltz	a0,800054e2 <sys_link+0x13c>
  begin_op();
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	d2a080e7          	jalr	-726(ra) # 8000410c <begin_op>
  if((ip = namei(old)) == 0){
    800053ea:	ed040513          	addi	a0,s0,-304
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	b1e080e7          	jalr	-1250(ra) # 80003f0c <namei>
    800053f6:	84aa                	mv	s1,a0
    800053f8:	c551                	beqz	a0,80005484 <sys_link+0xde>
  ilock(ip);
    800053fa:	ffffe097          	auipc	ra,0xffffe
    800053fe:	36c080e7          	jalr	876(ra) # 80003766 <ilock>
  if(ip->type == T_DIR){
    80005402:	04449703          	lh	a4,68(s1)
    80005406:	4785                	li	a5,1
    80005408:	08f70463          	beq	a4,a5,80005490 <sys_link+0xea>
  ip->nlink++;
    8000540c:	04a4d783          	lhu	a5,74(s1)
    80005410:	2785                	addiw	a5,a5,1
    80005412:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005416:	8526                	mv	a0,s1
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	282080e7          	jalr	642(ra) # 8000369a <iupdate>
  iunlock(ip);
    80005420:	8526                	mv	a0,s1
    80005422:	ffffe097          	auipc	ra,0xffffe
    80005426:	406080e7          	jalr	1030(ra) # 80003828 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000542a:	fd040593          	addi	a1,s0,-48
    8000542e:	f5040513          	addi	a0,s0,-176
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	af8080e7          	jalr	-1288(ra) # 80003f2a <nameiparent>
    8000543a:	892a                	mv	s2,a0
    8000543c:	c935                	beqz	a0,800054b0 <sys_link+0x10a>
  ilock(dp);
    8000543e:	ffffe097          	auipc	ra,0xffffe
    80005442:	328080e7          	jalr	808(ra) # 80003766 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005446:	00092703          	lw	a4,0(s2)
    8000544a:	409c                	lw	a5,0(s1)
    8000544c:	04f71d63          	bne	a4,a5,800054a6 <sys_link+0x100>
    80005450:	40d0                	lw	a2,4(s1)
    80005452:	fd040593          	addi	a1,s0,-48
    80005456:	854a                	mv	a0,s2
    80005458:	fffff097          	auipc	ra,0xfffff
    8000545c:	a02080e7          	jalr	-1534(ra) # 80003e5a <dirlink>
    80005460:	04054363          	bltz	a0,800054a6 <sys_link+0x100>
  iunlockput(dp);
    80005464:	854a                	mv	a0,s2
    80005466:	ffffe097          	auipc	ra,0xffffe
    8000546a:	562080e7          	jalr	1378(ra) # 800039c8 <iunlockput>
  iput(ip);
    8000546e:	8526                	mv	a0,s1
    80005470:	ffffe097          	auipc	ra,0xffffe
    80005474:	4b0080e7          	jalr	1200(ra) # 80003920 <iput>
  end_op();
    80005478:	fffff097          	auipc	ra,0xfffff
    8000547c:	d0e080e7          	jalr	-754(ra) # 80004186 <end_op>
  return 0;
    80005480:	4781                	li	a5,0
    80005482:	a085                	j	800054e2 <sys_link+0x13c>
    end_op();
    80005484:	fffff097          	auipc	ra,0xfffff
    80005488:	d02080e7          	jalr	-766(ra) # 80004186 <end_op>
    return -1;
    8000548c:	57fd                	li	a5,-1
    8000548e:	a891                	j	800054e2 <sys_link+0x13c>
    iunlockput(ip);
    80005490:	8526                	mv	a0,s1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	536080e7          	jalr	1334(ra) # 800039c8 <iunlockput>
    end_op();
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	cec080e7          	jalr	-788(ra) # 80004186 <end_op>
    return -1;
    800054a2:	57fd                	li	a5,-1
    800054a4:	a83d                	j	800054e2 <sys_link+0x13c>
    iunlockput(dp);
    800054a6:	854a                	mv	a0,s2
    800054a8:	ffffe097          	auipc	ra,0xffffe
    800054ac:	520080e7          	jalr	1312(ra) # 800039c8 <iunlockput>
  ilock(ip);
    800054b0:	8526                	mv	a0,s1
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	2b4080e7          	jalr	692(ra) # 80003766 <ilock>
  ip->nlink--;
    800054ba:	04a4d783          	lhu	a5,74(s1)
    800054be:	37fd                	addiw	a5,a5,-1
    800054c0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054c4:	8526                	mv	a0,s1
    800054c6:	ffffe097          	auipc	ra,0xffffe
    800054ca:	1d4080e7          	jalr	468(ra) # 8000369a <iupdate>
  iunlockput(ip);
    800054ce:	8526                	mv	a0,s1
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	4f8080e7          	jalr	1272(ra) # 800039c8 <iunlockput>
  end_op();
    800054d8:	fffff097          	auipc	ra,0xfffff
    800054dc:	cae080e7          	jalr	-850(ra) # 80004186 <end_op>
  return -1;
    800054e0:	57fd                	li	a5,-1
}
    800054e2:	853e                	mv	a0,a5
    800054e4:	70b2                	ld	ra,296(sp)
    800054e6:	7412                	ld	s0,288(sp)
    800054e8:	64f2                	ld	s1,280(sp)
    800054ea:	6952                	ld	s2,272(sp)
    800054ec:	6155                	addi	sp,sp,304
    800054ee:	8082                	ret

00000000800054f0 <sys_unlink>:
{
    800054f0:	7151                	addi	sp,sp,-240
    800054f2:	f586                	sd	ra,232(sp)
    800054f4:	f1a2                	sd	s0,224(sp)
    800054f6:	eda6                	sd	s1,216(sp)
    800054f8:	e9ca                	sd	s2,208(sp)
    800054fa:	e5ce                	sd	s3,200(sp)
    800054fc:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054fe:	08000613          	li	a2,128
    80005502:	f3040593          	addi	a1,s0,-208
    80005506:	4501                	li	a0,0
    80005508:	ffffd097          	auipc	ra,0xffffd
    8000550c:	614080e7          	jalr	1556(ra) # 80002b1c <argstr>
    80005510:	18054163          	bltz	a0,80005692 <sys_unlink+0x1a2>
  begin_op();
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	bf8080e7          	jalr	-1032(ra) # 8000410c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000551c:	fb040593          	addi	a1,s0,-80
    80005520:	f3040513          	addi	a0,s0,-208
    80005524:	fffff097          	auipc	ra,0xfffff
    80005528:	a06080e7          	jalr	-1530(ra) # 80003f2a <nameiparent>
    8000552c:	84aa                	mv	s1,a0
    8000552e:	c979                	beqz	a0,80005604 <sys_unlink+0x114>
  ilock(dp);
    80005530:	ffffe097          	auipc	ra,0xffffe
    80005534:	236080e7          	jalr	566(ra) # 80003766 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005538:	00003597          	auipc	a1,0x3
    8000553c:	2c058593          	addi	a1,a1,704 # 800087f8 <syscalls+0x2a0>
    80005540:	fb040513          	addi	a0,s0,-80
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	6ec080e7          	jalr	1772(ra) # 80003c30 <namecmp>
    8000554c:	14050a63          	beqz	a0,800056a0 <sys_unlink+0x1b0>
    80005550:	00003597          	auipc	a1,0x3
    80005554:	2b058593          	addi	a1,a1,688 # 80008800 <syscalls+0x2a8>
    80005558:	fb040513          	addi	a0,s0,-80
    8000555c:	ffffe097          	auipc	ra,0xffffe
    80005560:	6d4080e7          	jalr	1748(ra) # 80003c30 <namecmp>
    80005564:	12050e63          	beqz	a0,800056a0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005568:	f2c40613          	addi	a2,s0,-212
    8000556c:	fb040593          	addi	a1,s0,-80
    80005570:	8526                	mv	a0,s1
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	6d8080e7          	jalr	1752(ra) # 80003c4a <dirlookup>
    8000557a:	892a                	mv	s2,a0
    8000557c:	12050263          	beqz	a0,800056a0 <sys_unlink+0x1b0>
  ilock(ip);
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	1e6080e7          	jalr	486(ra) # 80003766 <ilock>
  if(ip->nlink < 1)
    80005588:	04a91783          	lh	a5,74(s2)
    8000558c:	08f05263          	blez	a5,80005610 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005590:	04491703          	lh	a4,68(s2)
    80005594:	4785                	li	a5,1
    80005596:	08f70563          	beq	a4,a5,80005620 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000559a:	4641                	li	a2,16
    8000559c:	4581                	li	a1,0
    8000559e:	fc040513          	addi	a0,s0,-64
    800055a2:	ffffb097          	auipc	ra,0xffffb
    800055a6:	72c080e7          	jalr	1836(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055aa:	4741                	li	a4,16
    800055ac:	f2c42683          	lw	a3,-212(s0)
    800055b0:	fc040613          	addi	a2,s0,-64
    800055b4:	4581                	li	a1,0
    800055b6:	8526                	mv	a0,s1
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	55a080e7          	jalr	1370(ra) # 80003b12 <writei>
    800055c0:	47c1                	li	a5,16
    800055c2:	0af51563          	bne	a0,a5,8000566c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055c6:	04491703          	lh	a4,68(s2)
    800055ca:	4785                	li	a5,1
    800055cc:	0af70863          	beq	a4,a5,8000567c <sys_unlink+0x18c>
  iunlockput(dp);
    800055d0:	8526                	mv	a0,s1
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	3f6080e7          	jalr	1014(ra) # 800039c8 <iunlockput>
  ip->nlink--;
    800055da:	04a95783          	lhu	a5,74(s2)
    800055de:	37fd                	addiw	a5,a5,-1
    800055e0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055e4:	854a                	mv	a0,s2
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	0b4080e7          	jalr	180(ra) # 8000369a <iupdate>
  iunlockput(ip);
    800055ee:	854a                	mv	a0,s2
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	3d8080e7          	jalr	984(ra) # 800039c8 <iunlockput>
  end_op();
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	b8e080e7          	jalr	-1138(ra) # 80004186 <end_op>
  return 0;
    80005600:	4501                	li	a0,0
    80005602:	a84d                	j	800056b4 <sys_unlink+0x1c4>
    end_op();
    80005604:	fffff097          	auipc	ra,0xfffff
    80005608:	b82080e7          	jalr	-1150(ra) # 80004186 <end_op>
    return -1;
    8000560c:	557d                	li	a0,-1
    8000560e:	a05d                	j	800056b4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005610:	00003517          	auipc	a0,0x3
    80005614:	1f850513          	addi	a0,a0,504 # 80008808 <syscalls+0x2b0>
    80005618:	ffffb097          	auipc	ra,0xffffb
    8000561c:	f24080e7          	jalr	-220(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005620:	04c92703          	lw	a4,76(s2)
    80005624:	02000793          	li	a5,32
    80005628:	f6e7f9e3          	bgeu	a5,a4,8000559a <sys_unlink+0xaa>
    8000562c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005630:	4741                	li	a4,16
    80005632:	86ce                	mv	a3,s3
    80005634:	f1840613          	addi	a2,s0,-232
    80005638:	4581                	li	a1,0
    8000563a:	854a                	mv	a0,s2
    8000563c:	ffffe097          	auipc	ra,0xffffe
    80005640:	3de080e7          	jalr	990(ra) # 80003a1a <readi>
    80005644:	47c1                	li	a5,16
    80005646:	00f51b63          	bne	a0,a5,8000565c <sys_unlink+0x16c>
    if(de.inum != 0)
    8000564a:	f1845783          	lhu	a5,-232(s0)
    8000564e:	e7a1                	bnez	a5,80005696 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005650:	29c1                	addiw	s3,s3,16
    80005652:	04c92783          	lw	a5,76(s2)
    80005656:	fcf9ede3          	bltu	s3,a5,80005630 <sys_unlink+0x140>
    8000565a:	b781                	j	8000559a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000565c:	00003517          	auipc	a0,0x3
    80005660:	1c450513          	addi	a0,a0,452 # 80008820 <syscalls+0x2c8>
    80005664:	ffffb097          	auipc	ra,0xffffb
    80005668:	ed8080e7          	jalr	-296(ra) # 8000053c <panic>
    panic("unlink: writei");
    8000566c:	00003517          	auipc	a0,0x3
    80005670:	1cc50513          	addi	a0,a0,460 # 80008838 <syscalls+0x2e0>
    80005674:	ffffb097          	auipc	ra,0xffffb
    80005678:	ec8080e7          	jalr	-312(ra) # 8000053c <panic>
    dp->nlink--;
    8000567c:	04a4d783          	lhu	a5,74(s1)
    80005680:	37fd                	addiw	a5,a5,-1
    80005682:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005686:	8526                	mv	a0,s1
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	012080e7          	jalr	18(ra) # 8000369a <iupdate>
    80005690:	b781                	j	800055d0 <sys_unlink+0xe0>
    return -1;
    80005692:	557d                	li	a0,-1
    80005694:	a005                	j	800056b4 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005696:	854a                	mv	a0,s2
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	330080e7          	jalr	816(ra) # 800039c8 <iunlockput>
  iunlockput(dp);
    800056a0:	8526                	mv	a0,s1
    800056a2:	ffffe097          	auipc	ra,0xffffe
    800056a6:	326080e7          	jalr	806(ra) # 800039c8 <iunlockput>
  end_op();
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	adc080e7          	jalr	-1316(ra) # 80004186 <end_op>
  return -1;
    800056b2:	557d                	li	a0,-1
}
    800056b4:	70ae                	ld	ra,232(sp)
    800056b6:	740e                	ld	s0,224(sp)
    800056b8:	64ee                	ld	s1,216(sp)
    800056ba:	694e                	ld	s2,208(sp)
    800056bc:	69ae                	ld	s3,200(sp)
    800056be:	616d                	addi	sp,sp,240
    800056c0:	8082                	ret

00000000800056c2 <sys_open>:

uint64
sys_open(void)
{
    800056c2:	7131                	addi	sp,sp,-192
    800056c4:	fd06                	sd	ra,184(sp)
    800056c6:	f922                	sd	s0,176(sp)
    800056c8:	f526                	sd	s1,168(sp)
    800056ca:	f14a                	sd	s2,160(sp)
    800056cc:	ed4e                	sd	s3,152(sp)
    800056ce:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056d0:	f4c40593          	addi	a1,s0,-180
    800056d4:	4505                	li	a0,1
    800056d6:	ffffd097          	auipc	ra,0xffffd
    800056da:	406080e7          	jalr	1030(ra) # 80002adc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056de:	08000613          	li	a2,128
    800056e2:	f5040593          	addi	a1,s0,-176
    800056e6:	4501                	li	a0,0
    800056e8:	ffffd097          	auipc	ra,0xffffd
    800056ec:	434080e7          	jalr	1076(ra) # 80002b1c <argstr>
    800056f0:	87aa                	mv	a5,a0
    return -1;
    800056f2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056f4:	0a07c863          	bltz	a5,800057a4 <sys_open+0xe2>

  begin_op();
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	a14080e7          	jalr	-1516(ra) # 8000410c <begin_op>

  if(omode & O_CREATE){
    80005700:	f4c42783          	lw	a5,-180(s0)
    80005704:	2007f793          	andi	a5,a5,512
    80005708:	cbdd                	beqz	a5,800057be <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    8000570a:	4681                	li	a3,0
    8000570c:	4601                	li	a2,0
    8000570e:	4589                	li	a1,2
    80005710:	f5040513          	addi	a0,s0,-176
    80005714:	00000097          	auipc	ra,0x0
    80005718:	97a080e7          	jalr	-1670(ra) # 8000508e <create>
    8000571c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000571e:	c951                	beqz	a0,800057b2 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005720:	04449703          	lh	a4,68(s1)
    80005724:	478d                	li	a5,3
    80005726:	00f71763          	bne	a4,a5,80005734 <sys_open+0x72>
    8000572a:	0464d703          	lhu	a4,70(s1)
    8000572e:	47a5                	li	a5,9
    80005730:	0ce7ec63          	bltu	a5,a4,80005808 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005734:	fffff097          	auipc	ra,0xfffff
    80005738:	de0080e7          	jalr	-544(ra) # 80004514 <filealloc>
    8000573c:	892a                	mv	s2,a0
    8000573e:	c56d                	beqz	a0,80005828 <sys_open+0x166>
    80005740:	00000097          	auipc	ra,0x0
    80005744:	90c080e7          	jalr	-1780(ra) # 8000504c <fdalloc>
    80005748:	89aa                	mv	s3,a0
    8000574a:	0c054a63          	bltz	a0,8000581e <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000574e:	04449703          	lh	a4,68(s1)
    80005752:	478d                	li	a5,3
    80005754:	0ef70563          	beq	a4,a5,8000583e <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005758:	4789                	li	a5,2
    8000575a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000575e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005762:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005766:	f4c42783          	lw	a5,-180(s0)
    8000576a:	0017c713          	xori	a4,a5,1
    8000576e:	8b05                	andi	a4,a4,1
    80005770:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005774:	0037f713          	andi	a4,a5,3
    80005778:	00e03733          	snez	a4,a4
    8000577c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005780:	4007f793          	andi	a5,a5,1024
    80005784:	c791                	beqz	a5,80005790 <sys_open+0xce>
    80005786:	04449703          	lh	a4,68(s1)
    8000578a:	4789                	li	a5,2
    8000578c:	0cf70063          	beq	a4,a5,8000584c <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005790:	8526                	mv	a0,s1
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	096080e7          	jalr	150(ra) # 80003828 <iunlock>
  end_op();
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	9ec080e7          	jalr	-1556(ra) # 80004186 <end_op>

  return fd;
    800057a2:	854e                	mv	a0,s3
}
    800057a4:	70ea                	ld	ra,184(sp)
    800057a6:	744a                	ld	s0,176(sp)
    800057a8:	74aa                	ld	s1,168(sp)
    800057aa:	790a                	ld	s2,160(sp)
    800057ac:	69ea                	ld	s3,152(sp)
    800057ae:	6129                	addi	sp,sp,192
    800057b0:	8082                	ret
      end_op();
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	9d4080e7          	jalr	-1580(ra) # 80004186 <end_op>
      return -1;
    800057ba:	557d                	li	a0,-1
    800057bc:	b7e5                	j	800057a4 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800057be:	f5040513          	addi	a0,s0,-176
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	74a080e7          	jalr	1866(ra) # 80003f0c <namei>
    800057ca:	84aa                	mv	s1,a0
    800057cc:	c905                	beqz	a0,800057fc <sys_open+0x13a>
    ilock(ip);
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	f98080e7          	jalr	-104(ra) # 80003766 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057d6:	04449703          	lh	a4,68(s1)
    800057da:	4785                	li	a5,1
    800057dc:	f4f712e3          	bne	a4,a5,80005720 <sys_open+0x5e>
    800057e0:	f4c42783          	lw	a5,-180(s0)
    800057e4:	dba1                	beqz	a5,80005734 <sys_open+0x72>
      iunlockput(ip);
    800057e6:	8526                	mv	a0,s1
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	1e0080e7          	jalr	480(ra) # 800039c8 <iunlockput>
      end_op();
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	996080e7          	jalr	-1642(ra) # 80004186 <end_op>
      return -1;
    800057f8:	557d                	li	a0,-1
    800057fa:	b76d                	j	800057a4 <sys_open+0xe2>
      end_op();
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	98a080e7          	jalr	-1654(ra) # 80004186 <end_op>
      return -1;
    80005804:	557d                	li	a0,-1
    80005806:	bf79                	j	800057a4 <sys_open+0xe2>
    iunlockput(ip);
    80005808:	8526                	mv	a0,s1
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	1be080e7          	jalr	446(ra) # 800039c8 <iunlockput>
    end_op();
    80005812:	fffff097          	auipc	ra,0xfffff
    80005816:	974080e7          	jalr	-1676(ra) # 80004186 <end_op>
    return -1;
    8000581a:	557d                	li	a0,-1
    8000581c:	b761                	j	800057a4 <sys_open+0xe2>
      fileclose(f);
    8000581e:	854a                	mv	a0,s2
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	db0080e7          	jalr	-592(ra) # 800045d0 <fileclose>
    iunlockput(ip);
    80005828:	8526                	mv	a0,s1
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	19e080e7          	jalr	414(ra) # 800039c8 <iunlockput>
    end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	954080e7          	jalr	-1708(ra) # 80004186 <end_op>
    return -1;
    8000583a:	557d                	li	a0,-1
    8000583c:	b7a5                	j	800057a4 <sys_open+0xe2>
    f->type = FD_DEVICE;
    8000583e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005842:	04649783          	lh	a5,70(s1)
    80005846:	02f91223          	sh	a5,36(s2)
    8000584a:	bf21                	j	80005762 <sys_open+0xa0>
    itrunc(ip);
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	026080e7          	jalr	38(ra) # 80003874 <itrunc>
    80005856:	bf2d                	j	80005790 <sys_open+0xce>

0000000080005858 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005858:	7175                	addi	sp,sp,-144
    8000585a:	e506                	sd	ra,136(sp)
    8000585c:	e122                	sd	s0,128(sp)
    8000585e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	8ac080e7          	jalr	-1876(ra) # 8000410c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005868:	08000613          	li	a2,128
    8000586c:	f7040593          	addi	a1,s0,-144
    80005870:	4501                	li	a0,0
    80005872:	ffffd097          	auipc	ra,0xffffd
    80005876:	2aa080e7          	jalr	682(ra) # 80002b1c <argstr>
    8000587a:	02054963          	bltz	a0,800058ac <sys_mkdir+0x54>
    8000587e:	4681                	li	a3,0
    80005880:	4601                	li	a2,0
    80005882:	4585                	li	a1,1
    80005884:	f7040513          	addi	a0,s0,-144
    80005888:	00000097          	auipc	ra,0x0
    8000588c:	806080e7          	jalr	-2042(ra) # 8000508e <create>
    80005890:	cd11                	beqz	a0,800058ac <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005892:	ffffe097          	auipc	ra,0xffffe
    80005896:	136080e7          	jalr	310(ra) # 800039c8 <iunlockput>
  end_op();
    8000589a:	fffff097          	auipc	ra,0xfffff
    8000589e:	8ec080e7          	jalr	-1812(ra) # 80004186 <end_op>
  return 0;
    800058a2:	4501                	li	a0,0
}
    800058a4:	60aa                	ld	ra,136(sp)
    800058a6:	640a                	ld	s0,128(sp)
    800058a8:	6149                	addi	sp,sp,144
    800058aa:	8082                	ret
    end_op();
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	8da080e7          	jalr	-1830(ra) # 80004186 <end_op>
    return -1;
    800058b4:	557d                	li	a0,-1
    800058b6:	b7fd                	j	800058a4 <sys_mkdir+0x4c>

00000000800058b8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058b8:	7135                	addi	sp,sp,-160
    800058ba:	ed06                	sd	ra,152(sp)
    800058bc:	e922                	sd	s0,144(sp)
    800058be:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	84c080e7          	jalr	-1972(ra) # 8000410c <begin_op>
  argint(1, &major);
    800058c8:	f6c40593          	addi	a1,s0,-148
    800058cc:	4505                	li	a0,1
    800058ce:	ffffd097          	auipc	ra,0xffffd
    800058d2:	20e080e7          	jalr	526(ra) # 80002adc <argint>
  argint(2, &minor);
    800058d6:	f6840593          	addi	a1,s0,-152
    800058da:	4509                	li	a0,2
    800058dc:	ffffd097          	auipc	ra,0xffffd
    800058e0:	200080e7          	jalr	512(ra) # 80002adc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058e4:	08000613          	li	a2,128
    800058e8:	f7040593          	addi	a1,s0,-144
    800058ec:	4501                	li	a0,0
    800058ee:	ffffd097          	auipc	ra,0xffffd
    800058f2:	22e080e7          	jalr	558(ra) # 80002b1c <argstr>
    800058f6:	02054b63          	bltz	a0,8000592c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058fa:	f6841683          	lh	a3,-152(s0)
    800058fe:	f6c41603          	lh	a2,-148(s0)
    80005902:	458d                	li	a1,3
    80005904:	f7040513          	addi	a0,s0,-144
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	786080e7          	jalr	1926(ra) # 8000508e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005910:	cd11                	beqz	a0,8000592c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	0b6080e7          	jalr	182(ra) # 800039c8 <iunlockput>
  end_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	86c080e7          	jalr	-1940(ra) # 80004186 <end_op>
  return 0;
    80005922:	4501                	li	a0,0
}
    80005924:	60ea                	ld	ra,152(sp)
    80005926:	644a                	ld	s0,144(sp)
    80005928:	610d                	addi	sp,sp,160
    8000592a:	8082                	ret
    end_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	85a080e7          	jalr	-1958(ra) # 80004186 <end_op>
    return -1;
    80005934:	557d                	li	a0,-1
    80005936:	b7fd                	j	80005924 <sys_mknod+0x6c>

0000000080005938 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005938:	7135                	addi	sp,sp,-160
    8000593a:	ed06                	sd	ra,152(sp)
    8000593c:	e922                	sd	s0,144(sp)
    8000593e:	e526                	sd	s1,136(sp)
    80005940:	e14a                	sd	s2,128(sp)
    80005942:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005944:	ffffc097          	auipc	ra,0xffffc
    80005948:	072080e7          	jalr	114(ra) # 800019b6 <myproc>
    8000594c:	892a                	mv	s2,a0
  
  begin_op();
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	7be080e7          	jalr	1982(ra) # 8000410c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005956:	08000613          	li	a2,128
    8000595a:	f6040593          	addi	a1,s0,-160
    8000595e:	4501                	li	a0,0
    80005960:	ffffd097          	auipc	ra,0xffffd
    80005964:	1bc080e7          	jalr	444(ra) # 80002b1c <argstr>
    80005968:	04054b63          	bltz	a0,800059be <sys_chdir+0x86>
    8000596c:	f6040513          	addi	a0,s0,-160
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	59c080e7          	jalr	1436(ra) # 80003f0c <namei>
    80005978:	84aa                	mv	s1,a0
    8000597a:	c131                	beqz	a0,800059be <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	dea080e7          	jalr	-534(ra) # 80003766 <ilock>
  if(ip->type != T_DIR){
    80005984:	04449703          	lh	a4,68(s1)
    80005988:	4785                	li	a5,1
    8000598a:	04f71063          	bne	a4,a5,800059ca <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000598e:	8526                	mv	a0,s1
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	e98080e7          	jalr	-360(ra) # 80003828 <iunlock>
  iput(p->cwd);
    80005998:	15093503          	ld	a0,336(s2)
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	f84080e7          	jalr	-124(ra) # 80003920 <iput>
  end_op();
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	7e2080e7          	jalr	2018(ra) # 80004186 <end_op>
  p->cwd = ip;
    800059ac:	14993823          	sd	s1,336(s2)
  return 0;
    800059b0:	4501                	li	a0,0
}
    800059b2:	60ea                	ld	ra,152(sp)
    800059b4:	644a                	ld	s0,144(sp)
    800059b6:	64aa                	ld	s1,136(sp)
    800059b8:	690a                	ld	s2,128(sp)
    800059ba:	610d                	addi	sp,sp,160
    800059bc:	8082                	ret
    end_op();
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	7c8080e7          	jalr	1992(ra) # 80004186 <end_op>
    return -1;
    800059c6:	557d                	li	a0,-1
    800059c8:	b7ed                	j	800059b2 <sys_chdir+0x7a>
    iunlockput(ip);
    800059ca:	8526                	mv	a0,s1
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	ffc080e7          	jalr	-4(ra) # 800039c8 <iunlockput>
    end_op();
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	7b2080e7          	jalr	1970(ra) # 80004186 <end_op>
    return -1;
    800059dc:	557d                	li	a0,-1
    800059de:	bfd1                	j	800059b2 <sys_chdir+0x7a>

00000000800059e0 <sys_exec>:

uint64
sys_exec(void)
{
    800059e0:	7121                	addi	sp,sp,-448
    800059e2:	ff06                	sd	ra,440(sp)
    800059e4:	fb22                	sd	s0,432(sp)
    800059e6:	f726                	sd	s1,424(sp)
    800059e8:	f34a                	sd	s2,416(sp)
    800059ea:	ef4e                	sd	s3,408(sp)
    800059ec:	eb52                	sd	s4,400(sp)
    800059ee:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059f0:	e4840593          	addi	a1,s0,-440
    800059f4:	4505                	li	a0,1
    800059f6:	ffffd097          	auipc	ra,0xffffd
    800059fa:	106080e7          	jalr	262(ra) # 80002afc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059fe:	08000613          	li	a2,128
    80005a02:	f5040593          	addi	a1,s0,-176
    80005a06:	4501                	li	a0,0
    80005a08:	ffffd097          	auipc	ra,0xffffd
    80005a0c:	114080e7          	jalr	276(ra) # 80002b1c <argstr>
    80005a10:	87aa                	mv	a5,a0
    return -1;
    80005a12:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a14:	0c07c263          	bltz	a5,80005ad8 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a18:	10000613          	li	a2,256
    80005a1c:	4581                	li	a1,0
    80005a1e:	e5040513          	addi	a0,s0,-432
    80005a22:	ffffb097          	auipc	ra,0xffffb
    80005a26:	2ac080e7          	jalr	684(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a2a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a2e:	89a6                	mv	s3,s1
    80005a30:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a32:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a36:	00391513          	slli	a0,s2,0x3
    80005a3a:	e4040593          	addi	a1,s0,-448
    80005a3e:	e4843783          	ld	a5,-440(s0)
    80005a42:	953e                	add	a0,a0,a5
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	ffa080e7          	jalr	-6(ra) # 80002a3e <fetchaddr>
    80005a4c:	02054a63          	bltz	a0,80005a80 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005a50:	e4043783          	ld	a5,-448(s0)
    80005a54:	c3b9                	beqz	a5,80005a9a <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a56:	ffffb097          	auipc	ra,0xffffb
    80005a5a:	08c080e7          	jalr	140(ra) # 80000ae2 <kalloc>
    80005a5e:	85aa                	mv	a1,a0
    80005a60:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a64:	cd11                	beqz	a0,80005a80 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a66:	6605                	lui	a2,0x1
    80005a68:	e4043503          	ld	a0,-448(s0)
    80005a6c:	ffffd097          	auipc	ra,0xffffd
    80005a70:	024080e7          	jalr	36(ra) # 80002a90 <fetchstr>
    80005a74:	00054663          	bltz	a0,80005a80 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005a78:	0905                	addi	s2,s2,1
    80005a7a:	09a1                	addi	s3,s3,8
    80005a7c:	fb491de3          	bne	s2,s4,80005a36 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a80:	f5040913          	addi	s2,s0,-176
    80005a84:	6088                	ld	a0,0(s1)
    80005a86:	c921                	beqz	a0,80005ad6 <sys_exec+0xf6>
    kfree(argv[i]);
    80005a88:	ffffb097          	auipc	ra,0xffffb
    80005a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a90:	04a1                	addi	s1,s1,8
    80005a92:	ff2499e3          	bne	s1,s2,80005a84 <sys_exec+0xa4>
  return -1;
    80005a96:	557d                	li	a0,-1
    80005a98:	a081                	j	80005ad8 <sys_exec+0xf8>
      argv[i] = 0;
    80005a9a:	0009079b          	sext.w	a5,s2
    80005a9e:	078e                	slli	a5,a5,0x3
    80005aa0:	fd078793          	addi	a5,a5,-48
    80005aa4:	97a2                	add	a5,a5,s0
    80005aa6:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005aaa:	e5040593          	addi	a1,s0,-432
    80005aae:	f5040513          	addi	a0,s0,-176
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	194080e7          	jalr	404(ra) # 80004c46 <exec>
    80005aba:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005abc:	f5040993          	addi	s3,s0,-176
    80005ac0:	6088                	ld	a0,0(s1)
    80005ac2:	c901                	beqz	a0,80005ad2 <sys_exec+0xf2>
    kfree(argv[i]);
    80005ac4:	ffffb097          	auipc	ra,0xffffb
    80005ac8:	f20080e7          	jalr	-224(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005acc:	04a1                	addi	s1,s1,8
    80005ace:	ff3499e3          	bne	s1,s3,80005ac0 <sys_exec+0xe0>
  return ret;
    80005ad2:	854a                	mv	a0,s2
    80005ad4:	a011                	j	80005ad8 <sys_exec+0xf8>
  return -1;
    80005ad6:	557d                	li	a0,-1
}
    80005ad8:	70fa                	ld	ra,440(sp)
    80005ada:	745a                	ld	s0,432(sp)
    80005adc:	74ba                	ld	s1,424(sp)
    80005ade:	791a                	ld	s2,416(sp)
    80005ae0:	69fa                	ld	s3,408(sp)
    80005ae2:	6a5a                	ld	s4,400(sp)
    80005ae4:	6139                	addi	sp,sp,448
    80005ae6:	8082                	ret

0000000080005ae8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ae8:	7139                	addi	sp,sp,-64
    80005aea:	fc06                	sd	ra,56(sp)
    80005aec:	f822                	sd	s0,48(sp)
    80005aee:	f426                	sd	s1,40(sp)
    80005af0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005af2:	ffffc097          	auipc	ra,0xffffc
    80005af6:	ec4080e7          	jalr	-316(ra) # 800019b6 <myproc>
    80005afa:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005afc:	fd840593          	addi	a1,s0,-40
    80005b00:	4501                	li	a0,0
    80005b02:	ffffd097          	auipc	ra,0xffffd
    80005b06:	ffa080e7          	jalr	-6(ra) # 80002afc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b0a:	fc840593          	addi	a1,s0,-56
    80005b0e:	fd040513          	addi	a0,s0,-48
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	dea080e7          	jalr	-534(ra) # 800048fc <pipealloc>
    return -1;
    80005b1a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b1c:	0c054463          	bltz	a0,80005be4 <sys_pipe+0xfc>
  fd0 = -1;
    80005b20:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b24:	fd043503          	ld	a0,-48(s0)
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	524080e7          	jalr	1316(ra) # 8000504c <fdalloc>
    80005b30:	fca42223          	sw	a0,-60(s0)
    80005b34:	08054b63          	bltz	a0,80005bca <sys_pipe+0xe2>
    80005b38:	fc843503          	ld	a0,-56(s0)
    80005b3c:	fffff097          	auipc	ra,0xfffff
    80005b40:	510080e7          	jalr	1296(ra) # 8000504c <fdalloc>
    80005b44:	fca42023          	sw	a0,-64(s0)
    80005b48:	06054863          	bltz	a0,80005bb8 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b4c:	4691                	li	a3,4
    80005b4e:	fc440613          	addi	a2,s0,-60
    80005b52:	fd843583          	ld	a1,-40(s0)
    80005b56:	68a8                	ld	a0,80(s1)
    80005b58:	ffffc097          	auipc	ra,0xffffc
    80005b5c:	b1e080e7          	jalr	-1250(ra) # 80001676 <copyout>
    80005b60:	02054063          	bltz	a0,80005b80 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b64:	4691                	li	a3,4
    80005b66:	fc040613          	addi	a2,s0,-64
    80005b6a:	fd843583          	ld	a1,-40(s0)
    80005b6e:	0591                	addi	a1,a1,4
    80005b70:	68a8                	ld	a0,80(s1)
    80005b72:	ffffc097          	auipc	ra,0xffffc
    80005b76:	b04080e7          	jalr	-1276(ra) # 80001676 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b7a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b7c:	06055463          	bgez	a0,80005be4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b80:	fc442783          	lw	a5,-60(s0)
    80005b84:	07e9                	addi	a5,a5,26
    80005b86:	078e                	slli	a5,a5,0x3
    80005b88:	97a6                	add	a5,a5,s1
    80005b8a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b8e:	fc042783          	lw	a5,-64(s0)
    80005b92:	07e9                	addi	a5,a5,26
    80005b94:	078e                	slli	a5,a5,0x3
    80005b96:	94be                	add	s1,s1,a5
    80005b98:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b9c:	fd043503          	ld	a0,-48(s0)
    80005ba0:	fffff097          	auipc	ra,0xfffff
    80005ba4:	a30080e7          	jalr	-1488(ra) # 800045d0 <fileclose>
    fileclose(wf);
    80005ba8:	fc843503          	ld	a0,-56(s0)
    80005bac:	fffff097          	auipc	ra,0xfffff
    80005bb0:	a24080e7          	jalr	-1500(ra) # 800045d0 <fileclose>
    return -1;
    80005bb4:	57fd                	li	a5,-1
    80005bb6:	a03d                	j	80005be4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005bb8:	fc442783          	lw	a5,-60(s0)
    80005bbc:	0007c763          	bltz	a5,80005bca <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005bc0:	07e9                	addi	a5,a5,26
    80005bc2:	078e                	slli	a5,a5,0x3
    80005bc4:	97a6                	add	a5,a5,s1
    80005bc6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005bca:	fd043503          	ld	a0,-48(s0)
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	a02080e7          	jalr	-1534(ra) # 800045d0 <fileclose>
    fileclose(wf);
    80005bd6:	fc843503          	ld	a0,-56(s0)
    80005bda:	fffff097          	auipc	ra,0xfffff
    80005bde:	9f6080e7          	jalr	-1546(ra) # 800045d0 <fileclose>
    return -1;
    80005be2:	57fd                	li	a5,-1
}
    80005be4:	853e                	mv	a0,a5
    80005be6:	70e2                	ld	ra,56(sp)
    80005be8:	7442                	ld	s0,48(sp)
    80005bea:	74a2                	ld	s1,40(sp)
    80005bec:	6121                	addi	sp,sp,64
    80005bee:	8082                	ret

0000000080005bf0 <kernelvec>:
    80005bf0:	7111                	addi	sp,sp,-256
    80005bf2:	e006                	sd	ra,0(sp)
    80005bf4:	e40a                	sd	sp,8(sp)
    80005bf6:	e80e                	sd	gp,16(sp)
    80005bf8:	ec12                	sd	tp,24(sp)
    80005bfa:	f016                	sd	t0,32(sp)
    80005bfc:	f41a                	sd	t1,40(sp)
    80005bfe:	f81e                	sd	t2,48(sp)
    80005c00:	fc22                	sd	s0,56(sp)
    80005c02:	e0a6                	sd	s1,64(sp)
    80005c04:	e4aa                	sd	a0,72(sp)
    80005c06:	e8ae                	sd	a1,80(sp)
    80005c08:	ecb2                	sd	a2,88(sp)
    80005c0a:	f0b6                	sd	a3,96(sp)
    80005c0c:	f4ba                	sd	a4,104(sp)
    80005c0e:	f8be                	sd	a5,112(sp)
    80005c10:	fcc2                	sd	a6,120(sp)
    80005c12:	e146                	sd	a7,128(sp)
    80005c14:	e54a                	sd	s2,136(sp)
    80005c16:	e94e                	sd	s3,144(sp)
    80005c18:	ed52                	sd	s4,152(sp)
    80005c1a:	f156                	sd	s5,160(sp)
    80005c1c:	f55a                	sd	s6,168(sp)
    80005c1e:	f95e                	sd	s7,176(sp)
    80005c20:	fd62                	sd	s8,184(sp)
    80005c22:	e1e6                	sd	s9,192(sp)
    80005c24:	e5ea                	sd	s10,200(sp)
    80005c26:	e9ee                	sd	s11,208(sp)
    80005c28:	edf2                	sd	t3,216(sp)
    80005c2a:	f1f6                	sd	t4,224(sp)
    80005c2c:	f5fa                	sd	t5,232(sp)
    80005c2e:	f9fe                	sd	t6,240(sp)
    80005c30:	cdbfc0ef          	jal	ra,8000290a <kerneltrap>
    80005c34:	6082                	ld	ra,0(sp)
    80005c36:	6122                	ld	sp,8(sp)
    80005c38:	61c2                	ld	gp,16(sp)
    80005c3a:	7282                	ld	t0,32(sp)
    80005c3c:	7322                	ld	t1,40(sp)
    80005c3e:	73c2                	ld	t2,48(sp)
    80005c40:	7462                	ld	s0,56(sp)
    80005c42:	6486                	ld	s1,64(sp)
    80005c44:	6526                	ld	a0,72(sp)
    80005c46:	65c6                	ld	a1,80(sp)
    80005c48:	6666                	ld	a2,88(sp)
    80005c4a:	7686                	ld	a3,96(sp)
    80005c4c:	7726                	ld	a4,104(sp)
    80005c4e:	77c6                	ld	a5,112(sp)
    80005c50:	7866                	ld	a6,120(sp)
    80005c52:	688a                	ld	a7,128(sp)
    80005c54:	692a                	ld	s2,136(sp)
    80005c56:	69ca                	ld	s3,144(sp)
    80005c58:	6a6a                	ld	s4,152(sp)
    80005c5a:	7a8a                	ld	s5,160(sp)
    80005c5c:	7b2a                	ld	s6,168(sp)
    80005c5e:	7bca                	ld	s7,176(sp)
    80005c60:	7c6a                	ld	s8,184(sp)
    80005c62:	6c8e                	ld	s9,192(sp)
    80005c64:	6d2e                	ld	s10,200(sp)
    80005c66:	6dce                	ld	s11,208(sp)
    80005c68:	6e6e                	ld	t3,216(sp)
    80005c6a:	7e8e                	ld	t4,224(sp)
    80005c6c:	7f2e                	ld	t5,232(sp)
    80005c6e:	7fce                	ld	t6,240(sp)
    80005c70:	6111                	addi	sp,sp,256
    80005c72:	10200073          	sret
    80005c76:	00000013          	nop
    80005c7a:	00000013          	nop
    80005c7e:	0001                	nop

0000000080005c80 <timervec>:
    80005c80:	34051573          	csrrw	a0,mscratch,a0
    80005c84:	e10c                	sd	a1,0(a0)
    80005c86:	e510                	sd	a2,8(a0)
    80005c88:	e914                	sd	a3,16(a0)
    80005c8a:	6d0c                	ld	a1,24(a0)
    80005c8c:	7110                	ld	a2,32(a0)
    80005c8e:	6194                	ld	a3,0(a1)
    80005c90:	96b2                	add	a3,a3,a2
    80005c92:	e194                	sd	a3,0(a1)
    80005c94:	4589                	li	a1,2
    80005c96:	14459073          	csrw	sip,a1
    80005c9a:	6914                	ld	a3,16(a0)
    80005c9c:	6510                	ld	a2,8(a0)
    80005c9e:	610c                	ld	a1,0(a0)
    80005ca0:	34051573          	csrrw	a0,mscratch,a0
    80005ca4:	30200073          	mret
	...

0000000080005caa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005caa:	1141                	addi	sp,sp,-16
    80005cac:	e422                	sd	s0,8(sp)
    80005cae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cb0:	0c0007b7          	lui	a5,0xc000
    80005cb4:	4705                	li	a4,1
    80005cb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cb8:	c3d8                	sw	a4,4(a5)
}
    80005cba:	6422                	ld	s0,8(sp)
    80005cbc:	0141                	addi	sp,sp,16
    80005cbe:	8082                	ret

0000000080005cc0 <plicinithart>:

void
plicinithart(void)
{
    80005cc0:	1141                	addi	sp,sp,-16
    80005cc2:	e406                	sd	ra,8(sp)
    80005cc4:	e022                	sd	s0,0(sp)
    80005cc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cc8:	ffffc097          	auipc	ra,0xffffc
    80005ccc:	cc2080e7          	jalr	-830(ra) # 8000198a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cd0:	0085171b          	slliw	a4,a0,0x8
    80005cd4:	0c0027b7          	lui	a5,0xc002
    80005cd8:	97ba                	add	a5,a5,a4
    80005cda:	40200713          	li	a4,1026
    80005cde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ce2:	00d5151b          	slliw	a0,a0,0xd
    80005ce6:	0c2017b7          	lui	a5,0xc201
    80005cea:	97aa                	add	a5,a5,a0
    80005cec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005cf0:	60a2                	ld	ra,8(sp)
    80005cf2:	6402                	ld	s0,0(sp)
    80005cf4:	0141                	addi	sp,sp,16
    80005cf6:	8082                	ret

0000000080005cf8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cf8:	1141                	addi	sp,sp,-16
    80005cfa:	e406                	sd	ra,8(sp)
    80005cfc:	e022                	sd	s0,0(sp)
    80005cfe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d00:	ffffc097          	auipc	ra,0xffffc
    80005d04:	c8a080e7          	jalr	-886(ra) # 8000198a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d08:	00d5151b          	slliw	a0,a0,0xd
    80005d0c:	0c2017b7          	lui	a5,0xc201
    80005d10:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d12:	43c8                	lw	a0,4(a5)
    80005d14:	60a2                	ld	ra,8(sp)
    80005d16:	6402                	ld	s0,0(sp)
    80005d18:	0141                	addi	sp,sp,16
    80005d1a:	8082                	ret

0000000080005d1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d1c:	1101                	addi	sp,sp,-32
    80005d1e:	ec06                	sd	ra,24(sp)
    80005d20:	e822                	sd	s0,16(sp)
    80005d22:	e426                	sd	s1,8(sp)
    80005d24:	1000                	addi	s0,sp,32
    80005d26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d28:	ffffc097          	auipc	ra,0xffffc
    80005d2c:	c62080e7          	jalr	-926(ra) # 8000198a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d30:	00d5151b          	slliw	a0,a0,0xd
    80005d34:	0c2017b7          	lui	a5,0xc201
    80005d38:	97aa                	add	a5,a5,a0
    80005d3a:	c3c4                	sw	s1,4(a5)
}
    80005d3c:	60e2                	ld	ra,24(sp)
    80005d3e:	6442                	ld	s0,16(sp)
    80005d40:	64a2                	ld	s1,8(sp)
    80005d42:	6105                	addi	sp,sp,32
    80005d44:	8082                	ret

0000000080005d46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d46:	1141                	addi	sp,sp,-16
    80005d48:	e406                	sd	ra,8(sp)
    80005d4a:	e022                	sd	s0,0(sp)
    80005d4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d4e:	479d                	li	a5,7
    80005d50:	04a7cc63          	blt	a5,a0,80005da8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d54:	0001c797          	auipc	a5,0x1c
    80005d58:	34c78793          	addi	a5,a5,844 # 800220a0 <disk>
    80005d5c:	97aa                	add	a5,a5,a0
    80005d5e:	0187c783          	lbu	a5,24(a5)
    80005d62:	ebb9                	bnez	a5,80005db8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d64:	00451693          	slli	a3,a0,0x4
    80005d68:	0001c797          	auipc	a5,0x1c
    80005d6c:	33878793          	addi	a5,a5,824 # 800220a0 <disk>
    80005d70:	6398                	ld	a4,0(a5)
    80005d72:	9736                	add	a4,a4,a3
    80005d74:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d78:	6398                	ld	a4,0(a5)
    80005d7a:	9736                	add	a4,a4,a3
    80005d7c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d80:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d84:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d88:	97aa                	add	a5,a5,a0
    80005d8a:	4705                	li	a4,1
    80005d8c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005d90:	0001c517          	auipc	a0,0x1c
    80005d94:	32850513          	addi	a0,a0,808 # 800220b8 <disk+0x18>
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	336080e7          	jalr	822(ra) # 800020ce <wakeup>
}
    80005da0:	60a2                	ld	ra,8(sp)
    80005da2:	6402                	ld	s0,0(sp)
    80005da4:	0141                	addi	sp,sp,16
    80005da6:	8082                	ret
    panic("free_desc 1");
    80005da8:	00003517          	auipc	a0,0x3
    80005dac:	aa050513          	addi	a0,a0,-1376 # 80008848 <syscalls+0x2f0>
    80005db0:	ffffa097          	auipc	ra,0xffffa
    80005db4:	78c080e7          	jalr	1932(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005db8:	00003517          	auipc	a0,0x3
    80005dbc:	aa050513          	addi	a0,a0,-1376 # 80008858 <syscalls+0x300>
    80005dc0:	ffffa097          	auipc	ra,0xffffa
    80005dc4:	77c080e7          	jalr	1916(ra) # 8000053c <panic>

0000000080005dc8 <virtio_disk_init>:
{
    80005dc8:	1101                	addi	sp,sp,-32
    80005dca:	ec06                	sd	ra,24(sp)
    80005dcc:	e822                	sd	s0,16(sp)
    80005dce:	e426                	sd	s1,8(sp)
    80005dd0:	e04a                	sd	s2,0(sp)
    80005dd2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005dd4:	00003597          	auipc	a1,0x3
    80005dd8:	a9458593          	addi	a1,a1,-1388 # 80008868 <syscalls+0x310>
    80005ddc:	0001c517          	auipc	a0,0x1c
    80005de0:	3ec50513          	addi	a0,a0,1004 # 800221c8 <disk+0x128>
    80005de4:	ffffb097          	auipc	ra,0xffffb
    80005de8:	d5e080e7          	jalr	-674(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dec:	100017b7          	lui	a5,0x10001
    80005df0:	4398                	lw	a4,0(a5)
    80005df2:	2701                	sext.w	a4,a4
    80005df4:	747277b7          	lui	a5,0x74727
    80005df8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005dfc:	14f71b63          	bne	a4,a5,80005f52 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e00:	100017b7          	lui	a5,0x10001
    80005e04:	43dc                	lw	a5,4(a5)
    80005e06:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e08:	4709                	li	a4,2
    80005e0a:	14e79463          	bne	a5,a4,80005f52 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e0e:	100017b7          	lui	a5,0x10001
    80005e12:	479c                	lw	a5,8(a5)
    80005e14:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e16:	12e79e63          	bne	a5,a4,80005f52 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e1a:	100017b7          	lui	a5,0x10001
    80005e1e:	47d8                	lw	a4,12(a5)
    80005e20:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e22:	554d47b7          	lui	a5,0x554d4
    80005e26:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e2a:	12f71463          	bne	a4,a5,80005f52 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e2e:	100017b7          	lui	a5,0x10001
    80005e32:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e36:	4705                	li	a4,1
    80005e38:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e3a:	470d                	li	a4,3
    80005e3c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e3e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e40:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e44:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc57f>
    80005e48:	8f75                	and	a4,a4,a3
    80005e4a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e4c:	472d                	li	a4,11
    80005e4e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e50:	5bbc                	lw	a5,112(a5)
    80005e52:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e56:	8ba1                	andi	a5,a5,8
    80005e58:	10078563          	beqz	a5,80005f62 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e5c:	100017b7          	lui	a5,0x10001
    80005e60:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e64:	43fc                	lw	a5,68(a5)
    80005e66:	2781                	sext.w	a5,a5
    80005e68:	10079563          	bnez	a5,80005f72 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e6c:	100017b7          	lui	a5,0x10001
    80005e70:	5bdc                	lw	a5,52(a5)
    80005e72:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e74:	10078763          	beqz	a5,80005f82 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e78:	471d                	li	a4,7
    80005e7a:	10f77c63          	bgeu	a4,a5,80005f92 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e7e:	ffffb097          	auipc	ra,0xffffb
    80005e82:	c64080e7          	jalr	-924(ra) # 80000ae2 <kalloc>
    80005e86:	0001c497          	auipc	s1,0x1c
    80005e8a:	21a48493          	addi	s1,s1,538 # 800220a0 <disk>
    80005e8e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e90:	ffffb097          	auipc	ra,0xffffb
    80005e94:	c52080e7          	jalr	-942(ra) # 80000ae2 <kalloc>
    80005e98:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	c48080e7          	jalr	-952(ra) # 80000ae2 <kalloc>
    80005ea2:	87aa                	mv	a5,a0
    80005ea4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ea6:	6088                	ld	a0,0(s1)
    80005ea8:	cd6d                	beqz	a0,80005fa2 <virtio_disk_init+0x1da>
    80005eaa:	0001c717          	auipc	a4,0x1c
    80005eae:	1fe73703          	ld	a4,510(a4) # 800220a8 <disk+0x8>
    80005eb2:	cb65                	beqz	a4,80005fa2 <virtio_disk_init+0x1da>
    80005eb4:	c7fd                	beqz	a5,80005fa2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005eb6:	6605                	lui	a2,0x1
    80005eb8:	4581                	li	a1,0
    80005eba:	ffffb097          	auipc	ra,0xffffb
    80005ebe:	e14080e7          	jalr	-492(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ec2:	0001c497          	auipc	s1,0x1c
    80005ec6:	1de48493          	addi	s1,s1,478 # 800220a0 <disk>
    80005eca:	6605                	lui	a2,0x1
    80005ecc:	4581                	li	a1,0
    80005ece:	6488                	ld	a0,8(s1)
    80005ed0:	ffffb097          	auipc	ra,0xffffb
    80005ed4:	dfe080e7          	jalr	-514(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005ed8:	6605                	lui	a2,0x1
    80005eda:	4581                	li	a1,0
    80005edc:	6888                	ld	a0,16(s1)
    80005ede:	ffffb097          	auipc	ra,0xffffb
    80005ee2:	df0080e7          	jalr	-528(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ee6:	100017b7          	lui	a5,0x10001
    80005eea:	4721                	li	a4,8
    80005eec:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005eee:	4098                	lw	a4,0(s1)
    80005ef0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ef4:	40d8                	lw	a4,4(s1)
    80005ef6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005efa:	6498                	ld	a4,8(s1)
    80005efc:	0007069b          	sext.w	a3,a4
    80005f00:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f04:	9701                	srai	a4,a4,0x20
    80005f06:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f0a:	6898                	ld	a4,16(s1)
    80005f0c:	0007069b          	sext.w	a3,a4
    80005f10:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f14:	9701                	srai	a4,a4,0x20
    80005f16:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f1a:	4705                	li	a4,1
    80005f1c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f1e:	00e48c23          	sb	a4,24(s1)
    80005f22:	00e48ca3          	sb	a4,25(s1)
    80005f26:	00e48d23          	sb	a4,26(s1)
    80005f2a:	00e48da3          	sb	a4,27(s1)
    80005f2e:	00e48e23          	sb	a4,28(s1)
    80005f32:	00e48ea3          	sb	a4,29(s1)
    80005f36:	00e48f23          	sb	a4,30(s1)
    80005f3a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f3e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f42:	0727a823          	sw	s2,112(a5)
}
    80005f46:	60e2                	ld	ra,24(sp)
    80005f48:	6442                	ld	s0,16(sp)
    80005f4a:	64a2                	ld	s1,8(sp)
    80005f4c:	6902                	ld	s2,0(sp)
    80005f4e:	6105                	addi	sp,sp,32
    80005f50:	8082                	ret
    panic("could not find virtio disk");
    80005f52:	00003517          	auipc	a0,0x3
    80005f56:	92650513          	addi	a0,a0,-1754 # 80008878 <syscalls+0x320>
    80005f5a:	ffffa097          	auipc	ra,0xffffa
    80005f5e:	5e2080e7          	jalr	1506(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f62:	00003517          	auipc	a0,0x3
    80005f66:	93650513          	addi	a0,a0,-1738 # 80008898 <syscalls+0x340>
    80005f6a:	ffffa097          	auipc	ra,0xffffa
    80005f6e:	5d2080e7          	jalr	1490(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	94650513          	addi	a0,a0,-1722 # 800088b8 <syscalls+0x360>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5c2080e7          	jalr	1474(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	95650513          	addi	a0,a0,-1706 # 800088d8 <syscalls+0x380>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b2080e7          	jalr	1458(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	96650513          	addi	a0,a0,-1690 # 800088f8 <syscalls+0x3a0>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5a2080e7          	jalr	1442(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	97650513          	addi	a0,a0,-1674 # 80008918 <syscalls+0x3c0>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>

0000000080005fb2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fb2:	7159                	addi	sp,sp,-112
    80005fb4:	f486                	sd	ra,104(sp)
    80005fb6:	f0a2                	sd	s0,96(sp)
    80005fb8:	eca6                	sd	s1,88(sp)
    80005fba:	e8ca                	sd	s2,80(sp)
    80005fbc:	e4ce                	sd	s3,72(sp)
    80005fbe:	e0d2                	sd	s4,64(sp)
    80005fc0:	fc56                	sd	s5,56(sp)
    80005fc2:	f85a                	sd	s6,48(sp)
    80005fc4:	f45e                	sd	s7,40(sp)
    80005fc6:	f062                	sd	s8,32(sp)
    80005fc8:	ec66                	sd	s9,24(sp)
    80005fca:	e86a                	sd	s10,16(sp)
    80005fcc:	1880                	addi	s0,sp,112
    80005fce:	8a2a                	mv	s4,a0
    80005fd0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fd2:	00c52c83          	lw	s9,12(a0)
    80005fd6:	001c9c9b          	slliw	s9,s9,0x1
    80005fda:	1c82                	slli	s9,s9,0x20
    80005fdc:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005fe0:	0001c517          	auipc	a0,0x1c
    80005fe4:	1e850513          	addi	a0,a0,488 # 800221c8 <disk+0x128>
    80005fe8:	ffffb097          	auipc	ra,0xffffb
    80005fec:	bea080e7          	jalr	-1046(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80005ff0:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80005ff2:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005ff4:	0001cb17          	auipc	s6,0x1c
    80005ff8:	0acb0b13          	addi	s6,s6,172 # 800220a0 <disk>
  for(int i = 0; i < 3; i++){
    80005ffc:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ffe:	0001cc17          	auipc	s8,0x1c
    80006002:	1cac0c13          	addi	s8,s8,458 # 800221c8 <disk+0x128>
    80006006:	a095                	j	8000606a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006008:	00fb0733          	add	a4,s6,a5
    8000600c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006010:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006012:	0207c563          	bltz	a5,8000603c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006016:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006018:	0591                	addi	a1,a1,4
    8000601a:	05560d63          	beq	a2,s5,80006074 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000601e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006020:	0001c717          	auipc	a4,0x1c
    80006024:	08070713          	addi	a4,a4,128 # 800220a0 <disk>
    80006028:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000602a:	01874683          	lbu	a3,24(a4)
    8000602e:	fee9                	bnez	a3,80006008 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006030:	2785                	addiw	a5,a5,1
    80006032:	0705                	addi	a4,a4,1
    80006034:	fe979be3          	bne	a5,s1,8000602a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006038:	57fd                	li	a5,-1
    8000603a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000603c:	00c05e63          	blez	a2,80006058 <virtio_disk_rw+0xa6>
    80006040:	060a                	slli	a2,a2,0x2
    80006042:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006046:	0009a503          	lw	a0,0(s3)
    8000604a:	00000097          	auipc	ra,0x0
    8000604e:	cfc080e7          	jalr	-772(ra) # 80005d46 <free_desc>
      for(int j = 0; j < i; j++)
    80006052:	0991                	addi	s3,s3,4
    80006054:	ffa999e3          	bne	s3,s10,80006046 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006058:	85e2                	mv	a1,s8
    8000605a:	0001c517          	auipc	a0,0x1c
    8000605e:	05e50513          	addi	a0,a0,94 # 800220b8 <disk+0x18>
    80006062:	ffffc097          	auipc	ra,0xffffc
    80006066:	008080e7          	jalr	8(ra) # 8000206a <sleep>
  for(int i = 0; i < 3; i++){
    8000606a:	f9040993          	addi	s3,s0,-112
{
    8000606e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006070:	864a                	mv	a2,s2
    80006072:	b775                	j	8000601e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006074:	f9042503          	lw	a0,-112(s0)
    80006078:	00a50713          	addi	a4,a0,10
    8000607c:	0712                	slli	a4,a4,0x4

  if(write)
    8000607e:	0001c797          	auipc	a5,0x1c
    80006082:	02278793          	addi	a5,a5,34 # 800220a0 <disk>
    80006086:	00e786b3          	add	a3,a5,a4
    8000608a:	01703633          	snez	a2,s7
    8000608e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006090:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006094:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006098:	f6070613          	addi	a2,a4,-160
    8000609c:	6394                	ld	a3,0(a5)
    8000609e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060a0:	00870593          	addi	a1,a4,8
    800060a4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060a6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060a8:	0007b803          	ld	a6,0(a5)
    800060ac:	9642                	add	a2,a2,a6
    800060ae:	46c1                	li	a3,16
    800060b0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060b2:	4585                	li	a1,1
    800060b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800060b8:	f9442683          	lw	a3,-108(s0)
    800060bc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060c0:	0692                	slli	a3,a3,0x4
    800060c2:	9836                	add	a6,a6,a3
    800060c4:	058a0613          	addi	a2,s4,88
    800060c8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800060cc:	0007b803          	ld	a6,0(a5)
    800060d0:	96c2                	add	a3,a3,a6
    800060d2:	40000613          	li	a2,1024
    800060d6:	c690                	sw	a2,8(a3)
  if(write)
    800060d8:	001bb613          	seqz	a2,s7
    800060dc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060e0:	00166613          	ori	a2,a2,1
    800060e4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800060e8:	f9842603          	lw	a2,-104(s0)
    800060ec:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800060f0:	00250693          	addi	a3,a0,2
    800060f4:	0692                	slli	a3,a3,0x4
    800060f6:	96be                	add	a3,a3,a5
    800060f8:	58fd                	li	a7,-1
    800060fa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060fe:	0612                	slli	a2,a2,0x4
    80006100:	9832                	add	a6,a6,a2
    80006102:	f9070713          	addi	a4,a4,-112
    80006106:	973e                	add	a4,a4,a5
    80006108:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000610c:	6398                	ld	a4,0(a5)
    8000610e:	9732                	add	a4,a4,a2
    80006110:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006112:	4609                	li	a2,2
    80006114:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006118:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000611c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006120:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006124:	6794                	ld	a3,8(a5)
    80006126:	0026d703          	lhu	a4,2(a3)
    8000612a:	8b1d                	andi	a4,a4,7
    8000612c:	0706                	slli	a4,a4,0x1
    8000612e:	96ba                	add	a3,a3,a4
    80006130:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006134:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006138:	6798                	ld	a4,8(a5)
    8000613a:	00275783          	lhu	a5,2(a4)
    8000613e:	2785                	addiw	a5,a5,1
    80006140:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006144:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006148:	100017b7          	lui	a5,0x10001
    8000614c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006150:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006154:	0001c917          	auipc	s2,0x1c
    80006158:	07490913          	addi	s2,s2,116 # 800221c8 <disk+0x128>
  while(b->disk == 1) {
    8000615c:	4485                	li	s1,1
    8000615e:	00b79c63          	bne	a5,a1,80006176 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006162:	85ca                	mv	a1,s2
    80006164:	8552                	mv	a0,s4
    80006166:	ffffc097          	auipc	ra,0xffffc
    8000616a:	f04080e7          	jalr	-252(ra) # 8000206a <sleep>
  while(b->disk == 1) {
    8000616e:	004a2783          	lw	a5,4(s4)
    80006172:	fe9788e3          	beq	a5,s1,80006162 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006176:	f9042903          	lw	s2,-112(s0)
    8000617a:	00290713          	addi	a4,s2,2
    8000617e:	0712                	slli	a4,a4,0x4
    80006180:	0001c797          	auipc	a5,0x1c
    80006184:	f2078793          	addi	a5,a5,-224 # 800220a0 <disk>
    80006188:	97ba                	add	a5,a5,a4
    8000618a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000618e:	0001c997          	auipc	s3,0x1c
    80006192:	f1298993          	addi	s3,s3,-238 # 800220a0 <disk>
    80006196:	00491713          	slli	a4,s2,0x4
    8000619a:	0009b783          	ld	a5,0(s3)
    8000619e:	97ba                	add	a5,a5,a4
    800061a0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061a4:	854a                	mv	a0,s2
    800061a6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061aa:	00000097          	auipc	ra,0x0
    800061ae:	b9c080e7          	jalr	-1124(ra) # 80005d46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061b2:	8885                	andi	s1,s1,1
    800061b4:	f0ed                	bnez	s1,80006196 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061b6:	0001c517          	auipc	a0,0x1c
    800061ba:	01250513          	addi	a0,a0,18 # 800221c8 <disk+0x128>
    800061be:	ffffb097          	auipc	ra,0xffffb
    800061c2:	ac8080e7          	jalr	-1336(ra) # 80000c86 <release>
}
    800061c6:	70a6                	ld	ra,104(sp)
    800061c8:	7406                	ld	s0,96(sp)
    800061ca:	64e6                	ld	s1,88(sp)
    800061cc:	6946                	ld	s2,80(sp)
    800061ce:	69a6                	ld	s3,72(sp)
    800061d0:	6a06                	ld	s4,64(sp)
    800061d2:	7ae2                	ld	s5,56(sp)
    800061d4:	7b42                	ld	s6,48(sp)
    800061d6:	7ba2                	ld	s7,40(sp)
    800061d8:	7c02                	ld	s8,32(sp)
    800061da:	6ce2                	ld	s9,24(sp)
    800061dc:	6d42                	ld	s10,16(sp)
    800061de:	6165                	addi	sp,sp,112
    800061e0:	8082                	ret

00000000800061e2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061e2:	1101                	addi	sp,sp,-32
    800061e4:	ec06                	sd	ra,24(sp)
    800061e6:	e822                	sd	s0,16(sp)
    800061e8:	e426                	sd	s1,8(sp)
    800061ea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061ec:	0001c497          	auipc	s1,0x1c
    800061f0:	eb448493          	addi	s1,s1,-332 # 800220a0 <disk>
    800061f4:	0001c517          	auipc	a0,0x1c
    800061f8:	fd450513          	addi	a0,a0,-44 # 800221c8 <disk+0x128>
    800061fc:	ffffb097          	auipc	ra,0xffffb
    80006200:	9d6080e7          	jalr	-1578(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006204:	10001737          	lui	a4,0x10001
    80006208:	533c                	lw	a5,96(a4)
    8000620a:	8b8d                	andi	a5,a5,3
    8000620c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000620e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006212:	689c                	ld	a5,16(s1)
    80006214:	0204d703          	lhu	a4,32(s1)
    80006218:	0027d783          	lhu	a5,2(a5)
    8000621c:	04f70863          	beq	a4,a5,8000626c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006220:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006224:	6898                	ld	a4,16(s1)
    80006226:	0204d783          	lhu	a5,32(s1)
    8000622a:	8b9d                	andi	a5,a5,7
    8000622c:	078e                	slli	a5,a5,0x3
    8000622e:	97ba                	add	a5,a5,a4
    80006230:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006232:	00278713          	addi	a4,a5,2
    80006236:	0712                	slli	a4,a4,0x4
    80006238:	9726                	add	a4,a4,s1
    8000623a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000623e:	e721                	bnez	a4,80006286 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006240:	0789                	addi	a5,a5,2
    80006242:	0792                	slli	a5,a5,0x4
    80006244:	97a6                	add	a5,a5,s1
    80006246:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006248:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000624c:	ffffc097          	auipc	ra,0xffffc
    80006250:	e82080e7          	jalr	-382(ra) # 800020ce <wakeup>

    disk.used_idx += 1;
    80006254:	0204d783          	lhu	a5,32(s1)
    80006258:	2785                	addiw	a5,a5,1
    8000625a:	17c2                	slli	a5,a5,0x30
    8000625c:	93c1                	srli	a5,a5,0x30
    8000625e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006262:	6898                	ld	a4,16(s1)
    80006264:	00275703          	lhu	a4,2(a4)
    80006268:	faf71ce3          	bne	a4,a5,80006220 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000626c:	0001c517          	auipc	a0,0x1c
    80006270:	f5c50513          	addi	a0,a0,-164 # 800221c8 <disk+0x128>
    80006274:	ffffb097          	auipc	ra,0xffffb
    80006278:	a12080e7          	jalr	-1518(ra) # 80000c86 <release>
}
    8000627c:	60e2                	ld	ra,24(sp)
    8000627e:	6442                	ld	s0,16(sp)
    80006280:	64a2                	ld	s1,8(sp)
    80006282:	6105                	addi	sp,sp,32
    80006284:	8082                	ret
      panic("virtio_disk_intr status");
    80006286:	00002517          	auipc	a0,0x2
    8000628a:	6aa50513          	addi	a0,a0,1706 # 80008930 <syscalls+0x3d8>
    8000628e:	ffffa097          	auipc	ra,0xffffa
    80006292:	2ae080e7          	jalr	686(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
