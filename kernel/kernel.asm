
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a4010113          	addi	sp,sp,-1472 # 80008a40 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8ae70713          	addi	a4,a4,-1874 # 80008900 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	dbc78793          	addi	a5,a5,-580 # 80005e20 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc68f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	566080e7          	jalr	1382(ra) # 80002692 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
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
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8b650513          	addi	a0,a0,-1866 # 80010a40 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8a648493          	addi	s1,s1,-1882 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	93690913          	addi	s2,s2,-1738 # 80010ad8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7fc080e7          	jalr	2044(ra) # 800019bc <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	1c2080e7          	jalr	450(ra) # 8000238a <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f00080e7          	jalr	-256(ra) # 800020d6 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	42a080e7          	jalr	1066(ra) # 8000263c <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	81a50513          	addi	a0,a0,-2022 # 80010a40 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	80450513          	addi	a0,a0,-2044 # 80010a40 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72323          	sw	a5,-1946(a4) # 80010ad8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	77450513          	addi	a0,a0,1908 # 80010a40 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	3f6080e7          	jalr	1014(ra) # 800026e8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	74650513          	addi	a0,a0,1862 # 80010a40 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	72270713          	addi	a4,a4,1826 # 80010a40 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	6f878793          	addi	a5,a5,1784 # 80010a40 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7627a783          	lw	a5,1890(a5) # 80010ad8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6b670713          	addi	a4,a4,1718 # 80010a40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6a648493          	addi	s1,s1,1702 # 80010a40 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	66a70713          	addi	a4,a4,1642 # 80010a40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72a23          	sw	a5,1780(a4) # 80010ae0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	62e78793          	addi	a5,a5,1582 # 80010a40 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7a323          	sw	a2,1702(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	69a50513          	addi	a0,a0,1690 # 80010ad8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	cf4080e7          	jalr	-780(ra) # 8000213a <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5e050513          	addi	a0,a0,1504 # 80010a40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	b6078793          	addi	a5,a5,-1184 # 80020fd8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5a07ab23          	sw	zero,1462(a5) # 80010b00 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b8450513          	addi	a0,a0,-1148 # 800080f0 <digits+0xb0>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72123          	sw	a5,834(a4) # 800088c0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	546dad83          	lw	s11,1350(s11) # 80010b00 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	4f050513          	addi	a0,a0,1264 # 80010ae8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	39250513          	addi	a0,a0,914 # 80010ae8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	37648493          	addi	s1,s1,886 # 80010ae8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	33650513          	addi	a0,a0,822 # 80010b08 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0c27a783          	lw	a5,194(a5) # 800088c0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0927b783          	ld	a5,146(a5) # 800088c8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	09273703          	ld	a4,146(a4) # 800088d0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2a8a0a13          	addi	s4,s4,680 # 80010b08 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	06048493          	addi	s1,s1,96 # 800088c8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	06098993          	addi	s3,s3,96 # 800088d0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	8a8080e7          	jalr	-1880(ra) # 8000213a <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	23a50513          	addi	a0,a0,570 # 80010b08 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fe27a783          	lw	a5,-30(a5) # 800088c0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fe873703          	ld	a4,-24(a4) # 800088d0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fd87b783          	ld	a5,-40(a5) # 800088c8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	20c98993          	addi	s3,s3,524 # 80010b08 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fc448493          	addi	s1,s1,-60 # 800088c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fc490913          	addi	s2,s2,-60 # 800088d0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	7ba080e7          	jalr	1978(ra) # 800020d6 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1d648493          	addi	s1,s1,470 # 80010b08 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7b523          	sd	a4,-118(a5) # 800088d0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	14c48493          	addi	s1,s1,332 # 80010b08 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00021797          	auipc	a5,0x21
    80000a02:	77278793          	addi	a5,a5,1906 # 80022170 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	12290913          	addi	s2,s2,290 # 80010b40 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	08650513          	addi	a0,a0,134 # 80010b40 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	6a250513          	addi	a0,a0,1698 # 80022170 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	05048493          	addi	s1,s1,80 # 80010b40 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	03850513          	addi	a0,a0,56 # 80010b40 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	00c50513          	addi	a0,a0,12 # 80010b40 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e30080e7          	jalr	-464(ra) # 800019a0 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dfe080e7          	jalr	-514(ra) # 800019a0 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	df2080e7          	jalr	-526(ra) # 800019a0 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dda080e7          	jalr	-550(ra) # 800019a0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d9a080e7          	jalr	-614(ra) # 800019a0 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d6e080e7          	jalr	-658(ra) # 800019a0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b10080e7          	jalr	-1264(ra) # 80001990 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a5070713          	addi	a4,a4,-1456 # 800088d8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	af4080e7          	jalr	-1292(ra) # 80001990 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	23a50513          	addi	a0,a0,570 # 800080e0 <digits+0xa0>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0e8080e7          	jalr	232(ra) # 80000f9e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	96a080e7          	jalr	-1686(ra) # 80002828 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	f9a080e7          	jalr	-102(ra) # 80005e60 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	056080e7          	jalr	86(ra) # 80001f24 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	20a50513          	addi	a0,a0,522 # 800080f0 <digits+0xb0>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("=== Welcome to xv6-cos ===\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("The xv6-cos kernel is booting\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1ba50513          	addi	a0,a0,442 # 800080c0 <digits+0x80>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    printf("\n");
    80000f16:	00007517          	auipc	a0,0x7
    80000f1a:	1da50513          	addi	a0,a0,474 # 800080f0 <digits+0xb0>
    80000f1e:	fffff097          	auipc	ra,0xfffff
    80000f22:	66a080e7          	jalr	1642(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	b84080e7          	jalr	-1148(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f2e:	00000097          	auipc	ra,0x0
    80000f32:	326080e7          	jalr	806(ra) # 80001254 <kvminit>
    kvminithart();   // turn on paging
    80000f36:	00000097          	auipc	ra,0x0
    80000f3a:	068080e7          	jalr	104(ra) # 80000f9e <kvminithart>
    procinit();      // process table
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	99e080e7          	jalr	-1634(ra) # 800018dc <procinit>
    trapinit();      // trap vectors
    80000f46:	00002097          	auipc	ra,0x2
    80000f4a:	8ba080e7          	jalr	-1862(ra) # 80002800 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4e:	00002097          	auipc	ra,0x2
    80000f52:	8da080e7          	jalr	-1830(ra) # 80002828 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f56:	00005097          	auipc	ra,0x5
    80000f5a:	ef4080e7          	jalr	-268(ra) # 80005e4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5e:	00005097          	auipc	ra,0x5
    80000f62:	f02080e7          	jalr	-254(ra) # 80005e60 <plicinithart>
    binit();         // buffer cache
    80000f66:	00002097          	auipc	ra,0x2
    80000f6a:	0a8080e7          	jalr	168(ra) # 8000300e <binit>
    iinit();         // inode table
    80000f6e:	00002097          	auipc	ra,0x2
    80000f72:	74c080e7          	jalr	1868(ra) # 800036ba <iinit>
    fileinit();      // file table
    80000f76:	00003097          	auipc	ra,0x3
    80000f7a:	6ea080e7          	jalr	1770(ra) # 80004660 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	fea080e7          	jalr	-22(ra) # 80005f68 <virtio_disk_init>
    userinit();      // first user process
    80000f86:	00001097          	auipc	ra,0x1
    80000f8a:	d22080e7          	jalr	-734(ra) # 80001ca8 <userinit>
    __sync_synchronize();
    80000f8e:	0ff0000f          	fence
    started = 1;
    80000f92:	4785                	li	a5,1
    80000f94:	00008717          	auipc	a4,0x8
    80000f98:	94f72223          	sw	a5,-1724(a4) # 800088d8 <started>
    80000f9c:	bf0d                	j	80000ece <main+0x56>

0000000080000f9e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f9e:	1141                	addi	sp,sp,-16
    80000fa0:	e422                	sd	s0,8(sp)
    80000fa2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa8:	00008797          	auipc	a5,0x8
    80000fac:	9387b783          	ld	a5,-1736(a5) # 800088e0 <kernel_pagetable>
    80000fb0:	83b1                	srli	a5,a5,0xc
    80000fb2:	577d                	li	a4,-1
    80000fb4:	177e                	slli	a4,a4,0x3f
    80000fb6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fbc:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fc0:	6422                	ld	s0,8(sp)
    80000fc2:	0141                	addi	sp,sp,16
    80000fc4:	8082                	ret

0000000080000fc6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc6:	7139                	addi	sp,sp,-64
    80000fc8:	fc06                	sd	ra,56(sp)
    80000fca:	f822                	sd	s0,48(sp)
    80000fcc:	f426                	sd	s1,40(sp)
    80000fce:	f04a                	sd	s2,32(sp)
    80000fd0:	ec4e                	sd	s3,24(sp)
    80000fd2:	e852                	sd	s4,16(sp)
    80000fd4:	e456                	sd	s5,8(sp)
    80000fd6:	e05a                	sd	s6,0(sp)
    80000fd8:	0080                	addi	s0,sp,64
    80000fda:	84aa                	mv	s1,a0
    80000fdc:	89ae                	mv	s3,a1
    80000fde:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe0:	57fd                	li	a5,-1
    80000fe2:	83e9                	srli	a5,a5,0x1a
    80000fe4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe8:	04b7f263          	bgeu	a5,a1,8000102c <walk+0x66>
    panic("walk");
    80000fec:	00007517          	auipc	a0,0x7
    80000ff0:	10c50513          	addi	a0,a0,268 # 800080f8 <digits+0xb8>
    80000ff4:	fffff097          	auipc	ra,0xfffff
    80000ff8:	54a080e7          	jalr	1354(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffc:	060a8663          	beqz	s5,80001068 <walk+0xa2>
    80001000:	00000097          	auipc	ra,0x0
    80001004:	ae6080e7          	jalr	-1306(ra) # 80000ae6 <kalloc>
    80001008:	84aa                	mv	s1,a0
    8000100a:	c529                	beqz	a0,80001054 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100c:	6605                	lui	a2,0x1
    8000100e:	4581                	li	a1,0
    80001010:	00000097          	auipc	ra,0x0
    80001014:	cc2080e7          	jalr	-830(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001018:	00c4d793          	srli	a5,s1,0xc
    8000101c:	07aa                	slli	a5,a5,0xa
    8000101e:	0017e793          	ori	a5,a5,1
    80001022:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001026:	3a5d                	addiw	s4,s4,-9
    80001028:	036a0063          	beq	s4,s6,80001048 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102c:	0149d933          	srl	s2,s3,s4
    80001030:	1ff97913          	andi	s2,s2,511
    80001034:	090e                	slli	s2,s2,0x3
    80001036:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001038:	00093483          	ld	s1,0(s2)
    8000103c:	0014f793          	andi	a5,s1,1
    80001040:	dfd5                	beqz	a5,80000ffc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001042:	80a9                	srli	s1,s1,0xa
    80001044:	04b2                	slli	s1,s1,0xc
    80001046:	b7c5                	j	80001026 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001048:	00c9d513          	srli	a0,s3,0xc
    8000104c:	1ff57513          	andi	a0,a0,511
    80001050:	050e                	slli	a0,a0,0x3
    80001052:	9526                	add	a0,a0,s1
}
    80001054:	70e2                	ld	ra,56(sp)
    80001056:	7442                	ld	s0,48(sp)
    80001058:	74a2                	ld	s1,40(sp)
    8000105a:	7902                	ld	s2,32(sp)
    8000105c:	69e2                	ld	s3,24(sp)
    8000105e:	6a42                	ld	s4,16(sp)
    80001060:	6aa2                	ld	s5,8(sp)
    80001062:	6b02                	ld	s6,0(sp)
    80001064:	6121                	addi	sp,sp,64
    80001066:	8082                	ret
        return 0;
    80001068:	4501                	li	a0,0
    8000106a:	b7ed                	j	80001054 <walk+0x8e>

000000008000106c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106c:	57fd                	li	a5,-1
    8000106e:	83e9                	srli	a5,a5,0x1a
    80001070:	00b7f463          	bgeu	a5,a1,80001078 <walkaddr+0xc>
    return 0;
    80001074:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001076:	8082                	ret
{
    80001078:	1141                	addi	sp,sp,-16
    8000107a:	e406                	sd	ra,8(sp)
    8000107c:	e022                	sd	s0,0(sp)
    8000107e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001080:	4601                	li	a2,0
    80001082:	00000097          	auipc	ra,0x0
    80001086:	f44080e7          	jalr	-188(ra) # 80000fc6 <walk>
  if(pte == 0)
    8000108a:	c105                	beqz	a0,800010aa <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000108e:	0117f693          	andi	a3,a5,17
    80001092:	4745                	li	a4,17
    return 0;
    80001094:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001096:	00e68663          	beq	a3,a4,800010a2 <walkaddr+0x36>
}
    8000109a:	60a2                	ld	ra,8(sp)
    8000109c:	6402                	ld	s0,0(sp)
    8000109e:	0141                	addi	sp,sp,16
    800010a0:	8082                	ret
  pa = PTE2PA(*pte);
    800010a2:	00a7d513          	srli	a0,a5,0xa
    800010a6:	0532                	slli	a0,a0,0xc
  return pa;
    800010a8:	bfcd                	j	8000109a <walkaddr+0x2e>
    return 0;
    800010aa:	4501                	li	a0,0
    800010ac:	b7fd                	j	8000109a <walkaddr+0x2e>

00000000800010ae <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ae:	715d                	addi	sp,sp,-80
    800010b0:	e486                	sd	ra,72(sp)
    800010b2:	e0a2                	sd	s0,64(sp)
    800010b4:	fc26                	sd	s1,56(sp)
    800010b6:	f84a                	sd	s2,48(sp)
    800010b8:	f44e                	sd	s3,40(sp)
    800010ba:	f052                	sd	s4,32(sp)
    800010bc:	ec56                	sd	s5,24(sp)
    800010be:	e85a                	sd	s6,16(sp)
    800010c0:	e45e                	sd	s7,8(sp)
    800010c2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c4:	c639                	beqz	a2,80001112 <mappages+0x64>
    800010c6:	8aaa                	mv	s5,a0
    800010c8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ca:	77fd                	lui	a5,0xfffff
    800010cc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d0:	15fd                	addi	a1,a1,-1
    800010d2:	00c589b3          	add	s3,a1,a2
    800010d6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010da:	8952                	mv	s2,s4
    800010dc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e0:	6b85                	lui	s7,0x1
    800010e2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010e6:	4605                	li	a2,1
    800010e8:	85ca                	mv	a1,s2
    800010ea:	8556                	mv	a0,s5
    800010ec:	00000097          	auipc	ra,0x0
    800010f0:	eda080e7          	jalr	-294(ra) # 80000fc6 <walk>
    800010f4:	cd1d                	beqz	a0,80001132 <mappages+0x84>
    if(*pte & PTE_V)
    800010f6:	611c                	ld	a5,0(a0)
    800010f8:	8b85                	andi	a5,a5,1
    800010fa:	e785                	bnez	a5,80001122 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010fc:	80b1                	srli	s1,s1,0xc
    800010fe:	04aa                	slli	s1,s1,0xa
    80001100:	0164e4b3          	or	s1,s1,s6
    80001104:	0014e493          	ori	s1,s1,1
    80001108:	e104                	sd	s1,0(a0)
    if(a == last)
    8000110a:	05390063          	beq	s2,s3,8000114a <mappages+0x9c>
    a += PGSIZE;
    8000110e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001110:	bfc9                	j	800010e2 <mappages+0x34>
    panic("mappages: size");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fee50513          	addi	a0,a0,-18 # 80008100 <digits+0xc0>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001122:	00007517          	auipc	a0,0x7
    80001126:	fee50513          	addi	a0,a0,-18 # 80008110 <digits+0xd0>
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	414080e7          	jalr	1044(ra) # 8000053e <panic>
      return -1;
    80001132:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001134:	60a6                	ld	ra,72(sp)
    80001136:	6406                	ld	s0,64(sp)
    80001138:	74e2                	ld	s1,56(sp)
    8000113a:	7942                	ld	s2,48(sp)
    8000113c:	79a2                	ld	s3,40(sp)
    8000113e:	7a02                	ld	s4,32(sp)
    80001140:	6ae2                	ld	s5,24(sp)
    80001142:	6b42                	ld	s6,16(sp)
    80001144:	6ba2                	ld	s7,8(sp)
    80001146:	6161                	addi	sp,sp,80
    80001148:	8082                	ret
  return 0;
    8000114a:	4501                	li	a0,0
    8000114c:	b7e5                	j	80001134 <mappages+0x86>

000000008000114e <kvmmap>:
{
    8000114e:	1141                	addi	sp,sp,-16
    80001150:	e406                	sd	ra,8(sp)
    80001152:	e022                	sd	s0,0(sp)
    80001154:	0800                	addi	s0,sp,16
    80001156:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001158:	86b2                	mv	a3,a2
    8000115a:	863e                	mv	a2,a5
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	f52080e7          	jalr	-174(ra) # 800010ae <mappages>
    80001164:	e509                	bnez	a0,8000116e <kvmmap+0x20>
}
    80001166:	60a2                	ld	ra,8(sp)
    80001168:	6402                	ld	s0,0(sp)
    8000116a:	0141                	addi	sp,sp,16
    8000116c:	8082                	ret
    panic("kvmmap");
    8000116e:	00007517          	auipc	a0,0x7
    80001172:	fb250513          	addi	a0,a0,-78 # 80008120 <digits+0xe0>
    80001176:	fffff097          	auipc	ra,0xfffff
    8000117a:	3c8080e7          	jalr	968(ra) # 8000053e <panic>

000000008000117e <kvmmake>:
{
    8000117e:	1101                	addi	sp,sp,-32
    80001180:	ec06                	sd	ra,24(sp)
    80001182:	e822                	sd	s0,16(sp)
    80001184:	e426                	sd	s1,8(sp)
    80001186:	e04a                	sd	s2,0(sp)
    80001188:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	95c080e7          	jalr	-1700(ra) # 80000ae6 <kalloc>
    80001192:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001194:	6605                	lui	a2,0x1
    80001196:	4581                	li	a1,0
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	b3a080e7          	jalr	-1222(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10000637          	lui	a2,0x10000
    800011a8:	100005b7          	lui	a1,0x10000
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	fa0080e7          	jalr	-96(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	6685                	lui	a3,0x1
    800011ba:	10001637          	lui	a2,0x10001
    800011be:	100015b7          	lui	a1,0x10001
    800011c2:	8526                	mv	a0,s1
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	f8a080e7          	jalr	-118(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011cc:	4719                	li	a4,6
    800011ce:	004006b7          	lui	a3,0x400
    800011d2:	0c000637          	lui	a2,0xc000
    800011d6:	0c0005b7          	lui	a1,0xc000
    800011da:	8526                	mv	a0,s1
    800011dc:	00000097          	auipc	ra,0x0
    800011e0:	f72080e7          	jalr	-142(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e4:	00007917          	auipc	s2,0x7
    800011e8:	e1c90913          	addi	s2,s2,-484 # 80008000 <etext>
    800011ec:	4729                	li	a4,10
    800011ee:	80007697          	auipc	a3,0x80007
    800011f2:	e1268693          	addi	a3,a3,-494 # 8000 <_entry-0x7fff8000>
    800011f6:	4605                	li	a2,1
    800011f8:	067e                	slli	a2,a2,0x1f
    800011fa:	85b2                	mv	a1,a2
    800011fc:	8526                	mv	a0,s1
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	f50080e7          	jalr	-176(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001206:	4719                	li	a4,6
    80001208:	46c5                	li	a3,17
    8000120a:	06ee                	slli	a3,a3,0x1b
    8000120c:	412686b3          	sub	a3,a3,s2
    80001210:	864a                	mv	a2,s2
    80001212:	85ca                	mv	a1,s2
    80001214:	8526                	mv	a0,s1
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	f38080e7          	jalr	-200(ra) # 8000114e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000121e:	4729                	li	a4,10
    80001220:	6685                	lui	a3,0x1
    80001222:	00006617          	auipc	a2,0x6
    80001226:	dde60613          	addi	a2,a2,-546 # 80007000 <_trampoline>
    8000122a:	040005b7          	lui	a1,0x4000
    8000122e:	15fd                	addi	a1,a1,-1
    80001230:	05b2                	slli	a1,a1,0xc
    80001232:	8526                	mv	a0,s1
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f1a080e7          	jalr	-230(ra) # 8000114e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123c:	8526                	mv	a0,s1
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	608080e7          	jalr	1544(ra) # 80001846 <proc_mapstacks>
}
    80001246:	8526                	mv	a0,s1
    80001248:	60e2                	ld	ra,24(sp)
    8000124a:	6442                	ld	s0,16(sp)
    8000124c:	64a2                	ld	s1,8(sp)
    8000124e:	6902                	ld	s2,0(sp)
    80001250:	6105                	addi	sp,sp,32
    80001252:	8082                	ret

0000000080001254 <kvminit>:
{
    80001254:	1141                	addi	sp,sp,-16
    80001256:	e406                	sd	ra,8(sp)
    80001258:	e022                	sd	s0,0(sp)
    8000125a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	f22080e7          	jalr	-222(ra) # 8000117e <kvmmake>
    80001264:	00007797          	auipc	a5,0x7
    80001268:	66a7be23          	sd	a0,1660(a5) # 800088e0 <kernel_pagetable>
}
    8000126c:	60a2                	ld	ra,8(sp)
    8000126e:	6402                	ld	s0,0(sp)
    80001270:	0141                	addi	sp,sp,16
    80001272:	8082                	ret

0000000080001274 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001274:	715d                	addi	sp,sp,-80
    80001276:	e486                	sd	ra,72(sp)
    80001278:	e0a2                	sd	s0,64(sp)
    8000127a:	fc26                	sd	s1,56(sp)
    8000127c:	f84a                	sd	s2,48(sp)
    8000127e:	f44e                	sd	s3,40(sp)
    80001280:	f052                	sd	s4,32(sp)
    80001282:	ec56                	sd	s5,24(sp)
    80001284:	e85a                	sd	s6,16(sp)
    80001286:	e45e                	sd	s7,8(sp)
    80001288:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128a:	03459793          	slli	a5,a1,0x34
    8000128e:	e795                	bnez	a5,800012ba <uvmunmap+0x46>
    80001290:	8a2a                	mv	s4,a0
    80001292:	892e                	mv	s2,a1
    80001294:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001296:	0632                	slli	a2,a2,0xc
    80001298:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000129e:	6b05                	lui	s6,0x1
    800012a0:	0735e263          	bltu	a1,s3,80001304 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a4:	60a6                	ld	ra,72(sp)
    800012a6:	6406                	ld	s0,64(sp)
    800012a8:	74e2                	ld	s1,56(sp)
    800012aa:	7942                	ld	s2,48(sp)
    800012ac:	79a2                	ld	s3,40(sp)
    800012ae:	7a02                	ld	s4,32(sp)
    800012b0:	6ae2                	ld	s5,24(sp)
    800012b2:	6b42                	ld	s6,16(sp)
    800012b4:	6ba2                	ld	s7,8(sp)
    800012b6:	6161                	addi	sp,sp,80
    800012b8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e6e50513          	addi	a0,a0,-402 # 80008128 <digits+0xe8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e7650513          	addi	a0,a0,-394 # 80008140 <digits+0x100>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e7650513          	addi	a0,a0,-394 # 80008150 <digits+0x110>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012ea:	00007517          	auipc	a0,0x7
    800012ee:	e7e50513          	addi	a0,a0,-386 # 80008168 <digits+0x128>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	24c080e7          	jalr	588(ra) # 8000053e <panic>
    *pte = 0;
    800012fa:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012fe:	995a                	add	s2,s2,s6
    80001300:	fb3972e3          	bgeu	s2,s3,800012a4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001304:	4601                	li	a2,0
    80001306:	85ca                	mv	a1,s2
    80001308:	8552                	mv	a0,s4
    8000130a:	00000097          	auipc	ra,0x0
    8000130e:	cbc080e7          	jalr	-836(ra) # 80000fc6 <walk>
    80001312:	84aa                	mv	s1,a0
    80001314:	d95d                	beqz	a0,800012ca <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001316:	6108                	ld	a0,0(a0)
    80001318:	00157793          	andi	a5,a0,1
    8000131c:	dfdd                	beqz	a5,800012da <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000131e:	3ff57793          	andi	a5,a0,1023
    80001322:	fd7784e3          	beq	a5,s7,800012ea <uvmunmap+0x76>
    if(do_free){
    80001326:	fc0a8ae3          	beqz	s5,800012fa <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000132a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000132c:	0532                	slli	a0,a0,0xc
    8000132e:	fffff097          	auipc	ra,0xfffff
    80001332:	6bc080e7          	jalr	1724(ra) # 800009ea <kfree>
    80001336:	b7d1                	j	800012fa <uvmunmap+0x86>

0000000080001338 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001338:	1101                	addi	sp,sp,-32
    8000133a:	ec06                	sd	ra,24(sp)
    8000133c:	e822                	sd	s0,16(sp)
    8000133e:	e426                	sd	s1,8(sp)
    80001340:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001342:	fffff097          	auipc	ra,0xfffff
    80001346:	7a4080e7          	jalr	1956(ra) # 80000ae6 <kalloc>
    8000134a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134c:	c519                	beqz	a0,8000135a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000134e:	6605                	lui	a2,0x1
    80001350:	4581                	li	a1,0
    80001352:	00000097          	auipc	ra,0x0
    80001356:	980080e7          	jalr	-1664(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000135a:	8526                	mv	a0,s1
    8000135c:	60e2                	ld	ra,24(sp)
    8000135e:	6442                	ld	s0,16(sp)
    80001360:	64a2                	ld	s1,8(sp)
    80001362:	6105                	addi	sp,sp,32
    80001364:	8082                	ret

0000000080001366 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001366:	7179                	addi	sp,sp,-48
    80001368:	f406                	sd	ra,40(sp)
    8000136a:	f022                	sd	s0,32(sp)
    8000136c:	ec26                	sd	s1,24(sp)
    8000136e:	e84a                	sd	s2,16(sp)
    80001370:	e44e                	sd	s3,8(sp)
    80001372:	e052                	sd	s4,0(sp)
    80001374:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001376:	6785                	lui	a5,0x1
    80001378:	04f67863          	bgeu	a2,a5,800013c8 <uvmfirst+0x62>
    8000137c:	8a2a                	mv	s4,a0
    8000137e:	89ae                	mv	s3,a1
    80001380:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	764080e7          	jalr	1892(ra) # 80000ae6 <kalloc>
    8000138a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	00000097          	auipc	ra,0x0
    80001394:	942080e7          	jalr	-1726(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001398:	4779                	li	a4,30
    8000139a:	86ca                	mv	a3,s2
    8000139c:	6605                	lui	a2,0x1
    8000139e:	4581                	li	a1,0
    800013a0:	8552                	mv	a0,s4
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	d0c080e7          	jalr	-756(ra) # 800010ae <mappages>
  memmove(mem, src, sz);
    800013aa:	8626                	mv	a2,s1
    800013ac:	85ce                	mv	a1,s3
    800013ae:	854a                	mv	a0,s2
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	97e080e7          	jalr	-1666(ra) # 80000d2e <memmove>
}
    800013b8:	70a2                	ld	ra,40(sp)
    800013ba:	7402                	ld	s0,32(sp)
    800013bc:	64e2                	ld	s1,24(sp)
    800013be:	6942                	ld	s2,16(sp)
    800013c0:	69a2                	ld	s3,8(sp)
    800013c2:	6a02                	ld	s4,0(sp)
    800013c4:	6145                	addi	sp,sp,48
    800013c6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013c8:	00007517          	auipc	a0,0x7
    800013cc:	db850513          	addi	a0,a0,-584 # 80008180 <digits+0x140>
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	16e080e7          	jalr	366(ra) # 8000053e <panic>

00000000800013d8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d8:	1101                	addi	sp,sp,-32
    800013da:	ec06                	sd	ra,24(sp)
    800013dc:	e822                	sd	s0,16(sp)
    800013de:	e426                	sd	s1,8(sp)
    800013e0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e4:	00b67d63          	bgeu	a2,a1,800013fe <uvmdealloc+0x26>
    800013e8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ea:	6785                	lui	a5,0x1
    800013ec:	17fd                	addi	a5,a5,-1
    800013ee:	00f60733          	add	a4,a2,a5
    800013f2:	767d                	lui	a2,0xfffff
    800013f4:	8f71                	and	a4,a4,a2
    800013f6:	97ae                	add	a5,a5,a1
    800013f8:	8ff1                	and	a5,a5,a2
    800013fa:	00f76863          	bltu	a4,a5,8000140a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013fe:	8526                	mv	a0,s1
    80001400:	60e2                	ld	ra,24(sp)
    80001402:	6442                	ld	s0,16(sp)
    80001404:	64a2                	ld	s1,8(sp)
    80001406:	6105                	addi	sp,sp,32
    80001408:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140a:	8f99                	sub	a5,a5,a4
    8000140c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000140e:	4685                	li	a3,1
    80001410:	0007861b          	sext.w	a2,a5
    80001414:	85ba                	mv	a1,a4
    80001416:	00000097          	auipc	ra,0x0
    8000141a:	e5e080e7          	jalr	-418(ra) # 80001274 <uvmunmap>
    8000141e:	b7c5                	j	800013fe <uvmdealloc+0x26>

0000000080001420 <uvmalloc>:
  if(newsz < oldsz)
    80001420:	0ab66563          	bltu	a2,a1,800014ca <uvmalloc+0xaa>
{
    80001424:	7139                	addi	sp,sp,-64
    80001426:	fc06                	sd	ra,56(sp)
    80001428:	f822                	sd	s0,48(sp)
    8000142a:	f426                	sd	s1,40(sp)
    8000142c:	f04a                	sd	s2,32(sp)
    8000142e:	ec4e                	sd	s3,24(sp)
    80001430:	e852                	sd	s4,16(sp)
    80001432:	e456                	sd	s5,8(sp)
    80001434:	e05a                	sd	s6,0(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f363          	bgeu	s3,a2,800014ce <uvmalloc+0xae>
    8000144c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000144e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001452:	fffff097          	auipc	ra,0xfffff
    80001456:	694080e7          	jalr	1684(ra) # 80000ae6 <kalloc>
    8000145a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000145c:	c51d                	beqz	a0,8000148a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000145e:	6605                	lui	a2,0x1
    80001460:	4581                	li	a1,0
    80001462:	00000097          	auipc	ra,0x0
    80001466:	870080e7          	jalr	-1936(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000146a:	875a                	mv	a4,s6
    8000146c:	86a6                	mv	a3,s1
    8000146e:	6605                	lui	a2,0x1
    80001470:	85ca                	mv	a1,s2
    80001472:	8556                	mv	a0,s5
    80001474:	00000097          	auipc	ra,0x0
    80001478:	c3a080e7          	jalr	-966(ra) # 800010ae <mappages>
    8000147c:	e90d                	bnez	a0,800014ae <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147e:	6785                	lui	a5,0x1
    80001480:	993e                	add	s2,s2,a5
    80001482:	fd4968e3          	bltu	s2,s4,80001452 <uvmalloc+0x32>
  return newsz;
    80001486:	8552                	mv	a0,s4
    80001488:	a809                	j	8000149a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000148a:	864e                	mv	a2,s3
    8000148c:	85ca                	mv	a1,s2
    8000148e:	8556                	mv	a0,s5
    80001490:	00000097          	auipc	ra,0x0
    80001494:	f48080e7          	jalr	-184(ra) # 800013d8 <uvmdealloc>
      return 0;
    80001498:	4501                	li	a0,0
}
    8000149a:	70e2                	ld	ra,56(sp)
    8000149c:	7442                	ld	s0,48(sp)
    8000149e:	74a2                	ld	s1,40(sp)
    800014a0:	7902                	ld	s2,32(sp)
    800014a2:	69e2                	ld	s3,24(sp)
    800014a4:	6a42                	ld	s4,16(sp)
    800014a6:	6aa2                	ld	s5,8(sp)
    800014a8:	6b02                	ld	s6,0(sp)
    800014aa:	6121                	addi	sp,sp,64
    800014ac:	8082                	ret
      kfree(mem);
    800014ae:	8526                	mv	a0,s1
    800014b0:	fffff097          	auipc	ra,0xfffff
    800014b4:	53a080e7          	jalr	1338(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b8:	864e                	mv	a2,s3
    800014ba:	85ca                	mv	a1,s2
    800014bc:	8556                	mv	a0,s5
    800014be:	00000097          	auipc	ra,0x0
    800014c2:	f1a080e7          	jalr	-230(ra) # 800013d8 <uvmdealloc>
      return 0;
    800014c6:	4501                	li	a0,0
    800014c8:	bfc9                	j	8000149a <uvmalloc+0x7a>
    return oldsz;
    800014ca:	852e                	mv	a0,a1
}
    800014cc:	8082                	ret
  return newsz;
    800014ce:	8532                	mv	a0,a2
    800014d0:	b7e9                	j	8000149a <uvmalloc+0x7a>

00000000800014d2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014d2:	7179                	addi	sp,sp,-48
    800014d4:	f406                	sd	ra,40(sp)
    800014d6:	f022                	sd	s0,32(sp)
    800014d8:	ec26                	sd	s1,24(sp)
    800014da:	e84a                	sd	s2,16(sp)
    800014dc:	e44e                	sd	s3,8(sp)
    800014de:	e052                	sd	s4,0(sp)
    800014e0:	1800                	addi	s0,sp,48
    800014e2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014e4:	84aa                	mv	s1,a0
    800014e6:	6905                	lui	s2,0x1
    800014e8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ea:	4985                	li	s3,1
    800014ec:	a821                	j	80001504 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014ee:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014f0:	0532                	slli	a0,a0,0xc
    800014f2:	00000097          	auipc	ra,0x0
    800014f6:	fe0080e7          	jalr	-32(ra) # 800014d2 <freewalk>
      pagetable[i] = 0;
    800014fa:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014fe:	04a1                	addi	s1,s1,8
    80001500:	03248163          	beq	s1,s2,80001522 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001504:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001506:	00f57793          	andi	a5,a0,15
    8000150a:	ff3782e3          	beq	a5,s3,800014ee <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000150e:	8905                	andi	a0,a0,1
    80001510:	d57d                	beqz	a0,800014fe <freewalk+0x2c>
      panic("freewalk: leaf");
    80001512:	00007517          	auipc	a0,0x7
    80001516:	c8e50513          	addi	a0,a0,-882 # 800081a0 <digits+0x160>
    8000151a:	fffff097          	auipc	ra,0xfffff
    8000151e:	024080e7          	jalr	36(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001522:	8552                	mv	a0,s4
    80001524:	fffff097          	auipc	ra,0xfffff
    80001528:	4c6080e7          	jalr	1222(ra) # 800009ea <kfree>
}
    8000152c:	70a2                	ld	ra,40(sp)
    8000152e:	7402                	ld	s0,32(sp)
    80001530:	64e2                	ld	s1,24(sp)
    80001532:	6942                	ld	s2,16(sp)
    80001534:	69a2                	ld	s3,8(sp)
    80001536:	6a02                	ld	s4,0(sp)
    80001538:	6145                	addi	sp,sp,48
    8000153a:	8082                	ret

000000008000153c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000153c:	1101                	addi	sp,sp,-32
    8000153e:	ec06                	sd	ra,24(sp)
    80001540:	e822                	sd	s0,16(sp)
    80001542:	e426                	sd	s1,8(sp)
    80001544:	1000                	addi	s0,sp,32
    80001546:	84aa                	mv	s1,a0
  if(sz > 0)
    80001548:	e999                	bnez	a1,8000155e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000154a:	8526                	mv	a0,s1
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	f86080e7          	jalr	-122(ra) # 800014d2 <freewalk>
}
    80001554:	60e2                	ld	ra,24(sp)
    80001556:	6442                	ld	s0,16(sp)
    80001558:	64a2                	ld	s1,8(sp)
    8000155a:	6105                	addi	sp,sp,32
    8000155c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000155e:	6605                	lui	a2,0x1
    80001560:	167d                	addi	a2,a2,-1
    80001562:	962e                	add	a2,a2,a1
    80001564:	4685                	li	a3,1
    80001566:	8231                	srli	a2,a2,0xc
    80001568:	4581                	li	a1,0
    8000156a:	00000097          	auipc	ra,0x0
    8000156e:	d0a080e7          	jalr	-758(ra) # 80001274 <uvmunmap>
    80001572:	bfe1                	j	8000154a <uvmfree+0xe>

0000000080001574 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001574:	c679                	beqz	a2,80001642 <uvmcopy+0xce>
{
    80001576:	715d                	addi	sp,sp,-80
    80001578:	e486                	sd	ra,72(sp)
    8000157a:	e0a2                	sd	s0,64(sp)
    8000157c:	fc26                	sd	s1,56(sp)
    8000157e:	f84a                	sd	s2,48(sp)
    80001580:	f44e                	sd	s3,40(sp)
    80001582:	f052                	sd	s4,32(sp)
    80001584:	ec56                	sd	s5,24(sp)
    80001586:	e85a                	sd	s6,16(sp)
    80001588:	e45e                	sd	s7,8(sp)
    8000158a:	0880                	addi	s0,sp,80
    8000158c:	8b2a                	mv	s6,a0
    8000158e:	8aae                	mv	s5,a1
    80001590:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001592:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001594:	4601                	li	a2,0
    80001596:	85ce                	mv	a1,s3
    80001598:	855a                	mv	a0,s6
    8000159a:	00000097          	auipc	ra,0x0
    8000159e:	a2c080e7          	jalr	-1492(ra) # 80000fc6 <walk>
    800015a2:	c531                	beqz	a0,800015ee <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015a4:	6118                	ld	a4,0(a0)
    800015a6:	00177793          	andi	a5,a4,1
    800015aa:	cbb1                	beqz	a5,800015fe <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015ac:	00a75593          	srli	a1,a4,0xa
    800015b0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015b4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	52e080e7          	jalr	1326(ra) # 80000ae6 <kalloc>
    800015c0:	892a                	mv	s2,a0
    800015c2:	c939                	beqz	a0,80001618 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85de                	mv	a1,s7
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	766080e7          	jalr	1894(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015d0:	8726                	mv	a4,s1
    800015d2:	86ca                	mv	a3,s2
    800015d4:	6605                	lui	a2,0x1
    800015d6:	85ce                	mv	a1,s3
    800015d8:	8556                	mv	a0,s5
    800015da:	00000097          	auipc	ra,0x0
    800015de:	ad4080e7          	jalr	-1324(ra) # 800010ae <mappages>
    800015e2:	e515                	bnez	a0,8000160e <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015e4:	6785                	lui	a5,0x1
    800015e6:	99be                	add	s3,s3,a5
    800015e8:	fb49e6e3          	bltu	s3,s4,80001594 <uvmcopy+0x20>
    800015ec:	a081                	j	8000162c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bc250513          	addi	a0,a0,-1086 # 800081b0 <digits+0x170>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015fe:	00007517          	auipc	a0,0x7
    80001602:	bd250513          	addi	a0,a0,-1070 # 800081d0 <digits+0x190>
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	f38080e7          	jalr	-200(ra) # 8000053e <panic>
      kfree(mem);
    8000160e:	854a                	mv	a0,s2
    80001610:	fffff097          	auipc	ra,0xfffff
    80001614:	3da080e7          	jalr	986(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001618:	4685                	li	a3,1
    8000161a:	00c9d613          	srli	a2,s3,0xc
    8000161e:	4581                	li	a1,0
    80001620:	8556                	mv	a0,s5
    80001622:	00000097          	auipc	ra,0x0
    80001626:	c52080e7          	jalr	-942(ra) # 80001274 <uvmunmap>
  return -1;
    8000162a:	557d                	li	a0,-1
}
    8000162c:	60a6                	ld	ra,72(sp)
    8000162e:	6406                	ld	s0,64(sp)
    80001630:	74e2                	ld	s1,56(sp)
    80001632:	7942                	ld	s2,48(sp)
    80001634:	79a2                	ld	s3,40(sp)
    80001636:	7a02                	ld	s4,32(sp)
    80001638:	6ae2                	ld	s5,24(sp)
    8000163a:	6b42                	ld	s6,16(sp)
    8000163c:	6ba2                	ld	s7,8(sp)
    8000163e:	6161                	addi	sp,sp,80
    80001640:	8082                	ret
  return 0;
    80001642:	4501                	li	a0,0
}
    80001644:	8082                	ret

0000000080001646 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001646:	1141                	addi	sp,sp,-16
    80001648:	e406                	sd	ra,8(sp)
    8000164a:	e022                	sd	s0,0(sp)
    8000164c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000164e:	4601                	li	a2,0
    80001650:	00000097          	auipc	ra,0x0
    80001654:	976080e7          	jalr	-1674(ra) # 80000fc6 <walk>
  if(pte == 0)
    80001658:	c901                	beqz	a0,80001668 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000165a:	611c                	ld	a5,0(a0)
    8000165c:	9bbd                	andi	a5,a5,-17
    8000165e:	e11c                	sd	a5,0(a0)
}
    80001660:	60a2                	ld	ra,8(sp)
    80001662:	6402                	ld	s0,0(sp)
    80001664:	0141                	addi	sp,sp,16
    80001666:	8082                	ret
    panic("uvmclear");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b8850513          	addi	a0,a0,-1144 # 800081f0 <digits+0x1b0>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ece080e7          	jalr	-306(ra) # 8000053e <panic>

0000000080001678 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001678:	c6bd                	beqz	a3,800016e6 <copyout+0x6e>
{
    8000167a:	715d                	addi	sp,sp,-80
    8000167c:	e486                	sd	ra,72(sp)
    8000167e:	e0a2                	sd	s0,64(sp)
    80001680:	fc26                	sd	s1,56(sp)
    80001682:	f84a                	sd	s2,48(sp)
    80001684:	f44e                	sd	s3,40(sp)
    80001686:	f052                	sd	s4,32(sp)
    80001688:	ec56                	sd	s5,24(sp)
    8000168a:	e85a                	sd	s6,16(sp)
    8000168c:	e45e                	sd	s7,8(sp)
    8000168e:	e062                	sd	s8,0(sp)
    80001690:	0880                	addi	s0,sp,80
    80001692:	8b2a                	mv	s6,a0
    80001694:	8c2e                	mv	s8,a1
    80001696:	8a32                	mv	s4,a2
    80001698:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000169a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000169c:	6a85                	lui	s5,0x1
    8000169e:	a015                	j	800016c2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016a0:	9562                	add	a0,a0,s8
    800016a2:	0004861b          	sext.w	a2,s1
    800016a6:	85d2                	mv	a1,s4
    800016a8:	41250533          	sub	a0,a0,s2
    800016ac:	fffff097          	auipc	ra,0xfffff
    800016b0:	682080e7          	jalr	1666(ra) # 80000d2e <memmove>

    len -= n;
    800016b4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ba:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016be:	02098263          	beqz	s3,800016e2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016c2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c6:	85ca                	mv	a1,s2
    800016c8:	855a                	mv	a0,s6
    800016ca:	00000097          	auipc	ra,0x0
    800016ce:	9a2080e7          	jalr	-1630(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    800016d2:	cd01                	beqz	a0,800016ea <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016d4:	418904b3          	sub	s1,s2,s8
    800016d8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016da:	fc99f3e3          	bgeu	s3,s1,800016a0 <copyout+0x28>
    800016de:	84ce                	mv	s1,s3
    800016e0:	b7c1                	j	800016a0 <copyout+0x28>
  }
  return 0;
    800016e2:	4501                	li	a0,0
    800016e4:	a021                	j	800016ec <copyout+0x74>
    800016e6:	4501                	li	a0,0
}
    800016e8:	8082                	ret
      return -1;
    800016ea:	557d                	li	a0,-1
}
    800016ec:	60a6                	ld	ra,72(sp)
    800016ee:	6406                	ld	s0,64(sp)
    800016f0:	74e2                	ld	s1,56(sp)
    800016f2:	7942                	ld	s2,48(sp)
    800016f4:	79a2                	ld	s3,40(sp)
    800016f6:	7a02                	ld	s4,32(sp)
    800016f8:	6ae2                	ld	s5,24(sp)
    800016fa:	6b42                	ld	s6,16(sp)
    800016fc:	6ba2                	ld	s7,8(sp)
    800016fe:	6c02                	ld	s8,0(sp)
    80001700:	6161                	addi	sp,sp,80
    80001702:	8082                	ret

0000000080001704 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001704:	caa5                	beqz	a3,80001774 <copyin+0x70>
{
    80001706:	715d                	addi	sp,sp,-80
    80001708:	e486                	sd	ra,72(sp)
    8000170a:	e0a2                	sd	s0,64(sp)
    8000170c:	fc26                	sd	s1,56(sp)
    8000170e:	f84a                	sd	s2,48(sp)
    80001710:	f44e                	sd	s3,40(sp)
    80001712:	f052                	sd	s4,32(sp)
    80001714:	ec56                	sd	s5,24(sp)
    80001716:	e85a                	sd	s6,16(sp)
    80001718:	e45e                	sd	s7,8(sp)
    8000171a:	e062                	sd	s8,0(sp)
    8000171c:	0880                	addi	s0,sp,80
    8000171e:	8b2a                	mv	s6,a0
    80001720:	8a2e                	mv	s4,a1
    80001722:	8c32                	mv	s8,a2
    80001724:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001726:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001728:	6a85                	lui	s5,0x1
    8000172a:	a01d                	j	80001750 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000172c:	018505b3          	add	a1,a0,s8
    80001730:	0004861b          	sext.w	a2,s1
    80001734:	412585b3          	sub	a1,a1,s2
    80001738:	8552                	mv	a0,s4
    8000173a:	fffff097          	auipc	ra,0xfffff
    8000173e:	5f4080e7          	jalr	1524(ra) # 80000d2e <memmove>

    len -= n;
    80001742:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001746:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001748:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000174c:	02098263          	beqz	s3,80001770 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001750:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001754:	85ca                	mv	a1,s2
    80001756:	855a                	mv	a0,s6
    80001758:	00000097          	auipc	ra,0x0
    8000175c:	914080e7          	jalr	-1772(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    80001760:	cd01                	beqz	a0,80001778 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001762:	418904b3          	sub	s1,s2,s8
    80001766:	94d6                	add	s1,s1,s5
    if(n > len)
    80001768:	fc99f2e3          	bgeu	s3,s1,8000172c <copyin+0x28>
    8000176c:	84ce                	mv	s1,s3
    8000176e:	bf7d                	j	8000172c <copyin+0x28>
  }
  return 0;
    80001770:	4501                	li	a0,0
    80001772:	a021                	j	8000177a <copyin+0x76>
    80001774:	4501                	li	a0,0
}
    80001776:	8082                	ret
      return -1;
    80001778:	557d                	li	a0,-1
}
    8000177a:	60a6                	ld	ra,72(sp)
    8000177c:	6406                	ld	s0,64(sp)
    8000177e:	74e2                	ld	s1,56(sp)
    80001780:	7942                	ld	s2,48(sp)
    80001782:	79a2                	ld	s3,40(sp)
    80001784:	7a02                	ld	s4,32(sp)
    80001786:	6ae2                	ld	s5,24(sp)
    80001788:	6b42                	ld	s6,16(sp)
    8000178a:	6ba2                	ld	s7,8(sp)
    8000178c:	6c02                	ld	s8,0(sp)
    8000178e:	6161                	addi	sp,sp,80
    80001790:	8082                	ret

0000000080001792 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001792:	c6c5                	beqz	a3,8000183a <copyinstr+0xa8>
{
    80001794:	715d                	addi	sp,sp,-80
    80001796:	e486                	sd	ra,72(sp)
    80001798:	e0a2                	sd	s0,64(sp)
    8000179a:	fc26                	sd	s1,56(sp)
    8000179c:	f84a                	sd	s2,48(sp)
    8000179e:	f44e                	sd	s3,40(sp)
    800017a0:	f052                	sd	s4,32(sp)
    800017a2:	ec56                	sd	s5,24(sp)
    800017a4:	e85a                	sd	s6,16(sp)
    800017a6:	e45e                	sd	s7,8(sp)
    800017a8:	0880                	addi	s0,sp,80
    800017aa:	8a2a                	mv	s4,a0
    800017ac:	8b2e                	mv	s6,a1
    800017ae:	8bb2                	mv	s7,a2
    800017b0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017b2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017b4:	6985                	lui	s3,0x1
    800017b6:	a035                	j	800017e2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017bc:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017be:	0017b793          	seqz	a5,a5
    800017c2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017c6:	60a6                	ld	ra,72(sp)
    800017c8:	6406                	ld	s0,64(sp)
    800017ca:	74e2                	ld	s1,56(sp)
    800017cc:	7942                	ld	s2,48(sp)
    800017ce:	79a2                	ld	s3,40(sp)
    800017d0:	7a02                	ld	s4,32(sp)
    800017d2:	6ae2                	ld	s5,24(sp)
    800017d4:	6b42                	ld	s6,16(sp)
    800017d6:	6ba2                	ld	s7,8(sp)
    800017d8:	6161                	addi	sp,sp,80
    800017da:	8082                	ret
    srcva = va0 + PGSIZE;
    800017dc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017e0:	c8a9                	beqz	s1,80001832 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017e2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017e6:	85ca                	mv	a1,s2
    800017e8:	8552                	mv	a0,s4
    800017ea:	00000097          	auipc	ra,0x0
    800017ee:	882080e7          	jalr	-1918(ra) # 8000106c <walkaddr>
    if(pa0 == 0)
    800017f2:	c131                	beqz	a0,80001836 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017f4:	41790833          	sub	a6,s2,s7
    800017f8:	984e                	add	a6,a6,s3
    if(n > max)
    800017fa:	0104f363          	bgeu	s1,a6,80001800 <copyinstr+0x6e>
    800017fe:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001800:	955e                	add	a0,a0,s7
    80001802:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001806:	fc080be3          	beqz	a6,800017dc <copyinstr+0x4a>
    8000180a:	985a                	add	a6,a6,s6
    8000180c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000180e:	41650633          	sub	a2,a0,s6
    80001812:	14fd                	addi	s1,s1,-1
    80001814:	9b26                	add	s6,s6,s1
    80001816:	00f60733          	add	a4,a2,a5
    8000181a:	00074703          	lbu	a4,0(a4)
    8000181e:	df49                	beqz	a4,800017b8 <copyinstr+0x26>
        *dst = *p;
    80001820:	00e78023          	sb	a4,0(a5)
      --max;
    80001824:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001828:	0785                	addi	a5,a5,1
    while(n > 0){
    8000182a:	ff0796e3          	bne	a5,a6,80001816 <copyinstr+0x84>
      dst++;
    8000182e:	8b42                	mv	s6,a6
    80001830:	b775                	j	800017dc <copyinstr+0x4a>
    80001832:	4781                	li	a5,0
    80001834:	b769                	j	800017be <copyinstr+0x2c>
      return -1;
    80001836:	557d                	li	a0,-1
    80001838:	b779                	j	800017c6 <copyinstr+0x34>
  int got_null = 0;
    8000183a:	4781                	li	a5,0
  if(got_null){
    8000183c:	0017b793          	seqz	a5,a5
    80001840:	40f00533          	neg	a0,a5
}
    80001844:	8082                	ret

0000000080001846 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001846:	7139                	addi	sp,sp,-64
    80001848:	fc06                	sd	ra,56(sp)
    8000184a:	f822                	sd	s0,48(sp)
    8000184c:	f426                	sd	s1,40(sp)
    8000184e:	f04a                	sd	s2,32(sp)
    80001850:	ec4e                	sd	s3,24(sp)
    80001852:	e852                	sd	s4,16(sp)
    80001854:	e456                	sd	s5,8(sp)
    80001856:	e05a                	sd	s6,0(sp)
    80001858:	0080                	addi	s0,sp,64
    8000185a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	0000f497          	auipc	s1,0xf
    80001860:	73448493          	addi	s1,s1,1844 # 80010f90 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001864:	8b26                	mv	s6,s1
    80001866:	00006a97          	auipc	s5,0x6
    8000186a:	79aa8a93          	addi	s5,s5,1946 # 80008000 <etext>
    8000186e:	04000937          	lui	s2,0x4000
    80001872:	197d                	addi	s2,s2,-1
    80001874:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	00015a17          	auipc	s4,0x15
    8000187a:	51aa0a13          	addi	s4,s4,1306 # 80016d90 <tickslock>
    char *pa = kalloc();
    8000187e:	fffff097          	auipc	ra,0xfffff
    80001882:	268080e7          	jalr	616(ra) # 80000ae6 <kalloc>
    80001886:	862a                	mv	a2,a0
    if(pa == 0)
    80001888:	c131                	beqz	a0,800018cc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000188a:	416485b3          	sub	a1,s1,s6
    8000188e:	858d                	srai	a1,a1,0x3
    80001890:	000ab783          	ld	a5,0(s5)
    80001894:	02f585b3          	mul	a1,a1,a5
    80001898:	2585                	addiw	a1,a1,1
    8000189a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000189e:	4719                	li	a4,6
    800018a0:	6685                	lui	a3,0x1
    800018a2:	40b905b3          	sub	a1,s2,a1
    800018a6:	854e                	mv	a0,s3
    800018a8:	00000097          	auipc	ra,0x0
    800018ac:	8a6080e7          	jalr	-1882(ra) # 8000114e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b0:	17848493          	addi	s1,s1,376
    800018b4:	fd4495e3          	bne	s1,s4,8000187e <proc_mapstacks+0x38>
  }
}
    800018b8:	70e2                	ld	ra,56(sp)
    800018ba:	7442                	ld	s0,48(sp)
    800018bc:	74a2                	ld	s1,40(sp)
    800018be:	7902                	ld	s2,32(sp)
    800018c0:	69e2                	ld	s3,24(sp)
    800018c2:	6a42                	ld	s4,16(sp)
    800018c4:	6aa2                	ld	s5,8(sp)
    800018c6:	6b02                	ld	s6,0(sp)
    800018c8:	6121                	addi	sp,sp,64
    800018ca:	8082                	ret
      panic("kalloc");
    800018cc:	00007517          	auipc	a0,0x7
    800018d0:	93450513          	addi	a0,a0,-1740 # 80008200 <digits+0x1c0>
    800018d4:	fffff097          	auipc	ra,0xfffff
    800018d8:	c6a080e7          	jalr	-918(ra) # 8000053e <panic>

00000000800018dc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018dc:	7139                	addi	sp,sp,-64
    800018de:	fc06                	sd	ra,56(sp)
    800018e0:	f822                	sd	s0,48(sp)
    800018e2:	f426                	sd	s1,40(sp)
    800018e4:	f04a                	sd	s2,32(sp)
    800018e6:	ec4e                	sd	s3,24(sp)
    800018e8:	e852                	sd	s4,16(sp)
    800018ea:	e456                	sd	s5,8(sp)
    800018ec:	e05a                	sd	s6,0(sp)
    800018ee:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018f0:	00007597          	auipc	a1,0x7
    800018f4:	91858593          	addi	a1,a1,-1768 # 80008208 <digits+0x1c8>
    800018f8:	0000f517          	auipc	a0,0xf
    800018fc:	26850513          	addi	a0,a0,616 # 80010b60 <pid_lock>
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	246080e7          	jalr	582(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001908:	00007597          	auipc	a1,0x7
    8000190c:	90858593          	addi	a1,a1,-1784 # 80008210 <digits+0x1d0>
    80001910:	0000f517          	auipc	a0,0xf
    80001914:	26850513          	addi	a0,a0,616 # 80010b78 <wait_lock>
    80001918:	fffff097          	auipc	ra,0xfffff
    8000191c:	22e080e7          	jalr	558(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	0000f497          	auipc	s1,0xf
    80001924:	67048493          	addi	s1,s1,1648 # 80010f90 <proc>
      initlock(&p->lock, "proc");
    80001928:	00007b17          	auipc	s6,0x7
    8000192c:	8f8b0b13          	addi	s6,s6,-1800 # 80008220 <digits+0x1e0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001930:	8aa6                	mv	s5,s1
    80001932:	00006a17          	auipc	s4,0x6
    80001936:	6cea0a13          	addi	s4,s4,1742 # 80008000 <etext>
    8000193a:	04000937          	lui	s2,0x4000
    8000193e:	197d                	addi	s2,s2,-1
    80001940:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001942:	00015997          	auipc	s3,0x15
    80001946:	44e98993          	addi	s3,s3,1102 # 80016d90 <tickslock>
      initlock(&p->lock, "proc");
    8000194a:	85da                	mv	a1,s6
    8000194c:	8526                	mv	a0,s1
    8000194e:	fffff097          	auipc	ra,0xfffff
    80001952:	1f8080e7          	jalr	504(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001956:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000195a:	415487b3          	sub	a5,s1,s5
    8000195e:	878d                	srai	a5,a5,0x3
    80001960:	000a3703          	ld	a4,0(s4)
    80001964:	02e787b3          	mul	a5,a5,a4
    80001968:	2785                	addiw	a5,a5,1
    8000196a:	00d7979b          	slliw	a5,a5,0xd
    8000196e:	40f907b3          	sub	a5,s2,a5
    80001972:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001974:	17848493          	addi	s1,s1,376
    80001978:	fd3499e3          	bne	s1,s3,8000194a <procinit+0x6e>
  }
}
    8000197c:	70e2                	ld	ra,56(sp)
    8000197e:	7442                	ld	s0,48(sp)
    80001980:	74a2                	ld	s1,40(sp)
    80001982:	7902                	ld	s2,32(sp)
    80001984:	69e2                	ld	s3,24(sp)
    80001986:	6a42                	ld	s4,16(sp)
    80001988:	6aa2                	ld	s5,8(sp)
    8000198a:	6b02                	ld	s6,0(sp)
    8000198c:	6121                	addi	sp,sp,64
    8000198e:	8082                	ret

0000000080001990 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001996:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001998:	2501                	sext.w	a0,a0
    8000199a:	6422                	ld	s0,8(sp)
    8000199c:	0141                	addi	sp,sp,16
    8000199e:	8082                	ret

00000000800019a0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019a0:	1141                	addi	sp,sp,-16
    800019a2:	e422                	sd	s0,8(sp)
    800019a4:	0800                	addi	s0,sp,16
    800019a6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a8:	2781                	sext.w	a5,a5
    800019aa:	079e                	slli	a5,a5,0x7
  return c;
}
    800019ac:	0000f517          	auipc	a0,0xf
    800019b0:	1e450513          	addi	a0,a0,484 # 80010b90 <cpus>
    800019b4:	953e                	add	a0,a0,a5
    800019b6:	6422                	ld	s0,8(sp)
    800019b8:	0141                	addi	sp,sp,16
    800019ba:	8082                	ret

00000000800019bc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019bc:	1101                	addi	sp,sp,-32
    800019be:	ec06                	sd	ra,24(sp)
    800019c0:	e822                	sd	s0,16(sp)
    800019c2:	e426                	sd	s1,8(sp)
    800019c4:	1000                	addi	s0,sp,32
  push_off();
    800019c6:	fffff097          	auipc	ra,0xfffff
    800019ca:	1c4080e7          	jalr	452(ra) # 80000b8a <push_off>
    800019ce:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019d0:	2781                	sext.w	a5,a5
    800019d2:	079e                	slli	a5,a5,0x7
    800019d4:	0000f717          	auipc	a4,0xf
    800019d8:	18c70713          	addi	a4,a4,396 # 80010b60 <pid_lock>
    800019dc:	97ba                	add	a5,a5,a4
    800019de:	7b84                	ld	s1,48(a5)
  pop_off();
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	24a080e7          	jalr	586(ra) # 80000c2a <pop_off>
  return p;
}
    800019e8:	8526                	mv	a0,s1
    800019ea:	60e2                	ld	ra,24(sp)
    800019ec:	6442                	ld	s0,16(sp)
    800019ee:	64a2                	ld	s1,8(sp)
    800019f0:	6105                	addi	sp,sp,32
    800019f2:	8082                	ret

00000000800019f4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019f4:	1141                	addi	sp,sp,-16
    800019f6:	e406                	sd	ra,8(sp)
    800019f8:	e022                	sd	s0,0(sp)
    800019fa:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019fc:	00000097          	auipc	ra,0x0
    80001a00:	fc0080e7          	jalr	-64(ra) # 800019bc <myproc>
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	286080e7          	jalr	646(ra) # 80000c8a <release>

  if (first) {
    80001a0c:	00007797          	auipc	a5,0x7
    80001a10:	e647a783          	lw	a5,-412(a5) # 80008870 <first.1>
    80001a14:	eb89                	bnez	a5,80001a26 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a16:	00001097          	auipc	ra,0x1
    80001a1a:	e2a080e7          	jalr	-470(ra) # 80002840 <usertrapret>
}
    80001a1e:	60a2                	ld	ra,8(sp)
    80001a20:	6402                	ld	s0,0(sp)
    80001a22:	0141                	addi	sp,sp,16
    80001a24:	8082                	ret
    first = 0;
    80001a26:	00007797          	auipc	a5,0x7
    80001a2a:	e407a523          	sw	zero,-438(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a2e:	4505                	li	a0,1
    80001a30:	00002097          	auipc	ra,0x2
    80001a34:	c0a080e7          	jalr	-1014(ra) # 8000363a <fsinit>
    80001a38:	bff9                	j	80001a16 <forkret+0x22>

0000000080001a3a <allocpid>:
{
    80001a3a:	1101                	addi	sp,sp,-32
    80001a3c:	ec06                	sd	ra,24(sp)
    80001a3e:	e822                	sd	s0,16(sp)
    80001a40:	e426                	sd	s1,8(sp)
    80001a42:	e04a                	sd	s2,0(sp)
    80001a44:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a46:	0000f917          	auipc	s2,0xf
    80001a4a:	11a90913          	addi	s2,s2,282 # 80010b60 <pid_lock>
    80001a4e:	854a                	mv	a0,s2
    80001a50:	fffff097          	auipc	ra,0xfffff
    80001a54:	186080e7          	jalr	390(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a58:	00007797          	auipc	a5,0x7
    80001a5c:	e1c78793          	addi	a5,a5,-484 # 80008874 <nextpid>
    80001a60:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a62:	0014871b          	addiw	a4,s1,1
    80001a66:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a68:	854a                	mv	a0,s2
    80001a6a:	fffff097          	auipc	ra,0xfffff
    80001a6e:	220080e7          	jalr	544(ra) # 80000c8a <release>
}
    80001a72:	8526                	mv	a0,s1
    80001a74:	60e2                	ld	ra,24(sp)
    80001a76:	6442                	ld	s0,16(sp)
    80001a78:	64a2                	ld	s1,8(sp)
    80001a7a:	6902                	ld	s2,0(sp)
    80001a7c:	6105                	addi	sp,sp,32
    80001a7e:	8082                	ret

0000000080001a80 <proc_pagetable>:
{
    80001a80:	1101                	addi	sp,sp,-32
    80001a82:	ec06                	sd	ra,24(sp)
    80001a84:	e822                	sd	s0,16(sp)
    80001a86:	e426                	sd	s1,8(sp)
    80001a88:	e04a                	sd	s2,0(sp)
    80001a8a:	1000                	addi	s0,sp,32
    80001a8c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a8e:	00000097          	auipc	ra,0x0
    80001a92:	8aa080e7          	jalr	-1878(ra) # 80001338 <uvmcreate>
    80001a96:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a98:	c121                	beqz	a0,80001ad8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a9a:	4729                	li	a4,10
    80001a9c:	00005697          	auipc	a3,0x5
    80001aa0:	56468693          	addi	a3,a3,1380 # 80007000 <_trampoline>
    80001aa4:	6605                	lui	a2,0x1
    80001aa6:	040005b7          	lui	a1,0x4000
    80001aaa:	15fd                	addi	a1,a1,-1
    80001aac:	05b2                	slli	a1,a1,0xc
    80001aae:	fffff097          	auipc	ra,0xfffff
    80001ab2:	600080e7          	jalr	1536(ra) # 800010ae <mappages>
    80001ab6:	02054863          	bltz	a0,80001ae6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aba:	4719                	li	a4,6
    80001abc:	05893683          	ld	a3,88(s2)
    80001ac0:	6605                	lui	a2,0x1
    80001ac2:	020005b7          	lui	a1,0x2000
    80001ac6:	15fd                	addi	a1,a1,-1
    80001ac8:	05b6                	slli	a1,a1,0xd
    80001aca:	8526                	mv	a0,s1
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	5e2080e7          	jalr	1506(ra) # 800010ae <mappages>
    80001ad4:	02054163          	bltz	a0,80001af6 <proc_pagetable+0x76>
}
    80001ad8:	8526                	mv	a0,s1
    80001ada:	60e2                	ld	ra,24(sp)
    80001adc:	6442                	ld	s0,16(sp)
    80001ade:	64a2                	ld	s1,8(sp)
    80001ae0:	6902                	ld	s2,0(sp)
    80001ae2:	6105                	addi	sp,sp,32
    80001ae4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	a52080e7          	jalr	-1454(ra) # 8000153c <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	b7d5                	j	80001ad8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001af6:	4681                	li	a3,0
    80001af8:	4605                	li	a2,1
    80001afa:	040005b7          	lui	a1,0x4000
    80001afe:	15fd                	addi	a1,a1,-1
    80001b00:	05b2                	slli	a1,a1,0xc
    80001b02:	8526                	mv	a0,s1
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	770080e7          	jalr	1904(ra) # 80001274 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b0c:	4581                	li	a1,0
    80001b0e:	8526                	mv	a0,s1
    80001b10:	00000097          	auipc	ra,0x0
    80001b14:	a2c080e7          	jalr	-1492(ra) # 8000153c <uvmfree>
    return 0;
    80001b18:	4481                	li	s1,0
    80001b1a:	bf7d                	j	80001ad8 <proc_pagetable+0x58>

0000000080001b1c <proc_freepagetable>:
{
    80001b1c:	1101                	addi	sp,sp,-32
    80001b1e:	ec06                	sd	ra,24(sp)
    80001b20:	e822                	sd	s0,16(sp)
    80001b22:	e426                	sd	s1,8(sp)
    80001b24:	e04a                	sd	s2,0(sp)
    80001b26:	1000                	addi	s0,sp,32
    80001b28:	84aa                	mv	s1,a0
    80001b2a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b2c:	4681                	li	a3,0
    80001b2e:	4605                	li	a2,1
    80001b30:	040005b7          	lui	a1,0x4000
    80001b34:	15fd                	addi	a1,a1,-1
    80001b36:	05b2                	slli	a1,a1,0xc
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	73c080e7          	jalr	1852(ra) # 80001274 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b40:	4681                	li	a3,0
    80001b42:	4605                	li	a2,1
    80001b44:	020005b7          	lui	a1,0x2000
    80001b48:	15fd                	addi	a1,a1,-1
    80001b4a:	05b6                	slli	a1,a1,0xd
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	726080e7          	jalr	1830(ra) # 80001274 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b56:	85ca                	mv	a1,s2
    80001b58:	8526                	mv	a0,s1
    80001b5a:	00000097          	auipc	ra,0x0
    80001b5e:	9e2080e7          	jalr	-1566(ra) # 8000153c <uvmfree>
}
    80001b62:	60e2                	ld	ra,24(sp)
    80001b64:	6442                	ld	s0,16(sp)
    80001b66:	64a2                	ld	s1,8(sp)
    80001b68:	6902                	ld	s2,0(sp)
    80001b6a:	6105                	addi	sp,sp,32
    80001b6c:	8082                	ret

0000000080001b6e <freeproc>:
{
    80001b6e:	1101                	addi	sp,sp,-32
    80001b70:	ec06                	sd	ra,24(sp)
    80001b72:	e822                	sd	s0,16(sp)
    80001b74:	e426                	sd	s1,8(sp)
    80001b76:	1000                	addi	s0,sp,32
    80001b78:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b7a:	6d28                	ld	a0,88(a0)
    80001b7c:	c509                	beqz	a0,80001b86 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b7e:	fffff097          	auipc	ra,0xfffff
    80001b82:	e6c080e7          	jalr	-404(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b86:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b8a:	68a8                	ld	a0,80(s1)
    80001b8c:	c511                	beqz	a0,80001b98 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b8e:	64ac                	ld	a1,72(s1)
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	f8c080e7          	jalr	-116(ra) # 80001b1c <proc_freepagetable>
  p->pagetable = 0;
    80001b98:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b9c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ba0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ba4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bac:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bb0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bb4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb8:	0004ac23          	sw	zero,24(s1)
}
    80001bbc:	60e2                	ld	ra,24(sp)
    80001bbe:	6442                	ld	s0,16(sp)
    80001bc0:	64a2                	ld	s1,8(sp)
    80001bc2:	6105                	addi	sp,sp,32
    80001bc4:	8082                	ret

0000000080001bc6 <allocproc>:
{
    80001bc6:	1101                	addi	sp,sp,-32
    80001bc8:	ec06                	sd	ra,24(sp)
    80001bca:	e822                	sd	s0,16(sp)
    80001bcc:	e426                	sd	s1,8(sp)
    80001bce:	e04a                	sd	s2,0(sp)
    80001bd0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd2:	0000f497          	auipc	s1,0xf
    80001bd6:	3be48493          	addi	s1,s1,958 # 80010f90 <proc>
    80001bda:	00015917          	auipc	s2,0x15
    80001bde:	1b690913          	addi	s2,s2,438 # 80016d90 <tickslock>
    acquire(&p->lock);
    80001be2:	8526                	mv	a0,s1
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	ff2080e7          	jalr	-14(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bec:	4c9c                	lw	a5,24(s1)
    80001bee:	cf81                	beqz	a5,80001c06 <allocproc+0x40>
      release(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	098080e7          	jalr	152(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bfa:	17848493          	addi	s1,s1,376
    80001bfe:	ff2492e3          	bne	s1,s2,80001be2 <allocproc+0x1c>
  return 0;
    80001c02:	4481                	li	s1,0
    80001c04:	a09d                	j	80001c6a <allocproc+0xa4>
  p->pid = allocpid();
    80001c06:	00000097          	auipc	ra,0x0
    80001c0a:	e34080e7          	jalr	-460(ra) # 80001a3a <allocpid>
    80001c0e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c10:	4785                	li	a5,1
    80001c12:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	ed2080e7          	jalr	-302(ra) # 80000ae6 <kalloc>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	eca8                	sd	a0,88(s1)
    80001c20:	cd21                	beqz	a0,80001c78 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001c22:	8526                	mv	a0,s1
    80001c24:	00000097          	auipc	ra,0x0
    80001c28:	e5c080e7          	jalr	-420(ra) # 80001a80 <proc_pagetable>
    80001c2c:	892a                	mv	s2,a0
    80001c2e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c30:	c125                	beqz	a0,80001c90 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001c32:	07000613          	li	a2,112
    80001c36:	4581                	li	a1,0
    80001c38:	06048513          	addi	a0,s1,96
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	096080e7          	jalr	150(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c44:	00000797          	auipc	a5,0x0
    80001c48:	db078793          	addi	a5,a5,-592 # 800019f4 <forkret>
    80001c4c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4e:	60bc                	ld	a5,64(s1)
    80001c50:	6705                	lui	a4,0x1
    80001c52:	97ba                	add	a5,a5,a4
    80001c54:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c56:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c5a:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c5e:	00007797          	auipc	a5,0x7
    80001c62:	c927a783          	lw	a5,-878(a5) # 800088f0 <ticks>
    80001c66:	16f4a623          	sw	a5,364(s1)
}
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	60e2                	ld	ra,24(sp)
    80001c6e:	6442                	ld	s0,16(sp)
    80001c70:	64a2                	ld	s1,8(sp)
    80001c72:	6902                	ld	s2,0(sp)
    80001c74:	6105                	addi	sp,sp,32
    80001c76:	8082                	ret
    freeproc(p);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	00000097          	auipc	ra,0x0
    80001c7e:	ef4080e7          	jalr	-268(ra) # 80001b6e <freeproc>
    release(&p->lock);
    80001c82:	8526                	mv	a0,s1
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	006080e7          	jalr	6(ra) # 80000c8a <release>
    return 0;
    80001c8c:	84ca                	mv	s1,s2
    80001c8e:	bff1                	j	80001c6a <allocproc+0xa4>
    freeproc(p);
    80001c90:	8526                	mv	a0,s1
    80001c92:	00000097          	auipc	ra,0x0
    80001c96:	edc080e7          	jalr	-292(ra) # 80001b6e <freeproc>
    release(&p->lock);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	fee080e7          	jalr	-18(ra) # 80000c8a <release>
    return 0;
    80001ca4:	84ca                	mv	s1,s2
    80001ca6:	b7d1                	j	80001c6a <allocproc+0xa4>

0000000080001ca8 <userinit>:
{
    80001ca8:	1101                	addi	sp,sp,-32
    80001caa:	ec06                	sd	ra,24(sp)
    80001cac:	e822                	sd	s0,16(sp)
    80001cae:	e426                	sd	s1,8(sp)
    80001cb0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	f14080e7          	jalr	-236(ra) # 80001bc6 <allocproc>
    80001cba:	84aa                	mv	s1,a0
  initproc = p;
    80001cbc:	00007797          	auipc	a5,0x7
    80001cc0:	c2a7b623          	sd	a0,-980(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cc4:	03400613          	li	a2,52
    80001cc8:	00007597          	auipc	a1,0x7
    80001ccc:	bb858593          	addi	a1,a1,-1096 # 80008880 <initcode>
    80001cd0:	6928                	ld	a0,80(a0)
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	694080e7          	jalr	1684(ra) # 80001366 <uvmfirst>
  p->sz = PGSIZE;
    80001cda:	6785                	lui	a5,0x1
    80001cdc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cde:	6cb8                	ld	a4,88(s1)
    80001ce0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ce4:	6cb8                	ld	a4,88(s1)
    80001ce6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce8:	4641                	li	a2,16
    80001cea:	00006597          	auipc	a1,0x6
    80001cee:	53e58593          	addi	a1,a1,1342 # 80008228 <digits+0x1e8>
    80001cf2:	15848513          	addi	a0,s1,344
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	126080e7          	jalr	294(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cfe:	00006517          	auipc	a0,0x6
    80001d02:	53a50513          	addi	a0,a0,1338 # 80008238 <digits+0x1f8>
    80001d06:	00002097          	auipc	ra,0x2
    80001d0a:	356080e7          	jalr	854(ra) # 8000405c <namei>
    80001d0e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d12:	478d                	li	a5,3
    80001d14:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d16:	8526                	mv	a0,s1
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	f72080e7          	jalr	-142(ra) # 80000c8a <release>
}
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret

0000000080001d2a <growproc>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	e04a                	sd	s2,0(sp)
    80001d34:	1000                	addi	s0,sp,32
    80001d36:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d38:	00000097          	auipc	ra,0x0
    80001d3c:	c84080e7          	jalr	-892(ra) # 800019bc <myproc>
    80001d40:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d42:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d44:	01204c63          	bgtz	s2,80001d5c <growproc+0x32>
  } else if(n < 0){
    80001d48:	02094663          	bltz	s2,80001d74 <growproc+0x4a>
  p->sz = sz;
    80001d4c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d4e:	4501                	li	a0,0
}
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6902                	ld	s2,0(sp)
    80001d58:	6105                	addi	sp,sp,32
    80001d5a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d5c:	4691                	li	a3,4
    80001d5e:	00b90633          	add	a2,s2,a1
    80001d62:	6928                	ld	a0,80(a0)
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	6bc080e7          	jalr	1724(ra) # 80001420 <uvmalloc>
    80001d6c:	85aa                	mv	a1,a0
    80001d6e:	fd79                	bnez	a0,80001d4c <growproc+0x22>
      return -1;
    80001d70:	557d                	li	a0,-1
    80001d72:	bff9                	j	80001d50 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d74:	00b90633          	add	a2,s2,a1
    80001d78:	6928                	ld	a0,80(a0)
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	65e080e7          	jalr	1630(ra) # 800013d8 <uvmdealloc>
    80001d82:	85aa                	mv	a1,a0
    80001d84:	b7e1                	j	80001d4c <growproc+0x22>

0000000080001d86 <fork>:
{
    80001d86:	7139                	addi	sp,sp,-64
    80001d88:	fc06                	sd	ra,56(sp)
    80001d8a:	f822                	sd	s0,48(sp)
    80001d8c:	f426                	sd	s1,40(sp)
    80001d8e:	f04a                	sd	s2,32(sp)
    80001d90:	ec4e                	sd	s3,24(sp)
    80001d92:	e852                	sd	s4,16(sp)
    80001d94:	e456                	sd	s5,8(sp)
    80001d96:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	c24080e7          	jalr	-988(ra) # 800019bc <myproc>
    80001da0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001da2:	00000097          	auipc	ra,0x0
    80001da6:	e24080e7          	jalr	-476(ra) # 80001bc6 <allocproc>
    80001daa:	10050c63          	beqz	a0,80001ec2 <fork+0x13c>
    80001dae:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001db0:	048ab603          	ld	a2,72(s5)
    80001db4:	692c                	ld	a1,80(a0)
    80001db6:	050ab503          	ld	a0,80(s5)
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	7ba080e7          	jalr	1978(ra) # 80001574 <uvmcopy>
    80001dc2:	04054863          	bltz	a0,80001e12 <fork+0x8c>
  np->sz = p->sz;
    80001dc6:	048ab783          	ld	a5,72(s5)
    80001dca:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dce:	058ab683          	ld	a3,88(s5)
    80001dd2:	87b6                	mv	a5,a3
    80001dd4:	058a3703          	ld	a4,88(s4)
    80001dd8:	12068693          	addi	a3,a3,288
    80001ddc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001de0:	6788                	ld	a0,8(a5)
    80001de2:	6b8c                	ld	a1,16(a5)
    80001de4:	6f90                	ld	a2,24(a5)
    80001de6:	01073023          	sd	a6,0(a4)
    80001dea:	e708                	sd	a0,8(a4)
    80001dec:	eb0c                	sd	a1,16(a4)
    80001dee:	ef10                	sd	a2,24(a4)
    80001df0:	02078793          	addi	a5,a5,32
    80001df4:	02070713          	addi	a4,a4,32
    80001df8:	fed792e3          	bne	a5,a3,80001ddc <fork+0x56>
  np->trapframe->a0 = 0;
    80001dfc:	058a3783          	ld	a5,88(s4)
    80001e00:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e04:	0d0a8493          	addi	s1,s5,208
    80001e08:	0d0a0913          	addi	s2,s4,208
    80001e0c:	150a8993          	addi	s3,s5,336
    80001e10:	a00d                	j	80001e32 <fork+0xac>
    freeproc(np);
    80001e12:	8552                	mv	a0,s4
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	d5a080e7          	jalr	-678(ra) # 80001b6e <freeproc>
    release(&np->lock);
    80001e1c:	8552                	mv	a0,s4
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	e6c080e7          	jalr	-404(ra) # 80000c8a <release>
    return -1;
    80001e26:	597d                	li	s2,-1
    80001e28:	a059                	j	80001eae <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e2a:	04a1                	addi	s1,s1,8
    80001e2c:	0921                	addi	s2,s2,8
    80001e2e:	01348b63          	beq	s1,s3,80001e44 <fork+0xbe>
    if(p->ofile[i])
    80001e32:	6088                	ld	a0,0(s1)
    80001e34:	d97d                	beqz	a0,80001e2a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e36:	00003097          	auipc	ra,0x3
    80001e3a:	8bc080e7          	jalr	-1860(ra) # 800046f2 <filedup>
    80001e3e:	00a93023          	sd	a0,0(s2)
    80001e42:	b7e5                	j	80001e2a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e44:	150ab503          	ld	a0,336(s5)
    80001e48:	00002097          	auipc	ra,0x2
    80001e4c:	a30080e7          	jalr	-1488(ra) # 80003878 <idup>
    80001e50:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e54:	4641                	li	a2,16
    80001e56:	158a8593          	addi	a1,s5,344
    80001e5a:	158a0513          	addi	a0,s4,344
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	fbe080e7          	jalr	-66(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e66:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e6a:	8552                	mv	a0,s4
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	e1e080e7          	jalr	-482(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e74:	0000f497          	auipc	s1,0xf
    80001e78:	d0448493          	addi	s1,s1,-764 # 80010b78 <wait_lock>
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	d58080e7          	jalr	-680(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e86:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	dfe080e7          	jalr	-514(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e94:	8552                	mv	a0,s4
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	d40080e7          	jalr	-704(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e9e:	478d                	li	a5,3
    80001ea0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ea4:	8552                	mv	a0,s4
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	de4080e7          	jalr	-540(ra) # 80000c8a <release>
}
    80001eae:	854a                	mv	a0,s2
    80001eb0:	70e2                	ld	ra,56(sp)
    80001eb2:	7442                	ld	s0,48(sp)
    80001eb4:	74a2                	ld	s1,40(sp)
    80001eb6:	7902                	ld	s2,32(sp)
    80001eb8:	69e2                	ld	s3,24(sp)
    80001eba:	6a42                	ld	s4,16(sp)
    80001ebc:	6aa2                	ld	s5,8(sp)
    80001ebe:	6121                	addi	sp,sp,64
    80001ec0:	8082                	ret
    return -1;
    80001ec2:	597d                	li	s2,-1
    80001ec4:	b7ed                	j	80001eae <fork+0x128>

0000000080001ec6 <update_time>:
{
    80001ec6:	7179                	addi	sp,sp,-48
    80001ec8:	f406                	sd	ra,40(sp)
    80001eca:	f022                	sd	s0,32(sp)
    80001ecc:	ec26                	sd	s1,24(sp)
    80001ece:	e84a                	sd	s2,16(sp)
    80001ed0:	e44e                	sd	s3,8(sp)
    80001ed2:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ed4:	0000f497          	auipc	s1,0xf
    80001ed8:	0bc48493          	addi	s1,s1,188 # 80010f90 <proc>
    if(p->state == RUNNING) {
    80001edc:	4991                	li	s3,4
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ede:	00015917          	auipc	s2,0x15
    80001ee2:	eb290913          	addi	s2,s2,-334 # 80016d90 <tickslock>
    80001ee6:	a811                	j	80001efa <update_time+0x34>
    release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	da0080e7          	jalr	-608(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ef2:	17848493          	addi	s1,s1,376
    80001ef6:	03248063          	beq	s1,s2,80001f16 <update_time+0x50>
    acquire(&p->lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	cda080e7          	jalr	-806(ra) # 80000bd6 <acquire>
    if(p->state == RUNNING) {
    80001f04:	4c9c                	lw	a5,24(s1)
    80001f06:	ff3791e3          	bne	a5,s3,80001ee8 <update_time+0x22>
      p->rtime++;
    80001f0a:	1684a783          	lw	a5,360(s1)
    80001f0e:	2785                	addiw	a5,a5,1
    80001f10:	16f4a423          	sw	a5,360(s1)
    80001f14:	bfd1                	j	80001ee8 <update_time+0x22>
}
    80001f16:	70a2                	ld	ra,40(sp)
    80001f18:	7402                	ld	s0,32(sp)
    80001f1a:	64e2                	ld	s1,24(sp)
    80001f1c:	6942                	ld	s2,16(sp)
    80001f1e:	69a2                	ld	s3,8(sp)
    80001f20:	6145                	addi	sp,sp,48
    80001f22:	8082                	ret

0000000080001f24 <scheduler>:
{
    80001f24:	7139                	addi	sp,sp,-64
    80001f26:	fc06                	sd	ra,56(sp)
    80001f28:	f822                	sd	s0,48(sp)
    80001f2a:	f426                	sd	s1,40(sp)
    80001f2c:	f04a                	sd	s2,32(sp)
    80001f2e:	ec4e                	sd	s3,24(sp)
    80001f30:	e852                	sd	s4,16(sp)
    80001f32:	e456                	sd	s5,8(sp)
    80001f34:	e05a                	sd	s6,0(sp)
    80001f36:	0080                	addi	s0,sp,64
    80001f38:	8792                	mv	a5,tp
  int id = r_tp();
    80001f3a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f3c:	00779a93          	slli	s5,a5,0x7
    80001f40:	0000f717          	auipc	a4,0xf
    80001f44:	c2070713          	addi	a4,a4,-992 # 80010b60 <pid_lock>
    80001f48:	9756                	add	a4,a4,s5
    80001f4a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f4e:	0000f717          	auipc	a4,0xf
    80001f52:	c4a70713          	addi	a4,a4,-950 # 80010b98 <cpus+0x8>
    80001f56:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f58:	498d                	li	s3,3
        p->state = RUNNING;
    80001f5a:	4b11                	li	s6,4
        c->proc = p;
    80001f5c:	079e                	slli	a5,a5,0x7
    80001f5e:	0000fa17          	auipc	s4,0xf
    80001f62:	c02a0a13          	addi	s4,s4,-1022 # 80010b60 <pid_lock>
    80001f66:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f68:	00015917          	auipc	s2,0x15
    80001f6c:	e2890913          	addi	s2,s2,-472 # 80016d90 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f70:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f74:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f78:	10079073          	csrw	sstatus,a5
    80001f7c:	0000f497          	auipc	s1,0xf
    80001f80:	01448493          	addi	s1,s1,20 # 80010f90 <proc>
    80001f84:	a811                	j	80001f98 <scheduler+0x74>
      release(&p->lock);
    80001f86:	8526                	mv	a0,s1
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	d02080e7          	jalr	-766(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f90:	17848493          	addi	s1,s1,376
    80001f94:	fd248ee3          	beq	s1,s2,80001f70 <scheduler+0x4c>
      acquire(&p->lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	c3c080e7          	jalr	-964(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001fa2:	4c9c                	lw	a5,24(s1)
    80001fa4:	ff3791e3          	bne	a5,s3,80001f86 <scheduler+0x62>
        p->state = RUNNING;
    80001fa8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fac:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fb0:	06048593          	addi	a1,s1,96
    80001fb4:	8556                	mv	a0,s5
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	7e0080e7          	jalr	2016(ra) # 80002796 <swtch>
        c->proc = 0;
    80001fbe:	020a3823          	sd	zero,48(s4)
    80001fc2:	b7d1                	j	80001f86 <scheduler+0x62>

0000000080001fc4 <sched>:
{
    80001fc4:	7179                	addi	sp,sp,-48
    80001fc6:	f406                	sd	ra,40(sp)
    80001fc8:	f022                	sd	s0,32(sp)
    80001fca:	ec26                	sd	s1,24(sp)
    80001fcc:	e84a                	sd	s2,16(sp)
    80001fce:	e44e                	sd	s3,8(sp)
    80001fd0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	9ea080e7          	jalr	-1558(ra) # 800019bc <myproc>
    80001fda:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	b80080e7          	jalr	-1152(ra) # 80000b5c <holding>
    80001fe4:	c93d                	beqz	a0,8000205a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fe6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fe8:	2781                	sext.w	a5,a5
    80001fea:	079e                	slli	a5,a5,0x7
    80001fec:	0000f717          	auipc	a4,0xf
    80001ff0:	b7470713          	addi	a4,a4,-1164 # 80010b60 <pid_lock>
    80001ff4:	97ba                	add	a5,a5,a4
    80001ff6:	0a87a703          	lw	a4,168(a5)
    80001ffa:	4785                	li	a5,1
    80001ffc:	06f71763          	bne	a4,a5,8000206a <sched+0xa6>
  if(p->state == RUNNING)
    80002000:	4c98                	lw	a4,24(s1)
    80002002:	4791                	li	a5,4
    80002004:	06f70b63          	beq	a4,a5,8000207a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002008:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000200c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000200e:	efb5                	bnez	a5,8000208a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002010:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002012:	0000f917          	auipc	s2,0xf
    80002016:	b4e90913          	addi	s2,s2,-1202 # 80010b60 <pid_lock>
    8000201a:	2781                	sext.w	a5,a5
    8000201c:	079e                	slli	a5,a5,0x7
    8000201e:	97ca                	add	a5,a5,s2
    80002020:	0ac7a983          	lw	s3,172(a5)
    80002024:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002026:	2781                	sext.w	a5,a5
    80002028:	079e                	slli	a5,a5,0x7
    8000202a:	0000f597          	auipc	a1,0xf
    8000202e:	b6e58593          	addi	a1,a1,-1170 # 80010b98 <cpus+0x8>
    80002032:	95be                	add	a1,a1,a5
    80002034:	06048513          	addi	a0,s1,96
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	75e080e7          	jalr	1886(ra) # 80002796 <swtch>
    80002040:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002042:	2781                	sext.w	a5,a5
    80002044:	079e                	slli	a5,a5,0x7
    80002046:	97ca                	add	a5,a5,s2
    80002048:	0b37a623          	sw	s3,172(a5)
}
    8000204c:	70a2                	ld	ra,40(sp)
    8000204e:	7402                	ld	s0,32(sp)
    80002050:	64e2                	ld	s1,24(sp)
    80002052:	6942                	ld	s2,16(sp)
    80002054:	69a2                	ld	s3,8(sp)
    80002056:	6145                	addi	sp,sp,48
    80002058:	8082                	ret
    panic("sched p->lock");
    8000205a:	00006517          	auipc	a0,0x6
    8000205e:	1e650513          	addi	a0,a0,486 # 80008240 <digits+0x200>
    80002062:	ffffe097          	auipc	ra,0xffffe
    80002066:	4dc080e7          	jalr	1244(ra) # 8000053e <panic>
    panic("sched locks");
    8000206a:	00006517          	auipc	a0,0x6
    8000206e:	1e650513          	addi	a0,a0,486 # 80008250 <digits+0x210>
    80002072:	ffffe097          	auipc	ra,0xffffe
    80002076:	4cc080e7          	jalr	1228(ra) # 8000053e <panic>
    panic("sched running");
    8000207a:	00006517          	auipc	a0,0x6
    8000207e:	1e650513          	addi	a0,a0,486 # 80008260 <digits+0x220>
    80002082:	ffffe097          	auipc	ra,0xffffe
    80002086:	4bc080e7          	jalr	1212(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000208a:	00006517          	auipc	a0,0x6
    8000208e:	1e650513          	addi	a0,a0,486 # 80008270 <digits+0x230>
    80002092:	ffffe097          	auipc	ra,0xffffe
    80002096:	4ac080e7          	jalr	1196(ra) # 8000053e <panic>

000000008000209a <yield>:
{
    8000209a:	1101                	addi	sp,sp,-32
    8000209c:	ec06                	sd	ra,24(sp)
    8000209e:	e822                	sd	s0,16(sp)
    800020a0:	e426                	sd	s1,8(sp)
    800020a2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	918080e7          	jalr	-1768(ra) # 800019bc <myproc>
    800020ac:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	b28080e7          	jalr	-1240(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020b6:	478d                	li	a5,3
    800020b8:	cc9c                	sw	a5,24(s1)
  sched();
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	f0a080e7          	jalr	-246(ra) # 80001fc4 <sched>
  release(&p->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	bc6080e7          	jalr	-1082(ra) # 80000c8a <release>
}
    800020cc:	60e2                	ld	ra,24(sp)
    800020ce:	6442                	ld	s0,16(sp)
    800020d0:	64a2                	ld	s1,8(sp)
    800020d2:	6105                	addi	sp,sp,32
    800020d4:	8082                	ret

00000000800020d6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020d6:	7179                	addi	sp,sp,-48
    800020d8:	f406                	sd	ra,40(sp)
    800020da:	f022                	sd	s0,32(sp)
    800020dc:	ec26                	sd	s1,24(sp)
    800020de:	e84a                	sd	s2,16(sp)
    800020e0:	e44e                	sd	s3,8(sp)
    800020e2:	1800                	addi	s0,sp,48
    800020e4:	89aa                	mv	s3,a0
    800020e6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020e8:	00000097          	auipc	ra,0x0
    800020ec:	8d4080e7          	jalr	-1836(ra) # 800019bc <myproc>
    800020f0:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	ae4080e7          	jalr	-1308(ra) # 80000bd6 <acquire>
  release(lk);
    800020fa:	854a                	mv	a0,s2
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	b8e080e7          	jalr	-1138(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002104:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002108:	4789                	li	a5,2
    8000210a:	cc9c                	sw	a5,24(s1)

  sched();
    8000210c:	00000097          	auipc	ra,0x0
    80002110:	eb8080e7          	jalr	-328(ra) # 80001fc4 <sched>

  // Tidy up.
  p->chan = 0;
    80002114:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002118:	8526                	mv	a0,s1
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	b70080e7          	jalr	-1168(ra) # 80000c8a <release>
  acquire(lk);
    80002122:	854a                	mv	a0,s2
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	ab2080e7          	jalr	-1358(ra) # 80000bd6 <acquire>
}
    8000212c:	70a2                	ld	ra,40(sp)
    8000212e:	7402                	ld	s0,32(sp)
    80002130:	64e2                	ld	s1,24(sp)
    80002132:	6942                	ld	s2,16(sp)
    80002134:	69a2                	ld	s3,8(sp)
    80002136:	6145                	addi	sp,sp,48
    80002138:	8082                	ret

000000008000213a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000213a:	7139                	addi	sp,sp,-64
    8000213c:	fc06                	sd	ra,56(sp)
    8000213e:	f822                	sd	s0,48(sp)
    80002140:	f426                	sd	s1,40(sp)
    80002142:	f04a                	sd	s2,32(sp)
    80002144:	ec4e                	sd	s3,24(sp)
    80002146:	e852                	sd	s4,16(sp)
    80002148:	e456                	sd	s5,8(sp)
    8000214a:	0080                	addi	s0,sp,64
    8000214c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000214e:	0000f497          	auipc	s1,0xf
    80002152:	e4248493          	addi	s1,s1,-446 # 80010f90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002156:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002158:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000215a:	00015917          	auipc	s2,0x15
    8000215e:	c3690913          	addi	s2,s2,-970 # 80016d90 <tickslock>
    80002162:	a811                	j	80002176 <wakeup+0x3c>
      }
      release(&p->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	b24080e7          	jalr	-1244(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000216e:	17848493          	addi	s1,s1,376
    80002172:	03248663          	beq	s1,s2,8000219e <wakeup+0x64>
    if(p != myproc()){
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	846080e7          	jalr	-1978(ra) # 800019bc <myproc>
    8000217e:	fea488e3          	beq	s1,a0,8000216e <wakeup+0x34>
      acquire(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	a52080e7          	jalr	-1454(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000218c:	4c9c                	lw	a5,24(s1)
    8000218e:	fd379be3          	bne	a5,s3,80002164 <wakeup+0x2a>
    80002192:	709c                	ld	a5,32(s1)
    80002194:	fd4798e3          	bne	a5,s4,80002164 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002198:	0154ac23          	sw	s5,24(s1)
    8000219c:	b7e1                	j	80002164 <wakeup+0x2a>
    }
  }
}
    8000219e:	70e2                	ld	ra,56(sp)
    800021a0:	7442                	ld	s0,48(sp)
    800021a2:	74a2                	ld	s1,40(sp)
    800021a4:	7902                	ld	s2,32(sp)
    800021a6:	69e2                	ld	s3,24(sp)
    800021a8:	6a42                	ld	s4,16(sp)
    800021aa:	6aa2                	ld	s5,8(sp)
    800021ac:	6121                	addi	sp,sp,64
    800021ae:	8082                	ret

00000000800021b0 <reparent>:
{
    800021b0:	7179                	addi	sp,sp,-48
    800021b2:	f406                	sd	ra,40(sp)
    800021b4:	f022                	sd	s0,32(sp)
    800021b6:	ec26                	sd	s1,24(sp)
    800021b8:	e84a                	sd	s2,16(sp)
    800021ba:	e44e                	sd	s3,8(sp)
    800021bc:	e052                	sd	s4,0(sp)
    800021be:	1800                	addi	s0,sp,48
    800021c0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021c2:	0000f497          	auipc	s1,0xf
    800021c6:	dce48493          	addi	s1,s1,-562 # 80010f90 <proc>
      pp->parent = initproc;
    800021ca:	00006a17          	auipc	s4,0x6
    800021ce:	71ea0a13          	addi	s4,s4,1822 # 800088e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d2:	00015997          	auipc	s3,0x15
    800021d6:	bbe98993          	addi	s3,s3,-1090 # 80016d90 <tickslock>
    800021da:	a029                	j	800021e4 <reparent+0x34>
    800021dc:	17848493          	addi	s1,s1,376
    800021e0:	01348d63          	beq	s1,s3,800021fa <reparent+0x4a>
    if(pp->parent == p){
    800021e4:	7c9c                	ld	a5,56(s1)
    800021e6:	ff279be3          	bne	a5,s2,800021dc <reparent+0x2c>
      pp->parent = initproc;
    800021ea:	000a3503          	ld	a0,0(s4)
    800021ee:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021f0:	00000097          	auipc	ra,0x0
    800021f4:	f4a080e7          	jalr	-182(ra) # 8000213a <wakeup>
    800021f8:	b7d5                	j	800021dc <reparent+0x2c>
}
    800021fa:	70a2                	ld	ra,40(sp)
    800021fc:	7402                	ld	s0,32(sp)
    800021fe:	64e2                	ld	s1,24(sp)
    80002200:	6942                	ld	s2,16(sp)
    80002202:	69a2                	ld	s3,8(sp)
    80002204:	6a02                	ld	s4,0(sp)
    80002206:	6145                	addi	sp,sp,48
    80002208:	8082                	ret

000000008000220a <exit>:
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	7a0080e7          	jalr	1952(ra) # 800019bc <myproc>
    80002224:	89aa                	mv	s3,a0
  if(p == initproc)
    80002226:	00006797          	auipc	a5,0x6
    8000222a:	6c27b783          	ld	a5,1730(a5) # 800088e8 <initproc>
    8000222e:	0d050493          	addi	s1,a0,208
    80002232:	15050913          	addi	s2,a0,336
    80002236:	02a79363          	bne	a5,a0,8000225c <exit+0x52>
    panic("init exiting");
    8000223a:	00006517          	auipc	a0,0x6
    8000223e:	04e50513          	addi	a0,a0,78 # 80008288 <digits+0x248>
    80002242:	ffffe097          	auipc	ra,0xffffe
    80002246:	2fc080e7          	jalr	764(ra) # 8000053e <panic>
      fileclose(f);
    8000224a:	00002097          	auipc	ra,0x2
    8000224e:	4fa080e7          	jalr	1274(ra) # 80004744 <fileclose>
      p->ofile[fd] = 0;
    80002252:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002256:	04a1                	addi	s1,s1,8
    80002258:	01248563          	beq	s1,s2,80002262 <exit+0x58>
    if(p->ofile[fd]){
    8000225c:	6088                	ld	a0,0(s1)
    8000225e:	f575                	bnez	a0,8000224a <exit+0x40>
    80002260:	bfdd                	j	80002256 <exit+0x4c>
  begin_op();
    80002262:	00002097          	auipc	ra,0x2
    80002266:	016080e7          	jalr	22(ra) # 80004278 <begin_op>
  iput(p->cwd);
    8000226a:	1509b503          	ld	a0,336(s3)
    8000226e:	00002097          	auipc	ra,0x2
    80002272:	802080e7          	jalr	-2046(ra) # 80003a70 <iput>
  end_op();
    80002276:	00002097          	auipc	ra,0x2
    8000227a:	082080e7          	jalr	130(ra) # 800042f8 <end_op>
  p->cwd = 0;
    8000227e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002282:	0000f497          	auipc	s1,0xf
    80002286:	8f648493          	addi	s1,s1,-1802 # 80010b78 <wait_lock>
    8000228a:	8526                	mv	a0,s1
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	94a080e7          	jalr	-1718(ra) # 80000bd6 <acquire>
  reparent(p);
    80002294:	854e                	mv	a0,s3
    80002296:	00000097          	auipc	ra,0x0
    8000229a:	f1a080e7          	jalr	-230(ra) # 800021b0 <reparent>
  wakeup(p->parent);
    8000229e:	0389b503          	ld	a0,56(s3)
    800022a2:	00000097          	auipc	ra,0x0
    800022a6:	e98080e7          	jalr	-360(ra) # 8000213a <wakeup>
  acquire(&p->lock);
    800022aa:	854e                	mv	a0,s3
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	92a080e7          	jalr	-1750(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800022b4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022b8:	4795                	li	a5,5
    800022ba:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks; // update the exit time of the process
    800022be:	00006797          	auipc	a5,0x6
    800022c2:	6327a783          	lw	a5,1586(a5) # 800088f0 <ticks>
    800022c6:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	9be080e7          	jalr	-1602(ra) # 80000c8a <release>
  sched();
    800022d4:	00000097          	auipc	ra,0x0
    800022d8:	cf0080e7          	jalr	-784(ra) # 80001fc4 <sched>
  panic("zombie exit");
    800022dc:	00006517          	auipc	a0,0x6
    800022e0:	fbc50513          	addi	a0,a0,-68 # 80008298 <digits+0x258>
    800022e4:	ffffe097          	auipc	ra,0xffffe
    800022e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>

00000000800022ec <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022ec:	7179                	addi	sp,sp,-48
    800022ee:	f406                	sd	ra,40(sp)
    800022f0:	f022                	sd	s0,32(sp)
    800022f2:	ec26                	sd	s1,24(sp)
    800022f4:	e84a                	sd	s2,16(sp)
    800022f6:	e44e                	sd	s3,8(sp)
    800022f8:	1800                	addi	s0,sp,48
    800022fa:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022fc:	0000f497          	auipc	s1,0xf
    80002300:	c9448493          	addi	s1,s1,-876 # 80010f90 <proc>
    80002304:	00015997          	auipc	s3,0x15
    80002308:	a8c98993          	addi	s3,s3,-1396 # 80016d90 <tickslock>
    acquire(&p->lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	8c8080e7          	jalr	-1848(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002316:	589c                	lw	a5,48(s1)
    80002318:	01278d63          	beq	a5,s2,80002332 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000231c:	8526                	mv	a0,s1
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	96c080e7          	jalr	-1684(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002326:	17848493          	addi	s1,s1,376
    8000232a:	ff3491e3          	bne	s1,s3,8000230c <kill+0x20>
  }
  return -1;
    8000232e:	557d                	li	a0,-1
    80002330:	a829                	j	8000234a <kill+0x5e>
      p->killed = 1;
    80002332:	4785                	li	a5,1
    80002334:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002336:	4c98                	lw	a4,24(s1)
    80002338:	4789                	li	a5,2
    8000233a:	00f70f63          	beq	a4,a5,80002358 <kill+0x6c>
      release(&p->lock);
    8000233e:	8526                	mv	a0,s1
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	94a080e7          	jalr	-1718(ra) # 80000c8a <release>
      return 0;
    80002348:	4501                	li	a0,0
}
    8000234a:	70a2                	ld	ra,40(sp)
    8000234c:	7402                	ld	s0,32(sp)
    8000234e:	64e2                	ld	s1,24(sp)
    80002350:	6942                	ld	s2,16(sp)
    80002352:	69a2                	ld	s3,8(sp)
    80002354:	6145                	addi	sp,sp,48
    80002356:	8082                	ret
        p->state = RUNNABLE;
    80002358:	478d                	li	a5,3
    8000235a:	cc9c                	sw	a5,24(s1)
    8000235c:	b7cd                	j	8000233e <kill+0x52>

000000008000235e <setkilled>:

void
setkilled(struct proc *p)
{
    8000235e:	1101                	addi	sp,sp,-32
    80002360:	ec06                	sd	ra,24(sp)
    80002362:	e822                	sd	s0,16(sp)
    80002364:	e426                	sd	s1,8(sp)
    80002366:	1000                	addi	s0,sp,32
    80002368:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	86c080e7          	jalr	-1940(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002372:	4785                	li	a5,1
    80002374:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002376:	8526                	mv	a0,s1
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	912080e7          	jalr	-1774(ra) # 80000c8a <release>
}
    80002380:	60e2                	ld	ra,24(sp)
    80002382:	6442                	ld	s0,16(sp)
    80002384:	64a2                	ld	s1,8(sp)
    80002386:	6105                	addi	sp,sp,32
    80002388:	8082                	ret

000000008000238a <killed>:

int
killed(struct proc *p)
{
    8000238a:	1101                	addi	sp,sp,-32
    8000238c:	ec06                	sd	ra,24(sp)
    8000238e:	e822                	sd	s0,16(sp)
    80002390:	e426                	sd	s1,8(sp)
    80002392:	e04a                	sd	s2,0(sp)
    80002394:	1000                	addi	s0,sp,32
    80002396:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	83e080e7          	jalr	-1986(ra) # 80000bd6 <acquire>
  k = p->killed;
    800023a0:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	8e4080e7          	jalr	-1820(ra) # 80000c8a <release>
  return k;
}
    800023ae:	854a                	mv	a0,s2
    800023b0:	60e2                	ld	ra,24(sp)
    800023b2:	6442                	ld	s0,16(sp)
    800023b4:	64a2                	ld	s1,8(sp)
    800023b6:	6902                	ld	s2,0(sp)
    800023b8:	6105                	addi	sp,sp,32
    800023ba:	8082                	ret

00000000800023bc <wait>:
{
    800023bc:	715d                	addi	sp,sp,-80
    800023be:	e486                	sd	ra,72(sp)
    800023c0:	e0a2                	sd	s0,64(sp)
    800023c2:	fc26                	sd	s1,56(sp)
    800023c4:	f84a                	sd	s2,48(sp)
    800023c6:	f44e                	sd	s3,40(sp)
    800023c8:	f052                	sd	s4,32(sp)
    800023ca:	ec56                	sd	s5,24(sp)
    800023cc:	e85a                	sd	s6,16(sp)
    800023ce:	e45e                	sd	s7,8(sp)
    800023d0:	e062                	sd	s8,0(sp)
    800023d2:	0880                	addi	s0,sp,80
    800023d4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	5e6080e7          	jalr	1510(ra) # 800019bc <myproc>
    800023de:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023e0:	0000e517          	auipc	a0,0xe
    800023e4:	79850513          	addi	a0,a0,1944 # 80010b78 <wait_lock>
    800023e8:	ffffe097          	auipc	ra,0xffffe
    800023ec:	7ee080e7          	jalr	2030(ra) # 80000bd6 <acquire>
    havekids = 0;
    800023f0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023f2:	4a15                	li	s4,5
        havekids = 1;
    800023f4:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f6:	00015997          	auipc	s3,0x15
    800023fa:	99a98993          	addi	s3,s3,-1638 # 80016d90 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023fe:	0000ec17          	auipc	s8,0xe
    80002402:	77ac0c13          	addi	s8,s8,1914 # 80010b78 <wait_lock>
    havekids = 0;
    80002406:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002408:	0000f497          	auipc	s1,0xf
    8000240c:	b8848493          	addi	s1,s1,-1144 # 80010f90 <proc>
    80002410:	a0bd                	j	8000247e <wait+0xc2>
          pid = pp->pid;
    80002412:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002416:	000b0e63          	beqz	s6,80002432 <wait+0x76>
    8000241a:	4691                	li	a3,4
    8000241c:	02c48613          	addi	a2,s1,44
    80002420:	85da                	mv	a1,s6
    80002422:	05093503          	ld	a0,80(s2)
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	252080e7          	jalr	594(ra) # 80001678 <copyout>
    8000242e:	02054563          	bltz	a0,80002458 <wait+0x9c>
          freeproc(pp);
    80002432:	8526                	mv	a0,s1
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	73a080e7          	jalr	1850(ra) # 80001b6e <freeproc>
          release(&pp->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	84c080e7          	jalr	-1972(ra) # 80000c8a <release>
          release(&wait_lock);
    80002446:	0000e517          	auipc	a0,0xe
    8000244a:	73250513          	addi	a0,a0,1842 # 80010b78 <wait_lock>
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	83c080e7          	jalr	-1988(ra) # 80000c8a <release>
          return pid;
    80002456:	a0b5                	j	800024c2 <wait+0x106>
            release(&pp->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	830080e7          	jalr	-2000(ra) # 80000c8a <release>
            release(&wait_lock);
    80002462:	0000e517          	auipc	a0,0xe
    80002466:	71650513          	addi	a0,a0,1814 # 80010b78 <wait_lock>
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	820080e7          	jalr	-2016(ra) # 80000c8a <release>
            return -1;
    80002472:	59fd                	li	s3,-1
    80002474:	a0b9                	j	800024c2 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002476:	17848493          	addi	s1,s1,376
    8000247a:	03348463          	beq	s1,s3,800024a2 <wait+0xe6>
      if(pp->parent == p){
    8000247e:	7c9c                	ld	a5,56(s1)
    80002480:	ff279be3          	bne	a5,s2,80002476 <wait+0xba>
        acquire(&pp->lock);
    80002484:	8526                	mv	a0,s1
    80002486:	ffffe097          	auipc	ra,0xffffe
    8000248a:	750080e7          	jalr	1872(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    8000248e:	4c9c                	lw	a5,24(s1)
    80002490:	f94781e3          	beq	a5,s4,80002412 <wait+0x56>
        release(&pp->lock);
    80002494:	8526                	mv	a0,s1
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	7f4080e7          	jalr	2036(ra) # 80000c8a <release>
        havekids = 1;
    8000249e:	8756                	mv	a4,s5
    800024a0:	bfd9                	j	80002476 <wait+0xba>
    if(!havekids || killed(p)){
    800024a2:	c719                	beqz	a4,800024b0 <wait+0xf4>
    800024a4:	854a                	mv	a0,s2
    800024a6:	00000097          	auipc	ra,0x0
    800024aa:	ee4080e7          	jalr	-284(ra) # 8000238a <killed>
    800024ae:	c51d                	beqz	a0,800024dc <wait+0x120>
      release(&wait_lock);
    800024b0:	0000e517          	auipc	a0,0xe
    800024b4:	6c850513          	addi	a0,a0,1736 # 80010b78 <wait_lock>
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	7d2080e7          	jalr	2002(ra) # 80000c8a <release>
      return -1;
    800024c0:	59fd                	li	s3,-1
}
    800024c2:	854e                	mv	a0,s3
    800024c4:	60a6                	ld	ra,72(sp)
    800024c6:	6406                	ld	s0,64(sp)
    800024c8:	74e2                	ld	s1,56(sp)
    800024ca:	7942                	ld	s2,48(sp)
    800024cc:	79a2                	ld	s3,40(sp)
    800024ce:	7a02                	ld	s4,32(sp)
    800024d0:	6ae2                	ld	s5,24(sp)
    800024d2:	6b42                	ld	s6,16(sp)
    800024d4:	6ba2                	ld	s7,8(sp)
    800024d6:	6c02                	ld	s8,0(sp)
    800024d8:	6161                	addi	sp,sp,80
    800024da:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024dc:	85e2                	mv	a1,s8
    800024de:	854a                	mv	a0,s2
    800024e0:	00000097          	auipc	ra,0x0
    800024e4:	bf6080e7          	jalr	-1034(ra) # 800020d6 <sleep>
    havekids = 0;
    800024e8:	bf39                	j	80002406 <wait+0x4a>

00000000800024ea <waitx>:
{
    800024ea:	711d                	addi	sp,sp,-96
    800024ec:	ec86                	sd	ra,88(sp)
    800024ee:	e8a2                	sd	s0,80(sp)
    800024f0:	e4a6                	sd	s1,72(sp)
    800024f2:	e0ca                	sd	s2,64(sp)
    800024f4:	fc4e                	sd	s3,56(sp)
    800024f6:	f852                	sd	s4,48(sp)
    800024f8:	f456                	sd	s5,40(sp)
    800024fa:	f05a                	sd	s6,32(sp)
    800024fc:	ec5e                	sd	s7,24(sp)
    800024fe:	e862                	sd	s8,16(sp)
    80002500:	e466                	sd	s9,8(sp)
    80002502:	e06a                	sd	s10,0(sp)
    80002504:	1080                	addi	s0,sp,96
    80002506:	8b2a                	mv	s6,a0
    80002508:	8bae                	mv	s7,a1
    8000250a:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    8000250c:	fffff097          	auipc	ra,0xfffff
    80002510:	4b0080e7          	jalr	1200(ra) # 800019bc <myproc>
    80002514:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002516:	0000e517          	auipc	a0,0xe
    8000251a:	66250513          	addi	a0,a0,1634 # 80010b78 <wait_lock>
    8000251e:	ffffe097          	auipc	ra,0xffffe
    80002522:	6b8080e7          	jalr	1720(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002526:	4c81                	li	s9,0
        if(pp->state == ZOMBIE){
    80002528:	4a15                	li	s4,5
        havekids = 1;
    8000252a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000252c:	00015997          	auipc	s3,0x15
    80002530:	86498993          	addi	s3,s3,-1948 # 80016d90 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002534:	0000ed17          	auipc	s10,0xe
    80002538:	644d0d13          	addi	s10,s10,1604 # 80010b78 <wait_lock>
    havekids = 0;
    8000253c:	8766                	mv	a4,s9
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000253e:	0000f497          	auipc	s1,0xf
    80002542:	a5248493          	addi	s1,s1,-1454 # 80010f90 <proc>
    80002546:	a059                	j	800025cc <waitx+0xe2>
          pid = pp->pid;
    80002548:	0304a983          	lw	s3,48(s1)
          *rtime = pp->rtime;
    8000254c:	1684a703          	lw	a4,360(s1)
    80002550:	00ec2023          	sw	a4,0(s8)
          *wtime = pp->etime - pp->ctime - pp->rtime;          
    80002554:	16c4a783          	lw	a5,364(s1)
    80002558:	9f3d                	addw	a4,a4,a5
    8000255a:	1704a783          	lw	a5,368(s1)
    8000255e:	9f99                	subw	a5,a5,a4
    80002560:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdce90>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002564:	000b0e63          	beqz	s6,80002580 <waitx+0x96>
    80002568:	4691                	li	a3,4
    8000256a:	02c48613          	addi	a2,s1,44
    8000256e:	85da                	mv	a1,s6
    80002570:	05093503          	ld	a0,80(s2)
    80002574:	fffff097          	auipc	ra,0xfffff
    80002578:	104080e7          	jalr	260(ra) # 80001678 <copyout>
    8000257c:	02054563          	bltz	a0,800025a6 <waitx+0xbc>
          freeproc(pp);
    80002580:	8526                	mv	a0,s1
    80002582:	fffff097          	auipc	ra,0xfffff
    80002586:	5ec080e7          	jalr	1516(ra) # 80001b6e <freeproc>
          release(&pp->lock);
    8000258a:	8526                	mv	a0,s1
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	6fe080e7          	jalr	1790(ra) # 80000c8a <release>
          release(&wait_lock);
    80002594:	0000e517          	auipc	a0,0xe
    80002598:	5e450513          	addi	a0,a0,1508 # 80010b78 <wait_lock>
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	6ee080e7          	jalr	1774(ra) # 80000c8a <release>
          return pid;
    800025a4:	a0b5                	j	80002610 <waitx+0x126>
            release(&pp->lock);
    800025a6:	8526                	mv	a0,s1
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	6e2080e7          	jalr	1762(ra) # 80000c8a <release>
            release(&wait_lock);
    800025b0:	0000e517          	auipc	a0,0xe
    800025b4:	5c850513          	addi	a0,a0,1480 # 80010b78 <wait_lock>
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	6d2080e7          	jalr	1746(ra) # 80000c8a <release>
            return -1;
    800025c0:	59fd                	li	s3,-1
    800025c2:	a0b9                	j	80002610 <waitx+0x126>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025c4:	17848493          	addi	s1,s1,376
    800025c8:	03348463          	beq	s1,s3,800025f0 <waitx+0x106>
      if(pp->parent == p){
    800025cc:	7c9c                	ld	a5,56(s1)
    800025ce:	ff279be3          	bne	a5,s2,800025c4 <waitx+0xda>
        acquire(&pp->lock);
    800025d2:	8526                	mv	a0,s1
    800025d4:	ffffe097          	auipc	ra,0xffffe
    800025d8:	602080e7          	jalr	1538(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    800025dc:	4c9c                	lw	a5,24(s1)
    800025de:	f74785e3          	beq	a5,s4,80002548 <waitx+0x5e>
        release(&pp->lock);
    800025e2:	8526                	mv	a0,s1
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	6a6080e7          	jalr	1702(ra) # 80000c8a <release>
        havekids = 1;
    800025ec:	8756                	mv	a4,s5
    800025ee:	bfd9                	j	800025c4 <waitx+0xda>
    if(!havekids || killed(p)){
    800025f0:	c719                	beqz	a4,800025fe <waitx+0x114>
    800025f2:	854a                	mv	a0,s2
    800025f4:	00000097          	auipc	ra,0x0
    800025f8:	d96080e7          	jalr	-618(ra) # 8000238a <killed>
    800025fc:	c90d                	beqz	a0,8000262e <waitx+0x144>
      release(&wait_lock);
    800025fe:	0000e517          	auipc	a0,0xe
    80002602:	57a50513          	addi	a0,a0,1402 # 80010b78 <wait_lock>
    80002606:	ffffe097          	auipc	ra,0xffffe
    8000260a:	684080e7          	jalr	1668(ra) # 80000c8a <release>
      return -1;
    8000260e:	59fd                	li	s3,-1
}
    80002610:	854e                	mv	a0,s3
    80002612:	60e6                	ld	ra,88(sp)
    80002614:	6446                	ld	s0,80(sp)
    80002616:	64a6                	ld	s1,72(sp)
    80002618:	6906                	ld	s2,64(sp)
    8000261a:	79e2                	ld	s3,56(sp)
    8000261c:	7a42                	ld	s4,48(sp)
    8000261e:	7aa2                	ld	s5,40(sp)
    80002620:	7b02                	ld	s6,32(sp)
    80002622:	6be2                	ld	s7,24(sp)
    80002624:	6c42                	ld	s8,16(sp)
    80002626:	6ca2                	ld	s9,8(sp)
    80002628:	6d02                	ld	s10,0(sp)
    8000262a:	6125                	addi	sp,sp,96
    8000262c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000262e:	85ea                	mv	a1,s10
    80002630:	854a                	mv	a0,s2
    80002632:	00000097          	auipc	ra,0x0
    80002636:	aa4080e7          	jalr	-1372(ra) # 800020d6 <sleep>
    havekids = 0;
    8000263a:	b709                	j	8000253c <waitx+0x52>

000000008000263c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000263c:	7179                	addi	sp,sp,-48
    8000263e:	f406                	sd	ra,40(sp)
    80002640:	f022                	sd	s0,32(sp)
    80002642:	ec26                	sd	s1,24(sp)
    80002644:	e84a                	sd	s2,16(sp)
    80002646:	e44e                	sd	s3,8(sp)
    80002648:	e052                	sd	s4,0(sp)
    8000264a:	1800                	addi	s0,sp,48
    8000264c:	84aa                	mv	s1,a0
    8000264e:	892e                	mv	s2,a1
    80002650:	89b2                	mv	s3,a2
    80002652:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002654:	fffff097          	auipc	ra,0xfffff
    80002658:	368080e7          	jalr	872(ra) # 800019bc <myproc>
  if(user_dst){
    8000265c:	c08d                	beqz	s1,8000267e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000265e:	86d2                	mv	a3,s4
    80002660:	864e                	mv	a2,s3
    80002662:	85ca                	mv	a1,s2
    80002664:	6928                	ld	a0,80(a0)
    80002666:	fffff097          	auipc	ra,0xfffff
    8000266a:	012080e7          	jalr	18(ra) # 80001678 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000266e:	70a2                	ld	ra,40(sp)
    80002670:	7402                	ld	s0,32(sp)
    80002672:	64e2                	ld	s1,24(sp)
    80002674:	6942                	ld	s2,16(sp)
    80002676:	69a2                	ld	s3,8(sp)
    80002678:	6a02                	ld	s4,0(sp)
    8000267a:	6145                	addi	sp,sp,48
    8000267c:	8082                	ret
    memmove((char *)dst, src, len);
    8000267e:	000a061b          	sext.w	a2,s4
    80002682:	85ce                	mv	a1,s3
    80002684:	854a                	mv	a0,s2
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	6a8080e7          	jalr	1704(ra) # 80000d2e <memmove>
    return 0;
    8000268e:	8526                	mv	a0,s1
    80002690:	bff9                	j	8000266e <either_copyout+0x32>

0000000080002692 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002692:	7179                	addi	sp,sp,-48
    80002694:	f406                	sd	ra,40(sp)
    80002696:	f022                	sd	s0,32(sp)
    80002698:	ec26                	sd	s1,24(sp)
    8000269a:	e84a                	sd	s2,16(sp)
    8000269c:	e44e                	sd	s3,8(sp)
    8000269e:	e052                	sd	s4,0(sp)
    800026a0:	1800                	addi	s0,sp,48
    800026a2:	892a                	mv	s2,a0
    800026a4:	84ae                	mv	s1,a1
    800026a6:	89b2                	mv	s3,a2
    800026a8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026aa:	fffff097          	auipc	ra,0xfffff
    800026ae:	312080e7          	jalr	786(ra) # 800019bc <myproc>
  if(user_src){
    800026b2:	c08d                	beqz	s1,800026d4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026b4:	86d2                	mv	a3,s4
    800026b6:	864e                	mv	a2,s3
    800026b8:	85ca                	mv	a1,s2
    800026ba:	6928                	ld	a0,80(a0)
    800026bc:	fffff097          	auipc	ra,0xfffff
    800026c0:	048080e7          	jalr	72(ra) # 80001704 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026c4:	70a2                	ld	ra,40(sp)
    800026c6:	7402                	ld	s0,32(sp)
    800026c8:	64e2                	ld	s1,24(sp)
    800026ca:	6942                	ld	s2,16(sp)
    800026cc:	69a2                	ld	s3,8(sp)
    800026ce:	6a02                	ld	s4,0(sp)
    800026d0:	6145                	addi	sp,sp,48
    800026d2:	8082                	ret
    memmove(dst, (char*)src, len);
    800026d4:	000a061b          	sext.w	a2,s4
    800026d8:	85ce                	mv	a1,s3
    800026da:	854a                	mv	a0,s2
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	652080e7          	jalr	1618(ra) # 80000d2e <memmove>
    return 0;
    800026e4:	8526                	mv	a0,s1
    800026e6:	bff9                	j	800026c4 <either_copyin+0x32>

00000000800026e8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800026e8:	715d                	addi	sp,sp,-80
    800026ea:	e486                	sd	ra,72(sp)
    800026ec:	e0a2                	sd	s0,64(sp)
    800026ee:	fc26                	sd	s1,56(sp)
    800026f0:	f84a                	sd	s2,48(sp)
    800026f2:	f44e                	sd	s3,40(sp)
    800026f4:	f052                	sd	s4,32(sp)
    800026f6:	ec56                	sd	s5,24(sp)
    800026f8:	e85a                	sd	s6,16(sp)
    800026fa:	e45e                	sd	s7,8(sp)
    800026fc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800026fe:	00006517          	auipc	a0,0x6
    80002702:	9f250513          	addi	a0,a0,-1550 # 800080f0 <digits+0xb0>
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	e82080e7          	jalr	-382(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000270e:	0000f497          	auipc	s1,0xf
    80002712:	9da48493          	addi	s1,s1,-1574 # 800110e8 <proc+0x158>
    80002716:	00014917          	auipc	s2,0x14
    8000271a:	7d290913          	addi	s2,s2,2002 # 80016ee8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000271e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002720:	00006997          	auipc	s3,0x6
    80002724:	b8898993          	addi	s3,s3,-1144 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    80002728:	00006a97          	auipc	s5,0x6
    8000272c:	b88a8a93          	addi	s5,s5,-1144 # 800082b0 <digits+0x270>
    printf("\n");
    80002730:	00006a17          	auipc	s4,0x6
    80002734:	9c0a0a13          	addi	s4,s4,-1600 # 800080f0 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002738:	00006b97          	auipc	s7,0x6
    8000273c:	bb8b8b93          	addi	s7,s7,-1096 # 800082f0 <states.0>
    80002740:	a00d                	j	80002762 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002742:	ed86a583          	lw	a1,-296(a3)
    80002746:	8556                	mv	a0,s5
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	e40080e7          	jalr	-448(ra) # 80000588 <printf>
    printf("\n");
    80002750:	8552                	mv	a0,s4
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	e36080e7          	jalr	-458(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000275a:	17848493          	addi	s1,s1,376
    8000275e:	03248163          	beq	s1,s2,80002780 <procdump+0x98>
    if(p->state == UNUSED)
    80002762:	86a6                	mv	a3,s1
    80002764:	ec04a783          	lw	a5,-320(s1)
    80002768:	dbed                	beqz	a5,8000275a <procdump+0x72>
      state = "???";
    8000276a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000276c:	fcfb6be3          	bltu	s6,a5,80002742 <procdump+0x5a>
    80002770:	1782                	slli	a5,a5,0x20
    80002772:	9381                	srli	a5,a5,0x20
    80002774:	078e                	slli	a5,a5,0x3
    80002776:	97de                	add	a5,a5,s7
    80002778:	6390                	ld	a2,0(a5)
    8000277a:	f661                	bnez	a2,80002742 <procdump+0x5a>
      state = "???";
    8000277c:	864e                	mv	a2,s3
    8000277e:	b7d1                	j	80002742 <procdump+0x5a>
  }
}
    80002780:	60a6                	ld	ra,72(sp)
    80002782:	6406                	ld	s0,64(sp)
    80002784:	74e2                	ld	s1,56(sp)
    80002786:	7942                	ld	s2,48(sp)
    80002788:	79a2                	ld	s3,40(sp)
    8000278a:	7a02                	ld	s4,32(sp)
    8000278c:	6ae2                	ld	s5,24(sp)
    8000278e:	6b42                	ld	s6,16(sp)
    80002790:	6ba2                	ld	s7,8(sp)
    80002792:	6161                	addi	sp,sp,80
    80002794:	8082                	ret

0000000080002796 <swtch>:
    80002796:	00153023          	sd	ra,0(a0)
    8000279a:	00253423          	sd	sp,8(a0)
    8000279e:	e900                	sd	s0,16(a0)
    800027a0:	ed04                	sd	s1,24(a0)
    800027a2:	03253023          	sd	s2,32(a0)
    800027a6:	03353423          	sd	s3,40(a0)
    800027aa:	03453823          	sd	s4,48(a0)
    800027ae:	03553c23          	sd	s5,56(a0)
    800027b2:	05653023          	sd	s6,64(a0)
    800027b6:	05753423          	sd	s7,72(a0)
    800027ba:	05853823          	sd	s8,80(a0)
    800027be:	05953c23          	sd	s9,88(a0)
    800027c2:	07a53023          	sd	s10,96(a0)
    800027c6:	07b53423          	sd	s11,104(a0)
    800027ca:	0005b083          	ld	ra,0(a1)
    800027ce:	0085b103          	ld	sp,8(a1)
    800027d2:	6980                	ld	s0,16(a1)
    800027d4:	6d84                	ld	s1,24(a1)
    800027d6:	0205b903          	ld	s2,32(a1)
    800027da:	0285b983          	ld	s3,40(a1)
    800027de:	0305ba03          	ld	s4,48(a1)
    800027e2:	0385ba83          	ld	s5,56(a1)
    800027e6:	0405bb03          	ld	s6,64(a1)
    800027ea:	0485bb83          	ld	s7,72(a1)
    800027ee:	0505bc03          	ld	s8,80(a1)
    800027f2:	0585bc83          	ld	s9,88(a1)
    800027f6:	0605bd03          	ld	s10,96(a1)
    800027fa:	0685bd83          	ld	s11,104(a1)
    800027fe:	8082                	ret

0000000080002800 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002800:	1141                	addi	sp,sp,-16
    80002802:	e406                	sd	ra,8(sp)
    80002804:	e022                	sd	s0,0(sp)
    80002806:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002808:	00006597          	auipc	a1,0x6
    8000280c:	b1858593          	addi	a1,a1,-1256 # 80008320 <states.0+0x30>
    80002810:	00014517          	auipc	a0,0x14
    80002814:	58050513          	addi	a0,a0,1408 # 80016d90 <tickslock>
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	32e080e7          	jalr	814(ra) # 80000b46 <initlock>
}
    80002820:	60a2                	ld	ra,8(sp)
    80002822:	6402                	ld	s0,0(sp)
    80002824:	0141                	addi	sp,sp,16
    80002826:	8082                	ret

0000000080002828 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002828:	1141                	addi	sp,sp,-16
    8000282a:	e422                	sd	s0,8(sp)
    8000282c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000282e:	00003797          	auipc	a5,0x3
    80002832:	56278793          	addi	a5,a5,1378 # 80005d90 <kernelvec>
    80002836:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000283a:	6422                	ld	s0,8(sp)
    8000283c:	0141                	addi	sp,sp,16
    8000283e:	8082                	ret

0000000080002840 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002840:	1141                	addi	sp,sp,-16
    80002842:	e406                	sd	ra,8(sp)
    80002844:	e022                	sd	s0,0(sp)
    80002846:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002848:	fffff097          	auipc	ra,0xfffff
    8000284c:	174080e7          	jalr	372(ra) # 800019bc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002850:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002854:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002856:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000285a:	00004617          	auipc	a2,0x4
    8000285e:	7a660613          	addi	a2,a2,1958 # 80007000 <_trampoline>
    80002862:	00004697          	auipc	a3,0x4
    80002866:	79e68693          	addi	a3,a3,1950 # 80007000 <_trampoline>
    8000286a:	8e91                	sub	a3,a3,a2
    8000286c:	040007b7          	lui	a5,0x4000
    80002870:	17fd                	addi	a5,a5,-1
    80002872:	07b2                	slli	a5,a5,0xc
    80002874:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002876:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000287a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000287c:	180026f3          	csrr	a3,satp
    80002880:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002882:	6d38                	ld	a4,88(a0)
    80002884:	6134                	ld	a3,64(a0)
    80002886:	6585                	lui	a1,0x1
    80002888:	96ae                	add	a3,a3,a1
    8000288a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000288c:	6d38                	ld	a4,88(a0)
    8000288e:	00000697          	auipc	a3,0x0
    80002892:	13e68693          	addi	a3,a3,318 # 800029cc <usertrap>
    80002896:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002898:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000289a:	8692                	mv	a3,tp
    8000289c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000289e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028a2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028a6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028aa:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028ae:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028b0:	6f18                	ld	a4,24(a4)
    800028b2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028b6:	6928                	ld	a0,80(a0)
    800028b8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028ba:	00004717          	auipc	a4,0x4
    800028be:	7e270713          	addi	a4,a4,2018 # 8000709c <userret>
    800028c2:	8f11                	sub	a4,a4,a2
    800028c4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028c6:	577d                	li	a4,-1
    800028c8:	177e                	slli	a4,a4,0x3f
    800028ca:	8d59                	or	a0,a0,a4
    800028cc:	9782                	jalr	a5
}
    800028ce:	60a2                	ld	ra,8(sp)
    800028d0:	6402                	ld	s0,0(sp)
    800028d2:	0141                	addi	sp,sp,16
    800028d4:	8082                	ret

00000000800028d6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028d6:	1101                	addi	sp,sp,-32
    800028d8:	ec06                	sd	ra,24(sp)
    800028da:	e822                	sd	s0,16(sp)
    800028dc:	e426                	sd	s1,8(sp)
    800028de:	e04a                	sd	s2,0(sp)
    800028e0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800028e2:	00014917          	auipc	s2,0x14
    800028e6:	4ae90913          	addi	s2,s2,1198 # 80016d90 <tickslock>
    800028ea:	854a                	mv	a0,s2
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	2ea080e7          	jalr	746(ra) # 80000bd6 <acquire>
  ticks++;
    800028f4:	00006497          	auipc	s1,0x6
    800028f8:	ffc48493          	addi	s1,s1,-4 # 800088f0 <ticks>
    800028fc:	409c                	lw	a5,0(s1)
    800028fe:	2785                	addiw	a5,a5,1
    80002900:	c09c                	sw	a5,0(s1)
  update_time();
    80002902:	fffff097          	auipc	ra,0xfffff
    80002906:	5c4080e7          	jalr	1476(ra) # 80001ec6 <update_time>
  wakeup(&ticks);
    8000290a:	8526                	mv	a0,s1
    8000290c:	00000097          	auipc	ra,0x0
    80002910:	82e080e7          	jalr	-2002(ra) # 8000213a <wakeup>
  release(&tickslock);
    80002914:	854a                	mv	a0,s2
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	374080e7          	jalr	884(ra) # 80000c8a <release>
}
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6902                	ld	s2,0(sp)
    80002926:	6105                	addi	sp,sp,32
    80002928:	8082                	ret

000000008000292a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000292a:	1101                	addi	sp,sp,-32
    8000292c:	ec06                	sd	ra,24(sp)
    8000292e:	e822                	sd	s0,16(sp)
    80002930:	e426                	sd	s1,8(sp)
    80002932:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002934:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002938:	00074d63          	bltz	a4,80002952 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000293c:	57fd                	li	a5,-1
    8000293e:	17fe                	slli	a5,a5,0x3f
    80002940:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002942:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002944:	06f70363          	beq	a4,a5,800029aa <devintr+0x80>
  }
}
    80002948:	60e2                	ld	ra,24(sp)
    8000294a:	6442                	ld	s0,16(sp)
    8000294c:	64a2                	ld	s1,8(sp)
    8000294e:	6105                	addi	sp,sp,32
    80002950:	8082                	ret
     (scause & 0xff) == 9){
    80002952:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002956:	46a5                	li	a3,9
    80002958:	fed792e3          	bne	a5,a3,8000293c <devintr+0x12>
    int irq = plic_claim();
    8000295c:	00003097          	auipc	ra,0x3
    80002960:	53c080e7          	jalr	1340(ra) # 80005e98 <plic_claim>
    80002964:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002966:	47a9                	li	a5,10
    80002968:	02f50763          	beq	a0,a5,80002996 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000296c:	4785                	li	a5,1
    8000296e:	02f50963          	beq	a0,a5,800029a0 <devintr+0x76>
    return 1;
    80002972:	4505                	li	a0,1
    } else if(irq){
    80002974:	d8f1                	beqz	s1,80002948 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002976:	85a6                	mv	a1,s1
    80002978:	00006517          	auipc	a0,0x6
    8000297c:	9b050513          	addi	a0,a0,-1616 # 80008328 <states.0+0x38>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	c08080e7          	jalr	-1016(ra) # 80000588 <printf>
      plic_complete(irq);
    80002988:	8526                	mv	a0,s1
    8000298a:	00003097          	auipc	ra,0x3
    8000298e:	532080e7          	jalr	1330(ra) # 80005ebc <plic_complete>
    return 1;
    80002992:	4505                	li	a0,1
    80002994:	bf55                	j	80002948 <devintr+0x1e>
      uartintr();
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	004080e7          	jalr	4(ra) # 8000099a <uartintr>
    8000299e:	b7ed                	j	80002988 <devintr+0x5e>
      virtio_disk_intr();
    800029a0:	00004097          	auipc	ra,0x4
    800029a4:	9e8080e7          	jalr	-1560(ra) # 80006388 <virtio_disk_intr>
    800029a8:	b7c5                	j	80002988 <devintr+0x5e>
    if(cpuid() == 0){
    800029aa:	fffff097          	auipc	ra,0xfffff
    800029ae:	fe6080e7          	jalr	-26(ra) # 80001990 <cpuid>
    800029b2:	c901                	beqz	a0,800029c2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029b4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029b8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029ba:	14479073          	csrw	sip,a5
    return 2;
    800029be:	4509                	li	a0,2
    800029c0:	b761                	j	80002948 <devintr+0x1e>
      clockintr();
    800029c2:	00000097          	auipc	ra,0x0
    800029c6:	f14080e7          	jalr	-236(ra) # 800028d6 <clockintr>
    800029ca:	b7ed                	j	800029b4 <devintr+0x8a>

00000000800029cc <usertrap>:
{
    800029cc:	1101                	addi	sp,sp,-32
    800029ce:	ec06                	sd	ra,24(sp)
    800029d0:	e822                	sd	s0,16(sp)
    800029d2:	e426                	sd	s1,8(sp)
    800029d4:	e04a                	sd	s2,0(sp)
    800029d6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029dc:	1007f793          	andi	a5,a5,256
    800029e0:	e3b1                	bnez	a5,80002a24 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e2:	00003797          	auipc	a5,0x3
    800029e6:	3ae78793          	addi	a5,a5,942 # 80005d90 <kernelvec>
    800029ea:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029ee:	fffff097          	auipc	ra,0xfffff
    800029f2:	fce080e7          	jalr	-50(ra) # 800019bc <myproc>
    800029f6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029f8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029fa:	14102773          	csrr	a4,sepc
    800029fe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a00:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a04:	47a1                	li	a5,8
    80002a06:	02f70763          	beq	a4,a5,80002a34 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a0a:	00000097          	auipc	ra,0x0
    80002a0e:	f20080e7          	jalr	-224(ra) # 8000292a <devintr>
    80002a12:	892a                	mv	s2,a0
    80002a14:	c151                	beqz	a0,80002a98 <usertrap+0xcc>
  if(killed(p))
    80002a16:	8526                	mv	a0,s1
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	972080e7          	jalr	-1678(ra) # 8000238a <killed>
    80002a20:	c929                	beqz	a0,80002a72 <usertrap+0xa6>
    80002a22:	a099                	j	80002a68 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002a24:	00006517          	auipc	a0,0x6
    80002a28:	92450513          	addi	a0,a0,-1756 # 80008348 <states.0+0x58>
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	b12080e7          	jalr	-1262(ra) # 8000053e <panic>
    if(killed(p))
    80002a34:	00000097          	auipc	ra,0x0
    80002a38:	956080e7          	jalr	-1706(ra) # 8000238a <killed>
    80002a3c:	e921                	bnez	a0,80002a8c <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002a3e:	6cb8                	ld	a4,88(s1)
    80002a40:	6f1c                	ld	a5,24(a4)
    80002a42:	0791                	addi	a5,a5,4
    80002a44:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a4e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a52:	00000097          	auipc	ra,0x0
    80002a56:	2d4080e7          	jalr	724(ra) # 80002d26 <syscall>
  if(killed(p))
    80002a5a:	8526                	mv	a0,s1
    80002a5c:	00000097          	auipc	ra,0x0
    80002a60:	92e080e7          	jalr	-1746(ra) # 8000238a <killed>
    80002a64:	c911                	beqz	a0,80002a78 <usertrap+0xac>
    80002a66:	4901                	li	s2,0
    exit(-1);
    80002a68:	557d                	li	a0,-1
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	7a0080e7          	jalr	1952(ra) # 8000220a <exit>
  if(which_dev == 2)
    80002a72:	4789                	li	a5,2
    80002a74:	04f90f63          	beq	s2,a5,80002ad2 <usertrap+0x106>
  usertrapret();
    80002a78:	00000097          	auipc	ra,0x0
    80002a7c:	dc8080e7          	jalr	-568(ra) # 80002840 <usertrapret>
}
    80002a80:	60e2                	ld	ra,24(sp)
    80002a82:	6442                	ld	s0,16(sp)
    80002a84:	64a2                	ld	s1,8(sp)
    80002a86:	6902                	ld	s2,0(sp)
    80002a88:	6105                	addi	sp,sp,32
    80002a8a:	8082                	ret
      exit(-1);
    80002a8c:	557d                	li	a0,-1
    80002a8e:	fffff097          	auipc	ra,0xfffff
    80002a92:	77c080e7          	jalr	1916(ra) # 8000220a <exit>
    80002a96:	b765                	j	80002a3e <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a98:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a9c:	5890                	lw	a2,48(s1)
    80002a9e:	00006517          	auipc	a0,0x6
    80002aa2:	8ca50513          	addi	a0,a0,-1846 # 80008368 <states.0+0x78>
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	ae2080e7          	jalr	-1310(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ab2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ab6:	00006517          	auipc	a0,0x6
    80002aba:	8e250513          	addi	a0,a0,-1822 # 80008398 <states.0+0xa8>
    80002abe:	ffffe097          	auipc	ra,0xffffe
    80002ac2:	aca080e7          	jalr	-1334(ra) # 80000588 <printf>
    setkilled(p);
    80002ac6:	8526                	mv	a0,s1
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	896080e7          	jalr	-1898(ra) # 8000235e <setkilled>
    80002ad0:	b769                	j	80002a5a <usertrap+0x8e>
    yield();
    80002ad2:	fffff097          	auipc	ra,0xfffff
    80002ad6:	5c8080e7          	jalr	1480(ra) # 8000209a <yield>
    80002ada:	bf79                	j	80002a78 <usertrap+0xac>

0000000080002adc <kerneltrap>:
{
    80002adc:	7179                	addi	sp,sp,-48
    80002ade:	f406                	sd	ra,40(sp)
    80002ae0:	f022                	sd	s0,32(sp)
    80002ae2:	ec26                	sd	s1,24(sp)
    80002ae4:	e84a                	sd	s2,16(sp)
    80002ae6:	e44e                	sd	s3,8(sp)
    80002ae8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aea:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aee:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002af6:	1004f793          	andi	a5,s1,256
    80002afa:	cb85                	beqz	a5,80002b2a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002afc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b00:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b02:	ef85                	bnez	a5,80002b3a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	e26080e7          	jalr	-474(ra) # 8000292a <devintr>
    80002b0c:	cd1d                	beqz	a0,80002b4a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b0e:	4789                	li	a5,2
    80002b10:	06f50a63          	beq	a0,a5,80002b84 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b14:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b18:	10049073          	csrw	sstatus,s1
}
    80002b1c:	70a2                	ld	ra,40(sp)
    80002b1e:	7402                	ld	s0,32(sp)
    80002b20:	64e2                	ld	s1,24(sp)
    80002b22:	6942                	ld	s2,16(sp)
    80002b24:	69a2                	ld	s3,8(sp)
    80002b26:	6145                	addi	sp,sp,48
    80002b28:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b2a:	00006517          	auipc	a0,0x6
    80002b2e:	88e50513          	addi	a0,a0,-1906 # 800083b8 <states.0+0xc8>
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	a0c080e7          	jalr	-1524(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b3a:	00006517          	auipc	a0,0x6
    80002b3e:	8a650513          	addi	a0,a0,-1882 # 800083e0 <states.0+0xf0>
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	9fc080e7          	jalr	-1540(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002b4a:	85ce                	mv	a1,s3
    80002b4c:	00006517          	auipc	a0,0x6
    80002b50:	8b450513          	addi	a0,a0,-1868 # 80008400 <states.0+0x110>
    80002b54:	ffffe097          	auipc	ra,0xffffe
    80002b58:	a34080e7          	jalr	-1484(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b5c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b60:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b64:	00006517          	auipc	a0,0x6
    80002b68:	8ac50513          	addi	a0,a0,-1876 # 80008410 <states.0+0x120>
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	a1c080e7          	jalr	-1508(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002b74:	00006517          	auipc	a0,0x6
    80002b78:	8b450513          	addi	a0,a0,-1868 # 80008428 <states.0+0x138>
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	9c2080e7          	jalr	-1598(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	e38080e7          	jalr	-456(ra) # 800019bc <myproc>
    80002b8c:	d541                	beqz	a0,80002b14 <kerneltrap+0x38>
    80002b8e:	fffff097          	auipc	ra,0xfffff
    80002b92:	e2e080e7          	jalr	-466(ra) # 800019bc <myproc>
    80002b96:	4d18                	lw	a4,24(a0)
    80002b98:	4791                	li	a5,4
    80002b9a:	f6f71de3          	bne	a4,a5,80002b14 <kerneltrap+0x38>
    yield();
    80002b9e:	fffff097          	auipc	ra,0xfffff
    80002ba2:	4fc080e7          	jalr	1276(ra) # 8000209a <yield>
    80002ba6:	b7bd                	j	80002b14 <kerneltrap+0x38>

0000000080002ba8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ba8:	1101                	addi	sp,sp,-32
    80002baa:	ec06                	sd	ra,24(sp)
    80002bac:	e822                	sd	s0,16(sp)
    80002bae:	e426                	sd	s1,8(sp)
    80002bb0:	1000                	addi	s0,sp,32
    80002bb2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bb4:	fffff097          	auipc	ra,0xfffff
    80002bb8:	e08080e7          	jalr	-504(ra) # 800019bc <myproc>
  switch (n) {
    80002bbc:	4795                	li	a5,5
    80002bbe:	0497e163          	bltu	a5,s1,80002c00 <argraw+0x58>
    80002bc2:	048a                	slli	s1,s1,0x2
    80002bc4:	00006717          	auipc	a4,0x6
    80002bc8:	89c70713          	addi	a4,a4,-1892 # 80008460 <states.0+0x170>
    80002bcc:	94ba                	add	s1,s1,a4
    80002bce:	409c                	lw	a5,0(s1)
    80002bd0:	97ba                	add	a5,a5,a4
    80002bd2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bd4:	6d3c                	ld	a5,88(a0)
    80002bd6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bd8:	60e2                	ld	ra,24(sp)
    80002bda:	6442                	ld	s0,16(sp)
    80002bdc:	64a2                	ld	s1,8(sp)
    80002bde:	6105                	addi	sp,sp,32
    80002be0:	8082                	ret
    return p->trapframe->a1;
    80002be2:	6d3c                	ld	a5,88(a0)
    80002be4:	7fa8                	ld	a0,120(a5)
    80002be6:	bfcd                	j	80002bd8 <argraw+0x30>
    return p->trapframe->a2;
    80002be8:	6d3c                	ld	a5,88(a0)
    80002bea:	63c8                	ld	a0,128(a5)
    80002bec:	b7f5                	j	80002bd8 <argraw+0x30>
    return p->trapframe->a3;
    80002bee:	6d3c                	ld	a5,88(a0)
    80002bf0:	67c8                	ld	a0,136(a5)
    80002bf2:	b7dd                	j	80002bd8 <argraw+0x30>
    return p->trapframe->a4;
    80002bf4:	6d3c                	ld	a5,88(a0)
    80002bf6:	6bc8                	ld	a0,144(a5)
    80002bf8:	b7c5                	j	80002bd8 <argraw+0x30>
    return p->trapframe->a5;
    80002bfa:	6d3c                	ld	a5,88(a0)
    80002bfc:	6fc8                	ld	a0,152(a5)
    80002bfe:	bfe9                	j	80002bd8 <argraw+0x30>
  panic("argraw");
    80002c00:	00006517          	auipc	a0,0x6
    80002c04:	83850513          	addi	a0,a0,-1992 # 80008438 <states.0+0x148>
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	936080e7          	jalr	-1738(ra) # 8000053e <panic>

0000000080002c10 <fetchaddr>:
{
    80002c10:	1101                	addi	sp,sp,-32
    80002c12:	ec06                	sd	ra,24(sp)
    80002c14:	e822                	sd	s0,16(sp)
    80002c16:	e426                	sd	s1,8(sp)
    80002c18:	e04a                	sd	s2,0(sp)
    80002c1a:	1000                	addi	s0,sp,32
    80002c1c:	84aa                	mv	s1,a0
    80002c1e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c20:	fffff097          	auipc	ra,0xfffff
    80002c24:	d9c080e7          	jalr	-612(ra) # 800019bc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c28:	653c                	ld	a5,72(a0)
    80002c2a:	02f4f863          	bgeu	s1,a5,80002c5a <fetchaddr+0x4a>
    80002c2e:	00848713          	addi	a4,s1,8
    80002c32:	02e7e663          	bltu	a5,a4,80002c5e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c36:	46a1                	li	a3,8
    80002c38:	8626                	mv	a2,s1
    80002c3a:	85ca                	mv	a1,s2
    80002c3c:	6928                	ld	a0,80(a0)
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	ac6080e7          	jalr	-1338(ra) # 80001704 <copyin>
    80002c46:	00a03533          	snez	a0,a0
    80002c4a:	40a00533          	neg	a0,a0
}
    80002c4e:	60e2                	ld	ra,24(sp)
    80002c50:	6442                	ld	s0,16(sp)
    80002c52:	64a2                	ld	s1,8(sp)
    80002c54:	6902                	ld	s2,0(sp)
    80002c56:	6105                	addi	sp,sp,32
    80002c58:	8082                	ret
    return -1;
    80002c5a:	557d                	li	a0,-1
    80002c5c:	bfcd                	j	80002c4e <fetchaddr+0x3e>
    80002c5e:	557d                	li	a0,-1
    80002c60:	b7fd                	j	80002c4e <fetchaddr+0x3e>

0000000080002c62 <fetchstr>:
{
    80002c62:	7179                	addi	sp,sp,-48
    80002c64:	f406                	sd	ra,40(sp)
    80002c66:	f022                	sd	s0,32(sp)
    80002c68:	ec26                	sd	s1,24(sp)
    80002c6a:	e84a                	sd	s2,16(sp)
    80002c6c:	e44e                	sd	s3,8(sp)
    80002c6e:	1800                	addi	s0,sp,48
    80002c70:	892a                	mv	s2,a0
    80002c72:	84ae                	mv	s1,a1
    80002c74:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	d46080e7          	jalr	-698(ra) # 800019bc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c7e:	86ce                	mv	a3,s3
    80002c80:	864a                	mv	a2,s2
    80002c82:	85a6                	mv	a1,s1
    80002c84:	6928                	ld	a0,80(a0)
    80002c86:	fffff097          	auipc	ra,0xfffff
    80002c8a:	b0c080e7          	jalr	-1268(ra) # 80001792 <copyinstr>
    80002c8e:	00054e63          	bltz	a0,80002caa <fetchstr+0x48>
  return strlen(buf);
    80002c92:	8526                	mv	a0,s1
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	1ba080e7          	jalr	442(ra) # 80000e4e <strlen>
}
    80002c9c:	70a2                	ld	ra,40(sp)
    80002c9e:	7402                	ld	s0,32(sp)
    80002ca0:	64e2                	ld	s1,24(sp)
    80002ca2:	6942                	ld	s2,16(sp)
    80002ca4:	69a2                	ld	s3,8(sp)
    80002ca6:	6145                	addi	sp,sp,48
    80002ca8:	8082                	ret
    return -1;
    80002caa:	557d                	li	a0,-1
    80002cac:	bfc5                	j	80002c9c <fetchstr+0x3a>

0000000080002cae <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002cae:	1101                	addi	sp,sp,-32
    80002cb0:	ec06                	sd	ra,24(sp)
    80002cb2:	e822                	sd	s0,16(sp)
    80002cb4:	e426                	sd	s1,8(sp)
    80002cb6:	1000                	addi	s0,sp,32
    80002cb8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cba:	00000097          	auipc	ra,0x0
    80002cbe:	eee080e7          	jalr	-274(ra) # 80002ba8 <argraw>
    80002cc2:	c088                	sw	a0,0(s1)
}
    80002cc4:	60e2                	ld	ra,24(sp)
    80002cc6:	6442                	ld	s0,16(sp)
    80002cc8:	64a2                	ld	s1,8(sp)
    80002cca:	6105                	addi	sp,sp,32
    80002ccc:	8082                	ret

0000000080002cce <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002cce:	1101                	addi	sp,sp,-32
    80002cd0:	ec06                	sd	ra,24(sp)
    80002cd2:	e822                	sd	s0,16(sp)
    80002cd4:	e426                	sd	s1,8(sp)
    80002cd6:	1000                	addi	s0,sp,32
    80002cd8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cda:	00000097          	auipc	ra,0x0
    80002cde:	ece080e7          	jalr	-306(ra) # 80002ba8 <argraw>
    80002ce2:	e088                	sd	a0,0(s1)
}
    80002ce4:	60e2                	ld	ra,24(sp)
    80002ce6:	6442                	ld	s0,16(sp)
    80002ce8:	64a2                	ld	s1,8(sp)
    80002cea:	6105                	addi	sp,sp,32
    80002cec:	8082                	ret

0000000080002cee <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002cee:	7179                	addi	sp,sp,-48
    80002cf0:	f406                	sd	ra,40(sp)
    80002cf2:	f022                	sd	s0,32(sp)
    80002cf4:	ec26                	sd	s1,24(sp)
    80002cf6:	e84a                	sd	s2,16(sp)
    80002cf8:	1800                	addi	s0,sp,48
    80002cfa:	84ae                	mv	s1,a1
    80002cfc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002cfe:	fd840593          	addi	a1,s0,-40
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	fcc080e7          	jalr	-52(ra) # 80002cce <argaddr>
  return fetchstr(addr, buf, max);
    80002d0a:	864a                	mv	a2,s2
    80002d0c:	85a6                	mv	a1,s1
    80002d0e:	fd843503          	ld	a0,-40(s0)
    80002d12:	00000097          	auipc	ra,0x0
    80002d16:	f50080e7          	jalr	-176(ra) # 80002c62 <fetchstr>
}
    80002d1a:	70a2                	ld	ra,40(sp)
    80002d1c:	7402                	ld	s0,32(sp)
    80002d1e:	64e2                	ld	s1,24(sp)
    80002d20:	6942                	ld	s2,16(sp)
    80002d22:	6145                	addi	sp,sp,48
    80002d24:	8082                	ret

0000000080002d26 <syscall>:
[SYS_waitx]   sys_waitx,
};

void
syscall(void)
{
    80002d26:	1101                	addi	sp,sp,-32
    80002d28:	ec06                	sd	ra,24(sp)
    80002d2a:	e822                	sd	s0,16(sp)
    80002d2c:	e426                	sd	s1,8(sp)
    80002d2e:	e04a                	sd	s2,0(sp)
    80002d30:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	c8a080e7          	jalr	-886(ra) # 800019bc <myproc>
    80002d3a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d3c:	05853903          	ld	s2,88(a0)
    80002d40:	0a893783          	ld	a5,168(s2)
    80002d44:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d48:	37fd                	addiw	a5,a5,-1
    80002d4a:	4755                	li	a4,21
    80002d4c:	00f76f63          	bltu	a4,a5,80002d6a <syscall+0x44>
    80002d50:	00369713          	slli	a4,a3,0x3
    80002d54:	00005797          	auipc	a5,0x5
    80002d58:	72478793          	addi	a5,a5,1828 # 80008478 <syscalls>
    80002d5c:	97ba                	add	a5,a5,a4
    80002d5e:	639c                	ld	a5,0(a5)
    80002d60:	c789                	beqz	a5,80002d6a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d62:	9782                	jalr	a5
    80002d64:	06a93823          	sd	a0,112(s2)
    80002d68:	a839                	j	80002d86 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d6a:	15848613          	addi	a2,s1,344
    80002d6e:	588c                	lw	a1,48(s1)
    80002d70:	00005517          	auipc	a0,0x5
    80002d74:	6d050513          	addi	a0,a0,1744 # 80008440 <states.0+0x150>
    80002d78:	ffffe097          	auipc	ra,0xffffe
    80002d7c:	810080e7          	jalr	-2032(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d80:	6cbc                	ld	a5,88(s1)
    80002d82:	577d                	li	a4,-1
    80002d84:	fbb8                	sd	a4,112(a5)
  }
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6902                	ld	s2,0(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002d9a:	fec40593          	addi	a1,s0,-20
    80002d9e:	4501                	li	a0,0
    80002da0:	00000097          	auipc	ra,0x0
    80002da4:	f0e080e7          	jalr	-242(ra) # 80002cae <argint>
  exit(n);
    80002da8:	fec42503          	lw	a0,-20(s0)
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	45e080e7          	jalr	1118(ra) # 8000220a <exit>
  return 0;  // not reached
}
    80002db4:	4501                	li	a0,0
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret

0000000080002dbe <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dbe:	1141                	addi	sp,sp,-16
    80002dc0:	e406                	sd	ra,8(sp)
    80002dc2:	e022                	sd	s0,0(sp)
    80002dc4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	bf6080e7          	jalr	-1034(ra) # 800019bc <myproc>
}
    80002dce:	5908                	lw	a0,48(a0)
    80002dd0:	60a2                	ld	ra,8(sp)
    80002dd2:	6402                	ld	s0,0(sp)
    80002dd4:	0141                	addi	sp,sp,16
    80002dd6:	8082                	ret

0000000080002dd8 <sys_fork>:

uint64
sys_fork(void)
{
    80002dd8:	1141                	addi	sp,sp,-16
    80002dda:	e406                	sd	ra,8(sp)
    80002ddc:	e022                	sd	s0,0(sp)
    80002dde:	0800                	addi	s0,sp,16
  return fork();
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	fa6080e7          	jalr	-90(ra) # 80001d86 <fork>
}
    80002de8:	60a2                	ld	ra,8(sp)
    80002dea:	6402                	ld	s0,0(sp)
    80002dec:	0141                	addi	sp,sp,16
    80002dee:	8082                	ret

0000000080002df0 <sys_wait>:

uint64
sys_wait(void)
{
    80002df0:	1101                	addi	sp,sp,-32
    80002df2:	ec06                	sd	ra,24(sp)
    80002df4:	e822                	sd	s0,16(sp)
    80002df6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002df8:	fe840593          	addi	a1,s0,-24
    80002dfc:	4501                	li	a0,0
    80002dfe:	00000097          	auipc	ra,0x0
    80002e02:	ed0080e7          	jalr	-304(ra) # 80002cce <argaddr>
  return wait(p);
    80002e06:	fe843503          	ld	a0,-24(s0)
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	5b2080e7          	jalr	1458(ra) # 800023bc <wait>
}
    80002e12:	60e2                	ld	ra,24(sp)
    80002e14:	6442                	ld	s0,16(sp)
    80002e16:	6105                	addi	sp,sp,32
    80002e18:	8082                	ret

0000000080002e1a <sys_waitx>:

uint64
sys_waitx(void)
{
    80002e1a:	7139                	addi	sp,sp,-64
    80002e1c:	fc06                	sd	ra,56(sp)
    80002e1e:	f822                	sd	s0,48(sp)
    80002e20:	f426                	sd	s1,40(sp)
    80002e22:	f04a                	sd	s2,32(sp)
    80002e24:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80002e26:	fd840593          	addi	a1,s0,-40
    80002e2a:	4501                	li	a0,0
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	ea2080e7          	jalr	-350(ra) # 80002cce <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80002e34:	fd040593          	addi	a1,s0,-48
    80002e38:	4505                	li	a0,1
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	e94080e7          	jalr	-364(ra) # 80002cce <argaddr>
  argaddr(2, &addr2);
    80002e42:	fc840593          	addi	a1,s0,-56
    80002e46:	4509                	li	a0,2
    80002e48:	00000097          	auipc	ra,0x0
    80002e4c:	e86080e7          	jalr	-378(ra) # 80002cce <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80002e50:	fc040613          	addi	a2,s0,-64
    80002e54:	fc440593          	addi	a1,s0,-60
    80002e58:	fd843503          	ld	a0,-40(s0)
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	68e080e7          	jalr	1678(ra) # 800024ea <waitx>
    80002e64:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	b56080e7          	jalr	-1194(ra) # 800019bc <myproc>
    80002e6e:	84aa                	mv	s1,a0
  if(copyout(p->pagetable, addr1, (char*)&wtime, sizeof(int)) < 0)
    80002e70:	4691                	li	a3,4
    80002e72:	fc440613          	addi	a2,s0,-60
    80002e76:	fd043583          	ld	a1,-48(s0)
    80002e7a:	6928                	ld	a0,80(a0)
    80002e7c:	ffffe097          	auipc	ra,0xffffe
    80002e80:	7fc080e7          	jalr	2044(ra) # 80001678 <copyout>
    return -1;
    80002e84:	57fd                	li	a5,-1
  if(copyout(p->pagetable, addr1, (char*)&wtime, sizeof(int)) < 0)
    80002e86:	00054f63          	bltz	a0,80002ea4 <sys_waitx+0x8a>
  if(copyout(p->pagetable, addr2, (char*)&rtime, sizeof(int)) < 0)
    80002e8a:	4691                	li	a3,4
    80002e8c:	fc040613          	addi	a2,s0,-64
    80002e90:	fc843583          	ld	a1,-56(s0)
    80002e94:	68a8                	ld	a0,80(s1)
    80002e96:	ffffe097          	auipc	ra,0xffffe
    80002e9a:	7e2080e7          	jalr	2018(ra) # 80001678 <copyout>
    80002e9e:	00054a63          	bltz	a0,80002eb2 <sys_waitx+0x98>
    return -1;
  return ret;
    80002ea2:	87ca                	mv	a5,s2
}
    80002ea4:	853e                	mv	a0,a5
    80002ea6:	70e2                	ld	ra,56(sp)
    80002ea8:	7442                	ld	s0,48(sp)
    80002eaa:	74a2                	ld	s1,40(sp)
    80002eac:	7902                	ld	s2,32(sp)
    80002eae:	6121                	addi	sp,sp,64
    80002eb0:	8082                	ret
    return -1;
    80002eb2:	57fd                	li	a5,-1
    80002eb4:	bfc5                	j	80002ea4 <sys_waitx+0x8a>

0000000080002eb6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002eb6:	7179                	addi	sp,sp,-48
    80002eb8:	f406                	sd	ra,40(sp)
    80002eba:	f022                	sd	s0,32(sp)
    80002ebc:	ec26                	sd	s1,24(sp)
    80002ebe:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ec0:	fdc40593          	addi	a1,s0,-36
    80002ec4:	4501                	li	a0,0
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	de8080e7          	jalr	-536(ra) # 80002cae <argint>
  addr = myproc()->sz;
    80002ece:	fffff097          	auipc	ra,0xfffff
    80002ed2:	aee080e7          	jalr	-1298(ra) # 800019bc <myproc>
    80002ed6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002ed8:	fdc42503          	lw	a0,-36(s0)
    80002edc:	fffff097          	auipc	ra,0xfffff
    80002ee0:	e4e080e7          	jalr	-434(ra) # 80001d2a <growproc>
    80002ee4:	00054863          	bltz	a0,80002ef4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002ee8:	8526                	mv	a0,s1
    80002eea:	70a2                	ld	ra,40(sp)
    80002eec:	7402                	ld	s0,32(sp)
    80002eee:	64e2                	ld	s1,24(sp)
    80002ef0:	6145                	addi	sp,sp,48
    80002ef2:	8082                	ret
    return -1;
    80002ef4:	54fd                	li	s1,-1
    80002ef6:	bfcd                	j	80002ee8 <sys_sbrk+0x32>

0000000080002ef8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ef8:	7139                	addi	sp,sp,-64
    80002efa:	fc06                	sd	ra,56(sp)
    80002efc:	f822                	sd	s0,48(sp)
    80002efe:	f426                	sd	s1,40(sp)
    80002f00:	f04a                	sd	s2,32(sp)
    80002f02:	ec4e                	sd	s3,24(sp)
    80002f04:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f06:	fcc40593          	addi	a1,s0,-52
    80002f0a:	4501                	li	a0,0
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	da2080e7          	jalr	-606(ra) # 80002cae <argint>
  acquire(&tickslock);
    80002f14:	00014517          	auipc	a0,0x14
    80002f18:	e7c50513          	addi	a0,a0,-388 # 80016d90 <tickslock>
    80002f1c:	ffffe097          	auipc	ra,0xffffe
    80002f20:	cba080e7          	jalr	-838(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f24:	00006917          	auipc	s2,0x6
    80002f28:	9cc92903          	lw	s2,-1588(s2) # 800088f0 <ticks>
  while(ticks - ticks0 < n){
    80002f2c:	fcc42783          	lw	a5,-52(s0)
    80002f30:	cf9d                	beqz	a5,80002f6e <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f32:	00014997          	auipc	s3,0x14
    80002f36:	e5e98993          	addi	s3,s3,-418 # 80016d90 <tickslock>
    80002f3a:	00006497          	auipc	s1,0x6
    80002f3e:	9b648493          	addi	s1,s1,-1610 # 800088f0 <ticks>
    if(killed(myproc())){
    80002f42:	fffff097          	auipc	ra,0xfffff
    80002f46:	a7a080e7          	jalr	-1414(ra) # 800019bc <myproc>
    80002f4a:	fffff097          	auipc	ra,0xfffff
    80002f4e:	440080e7          	jalr	1088(ra) # 8000238a <killed>
    80002f52:	ed15                	bnez	a0,80002f8e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f54:	85ce                	mv	a1,s3
    80002f56:	8526                	mv	a0,s1
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	17e080e7          	jalr	382(ra) # 800020d6 <sleep>
  while(ticks - ticks0 < n){
    80002f60:	409c                	lw	a5,0(s1)
    80002f62:	412787bb          	subw	a5,a5,s2
    80002f66:	fcc42703          	lw	a4,-52(s0)
    80002f6a:	fce7ece3          	bltu	a5,a4,80002f42 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002f6e:	00014517          	auipc	a0,0x14
    80002f72:	e2250513          	addi	a0,a0,-478 # 80016d90 <tickslock>
    80002f76:	ffffe097          	auipc	ra,0xffffe
    80002f7a:	d14080e7          	jalr	-748(ra) # 80000c8a <release>
  return 0;
    80002f7e:	4501                	li	a0,0
}
    80002f80:	70e2                	ld	ra,56(sp)
    80002f82:	7442                	ld	s0,48(sp)
    80002f84:	74a2                	ld	s1,40(sp)
    80002f86:	7902                	ld	s2,32(sp)
    80002f88:	69e2                	ld	s3,24(sp)
    80002f8a:	6121                	addi	sp,sp,64
    80002f8c:	8082                	ret
      release(&tickslock);
    80002f8e:	00014517          	auipc	a0,0x14
    80002f92:	e0250513          	addi	a0,a0,-510 # 80016d90 <tickslock>
    80002f96:	ffffe097          	auipc	ra,0xffffe
    80002f9a:	cf4080e7          	jalr	-780(ra) # 80000c8a <release>
      return -1;
    80002f9e:	557d                	li	a0,-1
    80002fa0:	b7c5                	j	80002f80 <sys_sleep+0x88>

0000000080002fa2 <sys_kill>:

uint64
sys_kill(void)
{
    80002fa2:	1101                	addi	sp,sp,-32
    80002fa4:	ec06                	sd	ra,24(sp)
    80002fa6:	e822                	sd	s0,16(sp)
    80002fa8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002faa:	fec40593          	addi	a1,s0,-20
    80002fae:	4501                	li	a0,0
    80002fb0:	00000097          	auipc	ra,0x0
    80002fb4:	cfe080e7          	jalr	-770(ra) # 80002cae <argint>
  return kill(pid);
    80002fb8:	fec42503          	lw	a0,-20(s0)
    80002fbc:	fffff097          	auipc	ra,0xfffff
    80002fc0:	330080e7          	jalr	816(ra) # 800022ec <kill>
}
    80002fc4:	60e2                	ld	ra,24(sp)
    80002fc6:	6442                	ld	s0,16(sp)
    80002fc8:	6105                	addi	sp,sp,32
    80002fca:	8082                	ret

0000000080002fcc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fcc:	1101                	addi	sp,sp,-32
    80002fce:	ec06                	sd	ra,24(sp)
    80002fd0:	e822                	sd	s0,16(sp)
    80002fd2:	e426                	sd	s1,8(sp)
    80002fd4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fd6:	00014517          	auipc	a0,0x14
    80002fda:	dba50513          	addi	a0,a0,-582 # 80016d90 <tickslock>
    80002fde:	ffffe097          	auipc	ra,0xffffe
    80002fe2:	bf8080e7          	jalr	-1032(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002fe6:	00006497          	auipc	s1,0x6
    80002fea:	90a4a483          	lw	s1,-1782(s1) # 800088f0 <ticks>
  release(&tickslock);
    80002fee:	00014517          	auipc	a0,0x14
    80002ff2:	da250513          	addi	a0,a0,-606 # 80016d90 <tickslock>
    80002ff6:	ffffe097          	auipc	ra,0xffffe
    80002ffa:	c94080e7          	jalr	-876(ra) # 80000c8a <release>
  return xticks;
}
    80002ffe:	02049513          	slli	a0,s1,0x20
    80003002:	9101                	srli	a0,a0,0x20
    80003004:	60e2                	ld	ra,24(sp)
    80003006:	6442                	ld	s0,16(sp)
    80003008:	64a2                	ld	s1,8(sp)
    8000300a:	6105                	addi	sp,sp,32
    8000300c:	8082                	ret

000000008000300e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000300e:	7179                	addi	sp,sp,-48
    80003010:	f406                	sd	ra,40(sp)
    80003012:	f022                	sd	s0,32(sp)
    80003014:	ec26                	sd	s1,24(sp)
    80003016:	e84a                	sd	s2,16(sp)
    80003018:	e44e                	sd	s3,8(sp)
    8000301a:	e052                	sd	s4,0(sp)
    8000301c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000301e:	00005597          	auipc	a1,0x5
    80003022:	51258593          	addi	a1,a1,1298 # 80008530 <syscalls+0xb8>
    80003026:	00014517          	auipc	a0,0x14
    8000302a:	d8250513          	addi	a0,a0,-638 # 80016da8 <bcache>
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	b18080e7          	jalr	-1256(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003036:	0001c797          	auipc	a5,0x1c
    8000303a:	d7278793          	addi	a5,a5,-654 # 8001eda8 <bcache+0x8000>
    8000303e:	0001c717          	auipc	a4,0x1c
    80003042:	fd270713          	addi	a4,a4,-46 # 8001f010 <bcache+0x8268>
    80003046:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000304a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000304e:	00014497          	auipc	s1,0x14
    80003052:	d7248493          	addi	s1,s1,-654 # 80016dc0 <bcache+0x18>
    b->next = bcache.head.next;
    80003056:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003058:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000305a:	00005a17          	auipc	s4,0x5
    8000305e:	4dea0a13          	addi	s4,s4,1246 # 80008538 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003062:	2b893783          	ld	a5,696(s2)
    80003066:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003068:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000306c:	85d2                	mv	a1,s4
    8000306e:	01048513          	addi	a0,s1,16
    80003072:	00001097          	auipc	ra,0x1
    80003076:	4c4080e7          	jalr	1220(ra) # 80004536 <initsleeplock>
    bcache.head.next->prev = b;
    8000307a:	2b893783          	ld	a5,696(s2)
    8000307e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003080:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003084:	45848493          	addi	s1,s1,1112
    80003088:	fd349de3          	bne	s1,s3,80003062 <binit+0x54>
  }
}
    8000308c:	70a2                	ld	ra,40(sp)
    8000308e:	7402                	ld	s0,32(sp)
    80003090:	64e2                	ld	s1,24(sp)
    80003092:	6942                	ld	s2,16(sp)
    80003094:	69a2                	ld	s3,8(sp)
    80003096:	6a02                	ld	s4,0(sp)
    80003098:	6145                	addi	sp,sp,48
    8000309a:	8082                	ret

000000008000309c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000309c:	7179                	addi	sp,sp,-48
    8000309e:	f406                	sd	ra,40(sp)
    800030a0:	f022                	sd	s0,32(sp)
    800030a2:	ec26                	sd	s1,24(sp)
    800030a4:	e84a                	sd	s2,16(sp)
    800030a6:	e44e                	sd	s3,8(sp)
    800030a8:	1800                	addi	s0,sp,48
    800030aa:	892a                	mv	s2,a0
    800030ac:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030ae:	00014517          	auipc	a0,0x14
    800030b2:	cfa50513          	addi	a0,a0,-774 # 80016da8 <bcache>
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	b20080e7          	jalr	-1248(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030be:	0001c497          	auipc	s1,0x1c
    800030c2:	fa24b483          	ld	s1,-94(s1) # 8001f060 <bcache+0x82b8>
    800030c6:	0001c797          	auipc	a5,0x1c
    800030ca:	f4a78793          	addi	a5,a5,-182 # 8001f010 <bcache+0x8268>
    800030ce:	02f48f63          	beq	s1,a5,8000310c <bread+0x70>
    800030d2:	873e                	mv	a4,a5
    800030d4:	a021                	j	800030dc <bread+0x40>
    800030d6:	68a4                	ld	s1,80(s1)
    800030d8:	02e48a63          	beq	s1,a4,8000310c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030dc:	449c                	lw	a5,8(s1)
    800030de:	ff279ce3          	bne	a5,s2,800030d6 <bread+0x3a>
    800030e2:	44dc                	lw	a5,12(s1)
    800030e4:	ff3799e3          	bne	a5,s3,800030d6 <bread+0x3a>
      b->refcnt++;
    800030e8:	40bc                	lw	a5,64(s1)
    800030ea:	2785                	addiw	a5,a5,1
    800030ec:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ee:	00014517          	auipc	a0,0x14
    800030f2:	cba50513          	addi	a0,a0,-838 # 80016da8 <bcache>
    800030f6:	ffffe097          	auipc	ra,0xffffe
    800030fa:	b94080e7          	jalr	-1132(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800030fe:	01048513          	addi	a0,s1,16
    80003102:	00001097          	auipc	ra,0x1
    80003106:	46e080e7          	jalr	1134(ra) # 80004570 <acquiresleep>
      return b;
    8000310a:	a8b9                	j	80003168 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000310c:	0001c497          	auipc	s1,0x1c
    80003110:	f4c4b483          	ld	s1,-180(s1) # 8001f058 <bcache+0x82b0>
    80003114:	0001c797          	auipc	a5,0x1c
    80003118:	efc78793          	addi	a5,a5,-260 # 8001f010 <bcache+0x8268>
    8000311c:	00f48863          	beq	s1,a5,8000312c <bread+0x90>
    80003120:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003122:	40bc                	lw	a5,64(s1)
    80003124:	cf81                	beqz	a5,8000313c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003126:	64a4                	ld	s1,72(s1)
    80003128:	fee49de3          	bne	s1,a4,80003122 <bread+0x86>
  panic("bget: no buffers");
    8000312c:	00005517          	auipc	a0,0x5
    80003130:	41450513          	addi	a0,a0,1044 # 80008540 <syscalls+0xc8>
    80003134:	ffffd097          	auipc	ra,0xffffd
    80003138:	40a080e7          	jalr	1034(ra) # 8000053e <panic>
      b->dev = dev;
    8000313c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003140:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003144:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003148:	4785                	li	a5,1
    8000314a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000314c:	00014517          	auipc	a0,0x14
    80003150:	c5c50513          	addi	a0,a0,-932 # 80016da8 <bcache>
    80003154:	ffffe097          	auipc	ra,0xffffe
    80003158:	b36080e7          	jalr	-1226(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000315c:	01048513          	addi	a0,s1,16
    80003160:	00001097          	auipc	ra,0x1
    80003164:	410080e7          	jalr	1040(ra) # 80004570 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003168:	409c                	lw	a5,0(s1)
    8000316a:	cb89                	beqz	a5,8000317c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000316c:	8526                	mv	a0,s1
    8000316e:	70a2                	ld	ra,40(sp)
    80003170:	7402                	ld	s0,32(sp)
    80003172:	64e2                	ld	s1,24(sp)
    80003174:	6942                	ld	s2,16(sp)
    80003176:	69a2                	ld	s3,8(sp)
    80003178:	6145                	addi	sp,sp,48
    8000317a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000317c:	4581                	li	a1,0
    8000317e:	8526                	mv	a0,s1
    80003180:	00003097          	auipc	ra,0x3
    80003184:	fd4080e7          	jalr	-44(ra) # 80006154 <virtio_disk_rw>
    b->valid = 1;
    80003188:	4785                	li	a5,1
    8000318a:	c09c                	sw	a5,0(s1)
  return b;
    8000318c:	b7c5                	j	8000316c <bread+0xd0>

000000008000318e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000318e:	1101                	addi	sp,sp,-32
    80003190:	ec06                	sd	ra,24(sp)
    80003192:	e822                	sd	s0,16(sp)
    80003194:	e426                	sd	s1,8(sp)
    80003196:	1000                	addi	s0,sp,32
    80003198:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000319a:	0541                	addi	a0,a0,16
    8000319c:	00001097          	auipc	ra,0x1
    800031a0:	46e080e7          	jalr	1134(ra) # 8000460a <holdingsleep>
    800031a4:	cd01                	beqz	a0,800031bc <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031a6:	4585                	li	a1,1
    800031a8:	8526                	mv	a0,s1
    800031aa:	00003097          	auipc	ra,0x3
    800031ae:	faa080e7          	jalr	-86(ra) # 80006154 <virtio_disk_rw>
}
    800031b2:	60e2                	ld	ra,24(sp)
    800031b4:	6442                	ld	s0,16(sp)
    800031b6:	64a2                	ld	s1,8(sp)
    800031b8:	6105                	addi	sp,sp,32
    800031ba:	8082                	ret
    panic("bwrite");
    800031bc:	00005517          	auipc	a0,0x5
    800031c0:	39c50513          	addi	a0,a0,924 # 80008558 <syscalls+0xe0>
    800031c4:	ffffd097          	auipc	ra,0xffffd
    800031c8:	37a080e7          	jalr	890(ra) # 8000053e <panic>

00000000800031cc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031cc:	1101                	addi	sp,sp,-32
    800031ce:	ec06                	sd	ra,24(sp)
    800031d0:	e822                	sd	s0,16(sp)
    800031d2:	e426                	sd	s1,8(sp)
    800031d4:	e04a                	sd	s2,0(sp)
    800031d6:	1000                	addi	s0,sp,32
    800031d8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031da:	01050913          	addi	s2,a0,16
    800031de:	854a                	mv	a0,s2
    800031e0:	00001097          	auipc	ra,0x1
    800031e4:	42a080e7          	jalr	1066(ra) # 8000460a <holdingsleep>
    800031e8:	c92d                	beqz	a0,8000325a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800031ea:	854a                	mv	a0,s2
    800031ec:	00001097          	auipc	ra,0x1
    800031f0:	3da080e7          	jalr	986(ra) # 800045c6 <releasesleep>

  acquire(&bcache.lock);
    800031f4:	00014517          	auipc	a0,0x14
    800031f8:	bb450513          	addi	a0,a0,-1100 # 80016da8 <bcache>
    800031fc:	ffffe097          	auipc	ra,0xffffe
    80003200:	9da080e7          	jalr	-1574(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003204:	40bc                	lw	a5,64(s1)
    80003206:	37fd                	addiw	a5,a5,-1
    80003208:	0007871b          	sext.w	a4,a5
    8000320c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000320e:	eb05                	bnez	a4,8000323e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003210:	68bc                	ld	a5,80(s1)
    80003212:	64b8                	ld	a4,72(s1)
    80003214:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003216:	64bc                	ld	a5,72(s1)
    80003218:	68b8                	ld	a4,80(s1)
    8000321a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000321c:	0001c797          	auipc	a5,0x1c
    80003220:	b8c78793          	addi	a5,a5,-1140 # 8001eda8 <bcache+0x8000>
    80003224:	2b87b703          	ld	a4,696(a5)
    80003228:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000322a:	0001c717          	auipc	a4,0x1c
    8000322e:	de670713          	addi	a4,a4,-538 # 8001f010 <bcache+0x8268>
    80003232:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003234:	2b87b703          	ld	a4,696(a5)
    80003238:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000323a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000323e:	00014517          	auipc	a0,0x14
    80003242:	b6a50513          	addi	a0,a0,-1174 # 80016da8 <bcache>
    80003246:	ffffe097          	auipc	ra,0xffffe
    8000324a:	a44080e7          	jalr	-1468(ra) # 80000c8a <release>
}
    8000324e:	60e2                	ld	ra,24(sp)
    80003250:	6442                	ld	s0,16(sp)
    80003252:	64a2                	ld	s1,8(sp)
    80003254:	6902                	ld	s2,0(sp)
    80003256:	6105                	addi	sp,sp,32
    80003258:	8082                	ret
    panic("brelse");
    8000325a:	00005517          	auipc	a0,0x5
    8000325e:	30650513          	addi	a0,a0,774 # 80008560 <syscalls+0xe8>
    80003262:	ffffd097          	auipc	ra,0xffffd
    80003266:	2dc080e7          	jalr	732(ra) # 8000053e <panic>

000000008000326a <bpin>:

void
bpin(struct buf *b) {
    8000326a:	1101                	addi	sp,sp,-32
    8000326c:	ec06                	sd	ra,24(sp)
    8000326e:	e822                	sd	s0,16(sp)
    80003270:	e426                	sd	s1,8(sp)
    80003272:	1000                	addi	s0,sp,32
    80003274:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003276:	00014517          	auipc	a0,0x14
    8000327a:	b3250513          	addi	a0,a0,-1230 # 80016da8 <bcache>
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	958080e7          	jalr	-1704(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003286:	40bc                	lw	a5,64(s1)
    80003288:	2785                	addiw	a5,a5,1
    8000328a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000328c:	00014517          	auipc	a0,0x14
    80003290:	b1c50513          	addi	a0,a0,-1252 # 80016da8 <bcache>
    80003294:	ffffe097          	auipc	ra,0xffffe
    80003298:	9f6080e7          	jalr	-1546(ra) # 80000c8a <release>
}
    8000329c:	60e2                	ld	ra,24(sp)
    8000329e:	6442                	ld	s0,16(sp)
    800032a0:	64a2                	ld	s1,8(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret

00000000800032a6 <bunpin>:

void
bunpin(struct buf *b) {
    800032a6:	1101                	addi	sp,sp,-32
    800032a8:	ec06                	sd	ra,24(sp)
    800032aa:	e822                	sd	s0,16(sp)
    800032ac:	e426                	sd	s1,8(sp)
    800032ae:	1000                	addi	s0,sp,32
    800032b0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032b2:	00014517          	auipc	a0,0x14
    800032b6:	af650513          	addi	a0,a0,-1290 # 80016da8 <bcache>
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	91c080e7          	jalr	-1764(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800032c2:	40bc                	lw	a5,64(s1)
    800032c4:	37fd                	addiw	a5,a5,-1
    800032c6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032c8:	00014517          	auipc	a0,0x14
    800032cc:	ae050513          	addi	a0,a0,-1312 # 80016da8 <bcache>
    800032d0:	ffffe097          	auipc	ra,0xffffe
    800032d4:	9ba080e7          	jalr	-1606(ra) # 80000c8a <release>
}
    800032d8:	60e2                	ld	ra,24(sp)
    800032da:	6442                	ld	s0,16(sp)
    800032dc:	64a2                	ld	s1,8(sp)
    800032de:	6105                	addi	sp,sp,32
    800032e0:	8082                	ret

00000000800032e2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032e2:	1101                	addi	sp,sp,-32
    800032e4:	ec06                	sd	ra,24(sp)
    800032e6:	e822                	sd	s0,16(sp)
    800032e8:	e426                	sd	s1,8(sp)
    800032ea:	e04a                	sd	s2,0(sp)
    800032ec:	1000                	addi	s0,sp,32
    800032ee:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032f0:	00d5d59b          	srliw	a1,a1,0xd
    800032f4:	0001c797          	auipc	a5,0x1c
    800032f8:	1907a783          	lw	a5,400(a5) # 8001f484 <sb+0x1c>
    800032fc:	9dbd                	addw	a1,a1,a5
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	d9e080e7          	jalr	-610(ra) # 8000309c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003306:	0074f713          	andi	a4,s1,7
    8000330a:	4785                	li	a5,1
    8000330c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003310:	14ce                	slli	s1,s1,0x33
    80003312:	90d9                	srli	s1,s1,0x36
    80003314:	00950733          	add	a4,a0,s1
    80003318:	05874703          	lbu	a4,88(a4)
    8000331c:	00e7f6b3          	and	a3,a5,a4
    80003320:	c69d                	beqz	a3,8000334e <bfree+0x6c>
    80003322:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003324:	94aa                	add	s1,s1,a0
    80003326:	fff7c793          	not	a5,a5
    8000332a:	8ff9                	and	a5,a5,a4
    8000332c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003330:	00001097          	auipc	ra,0x1
    80003334:	120080e7          	jalr	288(ra) # 80004450 <log_write>
  brelse(bp);
    80003338:	854a                	mv	a0,s2
    8000333a:	00000097          	auipc	ra,0x0
    8000333e:	e92080e7          	jalr	-366(ra) # 800031cc <brelse>
}
    80003342:	60e2                	ld	ra,24(sp)
    80003344:	6442                	ld	s0,16(sp)
    80003346:	64a2                	ld	s1,8(sp)
    80003348:	6902                	ld	s2,0(sp)
    8000334a:	6105                	addi	sp,sp,32
    8000334c:	8082                	ret
    panic("freeing free block");
    8000334e:	00005517          	auipc	a0,0x5
    80003352:	21a50513          	addi	a0,a0,538 # 80008568 <syscalls+0xf0>
    80003356:	ffffd097          	auipc	ra,0xffffd
    8000335a:	1e8080e7          	jalr	488(ra) # 8000053e <panic>

000000008000335e <balloc>:
{
    8000335e:	711d                	addi	sp,sp,-96
    80003360:	ec86                	sd	ra,88(sp)
    80003362:	e8a2                	sd	s0,80(sp)
    80003364:	e4a6                	sd	s1,72(sp)
    80003366:	e0ca                	sd	s2,64(sp)
    80003368:	fc4e                	sd	s3,56(sp)
    8000336a:	f852                	sd	s4,48(sp)
    8000336c:	f456                	sd	s5,40(sp)
    8000336e:	f05a                	sd	s6,32(sp)
    80003370:	ec5e                	sd	s7,24(sp)
    80003372:	e862                	sd	s8,16(sp)
    80003374:	e466                	sd	s9,8(sp)
    80003376:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003378:	0001c797          	auipc	a5,0x1c
    8000337c:	0f47a783          	lw	a5,244(a5) # 8001f46c <sb+0x4>
    80003380:	10078163          	beqz	a5,80003482 <balloc+0x124>
    80003384:	8baa                	mv	s7,a0
    80003386:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003388:	0001cb17          	auipc	s6,0x1c
    8000338c:	0e0b0b13          	addi	s6,s6,224 # 8001f468 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003390:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003392:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003394:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003396:	6c89                	lui	s9,0x2
    80003398:	a061                	j	80003420 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000339a:	974a                	add	a4,a4,s2
    8000339c:	8fd5                	or	a5,a5,a3
    8000339e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800033a2:	854a                	mv	a0,s2
    800033a4:	00001097          	auipc	ra,0x1
    800033a8:	0ac080e7          	jalr	172(ra) # 80004450 <log_write>
        brelse(bp);
    800033ac:	854a                	mv	a0,s2
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	e1e080e7          	jalr	-482(ra) # 800031cc <brelse>
  bp = bread(dev, bno);
    800033b6:	85a6                	mv	a1,s1
    800033b8:	855e                	mv	a0,s7
    800033ba:	00000097          	auipc	ra,0x0
    800033be:	ce2080e7          	jalr	-798(ra) # 8000309c <bread>
    800033c2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033c4:	40000613          	li	a2,1024
    800033c8:	4581                	li	a1,0
    800033ca:	05850513          	addi	a0,a0,88
    800033ce:	ffffe097          	auipc	ra,0xffffe
    800033d2:	904080e7          	jalr	-1788(ra) # 80000cd2 <memset>
  log_write(bp);
    800033d6:	854a                	mv	a0,s2
    800033d8:	00001097          	auipc	ra,0x1
    800033dc:	078080e7          	jalr	120(ra) # 80004450 <log_write>
  brelse(bp);
    800033e0:	854a                	mv	a0,s2
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	dea080e7          	jalr	-534(ra) # 800031cc <brelse>
}
    800033ea:	8526                	mv	a0,s1
    800033ec:	60e6                	ld	ra,88(sp)
    800033ee:	6446                	ld	s0,80(sp)
    800033f0:	64a6                	ld	s1,72(sp)
    800033f2:	6906                	ld	s2,64(sp)
    800033f4:	79e2                	ld	s3,56(sp)
    800033f6:	7a42                	ld	s4,48(sp)
    800033f8:	7aa2                	ld	s5,40(sp)
    800033fa:	7b02                	ld	s6,32(sp)
    800033fc:	6be2                	ld	s7,24(sp)
    800033fe:	6c42                	ld	s8,16(sp)
    80003400:	6ca2                	ld	s9,8(sp)
    80003402:	6125                	addi	sp,sp,96
    80003404:	8082                	ret
    brelse(bp);
    80003406:	854a                	mv	a0,s2
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	dc4080e7          	jalr	-572(ra) # 800031cc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003410:	015c87bb          	addw	a5,s9,s5
    80003414:	00078a9b          	sext.w	s5,a5
    80003418:	004b2703          	lw	a4,4(s6)
    8000341c:	06eaf363          	bgeu	s5,a4,80003482 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003420:	41fad79b          	sraiw	a5,s5,0x1f
    80003424:	0137d79b          	srliw	a5,a5,0x13
    80003428:	015787bb          	addw	a5,a5,s5
    8000342c:	40d7d79b          	sraiw	a5,a5,0xd
    80003430:	01cb2583          	lw	a1,28(s6)
    80003434:	9dbd                	addw	a1,a1,a5
    80003436:	855e                	mv	a0,s7
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	c64080e7          	jalr	-924(ra) # 8000309c <bread>
    80003440:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003442:	004b2503          	lw	a0,4(s6)
    80003446:	000a849b          	sext.w	s1,s5
    8000344a:	8662                	mv	a2,s8
    8000344c:	faa4fde3          	bgeu	s1,a0,80003406 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003450:	41f6579b          	sraiw	a5,a2,0x1f
    80003454:	01d7d69b          	srliw	a3,a5,0x1d
    80003458:	00c6873b          	addw	a4,a3,a2
    8000345c:	00777793          	andi	a5,a4,7
    80003460:	9f95                	subw	a5,a5,a3
    80003462:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003466:	4037571b          	sraiw	a4,a4,0x3
    8000346a:	00e906b3          	add	a3,s2,a4
    8000346e:	0586c683          	lbu	a3,88(a3)
    80003472:	00d7f5b3          	and	a1,a5,a3
    80003476:	d195                	beqz	a1,8000339a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003478:	2605                	addiw	a2,a2,1
    8000347a:	2485                	addiw	s1,s1,1
    8000347c:	fd4618e3          	bne	a2,s4,8000344c <balloc+0xee>
    80003480:	b759                	j	80003406 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003482:	00005517          	auipc	a0,0x5
    80003486:	0fe50513          	addi	a0,a0,254 # 80008580 <syscalls+0x108>
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	0fe080e7          	jalr	254(ra) # 80000588 <printf>
  return 0;
    80003492:	4481                	li	s1,0
    80003494:	bf99                	j	800033ea <balloc+0x8c>

0000000080003496 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003496:	7179                	addi	sp,sp,-48
    80003498:	f406                	sd	ra,40(sp)
    8000349a:	f022                	sd	s0,32(sp)
    8000349c:	ec26                	sd	s1,24(sp)
    8000349e:	e84a                	sd	s2,16(sp)
    800034a0:	e44e                	sd	s3,8(sp)
    800034a2:	e052                	sd	s4,0(sp)
    800034a4:	1800                	addi	s0,sp,48
    800034a6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034a8:	47ad                	li	a5,11
    800034aa:	02b7e763          	bltu	a5,a1,800034d8 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800034ae:	02059493          	slli	s1,a1,0x20
    800034b2:	9081                	srli	s1,s1,0x20
    800034b4:	048a                	slli	s1,s1,0x2
    800034b6:	94aa                	add	s1,s1,a0
    800034b8:	0504a903          	lw	s2,80(s1)
    800034bc:	06091e63          	bnez	s2,80003538 <bmap+0xa2>
      addr = balloc(ip->dev);
    800034c0:	4108                	lw	a0,0(a0)
    800034c2:	00000097          	auipc	ra,0x0
    800034c6:	e9c080e7          	jalr	-356(ra) # 8000335e <balloc>
    800034ca:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034ce:	06090563          	beqz	s2,80003538 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800034d2:	0524a823          	sw	s2,80(s1)
    800034d6:	a08d                	j	80003538 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034d8:	ff45849b          	addiw	s1,a1,-12
    800034dc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034e0:	0ff00793          	li	a5,255
    800034e4:	08e7e563          	bltu	a5,a4,8000356e <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034e8:	08052903          	lw	s2,128(a0)
    800034ec:	00091d63          	bnez	s2,80003506 <bmap+0x70>
      addr = balloc(ip->dev);
    800034f0:	4108                	lw	a0,0(a0)
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	e6c080e7          	jalr	-404(ra) # 8000335e <balloc>
    800034fa:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034fe:	02090d63          	beqz	s2,80003538 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003502:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003506:	85ca                	mv	a1,s2
    80003508:	0009a503          	lw	a0,0(s3)
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	b90080e7          	jalr	-1136(ra) # 8000309c <bread>
    80003514:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003516:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000351a:	02049593          	slli	a1,s1,0x20
    8000351e:	9181                	srli	a1,a1,0x20
    80003520:	058a                	slli	a1,a1,0x2
    80003522:	00b784b3          	add	s1,a5,a1
    80003526:	0004a903          	lw	s2,0(s1)
    8000352a:	02090063          	beqz	s2,8000354a <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000352e:	8552                	mv	a0,s4
    80003530:	00000097          	auipc	ra,0x0
    80003534:	c9c080e7          	jalr	-868(ra) # 800031cc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003538:	854a                	mv	a0,s2
    8000353a:	70a2                	ld	ra,40(sp)
    8000353c:	7402                	ld	s0,32(sp)
    8000353e:	64e2                	ld	s1,24(sp)
    80003540:	6942                	ld	s2,16(sp)
    80003542:	69a2                	ld	s3,8(sp)
    80003544:	6a02                	ld	s4,0(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
      addr = balloc(ip->dev);
    8000354a:	0009a503          	lw	a0,0(s3)
    8000354e:	00000097          	auipc	ra,0x0
    80003552:	e10080e7          	jalr	-496(ra) # 8000335e <balloc>
    80003556:	0005091b          	sext.w	s2,a0
      if(addr){
    8000355a:	fc090ae3          	beqz	s2,8000352e <bmap+0x98>
        a[bn] = addr;
    8000355e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003562:	8552                	mv	a0,s4
    80003564:	00001097          	auipc	ra,0x1
    80003568:	eec080e7          	jalr	-276(ra) # 80004450 <log_write>
    8000356c:	b7c9                	j	8000352e <bmap+0x98>
  panic("bmap: out of range");
    8000356e:	00005517          	auipc	a0,0x5
    80003572:	02a50513          	addi	a0,a0,42 # 80008598 <syscalls+0x120>
    80003576:	ffffd097          	auipc	ra,0xffffd
    8000357a:	fc8080e7          	jalr	-56(ra) # 8000053e <panic>

000000008000357e <iget>:
{
    8000357e:	7179                	addi	sp,sp,-48
    80003580:	f406                	sd	ra,40(sp)
    80003582:	f022                	sd	s0,32(sp)
    80003584:	ec26                	sd	s1,24(sp)
    80003586:	e84a                	sd	s2,16(sp)
    80003588:	e44e                	sd	s3,8(sp)
    8000358a:	e052                	sd	s4,0(sp)
    8000358c:	1800                	addi	s0,sp,48
    8000358e:	89aa                	mv	s3,a0
    80003590:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003592:	0001c517          	auipc	a0,0x1c
    80003596:	ef650513          	addi	a0,a0,-266 # 8001f488 <itable>
    8000359a:	ffffd097          	auipc	ra,0xffffd
    8000359e:	63c080e7          	jalr	1596(ra) # 80000bd6 <acquire>
  empty = 0;
    800035a2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035a4:	0001c497          	auipc	s1,0x1c
    800035a8:	efc48493          	addi	s1,s1,-260 # 8001f4a0 <itable+0x18>
    800035ac:	0001e697          	auipc	a3,0x1e
    800035b0:	98468693          	addi	a3,a3,-1660 # 80020f30 <log>
    800035b4:	a039                	j	800035c2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035b6:	02090b63          	beqz	s2,800035ec <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035ba:	08848493          	addi	s1,s1,136
    800035be:	02d48a63          	beq	s1,a3,800035f2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035c2:	449c                	lw	a5,8(s1)
    800035c4:	fef059e3          	blez	a5,800035b6 <iget+0x38>
    800035c8:	4098                	lw	a4,0(s1)
    800035ca:	ff3716e3          	bne	a4,s3,800035b6 <iget+0x38>
    800035ce:	40d8                	lw	a4,4(s1)
    800035d0:	ff4713e3          	bne	a4,s4,800035b6 <iget+0x38>
      ip->ref++;
    800035d4:	2785                	addiw	a5,a5,1
    800035d6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035d8:	0001c517          	auipc	a0,0x1c
    800035dc:	eb050513          	addi	a0,a0,-336 # 8001f488 <itable>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	6aa080e7          	jalr	1706(ra) # 80000c8a <release>
      return ip;
    800035e8:	8926                	mv	s2,s1
    800035ea:	a03d                	j	80003618 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ec:	f7f9                	bnez	a5,800035ba <iget+0x3c>
    800035ee:	8926                	mv	s2,s1
    800035f0:	b7e9                	j	800035ba <iget+0x3c>
  if(empty == 0)
    800035f2:	02090c63          	beqz	s2,8000362a <iget+0xac>
  ip->dev = dev;
    800035f6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035fa:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035fe:	4785                	li	a5,1
    80003600:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003604:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003608:	0001c517          	auipc	a0,0x1c
    8000360c:	e8050513          	addi	a0,a0,-384 # 8001f488 <itable>
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	67a080e7          	jalr	1658(ra) # 80000c8a <release>
}
    80003618:	854a                	mv	a0,s2
    8000361a:	70a2                	ld	ra,40(sp)
    8000361c:	7402                	ld	s0,32(sp)
    8000361e:	64e2                	ld	s1,24(sp)
    80003620:	6942                	ld	s2,16(sp)
    80003622:	69a2                	ld	s3,8(sp)
    80003624:	6a02                	ld	s4,0(sp)
    80003626:	6145                	addi	sp,sp,48
    80003628:	8082                	ret
    panic("iget: no inodes");
    8000362a:	00005517          	auipc	a0,0x5
    8000362e:	f8650513          	addi	a0,a0,-122 # 800085b0 <syscalls+0x138>
    80003632:	ffffd097          	auipc	ra,0xffffd
    80003636:	f0c080e7          	jalr	-244(ra) # 8000053e <panic>

000000008000363a <fsinit>:
fsinit(int dev) {
    8000363a:	7179                	addi	sp,sp,-48
    8000363c:	f406                	sd	ra,40(sp)
    8000363e:	f022                	sd	s0,32(sp)
    80003640:	ec26                	sd	s1,24(sp)
    80003642:	e84a                	sd	s2,16(sp)
    80003644:	e44e                	sd	s3,8(sp)
    80003646:	1800                	addi	s0,sp,48
    80003648:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000364a:	4585                	li	a1,1
    8000364c:	00000097          	auipc	ra,0x0
    80003650:	a50080e7          	jalr	-1456(ra) # 8000309c <bread>
    80003654:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003656:	0001c997          	auipc	s3,0x1c
    8000365a:	e1298993          	addi	s3,s3,-494 # 8001f468 <sb>
    8000365e:	02000613          	li	a2,32
    80003662:	05850593          	addi	a1,a0,88
    80003666:	854e                	mv	a0,s3
    80003668:	ffffd097          	auipc	ra,0xffffd
    8000366c:	6c6080e7          	jalr	1734(ra) # 80000d2e <memmove>
  brelse(bp);
    80003670:	8526                	mv	a0,s1
    80003672:	00000097          	auipc	ra,0x0
    80003676:	b5a080e7          	jalr	-1190(ra) # 800031cc <brelse>
  if(sb.magic != FSMAGIC)
    8000367a:	0009a703          	lw	a4,0(s3)
    8000367e:	102037b7          	lui	a5,0x10203
    80003682:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003686:	02f71263          	bne	a4,a5,800036aa <fsinit+0x70>
  initlog(dev, &sb);
    8000368a:	0001c597          	auipc	a1,0x1c
    8000368e:	dde58593          	addi	a1,a1,-546 # 8001f468 <sb>
    80003692:	854a                	mv	a0,s2
    80003694:	00001097          	auipc	ra,0x1
    80003698:	b40080e7          	jalr	-1216(ra) # 800041d4 <initlog>
}
    8000369c:	70a2                	ld	ra,40(sp)
    8000369e:	7402                	ld	s0,32(sp)
    800036a0:	64e2                	ld	s1,24(sp)
    800036a2:	6942                	ld	s2,16(sp)
    800036a4:	69a2                	ld	s3,8(sp)
    800036a6:	6145                	addi	sp,sp,48
    800036a8:	8082                	ret
    panic("invalid file system");
    800036aa:	00005517          	auipc	a0,0x5
    800036ae:	f1650513          	addi	a0,a0,-234 # 800085c0 <syscalls+0x148>
    800036b2:	ffffd097          	auipc	ra,0xffffd
    800036b6:	e8c080e7          	jalr	-372(ra) # 8000053e <panic>

00000000800036ba <iinit>:
{
    800036ba:	7179                	addi	sp,sp,-48
    800036bc:	f406                	sd	ra,40(sp)
    800036be:	f022                	sd	s0,32(sp)
    800036c0:	ec26                	sd	s1,24(sp)
    800036c2:	e84a                	sd	s2,16(sp)
    800036c4:	e44e                	sd	s3,8(sp)
    800036c6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036c8:	00005597          	auipc	a1,0x5
    800036cc:	f1058593          	addi	a1,a1,-240 # 800085d8 <syscalls+0x160>
    800036d0:	0001c517          	auipc	a0,0x1c
    800036d4:	db850513          	addi	a0,a0,-584 # 8001f488 <itable>
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	46e080e7          	jalr	1134(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036e0:	0001c497          	auipc	s1,0x1c
    800036e4:	dd048493          	addi	s1,s1,-560 # 8001f4b0 <itable+0x28>
    800036e8:	0001e997          	auipc	s3,0x1e
    800036ec:	85898993          	addi	s3,s3,-1960 # 80020f40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036f0:	00005917          	auipc	s2,0x5
    800036f4:	ef090913          	addi	s2,s2,-272 # 800085e0 <syscalls+0x168>
    800036f8:	85ca                	mv	a1,s2
    800036fa:	8526                	mv	a0,s1
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	e3a080e7          	jalr	-454(ra) # 80004536 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003704:	08848493          	addi	s1,s1,136
    80003708:	ff3498e3          	bne	s1,s3,800036f8 <iinit+0x3e>
}
    8000370c:	70a2                	ld	ra,40(sp)
    8000370e:	7402                	ld	s0,32(sp)
    80003710:	64e2                	ld	s1,24(sp)
    80003712:	6942                	ld	s2,16(sp)
    80003714:	69a2                	ld	s3,8(sp)
    80003716:	6145                	addi	sp,sp,48
    80003718:	8082                	ret

000000008000371a <ialloc>:
{
    8000371a:	715d                	addi	sp,sp,-80
    8000371c:	e486                	sd	ra,72(sp)
    8000371e:	e0a2                	sd	s0,64(sp)
    80003720:	fc26                	sd	s1,56(sp)
    80003722:	f84a                	sd	s2,48(sp)
    80003724:	f44e                	sd	s3,40(sp)
    80003726:	f052                	sd	s4,32(sp)
    80003728:	ec56                	sd	s5,24(sp)
    8000372a:	e85a                	sd	s6,16(sp)
    8000372c:	e45e                	sd	s7,8(sp)
    8000372e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003730:	0001c717          	auipc	a4,0x1c
    80003734:	d4472703          	lw	a4,-700(a4) # 8001f474 <sb+0xc>
    80003738:	4785                	li	a5,1
    8000373a:	04e7fa63          	bgeu	a5,a4,8000378e <ialloc+0x74>
    8000373e:	8aaa                	mv	s5,a0
    80003740:	8bae                	mv	s7,a1
    80003742:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003744:	0001ca17          	auipc	s4,0x1c
    80003748:	d24a0a13          	addi	s4,s4,-732 # 8001f468 <sb>
    8000374c:	00048b1b          	sext.w	s6,s1
    80003750:	0044d793          	srli	a5,s1,0x4
    80003754:	018a2583          	lw	a1,24(s4)
    80003758:	9dbd                	addw	a1,a1,a5
    8000375a:	8556                	mv	a0,s5
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	940080e7          	jalr	-1728(ra) # 8000309c <bread>
    80003764:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003766:	05850993          	addi	s3,a0,88
    8000376a:	00f4f793          	andi	a5,s1,15
    8000376e:	079a                	slli	a5,a5,0x6
    80003770:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003772:	00099783          	lh	a5,0(s3)
    80003776:	c3a1                	beqz	a5,800037b6 <ialloc+0x9c>
    brelse(bp);
    80003778:	00000097          	auipc	ra,0x0
    8000377c:	a54080e7          	jalr	-1452(ra) # 800031cc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003780:	0485                	addi	s1,s1,1
    80003782:	00ca2703          	lw	a4,12(s4)
    80003786:	0004879b          	sext.w	a5,s1
    8000378a:	fce7e1e3          	bltu	a5,a4,8000374c <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	e5a50513          	addi	a0,a0,-422 # 800085e8 <syscalls+0x170>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	df2080e7          	jalr	-526(ra) # 80000588 <printf>
  return 0;
    8000379e:	4501                	li	a0,0
}
    800037a0:	60a6                	ld	ra,72(sp)
    800037a2:	6406                	ld	s0,64(sp)
    800037a4:	74e2                	ld	s1,56(sp)
    800037a6:	7942                	ld	s2,48(sp)
    800037a8:	79a2                	ld	s3,40(sp)
    800037aa:	7a02                	ld	s4,32(sp)
    800037ac:	6ae2                	ld	s5,24(sp)
    800037ae:	6b42                	ld	s6,16(sp)
    800037b0:	6ba2                	ld	s7,8(sp)
    800037b2:	6161                	addi	sp,sp,80
    800037b4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037b6:	04000613          	li	a2,64
    800037ba:	4581                	li	a1,0
    800037bc:	854e                	mv	a0,s3
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	514080e7          	jalr	1300(ra) # 80000cd2 <memset>
      dip->type = type;
    800037c6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037ca:	854a                	mv	a0,s2
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	c84080e7          	jalr	-892(ra) # 80004450 <log_write>
      brelse(bp);
    800037d4:	854a                	mv	a0,s2
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	9f6080e7          	jalr	-1546(ra) # 800031cc <brelse>
      return iget(dev, inum);
    800037de:	85da                	mv	a1,s6
    800037e0:	8556                	mv	a0,s5
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	d9c080e7          	jalr	-612(ra) # 8000357e <iget>
    800037ea:	bf5d                	j	800037a0 <ialloc+0x86>

00000000800037ec <iupdate>:
{
    800037ec:	1101                	addi	sp,sp,-32
    800037ee:	ec06                	sd	ra,24(sp)
    800037f0:	e822                	sd	s0,16(sp)
    800037f2:	e426                	sd	s1,8(sp)
    800037f4:	e04a                	sd	s2,0(sp)
    800037f6:	1000                	addi	s0,sp,32
    800037f8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037fa:	415c                	lw	a5,4(a0)
    800037fc:	0047d79b          	srliw	a5,a5,0x4
    80003800:	0001c597          	auipc	a1,0x1c
    80003804:	c805a583          	lw	a1,-896(a1) # 8001f480 <sb+0x18>
    80003808:	9dbd                	addw	a1,a1,a5
    8000380a:	4108                	lw	a0,0(a0)
    8000380c:	00000097          	auipc	ra,0x0
    80003810:	890080e7          	jalr	-1904(ra) # 8000309c <bread>
    80003814:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003816:	05850793          	addi	a5,a0,88
    8000381a:	40c8                	lw	a0,4(s1)
    8000381c:	893d                	andi	a0,a0,15
    8000381e:	051a                	slli	a0,a0,0x6
    80003820:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003822:	04449703          	lh	a4,68(s1)
    80003826:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000382a:	04649703          	lh	a4,70(s1)
    8000382e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003832:	04849703          	lh	a4,72(s1)
    80003836:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000383a:	04a49703          	lh	a4,74(s1)
    8000383e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003842:	44f8                	lw	a4,76(s1)
    80003844:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003846:	03400613          	li	a2,52
    8000384a:	05048593          	addi	a1,s1,80
    8000384e:	0531                	addi	a0,a0,12
    80003850:	ffffd097          	auipc	ra,0xffffd
    80003854:	4de080e7          	jalr	1246(ra) # 80000d2e <memmove>
  log_write(bp);
    80003858:	854a                	mv	a0,s2
    8000385a:	00001097          	auipc	ra,0x1
    8000385e:	bf6080e7          	jalr	-1034(ra) # 80004450 <log_write>
  brelse(bp);
    80003862:	854a                	mv	a0,s2
    80003864:	00000097          	auipc	ra,0x0
    80003868:	968080e7          	jalr	-1688(ra) # 800031cc <brelse>
}
    8000386c:	60e2                	ld	ra,24(sp)
    8000386e:	6442                	ld	s0,16(sp)
    80003870:	64a2                	ld	s1,8(sp)
    80003872:	6902                	ld	s2,0(sp)
    80003874:	6105                	addi	sp,sp,32
    80003876:	8082                	ret

0000000080003878 <idup>:
{
    80003878:	1101                	addi	sp,sp,-32
    8000387a:	ec06                	sd	ra,24(sp)
    8000387c:	e822                	sd	s0,16(sp)
    8000387e:	e426                	sd	s1,8(sp)
    80003880:	1000                	addi	s0,sp,32
    80003882:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003884:	0001c517          	auipc	a0,0x1c
    80003888:	c0450513          	addi	a0,a0,-1020 # 8001f488 <itable>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	34a080e7          	jalr	842(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003894:	449c                	lw	a5,8(s1)
    80003896:	2785                	addiw	a5,a5,1
    80003898:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000389a:	0001c517          	auipc	a0,0x1c
    8000389e:	bee50513          	addi	a0,a0,-1042 # 8001f488 <itable>
    800038a2:	ffffd097          	auipc	ra,0xffffd
    800038a6:	3e8080e7          	jalr	1000(ra) # 80000c8a <release>
}
    800038aa:	8526                	mv	a0,s1
    800038ac:	60e2                	ld	ra,24(sp)
    800038ae:	6442                	ld	s0,16(sp)
    800038b0:	64a2                	ld	s1,8(sp)
    800038b2:	6105                	addi	sp,sp,32
    800038b4:	8082                	ret

00000000800038b6 <ilock>:
{
    800038b6:	1101                	addi	sp,sp,-32
    800038b8:	ec06                	sd	ra,24(sp)
    800038ba:	e822                	sd	s0,16(sp)
    800038bc:	e426                	sd	s1,8(sp)
    800038be:	e04a                	sd	s2,0(sp)
    800038c0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038c2:	c115                	beqz	a0,800038e6 <ilock+0x30>
    800038c4:	84aa                	mv	s1,a0
    800038c6:	451c                	lw	a5,8(a0)
    800038c8:	00f05f63          	blez	a5,800038e6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800038cc:	0541                	addi	a0,a0,16
    800038ce:	00001097          	auipc	ra,0x1
    800038d2:	ca2080e7          	jalr	-862(ra) # 80004570 <acquiresleep>
  if(ip->valid == 0){
    800038d6:	40bc                	lw	a5,64(s1)
    800038d8:	cf99                	beqz	a5,800038f6 <ilock+0x40>
}
    800038da:	60e2                	ld	ra,24(sp)
    800038dc:	6442                	ld	s0,16(sp)
    800038de:	64a2                	ld	s1,8(sp)
    800038e0:	6902                	ld	s2,0(sp)
    800038e2:	6105                	addi	sp,sp,32
    800038e4:	8082                	ret
    panic("ilock");
    800038e6:	00005517          	auipc	a0,0x5
    800038ea:	d1a50513          	addi	a0,a0,-742 # 80008600 <syscalls+0x188>
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	c50080e7          	jalr	-944(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038f6:	40dc                	lw	a5,4(s1)
    800038f8:	0047d79b          	srliw	a5,a5,0x4
    800038fc:	0001c597          	auipc	a1,0x1c
    80003900:	b845a583          	lw	a1,-1148(a1) # 8001f480 <sb+0x18>
    80003904:	9dbd                	addw	a1,a1,a5
    80003906:	4088                	lw	a0,0(s1)
    80003908:	fffff097          	auipc	ra,0xfffff
    8000390c:	794080e7          	jalr	1940(ra) # 8000309c <bread>
    80003910:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003912:	05850593          	addi	a1,a0,88
    80003916:	40dc                	lw	a5,4(s1)
    80003918:	8bbd                	andi	a5,a5,15
    8000391a:	079a                	slli	a5,a5,0x6
    8000391c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000391e:	00059783          	lh	a5,0(a1)
    80003922:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003926:	00259783          	lh	a5,2(a1)
    8000392a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000392e:	00459783          	lh	a5,4(a1)
    80003932:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003936:	00659783          	lh	a5,6(a1)
    8000393a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000393e:	459c                	lw	a5,8(a1)
    80003940:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003942:	03400613          	li	a2,52
    80003946:	05b1                	addi	a1,a1,12
    80003948:	05048513          	addi	a0,s1,80
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	3e2080e7          	jalr	994(ra) # 80000d2e <memmove>
    brelse(bp);
    80003954:	854a                	mv	a0,s2
    80003956:	00000097          	auipc	ra,0x0
    8000395a:	876080e7          	jalr	-1930(ra) # 800031cc <brelse>
    ip->valid = 1;
    8000395e:	4785                	li	a5,1
    80003960:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003962:	04449783          	lh	a5,68(s1)
    80003966:	fbb5                	bnez	a5,800038da <ilock+0x24>
      panic("ilock: no type");
    80003968:	00005517          	auipc	a0,0x5
    8000396c:	ca050513          	addi	a0,a0,-864 # 80008608 <syscalls+0x190>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	bce080e7          	jalr	-1074(ra) # 8000053e <panic>

0000000080003978 <iunlock>:
{
    80003978:	1101                	addi	sp,sp,-32
    8000397a:	ec06                	sd	ra,24(sp)
    8000397c:	e822                	sd	s0,16(sp)
    8000397e:	e426                	sd	s1,8(sp)
    80003980:	e04a                	sd	s2,0(sp)
    80003982:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003984:	c905                	beqz	a0,800039b4 <iunlock+0x3c>
    80003986:	84aa                	mv	s1,a0
    80003988:	01050913          	addi	s2,a0,16
    8000398c:	854a                	mv	a0,s2
    8000398e:	00001097          	auipc	ra,0x1
    80003992:	c7c080e7          	jalr	-900(ra) # 8000460a <holdingsleep>
    80003996:	cd19                	beqz	a0,800039b4 <iunlock+0x3c>
    80003998:	449c                	lw	a5,8(s1)
    8000399a:	00f05d63          	blez	a5,800039b4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000399e:	854a                	mv	a0,s2
    800039a0:	00001097          	auipc	ra,0x1
    800039a4:	c26080e7          	jalr	-986(ra) # 800045c6 <releasesleep>
}
    800039a8:	60e2                	ld	ra,24(sp)
    800039aa:	6442                	ld	s0,16(sp)
    800039ac:	64a2                	ld	s1,8(sp)
    800039ae:	6902                	ld	s2,0(sp)
    800039b0:	6105                	addi	sp,sp,32
    800039b2:	8082                	ret
    panic("iunlock");
    800039b4:	00005517          	auipc	a0,0x5
    800039b8:	c6450513          	addi	a0,a0,-924 # 80008618 <syscalls+0x1a0>
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	b82080e7          	jalr	-1150(ra) # 8000053e <panic>

00000000800039c4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039c4:	7179                	addi	sp,sp,-48
    800039c6:	f406                	sd	ra,40(sp)
    800039c8:	f022                	sd	s0,32(sp)
    800039ca:	ec26                	sd	s1,24(sp)
    800039cc:	e84a                	sd	s2,16(sp)
    800039ce:	e44e                	sd	s3,8(sp)
    800039d0:	e052                	sd	s4,0(sp)
    800039d2:	1800                	addi	s0,sp,48
    800039d4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039d6:	05050493          	addi	s1,a0,80
    800039da:	08050913          	addi	s2,a0,128
    800039de:	a021                	j	800039e6 <itrunc+0x22>
    800039e0:	0491                	addi	s1,s1,4
    800039e2:	01248d63          	beq	s1,s2,800039fc <itrunc+0x38>
    if(ip->addrs[i]){
    800039e6:	408c                	lw	a1,0(s1)
    800039e8:	dde5                	beqz	a1,800039e0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039ea:	0009a503          	lw	a0,0(s3)
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	8f4080e7          	jalr	-1804(ra) # 800032e2 <bfree>
      ip->addrs[i] = 0;
    800039f6:	0004a023          	sw	zero,0(s1)
    800039fa:	b7dd                	j	800039e0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039fc:	0809a583          	lw	a1,128(s3)
    80003a00:	e185                	bnez	a1,80003a20 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a02:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a06:	854e                	mv	a0,s3
    80003a08:	00000097          	auipc	ra,0x0
    80003a0c:	de4080e7          	jalr	-540(ra) # 800037ec <iupdate>
}
    80003a10:	70a2                	ld	ra,40(sp)
    80003a12:	7402                	ld	s0,32(sp)
    80003a14:	64e2                	ld	s1,24(sp)
    80003a16:	6942                	ld	s2,16(sp)
    80003a18:	69a2                	ld	s3,8(sp)
    80003a1a:	6a02                	ld	s4,0(sp)
    80003a1c:	6145                	addi	sp,sp,48
    80003a1e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a20:	0009a503          	lw	a0,0(s3)
    80003a24:	fffff097          	auipc	ra,0xfffff
    80003a28:	678080e7          	jalr	1656(ra) # 8000309c <bread>
    80003a2c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a2e:	05850493          	addi	s1,a0,88
    80003a32:	45850913          	addi	s2,a0,1112
    80003a36:	a021                	j	80003a3e <itrunc+0x7a>
    80003a38:	0491                	addi	s1,s1,4
    80003a3a:	01248b63          	beq	s1,s2,80003a50 <itrunc+0x8c>
      if(a[j])
    80003a3e:	408c                	lw	a1,0(s1)
    80003a40:	dde5                	beqz	a1,80003a38 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a42:	0009a503          	lw	a0,0(s3)
    80003a46:	00000097          	auipc	ra,0x0
    80003a4a:	89c080e7          	jalr	-1892(ra) # 800032e2 <bfree>
    80003a4e:	b7ed                	j	80003a38 <itrunc+0x74>
    brelse(bp);
    80003a50:	8552                	mv	a0,s4
    80003a52:	fffff097          	auipc	ra,0xfffff
    80003a56:	77a080e7          	jalr	1914(ra) # 800031cc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a5a:	0809a583          	lw	a1,128(s3)
    80003a5e:	0009a503          	lw	a0,0(s3)
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	880080e7          	jalr	-1920(ra) # 800032e2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a6a:	0809a023          	sw	zero,128(s3)
    80003a6e:	bf51                	j	80003a02 <itrunc+0x3e>

0000000080003a70 <iput>:
{
    80003a70:	1101                	addi	sp,sp,-32
    80003a72:	ec06                	sd	ra,24(sp)
    80003a74:	e822                	sd	s0,16(sp)
    80003a76:	e426                	sd	s1,8(sp)
    80003a78:	e04a                	sd	s2,0(sp)
    80003a7a:	1000                	addi	s0,sp,32
    80003a7c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a7e:	0001c517          	auipc	a0,0x1c
    80003a82:	a0a50513          	addi	a0,a0,-1526 # 8001f488 <itable>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	150080e7          	jalr	336(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a8e:	4498                	lw	a4,8(s1)
    80003a90:	4785                	li	a5,1
    80003a92:	02f70363          	beq	a4,a5,80003ab8 <iput+0x48>
  ip->ref--;
    80003a96:	449c                	lw	a5,8(s1)
    80003a98:	37fd                	addiw	a5,a5,-1
    80003a9a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a9c:	0001c517          	auipc	a0,0x1c
    80003aa0:	9ec50513          	addi	a0,a0,-1556 # 8001f488 <itable>
    80003aa4:	ffffd097          	auipc	ra,0xffffd
    80003aa8:	1e6080e7          	jalr	486(ra) # 80000c8a <release>
}
    80003aac:	60e2                	ld	ra,24(sp)
    80003aae:	6442                	ld	s0,16(sp)
    80003ab0:	64a2                	ld	s1,8(sp)
    80003ab2:	6902                	ld	s2,0(sp)
    80003ab4:	6105                	addi	sp,sp,32
    80003ab6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ab8:	40bc                	lw	a5,64(s1)
    80003aba:	dff1                	beqz	a5,80003a96 <iput+0x26>
    80003abc:	04a49783          	lh	a5,74(s1)
    80003ac0:	fbf9                	bnez	a5,80003a96 <iput+0x26>
    acquiresleep(&ip->lock);
    80003ac2:	01048913          	addi	s2,s1,16
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	00001097          	auipc	ra,0x1
    80003acc:	aa8080e7          	jalr	-1368(ra) # 80004570 <acquiresleep>
    release(&itable.lock);
    80003ad0:	0001c517          	auipc	a0,0x1c
    80003ad4:	9b850513          	addi	a0,a0,-1608 # 8001f488 <itable>
    80003ad8:	ffffd097          	auipc	ra,0xffffd
    80003adc:	1b2080e7          	jalr	434(ra) # 80000c8a <release>
    itrunc(ip);
    80003ae0:	8526                	mv	a0,s1
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	ee2080e7          	jalr	-286(ra) # 800039c4 <itrunc>
    ip->type = 0;
    80003aea:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aee:	8526                	mv	a0,s1
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	cfc080e7          	jalr	-772(ra) # 800037ec <iupdate>
    ip->valid = 0;
    80003af8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003afc:	854a                	mv	a0,s2
    80003afe:	00001097          	auipc	ra,0x1
    80003b02:	ac8080e7          	jalr	-1336(ra) # 800045c6 <releasesleep>
    acquire(&itable.lock);
    80003b06:	0001c517          	auipc	a0,0x1c
    80003b0a:	98250513          	addi	a0,a0,-1662 # 8001f488 <itable>
    80003b0e:	ffffd097          	auipc	ra,0xffffd
    80003b12:	0c8080e7          	jalr	200(ra) # 80000bd6 <acquire>
    80003b16:	b741                	j	80003a96 <iput+0x26>

0000000080003b18 <iunlockput>:
{
    80003b18:	1101                	addi	sp,sp,-32
    80003b1a:	ec06                	sd	ra,24(sp)
    80003b1c:	e822                	sd	s0,16(sp)
    80003b1e:	e426                	sd	s1,8(sp)
    80003b20:	1000                	addi	s0,sp,32
    80003b22:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	e54080e7          	jalr	-428(ra) # 80003978 <iunlock>
  iput(ip);
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	00000097          	auipc	ra,0x0
    80003b32:	f42080e7          	jalr	-190(ra) # 80003a70 <iput>
}
    80003b36:	60e2                	ld	ra,24(sp)
    80003b38:	6442                	ld	s0,16(sp)
    80003b3a:	64a2                	ld	s1,8(sp)
    80003b3c:	6105                	addi	sp,sp,32
    80003b3e:	8082                	ret

0000000080003b40 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b40:	1141                	addi	sp,sp,-16
    80003b42:	e422                	sd	s0,8(sp)
    80003b44:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b46:	411c                	lw	a5,0(a0)
    80003b48:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b4a:	415c                	lw	a5,4(a0)
    80003b4c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b4e:	04451783          	lh	a5,68(a0)
    80003b52:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b56:	04a51783          	lh	a5,74(a0)
    80003b5a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b5e:	04c56783          	lwu	a5,76(a0)
    80003b62:	e99c                	sd	a5,16(a1)
}
    80003b64:	6422                	ld	s0,8(sp)
    80003b66:	0141                	addi	sp,sp,16
    80003b68:	8082                	ret

0000000080003b6a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b6a:	457c                	lw	a5,76(a0)
    80003b6c:	0ed7e963          	bltu	a5,a3,80003c5e <readi+0xf4>
{
    80003b70:	7159                	addi	sp,sp,-112
    80003b72:	f486                	sd	ra,104(sp)
    80003b74:	f0a2                	sd	s0,96(sp)
    80003b76:	eca6                	sd	s1,88(sp)
    80003b78:	e8ca                	sd	s2,80(sp)
    80003b7a:	e4ce                	sd	s3,72(sp)
    80003b7c:	e0d2                	sd	s4,64(sp)
    80003b7e:	fc56                	sd	s5,56(sp)
    80003b80:	f85a                	sd	s6,48(sp)
    80003b82:	f45e                	sd	s7,40(sp)
    80003b84:	f062                	sd	s8,32(sp)
    80003b86:	ec66                	sd	s9,24(sp)
    80003b88:	e86a                	sd	s10,16(sp)
    80003b8a:	e46e                	sd	s11,8(sp)
    80003b8c:	1880                	addi	s0,sp,112
    80003b8e:	8b2a                	mv	s6,a0
    80003b90:	8bae                	mv	s7,a1
    80003b92:	8a32                	mv	s4,a2
    80003b94:	84b6                	mv	s1,a3
    80003b96:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b98:	9f35                	addw	a4,a4,a3
    return 0;
    80003b9a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b9c:	0ad76063          	bltu	a4,a3,80003c3c <readi+0xd2>
  if(off + n > ip->size)
    80003ba0:	00e7f463          	bgeu	a5,a4,80003ba8 <readi+0x3e>
    n = ip->size - off;
    80003ba4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ba8:	0a0a8963          	beqz	s5,80003c5a <readi+0xf0>
    80003bac:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bae:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bb2:	5c7d                	li	s8,-1
    80003bb4:	a82d                	j	80003bee <readi+0x84>
    80003bb6:	020d1d93          	slli	s11,s10,0x20
    80003bba:	020ddd93          	srli	s11,s11,0x20
    80003bbe:	05890793          	addi	a5,s2,88
    80003bc2:	86ee                	mv	a3,s11
    80003bc4:	963e                	add	a2,a2,a5
    80003bc6:	85d2                	mv	a1,s4
    80003bc8:	855e                	mv	a0,s7
    80003bca:	fffff097          	auipc	ra,0xfffff
    80003bce:	a72080e7          	jalr	-1422(ra) # 8000263c <either_copyout>
    80003bd2:	05850d63          	beq	a0,s8,80003c2c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bd6:	854a                	mv	a0,s2
    80003bd8:	fffff097          	auipc	ra,0xfffff
    80003bdc:	5f4080e7          	jalr	1524(ra) # 800031cc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003be0:	013d09bb          	addw	s3,s10,s3
    80003be4:	009d04bb          	addw	s1,s10,s1
    80003be8:	9a6e                	add	s4,s4,s11
    80003bea:	0559f763          	bgeu	s3,s5,80003c38 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003bee:	00a4d59b          	srliw	a1,s1,0xa
    80003bf2:	855a                	mv	a0,s6
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	8a2080e7          	jalr	-1886(ra) # 80003496 <bmap>
    80003bfc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c00:	cd85                	beqz	a1,80003c38 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c02:	000b2503          	lw	a0,0(s6)
    80003c06:	fffff097          	auipc	ra,0xfffff
    80003c0a:	496080e7          	jalr	1174(ra) # 8000309c <bread>
    80003c0e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c10:	3ff4f613          	andi	a2,s1,1023
    80003c14:	40cc87bb          	subw	a5,s9,a2
    80003c18:	413a873b          	subw	a4,s5,s3
    80003c1c:	8d3e                	mv	s10,a5
    80003c1e:	2781                	sext.w	a5,a5
    80003c20:	0007069b          	sext.w	a3,a4
    80003c24:	f8f6f9e3          	bgeu	a3,a5,80003bb6 <readi+0x4c>
    80003c28:	8d3a                	mv	s10,a4
    80003c2a:	b771                	j	80003bb6 <readi+0x4c>
      brelse(bp);
    80003c2c:	854a                	mv	a0,s2
    80003c2e:	fffff097          	auipc	ra,0xfffff
    80003c32:	59e080e7          	jalr	1438(ra) # 800031cc <brelse>
      tot = -1;
    80003c36:	59fd                	li	s3,-1
  }
  return tot;
    80003c38:	0009851b          	sext.w	a0,s3
}
    80003c3c:	70a6                	ld	ra,104(sp)
    80003c3e:	7406                	ld	s0,96(sp)
    80003c40:	64e6                	ld	s1,88(sp)
    80003c42:	6946                	ld	s2,80(sp)
    80003c44:	69a6                	ld	s3,72(sp)
    80003c46:	6a06                	ld	s4,64(sp)
    80003c48:	7ae2                	ld	s5,56(sp)
    80003c4a:	7b42                	ld	s6,48(sp)
    80003c4c:	7ba2                	ld	s7,40(sp)
    80003c4e:	7c02                	ld	s8,32(sp)
    80003c50:	6ce2                	ld	s9,24(sp)
    80003c52:	6d42                	ld	s10,16(sp)
    80003c54:	6da2                	ld	s11,8(sp)
    80003c56:	6165                	addi	sp,sp,112
    80003c58:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c5a:	89d6                	mv	s3,s5
    80003c5c:	bff1                	j	80003c38 <readi+0xce>
    return 0;
    80003c5e:	4501                	li	a0,0
}
    80003c60:	8082                	ret

0000000080003c62 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c62:	457c                	lw	a5,76(a0)
    80003c64:	10d7e863          	bltu	a5,a3,80003d74 <writei+0x112>
{
    80003c68:	7159                	addi	sp,sp,-112
    80003c6a:	f486                	sd	ra,104(sp)
    80003c6c:	f0a2                	sd	s0,96(sp)
    80003c6e:	eca6                	sd	s1,88(sp)
    80003c70:	e8ca                	sd	s2,80(sp)
    80003c72:	e4ce                	sd	s3,72(sp)
    80003c74:	e0d2                	sd	s4,64(sp)
    80003c76:	fc56                	sd	s5,56(sp)
    80003c78:	f85a                	sd	s6,48(sp)
    80003c7a:	f45e                	sd	s7,40(sp)
    80003c7c:	f062                	sd	s8,32(sp)
    80003c7e:	ec66                	sd	s9,24(sp)
    80003c80:	e86a                	sd	s10,16(sp)
    80003c82:	e46e                	sd	s11,8(sp)
    80003c84:	1880                	addi	s0,sp,112
    80003c86:	8aaa                	mv	s5,a0
    80003c88:	8bae                	mv	s7,a1
    80003c8a:	8a32                	mv	s4,a2
    80003c8c:	8936                	mv	s2,a3
    80003c8e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c90:	00e687bb          	addw	a5,a3,a4
    80003c94:	0ed7e263          	bltu	a5,a3,80003d78 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c98:	00043737          	lui	a4,0x43
    80003c9c:	0ef76063          	bltu	a4,a5,80003d7c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ca0:	0c0b0863          	beqz	s6,80003d70 <writei+0x10e>
    80003ca4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ca6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003caa:	5c7d                	li	s8,-1
    80003cac:	a091                	j	80003cf0 <writei+0x8e>
    80003cae:	020d1d93          	slli	s11,s10,0x20
    80003cb2:	020ddd93          	srli	s11,s11,0x20
    80003cb6:	05848793          	addi	a5,s1,88
    80003cba:	86ee                	mv	a3,s11
    80003cbc:	8652                	mv	a2,s4
    80003cbe:	85de                	mv	a1,s7
    80003cc0:	953e                	add	a0,a0,a5
    80003cc2:	fffff097          	auipc	ra,0xfffff
    80003cc6:	9d0080e7          	jalr	-1584(ra) # 80002692 <either_copyin>
    80003cca:	07850263          	beq	a0,s8,80003d2e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cce:	8526                	mv	a0,s1
    80003cd0:	00000097          	auipc	ra,0x0
    80003cd4:	780080e7          	jalr	1920(ra) # 80004450 <log_write>
    brelse(bp);
    80003cd8:	8526                	mv	a0,s1
    80003cda:	fffff097          	auipc	ra,0xfffff
    80003cde:	4f2080e7          	jalr	1266(ra) # 800031cc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ce2:	013d09bb          	addw	s3,s10,s3
    80003ce6:	012d093b          	addw	s2,s10,s2
    80003cea:	9a6e                	add	s4,s4,s11
    80003cec:	0569f663          	bgeu	s3,s6,80003d38 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003cf0:	00a9559b          	srliw	a1,s2,0xa
    80003cf4:	8556                	mv	a0,s5
    80003cf6:	fffff097          	auipc	ra,0xfffff
    80003cfa:	7a0080e7          	jalr	1952(ra) # 80003496 <bmap>
    80003cfe:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d02:	c99d                	beqz	a1,80003d38 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d04:	000aa503          	lw	a0,0(s5)
    80003d08:	fffff097          	auipc	ra,0xfffff
    80003d0c:	394080e7          	jalr	916(ra) # 8000309c <bread>
    80003d10:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d12:	3ff97513          	andi	a0,s2,1023
    80003d16:	40ac87bb          	subw	a5,s9,a0
    80003d1a:	413b073b          	subw	a4,s6,s3
    80003d1e:	8d3e                	mv	s10,a5
    80003d20:	2781                	sext.w	a5,a5
    80003d22:	0007069b          	sext.w	a3,a4
    80003d26:	f8f6f4e3          	bgeu	a3,a5,80003cae <writei+0x4c>
    80003d2a:	8d3a                	mv	s10,a4
    80003d2c:	b749                	j	80003cae <writei+0x4c>
      brelse(bp);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	fffff097          	auipc	ra,0xfffff
    80003d34:	49c080e7          	jalr	1180(ra) # 800031cc <brelse>
  }

  if(off > ip->size)
    80003d38:	04caa783          	lw	a5,76(s5)
    80003d3c:	0127f463          	bgeu	a5,s2,80003d44 <writei+0xe2>
    ip->size = off;
    80003d40:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d44:	8556                	mv	a0,s5
    80003d46:	00000097          	auipc	ra,0x0
    80003d4a:	aa6080e7          	jalr	-1370(ra) # 800037ec <iupdate>

  return tot;
    80003d4e:	0009851b          	sext.w	a0,s3
}
    80003d52:	70a6                	ld	ra,104(sp)
    80003d54:	7406                	ld	s0,96(sp)
    80003d56:	64e6                	ld	s1,88(sp)
    80003d58:	6946                	ld	s2,80(sp)
    80003d5a:	69a6                	ld	s3,72(sp)
    80003d5c:	6a06                	ld	s4,64(sp)
    80003d5e:	7ae2                	ld	s5,56(sp)
    80003d60:	7b42                	ld	s6,48(sp)
    80003d62:	7ba2                	ld	s7,40(sp)
    80003d64:	7c02                	ld	s8,32(sp)
    80003d66:	6ce2                	ld	s9,24(sp)
    80003d68:	6d42                	ld	s10,16(sp)
    80003d6a:	6da2                	ld	s11,8(sp)
    80003d6c:	6165                	addi	sp,sp,112
    80003d6e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d70:	89da                	mv	s3,s6
    80003d72:	bfc9                	j	80003d44 <writei+0xe2>
    return -1;
    80003d74:	557d                	li	a0,-1
}
    80003d76:	8082                	ret
    return -1;
    80003d78:	557d                	li	a0,-1
    80003d7a:	bfe1                	j	80003d52 <writei+0xf0>
    return -1;
    80003d7c:	557d                	li	a0,-1
    80003d7e:	bfd1                	j	80003d52 <writei+0xf0>

0000000080003d80 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d80:	1141                	addi	sp,sp,-16
    80003d82:	e406                	sd	ra,8(sp)
    80003d84:	e022                	sd	s0,0(sp)
    80003d86:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d88:	4639                	li	a2,14
    80003d8a:	ffffd097          	auipc	ra,0xffffd
    80003d8e:	018080e7          	jalr	24(ra) # 80000da2 <strncmp>
}
    80003d92:	60a2                	ld	ra,8(sp)
    80003d94:	6402                	ld	s0,0(sp)
    80003d96:	0141                	addi	sp,sp,16
    80003d98:	8082                	ret

0000000080003d9a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d9a:	7139                	addi	sp,sp,-64
    80003d9c:	fc06                	sd	ra,56(sp)
    80003d9e:	f822                	sd	s0,48(sp)
    80003da0:	f426                	sd	s1,40(sp)
    80003da2:	f04a                	sd	s2,32(sp)
    80003da4:	ec4e                	sd	s3,24(sp)
    80003da6:	e852                	sd	s4,16(sp)
    80003da8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003daa:	04451703          	lh	a4,68(a0)
    80003dae:	4785                	li	a5,1
    80003db0:	00f71a63          	bne	a4,a5,80003dc4 <dirlookup+0x2a>
    80003db4:	892a                	mv	s2,a0
    80003db6:	89ae                	mv	s3,a1
    80003db8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dba:	457c                	lw	a5,76(a0)
    80003dbc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dbe:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dc0:	e79d                	bnez	a5,80003dee <dirlookup+0x54>
    80003dc2:	a8a5                	j	80003e3a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003dc4:	00005517          	auipc	a0,0x5
    80003dc8:	85c50513          	addi	a0,a0,-1956 # 80008620 <syscalls+0x1a8>
    80003dcc:	ffffc097          	auipc	ra,0xffffc
    80003dd0:	772080e7          	jalr	1906(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003dd4:	00005517          	auipc	a0,0x5
    80003dd8:	86450513          	addi	a0,a0,-1948 # 80008638 <syscalls+0x1c0>
    80003ddc:	ffffc097          	auipc	ra,0xffffc
    80003de0:	762080e7          	jalr	1890(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de4:	24c1                	addiw	s1,s1,16
    80003de6:	04c92783          	lw	a5,76(s2)
    80003dea:	04f4f763          	bgeu	s1,a5,80003e38 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dee:	4741                	li	a4,16
    80003df0:	86a6                	mv	a3,s1
    80003df2:	fc040613          	addi	a2,s0,-64
    80003df6:	4581                	li	a1,0
    80003df8:	854a                	mv	a0,s2
    80003dfa:	00000097          	auipc	ra,0x0
    80003dfe:	d70080e7          	jalr	-656(ra) # 80003b6a <readi>
    80003e02:	47c1                	li	a5,16
    80003e04:	fcf518e3          	bne	a0,a5,80003dd4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e08:	fc045783          	lhu	a5,-64(s0)
    80003e0c:	dfe1                	beqz	a5,80003de4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e0e:	fc240593          	addi	a1,s0,-62
    80003e12:	854e                	mv	a0,s3
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	f6c080e7          	jalr	-148(ra) # 80003d80 <namecmp>
    80003e1c:	f561                	bnez	a0,80003de4 <dirlookup+0x4a>
      if(poff)
    80003e1e:	000a0463          	beqz	s4,80003e26 <dirlookup+0x8c>
        *poff = off;
    80003e22:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e26:	fc045583          	lhu	a1,-64(s0)
    80003e2a:	00092503          	lw	a0,0(s2)
    80003e2e:	fffff097          	auipc	ra,0xfffff
    80003e32:	750080e7          	jalr	1872(ra) # 8000357e <iget>
    80003e36:	a011                	j	80003e3a <dirlookup+0xa0>
  return 0;
    80003e38:	4501                	li	a0,0
}
    80003e3a:	70e2                	ld	ra,56(sp)
    80003e3c:	7442                	ld	s0,48(sp)
    80003e3e:	74a2                	ld	s1,40(sp)
    80003e40:	7902                	ld	s2,32(sp)
    80003e42:	69e2                	ld	s3,24(sp)
    80003e44:	6a42                	ld	s4,16(sp)
    80003e46:	6121                	addi	sp,sp,64
    80003e48:	8082                	ret

0000000080003e4a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e4a:	711d                	addi	sp,sp,-96
    80003e4c:	ec86                	sd	ra,88(sp)
    80003e4e:	e8a2                	sd	s0,80(sp)
    80003e50:	e4a6                	sd	s1,72(sp)
    80003e52:	e0ca                	sd	s2,64(sp)
    80003e54:	fc4e                	sd	s3,56(sp)
    80003e56:	f852                	sd	s4,48(sp)
    80003e58:	f456                	sd	s5,40(sp)
    80003e5a:	f05a                	sd	s6,32(sp)
    80003e5c:	ec5e                	sd	s7,24(sp)
    80003e5e:	e862                	sd	s8,16(sp)
    80003e60:	e466                	sd	s9,8(sp)
    80003e62:	1080                	addi	s0,sp,96
    80003e64:	84aa                	mv	s1,a0
    80003e66:	8aae                	mv	s5,a1
    80003e68:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e6a:	00054703          	lbu	a4,0(a0)
    80003e6e:	02f00793          	li	a5,47
    80003e72:	02f70363          	beq	a4,a5,80003e98 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e76:	ffffe097          	auipc	ra,0xffffe
    80003e7a:	b46080e7          	jalr	-1210(ra) # 800019bc <myproc>
    80003e7e:	15053503          	ld	a0,336(a0)
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	9f6080e7          	jalr	-1546(ra) # 80003878 <idup>
    80003e8a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e8c:	02f00913          	li	s2,47
  len = path - s;
    80003e90:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003e92:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e94:	4b85                	li	s7,1
    80003e96:	a865                	j	80003f4e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e98:	4585                	li	a1,1
    80003e9a:	4505                	li	a0,1
    80003e9c:	fffff097          	auipc	ra,0xfffff
    80003ea0:	6e2080e7          	jalr	1762(ra) # 8000357e <iget>
    80003ea4:	89aa                	mv	s3,a0
    80003ea6:	b7dd                	j	80003e8c <namex+0x42>
      iunlockput(ip);
    80003ea8:	854e                	mv	a0,s3
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	c6e080e7          	jalr	-914(ra) # 80003b18 <iunlockput>
      return 0;
    80003eb2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003eb4:	854e                	mv	a0,s3
    80003eb6:	60e6                	ld	ra,88(sp)
    80003eb8:	6446                	ld	s0,80(sp)
    80003eba:	64a6                	ld	s1,72(sp)
    80003ebc:	6906                	ld	s2,64(sp)
    80003ebe:	79e2                	ld	s3,56(sp)
    80003ec0:	7a42                	ld	s4,48(sp)
    80003ec2:	7aa2                	ld	s5,40(sp)
    80003ec4:	7b02                	ld	s6,32(sp)
    80003ec6:	6be2                	ld	s7,24(sp)
    80003ec8:	6c42                	ld	s8,16(sp)
    80003eca:	6ca2                	ld	s9,8(sp)
    80003ecc:	6125                	addi	sp,sp,96
    80003ece:	8082                	ret
      iunlock(ip);
    80003ed0:	854e                	mv	a0,s3
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	aa6080e7          	jalr	-1370(ra) # 80003978 <iunlock>
      return ip;
    80003eda:	bfe9                	j	80003eb4 <namex+0x6a>
      iunlockput(ip);
    80003edc:	854e                	mv	a0,s3
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	c3a080e7          	jalr	-966(ra) # 80003b18 <iunlockput>
      return 0;
    80003ee6:	89e6                	mv	s3,s9
    80003ee8:	b7f1                	j	80003eb4 <namex+0x6a>
  len = path - s;
    80003eea:	40b48633          	sub	a2,s1,a1
    80003eee:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ef2:	099c5463          	bge	s8,s9,80003f7a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003ef6:	4639                	li	a2,14
    80003ef8:	8552                	mv	a0,s4
    80003efa:	ffffd097          	auipc	ra,0xffffd
    80003efe:	e34080e7          	jalr	-460(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003f02:	0004c783          	lbu	a5,0(s1)
    80003f06:	01279763          	bne	a5,s2,80003f14 <namex+0xca>
    path++;
    80003f0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f0c:	0004c783          	lbu	a5,0(s1)
    80003f10:	ff278de3          	beq	a5,s2,80003f0a <namex+0xc0>
    ilock(ip);
    80003f14:	854e                	mv	a0,s3
    80003f16:	00000097          	auipc	ra,0x0
    80003f1a:	9a0080e7          	jalr	-1632(ra) # 800038b6 <ilock>
    if(ip->type != T_DIR){
    80003f1e:	04499783          	lh	a5,68(s3)
    80003f22:	f97793e3          	bne	a5,s7,80003ea8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f26:	000a8563          	beqz	s5,80003f30 <namex+0xe6>
    80003f2a:	0004c783          	lbu	a5,0(s1)
    80003f2e:	d3cd                	beqz	a5,80003ed0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f30:	865a                	mv	a2,s6
    80003f32:	85d2                	mv	a1,s4
    80003f34:	854e                	mv	a0,s3
    80003f36:	00000097          	auipc	ra,0x0
    80003f3a:	e64080e7          	jalr	-412(ra) # 80003d9a <dirlookup>
    80003f3e:	8caa                	mv	s9,a0
    80003f40:	dd51                	beqz	a0,80003edc <namex+0x92>
    iunlockput(ip);
    80003f42:	854e                	mv	a0,s3
    80003f44:	00000097          	auipc	ra,0x0
    80003f48:	bd4080e7          	jalr	-1068(ra) # 80003b18 <iunlockput>
    ip = next;
    80003f4c:	89e6                	mv	s3,s9
  while(*path == '/')
    80003f4e:	0004c783          	lbu	a5,0(s1)
    80003f52:	05279763          	bne	a5,s2,80003fa0 <namex+0x156>
    path++;
    80003f56:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f58:	0004c783          	lbu	a5,0(s1)
    80003f5c:	ff278de3          	beq	a5,s2,80003f56 <namex+0x10c>
  if(*path == 0)
    80003f60:	c79d                	beqz	a5,80003f8e <namex+0x144>
    path++;
    80003f62:	85a6                	mv	a1,s1
  len = path - s;
    80003f64:	8cda                	mv	s9,s6
    80003f66:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003f68:	01278963          	beq	a5,s2,80003f7a <namex+0x130>
    80003f6c:	dfbd                	beqz	a5,80003eea <namex+0xa0>
    path++;
    80003f6e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f70:	0004c783          	lbu	a5,0(s1)
    80003f74:	ff279ce3          	bne	a5,s2,80003f6c <namex+0x122>
    80003f78:	bf8d                	j	80003eea <namex+0xa0>
    memmove(name, s, len);
    80003f7a:	2601                	sext.w	a2,a2
    80003f7c:	8552                	mv	a0,s4
    80003f7e:	ffffd097          	auipc	ra,0xffffd
    80003f82:	db0080e7          	jalr	-592(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003f86:	9cd2                	add	s9,s9,s4
    80003f88:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f8c:	bf9d                	j	80003f02 <namex+0xb8>
  if(nameiparent){
    80003f8e:	f20a83e3          	beqz	s5,80003eb4 <namex+0x6a>
    iput(ip);
    80003f92:	854e                	mv	a0,s3
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	adc080e7          	jalr	-1316(ra) # 80003a70 <iput>
    return 0;
    80003f9c:	4981                	li	s3,0
    80003f9e:	bf19                	j	80003eb4 <namex+0x6a>
  if(*path == 0)
    80003fa0:	d7fd                	beqz	a5,80003f8e <namex+0x144>
  while(*path != '/' && *path != 0)
    80003fa2:	0004c783          	lbu	a5,0(s1)
    80003fa6:	85a6                	mv	a1,s1
    80003fa8:	b7d1                	j	80003f6c <namex+0x122>

0000000080003faa <dirlink>:
{
    80003faa:	7139                	addi	sp,sp,-64
    80003fac:	fc06                	sd	ra,56(sp)
    80003fae:	f822                	sd	s0,48(sp)
    80003fb0:	f426                	sd	s1,40(sp)
    80003fb2:	f04a                	sd	s2,32(sp)
    80003fb4:	ec4e                	sd	s3,24(sp)
    80003fb6:	e852                	sd	s4,16(sp)
    80003fb8:	0080                	addi	s0,sp,64
    80003fba:	892a                	mv	s2,a0
    80003fbc:	8a2e                	mv	s4,a1
    80003fbe:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fc0:	4601                	li	a2,0
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	dd8080e7          	jalr	-552(ra) # 80003d9a <dirlookup>
    80003fca:	e93d                	bnez	a0,80004040 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fcc:	04c92483          	lw	s1,76(s2)
    80003fd0:	c49d                	beqz	s1,80003ffe <dirlink+0x54>
    80003fd2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fd4:	4741                	li	a4,16
    80003fd6:	86a6                	mv	a3,s1
    80003fd8:	fc040613          	addi	a2,s0,-64
    80003fdc:	4581                	li	a1,0
    80003fde:	854a                	mv	a0,s2
    80003fe0:	00000097          	auipc	ra,0x0
    80003fe4:	b8a080e7          	jalr	-1142(ra) # 80003b6a <readi>
    80003fe8:	47c1                	li	a5,16
    80003fea:	06f51163          	bne	a0,a5,8000404c <dirlink+0xa2>
    if(de.inum == 0)
    80003fee:	fc045783          	lhu	a5,-64(s0)
    80003ff2:	c791                	beqz	a5,80003ffe <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ff4:	24c1                	addiw	s1,s1,16
    80003ff6:	04c92783          	lw	a5,76(s2)
    80003ffa:	fcf4ede3          	bltu	s1,a5,80003fd4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ffe:	4639                	li	a2,14
    80004000:	85d2                	mv	a1,s4
    80004002:	fc240513          	addi	a0,s0,-62
    80004006:	ffffd097          	auipc	ra,0xffffd
    8000400a:	dd8080e7          	jalr	-552(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000400e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004012:	4741                	li	a4,16
    80004014:	86a6                	mv	a3,s1
    80004016:	fc040613          	addi	a2,s0,-64
    8000401a:	4581                	li	a1,0
    8000401c:	854a                	mv	a0,s2
    8000401e:	00000097          	auipc	ra,0x0
    80004022:	c44080e7          	jalr	-956(ra) # 80003c62 <writei>
    80004026:	1541                	addi	a0,a0,-16
    80004028:	00a03533          	snez	a0,a0
    8000402c:	40a00533          	neg	a0,a0
}
    80004030:	70e2                	ld	ra,56(sp)
    80004032:	7442                	ld	s0,48(sp)
    80004034:	74a2                	ld	s1,40(sp)
    80004036:	7902                	ld	s2,32(sp)
    80004038:	69e2                	ld	s3,24(sp)
    8000403a:	6a42                	ld	s4,16(sp)
    8000403c:	6121                	addi	sp,sp,64
    8000403e:	8082                	ret
    iput(ip);
    80004040:	00000097          	auipc	ra,0x0
    80004044:	a30080e7          	jalr	-1488(ra) # 80003a70 <iput>
    return -1;
    80004048:	557d                	li	a0,-1
    8000404a:	b7dd                	j	80004030 <dirlink+0x86>
      panic("dirlink read");
    8000404c:	00004517          	auipc	a0,0x4
    80004050:	5fc50513          	addi	a0,a0,1532 # 80008648 <syscalls+0x1d0>
    80004054:	ffffc097          	auipc	ra,0xffffc
    80004058:	4ea080e7          	jalr	1258(ra) # 8000053e <panic>

000000008000405c <namei>:

struct inode*
namei(char *path)
{
    8000405c:	1101                	addi	sp,sp,-32
    8000405e:	ec06                	sd	ra,24(sp)
    80004060:	e822                	sd	s0,16(sp)
    80004062:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004064:	fe040613          	addi	a2,s0,-32
    80004068:	4581                	li	a1,0
    8000406a:	00000097          	auipc	ra,0x0
    8000406e:	de0080e7          	jalr	-544(ra) # 80003e4a <namex>
}
    80004072:	60e2                	ld	ra,24(sp)
    80004074:	6442                	ld	s0,16(sp)
    80004076:	6105                	addi	sp,sp,32
    80004078:	8082                	ret

000000008000407a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000407a:	1141                	addi	sp,sp,-16
    8000407c:	e406                	sd	ra,8(sp)
    8000407e:	e022                	sd	s0,0(sp)
    80004080:	0800                	addi	s0,sp,16
    80004082:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004084:	4585                	li	a1,1
    80004086:	00000097          	auipc	ra,0x0
    8000408a:	dc4080e7          	jalr	-572(ra) # 80003e4a <namex>
}
    8000408e:	60a2                	ld	ra,8(sp)
    80004090:	6402                	ld	s0,0(sp)
    80004092:	0141                	addi	sp,sp,16
    80004094:	8082                	ret

0000000080004096 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004096:	1101                	addi	sp,sp,-32
    80004098:	ec06                	sd	ra,24(sp)
    8000409a:	e822                	sd	s0,16(sp)
    8000409c:	e426                	sd	s1,8(sp)
    8000409e:	e04a                	sd	s2,0(sp)
    800040a0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040a2:	0001d917          	auipc	s2,0x1d
    800040a6:	e8e90913          	addi	s2,s2,-370 # 80020f30 <log>
    800040aa:	01892583          	lw	a1,24(s2)
    800040ae:	02892503          	lw	a0,40(s2)
    800040b2:	fffff097          	auipc	ra,0xfffff
    800040b6:	fea080e7          	jalr	-22(ra) # 8000309c <bread>
    800040ba:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040bc:	02c92683          	lw	a3,44(s2)
    800040c0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040c2:	02d05763          	blez	a3,800040f0 <write_head+0x5a>
    800040c6:	0001d797          	auipc	a5,0x1d
    800040ca:	e9a78793          	addi	a5,a5,-358 # 80020f60 <log+0x30>
    800040ce:	05c50713          	addi	a4,a0,92
    800040d2:	36fd                	addiw	a3,a3,-1
    800040d4:	1682                	slli	a3,a3,0x20
    800040d6:	9281                	srli	a3,a3,0x20
    800040d8:	068a                	slli	a3,a3,0x2
    800040da:	0001d617          	auipc	a2,0x1d
    800040de:	e8a60613          	addi	a2,a2,-374 # 80020f64 <log+0x34>
    800040e2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040e4:	4390                	lw	a2,0(a5)
    800040e6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040e8:	0791                	addi	a5,a5,4
    800040ea:	0711                	addi	a4,a4,4
    800040ec:	fed79ce3          	bne	a5,a3,800040e4 <write_head+0x4e>
  }
  bwrite(buf);
    800040f0:	8526                	mv	a0,s1
    800040f2:	fffff097          	auipc	ra,0xfffff
    800040f6:	09c080e7          	jalr	156(ra) # 8000318e <bwrite>
  brelse(buf);
    800040fa:	8526                	mv	a0,s1
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	0d0080e7          	jalr	208(ra) # 800031cc <brelse>
}
    80004104:	60e2                	ld	ra,24(sp)
    80004106:	6442                	ld	s0,16(sp)
    80004108:	64a2                	ld	s1,8(sp)
    8000410a:	6902                	ld	s2,0(sp)
    8000410c:	6105                	addi	sp,sp,32
    8000410e:	8082                	ret

0000000080004110 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004110:	0001d797          	auipc	a5,0x1d
    80004114:	e4c7a783          	lw	a5,-436(a5) # 80020f5c <log+0x2c>
    80004118:	0af05d63          	blez	a5,800041d2 <install_trans+0xc2>
{
    8000411c:	7139                	addi	sp,sp,-64
    8000411e:	fc06                	sd	ra,56(sp)
    80004120:	f822                	sd	s0,48(sp)
    80004122:	f426                	sd	s1,40(sp)
    80004124:	f04a                	sd	s2,32(sp)
    80004126:	ec4e                	sd	s3,24(sp)
    80004128:	e852                	sd	s4,16(sp)
    8000412a:	e456                	sd	s5,8(sp)
    8000412c:	e05a                	sd	s6,0(sp)
    8000412e:	0080                	addi	s0,sp,64
    80004130:	8b2a                	mv	s6,a0
    80004132:	0001da97          	auipc	s5,0x1d
    80004136:	e2ea8a93          	addi	s5,s5,-466 # 80020f60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000413a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000413c:	0001d997          	auipc	s3,0x1d
    80004140:	df498993          	addi	s3,s3,-524 # 80020f30 <log>
    80004144:	a00d                	j	80004166 <install_trans+0x56>
    brelse(lbuf);
    80004146:	854a                	mv	a0,s2
    80004148:	fffff097          	auipc	ra,0xfffff
    8000414c:	084080e7          	jalr	132(ra) # 800031cc <brelse>
    brelse(dbuf);
    80004150:	8526                	mv	a0,s1
    80004152:	fffff097          	auipc	ra,0xfffff
    80004156:	07a080e7          	jalr	122(ra) # 800031cc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000415a:	2a05                	addiw	s4,s4,1
    8000415c:	0a91                	addi	s5,s5,4
    8000415e:	02c9a783          	lw	a5,44(s3)
    80004162:	04fa5e63          	bge	s4,a5,800041be <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004166:	0189a583          	lw	a1,24(s3)
    8000416a:	014585bb          	addw	a1,a1,s4
    8000416e:	2585                	addiw	a1,a1,1
    80004170:	0289a503          	lw	a0,40(s3)
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	f28080e7          	jalr	-216(ra) # 8000309c <bread>
    8000417c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000417e:	000aa583          	lw	a1,0(s5)
    80004182:	0289a503          	lw	a0,40(s3)
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	f16080e7          	jalr	-234(ra) # 8000309c <bread>
    8000418e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004190:	40000613          	li	a2,1024
    80004194:	05890593          	addi	a1,s2,88
    80004198:	05850513          	addi	a0,a0,88
    8000419c:	ffffd097          	auipc	ra,0xffffd
    800041a0:	b92080e7          	jalr	-1134(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800041a4:	8526                	mv	a0,s1
    800041a6:	fffff097          	auipc	ra,0xfffff
    800041aa:	fe8080e7          	jalr	-24(ra) # 8000318e <bwrite>
    if(recovering == 0)
    800041ae:	f80b1ce3          	bnez	s6,80004146 <install_trans+0x36>
      bunpin(dbuf);
    800041b2:	8526                	mv	a0,s1
    800041b4:	fffff097          	auipc	ra,0xfffff
    800041b8:	0f2080e7          	jalr	242(ra) # 800032a6 <bunpin>
    800041bc:	b769                	j	80004146 <install_trans+0x36>
}
    800041be:	70e2                	ld	ra,56(sp)
    800041c0:	7442                	ld	s0,48(sp)
    800041c2:	74a2                	ld	s1,40(sp)
    800041c4:	7902                	ld	s2,32(sp)
    800041c6:	69e2                	ld	s3,24(sp)
    800041c8:	6a42                	ld	s4,16(sp)
    800041ca:	6aa2                	ld	s5,8(sp)
    800041cc:	6b02                	ld	s6,0(sp)
    800041ce:	6121                	addi	sp,sp,64
    800041d0:	8082                	ret
    800041d2:	8082                	ret

00000000800041d4 <initlog>:
{
    800041d4:	7179                	addi	sp,sp,-48
    800041d6:	f406                	sd	ra,40(sp)
    800041d8:	f022                	sd	s0,32(sp)
    800041da:	ec26                	sd	s1,24(sp)
    800041dc:	e84a                	sd	s2,16(sp)
    800041de:	e44e                	sd	s3,8(sp)
    800041e0:	1800                	addi	s0,sp,48
    800041e2:	892a                	mv	s2,a0
    800041e4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041e6:	0001d497          	auipc	s1,0x1d
    800041ea:	d4a48493          	addi	s1,s1,-694 # 80020f30 <log>
    800041ee:	00004597          	auipc	a1,0x4
    800041f2:	46a58593          	addi	a1,a1,1130 # 80008658 <syscalls+0x1e0>
    800041f6:	8526                	mv	a0,s1
    800041f8:	ffffd097          	auipc	ra,0xffffd
    800041fc:	94e080e7          	jalr	-1714(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004200:	0149a583          	lw	a1,20(s3)
    80004204:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004206:	0109a783          	lw	a5,16(s3)
    8000420a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000420c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004210:	854a                	mv	a0,s2
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	e8a080e7          	jalr	-374(ra) # 8000309c <bread>
  log.lh.n = lh->n;
    8000421a:	4d34                	lw	a3,88(a0)
    8000421c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000421e:	02d05563          	blez	a3,80004248 <initlog+0x74>
    80004222:	05c50793          	addi	a5,a0,92
    80004226:	0001d717          	auipc	a4,0x1d
    8000422a:	d3a70713          	addi	a4,a4,-710 # 80020f60 <log+0x30>
    8000422e:	36fd                	addiw	a3,a3,-1
    80004230:	1682                	slli	a3,a3,0x20
    80004232:	9281                	srli	a3,a3,0x20
    80004234:	068a                	slli	a3,a3,0x2
    80004236:	06050613          	addi	a2,a0,96
    8000423a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000423c:	4390                	lw	a2,0(a5)
    8000423e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004240:	0791                	addi	a5,a5,4
    80004242:	0711                	addi	a4,a4,4
    80004244:	fed79ce3          	bne	a5,a3,8000423c <initlog+0x68>
  brelse(buf);
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	f84080e7          	jalr	-124(ra) # 800031cc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004250:	4505                	li	a0,1
    80004252:	00000097          	auipc	ra,0x0
    80004256:	ebe080e7          	jalr	-322(ra) # 80004110 <install_trans>
  log.lh.n = 0;
    8000425a:	0001d797          	auipc	a5,0x1d
    8000425e:	d007a123          	sw	zero,-766(a5) # 80020f5c <log+0x2c>
  write_head(); // clear the log
    80004262:	00000097          	auipc	ra,0x0
    80004266:	e34080e7          	jalr	-460(ra) # 80004096 <write_head>
}
    8000426a:	70a2                	ld	ra,40(sp)
    8000426c:	7402                	ld	s0,32(sp)
    8000426e:	64e2                	ld	s1,24(sp)
    80004270:	6942                	ld	s2,16(sp)
    80004272:	69a2                	ld	s3,8(sp)
    80004274:	6145                	addi	sp,sp,48
    80004276:	8082                	ret

0000000080004278 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004278:	1101                	addi	sp,sp,-32
    8000427a:	ec06                	sd	ra,24(sp)
    8000427c:	e822                	sd	s0,16(sp)
    8000427e:	e426                	sd	s1,8(sp)
    80004280:	e04a                	sd	s2,0(sp)
    80004282:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004284:	0001d517          	auipc	a0,0x1d
    80004288:	cac50513          	addi	a0,a0,-852 # 80020f30 <log>
    8000428c:	ffffd097          	auipc	ra,0xffffd
    80004290:	94a080e7          	jalr	-1718(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004294:	0001d497          	auipc	s1,0x1d
    80004298:	c9c48493          	addi	s1,s1,-868 # 80020f30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000429c:	4979                	li	s2,30
    8000429e:	a039                	j	800042ac <begin_op+0x34>
      sleep(&log, &log.lock);
    800042a0:	85a6                	mv	a1,s1
    800042a2:	8526                	mv	a0,s1
    800042a4:	ffffe097          	auipc	ra,0xffffe
    800042a8:	e32080e7          	jalr	-462(ra) # 800020d6 <sleep>
    if(log.committing){
    800042ac:	50dc                	lw	a5,36(s1)
    800042ae:	fbed                	bnez	a5,800042a0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042b0:	509c                	lw	a5,32(s1)
    800042b2:	0017871b          	addiw	a4,a5,1
    800042b6:	0007069b          	sext.w	a3,a4
    800042ba:	0027179b          	slliw	a5,a4,0x2
    800042be:	9fb9                	addw	a5,a5,a4
    800042c0:	0017979b          	slliw	a5,a5,0x1
    800042c4:	54d8                	lw	a4,44(s1)
    800042c6:	9fb9                	addw	a5,a5,a4
    800042c8:	00f95963          	bge	s2,a5,800042da <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042cc:	85a6                	mv	a1,s1
    800042ce:	8526                	mv	a0,s1
    800042d0:	ffffe097          	auipc	ra,0xffffe
    800042d4:	e06080e7          	jalr	-506(ra) # 800020d6 <sleep>
    800042d8:	bfd1                	j	800042ac <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042da:	0001d517          	auipc	a0,0x1d
    800042de:	c5650513          	addi	a0,a0,-938 # 80020f30 <log>
    800042e2:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042e4:	ffffd097          	auipc	ra,0xffffd
    800042e8:	9a6080e7          	jalr	-1626(ra) # 80000c8a <release>
      break;
    }
  }
}
    800042ec:	60e2                	ld	ra,24(sp)
    800042ee:	6442                	ld	s0,16(sp)
    800042f0:	64a2                	ld	s1,8(sp)
    800042f2:	6902                	ld	s2,0(sp)
    800042f4:	6105                	addi	sp,sp,32
    800042f6:	8082                	ret

00000000800042f8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042f8:	7139                	addi	sp,sp,-64
    800042fa:	fc06                	sd	ra,56(sp)
    800042fc:	f822                	sd	s0,48(sp)
    800042fe:	f426                	sd	s1,40(sp)
    80004300:	f04a                	sd	s2,32(sp)
    80004302:	ec4e                	sd	s3,24(sp)
    80004304:	e852                	sd	s4,16(sp)
    80004306:	e456                	sd	s5,8(sp)
    80004308:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000430a:	0001d497          	auipc	s1,0x1d
    8000430e:	c2648493          	addi	s1,s1,-986 # 80020f30 <log>
    80004312:	8526                	mv	a0,s1
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	8c2080e7          	jalr	-1854(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000431c:	509c                	lw	a5,32(s1)
    8000431e:	37fd                	addiw	a5,a5,-1
    80004320:	0007891b          	sext.w	s2,a5
    80004324:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004326:	50dc                	lw	a5,36(s1)
    80004328:	e7b9                	bnez	a5,80004376 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000432a:	04091e63          	bnez	s2,80004386 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000432e:	0001d497          	auipc	s1,0x1d
    80004332:	c0248493          	addi	s1,s1,-1022 # 80020f30 <log>
    80004336:	4785                	li	a5,1
    80004338:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000433a:	8526                	mv	a0,s1
    8000433c:	ffffd097          	auipc	ra,0xffffd
    80004340:	94e080e7          	jalr	-1714(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004344:	54dc                	lw	a5,44(s1)
    80004346:	06f04763          	bgtz	a5,800043b4 <end_op+0xbc>
    acquire(&log.lock);
    8000434a:	0001d497          	auipc	s1,0x1d
    8000434e:	be648493          	addi	s1,s1,-1050 # 80020f30 <log>
    80004352:	8526                	mv	a0,s1
    80004354:	ffffd097          	auipc	ra,0xffffd
    80004358:	882080e7          	jalr	-1918(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000435c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004360:	8526                	mv	a0,s1
    80004362:	ffffe097          	auipc	ra,0xffffe
    80004366:	dd8080e7          	jalr	-552(ra) # 8000213a <wakeup>
    release(&log.lock);
    8000436a:	8526                	mv	a0,s1
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	91e080e7          	jalr	-1762(ra) # 80000c8a <release>
}
    80004374:	a03d                	j	800043a2 <end_op+0xaa>
    panic("log.committing");
    80004376:	00004517          	auipc	a0,0x4
    8000437a:	2ea50513          	addi	a0,a0,746 # 80008660 <syscalls+0x1e8>
    8000437e:	ffffc097          	auipc	ra,0xffffc
    80004382:	1c0080e7          	jalr	448(ra) # 8000053e <panic>
    wakeup(&log);
    80004386:	0001d497          	auipc	s1,0x1d
    8000438a:	baa48493          	addi	s1,s1,-1110 # 80020f30 <log>
    8000438e:	8526                	mv	a0,s1
    80004390:	ffffe097          	auipc	ra,0xffffe
    80004394:	daa080e7          	jalr	-598(ra) # 8000213a <wakeup>
  release(&log.lock);
    80004398:	8526                	mv	a0,s1
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	8f0080e7          	jalr	-1808(ra) # 80000c8a <release>
}
    800043a2:	70e2                	ld	ra,56(sp)
    800043a4:	7442                	ld	s0,48(sp)
    800043a6:	74a2                	ld	s1,40(sp)
    800043a8:	7902                	ld	s2,32(sp)
    800043aa:	69e2                	ld	s3,24(sp)
    800043ac:	6a42                	ld	s4,16(sp)
    800043ae:	6aa2                	ld	s5,8(sp)
    800043b0:	6121                	addi	sp,sp,64
    800043b2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800043b4:	0001da97          	auipc	s5,0x1d
    800043b8:	baca8a93          	addi	s5,s5,-1108 # 80020f60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043bc:	0001da17          	auipc	s4,0x1d
    800043c0:	b74a0a13          	addi	s4,s4,-1164 # 80020f30 <log>
    800043c4:	018a2583          	lw	a1,24(s4)
    800043c8:	012585bb          	addw	a1,a1,s2
    800043cc:	2585                	addiw	a1,a1,1
    800043ce:	028a2503          	lw	a0,40(s4)
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	cca080e7          	jalr	-822(ra) # 8000309c <bread>
    800043da:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043dc:	000aa583          	lw	a1,0(s5)
    800043e0:	028a2503          	lw	a0,40(s4)
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	cb8080e7          	jalr	-840(ra) # 8000309c <bread>
    800043ec:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043ee:	40000613          	li	a2,1024
    800043f2:	05850593          	addi	a1,a0,88
    800043f6:	05848513          	addi	a0,s1,88
    800043fa:	ffffd097          	auipc	ra,0xffffd
    800043fe:	934080e7          	jalr	-1740(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004402:	8526                	mv	a0,s1
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	d8a080e7          	jalr	-630(ra) # 8000318e <bwrite>
    brelse(from);
    8000440c:	854e                	mv	a0,s3
    8000440e:	fffff097          	auipc	ra,0xfffff
    80004412:	dbe080e7          	jalr	-578(ra) # 800031cc <brelse>
    brelse(to);
    80004416:	8526                	mv	a0,s1
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	db4080e7          	jalr	-588(ra) # 800031cc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004420:	2905                	addiw	s2,s2,1
    80004422:	0a91                	addi	s5,s5,4
    80004424:	02ca2783          	lw	a5,44(s4)
    80004428:	f8f94ee3          	blt	s2,a5,800043c4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000442c:	00000097          	auipc	ra,0x0
    80004430:	c6a080e7          	jalr	-918(ra) # 80004096 <write_head>
    install_trans(0); // Now install writes to home locations
    80004434:	4501                	li	a0,0
    80004436:	00000097          	auipc	ra,0x0
    8000443a:	cda080e7          	jalr	-806(ra) # 80004110 <install_trans>
    log.lh.n = 0;
    8000443e:	0001d797          	auipc	a5,0x1d
    80004442:	b007af23          	sw	zero,-1250(a5) # 80020f5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	c50080e7          	jalr	-944(ra) # 80004096 <write_head>
    8000444e:	bdf5                	j	8000434a <end_op+0x52>

0000000080004450 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004450:	1101                	addi	sp,sp,-32
    80004452:	ec06                	sd	ra,24(sp)
    80004454:	e822                	sd	s0,16(sp)
    80004456:	e426                	sd	s1,8(sp)
    80004458:	e04a                	sd	s2,0(sp)
    8000445a:	1000                	addi	s0,sp,32
    8000445c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000445e:	0001d917          	auipc	s2,0x1d
    80004462:	ad290913          	addi	s2,s2,-1326 # 80020f30 <log>
    80004466:	854a                	mv	a0,s2
    80004468:	ffffc097          	auipc	ra,0xffffc
    8000446c:	76e080e7          	jalr	1902(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004470:	02c92603          	lw	a2,44(s2)
    80004474:	47f5                	li	a5,29
    80004476:	06c7c563          	blt	a5,a2,800044e0 <log_write+0x90>
    8000447a:	0001d797          	auipc	a5,0x1d
    8000447e:	ad27a783          	lw	a5,-1326(a5) # 80020f4c <log+0x1c>
    80004482:	37fd                	addiw	a5,a5,-1
    80004484:	04f65e63          	bge	a2,a5,800044e0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004488:	0001d797          	auipc	a5,0x1d
    8000448c:	ac87a783          	lw	a5,-1336(a5) # 80020f50 <log+0x20>
    80004490:	06f05063          	blez	a5,800044f0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004494:	4781                	li	a5,0
    80004496:	06c05563          	blez	a2,80004500 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000449a:	44cc                	lw	a1,12(s1)
    8000449c:	0001d717          	auipc	a4,0x1d
    800044a0:	ac470713          	addi	a4,a4,-1340 # 80020f60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044a4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044a6:	4314                	lw	a3,0(a4)
    800044a8:	04b68c63          	beq	a3,a1,80004500 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800044ac:	2785                	addiw	a5,a5,1
    800044ae:	0711                	addi	a4,a4,4
    800044b0:	fef61be3          	bne	a2,a5,800044a6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044b4:	0621                	addi	a2,a2,8
    800044b6:	060a                	slli	a2,a2,0x2
    800044b8:	0001d797          	auipc	a5,0x1d
    800044bc:	a7878793          	addi	a5,a5,-1416 # 80020f30 <log>
    800044c0:	963e                	add	a2,a2,a5
    800044c2:	44dc                	lw	a5,12(s1)
    800044c4:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044c6:	8526                	mv	a0,s1
    800044c8:	fffff097          	auipc	ra,0xfffff
    800044cc:	da2080e7          	jalr	-606(ra) # 8000326a <bpin>
    log.lh.n++;
    800044d0:	0001d717          	auipc	a4,0x1d
    800044d4:	a6070713          	addi	a4,a4,-1440 # 80020f30 <log>
    800044d8:	575c                	lw	a5,44(a4)
    800044da:	2785                	addiw	a5,a5,1
    800044dc:	d75c                	sw	a5,44(a4)
    800044de:	a835                	j	8000451a <log_write+0xca>
    panic("too big a transaction");
    800044e0:	00004517          	auipc	a0,0x4
    800044e4:	19050513          	addi	a0,a0,400 # 80008670 <syscalls+0x1f8>
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	056080e7          	jalr	86(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800044f0:	00004517          	auipc	a0,0x4
    800044f4:	19850513          	addi	a0,a0,408 # 80008688 <syscalls+0x210>
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	046080e7          	jalr	70(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004500:	00878713          	addi	a4,a5,8
    80004504:	00271693          	slli	a3,a4,0x2
    80004508:	0001d717          	auipc	a4,0x1d
    8000450c:	a2870713          	addi	a4,a4,-1496 # 80020f30 <log>
    80004510:	9736                	add	a4,a4,a3
    80004512:	44d4                	lw	a3,12(s1)
    80004514:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004516:	faf608e3          	beq	a2,a5,800044c6 <log_write+0x76>
  }
  release(&log.lock);
    8000451a:	0001d517          	auipc	a0,0x1d
    8000451e:	a1650513          	addi	a0,a0,-1514 # 80020f30 <log>
    80004522:	ffffc097          	auipc	ra,0xffffc
    80004526:	768080e7          	jalr	1896(ra) # 80000c8a <release>
}
    8000452a:	60e2                	ld	ra,24(sp)
    8000452c:	6442                	ld	s0,16(sp)
    8000452e:	64a2                	ld	s1,8(sp)
    80004530:	6902                	ld	s2,0(sp)
    80004532:	6105                	addi	sp,sp,32
    80004534:	8082                	ret

0000000080004536 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004536:	1101                	addi	sp,sp,-32
    80004538:	ec06                	sd	ra,24(sp)
    8000453a:	e822                	sd	s0,16(sp)
    8000453c:	e426                	sd	s1,8(sp)
    8000453e:	e04a                	sd	s2,0(sp)
    80004540:	1000                	addi	s0,sp,32
    80004542:	84aa                	mv	s1,a0
    80004544:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004546:	00004597          	auipc	a1,0x4
    8000454a:	16258593          	addi	a1,a1,354 # 800086a8 <syscalls+0x230>
    8000454e:	0521                	addi	a0,a0,8
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	5f6080e7          	jalr	1526(ra) # 80000b46 <initlock>
  lk->name = name;
    80004558:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000455c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004560:	0204a423          	sw	zero,40(s1)
}
    80004564:	60e2                	ld	ra,24(sp)
    80004566:	6442                	ld	s0,16(sp)
    80004568:	64a2                	ld	s1,8(sp)
    8000456a:	6902                	ld	s2,0(sp)
    8000456c:	6105                	addi	sp,sp,32
    8000456e:	8082                	ret

0000000080004570 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004570:	1101                	addi	sp,sp,-32
    80004572:	ec06                	sd	ra,24(sp)
    80004574:	e822                	sd	s0,16(sp)
    80004576:	e426                	sd	s1,8(sp)
    80004578:	e04a                	sd	s2,0(sp)
    8000457a:	1000                	addi	s0,sp,32
    8000457c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000457e:	00850913          	addi	s2,a0,8
    80004582:	854a                	mv	a0,s2
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	652080e7          	jalr	1618(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000458c:	409c                	lw	a5,0(s1)
    8000458e:	cb89                	beqz	a5,800045a0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004590:	85ca                	mv	a1,s2
    80004592:	8526                	mv	a0,s1
    80004594:	ffffe097          	auipc	ra,0xffffe
    80004598:	b42080e7          	jalr	-1214(ra) # 800020d6 <sleep>
  while (lk->locked) {
    8000459c:	409c                	lw	a5,0(s1)
    8000459e:	fbed                	bnez	a5,80004590 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045a0:	4785                	li	a5,1
    800045a2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045a4:	ffffd097          	auipc	ra,0xffffd
    800045a8:	418080e7          	jalr	1048(ra) # 800019bc <myproc>
    800045ac:	591c                	lw	a5,48(a0)
    800045ae:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045b0:	854a                	mv	a0,s2
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	6d8080e7          	jalr	1752(ra) # 80000c8a <release>
}
    800045ba:	60e2                	ld	ra,24(sp)
    800045bc:	6442                	ld	s0,16(sp)
    800045be:	64a2                	ld	s1,8(sp)
    800045c0:	6902                	ld	s2,0(sp)
    800045c2:	6105                	addi	sp,sp,32
    800045c4:	8082                	ret

00000000800045c6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045c6:	1101                	addi	sp,sp,-32
    800045c8:	ec06                	sd	ra,24(sp)
    800045ca:	e822                	sd	s0,16(sp)
    800045cc:	e426                	sd	s1,8(sp)
    800045ce:	e04a                	sd	s2,0(sp)
    800045d0:	1000                	addi	s0,sp,32
    800045d2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045d4:	00850913          	addi	s2,a0,8
    800045d8:	854a                	mv	a0,s2
    800045da:	ffffc097          	auipc	ra,0xffffc
    800045de:	5fc080e7          	jalr	1532(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800045e2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045e6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045ea:	8526                	mv	a0,s1
    800045ec:	ffffe097          	auipc	ra,0xffffe
    800045f0:	b4e080e7          	jalr	-1202(ra) # 8000213a <wakeup>
  release(&lk->lk);
    800045f4:	854a                	mv	a0,s2
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	694080e7          	jalr	1684(ra) # 80000c8a <release>
}
    800045fe:	60e2                	ld	ra,24(sp)
    80004600:	6442                	ld	s0,16(sp)
    80004602:	64a2                	ld	s1,8(sp)
    80004604:	6902                	ld	s2,0(sp)
    80004606:	6105                	addi	sp,sp,32
    80004608:	8082                	ret

000000008000460a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000460a:	7179                	addi	sp,sp,-48
    8000460c:	f406                	sd	ra,40(sp)
    8000460e:	f022                	sd	s0,32(sp)
    80004610:	ec26                	sd	s1,24(sp)
    80004612:	e84a                	sd	s2,16(sp)
    80004614:	e44e                	sd	s3,8(sp)
    80004616:	1800                	addi	s0,sp,48
    80004618:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000461a:	00850913          	addi	s2,a0,8
    8000461e:	854a                	mv	a0,s2
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	5b6080e7          	jalr	1462(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004628:	409c                	lw	a5,0(s1)
    8000462a:	ef99                	bnez	a5,80004648 <holdingsleep+0x3e>
    8000462c:	4481                	li	s1,0
  release(&lk->lk);
    8000462e:	854a                	mv	a0,s2
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	65a080e7          	jalr	1626(ra) # 80000c8a <release>
  return r;
}
    80004638:	8526                	mv	a0,s1
    8000463a:	70a2                	ld	ra,40(sp)
    8000463c:	7402                	ld	s0,32(sp)
    8000463e:	64e2                	ld	s1,24(sp)
    80004640:	6942                	ld	s2,16(sp)
    80004642:	69a2                	ld	s3,8(sp)
    80004644:	6145                	addi	sp,sp,48
    80004646:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004648:	0284a983          	lw	s3,40(s1)
    8000464c:	ffffd097          	auipc	ra,0xffffd
    80004650:	370080e7          	jalr	880(ra) # 800019bc <myproc>
    80004654:	5904                	lw	s1,48(a0)
    80004656:	413484b3          	sub	s1,s1,s3
    8000465a:	0014b493          	seqz	s1,s1
    8000465e:	bfc1                	j	8000462e <holdingsleep+0x24>

0000000080004660 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004660:	1141                	addi	sp,sp,-16
    80004662:	e406                	sd	ra,8(sp)
    80004664:	e022                	sd	s0,0(sp)
    80004666:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004668:	00004597          	auipc	a1,0x4
    8000466c:	05058593          	addi	a1,a1,80 # 800086b8 <syscalls+0x240>
    80004670:	0001d517          	auipc	a0,0x1d
    80004674:	a0850513          	addi	a0,a0,-1528 # 80021078 <ftable>
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	4ce080e7          	jalr	1230(ra) # 80000b46 <initlock>
}
    80004680:	60a2                	ld	ra,8(sp)
    80004682:	6402                	ld	s0,0(sp)
    80004684:	0141                	addi	sp,sp,16
    80004686:	8082                	ret

0000000080004688 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004688:	1101                	addi	sp,sp,-32
    8000468a:	ec06                	sd	ra,24(sp)
    8000468c:	e822                	sd	s0,16(sp)
    8000468e:	e426                	sd	s1,8(sp)
    80004690:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004692:	0001d517          	auipc	a0,0x1d
    80004696:	9e650513          	addi	a0,a0,-1562 # 80021078 <ftable>
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	53c080e7          	jalr	1340(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046a2:	0001d497          	auipc	s1,0x1d
    800046a6:	9ee48493          	addi	s1,s1,-1554 # 80021090 <ftable+0x18>
    800046aa:	0001e717          	auipc	a4,0x1e
    800046ae:	98670713          	addi	a4,a4,-1658 # 80022030 <disk>
    if(f->ref == 0){
    800046b2:	40dc                	lw	a5,4(s1)
    800046b4:	cf99                	beqz	a5,800046d2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046b6:	02848493          	addi	s1,s1,40
    800046ba:	fee49ce3          	bne	s1,a4,800046b2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046be:	0001d517          	auipc	a0,0x1d
    800046c2:	9ba50513          	addi	a0,a0,-1606 # 80021078 <ftable>
    800046c6:	ffffc097          	auipc	ra,0xffffc
    800046ca:	5c4080e7          	jalr	1476(ra) # 80000c8a <release>
  return 0;
    800046ce:	4481                	li	s1,0
    800046d0:	a819                	j	800046e6 <filealloc+0x5e>
      f->ref = 1;
    800046d2:	4785                	li	a5,1
    800046d4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046d6:	0001d517          	auipc	a0,0x1d
    800046da:	9a250513          	addi	a0,a0,-1630 # 80021078 <ftable>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	5ac080e7          	jalr	1452(ra) # 80000c8a <release>
}
    800046e6:	8526                	mv	a0,s1
    800046e8:	60e2                	ld	ra,24(sp)
    800046ea:	6442                	ld	s0,16(sp)
    800046ec:	64a2                	ld	s1,8(sp)
    800046ee:	6105                	addi	sp,sp,32
    800046f0:	8082                	ret

00000000800046f2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046f2:	1101                	addi	sp,sp,-32
    800046f4:	ec06                	sd	ra,24(sp)
    800046f6:	e822                	sd	s0,16(sp)
    800046f8:	e426                	sd	s1,8(sp)
    800046fa:	1000                	addi	s0,sp,32
    800046fc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046fe:	0001d517          	auipc	a0,0x1d
    80004702:	97a50513          	addi	a0,a0,-1670 # 80021078 <ftable>
    80004706:	ffffc097          	auipc	ra,0xffffc
    8000470a:	4d0080e7          	jalr	1232(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000470e:	40dc                	lw	a5,4(s1)
    80004710:	02f05263          	blez	a5,80004734 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004714:	2785                	addiw	a5,a5,1
    80004716:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004718:	0001d517          	auipc	a0,0x1d
    8000471c:	96050513          	addi	a0,a0,-1696 # 80021078 <ftable>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	56a080e7          	jalr	1386(ra) # 80000c8a <release>
  return f;
}
    80004728:	8526                	mv	a0,s1
    8000472a:	60e2                	ld	ra,24(sp)
    8000472c:	6442                	ld	s0,16(sp)
    8000472e:	64a2                	ld	s1,8(sp)
    80004730:	6105                	addi	sp,sp,32
    80004732:	8082                	ret
    panic("filedup");
    80004734:	00004517          	auipc	a0,0x4
    80004738:	f8c50513          	addi	a0,a0,-116 # 800086c0 <syscalls+0x248>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	e02080e7          	jalr	-510(ra) # 8000053e <panic>

0000000080004744 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004744:	7139                	addi	sp,sp,-64
    80004746:	fc06                	sd	ra,56(sp)
    80004748:	f822                	sd	s0,48(sp)
    8000474a:	f426                	sd	s1,40(sp)
    8000474c:	f04a                	sd	s2,32(sp)
    8000474e:	ec4e                	sd	s3,24(sp)
    80004750:	e852                	sd	s4,16(sp)
    80004752:	e456                	sd	s5,8(sp)
    80004754:	0080                	addi	s0,sp,64
    80004756:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004758:	0001d517          	auipc	a0,0x1d
    8000475c:	92050513          	addi	a0,a0,-1760 # 80021078 <ftable>
    80004760:	ffffc097          	auipc	ra,0xffffc
    80004764:	476080e7          	jalr	1142(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004768:	40dc                	lw	a5,4(s1)
    8000476a:	06f05163          	blez	a5,800047cc <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000476e:	37fd                	addiw	a5,a5,-1
    80004770:	0007871b          	sext.w	a4,a5
    80004774:	c0dc                	sw	a5,4(s1)
    80004776:	06e04363          	bgtz	a4,800047dc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000477a:	0004a903          	lw	s2,0(s1)
    8000477e:	0094ca83          	lbu	s5,9(s1)
    80004782:	0104ba03          	ld	s4,16(s1)
    80004786:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000478a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000478e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004792:	0001d517          	auipc	a0,0x1d
    80004796:	8e650513          	addi	a0,a0,-1818 # 80021078 <ftable>
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	4f0080e7          	jalr	1264(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800047a2:	4785                	li	a5,1
    800047a4:	04f90d63          	beq	s2,a5,800047fe <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047a8:	3979                	addiw	s2,s2,-2
    800047aa:	4785                	li	a5,1
    800047ac:	0527e063          	bltu	a5,s2,800047ec <fileclose+0xa8>
    begin_op();
    800047b0:	00000097          	auipc	ra,0x0
    800047b4:	ac8080e7          	jalr	-1336(ra) # 80004278 <begin_op>
    iput(ff.ip);
    800047b8:	854e                	mv	a0,s3
    800047ba:	fffff097          	auipc	ra,0xfffff
    800047be:	2b6080e7          	jalr	694(ra) # 80003a70 <iput>
    end_op();
    800047c2:	00000097          	auipc	ra,0x0
    800047c6:	b36080e7          	jalr	-1226(ra) # 800042f8 <end_op>
    800047ca:	a00d                	j	800047ec <fileclose+0xa8>
    panic("fileclose");
    800047cc:	00004517          	auipc	a0,0x4
    800047d0:	efc50513          	addi	a0,a0,-260 # 800086c8 <syscalls+0x250>
    800047d4:	ffffc097          	auipc	ra,0xffffc
    800047d8:	d6a080e7          	jalr	-662(ra) # 8000053e <panic>
    release(&ftable.lock);
    800047dc:	0001d517          	auipc	a0,0x1d
    800047e0:	89c50513          	addi	a0,a0,-1892 # 80021078 <ftable>
    800047e4:	ffffc097          	auipc	ra,0xffffc
    800047e8:	4a6080e7          	jalr	1190(ra) # 80000c8a <release>
  }
}
    800047ec:	70e2                	ld	ra,56(sp)
    800047ee:	7442                	ld	s0,48(sp)
    800047f0:	74a2                	ld	s1,40(sp)
    800047f2:	7902                	ld	s2,32(sp)
    800047f4:	69e2                	ld	s3,24(sp)
    800047f6:	6a42                	ld	s4,16(sp)
    800047f8:	6aa2                	ld	s5,8(sp)
    800047fa:	6121                	addi	sp,sp,64
    800047fc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047fe:	85d6                	mv	a1,s5
    80004800:	8552                	mv	a0,s4
    80004802:	00000097          	auipc	ra,0x0
    80004806:	34c080e7          	jalr	844(ra) # 80004b4e <pipeclose>
    8000480a:	b7cd                	j	800047ec <fileclose+0xa8>

000000008000480c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000480c:	715d                	addi	sp,sp,-80
    8000480e:	e486                	sd	ra,72(sp)
    80004810:	e0a2                	sd	s0,64(sp)
    80004812:	fc26                	sd	s1,56(sp)
    80004814:	f84a                	sd	s2,48(sp)
    80004816:	f44e                	sd	s3,40(sp)
    80004818:	0880                	addi	s0,sp,80
    8000481a:	84aa                	mv	s1,a0
    8000481c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000481e:	ffffd097          	auipc	ra,0xffffd
    80004822:	19e080e7          	jalr	414(ra) # 800019bc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004826:	409c                	lw	a5,0(s1)
    80004828:	37f9                	addiw	a5,a5,-2
    8000482a:	4705                	li	a4,1
    8000482c:	04f76763          	bltu	a4,a5,8000487a <filestat+0x6e>
    80004830:	892a                	mv	s2,a0
    ilock(f->ip);
    80004832:	6c88                	ld	a0,24(s1)
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	082080e7          	jalr	130(ra) # 800038b6 <ilock>
    stati(f->ip, &st);
    8000483c:	fb840593          	addi	a1,s0,-72
    80004840:	6c88                	ld	a0,24(s1)
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	2fe080e7          	jalr	766(ra) # 80003b40 <stati>
    iunlock(f->ip);
    8000484a:	6c88                	ld	a0,24(s1)
    8000484c:	fffff097          	auipc	ra,0xfffff
    80004850:	12c080e7          	jalr	300(ra) # 80003978 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004854:	46e1                	li	a3,24
    80004856:	fb840613          	addi	a2,s0,-72
    8000485a:	85ce                	mv	a1,s3
    8000485c:	05093503          	ld	a0,80(s2)
    80004860:	ffffd097          	auipc	ra,0xffffd
    80004864:	e18080e7          	jalr	-488(ra) # 80001678 <copyout>
    80004868:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000486c:	60a6                	ld	ra,72(sp)
    8000486e:	6406                	ld	s0,64(sp)
    80004870:	74e2                	ld	s1,56(sp)
    80004872:	7942                	ld	s2,48(sp)
    80004874:	79a2                	ld	s3,40(sp)
    80004876:	6161                	addi	sp,sp,80
    80004878:	8082                	ret
  return -1;
    8000487a:	557d                	li	a0,-1
    8000487c:	bfc5                	j	8000486c <filestat+0x60>

000000008000487e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000487e:	7179                	addi	sp,sp,-48
    80004880:	f406                	sd	ra,40(sp)
    80004882:	f022                	sd	s0,32(sp)
    80004884:	ec26                	sd	s1,24(sp)
    80004886:	e84a                	sd	s2,16(sp)
    80004888:	e44e                	sd	s3,8(sp)
    8000488a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000488c:	00854783          	lbu	a5,8(a0)
    80004890:	c3d5                	beqz	a5,80004934 <fileread+0xb6>
    80004892:	84aa                	mv	s1,a0
    80004894:	89ae                	mv	s3,a1
    80004896:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004898:	411c                	lw	a5,0(a0)
    8000489a:	4705                	li	a4,1
    8000489c:	04e78963          	beq	a5,a4,800048ee <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048a0:	470d                	li	a4,3
    800048a2:	04e78d63          	beq	a5,a4,800048fc <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048a6:	4709                	li	a4,2
    800048a8:	06e79e63          	bne	a5,a4,80004924 <fileread+0xa6>
    ilock(f->ip);
    800048ac:	6d08                	ld	a0,24(a0)
    800048ae:	fffff097          	auipc	ra,0xfffff
    800048b2:	008080e7          	jalr	8(ra) # 800038b6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048b6:	874a                	mv	a4,s2
    800048b8:	5094                	lw	a3,32(s1)
    800048ba:	864e                	mv	a2,s3
    800048bc:	4585                	li	a1,1
    800048be:	6c88                	ld	a0,24(s1)
    800048c0:	fffff097          	auipc	ra,0xfffff
    800048c4:	2aa080e7          	jalr	682(ra) # 80003b6a <readi>
    800048c8:	892a                	mv	s2,a0
    800048ca:	00a05563          	blez	a0,800048d4 <fileread+0x56>
      f->off += r;
    800048ce:	509c                	lw	a5,32(s1)
    800048d0:	9fa9                	addw	a5,a5,a0
    800048d2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048d4:	6c88                	ld	a0,24(s1)
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	0a2080e7          	jalr	162(ra) # 80003978 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048de:	854a                	mv	a0,s2
    800048e0:	70a2                	ld	ra,40(sp)
    800048e2:	7402                	ld	s0,32(sp)
    800048e4:	64e2                	ld	s1,24(sp)
    800048e6:	6942                	ld	s2,16(sp)
    800048e8:	69a2                	ld	s3,8(sp)
    800048ea:	6145                	addi	sp,sp,48
    800048ec:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048ee:	6908                	ld	a0,16(a0)
    800048f0:	00000097          	auipc	ra,0x0
    800048f4:	3c6080e7          	jalr	966(ra) # 80004cb6 <piperead>
    800048f8:	892a                	mv	s2,a0
    800048fa:	b7d5                	j	800048de <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048fc:	02451783          	lh	a5,36(a0)
    80004900:	03079693          	slli	a3,a5,0x30
    80004904:	92c1                	srli	a3,a3,0x30
    80004906:	4725                	li	a4,9
    80004908:	02d76863          	bltu	a4,a3,80004938 <fileread+0xba>
    8000490c:	0792                	slli	a5,a5,0x4
    8000490e:	0001c717          	auipc	a4,0x1c
    80004912:	6ca70713          	addi	a4,a4,1738 # 80020fd8 <devsw>
    80004916:	97ba                	add	a5,a5,a4
    80004918:	639c                	ld	a5,0(a5)
    8000491a:	c38d                	beqz	a5,8000493c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000491c:	4505                	li	a0,1
    8000491e:	9782                	jalr	a5
    80004920:	892a                	mv	s2,a0
    80004922:	bf75                	j	800048de <fileread+0x60>
    panic("fileread");
    80004924:	00004517          	auipc	a0,0x4
    80004928:	db450513          	addi	a0,a0,-588 # 800086d8 <syscalls+0x260>
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	c12080e7          	jalr	-1006(ra) # 8000053e <panic>
    return -1;
    80004934:	597d                	li	s2,-1
    80004936:	b765                	j	800048de <fileread+0x60>
      return -1;
    80004938:	597d                	li	s2,-1
    8000493a:	b755                	j	800048de <fileread+0x60>
    8000493c:	597d                	li	s2,-1
    8000493e:	b745                	j	800048de <fileread+0x60>

0000000080004940 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004940:	715d                	addi	sp,sp,-80
    80004942:	e486                	sd	ra,72(sp)
    80004944:	e0a2                	sd	s0,64(sp)
    80004946:	fc26                	sd	s1,56(sp)
    80004948:	f84a                	sd	s2,48(sp)
    8000494a:	f44e                	sd	s3,40(sp)
    8000494c:	f052                	sd	s4,32(sp)
    8000494e:	ec56                	sd	s5,24(sp)
    80004950:	e85a                	sd	s6,16(sp)
    80004952:	e45e                	sd	s7,8(sp)
    80004954:	e062                	sd	s8,0(sp)
    80004956:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004958:	00954783          	lbu	a5,9(a0)
    8000495c:	10078663          	beqz	a5,80004a68 <filewrite+0x128>
    80004960:	892a                	mv	s2,a0
    80004962:	8aae                	mv	s5,a1
    80004964:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004966:	411c                	lw	a5,0(a0)
    80004968:	4705                	li	a4,1
    8000496a:	02e78263          	beq	a5,a4,8000498e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000496e:	470d                	li	a4,3
    80004970:	02e78663          	beq	a5,a4,8000499c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004974:	4709                	li	a4,2
    80004976:	0ee79163          	bne	a5,a4,80004a58 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000497a:	0ac05d63          	blez	a2,80004a34 <filewrite+0xf4>
    int i = 0;
    8000497e:	4981                	li	s3,0
    80004980:	6b05                	lui	s6,0x1
    80004982:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004986:	6b85                	lui	s7,0x1
    80004988:	c00b8b9b          	addiw	s7,s7,-1024
    8000498c:	a861                	j	80004a24 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000498e:	6908                	ld	a0,16(a0)
    80004990:	00000097          	auipc	ra,0x0
    80004994:	22e080e7          	jalr	558(ra) # 80004bbe <pipewrite>
    80004998:	8a2a                	mv	s4,a0
    8000499a:	a045                	j	80004a3a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000499c:	02451783          	lh	a5,36(a0)
    800049a0:	03079693          	slli	a3,a5,0x30
    800049a4:	92c1                	srli	a3,a3,0x30
    800049a6:	4725                	li	a4,9
    800049a8:	0cd76263          	bltu	a4,a3,80004a6c <filewrite+0x12c>
    800049ac:	0792                	slli	a5,a5,0x4
    800049ae:	0001c717          	auipc	a4,0x1c
    800049b2:	62a70713          	addi	a4,a4,1578 # 80020fd8 <devsw>
    800049b6:	97ba                	add	a5,a5,a4
    800049b8:	679c                	ld	a5,8(a5)
    800049ba:	cbdd                	beqz	a5,80004a70 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800049bc:	4505                	li	a0,1
    800049be:	9782                	jalr	a5
    800049c0:	8a2a                	mv	s4,a0
    800049c2:	a8a5                	j	80004a3a <filewrite+0xfa>
    800049c4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049c8:	00000097          	auipc	ra,0x0
    800049cc:	8b0080e7          	jalr	-1872(ra) # 80004278 <begin_op>
      ilock(f->ip);
    800049d0:	01893503          	ld	a0,24(s2)
    800049d4:	fffff097          	auipc	ra,0xfffff
    800049d8:	ee2080e7          	jalr	-286(ra) # 800038b6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049dc:	8762                	mv	a4,s8
    800049de:	02092683          	lw	a3,32(s2)
    800049e2:	01598633          	add	a2,s3,s5
    800049e6:	4585                	li	a1,1
    800049e8:	01893503          	ld	a0,24(s2)
    800049ec:	fffff097          	auipc	ra,0xfffff
    800049f0:	276080e7          	jalr	630(ra) # 80003c62 <writei>
    800049f4:	84aa                	mv	s1,a0
    800049f6:	00a05763          	blez	a0,80004a04 <filewrite+0xc4>
        f->off += r;
    800049fa:	02092783          	lw	a5,32(s2)
    800049fe:	9fa9                	addw	a5,a5,a0
    80004a00:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a04:	01893503          	ld	a0,24(s2)
    80004a08:	fffff097          	auipc	ra,0xfffff
    80004a0c:	f70080e7          	jalr	-144(ra) # 80003978 <iunlock>
      end_op();
    80004a10:	00000097          	auipc	ra,0x0
    80004a14:	8e8080e7          	jalr	-1816(ra) # 800042f8 <end_op>

      if(r != n1){
    80004a18:	009c1f63          	bne	s8,s1,80004a36 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a1c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a20:	0149db63          	bge	s3,s4,80004a36 <filewrite+0xf6>
      int n1 = n - i;
    80004a24:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a28:	84be                	mv	s1,a5
    80004a2a:	2781                	sext.w	a5,a5
    80004a2c:	f8fb5ce3          	bge	s6,a5,800049c4 <filewrite+0x84>
    80004a30:	84de                	mv	s1,s7
    80004a32:	bf49                	j	800049c4 <filewrite+0x84>
    int i = 0;
    80004a34:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a36:	013a1f63          	bne	s4,s3,80004a54 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a3a:	8552                	mv	a0,s4
    80004a3c:	60a6                	ld	ra,72(sp)
    80004a3e:	6406                	ld	s0,64(sp)
    80004a40:	74e2                	ld	s1,56(sp)
    80004a42:	7942                	ld	s2,48(sp)
    80004a44:	79a2                	ld	s3,40(sp)
    80004a46:	7a02                	ld	s4,32(sp)
    80004a48:	6ae2                	ld	s5,24(sp)
    80004a4a:	6b42                	ld	s6,16(sp)
    80004a4c:	6ba2                	ld	s7,8(sp)
    80004a4e:	6c02                	ld	s8,0(sp)
    80004a50:	6161                	addi	sp,sp,80
    80004a52:	8082                	ret
    ret = (i == n ? n : -1);
    80004a54:	5a7d                	li	s4,-1
    80004a56:	b7d5                	j	80004a3a <filewrite+0xfa>
    panic("filewrite");
    80004a58:	00004517          	auipc	a0,0x4
    80004a5c:	c9050513          	addi	a0,a0,-880 # 800086e8 <syscalls+0x270>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	ade080e7          	jalr	-1314(ra) # 8000053e <panic>
    return -1;
    80004a68:	5a7d                	li	s4,-1
    80004a6a:	bfc1                	j	80004a3a <filewrite+0xfa>
      return -1;
    80004a6c:	5a7d                	li	s4,-1
    80004a6e:	b7f1                	j	80004a3a <filewrite+0xfa>
    80004a70:	5a7d                	li	s4,-1
    80004a72:	b7e1                	j	80004a3a <filewrite+0xfa>

0000000080004a74 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a74:	7179                	addi	sp,sp,-48
    80004a76:	f406                	sd	ra,40(sp)
    80004a78:	f022                	sd	s0,32(sp)
    80004a7a:	ec26                	sd	s1,24(sp)
    80004a7c:	e84a                	sd	s2,16(sp)
    80004a7e:	e44e                	sd	s3,8(sp)
    80004a80:	e052                	sd	s4,0(sp)
    80004a82:	1800                	addi	s0,sp,48
    80004a84:	84aa                	mv	s1,a0
    80004a86:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a88:	0005b023          	sd	zero,0(a1)
    80004a8c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a90:	00000097          	auipc	ra,0x0
    80004a94:	bf8080e7          	jalr	-1032(ra) # 80004688 <filealloc>
    80004a98:	e088                	sd	a0,0(s1)
    80004a9a:	c551                	beqz	a0,80004b26 <pipealloc+0xb2>
    80004a9c:	00000097          	auipc	ra,0x0
    80004aa0:	bec080e7          	jalr	-1044(ra) # 80004688 <filealloc>
    80004aa4:	00aa3023          	sd	a0,0(s4)
    80004aa8:	c92d                	beqz	a0,80004b1a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	03c080e7          	jalr	60(ra) # 80000ae6 <kalloc>
    80004ab2:	892a                	mv	s2,a0
    80004ab4:	c125                	beqz	a0,80004b14 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ab6:	4985                	li	s3,1
    80004ab8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004abc:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ac0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ac4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ac8:	00004597          	auipc	a1,0x4
    80004acc:	c3058593          	addi	a1,a1,-976 # 800086f8 <syscalls+0x280>
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	076080e7          	jalr	118(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004ad8:	609c                	ld	a5,0(s1)
    80004ada:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ade:	609c                	ld	a5,0(s1)
    80004ae0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ae4:	609c                	ld	a5,0(s1)
    80004ae6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004aea:	609c                	ld	a5,0(s1)
    80004aec:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004af0:	000a3783          	ld	a5,0(s4)
    80004af4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004af8:	000a3783          	ld	a5,0(s4)
    80004afc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b00:	000a3783          	ld	a5,0(s4)
    80004b04:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b08:	000a3783          	ld	a5,0(s4)
    80004b0c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b10:	4501                	li	a0,0
    80004b12:	a025                	j	80004b3a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b14:	6088                	ld	a0,0(s1)
    80004b16:	e501                	bnez	a0,80004b1e <pipealloc+0xaa>
    80004b18:	a039                	j	80004b26 <pipealloc+0xb2>
    80004b1a:	6088                	ld	a0,0(s1)
    80004b1c:	c51d                	beqz	a0,80004b4a <pipealloc+0xd6>
    fileclose(*f0);
    80004b1e:	00000097          	auipc	ra,0x0
    80004b22:	c26080e7          	jalr	-986(ra) # 80004744 <fileclose>
  if(*f1)
    80004b26:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b2a:	557d                	li	a0,-1
  if(*f1)
    80004b2c:	c799                	beqz	a5,80004b3a <pipealloc+0xc6>
    fileclose(*f1);
    80004b2e:	853e                	mv	a0,a5
    80004b30:	00000097          	auipc	ra,0x0
    80004b34:	c14080e7          	jalr	-1004(ra) # 80004744 <fileclose>
  return -1;
    80004b38:	557d                	li	a0,-1
}
    80004b3a:	70a2                	ld	ra,40(sp)
    80004b3c:	7402                	ld	s0,32(sp)
    80004b3e:	64e2                	ld	s1,24(sp)
    80004b40:	6942                	ld	s2,16(sp)
    80004b42:	69a2                	ld	s3,8(sp)
    80004b44:	6a02                	ld	s4,0(sp)
    80004b46:	6145                	addi	sp,sp,48
    80004b48:	8082                	ret
  return -1;
    80004b4a:	557d                	li	a0,-1
    80004b4c:	b7fd                	j	80004b3a <pipealloc+0xc6>

0000000080004b4e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b4e:	1101                	addi	sp,sp,-32
    80004b50:	ec06                	sd	ra,24(sp)
    80004b52:	e822                	sd	s0,16(sp)
    80004b54:	e426                	sd	s1,8(sp)
    80004b56:	e04a                	sd	s2,0(sp)
    80004b58:	1000                	addi	s0,sp,32
    80004b5a:	84aa                	mv	s1,a0
    80004b5c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b5e:	ffffc097          	auipc	ra,0xffffc
    80004b62:	078080e7          	jalr	120(ra) # 80000bd6 <acquire>
  if(writable){
    80004b66:	02090d63          	beqz	s2,80004ba0 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b6a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b6e:	21848513          	addi	a0,s1,536
    80004b72:	ffffd097          	auipc	ra,0xffffd
    80004b76:	5c8080e7          	jalr	1480(ra) # 8000213a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b7a:	2204b783          	ld	a5,544(s1)
    80004b7e:	eb95                	bnez	a5,80004bb2 <pipeclose+0x64>
    release(&pi->lock);
    80004b80:	8526                	mv	a0,s1
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	108080e7          	jalr	264(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004b8a:	8526                	mv	a0,s1
    80004b8c:	ffffc097          	auipc	ra,0xffffc
    80004b90:	e5e080e7          	jalr	-418(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004b94:	60e2                	ld	ra,24(sp)
    80004b96:	6442                	ld	s0,16(sp)
    80004b98:	64a2                	ld	s1,8(sp)
    80004b9a:	6902                	ld	s2,0(sp)
    80004b9c:	6105                	addi	sp,sp,32
    80004b9e:	8082                	ret
    pi->readopen = 0;
    80004ba0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ba4:	21c48513          	addi	a0,s1,540
    80004ba8:	ffffd097          	auipc	ra,0xffffd
    80004bac:	592080e7          	jalr	1426(ra) # 8000213a <wakeup>
    80004bb0:	b7e9                	j	80004b7a <pipeclose+0x2c>
    release(&pi->lock);
    80004bb2:	8526                	mv	a0,s1
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	0d6080e7          	jalr	214(ra) # 80000c8a <release>
}
    80004bbc:	bfe1                	j	80004b94 <pipeclose+0x46>

0000000080004bbe <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bbe:	711d                	addi	sp,sp,-96
    80004bc0:	ec86                	sd	ra,88(sp)
    80004bc2:	e8a2                	sd	s0,80(sp)
    80004bc4:	e4a6                	sd	s1,72(sp)
    80004bc6:	e0ca                	sd	s2,64(sp)
    80004bc8:	fc4e                	sd	s3,56(sp)
    80004bca:	f852                	sd	s4,48(sp)
    80004bcc:	f456                	sd	s5,40(sp)
    80004bce:	f05a                	sd	s6,32(sp)
    80004bd0:	ec5e                	sd	s7,24(sp)
    80004bd2:	e862                	sd	s8,16(sp)
    80004bd4:	1080                	addi	s0,sp,96
    80004bd6:	84aa                	mv	s1,a0
    80004bd8:	8aae                	mv	s5,a1
    80004bda:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004bdc:	ffffd097          	auipc	ra,0xffffd
    80004be0:	de0080e7          	jalr	-544(ra) # 800019bc <myproc>
    80004be4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004be6:	8526                	mv	a0,s1
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	fee080e7          	jalr	-18(ra) # 80000bd6 <acquire>
  while(i < n){
    80004bf0:	0b405663          	blez	s4,80004c9c <pipewrite+0xde>
  int i = 0;
    80004bf4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bf6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004bf8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004bfc:	21c48b93          	addi	s7,s1,540
    80004c00:	a089                	j	80004c42 <pipewrite+0x84>
      release(&pi->lock);
    80004c02:	8526                	mv	a0,s1
    80004c04:	ffffc097          	auipc	ra,0xffffc
    80004c08:	086080e7          	jalr	134(ra) # 80000c8a <release>
      return -1;
    80004c0c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c0e:	854a                	mv	a0,s2
    80004c10:	60e6                	ld	ra,88(sp)
    80004c12:	6446                	ld	s0,80(sp)
    80004c14:	64a6                	ld	s1,72(sp)
    80004c16:	6906                	ld	s2,64(sp)
    80004c18:	79e2                	ld	s3,56(sp)
    80004c1a:	7a42                	ld	s4,48(sp)
    80004c1c:	7aa2                	ld	s5,40(sp)
    80004c1e:	7b02                	ld	s6,32(sp)
    80004c20:	6be2                	ld	s7,24(sp)
    80004c22:	6c42                	ld	s8,16(sp)
    80004c24:	6125                	addi	sp,sp,96
    80004c26:	8082                	ret
      wakeup(&pi->nread);
    80004c28:	8562                	mv	a0,s8
    80004c2a:	ffffd097          	auipc	ra,0xffffd
    80004c2e:	510080e7          	jalr	1296(ra) # 8000213a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c32:	85a6                	mv	a1,s1
    80004c34:	855e                	mv	a0,s7
    80004c36:	ffffd097          	auipc	ra,0xffffd
    80004c3a:	4a0080e7          	jalr	1184(ra) # 800020d6 <sleep>
  while(i < n){
    80004c3e:	07495063          	bge	s2,s4,80004c9e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004c42:	2204a783          	lw	a5,544(s1)
    80004c46:	dfd5                	beqz	a5,80004c02 <pipewrite+0x44>
    80004c48:	854e                	mv	a0,s3
    80004c4a:	ffffd097          	auipc	ra,0xffffd
    80004c4e:	740080e7          	jalr	1856(ra) # 8000238a <killed>
    80004c52:	f945                	bnez	a0,80004c02 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c54:	2184a783          	lw	a5,536(s1)
    80004c58:	21c4a703          	lw	a4,540(s1)
    80004c5c:	2007879b          	addiw	a5,a5,512
    80004c60:	fcf704e3          	beq	a4,a5,80004c28 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c64:	4685                	li	a3,1
    80004c66:	01590633          	add	a2,s2,s5
    80004c6a:	faf40593          	addi	a1,s0,-81
    80004c6e:	0509b503          	ld	a0,80(s3)
    80004c72:	ffffd097          	auipc	ra,0xffffd
    80004c76:	a92080e7          	jalr	-1390(ra) # 80001704 <copyin>
    80004c7a:	03650263          	beq	a0,s6,80004c9e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c7e:	21c4a783          	lw	a5,540(s1)
    80004c82:	0017871b          	addiw	a4,a5,1
    80004c86:	20e4ae23          	sw	a4,540(s1)
    80004c8a:	1ff7f793          	andi	a5,a5,511
    80004c8e:	97a6                	add	a5,a5,s1
    80004c90:	faf44703          	lbu	a4,-81(s0)
    80004c94:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c98:	2905                	addiw	s2,s2,1
    80004c9a:	b755                	j	80004c3e <pipewrite+0x80>
  int i = 0;
    80004c9c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004c9e:	21848513          	addi	a0,s1,536
    80004ca2:	ffffd097          	auipc	ra,0xffffd
    80004ca6:	498080e7          	jalr	1176(ra) # 8000213a <wakeup>
  release(&pi->lock);
    80004caa:	8526                	mv	a0,s1
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	fde080e7          	jalr	-34(ra) # 80000c8a <release>
  return i;
    80004cb4:	bfa9                	j	80004c0e <pipewrite+0x50>

0000000080004cb6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cb6:	715d                	addi	sp,sp,-80
    80004cb8:	e486                	sd	ra,72(sp)
    80004cba:	e0a2                	sd	s0,64(sp)
    80004cbc:	fc26                	sd	s1,56(sp)
    80004cbe:	f84a                	sd	s2,48(sp)
    80004cc0:	f44e                	sd	s3,40(sp)
    80004cc2:	f052                	sd	s4,32(sp)
    80004cc4:	ec56                	sd	s5,24(sp)
    80004cc6:	e85a                	sd	s6,16(sp)
    80004cc8:	0880                	addi	s0,sp,80
    80004cca:	84aa                	mv	s1,a0
    80004ccc:	892e                	mv	s2,a1
    80004cce:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cd0:	ffffd097          	auipc	ra,0xffffd
    80004cd4:	cec080e7          	jalr	-788(ra) # 800019bc <myproc>
    80004cd8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cda:	8526                	mv	a0,s1
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	efa080e7          	jalr	-262(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ce4:	2184a703          	lw	a4,536(s1)
    80004ce8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cec:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cf0:	02f71763          	bne	a4,a5,80004d1e <piperead+0x68>
    80004cf4:	2244a783          	lw	a5,548(s1)
    80004cf8:	c39d                	beqz	a5,80004d1e <piperead+0x68>
    if(killed(pr)){
    80004cfa:	8552                	mv	a0,s4
    80004cfc:	ffffd097          	auipc	ra,0xffffd
    80004d00:	68e080e7          	jalr	1678(ra) # 8000238a <killed>
    80004d04:	e941                	bnez	a0,80004d94 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d06:	85a6                	mv	a1,s1
    80004d08:	854e                	mv	a0,s3
    80004d0a:	ffffd097          	auipc	ra,0xffffd
    80004d0e:	3cc080e7          	jalr	972(ra) # 800020d6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d12:	2184a703          	lw	a4,536(s1)
    80004d16:	21c4a783          	lw	a5,540(s1)
    80004d1a:	fcf70de3          	beq	a4,a5,80004cf4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d1e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d20:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d22:	05505363          	blez	s5,80004d68 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004d26:	2184a783          	lw	a5,536(s1)
    80004d2a:	21c4a703          	lw	a4,540(s1)
    80004d2e:	02f70d63          	beq	a4,a5,80004d68 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d32:	0017871b          	addiw	a4,a5,1
    80004d36:	20e4ac23          	sw	a4,536(s1)
    80004d3a:	1ff7f793          	andi	a5,a5,511
    80004d3e:	97a6                	add	a5,a5,s1
    80004d40:	0187c783          	lbu	a5,24(a5)
    80004d44:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d48:	4685                	li	a3,1
    80004d4a:	fbf40613          	addi	a2,s0,-65
    80004d4e:	85ca                	mv	a1,s2
    80004d50:	050a3503          	ld	a0,80(s4)
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	924080e7          	jalr	-1756(ra) # 80001678 <copyout>
    80004d5c:	01650663          	beq	a0,s6,80004d68 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d60:	2985                	addiw	s3,s3,1
    80004d62:	0905                	addi	s2,s2,1
    80004d64:	fd3a91e3          	bne	s5,s3,80004d26 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d68:	21c48513          	addi	a0,s1,540
    80004d6c:	ffffd097          	auipc	ra,0xffffd
    80004d70:	3ce080e7          	jalr	974(ra) # 8000213a <wakeup>
  release(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	f14080e7          	jalr	-236(ra) # 80000c8a <release>
  return i;
}
    80004d7e:	854e                	mv	a0,s3
    80004d80:	60a6                	ld	ra,72(sp)
    80004d82:	6406                	ld	s0,64(sp)
    80004d84:	74e2                	ld	s1,56(sp)
    80004d86:	7942                	ld	s2,48(sp)
    80004d88:	79a2                	ld	s3,40(sp)
    80004d8a:	7a02                	ld	s4,32(sp)
    80004d8c:	6ae2                	ld	s5,24(sp)
    80004d8e:	6b42                	ld	s6,16(sp)
    80004d90:	6161                	addi	sp,sp,80
    80004d92:	8082                	ret
      release(&pi->lock);
    80004d94:	8526                	mv	a0,s1
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	ef4080e7          	jalr	-268(ra) # 80000c8a <release>
      return -1;
    80004d9e:	59fd                	li	s3,-1
    80004da0:	bff9                	j	80004d7e <piperead+0xc8>

0000000080004da2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004da2:	1141                	addi	sp,sp,-16
    80004da4:	e422                	sd	s0,8(sp)
    80004da6:	0800                	addi	s0,sp,16
    80004da8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004daa:	8905                	andi	a0,a0,1
    80004dac:	c111                	beqz	a0,80004db0 <flags2perm+0xe>
      perm = PTE_X;
    80004dae:	4521                	li	a0,8
    if(flags & 0x2)
    80004db0:	8b89                	andi	a5,a5,2
    80004db2:	c399                	beqz	a5,80004db8 <flags2perm+0x16>
      perm |= PTE_W;
    80004db4:	00456513          	ori	a0,a0,4
    return perm;
}
    80004db8:	6422                	ld	s0,8(sp)
    80004dba:	0141                	addi	sp,sp,16
    80004dbc:	8082                	ret

0000000080004dbe <exec>:

int
exec(char *path, char **argv)
{
    80004dbe:	de010113          	addi	sp,sp,-544
    80004dc2:	20113c23          	sd	ra,536(sp)
    80004dc6:	20813823          	sd	s0,528(sp)
    80004dca:	20913423          	sd	s1,520(sp)
    80004dce:	21213023          	sd	s2,512(sp)
    80004dd2:	ffce                	sd	s3,504(sp)
    80004dd4:	fbd2                	sd	s4,496(sp)
    80004dd6:	f7d6                	sd	s5,488(sp)
    80004dd8:	f3da                	sd	s6,480(sp)
    80004dda:	efde                	sd	s7,472(sp)
    80004ddc:	ebe2                	sd	s8,464(sp)
    80004dde:	e7e6                	sd	s9,456(sp)
    80004de0:	e3ea                	sd	s10,448(sp)
    80004de2:	ff6e                	sd	s11,440(sp)
    80004de4:	1400                	addi	s0,sp,544
    80004de6:	892a                	mv	s2,a0
    80004de8:	dea43423          	sd	a0,-536(s0)
    80004dec:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004df0:	ffffd097          	auipc	ra,0xffffd
    80004df4:	bcc080e7          	jalr	-1076(ra) # 800019bc <myproc>
    80004df8:	84aa                	mv	s1,a0

  begin_op();
    80004dfa:	fffff097          	auipc	ra,0xfffff
    80004dfe:	47e080e7          	jalr	1150(ra) # 80004278 <begin_op>

  if((ip = namei(path)) == 0){
    80004e02:	854a                	mv	a0,s2
    80004e04:	fffff097          	auipc	ra,0xfffff
    80004e08:	258080e7          	jalr	600(ra) # 8000405c <namei>
    80004e0c:	c93d                	beqz	a0,80004e82 <exec+0xc4>
    80004e0e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e10:	fffff097          	auipc	ra,0xfffff
    80004e14:	aa6080e7          	jalr	-1370(ra) # 800038b6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e18:	04000713          	li	a4,64
    80004e1c:	4681                	li	a3,0
    80004e1e:	e5040613          	addi	a2,s0,-432
    80004e22:	4581                	li	a1,0
    80004e24:	8556                	mv	a0,s5
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	d44080e7          	jalr	-700(ra) # 80003b6a <readi>
    80004e2e:	04000793          	li	a5,64
    80004e32:	00f51a63          	bne	a0,a5,80004e46 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e36:	e5042703          	lw	a4,-432(s0)
    80004e3a:	464c47b7          	lui	a5,0x464c4
    80004e3e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e42:	04f70663          	beq	a4,a5,80004e8e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e46:	8556                	mv	a0,s5
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	cd0080e7          	jalr	-816(ra) # 80003b18 <iunlockput>
    end_op();
    80004e50:	fffff097          	auipc	ra,0xfffff
    80004e54:	4a8080e7          	jalr	1192(ra) # 800042f8 <end_op>
  }
  return -1;
    80004e58:	557d                	li	a0,-1
}
    80004e5a:	21813083          	ld	ra,536(sp)
    80004e5e:	21013403          	ld	s0,528(sp)
    80004e62:	20813483          	ld	s1,520(sp)
    80004e66:	20013903          	ld	s2,512(sp)
    80004e6a:	79fe                	ld	s3,504(sp)
    80004e6c:	7a5e                	ld	s4,496(sp)
    80004e6e:	7abe                	ld	s5,488(sp)
    80004e70:	7b1e                	ld	s6,480(sp)
    80004e72:	6bfe                	ld	s7,472(sp)
    80004e74:	6c5e                	ld	s8,464(sp)
    80004e76:	6cbe                	ld	s9,456(sp)
    80004e78:	6d1e                	ld	s10,448(sp)
    80004e7a:	7dfa                	ld	s11,440(sp)
    80004e7c:	22010113          	addi	sp,sp,544
    80004e80:	8082                	ret
    end_op();
    80004e82:	fffff097          	auipc	ra,0xfffff
    80004e86:	476080e7          	jalr	1142(ra) # 800042f8 <end_op>
    return -1;
    80004e8a:	557d                	li	a0,-1
    80004e8c:	b7f9                	j	80004e5a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e8e:	8526                	mv	a0,s1
    80004e90:	ffffd097          	auipc	ra,0xffffd
    80004e94:	bf0080e7          	jalr	-1040(ra) # 80001a80 <proc_pagetable>
    80004e98:	8b2a                	mv	s6,a0
    80004e9a:	d555                	beqz	a0,80004e46 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e9c:	e7042783          	lw	a5,-400(s0)
    80004ea0:	e8845703          	lhu	a4,-376(s0)
    80004ea4:	c735                	beqz	a4,80004f10 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ea6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ea8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004eac:	6a05                	lui	s4,0x1
    80004eae:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004eb2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004eb6:	6d85                	lui	s11,0x1
    80004eb8:	7d7d                	lui	s10,0xfffff
    80004eba:	a481                	j	800050fa <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ebc:	00004517          	auipc	a0,0x4
    80004ec0:	84450513          	addi	a0,a0,-1980 # 80008700 <syscalls+0x288>
    80004ec4:	ffffb097          	auipc	ra,0xffffb
    80004ec8:	67a080e7          	jalr	1658(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ecc:	874a                	mv	a4,s2
    80004ece:	009c86bb          	addw	a3,s9,s1
    80004ed2:	4581                	li	a1,0
    80004ed4:	8556                	mv	a0,s5
    80004ed6:	fffff097          	auipc	ra,0xfffff
    80004eda:	c94080e7          	jalr	-876(ra) # 80003b6a <readi>
    80004ede:	2501                	sext.w	a0,a0
    80004ee0:	1aa91a63          	bne	s2,a0,80005094 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004ee4:	009d84bb          	addw	s1,s11,s1
    80004ee8:	013d09bb          	addw	s3,s10,s3
    80004eec:	1f74f763          	bgeu	s1,s7,800050da <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004ef0:	02049593          	slli	a1,s1,0x20
    80004ef4:	9181                	srli	a1,a1,0x20
    80004ef6:	95e2                	add	a1,a1,s8
    80004ef8:	855a                	mv	a0,s6
    80004efa:	ffffc097          	auipc	ra,0xffffc
    80004efe:	172080e7          	jalr	370(ra) # 8000106c <walkaddr>
    80004f02:	862a                	mv	a2,a0
    if(pa == 0)
    80004f04:	dd45                	beqz	a0,80004ebc <exec+0xfe>
      n = PGSIZE;
    80004f06:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f08:	fd49f2e3          	bgeu	s3,s4,80004ecc <exec+0x10e>
      n = sz - i;
    80004f0c:	894e                	mv	s2,s3
    80004f0e:	bf7d                	j	80004ecc <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f10:	4901                	li	s2,0
  iunlockput(ip);
    80004f12:	8556                	mv	a0,s5
    80004f14:	fffff097          	auipc	ra,0xfffff
    80004f18:	c04080e7          	jalr	-1020(ra) # 80003b18 <iunlockput>
  end_op();
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	3dc080e7          	jalr	988(ra) # 800042f8 <end_op>
  p = myproc();
    80004f24:	ffffd097          	auipc	ra,0xffffd
    80004f28:	a98080e7          	jalr	-1384(ra) # 800019bc <myproc>
    80004f2c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f2e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f32:	6785                	lui	a5,0x1
    80004f34:	17fd                	addi	a5,a5,-1
    80004f36:	993e                	add	s2,s2,a5
    80004f38:	77fd                	lui	a5,0xfffff
    80004f3a:	00f977b3          	and	a5,s2,a5
    80004f3e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f42:	4691                	li	a3,4
    80004f44:	6609                	lui	a2,0x2
    80004f46:	963e                	add	a2,a2,a5
    80004f48:	85be                	mv	a1,a5
    80004f4a:	855a                	mv	a0,s6
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	4d4080e7          	jalr	1236(ra) # 80001420 <uvmalloc>
    80004f54:	8c2a                	mv	s8,a0
  ip = 0;
    80004f56:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f58:	12050e63          	beqz	a0,80005094 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f5c:	75f9                	lui	a1,0xffffe
    80004f5e:	95aa                	add	a1,a1,a0
    80004f60:	855a                	mv	a0,s6
    80004f62:	ffffc097          	auipc	ra,0xffffc
    80004f66:	6e4080e7          	jalr	1764(ra) # 80001646 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f6a:	7afd                	lui	s5,0xfffff
    80004f6c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f6e:	df043783          	ld	a5,-528(s0)
    80004f72:	6388                	ld	a0,0(a5)
    80004f74:	c925                	beqz	a0,80004fe4 <exec+0x226>
    80004f76:	e9040993          	addi	s3,s0,-368
    80004f7a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f7e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f80:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f82:	ffffc097          	auipc	ra,0xffffc
    80004f86:	ecc080e7          	jalr	-308(ra) # 80000e4e <strlen>
    80004f8a:	0015079b          	addiw	a5,a0,1
    80004f8e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f92:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f96:	13596663          	bltu	s2,s5,800050c2 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f9a:	df043d83          	ld	s11,-528(s0)
    80004f9e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004fa2:	8552                	mv	a0,s4
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	eaa080e7          	jalr	-342(ra) # 80000e4e <strlen>
    80004fac:	0015069b          	addiw	a3,a0,1
    80004fb0:	8652                	mv	a2,s4
    80004fb2:	85ca                	mv	a1,s2
    80004fb4:	855a                	mv	a0,s6
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	6c2080e7          	jalr	1730(ra) # 80001678 <copyout>
    80004fbe:	10054663          	bltz	a0,800050ca <exec+0x30c>
    ustack[argc] = sp;
    80004fc2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fc6:	0485                	addi	s1,s1,1
    80004fc8:	008d8793          	addi	a5,s11,8
    80004fcc:	def43823          	sd	a5,-528(s0)
    80004fd0:	008db503          	ld	a0,8(s11)
    80004fd4:	c911                	beqz	a0,80004fe8 <exec+0x22a>
    if(argc >= MAXARG)
    80004fd6:	09a1                	addi	s3,s3,8
    80004fd8:	fb3c95e3          	bne	s9,s3,80004f82 <exec+0x1c4>
  sz = sz1;
    80004fdc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004fe0:	4a81                	li	s5,0
    80004fe2:	a84d                	j	80005094 <exec+0x2d6>
  sp = sz;
    80004fe4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fe6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fe8:	00349793          	slli	a5,s1,0x3
    80004fec:	f9040713          	addi	a4,s0,-112
    80004ff0:	97ba                	add	a5,a5,a4
    80004ff2:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdcd90>
  sp -= (argc+1) * sizeof(uint64);
    80004ff6:	00148693          	addi	a3,s1,1
    80004ffa:	068e                	slli	a3,a3,0x3
    80004ffc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005000:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005004:	01597663          	bgeu	s2,s5,80005010 <exec+0x252>
  sz = sz1;
    80005008:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000500c:	4a81                	li	s5,0
    8000500e:	a059                	j	80005094 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005010:	e9040613          	addi	a2,s0,-368
    80005014:	85ca                	mv	a1,s2
    80005016:	855a                	mv	a0,s6
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	660080e7          	jalr	1632(ra) # 80001678 <copyout>
    80005020:	0a054963          	bltz	a0,800050d2 <exec+0x314>
  p->trapframe->a1 = sp;
    80005024:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005028:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000502c:	de843783          	ld	a5,-536(s0)
    80005030:	0007c703          	lbu	a4,0(a5)
    80005034:	cf11                	beqz	a4,80005050 <exec+0x292>
    80005036:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005038:	02f00693          	li	a3,47
    8000503c:	a039                	j	8000504a <exec+0x28c>
      last = s+1;
    8000503e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005042:	0785                	addi	a5,a5,1
    80005044:	fff7c703          	lbu	a4,-1(a5)
    80005048:	c701                	beqz	a4,80005050 <exec+0x292>
    if(*s == '/')
    8000504a:	fed71ce3          	bne	a4,a3,80005042 <exec+0x284>
    8000504e:	bfc5                	j	8000503e <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005050:	4641                	li	a2,16
    80005052:	de843583          	ld	a1,-536(s0)
    80005056:	158b8513          	addi	a0,s7,344
    8000505a:	ffffc097          	auipc	ra,0xffffc
    8000505e:	dc2080e7          	jalr	-574(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005062:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005066:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000506a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000506e:	058bb783          	ld	a5,88(s7)
    80005072:	e6843703          	ld	a4,-408(s0)
    80005076:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005078:	058bb783          	ld	a5,88(s7)
    8000507c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005080:	85ea                	mv	a1,s10
    80005082:	ffffd097          	auipc	ra,0xffffd
    80005086:	a9a080e7          	jalr	-1382(ra) # 80001b1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000508a:	0004851b          	sext.w	a0,s1
    8000508e:	b3f1                	j	80004e5a <exec+0x9c>
    80005090:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005094:	df843583          	ld	a1,-520(s0)
    80005098:	855a                	mv	a0,s6
    8000509a:	ffffd097          	auipc	ra,0xffffd
    8000509e:	a82080e7          	jalr	-1406(ra) # 80001b1c <proc_freepagetable>
  if(ip){
    800050a2:	da0a92e3          	bnez	s5,80004e46 <exec+0x88>
  return -1;
    800050a6:	557d                	li	a0,-1
    800050a8:	bb4d                	j	80004e5a <exec+0x9c>
    800050aa:	df243c23          	sd	s2,-520(s0)
    800050ae:	b7dd                	j	80005094 <exec+0x2d6>
    800050b0:	df243c23          	sd	s2,-520(s0)
    800050b4:	b7c5                	j	80005094 <exec+0x2d6>
    800050b6:	df243c23          	sd	s2,-520(s0)
    800050ba:	bfe9                	j	80005094 <exec+0x2d6>
    800050bc:	df243c23          	sd	s2,-520(s0)
    800050c0:	bfd1                	j	80005094 <exec+0x2d6>
  sz = sz1;
    800050c2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050c6:	4a81                	li	s5,0
    800050c8:	b7f1                	j	80005094 <exec+0x2d6>
  sz = sz1;
    800050ca:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050ce:	4a81                	li	s5,0
    800050d0:	b7d1                	j	80005094 <exec+0x2d6>
  sz = sz1;
    800050d2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050d6:	4a81                	li	s5,0
    800050d8:	bf75                	j	80005094 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050da:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050de:	e0843783          	ld	a5,-504(s0)
    800050e2:	0017869b          	addiw	a3,a5,1
    800050e6:	e0d43423          	sd	a3,-504(s0)
    800050ea:	e0043783          	ld	a5,-512(s0)
    800050ee:	0387879b          	addiw	a5,a5,56
    800050f2:	e8845703          	lhu	a4,-376(s0)
    800050f6:	e0e6dee3          	bge	a3,a4,80004f12 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050fa:	2781                	sext.w	a5,a5
    800050fc:	e0f43023          	sd	a5,-512(s0)
    80005100:	03800713          	li	a4,56
    80005104:	86be                	mv	a3,a5
    80005106:	e1840613          	addi	a2,s0,-488
    8000510a:	4581                	li	a1,0
    8000510c:	8556                	mv	a0,s5
    8000510e:	fffff097          	auipc	ra,0xfffff
    80005112:	a5c080e7          	jalr	-1444(ra) # 80003b6a <readi>
    80005116:	03800793          	li	a5,56
    8000511a:	f6f51be3          	bne	a0,a5,80005090 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    8000511e:	e1842783          	lw	a5,-488(s0)
    80005122:	4705                	li	a4,1
    80005124:	fae79de3          	bne	a5,a4,800050de <exec+0x320>
    if(ph.memsz < ph.filesz)
    80005128:	e4043483          	ld	s1,-448(s0)
    8000512c:	e3843783          	ld	a5,-456(s0)
    80005130:	f6f4ede3          	bltu	s1,a5,800050aa <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005134:	e2843783          	ld	a5,-472(s0)
    80005138:	94be                	add	s1,s1,a5
    8000513a:	f6f4ebe3          	bltu	s1,a5,800050b0 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    8000513e:	de043703          	ld	a4,-544(s0)
    80005142:	8ff9                	and	a5,a5,a4
    80005144:	fbad                	bnez	a5,800050b6 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005146:	e1c42503          	lw	a0,-484(s0)
    8000514a:	00000097          	auipc	ra,0x0
    8000514e:	c58080e7          	jalr	-936(ra) # 80004da2 <flags2perm>
    80005152:	86aa                	mv	a3,a0
    80005154:	8626                	mv	a2,s1
    80005156:	85ca                	mv	a1,s2
    80005158:	855a                	mv	a0,s6
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	2c6080e7          	jalr	710(ra) # 80001420 <uvmalloc>
    80005162:	dea43c23          	sd	a0,-520(s0)
    80005166:	d939                	beqz	a0,800050bc <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005168:	e2843c03          	ld	s8,-472(s0)
    8000516c:	e2042c83          	lw	s9,-480(s0)
    80005170:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005174:	f60b83e3          	beqz	s7,800050da <exec+0x31c>
    80005178:	89de                	mv	s3,s7
    8000517a:	4481                	li	s1,0
    8000517c:	bb95                	j	80004ef0 <exec+0x132>

000000008000517e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000517e:	7179                	addi	sp,sp,-48
    80005180:	f406                	sd	ra,40(sp)
    80005182:	f022                	sd	s0,32(sp)
    80005184:	ec26                	sd	s1,24(sp)
    80005186:	e84a                	sd	s2,16(sp)
    80005188:	1800                	addi	s0,sp,48
    8000518a:	892e                	mv	s2,a1
    8000518c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000518e:	fdc40593          	addi	a1,s0,-36
    80005192:	ffffe097          	auipc	ra,0xffffe
    80005196:	b1c080e7          	jalr	-1252(ra) # 80002cae <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000519a:	fdc42703          	lw	a4,-36(s0)
    8000519e:	47bd                	li	a5,15
    800051a0:	02e7eb63          	bltu	a5,a4,800051d6 <argfd+0x58>
    800051a4:	ffffd097          	auipc	ra,0xffffd
    800051a8:	818080e7          	jalr	-2024(ra) # 800019bc <myproc>
    800051ac:	fdc42703          	lw	a4,-36(s0)
    800051b0:	01a70793          	addi	a5,a4,26
    800051b4:	078e                	slli	a5,a5,0x3
    800051b6:	953e                	add	a0,a0,a5
    800051b8:	611c                	ld	a5,0(a0)
    800051ba:	c385                	beqz	a5,800051da <argfd+0x5c>
    return -1;
  if(pfd)
    800051bc:	00090463          	beqz	s2,800051c4 <argfd+0x46>
    *pfd = fd;
    800051c0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051c4:	4501                	li	a0,0
  if(pf)
    800051c6:	c091                	beqz	s1,800051ca <argfd+0x4c>
    *pf = f;
    800051c8:	e09c                	sd	a5,0(s1)
}
    800051ca:	70a2                	ld	ra,40(sp)
    800051cc:	7402                	ld	s0,32(sp)
    800051ce:	64e2                	ld	s1,24(sp)
    800051d0:	6942                	ld	s2,16(sp)
    800051d2:	6145                	addi	sp,sp,48
    800051d4:	8082                	ret
    return -1;
    800051d6:	557d                	li	a0,-1
    800051d8:	bfcd                	j	800051ca <argfd+0x4c>
    800051da:	557d                	li	a0,-1
    800051dc:	b7fd                	j	800051ca <argfd+0x4c>

00000000800051de <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051de:	1101                	addi	sp,sp,-32
    800051e0:	ec06                	sd	ra,24(sp)
    800051e2:	e822                	sd	s0,16(sp)
    800051e4:	e426                	sd	s1,8(sp)
    800051e6:	1000                	addi	s0,sp,32
    800051e8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051ea:	ffffc097          	auipc	ra,0xffffc
    800051ee:	7d2080e7          	jalr	2002(ra) # 800019bc <myproc>
    800051f2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051f4:	0d050793          	addi	a5,a0,208
    800051f8:	4501                	li	a0,0
    800051fa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051fc:	6398                	ld	a4,0(a5)
    800051fe:	cb19                	beqz	a4,80005214 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005200:	2505                	addiw	a0,a0,1
    80005202:	07a1                	addi	a5,a5,8
    80005204:	fed51ce3          	bne	a0,a3,800051fc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005208:	557d                	li	a0,-1
}
    8000520a:	60e2                	ld	ra,24(sp)
    8000520c:	6442                	ld	s0,16(sp)
    8000520e:	64a2                	ld	s1,8(sp)
    80005210:	6105                	addi	sp,sp,32
    80005212:	8082                	ret
      p->ofile[fd] = f;
    80005214:	01a50793          	addi	a5,a0,26
    80005218:	078e                	slli	a5,a5,0x3
    8000521a:	963e                	add	a2,a2,a5
    8000521c:	e204                	sd	s1,0(a2)
      return fd;
    8000521e:	b7f5                	j	8000520a <fdalloc+0x2c>

0000000080005220 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005220:	715d                	addi	sp,sp,-80
    80005222:	e486                	sd	ra,72(sp)
    80005224:	e0a2                	sd	s0,64(sp)
    80005226:	fc26                	sd	s1,56(sp)
    80005228:	f84a                	sd	s2,48(sp)
    8000522a:	f44e                	sd	s3,40(sp)
    8000522c:	f052                	sd	s4,32(sp)
    8000522e:	ec56                	sd	s5,24(sp)
    80005230:	e85a                	sd	s6,16(sp)
    80005232:	0880                	addi	s0,sp,80
    80005234:	8b2e                	mv	s6,a1
    80005236:	89b2                	mv	s3,a2
    80005238:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000523a:	fb040593          	addi	a1,s0,-80
    8000523e:	fffff097          	auipc	ra,0xfffff
    80005242:	e3c080e7          	jalr	-452(ra) # 8000407a <nameiparent>
    80005246:	84aa                	mv	s1,a0
    80005248:	14050f63          	beqz	a0,800053a6 <create+0x186>
    return 0;

  ilock(dp);
    8000524c:	ffffe097          	auipc	ra,0xffffe
    80005250:	66a080e7          	jalr	1642(ra) # 800038b6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005254:	4601                	li	a2,0
    80005256:	fb040593          	addi	a1,s0,-80
    8000525a:	8526                	mv	a0,s1
    8000525c:	fffff097          	auipc	ra,0xfffff
    80005260:	b3e080e7          	jalr	-1218(ra) # 80003d9a <dirlookup>
    80005264:	8aaa                	mv	s5,a0
    80005266:	c931                	beqz	a0,800052ba <create+0x9a>
    iunlockput(dp);
    80005268:	8526                	mv	a0,s1
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	8ae080e7          	jalr	-1874(ra) # 80003b18 <iunlockput>
    ilock(ip);
    80005272:	8556                	mv	a0,s5
    80005274:	ffffe097          	auipc	ra,0xffffe
    80005278:	642080e7          	jalr	1602(ra) # 800038b6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000527c:	000b059b          	sext.w	a1,s6
    80005280:	4789                	li	a5,2
    80005282:	02f59563          	bne	a1,a5,800052ac <create+0x8c>
    80005286:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdced4>
    8000528a:	37f9                	addiw	a5,a5,-2
    8000528c:	17c2                	slli	a5,a5,0x30
    8000528e:	93c1                	srli	a5,a5,0x30
    80005290:	4705                	li	a4,1
    80005292:	00f76d63          	bltu	a4,a5,800052ac <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005296:	8556                	mv	a0,s5
    80005298:	60a6                	ld	ra,72(sp)
    8000529a:	6406                	ld	s0,64(sp)
    8000529c:	74e2                	ld	s1,56(sp)
    8000529e:	7942                	ld	s2,48(sp)
    800052a0:	79a2                	ld	s3,40(sp)
    800052a2:	7a02                	ld	s4,32(sp)
    800052a4:	6ae2                	ld	s5,24(sp)
    800052a6:	6b42                	ld	s6,16(sp)
    800052a8:	6161                	addi	sp,sp,80
    800052aa:	8082                	ret
    iunlockput(ip);
    800052ac:	8556                	mv	a0,s5
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	86a080e7          	jalr	-1942(ra) # 80003b18 <iunlockput>
    return 0;
    800052b6:	4a81                	li	s5,0
    800052b8:	bff9                	j	80005296 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800052ba:	85da                	mv	a1,s6
    800052bc:	4088                	lw	a0,0(s1)
    800052be:	ffffe097          	auipc	ra,0xffffe
    800052c2:	45c080e7          	jalr	1116(ra) # 8000371a <ialloc>
    800052c6:	8a2a                	mv	s4,a0
    800052c8:	c539                	beqz	a0,80005316 <create+0xf6>
  ilock(ip);
    800052ca:	ffffe097          	auipc	ra,0xffffe
    800052ce:	5ec080e7          	jalr	1516(ra) # 800038b6 <ilock>
  ip->major = major;
    800052d2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800052d6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800052da:	4905                	li	s2,1
    800052dc:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800052e0:	8552                	mv	a0,s4
    800052e2:	ffffe097          	auipc	ra,0xffffe
    800052e6:	50a080e7          	jalr	1290(ra) # 800037ec <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052ea:	000b059b          	sext.w	a1,s6
    800052ee:	03258b63          	beq	a1,s2,80005324 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800052f2:	004a2603          	lw	a2,4(s4)
    800052f6:	fb040593          	addi	a1,s0,-80
    800052fa:	8526                	mv	a0,s1
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	cae080e7          	jalr	-850(ra) # 80003faa <dirlink>
    80005304:	06054f63          	bltz	a0,80005382 <create+0x162>
  iunlockput(dp);
    80005308:	8526                	mv	a0,s1
    8000530a:	fffff097          	auipc	ra,0xfffff
    8000530e:	80e080e7          	jalr	-2034(ra) # 80003b18 <iunlockput>
  return ip;
    80005312:	8ad2                	mv	s5,s4
    80005314:	b749                	j	80005296 <create+0x76>
    iunlockput(dp);
    80005316:	8526                	mv	a0,s1
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	800080e7          	jalr	-2048(ra) # 80003b18 <iunlockput>
    return 0;
    80005320:	8ad2                	mv	s5,s4
    80005322:	bf95                	j	80005296 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005324:	004a2603          	lw	a2,4(s4)
    80005328:	00003597          	auipc	a1,0x3
    8000532c:	3f858593          	addi	a1,a1,1016 # 80008720 <syscalls+0x2a8>
    80005330:	8552                	mv	a0,s4
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	c78080e7          	jalr	-904(ra) # 80003faa <dirlink>
    8000533a:	04054463          	bltz	a0,80005382 <create+0x162>
    8000533e:	40d0                	lw	a2,4(s1)
    80005340:	00003597          	auipc	a1,0x3
    80005344:	3e858593          	addi	a1,a1,1000 # 80008728 <syscalls+0x2b0>
    80005348:	8552                	mv	a0,s4
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	c60080e7          	jalr	-928(ra) # 80003faa <dirlink>
    80005352:	02054863          	bltz	a0,80005382 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005356:	004a2603          	lw	a2,4(s4)
    8000535a:	fb040593          	addi	a1,s0,-80
    8000535e:	8526                	mv	a0,s1
    80005360:	fffff097          	auipc	ra,0xfffff
    80005364:	c4a080e7          	jalr	-950(ra) # 80003faa <dirlink>
    80005368:	00054d63          	bltz	a0,80005382 <create+0x162>
    dp->nlink++;  // for ".."
    8000536c:	04a4d783          	lhu	a5,74(s1)
    80005370:	2785                	addiw	a5,a5,1
    80005372:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005376:	8526                	mv	a0,s1
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	474080e7          	jalr	1140(ra) # 800037ec <iupdate>
    80005380:	b761                	j	80005308 <create+0xe8>
  ip->nlink = 0;
    80005382:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005386:	8552                	mv	a0,s4
    80005388:	ffffe097          	auipc	ra,0xffffe
    8000538c:	464080e7          	jalr	1124(ra) # 800037ec <iupdate>
  iunlockput(ip);
    80005390:	8552                	mv	a0,s4
    80005392:	ffffe097          	auipc	ra,0xffffe
    80005396:	786080e7          	jalr	1926(ra) # 80003b18 <iunlockput>
  iunlockput(dp);
    8000539a:	8526                	mv	a0,s1
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	77c080e7          	jalr	1916(ra) # 80003b18 <iunlockput>
  return 0;
    800053a4:	bdcd                	j	80005296 <create+0x76>
    return 0;
    800053a6:	8aaa                	mv	s5,a0
    800053a8:	b5fd                	j	80005296 <create+0x76>

00000000800053aa <sys_dup>:
{
    800053aa:	7179                	addi	sp,sp,-48
    800053ac:	f406                	sd	ra,40(sp)
    800053ae:	f022                	sd	s0,32(sp)
    800053b0:	ec26                	sd	s1,24(sp)
    800053b2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053b4:	fd840613          	addi	a2,s0,-40
    800053b8:	4581                	li	a1,0
    800053ba:	4501                	li	a0,0
    800053bc:	00000097          	auipc	ra,0x0
    800053c0:	dc2080e7          	jalr	-574(ra) # 8000517e <argfd>
    return -1;
    800053c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053c6:	02054363          	bltz	a0,800053ec <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053ca:	fd843503          	ld	a0,-40(s0)
    800053ce:	00000097          	auipc	ra,0x0
    800053d2:	e10080e7          	jalr	-496(ra) # 800051de <fdalloc>
    800053d6:	84aa                	mv	s1,a0
    return -1;
    800053d8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053da:	00054963          	bltz	a0,800053ec <sys_dup+0x42>
  filedup(f);
    800053de:	fd843503          	ld	a0,-40(s0)
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	310080e7          	jalr	784(ra) # 800046f2 <filedup>
  return fd;
    800053ea:	87a6                	mv	a5,s1
}
    800053ec:	853e                	mv	a0,a5
    800053ee:	70a2                	ld	ra,40(sp)
    800053f0:	7402                	ld	s0,32(sp)
    800053f2:	64e2                	ld	s1,24(sp)
    800053f4:	6145                	addi	sp,sp,48
    800053f6:	8082                	ret

00000000800053f8 <sys_read>:
{
    800053f8:	7179                	addi	sp,sp,-48
    800053fa:	f406                	sd	ra,40(sp)
    800053fc:	f022                	sd	s0,32(sp)
    800053fe:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005400:	fd840593          	addi	a1,s0,-40
    80005404:	4505                	li	a0,1
    80005406:	ffffe097          	auipc	ra,0xffffe
    8000540a:	8c8080e7          	jalr	-1848(ra) # 80002cce <argaddr>
  argint(2, &n);
    8000540e:	fe440593          	addi	a1,s0,-28
    80005412:	4509                	li	a0,2
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	89a080e7          	jalr	-1894(ra) # 80002cae <argint>
  if(argfd(0, 0, &f) < 0)
    8000541c:	fe840613          	addi	a2,s0,-24
    80005420:	4581                	li	a1,0
    80005422:	4501                	li	a0,0
    80005424:	00000097          	auipc	ra,0x0
    80005428:	d5a080e7          	jalr	-678(ra) # 8000517e <argfd>
    8000542c:	87aa                	mv	a5,a0
    return -1;
    8000542e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005430:	0007cc63          	bltz	a5,80005448 <sys_read+0x50>
  return fileread(f, p, n);
    80005434:	fe442603          	lw	a2,-28(s0)
    80005438:	fd843583          	ld	a1,-40(s0)
    8000543c:	fe843503          	ld	a0,-24(s0)
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	43e080e7          	jalr	1086(ra) # 8000487e <fileread>
}
    80005448:	70a2                	ld	ra,40(sp)
    8000544a:	7402                	ld	s0,32(sp)
    8000544c:	6145                	addi	sp,sp,48
    8000544e:	8082                	ret

0000000080005450 <sys_write>:
{
    80005450:	7179                	addi	sp,sp,-48
    80005452:	f406                	sd	ra,40(sp)
    80005454:	f022                	sd	s0,32(sp)
    80005456:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005458:	fd840593          	addi	a1,s0,-40
    8000545c:	4505                	li	a0,1
    8000545e:	ffffe097          	auipc	ra,0xffffe
    80005462:	870080e7          	jalr	-1936(ra) # 80002cce <argaddr>
  argint(2, &n);
    80005466:	fe440593          	addi	a1,s0,-28
    8000546a:	4509                	li	a0,2
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	842080e7          	jalr	-1982(ra) # 80002cae <argint>
  if(argfd(0, 0, &f) < 0)
    80005474:	fe840613          	addi	a2,s0,-24
    80005478:	4581                	li	a1,0
    8000547a:	4501                	li	a0,0
    8000547c:	00000097          	auipc	ra,0x0
    80005480:	d02080e7          	jalr	-766(ra) # 8000517e <argfd>
    80005484:	87aa                	mv	a5,a0
    return -1;
    80005486:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005488:	0007cc63          	bltz	a5,800054a0 <sys_write+0x50>
  return filewrite(f, p, n);
    8000548c:	fe442603          	lw	a2,-28(s0)
    80005490:	fd843583          	ld	a1,-40(s0)
    80005494:	fe843503          	ld	a0,-24(s0)
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	4a8080e7          	jalr	1192(ra) # 80004940 <filewrite>
}
    800054a0:	70a2                	ld	ra,40(sp)
    800054a2:	7402                	ld	s0,32(sp)
    800054a4:	6145                	addi	sp,sp,48
    800054a6:	8082                	ret

00000000800054a8 <sys_close>:
{
    800054a8:	1101                	addi	sp,sp,-32
    800054aa:	ec06                	sd	ra,24(sp)
    800054ac:	e822                	sd	s0,16(sp)
    800054ae:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054b0:	fe040613          	addi	a2,s0,-32
    800054b4:	fec40593          	addi	a1,s0,-20
    800054b8:	4501                	li	a0,0
    800054ba:	00000097          	auipc	ra,0x0
    800054be:	cc4080e7          	jalr	-828(ra) # 8000517e <argfd>
    return -1;
    800054c2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054c4:	02054463          	bltz	a0,800054ec <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054c8:	ffffc097          	auipc	ra,0xffffc
    800054cc:	4f4080e7          	jalr	1268(ra) # 800019bc <myproc>
    800054d0:	fec42783          	lw	a5,-20(s0)
    800054d4:	07e9                	addi	a5,a5,26
    800054d6:	078e                	slli	a5,a5,0x3
    800054d8:	97aa                	add	a5,a5,a0
    800054da:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800054de:	fe043503          	ld	a0,-32(s0)
    800054e2:	fffff097          	auipc	ra,0xfffff
    800054e6:	262080e7          	jalr	610(ra) # 80004744 <fileclose>
  return 0;
    800054ea:	4781                	li	a5,0
}
    800054ec:	853e                	mv	a0,a5
    800054ee:	60e2                	ld	ra,24(sp)
    800054f0:	6442                	ld	s0,16(sp)
    800054f2:	6105                	addi	sp,sp,32
    800054f4:	8082                	ret

00000000800054f6 <sys_fstat>:
{
    800054f6:	1101                	addi	sp,sp,-32
    800054f8:	ec06                	sd	ra,24(sp)
    800054fa:	e822                	sd	s0,16(sp)
    800054fc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800054fe:	fe040593          	addi	a1,s0,-32
    80005502:	4505                	li	a0,1
    80005504:	ffffd097          	auipc	ra,0xffffd
    80005508:	7ca080e7          	jalr	1994(ra) # 80002cce <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000550c:	fe840613          	addi	a2,s0,-24
    80005510:	4581                	li	a1,0
    80005512:	4501                	li	a0,0
    80005514:	00000097          	auipc	ra,0x0
    80005518:	c6a080e7          	jalr	-918(ra) # 8000517e <argfd>
    8000551c:	87aa                	mv	a5,a0
    return -1;
    8000551e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005520:	0007ca63          	bltz	a5,80005534 <sys_fstat+0x3e>
  return filestat(f, st);
    80005524:	fe043583          	ld	a1,-32(s0)
    80005528:	fe843503          	ld	a0,-24(s0)
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	2e0080e7          	jalr	736(ra) # 8000480c <filestat>
}
    80005534:	60e2                	ld	ra,24(sp)
    80005536:	6442                	ld	s0,16(sp)
    80005538:	6105                	addi	sp,sp,32
    8000553a:	8082                	ret

000000008000553c <sys_link>:
{
    8000553c:	7169                	addi	sp,sp,-304
    8000553e:	f606                	sd	ra,296(sp)
    80005540:	f222                	sd	s0,288(sp)
    80005542:	ee26                	sd	s1,280(sp)
    80005544:	ea4a                	sd	s2,272(sp)
    80005546:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005548:	08000613          	li	a2,128
    8000554c:	ed040593          	addi	a1,s0,-304
    80005550:	4501                	li	a0,0
    80005552:	ffffd097          	auipc	ra,0xffffd
    80005556:	79c080e7          	jalr	1948(ra) # 80002cee <argstr>
    return -1;
    8000555a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000555c:	10054e63          	bltz	a0,80005678 <sys_link+0x13c>
    80005560:	08000613          	li	a2,128
    80005564:	f5040593          	addi	a1,s0,-176
    80005568:	4505                	li	a0,1
    8000556a:	ffffd097          	auipc	ra,0xffffd
    8000556e:	784080e7          	jalr	1924(ra) # 80002cee <argstr>
    return -1;
    80005572:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005574:	10054263          	bltz	a0,80005678 <sys_link+0x13c>
  begin_op();
    80005578:	fffff097          	auipc	ra,0xfffff
    8000557c:	d00080e7          	jalr	-768(ra) # 80004278 <begin_op>
  if((ip = namei(old)) == 0){
    80005580:	ed040513          	addi	a0,s0,-304
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	ad8080e7          	jalr	-1320(ra) # 8000405c <namei>
    8000558c:	84aa                	mv	s1,a0
    8000558e:	c551                	beqz	a0,8000561a <sys_link+0xde>
  ilock(ip);
    80005590:	ffffe097          	auipc	ra,0xffffe
    80005594:	326080e7          	jalr	806(ra) # 800038b6 <ilock>
  if(ip->type == T_DIR){
    80005598:	04449703          	lh	a4,68(s1)
    8000559c:	4785                	li	a5,1
    8000559e:	08f70463          	beq	a4,a5,80005626 <sys_link+0xea>
  ip->nlink++;
    800055a2:	04a4d783          	lhu	a5,74(s1)
    800055a6:	2785                	addiw	a5,a5,1
    800055a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055ac:	8526                	mv	a0,s1
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	23e080e7          	jalr	574(ra) # 800037ec <iupdate>
  iunlock(ip);
    800055b6:	8526                	mv	a0,s1
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	3c0080e7          	jalr	960(ra) # 80003978 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055c0:	fd040593          	addi	a1,s0,-48
    800055c4:	f5040513          	addi	a0,s0,-176
    800055c8:	fffff097          	auipc	ra,0xfffff
    800055cc:	ab2080e7          	jalr	-1358(ra) # 8000407a <nameiparent>
    800055d0:	892a                	mv	s2,a0
    800055d2:	c935                	beqz	a0,80005646 <sys_link+0x10a>
  ilock(dp);
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	2e2080e7          	jalr	738(ra) # 800038b6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055dc:	00092703          	lw	a4,0(s2)
    800055e0:	409c                	lw	a5,0(s1)
    800055e2:	04f71d63          	bne	a4,a5,8000563c <sys_link+0x100>
    800055e6:	40d0                	lw	a2,4(s1)
    800055e8:	fd040593          	addi	a1,s0,-48
    800055ec:	854a                	mv	a0,s2
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	9bc080e7          	jalr	-1604(ra) # 80003faa <dirlink>
    800055f6:	04054363          	bltz	a0,8000563c <sys_link+0x100>
  iunlockput(dp);
    800055fa:	854a                	mv	a0,s2
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	51c080e7          	jalr	1308(ra) # 80003b18 <iunlockput>
  iput(ip);
    80005604:	8526                	mv	a0,s1
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	46a080e7          	jalr	1130(ra) # 80003a70 <iput>
  end_op();
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	cea080e7          	jalr	-790(ra) # 800042f8 <end_op>
  return 0;
    80005616:	4781                	li	a5,0
    80005618:	a085                	j	80005678 <sys_link+0x13c>
    end_op();
    8000561a:	fffff097          	auipc	ra,0xfffff
    8000561e:	cde080e7          	jalr	-802(ra) # 800042f8 <end_op>
    return -1;
    80005622:	57fd                	li	a5,-1
    80005624:	a891                	j	80005678 <sys_link+0x13c>
    iunlockput(ip);
    80005626:	8526                	mv	a0,s1
    80005628:	ffffe097          	auipc	ra,0xffffe
    8000562c:	4f0080e7          	jalr	1264(ra) # 80003b18 <iunlockput>
    end_op();
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	cc8080e7          	jalr	-824(ra) # 800042f8 <end_op>
    return -1;
    80005638:	57fd                	li	a5,-1
    8000563a:	a83d                	j	80005678 <sys_link+0x13c>
    iunlockput(dp);
    8000563c:	854a                	mv	a0,s2
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	4da080e7          	jalr	1242(ra) # 80003b18 <iunlockput>
  ilock(ip);
    80005646:	8526                	mv	a0,s1
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	26e080e7          	jalr	622(ra) # 800038b6 <ilock>
  ip->nlink--;
    80005650:	04a4d783          	lhu	a5,74(s1)
    80005654:	37fd                	addiw	a5,a5,-1
    80005656:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000565a:	8526                	mv	a0,s1
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	190080e7          	jalr	400(ra) # 800037ec <iupdate>
  iunlockput(ip);
    80005664:	8526                	mv	a0,s1
    80005666:	ffffe097          	auipc	ra,0xffffe
    8000566a:	4b2080e7          	jalr	1202(ra) # 80003b18 <iunlockput>
  end_op();
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	c8a080e7          	jalr	-886(ra) # 800042f8 <end_op>
  return -1;
    80005676:	57fd                	li	a5,-1
}
    80005678:	853e                	mv	a0,a5
    8000567a:	70b2                	ld	ra,296(sp)
    8000567c:	7412                	ld	s0,288(sp)
    8000567e:	64f2                	ld	s1,280(sp)
    80005680:	6952                	ld	s2,272(sp)
    80005682:	6155                	addi	sp,sp,304
    80005684:	8082                	ret

0000000080005686 <sys_unlink>:
{
    80005686:	7151                	addi	sp,sp,-240
    80005688:	f586                	sd	ra,232(sp)
    8000568a:	f1a2                	sd	s0,224(sp)
    8000568c:	eda6                	sd	s1,216(sp)
    8000568e:	e9ca                	sd	s2,208(sp)
    80005690:	e5ce                	sd	s3,200(sp)
    80005692:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005694:	08000613          	li	a2,128
    80005698:	f3040593          	addi	a1,s0,-208
    8000569c:	4501                	li	a0,0
    8000569e:	ffffd097          	auipc	ra,0xffffd
    800056a2:	650080e7          	jalr	1616(ra) # 80002cee <argstr>
    800056a6:	18054163          	bltz	a0,80005828 <sys_unlink+0x1a2>
  begin_op();
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	bce080e7          	jalr	-1074(ra) # 80004278 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056b2:	fb040593          	addi	a1,s0,-80
    800056b6:	f3040513          	addi	a0,s0,-208
    800056ba:	fffff097          	auipc	ra,0xfffff
    800056be:	9c0080e7          	jalr	-1600(ra) # 8000407a <nameiparent>
    800056c2:	84aa                	mv	s1,a0
    800056c4:	c979                	beqz	a0,8000579a <sys_unlink+0x114>
  ilock(dp);
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	1f0080e7          	jalr	496(ra) # 800038b6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056ce:	00003597          	auipc	a1,0x3
    800056d2:	05258593          	addi	a1,a1,82 # 80008720 <syscalls+0x2a8>
    800056d6:	fb040513          	addi	a0,s0,-80
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	6a6080e7          	jalr	1702(ra) # 80003d80 <namecmp>
    800056e2:	14050a63          	beqz	a0,80005836 <sys_unlink+0x1b0>
    800056e6:	00003597          	auipc	a1,0x3
    800056ea:	04258593          	addi	a1,a1,66 # 80008728 <syscalls+0x2b0>
    800056ee:	fb040513          	addi	a0,s0,-80
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	68e080e7          	jalr	1678(ra) # 80003d80 <namecmp>
    800056fa:	12050e63          	beqz	a0,80005836 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056fe:	f2c40613          	addi	a2,s0,-212
    80005702:	fb040593          	addi	a1,s0,-80
    80005706:	8526                	mv	a0,s1
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	692080e7          	jalr	1682(ra) # 80003d9a <dirlookup>
    80005710:	892a                	mv	s2,a0
    80005712:	12050263          	beqz	a0,80005836 <sys_unlink+0x1b0>
  ilock(ip);
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	1a0080e7          	jalr	416(ra) # 800038b6 <ilock>
  if(ip->nlink < 1)
    8000571e:	04a91783          	lh	a5,74(s2)
    80005722:	08f05263          	blez	a5,800057a6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005726:	04491703          	lh	a4,68(s2)
    8000572a:	4785                	li	a5,1
    8000572c:	08f70563          	beq	a4,a5,800057b6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005730:	4641                	li	a2,16
    80005732:	4581                	li	a1,0
    80005734:	fc040513          	addi	a0,s0,-64
    80005738:	ffffb097          	auipc	ra,0xffffb
    8000573c:	59a080e7          	jalr	1434(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005740:	4741                	li	a4,16
    80005742:	f2c42683          	lw	a3,-212(s0)
    80005746:	fc040613          	addi	a2,s0,-64
    8000574a:	4581                	li	a1,0
    8000574c:	8526                	mv	a0,s1
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	514080e7          	jalr	1300(ra) # 80003c62 <writei>
    80005756:	47c1                	li	a5,16
    80005758:	0af51563          	bne	a0,a5,80005802 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000575c:	04491703          	lh	a4,68(s2)
    80005760:	4785                	li	a5,1
    80005762:	0af70863          	beq	a4,a5,80005812 <sys_unlink+0x18c>
  iunlockput(dp);
    80005766:	8526                	mv	a0,s1
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	3b0080e7          	jalr	944(ra) # 80003b18 <iunlockput>
  ip->nlink--;
    80005770:	04a95783          	lhu	a5,74(s2)
    80005774:	37fd                	addiw	a5,a5,-1
    80005776:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000577a:	854a                	mv	a0,s2
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	070080e7          	jalr	112(ra) # 800037ec <iupdate>
  iunlockput(ip);
    80005784:	854a                	mv	a0,s2
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	392080e7          	jalr	914(ra) # 80003b18 <iunlockput>
  end_op();
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	b6a080e7          	jalr	-1174(ra) # 800042f8 <end_op>
  return 0;
    80005796:	4501                	li	a0,0
    80005798:	a84d                	j	8000584a <sys_unlink+0x1c4>
    end_op();
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	b5e080e7          	jalr	-1186(ra) # 800042f8 <end_op>
    return -1;
    800057a2:	557d                	li	a0,-1
    800057a4:	a05d                	j	8000584a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057a6:	00003517          	auipc	a0,0x3
    800057aa:	f8a50513          	addi	a0,a0,-118 # 80008730 <syscalls+0x2b8>
    800057ae:	ffffb097          	auipc	ra,0xffffb
    800057b2:	d90080e7          	jalr	-624(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057b6:	04c92703          	lw	a4,76(s2)
    800057ba:	02000793          	li	a5,32
    800057be:	f6e7f9e3          	bgeu	a5,a4,80005730 <sys_unlink+0xaa>
    800057c2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057c6:	4741                	li	a4,16
    800057c8:	86ce                	mv	a3,s3
    800057ca:	f1840613          	addi	a2,s0,-232
    800057ce:	4581                	li	a1,0
    800057d0:	854a                	mv	a0,s2
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	398080e7          	jalr	920(ra) # 80003b6a <readi>
    800057da:	47c1                	li	a5,16
    800057dc:	00f51b63          	bne	a0,a5,800057f2 <sys_unlink+0x16c>
    if(de.inum != 0)
    800057e0:	f1845783          	lhu	a5,-232(s0)
    800057e4:	e7a1                	bnez	a5,8000582c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057e6:	29c1                	addiw	s3,s3,16
    800057e8:	04c92783          	lw	a5,76(s2)
    800057ec:	fcf9ede3          	bltu	s3,a5,800057c6 <sys_unlink+0x140>
    800057f0:	b781                	j	80005730 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057f2:	00003517          	auipc	a0,0x3
    800057f6:	f5650513          	addi	a0,a0,-170 # 80008748 <syscalls+0x2d0>
    800057fa:	ffffb097          	auipc	ra,0xffffb
    800057fe:	d44080e7          	jalr	-700(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005802:	00003517          	auipc	a0,0x3
    80005806:	f5e50513          	addi	a0,a0,-162 # 80008760 <syscalls+0x2e8>
    8000580a:	ffffb097          	auipc	ra,0xffffb
    8000580e:	d34080e7          	jalr	-716(ra) # 8000053e <panic>
    dp->nlink--;
    80005812:	04a4d783          	lhu	a5,74(s1)
    80005816:	37fd                	addiw	a5,a5,-1
    80005818:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000581c:	8526                	mv	a0,s1
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	fce080e7          	jalr	-50(ra) # 800037ec <iupdate>
    80005826:	b781                	j	80005766 <sys_unlink+0xe0>
    return -1;
    80005828:	557d                	li	a0,-1
    8000582a:	a005                	j	8000584a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000582c:	854a                	mv	a0,s2
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	2ea080e7          	jalr	746(ra) # 80003b18 <iunlockput>
  iunlockput(dp);
    80005836:	8526                	mv	a0,s1
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	2e0080e7          	jalr	736(ra) # 80003b18 <iunlockput>
  end_op();
    80005840:	fffff097          	auipc	ra,0xfffff
    80005844:	ab8080e7          	jalr	-1352(ra) # 800042f8 <end_op>
  return -1;
    80005848:	557d                	li	a0,-1
}
    8000584a:	70ae                	ld	ra,232(sp)
    8000584c:	740e                	ld	s0,224(sp)
    8000584e:	64ee                	ld	s1,216(sp)
    80005850:	694e                	ld	s2,208(sp)
    80005852:	69ae                	ld	s3,200(sp)
    80005854:	616d                	addi	sp,sp,240
    80005856:	8082                	ret

0000000080005858 <sys_open>:

uint64
sys_open(void)
{
    80005858:	7131                	addi	sp,sp,-192
    8000585a:	fd06                	sd	ra,184(sp)
    8000585c:	f922                	sd	s0,176(sp)
    8000585e:	f526                	sd	s1,168(sp)
    80005860:	f14a                	sd	s2,160(sp)
    80005862:	ed4e                	sd	s3,152(sp)
    80005864:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005866:	f4c40593          	addi	a1,s0,-180
    8000586a:	4505                	li	a0,1
    8000586c:	ffffd097          	auipc	ra,0xffffd
    80005870:	442080e7          	jalr	1090(ra) # 80002cae <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005874:	08000613          	li	a2,128
    80005878:	f5040593          	addi	a1,s0,-176
    8000587c:	4501                	li	a0,0
    8000587e:	ffffd097          	auipc	ra,0xffffd
    80005882:	470080e7          	jalr	1136(ra) # 80002cee <argstr>
    80005886:	87aa                	mv	a5,a0
    return -1;
    80005888:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000588a:	0a07c963          	bltz	a5,8000593c <sys_open+0xe4>

  begin_op();
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	9ea080e7          	jalr	-1558(ra) # 80004278 <begin_op>

  if(omode & O_CREATE){
    80005896:	f4c42783          	lw	a5,-180(s0)
    8000589a:	2007f793          	andi	a5,a5,512
    8000589e:	cfc5                	beqz	a5,80005956 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058a0:	4681                	li	a3,0
    800058a2:	4601                	li	a2,0
    800058a4:	4589                	li	a1,2
    800058a6:	f5040513          	addi	a0,s0,-176
    800058aa:	00000097          	auipc	ra,0x0
    800058ae:	976080e7          	jalr	-1674(ra) # 80005220 <create>
    800058b2:	84aa                	mv	s1,a0
    if(ip == 0){
    800058b4:	c959                	beqz	a0,8000594a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058b6:	04449703          	lh	a4,68(s1)
    800058ba:	478d                	li	a5,3
    800058bc:	00f71763          	bne	a4,a5,800058ca <sys_open+0x72>
    800058c0:	0464d703          	lhu	a4,70(s1)
    800058c4:	47a5                	li	a5,9
    800058c6:	0ce7ed63          	bltu	a5,a4,800059a0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	dbe080e7          	jalr	-578(ra) # 80004688 <filealloc>
    800058d2:	89aa                	mv	s3,a0
    800058d4:	10050363          	beqz	a0,800059da <sys_open+0x182>
    800058d8:	00000097          	auipc	ra,0x0
    800058dc:	906080e7          	jalr	-1786(ra) # 800051de <fdalloc>
    800058e0:	892a                	mv	s2,a0
    800058e2:	0e054763          	bltz	a0,800059d0 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058e6:	04449703          	lh	a4,68(s1)
    800058ea:	478d                	li	a5,3
    800058ec:	0cf70563          	beq	a4,a5,800059b6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058f0:	4789                	li	a5,2
    800058f2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800058f6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800058fa:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800058fe:	f4c42783          	lw	a5,-180(s0)
    80005902:	0017c713          	xori	a4,a5,1
    80005906:	8b05                	andi	a4,a4,1
    80005908:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000590c:	0037f713          	andi	a4,a5,3
    80005910:	00e03733          	snez	a4,a4
    80005914:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005918:	4007f793          	andi	a5,a5,1024
    8000591c:	c791                	beqz	a5,80005928 <sys_open+0xd0>
    8000591e:	04449703          	lh	a4,68(s1)
    80005922:	4789                	li	a5,2
    80005924:	0af70063          	beq	a4,a5,800059c4 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005928:	8526                	mv	a0,s1
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	04e080e7          	jalr	78(ra) # 80003978 <iunlock>
  end_op();
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	9c6080e7          	jalr	-1594(ra) # 800042f8 <end_op>

  return fd;
    8000593a:	854a                	mv	a0,s2
}
    8000593c:	70ea                	ld	ra,184(sp)
    8000593e:	744a                	ld	s0,176(sp)
    80005940:	74aa                	ld	s1,168(sp)
    80005942:	790a                	ld	s2,160(sp)
    80005944:	69ea                	ld	s3,152(sp)
    80005946:	6129                	addi	sp,sp,192
    80005948:	8082                	ret
      end_op();
    8000594a:	fffff097          	auipc	ra,0xfffff
    8000594e:	9ae080e7          	jalr	-1618(ra) # 800042f8 <end_op>
      return -1;
    80005952:	557d                	li	a0,-1
    80005954:	b7e5                	j	8000593c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005956:	f5040513          	addi	a0,s0,-176
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	702080e7          	jalr	1794(ra) # 8000405c <namei>
    80005962:	84aa                	mv	s1,a0
    80005964:	c905                	beqz	a0,80005994 <sys_open+0x13c>
    ilock(ip);
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	f50080e7          	jalr	-176(ra) # 800038b6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000596e:	04449703          	lh	a4,68(s1)
    80005972:	4785                	li	a5,1
    80005974:	f4f711e3          	bne	a4,a5,800058b6 <sys_open+0x5e>
    80005978:	f4c42783          	lw	a5,-180(s0)
    8000597c:	d7b9                	beqz	a5,800058ca <sys_open+0x72>
      iunlockput(ip);
    8000597e:	8526                	mv	a0,s1
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	198080e7          	jalr	408(ra) # 80003b18 <iunlockput>
      end_op();
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	970080e7          	jalr	-1680(ra) # 800042f8 <end_op>
      return -1;
    80005990:	557d                	li	a0,-1
    80005992:	b76d                	j	8000593c <sys_open+0xe4>
      end_op();
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	964080e7          	jalr	-1692(ra) # 800042f8 <end_op>
      return -1;
    8000599c:	557d                	li	a0,-1
    8000599e:	bf79                	j	8000593c <sys_open+0xe4>
    iunlockput(ip);
    800059a0:	8526                	mv	a0,s1
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	176080e7          	jalr	374(ra) # 80003b18 <iunlockput>
    end_op();
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	94e080e7          	jalr	-1714(ra) # 800042f8 <end_op>
    return -1;
    800059b2:	557d                	li	a0,-1
    800059b4:	b761                	j	8000593c <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059b6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059ba:	04649783          	lh	a5,70(s1)
    800059be:	02f99223          	sh	a5,36(s3)
    800059c2:	bf25                	j	800058fa <sys_open+0xa2>
    itrunc(ip);
    800059c4:	8526                	mv	a0,s1
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	ffe080e7          	jalr	-2(ra) # 800039c4 <itrunc>
    800059ce:	bfa9                	j	80005928 <sys_open+0xd0>
      fileclose(f);
    800059d0:	854e                	mv	a0,s3
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	d72080e7          	jalr	-654(ra) # 80004744 <fileclose>
    iunlockput(ip);
    800059da:	8526                	mv	a0,s1
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	13c080e7          	jalr	316(ra) # 80003b18 <iunlockput>
    end_op();
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	914080e7          	jalr	-1772(ra) # 800042f8 <end_op>
    return -1;
    800059ec:	557d                	li	a0,-1
    800059ee:	b7b9                	j	8000593c <sys_open+0xe4>

00000000800059f0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059f0:	7175                	addi	sp,sp,-144
    800059f2:	e506                	sd	ra,136(sp)
    800059f4:	e122                	sd	s0,128(sp)
    800059f6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	880080e7          	jalr	-1920(ra) # 80004278 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a00:	08000613          	li	a2,128
    80005a04:	f7040593          	addi	a1,s0,-144
    80005a08:	4501                	li	a0,0
    80005a0a:	ffffd097          	auipc	ra,0xffffd
    80005a0e:	2e4080e7          	jalr	740(ra) # 80002cee <argstr>
    80005a12:	02054963          	bltz	a0,80005a44 <sys_mkdir+0x54>
    80005a16:	4681                	li	a3,0
    80005a18:	4601                	li	a2,0
    80005a1a:	4585                	li	a1,1
    80005a1c:	f7040513          	addi	a0,s0,-144
    80005a20:	00000097          	auipc	ra,0x0
    80005a24:	800080e7          	jalr	-2048(ra) # 80005220 <create>
    80005a28:	cd11                	beqz	a0,80005a44 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	0ee080e7          	jalr	238(ra) # 80003b18 <iunlockput>
  end_op();
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	8c6080e7          	jalr	-1850(ra) # 800042f8 <end_op>
  return 0;
    80005a3a:	4501                	li	a0,0
}
    80005a3c:	60aa                	ld	ra,136(sp)
    80005a3e:	640a                	ld	s0,128(sp)
    80005a40:	6149                	addi	sp,sp,144
    80005a42:	8082                	ret
    end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	8b4080e7          	jalr	-1868(ra) # 800042f8 <end_op>
    return -1;
    80005a4c:	557d                	li	a0,-1
    80005a4e:	b7fd                	j	80005a3c <sys_mkdir+0x4c>

0000000080005a50 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a50:	7135                	addi	sp,sp,-160
    80005a52:	ed06                	sd	ra,152(sp)
    80005a54:	e922                	sd	s0,144(sp)
    80005a56:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	820080e7          	jalr	-2016(ra) # 80004278 <begin_op>
  argint(1, &major);
    80005a60:	f6c40593          	addi	a1,s0,-148
    80005a64:	4505                	li	a0,1
    80005a66:	ffffd097          	auipc	ra,0xffffd
    80005a6a:	248080e7          	jalr	584(ra) # 80002cae <argint>
  argint(2, &minor);
    80005a6e:	f6840593          	addi	a1,s0,-152
    80005a72:	4509                	li	a0,2
    80005a74:	ffffd097          	auipc	ra,0xffffd
    80005a78:	23a080e7          	jalr	570(ra) # 80002cae <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a7c:	08000613          	li	a2,128
    80005a80:	f7040593          	addi	a1,s0,-144
    80005a84:	4501                	li	a0,0
    80005a86:	ffffd097          	auipc	ra,0xffffd
    80005a8a:	268080e7          	jalr	616(ra) # 80002cee <argstr>
    80005a8e:	02054b63          	bltz	a0,80005ac4 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a92:	f6841683          	lh	a3,-152(s0)
    80005a96:	f6c41603          	lh	a2,-148(s0)
    80005a9a:	458d                	li	a1,3
    80005a9c:	f7040513          	addi	a0,s0,-144
    80005aa0:	fffff097          	auipc	ra,0xfffff
    80005aa4:	780080e7          	jalr	1920(ra) # 80005220 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa8:	cd11                	beqz	a0,80005ac4 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	06e080e7          	jalr	110(ra) # 80003b18 <iunlockput>
  end_op();
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	846080e7          	jalr	-1978(ra) # 800042f8 <end_op>
  return 0;
    80005aba:	4501                	li	a0,0
}
    80005abc:	60ea                	ld	ra,152(sp)
    80005abe:	644a                	ld	s0,144(sp)
    80005ac0:	610d                	addi	sp,sp,160
    80005ac2:	8082                	ret
    end_op();
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	834080e7          	jalr	-1996(ra) # 800042f8 <end_op>
    return -1;
    80005acc:	557d                	li	a0,-1
    80005ace:	b7fd                	j	80005abc <sys_mknod+0x6c>

0000000080005ad0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ad0:	7135                	addi	sp,sp,-160
    80005ad2:	ed06                	sd	ra,152(sp)
    80005ad4:	e922                	sd	s0,144(sp)
    80005ad6:	e526                	sd	s1,136(sp)
    80005ad8:	e14a                	sd	s2,128(sp)
    80005ada:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005adc:	ffffc097          	auipc	ra,0xffffc
    80005ae0:	ee0080e7          	jalr	-288(ra) # 800019bc <myproc>
    80005ae4:	892a                	mv	s2,a0
  
  begin_op();
    80005ae6:	ffffe097          	auipc	ra,0xffffe
    80005aea:	792080e7          	jalr	1938(ra) # 80004278 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005aee:	08000613          	li	a2,128
    80005af2:	f6040593          	addi	a1,s0,-160
    80005af6:	4501                	li	a0,0
    80005af8:	ffffd097          	auipc	ra,0xffffd
    80005afc:	1f6080e7          	jalr	502(ra) # 80002cee <argstr>
    80005b00:	04054b63          	bltz	a0,80005b56 <sys_chdir+0x86>
    80005b04:	f6040513          	addi	a0,s0,-160
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	554080e7          	jalr	1364(ra) # 8000405c <namei>
    80005b10:	84aa                	mv	s1,a0
    80005b12:	c131                	beqz	a0,80005b56 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	da2080e7          	jalr	-606(ra) # 800038b6 <ilock>
  if(ip->type != T_DIR){
    80005b1c:	04449703          	lh	a4,68(s1)
    80005b20:	4785                	li	a5,1
    80005b22:	04f71063          	bne	a4,a5,80005b62 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b26:	8526                	mv	a0,s1
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	e50080e7          	jalr	-432(ra) # 80003978 <iunlock>
  iput(p->cwd);
    80005b30:	15093503          	ld	a0,336(s2)
    80005b34:	ffffe097          	auipc	ra,0xffffe
    80005b38:	f3c080e7          	jalr	-196(ra) # 80003a70 <iput>
  end_op();
    80005b3c:	ffffe097          	auipc	ra,0xffffe
    80005b40:	7bc080e7          	jalr	1980(ra) # 800042f8 <end_op>
  p->cwd = ip;
    80005b44:	14993823          	sd	s1,336(s2)
  return 0;
    80005b48:	4501                	li	a0,0
}
    80005b4a:	60ea                	ld	ra,152(sp)
    80005b4c:	644a                	ld	s0,144(sp)
    80005b4e:	64aa                	ld	s1,136(sp)
    80005b50:	690a                	ld	s2,128(sp)
    80005b52:	610d                	addi	sp,sp,160
    80005b54:	8082                	ret
    end_op();
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	7a2080e7          	jalr	1954(ra) # 800042f8 <end_op>
    return -1;
    80005b5e:	557d                	li	a0,-1
    80005b60:	b7ed                	j	80005b4a <sys_chdir+0x7a>
    iunlockput(ip);
    80005b62:	8526                	mv	a0,s1
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	fb4080e7          	jalr	-76(ra) # 80003b18 <iunlockput>
    end_op();
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	78c080e7          	jalr	1932(ra) # 800042f8 <end_op>
    return -1;
    80005b74:	557d                	li	a0,-1
    80005b76:	bfd1                	j	80005b4a <sys_chdir+0x7a>

0000000080005b78 <sys_exec>:

uint64
sys_exec(void)
{
    80005b78:	7145                	addi	sp,sp,-464
    80005b7a:	e786                	sd	ra,456(sp)
    80005b7c:	e3a2                	sd	s0,448(sp)
    80005b7e:	ff26                	sd	s1,440(sp)
    80005b80:	fb4a                	sd	s2,432(sp)
    80005b82:	f74e                	sd	s3,424(sp)
    80005b84:	f352                	sd	s4,416(sp)
    80005b86:	ef56                	sd	s5,408(sp)
    80005b88:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b8a:	e3840593          	addi	a1,s0,-456
    80005b8e:	4505                	li	a0,1
    80005b90:	ffffd097          	auipc	ra,0xffffd
    80005b94:	13e080e7          	jalr	318(ra) # 80002cce <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b98:	08000613          	li	a2,128
    80005b9c:	f4040593          	addi	a1,s0,-192
    80005ba0:	4501                	li	a0,0
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	14c080e7          	jalr	332(ra) # 80002cee <argstr>
    80005baa:	87aa                	mv	a5,a0
    return -1;
    80005bac:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005bae:	0c07c263          	bltz	a5,80005c72 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005bb2:	10000613          	li	a2,256
    80005bb6:	4581                	li	a1,0
    80005bb8:	e4040513          	addi	a0,s0,-448
    80005bbc:	ffffb097          	auipc	ra,0xffffb
    80005bc0:	116080e7          	jalr	278(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bc4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005bc8:	89a6                	mv	s3,s1
    80005bca:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bcc:	02000a13          	li	s4,32
    80005bd0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bd4:	00391793          	slli	a5,s2,0x3
    80005bd8:	e3040593          	addi	a1,s0,-464
    80005bdc:	e3843503          	ld	a0,-456(s0)
    80005be0:	953e                	add	a0,a0,a5
    80005be2:	ffffd097          	auipc	ra,0xffffd
    80005be6:	02e080e7          	jalr	46(ra) # 80002c10 <fetchaddr>
    80005bea:	02054a63          	bltz	a0,80005c1e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005bee:	e3043783          	ld	a5,-464(s0)
    80005bf2:	c3b9                	beqz	a5,80005c38 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bf4:	ffffb097          	auipc	ra,0xffffb
    80005bf8:	ef2080e7          	jalr	-270(ra) # 80000ae6 <kalloc>
    80005bfc:	85aa                	mv	a1,a0
    80005bfe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c02:	cd11                	beqz	a0,80005c1e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c04:	6605                	lui	a2,0x1
    80005c06:	e3043503          	ld	a0,-464(s0)
    80005c0a:	ffffd097          	auipc	ra,0xffffd
    80005c0e:	058080e7          	jalr	88(ra) # 80002c62 <fetchstr>
    80005c12:	00054663          	bltz	a0,80005c1e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c16:	0905                	addi	s2,s2,1
    80005c18:	09a1                	addi	s3,s3,8
    80005c1a:	fb491be3          	bne	s2,s4,80005bd0 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c1e:	10048913          	addi	s2,s1,256
    80005c22:	6088                	ld	a0,0(s1)
    80005c24:	c531                	beqz	a0,80005c70 <sys_exec+0xf8>
    kfree(argv[i]);
    80005c26:	ffffb097          	auipc	ra,0xffffb
    80005c2a:	dc4080e7          	jalr	-572(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c2e:	04a1                	addi	s1,s1,8
    80005c30:	ff2499e3          	bne	s1,s2,80005c22 <sys_exec+0xaa>
  return -1;
    80005c34:	557d                	li	a0,-1
    80005c36:	a835                	j	80005c72 <sys_exec+0xfa>
      argv[i] = 0;
    80005c38:	0a8e                	slli	s5,s5,0x3
    80005c3a:	fc040793          	addi	a5,s0,-64
    80005c3e:	9abe                	add	s5,s5,a5
    80005c40:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c44:	e4040593          	addi	a1,s0,-448
    80005c48:	f4040513          	addi	a0,s0,-192
    80005c4c:	fffff097          	auipc	ra,0xfffff
    80005c50:	172080e7          	jalr	370(ra) # 80004dbe <exec>
    80005c54:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c56:	10048993          	addi	s3,s1,256
    80005c5a:	6088                	ld	a0,0(s1)
    80005c5c:	c901                	beqz	a0,80005c6c <sys_exec+0xf4>
    kfree(argv[i]);
    80005c5e:	ffffb097          	auipc	ra,0xffffb
    80005c62:	d8c080e7          	jalr	-628(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c66:	04a1                	addi	s1,s1,8
    80005c68:	ff3499e3          	bne	s1,s3,80005c5a <sys_exec+0xe2>
  return ret;
    80005c6c:	854a                	mv	a0,s2
    80005c6e:	a011                	j	80005c72 <sys_exec+0xfa>
  return -1;
    80005c70:	557d                	li	a0,-1
}
    80005c72:	60be                	ld	ra,456(sp)
    80005c74:	641e                	ld	s0,448(sp)
    80005c76:	74fa                	ld	s1,440(sp)
    80005c78:	795a                	ld	s2,432(sp)
    80005c7a:	79ba                	ld	s3,424(sp)
    80005c7c:	7a1a                	ld	s4,416(sp)
    80005c7e:	6afa                	ld	s5,408(sp)
    80005c80:	6179                	addi	sp,sp,464
    80005c82:	8082                	ret

0000000080005c84 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c84:	7139                	addi	sp,sp,-64
    80005c86:	fc06                	sd	ra,56(sp)
    80005c88:	f822                	sd	s0,48(sp)
    80005c8a:	f426                	sd	s1,40(sp)
    80005c8c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c8e:	ffffc097          	auipc	ra,0xffffc
    80005c92:	d2e080e7          	jalr	-722(ra) # 800019bc <myproc>
    80005c96:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c98:	fd840593          	addi	a1,s0,-40
    80005c9c:	4501                	li	a0,0
    80005c9e:	ffffd097          	auipc	ra,0xffffd
    80005ca2:	030080e7          	jalr	48(ra) # 80002cce <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ca6:	fc840593          	addi	a1,s0,-56
    80005caa:	fd040513          	addi	a0,s0,-48
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	dc6080e7          	jalr	-570(ra) # 80004a74 <pipealloc>
    return -1;
    80005cb6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cb8:	0c054463          	bltz	a0,80005d80 <sys_pipe+0xfc>
  fd0 = -1;
    80005cbc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cc0:	fd043503          	ld	a0,-48(s0)
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	51a080e7          	jalr	1306(ra) # 800051de <fdalloc>
    80005ccc:	fca42223          	sw	a0,-60(s0)
    80005cd0:	08054b63          	bltz	a0,80005d66 <sys_pipe+0xe2>
    80005cd4:	fc843503          	ld	a0,-56(s0)
    80005cd8:	fffff097          	auipc	ra,0xfffff
    80005cdc:	506080e7          	jalr	1286(ra) # 800051de <fdalloc>
    80005ce0:	fca42023          	sw	a0,-64(s0)
    80005ce4:	06054863          	bltz	a0,80005d54 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ce8:	4691                	li	a3,4
    80005cea:	fc440613          	addi	a2,s0,-60
    80005cee:	fd843583          	ld	a1,-40(s0)
    80005cf2:	68a8                	ld	a0,80(s1)
    80005cf4:	ffffc097          	auipc	ra,0xffffc
    80005cf8:	984080e7          	jalr	-1660(ra) # 80001678 <copyout>
    80005cfc:	02054063          	bltz	a0,80005d1c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d00:	4691                	li	a3,4
    80005d02:	fc040613          	addi	a2,s0,-64
    80005d06:	fd843583          	ld	a1,-40(s0)
    80005d0a:	0591                	addi	a1,a1,4
    80005d0c:	68a8                	ld	a0,80(s1)
    80005d0e:	ffffc097          	auipc	ra,0xffffc
    80005d12:	96a080e7          	jalr	-1686(ra) # 80001678 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d16:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d18:	06055463          	bgez	a0,80005d80 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d1c:	fc442783          	lw	a5,-60(s0)
    80005d20:	07e9                	addi	a5,a5,26
    80005d22:	078e                	slli	a5,a5,0x3
    80005d24:	97a6                	add	a5,a5,s1
    80005d26:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d2a:	fc042503          	lw	a0,-64(s0)
    80005d2e:	0569                	addi	a0,a0,26
    80005d30:	050e                	slli	a0,a0,0x3
    80005d32:	94aa                	add	s1,s1,a0
    80005d34:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d38:	fd043503          	ld	a0,-48(s0)
    80005d3c:	fffff097          	auipc	ra,0xfffff
    80005d40:	a08080e7          	jalr	-1528(ra) # 80004744 <fileclose>
    fileclose(wf);
    80005d44:	fc843503          	ld	a0,-56(s0)
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	9fc080e7          	jalr	-1540(ra) # 80004744 <fileclose>
    return -1;
    80005d50:	57fd                	li	a5,-1
    80005d52:	a03d                	j	80005d80 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005d54:	fc442783          	lw	a5,-60(s0)
    80005d58:	0007c763          	bltz	a5,80005d66 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005d5c:	07e9                	addi	a5,a5,26
    80005d5e:	078e                	slli	a5,a5,0x3
    80005d60:	94be                	add	s1,s1,a5
    80005d62:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d66:	fd043503          	ld	a0,-48(s0)
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	9da080e7          	jalr	-1574(ra) # 80004744 <fileclose>
    fileclose(wf);
    80005d72:	fc843503          	ld	a0,-56(s0)
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	9ce080e7          	jalr	-1586(ra) # 80004744 <fileclose>
    return -1;
    80005d7e:	57fd                	li	a5,-1
}
    80005d80:	853e                	mv	a0,a5
    80005d82:	70e2                	ld	ra,56(sp)
    80005d84:	7442                	ld	s0,48(sp)
    80005d86:	74a2                	ld	s1,40(sp)
    80005d88:	6121                	addi	sp,sp,64
    80005d8a:	8082                	ret
    80005d8c:	0000                	unimp
	...

0000000080005d90 <kernelvec>:
    80005d90:	7111                	addi	sp,sp,-256
    80005d92:	e006                	sd	ra,0(sp)
    80005d94:	e40a                	sd	sp,8(sp)
    80005d96:	e80e                	sd	gp,16(sp)
    80005d98:	ec12                	sd	tp,24(sp)
    80005d9a:	f016                	sd	t0,32(sp)
    80005d9c:	f41a                	sd	t1,40(sp)
    80005d9e:	f81e                	sd	t2,48(sp)
    80005da0:	fc22                	sd	s0,56(sp)
    80005da2:	e0a6                	sd	s1,64(sp)
    80005da4:	e4aa                	sd	a0,72(sp)
    80005da6:	e8ae                	sd	a1,80(sp)
    80005da8:	ecb2                	sd	a2,88(sp)
    80005daa:	f0b6                	sd	a3,96(sp)
    80005dac:	f4ba                	sd	a4,104(sp)
    80005dae:	f8be                	sd	a5,112(sp)
    80005db0:	fcc2                	sd	a6,120(sp)
    80005db2:	e146                	sd	a7,128(sp)
    80005db4:	e54a                	sd	s2,136(sp)
    80005db6:	e94e                	sd	s3,144(sp)
    80005db8:	ed52                	sd	s4,152(sp)
    80005dba:	f156                	sd	s5,160(sp)
    80005dbc:	f55a                	sd	s6,168(sp)
    80005dbe:	f95e                	sd	s7,176(sp)
    80005dc0:	fd62                	sd	s8,184(sp)
    80005dc2:	e1e6                	sd	s9,192(sp)
    80005dc4:	e5ea                	sd	s10,200(sp)
    80005dc6:	e9ee                	sd	s11,208(sp)
    80005dc8:	edf2                	sd	t3,216(sp)
    80005dca:	f1f6                	sd	t4,224(sp)
    80005dcc:	f5fa                	sd	t5,232(sp)
    80005dce:	f9fe                	sd	t6,240(sp)
    80005dd0:	d0dfc0ef          	jal	ra,80002adc <kerneltrap>
    80005dd4:	6082                	ld	ra,0(sp)
    80005dd6:	6122                	ld	sp,8(sp)
    80005dd8:	61c2                	ld	gp,16(sp)
    80005dda:	7282                	ld	t0,32(sp)
    80005ddc:	7322                	ld	t1,40(sp)
    80005dde:	73c2                	ld	t2,48(sp)
    80005de0:	7462                	ld	s0,56(sp)
    80005de2:	6486                	ld	s1,64(sp)
    80005de4:	6526                	ld	a0,72(sp)
    80005de6:	65c6                	ld	a1,80(sp)
    80005de8:	6666                	ld	a2,88(sp)
    80005dea:	7686                	ld	a3,96(sp)
    80005dec:	7726                	ld	a4,104(sp)
    80005dee:	77c6                	ld	a5,112(sp)
    80005df0:	7866                	ld	a6,120(sp)
    80005df2:	688a                	ld	a7,128(sp)
    80005df4:	692a                	ld	s2,136(sp)
    80005df6:	69ca                	ld	s3,144(sp)
    80005df8:	6a6a                	ld	s4,152(sp)
    80005dfa:	7a8a                	ld	s5,160(sp)
    80005dfc:	7b2a                	ld	s6,168(sp)
    80005dfe:	7bca                	ld	s7,176(sp)
    80005e00:	7c6a                	ld	s8,184(sp)
    80005e02:	6c8e                	ld	s9,192(sp)
    80005e04:	6d2e                	ld	s10,200(sp)
    80005e06:	6dce                	ld	s11,208(sp)
    80005e08:	6e6e                	ld	t3,216(sp)
    80005e0a:	7e8e                	ld	t4,224(sp)
    80005e0c:	7f2e                	ld	t5,232(sp)
    80005e0e:	7fce                	ld	t6,240(sp)
    80005e10:	6111                	addi	sp,sp,256
    80005e12:	10200073          	sret
    80005e16:	00000013          	nop
    80005e1a:	00000013          	nop
    80005e1e:	0001                	nop

0000000080005e20 <timervec>:
    80005e20:	34051573          	csrrw	a0,mscratch,a0
    80005e24:	e10c                	sd	a1,0(a0)
    80005e26:	e510                	sd	a2,8(a0)
    80005e28:	e914                	sd	a3,16(a0)
    80005e2a:	6d0c                	ld	a1,24(a0)
    80005e2c:	7110                	ld	a2,32(a0)
    80005e2e:	6194                	ld	a3,0(a1)
    80005e30:	96b2                	add	a3,a3,a2
    80005e32:	e194                	sd	a3,0(a1)
    80005e34:	4589                	li	a1,2
    80005e36:	14459073          	csrw	sip,a1
    80005e3a:	6914                	ld	a3,16(a0)
    80005e3c:	6510                	ld	a2,8(a0)
    80005e3e:	610c                	ld	a1,0(a0)
    80005e40:	34051573          	csrrw	a0,mscratch,a0
    80005e44:	30200073          	mret
	...

0000000080005e4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e4a:	1141                	addi	sp,sp,-16
    80005e4c:	e422                	sd	s0,8(sp)
    80005e4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e50:	0c0007b7          	lui	a5,0xc000
    80005e54:	4705                	li	a4,1
    80005e56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e58:	c3d8                	sw	a4,4(a5)
}
    80005e5a:	6422                	ld	s0,8(sp)
    80005e5c:	0141                	addi	sp,sp,16
    80005e5e:	8082                	ret

0000000080005e60 <plicinithart>:

void
plicinithart(void)
{
    80005e60:	1141                	addi	sp,sp,-16
    80005e62:	e406                	sd	ra,8(sp)
    80005e64:	e022                	sd	s0,0(sp)
    80005e66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e68:	ffffc097          	auipc	ra,0xffffc
    80005e6c:	b28080e7          	jalr	-1240(ra) # 80001990 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e70:	0085171b          	slliw	a4,a0,0x8
    80005e74:	0c0027b7          	lui	a5,0xc002
    80005e78:	97ba                	add	a5,a5,a4
    80005e7a:	40200713          	li	a4,1026
    80005e7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e82:	00d5151b          	slliw	a0,a0,0xd
    80005e86:	0c2017b7          	lui	a5,0xc201
    80005e8a:	953e                	add	a0,a0,a5
    80005e8c:	00052023          	sw	zero,0(a0)
}
    80005e90:	60a2                	ld	ra,8(sp)
    80005e92:	6402                	ld	s0,0(sp)
    80005e94:	0141                	addi	sp,sp,16
    80005e96:	8082                	ret

0000000080005e98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e98:	1141                	addi	sp,sp,-16
    80005e9a:	e406                	sd	ra,8(sp)
    80005e9c:	e022                	sd	s0,0(sp)
    80005e9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ea0:	ffffc097          	auipc	ra,0xffffc
    80005ea4:	af0080e7          	jalr	-1296(ra) # 80001990 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ea8:	00d5179b          	slliw	a5,a0,0xd
    80005eac:	0c201537          	lui	a0,0xc201
    80005eb0:	953e                	add	a0,a0,a5
  return irq;
}
    80005eb2:	4148                	lw	a0,4(a0)
    80005eb4:	60a2                	ld	ra,8(sp)
    80005eb6:	6402                	ld	s0,0(sp)
    80005eb8:	0141                	addi	sp,sp,16
    80005eba:	8082                	ret

0000000080005ebc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ebc:	1101                	addi	sp,sp,-32
    80005ebe:	ec06                	sd	ra,24(sp)
    80005ec0:	e822                	sd	s0,16(sp)
    80005ec2:	e426                	sd	s1,8(sp)
    80005ec4:	1000                	addi	s0,sp,32
    80005ec6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	ac8080e7          	jalr	-1336(ra) # 80001990 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ed0:	00d5151b          	slliw	a0,a0,0xd
    80005ed4:	0c2017b7          	lui	a5,0xc201
    80005ed8:	97aa                	add	a5,a5,a0
    80005eda:	c3c4                	sw	s1,4(a5)
}
    80005edc:	60e2                	ld	ra,24(sp)
    80005ede:	6442                	ld	s0,16(sp)
    80005ee0:	64a2                	ld	s1,8(sp)
    80005ee2:	6105                	addi	sp,sp,32
    80005ee4:	8082                	ret

0000000080005ee6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ee6:	1141                	addi	sp,sp,-16
    80005ee8:	e406                	sd	ra,8(sp)
    80005eea:	e022                	sd	s0,0(sp)
    80005eec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005eee:	479d                	li	a5,7
    80005ef0:	04a7cc63          	blt	a5,a0,80005f48 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ef4:	0001c797          	auipc	a5,0x1c
    80005ef8:	13c78793          	addi	a5,a5,316 # 80022030 <disk>
    80005efc:	97aa                	add	a5,a5,a0
    80005efe:	0187c783          	lbu	a5,24(a5)
    80005f02:	ebb9                	bnez	a5,80005f58 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f04:	00451613          	slli	a2,a0,0x4
    80005f08:	0001c797          	auipc	a5,0x1c
    80005f0c:	12878793          	addi	a5,a5,296 # 80022030 <disk>
    80005f10:	6394                	ld	a3,0(a5)
    80005f12:	96b2                	add	a3,a3,a2
    80005f14:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005f18:	6398                	ld	a4,0(a5)
    80005f1a:	9732                	add	a4,a4,a2
    80005f1c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f20:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f24:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f28:	953e                	add	a0,a0,a5
    80005f2a:	4785                	li	a5,1
    80005f2c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005f30:	0001c517          	auipc	a0,0x1c
    80005f34:	11850513          	addi	a0,a0,280 # 80022048 <disk+0x18>
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	202080e7          	jalr	514(ra) # 8000213a <wakeup>
}
    80005f40:	60a2                	ld	ra,8(sp)
    80005f42:	6402                	ld	s0,0(sp)
    80005f44:	0141                	addi	sp,sp,16
    80005f46:	8082                	ret
    panic("free_desc 1");
    80005f48:	00003517          	auipc	a0,0x3
    80005f4c:	82850513          	addi	a0,a0,-2008 # 80008770 <syscalls+0x2f8>
    80005f50:	ffffa097          	auipc	ra,0xffffa
    80005f54:	5ee080e7          	jalr	1518(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005f58:	00003517          	auipc	a0,0x3
    80005f5c:	82850513          	addi	a0,a0,-2008 # 80008780 <syscalls+0x308>
    80005f60:	ffffa097          	auipc	ra,0xffffa
    80005f64:	5de080e7          	jalr	1502(ra) # 8000053e <panic>

0000000080005f68 <virtio_disk_init>:
{
    80005f68:	1101                	addi	sp,sp,-32
    80005f6a:	ec06                	sd	ra,24(sp)
    80005f6c:	e822                	sd	s0,16(sp)
    80005f6e:	e426                	sd	s1,8(sp)
    80005f70:	e04a                	sd	s2,0(sp)
    80005f72:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f74:	00003597          	auipc	a1,0x3
    80005f78:	81c58593          	addi	a1,a1,-2020 # 80008790 <syscalls+0x318>
    80005f7c:	0001c517          	auipc	a0,0x1c
    80005f80:	1dc50513          	addi	a0,a0,476 # 80022158 <disk+0x128>
    80005f84:	ffffb097          	auipc	ra,0xffffb
    80005f88:	bc2080e7          	jalr	-1086(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f8c:	100017b7          	lui	a5,0x10001
    80005f90:	4398                	lw	a4,0(a5)
    80005f92:	2701                	sext.w	a4,a4
    80005f94:	747277b7          	lui	a5,0x74727
    80005f98:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f9c:	14f71c63          	bne	a4,a5,800060f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005fa0:	100017b7          	lui	a5,0x10001
    80005fa4:	43dc                	lw	a5,4(a5)
    80005fa6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fa8:	4709                	li	a4,2
    80005faa:	14e79563          	bne	a5,a4,800060f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fae:	100017b7          	lui	a5,0x10001
    80005fb2:	479c                	lw	a5,8(a5)
    80005fb4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005fb6:	12e79f63          	bne	a5,a4,800060f4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005fba:	100017b7          	lui	a5,0x10001
    80005fbe:	47d8                	lw	a4,12(a5)
    80005fc0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fc2:	554d47b7          	lui	a5,0x554d4
    80005fc6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005fca:	12f71563          	bne	a4,a5,800060f4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fce:	100017b7          	lui	a5,0x10001
    80005fd2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fd6:	4705                	li	a4,1
    80005fd8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fda:	470d                	li	a4,3
    80005fdc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005fde:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005fe0:	c7ffe737          	lui	a4,0xc7ffe
    80005fe4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc5ef>
    80005fe8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fea:	2701                	sext.w	a4,a4
    80005fec:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fee:	472d                	li	a4,11
    80005ff0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005ff2:	5bbc                	lw	a5,112(a5)
    80005ff4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005ff8:	8ba1                	andi	a5,a5,8
    80005ffa:	10078563          	beqz	a5,80006104 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ffe:	100017b7          	lui	a5,0x10001
    80006002:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006006:	43fc                	lw	a5,68(a5)
    80006008:	2781                	sext.w	a5,a5
    8000600a:	10079563          	bnez	a5,80006114 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000600e:	100017b7          	lui	a5,0x10001
    80006012:	5bdc                	lw	a5,52(a5)
    80006014:	2781                	sext.w	a5,a5
  if(max == 0)
    80006016:	10078763          	beqz	a5,80006124 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000601a:	471d                	li	a4,7
    8000601c:	10f77c63          	bgeu	a4,a5,80006134 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006020:	ffffb097          	auipc	ra,0xffffb
    80006024:	ac6080e7          	jalr	-1338(ra) # 80000ae6 <kalloc>
    80006028:	0001c497          	auipc	s1,0x1c
    8000602c:	00848493          	addi	s1,s1,8 # 80022030 <disk>
    80006030:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006032:	ffffb097          	auipc	ra,0xffffb
    80006036:	ab4080e7          	jalr	-1356(ra) # 80000ae6 <kalloc>
    8000603a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000603c:	ffffb097          	auipc	ra,0xffffb
    80006040:	aaa080e7          	jalr	-1366(ra) # 80000ae6 <kalloc>
    80006044:	87aa                	mv	a5,a0
    80006046:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006048:	6088                	ld	a0,0(s1)
    8000604a:	cd6d                	beqz	a0,80006144 <virtio_disk_init+0x1dc>
    8000604c:	0001c717          	auipc	a4,0x1c
    80006050:	fec73703          	ld	a4,-20(a4) # 80022038 <disk+0x8>
    80006054:	cb65                	beqz	a4,80006144 <virtio_disk_init+0x1dc>
    80006056:	c7fd                	beqz	a5,80006144 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006058:	6605                	lui	a2,0x1
    8000605a:	4581                	li	a1,0
    8000605c:	ffffb097          	auipc	ra,0xffffb
    80006060:	c76080e7          	jalr	-906(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006064:	0001c497          	auipc	s1,0x1c
    80006068:	fcc48493          	addi	s1,s1,-52 # 80022030 <disk>
    8000606c:	6605                	lui	a2,0x1
    8000606e:	4581                	li	a1,0
    80006070:	6488                	ld	a0,8(s1)
    80006072:	ffffb097          	auipc	ra,0xffffb
    80006076:	c60080e7          	jalr	-928(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000607a:	6605                	lui	a2,0x1
    8000607c:	4581                	li	a1,0
    8000607e:	6888                	ld	a0,16(s1)
    80006080:	ffffb097          	auipc	ra,0xffffb
    80006084:	c52080e7          	jalr	-942(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006088:	100017b7          	lui	a5,0x10001
    8000608c:	4721                	li	a4,8
    8000608e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006090:	4098                	lw	a4,0(s1)
    80006092:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006096:	40d8                	lw	a4,4(s1)
    80006098:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000609c:	6498                	ld	a4,8(s1)
    8000609e:	0007069b          	sext.w	a3,a4
    800060a2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060a6:	9701                	srai	a4,a4,0x20
    800060a8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800060ac:	6898                	ld	a4,16(s1)
    800060ae:	0007069b          	sext.w	a3,a4
    800060b2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800060b6:	9701                	srai	a4,a4,0x20
    800060b8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800060bc:	4705                	li	a4,1
    800060be:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800060c0:	00e48c23          	sb	a4,24(s1)
    800060c4:	00e48ca3          	sb	a4,25(s1)
    800060c8:	00e48d23          	sb	a4,26(s1)
    800060cc:	00e48da3          	sb	a4,27(s1)
    800060d0:	00e48e23          	sb	a4,28(s1)
    800060d4:	00e48ea3          	sb	a4,29(s1)
    800060d8:	00e48f23          	sb	a4,30(s1)
    800060dc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800060e0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e4:	0727a823          	sw	s2,112(a5)
}
    800060e8:	60e2                	ld	ra,24(sp)
    800060ea:	6442                	ld	s0,16(sp)
    800060ec:	64a2                	ld	s1,8(sp)
    800060ee:	6902                	ld	s2,0(sp)
    800060f0:	6105                	addi	sp,sp,32
    800060f2:	8082                	ret
    panic("could not find virtio disk");
    800060f4:	00002517          	auipc	a0,0x2
    800060f8:	6ac50513          	addi	a0,a0,1708 # 800087a0 <syscalls+0x328>
    800060fc:	ffffa097          	auipc	ra,0xffffa
    80006100:	442080e7          	jalr	1090(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006104:	00002517          	auipc	a0,0x2
    80006108:	6bc50513          	addi	a0,a0,1724 # 800087c0 <syscalls+0x348>
    8000610c:	ffffa097          	auipc	ra,0xffffa
    80006110:	432080e7          	jalr	1074(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006114:	00002517          	auipc	a0,0x2
    80006118:	6cc50513          	addi	a0,a0,1740 # 800087e0 <syscalls+0x368>
    8000611c:	ffffa097          	auipc	ra,0xffffa
    80006120:	422080e7          	jalr	1058(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006124:	00002517          	auipc	a0,0x2
    80006128:	6dc50513          	addi	a0,a0,1756 # 80008800 <syscalls+0x388>
    8000612c:	ffffa097          	auipc	ra,0xffffa
    80006130:	412080e7          	jalr	1042(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006134:	00002517          	auipc	a0,0x2
    80006138:	6ec50513          	addi	a0,a0,1772 # 80008820 <syscalls+0x3a8>
    8000613c:	ffffa097          	auipc	ra,0xffffa
    80006140:	402080e7          	jalr	1026(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006144:	00002517          	auipc	a0,0x2
    80006148:	6fc50513          	addi	a0,a0,1788 # 80008840 <syscalls+0x3c8>
    8000614c:	ffffa097          	auipc	ra,0xffffa
    80006150:	3f2080e7          	jalr	1010(ra) # 8000053e <panic>

0000000080006154 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006154:	7119                	addi	sp,sp,-128
    80006156:	fc86                	sd	ra,120(sp)
    80006158:	f8a2                	sd	s0,112(sp)
    8000615a:	f4a6                	sd	s1,104(sp)
    8000615c:	f0ca                	sd	s2,96(sp)
    8000615e:	ecce                	sd	s3,88(sp)
    80006160:	e8d2                	sd	s4,80(sp)
    80006162:	e4d6                	sd	s5,72(sp)
    80006164:	e0da                	sd	s6,64(sp)
    80006166:	fc5e                	sd	s7,56(sp)
    80006168:	f862                	sd	s8,48(sp)
    8000616a:	f466                	sd	s9,40(sp)
    8000616c:	f06a                	sd	s10,32(sp)
    8000616e:	ec6e                	sd	s11,24(sp)
    80006170:	0100                	addi	s0,sp,128
    80006172:	8aaa                	mv	s5,a0
    80006174:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006176:	00c52d03          	lw	s10,12(a0)
    8000617a:	001d1d1b          	slliw	s10,s10,0x1
    8000617e:	1d02                	slli	s10,s10,0x20
    80006180:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006184:	0001c517          	auipc	a0,0x1c
    80006188:	fd450513          	addi	a0,a0,-44 # 80022158 <disk+0x128>
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	a4a080e7          	jalr	-1462(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006194:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006196:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006198:	0001cb97          	auipc	s7,0x1c
    8000619c:	e98b8b93          	addi	s7,s7,-360 # 80022030 <disk>
  for(int i = 0; i < 3; i++){
    800061a0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061a2:	0001cc97          	auipc	s9,0x1c
    800061a6:	fb6c8c93          	addi	s9,s9,-74 # 80022158 <disk+0x128>
    800061aa:	a08d                	j	8000620c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800061ac:	00fb8733          	add	a4,s7,a5
    800061b0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800061b4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800061b6:	0207c563          	bltz	a5,800061e0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800061ba:	2905                	addiw	s2,s2,1
    800061bc:	0611                	addi	a2,a2,4
    800061be:	05690c63          	beq	s2,s6,80006216 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800061c2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800061c4:	0001c717          	auipc	a4,0x1c
    800061c8:	e6c70713          	addi	a4,a4,-404 # 80022030 <disk>
    800061cc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800061ce:	01874683          	lbu	a3,24(a4)
    800061d2:	fee9                	bnez	a3,800061ac <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800061d4:	2785                	addiw	a5,a5,1
    800061d6:	0705                	addi	a4,a4,1
    800061d8:	fe979be3          	bne	a5,s1,800061ce <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800061dc:	57fd                	li	a5,-1
    800061de:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800061e0:	01205d63          	blez	s2,800061fa <virtio_disk_rw+0xa6>
    800061e4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800061e6:	000a2503          	lw	a0,0(s4)
    800061ea:	00000097          	auipc	ra,0x0
    800061ee:	cfc080e7          	jalr	-772(ra) # 80005ee6 <free_desc>
      for(int j = 0; j < i; j++)
    800061f2:	2d85                	addiw	s11,s11,1
    800061f4:	0a11                	addi	s4,s4,4
    800061f6:	ffb918e3          	bne	s2,s11,800061e6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061fa:	85e6                	mv	a1,s9
    800061fc:	0001c517          	auipc	a0,0x1c
    80006200:	e4c50513          	addi	a0,a0,-436 # 80022048 <disk+0x18>
    80006204:	ffffc097          	auipc	ra,0xffffc
    80006208:	ed2080e7          	jalr	-302(ra) # 800020d6 <sleep>
  for(int i = 0; i < 3; i++){
    8000620c:	f8040a13          	addi	s4,s0,-128
{
    80006210:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006212:	894e                	mv	s2,s3
    80006214:	b77d                	j	800061c2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006216:	f8042583          	lw	a1,-128(s0)
    8000621a:	00a58793          	addi	a5,a1,10
    8000621e:	0792                	slli	a5,a5,0x4

  if(write)
    80006220:	0001c617          	auipc	a2,0x1c
    80006224:	e1060613          	addi	a2,a2,-496 # 80022030 <disk>
    80006228:	00f60733          	add	a4,a2,a5
    8000622c:	018036b3          	snez	a3,s8
    80006230:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006232:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006236:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000623a:	f6078693          	addi	a3,a5,-160
    8000623e:	6218                	ld	a4,0(a2)
    80006240:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006242:	00878513          	addi	a0,a5,8
    80006246:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006248:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000624a:	6208                	ld	a0,0(a2)
    8000624c:	96aa                	add	a3,a3,a0
    8000624e:	4741                	li	a4,16
    80006250:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006252:	4705                	li	a4,1
    80006254:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006258:	f8442703          	lw	a4,-124(s0)
    8000625c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006260:	0712                	slli	a4,a4,0x4
    80006262:	953a                	add	a0,a0,a4
    80006264:	058a8693          	addi	a3,s5,88
    80006268:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000626a:	6208                	ld	a0,0(a2)
    8000626c:	972a                	add	a4,a4,a0
    8000626e:	40000693          	li	a3,1024
    80006272:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006274:	001c3c13          	seqz	s8,s8
    80006278:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000627a:	001c6c13          	ori	s8,s8,1
    8000627e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006282:	f8842603          	lw	a2,-120(s0)
    80006286:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000628a:	0001c697          	auipc	a3,0x1c
    8000628e:	da668693          	addi	a3,a3,-602 # 80022030 <disk>
    80006292:	00258713          	addi	a4,a1,2
    80006296:	0712                	slli	a4,a4,0x4
    80006298:	9736                	add	a4,a4,a3
    8000629a:	587d                	li	a6,-1
    8000629c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062a0:	0612                	slli	a2,a2,0x4
    800062a2:	9532                	add	a0,a0,a2
    800062a4:	f9078793          	addi	a5,a5,-112
    800062a8:	97b6                	add	a5,a5,a3
    800062aa:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800062ac:	629c                	ld	a5,0(a3)
    800062ae:	97b2                	add	a5,a5,a2
    800062b0:	4605                	li	a2,1
    800062b2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062b4:	4509                	li	a0,2
    800062b6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800062ba:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062be:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800062c2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800062c6:	6698                	ld	a4,8(a3)
    800062c8:	00275783          	lhu	a5,2(a4)
    800062cc:	8b9d                	andi	a5,a5,7
    800062ce:	0786                	slli	a5,a5,0x1
    800062d0:	97ba                	add	a5,a5,a4
    800062d2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800062d6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800062da:	6698                	ld	a4,8(a3)
    800062dc:	00275783          	lhu	a5,2(a4)
    800062e0:	2785                	addiw	a5,a5,1
    800062e2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800062e6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062ea:	100017b7          	lui	a5,0x10001
    800062ee:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062f2:	004aa783          	lw	a5,4(s5)
    800062f6:	02c79163          	bne	a5,a2,80006318 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800062fa:	0001c917          	auipc	s2,0x1c
    800062fe:	e5e90913          	addi	s2,s2,-418 # 80022158 <disk+0x128>
  while(b->disk == 1) {
    80006302:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006304:	85ca                	mv	a1,s2
    80006306:	8556                	mv	a0,s5
    80006308:	ffffc097          	auipc	ra,0xffffc
    8000630c:	dce080e7          	jalr	-562(ra) # 800020d6 <sleep>
  while(b->disk == 1) {
    80006310:	004aa783          	lw	a5,4(s5)
    80006314:	fe9788e3          	beq	a5,s1,80006304 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006318:	f8042903          	lw	s2,-128(s0)
    8000631c:	00290793          	addi	a5,s2,2
    80006320:	00479713          	slli	a4,a5,0x4
    80006324:	0001c797          	auipc	a5,0x1c
    80006328:	d0c78793          	addi	a5,a5,-756 # 80022030 <disk>
    8000632c:	97ba                	add	a5,a5,a4
    8000632e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006332:	0001c997          	auipc	s3,0x1c
    80006336:	cfe98993          	addi	s3,s3,-770 # 80022030 <disk>
    8000633a:	00491713          	slli	a4,s2,0x4
    8000633e:	0009b783          	ld	a5,0(s3)
    80006342:	97ba                	add	a5,a5,a4
    80006344:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006348:	854a                	mv	a0,s2
    8000634a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000634e:	00000097          	auipc	ra,0x0
    80006352:	b98080e7          	jalr	-1128(ra) # 80005ee6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006356:	8885                	andi	s1,s1,1
    80006358:	f0ed                	bnez	s1,8000633a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000635a:	0001c517          	auipc	a0,0x1c
    8000635e:	dfe50513          	addi	a0,a0,-514 # 80022158 <disk+0x128>
    80006362:	ffffb097          	auipc	ra,0xffffb
    80006366:	928080e7          	jalr	-1752(ra) # 80000c8a <release>
}
    8000636a:	70e6                	ld	ra,120(sp)
    8000636c:	7446                	ld	s0,112(sp)
    8000636e:	74a6                	ld	s1,104(sp)
    80006370:	7906                	ld	s2,96(sp)
    80006372:	69e6                	ld	s3,88(sp)
    80006374:	6a46                	ld	s4,80(sp)
    80006376:	6aa6                	ld	s5,72(sp)
    80006378:	6b06                	ld	s6,64(sp)
    8000637a:	7be2                	ld	s7,56(sp)
    8000637c:	7c42                	ld	s8,48(sp)
    8000637e:	7ca2                	ld	s9,40(sp)
    80006380:	7d02                	ld	s10,32(sp)
    80006382:	6de2                	ld	s11,24(sp)
    80006384:	6109                	addi	sp,sp,128
    80006386:	8082                	ret

0000000080006388 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006388:	1101                	addi	sp,sp,-32
    8000638a:	ec06                	sd	ra,24(sp)
    8000638c:	e822                	sd	s0,16(sp)
    8000638e:	e426                	sd	s1,8(sp)
    80006390:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006392:	0001c497          	auipc	s1,0x1c
    80006396:	c9e48493          	addi	s1,s1,-866 # 80022030 <disk>
    8000639a:	0001c517          	auipc	a0,0x1c
    8000639e:	dbe50513          	addi	a0,a0,-578 # 80022158 <disk+0x128>
    800063a2:	ffffb097          	auipc	ra,0xffffb
    800063a6:	834080e7          	jalr	-1996(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063aa:	10001737          	lui	a4,0x10001
    800063ae:	533c                	lw	a5,96(a4)
    800063b0:	8b8d                	andi	a5,a5,3
    800063b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800063b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063b8:	689c                	ld	a5,16(s1)
    800063ba:	0204d703          	lhu	a4,32(s1)
    800063be:	0027d783          	lhu	a5,2(a5)
    800063c2:	04f70863          	beq	a4,a5,80006412 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800063c6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063ca:	6898                	ld	a4,16(s1)
    800063cc:	0204d783          	lhu	a5,32(s1)
    800063d0:	8b9d                	andi	a5,a5,7
    800063d2:	078e                	slli	a5,a5,0x3
    800063d4:	97ba                	add	a5,a5,a4
    800063d6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800063d8:	00278713          	addi	a4,a5,2
    800063dc:	0712                	slli	a4,a4,0x4
    800063de:	9726                	add	a4,a4,s1
    800063e0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800063e4:	e721                	bnez	a4,8000642c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800063e6:	0789                	addi	a5,a5,2
    800063e8:	0792                	slli	a5,a5,0x4
    800063ea:	97a6                	add	a5,a5,s1
    800063ec:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800063ee:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800063f2:	ffffc097          	auipc	ra,0xffffc
    800063f6:	d48080e7          	jalr	-696(ra) # 8000213a <wakeup>

    disk.used_idx += 1;
    800063fa:	0204d783          	lhu	a5,32(s1)
    800063fe:	2785                	addiw	a5,a5,1
    80006400:	17c2                	slli	a5,a5,0x30
    80006402:	93c1                	srli	a5,a5,0x30
    80006404:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006408:	6898                	ld	a4,16(s1)
    8000640a:	00275703          	lhu	a4,2(a4)
    8000640e:	faf71ce3          	bne	a4,a5,800063c6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006412:	0001c517          	auipc	a0,0x1c
    80006416:	d4650513          	addi	a0,a0,-698 # 80022158 <disk+0x128>
    8000641a:	ffffb097          	auipc	ra,0xffffb
    8000641e:	870080e7          	jalr	-1936(ra) # 80000c8a <release>
}
    80006422:	60e2                	ld	ra,24(sp)
    80006424:	6442                	ld	s0,16(sp)
    80006426:	64a2                	ld	s1,8(sp)
    80006428:	6105                	addi	sp,sp,32
    8000642a:	8082                	ret
      panic("virtio_disk_intr status");
    8000642c:	00002517          	auipc	a0,0x2
    80006430:	42c50513          	addi	a0,a0,1068 # 80008858 <syscalls+0x3e0>
    80006434:	ffffa097          	auipc	ra,0xffffa
    80006438:	10a080e7          	jalr	266(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
