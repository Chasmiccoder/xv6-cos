
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a7010113          	addi	sp,sp,-1424 # 80008a70 <stack0>
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
    80000056:	8de70713          	addi	a4,a4,-1826 # 80008930 <timer_scratch>
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
    80000068:	e3c78793          	addi	a5,a5,-452 # 80005ea0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc65f>
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
    80000130:	5e2080e7          	jalr	1506(ra) # 8000270e <either_copyin>
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
    8000018e:	8e650513          	addi	a0,a0,-1818 # 80010a70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8d648493          	addi	s1,s1,-1834 # 80010a70 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	96690913          	addi	s2,s2,-1690 # 80010b08 <cons+0x98>
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
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	80c080e7          	jalr	-2036(ra) # 800019cc <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	23e080e7          	jalr	574(ra) # 80002406 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f7c080e7          	jalr	-132(ra) # 80002152 <sleep>
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
    80000216:	4a6080e7          	jalr	1190(ra) # 800026b8 <either_copyout>
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
    8000022a:	84a50513          	addi	a0,a0,-1974 # 80010a70 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	83450513          	addi	a0,a0,-1996 # 80010a70 <cons>
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
    80000276:	88f72b23          	sw	a5,-1898(a4) # 80010b08 <cons+0x98>
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
    800002d0:	7a450513          	addi	a0,a0,1956 # 80010a70 <cons>
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
    800002f6:	472080e7          	jalr	1138(ra) # 80002764 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	77650513          	addi	a0,a0,1910 # 80010a70 <cons>
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
    80000322:	75270713          	addi	a4,a4,1874 # 80010a70 <cons>
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
    8000034c:	72878793          	addi	a5,a5,1832 # 80010a70 <cons>
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
    8000037a:	7927a783          	lw	a5,1938(a5) # 80010b08 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6e670713          	addi	a4,a4,1766 # 80010a70 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6d648493          	addi	s1,s1,1750 # 80010a70 <cons>
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
    800003da:	69a70713          	addi	a4,a4,1690 # 80010a70 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72223          	sw	a5,1828(a4) # 80010b10 <cons+0xa0>
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
    80000416:	65e78793          	addi	a5,a5,1630 # 80010a70 <cons>
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
    8000043a:	6cc7ab23          	sw	a2,1750(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ca50513          	addi	a0,a0,1738 # 80010b08 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d70080e7          	jalr	-656(ra) # 800021b6 <wakeup>
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
    80000464:	61050513          	addi	a0,a0,1552 # 80010a70 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	b9078793          	addi	a5,a5,-1136 # 80021008 <devsw>
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
    8000054e:	5e07a323          	sw	zero,1510(a5) # 80010b30 <pr+0x18>
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
    80000570:	bb450513          	addi	a0,a0,-1100 # 80008120 <digits+0xe0>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	36f72923          	sw	a5,882(a4) # 800088f0 <panicked>
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
    800005be:	576dad83          	lw	s11,1398(s11) # 80010b30 <pr+0x18>
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
    800005fc:	52050513          	addi	a0,a0,1312 # 80010b18 <pr>
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
    8000075a:	3c250513          	addi	a0,a0,962 # 80010b18 <pr>
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
    80000776:	3a648493          	addi	s1,s1,934 # 80010b18 <pr>
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
    800007d6:	36650513          	addi	a0,a0,870 # 80010b38 <uart_tx_lock>
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
    80000802:	0f27a783          	lw	a5,242(a5) # 800088f0 <panicked>
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
    8000083a:	0c27b783          	ld	a5,194(a5) # 800088f8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0c273703          	ld	a4,194(a4) # 80008900 <uart_tx_w>
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
    80000864:	2d8a0a13          	addi	s4,s4,728 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	09048493          	addi	s1,s1,144 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	09098993          	addi	s3,s3,144 # 80008900 <uart_tx_w>
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
    80000896:	924080e7          	jalr	-1756(ra) # 800021b6 <wakeup>
    
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
    800008d2:	26a50513          	addi	a0,a0,618 # 80010b38 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	0127a783          	lw	a5,18(a5) # 800088f0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	01873703          	ld	a4,24(a4) # 80008900 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	0087b783          	ld	a5,8(a5) # 800088f8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	23c98993          	addi	s3,s3,572 # 80010b38 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	ff448493          	addi	s1,s1,-12 # 800088f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	ff490913          	addi	s2,s2,-12 # 80008900 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	836080e7          	jalr	-1994(ra) # 80002152 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	20648493          	addi	s1,s1,518 # 80010b38 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	fae7bd23          	sd	a4,-70(a5) # 80008900 <uart_tx_w>
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
    800009c0:	17c48493          	addi	s1,s1,380 # 80010b38 <uart_tx_lock>
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
    80000a02:	7a278793          	addi	a5,a5,1954 # 800221a0 <end>
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
    80000a22:	15290913          	addi	s2,s2,338 # 80010b70 <kmem>
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
    80000abe:	0b650513          	addi	a0,a0,182 # 80010b70 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	6d250513          	addi	a0,a0,1746 # 800221a0 <end>
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
    80000af4:	08048493          	addi	s1,s1,128 # 80010b70 <kmem>
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
    80000b0c:	06850513          	addi	a0,a0,104 # 80010b70 <kmem>
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
    80000b38:	03c50513          	addi	a0,a0,60 # 80010b70 <kmem>
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
    80000b74:	e40080e7          	jalr	-448(ra) # 800019b0 <mycpu>
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
    80000ba6:	e0e080e7          	jalr	-498(ra) # 800019b0 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e02080e7          	jalr	-510(ra) # 800019b0 <mycpu>
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
    80000bca:	dea080e7          	jalr	-534(ra) # 800019b0 <mycpu>
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
    80000c0a:	daa080e7          	jalr	-598(ra) # 800019b0 <mycpu>
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
    80000c36:	d7e080e7          	jalr	-642(ra) # 800019b0 <mycpu>
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
    80000e84:	b20080e7          	jalr	-1248(ra) # 800019a0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a8070713          	addi	a4,a4,-1408 # 80008908 <started>
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
    80000ea0:	b04080e7          	jalr	-1276(ra) # 800019a0 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	26a50513          	addi	a0,a0,618 # 80008110 <digits+0xd0>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0f8080e7          	jalr	248(ra) # 80000fae <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	9e6080e7          	jalr	-1562(ra) # 800028a4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	01a080e7          	jalr	26(ra) # 80005ee0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	066080e7          	jalr	102(ra) # 80001f34 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	23a50513          	addi	a0,a0,570 # 80008120 <digits+0xe0>
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
    80000f1a:	20a50513          	addi	a0,a0,522 # 80008120 <digits+0xe0>
    80000f1e:	fffff097          	auipc	ra,0xfffff
    80000f22:	66a080e7          	jalr	1642(ra) # 80000588 <printf>
      printf("Using First Come First Serve Scheduling\n");
    80000f26:	00007517          	auipc	a0,0x7
    80000f2a:	1ba50513          	addi	a0,a0,442 # 800080e0 <digits+0xa0>
    80000f2e:	fffff097          	auipc	ra,0xfffff
    80000f32:	65a080e7          	jalr	1626(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f36:	00000097          	auipc	ra,0x0
    80000f3a:	b74080e7          	jalr	-1164(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f3e:	00000097          	auipc	ra,0x0
    80000f42:	326080e7          	jalr	806(ra) # 80001264 <kvminit>
    kvminithart();   // turn on paging
    80000f46:	00000097          	auipc	ra,0x0
    80000f4a:	068080e7          	jalr	104(ra) # 80000fae <kvminithart>
    procinit();      // process table
    80000f4e:	00001097          	auipc	ra,0x1
    80000f52:	99e080e7          	jalr	-1634(ra) # 800018ec <procinit>
    trapinit();      // trap vectors
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	926080e7          	jalr	-1754(ra) # 8000287c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	946080e7          	jalr	-1722(ra) # 800028a4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f66:	00005097          	auipc	ra,0x5
    80000f6a:	f64080e7          	jalr	-156(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	f72080e7          	jalr	-142(ra) # 80005ee0 <plicinithart>
    binit();         // buffer cache
    80000f76:	00002097          	auipc	ra,0x2
    80000f7a:	114080e7          	jalr	276(ra) # 8000308a <binit>
    iinit();         // inode table
    80000f7e:	00002097          	auipc	ra,0x2
    80000f82:	7b8080e7          	jalr	1976(ra) # 80003736 <iinit>
    fileinit();      // file table
    80000f86:	00003097          	auipc	ra,0x3
    80000f8a:	756080e7          	jalr	1878(ra) # 800046dc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8e:	00005097          	auipc	ra,0x5
    80000f92:	05a080e7          	jalr	90(ra) # 80005fe8 <virtio_disk_init>
    userinit();      // first user process
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	d22080e7          	jalr	-734(ra) # 80001cb8 <userinit>
    __sync_synchronize();
    80000f9e:	0ff0000f          	fence
    started = 1;
    80000fa2:	4785                	li	a5,1
    80000fa4:	00008717          	auipc	a4,0x8
    80000fa8:	96f72223          	sw	a5,-1692(a4) # 80008908 <started>
    80000fac:	b70d                	j	80000ece <main+0x56>

0000000080000fae <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fae:	1141                	addi	sp,sp,-16
    80000fb0:	e422                	sd	s0,8(sp)
    80000fb2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb8:	00008797          	auipc	a5,0x8
    80000fbc:	9587b783          	ld	a5,-1704(a5) # 80008910 <kernel_pagetable>
    80000fc0:	83b1                	srli	a5,a5,0xc
    80000fc2:	577d                	li	a4,-1
    80000fc4:	177e                	slli	a4,a4,0x3f
    80000fc6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fcc:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fd0:	6422                	ld	s0,8(sp)
    80000fd2:	0141                	addi	sp,sp,16
    80000fd4:	8082                	ret

0000000080000fd6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd6:	7139                	addi	sp,sp,-64
    80000fd8:	fc06                	sd	ra,56(sp)
    80000fda:	f822                	sd	s0,48(sp)
    80000fdc:	f426                	sd	s1,40(sp)
    80000fde:	f04a                	sd	s2,32(sp)
    80000fe0:	ec4e                	sd	s3,24(sp)
    80000fe2:	e852                	sd	s4,16(sp)
    80000fe4:	e456                	sd	s5,8(sp)
    80000fe6:	e05a                	sd	s6,0(sp)
    80000fe8:	0080                	addi	s0,sp,64
    80000fea:	84aa                	mv	s1,a0
    80000fec:	89ae                	mv	s3,a1
    80000fee:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ff0:	57fd                	li	a5,-1
    80000ff2:	83e9                	srli	a5,a5,0x1a
    80000ff4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff8:	04b7f263          	bgeu	a5,a1,8000103c <walk+0x66>
    panic("walk");
    80000ffc:	00007517          	auipc	a0,0x7
    80001000:	12c50513          	addi	a0,a0,300 # 80008128 <digits+0xe8>
    80001004:	fffff097          	auipc	ra,0xfffff
    80001008:	53a080e7          	jalr	1338(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000100c:	060a8663          	beqz	s5,80001078 <walk+0xa2>
    80001010:	00000097          	auipc	ra,0x0
    80001014:	ad6080e7          	jalr	-1322(ra) # 80000ae6 <kalloc>
    80001018:	84aa                	mv	s1,a0
    8000101a:	c529                	beqz	a0,80001064 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000101c:	6605                	lui	a2,0x1
    8000101e:	4581                	li	a1,0
    80001020:	00000097          	auipc	ra,0x0
    80001024:	cb2080e7          	jalr	-846(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001028:	00c4d793          	srli	a5,s1,0xc
    8000102c:	07aa                	slli	a5,a5,0xa
    8000102e:	0017e793          	ori	a5,a5,1
    80001032:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001036:	3a5d                	addiw	s4,s4,-9
    80001038:	036a0063          	beq	s4,s6,80001058 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000103c:	0149d933          	srl	s2,s3,s4
    80001040:	1ff97913          	andi	s2,s2,511
    80001044:	090e                	slli	s2,s2,0x3
    80001046:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001048:	00093483          	ld	s1,0(s2)
    8000104c:	0014f793          	andi	a5,s1,1
    80001050:	dfd5                	beqz	a5,8000100c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001052:	80a9                	srli	s1,s1,0xa
    80001054:	04b2                	slli	s1,s1,0xc
    80001056:	b7c5                	j	80001036 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001058:	00c9d513          	srli	a0,s3,0xc
    8000105c:	1ff57513          	andi	a0,a0,511
    80001060:	050e                	slli	a0,a0,0x3
    80001062:	9526                	add	a0,a0,s1
}
    80001064:	70e2                	ld	ra,56(sp)
    80001066:	7442                	ld	s0,48(sp)
    80001068:	74a2                	ld	s1,40(sp)
    8000106a:	7902                	ld	s2,32(sp)
    8000106c:	69e2                	ld	s3,24(sp)
    8000106e:	6a42                	ld	s4,16(sp)
    80001070:	6aa2                	ld	s5,8(sp)
    80001072:	6b02                	ld	s6,0(sp)
    80001074:	6121                	addi	sp,sp,64
    80001076:	8082                	ret
        return 0;
    80001078:	4501                	li	a0,0
    8000107a:	b7ed                	j	80001064 <walk+0x8e>

000000008000107c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000107c:	57fd                	li	a5,-1
    8000107e:	83e9                	srli	a5,a5,0x1a
    80001080:	00b7f463          	bgeu	a5,a1,80001088 <walkaddr+0xc>
    return 0;
    80001084:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001086:	8082                	ret
{
    80001088:	1141                	addi	sp,sp,-16
    8000108a:	e406                	sd	ra,8(sp)
    8000108c:	e022                	sd	s0,0(sp)
    8000108e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001090:	4601                	li	a2,0
    80001092:	00000097          	auipc	ra,0x0
    80001096:	f44080e7          	jalr	-188(ra) # 80000fd6 <walk>
  if(pte == 0)
    8000109a:	c105                	beqz	a0,800010ba <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000109c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109e:	0117f693          	andi	a3,a5,17
    800010a2:	4745                	li	a4,17
    return 0;
    800010a4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a6:	00e68663          	beq	a3,a4,800010b2 <walkaddr+0x36>
}
    800010aa:	60a2                	ld	ra,8(sp)
    800010ac:	6402                	ld	s0,0(sp)
    800010ae:	0141                	addi	sp,sp,16
    800010b0:	8082                	ret
  pa = PTE2PA(*pte);
    800010b2:	00a7d513          	srli	a0,a5,0xa
    800010b6:	0532                	slli	a0,a0,0xc
  return pa;
    800010b8:	bfcd                	j	800010aa <walkaddr+0x2e>
    return 0;
    800010ba:	4501                	li	a0,0
    800010bc:	b7fd                	j	800010aa <walkaddr+0x2e>

00000000800010be <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010be:	715d                	addi	sp,sp,-80
    800010c0:	e486                	sd	ra,72(sp)
    800010c2:	e0a2                	sd	s0,64(sp)
    800010c4:	fc26                	sd	s1,56(sp)
    800010c6:	f84a                	sd	s2,48(sp)
    800010c8:	f44e                	sd	s3,40(sp)
    800010ca:	f052                	sd	s4,32(sp)
    800010cc:	ec56                	sd	s5,24(sp)
    800010ce:	e85a                	sd	s6,16(sp)
    800010d0:	e45e                	sd	s7,8(sp)
    800010d2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d4:	c639                	beqz	a2,80001122 <mappages+0x64>
    800010d6:	8aaa                	mv	s5,a0
    800010d8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010da:	77fd                	lui	a5,0xfffff
    800010dc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010e0:	15fd                	addi	a1,a1,-1
    800010e2:	00c589b3          	add	s3,a1,a2
    800010e6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ea:	8952                	mv	s2,s4
    800010ec:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010f0:	6b85                	lui	s7,0x1
    800010f2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f6:	4605                	li	a2,1
    800010f8:	85ca                	mv	a1,s2
    800010fa:	8556                	mv	a0,s5
    800010fc:	00000097          	auipc	ra,0x0
    80001100:	eda080e7          	jalr	-294(ra) # 80000fd6 <walk>
    80001104:	cd1d                	beqz	a0,80001142 <mappages+0x84>
    if(*pte & PTE_V)
    80001106:	611c                	ld	a5,0(a0)
    80001108:	8b85                	andi	a5,a5,1
    8000110a:	e785                	bnez	a5,80001132 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000110c:	80b1                	srli	s1,s1,0xc
    8000110e:	04aa                	slli	s1,s1,0xa
    80001110:	0164e4b3          	or	s1,s1,s6
    80001114:	0014e493          	ori	s1,s1,1
    80001118:	e104                	sd	s1,0(a0)
    if(a == last)
    8000111a:	05390063          	beq	s2,s3,8000115a <mappages+0x9c>
    a += PGSIZE;
    8000111e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001120:	bfc9                	j	800010f2 <mappages+0x34>
    panic("mappages: size");
    80001122:	00007517          	auipc	a0,0x7
    80001126:	00e50513          	addi	a0,a0,14 # 80008130 <digits+0xf0>
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	414080e7          	jalr	1044(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001132:	00007517          	auipc	a0,0x7
    80001136:	00e50513          	addi	a0,a0,14 # 80008140 <digits+0x100>
    8000113a:	fffff097          	auipc	ra,0xfffff
    8000113e:	404080e7          	jalr	1028(ra) # 8000053e <panic>
      return -1;
    80001142:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001144:	60a6                	ld	ra,72(sp)
    80001146:	6406                	ld	s0,64(sp)
    80001148:	74e2                	ld	s1,56(sp)
    8000114a:	7942                	ld	s2,48(sp)
    8000114c:	79a2                	ld	s3,40(sp)
    8000114e:	7a02                	ld	s4,32(sp)
    80001150:	6ae2                	ld	s5,24(sp)
    80001152:	6b42                	ld	s6,16(sp)
    80001154:	6ba2                	ld	s7,8(sp)
    80001156:	6161                	addi	sp,sp,80
    80001158:	8082                	ret
  return 0;
    8000115a:	4501                	li	a0,0
    8000115c:	b7e5                	j	80001144 <mappages+0x86>

000000008000115e <kvmmap>:
{
    8000115e:	1141                	addi	sp,sp,-16
    80001160:	e406                	sd	ra,8(sp)
    80001162:	e022                	sd	s0,0(sp)
    80001164:	0800                	addi	s0,sp,16
    80001166:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001168:	86b2                	mv	a3,a2
    8000116a:	863e                	mv	a2,a5
    8000116c:	00000097          	auipc	ra,0x0
    80001170:	f52080e7          	jalr	-174(ra) # 800010be <mappages>
    80001174:	e509                	bnez	a0,8000117e <kvmmap+0x20>
}
    80001176:	60a2                	ld	ra,8(sp)
    80001178:	6402                	ld	s0,0(sp)
    8000117a:	0141                	addi	sp,sp,16
    8000117c:	8082                	ret
    panic("kvmmap");
    8000117e:	00007517          	auipc	a0,0x7
    80001182:	fd250513          	addi	a0,a0,-46 # 80008150 <digits+0x110>
    80001186:	fffff097          	auipc	ra,0xfffff
    8000118a:	3b8080e7          	jalr	952(ra) # 8000053e <panic>

000000008000118e <kvmmake>:
{
    8000118e:	1101                	addi	sp,sp,-32
    80001190:	ec06                	sd	ra,24(sp)
    80001192:	e822                	sd	s0,16(sp)
    80001194:	e426                	sd	s1,8(sp)
    80001196:	e04a                	sd	s2,0(sp)
    80001198:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	94c080e7          	jalr	-1716(ra) # 80000ae6 <kalloc>
    800011a2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a4:	6605                	lui	a2,0x1
    800011a6:	4581                	li	a1,0
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	b2a080e7          	jalr	-1238(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	6685                	lui	a3,0x1
    800011b4:	10000637          	lui	a2,0x10000
    800011b8:	100005b7          	lui	a1,0x10000
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	fa0080e7          	jalr	-96(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c6:	4719                	li	a4,6
    800011c8:	6685                	lui	a3,0x1
    800011ca:	10001637          	lui	a2,0x10001
    800011ce:	100015b7          	lui	a1,0x10001
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	f8a080e7          	jalr	-118(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011dc:	4719                	li	a4,6
    800011de:	004006b7          	lui	a3,0x400
    800011e2:	0c000637          	lui	a2,0xc000
    800011e6:	0c0005b7          	lui	a1,0xc000
    800011ea:	8526                	mv	a0,s1
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f72080e7          	jalr	-142(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f4:	00007917          	auipc	s2,0x7
    800011f8:	e0c90913          	addi	s2,s2,-500 # 80008000 <etext>
    800011fc:	4729                	li	a4,10
    800011fe:	80007697          	auipc	a3,0x80007
    80001202:	e0268693          	addi	a3,a3,-510 # 8000 <_entry-0x7fff8000>
    80001206:	4605                	li	a2,1
    80001208:	067e                	slli	a2,a2,0x1f
    8000120a:	85b2                	mv	a1,a2
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f50080e7          	jalr	-176(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	46c5                	li	a3,17
    8000121a:	06ee                	slli	a3,a3,0x1b
    8000121c:	412686b3          	sub	a3,a3,s2
    80001220:	864a                	mv	a2,s2
    80001222:	85ca                	mv	a1,s2
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f38080e7          	jalr	-200(ra) # 8000115e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122e:	4729                	li	a4,10
    80001230:	6685                	lui	a3,0x1
    80001232:	00006617          	auipc	a2,0x6
    80001236:	dce60613          	addi	a2,a2,-562 # 80007000 <_trampoline>
    8000123a:	040005b7          	lui	a1,0x4000
    8000123e:	15fd                	addi	a1,a1,-1
    80001240:	05b2                	slli	a1,a1,0xc
    80001242:	8526                	mv	a0,s1
    80001244:	00000097          	auipc	ra,0x0
    80001248:	f1a080e7          	jalr	-230(ra) # 8000115e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000124c:	8526                	mv	a0,s1
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	608080e7          	jalr	1544(ra) # 80001856 <proc_mapstacks>
}
    80001256:	8526                	mv	a0,s1
    80001258:	60e2                	ld	ra,24(sp)
    8000125a:	6442                	ld	s0,16(sp)
    8000125c:	64a2                	ld	s1,8(sp)
    8000125e:	6902                	ld	s2,0(sp)
    80001260:	6105                	addi	sp,sp,32
    80001262:	8082                	ret

0000000080001264 <kvminit>:
{
    80001264:	1141                	addi	sp,sp,-16
    80001266:	e406                	sd	ra,8(sp)
    80001268:	e022                	sd	s0,0(sp)
    8000126a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	f22080e7          	jalr	-222(ra) # 8000118e <kvmmake>
    80001274:	00007797          	auipc	a5,0x7
    80001278:	68a7be23          	sd	a0,1692(a5) # 80008910 <kernel_pagetable>
}
    8000127c:	60a2                	ld	ra,8(sp)
    8000127e:	6402                	ld	s0,0(sp)
    80001280:	0141                	addi	sp,sp,16
    80001282:	8082                	ret

0000000080001284 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001284:	715d                	addi	sp,sp,-80
    80001286:	e486                	sd	ra,72(sp)
    80001288:	e0a2                	sd	s0,64(sp)
    8000128a:	fc26                	sd	s1,56(sp)
    8000128c:	f84a                	sd	s2,48(sp)
    8000128e:	f44e                	sd	s3,40(sp)
    80001290:	f052                	sd	s4,32(sp)
    80001292:	ec56                	sd	s5,24(sp)
    80001294:	e85a                	sd	s6,16(sp)
    80001296:	e45e                	sd	s7,8(sp)
    80001298:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000129a:	03459793          	slli	a5,a1,0x34
    8000129e:	e795                	bnez	a5,800012ca <uvmunmap+0x46>
    800012a0:	8a2a                	mv	s4,a0
    800012a2:	892e                	mv	s2,a1
    800012a4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a6:	0632                	slli	a2,a2,0xc
    800012a8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ac:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ae:	6b05                	lui	s6,0x1
    800012b0:	0735e263          	bltu	a1,s3,80001314 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b4:	60a6                	ld	ra,72(sp)
    800012b6:	6406                	ld	s0,64(sp)
    800012b8:	74e2                	ld	s1,56(sp)
    800012ba:	7942                	ld	s2,48(sp)
    800012bc:	79a2                	ld	s3,40(sp)
    800012be:	7a02                	ld	s4,32(sp)
    800012c0:	6ae2                	ld	s5,24(sp)
    800012c2:	6b42                	ld	s6,16(sp)
    800012c4:	6ba2                	ld	s7,8(sp)
    800012c6:	6161                	addi	sp,sp,80
    800012c8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e8e50513          	addi	a0,a0,-370 # 80008158 <digits+0x118>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e9650513          	addi	a0,a0,-362 # 80008170 <digits+0x130>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ea:	00007517          	auipc	a0,0x7
    800012ee:	e9650513          	addi	a0,a0,-362 # 80008180 <digits+0x140>
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	24c080e7          	jalr	588(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012fa:	00007517          	auipc	a0,0x7
    800012fe:	e9e50513          	addi	a0,a0,-354 # 80008198 <digits+0x158>
    80001302:	fffff097          	auipc	ra,0xfffff
    80001306:	23c080e7          	jalr	572(ra) # 8000053e <panic>
    *pte = 0;
    8000130a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130e:	995a                	add	s2,s2,s6
    80001310:	fb3972e3          	bgeu	s2,s3,800012b4 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001314:	4601                	li	a2,0
    80001316:	85ca                	mv	a1,s2
    80001318:	8552                	mv	a0,s4
    8000131a:	00000097          	auipc	ra,0x0
    8000131e:	cbc080e7          	jalr	-836(ra) # 80000fd6 <walk>
    80001322:	84aa                	mv	s1,a0
    80001324:	d95d                	beqz	a0,800012da <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001326:	6108                	ld	a0,0(a0)
    80001328:	00157793          	andi	a5,a0,1
    8000132c:	dfdd                	beqz	a5,800012ea <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132e:	3ff57793          	andi	a5,a0,1023
    80001332:	fd7784e3          	beq	a5,s7,800012fa <uvmunmap+0x76>
    if(do_free){
    80001336:	fc0a8ae3          	beqz	s5,8000130a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000133a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000133c:	0532                	slli	a0,a0,0xc
    8000133e:	fffff097          	auipc	ra,0xfffff
    80001342:	6ac080e7          	jalr	1708(ra) # 800009ea <kfree>
    80001346:	b7d1                	j	8000130a <uvmunmap+0x86>

0000000080001348 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001348:	1101                	addi	sp,sp,-32
    8000134a:	ec06                	sd	ra,24(sp)
    8000134c:	e822                	sd	s0,16(sp)
    8000134e:	e426                	sd	s1,8(sp)
    80001350:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001352:	fffff097          	auipc	ra,0xfffff
    80001356:	794080e7          	jalr	1940(ra) # 80000ae6 <kalloc>
    8000135a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000135c:	c519                	beqz	a0,8000136a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000135e:	6605                	lui	a2,0x1
    80001360:	4581                	li	a1,0
    80001362:	00000097          	auipc	ra,0x0
    80001366:	970080e7          	jalr	-1680(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000136a:	8526                	mv	a0,s1
    8000136c:	60e2                	ld	ra,24(sp)
    8000136e:	6442                	ld	s0,16(sp)
    80001370:	64a2                	ld	s1,8(sp)
    80001372:	6105                	addi	sp,sp,32
    80001374:	8082                	ret

0000000080001376 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001376:	7179                	addi	sp,sp,-48
    80001378:	f406                	sd	ra,40(sp)
    8000137a:	f022                	sd	s0,32(sp)
    8000137c:	ec26                	sd	s1,24(sp)
    8000137e:	e84a                	sd	s2,16(sp)
    80001380:	e44e                	sd	s3,8(sp)
    80001382:	e052                	sd	s4,0(sp)
    80001384:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001386:	6785                	lui	a5,0x1
    80001388:	04f67863          	bgeu	a2,a5,800013d8 <uvmfirst+0x62>
    8000138c:	8a2a                	mv	s4,a0
    8000138e:	89ae                	mv	s3,a1
    80001390:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	754080e7          	jalr	1876(ra) # 80000ae6 <kalloc>
    8000139a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000139c:	6605                	lui	a2,0x1
    8000139e:	4581                	li	a1,0
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	932080e7          	jalr	-1742(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a8:	4779                	li	a4,30
    800013aa:	86ca                	mv	a3,s2
    800013ac:	6605                	lui	a2,0x1
    800013ae:	4581                	li	a1,0
    800013b0:	8552                	mv	a0,s4
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	d0c080e7          	jalr	-756(ra) # 800010be <mappages>
  memmove(mem, src, sz);
    800013ba:	8626                	mv	a2,s1
    800013bc:	85ce                	mv	a1,s3
    800013be:	854a                	mv	a0,s2
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	96e080e7          	jalr	-1682(ra) # 80000d2e <memmove>
}
    800013c8:	70a2                	ld	ra,40(sp)
    800013ca:	7402                	ld	s0,32(sp)
    800013cc:	64e2                	ld	s1,24(sp)
    800013ce:	6942                	ld	s2,16(sp)
    800013d0:	69a2                	ld	s3,8(sp)
    800013d2:	6a02                	ld	s4,0(sp)
    800013d4:	6145                	addi	sp,sp,48
    800013d6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013d8:	00007517          	auipc	a0,0x7
    800013dc:	dd850513          	addi	a0,a0,-552 # 800081b0 <digits+0x170>
    800013e0:	fffff097          	auipc	ra,0xfffff
    800013e4:	15e080e7          	jalr	350(ra) # 8000053e <panic>

00000000800013e8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e8:	1101                	addi	sp,sp,-32
    800013ea:	ec06                	sd	ra,24(sp)
    800013ec:	e822                	sd	s0,16(sp)
    800013ee:	e426                	sd	s1,8(sp)
    800013f0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013f2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f4:	00b67d63          	bgeu	a2,a1,8000140e <uvmdealloc+0x26>
    800013f8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013fa:	6785                	lui	a5,0x1
    800013fc:	17fd                	addi	a5,a5,-1
    800013fe:	00f60733          	add	a4,a2,a5
    80001402:	767d                	lui	a2,0xfffff
    80001404:	8f71                	and	a4,a4,a2
    80001406:	97ae                	add	a5,a5,a1
    80001408:	8ff1                	and	a5,a5,a2
    8000140a:	00f76863          	bltu	a4,a5,8000141a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000140e:	8526                	mv	a0,s1
    80001410:	60e2                	ld	ra,24(sp)
    80001412:	6442                	ld	s0,16(sp)
    80001414:	64a2                	ld	s1,8(sp)
    80001416:	6105                	addi	sp,sp,32
    80001418:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000141a:	8f99                	sub	a5,a5,a4
    8000141c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000141e:	4685                	li	a3,1
    80001420:	0007861b          	sext.w	a2,a5
    80001424:	85ba                	mv	a1,a4
    80001426:	00000097          	auipc	ra,0x0
    8000142a:	e5e080e7          	jalr	-418(ra) # 80001284 <uvmunmap>
    8000142e:	b7c5                	j	8000140e <uvmdealloc+0x26>

0000000080001430 <uvmalloc>:
  if(newsz < oldsz)
    80001430:	0ab66563          	bltu	a2,a1,800014da <uvmalloc+0xaa>
{
    80001434:	7139                	addi	sp,sp,-64
    80001436:	fc06                	sd	ra,56(sp)
    80001438:	f822                	sd	s0,48(sp)
    8000143a:	f426                	sd	s1,40(sp)
    8000143c:	f04a                	sd	s2,32(sp)
    8000143e:	ec4e                	sd	s3,24(sp)
    80001440:	e852                	sd	s4,16(sp)
    80001442:	e456                	sd	s5,8(sp)
    80001444:	e05a                	sd	s6,0(sp)
    80001446:	0080                	addi	s0,sp,64
    80001448:	8aaa                	mv	s5,a0
    8000144a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000144c:	6985                	lui	s3,0x1
    8000144e:	19fd                	addi	s3,s3,-1
    80001450:	95ce                	add	a1,a1,s3
    80001452:	79fd                	lui	s3,0xfffff
    80001454:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001458:	08c9f363          	bgeu	s3,a2,800014de <uvmalloc+0xae>
    8000145c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001462:	fffff097          	auipc	ra,0xfffff
    80001466:	684080e7          	jalr	1668(ra) # 80000ae6 <kalloc>
    8000146a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000146c:	c51d                	beqz	a0,8000149a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000146e:	6605                	lui	a2,0x1
    80001470:	4581                	li	a1,0
    80001472:	00000097          	auipc	ra,0x0
    80001476:	860080e7          	jalr	-1952(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000147a:	875a                	mv	a4,s6
    8000147c:	86a6                	mv	a3,s1
    8000147e:	6605                	lui	a2,0x1
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	c3a080e7          	jalr	-966(ra) # 800010be <mappages>
    8000148c:	e90d                	bnez	a0,800014be <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000148e:	6785                	lui	a5,0x1
    80001490:	993e                	add	s2,s2,a5
    80001492:	fd4968e3          	bltu	s2,s4,80001462 <uvmalloc+0x32>
  return newsz;
    80001496:	8552                	mv	a0,s4
    80001498:	a809                	j	800014aa <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000149a:	864e                	mv	a2,s3
    8000149c:	85ca                	mv	a1,s2
    8000149e:	8556                	mv	a0,s5
    800014a0:	00000097          	auipc	ra,0x0
    800014a4:	f48080e7          	jalr	-184(ra) # 800013e8 <uvmdealloc>
      return 0;
    800014a8:	4501                	li	a0,0
}
    800014aa:	70e2                	ld	ra,56(sp)
    800014ac:	7442                	ld	s0,48(sp)
    800014ae:	74a2                	ld	s1,40(sp)
    800014b0:	7902                	ld	s2,32(sp)
    800014b2:	69e2                	ld	s3,24(sp)
    800014b4:	6a42                	ld	s4,16(sp)
    800014b6:	6aa2                	ld	s5,8(sp)
    800014b8:	6b02                	ld	s6,0(sp)
    800014ba:	6121                	addi	sp,sp,64
    800014bc:	8082                	ret
      kfree(mem);
    800014be:	8526                	mv	a0,s1
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	52a080e7          	jalr	1322(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c8:	864e                	mv	a2,s3
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	f1a080e7          	jalr	-230(ra) # 800013e8 <uvmdealloc>
      return 0;
    800014d6:	4501                	li	a0,0
    800014d8:	bfc9                	j	800014aa <uvmalloc+0x7a>
    return oldsz;
    800014da:	852e                	mv	a0,a1
}
    800014dc:	8082                	ret
  return newsz;
    800014de:	8532                	mv	a0,a2
    800014e0:	b7e9                	j	800014aa <uvmalloc+0x7a>

00000000800014e2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014e2:	7179                	addi	sp,sp,-48
    800014e4:	f406                	sd	ra,40(sp)
    800014e6:	f022                	sd	s0,32(sp)
    800014e8:	ec26                	sd	s1,24(sp)
    800014ea:	e84a                	sd	s2,16(sp)
    800014ec:	e44e                	sd	s3,8(sp)
    800014ee:	e052                	sd	s4,0(sp)
    800014f0:	1800                	addi	s0,sp,48
    800014f2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f4:	84aa                	mv	s1,a0
    800014f6:	6905                	lui	s2,0x1
    800014f8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fa:	4985                	li	s3,1
    800014fc:	a821                	j	80001514 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fe:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001500:	0532                	slli	a0,a0,0xc
    80001502:	00000097          	auipc	ra,0x0
    80001506:	fe0080e7          	jalr	-32(ra) # 800014e2 <freewalk>
      pagetable[i] = 0;
    8000150a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000150e:	04a1                	addi	s1,s1,8
    80001510:	03248163          	beq	s1,s2,80001532 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001514:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001516:	00f57793          	andi	a5,a0,15
    8000151a:	ff3782e3          	beq	a5,s3,800014fe <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000151e:	8905                	andi	a0,a0,1
    80001520:	d57d                	beqz	a0,8000150e <freewalk+0x2c>
      panic("freewalk: leaf");
    80001522:	00007517          	auipc	a0,0x7
    80001526:	cae50513          	addi	a0,a0,-850 # 800081d0 <digits+0x190>
    8000152a:	fffff097          	auipc	ra,0xfffff
    8000152e:	014080e7          	jalr	20(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001532:	8552                	mv	a0,s4
    80001534:	fffff097          	auipc	ra,0xfffff
    80001538:	4b6080e7          	jalr	1206(ra) # 800009ea <kfree>
}
    8000153c:	70a2                	ld	ra,40(sp)
    8000153e:	7402                	ld	s0,32(sp)
    80001540:	64e2                	ld	s1,24(sp)
    80001542:	6942                	ld	s2,16(sp)
    80001544:	69a2                	ld	s3,8(sp)
    80001546:	6a02                	ld	s4,0(sp)
    80001548:	6145                	addi	sp,sp,48
    8000154a:	8082                	ret

000000008000154c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000154c:	1101                	addi	sp,sp,-32
    8000154e:	ec06                	sd	ra,24(sp)
    80001550:	e822                	sd	s0,16(sp)
    80001552:	e426                	sd	s1,8(sp)
    80001554:	1000                	addi	s0,sp,32
    80001556:	84aa                	mv	s1,a0
  if(sz > 0)
    80001558:	e999                	bnez	a1,8000156e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000155a:	8526                	mv	a0,s1
    8000155c:	00000097          	auipc	ra,0x0
    80001560:	f86080e7          	jalr	-122(ra) # 800014e2 <freewalk>
}
    80001564:	60e2                	ld	ra,24(sp)
    80001566:	6442                	ld	s0,16(sp)
    80001568:	64a2                	ld	s1,8(sp)
    8000156a:	6105                	addi	sp,sp,32
    8000156c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000156e:	6605                	lui	a2,0x1
    80001570:	167d                	addi	a2,a2,-1
    80001572:	962e                	add	a2,a2,a1
    80001574:	4685                	li	a3,1
    80001576:	8231                	srli	a2,a2,0xc
    80001578:	4581                	li	a1,0
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	d0a080e7          	jalr	-758(ra) # 80001284 <uvmunmap>
    80001582:	bfe1                	j	8000155a <uvmfree+0xe>

0000000080001584 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001584:	c679                	beqz	a2,80001652 <uvmcopy+0xce>
{
    80001586:	715d                	addi	sp,sp,-80
    80001588:	e486                	sd	ra,72(sp)
    8000158a:	e0a2                	sd	s0,64(sp)
    8000158c:	fc26                	sd	s1,56(sp)
    8000158e:	f84a                	sd	s2,48(sp)
    80001590:	f44e                	sd	s3,40(sp)
    80001592:	f052                	sd	s4,32(sp)
    80001594:	ec56                	sd	s5,24(sp)
    80001596:	e85a                	sd	s6,16(sp)
    80001598:	e45e                	sd	s7,8(sp)
    8000159a:	0880                	addi	s0,sp,80
    8000159c:	8b2a                	mv	s6,a0
    8000159e:	8aae                	mv	s5,a1
    800015a0:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015a2:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a4:	4601                	li	a2,0
    800015a6:	85ce                	mv	a1,s3
    800015a8:	855a                	mv	a0,s6
    800015aa:	00000097          	auipc	ra,0x0
    800015ae:	a2c080e7          	jalr	-1492(ra) # 80000fd6 <walk>
    800015b2:	c531                	beqz	a0,800015fe <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b4:	6118                	ld	a4,0(a0)
    800015b6:	00177793          	andi	a5,a4,1
    800015ba:	cbb1                	beqz	a5,8000160e <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015bc:	00a75593          	srli	a1,a4,0xa
    800015c0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	51e080e7          	jalr	1310(ra) # 80000ae6 <kalloc>
    800015d0:	892a                	mv	s2,a0
    800015d2:	c939                	beqz	a0,80001628 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d4:	6605                	lui	a2,0x1
    800015d6:	85de                	mv	a1,s7
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	756080e7          	jalr	1878(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015e0:	8726                	mv	a4,s1
    800015e2:	86ca                	mv	a3,s2
    800015e4:	6605                	lui	a2,0x1
    800015e6:	85ce                	mv	a1,s3
    800015e8:	8556                	mv	a0,s5
    800015ea:	00000097          	auipc	ra,0x0
    800015ee:	ad4080e7          	jalr	-1324(ra) # 800010be <mappages>
    800015f2:	e515                	bnez	a0,8000161e <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f4:	6785                	lui	a5,0x1
    800015f6:	99be                	add	s3,s3,a5
    800015f8:	fb49e6e3          	bltu	s3,s4,800015a4 <uvmcopy+0x20>
    800015fc:	a081                	j	8000163c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015fe:	00007517          	auipc	a0,0x7
    80001602:	be250513          	addi	a0,a0,-1054 # 800081e0 <digits+0x1a0>
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	f38080e7          	jalr	-200(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    8000160e:	00007517          	auipc	a0,0x7
    80001612:	bf250513          	addi	a0,a0,-1038 # 80008200 <digits+0x1c0>
    80001616:	fffff097          	auipc	ra,0xfffff
    8000161a:	f28080e7          	jalr	-216(ra) # 8000053e <panic>
      kfree(mem);
    8000161e:	854a                	mv	a0,s2
    80001620:	fffff097          	auipc	ra,0xfffff
    80001624:	3ca080e7          	jalr	970(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001628:	4685                	li	a3,1
    8000162a:	00c9d613          	srli	a2,s3,0xc
    8000162e:	4581                	li	a1,0
    80001630:	8556                	mv	a0,s5
    80001632:	00000097          	auipc	ra,0x0
    80001636:	c52080e7          	jalr	-942(ra) # 80001284 <uvmunmap>
  return -1;
    8000163a:	557d                	li	a0,-1
}
    8000163c:	60a6                	ld	ra,72(sp)
    8000163e:	6406                	ld	s0,64(sp)
    80001640:	74e2                	ld	s1,56(sp)
    80001642:	7942                	ld	s2,48(sp)
    80001644:	79a2                	ld	s3,40(sp)
    80001646:	7a02                	ld	s4,32(sp)
    80001648:	6ae2                	ld	s5,24(sp)
    8000164a:	6b42                	ld	s6,16(sp)
    8000164c:	6ba2                	ld	s7,8(sp)
    8000164e:	6161                	addi	sp,sp,80
    80001650:	8082                	ret
  return 0;
    80001652:	4501                	li	a0,0
}
    80001654:	8082                	ret

0000000080001656 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001656:	1141                	addi	sp,sp,-16
    80001658:	e406                	sd	ra,8(sp)
    8000165a:	e022                	sd	s0,0(sp)
    8000165c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165e:	4601                	li	a2,0
    80001660:	00000097          	auipc	ra,0x0
    80001664:	976080e7          	jalr	-1674(ra) # 80000fd6 <walk>
  if(pte == 0)
    80001668:	c901                	beqz	a0,80001678 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000166a:	611c                	ld	a5,0(a0)
    8000166c:	9bbd                	andi	a5,a5,-17
    8000166e:	e11c                	sd	a5,0(a0)
}
    80001670:	60a2                	ld	ra,8(sp)
    80001672:	6402                	ld	s0,0(sp)
    80001674:	0141                	addi	sp,sp,16
    80001676:	8082                	ret
    panic("uvmclear");
    80001678:	00007517          	auipc	a0,0x7
    8000167c:	ba850513          	addi	a0,a0,-1112 # 80008220 <digits+0x1e0>
    80001680:	fffff097          	auipc	ra,0xfffff
    80001684:	ebe080e7          	jalr	-322(ra) # 8000053e <panic>

0000000080001688 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001688:	c6bd                	beqz	a3,800016f6 <copyout+0x6e>
{
    8000168a:	715d                	addi	sp,sp,-80
    8000168c:	e486                	sd	ra,72(sp)
    8000168e:	e0a2                	sd	s0,64(sp)
    80001690:	fc26                	sd	s1,56(sp)
    80001692:	f84a                	sd	s2,48(sp)
    80001694:	f44e                	sd	s3,40(sp)
    80001696:	f052                	sd	s4,32(sp)
    80001698:	ec56                	sd	s5,24(sp)
    8000169a:	e85a                	sd	s6,16(sp)
    8000169c:	e45e                	sd	s7,8(sp)
    8000169e:	e062                	sd	s8,0(sp)
    800016a0:	0880                	addi	s0,sp,80
    800016a2:	8b2a                	mv	s6,a0
    800016a4:	8c2e                	mv	s8,a1
    800016a6:	8a32                	mv	s4,a2
    800016a8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016aa:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ac:	6a85                	lui	s5,0x1
    800016ae:	a015                	j	800016d2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016b0:	9562                	add	a0,a0,s8
    800016b2:	0004861b          	sext.w	a2,s1
    800016b6:	85d2                	mv	a1,s4
    800016b8:	41250533          	sub	a0,a0,s2
    800016bc:	fffff097          	auipc	ra,0xfffff
    800016c0:	672080e7          	jalr	1650(ra) # 80000d2e <memmove>

    len -= n;
    800016c4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ca:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ce:	02098263          	beqz	s3,800016f2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016d2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d6:	85ca                	mv	a1,s2
    800016d8:	855a                	mv	a0,s6
    800016da:	00000097          	auipc	ra,0x0
    800016de:	9a2080e7          	jalr	-1630(ra) # 8000107c <walkaddr>
    if(pa0 == 0)
    800016e2:	cd01                	beqz	a0,800016fa <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e4:	418904b3          	sub	s1,s2,s8
    800016e8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ea:	fc99f3e3          	bgeu	s3,s1,800016b0 <copyout+0x28>
    800016ee:	84ce                	mv	s1,s3
    800016f0:	b7c1                	j	800016b0 <copyout+0x28>
  }
  return 0;
    800016f2:	4501                	li	a0,0
    800016f4:	a021                	j	800016fc <copyout+0x74>
    800016f6:	4501                	li	a0,0
}
    800016f8:	8082                	ret
      return -1;
    800016fa:	557d                	li	a0,-1
}
    800016fc:	60a6                	ld	ra,72(sp)
    800016fe:	6406                	ld	s0,64(sp)
    80001700:	74e2                	ld	s1,56(sp)
    80001702:	7942                	ld	s2,48(sp)
    80001704:	79a2                	ld	s3,40(sp)
    80001706:	7a02                	ld	s4,32(sp)
    80001708:	6ae2                	ld	s5,24(sp)
    8000170a:	6b42                	ld	s6,16(sp)
    8000170c:	6ba2                	ld	s7,8(sp)
    8000170e:	6c02                	ld	s8,0(sp)
    80001710:	6161                	addi	sp,sp,80
    80001712:	8082                	ret

0000000080001714 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001714:	caa5                	beqz	a3,80001784 <copyin+0x70>
{
    80001716:	715d                	addi	sp,sp,-80
    80001718:	e486                	sd	ra,72(sp)
    8000171a:	e0a2                	sd	s0,64(sp)
    8000171c:	fc26                	sd	s1,56(sp)
    8000171e:	f84a                	sd	s2,48(sp)
    80001720:	f44e                	sd	s3,40(sp)
    80001722:	f052                	sd	s4,32(sp)
    80001724:	ec56                	sd	s5,24(sp)
    80001726:	e85a                	sd	s6,16(sp)
    80001728:	e45e                	sd	s7,8(sp)
    8000172a:	e062                	sd	s8,0(sp)
    8000172c:	0880                	addi	s0,sp,80
    8000172e:	8b2a                	mv	s6,a0
    80001730:	8a2e                	mv	s4,a1
    80001732:	8c32                	mv	s8,a2
    80001734:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001736:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001738:	6a85                	lui	s5,0x1
    8000173a:	a01d                	j	80001760 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000173c:	018505b3          	add	a1,a0,s8
    80001740:	0004861b          	sext.w	a2,s1
    80001744:	412585b3          	sub	a1,a1,s2
    80001748:	8552                	mv	a0,s4
    8000174a:	fffff097          	auipc	ra,0xfffff
    8000174e:	5e4080e7          	jalr	1508(ra) # 80000d2e <memmove>

    len -= n;
    80001752:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001756:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001758:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175c:	02098263          	beqz	s3,80001780 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001760:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001764:	85ca                	mv	a1,s2
    80001766:	855a                	mv	a0,s6
    80001768:	00000097          	auipc	ra,0x0
    8000176c:	914080e7          	jalr	-1772(ra) # 8000107c <walkaddr>
    if(pa0 == 0)
    80001770:	cd01                	beqz	a0,80001788 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001772:	418904b3          	sub	s1,s2,s8
    80001776:	94d6                	add	s1,s1,s5
    if(n > len)
    80001778:	fc99f2e3          	bgeu	s3,s1,8000173c <copyin+0x28>
    8000177c:	84ce                	mv	s1,s3
    8000177e:	bf7d                	j	8000173c <copyin+0x28>
  }
  return 0;
    80001780:	4501                	li	a0,0
    80001782:	a021                	j	8000178a <copyin+0x76>
    80001784:	4501                	li	a0,0
}
    80001786:	8082                	ret
      return -1;
    80001788:	557d                	li	a0,-1
}
    8000178a:	60a6                	ld	ra,72(sp)
    8000178c:	6406                	ld	s0,64(sp)
    8000178e:	74e2                	ld	s1,56(sp)
    80001790:	7942                	ld	s2,48(sp)
    80001792:	79a2                	ld	s3,40(sp)
    80001794:	7a02                	ld	s4,32(sp)
    80001796:	6ae2                	ld	s5,24(sp)
    80001798:	6b42                	ld	s6,16(sp)
    8000179a:	6ba2                	ld	s7,8(sp)
    8000179c:	6c02                	ld	s8,0(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret

00000000800017a2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017a2:	c6c5                	beqz	a3,8000184a <copyinstr+0xa8>
{
    800017a4:	715d                	addi	sp,sp,-80
    800017a6:	e486                	sd	ra,72(sp)
    800017a8:	e0a2                	sd	s0,64(sp)
    800017aa:	fc26                	sd	s1,56(sp)
    800017ac:	f84a                	sd	s2,48(sp)
    800017ae:	f44e                	sd	s3,40(sp)
    800017b0:	f052                	sd	s4,32(sp)
    800017b2:	ec56                	sd	s5,24(sp)
    800017b4:	e85a                	sd	s6,16(sp)
    800017b6:	e45e                	sd	s7,8(sp)
    800017b8:	0880                	addi	s0,sp,80
    800017ba:	8a2a                	mv	s4,a0
    800017bc:	8b2e                	mv	s6,a1
    800017be:	8bb2                	mv	s7,a2
    800017c0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017c2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c4:	6985                	lui	s3,0x1
    800017c6:	a035                	j	800017f2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017cc:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ce:	0017b793          	seqz	a5,a5
    800017d2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d6:	60a6                	ld	ra,72(sp)
    800017d8:	6406                	ld	s0,64(sp)
    800017da:	74e2                	ld	s1,56(sp)
    800017dc:	7942                	ld	s2,48(sp)
    800017de:	79a2                	ld	s3,40(sp)
    800017e0:	7a02                	ld	s4,32(sp)
    800017e2:	6ae2                	ld	s5,24(sp)
    800017e4:	6b42                	ld	s6,16(sp)
    800017e6:	6ba2                	ld	s7,8(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ec:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f0:	c8a9                	beqz	s1,80001842 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017f2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f6:	85ca                	mv	a1,s2
    800017f8:	8552                	mv	a0,s4
    800017fa:	00000097          	auipc	ra,0x0
    800017fe:	882080e7          	jalr	-1918(ra) # 8000107c <walkaddr>
    if(pa0 == 0)
    80001802:	c131                	beqz	a0,80001846 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001804:	41790833          	sub	a6,s2,s7
    80001808:	984e                	add	a6,a6,s3
    if(n > max)
    8000180a:	0104f363          	bgeu	s1,a6,80001810 <copyinstr+0x6e>
    8000180e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001810:	955e                	add	a0,a0,s7
    80001812:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001816:	fc080be3          	beqz	a6,800017ec <copyinstr+0x4a>
    8000181a:	985a                	add	a6,a6,s6
    8000181c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000181e:	41650633          	sub	a2,a0,s6
    80001822:	14fd                	addi	s1,s1,-1
    80001824:	9b26                	add	s6,s6,s1
    80001826:	00f60733          	add	a4,a2,a5
    8000182a:	00074703          	lbu	a4,0(a4)
    8000182e:	df49                	beqz	a4,800017c8 <copyinstr+0x26>
        *dst = *p;
    80001830:	00e78023          	sb	a4,0(a5)
      --max;
    80001834:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001838:	0785                	addi	a5,a5,1
    while(n > 0){
    8000183a:	ff0796e3          	bne	a5,a6,80001826 <copyinstr+0x84>
      dst++;
    8000183e:	8b42                	mv	s6,a6
    80001840:	b775                	j	800017ec <copyinstr+0x4a>
    80001842:	4781                	li	a5,0
    80001844:	b769                	j	800017ce <copyinstr+0x2c>
      return -1;
    80001846:	557d                	li	a0,-1
    80001848:	b779                	j	800017d6 <copyinstr+0x34>
  int got_null = 0;
    8000184a:	4781                	li	a5,0
  if(got_null){
    8000184c:	0017b793          	seqz	a5,a5
    80001850:	40f00533          	neg	a0,a5
}
    80001854:	8082                	ret

0000000080001856 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001856:	7139                	addi	sp,sp,-64
    80001858:	fc06                	sd	ra,56(sp)
    8000185a:	f822                	sd	s0,48(sp)
    8000185c:	f426                	sd	s1,40(sp)
    8000185e:	f04a                	sd	s2,32(sp)
    80001860:	ec4e                	sd	s3,24(sp)
    80001862:	e852                	sd	s4,16(sp)
    80001864:	e456                	sd	s5,8(sp)
    80001866:	e05a                	sd	s6,0(sp)
    80001868:	0080                	addi	s0,sp,64
    8000186a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186c:	0000f497          	auipc	s1,0xf
    80001870:	75448493          	addi	s1,s1,1876 # 80010fc0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001874:	8b26                	mv	s6,s1
    80001876:	00006a97          	auipc	s5,0x6
    8000187a:	78aa8a93          	addi	s5,s5,1930 # 80008000 <etext>
    8000187e:	04000937          	lui	s2,0x4000
    80001882:	197d                	addi	s2,s2,-1
    80001884:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	00015a17          	auipc	s4,0x15
    8000188a:	53aa0a13          	addi	s4,s4,1338 # 80016dc0 <tickslock>
    char *pa = kalloc();
    8000188e:	fffff097          	auipc	ra,0xfffff
    80001892:	258080e7          	jalr	600(ra) # 80000ae6 <kalloc>
    80001896:	862a                	mv	a2,a0
    if(pa == 0)
    80001898:	c131                	beqz	a0,800018dc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000189a:	416485b3          	sub	a1,s1,s6
    8000189e:	858d                	srai	a1,a1,0x3
    800018a0:	000ab783          	ld	a5,0(s5)
    800018a4:	02f585b3          	mul	a1,a1,a5
    800018a8:	2585                	addiw	a1,a1,1
    800018aa:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018ae:	4719                	li	a4,6
    800018b0:	6685                	lui	a3,0x1
    800018b2:	40b905b3          	sub	a1,s2,a1
    800018b6:	854e                	mv	a0,s3
    800018b8:	00000097          	auipc	ra,0x0
    800018bc:	8a6080e7          	jalr	-1882(ra) # 8000115e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c0:	17848493          	addi	s1,s1,376
    800018c4:	fd4495e3          	bne	s1,s4,8000188e <proc_mapstacks+0x38>
  }
}
    800018c8:	70e2                	ld	ra,56(sp)
    800018ca:	7442                	ld	s0,48(sp)
    800018cc:	74a2                	ld	s1,40(sp)
    800018ce:	7902                	ld	s2,32(sp)
    800018d0:	69e2                	ld	s3,24(sp)
    800018d2:	6a42                	ld	s4,16(sp)
    800018d4:	6aa2                	ld	s5,8(sp)
    800018d6:	6b02                	ld	s6,0(sp)
    800018d8:	6121                	addi	sp,sp,64
    800018da:	8082                	ret
      panic("kalloc");
    800018dc:	00007517          	auipc	a0,0x7
    800018e0:	95450513          	addi	a0,a0,-1708 # 80008230 <digits+0x1f0>
    800018e4:	fffff097          	auipc	ra,0xfffff
    800018e8:	c5a080e7          	jalr	-934(ra) # 8000053e <panic>

00000000800018ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018ec:	7139                	addi	sp,sp,-64
    800018ee:	fc06                	sd	ra,56(sp)
    800018f0:	f822                	sd	s0,48(sp)
    800018f2:	f426                	sd	s1,40(sp)
    800018f4:	f04a                	sd	s2,32(sp)
    800018f6:	ec4e                	sd	s3,24(sp)
    800018f8:	e852                	sd	s4,16(sp)
    800018fa:	e456                	sd	s5,8(sp)
    800018fc:	e05a                	sd	s6,0(sp)
    800018fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	93858593          	addi	a1,a1,-1736 # 80008238 <digits+0x1f8>
    80001908:	0000f517          	auipc	a0,0xf
    8000190c:	28850513          	addi	a0,a0,648 # 80010b90 <pid_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	236080e7          	jalr	566(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001918:	00007597          	auipc	a1,0x7
    8000191c:	92858593          	addi	a1,a1,-1752 # 80008240 <digits+0x200>
    80001920:	0000f517          	auipc	a0,0xf
    80001924:	28850513          	addi	a0,a0,648 # 80010ba8 <wait_lock>
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	21e080e7          	jalr	542(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	0000f497          	auipc	s1,0xf
    80001934:	69048493          	addi	s1,s1,1680 # 80010fc0 <proc>
      initlock(&p->lock, "proc");
    80001938:	00007b17          	auipc	s6,0x7
    8000193c:	918b0b13          	addi	s6,s6,-1768 # 80008250 <digits+0x210>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001940:	8aa6                	mv	s5,s1
    80001942:	00006a17          	auipc	s4,0x6
    80001946:	6bea0a13          	addi	s4,s4,1726 # 80008000 <etext>
    8000194a:	04000937          	lui	s2,0x4000
    8000194e:	197d                	addi	s2,s2,-1
    80001950:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001952:	00015997          	auipc	s3,0x15
    80001956:	46e98993          	addi	s3,s3,1134 # 80016dc0 <tickslock>
      initlock(&p->lock, "proc");
    8000195a:	85da                	mv	a1,s6
    8000195c:	8526                	mv	a0,s1
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	1e8080e7          	jalr	488(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001966:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000196a:	415487b3          	sub	a5,s1,s5
    8000196e:	878d                	srai	a5,a5,0x3
    80001970:	000a3703          	ld	a4,0(s4)
    80001974:	02e787b3          	mul	a5,a5,a4
    80001978:	2785                	addiw	a5,a5,1
    8000197a:	00d7979b          	slliw	a5,a5,0xd
    8000197e:	40f907b3          	sub	a5,s2,a5
    80001982:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001984:	17848493          	addi	s1,s1,376
    80001988:	fd3499e3          	bne	s1,s3,8000195a <procinit+0x6e>
  }
}
    8000198c:	70e2                	ld	ra,56(sp)
    8000198e:	7442                	ld	s0,48(sp)
    80001990:	74a2                	ld	s1,40(sp)
    80001992:	7902                	ld	s2,32(sp)
    80001994:	69e2                	ld	s3,24(sp)
    80001996:	6a42                	ld	s4,16(sp)
    80001998:	6aa2                	ld	s5,8(sp)
    8000199a:	6b02                	ld	s6,0(sp)
    8000199c:	6121                	addi	sp,sp,64
    8000199e:	8082                	ret

00000000800019a0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019a0:	1141                	addi	sp,sp,-16
    800019a2:	e422                	sd	s0,8(sp)
    800019a4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a8:	2501                	sext.w	a0,a0
    800019aa:	6422                	ld	s0,8(sp)
    800019ac:	0141                	addi	sp,sp,16
    800019ae:	8082                	ret

00000000800019b0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019b0:	1141                	addi	sp,sp,-16
    800019b2:	e422                	sd	s0,8(sp)
    800019b4:	0800                	addi	s0,sp,16
    800019b6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b8:	2781                	sext.w	a5,a5
    800019ba:	079e                	slli	a5,a5,0x7
  return c;
}
    800019bc:	0000f517          	auipc	a0,0xf
    800019c0:	20450513          	addi	a0,a0,516 # 80010bc0 <cpus>
    800019c4:	953e                	add	a0,a0,a5
    800019c6:	6422                	ld	s0,8(sp)
    800019c8:	0141                	addi	sp,sp,16
    800019ca:	8082                	ret

00000000800019cc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019cc:	1101                	addi	sp,sp,-32
    800019ce:	ec06                	sd	ra,24(sp)
    800019d0:	e822                	sd	s0,16(sp)
    800019d2:	e426                	sd	s1,8(sp)
    800019d4:	1000                	addi	s0,sp,32
  push_off();
    800019d6:	fffff097          	auipc	ra,0xfffff
    800019da:	1b4080e7          	jalr	436(ra) # 80000b8a <push_off>
    800019de:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019e0:	2781                	sext.w	a5,a5
    800019e2:	079e                	slli	a5,a5,0x7
    800019e4:	0000f717          	auipc	a4,0xf
    800019e8:	1ac70713          	addi	a4,a4,428 # 80010b90 <pid_lock>
    800019ec:	97ba                	add	a5,a5,a4
    800019ee:	7b84                	ld	s1,48(a5)
  pop_off();
    800019f0:	fffff097          	auipc	ra,0xfffff
    800019f4:	23a080e7          	jalr	570(ra) # 80000c2a <pop_off>
  return p;
}
    800019f8:	8526                	mv	a0,s1
    800019fa:	60e2                	ld	ra,24(sp)
    800019fc:	6442                	ld	s0,16(sp)
    800019fe:	64a2                	ld	s1,8(sp)
    80001a00:	6105                	addi	sp,sp,32
    80001a02:	8082                	ret

0000000080001a04 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a04:	1141                	addi	sp,sp,-16
    80001a06:	e406                	sd	ra,8(sp)
    80001a08:	e022                	sd	s0,0(sp)
    80001a0a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a0c:	00000097          	auipc	ra,0x0
    80001a10:	fc0080e7          	jalr	-64(ra) # 800019cc <myproc>
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	276080e7          	jalr	630(ra) # 80000c8a <release>

  if (first) {
    80001a1c:	00007797          	auipc	a5,0x7
    80001a20:	e847a783          	lw	a5,-380(a5) # 800088a0 <first.1>
    80001a24:	eb89                	bnez	a5,80001a36 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a26:	00001097          	auipc	ra,0x1
    80001a2a:	e96080e7          	jalr	-362(ra) # 800028bc <usertrapret>
}
    80001a2e:	60a2                	ld	ra,8(sp)
    80001a30:	6402                	ld	s0,0(sp)
    80001a32:	0141                	addi	sp,sp,16
    80001a34:	8082                	ret
    first = 0;
    80001a36:	00007797          	auipc	a5,0x7
    80001a3a:	e607a523          	sw	zero,-406(a5) # 800088a0 <first.1>
    fsinit(ROOTDEV);
    80001a3e:	4505                	li	a0,1
    80001a40:	00002097          	auipc	ra,0x2
    80001a44:	c76080e7          	jalr	-906(ra) # 800036b6 <fsinit>
    80001a48:	bff9                	j	80001a26 <forkret+0x22>

0000000080001a4a <allocpid>:
{
    80001a4a:	1101                	addi	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	e04a                	sd	s2,0(sp)
    80001a54:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a56:	0000f917          	auipc	s2,0xf
    80001a5a:	13a90913          	addi	s2,s2,314 # 80010b90 <pid_lock>
    80001a5e:	854a                	mv	a0,s2
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	176080e7          	jalr	374(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a68:	00007797          	auipc	a5,0x7
    80001a6c:	e3c78793          	addi	a5,a5,-452 # 800088a4 <nextpid>
    80001a70:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a72:	0014871b          	addiw	a4,s1,1
    80001a76:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a78:	854a                	mv	a0,s2
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	210080e7          	jalr	528(ra) # 80000c8a <release>
}
    80001a82:	8526                	mv	a0,s1
    80001a84:	60e2                	ld	ra,24(sp)
    80001a86:	6442                	ld	s0,16(sp)
    80001a88:	64a2                	ld	s1,8(sp)
    80001a8a:	6902                	ld	s2,0(sp)
    80001a8c:	6105                	addi	sp,sp,32
    80001a8e:	8082                	ret

0000000080001a90 <proc_pagetable>:
{
    80001a90:	1101                	addi	sp,sp,-32
    80001a92:	ec06                	sd	ra,24(sp)
    80001a94:	e822                	sd	s0,16(sp)
    80001a96:	e426                	sd	s1,8(sp)
    80001a98:	e04a                	sd	s2,0(sp)
    80001a9a:	1000                	addi	s0,sp,32
    80001a9c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a9e:	00000097          	auipc	ra,0x0
    80001aa2:	8aa080e7          	jalr	-1878(ra) # 80001348 <uvmcreate>
    80001aa6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa8:	c121                	beqz	a0,80001ae8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aaa:	4729                	li	a4,10
    80001aac:	00005697          	auipc	a3,0x5
    80001ab0:	55468693          	addi	a3,a3,1364 # 80007000 <_trampoline>
    80001ab4:	6605                	lui	a2,0x1
    80001ab6:	040005b7          	lui	a1,0x4000
    80001aba:	15fd                	addi	a1,a1,-1
    80001abc:	05b2                	slli	a1,a1,0xc
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	600080e7          	jalr	1536(ra) # 800010be <mappages>
    80001ac6:	02054863          	bltz	a0,80001af6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aca:	4719                	li	a4,6
    80001acc:	05893683          	ld	a3,88(s2)
    80001ad0:	6605                	lui	a2,0x1
    80001ad2:	020005b7          	lui	a1,0x2000
    80001ad6:	15fd                	addi	a1,a1,-1
    80001ad8:	05b6                	slli	a1,a1,0xd
    80001ada:	8526                	mv	a0,s1
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	5e2080e7          	jalr	1506(ra) # 800010be <mappages>
    80001ae4:	02054163          	bltz	a0,80001b06 <proc_pagetable+0x76>
}
    80001ae8:	8526                	mv	a0,s1
    80001aea:	60e2                	ld	ra,24(sp)
    80001aec:	6442                	ld	s0,16(sp)
    80001aee:	64a2                	ld	s1,8(sp)
    80001af0:	6902                	ld	s2,0(sp)
    80001af2:	6105                	addi	sp,sp,32
    80001af4:	8082                	ret
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a52080e7          	jalr	-1454(ra) # 8000154c <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	b7d5                	j	80001ae8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b06:	4681                	li	a3,0
    80001b08:	4605                	li	a2,1
    80001b0a:	040005b7          	lui	a1,0x4000
    80001b0e:	15fd                	addi	a1,a1,-1
    80001b10:	05b2                	slli	a1,a1,0xc
    80001b12:	8526                	mv	a0,s1
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	770080e7          	jalr	1904(ra) # 80001284 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b1c:	4581                	li	a1,0
    80001b1e:	8526                	mv	a0,s1
    80001b20:	00000097          	auipc	ra,0x0
    80001b24:	a2c080e7          	jalr	-1492(ra) # 8000154c <uvmfree>
    return 0;
    80001b28:	4481                	li	s1,0
    80001b2a:	bf7d                	j	80001ae8 <proc_pagetable+0x58>

0000000080001b2c <proc_freepagetable>:
{
    80001b2c:	1101                	addi	sp,sp,-32
    80001b2e:	ec06                	sd	ra,24(sp)
    80001b30:	e822                	sd	s0,16(sp)
    80001b32:	e426                	sd	s1,8(sp)
    80001b34:	e04a                	sd	s2,0(sp)
    80001b36:	1000                	addi	s0,sp,32
    80001b38:	84aa                	mv	s1,a0
    80001b3a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b3c:	4681                	li	a3,0
    80001b3e:	4605                	li	a2,1
    80001b40:	040005b7          	lui	a1,0x4000
    80001b44:	15fd                	addi	a1,a1,-1
    80001b46:	05b2                	slli	a1,a1,0xc
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	73c080e7          	jalr	1852(ra) # 80001284 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b50:	4681                	li	a3,0
    80001b52:	4605                	li	a2,1
    80001b54:	020005b7          	lui	a1,0x2000
    80001b58:	15fd                	addi	a1,a1,-1
    80001b5a:	05b6                	slli	a1,a1,0xd
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	726080e7          	jalr	1830(ra) # 80001284 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b66:	85ca                	mv	a1,s2
    80001b68:	8526                	mv	a0,s1
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	9e2080e7          	jalr	-1566(ra) # 8000154c <uvmfree>
}
    80001b72:	60e2                	ld	ra,24(sp)
    80001b74:	6442                	ld	s0,16(sp)
    80001b76:	64a2                	ld	s1,8(sp)
    80001b78:	6902                	ld	s2,0(sp)
    80001b7a:	6105                	addi	sp,sp,32
    80001b7c:	8082                	ret

0000000080001b7e <freeproc>:
{
    80001b7e:	1101                	addi	sp,sp,-32
    80001b80:	ec06                	sd	ra,24(sp)
    80001b82:	e822                	sd	s0,16(sp)
    80001b84:	e426                	sd	s1,8(sp)
    80001b86:	1000                	addi	s0,sp,32
    80001b88:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b8a:	6d28                	ld	a0,88(a0)
    80001b8c:	c509                	beqz	a0,80001b96 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	e5c080e7          	jalr	-420(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b96:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b9a:	68a8                	ld	a0,80(s1)
    80001b9c:	c511                	beqz	a0,80001ba8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b9e:	64ac                	ld	a1,72(s1)
    80001ba0:	00000097          	auipc	ra,0x0
    80001ba4:	f8c080e7          	jalr	-116(ra) # 80001b2c <proc_freepagetable>
  p->pagetable = 0;
    80001ba8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bac:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bb0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bb8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bbc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bc0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bc4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc8:	0004ac23          	sw	zero,24(s1)
}
    80001bcc:	60e2                	ld	ra,24(sp)
    80001bce:	6442                	ld	s0,16(sp)
    80001bd0:	64a2                	ld	s1,8(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret

0000000080001bd6 <allocproc>:
{
    80001bd6:	1101                	addi	sp,sp,-32
    80001bd8:	ec06                	sd	ra,24(sp)
    80001bda:	e822                	sd	s0,16(sp)
    80001bdc:	e426                	sd	s1,8(sp)
    80001bde:	e04a                	sd	s2,0(sp)
    80001be0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be2:	0000f497          	auipc	s1,0xf
    80001be6:	3de48493          	addi	s1,s1,990 # 80010fc0 <proc>
    80001bea:	00015917          	auipc	s2,0x15
    80001bee:	1d690913          	addi	s2,s2,470 # 80016dc0 <tickslock>
    acquire(&p->lock);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	fe2080e7          	jalr	-30(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bfc:	4c9c                	lw	a5,24(s1)
    80001bfe:	cf81                	beqz	a5,80001c16 <allocproc+0x40>
      release(&p->lock);
    80001c00:	8526                	mv	a0,s1
    80001c02:	fffff097          	auipc	ra,0xfffff
    80001c06:	088080e7          	jalr	136(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c0a:	17848493          	addi	s1,s1,376
    80001c0e:	ff2492e3          	bne	s1,s2,80001bf2 <allocproc+0x1c>
  return 0;
    80001c12:	4481                	li	s1,0
    80001c14:	a09d                	j	80001c7a <allocproc+0xa4>
  p->pid = allocpid();
    80001c16:	00000097          	auipc	ra,0x0
    80001c1a:	e34080e7          	jalr	-460(ra) # 80001a4a <allocpid>
    80001c1e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c20:	4785                	li	a5,1
    80001c22:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	ec2080e7          	jalr	-318(ra) # 80000ae6 <kalloc>
    80001c2c:	892a                	mv	s2,a0
    80001c2e:	eca8                	sd	a0,88(s1)
    80001c30:	cd21                	beqz	a0,80001c88 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001c32:	8526                	mv	a0,s1
    80001c34:	00000097          	auipc	ra,0x0
    80001c38:	e5c080e7          	jalr	-420(ra) # 80001a90 <proc_pagetable>
    80001c3c:	892a                	mv	s2,a0
    80001c3e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c40:	c125                	beqz	a0,80001ca0 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001c42:	07000613          	li	a2,112
    80001c46:	4581                	li	a1,0
    80001c48:	06048513          	addi	a0,s1,96
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	086080e7          	jalr	134(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c54:	00000797          	auipc	a5,0x0
    80001c58:	db078793          	addi	a5,a5,-592 # 80001a04 <forkret>
    80001c5c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5e:	60bc                	ld	a5,64(s1)
    80001c60:	6705                	lui	a4,0x1
    80001c62:	97ba                	add	a5,a5,a4
    80001c64:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c66:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c6a:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c6e:	00007797          	auipc	a5,0x7
    80001c72:	cb27a783          	lw	a5,-846(a5) # 80008920 <ticks>
    80001c76:	16f4a623          	sw	a5,364(s1)
}
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	60e2                	ld	ra,24(sp)
    80001c7e:	6442                	ld	s0,16(sp)
    80001c80:	64a2                	ld	s1,8(sp)
    80001c82:	6902                	ld	s2,0(sp)
    80001c84:	6105                	addi	sp,sp,32
    80001c86:	8082                	ret
    freeproc(p);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	00000097          	auipc	ra,0x0
    80001c8e:	ef4080e7          	jalr	-268(ra) # 80001b7e <freeproc>
    release(&p->lock);
    80001c92:	8526                	mv	a0,s1
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	ff6080e7          	jalr	-10(ra) # 80000c8a <release>
    return 0;
    80001c9c:	84ca                	mv	s1,s2
    80001c9e:	bff1                	j	80001c7a <allocproc+0xa4>
    freeproc(p);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	edc080e7          	jalr	-292(ra) # 80001b7e <freeproc>
    release(&p->lock);
    80001caa:	8526                	mv	a0,s1
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	fde080e7          	jalr	-34(ra) # 80000c8a <release>
    return 0;
    80001cb4:	84ca                	mv	s1,s2
    80001cb6:	b7d1                	j	80001c7a <allocproc+0xa4>

0000000080001cb8 <userinit>:
{
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	f14080e7          	jalr	-236(ra) # 80001bd6 <allocproc>
    80001cca:	84aa                	mv	s1,a0
  initproc = p;
    80001ccc:	00007797          	auipc	a5,0x7
    80001cd0:	c4a7b623          	sd	a0,-948(a5) # 80008918 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cd4:	03400613          	li	a2,52
    80001cd8:	00007597          	auipc	a1,0x7
    80001cdc:	bd858593          	addi	a1,a1,-1064 # 800088b0 <initcode>
    80001ce0:	6928                	ld	a0,80(a0)
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	694080e7          	jalr	1684(ra) # 80001376 <uvmfirst>
  p->sz = PGSIZE;
    80001cea:	6785                	lui	a5,0x1
    80001cec:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cee:	6cb8                	ld	a4,88(s1)
    80001cf0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cf4:	6cb8                	ld	a4,88(s1)
    80001cf6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cf8:	4641                	li	a2,16
    80001cfa:	00006597          	auipc	a1,0x6
    80001cfe:	55e58593          	addi	a1,a1,1374 # 80008258 <digits+0x218>
    80001d02:	15848513          	addi	a0,s1,344
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	116080e7          	jalr	278(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d0e:	00006517          	auipc	a0,0x6
    80001d12:	55a50513          	addi	a0,a0,1370 # 80008268 <digits+0x228>
    80001d16:	00002097          	auipc	ra,0x2
    80001d1a:	3c2080e7          	jalr	962(ra) # 800040d8 <namei>
    80001d1e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d22:	478d                	li	a5,3
    80001d24:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d26:	8526                	mv	a0,s1
    80001d28:	fffff097          	auipc	ra,0xfffff
    80001d2c:	f62080e7          	jalr	-158(ra) # 80000c8a <release>
}
    80001d30:	60e2                	ld	ra,24(sp)
    80001d32:	6442                	ld	s0,16(sp)
    80001d34:	64a2                	ld	s1,8(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret

0000000080001d3a <growproc>:
{
    80001d3a:	1101                	addi	sp,sp,-32
    80001d3c:	ec06                	sd	ra,24(sp)
    80001d3e:	e822                	sd	s0,16(sp)
    80001d40:	e426                	sd	s1,8(sp)
    80001d42:	e04a                	sd	s2,0(sp)
    80001d44:	1000                	addi	s0,sp,32
    80001d46:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	c84080e7          	jalr	-892(ra) # 800019cc <myproc>
    80001d50:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d52:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d54:	01204c63          	bgtz	s2,80001d6c <growproc+0x32>
  } else if(n < 0){
    80001d58:	02094663          	bltz	s2,80001d84 <growproc+0x4a>
  p->sz = sz;
    80001d5c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d5e:	4501                	li	a0,0
}
    80001d60:	60e2                	ld	ra,24(sp)
    80001d62:	6442                	ld	s0,16(sp)
    80001d64:	64a2                	ld	s1,8(sp)
    80001d66:	6902                	ld	s2,0(sp)
    80001d68:	6105                	addi	sp,sp,32
    80001d6a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d6c:	4691                	li	a3,4
    80001d6e:	00b90633          	add	a2,s2,a1
    80001d72:	6928                	ld	a0,80(a0)
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	6bc080e7          	jalr	1724(ra) # 80001430 <uvmalloc>
    80001d7c:	85aa                	mv	a1,a0
    80001d7e:	fd79                	bnez	a0,80001d5c <growproc+0x22>
      return -1;
    80001d80:	557d                	li	a0,-1
    80001d82:	bff9                	j	80001d60 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d84:	00b90633          	add	a2,s2,a1
    80001d88:	6928                	ld	a0,80(a0)
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	65e080e7          	jalr	1630(ra) # 800013e8 <uvmdealloc>
    80001d92:	85aa                	mv	a1,a0
    80001d94:	b7e1                	j	80001d5c <growproc+0x22>

0000000080001d96 <fork>:
{
    80001d96:	7139                	addi	sp,sp,-64
    80001d98:	fc06                	sd	ra,56(sp)
    80001d9a:	f822                	sd	s0,48(sp)
    80001d9c:	f426                	sd	s1,40(sp)
    80001d9e:	f04a                	sd	s2,32(sp)
    80001da0:	ec4e                	sd	s3,24(sp)
    80001da2:	e852                	sd	s4,16(sp)
    80001da4:	e456                	sd	s5,8(sp)
    80001da6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001da8:	00000097          	auipc	ra,0x0
    80001dac:	c24080e7          	jalr	-988(ra) # 800019cc <myproc>
    80001db0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	e24080e7          	jalr	-476(ra) # 80001bd6 <allocproc>
    80001dba:	10050c63          	beqz	a0,80001ed2 <fork+0x13c>
    80001dbe:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dc0:	048ab603          	ld	a2,72(s5)
    80001dc4:	692c                	ld	a1,80(a0)
    80001dc6:	050ab503          	ld	a0,80(s5)
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	7ba080e7          	jalr	1978(ra) # 80001584 <uvmcopy>
    80001dd2:	04054863          	bltz	a0,80001e22 <fork+0x8c>
  np->sz = p->sz;
    80001dd6:	048ab783          	ld	a5,72(s5)
    80001dda:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dde:	058ab683          	ld	a3,88(s5)
    80001de2:	87b6                	mv	a5,a3
    80001de4:	058a3703          	ld	a4,88(s4)
    80001de8:	12068693          	addi	a3,a3,288
    80001dec:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df0:	6788                	ld	a0,8(a5)
    80001df2:	6b8c                	ld	a1,16(a5)
    80001df4:	6f90                	ld	a2,24(a5)
    80001df6:	01073023          	sd	a6,0(a4)
    80001dfa:	e708                	sd	a0,8(a4)
    80001dfc:	eb0c                	sd	a1,16(a4)
    80001dfe:	ef10                	sd	a2,24(a4)
    80001e00:	02078793          	addi	a5,a5,32
    80001e04:	02070713          	addi	a4,a4,32
    80001e08:	fed792e3          	bne	a5,a3,80001dec <fork+0x56>
  np->trapframe->a0 = 0;
    80001e0c:	058a3783          	ld	a5,88(s4)
    80001e10:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e14:	0d0a8493          	addi	s1,s5,208
    80001e18:	0d0a0913          	addi	s2,s4,208
    80001e1c:	150a8993          	addi	s3,s5,336
    80001e20:	a00d                	j	80001e42 <fork+0xac>
    freeproc(np);
    80001e22:	8552                	mv	a0,s4
    80001e24:	00000097          	auipc	ra,0x0
    80001e28:	d5a080e7          	jalr	-678(ra) # 80001b7e <freeproc>
    release(&np->lock);
    80001e2c:	8552                	mv	a0,s4
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	e5c080e7          	jalr	-420(ra) # 80000c8a <release>
    return -1;
    80001e36:	597d                	li	s2,-1
    80001e38:	a059                	j	80001ebe <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e3a:	04a1                	addi	s1,s1,8
    80001e3c:	0921                	addi	s2,s2,8
    80001e3e:	01348b63          	beq	s1,s3,80001e54 <fork+0xbe>
    if(p->ofile[i])
    80001e42:	6088                	ld	a0,0(s1)
    80001e44:	d97d                	beqz	a0,80001e3a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e46:	00003097          	auipc	ra,0x3
    80001e4a:	928080e7          	jalr	-1752(ra) # 8000476e <filedup>
    80001e4e:	00a93023          	sd	a0,0(s2)
    80001e52:	b7e5                	j	80001e3a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e54:	150ab503          	ld	a0,336(s5)
    80001e58:	00002097          	auipc	ra,0x2
    80001e5c:	a9c080e7          	jalr	-1380(ra) # 800038f4 <idup>
    80001e60:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e64:	4641                	li	a2,16
    80001e66:	158a8593          	addi	a1,s5,344
    80001e6a:	158a0513          	addi	a0,s4,344
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	fae080e7          	jalr	-82(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e76:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e0e080e7          	jalr	-498(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e84:	0000f497          	auipc	s1,0xf
    80001e88:	d2448493          	addi	s1,s1,-732 # 80010ba8 <wait_lock>
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	d48080e7          	jalr	-696(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e96:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	dee080e7          	jalr	-530(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ea4:	8552                	mv	a0,s4
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	d30080e7          	jalr	-720(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001eae:	478d                	li	a5,3
    80001eb0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	dd4080e7          	jalr	-556(ra) # 80000c8a <release>
}
    80001ebe:	854a                	mv	a0,s2
    80001ec0:	70e2                	ld	ra,56(sp)
    80001ec2:	7442                	ld	s0,48(sp)
    80001ec4:	74a2                	ld	s1,40(sp)
    80001ec6:	7902                	ld	s2,32(sp)
    80001ec8:	69e2                	ld	s3,24(sp)
    80001eca:	6a42                	ld	s4,16(sp)
    80001ecc:	6aa2                	ld	s5,8(sp)
    80001ece:	6121                	addi	sp,sp,64
    80001ed0:	8082                	ret
    return -1;
    80001ed2:	597d                	li	s2,-1
    80001ed4:	b7ed                	j	80001ebe <fork+0x128>

0000000080001ed6 <update_time>:
{
    80001ed6:	7179                	addi	sp,sp,-48
    80001ed8:	f406                	sd	ra,40(sp)
    80001eda:	f022                	sd	s0,32(sp)
    80001edc:	ec26                	sd	s1,24(sp)
    80001ede:	e84a                	sd	s2,16(sp)
    80001ee0:	e44e                	sd	s3,8(sp)
    80001ee2:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ee4:	0000f497          	auipc	s1,0xf
    80001ee8:	0dc48493          	addi	s1,s1,220 # 80010fc0 <proc>
    if(p->state == RUNNING) {
    80001eec:	4991                	li	s3,4
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eee:	00015917          	auipc	s2,0x15
    80001ef2:	ed290913          	addi	s2,s2,-302 # 80016dc0 <tickslock>
    80001ef6:	a811                	j	80001f0a <update_time+0x34>
    release(&p->lock);
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	d90080e7          	jalr	-624(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f02:	17848493          	addi	s1,s1,376
    80001f06:	03248063          	beq	s1,s2,80001f26 <update_time+0x50>
    acquire(&p->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	cca080e7          	jalr	-822(ra) # 80000bd6 <acquire>
    if(p->state == RUNNING) {
    80001f14:	4c9c                	lw	a5,24(s1)
    80001f16:	ff3791e3          	bne	a5,s3,80001ef8 <update_time+0x22>
      p->rtime++;
    80001f1a:	1684a783          	lw	a5,360(s1)
    80001f1e:	2785                	addiw	a5,a5,1
    80001f20:	16f4a423          	sw	a5,360(s1)
    80001f24:	bfd1                	j	80001ef8 <update_time+0x22>
}
    80001f26:	70a2                	ld	ra,40(sp)
    80001f28:	7402                	ld	s0,32(sp)
    80001f2a:	64e2                	ld	s1,24(sp)
    80001f2c:	6942                	ld	s2,16(sp)
    80001f2e:	69a2                	ld	s3,8(sp)
    80001f30:	6145                	addi	sp,sp,48
    80001f32:	8082                	ret

0000000080001f34 <scheduler>:
{
    80001f34:	7119                	addi	sp,sp,-128
    80001f36:	fc86                	sd	ra,120(sp)
    80001f38:	f8a2                	sd	s0,112(sp)
    80001f3a:	f4a6                	sd	s1,104(sp)
    80001f3c:	f0ca                	sd	s2,96(sp)
    80001f3e:	ecce                	sd	s3,88(sp)
    80001f40:	e8d2                	sd	s4,80(sp)
    80001f42:	e4d6                	sd	s5,72(sp)
    80001f44:	e0da                	sd	s6,64(sp)
    80001f46:	fc5e                	sd	s7,56(sp)
    80001f48:	f862                	sd	s8,48(sp)
    80001f4a:	f466                	sd	s9,40(sp)
    80001f4c:	f06a                	sd	s10,32(sp)
    80001f4e:	ec6e                	sd	s11,24(sp)
    80001f50:	0100                	addi	s0,sp,128
    80001f52:	8792                	mv	a5,tp
  int id = r_tp();
    80001f54:	2781                	sext.w	a5,a5
        swtch(&c->context, &first_come_process->context);
    80001f56:	00779693          	slli	a3,a5,0x7
    80001f5a:	0000f717          	auipc	a4,0xf
    80001f5e:	c6e70713          	addi	a4,a4,-914 # 80010bc8 <cpus+0x8>
    80001f62:	9736                	add	a4,a4,a3
    80001f64:	f8e43423          	sd	a4,-120(s0)
      c->proc = 0;
    80001f68:	0000fc97          	auipc	s9,0xf
    80001f6c:	c28c8c93          	addi	s9,s9,-984 # 80010b90 <pid_lock>
    80001f70:	9cb6                	add	s9,s9,a3
        if(p->state == RUNNABLE) {
    80001f72:	4b8d                	li	s7,3
      for(p = proc; p < &proc[NPROC]; p++) {
    80001f74:	00015b17          	auipc	s6,0x15
    80001f78:	e4cb0b13          	addi	s6,s6,-436 # 80016dc0 <tickslock>
      first_come_process = 0;
    80001f7c:	4d01                	li	s10,0
        first_come_process->state = RUNNING;
    80001f7e:	4d91                	li	s11,4
    80001f80:	a851                	j	80002014 <scheduler+0xe0>
            min_creation_time = p->ctime;
    80001f82:	ff49aa83          	lw	s5,-12(s3)
      for(p = proc; p < &proc[NPROC]; p++) {
    80001f86:	0769f463          	bgeu	s3,s6,80001fee <scheduler+0xba>
    80001f8a:	8c52                	mv	s8,s4
    80001f8c:	a005                	j	80001fac <scheduler+0x78>
            min_creation_time = p->ctime;
    80001f8e:	00078a9b          	sext.w	s5,a5
            release(&first_come_process->lock);
    80001f92:	8562                	mv	a0,s8
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	cf6080e7          	jalr	-778(ra) # 80000c8a <release>
            continue;
    80001f9c:	b7ed                	j	80001f86 <scheduler+0x52>
        release(&p->lock);
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	cea080e7          	jalr	-790(ra) # 80000c8a <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001fa8:	09697963          	bgeu	s2,s6,8000203a <scheduler+0x106>
    80001fac:	17848493          	addi	s1,s1,376
    80001fb0:	17890913          	addi	s2,s2,376
    80001fb4:	8a26                	mv	s4,s1
        acquire(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	c1e080e7          	jalr	-994(ra) # 80000bd6 <acquire>
        if(p->state == RUNNABLE) {
    80001fc0:	89ca                	mv	s3,s2
    80001fc2:	ea092783          	lw	a5,-352(s2)
    80001fc6:	fd779ce3          	bne	a5,s7,80001f9e <scheduler+0x6a>
          if(min_creation_time == 0 || first_come_process == 0) {
    80001fca:	fa0a8ce3          	beqz	s5,80001f82 <scheduler+0x4e>
    80001fce:	fa0c0ae3          	beqz	s8,80001f82 <scheduler+0x4e>
          } else if(min_creation_time > p->ctime) {
    80001fd2:	ff492783          	lw	a5,-12(s2)
    80001fd6:	000a871b          	sext.w	a4,s5
    80001fda:	fae7eae3          	bltu	a5,a4,80001f8e <scheduler+0x5a>
        release(&p->lock);
    80001fde:	8526                	mv	a0,s1
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	caa080e7          	jalr	-854(ra) # 80000c8a <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001fe8:	fd6962e3          	bltu	s2,s6,80001fac <scheduler+0x78>
    80001fec:	8a62                	mv	s4,s8
        first_come_process->state = RUNNING;
    80001fee:	01ba2c23          	sw	s11,24(s4)
        c->proc = first_come_process;
    80001ff2:	034cb823          	sd	s4,48(s9)
        swtch(&c->context, &first_come_process->context);
    80001ff6:	060a0593          	addi	a1,s4,96
    80001ffa:	f8843503          	ld	a0,-120(s0)
    80001ffe:	00001097          	auipc	ra,0x1
    80002002:	814080e7          	jalr	-2028(ra) # 80002812 <swtch>
        c->proc = 0;
    80002006:	020cb823          	sd	zero,48(s9)
        release(&first_come_process->lock);
    8000200a:	8552                	mv	a0,s4
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	c7e080e7          	jalr	-898(ra) # 80000c8a <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002014:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002018:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000201c:	10079073          	csrw	sstatus,a5
      c->proc = 0;
    80002020:	020cb823          	sd	zero,48(s9)
      for(p = proc; p < &proc[NPROC]; p++) {
    80002024:	0000f497          	auipc	s1,0xf
    80002028:	f9c48493          	addi	s1,s1,-100 # 80010fc0 <proc>
    8000202c:	0000f917          	auipc	s2,0xf
    80002030:	10c90913          	addi	s2,s2,268 # 80011138 <proc+0x178>
      first_come_process = 0;
    80002034:	8c6a                	mv	s8,s10
      int min_creation_time = 0;
    80002036:	8aea                	mv	s5,s10
    80002038:	bfb5                	j	80001fb4 <scheduler+0x80>
      if(first_come_process != 0) {
    8000203a:	fc0c0de3          	beqz	s8,80002014 <scheduler+0xe0>
    8000203e:	b77d                	j	80001fec <scheduler+0xb8>

0000000080002040 <sched>:
{
    80002040:	7179                	addi	sp,sp,-48
    80002042:	f406                	sd	ra,40(sp)
    80002044:	f022                	sd	s0,32(sp)
    80002046:	ec26                	sd	s1,24(sp)
    80002048:	e84a                	sd	s2,16(sp)
    8000204a:	e44e                	sd	s3,8(sp)
    8000204c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000204e:	00000097          	auipc	ra,0x0
    80002052:	97e080e7          	jalr	-1666(ra) # 800019cc <myproc>
    80002056:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	b04080e7          	jalr	-1276(ra) # 80000b5c <holding>
    80002060:	c93d                	beqz	a0,800020d6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002062:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002064:	2781                	sext.w	a5,a5
    80002066:	079e                	slli	a5,a5,0x7
    80002068:	0000f717          	auipc	a4,0xf
    8000206c:	b2870713          	addi	a4,a4,-1240 # 80010b90 <pid_lock>
    80002070:	97ba                	add	a5,a5,a4
    80002072:	0a87a703          	lw	a4,168(a5)
    80002076:	4785                	li	a5,1
    80002078:	06f71763          	bne	a4,a5,800020e6 <sched+0xa6>
  if(p->state == RUNNING)
    8000207c:	4c98                	lw	a4,24(s1)
    8000207e:	4791                	li	a5,4
    80002080:	06f70b63          	beq	a4,a5,800020f6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002084:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002088:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000208a:	efb5                	bnez	a5,80002106 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000208c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000208e:	0000f917          	auipc	s2,0xf
    80002092:	b0290913          	addi	s2,s2,-1278 # 80010b90 <pid_lock>
    80002096:	2781                	sext.w	a5,a5
    80002098:	079e                	slli	a5,a5,0x7
    8000209a:	97ca                	add	a5,a5,s2
    8000209c:	0ac7a983          	lw	s3,172(a5)
    800020a0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020a2:	2781                	sext.w	a5,a5
    800020a4:	079e                	slli	a5,a5,0x7
    800020a6:	0000f597          	auipc	a1,0xf
    800020aa:	b2258593          	addi	a1,a1,-1246 # 80010bc8 <cpus+0x8>
    800020ae:	95be                	add	a1,a1,a5
    800020b0:	06048513          	addi	a0,s1,96
    800020b4:	00000097          	auipc	ra,0x0
    800020b8:	75e080e7          	jalr	1886(ra) # 80002812 <swtch>
    800020bc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020be:	2781                	sext.w	a5,a5
    800020c0:	079e                	slli	a5,a5,0x7
    800020c2:	97ca                	add	a5,a5,s2
    800020c4:	0b37a623          	sw	s3,172(a5)
}
    800020c8:	70a2                	ld	ra,40(sp)
    800020ca:	7402                	ld	s0,32(sp)
    800020cc:	64e2                	ld	s1,24(sp)
    800020ce:	6942                	ld	s2,16(sp)
    800020d0:	69a2                	ld	s3,8(sp)
    800020d2:	6145                	addi	sp,sp,48
    800020d4:	8082                	ret
    panic("sched p->lock");
    800020d6:	00006517          	auipc	a0,0x6
    800020da:	19a50513          	addi	a0,a0,410 # 80008270 <digits+0x230>
    800020de:	ffffe097          	auipc	ra,0xffffe
    800020e2:	460080e7          	jalr	1120(ra) # 8000053e <panic>
    panic("sched locks");
    800020e6:	00006517          	auipc	a0,0x6
    800020ea:	19a50513          	addi	a0,a0,410 # 80008280 <digits+0x240>
    800020ee:	ffffe097          	auipc	ra,0xffffe
    800020f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
    panic("sched running");
    800020f6:	00006517          	auipc	a0,0x6
    800020fa:	19a50513          	addi	a0,a0,410 # 80008290 <digits+0x250>
    800020fe:	ffffe097          	auipc	ra,0xffffe
    80002102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002106:	00006517          	auipc	a0,0x6
    8000210a:	19a50513          	addi	a0,a0,410 # 800082a0 <digits+0x260>
    8000210e:	ffffe097          	auipc	ra,0xffffe
    80002112:	430080e7          	jalr	1072(ra) # 8000053e <panic>

0000000080002116 <yield>:
{
    80002116:	1101                	addi	sp,sp,-32
    80002118:	ec06                	sd	ra,24(sp)
    8000211a:	e822                	sd	s0,16(sp)
    8000211c:	e426                	sd	s1,8(sp)
    8000211e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002120:	00000097          	auipc	ra,0x0
    80002124:	8ac080e7          	jalr	-1876(ra) # 800019cc <myproc>
    80002128:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	aac080e7          	jalr	-1364(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002132:	478d                	li	a5,3
    80002134:	cc9c                	sw	a5,24(s1)
  sched();
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	f0a080e7          	jalr	-246(ra) # 80002040 <sched>
  release(&p->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	b4a080e7          	jalr	-1206(ra) # 80000c8a <release>
}
    80002148:	60e2                	ld	ra,24(sp)
    8000214a:	6442                	ld	s0,16(sp)
    8000214c:	64a2                	ld	s1,8(sp)
    8000214e:	6105                	addi	sp,sp,32
    80002150:	8082                	ret

0000000080002152 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002152:	7179                	addi	sp,sp,-48
    80002154:	f406                	sd	ra,40(sp)
    80002156:	f022                	sd	s0,32(sp)
    80002158:	ec26                	sd	s1,24(sp)
    8000215a:	e84a                	sd	s2,16(sp)
    8000215c:	e44e                	sd	s3,8(sp)
    8000215e:	1800                	addi	s0,sp,48
    80002160:	89aa                	mv	s3,a0
    80002162:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002164:	00000097          	auipc	ra,0x0
    80002168:	868080e7          	jalr	-1944(ra) # 800019cc <myproc>
    8000216c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	a68080e7          	jalr	-1432(ra) # 80000bd6 <acquire>
  release(lk);
    80002176:	854a                	mv	a0,s2
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	b12080e7          	jalr	-1262(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002180:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002184:	4789                	li	a5,2
    80002186:	cc9c                	sw	a5,24(s1)

  sched();
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	eb8080e7          	jalr	-328(ra) # 80002040 <sched>

  // Tidy up.
  p->chan = 0;
    80002190:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	af4080e7          	jalr	-1292(ra) # 80000c8a <release>
  acquire(lk);
    8000219e:	854a                	mv	a0,s2
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	a36080e7          	jalr	-1482(ra) # 80000bd6 <acquire>
}
    800021a8:	70a2                	ld	ra,40(sp)
    800021aa:	7402                	ld	s0,32(sp)
    800021ac:	64e2                	ld	s1,24(sp)
    800021ae:	6942                	ld	s2,16(sp)
    800021b0:	69a2                	ld	s3,8(sp)
    800021b2:	6145                	addi	sp,sp,48
    800021b4:	8082                	ret

00000000800021b6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021b6:	7139                	addi	sp,sp,-64
    800021b8:	fc06                	sd	ra,56(sp)
    800021ba:	f822                	sd	s0,48(sp)
    800021bc:	f426                	sd	s1,40(sp)
    800021be:	f04a                	sd	s2,32(sp)
    800021c0:	ec4e                	sd	s3,24(sp)
    800021c2:	e852                	sd	s4,16(sp)
    800021c4:	e456                	sd	s5,8(sp)
    800021c6:	0080                	addi	s0,sp,64
    800021c8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021ca:	0000f497          	auipc	s1,0xf
    800021ce:	df648493          	addi	s1,s1,-522 # 80010fc0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021d2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021d4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021d6:	00015917          	auipc	s2,0x15
    800021da:	bea90913          	addi	s2,s2,-1046 # 80016dc0 <tickslock>
    800021de:	a811                	j	800021f2 <wakeup+0x3c>
      }
      release(&p->lock);
    800021e0:	8526                	mv	a0,s1
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	aa8080e7          	jalr	-1368(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021ea:	17848493          	addi	s1,s1,376
    800021ee:	03248663          	beq	s1,s2,8000221a <wakeup+0x64>
    if(p != myproc()){
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	7da080e7          	jalr	2010(ra) # 800019cc <myproc>
    800021fa:	fea488e3          	beq	s1,a0,800021ea <wakeup+0x34>
      acquire(&p->lock);
    800021fe:	8526                	mv	a0,s1
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	9d6080e7          	jalr	-1578(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002208:	4c9c                	lw	a5,24(s1)
    8000220a:	fd379be3          	bne	a5,s3,800021e0 <wakeup+0x2a>
    8000220e:	709c                	ld	a5,32(s1)
    80002210:	fd4798e3          	bne	a5,s4,800021e0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002214:	0154ac23          	sw	s5,24(s1)
    80002218:	b7e1                	j	800021e0 <wakeup+0x2a>
    }
  }
}
    8000221a:	70e2                	ld	ra,56(sp)
    8000221c:	7442                	ld	s0,48(sp)
    8000221e:	74a2                	ld	s1,40(sp)
    80002220:	7902                	ld	s2,32(sp)
    80002222:	69e2                	ld	s3,24(sp)
    80002224:	6a42                	ld	s4,16(sp)
    80002226:	6aa2                	ld	s5,8(sp)
    80002228:	6121                	addi	sp,sp,64
    8000222a:	8082                	ret

000000008000222c <reparent>:
{
    8000222c:	7179                	addi	sp,sp,-48
    8000222e:	f406                	sd	ra,40(sp)
    80002230:	f022                	sd	s0,32(sp)
    80002232:	ec26                	sd	s1,24(sp)
    80002234:	e84a                	sd	s2,16(sp)
    80002236:	e44e                	sd	s3,8(sp)
    80002238:	e052                	sd	s4,0(sp)
    8000223a:	1800                	addi	s0,sp,48
    8000223c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000223e:	0000f497          	auipc	s1,0xf
    80002242:	d8248493          	addi	s1,s1,-638 # 80010fc0 <proc>
      pp->parent = initproc;
    80002246:	00006a17          	auipc	s4,0x6
    8000224a:	6d2a0a13          	addi	s4,s4,1746 # 80008918 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000224e:	00015997          	auipc	s3,0x15
    80002252:	b7298993          	addi	s3,s3,-1166 # 80016dc0 <tickslock>
    80002256:	a029                	j	80002260 <reparent+0x34>
    80002258:	17848493          	addi	s1,s1,376
    8000225c:	01348d63          	beq	s1,s3,80002276 <reparent+0x4a>
    if(pp->parent == p){
    80002260:	7c9c                	ld	a5,56(s1)
    80002262:	ff279be3          	bne	a5,s2,80002258 <reparent+0x2c>
      pp->parent = initproc;
    80002266:	000a3503          	ld	a0,0(s4)
    8000226a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000226c:	00000097          	auipc	ra,0x0
    80002270:	f4a080e7          	jalr	-182(ra) # 800021b6 <wakeup>
    80002274:	b7d5                	j	80002258 <reparent+0x2c>
}
    80002276:	70a2                	ld	ra,40(sp)
    80002278:	7402                	ld	s0,32(sp)
    8000227a:	64e2                	ld	s1,24(sp)
    8000227c:	6942                	ld	s2,16(sp)
    8000227e:	69a2                	ld	s3,8(sp)
    80002280:	6a02                	ld	s4,0(sp)
    80002282:	6145                	addi	sp,sp,48
    80002284:	8082                	ret

0000000080002286 <exit>:
{
    80002286:	7179                	addi	sp,sp,-48
    80002288:	f406                	sd	ra,40(sp)
    8000228a:	f022                	sd	s0,32(sp)
    8000228c:	ec26                	sd	s1,24(sp)
    8000228e:	e84a                	sd	s2,16(sp)
    80002290:	e44e                	sd	s3,8(sp)
    80002292:	e052                	sd	s4,0(sp)
    80002294:	1800                	addi	s0,sp,48
    80002296:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	734080e7          	jalr	1844(ra) # 800019cc <myproc>
    800022a0:	89aa                	mv	s3,a0
  if(p == initproc)
    800022a2:	00006797          	auipc	a5,0x6
    800022a6:	6767b783          	ld	a5,1654(a5) # 80008918 <initproc>
    800022aa:	0d050493          	addi	s1,a0,208
    800022ae:	15050913          	addi	s2,a0,336
    800022b2:	02a79363          	bne	a5,a0,800022d8 <exit+0x52>
    panic("init exiting");
    800022b6:	00006517          	auipc	a0,0x6
    800022ba:	00250513          	addi	a0,a0,2 # 800082b8 <digits+0x278>
    800022be:	ffffe097          	auipc	ra,0xffffe
    800022c2:	280080e7          	jalr	640(ra) # 8000053e <panic>
      fileclose(f);
    800022c6:	00002097          	auipc	ra,0x2
    800022ca:	4fa080e7          	jalr	1274(ra) # 800047c0 <fileclose>
      p->ofile[fd] = 0;
    800022ce:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022d2:	04a1                	addi	s1,s1,8
    800022d4:	01248563          	beq	s1,s2,800022de <exit+0x58>
    if(p->ofile[fd]){
    800022d8:	6088                	ld	a0,0(s1)
    800022da:	f575                	bnez	a0,800022c6 <exit+0x40>
    800022dc:	bfdd                	j	800022d2 <exit+0x4c>
  begin_op();
    800022de:	00002097          	auipc	ra,0x2
    800022e2:	016080e7          	jalr	22(ra) # 800042f4 <begin_op>
  iput(p->cwd);
    800022e6:	1509b503          	ld	a0,336(s3)
    800022ea:	00002097          	auipc	ra,0x2
    800022ee:	802080e7          	jalr	-2046(ra) # 80003aec <iput>
  end_op();
    800022f2:	00002097          	auipc	ra,0x2
    800022f6:	082080e7          	jalr	130(ra) # 80004374 <end_op>
  p->cwd = 0;
    800022fa:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022fe:	0000f497          	auipc	s1,0xf
    80002302:	8aa48493          	addi	s1,s1,-1878 # 80010ba8 <wait_lock>
    80002306:	8526                	mv	a0,s1
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	8ce080e7          	jalr	-1842(ra) # 80000bd6 <acquire>
  reparent(p);
    80002310:	854e                	mv	a0,s3
    80002312:	00000097          	auipc	ra,0x0
    80002316:	f1a080e7          	jalr	-230(ra) # 8000222c <reparent>
  wakeup(p->parent);
    8000231a:	0389b503          	ld	a0,56(s3)
    8000231e:	00000097          	auipc	ra,0x0
    80002322:	e98080e7          	jalr	-360(ra) # 800021b6 <wakeup>
  acquire(&p->lock);
    80002326:	854e                	mv	a0,s3
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	8ae080e7          	jalr	-1874(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002330:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002334:	4795                	li	a5,5
    80002336:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks; // update the exit time of the process
    8000233a:	00006797          	auipc	a5,0x6
    8000233e:	5e67a783          	lw	a5,1510(a5) # 80008920 <ticks>
    80002342:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    80002346:	8526                	mv	a0,s1
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	942080e7          	jalr	-1726(ra) # 80000c8a <release>
  sched();
    80002350:	00000097          	auipc	ra,0x0
    80002354:	cf0080e7          	jalr	-784(ra) # 80002040 <sched>
  panic("zombie exit");
    80002358:	00006517          	auipc	a0,0x6
    8000235c:	f7050513          	addi	a0,a0,-144 # 800082c8 <digits+0x288>
    80002360:	ffffe097          	auipc	ra,0xffffe
    80002364:	1de080e7          	jalr	478(ra) # 8000053e <panic>

0000000080002368 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002368:	7179                	addi	sp,sp,-48
    8000236a:	f406                	sd	ra,40(sp)
    8000236c:	f022                	sd	s0,32(sp)
    8000236e:	ec26                	sd	s1,24(sp)
    80002370:	e84a                	sd	s2,16(sp)
    80002372:	e44e                	sd	s3,8(sp)
    80002374:	1800                	addi	s0,sp,48
    80002376:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002378:	0000f497          	auipc	s1,0xf
    8000237c:	c4848493          	addi	s1,s1,-952 # 80010fc0 <proc>
    80002380:	00015997          	auipc	s3,0x15
    80002384:	a4098993          	addi	s3,s3,-1472 # 80016dc0 <tickslock>
    acquire(&p->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	84c080e7          	jalr	-1972(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002392:	589c                	lw	a5,48(s1)
    80002394:	01278d63          	beq	a5,s2,800023ae <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002398:	8526                	mv	a0,s1
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	8f0080e7          	jalr	-1808(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023a2:	17848493          	addi	s1,s1,376
    800023a6:	ff3491e3          	bne	s1,s3,80002388 <kill+0x20>
  }
  return -1;
    800023aa:	557d                	li	a0,-1
    800023ac:	a829                	j	800023c6 <kill+0x5e>
      p->killed = 1;
    800023ae:	4785                	li	a5,1
    800023b0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023b2:	4c98                	lw	a4,24(s1)
    800023b4:	4789                	li	a5,2
    800023b6:	00f70f63          	beq	a4,a5,800023d4 <kill+0x6c>
      release(&p->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	8ce080e7          	jalr	-1842(ra) # 80000c8a <release>
      return 0;
    800023c4:	4501                	li	a0,0
}
    800023c6:	70a2                	ld	ra,40(sp)
    800023c8:	7402                	ld	s0,32(sp)
    800023ca:	64e2                	ld	s1,24(sp)
    800023cc:	6942                	ld	s2,16(sp)
    800023ce:	69a2                	ld	s3,8(sp)
    800023d0:	6145                	addi	sp,sp,48
    800023d2:	8082                	ret
        p->state = RUNNABLE;
    800023d4:	478d                	li	a5,3
    800023d6:	cc9c                	sw	a5,24(s1)
    800023d8:	b7cd                	j	800023ba <kill+0x52>

00000000800023da <setkilled>:

void
setkilled(struct proc *p)
{
    800023da:	1101                	addi	sp,sp,-32
    800023dc:	ec06                	sd	ra,24(sp)
    800023de:	e822                	sd	s0,16(sp)
    800023e0:	e426                	sd	s1,8(sp)
    800023e2:	1000                	addi	s0,sp,32
    800023e4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023e6:	ffffe097          	auipc	ra,0xffffe
    800023ea:	7f0080e7          	jalr	2032(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800023ee:	4785                	li	a5,1
    800023f0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023f2:	8526                	mv	a0,s1
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	896080e7          	jalr	-1898(ra) # 80000c8a <release>
}
    800023fc:	60e2                	ld	ra,24(sp)
    800023fe:	6442                	ld	s0,16(sp)
    80002400:	64a2                	ld	s1,8(sp)
    80002402:	6105                	addi	sp,sp,32
    80002404:	8082                	ret

0000000080002406 <killed>:

int
killed(struct proc *p)
{
    80002406:	1101                	addi	sp,sp,-32
    80002408:	ec06                	sd	ra,24(sp)
    8000240a:	e822                	sd	s0,16(sp)
    8000240c:	e426                	sd	s1,8(sp)
    8000240e:	e04a                	sd	s2,0(sp)
    80002410:	1000                	addi	s0,sp,32
    80002412:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	7c2080e7          	jalr	1986(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000241c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	fffff097          	auipc	ra,0xfffff
    80002426:	868080e7          	jalr	-1944(ra) # 80000c8a <release>
  return k;
}
    8000242a:	854a                	mv	a0,s2
    8000242c:	60e2                	ld	ra,24(sp)
    8000242e:	6442                	ld	s0,16(sp)
    80002430:	64a2                	ld	s1,8(sp)
    80002432:	6902                	ld	s2,0(sp)
    80002434:	6105                	addi	sp,sp,32
    80002436:	8082                	ret

0000000080002438 <wait>:
{
    80002438:	715d                	addi	sp,sp,-80
    8000243a:	e486                	sd	ra,72(sp)
    8000243c:	e0a2                	sd	s0,64(sp)
    8000243e:	fc26                	sd	s1,56(sp)
    80002440:	f84a                	sd	s2,48(sp)
    80002442:	f44e                	sd	s3,40(sp)
    80002444:	f052                	sd	s4,32(sp)
    80002446:	ec56                	sd	s5,24(sp)
    80002448:	e85a                	sd	s6,16(sp)
    8000244a:	e45e                	sd	s7,8(sp)
    8000244c:	e062                	sd	s8,0(sp)
    8000244e:	0880                	addi	s0,sp,80
    80002450:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	57a080e7          	jalr	1402(ra) # 800019cc <myproc>
    8000245a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000245c:	0000e517          	auipc	a0,0xe
    80002460:	74c50513          	addi	a0,a0,1868 # 80010ba8 <wait_lock>
    80002464:	ffffe097          	auipc	ra,0xffffe
    80002468:	772080e7          	jalr	1906(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000246c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000246e:	4a15                	li	s4,5
        havekids = 1;
    80002470:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002472:	00015997          	auipc	s3,0x15
    80002476:	94e98993          	addi	s3,s3,-1714 # 80016dc0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000247a:	0000ec17          	auipc	s8,0xe
    8000247e:	72ec0c13          	addi	s8,s8,1838 # 80010ba8 <wait_lock>
    havekids = 0;
    80002482:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002484:	0000f497          	auipc	s1,0xf
    80002488:	b3c48493          	addi	s1,s1,-1220 # 80010fc0 <proc>
    8000248c:	a0bd                	j	800024fa <wait+0xc2>
          pid = pp->pid;
    8000248e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002492:	000b0e63          	beqz	s6,800024ae <wait+0x76>
    80002496:	4691                	li	a3,4
    80002498:	02c48613          	addi	a2,s1,44
    8000249c:	85da                	mv	a1,s6
    8000249e:	05093503          	ld	a0,80(s2)
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	1e6080e7          	jalr	486(ra) # 80001688 <copyout>
    800024aa:	02054563          	bltz	a0,800024d4 <wait+0x9c>
          freeproc(pp);
    800024ae:	8526                	mv	a0,s1
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	6ce080e7          	jalr	1742(ra) # 80001b7e <freeproc>
          release(&pp->lock);
    800024b8:	8526                	mv	a0,s1
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	7d0080e7          	jalr	2000(ra) # 80000c8a <release>
          release(&wait_lock);
    800024c2:	0000e517          	auipc	a0,0xe
    800024c6:	6e650513          	addi	a0,a0,1766 # 80010ba8 <wait_lock>
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	7c0080e7          	jalr	1984(ra) # 80000c8a <release>
          return pid;
    800024d2:	a0b5                	j	8000253e <wait+0x106>
            release(&pp->lock);
    800024d4:	8526                	mv	a0,s1
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	7b4080e7          	jalr	1972(ra) # 80000c8a <release>
            release(&wait_lock);
    800024de:	0000e517          	auipc	a0,0xe
    800024e2:	6ca50513          	addi	a0,a0,1738 # 80010ba8 <wait_lock>
    800024e6:	ffffe097          	auipc	ra,0xffffe
    800024ea:	7a4080e7          	jalr	1956(ra) # 80000c8a <release>
            return -1;
    800024ee:	59fd                	li	s3,-1
    800024f0:	a0b9                	j	8000253e <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024f2:	17848493          	addi	s1,s1,376
    800024f6:	03348463          	beq	s1,s3,8000251e <wait+0xe6>
      if(pp->parent == p){
    800024fa:	7c9c                	ld	a5,56(s1)
    800024fc:	ff279be3          	bne	a5,s2,800024f2 <wait+0xba>
        acquire(&pp->lock);
    80002500:	8526                	mv	a0,s1
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	6d4080e7          	jalr	1748(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    8000250a:	4c9c                	lw	a5,24(s1)
    8000250c:	f94781e3          	beq	a5,s4,8000248e <wait+0x56>
        release(&pp->lock);
    80002510:	8526                	mv	a0,s1
    80002512:	ffffe097          	auipc	ra,0xffffe
    80002516:	778080e7          	jalr	1912(ra) # 80000c8a <release>
        havekids = 1;
    8000251a:	8756                	mv	a4,s5
    8000251c:	bfd9                	j	800024f2 <wait+0xba>
    if(!havekids || killed(p)){
    8000251e:	c719                	beqz	a4,8000252c <wait+0xf4>
    80002520:	854a                	mv	a0,s2
    80002522:	00000097          	auipc	ra,0x0
    80002526:	ee4080e7          	jalr	-284(ra) # 80002406 <killed>
    8000252a:	c51d                	beqz	a0,80002558 <wait+0x120>
      release(&wait_lock);
    8000252c:	0000e517          	auipc	a0,0xe
    80002530:	67c50513          	addi	a0,a0,1660 # 80010ba8 <wait_lock>
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	756080e7          	jalr	1878(ra) # 80000c8a <release>
      return -1;
    8000253c:	59fd                	li	s3,-1
}
    8000253e:	854e                	mv	a0,s3
    80002540:	60a6                	ld	ra,72(sp)
    80002542:	6406                	ld	s0,64(sp)
    80002544:	74e2                	ld	s1,56(sp)
    80002546:	7942                	ld	s2,48(sp)
    80002548:	79a2                	ld	s3,40(sp)
    8000254a:	7a02                	ld	s4,32(sp)
    8000254c:	6ae2                	ld	s5,24(sp)
    8000254e:	6b42                	ld	s6,16(sp)
    80002550:	6ba2                	ld	s7,8(sp)
    80002552:	6c02                	ld	s8,0(sp)
    80002554:	6161                	addi	sp,sp,80
    80002556:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002558:	85e2                	mv	a1,s8
    8000255a:	854a                	mv	a0,s2
    8000255c:	00000097          	auipc	ra,0x0
    80002560:	bf6080e7          	jalr	-1034(ra) # 80002152 <sleep>
    havekids = 0;
    80002564:	bf39                	j	80002482 <wait+0x4a>

0000000080002566 <waitx>:
{
    80002566:	711d                	addi	sp,sp,-96
    80002568:	ec86                	sd	ra,88(sp)
    8000256a:	e8a2                	sd	s0,80(sp)
    8000256c:	e4a6                	sd	s1,72(sp)
    8000256e:	e0ca                	sd	s2,64(sp)
    80002570:	fc4e                	sd	s3,56(sp)
    80002572:	f852                	sd	s4,48(sp)
    80002574:	f456                	sd	s5,40(sp)
    80002576:	f05a                	sd	s6,32(sp)
    80002578:	ec5e                	sd	s7,24(sp)
    8000257a:	e862                	sd	s8,16(sp)
    8000257c:	e466                	sd	s9,8(sp)
    8000257e:	e06a                	sd	s10,0(sp)
    80002580:	1080                	addi	s0,sp,96
    80002582:	8b2a                	mv	s6,a0
    80002584:	8bae                	mv	s7,a1
    80002586:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	444080e7          	jalr	1092(ra) # 800019cc <myproc>
    80002590:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002592:	0000e517          	auipc	a0,0xe
    80002596:	61650513          	addi	a0,a0,1558 # 80010ba8 <wait_lock>
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	63c080e7          	jalr	1596(ra) # 80000bd6 <acquire>
    havekids = 0;
    800025a2:	4c81                	li	s9,0
        if(pp->state == ZOMBIE){
    800025a4:	4a15                	li	s4,5
        havekids = 1;
    800025a6:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025a8:	00015997          	auipc	s3,0x15
    800025ac:	81898993          	addi	s3,s3,-2024 # 80016dc0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025b0:	0000ed17          	auipc	s10,0xe
    800025b4:	5f8d0d13          	addi	s10,s10,1528 # 80010ba8 <wait_lock>
    havekids = 0;
    800025b8:	8766                	mv	a4,s9
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ba:	0000f497          	auipc	s1,0xf
    800025be:	a0648493          	addi	s1,s1,-1530 # 80010fc0 <proc>
    800025c2:	a059                	j	80002648 <waitx+0xe2>
          pid = pp->pid;
    800025c4:	0304a983          	lw	s3,48(s1)
          *rtime = pp->rtime;
    800025c8:	1684a703          	lw	a4,360(s1)
    800025cc:	00ec2023          	sw	a4,0(s8)
          *wtime = pp->etime - pp->ctime - pp->rtime;          
    800025d0:	16c4a783          	lw	a5,364(s1)
    800025d4:	9f3d                	addw	a4,a4,a5
    800025d6:	1704a783          	lw	a5,368(s1)
    800025da:	9f99                	subw	a5,a5,a4
    800025dc:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdce60>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025e0:	000b0e63          	beqz	s6,800025fc <waitx+0x96>
    800025e4:	4691                	li	a3,4
    800025e6:	02c48613          	addi	a2,s1,44
    800025ea:	85da                	mv	a1,s6
    800025ec:	05093503          	ld	a0,80(s2)
    800025f0:	fffff097          	auipc	ra,0xfffff
    800025f4:	098080e7          	jalr	152(ra) # 80001688 <copyout>
    800025f8:	02054563          	bltz	a0,80002622 <waitx+0xbc>
          freeproc(pp);
    800025fc:	8526                	mv	a0,s1
    800025fe:	fffff097          	auipc	ra,0xfffff
    80002602:	580080e7          	jalr	1408(ra) # 80001b7e <freeproc>
          release(&pp->lock);
    80002606:	8526                	mv	a0,s1
    80002608:	ffffe097          	auipc	ra,0xffffe
    8000260c:	682080e7          	jalr	1666(ra) # 80000c8a <release>
          release(&wait_lock);
    80002610:	0000e517          	auipc	a0,0xe
    80002614:	59850513          	addi	a0,a0,1432 # 80010ba8 <wait_lock>
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	672080e7          	jalr	1650(ra) # 80000c8a <release>
          return pid;
    80002620:	a0b5                	j	8000268c <waitx+0x126>
            release(&pp->lock);
    80002622:	8526                	mv	a0,s1
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	666080e7          	jalr	1638(ra) # 80000c8a <release>
            release(&wait_lock);
    8000262c:	0000e517          	auipc	a0,0xe
    80002630:	57c50513          	addi	a0,a0,1404 # 80010ba8 <wait_lock>
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	656080e7          	jalr	1622(ra) # 80000c8a <release>
            return -1;
    8000263c:	59fd                	li	s3,-1
    8000263e:	a0b9                	j	8000268c <waitx+0x126>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002640:	17848493          	addi	s1,s1,376
    80002644:	03348463          	beq	s1,s3,8000266c <waitx+0x106>
      if(pp->parent == p){
    80002648:	7c9c                	ld	a5,56(s1)
    8000264a:	ff279be3          	bne	a5,s2,80002640 <waitx+0xda>
        acquire(&pp->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	586080e7          	jalr	1414(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002658:	4c9c                	lw	a5,24(s1)
    8000265a:	f74785e3          	beq	a5,s4,800025c4 <waitx+0x5e>
        release(&pp->lock);
    8000265e:	8526                	mv	a0,s1
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	62a080e7          	jalr	1578(ra) # 80000c8a <release>
        havekids = 1;
    80002668:	8756                	mv	a4,s5
    8000266a:	bfd9                	j	80002640 <waitx+0xda>
    if(!havekids || killed(p)){
    8000266c:	c719                	beqz	a4,8000267a <waitx+0x114>
    8000266e:	854a                	mv	a0,s2
    80002670:	00000097          	auipc	ra,0x0
    80002674:	d96080e7          	jalr	-618(ra) # 80002406 <killed>
    80002678:	c90d                	beqz	a0,800026aa <waitx+0x144>
      release(&wait_lock);
    8000267a:	0000e517          	auipc	a0,0xe
    8000267e:	52e50513          	addi	a0,a0,1326 # 80010ba8 <wait_lock>
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	608080e7          	jalr	1544(ra) # 80000c8a <release>
      return -1;
    8000268a:	59fd                	li	s3,-1
}
    8000268c:	854e                	mv	a0,s3
    8000268e:	60e6                	ld	ra,88(sp)
    80002690:	6446                	ld	s0,80(sp)
    80002692:	64a6                	ld	s1,72(sp)
    80002694:	6906                	ld	s2,64(sp)
    80002696:	79e2                	ld	s3,56(sp)
    80002698:	7a42                	ld	s4,48(sp)
    8000269a:	7aa2                	ld	s5,40(sp)
    8000269c:	7b02                	ld	s6,32(sp)
    8000269e:	6be2                	ld	s7,24(sp)
    800026a0:	6c42                	ld	s8,16(sp)
    800026a2:	6ca2                	ld	s9,8(sp)
    800026a4:	6d02                	ld	s10,0(sp)
    800026a6:	6125                	addi	sp,sp,96
    800026a8:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026aa:	85ea                	mv	a1,s10
    800026ac:	854a                	mv	a0,s2
    800026ae:	00000097          	auipc	ra,0x0
    800026b2:	aa4080e7          	jalr	-1372(ra) # 80002152 <sleep>
    havekids = 0;
    800026b6:	b709                	j	800025b8 <waitx+0x52>

00000000800026b8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026b8:	7179                	addi	sp,sp,-48
    800026ba:	f406                	sd	ra,40(sp)
    800026bc:	f022                	sd	s0,32(sp)
    800026be:	ec26                	sd	s1,24(sp)
    800026c0:	e84a                	sd	s2,16(sp)
    800026c2:	e44e                	sd	s3,8(sp)
    800026c4:	e052                	sd	s4,0(sp)
    800026c6:	1800                	addi	s0,sp,48
    800026c8:	84aa                	mv	s1,a0
    800026ca:	892e                	mv	s2,a1
    800026cc:	89b2                	mv	s3,a2
    800026ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026d0:	fffff097          	auipc	ra,0xfffff
    800026d4:	2fc080e7          	jalr	764(ra) # 800019cc <myproc>
  if(user_dst){
    800026d8:	c08d                	beqz	s1,800026fa <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026da:	86d2                	mv	a3,s4
    800026dc:	864e                	mv	a2,s3
    800026de:	85ca                	mv	a1,s2
    800026e0:	6928                	ld	a0,80(a0)
    800026e2:	fffff097          	auipc	ra,0xfffff
    800026e6:	fa6080e7          	jalr	-90(ra) # 80001688 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026ea:	70a2                	ld	ra,40(sp)
    800026ec:	7402                	ld	s0,32(sp)
    800026ee:	64e2                	ld	s1,24(sp)
    800026f0:	6942                	ld	s2,16(sp)
    800026f2:	69a2                	ld	s3,8(sp)
    800026f4:	6a02                	ld	s4,0(sp)
    800026f6:	6145                	addi	sp,sp,48
    800026f8:	8082                	ret
    memmove((char *)dst, src, len);
    800026fa:	000a061b          	sext.w	a2,s4
    800026fe:	85ce                	mv	a1,s3
    80002700:	854a                	mv	a0,s2
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	62c080e7          	jalr	1580(ra) # 80000d2e <memmove>
    return 0;
    8000270a:	8526                	mv	a0,s1
    8000270c:	bff9                	j	800026ea <either_copyout+0x32>

000000008000270e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000270e:	7179                	addi	sp,sp,-48
    80002710:	f406                	sd	ra,40(sp)
    80002712:	f022                	sd	s0,32(sp)
    80002714:	ec26                	sd	s1,24(sp)
    80002716:	e84a                	sd	s2,16(sp)
    80002718:	e44e                	sd	s3,8(sp)
    8000271a:	e052                	sd	s4,0(sp)
    8000271c:	1800                	addi	s0,sp,48
    8000271e:	892a                	mv	s2,a0
    80002720:	84ae                	mv	s1,a1
    80002722:	89b2                	mv	s3,a2
    80002724:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002726:	fffff097          	auipc	ra,0xfffff
    8000272a:	2a6080e7          	jalr	678(ra) # 800019cc <myproc>
  if(user_src){
    8000272e:	c08d                	beqz	s1,80002750 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002730:	86d2                	mv	a3,s4
    80002732:	864e                	mv	a2,s3
    80002734:	85ca                	mv	a1,s2
    80002736:	6928                	ld	a0,80(a0)
    80002738:	fffff097          	auipc	ra,0xfffff
    8000273c:	fdc080e7          	jalr	-36(ra) # 80001714 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002740:	70a2                	ld	ra,40(sp)
    80002742:	7402                	ld	s0,32(sp)
    80002744:	64e2                	ld	s1,24(sp)
    80002746:	6942                	ld	s2,16(sp)
    80002748:	69a2                	ld	s3,8(sp)
    8000274a:	6a02                	ld	s4,0(sp)
    8000274c:	6145                	addi	sp,sp,48
    8000274e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002750:	000a061b          	sext.w	a2,s4
    80002754:	85ce                	mv	a1,s3
    80002756:	854a                	mv	a0,s2
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	5d6080e7          	jalr	1494(ra) # 80000d2e <memmove>
    return 0;
    80002760:	8526                	mv	a0,s1
    80002762:	bff9                	j	80002740 <either_copyin+0x32>

0000000080002764 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002764:	715d                	addi	sp,sp,-80
    80002766:	e486                	sd	ra,72(sp)
    80002768:	e0a2                	sd	s0,64(sp)
    8000276a:	fc26                	sd	s1,56(sp)
    8000276c:	f84a                	sd	s2,48(sp)
    8000276e:	f44e                	sd	s3,40(sp)
    80002770:	f052                	sd	s4,32(sp)
    80002772:	ec56                	sd	s5,24(sp)
    80002774:	e85a                	sd	s6,16(sp)
    80002776:	e45e                	sd	s7,8(sp)
    80002778:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000277a:	00006517          	auipc	a0,0x6
    8000277e:	9a650513          	addi	a0,a0,-1626 # 80008120 <digits+0xe0>
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	e06080e7          	jalr	-506(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000278a:	0000f497          	auipc	s1,0xf
    8000278e:	98e48493          	addi	s1,s1,-1650 # 80011118 <proc+0x158>
    80002792:	00014917          	auipc	s2,0x14
    80002796:	78690913          	addi	s2,s2,1926 # 80016f18 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000279a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000279c:	00006997          	auipc	s3,0x6
    800027a0:	b3c98993          	addi	s3,s3,-1220 # 800082d8 <digits+0x298>
    printf("%d %s %s", p->pid, state, p->name);
    800027a4:	00006a97          	auipc	s5,0x6
    800027a8:	b3ca8a93          	addi	s5,s5,-1220 # 800082e0 <digits+0x2a0>
    printf("\n");
    800027ac:	00006a17          	auipc	s4,0x6
    800027b0:	974a0a13          	addi	s4,s4,-1676 # 80008120 <digits+0xe0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027b4:	00006b97          	auipc	s7,0x6
    800027b8:	b6cb8b93          	addi	s7,s7,-1172 # 80008320 <states.0>
    800027bc:	a00d                	j	800027de <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027be:	ed86a583          	lw	a1,-296(a3)
    800027c2:	8556                	mv	a0,s5
    800027c4:	ffffe097          	auipc	ra,0xffffe
    800027c8:	dc4080e7          	jalr	-572(ra) # 80000588 <printf>
    printf("\n");
    800027cc:	8552                	mv	a0,s4
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	dba080e7          	jalr	-582(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027d6:	17848493          	addi	s1,s1,376
    800027da:	03248163          	beq	s1,s2,800027fc <procdump+0x98>
    if(p->state == UNUSED)
    800027de:	86a6                	mv	a3,s1
    800027e0:	ec04a783          	lw	a5,-320(s1)
    800027e4:	dbed                	beqz	a5,800027d6 <procdump+0x72>
      state = "???";
    800027e6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027e8:	fcfb6be3          	bltu	s6,a5,800027be <procdump+0x5a>
    800027ec:	1782                	slli	a5,a5,0x20
    800027ee:	9381                	srli	a5,a5,0x20
    800027f0:	078e                	slli	a5,a5,0x3
    800027f2:	97de                	add	a5,a5,s7
    800027f4:	6390                	ld	a2,0(a5)
    800027f6:	f661                	bnez	a2,800027be <procdump+0x5a>
      state = "???";
    800027f8:	864e                	mv	a2,s3
    800027fa:	b7d1                	j	800027be <procdump+0x5a>
  }
}
    800027fc:	60a6                	ld	ra,72(sp)
    800027fe:	6406                	ld	s0,64(sp)
    80002800:	74e2                	ld	s1,56(sp)
    80002802:	7942                	ld	s2,48(sp)
    80002804:	79a2                	ld	s3,40(sp)
    80002806:	7a02                	ld	s4,32(sp)
    80002808:	6ae2                	ld	s5,24(sp)
    8000280a:	6b42                	ld	s6,16(sp)
    8000280c:	6ba2                	ld	s7,8(sp)
    8000280e:	6161                	addi	sp,sp,80
    80002810:	8082                	ret

0000000080002812 <swtch>:
    80002812:	00153023          	sd	ra,0(a0)
    80002816:	00253423          	sd	sp,8(a0)
    8000281a:	e900                	sd	s0,16(a0)
    8000281c:	ed04                	sd	s1,24(a0)
    8000281e:	03253023          	sd	s2,32(a0)
    80002822:	03353423          	sd	s3,40(a0)
    80002826:	03453823          	sd	s4,48(a0)
    8000282a:	03553c23          	sd	s5,56(a0)
    8000282e:	05653023          	sd	s6,64(a0)
    80002832:	05753423          	sd	s7,72(a0)
    80002836:	05853823          	sd	s8,80(a0)
    8000283a:	05953c23          	sd	s9,88(a0)
    8000283e:	07a53023          	sd	s10,96(a0)
    80002842:	07b53423          	sd	s11,104(a0)
    80002846:	0005b083          	ld	ra,0(a1)
    8000284a:	0085b103          	ld	sp,8(a1)
    8000284e:	6980                	ld	s0,16(a1)
    80002850:	6d84                	ld	s1,24(a1)
    80002852:	0205b903          	ld	s2,32(a1)
    80002856:	0285b983          	ld	s3,40(a1)
    8000285a:	0305ba03          	ld	s4,48(a1)
    8000285e:	0385ba83          	ld	s5,56(a1)
    80002862:	0405bb03          	ld	s6,64(a1)
    80002866:	0485bb83          	ld	s7,72(a1)
    8000286a:	0505bc03          	ld	s8,80(a1)
    8000286e:	0585bc83          	ld	s9,88(a1)
    80002872:	0605bd03          	ld	s10,96(a1)
    80002876:	0685bd83          	ld	s11,104(a1)
    8000287a:	8082                	ret

000000008000287c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000287c:	1141                	addi	sp,sp,-16
    8000287e:	e406                	sd	ra,8(sp)
    80002880:	e022                	sd	s0,0(sp)
    80002882:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002884:	00006597          	auipc	a1,0x6
    80002888:	acc58593          	addi	a1,a1,-1332 # 80008350 <states.0+0x30>
    8000288c:	00014517          	auipc	a0,0x14
    80002890:	53450513          	addi	a0,a0,1332 # 80016dc0 <tickslock>
    80002894:	ffffe097          	auipc	ra,0xffffe
    80002898:	2b2080e7          	jalr	690(ra) # 80000b46 <initlock>
}
    8000289c:	60a2                	ld	ra,8(sp)
    8000289e:	6402                	ld	s0,0(sp)
    800028a0:	0141                	addi	sp,sp,16
    800028a2:	8082                	ret

00000000800028a4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028a4:	1141                	addi	sp,sp,-16
    800028a6:	e422                	sd	s0,8(sp)
    800028a8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028aa:	00003797          	auipc	a5,0x3
    800028ae:	56678793          	addi	a5,a5,1382 # 80005e10 <kernelvec>
    800028b2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028b6:	6422                	ld	s0,8(sp)
    800028b8:	0141                	addi	sp,sp,16
    800028ba:	8082                	ret

00000000800028bc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028bc:	1141                	addi	sp,sp,-16
    800028be:	e406                	sd	ra,8(sp)
    800028c0:	e022                	sd	s0,0(sp)
    800028c2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028c4:	fffff097          	auipc	ra,0xfffff
    800028c8:	108080e7          	jalr	264(ra) # 800019cc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028cc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028d0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028d6:	00004617          	auipc	a2,0x4
    800028da:	72a60613          	addi	a2,a2,1834 # 80007000 <_trampoline>
    800028de:	00004697          	auipc	a3,0x4
    800028e2:	72268693          	addi	a3,a3,1826 # 80007000 <_trampoline>
    800028e6:	8e91                	sub	a3,a3,a2
    800028e8:	040007b7          	lui	a5,0x4000
    800028ec:	17fd                	addi	a5,a5,-1
    800028ee:	07b2                	slli	a5,a5,0xc
    800028f0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028f2:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028f6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028f8:	180026f3          	csrr	a3,satp
    800028fc:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028fe:	6d38                	ld	a4,88(a0)
    80002900:	6134                	ld	a3,64(a0)
    80002902:	6585                	lui	a1,0x1
    80002904:	96ae                	add	a3,a3,a1
    80002906:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002908:	6d38                	ld	a4,88(a0)
    8000290a:	00000697          	auipc	a3,0x0
    8000290e:	13e68693          	addi	a3,a3,318 # 80002a48 <usertrap>
    80002912:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002914:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002916:	8692                	mv	a3,tp
    80002918:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000291e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002922:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002926:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000292a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000292c:	6f18                	ld	a4,24(a4)
    8000292e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002932:	6928                	ld	a0,80(a0)
    80002934:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002936:	00004717          	auipc	a4,0x4
    8000293a:	76670713          	addi	a4,a4,1894 # 8000709c <userret>
    8000293e:	8f11                	sub	a4,a4,a2
    80002940:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002942:	577d                	li	a4,-1
    80002944:	177e                	slli	a4,a4,0x3f
    80002946:	8d59                	or	a0,a0,a4
    80002948:	9782                	jalr	a5
}
    8000294a:	60a2                	ld	ra,8(sp)
    8000294c:	6402                	ld	s0,0(sp)
    8000294e:	0141                	addi	sp,sp,16
    80002950:	8082                	ret

0000000080002952 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002952:	1101                	addi	sp,sp,-32
    80002954:	ec06                	sd	ra,24(sp)
    80002956:	e822                	sd	s0,16(sp)
    80002958:	e426                	sd	s1,8(sp)
    8000295a:	e04a                	sd	s2,0(sp)
    8000295c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000295e:	00014917          	auipc	s2,0x14
    80002962:	46290913          	addi	s2,s2,1122 # 80016dc0 <tickslock>
    80002966:	854a                	mv	a0,s2
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	26e080e7          	jalr	622(ra) # 80000bd6 <acquire>
  ticks++;
    80002970:	00006497          	auipc	s1,0x6
    80002974:	fb048493          	addi	s1,s1,-80 # 80008920 <ticks>
    80002978:	409c                	lw	a5,0(s1)
    8000297a:	2785                	addiw	a5,a5,1
    8000297c:	c09c                	sw	a5,0(s1)
  update_time();
    8000297e:	fffff097          	auipc	ra,0xfffff
    80002982:	558080e7          	jalr	1368(ra) # 80001ed6 <update_time>
  wakeup(&ticks);
    80002986:	8526                	mv	a0,s1
    80002988:	00000097          	auipc	ra,0x0
    8000298c:	82e080e7          	jalr	-2002(ra) # 800021b6 <wakeup>
  release(&tickslock);
    80002990:	854a                	mv	a0,s2
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	2f8080e7          	jalr	760(ra) # 80000c8a <release>
}
    8000299a:	60e2                	ld	ra,24(sp)
    8000299c:	6442                	ld	s0,16(sp)
    8000299e:	64a2                	ld	s1,8(sp)
    800029a0:	6902                	ld	s2,0(sp)
    800029a2:	6105                	addi	sp,sp,32
    800029a4:	8082                	ret

00000000800029a6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029a6:	1101                	addi	sp,sp,-32
    800029a8:	ec06                	sd	ra,24(sp)
    800029aa:	e822                	sd	s0,16(sp)
    800029ac:	e426                	sd	s1,8(sp)
    800029ae:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029b0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029b4:	00074d63          	bltz	a4,800029ce <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029b8:	57fd                	li	a5,-1
    800029ba:	17fe                	slli	a5,a5,0x3f
    800029bc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029be:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029c0:	06f70363          	beq	a4,a5,80002a26 <devintr+0x80>
  }
}
    800029c4:	60e2                	ld	ra,24(sp)
    800029c6:	6442                	ld	s0,16(sp)
    800029c8:	64a2                	ld	s1,8(sp)
    800029ca:	6105                	addi	sp,sp,32
    800029cc:	8082                	ret
     (scause & 0xff) == 9){
    800029ce:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800029d2:	46a5                	li	a3,9
    800029d4:	fed792e3          	bne	a5,a3,800029b8 <devintr+0x12>
    int irq = plic_claim();
    800029d8:	00003097          	auipc	ra,0x3
    800029dc:	540080e7          	jalr	1344(ra) # 80005f18 <plic_claim>
    800029e0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029e2:	47a9                	li	a5,10
    800029e4:	02f50763          	beq	a0,a5,80002a12 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800029e8:	4785                	li	a5,1
    800029ea:	02f50963          	beq	a0,a5,80002a1c <devintr+0x76>
    return 1;
    800029ee:	4505                	li	a0,1
    } else if(irq){
    800029f0:	d8f1                	beqz	s1,800029c4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029f2:	85a6                	mv	a1,s1
    800029f4:	00006517          	auipc	a0,0x6
    800029f8:	96450513          	addi	a0,a0,-1692 # 80008358 <states.0+0x38>
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	b8c080e7          	jalr	-1140(ra) # 80000588 <printf>
      plic_complete(irq);
    80002a04:	8526                	mv	a0,s1
    80002a06:	00003097          	auipc	ra,0x3
    80002a0a:	536080e7          	jalr	1334(ra) # 80005f3c <plic_complete>
    return 1;
    80002a0e:	4505                	li	a0,1
    80002a10:	bf55                	j	800029c4 <devintr+0x1e>
      uartintr();
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	f88080e7          	jalr	-120(ra) # 8000099a <uartintr>
    80002a1a:	b7ed                	j	80002a04 <devintr+0x5e>
      virtio_disk_intr();
    80002a1c:	00004097          	auipc	ra,0x4
    80002a20:	9ec080e7          	jalr	-1556(ra) # 80006408 <virtio_disk_intr>
    80002a24:	b7c5                	j	80002a04 <devintr+0x5e>
    if(cpuid() == 0){
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	f7a080e7          	jalr	-134(ra) # 800019a0 <cpuid>
    80002a2e:	c901                	beqz	a0,80002a3e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a30:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a36:	14479073          	csrw	sip,a5
    return 2;
    80002a3a:	4509                	li	a0,2
    80002a3c:	b761                	j	800029c4 <devintr+0x1e>
      clockintr();
    80002a3e:	00000097          	auipc	ra,0x0
    80002a42:	f14080e7          	jalr	-236(ra) # 80002952 <clockintr>
    80002a46:	b7ed                	j	80002a30 <devintr+0x8a>

0000000080002a48 <usertrap>:
{
    80002a48:	1101                	addi	sp,sp,-32
    80002a4a:	ec06                	sd	ra,24(sp)
    80002a4c:	e822                	sd	s0,16(sp)
    80002a4e:	e426                	sd	s1,8(sp)
    80002a50:	e04a                	sd	s2,0(sp)
    80002a52:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a54:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a58:	1007f793          	andi	a5,a5,256
    80002a5c:	e3b1                	bnez	a5,80002aa0 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a5e:	00003797          	auipc	a5,0x3
    80002a62:	3b278793          	addi	a5,a5,946 # 80005e10 <kernelvec>
    80002a66:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	f62080e7          	jalr	-158(ra) # 800019cc <myproc>
    80002a72:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a74:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a76:	14102773          	csrr	a4,sepc
    80002a7a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a7c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a80:	47a1                	li	a5,8
    80002a82:	02f70763          	beq	a4,a5,80002ab0 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a86:	00000097          	auipc	ra,0x0
    80002a8a:	f20080e7          	jalr	-224(ra) # 800029a6 <devintr>
    80002a8e:	892a                	mv	s2,a0
    80002a90:	c151                	beqz	a0,80002b14 <usertrap+0xcc>
  if(killed(p))
    80002a92:	8526                	mv	a0,s1
    80002a94:	00000097          	auipc	ra,0x0
    80002a98:	972080e7          	jalr	-1678(ra) # 80002406 <killed>
    80002a9c:	c929                	beqz	a0,80002aee <usertrap+0xa6>
    80002a9e:	a099                	j	80002ae4 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002aa0:	00006517          	auipc	a0,0x6
    80002aa4:	8d850513          	addi	a0,a0,-1832 # 80008378 <states.0+0x58>
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	a96080e7          	jalr	-1386(ra) # 8000053e <panic>
    if(killed(p))
    80002ab0:	00000097          	auipc	ra,0x0
    80002ab4:	956080e7          	jalr	-1706(ra) # 80002406 <killed>
    80002ab8:	e921                	bnez	a0,80002b08 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002aba:	6cb8                	ld	a4,88(s1)
    80002abc:	6f1c                	ld	a5,24(a4)
    80002abe:	0791                	addi	a5,a5,4
    80002ac0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ac2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ac6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aca:	10079073          	csrw	sstatus,a5
    syscall();
    80002ace:	00000097          	auipc	ra,0x0
    80002ad2:	2d4080e7          	jalr	724(ra) # 80002da2 <syscall>
  if(killed(p))
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	00000097          	auipc	ra,0x0
    80002adc:	92e080e7          	jalr	-1746(ra) # 80002406 <killed>
    80002ae0:	c911                	beqz	a0,80002af4 <usertrap+0xac>
    80002ae2:	4901                	li	s2,0
    exit(-1);
    80002ae4:	557d                	li	a0,-1
    80002ae6:	fffff097          	auipc	ra,0xfffff
    80002aea:	7a0080e7          	jalr	1952(ra) # 80002286 <exit>
  if(which_dev == 2)
    80002aee:	4789                	li	a5,2
    80002af0:	04f90f63          	beq	s2,a5,80002b4e <usertrap+0x106>
  usertrapret();
    80002af4:	00000097          	auipc	ra,0x0
    80002af8:	dc8080e7          	jalr	-568(ra) # 800028bc <usertrapret>
}
    80002afc:	60e2                	ld	ra,24(sp)
    80002afe:	6442                	ld	s0,16(sp)
    80002b00:	64a2                	ld	s1,8(sp)
    80002b02:	6902                	ld	s2,0(sp)
    80002b04:	6105                	addi	sp,sp,32
    80002b06:	8082                	ret
      exit(-1);
    80002b08:	557d                	li	a0,-1
    80002b0a:	fffff097          	auipc	ra,0xfffff
    80002b0e:	77c080e7          	jalr	1916(ra) # 80002286 <exit>
    80002b12:	b765                	j	80002aba <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b14:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b18:	5890                	lw	a2,48(s1)
    80002b1a:	00006517          	auipc	a0,0x6
    80002b1e:	87e50513          	addi	a0,a0,-1922 # 80008398 <states.0+0x78>
    80002b22:	ffffe097          	auipc	ra,0xffffe
    80002b26:	a66080e7          	jalr	-1434(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b2a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b2e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b32:	00006517          	auipc	a0,0x6
    80002b36:	89650513          	addi	a0,a0,-1898 # 800083c8 <states.0+0xa8>
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	a4e080e7          	jalr	-1458(ra) # 80000588 <printf>
    setkilled(p);
    80002b42:	8526                	mv	a0,s1
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	896080e7          	jalr	-1898(ra) # 800023da <setkilled>
    80002b4c:	b769                	j	80002ad6 <usertrap+0x8e>
    yield();
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	5c8080e7          	jalr	1480(ra) # 80002116 <yield>
    80002b56:	bf79                	j	80002af4 <usertrap+0xac>

0000000080002b58 <kerneltrap>:
{
    80002b58:	7179                	addi	sp,sp,-48
    80002b5a:	f406                	sd	ra,40(sp)
    80002b5c:	f022                	sd	s0,32(sp)
    80002b5e:	ec26                	sd	s1,24(sp)
    80002b60:	e84a                	sd	s2,16(sp)
    80002b62:	e44e                	sd	s3,8(sp)
    80002b64:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b66:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b6a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b6e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b72:	1004f793          	andi	a5,s1,256
    80002b76:	cb85                	beqz	a5,80002ba6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b7c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b7e:	ef85                	bnez	a5,80002bb6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b80:	00000097          	auipc	ra,0x0
    80002b84:	e26080e7          	jalr	-474(ra) # 800029a6 <devintr>
    80002b88:	cd1d                	beqz	a0,80002bc6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b8a:	4789                	li	a5,2
    80002b8c:	06f50a63          	beq	a0,a5,80002c00 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b90:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b94:	10049073          	csrw	sstatus,s1
}
    80002b98:	70a2                	ld	ra,40(sp)
    80002b9a:	7402                	ld	s0,32(sp)
    80002b9c:	64e2                	ld	s1,24(sp)
    80002b9e:	6942                	ld	s2,16(sp)
    80002ba0:	69a2                	ld	s3,8(sp)
    80002ba2:	6145                	addi	sp,sp,48
    80002ba4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ba6:	00006517          	auipc	a0,0x6
    80002baa:	84250513          	addi	a0,a0,-1982 # 800083e8 <states.0+0xc8>
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	990080e7          	jalr	-1648(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002bb6:	00006517          	auipc	a0,0x6
    80002bba:	85a50513          	addi	a0,a0,-1958 # 80008410 <states.0+0xf0>
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	980080e7          	jalr	-1664(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002bc6:	85ce                	mv	a1,s3
    80002bc8:	00006517          	auipc	a0,0x6
    80002bcc:	86850513          	addi	a0,a0,-1944 # 80008430 <states.0+0x110>
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	9b8080e7          	jalr	-1608(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bd8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bdc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002be0:	00006517          	auipc	a0,0x6
    80002be4:	86050513          	addi	a0,a0,-1952 # 80008440 <states.0+0x120>
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	9a0080e7          	jalr	-1632(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002bf0:	00006517          	auipc	a0,0x6
    80002bf4:	86850513          	addi	a0,a0,-1944 # 80008458 <states.0+0x138>
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	946080e7          	jalr	-1722(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	dcc080e7          	jalr	-564(ra) # 800019cc <myproc>
    80002c08:	d541                	beqz	a0,80002b90 <kerneltrap+0x38>
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	dc2080e7          	jalr	-574(ra) # 800019cc <myproc>
    80002c12:	4d18                	lw	a4,24(a0)
    80002c14:	4791                	li	a5,4
    80002c16:	f6f71de3          	bne	a4,a5,80002b90 <kerneltrap+0x38>
    yield();
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	4fc080e7          	jalr	1276(ra) # 80002116 <yield>
    80002c22:	b7bd                	j	80002b90 <kerneltrap+0x38>

0000000080002c24 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c24:	1101                	addi	sp,sp,-32
    80002c26:	ec06                	sd	ra,24(sp)
    80002c28:	e822                	sd	s0,16(sp)
    80002c2a:	e426                	sd	s1,8(sp)
    80002c2c:	1000                	addi	s0,sp,32
    80002c2e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	d9c080e7          	jalr	-612(ra) # 800019cc <myproc>
  switch (n) {
    80002c38:	4795                	li	a5,5
    80002c3a:	0497e163          	bltu	a5,s1,80002c7c <argraw+0x58>
    80002c3e:	048a                	slli	s1,s1,0x2
    80002c40:	00006717          	auipc	a4,0x6
    80002c44:	85070713          	addi	a4,a4,-1968 # 80008490 <states.0+0x170>
    80002c48:	94ba                	add	s1,s1,a4
    80002c4a:	409c                	lw	a5,0(s1)
    80002c4c:	97ba                	add	a5,a5,a4
    80002c4e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c50:	6d3c                	ld	a5,88(a0)
    80002c52:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c54:	60e2                	ld	ra,24(sp)
    80002c56:	6442                	ld	s0,16(sp)
    80002c58:	64a2                	ld	s1,8(sp)
    80002c5a:	6105                	addi	sp,sp,32
    80002c5c:	8082                	ret
    return p->trapframe->a1;
    80002c5e:	6d3c                	ld	a5,88(a0)
    80002c60:	7fa8                	ld	a0,120(a5)
    80002c62:	bfcd                	j	80002c54 <argraw+0x30>
    return p->trapframe->a2;
    80002c64:	6d3c                	ld	a5,88(a0)
    80002c66:	63c8                	ld	a0,128(a5)
    80002c68:	b7f5                	j	80002c54 <argraw+0x30>
    return p->trapframe->a3;
    80002c6a:	6d3c                	ld	a5,88(a0)
    80002c6c:	67c8                	ld	a0,136(a5)
    80002c6e:	b7dd                	j	80002c54 <argraw+0x30>
    return p->trapframe->a4;
    80002c70:	6d3c                	ld	a5,88(a0)
    80002c72:	6bc8                	ld	a0,144(a5)
    80002c74:	b7c5                	j	80002c54 <argraw+0x30>
    return p->trapframe->a5;
    80002c76:	6d3c                	ld	a5,88(a0)
    80002c78:	6fc8                	ld	a0,152(a5)
    80002c7a:	bfe9                	j	80002c54 <argraw+0x30>
  panic("argraw");
    80002c7c:	00005517          	auipc	a0,0x5
    80002c80:	7ec50513          	addi	a0,a0,2028 # 80008468 <states.0+0x148>
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	8ba080e7          	jalr	-1862(ra) # 8000053e <panic>

0000000080002c8c <fetchaddr>:
{
    80002c8c:	1101                	addi	sp,sp,-32
    80002c8e:	ec06                	sd	ra,24(sp)
    80002c90:	e822                	sd	s0,16(sp)
    80002c92:	e426                	sd	s1,8(sp)
    80002c94:	e04a                	sd	s2,0(sp)
    80002c96:	1000                	addi	s0,sp,32
    80002c98:	84aa                	mv	s1,a0
    80002c9a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	d30080e7          	jalr	-720(ra) # 800019cc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ca4:	653c                	ld	a5,72(a0)
    80002ca6:	02f4f863          	bgeu	s1,a5,80002cd6 <fetchaddr+0x4a>
    80002caa:	00848713          	addi	a4,s1,8
    80002cae:	02e7e663          	bltu	a5,a4,80002cda <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cb2:	46a1                	li	a3,8
    80002cb4:	8626                	mv	a2,s1
    80002cb6:	85ca                	mv	a1,s2
    80002cb8:	6928                	ld	a0,80(a0)
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	a5a080e7          	jalr	-1446(ra) # 80001714 <copyin>
    80002cc2:	00a03533          	snez	a0,a0
    80002cc6:	40a00533          	neg	a0,a0
}
    80002cca:	60e2                	ld	ra,24(sp)
    80002ccc:	6442                	ld	s0,16(sp)
    80002cce:	64a2                	ld	s1,8(sp)
    80002cd0:	6902                	ld	s2,0(sp)
    80002cd2:	6105                	addi	sp,sp,32
    80002cd4:	8082                	ret
    return -1;
    80002cd6:	557d                	li	a0,-1
    80002cd8:	bfcd                	j	80002cca <fetchaddr+0x3e>
    80002cda:	557d                	li	a0,-1
    80002cdc:	b7fd                	j	80002cca <fetchaddr+0x3e>

0000000080002cde <fetchstr>:
{
    80002cde:	7179                	addi	sp,sp,-48
    80002ce0:	f406                	sd	ra,40(sp)
    80002ce2:	f022                	sd	s0,32(sp)
    80002ce4:	ec26                	sd	s1,24(sp)
    80002ce6:	e84a                	sd	s2,16(sp)
    80002ce8:	e44e                	sd	s3,8(sp)
    80002cea:	1800                	addi	s0,sp,48
    80002cec:	892a                	mv	s2,a0
    80002cee:	84ae                	mv	s1,a1
    80002cf0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cf2:	fffff097          	auipc	ra,0xfffff
    80002cf6:	cda080e7          	jalr	-806(ra) # 800019cc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cfa:	86ce                	mv	a3,s3
    80002cfc:	864a                	mv	a2,s2
    80002cfe:	85a6                	mv	a1,s1
    80002d00:	6928                	ld	a0,80(a0)
    80002d02:	fffff097          	auipc	ra,0xfffff
    80002d06:	aa0080e7          	jalr	-1376(ra) # 800017a2 <copyinstr>
    80002d0a:	00054e63          	bltz	a0,80002d26 <fetchstr+0x48>
  return strlen(buf);
    80002d0e:	8526                	mv	a0,s1
    80002d10:	ffffe097          	auipc	ra,0xffffe
    80002d14:	13e080e7          	jalr	318(ra) # 80000e4e <strlen>
}
    80002d18:	70a2                	ld	ra,40(sp)
    80002d1a:	7402                	ld	s0,32(sp)
    80002d1c:	64e2                	ld	s1,24(sp)
    80002d1e:	6942                	ld	s2,16(sp)
    80002d20:	69a2                	ld	s3,8(sp)
    80002d22:	6145                	addi	sp,sp,48
    80002d24:	8082                	ret
    return -1;
    80002d26:	557d                	li	a0,-1
    80002d28:	bfc5                	j	80002d18 <fetchstr+0x3a>

0000000080002d2a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d2a:	1101                	addi	sp,sp,-32
    80002d2c:	ec06                	sd	ra,24(sp)
    80002d2e:	e822                	sd	s0,16(sp)
    80002d30:	e426                	sd	s1,8(sp)
    80002d32:	1000                	addi	s0,sp,32
    80002d34:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d36:	00000097          	auipc	ra,0x0
    80002d3a:	eee080e7          	jalr	-274(ra) # 80002c24 <argraw>
    80002d3e:	c088                	sw	a0,0(s1)
}
    80002d40:	60e2                	ld	ra,24(sp)
    80002d42:	6442                	ld	s0,16(sp)
    80002d44:	64a2                	ld	s1,8(sp)
    80002d46:	6105                	addi	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	e426                	sd	s1,8(sp)
    80002d52:	1000                	addi	s0,sp,32
    80002d54:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	ece080e7          	jalr	-306(ra) # 80002c24 <argraw>
    80002d5e:	e088                	sd	a0,0(s1)
}
    80002d60:	60e2                	ld	ra,24(sp)
    80002d62:	6442                	ld	s0,16(sp)
    80002d64:	64a2                	ld	s1,8(sp)
    80002d66:	6105                	addi	sp,sp,32
    80002d68:	8082                	ret

0000000080002d6a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d6a:	7179                	addi	sp,sp,-48
    80002d6c:	f406                	sd	ra,40(sp)
    80002d6e:	f022                	sd	s0,32(sp)
    80002d70:	ec26                	sd	s1,24(sp)
    80002d72:	e84a                	sd	s2,16(sp)
    80002d74:	1800                	addi	s0,sp,48
    80002d76:	84ae                	mv	s1,a1
    80002d78:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d7a:	fd840593          	addi	a1,s0,-40
    80002d7e:	00000097          	auipc	ra,0x0
    80002d82:	fcc080e7          	jalr	-52(ra) # 80002d4a <argaddr>
  return fetchstr(addr, buf, max);
    80002d86:	864a                	mv	a2,s2
    80002d88:	85a6                	mv	a1,s1
    80002d8a:	fd843503          	ld	a0,-40(s0)
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	f50080e7          	jalr	-176(ra) # 80002cde <fetchstr>
}
    80002d96:	70a2                	ld	ra,40(sp)
    80002d98:	7402                	ld	s0,32(sp)
    80002d9a:	64e2                	ld	s1,24(sp)
    80002d9c:	6942                	ld	s2,16(sp)
    80002d9e:	6145                	addi	sp,sp,48
    80002da0:	8082                	ret

0000000080002da2 <syscall>:
[SYS_waitx]   sys_waitx,
};

void
syscall(void)
{
    80002da2:	1101                	addi	sp,sp,-32
    80002da4:	ec06                	sd	ra,24(sp)
    80002da6:	e822                	sd	s0,16(sp)
    80002da8:	e426                	sd	s1,8(sp)
    80002daa:	e04a                	sd	s2,0(sp)
    80002dac:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dae:	fffff097          	auipc	ra,0xfffff
    80002db2:	c1e080e7          	jalr	-994(ra) # 800019cc <myproc>
    80002db6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002db8:	05853903          	ld	s2,88(a0)
    80002dbc:	0a893783          	ld	a5,168(s2)
    80002dc0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dc4:	37fd                	addiw	a5,a5,-1
    80002dc6:	4755                	li	a4,21
    80002dc8:	00f76f63          	bltu	a4,a5,80002de6 <syscall+0x44>
    80002dcc:	00369713          	slli	a4,a3,0x3
    80002dd0:	00005797          	auipc	a5,0x5
    80002dd4:	6d878793          	addi	a5,a5,1752 # 800084a8 <syscalls>
    80002dd8:	97ba                	add	a5,a5,a4
    80002dda:	639c                	ld	a5,0(a5)
    80002ddc:	c789                	beqz	a5,80002de6 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002dde:	9782                	jalr	a5
    80002de0:	06a93823          	sd	a0,112(s2)
    80002de4:	a839                	j	80002e02 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002de6:	15848613          	addi	a2,s1,344
    80002dea:	588c                	lw	a1,48(s1)
    80002dec:	00005517          	auipc	a0,0x5
    80002df0:	68450513          	addi	a0,a0,1668 # 80008470 <states.0+0x150>
    80002df4:	ffffd097          	auipc	ra,0xffffd
    80002df8:	794080e7          	jalr	1940(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dfc:	6cbc                	ld	a5,88(s1)
    80002dfe:	577d                	li	a4,-1
    80002e00:	fbb8                	sd	a4,112(a5)
  }
}
    80002e02:	60e2                	ld	ra,24(sp)
    80002e04:	6442                	ld	s0,16(sp)
    80002e06:	64a2                	ld	s1,8(sp)
    80002e08:	6902                	ld	s2,0(sp)
    80002e0a:	6105                	addi	sp,sp,32
    80002e0c:	8082                	ret

0000000080002e0e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e0e:	1101                	addi	sp,sp,-32
    80002e10:	ec06                	sd	ra,24(sp)
    80002e12:	e822                	sd	s0,16(sp)
    80002e14:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e16:	fec40593          	addi	a1,s0,-20
    80002e1a:	4501                	li	a0,0
    80002e1c:	00000097          	auipc	ra,0x0
    80002e20:	f0e080e7          	jalr	-242(ra) # 80002d2a <argint>
  exit(n);
    80002e24:	fec42503          	lw	a0,-20(s0)
    80002e28:	fffff097          	auipc	ra,0xfffff
    80002e2c:	45e080e7          	jalr	1118(ra) # 80002286 <exit>
  return 0;  // not reached
}
    80002e30:	4501                	li	a0,0
    80002e32:	60e2                	ld	ra,24(sp)
    80002e34:	6442                	ld	s0,16(sp)
    80002e36:	6105                	addi	sp,sp,32
    80002e38:	8082                	ret

0000000080002e3a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e3a:	1141                	addi	sp,sp,-16
    80002e3c:	e406                	sd	ra,8(sp)
    80002e3e:	e022                	sd	s0,0(sp)
    80002e40:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	b8a080e7          	jalr	-1142(ra) # 800019cc <myproc>
}
    80002e4a:	5908                	lw	a0,48(a0)
    80002e4c:	60a2                	ld	ra,8(sp)
    80002e4e:	6402                	ld	s0,0(sp)
    80002e50:	0141                	addi	sp,sp,16
    80002e52:	8082                	ret

0000000080002e54 <sys_fork>:

uint64
sys_fork(void)
{
    80002e54:	1141                	addi	sp,sp,-16
    80002e56:	e406                	sd	ra,8(sp)
    80002e58:	e022                	sd	s0,0(sp)
    80002e5a:	0800                	addi	s0,sp,16
  return fork();
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	f3a080e7          	jalr	-198(ra) # 80001d96 <fork>
}
    80002e64:	60a2                	ld	ra,8(sp)
    80002e66:	6402                	ld	s0,0(sp)
    80002e68:	0141                	addi	sp,sp,16
    80002e6a:	8082                	ret

0000000080002e6c <sys_wait>:

uint64
sys_wait(void)
{
    80002e6c:	1101                	addi	sp,sp,-32
    80002e6e:	ec06                	sd	ra,24(sp)
    80002e70:	e822                	sd	s0,16(sp)
    80002e72:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e74:	fe840593          	addi	a1,s0,-24
    80002e78:	4501                	li	a0,0
    80002e7a:	00000097          	auipc	ra,0x0
    80002e7e:	ed0080e7          	jalr	-304(ra) # 80002d4a <argaddr>
  return wait(p);
    80002e82:	fe843503          	ld	a0,-24(s0)
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	5b2080e7          	jalr	1458(ra) # 80002438 <wait>
}
    80002e8e:	60e2                	ld	ra,24(sp)
    80002e90:	6442                	ld	s0,16(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret

0000000080002e96 <sys_waitx>:

uint64
sys_waitx(void)
{
    80002e96:	7139                	addi	sp,sp,-64
    80002e98:	fc06                	sd	ra,56(sp)
    80002e9a:	f822                	sd	s0,48(sp)
    80002e9c:	f426                	sd	s1,40(sp)
    80002e9e:	f04a                	sd	s2,32(sp)
    80002ea0:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80002ea2:	fd840593          	addi	a1,s0,-40
    80002ea6:	4501                	li	a0,0
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	ea2080e7          	jalr	-350(ra) # 80002d4a <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80002eb0:	fd040593          	addi	a1,s0,-48
    80002eb4:	4505                	li	a0,1
    80002eb6:	00000097          	auipc	ra,0x0
    80002eba:	e94080e7          	jalr	-364(ra) # 80002d4a <argaddr>
  argaddr(2, &addr2);
    80002ebe:	fc840593          	addi	a1,s0,-56
    80002ec2:	4509                	li	a0,2
    80002ec4:	00000097          	auipc	ra,0x0
    80002ec8:	e86080e7          	jalr	-378(ra) # 80002d4a <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80002ecc:	fc040613          	addi	a2,s0,-64
    80002ed0:	fc440593          	addi	a1,s0,-60
    80002ed4:	fd843503          	ld	a0,-40(s0)
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	68e080e7          	jalr	1678(ra) # 80002566 <waitx>
    80002ee0:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80002ee2:	fffff097          	auipc	ra,0xfffff
    80002ee6:	aea080e7          	jalr	-1302(ra) # 800019cc <myproc>
    80002eea:	84aa                	mv	s1,a0
  if(copyout(p->pagetable, addr1, (char*)&wtime, sizeof(int)) < 0)
    80002eec:	4691                	li	a3,4
    80002eee:	fc440613          	addi	a2,s0,-60
    80002ef2:	fd043583          	ld	a1,-48(s0)
    80002ef6:	6928                	ld	a0,80(a0)
    80002ef8:	ffffe097          	auipc	ra,0xffffe
    80002efc:	790080e7          	jalr	1936(ra) # 80001688 <copyout>
    return -1;
    80002f00:	57fd                	li	a5,-1
  if(copyout(p->pagetable, addr1, (char*)&wtime, sizeof(int)) < 0)
    80002f02:	00054f63          	bltz	a0,80002f20 <sys_waitx+0x8a>
  if(copyout(p->pagetable, addr2, (char*)&rtime, sizeof(int)) < 0)
    80002f06:	4691                	li	a3,4
    80002f08:	fc040613          	addi	a2,s0,-64
    80002f0c:	fc843583          	ld	a1,-56(s0)
    80002f10:	68a8                	ld	a0,80(s1)
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	776080e7          	jalr	1910(ra) # 80001688 <copyout>
    80002f1a:	00054a63          	bltz	a0,80002f2e <sys_waitx+0x98>
    return -1;
  return ret;
    80002f1e:	87ca                	mv	a5,s2
}
    80002f20:	853e                	mv	a0,a5
    80002f22:	70e2                	ld	ra,56(sp)
    80002f24:	7442                	ld	s0,48(sp)
    80002f26:	74a2                	ld	s1,40(sp)
    80002f28:	7902                	ld	s2,32(sp)
    80002f2a:	6121                	addi	sp,sp,64
    80002f2c:	8082                	ret
    return -1;
    80002f2e:	57fd                	li	a5,-1
    80002f30:	bfc5                	j	80002f20 <sys_waitx+0x8a>

0000000080002f32 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f32:	7179                	addi	sp,sp,-48
    80002f34:	f406                	sd	ra,40(sp)
    80002f36:	f022                	sd	s0,32(sp)
    80002f38:	ec26                	sd	s1,24(sp)
    80002f3a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f3c:	fdc40593          	addi	a1,s0,-36
    80002f40:	4501                	li	a0,0
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	de8080e7          	jalr	-536(ra) # 80002d2a <argint>
  addr = myproc()->sz;
    80002f4a:	fffff097          	auipc	ra,0xfffff
    80002f4e:	a82080e7          	jalr	-1406(ra) # 800019cc <myproc>
    80002f52:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002f54:	fdc42503          	lw	a0,-36(s0)
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	de2080e7          	jalr	-542(ra) # 80001d3a <growproc>
    80002f60:	00054863          	bltz	a0,80002f70 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f64:	8526                	mv	a0,s1
    80002f66:	70a2                	ld	ra,40(sp)
    80002f68:	7402                	ld	s0,32(sp)
    80002f6a:	64e2                	ld	s1,24(sp)
    80002f6c:	6145                	addi	sp,sp,48
    80002f6e:	8082                	ret
    return -1;
    80002f70:	54fd                	li	s1,-1
    80002f72:	bfcd                	j	80002f64 <sys_sbrk+0x32>

0000000080002f74 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f74:	7139                	addi	sp,sp,-64
    80002f76:	fc06                	sd	ra,56(sp)
    80002f78:	f822                	sd	s0,48(sp)
    80002f7a:	f426                	sd	s1,40(sp)
    80002f7c:	f04a                	sd	s2,32(sp)
    80002f7e:	ec4e                	sd	s3,24(sp)
    80002f80:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f82:	fcc40593          	addi	a1,s0,-52
    80002f86:	4501                	li	a0,0
    80002f88:	00000097          	auipc	ra,0x0
    80002f8c:	da2080e7          	jalr	-606(ra) # 80002d2a <argint>
  acquire(&tickslock);
    80002f90:	00014517          	auipc	a0,0x14
    80002f94:	e3050513          	addi	a0,a0,-464 # 80016dc0 <tickslock>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	c3e080e7          	jalr	-962(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002fa0:	00006917          	auipc	s2,0x6
    80002fa4:	98092903          	lw	s2,-1664(s2) # 80008920 <ticks>
  while(ticks - ticks0 < n){
    80002fa8:	fcc42783          	lw	a5,-52(s0)
    80002fac:	cf9d                	beqz	a5,80002fea <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fae:	00014997          	auipc	s3,0x14
    80002fb2:	e1298993          	addi	s3,s3,-494 # 80016dc0 <tickslock>
    80002fb6:	00006497          	auipc	s1,0x6
    80002fba:	96a48493          	addi	s1,s1,-1686 # 80008920 <ticks>
    if(killed(myproc())){
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	a0e080e7          	jalr	-1522(ra) # 800019cc <myproc>
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	440080e7          	jalr	1088(ra) # 80002406 <killed>
    80002fce:	ed15                	bnez	a0,8000300a <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002fd0:	85ce                	mv	a1,s3
    80002fd2:	8526                	mv	a0,s1
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	17e080e7          	jalr	382(ra) # 80002152 <sleep>
  while(ticks - ticks0 < n){
    80002fdc:	409c                	lw	a5,0(s1)
    80002fde:	412787bb          	subw	a5,a5,s2
    80002fe2:	fcc42703          	lw	a4,-52(s0)
    80002fe6:	fce7ece3          	bltu	a5,a4,80002fbe <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002fea:	00014517          	auipc	a0,0x14
    80002fee:	dd650513          	addi	a0,a0,-554 # 80016dc0 <tickslock>
    80002ff2:	ffffe097          	auipc	ra,0xffffe
    80002ff6:	c98080e7          	jalr	-872(ra) # 80000c8a <release>
  return 0;
    80002ffa:	4501                	li	a0,0
}
    80002ffc:	70e2                	ld	ra,56(sp)
    80002ffe:	7442                	ld	s0,48(sp)
    80003000:	74a2                	ld	s1,40(sp)
    80003002:	7902                	ld	s2,32(sp)
    80003004:	69e2                	ld	s3,24(sp)
    80003006:	6121                	addi	sp,sp,64
    80003008:	8082                	ret
      release(&tickslock);
    8000300a:	00014517          	auipc	a0,0x14
    8000300e:	db650513          	addi	a0,a0,-586 # 80016dc0 <tickslock>
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	c78080e7          	jalr	-904(ra) # 80000c8a <release>
      return -1;
    8000301a:	557d                	li	a0,-1
    8000301c:	b7c5                	j	80002ffc <sys_sleep+0x88>

000000008000301e <sys_kill>:

uint64
sys_kill(void)
{
    8000301e:	1101                	addi	sp,sp,-32
    80003020:	ec06                	sd	ra,24(sp)
    80003022:	e822                	sd	s0,16(sp)
    80003024:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003026:	fec40593          	addi	a1,s0,-20
    8000302a:	4501                	li	a0,0
    8000302c:	00000097          	auipc	ra,0x0
    80003030:	cfe080e7          	jalr	-770(ra) # 80002d2a <argint>
  return kill(pid);
    80003034:	fec42503          	lw	a0,-20(s0)
    80003038:	fffff097          	auipc	ra,0xfffff
    8000303c:	330080e7          	jalr	816(ra) # 80002368 <kill>
}
    80003040:	60e2                	ld	ra,24(sp)
    80003042:	6442                	ld	s0,16(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret

0000000080003048 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003048:	1101                	addi	sp,sp,-32
    8000304a:	ec06                	sd	ra,24(sp)
    8000304c:	e822                	sd	s0,16(sp)
    8000304e:	e426                	sd	s1,8(sp)
    80003050:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003052:	00014517          	auipc	a0,0x14
    80003056:	d6e50513          	addi	a0,a0,-658 # 80016dc0 <tickslock>
    8000305a:	ffffe097          	auipc	ra,0xffffe
    8000305e:	b7c080e7          	jalr	-1156(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003062:	00006497          	auipc	s1,0x6
    80003066:	8be4a483          	lw	s1,-1858(s1) # 80008920 <ticks>
  release(&tickslock);
    8000306a:	00014517          	auipc	a0,0x14
    8000306e:	d5650513          	addi	a0,a0,-682 # 80016dc0 <tickslock>
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	c18080e7          	jalr	-1000(ra) # 80000c8a <release>
  return xticks;
}
    8000307a:	02049513          	slli	a0,s1,0x20
    8000307e:	9101                	srli	a0,a0,0x20
    80003080:	60e2                	ld	ra,24(sp)
    80003082:	6442                	ld	s0,16(sp)
    80003084:	64a2                	ld	s1,8(sp)
    80003086:	6105                	addi	sp,sp,32
    80003088:	8082                	ret

000000008000308a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000308a:	7179                	addi	sp,sp,-48
    8000308c:	f406                	sd	ra,40(sp)
    8000308e:	f022                	sd	s0,32(sp)
    80003090:	ec26                	sd	s1,24(sp)
    80003092:	e84a                	sd	s2,16(sp)
    80003094:	e44e                	sd	s3,8(sp)
    80003096:	e052                	sd	s4,0(sp)
    80003098:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000309a:	00005597          	auipc	a1,0x5
    8000309e:	4c658593          	addi	a1,a1,1222 # 80008560 <syscalls+0xb8>
    800030a2:	00014517          	auipc	a0,0x14
    800030a6:	d3650513          	addi	a0,a0,-714 # 80016dd8 <bcache>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	a9c080e7          	jalr	-1380(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030b2:	0001c797          	auipc	a5,0x1c
    800030b6:	d2678793          	addi	a5,a5,-730 # 8001edd8 <bcache+0x8000>
    800030ba:	0001c717          	auipc	a4,0x1c
    800030be:	f8670713          	addi	a4,a4,-122 # 8001f040 <bcache+0x8268>
    800030c2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030c6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ca:	00014497          	auipc	s1,0x14
    800030ce:	d2648493          	addi	s1,s1,-730 # 80016df0 <bcache+0x18>
    b->next = bcache.head.next;
    800030d2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030d4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030d6:	00005a17          	auipc	s4,0x5
    800030da:	492a0a13          	addi	s4,s4,1170 # 80008568 <syscalls+0xc0>
    b->next = bcache.head.next;
    800030de:	2b893783          	ld	a5,696(s2)
    800030e2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030e4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030e8:	85d2                	mv	a1,s4
    800030ea:	01048513          	addi	a0,s1,16
    800030ee:	00001097          	auipc	ra,0x1
    800030f2:	4c4080e7          	jalr	1220(ra) # 800045b2 <initsleeplock>
    bcache.head.next->prev = b;
    800030f6:	2b893783          	ld	a5,696(s2)
    800030fa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030fc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003100:	45848493          	addi	s1,s1,1112
    80003104:	fd349de3          	bne	s1,s3,800030de <binit+0x54>
  }
}
    80003108:	70a2                	ld	ra,40(sp)
    8000310a:	7402                	ld	s0,32(sp)
    8000310c:	64e2                	ld	s1,24(sp)
    8000310e:	6942                	ld	s2,16(sp)
    80003110:	69a2                	ld	s3,8(sp)
    80003112:	6a02                	ld	s4,0(sp)
    80003114:	6145                	addi	sp,sp,48
    80003116:	8082                	ret

0000000080003118 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003118:	7179                	addi	sp,sp,-48
    8000311a:	f406                	sd	ra,40(sp)
    8000311c:	f022                	sd	s0,32(sp)
    8000311e:	ec26                	sd	s1,24(sp)
    80003120:	e84a                	sd	s2,16(sp)
    80003122:	e44e                	sd	s3,8(sp)
    80003124:	1800                	addi	s0,sp,48
    80003126:	892a                	mv	s2,a0
    80003128:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000312a:	00014517          	auipc	a0,0x14
    8000312e:	cae50513          	addi	a0,a0,-850 # 80016dd8 <bcache>
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	aa4080e7          	jalr	-1372(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000313a:	0001c497          	auipc	s1,0x1c
    8000313e:	f564b483          	ld	s1,-170(s1) # 8001f090 <bcache+0x82b8>
    80003142:	0001c797          	auipc	a5,0x1c
    80003146:	efe78793          	addi	a5,a5,-258 # 8001f040 <bcache+0x8268>
    8000314a:	02f48f63          	beq	s1,a5,80003188 <bread+0x70>
    8000314e:	873e                	mv	a4,a5
    80003150:	a021                	j	80003158 <bread+0x40>
    80003152:	68a4                	ld	s1,80(s1)
    80003154:	02e48a63          	beq	s1,a4,80003188 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003158:	449c                	lw	a5,8(s1)
    8000315a:	ff279ce3          	bne	a5,s2,80003152 <bread+0x3a>
    8000315e:	44dc                	lw	a5,12(s1)
    80003160:	ff3799e3          	bne	a5,s3,80003152 <bread+0x3a>
      b->refcnt++;
    80003164:	40bc                	lw	a5,64(s1)
    80003166:	2785                	addiw	a5,a5,1
    80003168:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000316a:	00014517          	auipc	a0,0x14
    8000316e:	c6e50513          	addi	a0,a0,-914 # 80016dd8 <bcache>
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	b18080e7          	jalr	-1256(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000317a:	01048513          	addi	a0,s1,16
    8000317e:	00001097          	auipc	ra,0x1
    80003182:	46e080e7          	jalr	1134(ra) # 800045ec <acquiresleep>
      return b;
    80003186:	a8b9                	j	800031e4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003188:	0001c497          	auipc	s1,0x1c
    8000318c:	f004b483          	ld	s1,-256(s1) # 8001f088 <bcache+0x82b0>
    80003190:	0001c797          	auipc	a5,0x1c
    80003194:	eb078793          	addi	a5,a5,-336 # 8001f040 <bcache+0x8268>
    80003198:	00f48863          	beq	s1,a5,800031a8 <bread+0x90>
    8000319c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000319e:	40bc                	lw	a5,64(s1)
    800031a0:	cf81                	beqz	a5,800031b8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031a2:	64a4                	ld	s1,72(s1)
    800031a4:	fee49de3          	bne	s1,a4,8000319e <bread+0x86>
  panic("bget: no buffers");
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	3c850513          	addi	a0,a0,968 # 80008570 <syscalls+0xc8>
    800031b0:	ffffd097          	auipc	ra,0xffffd
    800031b4:	38e080e7          	jalr	910(ra) # 8000053e <panic>
      b->dev = dev;
    800031b8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031bc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031c0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031c4:	4785                	li	a5,1
    800031c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031c8:	00014517          	auipc	a0,0x14
    800031cc:	c1050513          	addi	a0,a0,-1008 # 80016dd8 <bcache>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	aba080e7          	jalr	-1350(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031d8:	01048513          	addi	a0,s1,16
    800031dc:	00001097          	auipc	ra,0x1
    800031e0:	410080e7          	jalr	1040(ra) # 800045ec <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031e4:	409c                	lw	a5,0(s1)
    800031e6:	cb89                	beqz	a5,800031f8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031e8:	8526                	mv	a0,s1
    800031ea:	70a2                	ld	ra,40(sp)
    800031ec:	7402                	ld	s0,32(sp)
    800031ee:	64e2                	ld	s1,24(sp)
    800031f0:	6942                	ld	s2,16(sp)
    800031f2:	69a2                	ld	s3,8(sp)
    800031f4:	6145                	addi	sp,sp,48
    800031f6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031f8:	4581                	li	a1,0
    800031fa:	8526                	mv	a0,s1
    800031fc:	00003097          	auipc	ra,0x3
    80003200:	fd8080e7          	jalr	-40(ra) # 800061d4 <virtio_disk_rw>
    b->valid = 1;
    80003204:	4785                	li	a5,1
    80003206:	c09c                	sw	a5,0(s1)
  return b;
    80003208:	b7c5                	j	800031e8 <bread+0xd0>

000000008000320a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000320a:	1101                	addi	sp,sp,-32
    8000320c:	ec06                	sd	ra,24(sp)
    8000320e:	e822                	sd	s0,16(sp)
    80003210:	e426                	sd	s1,8(sp)
    80003212:	1000                	addi	s0,sp,32
    80003214:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003216:	0541                	addi	a0,a0,16
    80003218:	00001097          	auipc	ra,0x1
    8000321c:	46e080e7          	jalr	1134(ra) # 80004686 <holdingsleep>
    80003220:	cd01                	beqz	a0,80003238 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003222:	4585                	li	a1,1
    80003224:	8526                	mv	a0,s1
    80003226:	00003097          	auipc	ra,0x3
    8000322a:	fae080e7          	jalr	-82(ra) # 800061d4 <virtio_disk_rw>
}
    8000322e:	60e2                	ld	ra,24(sp)
    80003230:	6442                	ld	s0,16(sp)
    80003232:	64a2                	ld	s1,8(sp)
    80003234:	6105                	addi	sp,sp,32
    80003236:	8082                	ret
    panic("bwrite");
    80003238:	00005517          	auipc	a0,0x5
    8000323c:	35050513          	addi	a0,a0,848 # 80008588 <syscalls+0xe0>
    80003240:	ffffd097          	auipc	ra,0xffffd
    80003244:	2fe080e7          	jalr	766(ra) # 8000053e <panic>

0000000080003248 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	e426                	sd	s1,8(sp)
    80003250:	e04a                	sd	s2,0(sp)
    80003252:	1000                	addi	s0,sp,32
    80003254:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003256:	01050913          	addi	s2,a0,16
    8000325a:	854a                	mv	a0,s2
    8000325c:	00001097          	auipc	ra,0x1
    80003260:	42a080e7          	jalr	1066(ra) # 80004686 <holdingsleep>
    80003264:	c92d                	beqz	a0,800032d6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003266:	854a                	mv	a0,s2
    80003268:	00001097          	auipc	ra,0x1
    8000326c:	3da080e7          	jalr	986(ra) # 80004642 <releasesleep>

  acquire(&bcache.lock);
    80003270:	00014517          	auipc	a0,0x14
    80003274:	b6850513          	addi	a0,a0,-1176 # 80016dd8 <bcache>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	95e080e7          	jalr	-1698(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003280:	40bc                	lw	a5,64(s1)
    80003282:	37fd                	addiw	a5,a5,-1
    80003284:	0007871b          	sext.w	a4,a5
    80003288:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000328a:	eb05                	bnez	a4,800032ba <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000328c:	68bc                	ld	a5,80(s1)
    8000328e:	64b8                	ld	a4,72(s1)
    80003290:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003292:	64bc                	ld	a5,72(s1)
    80003294:	68b8                	ld	a4,80(s1)
    80003296:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003298:	0001c797          	auipc	a5,0x1c
    8000329c:	b4078793          	addi	a5,a5,-1216 # 8001edd8 <bcache+0x8000>
    800032a0:	2b87b703          	ld	a4,696(a5)
    800032a4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032a6:	0001c717          	auipc	a4,0x1c
    800032aa:	d9a70713          	addi	a4,a4,-614 # 8001f040 <bcache+0x8268>
    800032ae:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032b0:	2b87b703          	ld	a4,696(a5)
    800032b4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032b6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032ba:	00014517          	auipc	a0,0x14
    800032be:	b1e50513          	addi	a0,a0,-1250 # 80016dd8 <bcache>
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	9c8080e7          	jalr	-1592(ra) # 80000c8a <release>
}
    800032ca:	60e2                	ld	ra,24(sp)
    800032cc:	6442                	ld	s0,16(sp)
    800032ce:	64a2                	ld	s1,8(sp)
    800032d0:	6902                	ld	s2,0(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret
    panic("brelse");
    800032d6:	00005517          	auipc	a0,0x5
    800032da:	2ba50513          	addi	a0,a0,698 # 80008590 <syscalls+0xe8>
    800032de:	ffffd097          	auipc	ra,0xffffd
    800032e2:	260080e7          	jalr	608(ra) # 8000053e <panic>

00000000800032e6 <bpin>:

void
bpin(struct buf *b) {
    800032e6:	1101                	addi	sp,sp,-32
    800032e8:	ec06                	sd	ra,24(sp)
    800032ea:	e822                	sd	s0,16(sp)
    800032ec:	e426                	sd	s1,8(sp)
    800032ee:	1000                	addi	s0,sp,32
    800032f0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032f2:	00014517          	auipc	a0,0x14
    800032f6:	ae650513          	addi	a0,a0,-1306 # 80016dd8 <bcache>
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	8dc080e7          	jalr	-1828(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003302:	40bc                	lw	a5,64(s1)
    80003304:	2785                	addiw	a5,a5,1
    80003306:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003308:	00014517          	auipc	a0,0x14
    8000330c:	ad050513          	addi	a0,a0,-1328 # 80016dd8 <bcache>
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	97a080e7          	jalr	-1670(ra) # 80000c8a <release>
}
    80003318:	60e2                	ld	ra,24(sp)
    8000331a:	6442                	ld	s0,16(sp)
    8000331c:	64a2                	ld	s1,8(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <bunpin>:

void
bunpin(struct buf *b) {
    80003322:	1101                	addi	sp,sp,-32
    80003324:	ec06                	sd	ra,24(sp)
    80003326:	e822                	sd	s0,16(sp)
    80003328:	e426                	sd	s1,8(sp)
    8000332a:	1000                	addi	s0,sp,32
    8000332c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000332e:	00014517          	auipc	a0,0x14
    80003332:	aaa50513          	addi	a0,a0,-1366 # 80016dd8 <bcache>
    80003336:	ffffe097          	auipc	ra,0xffffe
    8000333a:	8a0080e7          	jalr	-1888(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000333e:	40bc                	lw	a5,64(s1)
    80003340:	37fd                	addiw	a5,a5,-1
    80003342:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003344:	00014517          	auipc	a0,0x14
    80003348:	a9450513          	addi	a0,a0,-1388 # 80016dd8 <bcache>
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	93e080e7          	jalr	-1730(ra) # 80000c8a <release>
}
    80003354:	60e2                	ld	ra,24(sp)
    80003356:	6442                	ld	s0,16(sp)
    80003358:	64a2                	ld	s1,8(sp)
    8000335a:	6105                	addi	sp,sp,32
    8000335c:	8082                	ret

000000008000335e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000335e:	1101                	addi	sp,sp,-32
    80003360:	ec06                	sd	ra,24(sp)
    80003362:	e822                	sd	s0,16(sp)
    80003364:	e426                	sd	s1,8(sp)
    80003366:	e04a                	sd	s2,0(sp)
    80003368:	1000                	addi	s0,sp,32
    8000336a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000336c:	00d5d59b          	srliw	a1,a1,0xd
    80003370:	0001c797          	auipc	a5,0x1c
    80003374:	1447a783          	lw	a5,324(a5) # 8001f4b4 <sb+0x1c>
    80003378:	9dbd                	addw	a1,a1,a5
    8000337a:	00000097          	auipc	ra,0x0
    8000337e:	d9e080e7          	jalr	-610(ra) # 80003118 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003382:	0074f713          	andi	a4,s1,7
    80003386:	4785                	li	a5,1
    80003388:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000338c:	14ce                	slli	s1,s1,0x33
    8000338e:	90d9                	srli	s1,s1,0x36
    80003390:	00950733          	add	a4,a0,s1
    80003394:	05874703          	lbu	a4,88(a4)
    80003398:	00e7f6b3          	and	a3,a5,a4
    8000339c:	c69d                	beqz	a3,800033ca <bfree+0x6c>
    8000339e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033a0:	94aa                	add	s1,s1,a0
    800033a2:	fff7c793          	not	a5,a5
    800033a6:	8ff9                	and	a5,a5,a4
    800033a8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033ac:	00001097          	auipc	ra,0x1
    800033b0:	120080e7          	jalr	288(ra) # 800044cc <log_write>
  brelse(bp);
    800033b4:	854a                	mv	a0,s2
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	e92080e7          	jalr	-366(ra) # 80003248 <brelse>
}
    800033be:	60e2                	ld	ra,24(sp)
    800033c0:	6442                	ld	s0,16(sp)
    800033c2:	64a2                	ld	s1,8(sp)
    800033c4:	6902                	ld	s2,0(sp)
    800033c6:	6105                	addi	sp,sp,32
    800033c8:	8082                	ret
    panic("freeing free block");
    800033ca:	00005517          	auipc	a0,0x5
    800033ce:	1ce50513          	addi	a0,a0,462 # 80008598 <syscalls+0xf0>
    800033d2:	ffffd097          	auipc	ra,0xffffd
    800033d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800033da <balloc>:
{
    800033da:	711d                	addi	sp,sp,-96
    800033dc:	ec86                	sd	ra,88(sp)
    800033de:	e8a2                	sd	s0,80(sp)
    800033e0:	e4a6                	sd	s1,72(sp)
    800033e2:	e0ca                	sd	s2,64(sp)
    800033e4:	fc4e                	sd	s3,56(sp)
    800033e6:	f852                	sd	s4,48(sp)
    800033e8:	f456                	sd	s5,40(sp)
    800033ea:	f05a                	sd	s6,32(sp)
    800033ec:	ec5e                	sd	s7,24(sp)
    800033ee:	e862                	sd	s8,16(sp)
    800033f0:	e466                	sd	s9,8(sp)
    800033f2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033f4:	0001c797          	auipc	a5,0x1c
    800033f8:	0a87a783          	lw	a5,168(a5) # 8001f49c <sb+0x4>
    800033fc:	10078163          	beqz	a5,800034fe <balloc+0x124>
    80003400:	8baa                	mv	s7,a0
    80003402:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003404:	0001cb17          	auipc	s6,0x1c
    80003408:	094b0b13          	addi	s6,s6,148 # 8001f498 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000340e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003410:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003412:	6c89                	lui	s9,0x2
    80003414:	a061                	j	8000349c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003416:	974a                	add	a4,a4,s2
    80003418:	8fd5                	or	a5,a5,a3
    8000341a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000341e:	854a                	mv	a0,s2
    80003420:	00001097          	auipc	ra,0x1
    80003424:	0ac080e7          	jalr	172(ra) # 800044cc <log_write>
        brelse(bp);
    80003428:	854a                	mv	a0,s2
    8000342a:	00000097          	auipc	ra,0x0
    8000342e:	e1e080e7          	jalr	-482(ra) # 80003248 <brelse>
  bp = bread(dev, bno);
    80003432:	85a6                	mv	a1,s1
    80003434:	855e                	mv	a0,s7
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	ce2080e7          	jalr	-798(ra) # 80003118 <bread>
    8000343e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003440:	40000613          	li	a2,1024
    80003444:	4581                	li	a1,0
    80003446:	05850513          	addi	a0,a0,88
    8000344a:	ffffe097          	auipc	ra,0xffffe
    8000344e:	888080e7          	jalr	-1912(ra) # 80000cd2 <memset>
  log_write(bp);
    80003452:	854a                	mv	a0,s2
    80003454:	00001097          	auipc	ra,0x1
    80003458:	078080e7          	jalr	120(ra) # 800044cc <log_write>
  brelse(bp);
    8000345c:	854a                	mv	a0,s2
    8000345e:	00000097          	auipc	ra,0x0
    80003462:	dea080e7          	jalr	-534(ra) # 80003248 <brelse>
}
    80003466:	8526                	mv	a0,s1
    80003468:	60e6                	ld	ra,88(sp)
    8000346a:	6446                	ld	s0,80(sp)
    8000346c:	64a6                	ld	s1,72(sp)
    8000346e:	6906                	ld	s2,64(sp)
    80003470:	79e2                	ld	s3,56(sp)
    80003472:	7a42                	ld	s4,48(sp)
    80003474:	7aa2                	ld	s5,40(sp)
    80003476:	7b02                	ld	s6,32(sp)
    80003478:	6be2                	ld	s7,24(sp)
    8000347a:	6c42                	ld	s8,16(sp)
    8000347c:	6ca2                	ld	s9,8(sp)
    8000347e:	6125                	addi	sp,sp,96
    80003480:	8082                	ret
    brelse(bp);
    80003482:	854a                	mv	a0,s2
    80003484:	00000097          	auipc	ra,0x0
    80003488:	dc4080e7          	jalr	-572(ra) # 80003248 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000348c:	015c87bb          	addw	a5,s9,s5
    80003490:	00078a9b          	sext.w	s5,a5
    80003494:	004b2703          	lw	a4,4(s6)
    80003498:	06eaf363          	bgeu	s5,a4,800034fe <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000349c:	41fad79b          	sraiw	a5,s5,0x1f
    800034a0:	0137d79b          	srliw	a5,a5,0x13
    800034a4:	015787bb          	addw	a5,a5,s5
    800034a8:	40d7d79b          	sraiw	a5,a5,0xd
    800034ac:	01cb2583          	lw	a1,28(s6)
    800034b0:	9dbd                	addw	a1,a1,a5
    800034b2:	855e                	mv	a0,s7
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	c64080e7          	jalr	-924(ra) # 80003118 <bread>
    800034bc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034be:	004b2503          	lw	a0,4(s6)
    800034c2:	000a849b          	sext.w	s1,s5
    800034c6:	8662                	mv	a2,s8
    800034c8:	faa4fde3          	bgeu	s1,a0,80003482 <balloc+0xa8>
      m = 1 << (bi % 8);
    800034cc:	41f6579b          	sraiw	a5,a2,0x1f
    800034d0:	01d7d69b          	srliw	a3,a5,0x1d
    800034d4:	00c6873b          	addw	a4,a3,a2
    800034d8:	00777793          	andi	a5,a4,7
    800034dc:	9f95                	subw	a5,a5,a3
    800034de:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034e2:	4037571b          	sraiw	a4,a4,0x3
    800034e6:	00e906b3          	add	a3,s2,a4
    800034ea:	0586c683          	lbu	a3,88(a3)
    800034ee:	00d7f5b3          	and	a1,a5,a3
    800034f2:	d195                	beqz	a1,80003416 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034f4:	2605                	addiw	a2,a2,1
    800034f6:	2485                	addiw	s1,s1,1
    800034f8:	fd4618e3          	bne	a2,s4,800034c8 <balloc+0xee>
    800034fc:	b759                	j	80003482 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800034fe:	00005517          	auipc	a0,0x5
    80003502:	0b250513          	addi	a0,a0,178 # 800085b0 <syscalls+0x108>
    80003506:	ffffd097          	auipc	ra,0xffffd
    8000350a:	082080e7          	jalr	130(ra) # 80000588 <printf>
  return 0;
    8000350e:	4481                	li	s1,0
    80003510:	bf99                	j	80003466 <balloc+0x8c>

0000000080003512 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003512:	7179                	addi	sp,sp,-48
    80003514:	f406                	sd	ra,40(sp)
    80003516:	f022                	sd	s0,32(sp)
    80003518:	ec26                	sd	s1,24(sp)
    8000351a:	e84a                	sd	s2,16(sp)
    8000351c:	e44e                	sd	s3,8(sp)
    8000351e:	e052                	sd	s4,0(sp)
    80003520:	1800                	addi	s0,sp,48
    80003522:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003524:	47ad                	li	a5,11
    80003526:	02b7e763          	bltu	a5,a1,80003554 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000352a:	02059493          	slli	s1,a1,0x20
    8000352e:	9081                	srli	s1,s1,0x20
    80003530:	048a                	slli	s1,s1,0x2
    80003532:	94aa                	add	s1,s1,a0
    80003534:	0504a903          	lw	s2,80(s1)
    80003538:	06091e63          	bnez	s2,800035b4 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000353c:	4108                	lw	a0,0(a0)
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	e9c080e7          	jalr	-356(ra) # 800033da <balloc>
    80003546:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000354a:	06090563          	beqz	s2,800035b4 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000354e:	0524a823          	sw	s2,80(s1)
    80003552:	a08d                	j	800035b4 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003554:	ff45849b          	addiw	s1,a1,-12
    80003558:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000355c:	0ff00793          	li	a5,255
    80003560:	08e7e563          	bltu	a5,a4,800035ea <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003564:	08052903          	lw	s2,128(a0)
    80003568:	00091d63          	bnez	s2,80003582 <bmap+0x70>
      addr = balloc(ip->dev);
    8000356c:	4108                	lw	a0,0(a0)
    8000356e:	00000097          	auipc	ra,0x0
    80003572:	e6c080e7          	jalr	-404(ra) # 800033da <balloc>
    80003576:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000357a:	02090d63          	beqz	s2,800035b4 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000357e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003582:	85ca                	mv	a1,s2
    80003584:	0009a503          	lw	a0,0(s3)
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	b90080e7          	jalr	-1136(ra) # 80003118 <bread>
    80003590:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003592:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003596:	02049593          	slli	a1,s1,0x20
    8000359a:	9181                	srli	a1,a1,0x20
    8000359c:	058a                	slli	a1,a1,0x2
    8000359e:	00b784b3          	add	s1,a5,a1
    800035a2:	0004a903          	lw	s2,0(s1)
    800035a6:	02090063          	beqz	s2,800035c6 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035aa:	8552                	mv	a0,s4
    800035ac:	00000097          	auipc	ra,0x0
    800035b0:	c9c080e7          	jalr	-868(ra) # 80003248 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035b4:	854a                	mv	a0,s2
    800035b6:	70a2                	ld	ra,40(sp)
    800035b8:	7402                	ld	s0,32(sp)
    800035ba:	64e2                	ld	s1,24(sp)
    800035bc:	6942                	ld	s2,16(sp)
    800035be:	69a2                	ld	s3,8(sp)
    800035c0:	6a02                	ld	s4,0(sp)
    800035c2:	6145                	addi	sp,sp,48
    800035c4:	8082                	ret
      addr = balloc(ip->dev);
    800035c6:	0009a503          	lw	a0,0(s3)
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e10080e7          	jalr	-496(ra) # 800033da <balloc>
    800035d2:	0005091b          	sext.w	s2,a0
      if(addr){
    800035d6:	fc090ae3          	beqz	s2,800035aa <bmap+0x98>
        a[bn] = addr;
    800035da:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035de:	8552                	mv	a0,s4
    800035e0:	00001097          	auipc	ra,0x1
    800035e4:	eec080e7          	jalr	-276(ra) # 800044cc <log_write>
    800035e8:	b7c9                	j	800035aa <bmap+0x98>
  panic("bmap: out of range");
    800035ea:	00005517          	auipc	a0,0x5
    800035ee:	fde50513          	addi	a0,a0,-34 # 800085c8 <syscalls+0x120>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	f4c080e7          	jalr	-180(ra) # 8000053e <panic>

00000000800035fa <iget>:
{
    800035fa:	7179                	addi	sp,sp,-48
    800035fc:	f406                	sd	ra,40(sp)
    800035fe:	f022                	sd	s0,32(sp)
    80003600:	ec26                	sd	s1,24(sp)
    80003602:	e84a                	sd	s2,16(sp)
    80003604:	e44e                	sd	s3,8(sp)
    80003606:	e052                	sd	s4,0(sp)
    80003608:	1800                	addi	s0,sp,48
    8000360a:	89aa                	mv	s3,a0
    8000360c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000360e:	0001c517          	auipc	a0,0x1c
    80003612:	eaa50513          	addi	a0,a0,-342 # 8001f4b8 <itable>
    80003616:	ffffd097          	auipc	ra,0xffffd
    8000361a:	5c0080e7          	jalr	1472(ra) # 80000bd6 <acquire>
  empty = 0;
    8000361e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003620:	0001c497          	auipc	s1,0x1c
    80003624:	eb048493          	addi	s1,s1,-336 # 8001f4d0 <itable+0x18>
    80003628:	0001e697          	auipc	a3,0x1e
    8000362c:	93868693          	addi	a3,a3,-1736 # 80020f60 <log>
    80003630:	a039                	j	8000363e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003632:	02090b63          	beqz	s2,80003668 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003636:	08848493          	addi	s1,s1,136
    8000363a:	02d48a63          	beq	s1,a3,8000366e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000363e:	449c                	lw	a5,8(s1)
    80003640:	fef059e3          	blez	a5,80003632 <iget+0x38>
    80003644:	4098                	lw	a4,0(s1)
    80003646:	ff3716e3          	bne	a4,s3,80003632 <iget+0x38>
    8000364a:	40d8                	lw	a4,4(s1)
    8000364c:	ff4713e3          	bne	a4,s4,80003632 <iget+0x38>
      ip->ref++;
    80003650:	2785                	addiw	a5,a5,1
    80003652:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003654:	0001c517          	auipc	a0,0x1c
    80003658:	e6450513          	addi	a0,a0,-412 # 8001f4b8 <itable>
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	62e080e7          	jalr	1582(ra) # 80000c8a <release>
      return ip;
    80003664:	8926                	mv	s2,s1
    80003666:	a03d                	j	80003694 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003668:	f7f9                	bnez	a5,80003636 <iget+0x3c>
    8000366a:	8926                	mv	s2,s1
    8000366c:	b7e9                	j	80003636 <iget+0x3c>
  if(empty == 0)
    8000366e:	02090c63          	beqz	s2,800036a6 <iget+0xac>
  ip->dev = dev;
    80003672:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003676:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000367a:	4785                	li	a5,1
    8000367c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003680:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003684:	0001c517          	auipc	a0,0x1c
    80003688:	e3450513          	addi	a0,a0,-460 # 8001f4b8 <itable>
    8000368c:	ffffd097          	auipc	ra,0xffffd
    80003690:	5fe080e7          	jalr	1534(ra) # 80000c8a <release>
}
    80003694:	854a                	mv	a0,s2
    80003696:	70a2                	ld	ra,40(sp)
    80003698:	7402                	ld	s0,32(sp)
    8000369a:	64e2                	ld	s1,24(sp)
    8000369c:	6942                	ld	s2,16(sp)
    8000369e:	69a2                	ld	s3,8(sp)
    800036a0:	6a02                	ld	s4,0(sp)
    800036a2:	6145                	addi	sp,sp,48
    800036a4:	8082                	ret
    panic("iget: no inodes");
    800036a6:	00005517          	auipc	a0,0x5
    800036aa:	f3a50513          	addi	a0,a0,-198 # 800085e0 <syscalls+0x138>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	e90080e7          	jalr	-368(ra) # 8000053e <panic>

00000000800036b6 <fsinit>:
fsinit(int dev) {
    800036b6:	7179                	addi	sp,sp,-48
    800036b8:	f406                	sd	ra,40(sp)
    800036ba:	f022                	sd	s0,32(sp)
    800036bc:	ec26                	sd	s1,24(sp)
    800036be:	e84a                	sd	s2,16(sp)
    800036c0:	e44e                	sd	s3,8(sp)
    800036c2:	1800                	addi	s0,sp,48
    800036c4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036c6:	4585                	li	a1,1
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	a50080e7          	jalr	-1456(ra) # 80003118 <bread>
    800036d0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036d2:	0001c997          	auipc	s3,0x1c
    800036d6:	dc698993          	addi	s3,s3,-570 # 8001f498 <sb>
    800036da:	02000613          	li	a2,32
    800036de:	05850593          	addi	a1,a0,88
    800036e2:	854e                	mv	a0,s3
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	64a080e7          	jalr	1610(ra) # 80000d2e <memmove>
  brelse(bp);
    800036ec:	8526                	mv	a0,s1
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	b5a080e7          	jalr	-1190(ra) # 80003248 <brelse>
  if(sb.magic != FSMAGIC)
    800036f6:	0009a703          	lw	a4,0(s3)
    800036fa:	102037b7          	lui	a5,0x10203
    800036fe:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003702:	02f71263          	bne	a4,a5,80003726 <fsinit+0x70>
  initlog(dev, &sb);
    80003706:	0001c597          	auipc	a1,0x1c
    8000370a:	d9258593          	addi	a1,a1,-622 # 8001f498 <sb>
    8000370e:	854a                	mv	a0,s2
    80003710:	00001097          	auipc	ra,0x1
    80003714:	b40080e7          	jalr	-1216(ra) # 80004250 <initlog>
}
    80003718:	70a2                	ld	ra,40(sp)
    8000371a:	7402                	ld	s0,32(sp)
    8000371c:	64e2                	ld	s1,24(sp)
    8000371e:	6942                	ld	s2,16(sp)
    80003720:	69a2                	ld	s3,8(sp)
    80003722:	6145                	addi	sp,sp,48
    80003724:	8082                	ret
    panic("invalid file system");
    80003726:	00005517          	auipc	a0,0x5
    8000372a:	eca50513          	addi	a0,a0,-310 # 800085f0 <syscalls+0x148>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	e10080e7          	jalr	-496(ra) # 8000053e <panic>

0000000080003736 <iinit>:
{
    80003736:	7179                	addi	sp,sp,-48
    80003738:	f406                	sd	ra,40(sp)
    8000373a:	f022                	sd	s0,32(sp)
    8000373c:	ec26                	sd	s1,24(sp)
    8000373e:	e84a                	sd	s2,16(sp)
    80003740:	e44e                	sd	s3,8(sp)
    80003742:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003744:	00005597          	auipc	a1,0x5
    80003748:	ec458593          	addi	a1,a1,-316 # 80008608 <syscalls+0x160>
    8000374c:	0001c517          	auipc	a0,0x1c
    80003750:	d6c50513          	addi	a0,a0,-660 # 8001f4b8 <itable>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	3f2080e7          	jalr	1010(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000375c:	0001c497          	auipc	s1,0x1c
    80003760:	d8448493          	addi	s1,s1,-636 # 8001f4e0 <itable+0x28>
    80003764:	0001e997          	auipc	s3,0x1e
    80003768:	80c98993          	addi	s3,s3,-2036 # 80020f70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000376c:	00005917          	auipc	s2,0x5
    80003770:	ea490913          	addi	s2,s2,-348 # 80008610 <syscalls+0x168>
    80003774:	85ca                	mv	a1,s2
    80003776:	8526                	mv	a0,s1
    80003778:	00001097          	auipc	ra,0x1
    8000377c:	e3a080e7          	jalr	-454(ra) # 800045b2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003780:	08848493          	addi	s1,s1,136
    80003784:	ff3498e3          	bne	s1,s3,80003774 <iinit+0x3e>
}
    80003788:	70a2                	ld	ra,40(sp)
    8000378a:	7402                	ld	s0,32(sp)
    8000378c:	64e2                	ld	s1,24(sp)
    8000378e:	6942                	ld	s2,16(sp)
    80003790:	69a2                	ld	s3,8(sp)
    80003792:	6145                	addi	sp,sp,48
    80003794:	8082                	ret

0000000080003796 <ialloc>:
{
    80003796:	715d                	addi	sp,sp,-80
    80003798:	e486                	sd	ra,72(sp)
    8000379a:	e0a2                	sd	s0,64(sp)
    8000379c:	fc26                	sd	s1,56(sp)
    8000379e:	f84a                	sd	s2,48(sp)
    800037a0:	f44e                	sd	s3,40(sp)
    800037a2:	f052                	sd	s4,32(sp)
    800037a4:	ec56                	sd	s5,24(sp)
    800037a6:	e85a                	sd	s6,16(sp)
    800037a8:	e45e                	sd	s7,8(sp)
    800037aa:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037ac:	0001c717          	auipc	a4,0x1c
    800037b0:	cf872703          	lw	a4,-776(a4) # 8001f4a4 <sb+0xc>
    800037b4:	4785                	li	a5,1
    800037b6:	04e7fa63          	bgeu	a5,a4,8000380a <ialloc+0x74>
    800037ba:	8aaa                	mv	s5,a0
    800037bc:	8bae                	mv	s7,a1
    800037be:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037c0:	0001ca17          	auipc	s4,0x1c
    800037c4:	cd8a0a13          	addi	s4,s4,-808 # 8001f498 <sb>
    800037c8:	00048b1b          	sext.w	s6,s1
    800037cc:	0044d793          	srli	a5,s1,0x4
    800037d0:	018a2583          	lw	a1,24(s4)
    800037d4:	9dbd                	addw	a1,a1,a5
    800037d6:	8556                	mv	a0,s5
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	940080e7          	jalr	-1728(ra) # 80003118 <bread>
    800037e0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037e2:	05850993          	addi	s3,a0,88
    800037e6:	00f4f793          	andi	a5,s1,15
    800037ea:	079a                	slli	a5,a5,0x6
    800037ec:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037ee:	00099783          	lh	a5,0(s3)
    800037f2:	c3a1                	beqz	a5,80003832 <ialloc+0x9c>
    brelse(bp);
    800037f4:	00000097          	auipc	ra,0x0
    800037f8:	a54080e7          	jalr	-1452(ra) # 80003248 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037fc:	0485                	addi	s1,s1,1
    800037fe:	00ca2703          	lw	a4,12(s4)
    80003802:	0004879b          	sext.w	a5,s1
    80003806:	fce7e1e3          	bltu	a5,a4,800037c8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000380a:	00005517          	auipc	a0,0x5
    8000380e:	e0e50513          	addi	a0,a0,-498 # 80008618 <syscalls+0x170>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	d76080e7          	jalr	-650(ra) # 80000588 <printf>
  return 0;
    8000381a:	4501                	li	a0,0
}
    8000381c:	60a6                	ld	ra,72(sp)
    8000381e:	6406                	ld	s0,64(sp)
    80003820:	74e2                	ld	s1,56(sp)
    80003822:	7942                	ld	s2,48(sp)
    80003824:	79a2                	ld	s3,40(sp)
    80003826:	7a02                	ld	s4,32(sp)
    80003828:	6ae2                	ld	s5,24(sp)
    8000382a:	6b42                	ld	s6,16(sp)
    8000382c:	6ba2                	ld	s7,8(sp)
    8000382e:	6161                	addi	sp,sp,80
    80003830:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003832:	04000613          	li	a2,64
    80003836:	4581                	li	a1,0
    80003838:	854e                	mv	a0,s3
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	498080e7          	jalr	1176(ra) # 80000cd2 <memset>
      dip->type = type;
    80003842:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003846:	854a                	mv	a0,s2
    80003848:	00001097          	auipc	ra,0x1
    8000384c:	c84080e7          	jalr	-892(ra) # 800044cc <log_write>
      brelse(bp);
    80003850:	854a                	mv	a0,s2
    80003852:	00000097          	auipc	ra,0x0
    80003856:	9f6080e7          	jalr	-1546(ra) # 80003248 <brelse>
      return iget(dev, inum);
    8000385a:	85da                	mv	a1,s6
    8000385c:	8556                	mv	a0,s5
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	d9c080e7          	jalr	-612(ra) # 800035fa <iget>
    80003866:	bf5d                	j	8000381c <ialloc+0x86>

0000000080003868 <iupdate>:
{
    80003868:	1101                	addi	sp,sp,-32
    8000386a:	ec06                	sd	ra,24(sp)
    8000386c:	e822                	sd	s0,16(sp)
    8000386e:	e426                	sd	s1,8(sp)
    80003870:	e04a                	sd	s2,0(sp)
    80003872:	1000                	addi	s0,sp,32
    80003874:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003876:	415c                	lw	a5,4(a0)
    80003878:	0047d79b          	srliw	a5,a5,0x4
    8000387c:	0001c597          	auipc	a1,0x1c
    80003880:	c345a583          	lw	a1,-972(a1) # 8001f4b0 <sb+0x18>
    80003884:	9dbd                	addw	a1,a1,a5
    80003886:	4108                	lw	a0,0(a0)
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	890080e7          	jalr	-1904(ra) # 80003118 <bread>
    80003890:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003892:	05850793          	addi	a5,a0,88
    80003896:	40c8                	lw	a0,4(s1)
    80003898:	893d                	andi	a0,a0,15
    8000389a:	051a                	slli	a0,a0,0x6
    8000389c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000389e:	04449703          	lh	a4,68(s1)
    800038a2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038a6:	04649703          	lh	a4,70(s1)
    800038aa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038ae:	04849703          	lh	a4,72(s1)
    800038b2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038b6:	04a49703          	lh	a4,74(s1)
    800038ba:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038be:	44f8                	lw	a4,76(s1)
    800038c0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038c2:	03400613          	li	a2,52
    800038c6:	05048593          	addi	a1,s1,80
    800038ca:	0531                	addi	a0,a0,12
    800038cc:	ffffd097          	auipc	ra,0xffffd
    800038d0:	462080e7          	jalr	1122(ra) # 80000d2e <memmove>
  log_write(bp);
    800038d4:	854a                	mv	a0,s2
    800038d6:	00001097          	auipc	ra,0x1
    800038da:	bf6080e7          	jalr	-1034(ra) # 800044cc <log_write>
  brelse(bp);
    800038de:	854a                	mv	a0,s2
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	968080e7          	jalr	-1688(ra) # 80003248 <brelse>
}
    800038e8:	60e2                	ld	ra,24(sp)
    800038ea:	6442                	ld	s0,16(sp)
    800038ec:	64a2                	ld	s1,8(sp)
    800038ee:	6902                	ld	s2,0(sp)
    800038f0:	6105                	addi	sp,sp,32
    800038f2:	8082                	ret

00000000800038f4 <idup>:
{
    800038f4:	1101                	addi	sp,sp,-32
    800038f6:	ec06                	sd	ra,24(sp)
    800038f8:	e822                	sd	s0,16(sp)
    800038fa:	e426                	sd	s1,8(sp)
    800038fc:	1000                	addi	s0,sp,32
    800038fe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003900:	0001c517          	auipc	a0,0x1c
    80003904:	bb850513          	addi	a0,a0,-1096 # 8001f4b8 <itable>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	2ce080e7          	jalr	718(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003910:	449c                	lw	a5,8(s1)
    80003912:	2785                	addiw	a5,a5,1
    80003914:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003916:	0001c517          	auipc	a0,0x1c
    8000391a:	ba250513          	addi	a0,a0,-1118 # 8001f4b8 <itable>
    8000391e:	ffffd097          	auipc	ra,0xffffd
    80003922:	36c080e7          	jalr	876(ra) # 80000c8a <release>
}
    80003926:	8526                	mv	a0,s1
    80003928:	60e2                	ld	ra,24(sp)
    8000392a:	6442                	ld	s0,16(sp)
    8000392c:	64a2                	ld	s1,8(sp)
    8000392e:	6105                	addi	sp,sp,32
    80003930:	8082                	ret

0000000080003932 <ilock>:
{
    80003932:	1101                	addi	sp,sp,-32
    80003934:	ec06                	sd	ra,24(sp)
    80003936:	e822                	sd	s0,16(sp)
    80003938:	e426                	sd	s1,8(sp)
    8000393a:	e04a                	sd	s2,0(sp)
    8000393c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000393e:	c115                	beqz	a0,80003962 <ilock+0x30>
    80003940:	84aa                	mv	s1,a0
    80003942:	451c                	lw	a5,8(a0)
    80003944:	00f05f63          	blez	a5,80003962 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003948:	0541                	addi	a0,a0,16
    8000394a:	00001097          	auipc	ra,0x1
    8000394e:	ca2080e7          	jalr	-862(ra) # 800045ec <acquiresleep>
  if(ip->valid == 0){
    80003952:	40bc                	lw	a5,64(s1)
    80003954:	cf99                	beqz	a5,80003972 <ilock+0x40>
}
    80003956:	60e2                	ld	ra,24(sp)
    80003958:	6442                	ld	s0,16(sp)
    8000395a:	64a2                	ld	s1,8(sp)
    8000395c:	6902                	ld	s2,0(sp)
    8000395e:	6105                	addi	sp,sp,32
    80003960:	8082                	ret
    panic("ilock");
    80003962:	00005517          	auipc	a0,0x5
    80003966:	cce50513          	addi	a0,a0,-818 # 80008630 <syscalls+0x188>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	bd4080e7          	jalr	-1068(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003972:	40dc                	lw	a5,4(s1)
    80003974:	0047d79b          	srliw	a5,a5,0x4
    80003978:	0001c597          	auipc	a1,0x1c
    8000397c:	b385a583          	lw	a1,-1224(a1) # 8001f4b0 <sb+0x18>
    80003980:	9dbd                	addw	a1,a1,a5
    80003982:	4088                	lw	a0,0(s1)
    80003984:	fffff097          	auipc	ra,0xfffff
    80003988:	794080e7          	jalr	1940(ra) # 80003118 <bread>
    8000398c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000398e:	05850593          	addi	a1,a0,88
    80003992:	40dc                	lw	a5,4(s1)
    80003994:	8bbd                	andi	a5,a5,15
    80003996:	079a                	slli	a5,a5,0x6
    80003998:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000399a:	00059783          	lh	a5,0(a1)
    8000399e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039a2:	00259783          	lh	a5,2(a1)
    800039a6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039aa:	00459783          	lh	a5,4(a1)
    800039ae:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039b2:	00659783          	lh	a5,6(a1)
    800039b6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039ba:	459c                	lw	a5,8(a1)
    800039bc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039be:	03400613          	li	a2,52
    800039c2:	05b1                	addi	a1,a1,12
    800039c4:	05048513          	addi	a0,s1,80
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	366080e7          	jalr	870(ra) # 80000d2e <memmove>
    brelse(bp);
    800039d0:	854a                	mv	a0,s2
    800039d2:	00000097          	auipc	ra,0x0
    800039d6:	876080e7          	jalr	-1930(ra) # 80003248 <brelse>
    ip->valid = 1;
    800039da:	4785                	li	a5,1
    800039dc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039de:	04449783          	lh	a5,68(s1)
    800039e2:	fbb5                	bnez	a5,80003956 <ilock+0x24>
      panic("ilock: no type");
    800039e4:	00005517          	auipc	a0,0x5
    800039e8:	c5450513          	addi	a0,a0,-940 # 80008638 <syscalls+0x190>
    800039ec:	ffffd097          	auipc	ra,0xffffd
    800039f0:	b52080e7          	jalr	-1198(ra) # 8000053e <panic>

00000000800039f4 <iunlock>:
{
    800039f4:	1101                	addi	sp,sp,-32
    800039f6:	ec06                	sd	ra,24(sp)
    800039f8:	e822                	sd	s0,16(sp)
    800039fa:	e426                	sd	s1,8(sp)
    800039fc:	e04a                	sd	s2,0(sp)
    800039fe:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a00:	c905                	beqz	a0,80003a30 <iunlock+0x3c>
    80003a02:	84aa                	mv	s1,a0
    80003a04:	01050913          	addi	s2,a0,16
    80003a08:	854a                	mv	a0,s2
    80003a0a:	00001097          	auipc	ra,0x1
    80003a0e:	c7c080e7          	jalr	-900(ra) # 80004686 <holdingsleep>
    80003a12:	cd19                	beqz	a0,80003a30 <iunlock+0x3c>
    80003a14:	449c                	lw	a5,8(s1)
    80003a16:	00f05d63          	blez	a5,80003a30 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	00001097          	auipc	ra,0x1
    80003a20:	c26080e7          	jalr	-986(ra) # 80004642 <releasesleep>
}
    80003a24:	60e2                	ld	ra,24(sp)
    80003a26:	6442                	ld	s0,16(sp)
    80003a28:	64a2                	ld	s1,8(sp)
    80003a2a:	6902                	ld	s2,0(sp)
    80003a2c:	6105                	addi	sp,sp,32
    80003a2e:	8082                	ret
    panic("iunlock");
    80003a30:	00005517          	auipc	a0,0x5
    80003a34:	c1850513          	addi	a0,a0,-1000 # 80008648 <syscalls+0x1a0>
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	b06080e7          	jalr	-1274(ra) # 8000053e <panic>

0000000080003a40 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a40:	7179                	addi	sp,sp,-48
    80003a42:	f406                	sd	ra,40(sp)
    80003a44:	f022                	sd	s0,32(sp)
    80003a46:	ec26                	sd	s1,24(sp)
    80003a48:	e84a                	sd	s2,16(sp)
    80003a4a:	e44e                	sd	s3,8(sp)
    80003a4c:	e052                	sd	s4,0(sp)
    80003a4e:	1800                	addi	s0,sp,48
    80003a50:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a52:	05050493          	addi	s1,a0,80
    80003a56:	08050913          	addi	s2,a0,128
    80003a5a:	a021                	j	80003a62 <itrunc+0x22>
    80003a5c:	0491                	addi	s1,s1,4
    80003a5e:	01248d63          	beq	s1,s2,80003a78 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a62:	408c                	lw	a1,0(s1)
    80003a64:	dde5                	beqz	a1,80003a5c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a66:	0009a503          	lw	a0,0(s3)
    80003a6a:	00000097          	auipc	ra,0x0
    80003a6e:	8f4080e7          	jalr	-1804(ra) # 8000335e <bfree>
      ip->addrs[i] = 0;
    80003a72:	0004a023          	sw	zero,0(s1)
    80003a76:	b7dd                	j	80003a5c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a78:	0809a583          	lw	a1,128(s3)
    80003a7c:	e185                	bnez	a1,80003a9c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a7e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a82:	854e                	mv	a0,s3
    80003a84:	00000097          	auipc	ra,0x0
    80003a88:	de4080e7          	jalr	-540(ra) # 80003868 <iupdate>
}
    80003a8c:	70a2                	ld	ra,40(sp)
    80003a8e:	7402                	ld	s0,32(sp)
    80003a90:	64e2                	ld	s1,24(sp)
    80003a92:	6942                	ld	s2,16(sp)
    80003a94:	69a2                	ld	s3,8(sp)
    80003a96:	6a02                	ld	s4,0(sp)
    80003a98:	6145                	addi	sp,sp,48
    80003a9a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a9c:	0009a503          	lw	a0,0(s3)
    80003aa0:	fffff097          	auipc	ra,0xfffff
    80003aa4:	678080e7          	jalr	1656(ra) # 80003118 <bread>
    80003aa8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003aaa:	05850493          	addi	s1,a0,88
    80003aae:	45850913          	addi	s2,a0,1112
    80003ab2:	a021                	j	80003aba <itrunc+0x7a>
    80003ab4:	0491                	addi	s1,s1,4
    80003ab6:	01248b63          	beq	s1,s2,80003acc <itrunc+0x8c>
      if(a[j])
    80003aba:	408c                	lw	a1,0(s1)
    80003abc:	dde5                	beqz	a1,80003ab4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003abe:	0009a503          	lw	a0,0(s3)
    80003ac2:	00000097          	auipc	ra,0x0
    80003ac6:	89c080e7          	jalr	-1892(ra) # 8000335e <bfree>
    80003aca:	b7ed                	j	80003ab4 <itrunc+0x74>
    brelse(bp);
    80003acc:	8552                	mv	a0,s4
    80003ace:	fffff097          	auipc	ra,0xfffff
    80003ad2:	77a080e7          	jalr	1914(ra) # 80003248 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ad6:	0809a583          	lw	a1,128(s3)
    80003ada:	0009a503          	lw	a0,0(s3)
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	880080e7          	jalr	-1920(ra) # 8000335e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ae6:	0809a023          	sw	zero,128(s3)
    80003aea:	bf51                	j	80003a7e <itrunc+0x3e>

0000000080003aec <iput>:
{
    80003aec:	1101                	addi	sp,sp,-32
    80003aee:	ec06                	sd	ra,24(sp)
    80003af0:	e822                	sd	s0,16(sp)
    80003af2:	e426                	sd	s1,8(sp)
    80003af4:	e04a                	sd	s2,0(sp)
    80003af6:	1000                	addi	s0,sp,32
    80003af8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003afa:	0001c517          	auipc	a0,0x1c
    80003afe:	9be50513          	addi	a0,a0,-1602 # 8001f4b8 <itable>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	0d4080e7          	jalr	212(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b0a:	4498                	lw	a4,8(s1)
    80003b0c:	4785                	li	a5,1
    80003b0e:	02f70363          	beq	a4,a5,80003b34 <iput+0x48>
  ip->ref--;
    80003b12:	449c                	lw	a5,8(s1)
    80003b14:	37fd                	addiw	a5,a5,-1
    80003b16:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b18:	0001c517          	auipc	a0,0x1c
    80003b1c:	9a050513          	addi	a0,a0,-1632 # 8001f4b8 <itable>
    80003b20:	ffffd097          	auipc	ra,0xffffd
    80003b24:	16a080e7          	jalr	362(ra) # 80000c8a <release>
}
    80003b28:	60e2                	ld	ra,24(sp)
    80003b2a:	6442                	ld	s0,16(sp)
    80003b2c:	64a2                	ld	s1,8(sp)
    80003b2e:	6902                	ld	s2,0(sp)
    80003b30:	6105                	addi	sp,sp,32
    80003b32:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b34:	40bc                	lw	a5,64(s1)
    80003b36:	dff1                	beqz	a5,80003b12 <iput+0x26>
    80003b38:	04a49783          	lh	a5,74(s1)
    80003b3c:	fbf9                	bnez	a5,80003b12 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b3e:	01048913          	addi	s2,s1,16
    80003b42:	854a                	mv	a0,s2
    80003b44:	00001097          	auipc	ra,0x1
    80003b48:	aa8080e7          	jalr	-1368(ra) # 800045ec <acquiresleep>
    release(&itable.lock);
    80003b4c:	0001c517          	auipc	a0,0x1c
    80003b50:	96c50513          	addi	a0,a0,-1684 # 8001f4b8 <itable>
    80003b54:	ffffd097          	auipc	ra,0xffffd
    80003b58:	136080e7          	jalr	310(ra) # 80000c8a <release>
    itrunc(ip);
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	ee2080e7          	jalr	-286(ra) # 80003a40 <itrunc>
    ip->type = 0;
    80003b66:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b6a:	8526                	mv	a0,s1
    80003b6c:	00000097          	auipc	ra,0x0
    80003b70:	cfc080e7          	jalr	-772(ra) # 80003868 <iupdate>
    ip->valid = 0;
    80003b74:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b78:	854a                	mv	a0,s2
    80003b7a:	00001097          	auipc	ra,0x1
    80003b7e:	ac8080e7          	jalr	-1336(ra) # 80004642 <releasesleep>
    acquire(&itable.lock);
    80003b82:	0001c517          	auipc	a0,0x1c
    80003b86:	93650513          	addi	a0,a0,-1738 # 8001f4b8 <itable>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	04c080e7          	jalr	76(ra) # 80000bd6 <acquire>
    80003b92:	b741                	j	80003b12 <iput+0x26>

0000000080003b94 <iunlockput>:
{
    80003b94:	1101                	addi	sp,sp,-32
    80003b96:	ec06                	sd	ra,24(sp)
    80003b98:	e822                	sd	s0,16(sp)
    80003b9a:	e426                	sd	s1,8(sp)
    80003b9c:	1000                	addi	s0,sp,32
    80003b9e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ba0:	00000097          	auipc	ra,0x0
    80003ba4:	e54080e7          	jalr	-428(ra) # 800039f4 <iunlock>
  iput(ip);
    80003ba8:	8526                	mv	a0,s1
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	f42080e7          	jalr	-190(ra) # 80003aec <iput>
}
    80003bb2:	60e2                	ld	ra,24(sp)
    80003bb4:	6442                	ld	s0,16(sp)
    80003bb6:	64a2                	ld	s1,8(sp)
    80003bb8:	6105                	addi	sp,sp,32
    80003bba:	8082                	ret

0000000080003bbc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bbc:	1141                	addi	sp,sp,-16
    80003bbe:	e422                	sd	s0,8(sp)
    80003bc0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bc2:	411c                	lw	a5,0(a0)
    80003bc4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bc6:	415c                	lw	a5,4(a0)
    80003bc8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bca:	04451783          	lh	a5,68(a0)
    80003bce:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bd2:	04a51783          	lh	a5,74(a0)
    80003bd6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bda:	04c56783          	lwu	a5,76(a0)
    80003bde:	e99c                	sd	a5,16(a1)
}
    80003be0:	6422                	ld	s0,8(sp)
    80003be2:	0141                	addi	sp,sp,16
    80003be4:	8082                	ret

0000000080003be6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003be6:	457c                	lw	a5,76(a0)
    80003be8:	0ed7e963          	bltu	a5,a3,80003cda <readi+0xf4>
{
    80003bec:	7159                	addi	sp,sp,-112
    80003bee:	f486                	sd	ra,104(sp)
    80003bf0:	f0a2                	sd	s0,96(sp)
    80003bf2:	eca6                	sd	s1,88(sp)
    80003bf4:	e8ca                	sd	s2,80(sp)
    80003bf6:	e4ce                	sd	s3,72(sp)
    80003bf8:	e0d2                	sd	s4,64(sp)
    80003bfa:	fc56                	sd	s5,56(sp)
    80003bfc:	f85a                	sd	s6,48(sp)
    80003bfe:	f45e                	sd	s7,40(sp)
    80003c00:	f062                	sd	s8,32(sp)
    80003c02:	ec66                	sd	s9,24(sp)
    80003c04:	e86a                	sd	s10,16(sp)
    80003c06:	e46e                	sd	s11,8(sp)
    80003c08:	1880                	addi	s0,sp,112
    80003c0a:	8b2a                	mv	s6,a0
    80003c0c:	8bae                	mv	s7,a1
    80003c0e:	8a32                	mv	s4,a2
    80003c10:	84b6                	mv	s1,a3
    80003c12:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c14:	9f35                	addw	a4,a4,a3
    return 0;
    80003c16:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c18:	0ad76063          	bltu	a4,a3,80003cb8 <readi+0xd2>
  if(off + n > ip->size)
    80003c1c:	00e7f463          	bgeu	a5,a4,80003c24 <readi+0x3e>
    n = ip->size - off;
    80003c20:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c24:	0a0a8963          	beqz	s5,80003cd6 <readi+0xf0>
    80003c28:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c2a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c2e:	5c7d                	li	s8,-1
    80003c30:	a82d                	j	80003c6a <readi+0x84>
    80003c32:	020d1d93          	slli	s11,s10,0x20
    80003c36:	020ddd93          	srli	s11,s11,0x20
    80003c3a:	05890793          	addi	a5,s2,88
    80003c3e:	86ee                	mv	a3,s11
    80003c40:	963e                	add	a2,a2,a5
    80003c42:	85d2                	mv	a1,s4
    80003c44:	855e                	mv	a0,s7
    80003c46:	fffff097          	auipc	ra,0xfffff
    80003c4a:	a72080e7          	jalr	-1422(ra) # 800026b8 <either_copyout>
    80003c4e:	05850d63          	beq	a0,s8,80003ca8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c52:	854a                	mv	a0,s2
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	5f4080e7          	jalr	1524(ra) # 80003248 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c5c:	013d09bb          	addw	s3,s10,s3
    80003c60:	009d04bb          	addw	s1,s10,s1
    80003c64:	9a6e                	add	s4,s4,s11
    80003c66:	0559f763          	bgeu	s3,s5,80003cb4 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c6a:	00a4d59b          	srliw	a1,s1,0xa
    80003c6e:	855a                	mv	a0,s6
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	8a2080e7          	jalr	-1886(ra) # 80003512 <bmap>
    80003c78:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c7c:	cd85                	beqz	a1,80003cb4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c7e:	000b2503          	lw	a0,0(s6)
    80003c82:	fffff097          	auipc	ra,0xfffff
    80003c86:	496080e7          	jalr	1174(ra) # 80003118 <bread>
    80003c8a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c8c:	3ff4f613          	andi	a2,s1,1023
    80003c90:	40cc87bb          	subw	a5,s9,a2
    80003c94:	413a873b          	subw	a4,s5,s3
    80003c98:	8d3e                	mv	s10,a5
    80003c9a:	2781                	sext.w	a5,a5
    80003c9c:	0007069b          	sext.w	a3,a4
    80003ca0:	f8f6f9e3          	bgeu	a3,a5,80003c32 <readi+0x4c>
    80003ca4:	8d3a                	mv	s10,a4
    80003ca6:	b771                	j	80003c32 <readi+0x4c>
      brelse(bp);
    80003ca8:	854a                	mv	a0,s2
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	59e080e7          	jalr	1438(ra) # 80003248 <brelse>
      tot = -1;
    80003cb2:	59fd                	li	s3,-1
  }
  return tot;
    80003cb4:	0009851b          	sext.w	a0,s3
}
    80003cb8:	70a6                	ld	ra,104(sp)
    80003cba:	7406                	ld	s0,96(sp)
    80003cbc:	64e6                	ld	s1,88(sp)
    80003cbe:	6946                	ld	s2,80(sp)
    80003cc0:	69a6                	ld	s3,72(sp)
    80003cc2:	6a06                	ld	s4,64(sp)
    80003cc4:	7ae2                	ld	s5,56(sp)
    80003cc6:	7b42                	ld	s6,48(sp)
    80003cc8:	7ba2                	ld	s7,40(sp)
    80003cca:	7c02                	ld	s8,32(sp)
    80003ccc:	6ce2                	ld	s9,24(sp)
    80003cce:	6d42                	ld	s10,16(sp)
    80003cd0:	6da2                	ld	s11,8(sp)
    80003cd2:	6165                	addi	sp,sp,112
    80003cd4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cd6:	89d6                	mv	s3,s5
    80003cd8:	bff1                	j	80003cb4 <readi+0xce>
    return 0;
    80003cda:	4501                	li	a0,0
}
    80003cdc:	8082                	ret

0000000080003cde <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cde:	457c                	lw	a5,76(a0)
    80003ce0:	10d7e863          	bltu	a5,a3,80003df0 <writei+0x112>
{
    80003ce4:	7159                	addi	sp,sp,-112
    80003ce6:	f486                	sd	ra,104(sp)
    80003ce8:	f0a2                	sd	s0,96(sp)
    80003cea:	eca6                	sd	s1,88(sp)
    80003cec:	e8ca                	sd	s2,80(sp)
    80003cee:	e4ce                	sd	s3,72(sp)
    80003cf0:	e0d2                	sd	s4,64(sp)
    80003cf2:	fc56                	sd	s5,56(sp)
    80003cf4:	f85a                	sd	s6,48(sp)
    80003cf6:	f45e                	sd	s7,40(sp)
    80003cf8:	f062                	sd	s8,32(sp)
    80003cfa:	ec66                	sd	s9,24(sp)
    80003cfc:	e86a                	sd	s10,16(sp)
    80003cfe:	e46e                	sd	s11,8(sp)
    80003d00:	1880                	addi	s0,sp,112
    80003d02:	8aaa                	mv	s5,a0
    80003d04:	8bae                	mv	s7,a1
    80003d06:	8a32                	mv	s4,a2
    80003d08:	8936                	mv	s2,a3
    80003d0a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d0c:	00e687bb          	addw	a5,a3,a4
    80003d10:	0ed7e263          	bltu	a5,a3,80003df4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d14:	00043737          	lui	a4,0x43
    80003d18:	0ef76063          	bltu	a4,a5,80003df8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d1c:	0c0b0863          	beqz	s6,80003dec <writei+0x10e>
    80003d20:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d22:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d26:	5c7d                	li	s8,-1
    80003d28:	a091                	j	80003d6c <writei+0x8e>
    80003d2a:	020d1d93          	slli	s11,s10,0x20
    80003d2e:	020ddd93          	srli	s11,s11,0x20
    80003d32:	05848793          	addi	a5,s1,88
    80003d36:	86ee                	mv	a3,s11
    80003d38:	8652                	mv	a2,s4
    80003d3a:	85de                	mv	a1,s7
    80003d3c:	953e                	add	a0,a0,a5
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	9d0080e7          	jalr	-1584(ra) # 8000270e <either_copyin>
    80003d46:	07850263          	beq	a0,s8,80003daa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	00000097          	auipc	ra,0x0
    80003d50:	780080e7          	jalr	1920(ra) # 800044cc <log_write>
    brelse(bp);
    80003d54:	8526                	mv	a0,s1
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	4f2080e7          	jalr	1266(ra) # 80003248 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d5e:	013d09bb          	addw	s3,s10,s3
    80003d62:	012d093b          	addw	s2,s10,s2
    80003d66:	9a6e                	add	s4,s4,s11
    80003d68:	0569f663          	bgeu	s3,s6,80003db4 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d6c:	00a9559b          	srliw	a1,s2,0xa
    80003d70:	8556                	mv	a0,s5
    80003d72:	fffff097          	auipc	ra,0xfffff
    80003d76:	7a0080e7          	jalr	1952(ra) # 80003512 <bmap>
    80003d7a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d7e:	c99d                	beqz	a1,80003db4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d80:	000aa503          	lw	a0,0(s5)
    80003d84:	fffff097          	auipc	ra,0xfffff
    80003d88:	394080e7          	jalr	916(ra) # 80003118 <bread>
    80003d8c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d8e:	3ff97513          	andi	a0,s2,1023
    80003d92:	40ac87bb          	subw	a5,s9,a0
    80003d96:	413b073b          	subw	a4,s6,s3
    80003d9a:	8d3e                	mv	s10,a5
    80003d9c:	2781                	sext.w	a5,a5
    80003d9e:	0007069b          	sext.w	a3,a4
    80003da2:	f8f6f4e3          	bgeu	a3,a5,80003d2a <writei+0x4c>
    80003da6:	8d3a                	mv	s10,a4
    80003da8:	b749                	j	80003d2a <writei+0x4c>
      brelse(bp);
    80003daa:	8526                	mv	a0,s1
    80003dac:	fffff097          	auipc	ra,0xfffff
    80003db0:	49c080e7          	jalr	1180(ra) # 80003248 <brelse>
  }

  if(off > ip->size)
    80003db4:	04caa783          	lw	a5,76(s5)
    80003db8:	0127f463          	bgeu	a5,s2,80003dc0 <writei+0xe2>
    ip->size = off;
    80003dbc:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003dc0:	8556                	mv	a0,s5
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	aa6080e7          	jalr	-1370(ra) # 80003868 <iupdate>

  return tot;
    80003dca:	0009851b          	sext.w	a0,s3
}
    80003dce:	70a6                	ld	ra,104(sp)
    80003dd0:	7406                	ld	s0,96(sp)
    80003dd2:	64e6                	ld	s1,88(sp)
    80003dd4:	6946                	ld	s2,80(sp)
    80003dd6:	69a6                	ld	s3,72(sp)
    80003dd8:	6a06                	ld	s4,64(sp)
    80003dda:	7ae2                	ld	s5,56(sp)
    80003ddc:	7b42                	ld	s6,48(sp)
    80003dde:	7ba2                	ld	s7,40(sp)
    80003de0:	7c02                	ld	s8,32(sp)
    80003de2:	6ce2                	ld	s9,24(sp)
    80003de4:	6d42                	ld	s10,16(sp)
    80003de6:	6da2                	ld	s11,8(sp)
    80003de8:	6165                	addi	sp,sp,112
    80003dea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dec:	89da                	mv	s3,s6
    80003dee:	bfc9                	j	80003dc0 <writei+0xe2>
    return -1;
    80003df0:	557d                	li	a0,-1
}
    80003df2:	8082                	ret
    return -1;
    80003df4:	557d                	li	a0,-1
    80003df6:	bfe1                	j	80003dce <writei+0xf0>
    return -1;
    80003df8:	557d                	li	a0,-1
    80003dfa:	bfd1                	j	80003dce <writei+0xf0>

0000000080003dfc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dfc:	1141                	addi	sp,sp,-16
    80003dfe:	e406                	sd	ra,8(sp)
    80003e00:	e022                	sd	s0,0(sp)
    80003e02:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e04:	4639                	li	a2,14
    80003e06:	ffffd097          	auipc	ra,0xffffd
    80003e0a:	f9c080e7          	jalr	-100(ra) # 80000da2 <strncmp>
}
    80003e0e:	60a2                	ld	ra,8(sp)
    80003e10:	6402                	ld	s0,0(sp)
    80003e12:	0141                	addi	sp,sp,16
    80003e14:	8082                	ret

0000000080003e16 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e16:	7139                	addi	sp,sp,-64
    80003e18:	fc06                	sd	ra,56(sp)
    80003e1a:	f822                	sd	s0,48(sp)
    80003e1c:	f426                	sd	s1,40(sp)
    80003e1e:	f04a                	sd	s2,32(sp)
    80003e20:	ec4e                	sd	s3,24(sp)
    80003e22:	e852                	sd	s4,16(sp)
    80003e24:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e26:	04451703          	lh	a4,68(a0)
    80003e2a:	4785                	li	a5,1
    80003e2c:	00f71a63          	bne	a4,a5,80003e40 <dirlookup+0x2a>
    80003e30:	892a                	mv	s2,a0
    80003e32:	89ae                	mv	s3,a1
    80003e34:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e36:	457c                	lw	a5,76(a0)
    80003e38:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e3a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e3c:	e79d                	bnez	a5,80003e6a <dirlookup+0x54>
    80003e3e:	a8a5                	j	80003eb6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e40:	00005517          	auipc	a0,0x5
    80003e44:	81050513          	addi	a0,a0,-2032 # 80008650 <syscalls+0x1a8>
    80003e48:	ffffc097          	auipc	ra,0xffffc
    80003e4c:	6f6080e7          	jalr	1782(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003e50:	00005517          	auipc	a0,0x5
    80003e54:	81850513          	addi	a0,a0,-2024 # 80008668 <syscalls+0x1c0>
    80003e58:	ffffc097          	auipc	ra,0xffffc
    80003e5c:	6e6080e7          	jalr	1766(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e60:	24c1                	addiw	s1,s1,16
    80003e62:	04c92783          	lw	a5,76(s2)
    80003e66:	04f4f763          	bgeu	s1,a5,80003eb4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e6a:	4741                	li	a4,16
    80003e6c:	86a6                	mv	a3,s1
    80003e6e:	fc040613          	addi	a2,s0,-64
    80003e72:	4581                	li	a1,0
    80003e74:	854a                	mv	a0,s2
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	d70080e7          	jalr	-656(ra) # 80003be6 <readi>
    80003e7e:	47c1                	li	a5,16
    80003e80:	fcf518e3          	bne	a0,a5,80003e50 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e84:	fc045783          	lhu	a5,-64(s0)
    80003e88:	dfe1                	beqz	a5,80003e60 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e8a:	fc240593          	addi	a1,s0,-62
    80003e8e:	854e                	mv	a0,s3
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	f6c080e7          	jalr	-148(ra) # 80003dfc <namecmp>
    80003e98:	f561                	bnez	a0,80003e60 <dirlookup+0x4a>
      if(poff)
    80003e9a:	000a0463          	beqz	s4,80003ea2 <dirlookup+0x8c>
        *poff = off;
    80003e9e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ea2:	fc045583          	lhu	a1,-64(s0)
    80003ea6:	00092503          	lw	a0,0(s2)
    80003eaa:	fffff097          	auipc	ra,0xfffff
    80003eae:	750080e7          	jalr	1872(ra) # 800035fa <iget>
    80003eb2:	a011                	j	80003eb6 <dirlookup+0xa0>
  return 0;
    80003eb4:	4501                	li	a0,0
}
    80003eb6:	70e2                	ld	ra,56(sp)
    80003eb8:	7442                	ld	s0,48(sp)
    80003eba:	74a2                	ld	s1,40(sp)
    80003ebc:	7902                	ld	s2,32(sp)
    80003ebe:	69e2                	ld	s3,24(sp)
    80003ec0:	6a42                	ld	s4,16(sp)
    80003ec2:	6121                	addi	sp,sp,64
    80003ec4:	8082                	ret

0000000080003ec6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ec6:	711d                	addi	sp,sp,-96
    80003ec8:	ec86                	sd	ra,88(sp)
    80003eca:	e8a2                	sd	s0,80(sp)
    80003ecc:	e4a6                	sd	s1,72(sp)
    80003ece:	e0ca                	sd	s2,64(sp)
    80003ed0:	fc4e                	sd	s3,56(sp)
    80003ed2:	f852                	sd	s4,48(sp)
    80003ed4:	f456                	sd	s5,40(sp)
    80003ed6:	f05a                	sd	s6,32(sp)
    80003ed8:	ec5e                	sd	s7,24(sp)
    80003eda:	e862                	sd	s8,16(sp)
    80003edc:	e466                	sd	s9,8(sp)
    80003ede:	1080                	addi	s0,sp,96
    80003ee0:	84aa                	mv	s1,a0
    80003ee2:	8aae                	mv	s5,a1
    80003ee4:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ee6:	00054703          	lbu	a4,0(a0)
    80003eea:	02f00793          	li	a5,47
    80003eee:	02f70363          	beq	a4,a5,80003f14 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ef2:	ffffe097          	auipc	ra,0xffffe
    80003ef6:	ada080e7          	jalr	-1318(ra) # 800019cc <myproc>
    80003efa:	15053503          	ld	a0,336(a0)
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	9f6080e7          	jalr	-1546(ra) # 800038f4 <idup>
    80003f06:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f08:	02f00913          	li	s2,47
  len = path - s;
    80003f0c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f0e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f10:	4b85                	li	s7,1
    80003f12:	a865                	j	80003fca <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f14:	4585                	li	a1,1
    80003f16:	4505                	li	a0,1
    80003f18:	fffff097          	auipc	ra,0xfffff
    80003f1c:	6e2080e7          	jalr	1762(ra) # 800035fa <iget>
    80003f20:	89aa                	mv	s3,a0
    80003f22:	b7dd                	j	80003f08 <namex+0x42>
      iunlockput(ip);
    80003f24:	854e                	mv	a0,s3
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	c6e080e7          	jalr	-914(ra) # 80003b94 <iunlockput>
      return 0;
    80003f2e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f30:	854e                	mv	a0,s3
    80003f32:	60e6                	ld	ra,88(sp)
    80003f34:	6446                	ld	s0,80(sp)
    80003f36:	64a6                	ld	s1,72(sp)
    80003f38:	6906                	ld	s2,64(sp)
    80003f3a:	79e2                	ld	s3,56(sp)
    80003f3c:	7a42                	ld	s4,48(sp)
    80003f3e:	7aa2                	ld	s5,40(sp)
    80003f40:	7b02                	ld	s6,32(sp)
    80003f42:	6be2                	ld	s7,24(sp)
    80003f44:	6c42                	ld	s8,16(sp)
    80003f46:	6ca2                	ld	s9,8(sp)
    80003f48:	6125                	addi	sp,sp,96
    80003f4a:	8082                	ret
      iunlock(ip);
    80003f4c:	854e                	mv	a0,s3
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	aa6080e7          	jalr	-1370(ra) # 800039f4 <iunlock>
      return ip;
    80003f56:	bfe9                	j	80003f30 <namex+0x6a>
      iunlockput(ip);
    80003f58:	854e                	mv	a0,s3
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	c3a080e7          	jalr	-966(ra) # 80003b94 <iunlockput>
      return 0;
    80003f62:	89e6                	mv	s3,s9
    80003f64:	b7f1                	j	80003f30 <namex+0x6a>
  len = path - s;
    80003f66:	40b48633          	sub	a2,s1,a1
    80003f6a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f6e:	099c5463          	bge	s8,s9,80003ff6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f72:	4639                	li	a2,14
    80003f74:	8552                	mv	a0,s4
    80003f76:	ffffd097          	auipc	ra,0xffffd
    80003f7a:	db8080e7          	jalr	-584(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003f7e:	0004c783          	lbu	a5,0(s1)
    80003f82:	01279763          	bne	a5,s2,80003f90 <namex+0xca>
    path++;
    80003f86:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f88:	0004c783          	lbu	a5,0(s1)
    80003f8c:	ff278de3          	beq	a5,s2,80003f86 <namex+0xc0>
    ilock(ip);
    80003f90:	854e                	mv	a0,s3
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	9a0080e7          	jalr	-1632(ra) # 80003932 <ilock>
    if(ip->type != T_DIR){
    80003f9a:	04499783          	lh	a5,68(s3)
    80003f9e:	f97793e3          	bne	a5,s7,80003f24 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003fa2:	000a8563          	beqz	s5,80003fac <namex+0xe6>
    80003fa6:	0004c783          	lbu	a5,0(s1)
    80003faa:	d3cd                	beqz	a5,80003f4c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fac:	865a                	mv	a2,s6
    80003fae:	85d2                	mv	a1,s4
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	e64080e7          	jalr	-412(ra) # 80003e16 <dirlookup>
    80003fba:	8caa                	mv	s9,a0
    80003fbc:	dd51                	beqz	a0,80003f58 <namex+0x92>
    iunlockput(ip);
    80003fbe:	854e                	mv	a0,s3
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	bd4080e7          	jalr	-1068(ra) # 80003b94 <iunlockput>
    ip = next;
    80003fc8:	89e6                	mv	s3,s9
  while(*path == '/')
    80003fca:	0004c783          	lbu	a5,0(s1)
    80003fce:	05279763          	bne	a5,s2,8000401c <namex+0x156>
    path++;
    80003fd2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fd4:	0004c783          	lbu	a5,0(s1)
    80003fd8:	ff278de3          	beq	a5,s2,80003fd2 <namex+0x10c>
  if(*path == 0)
    80003fdc:	c79d                	beqz	a5,8000400a <namex+0x144>
    path++;
    80003fde:	85a6                	mv	a1,s1
  len = path - s;
    80003fe0:	8cda                	mv	s9,s6
    80003fe2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003fe4:	01278963          	beq	a5,s2,80003ff6 <namex+0x130>
    80003fe8:	dfbd                	beqz	a5,80003f66 <namex+0xa0>
    path++;
    80003fea:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fec:	0004c783          	lbu	a5,0(s1)
    80003ff0:	ff279ce3          	bne	a5,s2,80003fe8 <namex+0x122>
    80003ff4:	bf8d                	j	80003f66 <namex+0xa0>
    memmove(name, s, len);
    80003ff6:	2601                	sext.w	a2,a2
    80003ff8:	8552                	mv	a0,s4
    80003ffa:	ffffd097          	auipc	ra,0xffffd
    80003ffe:	d34080e7          	jalr	-716(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004002:	9cd2                	add	s9,s9,s4
    80004004:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004008:	bf9d                	j	80003f7e <namex+0xb8>
  if(nameiparent){
    8000400a:	f20a83e3          	beqz	s5,80003f30 <namex+0x6a>
    iput(ip);
    8000400e:	854e                	mv	a0,s3
    80004010:	00000097          	auipc	ra,0x0
    80004014:	adc080e7          	jalr	-1316(ra) # 80003aec <iput>
    return 0;
    80004018:	4981                	li	s3,0
    8000401a:	bf19                	j	80003f30 <namex+0x6a>
  if(*path == 0)
    8000401c:	d7fd                	beqz	a5,8000400a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000401e:	0004c783          	lbu	a5,0(s1)
    80004022:	85a6                	mv	a1,s1
    80004024:	b7d1                	j	80003fe8 <namex+0x122>

0000000080004026 <dirlink>:
{
    80004026:	7139                	addi	sp,sp,-64
    80004028:	fc06                	sd	ra,56(sp)
    8000402a:	f822                	sd	s0,48(sp)
    8000402c:	f426                	sd	s1,40(sp)
    8000402e:	f04a                	sd	s2,32(sp)
    80004030:	ec4e                	sd	s3,24(sp)
    80004032:	e852                	sd	s4,16(sp)
    80004034:	0080                	addi	s0,sp,64
    80004036:	892a                	mv	s2,a0
    80004038:	8a2e                	mv	s4,a1
    8000403a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000403c:	4601                	li	a2,0
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	dd8080e7          	jalr	-552(ra) # 80003e16 <dirlookup>
    80004046:	e93d                	bnez	a0,800040bc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004048:	04c92483          	lw	s1,76(s2)
    8000404c:	c49d                	beqz	s1,8000407a <dirlink+0x54>
    8000404e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004050:	4741                	li	a4,16
    80004052:	86a6                	mv	a3,s1
    80004054:	fc040613          	addi	a2,s0,-64
    80004058:	4581                	li	a1,0
    8000405a:	854a                	mv	a0,s2
    8000405c:	00000097          	auipc	ra,0x0
    80004060:	b8a080e7          	jalr	-1142(ra) # 80003be6 <readi>
    80004064:	47c1                	li	a5,16
    80004066:	06f51163          	bne	a0,a5,800040c8 <dirlink+0xa2>
    if(de.inum == 0)
    8000406a:	fc045783          	lhu	a5,-64(s0)
    8000406e:	c791                	beqz	a5,8000407a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004070:	24c1                	addiw	s1,s1,16
    80004072:	04c92783          	lw	a5,76(s2)
    80004076:	fcf4ede3          	bltu	s1,a5,80004050 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000407a:	4639                	li	a2,14
    8000407c:	85d2                	mv	a1,s4
    8000407e:	fc240513          	addi	a0,s0,-62
    80004082:	ffffd097          	auipc	ra,0xffffd
    80004086:	d5c080e7          	jalr	-676(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000408a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000408e:	4741                	li	a4,16
    80004090:	86a6                	mv	a3,s1
    80004092:	fc040613          	addi	a2,s0,-64
    80004096:	4581                	li	a1,0
    80004098:	854a                	mv	a0,s2
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	c44080e7          	jalr	-956(ra) # 80003cde <writei>
    800040a2:	1541                	addi	a0,a0,-16
    800040a4:	00a03533          	snez	a0,a0
    800040a8:	40a00533          	neg	a0,a0
}
    800040ac:	70e2                	ld	ra,56(sp)
    800040ae:	7442                	ld	s0,48(sp)
    800040b0:	74a2                	ld	s1,40(sp)
    800040b2:	7902                	ld	s2,32(sp)
    800040b4:	69e2                	ld	s3,24(sp)
    800040b6:	6a42                	ld	s4,16(sp)
    800040b8:	6121                	addi	sp,sp,64
    800040ba:	8082                	ret
    iput(ip);
    800040bc:	00000097          	auipc	ra,0x0
    800040c0:	a30080e7          	jalr	-1488(ra) # 80003aec <iput>
    return -1;
    800040c4:	557d                	li	a0,-1
    800040c6:	b7dd                	j	800040ac <dirlink+0x86>
      panic("dirlink read");
    800040c8:	00004517          	auipc	a0,0x4
    800040cc:	5b050513          	addi	a0,a0,1456 # 80008678 <syscalls+0x1d0>
    800040d0:	ffffc097          	auipc	ra,0xffffc
    800040d4:	46e080e7          	jalr	1134(ra) # 8000053e <panic>

00000000800040d8 <namei>:

struct inode*
namei(char *path)
{
    800040d8:	1101                	addi	sp,sp,-32
    800040da:	ec06                	sd	ra,24(sp)
    800040dc:	e822                	sd	s0,16(sp)
    800040de:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040e0:	fe040613          	addi	a2,s0,-32
    800040e4:	4581                	li	a1,0
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	de0080e7          	jalr	-544(ra) # 80003ec6 <namex>
}
    800040ee:	60e2                	ld	ra,24(sp)
    800040f0:	6442                	ld	s0,16(sp)
    800040f2:	6105                	addi	sp,sp,32
    800040f4:	8082                	ret

00000000800040f6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040f6:	1141                	addi	sp,sp,-16
    800040f8:	e406                	sd	ra,8(sp)
    800040fa:	e022                	sd	s0,0(sp)
    800040fc:	0800                	addi	s0,sp,16
    800040fe:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004100:	4585                	li	a1,1
    80004102:	00000097          	auipc	ra,0x0
    80004106:	dc4080e7          	jalr	-572(ra) # 80003ec6 <namex>
}
    8000410a:	60a2                	ld	ra,8(sp)
    8000410c:	6402                	ld	s0,0(sp)
    8000410e:	0141                	addi	sp,sp,16
    80004110:	8082                	ret

0000000080004112 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004112:	1101                	addi	sp,sp,-32
    80004114:	ec06                	sd	ra,24(sp)
    80004116:	e822                	sd	s0,16(sp)
    80004118:	e426                	sd	s1,8(sp)
    8000411a:	e04a                	sd	s2,0(sp)
    8000411c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000411e:	0001d917          	auipc	s2,0x1d
    80004122:	e4290913          	addi	s2,s2,-446 # 80020f60 <log>
    80004126:	01892583          	lw	a1,24(s2)
    8000412a:	02892503          	lw	a0,40(s2)
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	fea080e7          	jalr	-22(ra) # 80003118 <bread>
    80004136:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004138:	02c92683          	lw	a3,44(s2)
    8000413c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000413e:	02d05763          	blez	a3,8000416c <write_head+0x5a>
    80004142:	0001d797          	auipc	a5,0x1d
    80004146:	e4e78793          	addi	a5,a5,-434 # 80020f90 <log+0x30>
    8000414a:	05c50713          	addi	a4,a0,92
    8000414e:	36fd                	addiw	a3,a3,-1
    80004150:	1682                	slli	a3,a3,0x20
    80004152:	9281                	srli	a3,a3,0x20
    80004154:	068a                	slli	a3,a3,0x2
    80004156:	0001d617          	auipc	a2,0x1d
    8000415a:	e3e60613          	addi	a2,a2,-450 # 80020f94 <log+0x34>
    8000415e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004160:	4390                	lw	a2,0(a5)
    80004162:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004164:	0791                	addi	a5,a5,4
    80004166:	0711                	addi	a4,a4,4
    80004168:	fed79ce3          	bne	a5,a3,80004160 <write_head+0x4e>
  }
  bwrite(buf);
    8000416c:	8526                	mv	a0,s1
    8000416e:	fffff097          	auipc	ra,0xfffff
    80004172:	09c080e7          	jalr	156(ra) # 8000320a <bwrite>
  brelse(buf);
    80004176:	8526                	mv	a0,s1
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	0d0080e7          	jalr	208(ra) # 80003248 <brelse>
}
    80004180:	60e2                	ld	ra,24(sp)
    80004182:	6442                	ld	s0,16(sp)
    80004184:	64a2                	ld	s1,8(sp)
    80004186:	6902                	ld	s2,0(sp)
    80004188:	6105                	addi	sp,sp,32
    8000418a:	8082                	ret

000000008000418c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000418c:	0001d797          	auipc	a5,0x1d
    80004190:	e007a783          	lw	a5,-512(a5) # 80020f8c <log+0x2c>
    80004194:	0af05d63          	blez	a5,8000424e <install_trans+0xc2>
{
    80004198:	7139                	addi	sp,sp,-64
    8000419a:	fc06                	sd	ra,56(sp)
    8000419c:	f822                	sd	s0,48(sp)
    8000419e:	f426                	sd	s1,40(sp)
    800041a0:	f04a                	sd	s2,32(sp)
    800041a2:	ec4e                	sd	s3,24(sp)
    800041a4:	e852                	sd	s4,16(sp)
    800041a6:	e456                	sd	s5,8(sp)
    800041a8:	e05a                	sd	s6,0(sp)
    800041aa:	0080                	addi	s0,sp,64
    800041ac:	8b2a                	mv	s6,a0
    800041ae:	0001da97          	auipc	s5,0x1d
    800041b2:	de2a8a93          	addi	s5,s5,-542 # 80020f90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041b8:	0001d997          	auipc	s3,0x1d
    800041bc:	da898993          	addi	s3,s3,-600 # 80020f60 <log>
    800041c0:	a00d                	j	800041e2 <install_trans+0x56>
    brelse(lbuf);
    800041c2:	854a                	mv	a0,s2
    800041c4:	fffff097          	auipc	ra,0xfffff
    800041c8:	084080e7          	jalr	132(ra) # 80003248 <brelse>
    brelse(dbuf);
    800041cc:	8526                	mv	a0,s1
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	07a080e7          	jalr	122(ra) # 80003248 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d6:	2a05                	addiw	s4,s4,1
    800041d8:	0a91                	addi	s5,s5,4
    800041da:	02c9a783          	lw	a5,44(s3)
    800041de:	04fa5e63          	bge	s4,a5,8000423a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041e2:	0189a583          	lw	a1,24(s3)
    800041e6:	014585bb          	addw	a1,a1,s4
    800041ea:	2585                	addiw	a1,a1,1
    800041ec:	0289a503          	lw	a0,40(s3)
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	f28080e7          	jalr	-216(ra) # 80003118 <bread>
    800041f8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041fa:	000aa583          	lw	a1,0(s5)
    800041fe:	0289a503          	lw	a0,40(s3)
    80004202:	fffff097          	auipc	ra,0xfffff
    80004206:	f16080e7          	jalr	-234(ra) # 80003118 <bread>
    8000420a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000420c:	40000613          	li	a2,1024
    80004210:	05890593          	addi	a1,s2,88
    80004214:	05850513          	addi	a0,a0,88
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	b16080e7          	jalr	-1258(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004220:	8526                	mv	a0,s1
    80004222:	fffff097          	auipc	ra,0xfffff
    80004226:	fe8080e7          	jalr	-24(ra) # 8000320a <bwrite>
    if(recovering == 0)
    8000422a:	f80b1ce3          	bnez	s6,800041c2 <install_trans+0x36>
      bunpin(dbuf);
    8000422e:	8526                	mv	a0,s1
    80004230:	fffff097          	auipc	ra,0xfffff
    80004234:	0f2080e7          	jalr	242(ra) # 80003322 <bunpin>
    80004238:	b769                	j	800041c2 <install_trans+0x36>
}
    8000423a:	70e2                	ld	ra,56(sp)
    8000423c:	7442                	ld	s0,48(sp)
    8000423e:	74a2                	ld	s1,40(sp)
    80004240:	7902                	ld	s2,32(sp)
    80004242:	69e2                	ld	s3,24(sp)
    80004244:	6a42                	ld	s4,16(sp)
    80004246:	6aa2                	ld	s5,8(sp)
    80004248:	6b02                	ld	s6,0(sp)
    8000424a:	6121                	addi	sp,sp,64
    8000424c:	8082                	ret
    8000424e:	8082                	ret

0000000080004250 <initlog>:
{
    80004250:	7179                	addi	sp,sp,-48
    80004252:	f406                	sd	ra,40(sp)
    80004254:	f022                	sd	s0,32(sp)
    80004256:	ec26                	sd	s1,24(sp)
    80004258:	e84a                	sd	s2,16(sp)
    8000425a:	e44e                	sd	s3,8(sp)
    8000425c:	1800                	addi	s0,sp,48
    8000425e:	892a                	mv	s2,a0
    80004260:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004262:	0001d497          	auipc	s1,0x1d
    80004266:	cfe48493          	addi	s1,s1,-770 # 80020f60 <log>
    8000426a:	00004597          	auipc	a1,0x4
    8000426e:	41e58593          	addi	a1,a1,1054 # 80008688 <syscalls+0x1e0>
    80004272:	8526                	mv	a0,s1
    80004274:	ffffd097          	auipc	ra,0xffffd
    80004278:	8d2080e7          	jalr	-1838(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000427c:	0149a583          	lw	a1,20(s3)
    80004280:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004282:	0109a783          	lw	a5,16(s3)
    80004286:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004288:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000428c:	854a                	mv	a0,s2
    8000428e:	fffff097          	auipc	ra,0xfffff
    80004292:	e8a080e7          	jalr	-374(ra) # 80003118 <bread>
  log.lh.n = lh->n;
    80004296:	4d34                	lw	a3,88(a0)
    80004298:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000429a:	02d05563          	blez	a3,800042c4 <initlog+0x74>
    8000429e:	05c50793          	addi	a5,a0,92
    800042a2:	0001d717          	auipc	a4,0x1d
    800042a6:	cee70713          	addi	a4,a4,-786 # 80020f90 <log+0x30>
    800042aa:	36fd                	addiw	a3,a3,-1
    800042ac:	1682                	slli	a3,a3,0x20
    800042ae:	9281                	srli	a3,a3,0x20
    800042b0:	068a                	slli	a3,a3,0x2
    800042b2:	06050613          	addi	a2,a0,96
    800042b6:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042b8:	4390                	lw	a2,0(a5)
    800042ba:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042bc:	0791                	addi	a5,a5,4
    800042be:	0711                	addi	a4,a4,4
    800042c0:	fed79ce3          	bne	a5,a3,800042b8 <initlog+0x68>
  brelse(buf);
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	f84080e7          	jalr	-124(ra) # 80003248 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042cc:	4505                	li	a0,1
    800042ce:	00000097          	auipc	ra,0x0
    800042d2:	ebe080e7          	jalr	-322(ra) # 8000418c <install_trans>
  log.lh.n = 0;
    800042d6:	0001d797          	auipc	a5,0x1d
    800042da:	ca07ab23          	sw	zero,-842(a5) # 80020f8c <log+0x2c>
  write_head(); // clear the log
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	e34080e7          	jalr	-460(ra) # 80004112 <write_head>
}
    800042e6:	70a2                	ld	ra,40(sp)
    800042e8:	7402                	ld	s0,32(sp)
    800042ea:	64e2                	ld	s1,24(sp)
    800042ec:	6942                	ld	s2,16(sp)
    800042ee:	69a2                	ld	s3,8(sp)
    800042f0:	6145                	addi	sp,sp,48
    800042f2:	8082                	ret

00000000800042f4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042f4:	1101                	addi	sp,sp,-32
    800042f6:	ec06                	sd	ra,24(sp)
    800042f8:	e822                	sd	s0,16(sp)
    800042fa:	e426                	sd	s1,8(sp)
    800042fc:	e04a                	sd	s2,0(sp)
    800042fe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004300:	0001d517          	auipc	a0,0x1d
    80004304:	c6050513          	addi	a0,a0,-928 # 80020f60 <log>
    80004308:	ffffd097          	auipc	ra,0xffffd
    8000430c:	8ce080e7          	jalr	-1842(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004310:	0001d497          	auipc	s1,0x1d
    80004314:	c5048493          	addi	s1,s1,-944 # 80020f60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004318:	4979                	li	s2,30
    8000431a:	a039                	j	80004328 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000431c:	85a6                	mv	a1,s1
    8000431e:	8526                	mv	a0,s1
    80004320:	ffffe097          	auipc	ra,0xffffe
    80004324:	e32080e7          	jalr	-462(ra) # 80002152 <sleep>
    if(log.committing){
    80004328:	50dc                	lw	a5,36(s1)
    8000432a:	fbed                	bnez	a5,8000431c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000432c:	509c                	lw	a5,32(s1)
    8000432e:	0017871b          	addiw	a4,a5,1
    80004332:	0007069b          	sext.w	a3,a4
    80004336:	0027179b          	slliw	a5,a4,0x2
    8000433a:	9fb9                	addw	a5,a5,a4
    8000433c:	0017979b          	slliw	a5,a5,0x1
    80004340:	54d8                	lw	a4,44(s1)
    80004342:	9fb9                	addw	a5,a5,a4
    80004344:	00f95963          	bge	s2,a5,80004356 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004348:	85a6                	mv	a1,s1
    8000434a:	8526                	mv	a0,s1
    8000434c:	ffffe097          	auipc	ra,0xffffe
    80004350:	e06080e7          	jalr	-506(ra) # 80002152 <sleep>
    80004354:	bfd1                	j	80004328 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004356:	0001d517          	auipc	a0,0x1d
    8000435a:	c0a50513          	addi	a0,a0,-1014 # 80020f60 <log>
    8000435e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004360:	ffffd097          	auipc	ra,0xffffd
    80004364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004368:	60e2                	ld	ra,24(sp)
    8000436a:	6442                	ld	s0,16(sp)
    8000436c:	64a2                	ld	s1,8(sp)
    8000436e:	6902                	ld	s2,0(sp)
    80004370:	6105                	addi	sp,sp,32
    80004372:	8082                	ret

0000000080004374 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004374:	7139                	addi	sp,sp,-64
    80004376:	fc06                	sd	ra,56(sp)
    80004378:	f822                	sd	s0,48(sp)
    8000437a:	f426                	sd	s1,40(sp)
    8000437c:	f04a                	sd	s2,32(sp)
    8000437e:	ec4e                	sd	s3,24(sp)
    80004380:	e852                	sd	s4,16(sp)
    80004382:	e456                	sd	s5,8(sp)
    80004384:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004386:	0001d497          	auipc	s1,0x1d
    8000438a:	bda48493          	addi	s1,s1,-1062 # 80020f60 <log>
    8000438e:	8526                	mv	a0,s1
    80004390:	ffffd097          	auipc	ra,0xffffd
    80004394:	846080e7          	jalr	-1978(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004398:	509c                	lw	a5,32(s1)
    8000439a:	37fd                	addiw	a5,a5,-1
    8000439c:	0007891b          	sext.w	s2,a5
    800043a0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043a2:	50dc                	lw	a5,36(s1)
    800043a4:	e7b9                	bnez	a5,800043f2 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043a6:	04091e63          	bnez	s2,80004402 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043aa:	0001d497          	auipc	s1,0x1d
    800043ae:	bb648493          	addi	s1,s1,-1098 # 80020f60 <log>
    800043b2:	4785                	li	a5,1
    800043b4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043b6:	8526                	mv	a0,s1
    800043b8:	ffffd097          	auipc	ra,0xffffd
    800043bc:	8d2080e7          	jalr	-1838(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043c0:	54dc                	lw	a5,44(s1)
    800043c2:	06f04763          	bgtz	a5,80004430 <end_op+0xbc>
    acquire(&log.lock);
    800043c6:	0001d497          	auipc	s1,0x1d
    800043ca:	b9a48493          	addi	s1,s1,-1126 # 80020f60 <log>
    800043ce:	8526                	mv	a0,s1
    800043d0:	ffffd097          	auipc	ra,0xffffd
    800043d4:	806080e7          	jalr	-2042(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800043d8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043dc:	8526                	mv	a0,s1
    800043de:	ffffe097          	auipc	ra,0xffffe
    800043e2:	dd8080e7          	jalr	-552(ra) # 800021b6 <wakeup>
    release(&log.lock);
    800043e6:	8526                	mv	a0,s1
    800043e8:	ffffd097          	auipc	ra,0xffffd
    800043ec:	8a2080e7          	jalr	-1886(ra) # 80000c8a <release>
}
    800043f0:	a03d                	j	8000441e <end_op+0xaa>
    panic("log.committing");
    800043f2:	00004517          	auipc	a0,0x4
    800043f6:	29e50513          	addi	a0,a0,670 # 80008690 <syscalls+0x1e8>
    800043fa:	ffffc097          	auipc	ra,0xffffc
    800043fe:	144080e7          	jalr	324(ra) # 8000053e <panic>
    wakeup(&log);
    80004402:	0001d497          	auipc	s1,0x1d
    80004406:	b5e48493          	addi	s1,s1,-1186 # 80020f60 <log>
    8000440a:	8526                	mv	a0,s1
    8000440c:	ffffe097          	auipc	ra,0xffffe
    80004410:	daa080e7          	jalr	-598(ra) # 800021b6 <wakeup>
  release(&log.lock);
    80004414:	8526                	mv	a0,s1
    80004416:	ffffd097          	auipc	ra,0xffffd
    8000441a:	874080e7          	jalr	-1932(ra) # 80000c8a <release>
}
    8000441e:	70e2                	ld	ra,56(sp)
    80004420:	7442                	ld	s0,48(sp)
    80004422:	74a2                	ld	s1,40(sp)
    80004424:	7902                	ld	s2,32(sp)
    80004426:	69e2                	ld	s3,24(sp)
    80004428:	6a42                	ld	s4,16(sp)
    8000442a:	6aa2                	ld	s5,8(sp)
    8000442c:	6121                	addi	sp,sp,64
    8000442e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004430:	0001da97          	auipc	s5,0x1d
    80004434:	b60a8a93          	addi	s5,s5,-1184 # 80020f90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004438:	0001da17          	auipc	s4,0x1d
    8000443c:	b28a0a13          	addi	s4,s4,-1240 # 80020f60 <log>
    80004440:	018a2583          	lw	a1,24(s4)
    80004444:	012585bb          	addw	a1,a1,s2
    80004448:	2585                	addiw	a1,a1,1
    8000444a:	028a2503          	lw	a0,40(s4)
    8000444e:	fffff097          	auipc	ra,0xfffff
    80004452:	cca080e7          	jalr	-822(ra) # 80003118 <bread>
    80004456:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004458:	000aa583          	lw	a1,0(s5)
    8000445c:	028a2503          	lw	a0,40(s4)
    80004460:	fffff097          	auipc	ra,0xfffff
    80004464:	cb8080e7          	jalr	-840(ra) # 80003118 <bread>
    80004468:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000446a:	40000613          	li	a2,1024
    8000446e:	05850593          	addi	a1,a0,88
    80004472:	05848513          	addi	a0,s1,88
    80004476:	ffffd097          	auipc	ra,0xffffd
    8000447a:	8b8080e7          	jalr	-1864(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000447e:	8526                	mv	a0,s1
    80004480:	fffff097          	auipc	ra,0xfffff
    80004484:	d8a080e7          	jalr	-630(ra) # 8000320a <bwrite>
    brelse(from);
    80004488:	854e                	mv	a0,s3
    8000448a:	fffff097          	auipc	ra,0xfffff
    8000448e:	dbe080e7          	jalr	-578(ra) # 80003248 <brelse>
    brelse(to);
    80004492:	8526                	mv	a0,s1
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	db4080e7          	jalr	-588(ra) # 80003248 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449c:	2905                	addiw	s2,s2,1
    8000449e:	0a91                	addi	s5,s5,4
    800044a0:	02ca2783          	lw	a5,44(s4)
    800044a4:	f8f94ee3          	blt	s2,a5,80004440 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	c6a080e7          	jalr	-918(ra) # 80004112 <write_head>
    install_trans(0); // Now install writes to home locations
    800044b0:	4501                	li	a0,0
    800044b2:	00000097          	auipc	ra,0x0
    800044b6:	cda080e7          	jalr	-806(ra) # 8000418c <install_trans>
    log.lh.n = 0;
    800044ba:	0001d797          	auipc	a5,0x1d
    800044be:	ac07a923          	sw	zero,-1326(a5) # 80020f8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044c2:	00000097          	auipc	ra,0x0
    800044c6:	c50080e7          	jalr	-944(ra) # 80004112 <write_head>
    800044ca:	bdf5                	j	800043c6 <end_op+0x52>

00000000800044cc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044cc:	1101                	addi	sp,sp,-32
    800044ce:	ec06                	sd	ra,24(sp)
    800044d0:	e822                	sd	s0,16(sp)
    800044d2:	e426                	sd	s1,8(sp)
    800044d4:	e04a                	sd	s2,0(sp)
    800044d6:	1000                	addi	s0,sp,32
    800044d8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044da:	0001d917          	auipc	s2,0x1d
    800044de:	a8690913          	addi	s2,s2,-1402 # 80020f60 <log>
    800044e2:	854a                	mv	a0,s2
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	6f2080e7          	jalr	1778(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044ec:	02c92603          	lw	a2,44(s2)
    800044f0:	47f5                	li	a5,29
    800044f2:	06c7c563          	blt	a5,a2,8000455c <log_write+0x90>
    800044f6:	0001d797          	auipc	a5,0x1d
    800044fa:	a867a783          	lw	a5,-1402(a5) # 80020f7c <log+0x1c>
    800044fe:	37fd                	addiw	a5,a5,-1
    80004500:	04f65e63          	bge	a2,a5,8000455c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004504:	0001d797          	auipc	a5,0x1d
    80004508:	a7c7a783          	lw	a5,-1412(a5) # 80020f80 <log+0x20>
    8000450c:	06f05063          	blez	a5,8000456c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004510:	4781                	li	a5,0
    80004512:	06c05563          	blez	a2,8000457c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004516:	44cc                	lw	a1,12(s1)
    80004518:	0001d717          	auipc	a4,0x1d
    8000451c:	a7870713          	addi	a4,a4,-1416 # 80020f90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004520:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004522:	4314                	lw	a3,0(a4)
    80004524:	04b68c63          	beq	a3,a1,8000457c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004528:	2785                	addiw	a5,a5,1
    8000452a:	0711                	addi	a4,a4,4
    8000452c:	fef61be3          	bne	a2,a5,80004522 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004530:	0621                	addi	a2,a2,8
    80004532:	060a                	slli	a2,a2,0x2
    80004534:	0001d797          	auipc	a5,0x1d
    80004538:	a2c78793          	addi	a5,a5,-1492 # 80020f60 <log>
    8000453c:	963e                	add	a2,a2,a5
    8000453e:	44dc                	lw	a5,12(s1)
    80004540:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004542:	8526                	mv	a0,s1
    80004544:	fffff097          	auipc	ra,0xfffff
    80004548:	da2080e7          	jalr	-606(ra) # 800032e6 <bpin>
    log.lh.n++;
    8000454c:	0001d717          	auipc	a4,0x1d
    80004550:	a1470713          	addi	a4,a4,-1516 # 80020f60 <log>
    80004554:	575c                	lw	a5,44(a4)
    80004556:	2785                	addiw	a5,a5,1
    80004558:	d75c                	sw	a5,44(a4)
    8000455a:	a835                	j	80004596 <log_write+0xca>
    panic("too big a transaction");
    8000455c:	00004517          	auipc	a0,0x4
    80004560:	14450513          	addi	a0,a0,324 # 800086a0 <syscalls+0x1f8>
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	fda080e7          	jalr	-38(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000456c:	00004517          	auipc	a0,0x4
    80004570:	14c50513          	addi	a0,a0,332 # 800086b8 <syscalls+0x210>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	fca080e7          	jalr	-54(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000457c:	00878713          	addi	a4,a5,8
    80004580:	00271693          	slli	a3,a4,0x2
    80004584:	0001d717          	auipc	a4,0x1d
    80004588:	9dc70713          	addi	a4,a4,-1572 # 80020f60 <log>
    8000458c:	9736                	add	a4,a4,a3
    8000458e:	44d4                	lw	a3,12(s1)
    80004590:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004592:	faf608e3          	beq	a2,a5,80004542 <log_write+0x76>
  }
  release(&log.lock);
    80004596:	0001d517          	auipc	a0,0x1d
    8000459a:	9ca50513          	addi	a0,a0,-1590 # 80020f60 <log>
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	6ec080e7          	jalr	1772(ra) # 80000c8a <release>
}
    800045a6:	60e2                	ld	ra,24(sp)
    800045a8:	6442                	ld	s0,16(sp)
    800045aa:	64a2                	ld	s1,8(sp)
    800045ac:	6902                	ld	s2,0(sp)
    800045ae:	6105                	addi	sp,sp,32
    800045b0:	8082                	ret

00000000800045b2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045b2:	1101                	addi	sp,sp,-32
    800045b4:	ec06                	sd	ra,24(sp)
    800045b6:	e822                	sd	s0,16(sp)
    800045b8:	e426                	sd	s1,8(sp)
    800045ba:	e04a                	sd	s2,0(sp)
    800045bc:	1000                	addi	s0,sp,32
    800045be:	84aa                	mv	s1,a0
    800045c0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045c2:	00004597          	auipc	a1,0x4
    800045c6:	11658593          	addi	a1,a1,278 # 800086d8 <syscalls+0x230>
    800045ca:	0521                	addi	a0,a0,8
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	57a080e7          	jalr	1402(ra) # 80000b46 <initlock>
  lk->name = name;
    800045d4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045d8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045dc:	0204a423          	sw	zero,40(s1)
}
    800045e0:	60e2                	ld	ra,24(sp)
    800045e2:	6442                	ld	s0,16(sp)
    800045e4:	64a2                	ld	s1,8(sp)
    800045e6:	6902                	ld	s2,0(sp)
    800045e8:	6105                	addi	sp,sp,32
    800045ea:	8082                	ret

00000000800045ec <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045ec:	1101                	addi	sp,sp,-32
    800045ee:	ec06                	sd	ra,24(sp)
    800045f0:	e822                	sd	s0,16(sp)
    800045f2:	e426                	sd	s1,8(sp)
    800045f4:	e04a                	sd	s2,0(sp)
    800045f6:	1000                	addi	s0,sp,32
    800045f8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045fa:	00850913          	addi	s2,a0,8
    800045fe:	854a                	mv	a0,s2
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004608:	409c                	lw	a5,0(s1)
    8000460a:	cb89                	beqz	a5,8000461c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000460c:	85ca                	mv	a1,s2
    8000460e:	8526                	mv	a0,s1
    80004610:	ffffe097          	auipc	ra,0xffffe
    80004614:	b42080e7          	jalr	-1214(ra) # 80002152 <sleep>
  while (lk->locked) {
    80004618:	409c                	lw	a5,0(s1)
    8000461a:	fbed                	bnez	a5,8000460c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000461c:	4785                	li	a5,1
    8000461e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004620:	ffffd097          	auipc	ra,0xffffd
    80004624:	3ac080e7          	jalr	940(ra) # 800019cc <myproc>
    80004628:	591c                	lw	a5,48(a0)
    8000462a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000462c:	854a                	mv	a0,s2
    8000462e:	ffffc097          	auipc	ra,0xffffc
    80004632:	65c080e7          	jalr	1628(ra) # 80000c8a <release>
}
    80004636:	60e2                	ld	ra,24(sp)
    80004638:	6442                	ld	s0,16(sp)
    8000463a:	64a2                	ld	s1,8(sp)
    8000463c:	6902                	ld	s2,0(sp)
    8000463e:	6105                	addi	sp,sp,32
    80004640:	8082                	ret

0000000080004642 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004642:	1101                	addi	sp,sp,-32
    80004644:	ec06                	sd	ra,24(sp)
    80004646:	e822                	sd	s0,16(sp)
    80004648:	e426                	sd	s1,8(sp)
    8000464a:	e04a                	sd	s2,0(sp)
    8000464c:	1000                	addi	s0,sp,32
    8000464e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004650:	00850913          	addi	s2,a0,8
    80004654:	854a                	mv	a0,s2
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	580080e7          	jalr	1408(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000465e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004662:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004666:	8526                	mv	a0,s1
    80004668:	ffffe097          	auipc	ra,0xffffe
    8000466c:	b4e080e7          	jalr	-1202(ra) # 800021b6 <wakeup>
  release(&lk->lk);
    80004670:	854a                	mv	a0,s2
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	618080e7          	jalr	1560(ra) # 80000c8a <release>
}
    8000467a:	60e2                	ld	ra,24(sp)
    8000467c:	6442                	ld	s0,16(sp)
    8000467e:	64a2                	ld	s1,8(sp)
    80004680:	6902                	ld	s2,0(sp)
    80004682:	6105                	addi	sp,sp,32
    80004684:	8082                	ret

0000000080004686 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004686:	7179                	addi	sp,sp,-48
    80004688:	f406                	sd	ra,40(sp)
    8000468a:	f022                	sd	s0,32(sp)
    8000468c:	ec26                	sd	s1,24(sp)
    8000468e:	e84a                	sd	s2,16(sp)
    80004690:	e44e                	sd	s3,8(sp)
    80004692:	1800                	addi	s0,sp,48
    80004694:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004696:	00850913          	addi	s2,a0,8
    8000469a:	854a                	mv	a0,s2
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	53a080e7          	jalr	1338(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046a4:	409c                	lw	a5,0(s1)
    800046a6:	ef99                	bnez	a5,800046c4 <holdingsleep+0x3e>
    800046a8:	4481                	li	s1,0
  release(&lk->lk);
    800046aa:	854a                	mv	a0,s2
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	5de080e7          	jalr	1502(ra) # 80000c8a <release>
  return r;
}
    800046b4:	8526                	mv	a0,s1
    800046b6:	70a2                	ld	ra,40(sp)
    800046b8:	7402                	ld	s0,32(sp)
    800046ba:	64e2                	ld	s1,24(sp)
    800046bc:	6942                	ld	s2,16(sp)
    800046be:	69a2                	ld	s3,8(sp)
    800046c0:	6145                	addi	sp,sp,48
    800046c2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046c4:	0284a983          	lw	s3,40(s1)
    800046c8:	ffffd097          	auipc	ra,0xffffd
    800046cc:	304080e7          	jalr	772(ra) # 800019cc <myproc>
    800046d0:	5904                	lw	s1,48(a0)
    800046d2:	413484b3          	sub	s1,s1,s3
    800046d6:	0014b493          	seqz	s1,s1
    800046da:	bfc1                	j	800046aa <holdingsleep+0x24>

00000000800046dc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046dc:	1141                	addi	sp,sp,-16
    800046de:	e406                	sd	ra,8(sp)
    800046e0:	e022                	sd	s0,0(sp)
    800046e2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046e4:	00004597          	auipc	a1,0x4
    800046e8:	00458593          	addi	a1,a1,4 # 800086e8 <syscalls+0x240>
    800046ec:	0001d517          	auipc	a0,0x1d
    800046f0:	9bc50513          	addi	a0,a0,-1604 # 800210a8 <ftable>
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	452080e7          	jalr	1106(ra) # 80000b46 <initlock>
}
    800046fc:	60a2                	ld	ra,8(sp)
    800046fe:	6402                	ld	s0,0(sp)
    80004700:	0141                	addi	sp,sp,16
    80004702:	8082                	ret

0000000080004704 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004704:	1101                	addi	sp,sp,-32
    80004706:	ec06                	sd	ra,24(sp)
    80004708:	e822                	sd	s0,16(sp)
    8000470a:	e426                	sd	s1,8(sp)
    8000470c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000470e:	0001d517          	auipc	a0,0x1d
    80004712:	99a50513          	addi	a0,a0,-1638 # 800210a8 <ftable>
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	4c0080e7          	jalr	1216(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000471e:	0001d497          	auipc	s1,0x1d
    80004722:	9a248493          	addi	s1,s1,-1630 # 800210c0 <ftable+0x18>
    80004726:	0001e717          	auipc	a4,0x1e
    8000472a:	93a70713          	addi	a4,a4,-1734 # 80022060 <disk>
    if(f->ref == 0){
    8000472e:	40dc                	lw	a5,4(s1)
    80004730:	cf99                	beqz	a5,8000474e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004732:	02848493          	addi	s1,s1,40
    80004736:	fee49ce3          	bne	s1,a4,8000472e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000473a:	0001d517          	auipc	a0,0x1d
    8000473e:	96e50513          	addi	a0,a0,-1682 # 800210a8 <ftable>
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	548080e7          	jalr	1352(ra) # 80000c8a <release>
  return 0;
    8000474a:	4481                	li	s1,0
    8000474c:	a819                	j	80004762 <filealloc+0x5e>
      f->ref = 1;
    8000474e:	4785                	li	a5,1
    80004750:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004752:	0001d517          	auipc	a0,0x1d
    80004756:	95650513          	addi	a0,a0,-1706 # 800210a8 <ftable>
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	530080e7          	jalr	1328(ra) # 80000c8a <release>
}
    80004762:	8526                	mv	a0,s1
    80004764:	60e2                	ld	ra,24(sp)
    80004766:	6442                	ld	s0,16(sp)
    80004768:	64a2                	ld	s1,8(sp)
    8000476a:	6105                	addi	sp,sp,32
    8000476c:	8082                	ret

000000008000476e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000476e:	1101                	addi	sp,sp,-32
    80004770:	ec06                	sd	ra,24(sp)
    80004772:	e822                	sd	s0,16(sp)
    80004774:	e426                	sd	s1,8(sp)
    80004776:	1000                	addi	s0,sp,32
    80004778:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000477a:	0001d517          	auipc	a0,0x1d
    8000477e:	92e50513          	addi	a0,a0,-1746 # 800210a8 <ftable>
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	454080e7          	jalr	1108(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000478a:	40dc                	lw	a5,4(s1)
    8000478c:	02f05263          	blez	a5,800047b0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004790:	2785                	addiw	a5,a5,1
    80004792:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004794:	0001d517          	auipc	a0,0x1d
    80004798:	91450513          	addi	a0,a0,-1772 # 800210a8 <ftable>
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	4ee080e7          	jalr	1262(ra) # 80000c8a <release>
  return f;
}
    800047a4:	8526                	mv	a0,s1
    800047a6:	60e2                	ld	ra,24(sp)
    800047a8:	6442                	ld	s0,16(sp)
    800047aa:	64a2                	ld	s1,8(sp)
    800047ac:	6105                	addi	sp,sp,32
    800047ae:	8082                	ret
    panic("filedup");
    800047b0:	00004517          	auipc	a0,0x4
    800047b4:	f4050513          	addi	a0,a0,-192 # 800086f0 <syscalls+0x248>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	d86080e7          	jalr	-634(ra) # 8000053e <panic>

00000000800047c0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047c0:	7139                	addi	sp,sp,-64
    800047c2:	fc06                	sd	ra,56(sp)
    800047c4:	f822                	sd	s0,48(sp)
    800047c6:	f426                	sd	s1,40(sp)
    800047c8:	f04a                	sd	s2,32(sp)
    800047ca:	ec4e                	sd	s3,24(sp)
    800047cc:	e852                	sd	s4,16(sp)
    800047ce:	e456                	sd	s5,8(sp)
    800047d0:	0080                	addi	s0,sp,64
    800047d2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047d4:	0001d517          	auipc	a0,0x1d
    800047d8:	8d450513          	addi	a0,a0,-1836 # 800210a8 <ftable>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	3fa080e7          	jalr	1018(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047e4:	40dc                	lw	a5,4(s1)
    800047e6:	06f05163          	blez	a5,80004848 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047ea:	37fd                	addiw	a5,a5,-1
    800047ec:	0007871b          	sext.w	a4,a5
    800047f0:	c0dc                	sw	a5,4(s1)
    800047f2:	06e04363          	bgtz	a4,80004858 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047f6:	0004a903          	lw	s2,0(s1)
    800047fa:	0094ca83          	lbu	s5,9(s1)
    800047fe:	0104ba03          	ld	s4,16(s1)
    80004802:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004806:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000480a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000480e:	0001d517          	auipc	a0,0x1d
    80004812:	89a50513          	addi	a0,a0,-1894 # 800210a8 <ftable>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	474080e7          	jalr	1140(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    8000481e:	4785                	li	a5,1
    80004820:	04f90d63          	beq	s2,a5,8000487a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004824:	3979                	addiw	s2,s2,-2
    80004826:	4785                	li	a5,1
    80004828:	0527e063          	bltu	a5,s2,80004868 <fileclose+0xa8>
    begin_op();
    8000482c:	00000097          	auipc	ra,0x0
    80004830:	ac8080e7          	jalr	-1336(ra) # 800042f4 <begin_op>
    iput(ff.ip);
    80004834:	854e                	mv	a0,s3
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	2b6080e7          	jalr	694(ra) # 80003aec <iput>
    end_op();
    8000483e:	00000097          	auipc	ra,0x0
    80004842:	b36080e7          	jalr	-1226(ra) # 80004374 <end_op>
    80004846:	a00d                	j	80004868 <fileclose+0xa8>
    panic("fileclose");
    80004848:	00004517          	auipc	a0,0x4
    8000484c:	eb050513          	addi	a0,a0,-336 # 800086f8 <syscalls+0x250>
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	cee080e7          	jalr	-786(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004858:	0001d517          	auipc	a0,0x1d
    8000485c:	85050513          	addi	a0,a0,-1968 # 800210a8 <ftable>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	42a080e7          	jalr	1066(ra) # 80000c8a <release>
  }
}
    80004868:	70e2                	ld	ra,56(sp)
    8000486a:	7442                	ld	s0,48(sp)
    8000486c:	74a2                	ld	s1,40(sp)
    8000486e:	7902                	ld	s2,32(sp)
    80004870:	69e2                	ld	s3,24(sp)
    80004872:	6a42                	ld	s4,16(sp)
    80004874:	6aa2                	ld	s5,8(sp)
    80004876:	6121                	addi	sp,sp,64
    80004878:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000487a:	85d6                	mv	a1,s5
    8000487c:	8552                	mv	a0,s4
    8000487e:	00000097          	auipc	ra,0x0
    80004882:	34c080e7          	jalr	844(ra) # 80004bca <pipeclose>
    80004886:	b7cd                	j	80004868 <fileclose+0xa8>

0000000080004888 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004888:	715d                	addi	sp,sp,-80
    8000488a:	e486                	sd	ra,72(sp)
    8000488c:	e0a2                	sd	s0,64(sp)
    8000488e:	fc26                	sd	s1,56(sp)
    80004890:	f84a                	sd	s2,48(sp)
    80004892:	f44e                	sd	s3,40(sp)
    80004894:	0880                	addi	s0,sp,80
    80004896:	84aa                	mv	s1,a0
    80004898:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000489a:	ffffd097          	auipc	ra,0xffffd
    8000489e:	132080e7          	jalr	306(ra) # 800019cc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048a2:	409c                	lw	a5,0(s1)
    800048a4:	37f9                	addiw	a5,a5,-2
    800048a6:	4705                	li	a4,1
    800048a8:	04f76763          	bltu	a4,a5,800048f6 <filestat+0x6e>
    800048ac:	892a                	mv	s2,a0
    ilock(f->ip);
    800048ae:	6c88                	ld	a0,24(s1)
    800048b0:	fffff097          	auipc	ra,0xfffff
    800048b4:	082080e7          	jalr	130(ra) # 80003932 <ilock>
    stati(f->ip, &st);
    800048b8:	fb840593          	addi	a1,s0,-72
    800048bc:	6c88                	ld	a0,24(s1)
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	2fe080e7          	jalr	766(ra) # 80003bbc <stati>
    iunlock(f->ip);
    800048c6:	6c88                	ld	a0,24(s1)
    800048c8:	fffff097          	auipc	ra,0xfffff
    800048cc:	12c080e7          	jalr	300(ra) # 800039f4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048d0:	46e1                	li	a3,24
    800048d2:	fb840613          	addi	a2,s0,-72
    800048d6:	85ce                	mv	a1,s3
    800048d8:	05093503          	ld	a0,80(s2)
    800048dc:	ffffd097          	auipc	ra,0xffffd
    800048e0:	dac080e7          	jalr	-596(ra) # 80001688 <copyout>
    800048e4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048e8:	60a6                	ld	ra,72(sp)
    800048ea:	6406                	ld	s0,64(sp)
    800048ec:	74e2                	ld	s1,56(sp)
    800048ee:	7942                	ld	s2,48(sp)
    800048f0:	79a2                	ld	s3,40(sp)
    800048f2:	6161                	addi	sp,sp,80
    800048f4:	8082                	ret
  return -1;
    800048f6:	557d                	li	a0,-1
    800048f8:	bfc5                	j	800048e8 <filestat+0x60>

00000000800048fa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048fa:	7179                	addi	sp,sp,-48
    800048fc:	f406                	sd	ra,40(sp)
    800048fe:	f022                	sd	s0,32(sp)
    80004900:	ec26                	sd	s1,24(sp)
    80004902:	e84a                	sd	s2,16(sp)
    80004904:	e44e                	sd	s3,8(sp)
    80004906:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004908:	00854783          	lbu	a5,8(a0)
    8000490c:	c3d5                	beqz	a5,800049b0 <fileread+0xb6>
    8000490e:	84aa                	mv	s1,a0
    80004910:	89ae                	mv	s3,a1
    80004912:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004914:	411c                	lw	a5,0(a0)
    80004916:	4705                	li	a4,1
    80004918:	04e78963          	beq	a5,a4,8000496a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000491c:	470d                	li	a4,3
    8000491e:	04e78d63          	beq	a5,a4,80004978 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004922:	4709                	li	a4,2
    80004924:	06e79e63          	bne	a5,a4,800049a0 <fileread+0xa6>
    ilock(f->ip);
    80004928:	6d08                	ld	a0,24(a0)
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	008080e7          	jalr	8(ra) # 80003932 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004932:	874a                	mv	a4,s2
    80004934:	5094                	lw	a3,32(s1)
    80004936:	864e                	mv	a2,s3
    80004938:	4585                	li	a1,1
    8000493a:	6c88                	ld	a0,24(s1)
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	2aa080e7          	jalr	682(ra) # 80003be6 <readi>
    80004944:	892a                	mv	s2,a0
    80004946:	00a05563          	blez	a0,80004950 <fileread+0x56>
      f->off += r;
    8000494a:	509c                	lw	a5,32(s1)
    8000494c:	9fa9                	addw	a5,a5,a0
    8000494e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004950:	6c88                	ld	a0,24(s1)
    80004952:	fffff097          	auipc	ra,0xfffff
    80004956:	0a2080e7          	jalr	162(ra) # 800039f4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000495a:	854a                	mv	a0,s2
    8000495c:	70a2                	ld	ra,40(sp)
    8000495e:	7402                	ld	s0,32(sp)
    80004960:	64e2                	ld	s1,24(sp)
    80004962:	6942                	ld	s2,16(sp)
    80004964:	69a2                	ld	s3,8(sp)
    80004966:	6145                	addi	sp,sp,48
    80004968:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000496a:	6908                	ld	a0,16(a0)
    8000496c:	00000097          	auipc	ra,0x0
    80004970:	3c6080e7          	jalr	966(ra) # 80004d32 <piperead>
    80004974:	892a                	mv	s2,a0
    80004976:	b7d5                	j	8000495a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004978:	02451783          	lh	a5,36(a0)
    8000497c:	03079693          	slli	a3,a5,0x30
    80004980:	92c1                	srli	a3,a3,0x30
    80004982:	4725                	li	a4,9
    80004984:	02d76863          	bltu	a4,a3,800049b4 <fileread+0xba>
    80004988:	0792                	slli	a5,a5,0x4
    8000498a:	0001c717          	auipc	a4,0x1c
    8000498e:	67e70713          	addi	a4,a4,1662 # 80021008 <devsw>
    80004992:	97ba                	add	a5,a5,a4
    80004994:	639c                	ld	a5,0(a5)
    80004996:	c38d                	beqz	a5,800049b8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004998:	4505                	li	a0,1
    8000499a:	9782                	jalr	a5
    8000499c:	892a                	mv	s2,a0
    8000499e:	bf75                	j	8000495a <fileread+0x60>
    panic("fileread");
    800049a0:	00004517          	auipc	a0,0x4
    800049a4:	d6850513          	addi	a0,a0,-664 # 80008708 <syscalls+0x260>
    800049a8:	ffffc097          	auipc	ra,0xffffc
    800049ac:	b96080e7          	jalr	-1130(ra) # 8000053e <panic>
    return -1;
    800049b0:	597d                	li	s2,-1
    800049b2:	b765                	j	8000495a <fileread+0x60>
      return -1;
    800049b4:	597d                	li	s2,-1
    800049b6:	b755                	j	8000495a <fileread+0x60>
    800049b8:	597d                	li	s2,-1
    800049ba:	b745                	j	8000495a <fileread+0x60>

00000000800049bc <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049bc:	715d                	addi	sp,sp,-80
    800049be:	e486                	sd	ra,72(sp)
    800049c0:	e0a2                	sd	s0,64(sp)
    800049c2:	fc26                	sd	s1,56(sp)
    800049c4:	f84a                	sd	s2,48(sp)
    800049c6:	f44e                	sd	s3,40(sp)
    800049c8:	f052                	sd	s4,32(sp)
    800049ca:	ec56                	sd	s5,24(sp)
    800049cc:	e85a                	sd	s6,16(sp)
    800049ce:	e45e                	sd	s7,8(sp)
    800049d0:	e062                	sd	s8,0(sp)
    800049d2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049d4:	00954783          	lbu	a5,9(a0)
    800049d8:	10078663          	beqz	a5,80004ae4 <filewrite+0x128>
    800049dc:	892a                	mv	s2,a0
    800049de:	8aae                	mv	s5,a1
    800049e0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049e2:	411c                	lw	a5,0(a0)
    800049e4:	4705                	li	a4,1
    800049e6:	02e78263          	beq	a5,a4,80004a0a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049ea:	470d                	li	a4,3
    800049ec:	02e78663          	beq	a5,a4,80004a18 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049f0:	4709                	li	a4,2
    800049f2:	0ee79163          	bne	a5,a4,80004ad4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049f6:	0ac05d63          	blez	a2,80004ab0 <filewrite+0xf4>
    int i = 0;
    800049fa:	4981                	li	s3,0
    800049fc:	6b05                	lui	s6,0x1
    800049fe:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a02:	6b85                	lui	s7,0x1
    80004a04:	c00b8b9b          	addiw	s7,s7,-1024
    80004a08:	a861                	j	80004aa0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a0a:	6908                	ld	a0,16(a0)
    80004a0c:	00000097          	auipc	ra,0x0
    80004a10:	22e080e7          	jalr	558(ra) # 80004c3a <pipewrite>
    80004a14:	8a2a                	mv	s4,a0
    80004a16:	a045                	j	80004ab6 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a18:	02451783          	lh	a5,36(a0)
    80004a1c:	03079693          	slli	a3,a5,0x30
    80004a20:	92c1                	srli	a3,a3,0x30
    80004a22:	4725                	li	a4,9
    80004a24:	0cd76263          	bltu	a4,a3,80004ae8 <filewrite+0x12c>
    80004a28:	0792                	slli	a5,a5,0x4
    80004a2a:	0001c717          	auipc	a4,0x1c
    80004a2e:	5de70713          	addi	a4,a4,1502 # 80021008 <devsw>
    80004a32:	97ba                	add	a5,a5,a4
    80004a34:	679c                	ld	a5,8(a5)
    80004a36:	cbdd                	beqz	a5,80004aec <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a38:	4505                	li	a0,1
    80004a3a:	9782                	jalr	a5
    80004a3c:	8a2a                	mv	s4,a0
    80004a3e:	a8a5                	j	80004ab6 <filewrite+0xfa>
    80004a40:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a44:	00000097          	auipc	ra,0x0
    80004a48:	8b0080e7          	jalr	-1872(ra) # 800042f4 <begin_op>
      ilock(f->ip);
    80004a4c:	01893503          	ld	a0,24(s2)
    80004a50:	fffff097          	auipc	ra,0xfffff
    80004a54:	ee2080e7          	jalr	-286(ra) # 80003932 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a58:	8762                	mv	a4,s8
    80004a5a:	02092683          	lw	a3,32(s2)
    80004a5e:	01598633          	add	a2,s3,s5
    80004a62:	4585                	li	a1,1
    80004a64:	01893503          	ld	a0,24(s2)
    80004a68:	fffff097          	auipc	ra,0xfffff
    80004a6c:	276080e7          	jalr	630(ra) # 80003cde <writei>
    80004a70:	84aa                	mv	s1,a0
    80004a72:	00a05763          	blez	a0,80004a80 <filewrite+0xc4>
        f->off += r;
    80004a76:	02092783          	lw	a5,32(s2)
    80004a7a:	9fa9                	addw	a5,a5,a0
    80004a7c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a80:	01893503          	ld	a0,24(s2)
    80004a84:	fffff097          	auipc	ra,0xfffff
    80004a88:	f70080e7          	jalr	-144(ra) # 800039f4 <iunlock>
      end_op();
    80004a8c:	00000097          	auipc	ra,0x0
    80004a90:	8e8080e7          	jalr	-1816(ra) # 80004374 <end_op>

      if(r != n1){
    80004a94:	009c1f63          	bne	s8,s1,80004ab2 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a98:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a9c:	0149db63          	bge	s3,s4,80004ab2 <filewrite+0xf6>
      int n1 = n - i;
    80004aa0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004aa4:	84be                	mv	s1,a5
    80004aa6:	2781                	sext.w	a5,a5
    80004aa8:	f8fb5ce3          	bge	s6,a5,80004a40 <filewrite+0x84>
    80004aac:	84de                	mv	s1,s7
    80004aae:	bf49                	j	80004a40 <filewrite+0x84>
    int i = 0;
    80004ab0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004ab2:	013a1f63          	bne	s4,s3,80004ad0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab6:	8552                	mv	a0,s4
    80004ab8:	60a6                	ld	ra,72(sp)
    80004aba:	6406                	ld	s0,64(sp)
    80004abc:	74e2                	ld	s1,56(sp)
    80004abe:	7942                	ld	s2,48(sp)
    80004ac0:	79a2                	ld	s3,40(sp)
    80004ac2:	7a02                	ld	s4,32(sp)
    80004ac4:	6ae2                	ld	s5,24(sp)
    80004ac6:	6b42                	ld	s6,16(sp)
    80004ac8:	6ba2                	ld	s7,8(sp)
    80004aca:	6c02                	ld	s8,0(sp)
    80004acc:	6161                	addi	sp,sp,80
    80004ace:	8082                	ret
    ret = (i == n ? n : -1);
    80004ad0:	5a7d                	li	s4,-1
    80004ad2:	b7d5                	j	80004ab6 <filewrite+0xfa>
    panic("filewrite");
    80004ad4:	00004517          	auipc	a0,0x4
    80004ad8:	c4450513          	addi	a0,a0,-956 # 80008718 <syscalls+0x270>
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	a62080e7          	jalr	-1438(ra) # 8000053e <panic>
    return -1;
    80004ae4:	5a7d                	li	s4,-1
    80004ae6:	bfc1                	j	80004ab6 <filewrite+0xfa>
      return -1;
    80004ae8:	5a7d                	li	s4,-1
    80004aea:	b7f1                	j	80004ab6 <filewrite+0xfa>
    80004aec:	5a7d                	li	s4,-1
    80004aee:	b7e1                	j	80004ab6 <filewrite+0xfa>

0000000080004af0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004af0:	7179                	addi	sp,sp,-48
    80004af2:	f406                	sd	ra,40(sp)
    80004af4:	f022                	sd	s0,32(sp)
    80004af6:	ec26                	sd	s1,24(sp)
    80004af8:	e84a                	sd	s2,16(sp)
    80004afa:	e44e                	sd	s3,8(sp)
    80004afc:	e052                	sd	s4,0(sp)
    80004afe:	1800                	addi	s0,sp,48
    80004b00:	84aa                	mv	s1,a0
    80004b02:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b04:	0005b023          	sd	zero,0(a1)
    80004b08:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b0c:	00000097          	auipc	ra,0x0
    80004b10:	bf8080e7          	jalr	-1032(ra) # 80004704 <filealloc>
    80004b14:	e088                	sd	a0,0(s1)
    80004b16:	c551                	beqz	a0,80004ba2 <pipealloc+0xb2>
    80004b18:	00000097          	auipc	ra,0x0
    80004b1c:	bec080e7          	jalr	-1044(ra) # 80004704 <filealloc>
    80004b20:	00aa3023          	sd	a0,0(s4)
    80004b24:	c92d                	beqz	a0,80004b96 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	fc0080e7          	jalr	-64(ra) # 80000ae6 <kalloc>
    80004b2e:	892a                	mv	s2,a0
    80004b30:	c125                	beqz	a0,80004b90 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b32:	4985                	li	s3,1
    80004b34:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b38:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b3c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b40:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b44:	00004597          	auipc	a1,0x4
    80004b48:	be458593          	addi	a1,a1,-1052 # 80008728 <syscalls+0x280>
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	ffa080e7          	jalr	-6(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b54:	609c                	ld	a5,0(s1)
    80004b56:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b5a:	609c                	ld	a5,0(s1)
    80004b5c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b60:	609c                	ld	a5,0(s1)
    80004b62:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b66:	609c                	ld	a5,0(s1)
    80004b68:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b6c:	000a3783          	ld	a5,0(s4)
    80004b70:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b74:	000a3783          	ld	a5,0(s4)
    80004b78:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b7c:	000a3783          	ld	a5,0(s4)
    80004b80:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b84:	000a3783          	ld	a5,0(s4)
    80004b88:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b8c:	4501                	li	a0,0
    80004b8e:	a025                	j	80004bb6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b90:	6088                	ld	a0,0(s1)
    80004b92:	e501                	bnez	a0,80004b9a <pipealloc+0xaa>
    80004b94:	a039                	j	80004ba2 <pipealloc+0xb2>
    80004b96:	6088                	ld	a0,0(s1)
    80004b98:	c51d                	beqz	a0,80004bc6 <pipealloc+0xd6>
    fileclose(*f0);
    80004b9a:	00000097          	auipc	ra,0x0
    80004b9e:	c26080e7          	jalr	-986(ra) # 800047c0 <fileclose>
  if(*f1)
    80004ba2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ba6:	557d                	li	a0,-1
  if(*f1)
    80004ba8:	c799                	beqz	a5,80004bb6 <pipealloc+0xc6>
    fileclose(*f1);
    80004baa:	853e                	mv	a0,a5
    80004bac:	00000097          	auipc	ra,0x0
    80004bb0:	c14080e7          	jalr	-1004(ra) # 800047c0 <fileclose>
  return -1;
    80004bb4:	557d                	li	a0,-1
}
    80004bb6:	70a2                	ld	ra,40(sp)
    80004bb8:	7402                	ld	s0,32(sp)
    80004bba:	64e2                	ld	s1,24(sp)
    80004bbc:	6942                	ld	s2,16(sp)
    80004bbe:	69a2                	ld	s3,8(sp)
    80004bc0:	6a02                	ld	s4,0(sp)
    80004bc2:	6145                	addi	sp,sp,48
    80004bc4:	8082                	ret
  return -1;
    80004bc6:	557d                	li	a0,-1
    80004bc8:	b7fd                	j	80004bb6 <pipealloc+0xc6>

0000000080004bca <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bca:	1101                	addi	sp,sp,-32
    80004bcc:	ec06                	sd	ra,24(sp)
    80004bce:	e822                	sd	s0,16(sp)
    80004bd0:	e426                	sd	s1,8(sp)
    80004bd2:	e04a                	sd	s2,0(sp)
    80004bd4:	1000                	addi	s0,sp,32
    80004bd6:	84aa                	mv	s1,a0
    80004bd8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	ffc080e7          	jalr	-4(ra) # 80000bd6 <acquire>
  if(writable){
    80004be2:	02090d63          	beqz	s2,80004c1c <pipeclose+0x52>
    pi->writeopen = 0;
    80004be6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bea:	21848513          	addi	a0,s1,536
    80004bee:	ffffd097          	auipc	ra,0xffffd
    80004bf2:	5c8080e7          	jalr	1480(ra) # 800021b6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bf6:	2204b783          	ld	a5,544(s1)
    80004bfa:	eb95                	bnez	a5,80004c2e <pipeclose+0x64>
    release(&pi->lock);
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	08c080e7          	jalr	140(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c06:	8526                	mv	a0,s1
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	de2080e7          	jalr	-542(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c10:	60e2                	ld	ra,24(sp)
    80004c12:	6442                	ld	s0,16(sp)
    80004c14:	64a2                	ld	s1,8(sp)
    80004c16:	6902                	ld	s2,0(sp)
    80004c18:	6105                	addi	sp,sp,32
    80004c1a:	8082                	ret
    pi->readopen = 0;
    80004c1c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c20:	21c48513          	addi	a0,s1,540
    80004c24:	ffffd097          	auipc	ra,0xffffd
    80004c28:	592080e7          	jalr	1426(ra) # 800021b6 <wakeup>
    80004c2c:	b7e9                	j	80004bf6 <pipeclose+0x2c>
    release(&pi->lock);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	05a080e7          	jalr	90(ra) # 80000c8a <release>
}
    80004c38:	bfe1                	j	80004c10 <pipeclose+0x46>

0000000080004c3a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c3a:	711d                	addi	sp,sp,-96
    80004c3c:	ec86                	sd	ra,88(sp)
    80004c3e:	e8a2                	sd	s0,80(sp)
    80004c40:	e4a6                	sd	s1,72(sp)
    80004c42:	e0ca                	sd	s2,64(sp)
    80004c44:	fc4e                	sd	s3,56(sp)
    80004c46:	f852                	sd	s4,48(sp)
    80004c48:	f456                	sd	s5,40(sp)
    80004c4a:	f05a                	sd	s6,32(sp)
    80004c4c:	ec5e                	sd	s7,24(sp)
    80004c4e:	e862                	sd	s8,16(sp)
    80004c50:	1080                	addi	s0,sp,96
    80004c52:	84aa                	mv	s1,a0
    80004c54:	8aae                	mv	s5,a1
    80004c56:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c58:	ffffd097          	auipc	ra,0xffffd
    80004c5c:	d74080e7          	jalr	-652(ra) # 800019cc <myproc>
    80004c60:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c62:	8526                	mv	a0,s1
    80004c64:	ffffc097          	auipc	ra,0xffffc
    80004c68:	f72080e7          	jalr	-142(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c6c:	0b405663          	blez	s4,80004d18 <pipewrite+0xde>
  int i = 0;
    80004c70:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c72:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c74:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c78:	21c48b93          	addi	s7,s1,540
    80004c7c:	a089                	j	80004cbe <pipewrite+0x84>
      release(&pi->lock);
    80004c7e:	8526                	mv	a0,s1
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
      return -1;
    80004c88:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c8a:	854a                	mv	a0,s2
    80004c8c:	60e6                	ld	ra,88(sp)
    80004c8e:	6446                	ld	s0,80(sp)
    80004c90:	64a6                	ld	s1,72(sp)
    80004c92:	6906                	ld	s2,64(sp)
    80004c94:	79e2                	ld	s3,56(sp)
    80004c96:	7a42                	ld	s4,48(sp)
    80004c98:	7aa2                	ld	s5,40(sp)
    80004c9a:	7b02                	ld	s6,32(sp)
    80004c9c:	6be2                	ld	s7,24(sp)
    80004c9e:	6c42                	ld	s8,16(sp)
    80004ca0:	6125                	addi	sp,sp,96
    80004ca2:	8082                	ret
      wakeup(&pi->nread);
    80004ca4:	8562                	mv	a0,s8
    80004ca6:	ffffd097          	auipc	ra,0xffffd
    80004caa:	510080e7          	jalr	1296(ra) # 800021b6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cae:	85a6                	mv	a1,s1
    80004cb0:	855e                	mv	a0,s7
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	4a0080e7          	jalr	1184(ra) # 80002152 <sleep>
  while(i < n){
    80004cba:	07495063          	bge	s2,s4,80004d1a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004cbe:	2204a783          	lw	a5,544(s1)
    80004cc2:	dfd5                	beqz	a5,80004c7e <pipewrite+0x44>
    80004cc4:	854e                	mv	a0,s3
    80004cc6:	ffffd097          	auipc	ra,0xffffd
    80004cca:	740080e7          	jalr	1856(ra) # 80002406 <killed>
    80004cce:	f945                	bnez	a0,80004c7e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cd0:	2184a783          	lw	a5,536(s1)
    80004cd4:	21c4a703          	lw	a4,540(s1)
    80004cd8:	2007879b          	addiw	a5,a5,512
    80004cdc:	fcf704e3          	beq	a4,a5,80004ca4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ce0:	4685                	li	a3,1
    80004ce2:	01590633          	add	a2,s2,s5
    80004ce6:	faf40593          	addi	a1,s0,-81
    80004cea:	0509b503          	ld	a0,80(s3)
    80004cee:	ffffd097          	auipc	ra,0xffffd
    80004cf2:	a26080e7          	jalr	-1498(ra) # 80001714 <copyin>
    80004cf6:	03650263          	beq	a0,s6,80004d1a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cfa:	21c4a783          	lw	a5,540(s1)
    80004cfe:	0017871b          	addiw	a4,a5,1
    80004d02:	20e4ae23          	sw	a4,540(s1)
    80004d06:	1ff7f793          	andi	a5,a5,511
    80004d0a:	97a6                	add	a5,a5,s1
    80004d0c:	faf44703          	lbu	a4,-81(s0)
    80004d10:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d14:	2905                	addiw	s2,s2,1
    80004d16:	b755                	j	80004cba <pipewrite+0x80>
  int i = 0;
    80004d18:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d1a:	21848513          	addi	a0,s1,536
    80004d1e:	ffffd097          	auipc	ra,0xffffd
    80004d22:	498080e7          	jalr	1176(ra) # 800021b6 <wakeup>
  release(&pi->lock);
    80004d26:	8526                	mv	a0,s1
    80004d28:	ffffc097          	auipc	ra,0xffffc
    80004d2c:	f62080e7          	jalr	-158(ra) # 80000c8a <release>
  return i;
    80004d30:	bfa9                	j	80004c8a <pipewrite+0x50>

0000000080004d32 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d32:	715d                	addi	sp,sp,-80
    80004d34:	e486                	sd	ra,72(sp)
    80004d36:	e0a2                	sd	s0,64(sp)
    80004d38:	fc26                	sd	s1,56(sp)
    80004d3a:	f84a                	sd	s2,48(sp)
    80004d3c:	f44e                	sd	s3,40(sp)
    80004d3e:	f052                	sd	s4,32(sp)
    80004d40:	ec56                	sd	s5,24(sp)
    80004d42:	e85a                	sd	s6,16(sp)
    80004d44:	0880                	addi	s0,sp,80
    80004d46:	84aa                	mv	s1,a0
    80004d48:	892e                	mv	s2,a1
    80004d4a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d4c:	ffffd097          	auipc	ra,0xffffd
    80004d50:	c80080e7          	jalr	-896(ra) # 800019cc <myproc>
    80004d54:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d56:	8526                	mv	a0,s1
    80004d58:	ffffc097          	auipc	ra,0xffffc
    80004d5c:	e7e080e7          	jalr	-386(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d60:	2184a703          	lw	a4,536(s1)
    80004d64:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d68:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d6c:	02f71763          	bne	a4,a5,80004d9a <piperead+0x68>
    80004d70:	2244a783          	lw	a5,548(s1)
    80004d74:	c39d                	beqz	a5,80004d9a <piperead+0x68>
    if(killed(pr)){
    80004d76:	8552                	mv	a0,s4
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	68e080e7          	jalr	1678(ra) # 80002406 <killed>
    80004d80:	e941                	bnez	a0,80004e10 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d82:	85a6                	mv	a1,s1
    80004d84:	854e                	mv	a0,s3
    80004d86:	ffffd097          	auipc	ra,0xffffd
    80004d8a:	3cc080e7          	jalr	972(ra) # 80002152 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d8e:	2184a703          	lw	a4,536(s1)
    80004d92:	21c4a783          	lw	a5,540(s1)
    80004d96:	fcf70de3          	beq	a4,a5,80004d70 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d9a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d9c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d9e:	05505363          	blez	s5,80004de4 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004da2:	2184a783          	lw	a5,536(s1)
    80004da6:	21c4a703          	lw	a4,540(s1)
    80004daa:	02f70d63          	beq	a4,a5,80004de4 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dae:	0017871b          	addiw	a4,a5,1
    80004db2:	20e4ac23          	sw	a4,536(s1)
    80004db6:	1ff7f793          	andi	a5,a5,511
    80004dba:	97a6                	add	a5,a5,s1
    80004dbc:	0187c783          	lbu	a5,24(a5)
    80004dc0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dc4:	4685                	li	a3,1
    80004dc6:	fbf40613          	addi	a2,s0,-65
    80004dca:	85ca                	mv	a1,s2
    80004dcc:	050a3503          	ld	a0,80(s4)
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	8b8080e7          	jalr	-1864(ra) # 80001688 <copyout>
    80004dd8:	01650663          	beq	a0,s6,80004de4 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ddc:	2985                	addiw	s3,s3,1
    80004dde:	0905                	addi	s2,s2,1
    80004de0:	fd3a91e3          	bne	s5,s3,80004da2 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004de4:	21c48513          	addi	a0,s1,540
    80004de8:	ffffd097          	auipc	ra,0xffffd
    80004dec:	3ce080e7          	jalr	974(ra) # 800021b6 <wakeup>
  release(&pi->lock);
    80004df0:	8526                	mv	a0,s1
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	e98080e7          	jalr	-360(ra) # 80000c8a <release>
  return i;
}
    80004dfa:	854e                	mv	a0,s3
    80004dfc:	60a6                	ld	ra,72(sp)
    80004dfe:	6406                	ld	s0,64(sp)
    80004e00:	74e2                	ld	s1,56(sp)
    80004e02:	7942                	ld	s2,48(sp)
    80004e04:	79a2                	ld	s3,40(sp)
    80004e06:	7a02                	ld	s4,32(sp)
    80004e08:	6ae2                	ld	s5,24(sp)
    80004e0a:	6b42                	ld	s6,16(sp)
    80004e0c:	6161                	addi	sp,sp,80
    80004e0e:	8082                	ret
      release(&pi->lock);
    80004e10:	8526                	mv	a0,s1
    80004e12:	ffffc097          	auipc	ra,0xffffc
    80004e16:	e78080e7          	jalr	-392(ra) # 80000c8a <release>
      return -1;
    80004e1a:	59fd                	li	s3,-1
    80004e1c:	bff9                	j	80004dfa <piperead+0xc8>

0000000080004e1e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e1e:	1141                	addi	sp,sp,-16
    80004e20:	e422                	sd	s0,8(sp)
    80004e22:	0800                	addi	s0,sp,16
    80004e24:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e26:	8905                	andi	a0,a0,1
    80004e28:	c111                	beqz	a0,80004e2c <flags2perm+0xe>
      perm = PTE_X;
    80004e2a:	4521                	li	a0,8
    if(flags & 0x2)
    80004e2c:	8b89                	andi	a5,a5,2
    80004e2e:	c399                	beqz	a5,80004e34 <flags2perm+0x16>
      perm |= PTE_W;
    80004e30:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e34:	6422                	ld	s0,8(sp)
    80004e36:	0141                	addi	sp,sp,16
    80004e38:	8082                	ret

0000000080004e3a <exec>:

int
exec(char *path, char **argv)
{
    80004e3a:	de010113          	addi	sp,sp,-544
    80004e3e:	20113c23          	sd	ra,536(sp)
    80004e42:	20813823          	sd	s0,528(sp)
    80004e46:	20913423          	sd	s1,520(sp)
    80004e4a:	21213023          	sd	s2,512(sp)
    80004e4e:	ffce                	sd	s3,504(sp)
    80004e50:	fbd2                	sd	s4,496(sp)
    80004e52:	f7d6                	sd	s5,488(sp)
    80004e54:	f3da                	sd	s6,480(sp)
    80004e56:	efde                	sd	s7,472(sp)
    80004e58:	ebe2                	sd	s8,464(sp)
    80004e5a:	e7e6                	sd	s9,456(sp)
    80004e5c:	e3ea                	sd	s10,448(sp)
    80004e5e:	ff6e                	sd	s11,440(sp)
    80004e60:	1400                	addi	s0,sp,544
    80004e62:	892a                	mv	s2,a0
    80004e64:	dea43423          	sd	a0,-536(s0)
    80004e68:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	b60080e7          	jalr	-1184(ra) # 800019cc <myproc>
    80004e74:	84aa                	mv	s1,a0

  begin_op();
    80004e76:	fffff097          	auipc	ra,0xfffff
    80004e7a:	47e080e7          	jalr	1150(ra) # 800042f4 <begin_op>

  if((ip = namei(path)) == 0){
    80004e7e:	854a                	mv	a0,s2
    80004e80:	fffff097          	auipc	ra,0xfffff
    80004e84:	258080e7          	jalr	600(ra) # 800040d8 <namei>
    80004e88:	c93d                	beqz	a0,80004efe <exec+0xc4>
    80004e8a:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e8c:	fffff097          	auipc	ra,0xfffff
    80004e90:	aa6080e7          	jalr	-1370(ra) # 80003932 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e94:	04000713          	li	a4,64
    80004e98:	4681                	li	a3,0
    80004e9a:	e5040613          	addi	a2,s0,-432
    80004e9e:	4581                	li	a1,0
    80004ea0:	8556                	mv	a0,s5
    80004ea2:	fffff097          	auipc	ra,0xfffff
    80004ea6:	d44080e7          	jalr	-700(ra) # 80003be6 <readi>
    80004eaa:	04000793          	li	a5,64
    80004eae:	00f51a63          	bne	a0,a5,80004ec2 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004eb2:	e5042703          	lw	a4,-432(s0)
    80004eb6:	464c47b7          	lui	a5,0x464c4
    80004eba:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ebe:	04f70663          	beq	a4,a5,80004f0a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ec2:	8556                	mv	a0,s5
    80004ec4:	fffff097          	auipc	ra,0xfffff
    80004ec8:	cd0080e7          	jalr	-816(ra) # 80003b94 <iunlockput>
    end_op();
    80004ecc:	fffff097          	auipc	ra,0xfffff
    80004ed0:	4a8080e7          	jalr	1192(ra) # 80004374 <end_op>
  }
  return -1;
    80004ed4:	557d                	li	a0,-1
}
    80004ed6:	21813083          	ld	ra,536(sp)
    80004eda:	21013403          	ld	s0,528(sp)
    80004ede:	20813483          	ld	s1,520(sp)
    80004ee2:	20013903          	ld	s2,512(sp)
    80004ee6:	79fe                	ld	s3,504(sp)
    80004ee8:	7a5e                	ld	s4,496(sp)
    80004eea:	7abe                	ld	s5,488(sp)
    80004eec:	7b1e                	ld	s6,480(sp)
    80004eee:	6bfe                	ld	s7,472(sp)
    80004ef0:	6c5e                	ld	s8,464(sp)
    80004ef2:	6cbe                	ld	s9,456(sp)
    80004ef4:	6d1e                	ld	s10,448(sp)
    80004ef6:	7dfa                	ld	s11,440(sp)
    80004ef8:	22010113          	addi	sp,sp,544
    80004efc:	8082                	ret
    end_op();
    80004efe:	fffff097          	auipc	ra,0xfffff
    80004f02:	476080e7          	jalr	1142(ra) # 80004374 <end_op>
    return -1;
    80004f06:	557d                	li	a0,-1
    80004f08:	b7f9                	j	80004ed6 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	b84080e7          	jalr	-1148(ra) # 80001a90 <proc_pagetable>
    80004f14:	8b2a                	mv	s6,a0
    80004f16:	d555                	beqz	a0,80004ec2 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f18:	e7042783          	lw	a5,-400(s0)
    80004f1c:	e8845703          	lhu	a4,-376(s0)
    80004f20:	c735                	beqz	a4,80004f8c <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f22:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f24:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f28:	6a05                	lui	s4,0x1
    80004f2a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f2e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f32:	6d85                	lui	s11,0x1
    80004f34:	7d7d                	lui	s10,0xfffff
    80004f36:	a481                	j	80005176 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f38:	00003517          	auipc	a0,0x3
    80004f3c:	7f850513          	addi	a0,a0,2040 # 80008730 <syscalls+0x288>
    80004f40:	ffffb097          	auipc	ra,0xffffb
    80004f44:	5fe080e7          	jalr	1534(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f48:	874a                	mv	a4,s2
    80004f4a:	009c86bb          	addw	a3,s9,s1
    80004f4e:	4581                	li	a1,0
    80004f50:	8556                	mv	a0,s5
    80004f52:	fffff097          	auipc	ra,0xfffff
    80004f56:	c94080e7          	jalr	-876(ra) # 80003be6 <readi>
    80004f5a:	2501                	sext.w	a0,a0
    80004f5c:	1aa91a63          	bne	s2,a0,80005110 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004f60:	009d84bb          	addw	s1,s11,s1
    80004f64:	013d09bb          	addw	s3,s10,s3
    80004f68:	1f74f763          	bgeu	s1,s7,80005156 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004f6c:	02049593          	slli	a1,s1,0x20
    80004f70:	9181                	srli	a1,a1,0x20
    80004f72:	95e2                	add	a1,a1,s8
    80004f74:	855a                	mv	a0,s6
    80004f76:	ffffc097          	auipc	ra,0xffffc
    80004f7a:	106080e7          	jalr	262(ra) # 8000107c <walkaddr>
    80004f7e:	862a                	mv	a2,a0
    if(pa == 0)
    80004f80:	dd45                	beqz	a0,80004f38 <exec+0xfe>
      n = PGSIZE;
    80004f82:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f84:	fd49f2e3          	bgeu	s3,s4,80004f48 <exec+0x10e>
      n = sz - i;
    80004f88:	894e                	mv	s2,s3
    80004f8a:	bf7d                	j	80004f48 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f8c:	4901                	li	s2,0
  iunlockput(ip);
    80004f8e:	8556                	mv	a0,s5
    80004f90:	fffff097          	auipc	ra,0xfffff
    80004f94:	c04080e7          	jalr	-1020(ra) # 80003b94 <iunlockput>
  end_op();
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	3dc080e7          	jalr	988(ra) # 80004374 <end_op>
  p = myproc();
    80004fa0:	ffffd097          	auipc	ra,0xffffd
    80004fa4:	a2c080e7          	jalr	-1492(ra) # 800019cc <myproc>
    80004fa8:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004faa:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fae:	6785                	lui	a5,0x1
    80004fb0:	17fd                	addi	a5,a5,-1
    80004fb2:	993e                	add	s2,s2,a5
    80004fb4:	77fd                	lui	a5,0xfffff
    80004fb6:	00f977b3          	and	a5,s2,a5
    80004fba:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fbe:	4691                	li	a3,4
    80004fc0:	6609                	lui	a2,0x2
    80004fc2:	963e                	add	a2,a2,a5
    80004fc4:	85be                	mv	a1,a5
    80004fc6:	855a                	mv	a0,s6
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	468080e7          	jalr	1128(ra) # 80001430 <uvmalloc>
    80004fd0:	8c2a                	mv	s8,a0
  ip = 0;
    80004fd2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fd4:	12050e63          	beqz	a0,80005110 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fd8:	75f9                	lui	a1,0xffffe
    80004fda:	95aa                	add	a1,a1,a0
    80004fdc:	855a                	mv	a0,s6
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	678080e7          	jalr	1656(ra) # 80001656 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fe6:	7afd                	lui	s5,0xfffff
    80004fe8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fea:	df043783          	ld	a5,-528(s0)
    80004fee:	6388                	ld	a0,0(a5)
    80004ff0:	c925                	beqz	a0,80005060 <exec+0x226>
    80004ff2:	e9040993          	addi	s3,s0,-368
    80004ff6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004ffa:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ffc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	e50080e7          	jalr	-432(ra) # 80000e4e <strlen>
    80005006:	0015079b          	addiw	a5,a0,1
    8000500a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000500e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005012:	13596663          	bltu	s2,s5,8000513e <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005016:	df043d83          	ld	s11,-528(s0)
    8000501a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000501e:	8552                	mv	a0,s4
    80005020:	ffffc097          	auipc	ra,0xffffc
    80005024:	e2e080e7          	jalr	-466(ra) # 80000e4e <strlen>
    80005028:	0015069b          	addiw	a3,a0,1
    8000502c:	8652                	mv	a2,s4
    8000502e:	85ca                	mv	a1,s2
    80005030:	855a                	mv	a0,s6
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	656080e7          	jalr	1622(ra) # 80001688 <copyout>
    8000503a:	10054663          	bltz	a0,80005146 <exec+0x30c>
    ustack[argc] = sp;
    8000503e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005042:	0485                	addi	s1,s1,1
    80005044:	008d8793          	addi	a5,s11,8
    80005048:	def43823          	sd	a5,-528(s0)
    8000504c:	008db503          	ld	a0,8(s11)
    80005050:	c911                	beqz	a0,80005064 <exec+0x22a>
    if(argc >= MAXARG)
    80005052:	09a1                	addi	s3,s3,8
    80005054:	fb3c95e3          	bne	s9,s3,80004ffe <exec+0x1c4>
  sz = sz1;
    80005058:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000505c:	4a81                	li	s5,0
    8000505e:	a84d                	j	80005110 <exec+0x2d6>
  sp = sz;
    80005060:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005062:	4481                	li	s1,0
  ustack[argc] = 0;
    80005064:	00349793          	slli	a5,s1,0x3
    80005068:	f9040713          	addi	a4,s0,-112
    8000506c:	97ba                	add	a5,a5,a4
    8000506e:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdcd60>
  sp -= (argc+1) * sizeof(uint64);
    80005072:	00148693          	addi	a3,s1,1
    80005076:	068e                	slli	a3,a3,0x3
    80005078:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000507c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005080:	01597663          	bgeu	s2,s5,8000508c <exec+0x252>
  sz = sz1;
    80005084:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005088:	4a81                	li	s5,0
    8000508a:	a059                	j	80005110 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000508c:	e9040613          	addi	a2,s0,-368
    80005090:	85ca                	mv	a1,s2
    80005092:	855a                	mv	a0,s6
    80005094:	ffffc097          	auipc	ra,0xffffc
    80005098:	5f4080e7          	jalr	1524(ra) # 80001688 <copyout>
    8000509c:	0a054963          	bltz	a0,8000514e <exec+0x314>
  p->trapframe->a1 = sp;
    800050a0:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800050a4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050a8:	de843783          	ld	a5,-536(s0)
    800050ac:	0007c703          	lbu	a4,0(a5)
    800050b0:	cf11                	beqz	a4,800050cc <exec+0x292>
    800050b2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050b4:	02f00693          	li	a3,47
    800050b8:	a039                	j	800050c6 <exec+0x28c>
      last = s+1;
    800050ba:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050be:	0785                	addi	a5,a5,1
    800050c0:	fff7c703          	lbu	a4,-1(a5)
    800050c4:	c701                	beqz	a4,800050cc <exec+0x292>
    if(*s == '/')
    800050c6:	fed71ce3          	bne	a4,a3,800050be <exec+0x284>
    800050ca:	bfc5                	j	800050ba <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800050cc:	4641                	li	a2,16
    800050ce:	de843583          	ld	a1,-536(s0)
    800050d2:	158b8513          	addi	a0,s7,344
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	d46080e7          	jalr	-698(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800050de:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800050e2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800050e6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050ea:	058bb783          	ld	a5,88(s7)
    800050ee:	e6843703          	ld	a4,-408(s0)
    800050f2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050f4:	058bb783          	ld	a5,88(s7)
    800050f8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050fc:	85ea                	mv	a1,s10
    800050fe:	ffffd097          	auipc	ra,0xffffd
    80005102:	a2e080e7          	jalr	-1490(ra) # 80001b2c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005106:	0004851b          	sext.w	a0,s1
    8000510a:	b3f1                	j	80004ed6 <exec+0x9c>
    8000510c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005110:	df843583          	ld	a1,-520(s0)
    80005114:	855a                	mv	a0,s6
    80005116:	ffffd097          	auipc	ra,0xffffd
    8000511a:	a16080e7          	jalr	-1514(ra) # 80001b2c <proc_freepagetable>
  if(ip){
    8000511e:	da0a92e3          	bnez	s5,80004ec2 <exec+0x88>
  return -1;
    80005122:	557d                	li	a0,-1
    80005124:	bb4d                	j	80004ed6 <exec+0x9c>
    80005126:	df243c23          	sd	s2,-520(s0)
    8000512a:	b7dd                	j	80005110 <exec+0x2d6>
    8000512c:	df243c23          	sd	s2,-520(s0)
    80005130:	b7c5                	j	80005110 <exec+0x2d6>
    80005132:	df243c23          	sd	s2,-520(s0)
    80005136:	bfe9                	j	80005110 <exec+0x2d6>
    80005138:	df243c23          	sd	s2,-520(s0)
    8000513c:	bfd1                	j	80005110 <exec+0x2d6>
  sz = sz1;
    8000513e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005142:	4a81                	li	s5,0
    80005144:	b7f1                	j	80005110 <exec+0x2d6>
  sz = sz1;
    80005146:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000514a:	4a81                	li	s5,0
    8000514c:	b7d1                	j	80005110 <exec+0x2d6>
  sz = sz1;
    8000514e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005152:	4a81                	li	s5,0
    80005154:	bf75                	j	80005110 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005156:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000515a:	e0843783          	ld	a5,-504(s0)
    8000515e:	0017869b          	addiw	a3,a5,1
    80005162:	e0d43423          	sd	a3,-504(s0)
    80005166:	e0043783          	ld	a5,-512(s0)
    8000516a:	0387879b          	addiw	a5,a5,56
    8000516e:	e8845703          	lhu	a4,-376(s0)
    80005172:	e0e6dee3          	bge	a3,a4,80004f8e <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005176:	2781                	sext.w	a5,a5
    80005178:	e0f43023          	sd	a5,-512(s0)
    8000517c:	03800713          	li	a4,56
    80005180:	86be                	mv	a3,a5
    80005182:	e1840613          	addi	a2,s0,-488
    80005186:	4581                	li	a1,0
    80005188:	8556                	mv	a0,s5
    8000518a:	fffff097          	auipc	ra,0xfffff
    8000518e:	a5c080e7          	jalr	-1444(ra) # 80003be6 <readi>
    80005192:	03800793          	li	a5,56
    80005196:	f6f51be3          	bne	a0,a5,8000510c <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    8000519a:	e1842783          	lw	a5,-488(s0)
    8000519e:	4705                	li	a4,1
    800051a0:	fae79de3          	bne	a5,a4,8000515a <exec+0x320>
    if(ph.memsz < ph.filesz)
    800051a4:	e4043483          	ld	s1,-448(s0)
    800051a8:	e3843783          	ld	a5,-456(s0)
    800051ac:	f6f4ede3          	bltu	s1,a5,80005126 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051b0:	e2843783          	ld	a5,-472(s0)
    800051b4:	94be                	add	s1,s1,a5
    800051b6:	f6f4ebe3          	bltu	s1,a5,8000512c <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800051ba:	de043703          	ld	a4,-544(s0)
    800051be:	8ff9                	and	a5,a5,a4
    800051c0:	fbad                	bnez	a5,80005132 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051c2:	e1c42503          	lw	a0,-484(s0)
    800051c6:	00000097          	auipc	ra,0x0
    800051ca:	c58080e7          	jalr	-936(ra) # 80004e1e <flags2perm>
    800051ce:	86aa                	mv	a3,a0
    800051d0:	8626                	mv	a2,s1
    800051d2:	85ca                	mv	a1,s2
    800051d4:	855a                	mv	a0,s6
    800051d6:	ffffc097          	auipc	ra,0xffffc
    800051da:	25a080e7          	jalr	602(ra) # 80001430 <uvmalloc>
    800051de:	dea43c23          	sd	a0,-520(s0)
    800051e2:	d939                	beqz	a0,80005138 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051e4:	e2843c03          	ld	s8,-472(s0)
    800051e8:	e2042c83          	lw	s9,-480(s0)
    800051ec:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051f0:	f60b83e3          	beqz	s7,80005156 <exec+0x31c>
    800051f4:	89de                	mv	s3,s7
    800051f6:	4481                	li	s1,0
    800051f8:	bb95                	j	80004f6c <exec+0x132>

00000000800051fa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051fa:	7179                	addi	sp,sp,-48
    800051fc:	f406                	sd	ra,40(sp)
    800051fe:	f022                	sd	s0,32(sp)
    80005200:	ec26                	sd	s1,24(sp)
    80005202:	e84a                	sd	s2,16(sp)
    80005204:	1800                	addi	s0,sp,48
    80005206:	892e                	mv	s2,a1
    80005208:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000520a:	fdc40593          	addi	a1,s0,-36
    8000520e:	ffffe097          	auipc	ra,0xffffe
    80005212:	b1c080e7          	jalr	-1252(ra) # 80002d2a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005216:	fdc42703          	lw	a4,-36(s0)
    8000521a:	47bd                	li	a5,15
    8000521c:	02e7eb63          	bltu	a5,a4,80005252 <argfd+0x58>
    80005220:	ffffc097          	auipc	ra,0xffffc
    80005224:	7ac080e7          	jalr	1964(ra) # 800019cc <myproc>
    80005228:	fdc42703          	lw	a4,-36(s0)
    8000522c:	01a70793          	addi	a5,a4,26
    80005230:	078e                	slli	a5,a5,0x3
    80005232:	953e                	add	a0,a0,a5
    80005234:	611c                	ld	a5,0(a0)
    80005236:	c385                	beqz	a5,80005256 <argfd+0x5c>
    return -1;
  if(pfd)
    80005238:	00090463          	beqz	s2,80005240 <argfd+0x46>
    *pfd = fd;
    8000523c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005240:	4501                	li	a0,0
  if(pf)
    80005242:	c091                	beqz	s1,80005246 <argfd+0x4c>
    *pf = f;
    80005244:	e09c                	sd	a5,0(s1)
}
    80005246:	70a2                	ld	ra,40(sp)
    80005248:	7402                	ld	s0,32(sp)
    8000524a:	64e2                	ld	s1,24(sp)
    8000524c:	6942                	ld	s2,16(sp)
    8000524e:	6145                	addi	sp,sp,48
    80005250:	8082                	ret
    return -1;
    80005252:	557d                	li	a0,-1
    80005254:	bfcd                	j	80005246 <argfd+0x4c>
    80005256:	557d                	li	a0,-1
    80005258:	b7fd                	j	80005246 <argfd+0x4c>

000000008000525a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000525a:	1101                	addi	sp,sp,-32
    8000525c:	ec06                	sd	ra,24(sp)
    8000525e:	e822                	sd	s0,16(sp)
    80005260:	e426                	sd	s1,8(sp)
    80005262:	1000                	addi	s0,sp,32
    80005264:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005266:	ffffc097          	auipc	ra,0xffffc
    8000526a:	766080e7          	jalr	1894(ra) # 800019cc <myproc>
    8000526e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005270:	0d050793          	addi	a5,a0,208
    80005274:	4501                	li	a0,0
    80005276:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005278:	6398                	ld	a4,0(a5)
    8000527a:	cb19                	beqz	a4,80005290 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000527c:	2505                	addiw	a0,a0,1
    8000527e:	07a1                	addi	a5,a5,8
    80005280:	fed51ce3          	bne	a0,a3,80005278 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005284:	557d                	li	a0,-1
}
    80005286:	60e2                	ld	ra,24(sp)
    80005288:	6442                	ld	s0,16(sp)
    8000528a:	64a2                	ld	s1,8(sp)
    8000528c:	6105                	addi	sp,sp,32
    8000528e:	8082                	ret
      p->ofile[fd] = f;
    80005290:	01a50793          	addi	a5,a0,26
    80005294:	078e                	slli	a5,a5,0x3
    80005296:	963e                	add	a2,a2,a5
    80005298:	e204                	sd	s1,0(a2)
      return fd;
    8000529a:	b7f5                	j	80005286 <fdalloc+0x2c>

000000008000529c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000529c:	715d                	addi	sp,sp,-80
    8000529e:	e486                	sd	ra,72(sp)
    800052a0:	e0a2                	sd	s0,64(sp)
    800052a2:	fc26                	sd	s1,56(sp)
    800052a4:	f84a                	sd	s2,48(sp)
    800052a6:	f44e                	sd	s3,40(sp)
    800052a8:	f052                	sd	s4,32(sp)
    800052aa:	ec56                	sd	s5,24(sp)
    800052ac:	e85a                	sd	s6,16(sp)
    800052ae:	0880                	addi	s0,sp,80
    800052b0:	8b2e                	mv	s6,a1
    800052b2:	89b2                	mv	s3,a2
    800052b4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052b6:	fb040593          	addi	a1,s0,-80
    800052ba:	fffff097          	auipc	ra,0xfffff
    800052be:	e3c080e7          	jalr	-452(ra) # 800040f6 <nameiparent>
    800052c2:	84aa                	mv	s1,a0
    800052c4:	14050f63          	beqz	a0,80005422 <create+0x186>
    return 0;

  ilock(dp);
    800052c8:	ffffe097          	auipc	ra,0xffffe
    800052cc:	66a080e7          	jalr	1642(ra) # 80003932 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052d0:	4601                	li	a2,0
    800052d2:	fb040593          	addi	a1,s0,-80
    800052d6:	8526                	mv	a0,s1
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	b3e080e7          	jalr	-1218(ra) # 80003e16 <dirlookup>
    800052e0:	8aaa                	mv	s5,a0
    800052e2:	c931                	beqz	a0,80005336 <create+0x9a>
    iunlockput(dp);
    800052e4:	8526                	mv	a0,s1
    800052e6:	fffff097          	auipc	ra,0xfffff
    800052ea:	8ae080e7          	jalr	-1874(ra) # 80003b94 <iunlockput>
    ilock(ip);
    800052ee:	8556                	mv	a0,s5
    800052f0:	ffffe097          	auipc	ra,0xffffe
    800052f4:	642080e7          	jalr	1602(ra) # 80003932 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052f8:	000b059b          	sext.w	a1,s6
    800052fc:	4789                	li	a5,2
    800052fe:	02f59563          	bne	a1,a5,80005328 <create+0x8c>
    80005302:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcea4>
    80005306:	37f9                	addiw	a5,a5,-2
    80005308:	17c2                	slli	a5,a5,0x30
    8000530a:	93c1                	srli	a5,a5,0x30
    8000530c:	4705                	li	a4,1
    8000530e:	00f76d63          	bltu	a4,a5,80005328 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005312:	8556                	mv	a0,s5
    80005314:	60a6                	ld	ra,72(sp)
    80005316:	6406                	ld	s0,64(sp)
    80005318:	74e2                	ld	s1,56(sp)
    8000531a:	7942                	ld	s2,48(sp)
    8000531c:	79a2                	ld	s3,40(sp)
    8000531e:	7a02                	ld	s4,32(sp)
    80005320:	6ae2                	ld	s5,24(sp)
    80005322:	6b42                	ld	s6,16(sp)
    80005324:	6161                	addi	sp,sp,80
    80005326:	8082                	ret
    iunlockput(ip);
    80005328:	8556                	mv	a0,s5
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	86a080e7          	jalr	-1942(ra) # 80003b94 <iunlockput>
    return 0;
    80005332:	4a81                	li	s5,0
    80005334:	bff9                	j	80005312 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005336:	85da                	mv	a1,s6
    80005338:	4088                	lw	a0,0(s1)
    8000533a:	ffffe097          	auipc	ra,0xffffe
    8000533e:	45c080e7          	jalr	1116(ra) # 80003796 <ialloc>
    80005342:	8a2a                	mv	s4,a0
    80005344:	c539                	beqz	a0,80005392 <create+0xf6>
  ilock(ip);
    80005346:	ffffe097          	auipc	ra,0xffffe
    8000534a:	5ec080e7          	jalr	1516(ra) # 80003932 <ilock>
  ip->major = major;
    8000534e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005352:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005356:	4905                	li	s2,1
    80005358:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000535c:	8552                	mv	a0,s4
    8000535e:	ffffe097          	auipc	ra,0xffffe
    80005362:	50a080e7          	jalr	1290(ra) # 80003868 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005366:	000b059b          	sext.w	a1,s6
    8000536a:	03258b63          	beq	a1,s2,800053a0 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000536e:	004a2603          	lw	a2,4(s4)
    80005372:	fb040593          	addi	a1,s0,-80
    80005376:	8526                	mv	a0,s1
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	cae080e7          	jalr	-850(ra) # 80004026 <dirlink>
    80005380:	06054f63          	bltz	a0,800053fe <create+0x162>
  iunlockput(dp);
    80005384:	8526                	mv	a0,s1
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	80e080e7          	jalr	-2034(ra) # 80003b94 <iunlockput>
  return ip;
    8000538e:	8ad2                	mv	s5,s4
    80005390:	b749                	j	80005312 <create+0x76>
    iunlockput(dp);
    80005392:	8526                	mv	a0,s1
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	800080e7          	jalr	-2048(ra) # 80003b94 <iunlockput>
    return 0;
    8000539c:	8ad2                	mv	s5,s4
    8000539e:	bf95                	j	80005312 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053a0:	004a2603          	lw	a2,4(s4)
    800053a4:	00003597          	auipc	a1,0x3
    800053a8:	3ac58593          	addi	a1,a1,940 # 80008750 <syscalls+0x2a8>
    800053ac:	8552                	mv	a0,s4
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	c78080e7          	jalr	-904(ra) # 80004026 <dirlink>
    800053b6:	04054463          	bltz	a0,800053fe <create+0x162>
    800053ba:	40d0                	lw	a2,4(s1)
    800053bc:	00003597          	auipc	a1,0x3
    800053c0:	39c58593          	addi	a1,a1,924 # 80008758 <syscalls+0x2b0>
    800053c4:	8552                	mv	a0,s4
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	c60080e7          	jalr	-928(ra) # 80004026 <dirlink>
    800053ce:	02054863          	bltz	a0,800053fe <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800053d2:	004a2603          	lw	a2,4(s4)
    800053d6:	fb040593          	addi	a1,s0,-80
    800053da:	8526                	mv	a0,s1
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	c4a080e7          	jalr	-950(ra) # 80004026 <dirlink>
    800053e4:	00054d63          	bltz	a0,800053fe <create+0x162>
    dp->nlink++;  // for ".."
    800053e8:	04a4d783          	lhu	a5,74(s1)
    800053ec:	2785                	addiw	a5,a5,1
    800053ee:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053f2:	8526                	mv	a0,s1
    800053f4:	ffffe097          	auipc	ra,0xffffe
    800053f8:	474080e7          	jalr	1140(ra) # 80003868 <iupdate>
    800053fc:	b761                	j	80005384 <create+0xe8>
  ip->nlink = 0;
    800053fe:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005402:	8552                	mv	a0,s4
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	464080e7          	jalr	1124(ra) # 80003868 <iupdate>
  iunlockput(ip);
    8000540c:	8552                	mv	a0,s4
    8000540e:	ffffe097          	auipc	ra,0xffffe
    80005412:	786080e7          	jalr	1926(ra) # 80003b94 <iunlockput>
  iunlockput(dp);
    80005416:	8526                	mv	a0,s1
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	77c080e7          	jalr	1916(ra) # 80003b94 <iunlockput>
  return 0;
    80005420:	bdcd                	j	80005312 <create+0x76>
    return 0;
    80005422:	8aaa                	mv	s5,a0
    80005424:	b5fd                	j	80005312 <create+0x76>

0000000080005426 <sys_dup>:
{
    80005426:	7179                	addi	sp,sp,-48
    80005428:	f406                	sd	ra,40(sp)
    8000542a:	f022                	sd	s0,32(sp)
    8000542c:	ec26                	sd	s1,24(sp)
    8000542e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005430:	fd840613          	addi	a2,s0,-40
    80005434:	4581                	li	a1,0
    80005436:	4501                	li	a0,0
    80005438:	00000097          	auipc	ra,0x0
    8000543c:	dc2080e7          	jalr	-574(ra) # 800051fa <argfd>
    return -1;
    80005440:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005442:	02054363          	bltz	a0,80005468 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005446:	fd843503          	ld	a0,-40(s0)
    8000544a:	00000097          	auipc	ra,0x0
    8000544e:	e10080e7          	jalr	-496(ra) # 8000525a <fdalloc>
    80005452:	84aa                	mv	s1,a0
    return -1;
    80005454:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005456:	00054963          	bltz	a0,80005468 <sys_dup+0x42>
  filedup(f);
    8000545a:	fd843503          	ld	a0,-40(s0)
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	310080e7          	jalr	784(ra) # 8000476e <filedup>
  return fd;
    80005466:	87a6                	mv	a5,s1
}
    80005468:	853e                	mv	a0,a5
    8000546a:	70a2                	ld	ra,40(sp)
    8000546c:	7402                	ld	s0,32(sp)
    8000546e:	64e2                	ld	s1,24(sp)
    80005470:	6145                	addi	sp,sp,48
    80005472:	8082                	ret

0000000080005474 <sys_read>:
{
    80005474:	7179                	addi	sp,sp,-48
    80005476:	f406                	sd	ra,40(sp)
    80005478:	f022                	sd	s0,32(sp)
    8000547a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000547c:	fd840593          	addi	a1,s0,-40
    80005480:	4505                	li	a0,1
    80005482:	ffffe097          	auipc	ra,0xffffe
    80005486:	8c8080e7          	jalr	-1848(ra) # 80002d4a <argaddr>
  argint(2, &n);
    8000548a:	fe440593          	addi	a1,s0,-28
    8000548e:	4509                	li	a0,2
    80005490:	ffffe097          	auipc	ra,0xffffe
    80005494:	89a080e7          	jalr	-1894(ra) # 80002d2a <argint>
  if(argfd(0, 0, &f) < 0)
    80005498:	fe840613          	addi	a2,s0,-24
    8000549c:	4581                	li	a1,0
    8000549e:	4501                	li	a0,0
    800054a0:	00000097          	auipc	ra,0x0
    800054a4:	d5a080e7          	jalr	-678(ra) # 800051fa <argfd>
    800054a8:	87aa                	mv	a5,a0
    return -1;
    800054aa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054ac:	0007cc63          	bltz	a5,800054c4 <sys_read+0x50>
  return fileread(f, p, n);
    800054b0:	fe442603          	lw	a2,-28(s0)
    800054b4:	fd843583          	ld	a1,-40(s0)
    800054b8:	fe843503          	ld	a0,-24(s0)
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	43e080e7          	jalr	1086(ra) # 800048fa <fileread>
}
    800054c4:	70a2                	ld	ra,40(sp)
    800054c6:	7402                	ld	s0,32(sp)
    800054c8:	6145                	addi	sp,sp,48
    800054ca:	8082                	ret

00000000800054cc <sys_write>:
{
    800054cc:	7179                	addi	sp,sp,-48
    800054ce:	f406                	sd	ra,40(sp)
    800054d0:	f022                	sd	s0,32(sp)
    800054d2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054d4:	fd840593          	addi	a1,s0,-40
    800054d8:	4505                	li	a0,1
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	870080e7          	jalr	-1936(ra) # 80002d4a <argaddr>
  argint(2, &n);
    800054e2:	fe440593          	addi	a1,s0,-28
    800054e6:	4509                	li	a0,2
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	842080e7          	jalr	-1982(ra) # 80002d2a <argint>
  if(argfd(0, 0, &f) < 0)
    800054f0:	fe840613          	addi	a2,s0,-24
    800054f4:	4581                	li	a1,0
    800054f6:	4501                	li	a0,0
    800054f8:	00000097          	auipc	ra,0x0
    800054fc:	d02080e7          	jalr	-766(ra) # 800051fa <argfd>
    80005500:	87aa                	mv	a5,a0
    return -1;
    80005502:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005504:	0007cc63          	bltz	a5,8000551c <sys_write+0x50>
  return filewrite(f, p, n);
    80005508:	fe442603          	lw	a2,-28(s0)
    8000550c:	fd843583          	ld	a1,-40(s0)
    80005510:	fe843503          	ld	a0,-24(s0)
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	4a8080e7          	jalr	1192(ra) # 800049bc <filewrite>
}
    8000551c:	70a2                	ld	ra,40(sp)
    8000551e:	7402                	ld	s0,32(sp)
    80005520:	6145                	addi	sp,sp,48
    80005522:	8082                	ret

0000000080005524 <sys_close>:
{
    80005524:	1101                	addi	sp,sp,-32
    80005526:	ec06                	sd	ra,24(sp)
    80005528:	e822                	sd	s0,16(sp)
    8000552a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000552c:	fe040613          	addi	a2,s0,-32
    80005530:	fec40593          	addi	a1,s0,-20
    80005534:	4501                	li	a0,0
    80005536:	00000097          	auipc	ra,0x0
    8000553a:	cc4080e7          	jalr	-828(ra) # 800051fa <argfd>
    return -1;
    8000553e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005540:	02054463          	bltz	a0,80005568 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005544:	ffffc097          	auipc	ra,0xffffc
    80005548:	488080e7          	jalr	1160(ra) # 800019cc <myproc>
    8000554c:	fec42783          	lw	a5,-20(s0)
    80005550:	07e9                	addi	a5,a5,26
    80005552:	078e                	slli	a5,a5,0x3
    80005554:	97aa                	add	a5,a5,a0
    80005556:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000555a:	fe043503          	ld	a0,-32(s0)
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	262080e7          	jalr	610(ra) # 800047c0 <fileclose>
  return 0;
    80005566:	4781                	li	a5,0
}
    80005568:	853e                	mv	a0,a5
    8000556a:	60e2                	ld	ra,24(sp)
    8000556c:	6442                	ld	s0,16(sp)
    8000556e:	6105                	addi	sp,sp,32
    80005570:	8082                	ret

0000000080005572 <sys_fstat>:
{
    80005572:	1101                	addi	sp,sp,-32
    80005574:	ec06                	sd	ra,24(sp)
    80005576:	e822                	sd	s0,16(sp)
    80005578:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000557a:	fe040593          	addi	a1,s0,-32
    8000557e:	4505                	li	a0,1
    80005580:	ffffd097          	auipc	ra,0xffffd
    80005584:	7ca080e7          	jalr	1994(ra) # 80002d4a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005588:	fe840613          	addi	a2,s0,-24
    8000558c:	4581                	li	a1,0
    8000558e:	4501                	li	a0,0
    80005590:	00000097          	auipc	ra,0x0
    80005594:	c6a080e7          	jalr	-918(ra) # 800051fa <argfd>
    80005598:	87aa                	mv	a5,a0
    return -1;
    8000559a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000559c:	0007ca63          	bltz	a5,800055b0 <sys_fstat+0x3e>
  return filestat(f, st);
    800055a0:	fe043583          	ld	a1,-32(s0)
    800055a4:	fe843503          	ld	a0,-24(s0)
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	2e0080e7          	jalr	736(ra) # 80004888 <filestat>
}
    800055b0:	60e2                	ld	ra,24(sp)
    800055b2:	6442                	ld	s0,16(sp)
    800055b4:	6105                	addi	sp,sp,32
    800055b6:	8082                	ret

00000000800055b8 <sys_link>:
{
    800055b8:	7169                	addi	sp,sp,-304
    800055ba:	f606                	sd	ra,296(sp)
    800055bc:	f222                	sd	s0,288(sp)
    800055be:	ee26                	sd	s1,280(sp)
    800055c0:	ea4a                	sd	s2,272(sp)
    800055c2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055c4:	08000613          	li	a2,128
    800055c8:	ed040593          	addi	a1,s0,-304
    800055cc:	4501                	li	a0,0
    800055ce:	ffffd097          	auipc	ra,0xffffd
    800055d2:	79c080e7          	jalr	1948(ra) # 80002d6a <argstr>
    return -1;
    800055d6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d8:	10054e63          	bltz	a0,800056f4 <sys_link+0x13c>
    800055dc:	08000613          	li	a2,128
    800055e0:	f5040593          	addi	a1,s0,-176
    800055e4:	4505                	li	a0,1
    800055e6:	ffffd097          	auipc	ra,0xffffd
    800055ea:	784080e7          	jalr	1924(ra) # 80002d6a <argstr>
    return -1;
    800055ee:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055f0:	10054263          	bltz	a0,800056f4 <sys_link+0x13c>
  begin_op();
    800055f4:	fffff097          	auipc	ra,0xfffff
    800055f8:	d00080e7          	jalr	-768(ra) # 800042f4 <begin_op>
  if((ip = namei(old)) == 0){
    800055fc:	ed040513          	addi	a0,s0,-304
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	ad8080e7          	jalr	-1320(ra) # 800040d8 <namei>
    80005608:	84aa                	mv	s1,a0
    8000560a:	c551                	beqz	a0,80005696 <sys_link+0xde>
  ilock(ip);
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	326080e7          	jalr	806(ra) # 80003932 <ilock>
  if(ip->type == T_DIR){
    80005614:	04449703          	lh	a4,68(s1)
    80005618:	4785                	li	a5,1
    8000561a:	08f70463          	beq	a4,a5,800056a2 <sys_link+0xea>
  ip->nlink++;
    8000561e:	04a4d783          	lhu	a5,74(s1)
    80005622:	2785                	addiw	a5,a5,1
    80005624:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005628:	8526                	mv	a0,s1
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	23e080e7          	jalr	574(ra) # 80003868 <iupdate>
  iunlock(ip);
    80005632:	8526                	mv	a0,s1
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	3c0080e7          	jalr	960(ra) # 800039f4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000563c:	fd040593          	addi	a1,s0,-48
    80005640:	f5040513          	addi	a0,s0,-176
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	ab2080e7          	jalr	-1358(ra) # 800040f6 <nameiparent>
    8000564c:	892a                	mv	s2,a0
    8000564e:	c935                	beqz	a0,800056c2 <sys_link+0x10a>
  ilock(dp);
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	2e2080e7          	jalr	738(ra) # 80003932 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005658:	00092703          	lw	a4,0(s2)
    8000565c:	409c                	lw	a5,0(s1)
    8000565e:	04f71d63          	bne	a4,a5,800056b8 <sys_link+0x100>
    80005662:	40d0                	lw	a2,4(s1)
    80005664:	fd040593          	addi	a1,s0,-48
    80005668:	854a                	mv	a0,s2
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	9bc080e7          	jalr	-1604(ra) # 80004026 <dirlink>
    80005672:	04054363          	bltz	a0,800056b8 <sys_link+0x100>
  iunlockput(dp);
    80005676:	854a                	mv	a0,s2
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	51c080e7          	jalr	1308(ra) # 80003b94 <iunlockput>
  iput(ip);
    80005680:	8526                	mv	a0,s1
    80005682:	ffffe097          	auipc	ra,0xffffe
    80005686:	46a080e7          	jalr	1130(ra) # 80003aec <iput>
  end_op();
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	cea080e7          	jalr	-790(ra) # 80004374 <end_op>
  return 0;
    80005692:	4781                	li	a5,0
    80005694:	a085                	j	800056f4 <sys_link+0x13c>
    end_op();
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	cde080e7          	jalr	-802(ra) # 80004374 <end_op>
    return -1;
    8000569e:	57fd                	li	a5,-1
    800056a0:	a891                	j	800056f4 <sys_link+0x13c>
    iunlockput(ip);
    800056a2:	8526                	mv	a0,s1
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	4f0080e7          	jalr	1264(ra) # 80003b94 <iunlockput>
    end_op();
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	cc8080e7          	jalr	-824(ra) # 80004374 <end_op>
    return -1;
    800056b4:	57fd                	li	a5,-1
    800056b6:	a83d                	j	800056f4 <sys_link+0x13c>
    iunlockput(dp);
    800056b8:	854a                	mv	a0,s2
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	4da080e7          	jalr	1242(ra) # 80003b94 <iunlockput>
  ilock(ip);
    800056c2:	8526                	mv	a0,s1
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	26e080e7          	jalr	622(ra) # 80003932 <ilock>
  ip->nlink--;
    800056cc:	04a4d783          	lhu	a5,74(s1)
    800056d0:	37fd                	addiw	a5,a5,-1
    800056d2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	190080e7          	jalr	400(ra) # 80003868 <iupdate>
  iunlockput(ip);
    800056e0:	8526                	mv	a0,s1
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	4b2080e7          	jalr	1202(ra) # 80003b94 <iunlockput>
  end_op();
    800056ea:	fffff097          	auipc	ra,0xfffff
    800056ee:	c8a080e7          	jalr	-886(ra) # 80004374 <end_op>
  return -1;
    800056f2:	57fd                	li	a5,-1
}
    800056f4:	853e                	mv	a0,a5
    800056f6:	70b2                	ld	ra,296(sp)
    800056f8:	7412                	ld	s0,288(sp)
    800056fa:	64f2                	ld	s1,280(sp)
    800056fc:	6952                	ld	s2,272(sp)
    800056fe:	6155                	addi	sp,sp,304
    80005700:	8082                	ret

0000000080005702 <sys_unlink>:
{
    80005702:	7151                	addi	sp,sp,-240
    80005704:	f586                	sd	ra,232(sp)
    80005706:	f1a2                	sd	s0,224(sp)
    80005708:	eda6                	sd	s1,216(sp)
    8000570a:	e9ca                	sd	s2,208(sp)
    8000570c:	e5ce                	sd	s3,200(sp)
    8000570e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005710:	08000613          	li	a2,128
    80005714:	f3040593          	addi	a1,s0,-208
    80005718:	4501                	li	a0,0
    8000571a:	ffffd097          	auipc	ra,0xffffd
    8000571e:	650080e7          	jalr	1616(ra) # 80002d6a <argstr>
    80005722:	18054163          	bltz	a0,800058a4 <sys_unlink+0x1a2>
  begin_op();
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	bce080e7          	jalr	-1074(ra) # 800042f4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000572e:	fb040593          	addi	a1,s0,-80
    80005732:	f3040513          	addi	a0,s0,-208
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	9c0080e7          	jalr	-1600(ra) # 800040f6 <nameiparent>
    8000573e:	84aa                	mv	s1,a0
    80005740:	c979                	beqz	a0,80005816 <sys_unlink+0x114>
  ilock(dp);
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	1f0080e7          	jalr	496(ra) # 80003932 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000574a:	00003597          	auipc	a1,0x3
    8000574e:	00658593          	addi	a1,a1,6 # 80008750 <syscalls+0x2a8>
    80005752:	fb040513          	addi	a0,s0,-80
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	6a6080e7          	jalr	1702(ra) # 80003dfc <namecmp>
    8000575e:	14050a63          	beqz	a0,800058b2 <sys_unlink+0x1b0>
    80005762:	00003597          	auipc	a1,0x3
    80005766:	ff658593          	addi	a1,a1,-10 # 80008758 <syscalls+0x2b0>
    8000576a:	fb040513          	addi	a0,s0,-80
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	68e080e7          	jalr	1678(ra) # 80003dfc <namecmp>
    80005776:	12050e63          	beqz	a0,800058b2 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000577a:	f2c40613          	addi	a2,s0,-212
    8000577e:	fb040593          	addi	a1,s0,-80
    80005782:	8526                	mv	a0,s1
    80005784:	ffffe097          	auipc	ra,0xffffe
    80005788:	692080e7          	jalr	1682(ra) # 80003e16 <dirlookup>
    8000578c:	892a                	mv	s2,a0
    8000578e:	12050263          	beqz	a0,800058b2 <sys_unlink+0x1b0>
  ilock(ip);
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	1a0080e7          	jalr	416(ra) # 80003932 <ilock>
  if(ip->nlink < 1)
    8000579a:	04a91783          	lh	a5,74(s2)
    8000579e:	08f05263          	blez	a5,80005822 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057a2:	04491703          	lh	a4,68(s2)
    800057a6:	4785                	li	a5,1
    800057a8:	08f70563          	beq	a4,a5,80005832 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057ac:	4641                	li	a2,16
    800057ae:	4581                	li	a1,0
    800057b0:	fc040513          	addi	a0,s0,-64
    800057b4:	ffffb097          	auipc	ra,0xffffb
    800057b8:	51e080e7          	jalr	1310(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057bc:	4741                	li	a4,16
    800057be:	f2c42683          	lw	a3,-212(s0)
    800057c2:	fc040613          	addi	a2,s0,-64
    800057c6:	4581                	li	a1,0
    800057c8:	8526                	mv	a0,s1
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	514080e7          	jalr	1300(ra) # 80003cde <writei>
    800057d2:	47c1                	li	a5,16
    800057d4:	0af51563          	bne	a0,a5,8000587e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057d8:	04491703          	lh	a4,68(s2)
    800057dc:	4785                	li	a5,1
    800057de:	0af70863          	beq	a4,a5,8000588e <sys_unlink+0x18c>
  iunlockput(dp);
    800057e2:	8526                	mv	a0,s1
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	3b0080e7          	jalr	944(ra) # 80003b94 <iunlockput>
  ip->nlink--;
    800057ec:	04a95783          	lhu	a5,74(s2)
    800057f0:	37fd                	addiw	a5,a5,-1
    800057f2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057f6:	854a                	mv	a0,s2
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	070080e7          	jalr	112(ra) # 80003868 <iupdate>
  iunlockput(ip);
    80005800:	854a                	mv	a0,s2
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	392080e7          	jalr	914(ra) # 80003b94 <iunlockput>
  end_op();
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	b6a080e7          	jalr	-1174(ra) # 80004374 <end_op>
  return 0;
    80005812:	4501                	li	a0,0
    80005814:	a84d                	j	800058c6 <sys_unlink+0x1c4>
    end_op();
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	b5e080e7          	jalr	-1186(ra) # 80004374 <end_op>
    return -1;
    8000581e:	557d                	li	a0,-1
    80005820:	a05d                	j	800058c6 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005822:	00003517          	auipc	a0,0x3
    80005826:	f3e50513          	addi	a0,a0,-194 # 80008760 <syscalls+0x2b8>
    8000582a:	ffffb097          	auipc	ra,0xffffb
    8000582e:	d14080e7          	jalr	-748(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005832:	04c92703          	lw	a4,76(s2)
    80005836:	02000793          	li	a5,32
    8000583a:	f6e7f9e3          	bgeu	a5,a4,800057ac <sys_unlink+0xaa>
    8000583e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005842:	4741                	li	a4,16
    80005844:	86ce                	mv	a3,s3
    80005846:	f1840613          	addi	a2,s0,-232
    8000584a:	4581                	li	a1,0
    8000584c:	854a                	mv	a0,s2
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	398080e7          	jalr	920(ra) # 80003be6 <readi>
    80005856:	47c1                	li	a5,16
    80005858:	00f51b63          	bne	a0,a5,8000586e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000585c:	f1845783          	lhu	a5,-232(s0)
    80005860:	e7a1                	bnez	a5,800058a8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005862:	29c1                	addiw	s3,s3,16
    80005864:	04c92783          	lw	a5,76(s2)
    80005868:	fcf9ede3          	bltu	s3,a5,80005842 <sys_unlink+0x140>
    8000586c:	b781                	j	800057ac <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000586e:	00003517          	auipc	a0,0x3
    80005872:	f0a50513          	addi	a0,a0,-246 # 80008778 <syscalls+0x2d0>
    80005876:	ffffb097          	auipc	ra,0xffffb
    8000587a:	cc8080e7          	jalr	-824(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000587e:	00003517          	auipc	a0,0x3
    80005882:	f1250513          	addi	a0,a0,-238 # 80008790 <syscalls+0x2e8>
    80005886:	ffffb097          	auipc	ra,0xffffb
    8000588a:	cb8080e7          	jalr	-840(ra) # 8000053e <panic>
    dp->nlink--;
    8000588e:	04a4d783          	lhu	a5,74(s1)
    80005892:	37fd                	addiw	a5,a5,-1
    80005894:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005898:	8526                	mv	a0,s1
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	fce080e7          	jalr	-50(ra) # 80003868 <iupdate>
    800058a2:	b781                	j	800057e2 <sys_unlink+0xe0>
    return -1;
    800058a4:	557d                	li	a0,-1
    800058a6:	a005                	j	800058c6 <sys_unlink+0x1c4>
    iunlockput(ip);
    800058a8:	854a                	mv	a0,s2
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	2ea080e7          	jalr	746(ra) # 80003b94 <iunlockput>
  iunlockput(dp);
    800058b2:	8526                	mv	a0,s1
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	2e0080e7          	jalr	736(ra) # 80003b94 <iunlockput>
  end_op();
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	ab8080e7          	jalr	-1352(ra) # 80004374 <end_op>
  return -1;
    800058c4:	557d                	li	a0,-1
}
    800058c6:	70ae                	ld	ra,232(sp)
    800058c8:	740e                	ld	s0,224(sp)
    800058ca:	64ee                	ld	s1,216(sp)
    800058cc:	694e                	ld	s2,208(sp)
    800058ce:	69ae                	ld	s3,200(sp)
    800058d0:	616d                	addi	sp,sp,240
    800058d2:	8082                	ret

00000000800058d4 <sys_open>:

uint64
sys_open(void)
{
    800058d4:	7131                	addi	sp,sp,-192
    800058d6:	fd06                	sd	ra,184(sp)
    800058d8:	f922                	sd	s0,176(sp)
    800058da:	f526                	sd	s1,168(sp)
    800058dc:	f14a                	sd	s2,160(sp)
    800058de:	ed4e                	sd	s3,152(sp)
    800058e0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058e2:	f4c40593          	addi	a1,s0,-180
    800058e6:	4505                	li	a0,1
    800058e8:	ffffd097          	auipc	ra,0xffffd
    800058ec:	442080e7          	jalr	1090(ra) # 80002d2a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058f0:	08000613          	li	a2,128
    800058f4:	f5040593          	addi	a1,s0,-176
    800058f8:	4501                	li	a0,0
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	470080e7          	jalr	1136(ra) # 80002d6a <argstr>
    80005902:	87aa                	mv	a5,a0
    return -1;
    80005904:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005906:	0a07c963          	bltz	a5,800059b8 <sys_open+0xe4>

  begin_op();
    8000590a:	fffff097          	auipc	ra,0xfffff
    8000590e:	9ea080e7          	jalr	-1558(ra) # 800042f4 <begin_op>

  if(omode & O_CREATE){
    80005912:	f4c42783          	lw	a5,-180(s0)
    80005916:	2007f793          	andi	a5,a5,512
    8000591a:	cfc5                	beqz	a5,800059d2 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000591c:	4681                	li	a3,0
    8000591e:	4601                	li	a2,0
    80005920:	4589                	li	a1,2
    80005922:	f5040513          	addi	a0,s0,-176
    80005926:	00000097          	auipc	ra,0x0
    8000592a:	976080e7          	jalr	-1674(ra) # 8000529c <create>
    8000592e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005930:	c959                	beqz	a0,800059c6 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005932:	04449703          	lh	a4,68(s1)
    80005936:	478d                	li	a5,3
    80005938:	00f71763          	bne	a4,a5,80005946 <sys_open+0x72>
    8000593c:	0464d703          	lhu	a4,70(s1)
    80005940:	47a5                	li	a5,9
    80005942:	0ce7ed63          	bltu	a5,a4,80005a1c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	dbe080e7          	jalr	-578(ra) # 80004704 <filealloc>
    8000594e:	89aa                	mv	s3,a0
    80005950:	10050363          	beqz	a0,80005a56 <sys_open+0x182>
    80005954:	00000097          	auipc	ra,0x0
    80005958:	906080e7          	jalr	-1786(ra) # 8000525a <fdalloc>
    8000595c:	892a                	mv	s2,a0
    8000595e:	0e054763          	bltz	a0,80005a4c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005962:	04449703          	lh	a4,68(s1)
    80005966:	478d                	li	a5,3
    80005968:	0cf70563          	beq	a4,a5,80005a32 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000596c:	4789                	li	a5,2
    8000596e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005972:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005976:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000597a:	f4c42783          	lw	a5,-180(s0)
    8000597e:	0017c713          	xori	a4,a5,1
    80005982:	8b05                	andi	a4,a4,1
    80005984:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005988:	0037f713          	andi	a4,a5,3
    8000598c:	00e03733          	snez	a4,a4
    80005990:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005994:	4007f793          	andi	a5,a5,1024
    80005998:	c791                	beqz	a5,800059a4 <sys_open+0xd0>
    8000599a:	04449703          	lh	a4,68(s1)
    8000599e:	4789                	li	a5,2
    800059a0:	0af70063          	beq	a4,a5,80005a40 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	04e080e7          	jalr	78(ra) # 800039f4 <iunlock>
  end_op();
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	9c6080e7          	jalr	-1594(ra) # 80004374 <end_op>

  return fd;
    800059b6:	854a                	mv	a0,s2
}
    800059b8:	70ea                	ld	ra,184(sp)
    800059ba:	744a                	ld	s0,176(sp)
    800059bc:	74aa                	ld	s1,168(sp)
    800059be:	790a                	ld	s2,160(sp)
    800059c0:	69ea                	ld	s3,152(sp)
    800059c2:	6129                	addi	sp,sp,192
    800059c4:	8082                	ret
      end_op();
    800059c6:	fffff097          	auipc	ra,0xfffff
    800059ca:	9ae080e7          	jalr	-1618(ra) # 80004374 <end_op>
      return -1;
    800059ce:	557d                	li	a0,-1
    800059d0:	b7e5                	j	800059b8 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059d2:	f5040513          	addi	a0,s0,-176
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	702080e7          	jalr	1794(ra) # 800040d8 <namei>
    800059de:	84aa                	mv	s1,a0
    800059e0:	c905                	beqz	a0,80005a10 <sys_open+0x13c>
    ilock(ip);
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	f50080e7          	jalr	-176(ra) # 80003932 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059ea:	04449703          	lh	a4,68(s1)
    800059ee:	4785                	li	a5,1
    800059f0:	f4f711e3          	bne	a4,a5,80005932 <sys_open+0x5e>
    800059f4:	f4c42783          	lw	a5,-180(s0)
    800059f8:	d7b9                	beqz	a5,80005946 <sys_open+0x72>
      iunlockput(ip);
    800059fa:	8526                	mv	a0,s1
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	198080e7          	jalr	408(ra) # 80003b94 <iunlockput>
      end_op();
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	970080e7          	jalr	-1680(ra) # 80004374 <end_op>
      return -1;
    80005a0c:	557d                	li	a0,-1
    80005a0e:	b76d                	j	800059b8 <sys_open+0xe4>
      end_op();
    80005a10:	fffff097          	auipc	ra,0xfffff
    80005a14:	964080e7          	jalr	-1692(ra) # 80004374 <end_op>
      return -1;
    80005a18:	557d                	li	a0,-1
    80005a1a:	bf79                	j	800059b8 <sys_open+0xe4>
    iunlockput(ip);
    80005a1c:	8526                	mv	a0,s1
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	176080e7          	jalr	374(ra) # 80003b94 <iunlockput>
    end_op();
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	94e080e7          	jalr	-1714(ra) # 80004374 <end_op>
    return -1;
    80005a2e:	557d                	li	a0,-1
    80005a30:	b761                	j	800059b8 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a32:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a36:	04649783          	lh	a5,70(s1)
    80005a3a:	02f99223          	sh	a5,36(s3)
    80005a3e:	bf25                	j	80005976 <sys_open+0xa2>
    itrunc(ip);
    80005a40:	8526                	mv	a0,s1
    80005a42:	ffffe097          	auipc	ra,0xffffe
    80005a46:	ffe080e7          	jalr	-2(ra) # 80003a40 <itrunc>
    80005a4a:	bfa9                	j	800059a4 <sys_open+0xd0>
      fileclose(f);
    80005a4c:	854e                	mv	a0,s3
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	d72080e7          	jalr	-654(ra) # 800047c0 <fileclose>
    iunlockput(ip);
    80005a56:	8526                	mv	a0,s1
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	13c080e7          	jalr	316(ra) # 80003b94 <iunlockput>
    end_op();
    80005a60:	fffff097          	auipc	ra,0xfffff
    80005a64:	914080e7          	jalr	-1772(ra) # 80004374 <end_op>
    return -1;
    80005a68:	557d                	li	a0,-1
    80005a6a:	b7b9                	j	800059b8 <sys_open+0xe4>

0000000080005a6c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a6c:	7175                	addi	sp,sp,-144
    80005a6e:	e506                	sd	ra,136(sp)
    80005a70:	e122                	sd	s0,128(sp)
    80005a72:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	880080e7          	jalr	-1920(ra) # 800042f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a7c:	08000613          	li	a2,128
    80005a80:	f7040593          	addi	a1,s0,-144
    80005a84:	4501                	li	a0,0
    80005a86:	ffffd097          	auipc	ra,0xffffd
    80005a8a:	2e4080e7          	jalr	740(ra) # 80002d6a <argstr>
    80005a8e:	02054963          	bltz	a0,80005ac0 <sys_mkdir+0x54>
    80005a92:	4681                	li	a3,0
    80005a94:	4601                	li	a2,0
    80005a96:	4585                	li	a1,1
    80005a98:	f7040513          	addi	a0,s0,-144
    80005a9c:	00000097          	auipc	ra,0x0
    80005aa0:	800080e7          	jalr	-2048(ra) # 8000529c <create>
    80005aa4:	cd11                	beqz	a0,80005ac0 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aa6:	ffffe097          	auipc	ra,0xffffe
    80005aaa:	0ee080e7          	jalr	238(ra) # 80003b94 <iunlockput>
  end_op();
    80005aae:	fffff097          	auipc	ra,0xfffff
    80005ab2:	8c6080e7          	jalr	-1850(ra) # 80004374 <end_op>
  return 0;
    80005ab6:	4501                	li	a0,0
}
    80005ab8:	60aa                	ld	ra,136(sp)
    80005aba:	640a                	ld	s0,128(sp)
    80005abc:	6149                	addi	sp,sp,144
    80005abe:	8082                	ret
    end_op();
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	8b4080e7          	jalr	-1868(ra) # 80004374 <end_op>
    return -1;
    80005ac8:	557d                	li	a0,-1
    80005aca:	b7fd                	j	80005ab8 <sys_mkdir+0x4c>

0000000080005acc <sys_mknod>:

uint64
sys_mknod(void)
{
    80005acc:	7135                	addi	sp,sp,-160
    80005ace:	ed06                	sd	ra,152(sp)
    80005ad0:	e922                	sd	s0,144(sp)
    80005ad2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	820080e7          	jalr	-2016(ra) # 800042f4 <begin_op>
  argint(1, &major);
    80005adc:	f6c40593          	addi	a1,s0,-148
    80005ae0:	4505                	li	a0,1
    80005ae2:	ffffd097          	auipc	ra,0xffffd
    80005ae6:	248080e7          	jalr	584(ra) # 80002d2a <argint>
  argint(2, &minor);
    80005aea:	f6840593          	addi	a1,s0,-152
    80005aee:	4509                	li	a0,2
    80005af0:	ffffd097          	auipc	ra,0xffffd
    80005af4:	23a080e7          	jalr	570(ra) # 80002d2a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005af8:	08000613          	li	a2,128
    80005afc:	f7040593          	addi	a1,s0,-144
    80005b00:	4501                	li	a0,0
    80005b02:	ffffd097          	auipc	ra,0xffffd
    80005b06:	268080e7          	jalr	616(ra) # 80002d6a <argstr>
    80005b0a:	02054b63          	bltz	a0,80005b40 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b0e:	f6841683          	lh	a3,-152(s0)
    80005b12:	f6c41603          	lh	a2,-148(s0)
    80005b16:	458d                	li	a1,3
    80005b18:	f7040513          	addi	a0,s0,-144
    80005b1c:	fffff097          	auipc	ra,0xfffff
    80005b20:	780080e7          	jalr	1920(ra) # 8000529c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b24:	cd11                	beqz	a0,80005b40 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b26:	ffffe097          	auipc	ra,0xffffe
    80005b2a:	06e080e7          	jalr	110(ra) # 80003b94 <iunlockput>
  end_op();
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	846080e7          	jalr	-1978(ra) # 80004374 <end_op>
  return 0;
    80005b36:	4501                	li	a0,0
}
    80005b38:	60ea                	ld	ra,152(sp)
    80005b3a:	644a                	ld	s0,144(sp)
    80005b3c:	610d                	addi	sp,sp,160
    80005b3e:	8082                	ret
    end_op();
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	834080e7          	jalr	-1996(ra) # 80004374 <end_op>
    return -1;
    80005b48:	557d                	li	a0,-1
    80005b4a:	b7fd                	j	80005b38 <sys_mknod+0x6c>

0000000080005b4c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b4c:	7135                	addi	sp,sp,-160
    80005b4e:	ed06                	sd	ra,152(sp)
    80005b50:	e922                	sd	s0,144(sp)
    80005b52:	e526                	sd	s1,136(sp)
    80005b54:	e14a                	sd	s2,128(sp)
    80005b56:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b58:	ffffc097          	auipc	ra,0xffffc
    80005b5c:	e74080e7          	jalr	-396(ra) # 800019cc <myproc>
    80005b60:	892a                	mv	s2,a0
  
  begin_op();
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	792080e7          	jalr	1938(ra) # 800042f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b6a:	08000613          	li	a2,128
    80005b6e:	f6040593          	addi	a1,s0,-160
    80005b72:	4501                	li	a0,0
    80005b74:	ffffd097          	auipc	ra,0xffffd
    80005b78:	1f6080e7          	jalr	502(ra) # 80002d6a <argstr>
    80005b7c:	04054b63          	bltz	a0,80005bd2 <sys_chdir+0x86>
    80005b80:	f6040513          	addi	a0,s0,-160
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	554080e7          	jalr	1364(ra) # 800040d8 <namei>
    80005b8c:	84aa                	mv	s1,a0
    80005b8e:	c131                	beqz	a0,80005bd2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	da2080e7          	jalr	-606(ra) # 80003932 <ilock>
  if(ip->type != T_DIR){
    80005b98:	04449703          	lh	a4,68(s1)
    80005b9c:	4785                	li	a5,1
    80005b9e:	04f71063          	bne	a4,a5,80005bde <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ba2:	8526                	mv	a0,s1
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	e50080e7          	jalr	-432(ra) # 800039f4 <iunlock>
  iput(p->cwd);
    80005bac:	15093503          	ld	a0,336(s2)
    80005bb0:	ffffe097          	auipc	ra,0xffffe
    80005bb4:	f3c080e7          	jalr	-196(ra) # 80003aec <iput>
  end_op();
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	7bc080e7          	jalr	1980(ra) # 80004374 <end_op>
  p->cwd = ip;
    80005bc0:	14993823          	sd	s1,336(s2)
  return 0;
    80005bc4:	4501                	li	a0,0
}
    80005bc6:	60ea                	ld	ra,152(sp)
    80005bc8:	644a                	ld	s0,144(sp)
    80005bca:	64aa                	ld	s1,136(sp)
    80005bcc:	690a                	ld	s2,128(sp)
    80005bce:	610d                	addi	sp,sp,160
    80005bd0:	8082                	ret
    end_op();
    80005bd2:	ffffe097          	auipc	ra,0xffffe
    80005bd6:	7a2080e7          	jalr	1954(ra) # 80004374 <end_op>
    return -1;
    80005bda:	557d                	li	a0,-1
    80005bdc:	b7ed                	j	80005bc6 <sys_chdir+0x7a>
    iunlockput(ip);
    80005bde:	8526                	mv	a0,s1
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	fb4080e7          	jalr	-76(ra) # 80003b94 <iunlockput>
    end_op();
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	78c080e7          	jalr	1932(ra) # 80004374 <end_op>
    return -1;
    80005bf0:	557d                	li	a0,-1
    80005bf2:	bfd1                	j	80005bc6 <sys_chdir+0x7a>

0000000080005bf4 <sys_exec>:

uint64
sys_exec(void)
{
    80005bf4:	7145                	addi	sp,sp,-464
    80005bf6:	e786                	sd	ra,456(sp)
    80005bf8:	e3a2                	sd	s0,448(sp)
    80005bfa:	ff26                	sd	s1,440(sp)
    80005bfc:	fb4a                	sd	s2,432(sp)
    80005bfe:	f74e                	sd	s3,424(sp)
    80005c00:	f352                	sd	s4,416(sp)
    80005c02:	ef56                	sd	s5,408(sp)
    80005c04:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c06:	e3840593          	addi	a1,s0,-456
    80005c0a:	4505                	li	a0,1
    80005c0c:	ffffd097          	auipc	ra,0xffffd
    80005c10:	13e080e7          	jalr	318(ra) # 80002d4a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c14:	08000613          	li	a2,128
    80005c18:	f4040593          	addi	a1,s0,-192
    80005c1c:	4501                	li	a0,0
    80005c1e:	ffffd097          	auipc	ra,0xffffd
    80005c22:	14c080e7          	jalr	332(ra) # 80002d6a <argstr>
    80005c26:	87aa                	mv	a5,a0
    return -1;
    80005c28:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c2a:	0c07c263          	bltz	a5,80005cee <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c2e:	10000613          	li	a2,256
    80005c32:	4581                	li	a1,0
    80005c34:	e4040513          	addi	a0,s0,-448
    80005c38:	ffffb097          	auipc	ra,0xffffb
    80005c3c:	09a080e7          	jalr	154(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c40:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c44:	89a6                	mv	s3,s1
    80005c46:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c48:	02000a13          	li	s4,32
    80005c4c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c50:	00391793          	slli	a5,s2,0x3
    80005c54:	e3040593          	addi	a1,s0,-464
    80005c58:	e3843503          	ld	a0,-456(s0)
    80005c5c:	953e                	add	a0,a0,a5
    80005c5e:	ffffd097          	auipc	ra,0xffffd
    80005c62:	02e080e7          	jalr	46(ra) # 80002c8c <fetchaddr>
    80005c66:	02054a63          	bltz	a0,80005c9a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c6a:	e3043783          	ld	a5,-464(s0)
    80005c6e:	c3b9                	beqz	a5,80005cb4 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c70:	ffffb097          	auipc	ra,0xffffb
    80005c74:	e76080e7          	jalr	-394(ra) # 80000ae6 <kalloc>
    80005c78:	85aa                	mv	a1,a0
    80005c7a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c7e:	cd11                	beqz	a0,80005c9a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c80:	6605                	lui	a2,0x1
    80005c82:	e3043503          	ld	a0,-464(s0)
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	058080e7          	jalr	88(ra) # 80002cde <fetchstr>
    80005c8e:	00054663          	bltz	a0,80005c9a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c92:	0905                	addi	s2,s2,1
    80005c94:	09a1                	addi	s3,s3,8
    80005c96:	fb491be3          	bne	s2,s4,80005c4c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c9a:	10048913          	addi	s2,s1,256
    80005c9e:	6088                	ld	a0,0(s1)
    80005ca0:	c531                	beqz	a0,80005cec <sys_exec+0xf8>
    kfree(argv[i]);
    80005ca2:	ffffb097          	auipc	ra,0xffffb
    80005ca6:	d48080e7          	jalr	-696(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005caa:	04a1                	addi	s1,s1,8
    80005cac:	ff2499e3          	bne	s1,s2,80005c9e <sys_exec+0xaa>
  return -1;
    80005cb0:	557d                	li	a0,-1
    80005cb2:	a835                	j	80005cee <sys_exec+0xfa>
      argv[i] = 0;
    80005cb4:	0a8e                	slli	s5,s5,0x3
    80005cb6:	fc040793          	addi	a5,s0,-64
    80005cba:	9abe                	add	s5,s5,a5
    80005cbc:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005cc0:	e4040593          	addi	a1,s0,-448
    80005cc4:	f4040513          	addi	a0,s0,-192
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	172080e7          	jalr	370(ra) # 80004e3a <exec>
    80005cd0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cd2:	10048993          	addi	s3,s1,256
    80005cd6:	6088                	ld	a0,0(s1)
    80005cd8:	c901                	beqz	a0,80005ce8 <sys_exec+0xf4>
    kfree(argv[i]);
    80005cda:	ffffb097          	auipc	ra,0xffffb
    80005cde:	d10080e7          	jalr	-752(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce2:	04a1                	addi	s1,s1,8
    80005ce4:	ff3499e3          	bne	s1,s3,80005cd6 <sys_exec+0xe2>
  return ret;
    80005ce8:	854a                	mv	a0,s2
    80005cea:	a011                	j	80005cee <sys_exec+0xfa>
  return -1;
    80005cec:	557d                	li	a0,-1
}
    80005cee:	60be                	ld	ra,456(sp)
    80005cf0:	641e                	ld	s0,448(sp)
    80005cf2:	74fa                	ld	s1,440(sp)
    80005cf4:	795a                	ld	s2,432(sp)
    80005cf6:	79ba                	ld	s3,424(sp)
    80005cf8:	7a1a                	ld	s4,416(sp)
    80005cfa:	6afa                	ld	s5,408(sp)
    80005cfc:	6179                	addi	sp,sp,464
    80005cfe:	8082                	ret

0000000080005d00 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d00:	7139                	addi	sp,sp,-64
    80005d02:	fc06                	sd	ra,56(sp)
    80005d04:	f822                	sd	s0,48(sp)
    80005d06:	f426                	sd	s1,40(sp)
    80005d08:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d0a:	ffffc097          	auipc	ra,0xffffc
    80005d0e:	cc2080e7          	jalr	-830(ra) # 800019cc <myproc>
    80005d12:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d14:	fd840593          	addi	a1,s0,-40
    80005d18:	4501                	li	a0,0
    80005d1a:	ffffd097          	auipc	ra,0xffffd
    80005d1e:	030080e7          	jalr	48(ra) # 80002d4a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d22:	fc840593          	addi	a1,s0,-56
    80005d26:	fd040513          	addi	a0,s0,-48
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	dc6080e7          	jalr	-570(ra) # 80004af0 <pipealloc>
    return -1;
    80005d32:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d34:	0c054463          	bltz	a0,80005dfc <sys_pipe+0xfc>
  fd0 = -1;
    80005d38:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d3c:	fd043503          	ld	a0,-48(s0)
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	51a080e7          	jalr	1306(ra) # 8000525a <fdalloc>
    80005d48:	fca42223          	sw	a0,-60(s0)
    80005d4c:	08054b63          	bltz	a0,80005de2 <sys_pipe+0xe2>
    80005d50:	fc843503          	ld	a0,-56(s0)
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	506080e7          	jalr	1286(ra) # 8000525a <fdalloc>
    80005d5c:	fca42023          	sw	a0,-64(s0)
    80005d60:	06054863          	bltz	a0,80005dd0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d64:	4691                	li	a3,4
    80005d66:	fc440613          	addi	a2,s0,-60
    80005d6a:	fd843583          	ld	a1,-40(s0)
    80005d6e:	68a8                	ld	a0,80(s1)
    80005d70:	ffffc097          	auipc	ra,0xffffc
    80005d74:	918080e7          	jalr	-1768(ra) # 80001688 <copyout>
    80005d78:	02054063          	bltz	a0,80005d98 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d7c:	4691                	li	a3,4
    80005d7e:	fc040613          	addi	a2,s0,-64
    80005d82:	fd843583          	ld	a1,-40(s0)
    80005d86:	0591                	addi	a1,a1,4
    80005d88:	68a8                	ld	a0,80(s1)
    80005d8a:	ffffc097          	auipc	ra,0xffffc
    80005d8e:	8fe080e7          	jalr	-1794(ra) # 80001688 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d92:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d94:	06055463          	bgez	a0,80005dfc <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d98:	fc442783          	lw	a5,-60(s0)
    80005d9c:	07e9                	addi	a5,a5,26
    80005d9e:	078e                	slli	a5,a5,0x3
    80005da0:	97a6                	add	a5,a5,s1
    80005da2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005da6:	fc042503          	lw	a0,-64(s0)
    80005daa:	0569                	addi	a0,a0,26
    80005dac:	050e                	slli	a0,a0,0x3
    80005dae:	94aa                	add	s1,s1,a0
    80005db0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005db4:	fd043503          	ld	a0,-48(s0)
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	a08080e7          	jalr	-1528(ra) # 800047c0 <fileclose>
    fileclose(wf);
    80005dc0:	fc843503          	ld	a0,-56(s0)
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	9fc080e7          	jalr	-1540(ra) # 800047c0 <fileclose>
    return -1;
    80005dcc:	57fd                	li	a5,-1
    80005dce:	a03d                	j	80005dfc <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005dd0:	fc442783          	lw	a5,-60(s0)
    80005dd4:	0007c763          	bltz	a5,80005de2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005dd8:	07e9                	addi	a5,a5,26
    80005dda:	078e                	slli	a5,a5,0x3
    80005ddc:	94be                	add	s1,s1,a5
    80005dde:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005de2:	fd043503          	ld	a0,-48(s0)
    80005de6:	fffff097          	auipc	ra,0xfffff
    80005dea:	9da080e7          	jalr	-1574(ra) # 800047c0 <fileclose>
    fileclose(wf);
    80005dee:	fc843503          	ld	a0,-56(s0)
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	9ce080e7          	jalr	-1586(ra) # 800047c0 <fileclose>
    return -1;
    80005dfa:	57fd                	li	a5,-1
}
    80005dfc:	853e                	mv	a0,a5
    80005dfe:	70e2                	ld	ra,56(sp)
    80005e00:	7442                	ld	s0,48(sp)
    80005e02:	74a2                	ld	s1,40(sp)
    80005e04:	6121                	addi	sp,sp,64
    80005e06:	8082                	ret
	...

0000000080005e10 <kernelvec>:
    80005e10:	7111                	addi	sp,sp,-256
    80005e12:	e006                	sd	ra,0(sp)
    80005e14:	e40a                	sd	sp,8(sp)
    80005e16:	e80e                	sd	gp,16(sp)
    80005e18:	ec12                	sd	tp,24(sp)
    80005e1a:	f016                	sd	t0,32(sp)
    80005e1c:	f41a                	sd	t1,40(sp)
    80005e1e:	f81e                	sd	t2,48(sp)
    80005e20:	fc22                	sd	s0,56(sp)
    80005e22:	e0a6                	sd	s1,64(sp)
    80005e24:	e4aa                	sd	a0,72(sp)
    80005e26:	e8ae                	sd	a1,80(sp)
    80005e28:	ecb2                	sd	a2,88(sp)
    80005e2a:	f0b6                	sd	a3,96(sp)
    80005e2c:	f4ba                	sd	a4,104(sp)
    80005e2e:	f8be                	sd	a5,112(sp)
    80005e30:	fcc2                	sd	a6,120(sp)
    80005e32:	e146                	sd	a7,128(sp)
    80005e34:	e54a                	sd	s2,136(sp)
    80005e36:	e94e                	sd	s3,144(sp)
    80005e38:	ed52                	sd	s4,152(sp)
    80005e3a:	f156                	sd	s5,160(sp)
    80005e3c:	f55a                	sd	s6,168(sp)
    80005e3e:	f95e                	sd	s7,176(sp)
    80005e40:	fd62                	sd	s8,184(sp)
    80005e42:	e1e6                	sd	s9,192(sp)
    80005e44:	e5ea                	sd	s10,200(sp)
    80005e46:	e9ee                	sd	s11,208(sp)
    80005e48:	edf2                	sd	t3,216(sp)
    80005e4a:	f1f6                	sd	t4,224(sp)
    80005e4c:	f5fa                	sd	t5,232(sp)
    80005e4e:	f9fe                	sd	t6,240(sp)
    80005e50:	d09fc0ef          	jal	ra,80002b58 <kerneltrap>
    80005e54:	6082                	ld	ra,0(sp)
    80005e56:	6122                	ld	sp,8(sp)
    80005e58:	61c2                	ld	gp,16(sp)
    80005e5a:	7282                	ld	t0,32(sp)
    80005e5c:	7322                	ld	t1,40(sp)
    80005e5e:	73c2                	ld	t2,48(sp)
    80005e60:	7462                	ld	s0,56(sp)
    80005e62:	6486                	ld	s1,64(sp)
    80005e64:	6526                	ld	a0,72(sp)
    80005e66:	65c6                	ld	a1,80(sp)
    80005e68:	6666                	ld	a2,88(sp)
    80005e6a:	7686                	ld	a3,96(sp)
    80005e6c:	7726                	ld	a4,104(sp)
    80005e6e:	77c6                	ld	a5,112(sp)
    80005e70:	7866                	ld	a6,120(sp)
    80005e72:	688a                	ld	a7,128(sp)
    80005e74:	692a                	ld	s2,136(sp)
    80005e76:	69ca                	ld	s3,144(sp)
    80005e78:	6a6a                	ld	s4,152(sp)
    80005e7a:	7a8a                	ld	s5,160(sp)
    80005e7c:	7b2a                	ld	s6,168(sp)
    80005e7e:	7bca                	ld	s7,176(sp)
    80005e80:	7c6a                	ld	s8,184(sp)
    80005e82:	6c8e                	ld	s9,192(sp)
    80005e84:	6d2e                	ld	s10,200(sp)
    80005e86:	6dce                	ld	s11,208(sp)
    80005e88:	6e6e                	ld	t3,216(sp)
    80005e8a:	7e8e                	ld	t4,224(sp)
    80005e8c:	7f2e                	ld	t5,232(sp)
    80005e8e:	7fce                	ld	t6,240(sp)
    80005e90:	6111                	addi	sp,sp,256
    80005e92:	10200073          	sret
    80005e96:	00000013          	nop
    80005e9a:	00000013          	nop
    80005e9e:	0001                	nop

0000000080005ea0 <timervec>:
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	e10c                	sd	a1,0(a0)
    80005ea6:	e510                	sd	a2,8(a0)
    80005ea8:	e914                	sd	a3,16(a0)
    80005eaa:	6d0c                	ld	a1,24(a0)
    80005eac:	7110                	ld	a2,32(a0)
    80005eae:	6194                	ld	a3,0(a1)
    80005eb0:	96b2                	add	a3,a3,a2
    80005eb2:	e194                	sd	a3,0(a1)
    80005eb4:	4589                	li	a1,2
    80005eb6:	14459073          	csrw	sip,a1
    80005eba:	6914                	ld	a3,16(a0)
    80005ebc:	6510                	ld	a2,8(a0)
    80005ebe:	610c                	ld	a1,0(a0)
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	30200073          	mret
	...

0000000080005eca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eca:	1141                	addi	sp,sp,-16
    80005ecc:	e422                	sd	s0,8(sp)
    80005ece:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ed0:	0c0007b7          	lui	a5,0xc000
    80005ed4:	4705                	li	a4,1
    80005ed6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ed8:	c3d8                	sw	a4,4(a5)
}
    80005eda:	6422                	ld	s0,8(sp)
    80005edc:	0141                	addi	sp,sp,16
    80005ede:	8082                	ret

0000000080005ee0 <plicinithart>:

void
plicinithart(void)
{
    80005ee0:	1141                	addi	sp,sp,-16
    80005ee2:	e406                	sd	ra,8(sp)
    80005ee4:	e022                	sd	s0,0(sp)
    80005ee6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ee8:	ffffc097          	auipc	ra,0xffffc
    80005eec:	ab8080e7          	jalr	-1352(ra) # 800019a0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ef0:	0085171b          	slliw	a4,a0,0x8
    80005ef4:	0c0027b7          	lui	a5,0xc002
    80005ef8:	97ba                	add	a5,a5,a4
    80005efa:	40200713          	li	a4,1026
    80005efe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f02:	00d5151b          	slliw	a0,a0,0xd
    80005f06:	0c2017b7          	lui	a5,0xc201
    80005f0a:	953e                	add	a0,a0,a5
    80005f0c:	00052023          	sw	zero,0(a0)
}
    80005f10:	60a2                	ld	ra,8(sp)
    80005f12:	6402                	ld	s0,0(sp)
    80005f14:	0141                	addi	sp,sp,16
    80005f16:	8082                	ret

0000000080005f18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f18:	1141                	addi	sp,sp,-16
    80005f1a:	e406                	sd	ra,8(sp)
    80005f1c:	e022                	sd	s0,0(sp)
    80005f1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f20:	ffffc097          	auipc	ra,0xffffc
    80005f24:	a80080e7          	jalr	-1408(ra) # 800019a0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f28:	00d5179b          	slliw	a5,a0,0xd
    80005f2c:	0c201537          	lui	a0,0xc201
    80005f30:	953e                	add	a0,a0,a5
  return irq;
}
    80005f32:	4148                	lw	a0,4(a0)
    80005f34:	60a2                	ld	ra,8(sp)
    80005f36:	6402                	ld	s0,0(sp)
    80005f38:	0141                	addi	sp,sp,16
    80005f3a:	8082                	ret

0000000080005f3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f3c:	1101                	addi	sp,sp,-32
    80005f3e:	ec06                	sd	ra,24(sp)
    80005f40:	e822                	sd	s0,16(sp)
    80005f42:	e426                	sd	s1,8(sp)
    80005f44:	1000                	addi	s0,sp,32
    80005f46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f48:	ffffc097          	auipc	ra,0xffffc
    80005f4c:	a58080e7          	jalr	-1448(ra) # 800019a0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f50:	00d5151b          	slliw	a0,a0,0xd
    80005f54:	0c2017b7          	lui	a5,0xc201
    80005f58:	97aa                	add	a5,a5,a0
    80005f5a:	c3c4                	sw	s1,4(a5)
}
    80005f5c:	60e2                	ld	ra,24(sp)
    80005f5e:	6442                	ld	s0,16(sp)
    80005f60:	64a2                	ld	s1,8(sp)
    80005f62:	6105                	addi	sp,sp,32
    80005f64:	8082                	ret

0000000080005f66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f66:	1141                	addi	sp,sp,-16
    80005f68:	e406                	sd	ra,8(sp)
    80005f6a:	e022                	sd	s0,0(sp)
    80005f6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f6e:	479d                	li	a5,7
    80005f70:	04a7cc63          	blt	a5,a0,80005fc8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f74:	0001c797          	auipc	a5,0x1c
    80005f78:	0ec78793          	addi	a5,a5,236 # 80022060 <disk>
    80005f7c:	97aa                	add	a5,a5,a0
    80005f7e:	0187c783          	lbu	a5,24(a5)
    80005f82:	ebb9                	bnez	a5,80005fd8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f84:	00451613          	slli	a2,a0,0x4
    80005f88:	0001c797          	auipc	a5,0x1c
    80005f8c:	0d878793          	addi	a5,a5,216 # 80022060 <disk>
    80005f90:	6394                	ld	a3,0(a5)
    80005f92:	96b2                	add	a3,a3,a2
    80005f94:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005f98:	6398                	ld	a4,0(a5)
    80005f9a:	9732                	add	a4,a4,a2
    80005f9c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fa0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005fa4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005fa8:	953e                	add	a0,a0,a5
    80005faa:	4785                	li	a5,1
    80005fac:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005fb0:	0001c517          	auipc	a0,0x1c
    80005fb4:	0c850513          	addi	a0,a0,200 # 80022078 <disk+0x18>
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	1fe080e7          	jalr	510(ra) # 800021b6 <wakeup>
}
    80005fc0:	60a2                	ld	ra,8(sp)
    80005fc2:	6402                	ld	s0,0(sp)
    80005fc4:	0141                	addi	sp,sp,16
    80005fc6:	8082                	ret
    panic("free_desc 1");
    80005fc8:	00002517          	auipc	a0,0x2
    80005fcc:	7d850513          	addi	a0,a0,2008 # 800087a0 <syscalls+0x2f8>
    80005fd0:	ffffa097          	auipc	ra,0xffffa
    80005fd4:	56e080e7          	jalr	1390(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005fd8:	00002517          	auipc	a0,0x2
    80005fdc:	7d850513          	addi	a0,a0,2008 # 800087b0 <syscalls+0x308>
    80005fe0:	ffffa097          	auipc	ra,0xffffa
    80005fe4:	55e080e7          	jalr	1374(ra) # 8000053e <panic>

0000000080005fe8 <virtio_disk_init>:
{
    80005fe8:	1101                	addi	sp,sp,-32
    80005fea:	ec06                	sd	ra,24(sp)
    80005fec:	e822                	sd	s0,16(sp)
    80005fee:	e426                	sd	s1,8(sp)
    80005ff0:	e04a                	sd	s2,0(sp)
    80005ff2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ff4:	00002597          	auipc	a1,0x2
    80005ff8:	7cc58593          	addi	a1,a1,1996 # 800087c0 <syscalls+0x318>
    80005ffc:	0001c517          	auipc	a0,0x1c
    80006000:	18c50513          	addi	a0,a0,396 # 80022188 <disk+0x128>
    80006004:	ffffb097          	auipc	ra,0xffffb
    80006008:	b42080e7          	jalr	-1214(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	4398                	lw	a4,0(a5)
    80006012:	2701                	sext.w	a4,a4
    80006014:	747277b7          	lui	a5,0x74727
    80006018:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000601c:	14f71c63          	bne	a4,a5,80006174 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006020:	100017b7          	lui	a5,0x10001
    80006024:	43dc                	lw	a5,4(a5)
    80006026:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006028:	4709                	li	a4,2
    8000602a:	14e79563          	bne	a5,a4,80006174 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000602e:	100017b7          	lui	a5,0x10001
    80006032:	479c                	lw	a5,8(a5)
    80006034:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006036:	12e79f63          	bne	a5,a4,80006174 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000603a:	100017b7          	lui	a5,0x10001
    8000603e:	47d8                	lw	a4,12(a5)
    80006040:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006042:	554d47b7          	lui	a5,0x554d4
    80006046:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000604a:	12f71563          	bne	a4,a5,80006174 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604e:	100017b7          	lui	a5,0x10001
    80006052:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006056:	4705                	li	a4,1
    80006058:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605a:	470d                	li	a4,3
    8000605c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000605e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006060:	c7ffe737          	lui	a4,0xc7ffe
    80006064:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc5bf>
    80006068:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000606a:	2701                	sext.w	a4,a4
    8000606c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606e:	472d                	li	a4,11
    80006070:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006072:	5bbc                	lw	a5,112(a5)
    80006074:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006078:	8ba1                	andi	a5,a5,8
    8000607a:	10078563          	beqz	a5,80006184 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000607e:	100017b7          	lui	a5,0x10001
    80006082:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006086:	43fc                	lw	a5,68(a5)
    80006088:	2781                	sext.w	a5,a5
    8000608a:	10079563          	bnez	a5,80006194 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000608e:	100017b7          	lui	a5,0x10001
    80006092:	5bdc                	lw	a5,52(a5)
    80006094:	2781                	sext.w	a5,a5
  if(max == 0)
    80006096:	10078763          	beqz	a5,800061a4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000609a:	471d                	li	a4,7
    8000609c:	10f77c63          	bgeu	a4,a5,800061b4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800060a0:	ffffb097          	auipc	ra,0xffffb
    800060a4:	a46080e7          	jalr	-1466(ra) # 80000ae6 <kalloc>
    800060a8:	0001c497          	auipc	s1,0x1c
    800060ac:	fb848493          	addi	s1,s1,-72 # 80022060 <disk>
    800060b0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060b2:	ffffb097          	auipc	ra,0xffffb
    800060b6:	a34080e7          	jalr	-1484(ra) # 80000ae6 <kalloc>
    800060ba:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060bc:	ffffb097          	auipc	ra,0xffffb
    800060c0:	a2a080e7          	jalr	-1494(ra) # 80000ae6 <kalloc>
    800060c4:	87aa                	mv	a5,a0
    800060c6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060c8:	6088                	ld	a0,0(s1)
    800060ca:	cd6d                	beqz	a0,800061c4 <virtio_disk_init+0x1dc>
    800060cc:	0001c717          	auipc	a4,0x1c
    800060d0:	f9c73703          	ld	a4,-100(a4) # 80022068 <disk+0x8>
    800060d4:	cb65                	beqz	a4,800061c4 <virtio_disk_init+0x1dc>
    800060d6:	c7fd                	beqz	a5,800061c4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800060d8:	6605                	lui	a2,0x1
    800060da:	4581                	li	a1,0
    800060dc:	ffffb097          	auipc	ra,0xffffb
    800060e0:	bf6080e7          	jalr	-1034(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060e4:	0001c497          	auipc	s1,0x1c
    800060e8:	f7c48493          	addi	s1,s1,-132 # 80022060 <disk>
    800060ec:	6605                	lui	a2,0x1
    800060ee:	4581                	li	a1,0
    800060f0:	6488                	ld	a0,8(s1)
    800060f2:	ffffb097          	auipc	ra,0xffffb
    800060f6:	be0080e7          	jalr	-1056(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800060fa:	6605                	lui	a2,0x1
    800060fc:	4581                	li	a1,0
    800060fe:	6888                	ld	a0,16(s1)
    80006100:	ffffb097          	auipc	ra,0xffffb
    80006104:	bd2080e7          	jalr	-1070(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006108:	100017b7          	lui	a5,0x10001
    8000610c:	4721                	li	a4,8
    8000610e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006110:	4098                	lw	a4,0(s1)
    80006112:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006116:	40d8                	lw	a4,4(s1)
    80006118:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000611c:	6498                	ld	a4,8(s1)
    8000611e:	0007069b          	sext.w	a3,a4
    80006122:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006126:	9701                	srai	a4,a4,0x20
    80006128:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000612c:	6898                	ld	a4,16(s1)
    8000612e:	0007069b          	sext.w	a3,a4
    80006132:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006136:	9701                	srai	a4,a4,0x20
    80006138:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000613c:	4705                	li	a4,1
    8000613e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006140:	00e48c23          	sb	a4,24(s1)
    80006144:	00e48ca3          	sb	a4,25(s1)
    80006148:	00e48d23          	sb	a4,26(s1)
    8000614c:	00e48da3          	sb	a4,27(s1)
    80006150:	00e48e23          	sb	a4,28(s1)
    80006154:	00e48ea3          	sb	a4,29(s1)
    80006158:	00e48f23          	sb	a4,30(s1)
    8000615c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006160:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006164:	0727a823          	sw	s2,112(a5)
}
    80006168:	60e2                	ld	ra,24(sp)
    8000616a:	6442                	ld	s0,16(sp)
    8000616c:	64a2                	ld	s1,8(sp)
    8000616e:	6902                	ld	s2,0(sp)
    80006170:	6105                	addi	sp,sp,32
    80006172:	8082                	ret
    panic("could not find virtio disk");
    80006174:	00002517          	auipc	a0,0x2
    80006178:	65c50513          	addi	a0,a0,1628 # 800087d0 <syscalls+0x328>
    8000617c:	ffffa097          	auipc	ra,0xffffa
    80006180:	3c2080e7          	jalr	962(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006184:	00002517          	auipc	a0,0x2
    80006188:	66c50513          	addi	a0,a0,1644 # 800087f0 <syscalls+0x348>
    8000618c:	ffffa097          	auipc	ra,0xffffa
    80006190:	3b2080e7          	jalr	946(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006194:	00002517          	auipc	a0,0x2
    80006198:	67c50513          	addi	a0,a0,1660 # 80008810 <syscalls+0x368>
    8000619c:	ffffa097          	auipc	ra,0xffffa
    800061a0:	3a2080e7          	jalr	930(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	68c50513          	addi	a0,a0,1676 # 80008830 <syscalls+0x388>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	392080e7          	jalr	914(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	69c50513          	addi	a0,a0,1692 # 80008850 <syscalls+0x3a8>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	382080e7          	jalr	898(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800061c4:	00002517          	auipc	a0,0x2
    800061c8:	6ac50513          	addi	a0,a0,1708 # 80008870 <syscalls+0x3c8>
    800061cc:	ffffa097          	auipc	ra,0xffffa
    800061d0:	372080e7          	jalr	882(ra) # 8000053e <panic>

00000000800061d4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061d4:	7119                	addi	sp,sp,-128
    800061d6:	fc86                	sd	ra,120(sp)
    800061d8:	f8a2                	sd	s0,112(sp)
    800061da:	f4a6                	sd	s1,104(sp)
    800061dc:	f0ca                	sd	s2,96(sp)
    800061de:	ecce                	sd	s3,88(sp)
    800061e0:	e8d2                	sd	s4,80(sp)
    800061e2:	e4d6                	sd	s5,72(sp)
    800061e4:	e0da                	sd	s6,64(sp)
    800061e6:	fc5e                	sd	s7,56(sp)
    800061e8:	f862                	sd	s8,48(sp)
    800061ea:	f466                	sd	s9,40(sp)
    800061ec:	f06a                	sd	s10,32(sp)
    800061ee:	ec6e                	sd	s11,24(sp)
    800061f0:	0100                	addi	s0,sp,128
    800061f2:	8aaa                	mv	s5,a0
    800061f4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061f6:	00c52d03          	lw	s10,12(a0)
    800061fa:	001d1d1b          	slliw	s10,s10,0x1
    800061fe:	1d02                	slli	s10,s10,0x20
    80006200:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006204:	0001c517          	auipc	a0,0x1c
    80006208:	f8450513          	addi	a0,a0,-124 # 80022188 <disk+0x128>
    8000620c:	ffffb097          	auipc	ra,0xffffb
    80006210:	9ca080e7          	jalr	-1590(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006214:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006216:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006218:	0001cb97          	auipc	s7,0x1c
    8000621c:	e48b8b93          	addi	s7,s7,-440 # 80022060 <disk>
  for(int i = 0; i < 3; i++){
    80006220:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006222:	0001cc97          	auipc	s9,0x1c
    80006226:	f66c8c93          	addi	s9,s9,-154 # 80022188 <disk+0x128>
    8000622a:	a08d                	j	8000628c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000622c:	00fb8733          	add	a4,s7,a5
    80006230:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006234:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006236:	0207c563          	bltz	a5,80006260 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000623a:	2905                	addiw	s2,s2,1
    8000623c:	0611                	addi	a2,a2,4
    8000623e:	05690c63          	beq	s2,s6,80006296 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006242:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006244:	0001c717          	auipc	a4,0x1c
    80006248:	e1c70713          	addi	a4,a4,-484 # 80022060 <disk>
    8000624c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000624e:	01874683          	lbu	a3,24(a4)
    80006252:	fee9                	bnez	a3,8000622c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006254:	2785                	addiw	a5,a5,1
    80006256:	0705                	addi	a4,a4,1
    80006258:	fe979be3          	bne	a5,s1,8000624e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000625c:	57fd                	li	a5,-1
    8000625e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006260:	01205d63          	blez	s2,8000627a <virtio_disk_rw+0xa6>
    80006264:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006266:	000a2503          	lw	a0,0(s4)
    8000626a:	00000097          	auipc	ra,0x0
    8000626e:	cfc080e7          	jalr	-772(ra) # 80005f66 <free_desc>
      for(int j = 0; j < i; j++)
    80006272:	2d85                	addiw	s11,s11,1
    80006274:	0a11                	addi	s4,s4,4
    80006276:	ffb918e3          	bne	s2,s11,80006266 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000627a:	85e6                	mv	a1,s9
    8000627c:	0001c517          	auipc	a0,0x1c
    80006280:	dfc50513          	addi	a0,a0,-516 # 80022078 <disk+0x18>
    80006284:	ffffc097          	auipc	ra,0xffffc
    80006288:	ece080e7          	jalr	-306(ra) # 80002152 <sleep>
  for(int i = 0; i < 3; i++){
    8000628c:	f8040a13          	addi	s4,s0,-128
{
    80006290:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006292:	894e                	mv	s2,s3
    80006294:	b77d                	j	80006242 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006296:	f8042583          	lw	a1,-128(s0)
    8000629a:	00a58793          	addi	a5,a1,10
    8000629e:	0792                	slli	a5,a5,0x4

  if(write)
    800062a0:	0001c617          	auipc	a2,0x1c
    800062a4:	dc060613          	addi	a2,a2,-576 # 80022060 <disk>
    800062a8:	00f60733          	add	a4,a2,a5
    800062ac:	018036b3          	snez	a3,s8
    800062b0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062b2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062b6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062ba:	f6078693          	addi	a3,a5,-160
    800062be:	6218                	ld	a4,0(a2)
    800062c0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062c2:	00878513          	addi	a0,a5,8
    800062c6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062c8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062ca:	6208                	ld	a0,0(a2)
    800062cc:	96aa                	add	a3,a3,a0
    800062ce:	4741                	li	a4,16
    800062d0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062d2:	4705                	li	a4,1
    800062d4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800062d8:	f8442703          	lw	a4,-124(s0)
    800062dc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062e0:	0712                	slli	a4,a4,0x4
    800062e2:	953a                	add	a0,a0,a4
    800062e4:	058a8693          	addi	a3,s5,88
    800062e8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800062ea:	6208                	ld	a0,0(a2)
    800062ec:	972a                	add	a4,a4,a0
    800062ee:	40000693          	li	a3,1024
    800062f2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800062f4:	001c3c13          	seqz	s8,s8
    800062f8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062fa:	001c6c13          	ori	s8,s8,1
    800062fe:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006302:	f8842603          	lw	a2,-120(s0)
    80006306:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000630a:	0001c697          	auipc	a3,0x1c
    8000630e:	d5668693          	addi	a3,a3,-682 # 80022060 <disk>
    80006312:	00258713          	addi	a4,a1,2
    80006316:	0712                	slli	a4,a4,0x4
    80006318:	9736                	add	a4,a4,a3
    8000631a:	587d                	li	a6,-1
    8000631c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006320:	0612                	slli	a2,a2,0x4
    80006322:	9532                	add	a0,a0,a2
    80006324:	f9078793          	addi	a5,a5,-112
    80006328:	97b6                	add	a5,a5,a3
    8000632a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000632c:	629c                	ld	a5,0(a3)
    8000632e:	97b2                	add	a5,a5,a2
    80006330:	4605                	li	a2,1
    80006332:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006334:	4509                	li	a0,2
    80006336:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000633a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000633e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006342:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006346:	6698                	ld	a4,8(a3)
    80006348:	00275783          	lhu	a5,2(a4)
    8000634c:	8b9d                	andi	a5,a5,7
    8000634e:	0786                	slli	a5,a5,0x1
    80006350:	97ba                	add	a5,a5,a4
    80006352:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006356:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000635a:	6698                	ld	a4,8(a3)
    8000635c:	00275783          	lhu	a5,2(a4)
    80006360:	2785                	addiw	a5,a5,1
    80006362:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006366:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000636a:	100017b7          	lui	a5,0x10001
    8000636e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006372:	004aa783          	lw	a5,4(s5)
    80006376:	02c79163          	bne	a5,a2,80006398 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000637a:	0001c917          	auipc	s2,0x1c
    8000637e:	e0e90913          	addi	s2,s2,-498 # 80022188 <disk+0x128>
  while(b->disk == 1) {
    80006382:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006384:	85ca                	mv	a1,s2
    80006386:	8556                	mv	a0,s5
    80006388:	ffffc097          	auipc	ra,0xffffc
    8000638c:	dca080e7          	jalr	-566(ra) # 80002152 <sleep>
  while(b->disk == 1) {
    80006390:	004aa783          	lw	a5,4(s5)
    80006394:	fe9788e3          	beq	a5,s1,80006384 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006398:	f8042903          	lw	s2,-128(s0)
    8000639c:	00290793          	addi	a5,s2,2
    800063a0:	00479713          	slli	a4,a5,0x4
    800063a4:	0001c797          	auipc	a5,0x1c
    800063a8:	cbc78793          	addi	a5,a5,-836 # 80022060 <disk>
    800063ac:	97ba                	add	a5,a5,a4
    800063ae:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063b2:	0001c997          	auipc	s3,0x1c
    800063b6:	cae98993          	addi	s3,s3,-850 # 80022060 <disk>
    800063ba:	00491713          	slli	a4,s2,0x4
    800063be:	0009b783          	ld	a5,0(s3)
    800063c2:	97ba                	add	a5,a5,a4
    800063c4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063c8:	854a                	mv	a0,s2
    800063ca:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063ce:	00000097          	auipc	ra,0x0
    800063d2:	b98080e7          	jalr	-1128(ra) # 80005f66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063d6:	8885                	andi	s1,s1,1
    800063d8:	f0ed                	bnez	s1,800063ba <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063da:	0001c517          	auipc	a0,0x1c
    800063de:	dae50513          	addi	a0,a0,-594 # 80022188 <disk+0x128>
    800063e2:	ffffb097          	auipc	ra,0xffffb
    800063e6:	8a8080e7          	jalr	-1880(ra) # 80000c8a <release>
}
    800063ea:	70e6                	ld	ra,120(sp)
    800063ec:	7446                	ld	s0,112(sp)
    800063ee:	74a6                	ld	s1,104(sp)
    800063f0:	7906                	ld	s2,96(sp)
    800063f2:	69e6                	ld	s3,88(sp)
    800063f4:	6a46                	ld	s4,80(sp)
    800063f6:	6aa6                	ld	s5,72(sp)
    800063f8:	6b06                	ld	s6,64(sp)
    800063fa:	7be2                	ld	s7,56(sp)
    800063fc:	7c42                	ld	s8,48(sp)
    800063fe:	7ca2                	ld	s9,40(sp)
    80006400:	7d02                	ld	s10,32(sp)
    80006402:	6de2                	ld	s11,24(sp)
    80006404:	6109                	addi	sp,sp,128
    80006406:	8082                	ret

0000000080006408 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006408:	1101                	addi	sp,sp,-32
    8000640a:	ec06                	sd	ra,24(sp)
    8000640c:	e822                	sd	s0,16(sp)
    8000640e:	e426                	sd	s1,8(sp)
    80006410:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006412:	0001c497          	auipc	s1,0x1c
    80006416:	c4e48493          	addi	s1,s1,-946 # 80022060 <disk>
    8000641a:	0001c517          	auipc	a0,0x1c
    8000641e:	d6e50513          	addi	a0,a0,-658 # 80022188 <disk+0x128>
    80006422:	ffffa097          	auipc	ra,0xffffa
    80006426:	7b4080e7          	jalr	1972(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000642a:	10001737          	lui	a4,0x10001
    8000642e:	533c                	lw	a5,96(a4)
    80006430:	8b8d                	andi	a5,a5,3
    80006432:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006434:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006438:	689c                	ld	a5,16(s1)
    8000643a:	0204d703          	lhu	a4,32(s1)
    8000643e:	0027d783          	lhu	a5,2(a5)
    80006442:	04f70863          	beq	a4,a5,80006492 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006446:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000644a:	6898                	ld	a4,16(s1)
    8000644c:	0204d783          	lhu	a5,32(s1)
    80006450:	8b9d                	andi	a5,a5,7
    80006452:	078e                	slli	a5,a5,0x3
    80006454:	97ba                	add	a5,a5,a4
    80006456:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006458:	00278713          	addi	a4,a5,2
    8000645c:	0712                	slli	a4,a4,0x4
    8000645e:	9726                	add	a4,a4,s1
    80006460:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006464:	e721                	bnez	a4,800064ac <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006466:	0789                	addi	a5,a5,2
    80006468:	0792                	slli	a5,a5,0x4
    8000646a:	97a6                	add	a5,a5,s1
    8000646c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000646e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006472:	ffffc097          	auipc	ra,0xffffc
    80006476:	d44080e7          	jalr	-700(ra) # 800021b6 <wakeup>

    disk.used_idx += 1;
    8000647a:	0204d783          	lhu	a5,32(s1)
    8000647e:	2785                	addiw	a5,a5,1
    80006480:	17c2                	slli	a5,a5,0x30
    80006482:	93c1                	srli	a5,a5,0x30
    80006484:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006488:	6898                	ld	a4,16(s1)
    8000648a:	00275703          	lhu	a4,2(a4)
    8000648e:	faf71ce3          	bne	a4,a5,80006446 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006492:	0001c517          	auipc	a0,0x1c
    80006496:	cf650513          	addi	a0,a0,-778 # 80022188 <disk+0x128>
    8000649a:	ffffa097          	auipc	ra,0xffffa
    8000649e:	7f0080e7          	jalr	2032(ra) # 80000c8a <release>
}
    800064a2:	60e2                	ld	ra,24(sp)
    800064a4:	6442                	ld	s0,16(sp)
    800064a6:	64a2                	ld	s1,8(sp)
    800064a8:	6105                	addi	sp,sp,32
    800064aa:	8082                	ret
      panic("virtio_disk_intr status");
    800064ac:	00002517          	auipc	a0,0x2
    800064b0:	3dc50513          	addi	a0,a0,988 # 80008888 <syscalls+0x3e0>
    800064b4:	ffffa097          	auipc	ra,0xffffa
    800064b8:	08a080e7          	jalr	138(ra) # 8000053e <panic>
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
