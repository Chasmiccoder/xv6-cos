
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
    80000068:	b4c78793          	addi	a5,a5,-1204 # 80005bb0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca8f>
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
    80000130:	396080e7          	jalr	918(ra) # 800024c2 <either_copyin>
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
    800001cc:	144080e7          	jalr	324(ra) # 8000230c <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e8e080e7          	jalr	-370(ra) # 80002064 <sleep>
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
    80000216:	25a080e7          	jalr	602(ra) # 8000246c <either_copyout>
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
    800002f6:	226080e7          	jalr	550(ra) # 80002518 <procdump>
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
    8000044a:	c82080e7          	jalr	-894(ra) # 800020c8 <wakeup>
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
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	76078793          	addi	a5,a5,1888 # 80020bd8 <devsw>
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
    80000896:	836080e7          	jalr	-1994(ra) # 800020c8 <wakeup>
    
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
    80000920:	748080e7          	jalr	1864(ra) # 80002064 <sleep>
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
    80000a02:	37278793          	addi	a5,a5,882 # 80021d70 <end>
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
    80000ad2:	2a250513          	addi	a0,a0,674 # 80021d70 <end>
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
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	79a080e7          	jalr	1946(ra) # 80002658 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	d2a080e7          	jalr	-726(ra) # 80005bf0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fe4080e7          	jalr	-28(ra) # 80001eb2 <scheduler>
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
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	6ea080e7          	jalr	1770(ra) # 80002630 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4e:	00001097          	auipc	ra,0x1
    80000f52:	70a080e7          	jalr	1802(ra) # 80002658 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f56:	00005097          	auipc	ra,0x5
    80000f5a:	c84080e7          	jalr	-892(ra) # 80005bda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5e:	00005097          	auipc	ra,0x5
    80000f62:	c92080e7          	jalr	-878(ra) # 80005bf0 <plicinithart>
    binit();         // buffer cache
    80000f66:	00002097          	auipc	ra,0x2
    80000f6a:	e2e080e7          	jalr	-466(ra) # 80002d94 <binit>
    iinit();         // inode table
    80000f6e:	00002097          	auipc	ra,0x2
    80000f72:	4d2080e7          	jalr	1234(ra) # 80003440 <iinit>
    fileinit();      // file table
    80000f76:	00003097          	auipc	ra,0x3
    80000f7a:	470080e7          	jalr	1136(ra) # 800043e6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	d7a080e7          	jalr	-646(ra) # 80005cf8 <virtio_disk_init>
    userinit();      // first user process
    80000f86:	00001097          	auipc	ra,0x1
    80000f8a:	d0e080e7          	jalr	-754(ra) # 80001c94 <userinit>
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
    8000187a:	11aa0a13          	addi	s4,s4,282 # 80016990 <tickslock>
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
    800018b0:	16848493          	addi	s1,s1,360
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
    80001946:	04e98993          	addi	s3,s3,78 # 80016990 <tickslock>
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
    80001974:	16848493          	addi	s1,s1,360
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
    80001a1a:	c5a080e7          	jalr	-934(ra) # 80002670 <usertrapret>
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
    80001a34:	990080e7          	jalr	-1648(ra) # 800033c0 <fsinit>
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
    80001bde:	db690913          	addi	s2,s2,-586 # 80016990 <tickslock>
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
    80001bfa:	16848493          	addi	s1,s1,360
    80001bfe:	ff2492e3          	bne	s1,s2,80001be2 <allocproc+0x1c>
  return 0;
    80001c02:	4481                	li	s1,0
    80001c04:	a889                	j	80001c56 <allocproc+0x90>
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
    80001c20:	c131                	beqz	a0,80001c64 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c22:	8526                	mv	a0,s1
    80001c24:	00000097          	auipc	ra,0x0
    80001c28:	e5c080e7          	jalr	-420(ra) # 80001a80 <proc_pagetable>
    80001c2c:	892a                	mv	s2,a0
    80001c2e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c30:	c531                	beqz	a0,80001c7c <allocproc+0xb6>
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
}
    80001c56:	8526                	mv	a0,s1
    80001c58:	60e2                	ld	ra,24(sp)
    80001c5a:	6442                	ld	s0,16(sp)
    80001c5c:	64a2                	ld	s1,8(sp)
    80001c5e:	6902                	ld	s2,0(sp)
    80001c60:	6105                	addi	sp,sp,32
    80001c62:	8082                	ret
    freeproc(p);
    80001c64:	8526                	mv	a0,s1
    80001c66:	00000097          	auipc	ra,0x0
    80001c6a:	f08080e7          	jalr	-248(ra) # 80001b6e <freeproc>
    release(&p->lock);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	01a080e7          	jalr	26(ra) # 80000c8a <release>
    return 0;
    80001c78:	84ca                	mv	s1,s2
    80001c7a:	bff1                	j	80001c56 <allocproc+0x90>
    freeproc(p);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	00000097          	auipc	ra,0x0
    80001c82:	ef0080e7          	jalr	-272(ra) # 80001b6e <freeproc>
    release(&p->lock);
    80001c86:	8526                	mv	a0,s1
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	002080e7          	jalr	2(ra) # 80000c8a <release>
    return 0;
    80001c90:	84ca                	mv	s1,s2
    80001c92:	b7d1                	j	80001c56 <allocproc+0x90>

0000000080001c94 <userinit>:
{
    80001c94:	1101                	addi	sp,sp,-32
    80001c96:	ec06                	sd	ra,24(sp)
    80001c98:	e822                	sd	s0,16(sp)
    80001c9a:	e426                	sd	s1,8(sp)
    80001c9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	f28080e7          	jalr	-216(ra) # 80001bc6 <allocproc>
    80001ca6:	84aa                	mv	s1,a0
  initproc = p;
    80001ca8:	00007797          	auipc	a5,0x7
    80001cac:	c4a7b023          	sd	a0,-960(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cb0:	03400613          	li	a2,52
    80001cb4:	00007597          	auipc	a1,0x7
    80001cb8:	bcc58593          	addi	a1,a1,-1076 # 80008880 <initcode>
    80001cbc:	6928                	ld	a0,80(a0)
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	6a8080e7          	jalr	1704(ra) # 80001366 <uvmfirst>
  p->sz = PGSIZE;
    80001cc6:	6785                	lui	a5,0x1
    80001cc8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cca:	6cb8                	ld	a4,88(s1)
    80001ccc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cd0:	6cb8                	ld	a4,88(s1)
    80001cd2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cd4:	4641                	li	a2,16
    80001cd6:	00006597          	auipc	a1,0x6
    80001cda:	55258593          	addi	a1,a1,1362 # 80008228 <digits+0x1e8>
    80001cde:	15848513          	addi	a0,s1,344
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	13a080e7          	jalr	314(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cea:	00006517          	auipc	a0,0x6
    80001cee:	54e50513          	addi	a0,a0,1358 # 80008238 <digits+0x1f8>
    80001cf2:	00002097          	auipc	ra,0x2
    80001cf6:	0f0080e7          	jalr	240(ra) # 80003de2 <namei>
    80001cfa:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cfe:	478d                	li	a5,3
    80001d00:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d02:	8526                	mv	a0,s1
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	f86080e7          	jalr	-122(ra) # 80000c8a <release>
}
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret

0000000080001d16 <growproc>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	e04a                	sd	s2,0(sp)
    80001d20:	1000                	addi	s0,sp,32
    80001d22:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	c98080e7          	jalr	-872(ra) # 800019bc <myproc>
    80001d2c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d2e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d30:	01204c63          	bgtz	s2,80001d48 <growproc+0x32>
  } else if(n < 0){
    80001d34:	02094663          	bltz	s2,80001d60 <growproc+0x4a>
  p->sz = sz;
    80001d38:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d3a:	4501                	li	a0,0
}
    80001d3c:	60e2                	ld	ra,24(sp)
    80001d3e:	6442                	ld	s0,16(sp)
    80001d40:	64a2                	ld	s1,8(sp)
    80001d42:	6902                	ld	s2,0(sp)
    80001d44:	6105                	addi	sp,sp,32
    80001d46:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d48:	4691                	li	a3,4
    80001d4a:	00b90633          	add	a2,s2,a1
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	6d0080e7          	jalr	1744(ra) # 80001420 <uvmalloc>
    80001d58:	85aa                	mv	a1,a0
    80001d5a:	fd79                	bnez	a0,80001d38 <growproc+0x22>
      return -1;
    80001d5c:	557d                	li	a0,-1
    80001d5e:	bff9                	j	80001d3c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d60:	00b90633          	add	a2,s2,a1
    80001d64:	6928                	ld	a0,80(a0)
    80001d66:	fffff097          	auipc	ra,0xfffff
    80001d6a:	672080e7          	jalr	1650(ra) # 800013d8 <uvmdealloc>
    80001d6e:	85aa                	mv	a1,a0
    80001d70:	b7e1                	j	80001d38 <growproc+0x22>

0000000080001d72 <fork>:
{
    80001d72:	7139                	addi	sp,sp,-64
    80001d74:	fc06                	sd	ra,56(sp)
    80001d76:	f822                	sd	s0,48(sp)
    80001d78:	f426                	sd	s1,40(sp)
    80001d7a:	f04a                	sd	s2,32(sp)
    80001d7c:	ec4e                	sd	s3,24(sp)
    80001d7e:	e852                	sd	s4,16(sp)
    80001d80:	e456                	sd	s5,8(sp)
    80001d82:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d84:	00000097          	auipc	ra,0x0
    80001d88:	c38080e7          	jalr	-968(ra) # 800019bc <myproc>
    80001d8c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d8e:	00000097          	auipc	ra,0x0
    80001d92:	e38080e7          	jalr	-456(ra) # 80001bc6 <allocproc>
    80001d96:	10050c63          	beqz	a0,80001eae <fork+0x13c>
    80001d9a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d9c:	048ab603          	ld	a2,72(s5)
    80001da0:	692c                	ld	a1,80(a0)
    80001da2:	050ab503          	ld	a0,80(s5)
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	7ce080e7          	jalr	1998(ra) # 80001574 <uvmcopy>
    80001dae:	04054863          	bltz	a0,80001dfe <fork+0x8c>
  np->sz = p->sz;
    80001db2:	048ab783          	ld	a5,72(s5)
    80001db6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dba:	058ab683          	ld	a3,88(s5)
    80001dbe:	87b6                	mv	a5,a3
    80001dc0:	058a3703          	ld	a4,88(s4)
    80001dc4:	12068693          	addi	a3,a3,288
    80001dc8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dcc:	6788                	ld	a0,8(a5)
    80001dce:	6b8c                	ld	a1,16(a5)
    80001dd0:	6f90                	ld	a2,24(a5)
    80001dd2:	01073023          	sd	a6,0(a4)
    80001dd6:	e708                	sd	a0,8(a4)
    80001dd8:	eb0c                	sd	a1,16(a4)
    80001dda:	ef10                	sd	a2,24(a4)
    80001ddc:	02078793          	addi	a5,a5,32
    80001de0:	02070713          	addi	a4,a4,32
    80001de4:	fed792e3          	bne	a5,a3,80001dc8 <fork+0x56>
  np->trapframe->a0 = 0;
    80001de8:	058a3783          	ld	a5,88(s4)
    80001dec:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001df0:	0d0a8493          	addi	s1,s5,208
    80001df4:	0d0a0913          	addi	s2,s4,208
    80001df8:	150a8993          	addi	s3,s5,336
    80001dfc:	a00d                	j	80001e1e <fork+0xac>
    freeproc(np);
    80001dfe:	8552                	mv	a0,s4
    80001e00:	00000097          	auipc	ra,0x0
    80001e04:	d6e080e7          	jalr	-658(ra) # 80001b6e <freeproc>
    release(&np->lock);
    80001e08:	8552                	mv	a0,s4
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	e80080e7          	jalr	-384(ra) # 80000c8a <release>
    return -1;
    80001e12:	597d                	li	s2,-1
    80001e14:	a059                	j	80001e9a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e16:	04a1                	addi	s1,s1,8
    80001e18:	0921                	addi	s2,s2,8
    80001e1a:	01348b63          	beq	s1,s3,80001e30 <fork+0xbe>
    if(p->ofile[i])
    80001e1e:	6088                	ld	a0,0(s1)
    80001e20:	d97d                	beqz	a0,80001e16 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e22:	00002097          	auipc	ra,0x2
    80001e26:	656080e7          	jalr	1622(ra) # 80004478 <filedup>
    80001e2a:	00a93023          	sd	a0,0(s2)
    80001e2e:	b7e5                	j	80001e16 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e30:	150ab503          	ld	a0,336(s5)
    80001e34:	00001097          	auipc	ra,0x1
    80001e38:	7ca080e7          	jalr	1994(ra) # 800035fe <idup>
    80001e3c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e40:	4641                	li	a2,16
    80001e42:	158a8593          	addi	a1,s5,344
    80001e46:	158a0513          	addi	a0,s4,344
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	fd2080e7          	jalr	-46(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e52:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e56:	8552                	mv	a0,s4
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	e32080e7          	jalr	-462(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e60:	0000f497          	auipc	s1,0xf
    80001e64:	d1848493          	addi	s1,s1,-744 # 80010b78 <wait_lock>
    80001e68:	8526                	mv	a0,s1
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	d6c080e7          	jalr	-660(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e72:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e76:	8526                	mv	a0,s1
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	e12080e7          	jalr	-494(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	d54080e7          	jalr	-684(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e8a:	478d                	li	a5,3
    80001e8c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e90:	8552                	mv	a0,s4
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	df8080e7          	jalr	-520(ra) # 80000c8a <release>
}
    80001e9a:	854a                	mv	a0,s2
    80001e9c:	70e2                	ld	ra,56(sp)
    80001e9e:	7442                	ld	s0,48(sp)
    80001ea0:	74a2                	ld	s1,40(sp)
    80001ea2:	7902                	ld	s2,32(sp)
    80001ea4:	69e2                	ld	s3,24(sp)
    80001ea6:	6a42                	ld	s4,16(sp)
    80001ea8:	6aa2                	ld	s5,8(sp)
    80001eaa:	6121                	addi	sp,sp,64
    80001eac:	8082                	ret
    return -1;
    80001eae:	597d                	li	s2,-1
    80001eb0:	b7ed                	j	80001e9a <fork+0x128>

0000000080001eb2 <scheduler>:
{
    80001eb2:	7139                	addi	sp,sp,-64
    80001eb4:	fc06                	sd	ra,56(sp)
    80001eb6:	f822                	sd	s0,48(sp)
    80001eb8:	f426                	sd	s1,40(sp)
    80001eba:	f04a                	sd	s2,32(sp)
    80001ebc:	ec4e                	sd	s3,24(sp)
    80001ebe:	e852                	sd	s4,16(sp)
    80001ec0:	e456                	sd	s5,8(sp)
    80001ec2:	e05a                	sd	s6,0(sp)
    80001ec4:	0080                	addi	s0,sp,64
    80001ec6:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eca:	00779a93          	slli	s5,a5,0x7
    80001ece:	0000f717          	auipc	a4,0xf
    80001ed2:	c9270713          	addi	a4,a4,-878 # 80010b60 <pid_lock>
    80001ed6:	9756                	add	a4,a4,s5
    80001ed8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001edc:	0000f717          	auipc	a4,0xf
    80001ee0:	cbc70713          	addi	a4,a4,-836 # 80010b98 <cpus+0x8>
    80001ee4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ee6:	498d                	li	s3,3
        p->state = RUNNING;
    80001ee8:	4b11                	li	s6,4
        c->proc = p;
    80001eea:	079e                	slli	a5,a5,0x7
    80001eec:	0000fa17          	auipc	s4,0xf
    80001ef0:	c74a0a13          	addi	s4,s4,-908 # 80010b60 <pid_lock>
    80001ef4:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ef6:	00015917          	auipc	s2,0x15
    80001efa:	a9a90913          	addi	s2,s2,-1382 # 80016990 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001efe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f02:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f06:	10079073          	csrw	sstatus,a5
    80001f0a:	0000f497          	auipc	s1,0xf
    80001f0e:	08648493          	addi	s1,s1,134 # 80010f90 <proc>
    80001f12:	a811                	j	80001f26 <scheduler+0x74>
      release(&p->lock);
    80001f14:	8526                	mv	a0,s1
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	d74080e7          	jalr	-652(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1e:	16848493          	addi	s1,s1,360
    80001f22:	fd248ee3          	beq	s1,s2,80001efe <scheduler+0x4c>
      acquire(&p->lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	cae080e7          	jalr	-850(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f30:	4c9c                	lw	a5,24(s1)
    80001f32:	ff3791e3          	bne	a5,s3,80001f14 <scheduler+0x62>
        p->state = RUNNING;
    80001f36:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f3a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f3e:	06048593          	addi	a1,s1,96
    80001f42:	8556                	mv	a0,s5
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	682080e7          	jalr	1666(ra) # 800025c6 <swtch>
        c->proc = 0;
    80001f4c:	020a3823          	sd	zero,48(s4)
    80001f50:	b7d1                	j	80001f14 <scheduler+0x62>

0000000080001f52 <sched>:
{
    80001f52:	7179                	addi	sp,sp,-48
    80001f54:	f406                	sd	ra,40(sp)
    80001f56:	f022                	sd	s0,32(sp)
    80001f58:	ec26                	sd	s1,24(sp)
    80001f5a:	e84a                	sd	s2,16(sp)
    80001f5c:	e44e                	sd	s3,8(sp)
    80001f5e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f60:	00000097          	auipc	ra,0x0
    80001f64:	a5c080e7          	jalr	-1444(ra) # 800019bc <myproc>
    80001f68:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	bf2080e7          	jalr	-1038(ra) # 80000b5c <holding>
    80001f72:	c93d                	beqz	a0,80001fe8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f74:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f76:	2781                	sext.w	a5,a5
    80001f78:	079e                	slli	a5,a5,0x7
    80001f7a:	0000f717          	auipc	a4,0xf
    80001f7e:	be670713          	addi	a4,a4,-1050 # 80010b60 <pid_lock>
    80001f82:	97ba                	add	a5,a5,a4
    80001f84:	0a87a703          	lw	a4,168(a5)
    80001f88:	4785                	li	a5,1
    80001f8a:	06f71763          	bne	a4,a5,80001ff8 <sched+0xa6>
  if(p->state == RUNNING)
    80001f8e:	4c98                	lw	a4,24(s1)
    80001f90:	4791                	li	a5,4
    80001f92:	06f70b63          	beq	a4,a5,80002008 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f96:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f9a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f9c:	efb5                	bnez	a5,80002018 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f9e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fa0:	0000f917          	auipc	s2,0xf
    80001fa4:	bc090913          	addi	s2,s2,-1088 # 80010b60 <pid_lock>
    80001fa8:	2781                	sext.w	a5,a5
    80001faa:	079e                	slli	a5,a5,0x7
    80001fac:	97ca                	add	a5,a5,s2
    80001fae:	0ac7a983          	lw	s3,172(a5)
    80001fb2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fb4:	2781                	sext.w	a5,a5
    80001fb6:	079e                	slli	a5,a5,0x7
    80001fb8:	0000f597          	auipc	a1,0xf
    80001fbc:	be058593          	addi	a1,a1,-1056 # 80010b98 <cpus+0x8>
    80001fc0:	95be                	add	a1,a1,a5
    80001fc2:	06048513          	addi	a0,s1,96
    80001fc6:	00000097          	auipc	ra,0x0
    80001fca:	600080e7          	jalr	1536(ra) # 800025c6 <swtch>
    80001fce:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fd0:	2781                	sext.w	a5,a5
    80001fd2:	079e                	slli	a5,a5,0x7
    80001fd4:	97ca                	add	a5,a5,s2
    80001fd6:	0b37a623          	sw	s3,172(a5)
}
    80001fda:	70a2                	ld	ra,40(sp)
    80001fdc:	7402                	ld	s0,32(sp)
    80001fde:	64e2                	ld	s1,24(sp)
    80001fe0:	6942                	ld	s2,16(sp)
    80001fe2:	69a2                	ld	s3,8(sp)
    80001fe4:	6145                	addi	sp,sp,48
    80001fe6:	8082                	ret
    panic("sched p->lock");
    80001fe8:	00006517          	auipc	a0,0x6
    80001fec:	25850513          	addi	a0,a0,600 # 80008240 <digits+0x200>
    80001ff0:	ffffe097          	auipc	ra,0xffffe
    80001ff4:	54e080e7          	jalr	1358(ra) # 8000053e <panic>
    panic("sched locks");
    80001ff8:	00006517          	auipc	a0,0x6
    80001ffc:	25850513          	addi	a0,a0,600 # 80008250 <digits+0x210>
    80002000:	ffffe097          	auipc	ra,0xffffe
    80002004:	53e080e7          	jalr	1342(ra) # 8000053e <panic>
    panic("sched running");
    80002008:	00006517          	auipc	a0,0x6
    8000200c:	25850513          	addi	a0,a0,600 # 80008260 <digits+0x220>
    80002010:	ffffe097          	auipc	ra,0xffffe
    80002014:	52e080e7          	jalr	1326(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002018:	00006517          	auipc	a0,0x6
    8000201c:	25850513          	addi	a0,a0,600 # 80008270 <digits+0x230>
    80002020:	ffffe097          	auipc	ra,0xffffe
    80002024:	51e080e7          	jalr	1310(ra) # 8000053e <panic>

0000000080002028 <yield>:
{
    80002028:	1101                	addi	sp,sp,-32
    8000202a:	ec06                	sd	ra,24(sp)
    8000202c:	e822                	sd	s0,16(sp)
    8000202e:	e426                	sd	s1,8(sp)
    80002030:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002032:	00000097          	auipc	ra,0x0
    80002036:	98a080e7          	jalr	-1654(ra) # 800019bc <myproc>
    8000203a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	b9a080e7          	jalr	-1126(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002044:	478d                	li	a5,3
    80002046:	cc9c                	sw	a5,24(s1)
  sched();
    80002048:	00000097          	auipc	ra,0x0
    8000204c:	f0a080e7          	jalr	-246(ra) # 80001f52 <sched>
  release(&p->lock);
    80002050:	8526                	mv	a0,s1
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	c38080e7          	jalr	-968(ra) # 80000c8a <release>
}
    8000205a:	60e2                	ld	ra,24(sp)
    8000205c:	6442                	ld	s0,16(sp)
    8000205e:	64a2                	ld	s1,8(sp)
    80002060:	6105                	addi	sp,sp,32
    80002062:	8082                	ret

0000000080002064 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002064:	7179                	addi	sp,sp,-48
    80002066:	f406                	sd	ra,40(sp)
    80002068:	f022                	sd	s0,32(sp)
    8000206a:	ec26                	sd	s1,24(sp)
    8000206c:	e84a                	sd	s2,16(sp)
    8000206e:	e44e                	sd	s3,8(sp)
    80002070:	1800                	addi	s0,sp,48
    80002072:	89aa                	mv	s3,a0
    80002074:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002076:	00000097          	auipc	ra,0x0
    8000207a:	946080e7          	jalr	-1722(ra) # 800019bc <myproc>
    8000207e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	b56080e7          	jalr	-1194(ra) # 80000bd6 <acquire>
  release(lk);
    80002088:	854a                	mv	a0,s2
    8000208a:	fffff097          	auipc	ra,0xfffff
    8000208e:	c00080e7          	jalr	-1024(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002092:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002096:	4789                	li	a5,2
    80002098:	cc9c                	sw	a5,24(s1)

  sched();
    8000209a:	00000097          	auipc	ra,0x0
    8000209e:	eb8080e7          	jalr	-328(ra) # 80001f52 <sched>

  // Tidy up.
  p->chan = 0;
    800020a2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	be2080e7          	jalr	-1054(ra) # 80000c8a <release>
  acquire(lk);
    800020b0:	854a                	mv	a0,s2
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	b24080e7          	jalr	-1244(ra) # 80000bd6 <acquire>
}
    800020ba:	70a2                	ld	ra,40(sp)
    800020bc:	7402                	ld	s0,32(sp)
    800020be:	64e2                	ld	s1,24(sp)
    800020c0:	6942                	ld	s2,16(sp)
    800020c2:	69a2                	ld	s3,8(sp)
    800020c4:	6145                	addi	sp,sp,48
    800020c6:	8082                	ret

00000000800020c8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020c8:	7139                	addi	sp,sp,-64
    800020ca:	fc06                	sd	ra,56(sp)
    800020cc:	f822                	sd	s0,48(sp)
    800020ce:	f426                	sd	s1,40(sp)
    800020d0:	f04a                	sd	s2,32(sp)
    800020d2:	ec4e                	sd	s3,24(sp)
    800020d4:	e852                	sd	s4,16(sp)
    800020d6:	e456                	sd	s5,8(sp)
    800020d8:	0080                	addi	s0,sp,64
    800020da:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020dc:	0000f497          	auipc	s1,0xf
    800020e0:	eb448493          	addi	s1,s1,-332 # 80010f90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020e4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020e6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e8:	00015917          	auipc	s2,0x15
    800020ec:	8a890913          	addi	s2,s2,-1880 # 80016990 <tickslock>
    800020f0:	a811                	j	80002104 <wakeup+0x3c>
      }
      release(&p->lock);
    800020f2:	8526                	mv	a0,s1
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	b96080e7          	jalr	-1130(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020fc:	16848493          	addi	s1,s1,360
    80002100:	03248663          	beq	s1,s2,8000212c <wakeup+0x64>
    if(p != myproc()){
    80002104:	00000097          	auipc	ra,0x0
    80002108:	8b8080e7          	jalr	-1864(ra) # 800019bc <myproc>
    8000210c:	fea488e3          	beq	s1,a0,800020fc <wakeup+0x34>
      acquire(&p->lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	ac4080e7          	jalr	-1340(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000211a:	4c9c                	lw	a5,24(s1)
    8000211c:	fd379be3          	bne	a5,s3,800020f2 <wakeup+0x2a>
    80002120:	709c                	ld	a5,32(s1)
    80002122:	fd4798e3          	bne	a5,s4,800020f2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002126:	0154ac23          	sw	s5,24(s1)
    8000212a:	b7e1                	j	800020f2 <wakeup+0x2a>
    }
  }
}
    8000212c:	70e2                	ld	ra,56(sp)
    8000212e:	7442                	ld	s0,48(sp)
    80002130:	74a2                	ld	s1,40(sp)
    80002132:	7902                	ld	s2,32(sp)
    80002134:	69e2                	ld	s3,24(sp)
    80002136:	6a42                	ld	s4,16(sp)
    80002138:	6aa2                	ld	s5,8(sp)
    8000213a:	6121                	addi	sp,sp,64
    8000213c:	8082                	ret

000000008000213e <reparent>:
{
    8000213e:	7179                	addi	sp,sp,-48
    80002140:	f406                	sd	ra,40(sp)
    80002142:	f022                	sd	s0,32(sp)
    80002144:	ec26                	sd	s1,24(sp)
    80002146:	e84a                	sd	s2,16(sp)
    80002148:	e44e                	sd	s3,8(sp)
    8000214a:	e052                	sd	s4,0(sp)
    8000214c:	1800                	addi	s0,sp,48
    8000214e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002150:	0000f497          	auipc	s1,0xf
    80002154:	e4048493          	addi	s1,s1,-448 # 80010f90 <proc>
      pp->parent = initproc;
    80002158:	00006a17          	auipc	s4,0x6
    8000215c:	790a0a13          	addi	s4,s4,1936 # 800088e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002160:	00015997          	auipc	s3,0x15
    80002164:	83098993          	addi	s3,s3,-2000 # 80016990 <tickslock>
    80002168:	a029                	j	80002172 <reparent+0x34>
    8000216a:	16848493          	addi	s1,s1,360
    8000216e:	01348d63          	beq	s1,s3,80002188 <reparent+0x4a>
    if(pp->parent == p){
    80002172:	7c9c                	ld	a5,56(s1)
    80002174:	ff279be3          	bne	a5,s2,8000216a <reparent+0x2c>
      pp->parent = initproc;
    80002178:	000a3503          	ld	a0,0(s4)
    8000217c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000217e:	00000097          	auipc	ra,0x0
    80002182:	f4a080e7          	jalr	-182(ra) # 800020c8 <wakeup>
    80002186:	b7d5                	j	8000216a <reparent+0x2c>
}
    80002188:	70a2                	ld	ra,40(sp)
    8000218a:	7402                	ld	s0,32(sp)
    8000218c:	64e2                	ld	s1,24(sp)
    8000218e:	6942                	ld	s2,16(sp)
    80002190:	69a2                	ld	s3,8(sp)
    80002192:	6a02                	ld	s4,0(sp)
    80002194:	6145                	addi	sp,sp,48
    80002196:	8082                	ret

0000000080002198 <exit>:
{
    80002198:	7179                	addi	sp,sp,-48
    8000219a:	f406                	sd	ra,40(sp)
    8000219c:	f022                	sd	s0,32(sp)
    8000219e:	ec26                	sd	s1,24(sp)
    800021a0:	e84a                	sd	s2,16(sp)
    800021a2:	e44e                	sd	s3,8(sp)
    800021a4:	e052                	sd	s4,0(sp)
    800021a6:	1800                	addi	s0,sp,48
    800021a8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021aa:	00000097          	auipc	ra,0x0
    800021ae:	812080e7          	jalr	-2030(ra) # 800019bc <myproc>
    800021b2:	89aa                	mv	s3,a0
  if(p == initproc)
    800021b4:	00006797          	auipc	a5,0x6
    800021b8:	7347b783          	ld	a5,1844(a5) # 800088e8 <initproc>
    800021bc:	0d050493          	addi	s1,a0,208
    800021c0:	15050913          	addi	s2,a0,336
    800021c4:	02a79363          	bne	a5,a0,800021ea <exit+0x52>
    panic("init exiting");
    800021c8:	00006517          	auipc	a0,0x6
    800021cc:	0c050513          	addi	a0,a0,192 # 80008288 <digits+0x248>
    800021d0:	ffffe097          	auipc	ra,0xffffe
    800021d4:	36e080e7          	jalr	878(ra) # 8000053e <panic>
      fileclose(f);
    800021d8:	00002097          	auipc	ra,0x2
    800021dc:	2f2080e7          	jalr	754(ra) # 800044ca <fileclose>
      p->ofile[fd] = 0;
    800021e0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021e4:	04a1                	addi	s1,s1,8
    800021e6:	01248563          	beq	s1,s2,800021f0 <exit+0x58>
    if(p->ofile[fd]){
    800021ea:	6088                	ld	a0,0(s1)
    800021ec:	f575                	bnez	a0,800021d8 <exit+0x40>
    800021ee:	bfdd                	j	800021e4 <exit+0x4c>
  begin_op();
    800021f0:	00002097          	auipc	ra,0x2
    800021f4:	e0e080e7          	jalr	-498(ra) # 80003ffe <begin_op>
  iput(p->cwd);
    800021f8:	1509b503          	ld	a0,336(s3)
    800021fc:	00001097          	auipc	ra,0x1
    80002200:	5fa080e7          	jalr	1530(ra) # 800037f6 <iput>
  end_op();
    80002204:	00002097          	auipc	ra,0x2
    80002208:	e7a080e7          	jalr	-390(ra) # 8000407e <end_op>
  p->cwd = 0;
    8000220c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002210:	0000f497          	auipc	s1,0xf
    80002214:	96848493          	addi	s1,s1,-1688 # 80010b78 <wait_lock>
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	9bc080e7          	jalr	-1604(ra) # 80000bd6 <acquire>
  reparent(p);
    80002222:	854e                	mv	a0,s3
    80002224:	00000097          	auipc	ra,0x0
    80002228:	f1a080e7          	jalr	-230(ra) # 8000213e <reparent>
  wakeup(p->parent);
    8000222c:	0389b503          	ld	a0,56(s3)
    80002230:	00000097          	auipc	ra,0x0
    80002234:	e98080e7          	jalr	-360(ra) # 800020c8 <wakeup>
  acquire(&p->lock);
    80002238:	854e                	mv	a0,s3
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	99c080e7          	jalr	-1636(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002242:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002246:	4795                	li	a5,5
    80002248:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	a3c080e7          	jalr	-1476(ra) # 80000c8a <release>
  sched();
    80002256:	00000097          	auipc	ra,0x0
    8000225a:	cfc080e7          	jalr	-772(ra) # 80001f52 <sched>
  panic("zombie exit");
    8000225e:	00006517          	auipc	a0,0x6
    80002262:	03a50513          	addi	a0,a0,58 # 80008298 <digits+0x258>
    80002266:	ffffe097          	auipc	ra,0xffffe
    8000226a:	2d8080e7          	jalr	728(ra) # 8000053e <panic>

000000008000226e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000226e:	7179                	addi	sp,sp,-48
    80002270:	f406                	sd	ra,40(sp)
    80002272:	f022                	sd	s0,32(sp)
    80002274:	ec26                	sd	s1,24(sp)
    80002276:	e84a                	sd	s2,16(sp)
    80002278:	e44e                	sd	s3,8(sp)
    8000227a:	1800                	addi	s0,sp,48
    8000227c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000227e:	0000f497          	auipc	s1,0xf
    80002282:	d1248493          	addi	s1,s1,-750 # 80010f90 <proc>
    80002286:	00014997          	auipc	s3,0x14
    8000228a:	70a98993          	addi	s3,s3,1802 # 80016990 <tickslock>
    acquire(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	946080e7          	jalr	-1722(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002298:	589c                	lw	a5,48(s1)
    8000229a:	01278d63          	beq	a5,s2,800022b4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000229e:	8526                	mv	a0,s1
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	9ea080e7          	jalr	-1558(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a8:	16848493          	addi	s1,s1,360
    800022ac:	ff3491e3          	bne	s1,s3,8000228e <kill+0x20>
  }
  return -1;
    800022b0:	557d                	li	a0,-1
    800022b2:	a829                	j	800022cc <kill+0x5e>
      p->killed = 1;
    800022b4:	4785                	li	a5,1
    800022b6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022b8:	4c98                	lw	a4,24(s1)
    800022ba:	4789                	li	a5,2
    800022bc:	00f70f63          	beq	a4,a5,800022da <kill+0x6c>
      release(&p->lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	9c8080e7          	jalr	-1592(ra) # 80000c8a <release>
      return 0;
    800022ca:	4501                	li	a0,0
}
    800022cc:	70a2                	ld	ra,40(sp)
    800022ce:	7402                	ld	s0,32(sp)
    800022d0:	64e2                	ld	s1,24(sp)
    800022d2:	6942                	ld	s2,16(sp)
    800022d4:	69a2                	ld	s3,8(sp)
    800022d6:	6145                	addi	sp,sp,48
    800022d8:	8082                	ret
        p->state = RUNNABLE;
    800022da:	478d                	li	a5,3
    800022dc:	cc9c                	sw	a5,24(s1)
    800022de:	b7cd                	j	800022c0 <kill+0x52>

00000000800022e0 <setkilled>:

void
setkilled(struct proc *p)
{
    800022e0:	1101                	addi	sp,sp,-32
    800022e2:	ec06                	sd	ra,24(sp)
    800022e4:	e822                	sd	s0,16(sp)
    800022e6:	e426                	sd	s1,8(sp)
    800022e8:	1000                	addi	s0,sp,32
    800022ea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	8ea080e7          	jalr	-1814(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022f4:	4785                	li	a5,1
    800022f6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	990080e7          	jalr	-1648(ra) # 80000c8a <release>
}
    80002302:	60e2                	ld	ra,24(sp)
    80002304:	6442                	ld	s0,16(sp)
    80002306:	64a2                	ld	s1,8(sp)
    80002308:	6105                	addi	sp,sp,32
    8000230a:	8082                	ret

000000008000230c <killed>:

int
killed(struct proc *p)
{
    8000230c:	1101                	addi	sp,sp,-32
    8000230e:	ec06                	sd	ra,24(sp)
    80002310:	e822                	sd	s0,16(sp)
    80002312:	e426                	sd	s1,8(sp)
    80002314:	e04a                	sd	s2,0(sp)
    80002316:	1000                	addi	s0,sp,32
    80002318:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	8bc080e7          	jalr	-1860(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002322:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002326:	8526                	mv	a0,s1
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	962080e7          	jalr	-1694(ra) # 80000c8a <release>
  return k;
}
    80002330:	854a                	mv	a0,s2
    80002332:	60e2                	ld	ra,24(sp)
    80002334:	6442                	ld	s0,16(sp)
    80002336:	64a2                	ld	s1,8(sp)
    80002338:	6902                	ld	s2,0(sp)
    8000233a:	6105                	addi	sp,sp,32
    8000233c:	8082                	ret

000000008000233e <wait>:
{
    8000233e:	715d                	addi	sp,sp,-80
    80002340:	e486                	sd	ra,72(sp)
    80002342:	e0a2                	sd	s0,64(sp)
    80002344:	fc26                	sd	s1,56(sp)
    80002346:	f84a                	sd	s2,48(sp)
    80002348:	f44e                	sd	s3,40(sp)
    8000234a:	f052                	sd	s4,32(sp)
    8000234c:	ec56                	sd	s5,24(sp)
    8000234e:	e85a                	sd	s6,16(sp)
    80002350:	e45e                	sd	s7,8(sp)
    80002352:	e062                	sd	s8,0(sp)
    80002354:	0880                	addi	s0,sp,80
    80002356:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	664080e7          	jalr	1636(ra) # 800019bc <myproc>
    80002360:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002362:	0000f517          	auipc	a0,0xf
    80002366:	81650513          	addi	a0,a0,-2026 # 80010b78 <wait_lock>
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	86c080e7          	jalr	-1940(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002372:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002374:	4a15                	li	s4,5
        havekids = 1;
    80002376:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002378:	00014997          	auipc	s3,0x14
    8000237c:	61898993          	addi	s3,s3,1560 # 80016990 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002380:	0000ec17          	auipc	s8,0xe
    80002384:	7f8c0c13          	addi	s8,s8,2040 # 80010b78 <wait_lock>
    havekids = 0;
    80002388:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000238a:	0000f497          	auipc	s1,0xf
    8000238e:	c0648493          	addi	s1,s1,-1018 # 80010f90 <proc>
    80002392:	a0bd                	j	80002400 <wait+0xc2>
          pid = pp->pid;
    80002394:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002398:	000b0e63          	beqz	s6,800023b4 <wait+0x76>
    8000239c:	4691                	li	a3,4
    8000239e:	02c48613          	addi	a2,s1,44
    800023a2:	85da                	mv	a1,s6
    800023a4:	05093503          	ld	a0,80(s2)
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	2d0080e7          	jalr	720(ra) # 80001678 <copyout>
    800023b0:	02054563          	bltz	a0,800023da <wait+0x9c>
          freeproc(pp);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	7b8080e7          	jalr	1976(ra) # 80001b6e <freeproc>
          release(&pp->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	8ca080e7          	jalr	-1846(ra) # 80000c8a <release>
          release(&wait_lock);
    800023c8:	0000e517          	auipc	a0,0xe
    800023cc:	7b050513          	addi	a0,a0,1968 # 80010b78 <wait_lock>
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8ba080e7          	jalr	-1862(ra) # 80000c8a <release>
          return pid;
    800023d8:	a0b5                	j	80002444 <wait+0x106>
            release(&pp->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
            release(&wait_lock);
    800023e4:	0000e517          	auipc	a0,0xe
    800023e8:	79450513          	addi	a0,a0,1940 # 80010b78 <wait_lock>
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	89e080e7          	jalr	-1890(ra) # 80000c8a <release>
            return -1;
    800023f4:	59fd                	li	s3,-1
    800023f6:	a0b9                	j	80002444 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f8:	16848493          	addi	s1,s1,360
    800023fc:	03348463          	beq	s1,s3,80002424 <wait+0xe6>
      if(pp->parent == p){
    80002400:	7c9c                	ld	a5,56(s1)
    80002402:	ff279be3          	bne	a5,s2,800023f8 <wait+0xba>
        acquire(&pp->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	ffffe097          	auipc	ra,0xffffe
    8000240c:	7ce080e7          	jalr	1998(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002410:	4c9c                	lw	a5,24(s1)
    80002412:	f94781e3          	beq	a5,s4,80002394 <wait+0x56>
        release(&pp->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	872080e7          	jalr	-1934(ra) # 80000c8a <release>
        havekids = 1;
    80002420:	8756                	mv	a4,s5
    80002422:	bfd9                	j	800023f8 <wait+0xba>
    if(!havekids || killed(p)){
    80002424:	c719                	beqz	a4,80002432 <wait+0xf4>
    80002426:	854a                	mv	a0,s2
    80002428:	00000097          	auipc	ra,0x0
    8000242c:	ee4080e7          	jalr	-284(ra) # 8000230c <killed>
    80002430:	c51d                	beqz	a0,8000245e <wait+0x120>
      release(&wait_lock);
    80002432:	0000e517          	auipc	a0,0xe
    80002436:	74650513          	addi	a0,a0,1862 # 80010b78 <wait_lock>
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	850080e7          	jalr	-1968(ra) # 80000c8a <release>
      return -1;
    80002442:	59fd                	li	s3,-1
}
    80002444:	854e                	mv	a0,s3
    80002446:	60a6                	ld	ra,72(sp)
    80002448:	6406                	ld	s0,64(sp)
    8000244a:	74e2                	ld	s1,56(sp)
    8000244c:	7942                	ld	s2,48(sp)
    8000244e:	79a2                	ld	s3,40(sp)
    80002450:	7a02                	ld	s4,32(sp)
    80002452:	6ae2                	ld	s5,24(sp)
    80002454:	6b42                	ld	s6,16(sp)
    80002456:	6ba2                	ld	s7,8(sp)
    80002458:	6c02                	ld	s8,0(sp)
    8000245a:	6161                	addi	sp,sp,80
    8000245c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000245e:	85e2                	mv	a1,s8
    80002460:	854a                	mv	a0,s2
    80002462:	00000097          	auipc	ra,0x0
    80002466:	c02080e7          	jalr	-1022(ra) # 80002064 <sleep>
    havekids = 0;
    8000246a:	bf39                	j	80002388 <wait+0x4a>

000000008000246c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000246c:	7179                	addi	sp,sp,-48
    8000246e:	f406                	sd	ra,40(sp)
    80002470:	f022                	sd	s0,32(sp)
    80002472:	ec26                	sd	s1,24(sp)
    80002474:	e84a                	sd	s2,16(sp)
    80002476:	e44e                	sd	s3,8(sp)
    80002478:	e052                	sd	s4,0(sp)
    8000247a:	1800                	addi	s0,sp,48
    8000247c:	84aa                	mv	s1,a0
    8000247e:	892e                	mv	s2,a1
    80002480:	89b2                	mv	s3,a2
    80002482:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	538080e7          	jalr	1336(ra) # 800019bc <myproc>
  if(user_dst){
    8000248c:	c08d                	beqz	s1,800024ae <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000248e:	86d2                	mv	a3,s4
    80002490:	864e                	mv	a2,s3
    80002492:	85ca                	mv	a1,s2
    80002494:	6928                	ld	a0,80(a0)
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	1e2080e7          	jalr	482(ra) # 80001678 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000249e:	70a2                	ld	ra,40(sp)
    800024a0:	7402                	ld	s0,32(sp)
    800024a2:	64e2                	ld	s1,24(sp)
    800024a4:	6942                	ld	s2,16(sp)
    800024a6:	69a2                	ld	s3,8(sp)
    800024a8:	6a02                	ld	s4,0(sp)
    800024aa:	6145                	addi	sp,sp,48
    800024ac:	8082                	ret
    memmove((char *)dst, src, len);
    800024ae:	000a061b          	sext.w	a2,s4
    800024b2:	85ce                	mv	a1,s3
    800024b4:	854a                	mv	a0,s2
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	878080e7          	jalr	-1928(ra) # 80000d2e <memmove>
    return 0;
    800024be:	8526                	mv	a0,s1
    800024c0:	bff9                	j	8000249e <either_copyout+0x32>

00000000800024c2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024c2:	7179                	addi	sp,sp,-48
    800024c4:	f406                	sd	ra,40(sp)
    800024c6:	f022                	sd	s0,32(sp)
    800024c8:	ec26                	sd	s1,24(sp)
    800024ca:	e84a                	sd	s2,16(sp)
    800024cc:	e44e                	sd	s3,8(sp)
    800024ce:	e052                	sd	s4,0(sp)
    800024d0:	1800                	addi	s0,sp,48
    800024d2:	892a                	mv	s2,a0
    800024d4:	84ae                	mv	s1,a1
    800024d6:	89b2                	mv	s3,a2
    800024d8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024da:	fffff097          	auipc	ra,0xfffff
    800024de:	4e2080e7          	jalr	1250(ra) # 800019bc <myproc>
  if(user_src){
    800024e2:	c08d                	beqz	s1,80002504 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024e4:	86d2                	mv	a3,s4
    800024e6:	864e                	mv	a2,s3
    800024e8:	85ca                	mv	a1,s2
    800024ea:	6928                	ld	a0,80(a0)
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	218080e7          	jalr	536(ra) # 80001704 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024f4:	70a2                	ld	ra,40(sp)
    800024f6:	7402                	ld	s0,32(sp)
    800024f8:	64e2                	ld	s1,24(sp)
    800024fa:	6942                	ld	s2,16(sp)
    800024fc:	69a2                	ld	s3,8(sp)
    800024fe:	6a02                	ld	s4,0(sp)
    80002500:	6145                	addi	sp,sp,48
    80002502:	8082                	ret
    memmove(dst, (char*)src, len);
    80002504:	000a061b          	sext.w	a2,s4
    80002508:	85ce                	mv	a1,s3
    8000250a:	854a                	mv	a0,s2
    8000250c:	fffff097          	auipc	ra,0xfffff
    80002510:	822080e7          	jalr	-2014(ra) # 80000d2e <memmove>
    return 0;
    80002514:	8526                	mv	a0,s1
    80002516:	bff9                	j	800024f4 <either_copyin+0x32>

0000000080002518 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002518:	715d                	addi	sp,sp,-80
    8000251a:	e486                	sd	ra,72(sp)
    8000251c:	e0a2                	sd	s0,64(sp)
    8000251e:	fc26                	sd	s1,56(sp)
    80002520:	f84a                	sd	s2,48(sp)
    80002522:	f44e                	sd	s3,40(sp)
    80002524:	f052                	sd	s4,32(sp)
    80002526:	ec56                	sd	s5,24(sp)
    80002528:	e85a                	sd	s6,16(sp)
    8000252a:	e45e                	sd	s7,8(sp)
    8000252c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000252e:	00006517          	auipc	a0,0x6
    80002532:	bc250513          	addi	a0,a0,-1086 # 800080f0 <digits+0xb0>
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	052080e7          	jalr	82(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000253e:	0000f497          	auipc	s1,0xf
    80002542:	baa48493          	addi	s1,s1,-1110 # 800110e8 <proc+0x158>
    80002546:	00014917          	auipc	s2,0x14
    8000254a:	5a290913          	addi	s2,s2,1442 # 80016ae8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000254e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002550:	00006997          	auipc	s3,0x6
    80002554:	d5898993          	addi	s3,s3,-680 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    80002558:	00006a97          	auipc	s5,0x6
    8000255c:	d58a8a93          	addi	s5,s5,-680 # 800082b0 <digits+0x270>
    printf("\n");
    80002560:	00006a17          	auipc	s4,0x6
    80002564:	b90a0a13          	addi	s4,s4,-1136 # 800080f0 <digits+0xb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002568:	00006b97          	auipc	s7,0x6
    8000256c:	d88b8b93          	addi	s7,s7,-632 # 800082f0 <states.0>
    80002570:	a00d                	j	80002592 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002572:	ed86a583          	lw	a1,-296(a3)
    80002576:	8556                	mv	a0,s5
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	010080e7          	jalr	16(ra) # 80000588 <printf>
    printf("\n");
    80002580:	8552                	mv	a0,s4
    80002582:	ffffe097          	auipc	ra,0xffffe
    80002586:	006080e7          	jalr	6(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000258a:	16848493          	addi	s1,s1,360
    8000258e:	03248163          	beq	s1,s2,800025b0 <procdump+0x98>
    if(p->state == UNUSED)
    80002592:	86a6                	mv	a3,s1
    80002594:	ec04a783          	lw	a5,-320(s1)
    80002598:	dbed                	beqz	a5,8000258a <procdump+0x72>
      state = "???";
    8000259a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000259c:	fcfb6be3          	bltu	s6,a5,80002572 <procdump+0x5a>
    800025a0:	1782                	slli	a5,a5,0x20
    800025a2:	9381                	srli	a5,a5,0x20
    800025a4:	078e                	slli	a5,a5,0x3
    800025a6:	97de                	add	a5,a5,s7
    800025a8:	6390                	ld	a2,0(a5)
    800025aa:	f661                	bnez	a2,80002572 <procdump+0x5a>
      state = "???";
    800025ac:	864e                	mv	a2,s3
    800025ae:	b7d1                	j	80002572 <procdump+0x5a>
  }
}
    800025b0:	60a6                	ld	ra,72(sp)
    800025b2:	6406                	ld	s0,64(sp)
    800025b4:	74e2                	ld	s1,56(sp)
    800025b6:	7942                	ld	s2,48(sp)
    800025b8:	79a2                	ld	s3,40(sp)
    800025ba:	7a02                	ld	s4,32(sp)
    800025bc:	6ae2                	ld	s5,24(sp)
    800025be:	6b42                	ld	s6,16(sp)
    800025c0:	6ba2                	ld	s7,8(sp)
    800025c2:	6161                	addi	sp,sp,80
    800025c4:	8082                	ret

00000000800025c6 <swtch>:
    800025c6:	00153023          	sd	ra,0(a0)
    800025ca:	00253423          	sd	sp,8(a0)
    800025ce:	e900                	sd	s0,16(a0)
    800025d0:	ed04                	sd	s1,24(a0)
    800025d2:	03253023          	sd	s2,32(a0)
    800025d6:	03353423          	sd	s3,40(a0)
    800025da:	03453823          	sd	s4,48(a0)
    800025de:	03553c23          	sd	s5,56(a0)
    800025e2:	05653023          	sd	s6,64(a0)
    800025e6:	05753423          	sd	s7,72(a0)
    800025ea:	05853823          	sd	s8,80(a0)
    800025ee:	05953c23          	sd	s9,88(a0)
    800025f2:	07a53023          	sd	s10,96(a0)
    800025f6:	07b53423          	sd	s11,104(a0)
    800025fa:	0005b083          	ld	ra,0(a1)
    800025fe:	0085b103          	ld	sp,8(a1)
    80002602:	6980                	ld	s0,16(a1)
    80002604:	6d84                	ld	s1,24(a1)
    80002606:	0205b903          	ld	s2,32(a1)
    8000260a:	0285b983          	ld	s3,40(a1)
    8000260e:	0305ba03          	ld	s4,48(a1)
    80002612:	0385ba83          	ld	s5,56(a1)
    80002616:	0405bb03          	ld	s6,64(a1)
    8000261a:	0485bb83          	ld	s7,72(a1)
    8000261e:	0505bc03          	ld	s8,80(a1)
    80002622:	0585bc83          	ld	s9,88(a1)
    80002626:	0605bd03          	ld	s10,96(a1)
    8000262a:	0685bd83          	ld	s11,104(a1)
    8000262e:	8082                	ret

0000000080002630 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002630:	1141                	addi	sp,sp,-16
    80002632:	e406                	sd	ra,8(sp)
    80002634:	e022                	sd	s0,0(sp)
    80002636:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002638:	00006597          	auipc	a1,0x6
    8000263c:	ce858593          	addi	a1,a1,-792 # 80008320 <states.0+0x30>
    80002640:	00014517          	auipc	a0,0x14
    80002644:	35050513          	addi	a0,a0,848 # 80016990 <tickslock>
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	4fe080e7          	jalr	1278(ra) # 80000b46 <initlock>
}
    80002650:	60a2                	ld	ra,8(sp)
    80002652:	6402                	ld	s0,0(sp)
    80002654:	0141                	addi	sp,sp,16
    80002656:	8082                	ret

0000000080002658 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002658:	1141                	addi	sp,sp,-16
    8000265a:	e422                	sd	s0,8(sp)
    8000265c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000265e:	00003797          	auipc	a5,0x3
    80002662:	4c278793          	addi	a5,a5,1218 # 80005b20 <kernelvec>
    80002666:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000266a:	6422                	ld	s0,8(sp)
    8000266c:	0141                	addi	sp,sp,16
    8000266e:	8082                	ret

0000000080002670 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002670:	1141                	addi	sp,sp,-16
    80002672:	e406                	sd	ra,8(sp)
    80002674:	e022                	sd	s0,0(sp)
    80002676:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002678:	fffff097          	auipc	ra,0xfffff
    8000267c:	344080e7          	jalr	836(ra) # 800019bc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002680:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002684:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002686:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000268a:	00005617          	auipc	a2,0x5
    8000268e:	97660613          	addi	a2,a2,-1674 # 80007000 <_trampoline>
    80002692:	00005697          	auipc	a3,0x5
    80002696:	96e68693          	addi	a3,a3,-1682 # 80007000 <_trampoline>
    8000269a:	8e91                	sub	a3,a3,a2
    8000269c:	040007b7          	lui	a5,0x4000
    800026a0:	17fd                	addi	a5,a5,-1
    800026a2:	07b2                	slli	a5,a5,0xc
    800026a4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a6:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026aa:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026ac:	180026f3          	csrr	a3,satp
    800026b0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026b2:	6d38                	ld	a4,88(a0)
    800026b4:	6134                	ld	a3,64(a0)
    800026b6:	6585                	lui	a1,0x1
    800026b8:	96ae                	add	a3,a3,a1
    800026ba:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026bc:	6d38                	ld	a4,88(a0)
    800026be:	00000697          	auipc	a3,0x0
    800026c2:	13068693          	addi	a3,a3,304 # 800027ee <usertrap>
    800026c6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026c8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026ca:	8692                	mv	a3,tp
    800026cc:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ce:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026d2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026d6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026da:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026de:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026e0:	6f18                	ld	a4,24(a4)
    800026e2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e6:	6928                	ld	a0,80(a0)
    800026e8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026ea:	00005717          	auipc	a4,0x5
    800026ee:	9b270713          	addi	a4,a4,-1614 # 8000709c <userret>
    800026f2:	8f11                	sub	a4,a4,a2
    800026f4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026f6:	577d                	li	a4,-1
    800026f8:	177e                	slli	a4,a4,0x3f
    800026fa:	8d59                	or	a0,a0,a4
    800026fc:	9782                	jalr	a5
}
    800026fe:	60a2                	ld	ra,8(sp)
    80002700:	6402                	ld	s0,0(sp)
    80002702:	0141                	addi	sp,sp,16
    80002704:	8082                	ret

0000000080002706 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002706:	1101                	addi	sp,sp,-32
    80002708:	ec06                	sd	ra,24(sp)
    8000270a:	e822                	sd	s0,16(sp)
    8000270c:	e426                	sd	s1,8(sp)
    8000270e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002710:	00014497          	auipc	s1,0x14
    80002714:	28048493          	addi	s1,s1,640 # 80016990 <tickslock>
    80002718:	8526                	mv	a0,s1
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	4bc080e7          	jalr	1212(ra) # 80000bd6 <acquire>
  ticks++;
    80002722:	00006517          	auipc	a0,0x6
    80002726:	1ce50513          	addi	a0,a0,462 # 800088f0 <ticks>
    8000272a:	411c                	lw	a5,0(a0)
    8000272c:	2785                	addiw	a5,a5,1
    8000272e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002730:	00000097          	auipc	ra,0x0
    80002734:	998080e7          	jalr	-1640(ra) # 800020c8 <wakeup>
  release(&tickslock);
    80002738:	8526                	mv	a0,s1
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	550080e7          	jalr	1360(ra) # 80000c8a <release>
}
    80002742:	60e2                	ld	ra,24(sp)
    80002744:	6442                	ld	s0,16(sp)
    80002746:	64a2                	ld	s1,8(sp)
    80002748:	6105                	addi	sp,sp,32
    8000274a:	8082                	ret

000000008000274c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000274c:	1101                	addi	sp,sp,-32
    8000274e:	ec06                	sd	ra,24(sp)
    80002750:	e822                	sd	s0,16(sp)
    80002752:	e426                	sd	s1,8(sp)
    80002754:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002756:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000275a:	00074d63          	bltz	a4,80002774 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000275e:	57fd                	li	a5,-1
    80002760:	17fe                	slli	a5,a5,0x3f
    80002762:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002764:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002766:	06f70363          	beq	a4,a5,800027cc <devintr+0x80>
  }
}
    8000276a:	60e2                	ld	ra,24(sp)
    8000276c:	6442                	ld	s0,16(sp)
    8000276e:	64a2                	ld	s1,8(sp)
    80002770:	6105                	addi	sp,sp,32
    80002772:	8082                	ret
     (scause & 0xff) == 9){
    80002774:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002778:	46a5                	li	a3,9
    8000277a:	fed792e3          	bne	a5,a3,8000275e <devintr+0x12>
    int irq = plic_claim();
    8000277e:	00003097          	auipc	ra,0x3
    80002782:	4aa080e7          	jalr	1194(ra) # 80005c28 <plic_claim>
    80002786:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002788:	47a9                	li	a5,10
    8000278a:	02f50763          	beq	a0,a5,800027b8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000278e:	4785                	li	a5,1
    80002790:	02f50963          	beq	a0,a5,800027c2 <devintr+0x76>
    return 1;
    80002794:	4505                	li	a0,1
    } else if(irq){
    80002796:	d8f1                	beqz	s1,8000276a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002798:	85a6                	mv	a1,s1
    8000279a:	00006517          	auipc	a0,0x6
    8000279e:	b8e50513          	addi	a0,a0,-1138 # 80008328 <states.0+0x38>
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	de6080e7          	jalr	-538(ra) # 80000588 <printf>
      plic_complete(irq);
    800027aa:	8526                	mv	a0,s1
    800027ac:	00003097          	auipc	ra,0x3
    800027b0:	4a0080e7          	jalr	1184(ra) # 80005c4c <plic_complete>
    return 1;
    800027b4:	4505                	li	a0,1
    800027b6:	bf55                	j	8000276a <devintr+0x1e>
      uartintr();
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	1e2080e7          	jalr	482(ra) # 8000099a <uartintr>
    800027c0:	b7ed                	j	800027aa <devintr+0x5e>
      virtio_disk_intr();
    800027c2:	00004097          	auipc	ra,0x4
    800027c6:	956080e7          	jalr	-1706(ra) # 80006118 <virtio_disk_intr>
    800027ca:	b7c5                	j	800027aa <devintr+0x5e>
    if(cpuid() == 0){
    800027cc:	fffff097          	auipc	ra,0xfffff
    800027d0:	1c4080e7          	jalr	452(ra) # 80001990 <cpuid>
    800027d4:	c901                	beqz	a0,800027e4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027d6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027da:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027dc:	14479073          	csrw	sip,a5
    return 2;
    800027e0:	4509                	li	a0,2
    800027e2:	b761                	j	8000276a <devintr+0x1e>
      clockintr();
    800027e4:	00000097          	auipc	ra,0x0
    800027e8:	f22080e7          	jalr	-222(ra) # 80002706 <clockintr>
    800027ec:	b7ed                	j	800027d6 <devintr+0x8a>

00000000800027ee <usertrap>:
{
    800027ee:	1101                	addi	sp,sp,-32
    800027f0:	ec06                	sd	ra,24(sp)
    800027f2:	e822                	sd	s0,16(sp)
    800027f4:	e426                	sd	s1,8(sp)
    800027f6:	e04a                	sd	s2,0(sp)
    800027f8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027fa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027fe:	1007f793          	andi	a5,a5,256
    80002802:	e3b1                	bnez	a5,80002846 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002804:	00003797          	auipc	a5,0x3
    80002808:	31c78793          	addi	a5,a5,796 # 80005b20 <kernelvec>
    8000280c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002810:	fffff097          	auipc	ra,0xfffff
    80002814:	1ac080e7          	jalr	428(ra) # 800019bc <myproc>
    80002818:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000281a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000281c:	14102773          	csrr	a4,sepc
    80002820:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002822:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002826:	47a1                	li	a5,8
    80002828:	02f70763          	beq	a4,a5,80002856 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000282c:	00000097          	auipc	ra,0x0
    80002830:	f20080e7          	jalr	-224(ra) # 8000274c <devintr>
    80002834:	892a                	mv	s2,a0
    80002836:	c151                	beqz	a0,800028ba <usertrap+0xcc>
  if(killed(p))
    80002838:	8526                	mv	a0,s1
    8000283a:	00000097          	auipc	ra,0x0
    8000283e:	ad2080e7          	jalr	-1326(ra) # 8000230c <killed>
    80002842:	c929                	beqz	a0,80002894 <usertrap+0xa6>
    80002844:	a099                	j	8000288a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002846:	00006517          	auipc	a0,0x6
    8000284a:	b0250513          	addi	a0,a0,-1278 # 80008348 <states.0+0x58>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	cf0080e7          	jalr	-784(ra) # 8000053e <panic>
    if(killed(p))
    80002856:	00000097          	auipc	ra,0x0
    8000285a:	ab6080e7          	jalr	-1354(ra) # 8000230c <killed>
    8000285e:	e921                	bnez	a0,800028ae <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002860:	6cb8                	ld	a4,88(s1)
    80002862:	6f1c                	ld	a5,24(a4)
    80002864:	0791                	addi	a5,a5,4
    80002866:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002868:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000286c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002870:	10079073          	csrw	sstatus,a5
    syscall();
    80002874:	00000097          	auipc	ra,0x0
    80002878:	2d4080e7          	jalr	724(ra) # 80002b48 <syscall>
  if(killed(p))
    8000287c:	8526                	mv	a0,s1
    8000287e:	00000097          	auipc	ra,0x0
    80002882:	a8e080e7          	jalr	-1394(ra) # 8000230c <killed>
    80002886:	c911                	beqz	a0,8000289a <usertrap+0xac>
    80002888:	4901                	li	s2,0
    exit(-1);
    8000288a:	557d                	li	a0,-1
    8000288c:	00000097          	auipc	ra,0x0
    80002890:	90c080e7          	jalr	-1780(ra) # 80002198 <exit>
  if(which_dev == 2)
    80002894:	4789                	li	a5,2
    80002896:	04f90f63          	beq	s2,a5,800028f4 <usertrap+0x106>
  usertrapret();
    8000289a:	00000097          	auipc	ra,0x0
    8000289e:	dd6080e7          	jalr	-554(ra) # 80002670 <usertrapret>
}
    800028a2:	60e2                	ld	ra,24(sp)
    800028a4:	6442                	ld	s0,16(sp)
    800028a6:	64a2                	ld	s1,8(sp)
    800028a8:	6902                	ld	s2,0(sp)
    800028aa:	6105                	addi	sp,sp,32
    800028ac:	8082                	ret
      exit(-1);
    800028ae:	557d                	li	a0,-1
    800028b0:	00000097          	auipc	ra,0x0
    800028b4:	8e8080e7          	jalr	-1816(ra) # 80002198 <exit>
    800028b8:	b765                	j	80002860 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ba:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028be:	5890                	lw	a2,48(s1)
    800028c0:	00006517          	auipc	a0,0x6
    800028c4:	aa850513          	addi	a0,a0,-1368 # 80008368 <states.0+0x78>
    800028c8:	ffffe097          	auipc	ra,0xffffe
    800028cc:	cc0080e7          	jalr	-832(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028d0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028d4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d8:	00006517          	auipc	a0,0x6
    800028dc:	ac050513          	addi	a0,a0,-1344 # 80008398 <states.0+0xa8>
    800028e0:	ffffe097          	auipc	ra,0xffffe
    800028e4:	ca8080e7          	jalr	-856(ra) # 80000588 <printf>
    setkilled(p);
    800028e8:	8526                	mv	a0,s1
    800028ea:	00000097          	auipc	ra,0x0
    800028ee:	9f6080e7          	jalr	-1546(ra) # 800022e0 <setkilled>
    800028f2:	b769                	j	8000287c <usertrap+0x8e>
    yield();
    800028f4:	fffff097          	auipc	ra,0xfffff
    800028f8:	734080e7          	jalr	1844(ra) # 80002028 <yield>
    800028fc:	bf79                	j	8000289a <usertrap+0xac>

00000000800028fe <kerneltrap>:
{
    800028fe:	7179                	addi	sp,sp,-48
    80002900:	f406                	sd	ra,40(sp)
    80002902:	f022                	sd	s0,32(sp)
    80002904:	ec26                	sd	s1,24(sp)
    80002906:	e84a                	sd	s2,16(sp)
    80002908:	e44e                	sd	s3,8(sp)
    8000290a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002910:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002914:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002918:	1004f793          	andi	a5,s1,256
    8000291c:	cb85                	beqz	a5,8000294c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002922:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002924:	ef85                	bnez	a5,8000295c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	e26080e7          	jalr	-474(ra) # 8000274c <devintr>
    8000292e:	cd1d                	beqz	a0,8000296c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002930:	4789                	li	a5,2
    80002932:	06f50a63          	beq	a0,a5,800029a6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002936:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000293a:	10049073          	csrw	sstatus,s1
}
    8000293e:	70a2                	ld	ra,40(sp)
    80002940:	7402                	ld	s0,32(sp)
    80002942:	64e2                	ld	s1,24(sp)
    80002944:	6942                	ld	s2,16(sp)
    80002946:	69a2                	ld	s3,8(sp)
    80002948:	6145                	addi	sp,sp,48
    8000294a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000294c:	00006517          	auipc	a0,0x6
    80002950:	a6c50513          	addi	a0,a0,-1428 # 800083b8 <states.0+0xc8>
    80002954:	ffffe097          	auipc	ra,0xffffe
    80002958:	bea080e7          	jalr	-1046(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    8000295c:	00006517          	auipc	a0,0x6
    80002960:	a8450513          	addi	a0,a0,-1404 # 800083e0 <states.0+0xf0>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	bda080e7          	jalr	-1062(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    8000296c:	85ce                	mv	a1,s3
    8000296e:	00006517          	auipc	a0,0x6
    80002972:	a9250513          	addi	a0,a0,-1390 # 80008400 <states.0+0x110>
    80002976:	ffffe097          	auipc	ra,0xffffe
    8000297a:	c12080e7          	jalr	-1006(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002982:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	a8a50513          	addi	a0,a0,-1398 # 80008410 <states.0+0x120>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	bfa080e7          	jalr	-1030(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002996:	00006517          	auipc	a0,0x6
    8000299a:	a9250513          	addi	a0,a0,-1390 # 80008428 <states.0+0x138>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	ba0080e7          	jalr	-1120(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a6:	fffff097          	auipc	ra,0xfffff
    800029aa:	016080e7          	jalr	22(ra) # 800019bc <myproc>
    800029ae:	d541                	beqz	a0,80002936 <kerneltrap+0x38>
    800029b0:	fffff097          	auipc	ra,0xfffff
    800029b4:	00c080e7          	jalr	12(ra) # 800019bc <myproc>
    800029b8:	4d18                	lw	a4,24(a0)
    800029ba:	4791                	li	a5,4
    800029bc:	f6f71de3          	bne	a4,a5,80002936 <kerneltrap+0x38>
    yield();
    800029c0:	fffff097          	auipc	ra,0xfffff
    800029c4:	668080e7          	jalr	1640(ra) # 80002028 <yield>
    800029c8:	b7bd                	j	80002936 <kerneltrap+0x38>

00000000800029ca <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029ca:	1101                	addi	sp,sp,-32
    800029cc:	ec06                	sd	ra,24(sp)
    800029ce:	e822                	sd	s0,16(sp)
    800029d0:	e426                	sd	s1,8(sp)
    800029d2:	1000                	addi	s0,sp,32
    800029d4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029d6:	fffff097          	auipc	ra,0xfffff
    800029da:	fe6080e7          	jalr	-26(ra) # 800019bc <myproc>
  switch (n) {
    800029de:	4795                	li	a5,5
    800029e0:	0497e163          	bltu	a5,s1,80002a22 <argraw+0x58>
    800029e4:	048a                	slli	s1,s1,0x2
    800029e6:	00006717          	auipc	a4,0x6
    800029ea:	a7a70713          	addi	a4,a4,-1414 # 80008460 <states.0+0x170>
    800029ee:	94ba                	add	s1,s1,a4
    800029f0:	409c                	lw	a5,0(s1)
    800029f2:	97ba                	add	a5,a5,a4
    800029f4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029f6:	6d3c                	ld	a5,88(a0)
    800029f8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029fa:	60e2                	ld	ra,24(sp)
    800029fc:	6442                	ld	s0,16(sp)
    800029fe:	64a2                	ld	s1,8(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret
    return p->trapframe->a1;
    80002a04:	6d3c                	ld	a5,88(a0)
    80002a06:	7fa8                	ld	a0,120(a5)
    80002a08:	bfcd                	j	800029fa <argraw+0x30>
    return p->trapframe->a2;
    80002a0a:	6d3c                	ld	a5,88(a0)
    80002a0c:	63c8                	ld	a0,128(a5)
    80002a0e:	b7f5                	j	800029fa <argraw+0x30>
    return p->trapframe->a3;
    80002a10:	6d3c                	ld	a5,88(a0)
    80002a12:	67c8                	ld	a0,136(a5)
    80002a14:	b7dd                	j	800029fa <argraw+0x30>
    return p->trapframe->a4;
    80002a16:	6d3c                	ld	a5,88(a0)
    80002a18:	6bc8                	ld	a0,144(a5)
    80002a1a:	b7c5                	j	800029fa <argraw+0x30>
    return p->trapframe->a5;
    80002a1c:	6d3c                	ld	a5,88(a0)
    80002a1e:	6fc8                	ld	a0,152(a5)
    80002a20:	bfe9                	j	800029fa <argraw+0x30>
  panic("argraw");
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	a1650513          	addi	a0,a0,-1514 # 80008438 <states.0+0x148>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b14080e7          	jalr	-1260(ra) # 8000053e <panic>

0000000080002a32 <fetchaddr>:
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	e04a                	sd	s2,0(sp)
    80002a3c:	1000                	addi	s0,sp,32
    80002a3e:	84aa                	mv	s1,a0
    80002a40:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a42:	fffff097          	auipc	ra,0xfffff
    80002a46:	f7a080e7          	jalr	-134(ra) # 800019bc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a4a:	653c                	ld	a5,72(a0)
    80002a4c:	02f4f863          	bgeu	s1,a5,80002a7c <fetchaddr+0x4a>
    80002a50:	00848713          	addi	a4,s1,8
    80002a54:	02e7e663          	bltu	a5,a4,80002a80 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a58:	46a1                	li	a3,8
    80002a5a:	8626                	mv	a2,s1
    80002a5c:	85ca                	mv	a1,s2
    80002a5e:	6928                	ld	a0,80(a0)
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	ca4080e7          	jalr	-860(ra) # 80001704 <copyin>
    80002a68:	00a03533          	snez	a0,a0
    80002a6c:	40a00533          	neg	a0,a0
}
    80002a70:	60e2                	ld	ra,24(sp)
    80002a72:	6442                	ld	s0,16(sp)
    80002a74:	64a2                	ld	s1,8(sp)
    80002a76:	6902                	ld	s2,0(sp)
    80002a78:	6105                	addi	sp,sp,32
    80002a7a:	8082                	ret
    return -1;
    80002a7c:	557d                	li	a0,-1
    80002a7e:	bfcd                	j	80002a70 <fetchaddr+0x3e>
    80002a80:	557d                	li	a0,-1
    80002a82:	b7fd                	j	80002a70 <fetchaddr+0x3e>

0000000080002a84 <fetchstr>:
{
    80002a84:	7179                	addi	sp,sp,-48
    80002a86:	f406                	sd	ra,40(sp)
    80002a88:	f022                	sd	s0,32(sp)
    80002a8a:	ec26                	sd	s1,24(sp)
    80002a8c:	e84a                	sd	s2,16(sp)
    80002a8e:	e44e                	sd	s3,8(sp)
    80002a90:	1800                	addi	s0,sp,48
    80002a92:	892a                	mv	s2,a0
    80002a94:	84ae                	mv	s1,a1
    80002a96:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	f24080e7          	jalr	-220(ra) # 800019bc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002aa0:	86ce                	mv	a3,s3
    80002aa2:	864a                	mv	a2,s2
    80002aa4:	85a6                	mv	a1,s1
    80002aa6:	6928                	ld	a0,80(a0)
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	cea080e7          	jalr	-790(ra) # 80001792 <copyinstr>
    80002ab0:	00054e63          	bltz	a0,80002acc <fetchstr+0x48>
  return strlen(buf);
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	398080e7          	jalr	920(ra) # 80000e4e <strlen>
}
    80002abe:	70a2                	ld	ra,40(sp)
    80002ac0:	7402                	ld	s0,32(sp)
    80002ac2:	64e2                	ld	s1,24(sp)
    80002ac4:	6942                	ld	s2,16(sp)
    80002ac6:	69a2                	ld	s3,8(sp)
    80002ac8:	6145                	addi	sp,sp,48
    80002aca:	8082                	ret
    return -1;
    80002acc:	557d                	li	a0,-1
    80002ace:	bfc5                	j	80002abe <fetchstr+0x3a>

0000000080002ad0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ad0:	1101                	addi	sp,sp,-32
    80002ad2:	ec06                	sd	ra,24(sp)
    80002ad4:	e822                	sd	s0,16(sp)
    80002ad6:	e426                	sd	s1,8(sp)
    80002ad8:	1000                	addi	s0,sp,32
    80002ada:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	eee080e7          	jalr	-274(ra) # 800029ca <argraw>
    80002ae4:	c088                	sw	a0,0(s1)
}
    80002ae6:	60e2                	ld	ra,24(sp)
    80002ae8:	6442                	ld	s0,16(sp)
    80002aea:	64a2                	ld	s1,8(sp)
    80002aec:	6105                	addi	sp,sp,32
    80002aee:	8082                	ret

0000000080002af0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002af0:	1101                	addi	sp,sp,-32
    80002af2:	ec06                	sd	ra,24(sp)
    80002af4:	e822                	sd	s0,16(sp)
    80002af6:	e426                	sd	s1,8(sp)
    80002af8:	1000                	addi	s0,sp,32
    80002afa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002afc:	00000097          	auipc	ra,0x0
    80002b00:	ece080e7          	jalr	-306(ra) # 800029ca <argraw>
    80002b04:	e088                	sd	a0,0(s1)
}
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	64a2                	ld	s1,8(sp)
    80002b0c:	6105                	addi	sp,sp,32
    80002b0e:	8082                	ret

0000000080002b10 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b10:	7179                	addi	sp,sp,-48
    80002b12:	f406                	sd	ra,40(sp)
    80002b14:	f022                	sd	s0,32(sp)
    80002b16:	ec26                	sd	s1,24(sp)
    80002b18:	e84a                	sd	s2,16(sp)
    80002b1a:	1800                	addi	s0,sp,48
    80002b1c:	84ae                	mv	s1,a1
    80002b1e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b20:	fd840593          	addi	a1,s0,-40
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	fcc080e7          	jalr	-52(ra) # 80002af0 <argaddr>
  return fetchstr(addr, buf, max);
    80002b2c:	864a                	mv	a2,s2
    80002b2e:	85a6                	mv	a1,s1
    80002b30:	fd843503          	ld	a0,-40(s0)
    80002b34:	00000097          	auipc	ra,0x0
    80002b38:	f50080e7          	jalr	-176(ra) # 80002a84 <fetchstr>
}
    80002b3c:	70a2                	ld	ra,40(sp)
    80002b3e:	7402                	ld	s0,32(sp)
    80002b40:	64e2                	ld	s1,24(sp)
    80002b42:	6942                	ld	s2,16(sp)
    80002b44:	6145                	addi	sp,sp,48
    80002b46:	8082                	ret

0000000080002b48 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	e426                	sd	s1,8(sp)
    80002b50:	e04a                	sd	s2,0(sp)
    80002b52:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b54:	fffff097          	auipc	ra,0xfffff
    80002b58:	e68080e7          	jalr	-408(ra) # 800019bc <myproc>
    80002b5c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b5e:	05853903          	ld	s2,88(a0)
    80002b62:	0a893783          	ld	a5,168(s2)
    80002b66:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b6a:	37fd                	addiw	a5,a5,-1
    80002b6c:	4751                	li	a4,20
    80002b6e:	00f76f63          	bltu	a4,a5,80002b8c <syscall+0x44>
    80002b72:	00369713          	slli	a4,a3,0x3
    80002b76:	00006797          	auipc	a5,0x6
    80002b7a:	90278793          	addi	a5,a5,-1790 # 80008478 <syscalls>
    80002b7e:	97ba                	add	a5,a5,a4
    80002b80:	639c                	ld	a5,0(a5)
    80002b82:	c789                	beqz	a5,80002b8c <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b84:	9782                	jalr	a5
    80002b86:	06a93823          	sd	a0,112(s2)
    80002b8a:	a839                	j	80002ba8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b8c:	15848613          	addi	a2,s1,344
    80002b90:	588c                	lw	a1,48(s1)
    80002b92:	00006517          	auipc	a0,0x6
    80002b96:	8ae50513          	addi	a0,a0,-1874 # 80008440 <states.0+0x150>
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	9ee080e7          	jalr	-1554(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ba2:	6cbc                	ld	a5,88(s1)
    80002ba4:	577d                	li	a4,-1
    80002ba6:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba8:	60e2                	ld	ra,24(sp)
    80002baa:	6442                	ld	s0,16(sp)
    80002bac:	64a2                	ld	s1,8(sp)
    80002bae:	6902                	ld	s2,0(sp)
    80002bb0:	6105                	addi	sp,sp,32
    80002bb2:	8082                	ret

0000000080002bb4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bb4:	1101                	addi	sp,sp,-32
    80002bb6:	ec06                	sd	ra,24(sp)
    80002bb8:	e822                	sd	s0,16(sp)
    80002bba:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bbc:	fec40593          	addi	a1,s0,-20
    80002bc0:	4501                	li	a0,0
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	f0e080e7          	jalr	-242(ra) # 80002ad0 <argint>
  exit(n);
    80002bca:	fec42503          	lw	a0,-20(s0)
    80002bce:	fffff097          	auipc	ra,0xfffff
    80002bd2:	5ca080e7          	jalr	1482(ra) # 80002198 <exit>
  return 0;  // not reached
}
    80002bd6:	4501                	li	a0,0
    80002bd8:	60e2                	ld	ra,24(sp)
    80002bda:	6442                	ld	s0,16(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002be0:	1141                	addi	sp,sp,-16
    80002be2:	e406                	sd	ra,8(sp)
    80002be4:	e022                	sd	s0,0(sp)
    80002be6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	dd4080e7          	jalr	-556(ra) # 800019bc <myproc>
}
    80002bf0:	5908                	lw	a0,48(a0)
    80002bf2:	60a2                	ld	ra,8(sp)
    80002bf4:	6402                	ld	s0,0(sp)
    80002bf6:	0141                	addi	sp,sp,16
    80002bf8:	8082                	ret

0000000080002bfa <sys_fork>:

uint64
sys_fork(void)
{
    80002bfa:	1141                	addi	sp,sp,-16
    80002bfc:	e406                	sd	ra,8(sp)
    80002bfe:	e022                	sd	s0,0(sp)
    80002c00:	0800                	addi	s0,sp,16
  return fork();
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	170080e7          	jalr	368(ra) # 80001d72 <fork>
}
    80002c0a:	60a2                	ld	ra,8(sp)
    80002c0c:	6402                	ld	s0,0(sp)
    80002c0e:	0141                	addi	sp,sp,16
    80002c10:	8082                	ret

0000000080002c12 <sys_wait>:

uint64
sys_wait(void)
{
    80002c12:	1101                	addi	sp,sp,-32
    80002c14:	ec06                	sd	ra,24(sp)
    80002c16:	e822                	sd	s0,16(sp)
    80002c18:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c1a:	fe840593          	addi	a1,s0,-24
    80002c1e:	4501                	li	a0,0
    80002c20:	00000097          	auipc	ra,0x0
    80002c24:	ed0080e7          	jalr	-304(ra) # 80002af0 <argaddr>
  return wait(p);
    80002c28:	fe843503          	ld	a0,-24(s0)
    80002c2c:	fffff097          	auipc	ra,0xfffff
    80002c30:	712080e7          	jalr	1810(ra) # 8000233e <wait>
}
    80002c34:	60e2                	ld	ra,24(sp)
    80002c36:	6442                	ld	s0,16(sp)
    80002c38:	6105                	addi	sp,sp,32
    80002c3a:	8082                	ret

0000000080002c3c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c3c:	7179                	addi	sp,sp,-48
    80002c3e:	f406                	sd	ra,40(sp)
    80002c40:	f022                	sd	s0,32(sp)
    80002c42:	ec26                	sd	s1,24(sp)
    80002c44:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c46:	fdc40593          	addi	a1,s0,-36
    80002c4a:	4501                	li	a0,0
    80002c4c:	00000097          	auipc	ra,0x0
    80002c50:	e84080e7          	jalr	-380(ra) # 80002ad0 <argint>
  addr = myproc()->sz;
    80002c54:	fffff097          	auipc	ra,0xfffff
    80002c58:	d68080e7          	jalr	-664(ra) # 800019bc <myproc>
    80002c5c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c5e:	fdc42503          	lw	a0,-36(s0)
    80002c62:	fffff097          	auipc	ra,0xfffff
    80002c66:	0b4080e7          	jalr	180(ra) # 80001d16 <growproc>
    80002c6a:	00054863          	bltz	a0,80002c7a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c6e:	8526                	mv	a0,s1
    80002c70:	70a2                	ld	ra,40(sp)
    80002c72:	7402                	ld	s0,32(sp)
    80002c74:	64e2                	ld	s1,24(sp)
    80002c76:	6145                	addi	sp,sp,48
    80002c78:	8082                	ret
    return -1;
    80002c7a:	54fd                	li	s1,-1
    80002c7c:	bfcd                	j	80002c6e <sys_sbrk+0x32>

0000000080002c7e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c7e:	7139                	addi	sp,sp,-64
    80002c80:	fc06                	sd	ra,56(sp)
    80002c82:	f822                	sd	s0,48(sp)
    80002c84:	f426                	sd	s1,40(sp)
    80002c86:	f04a                	sd	s2,32(sp)
    80002c88:	ec4e                	sd	s3,24(sp)
    80002c8a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c8c:	fcc40593          	addi	a1,s0,-52
    80002c90:	4501                	li	a0,0
    80002c92:	00000097          	auipc	ra,0x0
    80002c96:	e3e080e7          	jalr	-450(ra) # 80002ad0 <argint>
  acquire(&tickslock);
    80002c9a:	00014517          	auipc	a0,0x14
    80002c9e:	cf650513          	addi	a0,a0,-778 # 80016990 <tickslock>
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	f34080e7          	jalr	-204(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002caa:	00006917          	auipc	s2,0x6
    80002cae:	c4692903          	lw	s2,-954(s2) # 800088f0 <ticks>
  while(ticks - ticks0 < n){
    80002cb2:	fcc42783          	lw	a5,-52(s0)
    80002cb6:	cf9d                	beqz	a5,80002cf4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb8:	00014997          	auipc	s3,0x14
    80002cbc:	cd898993          	addi	s3,s3,-808 # 80016990 <tickslock>
    80002cc0:	00006497          	auipc	s1,0x6
    80002cc4:	c3048493          	addi	s1,s1,-976 # 800088f0 <ticks>
    if(killed(myproc())){
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	cf4080e7          	jalr	-780(ra) # 800019bc <myproc>
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	63c080e7          	jalr	1596(ra) # 8000230c <killed>
    80002cd8:	ed15                	bnez	a0,80002d14 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cda:	85ce                	mv	a1,s3
    80002cdc:	8526                	mv	a0,s1
    80002cde:	fffff097          	auipc	ra,0xfffff
    80002ce2:	386080e7          	jalr	902(ra) # 80002064 <sleep>
  while(ticks - ticks0 < n){
    80002ce6:	409c                	lw	a5,0(s1)
    80002ce8:	412787bb          	subw	a5,a5,s2
    80002cec:	fcc42703          	lw	a4,-52(s0)
    80002cf0:	fce7ece3          	bltu	a5,a4,80002cc8 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002cf4:	00014517          	auipc	a0,0x14
    80002cf8:	c9c50513          	addi	a0,a0,-868 # 80016990 <tickslock>
    80002cfc:	ffffe097          	auipc	ra,0xffffe
    80002d00:	f8e080e7          	jalr	-114(ra) # 80000c8a <release>
  return 0;
    80002d04:	4501                	li	a0,0
}
    80002d06:	70e2                	ld	ra,56(sp)
    80002d08:	7442                	ld	s0,48(sp)
    80002d0a:	74a2                	ld	s1,40(sp)
    80002d0c:	7902                	ld	s2,32(sp)
    80002d0e:	69e2                	ld	s3,24(sp)
    80002d10:	6121                	addi	sp,sp,64
    80002d12:	8082                	ret
      release(&tickslock);
    80002d14:	00014517          	auipc	a0,0x14
    80002d18:	c7c50513          	addi	a0,a0,-900 # 80016990 <tickslock>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	f6e080e7          	jalr	-146(ra) # 80000c8a <release>
      return -1;
    80002d24:	557d                	li	a0,-1
    80002d26:	b7c5                	j	80002d06 <sys_sleep+0x88>

0000000080002d28 <sys_kill>:

uint64
sys_kill(void)
{
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d30:	fec40593          	addi	a1,s0,-20
    80002d34:	4501                	li	a0,0
    80002d36:	00000097          	auipc	ra,0x0
    80002d3a:	d9a080e7          	jalr	-614(ra) # 80002ad0 <argint>
  return kill(pid);
    80002d3e:	fec42503          	lw	a0,-20(s0)
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	52c080e7          	jalr	1324(ra) # 8000226e <kill>
}
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	6105                	addi	sp,sp,32
    80002d50:	8082                	ret

0000000080002d52 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d52:	1101                	addi	sp,sp,-32
    80002d54:	ec06                	sd	ra,24(sp)
    80002d56:	e822                	sd	s0,16(sp)
    80002d58:	e426                	sd	s1,8(sp)
    80002d5a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d5c:	00014517          	auipc	a0,0x14
    80002d60:	c3450513          	addi	a0,a0,-972 # 80016990 <tickslock>
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	e72080e7          	jalr	-398(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d6c:	00006497          	auipc	s1,0x6
    80002d70:	b844a483          	lw	s1,-1148(s1) # 800088f0 <ticks>
  release(&tickslock);
    80002d74:	00014517          	auipc	a0,0x14
    80002d78:	c1c50513          	addi	a0,a0,-996 # 80016990 <tickslock>
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	f0e080e7          	jalr	-242(ra) # 80000c8a <release>
  return xticks;
}
    80002d84:	02049513          	slli	a0,s1,0x20
    80002d88:	9101                	srli	a0,a0,0x20
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	64a2                	ld	s1,8(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret

0000000080002d94 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d94:	7179                	addi	sp,sp,-48
    80002d96:	f406                	sd	ra,40(sp)
    80002d98:	f022                	sd	s0,32(sp)
    80002d9a:	ec26                	sd	s1,24(sp)
    80002d9c:	e84a                	sd	s2,16(sp)
    80002d9e:	e44e                	sd	s3,8(sp)
    80002da0:	e052                	sd	s4,0(sp)
    80002da2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002da4:	00005597          	auipc	a1,0x5
    80002da8:	78458593          	addi	a1,a1,1924 # 80008528 <syscalls+0xb0>
    80002dac:	00014517          	auipc	a0,0x14
    80002db0:	bfc50513          	addi	a0,a0,-1028 # 800169a8 <bcache>
    80002db4:	ffffe097          	auipc	ra,0xffffe
    80002db8:	d92080e7          	jalr	-622(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dbc:	0001c797          	auipc	a5,0x1c
    80002dc0:	bec78793          	addi	a5,a5,-1044 # 8001e9a8 <bcache+0x8000>
    80002dc4:	0001c717          	auipc	a4,0x1c
    80002dc8:	e4c70713          	addi	a4,a4,-436 # 8001ec10 <bcache+0x8268>
    80002dcc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002dd0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dd4:	00014497          	auipc	s1,0x14
    80002dd8:	bec48493          	addi	s1,s1,-1044 # 800169c0 <bcache+0x18>
    b->next = bcache.head.next;
    80002ddc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dde:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002de0:	00005a17          	auipc	s4,0x5
    80002de4:	750a0a13          	addi	s4,s4,1872 # 80008530 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002de8:	2b893783          	ld	a5,696(s2)
    80002dec:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dee:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002df2:	85d2                	mv	a1,s4
    80002df4:	01048513          	addi	a0,s1,16
    80002df8:	00001097          	auipc	ra,0x1
    80002dfc:	4c4080e7          	jalr	1220(ra) # 800042bc <initsleeplock>
    bcache.head.next->prev = b;
    80002e00:	2b893783          	ld	a5,696(s2)
    80002e04:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e06:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e0a:	45848493          	addi	s1,s1,1112
    80002e0e:	fd349de3          	bne	s1,s3,80002de8 <binit+0x54>
  }
}
    80002e12:	70a2                	ld	ra,40(sp)
    80002e14:	7402                	ld	s0,32(sp)
    80002e16:	64e2                	ld	s1,24(sp)
    80002e18:	6942                	ld	s2,16(sp)
    80002e1a:	69a2                	ld	s3,8(sp)
    80002e1c:	6a02                	ld	s4,0(sp)
    80002e1e:	6145                	addi	sp,sp,48
    80002e20:	8082                	ret

0000000080002e22 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e22:	7179                	addi	sp,sp,-48
    80002e24:	f406                	sd	ra,40(sp)
    80002e26:	f022                	sd	s0,32(sp)
    80002e28:	ec26                	sd	s1,24(sp)
    80002e2a:	e84a                	sd	s2,16(sp)
    80002e2c:	e44e                	sd	s3,8(sp)
    80002e2e:	1800                	addi	s0,sp,48
    80002e30:	892a                	mv	s2,a0
    80002e32:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e34:	00014517          	auipc	a0,0x14
    80002e38:	b7450513          	addi	a0,a0,-1164 # 800169a8 <bcache>
    80002e3c:	ffffe097          	auipc	ra,0xffffe
    80002e40:	d9a080e7          	jalr	-614(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e44:	0001c497          	auipc	s1,0x1c
    80002e48:	e1c4b483          	ld	s1,-484(s1) # 8001ec60 <bcache+0x82b8>
    80002e4c:	0001c797          	auipc	a5,0x1c
    80002e50:	dc478793          	addi	a5,a5,-572 # 8001ec10 <bcache+0x8268>
    80002e54:	02f48f63          	beq	s1,a5,80002e92 <bread+0x70>
    80002e58:	873e                	mv	a4,a5
    80002e5a:	a021                	j	80002e62 <bread+0x40>
    80002e5c:	68a4                	ld	s1,80(s1)
    80002e5e:	02e48a63          	beq	s1,a4,80002e92 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e62:	449c                	lw	a5,8(s1)
    80002e64:	ff279ce3          	bne	a5,s2,80002e5c <bread+0x3a>
    80002e68:	44dc                	lw	a5,12(s1)
    80002e6a:	ff3799e3          	bne	a5,s3,80002e5c <bread+0x3a>
      b->refcnt++;
    80002e6e:	40bc                	lw	a5,64(s1)
    80002e70:	2785                	addiw	a5,a5,1
    80002e72:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e74:	00014517          	auipc	a0,0x14
    80002e78:	b3450513          	addi	a0,a0,-1228 # 800169a8 <bcache>
    80002e7c:	ffffe097          	auipc	ra,0xffffe
    80002e80:	e0e080e7          	jalr	-498(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002e84:	01048513          	addi	a0,s1,16
    80002e88:	00001097          	auipc	ra,0x1
    80002e8c:	46e080e7          	jalr	1134(ra) # 800042f6 <acquiresleep>
      return b;
    80002e90:	a8b9                	j	80002eee <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e92:	0001c497          	auipc	s1,0x1c
    80002e96:	dc64b483          	ld	s1,-570(s1) # 8001ec58 <bcache+0x82b0>
    80002e9a:	0001c797          	auipc	a5,0x1c
    80002e9e:	d7678793          	addi	a5,a5,-650 # 8001ec10 <bcache+0x8268>
    80002ea2:	00f48863          	beq	s1,a5,80002eb2 <bread+0x90>
    80002ea6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ea8:	40bc                	lw	a5,64(s1)
    80002eaa:	cf81                	beqz	a5,80002ec2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002eac:	64a4                	ld	s1,72(s1)
    80002eae:	fee49de3          	bne	s1,a4,80002ea8 <bread+0x86>
  panic("bget: no buffers");
    80002eb2:	00005517          	auipc	a0,0x5
    80002eb6:	68650513          	addi	a0,a0,1670 # 80008538 <syscalls+0xc0>
    80002eba:	ffffd097          	auipc	ra,0xffffd
    80002ebe:	684080e7          	jalr	1668(ra) # 8000053e <panic>
      b->dev = dev;
    80002ec2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ec6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002eca:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ece:	4785                	li	a5,1
    80002ed0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ed2:	00014517          	auipc	a0,0x14
    80002ed6:	ad650513          	addi	a0,a0,-1322 # 800169a8 <bcache>
    80002eda:	ffffe097          	auipc	ra,0xffffe
    80002ede:	db0080e7          	jalr	-592(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002ee2:	01048513          	addi	a0,s1,16
    80002ee6:	00001097          	auipc	ra,0x1
    80002eea:	410080e7          	jalr	1040(ra) # 800042f6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002eee:	409c                	lw	a5,0(s1)
    80002ef0:	cb89                	beqz	a5,80002f02 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ef2:	8526                	mv	a0,s1
    80002ef4:	70a2                	ld	ra,40(sp)
    80002ef6:	7402                	ld	s0,32(sp)
    80002ef8:	64e2                	ld	s1,24(sp)
    80002efa:	6942                	ld	s2,16(sp)
    80002efc:	69a2                	ld	s3,8(sp)
    80002efe:	6145                	addi	sp,sp,48
    80002f00:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f02:	4581                	li	a1,0
    80002f04:	8526                	mv	a0,s1
    80002f06:	00003097          	auipc	ra,0x3
    80002f0a:	fde080e7          	jalr	-34(ra) # 80005ee4 <virtio_disk_rw>
    b->valid = 1;
    80002f0e:	4785                	li	a5,1
    80002f10:	c09c                	sw	a5,0(s1)
  return b;
    80002f12:	b7c5                	j	80002ef2 <bread+0xd0>

0000000080002f14 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f14:	1101                	addi	sp,sp,-32
    80002f16:	ec06                	sd	ra,24(sp)
    80002f18:	e822                	sd	s0,16(sp)
    80002f1a:	e426                	sd	s1,8(sp)
    80002f1c:	1000                	addi	s0,sp,32
    80002f1e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f20:	0541                	addi	a0,a0,16
    80002f22:	00001097          	auipc	ra,0x1
    80002f26:	46e080e7          	jalr	1134(ra) # 80004390 <holdingsleep>
    80002f2a:	cd01                	beqz	a0,80002f42 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f2c:	4585                	li	a1,1
    80002f2e:	8526                	mv	a0,s1
    80002f30:	00003097          	auipc	ra,0x3
    80002f34:	fb4080e7          	jalr	-76(ra) # 80005ee4 <virtio_disk_rw>
}
    80002f38:	60e2                	ld	ra,24(sp)
    80002f3a:	6442                	ld	s0,16(sp)
    80002f3c:	64a2                	ld	s1,8(sp)
    80002f3e:	6105                	addi	sp,sp,32
    80002f40:	8082                	ret
    panic("bwrite");
    80002f42:	00005517          	auipc	a0,0x5
    80002f46:	60e50513          	addi	a0,a0,1550 # 80008550 <syscalls+0xd8>
    80002f4a:	ffffd097          	auipc	ra,0xffffd
    80002f4e:	5f4080e7          	jalr	1524(ra) # 8000053e <panic>

0000000080002f52 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f52:	1101                	addi	sp,sp,-32
    80002f54:	ec06                	sd	ra,24(sp)
    80002f56:	e822                	sd	s0,16(sp)
    80002f58:	e426                	sd	s1,8(sp)
    80002f5a:	e04a                	sd	s2,0(sp)
    80002f5c:	1000                	addi	s0,sp,32
    80002f5e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f60:	01050913          	addi	s2,a0,16
    80002f64:	854a                	mv	a0,s2
    80002f66:	00001097          	auipc	ra,0x1
    80002f6a:	42a080e7          	jalr	1066(ra) # 80004390 <holdingsleep>
    80002f6e:	c92d                	beqz	a0,80002fe0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f70:	854a                	mv	a0,s2
    80002f72:	00001097          	auipc	ra,0x1
    80002f76:	3da080e7          	jalr	986(ra) # 8000434c <releasesleep>

  acquire(&bcache.lock);
    80002f7a:	00014517          	auipc	a0,0x14
    80002f7e:	a2e50513          	addi	a0,a0,-1490 # 800169a8 <bcache>
    80002f82:	ffffe097          	auipc	ra,0xffffe
    80002f86:	c54080e7          	jalr	-940(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002f8a:	40bc                	lw	a5,64(s1)
    80002f8c:	37fd                	addiw	a5,a5,-1
    80002f8e:	0007871b          	sext.w	a4,a5
    80002f92:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f94:	eb05                	bnez	a4,80002fc4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f96:	68bc                	ld	a5,80(s1)
    80002f98:	64b8                	ld	a4,72(s1)
    80002f9a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f9c:	64bc                	ld	a5,72(s1)
    80002f9e:	68b8                	ld	a4,80(s1)
    80002fa0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fa2:	0001c797          	auipc	a5,0x1c
    80002fa6:	a0678793          	addi	a5,a5,-1530 # 8001e9a8 <bcache+0x8000>
    80002faa:	2b87b703          	ld	a4,696(a5)
    80002fae:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fb0:	0001c717          	auipc	a4,0x1c
    80002fb4:	c6070713          	addi	a4,a4,-928 # 8001ec10 <bcache+0x8268>
    80002fb8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fba:	2b87b703          	ld	a4,696(a5)
    80002fbe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fc0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fc4:	00014517          	auipc	a0,0x14
    80002fc8:	9e450513          	addi	a0,a0,-1564 # 800169a8 <bcache>
    80002fcc:	ffffe097          	auipc	ra,0xffffe
    80002fd0:	cbe080e7          	jalr	-834(ra) # 80000c8a <release>
}
    80002fd4:	60e2                	ld	ra,24(sp)
    80002fd6:	6442                	ld	s0,16(sp)
    80002fd8:	64a2                	ld	s1,8(sp)
    80002fda:	6902                	ld	s2,0(sp)
    80002fdc:	6105                	addi	sp,sp,32
    80002fde:	8082                	ret
    panic("brelse");
    80002fe0:	00005517          	auipc	a0,0x5
    80002fe4:	57850513          	addi	a0,a0,1400 # 80008558 <syscalls+0xe0>
    80002fe8:	ffffd097          	auipc	ra,0xffffd
    80002fec:	556080e7          	jalr	1366(ra) # 8000053e <panic>

0000000080002ff0 <bpin>:

void
bpin(struct buf *b) {
    80002ff0:	1101                	addi	sp,sp,-32
    80002ff2:	ec06                	sd	ra,24(sp)
    80002ff4:	e822                	sd	s0,16(sp)
    80002ff6:	e426                	sd	s1,8(sp)
    80002ff8:	1000                	addi	s0,sp,32
    80002ffa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ffc:	00014517          	auipc	a0,0x14
    80003000:	9ac50513          	addi	a0,a0,-1620 # 800169a8 <bcache>
    80003004:	ffffe097          	auipc	ra,0xffffe
    80003008:	bd2080e7          	jalr	-1070(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000300c:	40bc                	lw	a5,64(s1)
    8000300e:	2785                	addiw	a5,a5,1
    80003010:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003012:	00014517          	auipc	a0,0x14
    80003016:	99650513          	addi	a0,a0,-1642 # 800169a8 <bcache>
    8000301a:	ffffe097          	auipc	ra,0xffffe
    8000301e:	c70080e7          	jalr	-912(ra) # 80000c8a <release>
}
    80003022:	60e2                	ld	ra,24(sp)
    80003024:	6442                	ld	s0,16(sp)
    80003026:	64a2                	ld	s1,8(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret

000000008000302c <bunpin>:

void
bunpin(struct buf *b) {
    8000302c:	1101                	addi	sp,sp,-32
    8000302e:	ec06                	sd	ra,24(sp)
    80003030:	e822                	sd	s0,16(sp)
    80003032:	e426                	sd	s1,8(sp)
    80003034:	1000                	addi	s0,sp,32
    80003036:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003038:	00014517          	auipc	a0,0x14
    8000303c:	97050513          	addi	a0,a0,-1680 # 800169a8 <bcache>
    80003040:	ffffe097          	auipc	ra,0xffffe
    80003044:	b96080e7          	jalr	-1130(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003048:	40bc                	lw	a5,64(s1)
    8000304a:	37fd                	addiw	a5,a5,-1
    8000304c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000304e:	00014517          	auipc	a0,0x14
    80003052:	95a50513          	addi	a0,a0,-1702 # 800169a8 <bcache>
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	c34080e7          	jalr	-972(ra) # 80000c8a <release>
}
    8000305e:	60e2                	ld	ra,24(sp)
    80003060:	6442                	ld	s0,16(sp)
    80003062:	64a2                	ld	s1,8(sp)
    80003064:	6105                	addi	sp,sp,32
    80003066:	8082                	ret

0000000080003068 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003068:	1101                	addi	sp,sp,-32
    8000306a:	ec06                	sd	ra,24(sp)
    8000306c:	e822                	sd	s0,16(sp)
    8000306e:	e426                	sd	s1,8(sp)
    80003070:	e04a                	sd	s2,0(sp)
    80003072:	1000                	addi	s0,sp,32
    80003074:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003076:	00d5d59b          	srliw	a1,a1,0xd
    8000307a:	0001c797          	auipc	a5,0x1c
    8000307e:	00a7a783          	lw	a5,10(a5) # 8001f084 <sb+0x1c>
    80003082:	9dbd                	addw	a1,a1,a5
    80003084:	00000097          	auipc	ra,0x0
    80003088:	d9e080e7          	jalr	-610(ra) # 80002e22 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000308c:	0074f713          	andi	a4,s1,7
    80003090:	4785                	li	a5,1
    80003092:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003096:	14ce                	slli	s1,s1,0x33
    80003098:	90d9                	srli	s1,s1,0x36
    8000309a:	00950733          	add	a4,a0,s1
    8000309e:	05874703          	lbu	a4,88(a4)
    800030a2:	00e7f6b3          	and	a3,a5,a4
    800030a6:	c69d                	beqz	a3,800030d4 <bfree+0x6c>
    800030a8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030aa:	94aa                	add	s1,s1,a0
    800030ac:	fff7c793          	not	a5,a5
    800030b0:	8ff9                	and	a5,a5,a4
    800030b2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800030b6:	00001097          	auipc	ra,0x1
    800030ba:	120080e7          	jalr	288(ra) # 800041d6 <log_write>
  brelse(bp);
    800030be:	854a                	mv	a0,s2
    800030c0:	00000097          	auipc	ra,0x0
    800030c4:	e92080e7          	jalr	-366(ra) # 80002f52 <brelse>
}
    800030c8:	60e2                	ld	ra,24(sp)
    800030ca:	6442                	ld	s0,16(sp)
    800030cc:	64a2                	ld	s1,8(sp)
    800030ce:	6902                	ld	s2,0(sp)
    800030d0:	6105                	addi	sp,sp,32
    800030d2:	8082                	ret
    panic("freeing free block");
    800030d4:	00005517          	auipc	a0,0x5
    800030d8:	48c50513          	addi	a0,a0,1164 # 80008560 <syscalls+0xe8>
    800030dc:	ffffd097          	auipc	ra,0xffffd
    800030e0:	462080e7          	jalr	1122(ra) # 8000053e <panic>

00000000800030e4 <balloc>:
{
    800030e4:	711d                	addi	sp,sp,-96
    800030e6:	ec86                	sd	ra,88(sp)
    800030e8:	e8a2                	sd	s0,80(sp)
    800030ea:	e4a6                	sd	s1,72(sp)
    800030ec:	e0ca                	sd	s2,64(sp)
    800030ee:	fc4e                	sd	s3,56(sp)
    800030f0:	f852                	sd	s4,48(sp)
    800030f2:	f456                	sd	s5,40(sp)
    800030f4:	f05a                	sd	s6,32(sp)
    800030f6:	ec5e                	sd	s7,24(sp)
    800030f8:	e862                	sd	s8,16(sp)
    800030fa:	e466                	sd	s9,8(sp)
    800030fc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030fe:	0001c797          	auipc	a5,0x1c
    80003102:	f6e7a783          	lw	a5,-146(a5) # 8001f06c <sb+0x4>
    80003106:	10078163          	beqz	a5,80003208 <balloc+0x124>
    8000310a:	8baa                	mv	s7,a0
    8000310c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000310e:	0001cb17          	auipc	s6,0x1c
    80003112:	f5ab0b13          	addi	s6,s6,-166 # 8001f068 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003116:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003118:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000311a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000311c:	6c89                	lui	s9,0x2
    8000311e:	a061                	j	800031a6 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003120:	974a                	add	a4,a4,s2
    80003122:	8fd5                	or	a5,a5,a3
    80003124:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003128:	854a                	mv	a0,s2
    8000312a:	00001097          	auipc	ra,0x1
    8000312e:	0ac080e7          	jalr	172(ra) # 800041d6 <log_write>
        brelse(bp);
    80003132:	854a                	mv	a0,s2
    80003134:	00000097          	auipc	ra,0x0
    80003138:	e1e080e7          	jalr	-482(ra) # 80002f52 <brelse>
  bp = bread(dev, bno);
    8000313c:	85a6                	mv	a1,s1
    8000313e:	855e                	mv	a0,s7
    80003140:	00000097          	auipc	ra,0x0
    80003144:	ce2080e7          	jalr	-798(ra) # 80002e22 <bread>
    80003148:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000314a:	40000613          	li	a2,1024
    8000314e:	4581                	li	a1,0
    80003150:	05850513          	addi	a0,a0,88
    80003154:	ffffe097          	auipc	ra,0xffffe
    80003158:	b7e080e7          	jalr	-1154(ra) # 80000cd2 <memset>
  log_write(bp);
    8000315c:	854a                	mv	a0,s2
    8000315e:	00001097          	auipc	ra,0x1
    80003162:	078080e7          	jalr	120(ra) # 800041d6 <log_write>
  brelse(bp);
    80003166:	854a                	mv	a0,s2
    80003168:	00000097          	auipc	ra,0x0
    8000316c:	dea080e7          	jalr	-534(ra) # 80002f52 <brelse>
}
    80003170:	8526                	mv	a0,s1
    80003172:	60e6                	ld	ra,88(sp)
    80003174:	6446                	ld	s0,80(sp)
    80003176:	64a6                	ld	s1,72(sp)
    80003178:	6906                	ld	s2,64(sp)
    8000317a:	79e2                	ld	s3,56(sp)
    8000317c:	7a42                	ld	s4,48(sp)
    8000317e:	7aa2                	ld	s5,40(sp)
    80003180:	7b02                	ld	s6,32(sp)
    80003182:	6be2                	ld	s7,24(sp)
    80003184:	6c42                	ld	s8,16(sp)
    80003186:	6ca2                	ld	s9,8(sp)
    80003188:	6125                	addi	sp,sp,96
    8000318a:	8082                	ret
    brelse(bp);
    8000318c:	854a                	mv	a0,s2
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	dc4080e7          	jalr	-572(ra) # 80002f52 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003196:	015c87bb          	addw	a5,s9,s5
    8000319a:	00078a9b          	sext.w	s5,a5
    8000319e:	004b2703          	lw	a4,4(s6)
    800031a2:	06eaf363          	bgeu	s5,a4,80003208 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800031a6:	41fad79b          	sraiw	a5,s5,0x1f
    800031aa:	0137d79b          	srliw	a5,a5,0x13
    800031ae:	015787bb          	addw	a5,a5,s5
    800031b2:	40d7d79b          	sraiw	a5,a5,0xd
    800031b6:	01cb2583          	lw	a1,28(s6)
    800031ba:	9dbd                	addw	a1,a1,a5
    800031bc:	855e                	mv	a0,s7
    800031be:	00000097          	auipc	ra,0x0
    800031c2:	c64080e7          	jalr	-924(ra) # 80002e22 <bread>
    800031c6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c8:	004b2503          	lw	a0,4(s6)
    800031cc:	000a849b          	sext.w	s1,s5
    800031d0:	8662                	mv	a2,s8
    800031d2:	faa4fde3          	bgeu	s1,a0,8000318c <balloc+0xa8>
      m = 1 << (bi % 8);
    800031d6:	41f6579b          	sraiw	a5,a2,0x1f
    800031da:	01d7d69b          	srliw	a3,a5,0x1d
    800031de:	00c6873b          	addw	a4,a3,a2
    800031e2:	00777793          	andi	a5,a4,7
    800031e6:	9f95                	subw	a5,a5,a3
    800031e8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031ec:	4037571b          	sraiw	a4,a4,0x3
    800031f0:	00e906b3          	add	a3,s2,a4
    800031f4:	0586c683          	lbu	a3,88(a3)
    800031f8:	00d7f5b3          	and	a1,a5,a3
    800031fc:	d195                	beqz	a1,80003120 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031fe:	2605                	addiw	a2,a2,1
    80003200:	2485                	addiw	s1,s1,1
    80003202:	fd4618e3          	bne	a2,s4,800031d2 <balloc+0xee>
    80003206:	b759                	j	8000318c <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003208:	00005517          	auipc	a0,0x5
    8000320c:	37050513          	addi	a0,a0,880 # 80008578 <syscalls+0x100>
    80003210:	ffffd097          	auipc	ra,0xffffd
    80003214:	378080e7          	jalr	888(ra) # 80000588 <printf>
  return 0;
    80003218:	4481                	li	s1,0
    8000321a:	bf99                	j	80003170 <balloc+0x8c>

000000008000321c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000321c:	7179                	addi	sp,sp,-48
    8000321e:	f406                	sd	ra,40(sp)
    80003220:	f022                	sd	s0,32(sp)
    80003222:	ec26                	sd	s1,24(sp)
    80003224:	e84a                	sd	s2,16(sp)
    80003226:	e44e                	sd	s3,8(sp)
    80003228:	e052                	sd	s4,0(sp)
    8000322a:	1800                	addi	s0,sp,48
    8000322c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000322e:	47ad                	li	a5,11
    80003230:	02b7e763          	bltu	a5,a1,8000325e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003234:	02059493          	slli	s1,a1,0x20
    80003238:	9081                	srli	s1,s1,0x20
    8000323a:	048a                	slli	s1,s1,0x2
    8000323c:	94aa                	add	s1,s1,a0
    8000323e:	0504a903          	lw	s2,80(s1)
    80003242:	06091e63          	bnez	s2,800032be <bmap+0xa2>
      addr = balloc(ip->dev);
    80003246:	4108                	lw	a0,0(a0)
    80003248:	00000097          	auipc	ra,0x0
    8000324c:	e9c080e7          	jalr	-356(ra) # 800030e4 <balloc>
    80003250:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003254:	06090563          	beqz	s2,800032be <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003258:	0524a823          	sw	s2,80(s1)
    8000325c:	a08d                	j	800032be <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000325e:	ff45849b          	addiw	s1,a1,-12
    80003262:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003266:	0ff00793          	li	a5,255
    8000326a:	08e7e563          	bltu	a5,a4,800032f4 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000326e:	08052903          	lw	s2,128(a0)
    80003272:	00091d63          	bnez	s2,8000328c <bmap+0x70>
      addr = balloc(ip->dev);
    80003276:	4108                	lw	a0,0(a0)
    80003278:	00000097          	auipc	ra,0x0
    8000327c:	e6c080e7          	jalr	-404(ra) # 800030e4 <balloc>
    80003280:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003284:	02090d63          	beqz	s2,800032be <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003288:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000328c:	85ca                	mv	a1,s2
    8000328e:	0009a503          	lw	a0,0(s3)
    80003292:	00000097          	auipc	ra,0x0
    80003296:	b90080e7          	jalr	-1136(ra) # 80002e22 <bread>
    8000329a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000329c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032a0:	02049593          	slli	a1,s1,0x20
    800032a4:	9181                	srli	a1,a1,0x20
    800032a6:	058a                	slli	a1,a1,0x2
    800032a8:	00b784b3          	add	s1,a5,a1
    800032ac:	0004a903          	lw	s2,0(s1)
    800032b0:	02090063          	beqz	s2,800032d0 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032b4:	8552                	mv	a0,s4
    800032b6:	00000097          	auipc	ra,0x0
    800032ba:	c9c080e7          	jalr	-868(ra) # 80002f52 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032be:	854a                	mv	a0,s2
    800032c0:	70a2                	ld	ra,40(sp)
    800032c2:	7402                	ld	s0,32(sp)
    800032c4:	64e2                	ld	s1,24(sp)
    800032c6:	6942                	ld	s2,16(sp)
    800032c8:	69a2                	ld	s3,8(sp)
    800032ca:	6a02                	ld	s4,0(sp)
    800032cc:	6145                	addi	sp,sp,48
    800032ce:	8082                	ret
      addr = balloc(ip->dev);
    800032d0:	0009a503          	lw	a0,0(s3)
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	e10080e7          	jalr	-496(ra) # 800030e4 <balloc>
    800032dc:	0005091b          	sext.w	s2,a0
      if(addr){
    800032e0:	fc090ae3          	beqz	s2,800032b4 <bmap+0x98>
        a[bn] = addr;
    800032e4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032e8:	8552                	mv	a0,s4
    800032ea:	00001097          	auipc	ra,0x1
    800032ee:	eec080e7          	jalr	-276(ra) # 800041d6 <log_write>
    800032f2:	b7c9                	j	800032b4 <bmap+0x98>
  panic("bmap: out of range");
    800032f4:	00005517          	auipc	a0,0x5
    800032f8:	29c50513          	addi	a0,a0,668 # 80008590 <syscalls+0x118>
    800032fc:	ffffd097          	auipc	ra,0xffffd
    80003300:	242080e7          	jalr	578(ra) # 8000053e <panic>

0000000080003304 <iget>:
{
    80003304:	7179                	addi	sp,sp,-48
    80003306:	f406                	sd	ra,40(sp)
    80003308:	f022                	sd	s0,32(sp)
    8000330a:	ec26                	sd	s1,24(sp)
    8000330c:	e84a                	sd	s2,16(sp)
    8000330e:	e44e                	sd	s3,8(sp)
    80003310:	e052                	sd	s4,0(sp)
    80003312:	1800                	addi	s0,sp,48
    80003314:	89aa                	mv	s3,a0
    80003316:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003318:	0001c517          	auipc	a0,0x1c
    8000331c:	d7050513          	addi	a0,a0,-656 # 8001f088 <itable>
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	8b6080e7          	jalr	-1866(ra) # 80000bd6 <acquire>
  empty = 0;
    80003328:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000332a:	0001c497          	auipc	s1,0x1c
    8000332e:	d7648493          	addi	s1,s1,-650 # 8001f0a0 <itable+0x18>
    80003332:	0001d697          	auipc	a3,0x1d
    80003336:	7fe68693          	addi	a3,a3,2046 # 80020b30 <log>
    8000333a:	a039                	j	80003348 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000333c:	02090b63          	beqz	s2,80003372 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003340:	08848493          	addi	s1,s1,136
    80003344:	02d48a63          	beq	s1,a3,80003378 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003348:	449c                	lw	a5,8(s1)
    8000334a:	fef059e3          	blez	a5,8000333c <iget+0x38>
    8000334e:	4098                	lw	a4,0(s1)
    80003350:	ff3716e3          	bne	a4,s3,8000333c <iget+0x38>
    80003354:	40d8                	lw	a4,4(s1)
    80003356:	ff4713e3          	bne	a4,s4,8000333c <iget+0x38>
      ip->ref++;
    8000335a:	2785                	addiw	a5,a5,1
    8000335c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000335e:	0001c517          	auipc	a0,0x1c
    80003362:	d2a50513          	addi	a0,a0,-726 # 8001f088 <itable>
    80003366:	ffffe097          	auipc	ra,0xffffe
    8000336a:	924080e7          	jalr	-1756(ra) # 80000c8a <release>
      return ip;
    8000336e:	8926                	mv	s2,s1
    80003370:	a03d                	j	8000339e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003372:	f7f9                	bnez	a5,80003340 <iget+0x3c>
    80003374:	8926                	mv	s2,s1
    80003376:	b7e9                	j	80003340 <iget+0x3c>
  if(empty == 0)
    80003378:	02090c63          	beqz	s2,800033b0 <iget+0xac>
  ip->dev = dev;
    8000337c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003380:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003384:	4785                	li	a5,1
    80003386:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000338a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000338e:	0001c517          	auipc	a0,0x1c
    80003392:	cfa50513          	addi	a0,a0,-774 # 8001f088 <itable>
    80003396:	ffffe097          	auipc	ra,0xffffe
    8000339a:	8f4080e7          	jalr	-1804(ra) # 80000c8a <release>
}
    8000339e:	854a                	mv	a0,s2
    800033a0:	70a2                	ld	ra,40(sp)
    800033a2:	7402                	ld	s0,32(sp)
    800033a4:	64e2                	ld	s1,24(sp)
    800033a6:	6942                	ld	s2,16(sp)
    800033a8:	69a2                	ld	s3,8(sp)
    800033aa:	6a02                	ld	s4,0(sp)
    800033ac:	6145                	addi	sp,sp,48
    800033ae:	8082                	ret
    panic("iget: no inodes");
    800033b0:	00005517          	auipc	a0,0x5
    800033b4:	1f850513          	addi	a0,a0,504 # 800085a8 <syscalls+0x130>
    800033b8:	ffffd097          	auipc	ra,0xffffd
    800033bc:	186080e7          	jalr	390(ra) # 8000053e <panic>

00000000800033c0 <fsinit>:
fsinit(int dev) {
    800033c0:	7179                	addi	sp,sp,-48
    800033c2:	f406                	sd	ra,40(sp)
    800033c4:	f022                	sd	s0,32(sp)
    800033c6:	ec26                	sd	s1,24(sp)
    800033c8:	e84a                	sd	s2,16(sp)
    800033ca:	e44e                	sd	s3,8(sp)
    800033cc:	1800                	addi	s0,sp,48
    800033ce:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033d0:	4585                	li	a1,1
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	a50080e7          	jalr	-1456(ra) # 80002e22 <bread>
    800033da:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033dc:	0001c997          	auipc	s3,0x1c
    800033e0:	c8c98993          	addi	s3,s3,-884 # 8001f068 <sb>
    800033e4:	02000613          	li	a2,32
    800033e8:	05850593          	addi	a1,a0,88
    800033ec:	854e                	mv	a0,s3
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	940080e7          	jalr	-1728(ra) # 80000d2e <memmove>
  brelse(bp);
    800033f6:	8526                	mv	a0,s1
    800033f8:	00000097          	auipc	ra,0x0
    800033fc:	b5a080e7          	jalr	-1190(ra) # 80002f52 <brelse>
  if(sb.magic != FSMAGIC)
    80003400:	0009a703          	lw	a4,0(s3)
    80003404:	102037b7          	lui	a5,0x10203
    80003408:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000340c:	02f71263          	bne	a4,a5,80003430 <fsinit+0x70>
  initlog(dev, &sb);
    80003410:	0001c597          	auipc	a1,0x1c
    80003414:	c5858593          	addi	a1,a1,-936 # 8001f068 <sb>
    80003418:	854a                	mv	a0,s2
    8000341a:	00001097          	auipc	ra,0x1
    8000341e:	b40080e7          	jalr	-1216(ra) # 80003f5a <initlog>
}
    80003422:	70a2                	ld	ra,40(sp)
    80003424:	7402                	ld	s0,32(sp)
    80003426:	64e2                	ld	s1,24(sp)
    80003428:	6942                	ld	s2,16(sp)
    8000342a:	69a2                	ld	s3,8(sp)
    8000342c:	6145                	addi	sp,sp,48
    8000342e:	8082                	ret
    panic("invalid file system");
    80003430:	00005517          	auipc	a0,0x5
    80003434:	18850513          	addi	a0,a0,392 # 800085b8 <syscalls+0x140>
    80003438:	ffffd097          	auipc	ra,0xffffd
    8000343c:	106080e7          	jalr	262(ra) # 8000053e <panic>

0000000080003440 <iinit>:
{
    80003440:	7179                	addi	sp,sp,-48
    80003442:	f406                	sd	ra,40(sp)
    80003444:	f022                	sd	s0,32(sp)
    80003446:	ec26                	sd	s1,24(sp)
    80003448:	e84a                	sd	s2,16(sp)
    8000344a:	e44e                	sd	s3,8(sp)
    8000344c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000344e:	00005597          	auipc	a1,0x5
    80003452:	18258593          	addi	a1,a1,386 # 800085d0 <syscalls+0x158>
    80003456:	0001c517          	auipc	a0,0x1c
    8000345a:	c3250513          	addi	a0,a0,-974 # 8001f088 <itable>
    8000345e:	ffffd097          	auipc	ra,0xffffd
    80003462:	6e8080e7          	jalr	1768(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003466:	0001c497          	auipc	s1,0x1c
    8000346a:	c4a48493          	addi	s1,s1,-950 # 8001f0b0 <itable+0x28>
    8000346e:	0001d997          	auipc	s3,0x1d
    80003472:	6d298993          	addi	s3,s3,1746 # 80020b40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003476:	00005917          	auipc	s2,0x5
    8000347a:	16290913          	addi	s2,s2,354 # 800085d8 <syscalls+0x160>
    8000347e:	85ca                	mv	a1,s2
    80003480:	8526                	mv	a0,s1
    80003482:	00001097          	auipc	ra,0x1
    80003486:	e3a080e7          	jalr	-454(ra) # 800042bc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000348a:	08848493          	addi	s1,s1,136
    8000348e:	ff3498e3          	bne	s1,s3,8000347e <iinit+0x3e>
}
    80003492:	70a2                	ld	ra,40(sp)
    80003494:	7402                	ld	s0,32(sp)
    80003496:	64e2                	ld	s1,24(sp)
    80003498:	6942                	ld	s2,16(sp)
    8000349a:	69a2                	ld	s3,8(sp)
    8000349c:	6145                	addi	sp,sp,48
    8000349e:	8082                	ret

00000000800034a0 <ialloc>:
{
    800034a0:	715d                	addi	sp,sp,-80
    800034a2:	e486                	sd	ra,72(sp)
    800034a4:	e0a2                	sd	s0,64(sp)
    800034a6:	fc26                	sd	s1,56(sp)
    800034a8:	f84a                	sd	s2,48(sp)
    800034aa:	f44e                	sd	s3,40(sp)
    800034ac:	f052                	sd	s4,32(sp)
    800034ae:	ec56                	sd	s5,24(sp)
    800034b0:	e85a                	sd	s6,16(sp)
    800034b2:	e45e                	sd	s7,8(sp)
    800034b4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800034b6:	0001c717          	auipc	a4,0x1c
    800034ba:	bbe72703          	lw	a4,-1090(a4) # 8001f074 <sb+0xc>
    800034be:	4785                	li	a5,1
    800034c0:	04e7fa63          	bgeu	a5,a4,80003514 <ialloc+0x74>
    800034c4:	8aaa                	mv	s5,a0
    800034c6:	8bae                	mv	s7,a1
    800034c8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034ca:	0001ca17          	auipc	s4,0x1c
    800034ce:	b9ea0a13          	addi	s4,s4,-1122 # 8001f068 <sb>
    800034d2:	00048b1b          	sext.w	s6,s1
    800034d6:	0044d793          	srli	a5,s1,0x4
    800034da:	018a2583          	lw	a1,24(s4)
    800034de:	9dbd                	addw	a1,a1,a5
    800034e0:	8556                	mv	a0,s5
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	940080e7          	jalr	-1728(ra) # 80002e22 <bread>
    800034ea:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034ec:	05850993          	addi	s3,a0,88
    800034f0:	00f4f793          	andi	a5,s1,15
    800034f4:	079a                	slli	a5,a5,0x6
    800034f6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034f8:	00099783          	lh	a5,0(s3)
    800034fc:	c3a1                	beqz	a5,8000353c <ialloc+0x9c>
    brelse(bp);
    800034fe:	00000097          	auipc	ra,0x0
    80003502:	a54080e7          	jalr	-1452(ra) # 80002f52 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003506:	0485                	addi	s1,s1,1
    80003508:	00ca2703          	lw	a4,12(s4)
    8000350c:	0004879b          	sext.w	a5,s1
    80003510:	fce7e1e3          	bltu	a5,a4,800034d2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003514:	00005517          	auipc	a0,0x5
    80003518:	0cc50513          	addi	a0,a0,204 # 800085e0 <syscalls+0x168>
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	06c080e7          	jalr	108(ra) # 80000588 <printf>
  return 0;
    80003524:	4501                	li	a0,0
}
    80003526:	60a6                	ld	ra,72(sp)
    80003528:	6406                	ld	s0,64(sp)
    8000352a:	74e2                	ld	s1,56(sp)
    8000352c:	7942                	ld	s2,48(sp)
    8000352e:	79a2                	ld	s3,40(sp)
    80003530:	7a02                	ld	s4,32(sp)
    80003532:	6ae2                	ld	s5,24(sp)
    80003534:	6b42                	ld	s6,16(sp)
    80003536:	6ba2                	ld	s7,8(sp)
    80003538:	6161                	addi	sp,sp,80
    8000353a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000353c:	04000613          	li	a2,64
    80003540:	4581                	li	a1,0
    80003542:	854e                	mv	a0,s3
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	78e080e7          	jalr	1934(ra) # 80000cd2 <memset>
      dip->type = type;
    8000354c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003550:	854a                	mv	a0,s2
    80003552:	00001097          	auipc	ra,0x1
    80003556:	c84080e7          	jalr	-892(ra) # 800041d6 <log_write>
      brelse(bp);
    8000355a:	854a                	mv	a0,s2
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	9f6080e7          	jalr	-1546(ra) # 80002f52 <brelse>
      return iget(dev, inum);
    80003564:	85da                	mv	a1,s6
    80003566:	8556                	mv	a0,s5
    80003568:	00000097          	auipc	ra,0x0
    8000356c:	d9c080e7          	jalr	-612(ra) # 80003304 <iget>
    80003570:	bf5d                	j	80003526 <ialloc+0x86>

0000000080003572 <iupdate>:
{
    80003572:	1101                	addi	sp,sp,-32
    80003574:	ec06                	sd	ra,24(sp)
    80003576:	e822                	sd	s0,16(sp)
    80003578:	e426                	sd	s1,8(sp)
    8000357a:	e04a                	sd	s2,0(sp)
    8000357c:	1000                	addi	s0,sp,32
    8000357e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003580:	415c                	lw	a5,4(a0)
    80003582:	0047d79b          	srliw	a5,a5,0x4
    80003586:	0001c597          	auipc	a1,0x1c
    8000358a:	afa5a583          	lw	a1,-1286(a1) # 8001f080 <sb+0x18>
    8000358e:	9dbd                	addw	a1,a1,a5
    80003590:	4108                	lw	a0,0(a0)
    80003592:	00000097          	auipc	ra,0x0
    80003596:	890080e7          	jalr	-1904(ra) # 80002e22 <bread>
    8000359a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000359c:	05850793          	addi	a5,a0,88
    800035a0:	40c8                	lw	a0,4(s1)
    800035a2:	893d                	andi	a0,a0,15
    800035a4:	051a                	slli	a0,a0,0x6
    800035a6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800035a8:	04449703          	lh	a4,68(s1)
    800035ac:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800035b0:	04649703          	lh	a4,70(s1)
    800035b4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800035b8:	04849703          	lh	a4,72(s1)
    800035bc:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800035c0:	04a49703          	lh	a4,74(s1)
    800035c4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800035c8:	44f8                	lw	a4,76(s1)
    800035ca:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035cc:	03400613          	li	a2,52
    800035d0:	05048593          	addi	a1,s1,80
    800035d4:	0531                	addi	a0,a0,12
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	758080e7          	jalr	1880(ra) # 80000d2e <memmove>
  log_write(bp);
    800035de:	854a                	mv	a0,s2
    800035e0:	00001097          	auipc	ra,0x1
    800035e4:	bf6080e7          	jalr	-1034(ra) # 800041d6 <log_write>
  brelse(bp);
    800035e8:	854a                	mv	a0,s2
    800035ea:	00000097          	auipc	ra,0x0
    800035ee:	968080e7          	jalr	-1688(ra) # 80002f52 <brelse>
}
    800035f2:	60e2                	ld	ra,24(sp)
    800035f4:	6442                	ld	s0,16(sp)
    800035f6:	64a2                	ld	s1,8(sp)
    800035f8:	6902                	ld	s2,0(sp)
    800035fa:	6105                	addi	sp,sp,32
    800035fc:	8082                	ret

00000000800035fe <idup>:
{
    800035fe:	1101                	addi	sp,sp,-32
    80003600:	ec06                	sd	ra,24(sp)
    80003602:	e822                	sd	s0,16(sp)
    80003604:	e426                	sd	s1,8(sp)
    80003606:	1000                	addi	s0,sp,32
    80003608:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000360a:	0001c517          	auipc	a0,0x1c
    8000360e:	a7e50513          	addi	a0,a0,-1410 # 8001f088 <itable>
    80003612:	ffffd097          	auipc	ra,0xffffd
    80003616:	5c4080e7          	jalr	1476(ra) # 80000bd6 <acquire>
  ip->ref++;
    8000361a:	449c                	lw	a5,8(s1)
    8000361c:	2785                	addiw	a5,a5,1
    8000361e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003620:	0001c517          	auipc	a0,0x1c
    80003624:	a6850513          	addi	a0,a0,-1432 # 8001f088 <itable>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	662080e7          	jalr	1634(ra) # 80000c8a <release>
}
    80003630:	8526                	mv	a0,s1
    80003632:	60e2                	ld	ra,24(sp)
    80003634:	6442                	ld	s0,16(sp)
    80003636:	64a2                	ld	s1,8(sp)
    80003638:	6105                	addi	sp,sp,32
    8000363a:	8082                	ret

000000008000363c <ilock>:
{
    8000363c:	1101                	addi	sp,sp,-32
    8000363e:	ec06                	sd	ra,24(sp)
    80003640:	e822                	sd	s0,16(sp)
    80003642:	e426                	sd	s1,8(sp)
    80003644:	e04a                	sd	s2,0(sp)
    80003646:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003648:	c115                	beqz	a0,8000366c <ilock+0x30>
    8000364a:	84aa                	mv	s1,a0
    8000364c:	451c                	lw	a5,8(a0)
    8000364e:	00f05f63          	blez	a5,8000366c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003652:	0541                	addi	a0,a0,16
    80003654:	00001097          	auipc	ra,0x1
    80003658:	ca2080e7          	jalr	-862(ra) # 800042f6 <acquiresleep>
  if(ip->valid == 0){
    8000365c:	40bc                	lw	a5,64(s1)
    8000365e:	cf99                	beqz	a5,8000367c <ilock+0x40>
}
    80003660:	60e2                	ld	ra,24(sp)
    80003662:	6442                	ld	s0,16(sp)
    80003664:	64a2                	ld	s1,8(sp)
    80003666:	6902                	ld	s2,0(sp)
    80003668:	6105                	addi	sp,sp,32
    8000366a:	8082                	ret
    panic("ilock");
    8000366c:	00005517          	auipc	a0,0x5
    80003670:	f8c50513          	addi	a0,a0,-116 # 800085f8 <syscalls+0x180>
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	eca080e7          	jalr	-310(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000367c:	40dc                	lw	a5,4(s1)
    8000367e:	0047d79b          	srliw	a5,a5,0x4
    80003682:	0001c597          	auipc	a1,0x1c
    80003686:	9fe5a583          	lw	a1,-1538(a1) # 8001f080 <sb+0x18>
    8000368a:	9dbd                	addw	a1,a1,a5
    8000368c:	4088                	lw	a0,0(s1)
    8000368e:	fffff097          	auipc	ra,0xfffff
    80003692:	794080e7          	jalr	1940(ra) # 80002e22 <bread>
    80003696:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003698:	05850593          	addi	a1,a0,88
    8000369c:	40dc                	lw	a5,4(s1)
    8000369e:	8bbd                	andi	a5,a5,15
    800036a0:	079a                	slli	a5,a5,0x6
    800036a2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036a4:	00059783          	lh	a5,0(a1)
    800036a8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036ac:	00259783          	lh	a5,2(a1)
    800036b0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036b4:	00459783          	lh	a5,4(a1)
    800036b8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036bc:	00659783          	lh	a5,6(a1)
    800036c0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036c4:	459c                	lw	a5,8(a1)
    800036c6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036c8:	03400613          	li	a2,52
    800036cc:	05b1                	addi	a1,a1,12
    800036ce:	05048513          	addi	a0,s1,80
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	65c080e7          	jalr	1628(ra) # 80000d2e <memmove>
    brelse(bp);
    800036da:	854a                	mv	a0,s2
    800036dc:	00000097          	auipc	ra,0x0
    800036e0:	876080e7          	jalr	-1930(ra) # 80002f52 <brelse>
    ip->valid = 1;
    800036e4:	4785                	li	a5,1
    800036e6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036e8:	04449783          	lh	a5,68(s1)
    800036ec:	fbb5                	bnez	a5,80003660 <ilock+0x24>
      panic("ilock: no type");
    800036ee:	00005517          	auipc	a0,0x5
    800036f2:	f1250513          	addi	a0,a0,-238 # 80008600 <syscalls+0x188>
    800036f6:	ffffd097          	auipc	ra,0xffffd
    800036fa:	e48080e7          	jalr	-440(ra) # 8000053e <panic>

00000000800036fe <iunlock>:
{
    800036fe:	1101                	addi	sp,sp,-32
    80003700:	ec06                	sd	ra,24(sp)
    80003702:	e822                	sd	s0,16(sp)
    80003704:	e426                	sd	s1,8(sp)
    80003706:	e04a                	sd	s2,0(sp)
    80003708:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000370a:	c905                	beqz	a0,8000373a <iunlock+0x3c>
    8000370c:	84aa                	mv	s1,a0
    8000370e:	01050913          	addi	s2,a0,16
    80003712:	854a                	mv	a0,s2
    80003714:	00001097          	auipc	ra,0x1
    80003718:	c7c080e7          	jalr	-900(ra) # 80004390 <holdingsleep>
    8000371c:	cd19                	beqz	a0,8000373a <iunlock+0x3c>
    8000371e:	449c                	lw	a5,8(s1)
    80003720:	00f05d63          	blez	a5,8000373a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003724:	854a                	mv	a0,s2
    80003726:	00001097          	auipc	ra,0x1
    8000372a:	c26080e7          	jalr	-986(ra) # 8000434c <releasesleep>
}
    8000372e:	60e2                	ld	ra,24(sp)
    80003730:	6442                	ld	s0,16(sp)
    80003732:	64a2                	ld	s1,8(sp)
    80003734:	6902                	ld	s2,0(sp)
    80003736:	6105                	addi	sp,sp,32
    80003738:	8082                	ret
    panic("iunlock");
    8000373a:	00005517          	auipc	a0,0x5
    8000373e:	ed650513          	addi	a0,a0,-298 # 80008610 <syscalls+0x198>
    80003742:	ffffd097          	auipc	ra,0xffffd
    80003746:	dfc080e7          	jalr	-516(ra) # 8000053e <panic>

000000008000374a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000374a:	7179                	addi	sp,sp,-48
    8000374c:	f406                	sd	ra,40(sp)
    8000374e:	f022                	sd	s0,32(sp)
    80003750:	ec26                	sd	s1,24(sp)
    80003752:	e84a                	sd	s2,16(sp)
    80003754:	e44e                	sd	s3,8(sp)
    80003756:	e052                	sd	s4,0(sp)
    80003758:	1800                	addi	s0,sp,48
    8000375a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000375c:	05050493          	addi	s1,a0,80
    80003760:	08050913          	addi	s2,a0,128
    80003764:	a021                	j	8000376c <itrunc+0x22>
    80003766:	0491                	addi	s1,s1,4
    80003768:	01248d63          	beq	s1,s2,80003782 <itrunc+0x38>
    if(ip->addrs[i]){
    8000376c:	408c                	lw	a1,0(s1)
    8000376e:	dde5                	beqz	a1,80003766 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003770:	0009a503          	lw	a0,0(s3)
    80003774:	00000097          	auipc	ra,0x0
    80003778:	8f4080e7          	jalr	-1804(ra) # 80003068 <bfree>
      ip->addrs[i] = 0;
    8000377c:	0004a023          	sw	zero,0(s1)
    80003780:	b7dd                	j	80003766 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003782:	0809a583          	lw	a1,128(s3)
    80003786:	e185                	bnez	a1,800037a6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003788:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000378c:	854e                	mv	a0,s3
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	de4080e7          	jalr	-540(ra) # 80003572 <iupdate>
}
    80003796:	70a2                	ld	ra,40(sp)
    80003798:	7402                	ld	s0,32(sp)
    8000379a:	64e2                	ld	s1,24(sp)
    8000379c:	6942                	ld	s2,16(sp)
    8000379e:	69a2                	ld	s3,8(sp)
    800037a0:	6a02                	ld	s4,0(sp)
    800037a2:	6145                	addi	sp,sp,48
    800037a4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037a6:	0009a503          	lw	a0,0(s3)
    800037aa:	fffff097          	auipc	ra,0xfffff
    800037ae:	678080e7          	jalr	1656(ra) # 80002e22 <bread>
    800037b2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037b4:	05850493          	addi	s1,a0,88
    800037b8:	45850913          	addi	s2,a0,1112
    800037bc:	a021                	j	800037c4 <itrunc+0x7a>
    800037be:	0491                	addi	s1,s1,4
    800037c0:	01248b63          	beq	s1,s2,800037d6 <itrunc+0x8c>
      if(a[j])
    800037c4:	408c                	lw	a1,0(s1)
    800037c6:	dde5                	beqz	a1,800037be <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037c8:	0009a503          	lw	a0,0(s3)
    800037cc:	00000097          	auipc	ra,0x0
    800037d0:	89c080e7          	jalr	-1892(ra) # 80003068 <bfree>
    800037d4:	b7ed                	j	800037be <itrunc+0x74>
    brelse(bp);
    800037d6:	8552                	mv	a0,s4
    800037d8:	fffff097          	auipc	ra,0xfffff
    800037dc:	77a080e7          	jalr	1914(ra) # 80002f52 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037e0:	0809a583          	lw	a1,128(s3)
    800037e4:	0009a503          	lw	a0,0(s3)
    800037e8:	00000097          	auipc	ra,0x0
    800037ec:	880080e7          	jalr	-1920(ra) # 80003068 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037f0:	0809a023          	sw	zero,128(s3)
    800037f4:	bf51                	j	80003788 <itrunc+0x3e>

00000000800037f6 <iput>:
{
    800037f6:	1101                	addi	sp,sp,-32
    800037f8:	ec06                	sd	ra,24(sp)
    800037fa:	e822                	sd	s0,16(sp)
    800037fc:	e426                	sd	s1,8(sp)
    800037fe:	e04a                	sd	s2,0(sp)
    80003800:	1000                	addi	s0,sp,32
    80003802:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003804:	0001c517          	auipc	a0,0x1c
    80003808:	88450513          	addi	a0,a0,-1916 # 8001f088 <itable>
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	3ca080e7          	jalr	970(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003814:	4498                	lw	a4,8(s1)
    80003816:	4785                	li	a5,1
    80003818:	02f70363          	beq	a4,a5,8000383e <iput+0x48>
  ip->ref--;
    8000381c:	449c                	lw	a5,8(s1)
    8000381e:	37fd                	addiw	a5,a5,-1
    80003820:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003822:	0001c517          	auipc	a0,0x1c
    80003826:	86650513          	addi	a0,a0,-1946 # 8001f088 <itable>
    8000382a:	ffffd097          	auipc	ra,0xffffd
    8000382e:	460080e7          	jalr	1120(ra) # 80000c8a <release>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	64a2                	ld	s1,8(sp)
    80003838:	6902                	ld	s2,0(sp)
    8000383a:	6105                	addi	sp,sp,32
    8000383c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000383e:	40bc                	lw	a5,64(s1)
    80003840:	dff1                	beqz	a5,8000381c <iput+0x26>
    80003842:	04a49783          	lh	a5,74(s1)
    80003846:	fbf9                	bnez	a5,8000381c <iput+0x26>
    acquiresleep(&ip->lock);
    80003848:	01048913          	addi	s2,s1,16
    8000384c:	854a                	mv	a0,s2
    8000384e:	00001097          	auipc	ra,0x1
    80003852:	aa8080e7          	jalr	-1368(ra) # 800042f6 <acquiresleep>
    release(&itable.lock);
    80003856:	0001c517          	auipc	a0,0x1c
    8000385a:	83250513          	addi	a0,a0,-1998 # 8001f088 <itable>
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	42c080e7          	jalr	1068(ra) # 80000c8a <release>
    itrunc(ip);
    80003866:	8526                	mv	a0,s1
    80003868:	00000097          	auipc	ra,0x0
    8000386c:	ee2080e7          	jalr	-286(ra) # 8000374a <itrunc>
    ip->type = 0;
    80003870:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003874:	8526                	mv	a0,s1
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	cfc080e7          	jalr	-772(ra) # 80003572 <iupdate>
    ip->valid = 0;
    8000387e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003882:	854a                	mv	a0,s2
    80003884:	00001097          	auipc	ra,0x1
    80003888:	ac8080e7          	jalr	-1336(ra) # 8000434c <releasesleep>
    acquire(&itable.lock);
    8000388c:	0001b517          	auipc	a0,0x1b
    80003890:	7fc50513          	addi	a0,a0,2044 # 8001f088 <itable>
    80003894:	ffffd097          	auipc	ra,0xffffd
    80003898:	342080e7          	jalr	834(ra) # 80000bd6 <acquire>
    8000389c:	b741                	j	8000381c <iput+0x26>

000000008000389e <iunlockput>:
{
    8000389e:	1101                	addi	sp,sp,-32
    800038a0:	ec06                	sd	ra,24(sp)
    800038a2:	e822                	sd	s0,16(sp)
    800038a4:	e426                	sd	s1,8(sp)
    800038a6:	1000                	addi	s0,sp,32
    800038a8:	84aa                	mv	s1,a0
  iunlock(ip);
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	e54080e7          	jalr	-428(ra) # 800036fe <iunlock>
  iput(ip);
    800038b2:	8526                	mv	a0,s1
    800038b4:	00000097          	auipc	ra,0x0
    800038b8:	f42080e7          	jalr	-190(ra) # 800037f6 <iput>
}
    800038bc:	60e2                	ld	ra,24(sp)
    800038be:	6442                	ld	s0,16(sp)
    800038c0:	64a2                	ld	s1,8(sp)
    800038c2:	6105                	addi	sp,sp,32
    800038c4:	8082                	ret

00000000800038c6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038c6:	1141                	addi	sp,sp,-16
    800038c8:	e422                	sd	s0,8(sp)
    800038ca:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038cc:	411c                	lw	a5,0(a0)
    800038ce:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038d0:	415c                	lw	a5,4(a0)
    800038d2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038d4:	04451783          	lh	a5,68(a0)
    800038d8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038dc:	04a51783          	lh	a5,74(a0)
    800038e0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038e4:	04c56783          	lwu	a5,76(a0)
    800038e8:	e99c                	sd	a5,16(a1)
}
    800038ea:	6422                	ld	s0,8(sp)
    800038ec:	0141                	addi	sp,sp,16
    800038ee:	8082                	ret

00000000800038f0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038f0:	457c                	lw	a5,76(a0)
    800038f2:	0ed7e963          	bltu	a5,a3,800039e4 <readi+0xf4>
{
    800038f6:	7159                	addi	sp,sp,-112
    800038f8:	f486                	sd	ra,104(sp)
    800038fa:	f0a2                	sd	s0,96(sp)
    800038fc:	eca6                	sd	s1,88(sp)
    800038fe:	e8ca                	sd	s2,80(sp)
    80003900:	e4ce                	sd	s3,72(sp)
    80003902:	e0d2                	sd	s4,64(sp)
    80003904:	fc56                	sd	s5,56(sp)
    80003906:	f85a                	sd	s6,48(sp)
    80003908:	f45e                	sd	s7,40(sp)
    8000390a:	f062                	sd	s8,32(sp)
    8000390c:	ec66                	sd	s9,24(sp)
    8000390e:	e86a                	sd	s10,16(sp)
    80003910:	e46e                	sd	s11,8(sp)
    80003912:	1880                	addi	s0,sp,112
    80003914:	8b2a                	mv	s6,a0
    80003916:	8bae                	mv	s7,a1
    80003918:	8a32                	mv	s4,a2
    8000391a:	84b6                	mv	s1,a3
    8000391c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000391e:	9f35                	addw	a4,a4,a3
    return 0;
    80003920:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003922:	0ad76063          	bltu	a4,a3,800039c2 <readi+0xd2>
  if(off + n > ip->size)
    80003926:	00e7f463          	bgeu	a5,a4,8000392e <readi+0x3e>
    n = ip->size - off;
    8000392a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000392e:	0a0a8963          	beqz	s5,800039e0 <readi+0xf0>
    80003932:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003934:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003938:	5c7d                	li	s8,-1
    8000393a:	a82d                	j	80003974 <readi+0x84>
    8000393c:	020d1d93          	slli	s11,s10,0x20
    80003940:	020ddd93          	srli	s11,s11,0x20
    80003944:	05890793          	addi	a5,s2,88
    80003948:	86ee                	mv	a3,s11
    8000394a:	963e                	add	a2,a2,a5
    8000394c:	85d2                	mv	a1,s4
    8000394e:	855e                	mv	a0,s7
    80003950:	fffff097          	auipc	ra,0xfffff
    80003954:	b1c080e7          	jalr	-1252(ra) # 8000246c <either_copyout>
    80003958:	05850d63          	beq	a0,s8,800039b2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000395c:	854a                	mv	a0,s2
    8000395e:	fffff097          	auipc	ra,0xfffff
    80003962:	5f4080e7          	jalr	1524(ra) # 80002f52 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003966:	013d09bb          	addw	s3,s10,s3
    8000396a:	009d04bb          	addw	s1,s10,s1
    8000396e:	9a6e                	add	s4,s4,s11
    80003970:	0559f763          	bgeu	s3,s5,800039be <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003974:	00a4d59b          	srliw	a1,s1,0xa
    80003978:	855a                	mv	a0,s6
    8000397a:	00000097          	auipc	ra,0x0
    8000397e:	8a2080e7          	jalr	-1886(ra) # 8000321c <bmap>
    80003982:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003986:	cd85                	beqz	a1,800039be <readi+0xce>
    bp = bread(ip->dev, addr);
    80003988:	000b2503          	lw	a0,0(s6)
    8000398c:	fffff097          	auipc	ra,0xfffff
    80003990:	496080e7          	jalr	1174(ra) # 80002e22 <bread>
    80003994:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003996:	3ff4f613          	andi	a2,s1,1023
    8000399a:	40cc87bb          	subw	a5,s9,a2
    8000399e:	413a873b          	subw	a4,s5,s3
    800039a2:	8d3e                	mv	s10,a5
    800039a4:	2781                	sext.w	a5,a5
    800039a6:	0007069b          	sext.w	a3,a4
    800039aa:	f8f6f9e3          	bgeu	a3,a5,8000393c <readi+0x4c>
    800039ae:	8d3a                	mv	s10,a4
    800039b0:	b771                	j	8000393c <readi+0x4c>
      brelse(bp);
    800039b2:	854a                	mv	a0,s2
    800039b4:	fffff097          	auipc	ra,0xfffff
    800039b8:	59e080e7          	jalr	1438(ra) # 80002f52 <brelse>
      tot = -1;
    800039bc:	59fd                	li	s3,-1
  }
  return tot;
    800039be:	0009851b          	sext.w	a0,s3
}
    800039c2:	70a6                	ld	ra,104(sp)
    800039c4:	7406                	ld	s0,96(sp)
    800039c6:	64e6                	ld	s1,88(sp)
    800039c8:	6946                	ld	s2,80(sp)
    800039ca:	69a6                	ld	s3,72(sp)
    800039cc:	6a06                	ld	s4,64(sp)
    800039ce:	7ae2                	ld	s5,56(sp)
    800039d0:	7b42                	ld	s6,48(sp)
    800039d2:	7ba2                	ld	s7,40(sp)
    800039d4:	7c02                	ld	s8,32(sp)
    800039d6:	6ce2                	ld	s9,24(sp)
    800039d8:	6d42                	ld	s10,16(sp)
    800039da:	6da2                	ld	s11,8(sp)
    800039dc:	6165                	addi	sp,sp,112
    800039de:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039e0:	89d6                	mv	s3,s5
    800039e2:	bff1                	j	800039be <readi+0xce>
    return 0;
    800039e4:	4501                	li	a0,0
}
    800039e6:	8082                	ret

00000000800039e8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039e8:	457c                	lw	a5,76(a0)
    800039ea:	10d7e863          	bltu	a5,a3,80003afa <writei+0x112>
{
    800039ee:	7159                	addi	sp,sp,-112
    800039f0:	f486                	sd	ra,104(sp)
    800039f2:	f0a2                	sd	s0,96(sp)
    800039f4:	eca6                	sd	s1,88(sp)
    800039f6:	e8ca                	sd	s2,80(sp)
    800039f8:	e4ce                	sd	s3,72(sp)
    800039fa:	e0d2                	sd	s4,64(sp)
    800039fc:	fc56                	sd	s5,56(sp)
    800039fe:	f85a                	sd	s6,48(sp)
    80003a00:	f45e                	sd	s7,40(sp)
    80003a02:	f062                	sd	s8,32(sp)
    80003a04:	ec66                	sd	s9,24(sp)
    80003a06:	e86a                	sd	s10,16(sp)
    80003a08:	e46e                	sd	s11,8(sp)
    80003a0a:	1880                	addi	s0,sp,112
    80003a0c:	8aaa                	mv	s5,a0
    80003a0e:	8bae                	mv	s7,a1
    80003a10:	8a32                	mv	s4,a2
    80003a12:	8936                	mv	s2,a3
    80003a14:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a16:	00e687bb          	addw	a5,a3,a4
    80003a1a:	0ed7e263          	bltu	a5,a3,80003afe <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a1e:	00043737          	lui	a4,0x43
    80003a22:	0ef76063          	bltu	a4,a5,80003b02 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a26:	0c0b0863          	beqz	s6,80003af6 <writei+0x10e>
    80003a2a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a2c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a30:	5c7d                	li	s8,-1
    80003a32:	a091                	j	80003a76 <writei+0x8e>
    80003a34:	020d1d93          	slli	s11,s10,0x20
    80003a38:	020ddd93          	srli	s11,s11,0x20
    80003a3c:	05848793          	addi	a5,s1,88
    80003a40:	86ee                	mv	a3,s11
    80003a42:	8652                	mv	a2,s4
    80003a44:	85de                	mv	a1,s7
    80003a46:	953e                	add	a0,a0,a5
    80003a48:	fffff097          	auipc	ra,0xfffff
    80003a4c:	a7a080e7          	jalr	-1414(ra) # 800024c2 <either_copyin>
    80003a50:	07850263          	beq	a0,s8,80003ab4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a54:	8526                	mv	a0,s1
    80003a56:	00000097          	auipc	ra,0x0
    80003a5a:	780080e7          	jalr	1920(ra) # 800041d6 <log_write>
    brelse(bp);
    80003a5e:	8526                	mv	a0,s1
    80003a60:	fffff097          	auipc	ra,0xfffff
    80003a64:	4f2080e7          	jalr	1266(ra) # 80002f52 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a68:	013d09bb          	addw	s3,s10,s3
    80003a6c:	012d093b          	addw	s2,s10,s2
    80003a70:	9a6e                	add	s4,s4,s11
    80003a72:	0569f663          	bgeu	s3,s6,80003abe <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003a76:	00a9559b          	srliw	a1,s2,0xa
    80003a7a:	8556                	mv	a0,s5
    80003a7c:	fffff097          	auipc	ra,0xfffff
    80003a80:	7a0080e7          	jalr	1952(ra) # 8000321c <bmap>
    80003a84:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a88:	c99d                	beqz	a1,80003abe <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003a8a:	000aa503          	lw	a0,0(s5)
    80003a8e:	fffff097          	auipc	ra,0xfffff
    80003a92:	394080e7          	jalr	916(ra) # 80002e22 <bread>
    80003a96:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a98:	3ff97513          	andi	a0,s2,1023
    80003a9c:	40ac87bb          	subw	a5,s9,a0
    80003aa0:	413b073b          	subw	a4,s6,s3
    80003aa4:	8d3e                	mv	s10,a5
    80003aa6:	2781                	sext.w	a5,a5
    80003aa8:	0007069b          	sext.w	a3,a4
    80003aac:	f8f6f4e3          	bgeu	a3,a5,80003a34 <writei+0x4c>
    80003ab0:	8d3a                	mv	s10,a4
    80003ab2:	b749                	j	80003a34 <writei+0x4c>
      brelse(bp);
    80003ab4:	8526                	mv	a0,s1
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	49c080e7          	jalr	1180(ra) # 80002f52 <brelse>
  }

  if(off > ip->size)
    80003abe:	04caa783          	lw	a5,76(s5)
    80003ac2:	0127f463          	bgeu	a5,s2,80003aca <writei+0xe2>
    ip->size = off;
    80003ac6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003aca:	8556                	mv	a0,s5
    80003acc:	00000097          	auipc	ra,0x0
    80003ad0:	aa6080e7          	jalr	-1370(ra) # 80003572 <iupdate>

  return tot;
    80003ad4:	0009851b          	sext.w	a0,s3
}
    80003ad8:	70a6                	ld	ra,104(sp)
    80003ada:	7406                	ld	s0,96(sp)
    80003adc:	64e6                	ld	s1,88(sp)
    80003ade:	6946                	ld	s2,80(sp)
    80003ae0:	69a6                	ld	s3,72(sp)
    80003ae2:	6a06                	ld	s4,64(sp)
    80003ae4:	7ae2                	ld	s5,56(sp)
    80003ae6:	7b42                	ld	s6,48(sp)
    80003ae8:	7ba2                	ld	s7,40(sp)
    80003aea:	7c02                	ld	s8,32(sp)
    80003aec:	6ce2                	ld	s9,24(sp)
    80003aee:	6d42                	ld	s10,16(sp)
    80003af0:	6da2                	ld	s11,8(sp)
    80003af2:	6165                	addi	sp,sp,112
    80003af4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003af6:	89da                	mv	s3,s6
    80003af8:	bfc9                	j	80003aca <writei+0xe2>
    return -1;
    80003afa:	557d                	li	a0,-1
}
    80003afc:	8082                	ret
    return -1;
    80003afe:	557d                	li	a0,-1
    80003b00:	bfe1                	j	80003ad8 <writei+0xf0>
    return -1;
    80003b02:	557d                	li	a0,-1
    80003b04:	bfd1                	j	80003ad8 <writei+0xf0>

0000000080003b06 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b06:	1141                	addi	sp,sp,-16
    80003b08:	e406                	sd	ra,8(sp)
    80003b0a:	e022                	sd	s0,0(sp)
    80003b0c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b0e:	4639                	li	a2,14
    80003b10:	ffffd097          	auipc	ra,0xffffd
    80003b14:	292080e7          	jalr	658(ra) # 80000da2 <strncmp>
}
    80003b18:	60a2                	ld	ra,8(sp)
    80003b1a:	6402                	ld	s0,0(sp)
    80003b1c:	0141                	addi	sp,sp,16
    80003b1e:	8082                	ret

0000000080003b20 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b20:	7139                	addi	sp,sp,-64
    80003b22:	fc06                	sd	ra,56(sp)
    80003b24:	f822                	sd	s0,48(sp)
    80003b26:	f426                	sd	s1,40(sp)
    80003b28:	f04a                	sd	s2,32(sp)
    80003b2a:	ec4e                	sd	s3,24(sp)
    80003b2c:	e852                	sd	s4,16(sp)
    80003b2e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b30:	04451703          	lh	a4,68(a0)
    80003b34:	4785                	li	a5,1
    80003b36:	00f71a63          	bne	a4,a5,80003b4a <dirlookup+0x2a>
    80003b3a:	892a                	mv	s2,a0
    80003b3c:	89ae                	mv	s3,a1
    80003b3e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b40:	457c                	lw	a5,76(a0)
    80003b42:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b44:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b46:	e79d                	bnez	a5,80003b74 <dirlookup+0x54>
    80003b48:	a8a5                	j	80003bc0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b4a:	00005517          	auipc	a0,0x5
    80003b4e:	ace50513          	addi	a0,a0,-1330 # 80008618 <syscalls+0x1a0>
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	9ec080e7          	jalr	-1556(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003b5a:	00005517          	auipc	a0,0x5
    80003b5e:	ad650513          	addi	a0,a0,-1322 # 80008630 <syscalls+0x1b8>
    80003b62:	ffffd097          	auipc	ra,0xffffd
    80003b66:	9dc080e7          	jalr	-1572(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6a:	24c1                	addiw	s1,s1,16
    80003b6c:	04c92783          	lw	a5,76(s2)
    80003b70:	04f4f763          	bgeu	s1,a5,80003bbe <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b74:	4741                	li	a4,16
    80003b76:	86a6                	mv	a3,s1
    80003b78:	fc040613          	addi	a2,s0,-64
    80003b7c:	4581                	li	a1,0
    80003b7e:	854a                	mv	a0,s2
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	d70080e7          	jalr	-656(ra) # 800038f0 <readi>
    80003b88:	47c1                	li	a5,16
    80003b8a:	fcf518e3          	bne	a0,a5,80003b5a <dirlookup+0x3a>
    if(de.inum == 0)
    80003b8e:	fc045783          	lhu	a5,-64(s0)
    80003b92:	dfe1                	beqz	a5,80003b6a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b94:	fc240593          	addi	a1,s0,-62
    80003b98:	854e                	mv	a0,s3
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	f6c080e7          	jalr	-148(ra) # 80003b06 <namecmp>
    80003ba2:	f561                	bnez	a0,80003b6a <dirlookup+0x4a>
      if(poff)
    80003ba4:	000a0463          	beqz	s4,80003bac <dirlookup+0x8c>
        *poff = off;
    80003ba8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bac:	fc045583          	lhu	a1,-64(s0)
    80003bb0:	00092503          	lw	a0,0(s2)
    80003bb4:	fffff097          	auipc	ra,0xfffff
    80003bb8:	750080e7          	jalr	1872(ra) # 80003304 <iget>
    80003bbc:	a011                	j	80003bc0 <dirlookup+0xa0>
  return 0;
    80003bbe:	4501                	li	a0,0
}
    80003bc0:	70e2                	ld	ra,56(sp)
    80003bc2:	7442                	ld	s0,48(sp)
    80003bc4:	74a2                	ld	s1,40(sp)
    80003bc6:	7902                	ld	s2,32(sp)
    80003bc8:	69e2                	ld	s3,24(sp)
    80003bca:	6a42                	ld	s4,16(sp)
    80003bcc:	6121                	addi	sp,sp,64
    80003bce:	8082                	ret

0000000080003bd0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bd0:	711d                	addi	sp,sp,-96
    80003bd2:	ec86                	sd	ra,88(sp)
    80003bd4:	e8a2                	sd	s0,80(sp)
    80003bd6:	e4a6                	sd	s1,72(sp)
    80003bd8:	e0ca                	sd	s2,64(sp)
    80003bda:	fc4e                	sd	s3,56(sp)
    80003bdc:	f852                	sd	s4,48(sp)
    80003bde:	f456                	sd	s5,40(sp)
    80003be0:	f05a                	sd	s6,32(sp)
    80003be2:	ec5e                	sd	s7,24(sp)
    80003be4:	e862                	sd	s8,16(sp)
    80003be6:	e466                	sd	s9,8(sp)
    80003be8:	1080                	addi	s0,sp,96
    80003bea:	84aa                	mv	s1,a0
    80003bec:	8aae                	mv	s5,a1
    80003bee:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003bf0:	00054703          	lbu	a4,0(a0)
    80003bf4:	02f00793          	li	a5,47
    80003bf8:	02f70363          	beq	a4,a5,80003c1e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bfc:	ffffe097          	auipc	ra,0xffffe
    80003c00:	dc0080e7          	jalr	-576(ra) # 800019bc <myproc>
    80003c04:	15053503          	ld	a0,336(a0)
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	9f6080e7          	jalr	-1546(ra) # 800035fe <idup>
    80003c10:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c12:	02f00913          	li	s2,47
  len = path - s;
    80003c16:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c18:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c1a:	4b85                	li	s7,1
    80003c1c:	a865                	j	80003cd4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c1e:	4585                	li	a1,1
    80003c20:	4505                	li	a0,1
    80003c22:	fffff097          	auipc	ra,0xfffff
    80003c26:	6e2080e7          	jalr	1762(ra) # 80003304 <iget>
    80003c2a:	89aa                	mv	s3,a0
    80003c2c:	b7dd                	j	80003c12 <namex+0x42>
      iunlockput(ip);
    80003c2e:	854e                	mv	a0,s3
    80003c30:	00000097          	auipc	ra,0x0
    80003c34:	c6e080e7          	jalr	-914(ra) # 8000389e <iunlockput>
      return 0;
    80003c38:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c3a:	854e                	mv	a0,s3
    80003c3c:	60e6                	ld	ra,88(sp)
    80003c3e:	6446                	ld	s0,80(sp)
    80003c40:	64a6                	ld	s1,72(sp)
    80003c42:	6906                	ld	s2,64(sp)
    80003c44:	79e2                	ld	s3,56(sp)
    80003c46:	7a42                	ld	s4,48(sp)
    80003c48:	7aa2                	ld	s5,40(sp)
    80003c4a:	7b02                	ld	s6,32(sp)
    80003c4c:	6be2                	ld	s7,24(sp)
    80003c4e:	6c42                	ld	s8,16(sp)
    80003c50:	6ca2                	ld	s9,8(sp)
    80003c52:	6125                	addi	sp,sp,96
    80003c54:	8082                	ret
      iunlock(ip);
    80003c56:	854e                	mv	a0,s3
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	aa6080e7          	jalr	-1370(ra) # 800036fe <iunlock>
      return ip;
    80003c60:	bfe9                	j	80003c3a <namex+0x6a>
      iunlockput(ip);
    80003c62:	854e                	mv	a0,s3
    80003c64:	00000097          	auipc	ra,0x0
    80003c68:	c3a080e7          	jalr	-966(ra) # 8000389e <iunlockput>
      return 0;
    80003c6c:	89e6                	mv	s3,s9
    80003c6e:	b7f1                	j	80003c3a <namex+0x6a>
  len = path - s;
    80003c70:	40b48633          	sub	a2,s1,a1
    80003c74:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c78:	099c5463          	bge	s8,s9,80003d00 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c7c:	4639                	li	a2,14
    80003c7e:	8552                	mv	a0,s4
    80003c80:	ffffd097          	auipc	ra,0xffffd
    80003c84:	0ae080e7          	jalr	174(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003c88:	0004c783          	lbu	a5,0(s1)
    80003c8c:	01279763          	bne	a5,s2,80003c9a <namex+0xca>
    path++;
    80003c90:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c92:	0004c783          	lbu	a5,0(s1)
    80003c96:	ff278de3          	beq	a5,s2,80003c90 <namex+0xc0>
    ilock(ip);
    80003c9a:	854e                	mv	a0,s3
    80003c9c:	00000097          	auipc	ra,0x0
    80003ca0:	9a0080e7          	jalr	-1632(ra) # 8000363c <ilock>
    if(ip->type != T_DIR){
    80003ca4:	04499783          	lh	a5,68(s3)
    80003ca8:	f97793e3          	bne	a5,s7,80003c2e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003cac:	000a8563          	beqz	s5,80003cb6 <namex+0xe6>
    80003cb0:	0004c783          	lbu	a5,0(s1)
    80003cb4:	d3cd                	beqz	a5,80003c56 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cb6:	865a                	mv	a2,s6
    80003cb8:	85d2                	mv	a1,s4
    80003cba:	854e                	mv	a0,s3
    80003cbc:	00000097          	auipc	ra,0x0
    80003cc0:	e64080e7          	jalr	-412(ra) # 80003b20 <dirlookup>
    80003cc4:	8caa                	mv	s9,a0
    80003cc6:	dd51                	beqz	a0,80003c62 <namex+0x92>
    iunlockput(ip);
    80003cc8:	854e                	mv	a0,s3
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	bd4080e7          	jalr	-1068(ra) # 8000389e <iunlockput>
    ip = next;
    80003cd2:	89e6                	mv	s3,s9
  while(*path == '/')
    80003cd4:	0004c783          	lbu	a5,0(s1)
    80003cd8:	05279763          	bne	a5,s2,80003d26 <namex+0x156>
    path++;
    80003cdc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cde:	0004c783          	lbu	a5,0(s1)
    80003ce2:	ff278de3          	beq	a5,s2,80003cdc <namex+0x10c>
  if(*path == 0)
    80003ce6:	c79d                	beqz	a5,80003d14 <namex+0x144>
    path++;
    80003ce8:	85a6                	mv	a1,s1
  len = path - s;
    80003cea:	8cda                	mv	s9,s6
    80003cec:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003cee:	01278963          	beq	a5,s2,80003d00 <namex+0x130>
    80003cf2:	dfbd                	beqz	a5,80003c70 <namex+0xa0>
    path++;
    80003cf4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003cf6:	0004c783          	lbu	a5,0(s1)
    80003cfa:	ff279ce3          	bne	a5,s2,80003cf2 <namex+0x122>
    80003cfe:	bf8d                	j	80003c70 <namex+0xa0>
    memmove(name, s, len);
    80003d00:	2601                	sext.w	a2,a2
    80003d02:	8552                	mv	a0,s4
    80003d04:	ffffd097          	auipc	ra,0xffffd
    80003d08:	02a080e7          	jalr	42(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003d0c:	9cd2                	add	s9,s9,s4
    80003d0e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d12:	bf9d                	j	80003c88 <namex+0xb8>
  if(nameiparent){
    80003d14:	f20a83e3          	beqz	s5,80003c3a <namex+0x6a>
    iput(ip);
    80003d18:	854e                	mv	a0,s3
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	adc080e7          	jalr	-1316(ra) # 800037f6 <iput>
    return 0;
    80003d22:	4981                	li	s3,0
    80003d24:	bf19                	j	80003c3a <namex+0x6a>
  if(*path == 0)
    80003d26:	d7fd                	beqz	a5,80003d14 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003d28:	0004c783          	lbu	a5,0(s1)
    80003d2c:	85a6                	mv	a1,s1
    80003d2e:	b7d1                	j	80003cf2 <namex+0x122>

0000000080003d30 <dirlink>:
{
    80003d30:	7139                	addi	sp,sp,-64
    80003d32:	fc06                	sd	ra,56(sp)
    80003d34:	f822                	sd	s0,48(sp)
    80003d36:	f426                	sd	s1,40(sp)
    80003d38:	f04a                	sd	s2,32(sp)
    80003d3a:	ec4e                	sd	s3,24(sp)
    80003d3c:	e852                	sd	s4,16(sp)
    80003d3e:	0080                	addi	s0,sp,64
    80003d40:	892a                	mv	s2,a0
    80003d42:	8a2e                	mv	s4,a1
    80003d44:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d46:	4601                	li	a2,0
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	dd8080e7          	jalr	-552(ra) # 80003b20 <dirlookup>
    80003d50:	e93d                	bnez	a0,80003dc6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d52:	04c92483          	lw	s1,76(s2)
    80003d56:	c49d                	beqz	s1,80003d84 <dirlink+0x54>
    80003d58:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d5a:	4741                	li	a4,16
    80003d5c:	86a6                	mv	a3,s1
    80003d5e:	fc040613          	addi	a2,s0,-64
    80003d62:	4581                	li	a1,0
    80003d64:	854a                	mv	a0,s2
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	b8a080e7          	jalr	-1142(ra) # 800038f0 <readi>
    80003d6e:	47c1                	li	a5,16
    80003d70:	06f51163          	bne	a0,a5,80003dd2 <dirlink+0xa2>
    if(de.inum == 0)
    80003d74:	fc045783          	lhu	a5,-64(s0)
    80003d78:	c791                	beqz	a5,80003d84 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d7a:	24c1                	addiw	s1,s1,16
    80003d7c:	04c92783          	lw	a5,76(s2)
    80003d80:	fcf4ede3          	bltu	s1,a5,80003d5a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d84:	4639                	li	a2,14
    80003d86:	85d2                	mv	a1,s4
    80003d88:	fc240513          	addi	a0,s0,-62
    80003d8c:	ffffd097          	auipc	ra,0xffffd
    80003d90:	052080e7          	jalr	82(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003d94:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d98:	4741                	li	a4,16
    80003d9a:	86a6                	mv	a3,s1
    80003d9c:	fc040613          	addi	a2,s0,-64
    80003da0:	4581                	li	a1,0
    80003da2:	854a                	mv	a0,s2
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	c44080e7          	jalr	-956(ra) # 800039e8 <writei>
    80003dac:	1541                	addi	a0,a0,-16
    80003dae:	00a03533          	snez	a0,a0
    80003db2:	40a00533          	neg	a0,a0
}
    80003db6:	70e2                	ld	ra,56(sp)
    80003db8:	7442                	ld	s0,48(sp)
    80003dba:	74a2                	ld	s1,40(sp)
    80003dbc:	7902                	ld	s2,32(sp)
    80003dbe:	69e2                	ld	s3,24(sp)
    80003dc0:	6a42                	ld	s4,16(sp)
    80003dc2:	6121                	addi	sp,sp,64
    80003dc4:	8082                	ret
    iput(ip);
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	a30080e7          	jalr	-1488(ra) # 800037f6 <iput>
    return -1;
    80003dce:	557d                	li	a0,-1
    80003dd0:	b7dd                	j	80003db6 <dirlink+0x86>
      panic("dirlink read");
    80003dd2:	00005517          	auipc	a0,0x5
    80003dd6:	86e50513          	addi	a0,a0,-1938 # 80008640 <syscalls+0x1c8>
    80003dda:	ffffc097          	auipc	ra,0xffffc
    80003dde:	764080e7          	jalr	1892(ra) # 8000053e <panic>

0000000080003de2 <namei>:

struct inode*
namei(char *path)
{
    80003de2:	1101                	addi	sp,sp,-32
    80003de4:	ec06                	sd	ra,24(sp)
    80003de6:	e822                	sd	s0,16(sp)
    80003de8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003dea:	fe040613          	addi	a2,s0,-32
    80003dee:	4581                	li	a1,0
    80003df0:	00000097          	auipc	ra,0x0
    80003df4:	de0080e7          	jalr	-544(ra) # 80003bd0 <namex>
}
    80003df8:	60e2                	ld	ra,24(sp)
    80003dfa:	6442                	ld	s0,16(sp)
    80003dfc:	6105                	addi	sp,sp,32
    80003dfe:	8082                	ret

0000000080003e00 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e00:	1141                	addi	sp,sp,-16
    80003e02:	e406                	sd	ra,8(sp)
    80003e04:	e022                	sd	s0,0(sp)
    80003e06:	0800                	addi	s0,sp,16
    80003e08:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e0a:	4585                	li	a1,1
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	dc4080e7          	jalr	-572(ra) # 80003bd0 <namex>
}
    80003e14:	60a2                	ld	ra,8(sp)
    80003e16:	6402                	ld	s0,0(sp)
    80003e18:	0141                	addi	sp,sp,16
    80003e1a:	8082                	ret

0000000080003e1c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e1c:	1101                	addi	sp,sp,-32
    80003e1e:	ec06                	sd	ra,24(sp)
    80003e20:	e822                	sd	s0,16(sp)
    80003e22:	e426                	sd	s1,8(sp)
    80003e24:	e04a                	sd	s2,0(sp)
    80003e26:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e28:	0001d917          	auipc	s2,0x1d
    80003e2c:	d0890913          	addi	s2,s2,-760 # 80020b30 <log>
    80003e30:	01892583          	lw	a1,24(s2)
    80003e34:	02892503          	lw	a0,40(s2)
    80003e38:	fffff097          	auipc	ra,0xfffff
    80003e3c:	fea080e7          	jalr	-22(ra) # 80002e22 <bread>
    80003e40:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e42:	02c92683          	lw	a3,44(s2)
    80003e46:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e48:	02d05763          	blez	a3,80003e76 <write_head+0x5a>
    80003e4c:	0001d797          	auipc	a5,0x1d
    80003e50:	d1478793          	addi	a5,a5,-748 # 80020b60 <log+0x30>
    80003e54:	05c50713          	addi	a4,a0,92
    80003e58:	36fd                	addiw	a3,a3,-1
    80003e5a:	1682                	slli	a3,a3,0x20
    80003e5c:	9281                	srli	a3,a3,0x20
    80003e5e:	068a                	slli	a3,a3,0x2
    80003e60:	0001d617          	auipc	a2,0x1d
    80003e64:	d0460613          	addi	a2,a2,-764 # 80020b64 <log+0x34>
    80003e68:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e6a:	4390                	lw	a2,0(a5)
    80003e6c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e6e:	0791                	addi	a5,a5,4
    80003e70:	0711                	addi	a4,a4,4
    80003e72:	fed79ce3          	bne	a5,a3,80003e6a <write_head+0x4e>
  }
  bwrite(buf);
    80003e76:	8526                	mv	a0,s1
    80003e78:	fffff097          	auipc	ra,0xfffff
    80003e7c:	09c080e7          	jalr	156(ra) # 80002f14 <bwrite>
  brelse(buf);
    80003e80:	8526                	mv	a0,s1
    80003e82:	fffff097          	auipc	ra,0xfffff
    80003e86:	0d0080e7          	jalr	208(ra) # 80002f52 <brelse>
}
    80003e8a:	60e2                	ld	ra,24(sp)
    80003e8c:	6442                	ld	s0,16(sp)
    80003e8e:	64a2                	ld	s1,8(sp)
    80003e90:	6902                	ld	s2,0(sp)
    80003e92:	6105                	addi	sp,sp,32
    80003e94:	8082                	ret

0000000080003e96 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e96:	0001d797          	auipc	a5,0x1d
    80003e9a:	cc67a783          	lw	a5,-826(a5) # 80020b5c <log+0x2c>
    80003e9e:	0af05d63          	blez	a5,80003f58 <install_trans+0xc2>
{
    80003ea2:	7139                	addi	sp,sp,-64
    80003ea4:	fc06                	sd	ra,56(sp)
    80003ea6:	f822                	sd	s0,48(sp)
    80003ea8:	f426                	sd	s1,40(sp)
    80003eaa:	f04a                	sd	s2,32(sp)
    80003eac:	ec4e                	sd	s3,24(sp)
    80003eae:	e852                	sd	s4,16(sp)
    80003eb0:	e456                	sd	s5,8(sp)
    80003eb2:	e05a                	sd	s6,0(sp)
    80003eb4:	0080                	addi	s0,sp,64
    80003eb6:	8b2a                	mv	s6,a0
    80003eb8:	0001da97          	auipc	s5,0x1d
    80003ebc:	ca8a8a93          	addi	s5,s5,-856 # 80020b60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ec0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ec2:	0001d997          	auipc	s3,0x1d
    80003ec6:	c6e98993          	addi	s3,s3,-914 # 80020b30 <log>
    80003eca:	a00d                	j	80003eec <install_trans+0x56>
    brelse(lbuf);
    80003ecc:	854a                	mv	a0,s2
    80003ece:	fffff097          	auipc	ra,0xfffff
    80003ed2:	084080e7          	jalr	132(ra) # 80002f52 <brelse>
    brelse(dbuf);
    80003ed6:	8526                	mv	a0,s1
    80003ed8:	fffff097          	auipc	ra,0xfffff
    80003edc:	07a080e7          	jalr	122(ra) # 80002f52 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ee0:	2a05                	addiw	s4,s4,1
    80003ee2:	0a91                	addi	s5,s5,4
    80003ee4:	02c9a783          	lw	a5,44(s3)
    80003ee8:	04fa5e63          	bge	s4,a5,80003f44 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003eec:	0189a583          	lw	a1,24(s3)
    80003ef0:	014585bb          	addw	a1,a1,s4
    80003ef4:	2585                	addiw	a1,a1,1
    80003ef6:	0289a503          	lw	a0,40(s3)
    80003efa:	fffff097          	auipc	ra,0xfffff
    80003efe:	f28080e7          	jalr	-216(ra) # 80002e22 <bread>
    80003f02:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f04:	000aa583          	lw	a1,0(s5)
    80003f08:	0289a503          	lw	a0,40(s3)
    80003f0c:	fffff097          	auipc	ra,0xfffff
    80003f10:	f16080e7          	jalr	-234(ra) # 80002e22 <bread>
    80003f14:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f16:	40000613          	li	a2,1024
    80003f1a:	05890593          	addi	a1,s2,88
    80003f1e:	05850513          	addi	a0,a0,88
    80003f22:	ffffd097          	auipc	ra,0xffffd
    80003f26:	e0c080e7          	jalr	-500(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	fffff097          	auipc	ra,0xfffff
    80003f30:	fe8080e7          	jalr	-24(ra) # 80002f14 <bwrite>
    if(recovering == 0)
    80003f34:	f80b1ce3          	bnez	s6,80003ecc <install_trans+0x36>
      bunpin(dbuf);
    80003f38:	8526                	mv	a0,s1
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	0f2080e7          	jalr	242(ra) # 8000302c <bunpin>
    80003f42:	b769                	j	80003ecc <install_trans+0x36>
}
    80003f44:	70e2                	ld	ra,56(sp)
    80003f46:	7442                	ld	s0,48(sp)
    80003f48:	74a2                	ld	s1,40(sp)
    80003f4a:	7902                	ld	s2,32(sp)
    80003f4c:	69e2                	ld	s3,24(sp)
    80003f4e:	6a42                	ld	s4,16(sp)
    80003f50:	6aa2                	ld	s5,8(sp)
    80003f52:	6b02                	ld	s6,0(sp)
    80003f54:	6121                	addi	sp,sp,64
    80003f56:	8082                	ret
    80003f58:	8082                	ret

0000000080003f5a <initlog>:
{
    80003f5a:	7179                	addi	sp,sp,-48
    80003f5c:	f406                	sd	ra,40(sp)
    80003f5e:	f022                	sd	s0,32(sp)
    80003f60:	ec26                	sd	s1,24(sp)
    80003f62:	e84a                	sd	s2,16(sp)
    80003f64:	e44e                	sd	s3,8(sp)
    80003f66:	1800                	addi	s0,sp,48
    80003f68:	892a                	mv	s2,a0
    80003f6a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f6c:	0001d497          	auipc	s1,0x1d
    80003f70:	bc448493          	addi	s1,s1,-1084 # 80020b30 <log>
    80003f74:	00004597          	auipc	a1,0x4
    80003f78:	6dc58593          	addi	a1,a1,1756 # 80008650 <syscalls+0x1d8>
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	ffffd097          	auipc	ra,0xffffd
    80003f82:	bc8080e7          	jalr	-1080(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003f86:	0149a583          	lw	a1,20(s3)
    80003f8a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f8c:	0109a783          	lw	a5,16(s3)
    80003f90:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f92:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f96:	854a                	mv	a0,s2
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	e8a080e7          	jalr	-374(ra) # 80002e22 <bread>
  log.lh.n = lh->n;
    80003fa0:	4d34                	lw	a3,88(a0)
    80003fa2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fa4:	02d05563          	blez	a3,80003fce <initlog+0x74>
    80003fa8:	05c50793          	addi	a5,a0,92
    80003fac:	0001d717          	auipc	a4,0x1d
    80003fb0:	bb470713          	addi	a4,a4,-1100 # 80020b60 <log+0x30>
    80003fb4:	36fd                	addiw	a3,a3,-1
    80003fb6:	1682                	slli	a3,a3,0x20
    80003fb8:	9281                	srli	a3,a3,0x20
    80003fba:	068a                	slli	a3,a3,0x2
    80003fbc:	06050613          	addi	a2,a0,96
    80003fc0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003fc2:	4390                	lw	a2,0(a5)
    80003fc4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fc6:	0791                	addi	a5,a5,4
    80003fc8:	0711                	addi	a4,a4,4
    80003fca:	fed79ce3          	bne	a5,a3,80003fc2 <initlog+0x68>
  brelse(buf);
    80003fce:	fffff097          	auipc	ra,0xfffff
    80003fd2:	f84080e7          	jalr	-124(ra) # 80002f52 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fd6:	4505                	li	a0,1
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	ebe080e7          	jalr	-322(ra) # 80003e96 <install_trans>
  log.lh.n = 0;
    80003fe0:	0001d797          	auipc	a5,0x1d
    80003fe4:	b607ae23          	sw	zero,-1156(a5) # 80020b5c <log+0x2c>
  write_head(); // clear the log
    80003fe8:	00000097          	auipc	ra,0x0
    80003fec:	e34080e7          	jalr	-460(ra) # 80003e1c <write_head>
}
    80003ff0:	70a2                	ld	ra,40(sp)
    80003ff2:	7402                	ld	s0,32(sp)
    80003ff4:	64e2                	ld	s1,24(sp)
    80003ff6:	6942                	ld	s2,16(sp)
    80003ff8:	69a2                	ld	s3,8(sp)
    80003ffa:	6145                	addi	sp,sp,48
    80003ffc:	8082                	ret

0000000080003ffe <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ffe:	1101                	addi	sp,sp,-32
    80004000:	ec06                	sd	ra,24(sp)
    80004002:	e822                	sd	s0,16(sp)
    80004004:	e426                	sd	s1,8(sp)
    80004006:	e04a                	sd	s2,0(sp)
    80004008:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000400a:	0001d517          	auipc	a0,0x1d
    8000400e:	b2650513          	addi	a0,a0,-1242 # 80020b30 <log>
    80004012:	ffffd097          	auipc	ra,0xffffd
    80004016:	bc4080e7          	jalr	-1084(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000401a:	0001d497          	auipc	s1,0x1d
    8000401e:	b1648493          	addi	s1,s1,-1258 # 80020b30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004022:	4979                	li	s2,30
    80004024:	a039                	j	80004032 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004026:	85a6                	mv	a1,s1
    80004028:	8526                	mv	a0,s1
    8000402a:	ffffe097          	auipc	ra,0xffffe
    8000402e:	03a080e7          	jalr	58(ra) # 80002064 <sleep>
    if(log.committing){
    80004032:	50dc                	lw	a5,36(s1)
    80004034:	fbed                	bnez	a5,80004026 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004036:	509c                	lw	a5,32(s1)
    80004038:	0017871b          	addiw	a4,a5,1
    8000403c:	0007069b          	sext.w	a3,a4
    80004040:	0027179b          	slliw	a5,a4,0x2
    80004044:	9fb9                	addw	a5,a5,a4
    80004046:	0017979b          	slliw	a5,a5,0x1
    8000404a:	54d8                	lw	a4,44(s1)
    8000404c:	9fb9                	addw	a5,a5,a4
    8000404e:	00f95963          	bge	s2,a5,80004060 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004052:	85a6                	mv	a1,s1
    80004054:	8526                	mv	a0,s1
    80004056:	ffffe097          	auipc	ra,0xffffe
    8000405a:	00e080e7          	jalr	14(ra) # 80002064 <sleep>
    8000405e:	bfd1                	j	80004032 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004060:	0001d517          	auipc	a0,0x1d
    80004064:	ad050513          	addi	a0,a0,-1328 # 80020b30 <log>
    80004068:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000406a:	ffffd097          	auipc	ra,0xffffd
    8000406e:	c20080e7          	jalr	-992(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004072:	60e2                	ld	ra,24(sp)
    80004074:	6442                	ld	s0,16(sp)
    80004076:	64a2                	ld	s1,8(sp)
    80004078:	6902                	ld	s2,0(sp)
    8000407a:	6105                	addi	sp,sp,32
    8000407c:	8082                	ret

000000008000407e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000407e:	7139                	addi	sp,sp,-64
    80004080:	fc06                	sd	ra,56(sp)
    80004082:	f822                	sd	s0,48(sp)
    80004084:	f426                	sd	s1,40(sp)
    80004086:	f04a                	sd	s2,32(sp)
    80004088:	ec4e                	sd	s3,24(sp)
    8000408a:	e852                	sd	s4,16(sp)
    8000408c:	e456                	sd	s5,8(sp)
    8000408e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004090:	0001d497          	auipc	s1,0x1d
    80004094:	aa048493          	addi	s1,s1,-1376 # 80020b30 <log>
    80004098:	8526                	mv	a0,s1
    8000409a:	ffffd097          	auipc	ra,0xffffd
    8000409e:	b3c080e7          	jalr	-1220(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800040a2:	509c                	lw	a5,32(s1)
    800040a4:	37fd                	addiw	a5,a5,-1
    800040a6:	0007891b          	sext.w	s2,a5
    800040aa:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040ac:	50dc                	lw	a5,36(s1)
    800040ae:	e7b9                	bnez	a5,800040fc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040b0:	04091e63          	bnez	s2,8000410c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040b4:	0001d497          	auipc	s1,0x1d
    800040b8:	a7c48493          	addi	s1,s1,-1412 # 80020b30 <log>
    800040bc:	4785                	li	a5,1
    800040be:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040c0:	8526                	mv	a0,s1
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	bc8080e7          	jalr	-1080(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040ca:	54dc                	lw	a5,44(s1)
    800040cc:	06f04763          	bgtz	a5,8000413a <end_op+0xbc>
    acquire(&log.lock);
    800040d0:	0001d497          	auipc	s1,0x1d
    800040d4:	a6048493          	addi	s1,s1,-1440 # 80020b30 <log>
    800040d8:	8526                	mv	a0,s1
    800040da:	ffffd097          	auipc	ra,0xffffd
    800040de:	afc080e7          	jalr	-1284(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800040e2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800040e6:	8526                	mv	a0,s1
    800040e8:	ffffe097          	auipc	ra,0xffffe
    800040ec:	fe0080e7          	jalr	-32(ra) # 800020c8 <wakeup>
    release(&log.lock);
    800040f0:	8526                	mv	a0,s1
    800040f2:	ffffd097          	auipc	ra,0xffffd
    800040f6:	b98080e7          	jalr	-1128(ra) # 80000c8a <release>
}
    800040fa:	a03d                	j	80004128 <end_op+0xaa>
    panic("log.committing");
    800040fc:	00004517          	auipc	a0,0x4
    80004100:	55c50513          	addi	a0,a0,1372 # 80008658 <syscalls+0x1e0>
    80004104:	ffffc097          	auipc	ra,0xffffc
    80004108:	43a080e7          	jalr	1082(ra) # 8000053e <panic>
    wakeup(&log);
    8000410c:	0001d497          	auipc	s1,0x1d
    80004110:	a2448493          	addi	s1,s1,-1500 # 80020b30 <log>
    80004114:	8526                	mv	a0,s1
    80004116:	ffffe097          	auipc	ra,0xffffe
    8000411a:	fb2080e7          	jalr	-78(ra) # 800020c8 <wakeup>
  release(&log.lock);
    8000411e:	8526                	mv	a0,s1
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	b6a080e7          	jalr	-1174(ra) # 80000c8a <release>
}
    80004128:	70e2                	ld	ra,56(sp)
    8000412a:	7442                	ld	s0,48(sp)
    8000412c:	74a2                	ld	s1,40(sp)
    8000412e:	7902                	ld	s2,32(sp)
    80004130:	69e2                	ld	s3,24(sp)
    80004132:	6a42                	ld	s4,16(sp)
    80004134:	6aa2                	ld	s5,8(sp)
    80004136:	6121                	addi	sp,sp,64
    80004138:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000413a:	0001da97          	auipc	s5,0x1d
    8000413e:	a26a8a93          	addi	s5,s5,-1498 # 80020b60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004142:	0001da17          	auipc	s4,0x1d
    80004146:	9eea0a13          	addi	s4,s4,-1554 # 80020b30 <log>
    8000414a:	018a2583          	lw	a1,24(s4)
    8000414e:	012585bb          	addw	a1,a1,s2
    80004152:	2585                	addiw	a1,a1,1
    80004154:	028a2503          	lw	a0,40(s4)
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	cca080e7          	jalr	-822(ra) # 80002e22 <bread>
    80004160:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004162:	000aa583          	lw	a1,0(s5)
    80004166:	028a2503          	lw	a0,40(s4)
    8000416a:	fffff097          	auipc	ra,0xfffff
    8000416e:	cb8080e7          	jalr	-840(ra) # 80002e22 <bread>
    80004172:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004174:	40000613          	li	a2,1024
    80004178:	05850593          	addi	a1,a0,88
    8000417c:	05848513          	addi	a0,s1,88
    80004180:	ffffd097          	auipc	ra,0xffffd
    80004184:	bae080e7          	jalr	-1106(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004188:	8526                	mv	a0,s1
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	d8a080e7          	jalr	-630(ra) # 80002f14 <bwrite>
    brelse(from);
    80004192:	854e                	mv	a0,s3
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	dbe080e7          	jalr	-578(ra) # 80002f52 <brelse>
    brelse(to);
    8000419c:	8526                	mv	a0,s1
    8000419e:	fffff097          	auipc	ra,0xfffff
    800041a2:	db4080e7          	jalr	-588(ra) # 80002f52 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a6:	2905                	addiw	s2,s2,1
    800041a8:	0a91                	addi	s5,s5,4
    800041aa:	02ca2783          	lw	a5,44(s4)
    800041ae:	f8f94ee3          	blt	s2,a5,8000414a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041b2:	00000097          	auipc	ra,0x0
    800041b6:	c6a080e7          	jalr	-918(ra) # 80003e1c <write_head>
    install_trans(0); // Now install writes to home locations
    800041ba:	4501                	li	a0,0
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	cda080e7          	jalr	-806(ra) # 80003e96 <install_trans>
    log.lh.n = 0;
    800041c4:	0001d797          	auipc	a5,0x1d
    800041c8:	9807ac23          	sw	zero,-1640(a5) # 80020b5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	c50080e7          	jalr	-944(ra) # 80003e1c <write_head>
    800041d4:	bdf5                	j	800040d0 <end_op+0x52>

00000000800041d6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041d6:	1101                	addi	sp,sp,-32
    800041d8:	ec06                	sd	ra,24(sp)
    800041da:	e822                	sd	s0,16(sp)
    800041dc:	e426                	sd	s1,8(sp)
    800041de:	e04a                	sd	s2,0(sp)
    800041e0:	1000                	addi	s0,sp,32
    800041e2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041e4:	0001d917          	auipc	s2,0x1d
    800041e8:	94c90913          	addi	s2,s2,-1716 # 80020b30 <log>
    800041ec:	854a                	mv	a0,s2
    800041ee:	ffffd097          	auipc	ra,0xffffd
    800041f2:	9e8080e7          	jalr	-1560(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800041f6:	02c92603          	lw	a2,44(s2)
    800041fa:	47f5                	li	a5,29
    800041fc:	06c7c563          	blt	a5,a2,80004266 <log_write+0x90>
    80004200:	0001d797          	auipc	a5,0x1d
    80004204:	94c7a783          	lw	a5,-1716(a5) # 80020b4c <log+0x1c>
    80004208:	37fd                	addiw	a5,a5,-1
    8000420a:	04f65e63          	bge	a2,a5,80004266 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000420e:	0001d797          	auipc	a5,0x1d
    80004212:	9427a783          	lw	a5,-1726(a5) # 80020b50 <log+0x20>
    80004216:	06f05063          	blez	a5,80004276 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000421a:	4781                	li	a5,0
    8000421c:	06c05563          	blez	a2,80004286 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004220:	44cc                	lw	a1,12(s1)
    80004222:	0001d717          	auipc	a4,0x1d
    80004226:	93e70713          	addi	a4,a4,-1730 # 80020b60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000422a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000422c:	4314                	lw	a3,0(a4)
    8000422e:	04b68c63          	beq	a3,a1,80004286 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004232:	2785                	addiw	a5,a5,1
    80004234:	0711                	addi	a4,a4,4
    80004236:	fef61be3          	bne	a2,a5,8000422c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000423a:	0621                	addi	a2,a2,8
    8000423c:	060a                	slli	a2,a2,0x2
    8000423e:	0001d797          	auipc	a5,0x1d
    80004242:	8f278793          	addi	a5,a5,-1806 # 80020b30 <log>
    80004246:	963e                	add	a2,a2,a5
    80004248:	44dc                	lw	a5,12(s1)
    8000424a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000424c:	8526                	mv	a0,s1
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	da2080e7          	jalr	-606(ra) # 80002ff0 <bpin>
    log.lh.n++;
    80004256:	0001d717          	auipc	a4,0x1d
    8000425a:	8da70713          	addi	a4,a4,-1830 # 80020b30 <log>
    8000425e:	575c                	lw	a5,44(a4)
    80004260:	2785                	addiw	a5,a5,1
    80004262:	d75c                	sw	a5,44(a4)
    80004264:	a835                	j	800042a0 <log_write+0xca>
    panic("too big a transaction");
    80004266:	00004517          	auipc	a0,0x4
    8000426a:	40250513          	addi	a0,a0,1026 # 80008668 <syscalls+0x1f0>
    8000426e:	ffffc097          	auipc	ra,0xffffc
    80004272:	2d0080e7          	jalr	720(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004276:	00004517          	auipc	a0,0x4
    8000427a:	40a50513          	addi	a0,a0,1034 # 80008680 <syscalls+0x208>
    8000427e:	ffffc097          	auipc	ra,0xffffc
    80004282:	2c0080e7          	jalr	704(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004286:	00878713          	addi	a4,a5,8
    8000428a:	00271693          	slli	a3,a4,0x2
    8000428e:	0001d717          	auipc	a4,0x1d
    80004292:	8a270713          	addi	a4,a4,-1886 # 80020b30 <log>
    80004296:	9736                	add	a4,a4,a3
    80004298:	44d4                	lw	a3,12(s1)
    8000429a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000429c:	faf608e3          	beq	a2,a5,8000424c <log_write+0x76>
  }
  release(&log.lock);
    800042a0:	0001d517          	auipc	a0,0x1d
    800042a4:	89050513          	addi	a0,a0,-1904 # 80020b30 <log>
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	9e2080e7          	jalr	-1566(ra) # 80000c8a <release>
}
    800042b0:	60e2                	ld	ra,24(sp)
    800042b2:	6442                	ld	s0,16(sp)
    800042b4:	64a2                	ld	s1,8(sp)
    800042b6:	6902                	ld	s2,0(sp)
    800042b8:	6105                	addi	sp,sp,32
    800042ba:	8082                	ret

00000000800042bc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042bc:	1101                	addi	sp,sp,-32
    800042be:	ec06                	sd	ra,24(sp)
    800042c0:	e822                	sd	s0,16(sp)
    800042c2:	e426                	sd	s1,8(sp)
    800042c4:	e04a                	sd	s2,0(sp)
    800042c6:	1000                	addi	s0,sp,32
    800042c8:	84aa                	mv	s1,a0
    800042ca:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042cc:	00004597          	auipc	a1,0x4
    800042d0:	3d458593          	addi	a1,a1,980 # 800086a0 <syscalls+0x228>
    800042d4:	0521                	addi	a0,a0,8
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	870080e7          	jalr	-1936(ra) # 80000b46 <initlock>
  lk->name = name;
    800042de:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042e2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042e6:	0204a423          	sw	zero,40(s1)
}
    800042ea:	60e2                	ld	ra,24(sp)
    800042ec:	6442                	ld	s0,16(sp)
    800042ee:	64a2                	ld	s1,8(sp)
    800042f0:	6902                	ld	s2,0(sp)
    800042f2:	6105                	addi	sp,sp,32
    800042f4:	8082                	ret

00000000800042f6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042f6:	1101                	addi	sp,sp,-32
    800042f8:	ec06                	sd	ra,24(sp)
    800042fa:	e822                	sd	s0,16(sp)
    800042fc:	e426                	sd	s1,8(sp)
    800042fe:	e04a                	sd	s2,0(sp)
    80004300:	1000                	addi	s0,sp,32
    80004302:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004304:	00850913          	addi	s2,a0,8
    80004308:	854a                	mv	a0,s2
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	8cc080e7          	jalr	-1844(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004312:	409c                	lw	a5,0(s1)
    80004314:	cb89                	beqz	a5,80004326 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004316:	85ca                	mv	a1,s2
    80004318:	8526                	mv	a0,s1
    8000431a:	ffffe097          	auipc	ra,0xffffe
    8000431e:	d4a080e7          	jalr	-694(ra) # 80002064 <sleep>
  while (lk->locked) {
    80004322:	409c                	lw	a5,0(s1)
    80004324:	fbed                	bnez	a5,80004316 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004326:	4785                	li	a5,1
    80004328:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000432a:	ffffd097          	auipc	ra,0xffffd
    8000432e:	692080e7          	jalr	1682(ra) # 800019bc <myproc>
    80004332:	591c                	lw	a5,48(a0)
    80004334:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004336:	854a                	mv	a0,s2
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	952080e7          	jalr	-1710(ra) # 80000c8a <release>
}
    80004340:	60e2                	ld	ra,24(sp)
    80004342:	6442                	ld	s0,16(sp)
    80004344:	64a2                	ld	s1,8(sp)
    80004346:	6902                	ld	s2,0(sp)
    80004348:	6105                	addi	sp,sp,32
    8000434a:	8082                	ret

000000008000434c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000434c:	1101                	addi	sp,sp,-32
    8000434e:	ec06                	sd	ra,24(sp)
    80004350:	e822                	sd	s0,16(sp)
    80004352:	e426                	sd	s1,8(sp)
    80004354:	e04a                	sd	s2,0(sp)
    80004356:	1000                	addi	s0,sp,32
    80004358:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000435a:	00850913          	addi	s2,a0,8
    8000435e:	854a                	mv	a0,s2
    80004360:	ffffd097          	auipc	ra,0xffffd
    80004364:	876080e7          	jalr	-1930(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004368:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000436c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004370:	8526                	mv	a0,s1
    80004372:	ffffe097          	auipc	ra,0xffffe
    80004376:	d56080e7          	jalr	-682(ra) # 800020c8 <wakeup>
  release(&lk->lk);
    8000437a:	854a                	mv	a0,s2
    8000437c:	ffffd097          	auipc	ra,0xffffd
    80004380:	90e080e7          	jalr	-1778(ra) # 80000c8a <release>
}
    80004384:	60e2                	ld	ra,24(sp)
    80004386:	6442                	ld	s0,16(sp)
    80004388:	64a2                	ld	s1,8(sp)
    8000438a:	6902                	ld	s2,0(sp)
    8000438c:	6105                	addi	sp,sp,32
    8000438e:	8082                	ret

0000000080004390 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004390:	7179                	addi	sp,sp,-48
    80004392:	f406                	sd	ra,40(sp)
    80004394:	f022                	sd	s0,32(sp)
    80004396:	ec26                	sd	s1,24(sp)
    80004398:	e84a                	sd	s2,16(sp)
    8000439a:	e44e                	sd	s3,8(sp)
    8000439c:	1800                	addi	s0,sp,48
    8000439e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043a0:	00850913          	addi	s2,a0,8
    800043a4:	854a                	mv	a0,s2
    800043a6:	ffffd097          	auipc	ra,0xffffd
    800043aa:	830080e7          	jalr	-2000(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ae:	409c                	lw	a5,0(s1)
    800043b0:	ef99                	bnez	a5,800043ce <holdingsleep+0x3e>
    800043b2:	4481                	li	s1,0
  release(&lk->lk);
    800043b4:	854a                	mv	a0,s2
    800043b6:	ffffd097          	auipc	ra,0xffffd
    800043ba:	8d4080e7          	jalr	-1836(ra) # 80000c8a <release>
  return r;
}
    800043be:	8526                	mv	a0,s1
    800043c0:	70a2                	ld	ra,40(sp)
    800043c2:	7402                	ld	s0,32(sp)
    800043c4:	64e2                	ld	s1,24(sp)
    800043c6:	6942                	ld	s2,16(sp)
    800043c8:	69a2                	ld	s3,8(sp)
    800043ca:	6145                	addi	sp,sp,48
    800043cc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ce:	0284a983          	lw	s3,40(s1)
    800043d2:	ffffd097          	auipc	ra,0xffffd
    800043d6:	5ea080e7          	jalr	1514(ra) # 800019bc <myproc>
    800043da:	5904                	lw	s1,48(a0)
    800043dc:	413484b3          	sub	s1,s1,s3
    800043e0:	0014b493          	seqz	s1,s1
    800043e4:	bfc1                	j	800043b4 <holdingsleep+0x24>

00000000800043e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043e6:	1141                	addi	sp,sp,-16
    800043e8:	e406                	sd	ra,8(sp)
    800043ea:	e022                	sd	s0,0(sp)
    800043ec:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043ee:	00004597          	auipc	a1,0x4
    800043f2:	2c258593          	addi	a1,a1,706 # 800086b0 <syscalls+0x238>
    800043f6:	0001d517          	auipc	a0,0x1d
    800043fa:	88250513          	addi	a0,a0,-1918 # 80020c78 <ftable>
    800043fe:	ffffc097          	auipc	ra,0xffffc
    80004402:	748080e7          	jalr	1864(ra) # 80000b46 <initlock>
}
    80004406:	60a2                	ld	ra,8(sp)
    80004408:	6402                	ld	s0,0(sp)
    8000440a:	0141                	addi	sp,sp,16
    8000440c:	8082                	ret

000000008000440e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000440e:	1101                	addi	sp,sp,-32
    80004410:	ec06                	sd	ra,24(sp)
    80004412:	e822                	sd	s0,16(sp)
    80004414:	e426                	sd	s1,8(sp)
    80004416:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004418:	0001d517          	auipc	a0,0x1d
    8000441c:	86050513          	addi	a0,a0,-1952 # 80020c78 <ftable>
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	7b6080e7          	jalr	1974(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004428:	0001d497          	auipc	s1,0x1d
    8000442c:	86848493          	addi	s1,s1,-1944 # 80020c90 <ftable+0x18>
    80004430:	0001e717          	auipc	a4,0x1e
    80004434:	80070713          	addi	a4,a4,-2048 # 80021c30 <disk>
    if(f->ref == 0){
    80004438:	40dc                	lw	a5,4(s1)
    8000443a:	cf99                	beqz	a5,80004458 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000443c:	02848493          	addi	s1,s1,40
    80004440:	fee49ce3          	bne	s1,a4,80004438 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004444:	0001d517          	auipc	a0,0x1d
    80004448:	83450513          	addi	a0,a0,-1996 # 80020c78 <ftable>
    8000444c:	ffffd097          	auipc	ra,0xffffd
    80004450:	83e080e7          	jalr	-1986(ra) # 80000c8a <release>
  return 0;
    80004454:	4481                	li	s1,0
    80004456:	a819                	j	8000446c <filealloc+0x5e>
      f->ref = 1;
    80004458:	4785                	li	a5,1
    8000445a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000445c:	0001d517          	auipc	a0,0x1d
    80004460:	81c50513          	addi	a0,a0,-2020 # 80020c78 <ftable>
    80004464:	ffffd097          	auipc	ra,0xffffd
    80004468:	826080e7          	jalr	-2010(ra) # 80000c8a <release>
}
    8000446c:	8526                	mv	a0,s1
    8000446e:	60e2                	ld	ra,24(sp)
    80004470:	6442                	ld	s0,16(sp)
    80004472:	64a2                	ld	s1,8(sp)
    80004474:	6105                	addi	sp,sp,32
    80004476:	8082                	ret

0000000080004478 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004478:	1101                	addi	sp,sp,-32
    8000447a:	ec06                	sd	ra,24(sp)
    8000447c:	e822                	sd	s0,16(sp)
    8000447e:	e426                	sd	s1,8(sp)
    80004480:	1000                	addi	s0,sp,32
    80004482:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004484:	0001c517          	auipc	a0,0x1c
    80004488:	7f450513          	addi	a0,a0,2036 # 80020c78 <ftable>
    8000448c:	ffffc097          	auipc	ra,0xffffc
    80004490:	74a080e7          	jalr	1866(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004494:	40dc                	lw	a5,4(s1)
    80004496:	02f05263          	blez	a5,800044ba <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000449a:	2785                	addiw	a5,a5,1
    8000449c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000449e:	0001c517          	auipc	a0,0x1c
    800044a2:	7da50513          	addi	a0,a0,2010 # 80020c78 <ftable>
    800044a6:	ffffc097          	auipc	ra,0xffffc
    800044aa:	7e4080e7          	jalr	2020(ra) # 80000c8a <release>
  return f;
}
    800044ae:	8526                	mv	a0,s1
    800044b0:	60e2                	ld	ra,24(sp)
    800044b2:	6442                	ld	s0,16(sp)
    800044b4:	64a2                	ld	s1,8(sp)
    800044b6:	6105                	addi	sp,sp,32
    800044b8:	8082                	ret
    panic("filedup");
    800044ba:	00004517          	auipc	a0,0x4
    800044be:	1fe50513          	addi	a0,a0,510 # 800086b8 <syscalls+0x240>
    800044c2:	ffffc097          	auipc	ra,0xffffc
    800044c6:	07c080e7          	jalr	124(ra) # 8000053e <panic>

00000000800044ca <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044ca:	7139                	addi	sp,sp,-64
    800044cc:	fc06                	sd	ra,56(sp)
    800044ce:	f822                	sd	s0,48(sp)
    800044d0:	f426                	sd	s1,40(sp)
    800044d2:	f04a                	sd	s2,32(sp)
    800044d4:	ec4e                	sd	s3,24(sp)
    800044d6:	e852                	sd	s4,16(sp)
    800044d8:	e456                	sd	s5,8(sp)
    800044da:	0080                	addi	s0,sp,64
    800044dc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044de:	0001c517          	auipc	a0,0x1c
    800044e2:	79a50513          	addi	a0,a0,1946 # 80020c78 <ftable>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	6f0080e7          	jalr	1776(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044ee:	40dc                	lw	a5,4(s1)
    800044f0:	06f05163          	blez	a5,80004552 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044f4:	37fd                	addiw	a5,a5,-1
    800044f6:	0007871b          	sext.w	a4,a5
    800044fa:	c0dc                	sw	a5,4(s1)
    800044fc:	06e04363          	bgtz	a4,80004562 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004500:	0004a903          	lw	s2,0(s1)
    80004504:	0094ca83          	lbu	s5,9(s1)
    80004508:	0104ba03          	ld	s4,16(s1)
    8000450c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004510:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004514:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004518:	0001c517          	auipc	a0,0x1c
    8000451c:	76050513          	addi	a0,a0,1888 # 80020c78 <ftable>
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	76a080e7          	jalr	1898(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004528:	4785                	li	a5,1
    8000452a:	04f90d63          	beq	s2,a5,80004584 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000452e:	3979                	addiw	s2,s2,-2
    80004530:	4785                	li	a5,1
    80004532:	0527e063          	bltu	a5,s2,80004572 <fileclose+0xa8>
    begin_op();
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	ac8080e7          	jalr	-1336(ra) # 80003ffe <begin_op>
    iput(ff.ip);
    8000453e:	854e                	mv	a0,s3
    80004540:	fffff097          	auipc	ra,0xfffff
    80004544:	2b6080e7          	jalr	694(ra) # 800037f6 <iput>
    end_op();
    80004548:	00000097          	auipc	ra,0x0
    8000454c:	b36080e7          	jalr	-1226(ra) # 8000407e <end_op>
    80004550:	a00d                	j	80004572 <fileclose+0xa8>
    panic("fileclose");
    80004552:	00004517          	auipc	a0,0x4
    80004556:	16e50513          	addi	a0,a0,366 # 800086c0 <syscalls+0x248>
    8000455a:	ffffc097          	auipc	ra,0xffffc
    8000455e:	fe4080e7          	jalr	-28(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004562:	0001c517          	auipc	a0,0x1c
    80004566:	71650513          	addi	a0,a0,1814 # 80020c78 <ftable>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	720080e7          	jalr	1824(ra) # 80000c8a <release>
  }
}
    80004572:	70e2                	ld	ra,56(sp)
    80004574:	7442                	ld	s0,48(sp)
    80004576:	74a2                	ld	s1,40(sp)
    80004578:	7902                	ld	s2,32(sp)
    8000457a:	69e2                	ld	s3,24(sp)
    8000457c:	6a42                	ld	s4,16(sp)
    8000457e:	6aa2                	ld	s5,8(sp)
    80004580:	6121                	addi	sp,sp,64
    80004582:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004584:	85d6                	mv	a1,s5
    80004586:	8552                	mv	a0,s4
    80004588:	00000097          	auipc	ra,0x0
    8000458c:	34c080e7          	jalr	844(ra) # 800048d4 <pipeclose>
    80004590:	b7cd                	j	80004572 <fileclose+0xa8>

0000000080004592 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004592:	715d                	addi	sp,sp,-80
    80004594:	e486                	sd	ra,72(sp)
    80004596:	e0a2                	sd	s0,64(sp)
    80004598:	fc26                	sd	s1,56(sp)
    8000459a:	f84a                	sd	s2,48(sp)
    8000459c:	f44e                	sd	s3,40(sp)
    8000459e:	0880                	addi	s0,sp,80
    800045a0:	84aa                	mv	s1,a0
    800045a2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045a4:	ffffd097          	auipc	ra,0xffffd
    800045a8:	418080e7          	jalr	1048(ra) # 800019bc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045ac:	409c                	lw	a5,0(s1)
    800045ae:	37f9                	addiw	a5,a5,-2
    800045b0:	4705                	li	a4,1
    800045b2:	04f76763          	bltu	a4,a5,80004600 <filestat+0x6e>
    800045b6:	892a                	mv	s2,a0
    ilock(f->ip);
    800045b8:	6c88                	ld	a0,24(s1)
    800045ba:	fffff097          	auipc	ra,0xfffff
    800045be:	082080e7          	jalr	130(ra) # 8000363c <ilock>
    stati(f->ip, &st);
    800045c2:	fb840593          	addi	a1,s0,-72
    800045c6:	6c88                	ld	a0,24(s1)
    800045c8:	fffff097          	auipc	ra,0xfffff
    800045cc:	2fe080e7          	jalr	766(ra) # 800038c6 <stati>
    iunlock(f->ip);
    800045d0:	6c88                	ld	a0,24(s1)
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	12c080e7          	jalr	300(ra) # 800036fe <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045da:	46e1                	li	a3,24
    800045dc:	fb840613          	addi	a2,s0,-72
    800045e0:	85ce                	mv	a1,s3
    800045e2:	05093503          	ld	a0,80(s2)
    800045e6:	ffffd097          	auipc	ra,0xffffd
    800045ea:	092080e7          	jalr	146(ra) # 80001678 <copyout>
    800045ee:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045f2:	60a6                	ld	ra,72(sp)
    800045f4:	6406                	ld	s0,64(sp)
    800045f6:	74e2                	ld	s1,56(sp)
    800045f8:	7942                	ld	s2,48(sp)
    800045fa:	79a2                	ld	s3,40(sp)
    800045fc:	6161                	addi	sp,sp,80
    800045fe:	8082                	ret
  return -1;
    80004600:	557d                	li	a0,-1
    80004602:	bfc5                	j	800045f2 <filestat+0x60>

0000000080004604 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004604:	7179                	addi	sp,sp,-48
    80004606:	f406                	sd	ra,40(sp)
    80004608:	f022                	sd	s0,32(sp)
    8000460a:	ec26                	sd	s1,24(sp)
    8000460c:	e84a                	sd	s2,16(sp)
    8000460e:	e44e                	sd	s3,8(sp)
    80004610:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004612:	00854783          	lbu	a5,8(a0)
    80004616:	c3d5                	beqz	a5,800046ba <fileread+0xb6>
    80004618:	84aa                	mv	s1,a0
    8000461a:	89ae                	mv	s3,a1
    8000461c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000461e:	411c                	lw	a5,0(a0)
    80004620:	4705                	li	a4,1
    80004622:	04e78963          	beq	a5,a4,80004674 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004626:	470d                	li	a4,3
    80004628:	04e78d63          	beq	a5,a4,80004682 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000462c:	4709                	li	a4,2
    8000462e:	06e79e63          	bne	a5,a4,800046aa <fileread+0xa6>
    ilock(f->ip);
    80004632:	6d08                	ld	a0,24(a0)
    80004634:	fffff097          	auipc	ra,0xfffff
    80004638:	008080e7          	jalr	8(ra) # 8000363c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000463c:	874a                	mv	a4,s2
    8000463e:	5094                	lw	a3,32(s1)
    80004640:	864e                	mv	a2,s3
    80004642:	4585                	li	a1,1
    80004644:	6c88                	ld	a0,24(s1)
    80004646:	fffff097          	auipc	ra,0xfffff
    8000464a:	2aa080e7          	jalr	682(ra) # 800038f0 <readi>
    8000464e:	892a                	mv	s2,a0
    80004650:	00a05563          	blez	a0,8000465a <fileread+0x56>
      f->off += r;
    80004654:	509c                	lw	a5,32(s1)
    80004656:	9fa9                	addw	a5,a5,a0
    80004658:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000465a:	6c88                	ld	a0,24(s1)
    8000465c:	fffff097          	auipc	ra,0xfffff
    80004660:	0a2080e7          	jalr	162(ra) # 800036fe <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004664:	854a                	mv	a0,s2
    80004666:	70a2                	ld	ra,40(sp)
    80004668:	7402                	ld	s0,32(sp)
    8000466a:	64e2                	ld	s1,24(sp)
    8000466c:	6942                	ld	s2,16(sp)
    8000466e:	69a2                	ld	s3,8(sp)
    80004670:	6145                	addi	sp,sp,48
    80004672:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004674:	6908                	ld	a0,16(a0)
    80004676:	00000097          	auipc	ra,0x0
    8000467a:	3c6080e7          	jalr	966(ra) # 80004a3c <piperead>
    8000467e:	892a                	mv	s2,a0
    80004680:	b7d5                	j	80004664 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004682:	02451783          	lh	a5,36(a0)
    80004686:	03079693          	slli	a3,a5,0x30
    8000468a:	92c1                	srli	a3,a3,0x30
    8000468c:	4725                	li	a4,9
    8000468e:	02d76863          	bltu	a4,a3,800046be <fileread+0xba>
    80004692:	0792                	slli	a5,a5,0x4
    80004694:	0001c717          	auipc	a4,0x1c
    80004698:	54470713          	addi	a4,a4,1348 # 80020bd8 <devsw>
    8000469c:	97ba                	add	a5,a5,a4
    8000469e:	639c                	ld	a5,0(a5)
    800046a0:	c38d                	beqz	a5,800046c2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046a2:	4505                	li	a0,1
    800046a4:	9782                	jalr	a5
    800046a6:	892a                	mv	s2,a0
    800046a8:	bf75                	j	80004664 <fileread+0x60>
    panic("fileread");
    800046aa:	00004517          	auipc	a0,0x4
    800046ae:	02650513          	addi	a0,a0,38 # 800086d0 <syscalls+0x258>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	e8c080e7          	jalr	-372(ra) # 8000053e <panic>
    return -1;
    800046ba:	597d                	li	s2,-1
    800046bc:	b765                	j	80004664 <fileread+0x60>
      return -1;
    800046be:	597d                	li	s2,-1
    800046c0:	b755                	j	80004664 <fileread+0x60>
    800046c2:	597d                	li	s2,-1
    800046c4:	b745                	j	80004664 <fileread+0x60>

00000000800046c6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800046c6:	715d                	addi	sp,sp,-80
    800046c8:	e486                	sd	ra,72(sp)
    800046ca:	e0a2                	sd	s0,64(sp)
    800046cc:	fc26                	sd	s1,56(sp)
    800046ce:	f84a                	sd	s2,48(sp)
    800046d0:	f44e                	sd	s3,40(sp)
    800046d2:	f052                	sd	s4,32(sp)
    800046d4:	ec56                	sd	s5,24(sp)
    800046d6:	e85a                	sd	s6,16(sp)
    800046d8:	e45e                	sd	s7,8(sp)
    800046da:	e062                	sd	s8,0(sp)
    800046dc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800046de:	00954783          	lbu	a5,9(a0)
    800046e2:	10078663          	beqz	a5,800047ee <filewrite+0x128>
    800046e6:	892a                	mv	s2,a0
    800046e8:	8aae                	mv	s5,a1
    800046ea:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046ec:	411c                	lw	a5,0(a0)
    800046ee:	4705                	li	a4,1
    800046f0:	02e78263          	beq	a5,a4,80004714 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046f4:	470d                	li	a4,3
    800046f6:	02e78663          	beq	a5,a4,80004722 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046fa:	4709                	li	a4,2
    800046fc:	0ee79163          	bne	a5,a4,800047de <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004700:	0ac05d63          	blez	a2,800047ba <filewrite+0xf4>
    int i = 0;
    80004704:	4981                	li	s3,0
    80004706:	6b05                	lui	s6,0x1
    80004708:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000470c:	6b85                	lui	s7,0x1
    8000470e:	c00b8b9b          	addiw	s7,s7,-1024
    80004712:	a861                	j	800047aa <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004714:	6908                	ld	a0,16(a0)
    80004716:	00000097          	auipc	ra,0x0
    8000471a:	22e080e7          	jalr	558(ra) # 80004944 <pipewrite>
    8000471e:	8a2a                	mv	s4,a0
    80004720:	a045                	j	800047c0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004722:	02451783          	lh	a5,36(a0)
    80004726:	03079693          	slli	a3,a5,0x30
    8000472a:	92c1                	srli	a3,a3,0x30
    8000472c:	4725                	li	a4,9
    8000472e:	0cd76263          	bltu	a4,a3,800047f2 <filewrite+0x12c>
    80004732:	0792                	slli	a5,a5,0x4
    80004734:	0001c717          	auipc	a4,0x1c
    80004738:	4a470713          	addi	a4,a4,1188 # 80020bd8 <devsw>
    8000473c:	97ba                	add	a5,a5,a4
    8000473e:	679c                	ld	a5,8(a5)
    80004740:	cbdd                	beqz	a5,800047f6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004742:	4505                	li	a0,1
    80004744:	9782                	jalr	a5
    80004746:	8a2a                	mv	s4,a0
    80004748:	a8a5                	j	800047c0 <filewrite+0xfa>
    8000474a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	8b0080e7          	jalr	-1872(ra) # 80003ffe <begin_op>
      ilock(f->ip);
    80004756:	01893503          	ld	a0,24(s2)
    8000475a:	fffff097          	auipc	ra,0xfffff
    8000475e:	ee2080e7          	jalr	-286(ra) # 8000363c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004762:	8762                	mv	a4,s8
    80004764:	02092683          	lw	a3,32(s2)
    80004768:	01598633          	add	a2,s3,s5
    8000476c:	4585                	li	a1,1
    8000476e:	01893503          	ld	a0,24(s2)
    80004772:	fffff097          	auipc	ra,0xfffff
    80004776:	276080e7          	jalr	630(ra) # 800039e8 <writei>
    8000477a:	84aa                	mv	s1,a0
    8000477c:	00a05763          	blez	a0,8000478a <filewrite+0xc4>
        f->off += r;
    80004780:	02092783          	lw	a5,32(s2)
    80004784:	9fa9                	addw	a5,a5,a0
    80004786:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000478a:	01893503          	ld	a0,24(s2)
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	f70080e7          	jalr	-144(ra) # 800036fe <iunlock>
      end_op();
    80004796:	00000097          	auipc	ra,0x0
    8000479a:	8e8080e7          	jalr	-1816(ra) # 8000407e <end_op>

      if(r != n1){
    8000479e:	009c1f63          	bne	s8,s1,800047bc <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800047a2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800047a6:	0149db63          	bge	s3,s4,800047bc <filewrite+0xf6>
      int n1 = n - i;
    800047aa:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800047ae:	84be                	mv	s1,a5
    800047b0:	2781                	sext.w	a5,a5
    800047b2:	f8fb5ce3          	bge	s6,a5,8000474a <filewrite+0x84>
    800047b6:	84de                	mv	s1,s7
    800047b8:	bf49                	j	8000474a <filewrite+0x84>
    int i = 0;
    800047ba:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800047bc:	013a1f63          	bne	s4,s3,800047da <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047c0:	8552                	mv	a0,s4
    800047c2:	60a6                	ld	ra,72(sp)
    800047c4:	6406                	ld	s0,64(sp)
    800047c6:	74e2                	ld	s1,56(sp)
    800047c8:	7942                	ld	s2,48(sp)
    800047ca:	79a2                	ld	s3,40(sp)
    800047cc:	7a02                	ld	s4,32(sp)
    800047ce:	6ae2                	ld	s5,24(sp)
    800047d0:	6b42                	ld	s6,16(sp)
    800047d2:	6ba2                	ld	s7,8(sp)
    800047d4:	6c02                	ld	s8,0(sp)
    800047d6:	6161                	addi	sp,sp,80
    800047d8:	8082                	ret
    ret = (i == n ? n : -1);
    800047da:	5a7d                	li	s4,-1
    800047dc:	b7d5                	j	800047c0 <filewrite+0xfa>
    panic("filewrite");
    800047de:	00004517          	auipc	a0,0x4
    800047e2:	f0250513          	addi	a0,a0,-254 # 800086e0 <syscalls+0x268>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	d58080e7          	jalr	-680(ra) # 8000053e <panic>
    return -1;
    800047ee:	5a7d                	li	s4,-1
    800047f0:	bfc1                	j	800047c0 <filewrite+0xfa>
      return -1;
    800047f2:	5a7d                	li	s4,-1
    800047f4:	b7f1                	j	800047c0 <filewrite+0xfa>
    800047f6:	5a7d                	li	s4,-1
    800047f8:	b7e1                	j	800047c0 <filewrite+0xfa>

00000000800047fa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047fa:	7179                	addi	sp,sp,-48
    800047fc:	f406                	sd	ra,40(sp)
    800047fe:	f022                	sd	s0,32(sp)
    80004800:	ec26                	sd	s1,24(sp)
    80004802:	e84a                	sd	s2,16(sp)
    80004804:	e44e                	sd	s3,8(sp)
    80004806:	e052                	sd	s4,0(sp)
    80004808:	1800                	addi	s0,sp,48
    8000480a:	84aa                	mv	s1,a0
    8000480c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000480e:	0005b023          	sd	zero,0(a1)
    80004812:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	bf8080e7          	jalr	-1032(ra) # 8000440e <filealloc>
    8000481e:	e088                	sd	a0,0(s1)
    80004820:	c551                	beqz	a0,800048ac <pipealloc+0xb2>
    80004822:	00000097          	auipc	ra,0x0
    80004826:	bec080e7          	jalr	-1044(ra) # 8000440e <filealloc>
    8000482a:	00aa3023          	sd	a0,0(s4)
    8000482e:	c92d                	beqz	a0,800048a0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004830:	ffffc097          	auipc	ra,0xffffc
    80004834:	2b6080e7          	jalr	694(ra) # 80000ae6 <kalloc>
    80004838:	892a                	mv	s2,a0
    8000483a:	c125                	beqz	a0,8000489a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000483c:	4985                	li	s3,1
    8000483e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004842:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004846:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000484a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000484e:	00004597          	auipc	a1,0x4
    80004852:	ea258593          	addi	a1,a1,-350 # 800086f0 <syscalls+0x278>
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	2f0080e7          	jalr	752(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    8000485e:	609c                	ld	a5,0(s1)
    80004860:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004864:	609c                	ld	a5,0(s1)
    80004866:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000486a:	609c                	ld	a5,0(s1)
    8000486c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004870:	609c                	ld	a5,0(s1)
    80004872:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004876:	000a3783          	ld	a5,0(s4)
    8000487a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000487e:	000a3783          	ld	a5,0(s4)
    80004882:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004886:	000a3783          	ld	a5,0(s4)
    8000488a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000488e:	000a3783          	ld	a5,0(s4)
    80004892:	0127b823          	sd	s2,16(a5)
  return 0;
    80004896:	4501                	li	a0,0
    80004898:	a025                	j	800048c0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000489a:	6088                	ld	a0,0(s1)
    8000489c:	e501                	bnez	a0,800048a4 <pipealloc+0xaa>
    8000489e:	a039                	j	800048ac <pipealloc+0xb2>
    800048a0:	6088                	ld	a0,0(s1)
    800048a2:	c51d                	beqz	a0,800048d0 <pipealloc+0xd6>
    fileclose(*f0);
    800048a4:	00000097          	auipc	ra,0x0
    800048a8:	c26080e7          	jalr	-986(ra) # 800044ca <fileclose>
  if(*f1)
    800048ac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048b0:	557d                	li	a0,-1
  if(*f1)
    800048b2:	c799                	beqz	a5,800048c0 <pipealloc+0xc6>
    fileclose(*f1);
    800048b4:	853e                	mv	a0,a5
    800048b6:	00000097          	auipc	ra,0x0
    800048ba:	c14080e7          	jalr	-1004(ra) # 800044ca <fileclose>
  return -1;
    800048be:	557d                	li	a0,-1
}
    800048c0:	70a2                	ld	ra,40(sp)
    800048c2:	7402                	ld	s0,32(sp)
    800048c4:	64e2                	ld	s1,24(sp)
    800048c6:	6942                	ld	s2,16(sp)
    800048c8:	69a2                	ld	s3,8(sp)
    800048ca:	6a02                	ld	s4,0(sp)
    800048cc:	6145                	addi	sp,sp,48
    800048ce:	8082                	ret
  return -1;
    800048d0:	557d                	li	a0,-1
    800048d2:	b7fd                	j	800048c0 <pipealloc+0xc6>

00000000800048d4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048d4:	1101                	addi	sp,sp,-32
    800048d6:	ec06                	sd	ra,24(sp)
    800048d8:	e822                	sd	s0,16(sp)
    800048da:	e426                	sd	s1,8(sp)
    800048dc:	e04a                	sd	s2,0(sp)
    800048de:	1000                	addi	s0,sp,32
    800048e0:	84aa                	mv	s1,a0
    800048e2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048e4:	ffffc097          	auipc	ra,0xffffc
    800048e8:	2f2080e7          	jalr	754(ra) # 80000bd6 <acquire>
  if(writable){
    800048ec:	02090d63          	beqz	s2,80004926 <pipeclose+0x52>
    pi->writeopen = 0;
    800048f0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048f4:	21848513          	addi	a0,s1,536
    800048f8:	ffffd097          	auipc	ra,0xffffd
    800048fc:	7d0080e7          	jalr	2000(ra) # 800020c8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004900:	2204b783          	ld	a5,544(s1)
    80004904:	eb95                	bnez	a5,80004938 <pipeclose+0x64>
    release(&pi->lock);
    80004906:	8526                	mv	a0,s1
    80004908:	ffffc097          	auipc	ra,0xffffc
    8000490c:	382080e7          	jalr	898(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004910:	8526                	mv	a0,s1
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	0d8080e7          	jalr	216(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    8000491a:	60e2                	ld	ra,24(sp)
    8000491c:	6442                	ld	s0,16(sp)
    8000491e:	64a2                	ld	s1,8(sp)
    80004920:	6902                	ld	s2,0(sp)
    80004922:	6105                	addi	sp,sp,32
    80004924:	8082                	ret
    pi->readopen = 0;
    80004926:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000492a:	21c48513          	addi	a0,s1,540
    8000492e:	ffffd097          	auipc	ra,0xffffd
    80004932:	79a080e7          	jalr	1946(ra) # 800020c8 <wakeup>
    80004936:	b7e9                	j	80004900 <pipeclose+0x2c>
    release(&pi->lock);
    80004938:	8526                	mv	a0,s1
    8000493a:	ffffc097          	auipc	ra,0xffffc
    8000493e:	350080e7          	jalr	848(ra) # 80000c8a <release>
}
    80004942:	bfe1                	j	8000491a <pipeclose+0x46>

0000000080004944 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004944:	711d                	addi	sp,sp,-96
    80004946:	ec86                	sd	ra,88(sp)
    80004948:	e8a2                	sd	s0,80(sp)
    8000494a:	e4a6                	sd	s1,72(sp)
    8000494c:	e0ca                	sd	s2,64(sp)
    8000494e:	fc4e                	sd	s3,56(sp)
    80004950:	f852                	sd	s4,48(sp)
    80004952:	f456                	sd	s5,40(sp)
    80004954:	f05a                	sd	s6,32(sp)
    80004956:	ec5e                	sd	s7,24(sp)
    80004958:	e862                	sd	s8,16(sp)
    8000495a:	1080                	addi	s0,sp,96
    8000495c:	84aa                	mv	s1,a0
    8000495e:	8aae                	mv	s5,a1
    80004960:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004962:	ffffd097          	auipc	ra,0xffffd
    80004966:	05a080e7          	jalr	90(ra) # 800019bc <myproc>
    8000496a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000496c:	8526                	mv	a0,s1
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	268080e7          	jalr	616(ra) # 80000bd6 <acquire>
  while(i < n){
    80004976:	0b405663          	blez	s4,80004a22 <pipewrite+0xde>
  int i = 0;
    8000497a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000497c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000497e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004982:	21c48b93          	addi	s7,s1,540
    80004986:	a089                	j	800049c8 <pipewrite+0x84>
      release(&pi->lock);
    80004988:	8526                	mv	a0,s1
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	300080e7          	jalr	768(ra) # 80000c8a <release>
      return -1;
    80004992:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004994:	854a                	mv	a0,s2
    80004996:	60e6                	ld	ra,88(sp)
    80004998:	6446                	ld	s0,80(sp)
    8000499a:	64a6                	ld	s1,72(sp)
    8000499c:	6906                	ld	s2,64(sp)
    8000499e:	79e2                	ld	s3,56(sp)
    800049a0:	7a42                	ld	s4,48(sp)
    800049a2:	7aa2                	ld	s5,40(sp)
    800049a4:	7b02                	ld	s6,32(sp)
    800049a6:	6be2                	ld	s7,24(sp)
    800049a8:	6c42                	ld	s8,16(sp)
    800049aa:	6125                	addi	sp,sp,96
    800049ac:	8082                	ret
      wakeup(&pi->nread);
    800049ae:	8562                	mv	a0,s8
    800049b0:	ffffd097          	auipc	ra,0xffffd
    800049b4:	718080e7          	jalr	1816(ra) # 800020c8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049b8:	85a6                	mv	a1,s1
    800049ba:	855e                	mv	a0,s7
    800049bc:	ffffd097          	auipc	ra,0xffffd
    800049c0:	6a8080e7          	jalr	1704(ra) # 80002064 <sleep>
  while(i < n){
    800049c4:	07495063          	bge	s2,s4,80004a24 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800049c8:	2204a783          	lw	a5,544(s1)
    800049cc:	dfd5                	beqz	a5,80004988 <pipewrite+0x44>
    800049ce:	854e                	mv	a0,s3
    800049d0:	ffffe097          	auipc	ra,0xffffe
    800049d4:	93c080e7          	jalr	-1732(ra) # 8000230c <killed>
    800049d8:	f945                	bnez	a0,80004988 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800049da:	2184a783          	lw	a5,536(s1)
    800049de:	21c4a703          	lw	a4,540(s1)
    800049e2:	2007879b          	addiw	a5,a5,512
    800049e6:	fcf704e3          	beq	a4,a5,800049ae <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049ea:	4685                	li	a3,1
    800049ec:	01590633          	add	a2,s2,s5
    800049f0:	faf40593          	addi	a1,s0,-81
    800049f4:	0509b503          	ld	a0,80(s3)
    800049f8:	ffffd097          	auipc	ra,0xffffd
    800049fc:	d0c080e7          	jalr	-756(ra) # 80001704 <copyin>
    80004a00:	03650263          	beq	a0,s6,80004a24 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a04:	21c4a783          	lw	a5,540(s1)
    80004a08:	0017871b          	addiw	a4,a5,1
    80004a0c:	20e4ae23          	sw	a4,540(s1)
    80004a10:	1ff7f793          	andi	a5,a5,511
    80004a14:	97a6                	add	a5,a5,s1
    80004a16:	faf44703          	lbu	a4,-81(s0)
    80004a1a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a1e:	2905                	addiw	s2,s2,1
    80004a20:	b755                	j	800049c4 <pipewrite+0x80>
  int i = 0;
    80004a22:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a24:	21848513          	addi	a0,s1,536
    80004a28:	ffffd097          	auipc	ra,0xffffd
    80004a2c:	6a0080e7          	jalr	1696(ra) # 800020c8 <wakeup>
  release(&pi->lock);
    80004a30:	8526                	mv	a0,s1
    80004a32:	ffffc097          	auipc	ra,0xffffc
    80004a36:	258080e7          	jalr	600(ra) # 80000c8a <release>
  return i;
    80004a3a:	bfa9                	j	80004994 <pipewrite+0x50>

0000000080004a3c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a3c:	715d                	addi	sp,sp,-80
    80004a3e:	e486                	sd	ra,72(sp)
    80004a40:	e0a2                	sd	s0,64(sp)
    80004a42:	fc26                	sd	s1,56(sp)
    80004a44:	f84a                	sd	s2,48(sp)
    80004a46:	f44e                	sd	s3,40(sp)
    80004a48:	f052                	sd	s4,32(sp)
    80004a4a:	ec56                	sd	s5,24(sp)
    80004a4c:	e85a                	sd	s6,16(sp)
    80004a4e:	0880                	addi	s0,sp,80
    80004a50:	84aa                	mv	s1,a0
    80004a52:	892e                	mv	s2,a1
    80004a54:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a56:	ffffd097          	auipc	ra,0xffffd
    80004a5a:	f66080e7          	jalr	-154(ra) # 800019bc <myproc>
    80004a5e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a60:	8526                	mv	a0,s1
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	174080e7          	jalr	372(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a6a:	2184a703          	lw	a4,536(s1)
    80004a6e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a72:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a76:	02f71763          	bne	a4,a5,80004aa4 <piperead+0x68>
    80004a7a:	2244a783          	lw	a5,548(s1)
    80004a7e:	c39d                	beqz	a5,80004aa4 <piperead+0x68>
    if(killed(pr)){
    80004a80:	8552                	mv	a0,s4
    80004a82:	ffffe097          	auipc	ra,0xffffe
    80004a86:	88a080e7          	jalr	-1910(ra) # 8000230c <killed>
    80004a8a:	e941                	bnez	a0,80004b1a <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a8c:	85a6                	mv	a1,s1
    80004a8e:	854e                	mv	a0,s3
    80004a90:	ffffd097          	auipc	ra,0xffffd
    80004a94:	5d4080e7          	jalr	1492(ra) # 80002064 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a98:	2184a703          	lw	a4,536(s1)
    80004a9c:	21c4a783          	lw	a5,540(s1)
    80004aa0:	fcf70de3          	beq	a4,a5,80004a7a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aa4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004aa6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aa8:	05505363          	blez	s5,80004aee <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004aac:	2184a783          	lw	a5,536(s1)
    80004ab0:	21c4a703          	lw	a4,540(s1)
    80004ab4:	02f70d63          	beq	a4,a5,80004aee <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ab8:	0017871b          	addiw	a4,a5,1
    80004abc:	20e4ac23          	sw	a4,536(s1)
    80004ac0:	1ff7f793          	andi	a5,a5,511
    80004ac4:	97a6                	add	a5,a5,s1
    80004ac6:	0187c783          	lbu	a5,24(a5)
    80004aca:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ace:	4685                	li	a3,1
    80004ad0:	fbf40613          	addi	a2,s0,-65
    80004ad4:	85ca                	mv	a1,s2
    80004ad6:	050a3503          	ld	a0,80(s4)
    80004ada:	ffffd097          	auipc	ra,0xffffd
    80004ade:	b9e080e7          	jalr	-1122(ra) # 80001678 <copyout>
    80004ae2:	01650663          	beq	a0,s6,80004aee <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ae6:	2985                	addiw	s3,s3,1
    80004ae8:	0905                	addi	s2,s2,1
    80004aea:	fd3a91e3          	bne	s5,s3,80004aac <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004aee:	21c48513          	addi	a0,s1,540
    80004af2:	ffffd097          	auipc	ra,0xffffd
    80004af6:	5d6080e7          	jalr	1494(ra) # 800020c8 <wakeup>
  release(&pi->lock);
    80004afa:	8526                	mv	a0,s1
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	18e080e7          	jalr	398(ra) # 80000c8a <release>
  return i;
}
    80004b04:	854e                	mv	a0,s3
    80004b06:	60a6                	ld	ra,72(sp)
    80004b08:	6406                	ld	s0,64(sp)
    80004b0a:	74e2                	ld	s1,56(sp)
    80004b0c:	7942                	ld	s2,48(sp)
    80004b0e:	79a2                	ld	s3,40(sp)
    80004b10:	7a02                	ld	s4,32(sp)
    80004b12:	6ae2                	ld	s5,24(sp)
    80004b14:	6b42                	ld	s6,16(sp)
    80004b16:	6161                	addi	sp,sp,80
    80004b18:	8082                	ret
      release(&pi->lock);
    80004b1a:	8526                	mv	a0,s1
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	16e080e7          	jalr	366(ra) # 80000c8a <release>
      return -1;
    80004b24:	59fd                	li	s3,-1
    80004b26:	bff9                	j	80004b04 <piperead+0xc8>

0000000080004b28 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b28:	1141                	addi	sp,sp,-16
    80004b2a:	e422                	sd	s0,8(sp)
    80004b2c:	0800                	addi	s0,sp,16
    80004b2e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b30:	8905                	andi	a0,a0,1
    80004b32:	c111                	beqz	a0,80004b36 <flags2perm+0xe>
      perm = PTE_X;
    80004b34:	4521                	li	a0,8
    if(flags & 0x2)
    80004b36:	8b89                	andi	a5,a5,2
    80004b38:	c399                	beqz	a5,80004b3e <flags2perm+0x16>
      perm |= PTE_W;
    80004b3a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b3e:	6422                	ld	s0,8(sp)
    80004b40:	0141                	addi	sp,sp,16
    80004b42:	8082                	ret

0000000080004b44 <exec>:

int
exec(char *path, char **argv)
{
    80004b44:	de010113          	addi	sp,sp,-544
    80004b48:	20113c23          	sd	ra,536(sp)
    80004b4c:	20813823          	sd	s0,528(sp)
    80004b50:	20913423          	sd	s1,520(sp)
    80004b54:	21213023          	sd	s2,512(sp)
    80004b58:	ffce                	sd	s3,504(sp)
    80004b5a:	fbd2                	sd	s4,496(sp)
    80004b5c:	f7d6                	sd	s5,488(sp)
    80004b5e:	f3da                	sd	s6,480(sp)
    80004b60:	efde                	sd	s7,472(sp)
    80004b62:	ebe2                	sd	s8,464(sp)
    80004b64:	e7e6                	sd	s9,456(sp)
    80004b66:	e3ea                	sd	s10,448(sp)
    80004b68:	ff6e                	sd	s11,440(sp)
    80004b6a:	1400                	addi	s0,sp,544
    80004b6c:	892a                	mv	s2,a0
    80004b6e:	dea43423          	sd	a0,-536(s0)
    80004b72:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b76:	ffffd097          	auipc	ra,0xffffd
    80004b7a:	e46080e7          	jalr	-442(ra) # 800019bc <myproc>
    80004b7e:	84aa                	mv	s1,a0

  begin_op();
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	47e080e7          	jalr	1150(ra) # 80003ffe <begin_op>

  if((ip = namei(path)) == 0){
    80004b88:	854a                	mv	a0,s2
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	258080e7          	jalr	600(ra) # 80003de2 <namei>
    80004b92:	c93d                	beqz	a0,80004c08 <exec+0xc4>
    80004b94:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b96:	fffff097          	auipc	ra,0xfffff
    80004b9a:	aa6080e7          	jalr	-1370(ra) # 8000363c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b9e:	04000713          	li	a4,64
    80004ba2:	4681                	li	a3,0
    80004ba4:	e5040613          	addi	a2,s0,-432
    80004ba8:	4581                	li	a1,0
    80004baa:	8556                	mv	a0,s5
    80004bac:	fffff097          	auipc	ra,0xfffff
    80004bb0:	d44080e7          	jalr	-700(ra) # 800038f0 <readi>
    80004bb4:	04000793          	li	a5,64
    80004bb8:	00f51a63          	bne	a0,a5,80004bcc <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004bbc:	e5042703          	lw	a4,-432(s0)
    80004bc0:	464c47b7          	lui	a5,0x464c4
    80004bc4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bc8:	04f70663          	beq	a4,a5,80004c14 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bcc:	8556                	mv	a0,s5
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	cd0080e7          	jalr	-816(ra) # 8000389e <iunlockput>
    end_op();
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	4a8080e7          	jalr	1192(ra) # 8000407e <end_op>
  }
  return -1;
    80004bde:	557d                	li	a0,-1
}
    80004be0:	21813083          	ld	ra,536(sp)
    80004be4:	21013403          	ld	s0,528(sp)
    80004be8:	20813483          	ld	s1,520(sp)
    80004bec:	20013903          	ld	s2,512(sp)
    80004bf0:	79fe                	ld	s3,504(sp)
    80004bf2:	7a5e                	ld	s4,496(sp)
    80004bf4:	7abe                	ld	s5,488(sp)
    80004bf6:	7b1e                	ld	s6,480(sp)
    80004bf8:	6bfe                	ld	s7,472(sp)
    80004bfa:	6c5e                	ld	s8,464(sp)
    80004bfc:	6cbe                	ld	s9,456(sp)
    80004bfe:	6d1e                	ld	s10,448(sp)
    80004c00:	7dfa                	ld	s11,440(sp)
    80004c02:	22010113          	addi	sp,sp,544
    80004c06:	8082                	ret
    end_op();
    80004c08:	fffff097          	auipc	ra,0xfffff
    80004c0c:	476080e7          	jalr	1142(ra) # 8000407e <end_op>
    return -1;
    80004c10:	557d                	li	a0,-1
    80004c12:	b7f9                	j	80004be0 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c14:	8526                	mv	a0,s1
    80004c16:	ffffd097          	auipc	ra,0xffffd
    80004c1a:	e6a080e7          	jalr	-406(ra) # 80001a80 <proc_pagetable>
    80004c1e:	8b2a                	mv	s6,a0
    80004c20:	d555                	beqz	a0,80004bcc <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c22:	e7042783          	lw	a5,-400(s0)
    80004c26:	e8845703          	lhu	a4,-376(s0)
    80004c2a:	c735                	beqz	a4,80004c96 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c2c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c2e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c32:	6a05                	lui	s4,0x1
    80004c34:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c38:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c3c:	6d85                	lui	s11,0x1
    80004c3e:	7d7d                	lui	s10,0xfffff
    80004c40:	a481                	j	80004e80 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c42:	00004517          	auipc	a0,0x4
    80004c46:	ab650513          	addi	a0,a0,-1354 # 800086f8 <syscalls+0x280>
    80004c4a:	ffffc097          	auipc	ra,0xffffc
    80004c4e:	8f4080e7          	jalr	-1804(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c52:	874a                	mv	a4,s2
    80004c54:	009c86bb          	addw	a3,s9,s1
    80004c58:	4581                	li	a1,0
    80004c5a:	8556                	mv	a0,s5
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	c94080e7          	jalr	-876(ra) # 800038f0 <readi>
    80004c64:	2501                	sext.w	a0,a0
    80004c66:	1aa91a63          	bne	s2,a0,80004e1a <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004c6a:	009d84bb          	addw	s1,s11,s1
    80004c6e:	013d09bb          	addw	s3,s10,s3
    80004c72:	1f74f763          	bgeu	s1,s7,80004e60 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004c76:	02049593          	slli	a1,s1,0x20
    80004c7a:	9181                	srli	a1,a1,0x20
    80004c7c:	95e2                	add	a1,a1,s8
    80004c7e:	855a                	mv	a0,s6
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	3ec080e7          	jalr	1004(ra) # 8000106c <walkaddr>
    80004c88:	862a                	mv	a2,a0
    if(pa == 0)
    80004c8a:	dd45                	beqz	a0,80004c42 <exec+0xfe>
      n = PGSIZE;
    80004c8c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004c8e:	fd49f2e3          	bgeu	s3,s4,80004c52 <exec+0x10e>
      n = sz - i;
    80004c92:	894e                	mv	s2,s3
    80004c94:	bf7d                	j	80004c52 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c96:	4901                	li	s2,0
  iunlockput(ip);
    80004c98:	8556                	mv	a0,s5
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	c04080e7          	jalr	-1020(ra) # 8000389e <iunlockput>
  end_op();
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	3dc080e7          	jalr	988(ra) # 8000407e <end_op>
  p = myproc();
    80004caa:	ffffd097          	auipc	ra,0xffffd
    80004cae:	d12080e7          	jalr	-750(ra) # 800019bc <myproc>
    80004cb2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004cb4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004cb8:	6785                	lui	a5,0x1
    80004cba:	17fd                	addi	a5,a5,-1
    80004cbc:	993e                	add	s2,s2,a5
    80004cbe:	77fd                	lui	a5,0xfffff
    80004cc0:	00f977b3          	and	a5,s2,a5
    80004cc4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004cc8:	4691                	li	a3,4
    80004cca:	6609                	lui	a2,0x2
    80004ccc:	963e                	add	a2,a2,a5
    80004cce:	85be                	mv	a1,a5
    80004cd0:	855a                	mv	a0,s6
    80004cd2:	ffffc097          	auipc	ra,0xffffc
    80004cd6:	74e080e7          	jalr	1870(ra) # 80001420 <uvmalloc>
    80004cda:	8c2a                	mv	s8,a0
  ip = 0;
    80004cdc:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004cde:	12050e63          	beqz	a0,80004e1a <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ce2:	75f9                	lui	a1,0xffffe
    80004ce4:	95aa                	add	a1,a1,a0
    80004ce6:	855a                	mv	a0,s6
    80004ce8:	ffffd097          	auipc	ra,0xffffd
    80004cec:	95e080e7          	jalr	-1698(ra) # 80001646 <uvmclear>
  stackbase = sp - PGSIZE;
    80004cf0:	7afd                	lui	s5,0xfffff
    80004cf2:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cf4:	df043783          	ld	a5,-528(s0)
    80004cf8:	6388                	ld	a0,0(a5)
    80004cfa:	c925                	beqz	a0,80004d6a <exec+0x226>
    80004cfc:	e9040993          	addi	s3,s0,-368
    80004d00:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d04:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d06:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	146080e7          	jalr	326(ra) # 80000e4e <strlen>
    80004d10:	0015079b          	addiw	a5,a0,1
    80004d14:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d18:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004d1c:	13596663          	bltu	s2,s5,80004e48 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d20:	df043d83          	ld	s11,-528(s0)
    80004d24:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d28:	8552                	mv	a0,s4
    80004d2a:	ffffc097          	auipc	ra,0xffffc
    80004d2e:	124080e7          	jalr	292(ra) # 80000e4e <strlen>
    80004d32:	0015069b          	addiw	a3,a0,1
    80004d36:	8652                	mv	a2,s4
    80004d38:	85ca                	mv	a1,s2
    80004d3a:	855a                	mv	a0,s6
    80004d3c:	ffffd097          	auipc	ra,0xffffd
    80004d40:	93c080e7          	jalr	-1732(ra) # 80001678 <copyout>
    80004d44:	10054663          	bltz	a0,80004e50 <exec+0x30c>
    ustack[argc] = sp;
    80004d48:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d4c:	0485                	addi	s1,s1,1
    80004d4e:	008d8793          	addi	a5,s11,8
    80004d52:	def43823          	sd	a5,-528(s0)
    80004d56:	008db503          	ld	a0,8(s11)
    80004d5a:	c911                	beqz	a0,80004d6e <exec+0x22a>
    if(argc >= MAXARG)
    80004d5c:	09a1                	addi	s3,s3,8
    80004d5e:	fb3c95e3          	bne	s9,s3,80004d08 <exec+0x1c4>
  sz = sz1;
    80004d62:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d66:	4a81                	li	s5,0
    80004d68:	a84d                	j	80004e1a <exec+0x2d6>
  sp = sz;
    80004d6a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d6c:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d6e:	00349793          	slli	a5,s1,0x3
    80004d72:	f9040713          	addi	a4,s0,-112
    80004d76:	97ba                	add	a5,a5,a4
    80004d78:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdd190>
  sp -= (argc+1) * sizeof(uint64);
    80004d7c:	00148693          	addi	a3,s1,1
    80004d80:	068e                	slli	a3,a3,0x3
    80004d82:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d86:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004d8a:	01597663          	bgeu	s2,s5,80004d96 <exec+0x252>
  sz = sz1;
    80004d8e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d92:	4a81                	li	s5,0
    80004d94:	a059                	j	80004e1a <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d96:	e9040613          	addi	a2,s0,-368
    80004d9a:	85ca                	mv	a1,s2
    80004d9c:	855a                	mv	a0,s6
    80004d9e:	ffffd097          	auipc	ra,0xffffd
    80004da2:	8da080e7          	jalr	-1830(ra) # 80001678 <copyout>
    80004da6:	0a054963          	bltz	a0,80004e58 <exec+0x314>
  p->trapframe->a1 = sp;
    80004daa:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004dae:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004db2:	de843783          	ld	a5,-536(s0)
    80004db6:	0007c703          	lbu	a4,0(a5)
    80004dba:	cf11                	beqz	a4,80004dd6 <exec+0x292>
    80004dbc:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004dbe:	02f00693          	li	a3,47
    80004dc2:	a039                	j	80004dd0 <exec+0x28c>
      last = s+1;
    80004dc4:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004dc8:	0785                	addi	a5,a5,1
    80004dca:	fff7c703          	lbu	a4,-1(a5)
    80004dce:	c701                	beqz	a4,80004dd6 <exec+0x292>
    if(*s == '/')
    80004dd0:	fed71ce3          	bne	a4,a3,80004dc8 <exec+0x284>
    80004dd4:	bfc5                	j	80004dc4 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80004dd6:	4641                	li	a2,16
    80004dd8:	de843583          	ld	a1,-536(s0)
    80004ddc:	158b8513          	addi	a0,s7,344
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	03c080e7          	jalr	60(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004de8:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004dec:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004df0:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004df4:	058bb783          	ld	a5,88(s7)
    80004df8:	e6843703          	ld	a4,-408(s0)
    80004dfc:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004dfe:	058bb783          	ld	a5,88(s7)
    80004e02:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e06:	85ea                	mv	a1,s10
    80004e08:	ffffd097          	auipc	ra,0xffffd
    80004e0c:	d14080e7          	jalr	-748(ra) # 80001b1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e10:	0004851b          	sext.w	a0,s1
    80004e14:	b3f1                	j	80004be0 <exec+0x9c>
    80004e16:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e1a:	df843583          	ld	a1,-520(s0)
    80004e1e:	855a                	mv	a0,s6
    80004e20:	ffffd097          	auipc	ra,0xffffd
    80004e24:	cfc080e7          	jalr	-772(ra) # 80001b1c <proc_freepagetable>
  if(ip){
    80004e28:	da0a92e3          	bnez	s5,80004bcc <exec+0x88>
  return -1;
    80004e2c:	557d                	li	a0,-1
    80004e2e:	bb4d                	j	80004be0 <exec+0x9c>
    80004e30:	df243c23          	sd	s2,-520(s0)
    80004e34:	b7dd                	j	80004e1a <exec+0x2d6>
    80004e36:	df243c23          	sd	s2,-520(s0)
    80004e3a:	b7c5                	j	80004e1a <exec+0x2d6>
    80004e3c:	df243c23          	sd	s2,-520(s0)
    80004e40:	bfe9                	j	80004e1a <exec+0x2d6>
    80004e42:	df243c23          	sd	s2,-520(s0)
    80004e46:	bfd1                	j	80004e1a <exec+0x2d6>
  sz = sz1;
    80004e48:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e4c:	4a81                	li	s5,0
    80004e4e:	b7f1                	j	80004e1a <exec+0x2d6>
  sz = sz1;
    80004e50:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e54:	4a81                	li	s5,0
    80004e56:	b7d1                	j	80004e1a <exec+0x2d6>
  sz = sz1;
    80004e58:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e5c:	4a81                	li	s5,0
    80004e5e:	bf75                	j	80004e1a <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e60:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e64:	e0843783          	ld	a5,-504(s0)
    80004e68:	0017869b          	addiw	a3,a5,1
    80004e6c:	e0d43423          	sd	a3,-504(s0)
    80004e70:	e0043783          	ld	a5,-512(s0)
    80004e74:	0387879b          	addiw	a5,a5,56
    80004e78:	e8845703          	lhu	a4,-376(s0)
    80004e7c:	e0e6dee3          	bge	a3,a4,80004c98 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e80:	2781                	sext.w	a5,a5
    80004e82:	e0f43023          	sd	a5,-512(s0)
    80004e86:	03800713          	li	a4,56
    80004e8a:	86be                	mv	a3,a5
    80004e8c:	e1840613          	addi	a2,s0,-488
    80004e90:	4581                	li	a1,0
    80004e92:	8556                	mv	a0,s5
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	a5c080e7          	jalr	-1444(ra) # 800038f0 <readi>
    80004e9c:	03800793          	li	a5,56
    80004ea0:	f6f51be3          	bne	a0,a5,80004e16 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80004ea4:	e1842783          	lw	a5,-488(s0)
    80004ea8:	4705                	li	a4,1
    80004eaa:	fae79de3          	bne	a5,a4,80004e64 <exec+0x320>
    if(ph.memsz < ph.filesz)
    80004eae:	e4043483          	ld	s1,-448(s0)
    80004eb2:	e3843783          	ld	a5,-456(s0)
    80004eb6:	f6f4ede3          	bltu	s1,a5,80004e30 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eba:	e2843783          	ld	a5,-472(s0)
    80004ebe:	94be                	add	s1,s1,a5
    80004ec0:	f6f4ebe3          	bltu	s1,a5,80004e36 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80004ec4:	de043703          	ld	a4,-544(s0)
    80004ec8:	8ff9                	and	a5,a5,a4
    80004eca:	fbad                	bnez	a5,80004e3c <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ecc:	e1c42503          	lw	a0,-484(s0)
    80004ed0:	00000097          	auipc	ra,0x0
    80004ed4:	c58080e7          	jalr	-936(ra) # 80004b28 <flags2perm>
    80004ed8:	86aa                	mv	a3,a0
    80004eda:	8626                	mv	a2,s1
    80004edc:	85ca                	mv	a1,s2
    80004ede:	855a                	mv	a0,s6
    80004ee0:	ffffc097          	auipc	ra,0xffffc
    80004ee4:	540080e7          	jalr	1344(ra) # 80001420 <uvmalloc>
    80004ee8:	dea43c23          	sd	a0,-520(s0)
    80004eec:	d939                	beqz	a0,80004e42 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004eee:	e2843c03          	ld	s8,-472(s0)
    80004ef2:	e2042c83          	lw	s9,-480(s0)
    80004ef6:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004efa:	f60b83e3          	beqz	s7,80004e60 <exec+0x31c>
    80004efe:	89de                	mv	s3,s7
    80004f00:	4481                	li	s1,0
    80004f02:	bb95                	j	80004c76 <exec+0x132>

0000000080004f04 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f04:	7179                	addi	sp,sp,-48
    80004f06:	f406                	sd	ra,40(sp)
    80004f08:	f022                	sd	s0,32(sp)
    80004f0a:	ec26                	sd	s1,24(sp)
    80004f0c:	e84a                	sd	s2,16(sp)
    80004f0e:	1800                	addi	s0,sp,48
    80004f10:	892e                	mv	s2,a1
    80004f12:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f14:	fdc40593          	addi	a1,s0,-36
    80004f18:	ffffe097          	auipc	ra,0xffffe
    80004f1c:	bb8080e7          	jalr	-1096(ra) # 80002ad0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f20:	fdc42703          	lw	a4,-36(s0)
    80004f24:	47bd                	li	a5,15
    80004f26:	02e7eb63          	bltu	a5,a4,80004f5c <argfd+0x58>
    80004f2a:	ffffd097          	auipc	ra,0xffffd
    80004f2e:	a92080e7          	jalr	-1390(ra) # 800019bc <myproc>
    80004f32:	fdc42703          	lw	a4,-36(s0)
    80004f36:	01a70793          	addi	a5,a4,26
    80004f3a:	078e                	slli	a5,a5,0x3
    80004f3c:	953e                	add	a0,a0,a5
    80004f3e:	611c                	ld	a5,0(a0)
    80004f40:	c385                	beqz	a5,80004f60 <argfd+0x5c>
    return -1;
  if(pfd)
    80004f42:	00090463          	beqz	s2,80004f4a <argfd+0x46>
    *pfd = fd;
    80004f46:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f4a:	4501                	li	a0,0
  if(pf)
    80004f4c:	c091                	beqz	s1,80004f50 <argfd+0x4c>
    *pf = f;
    80004f4e:	e09c                	sd	a5,0(s1)
}
    80004f50:	70a2                	ld	ra,40(sp)
    80004f52:	7402                	ld	s0,32(sp)
    80004f54:	64e2                	ld	s1,24(sp)
    80004f56:	6942                	ld	s2,16(sp)
    80004f58:	6145                	addi	sp,sp,48
    80004f5a:	8082                	ret
    return -1;
    80004f5c:	557d                	li	a0,-1
    80004f5e:	bfcd                	j	80004f50 <argfd+0x4c>
    80004f60:	557d                	li	a0,-1
    80004f62:	b7fd                	j	80004f50 <argfd+0x4c>

0000000080004f64 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f64:	1101                	addi	sp,sp,-32
    80004f66:	ec06                	sd	ra,24(sp)
    80004f68:	e822                	sd	s0,16(sp)
    80004f6a:	e426                	sd	s1,8(sp)
    80004f6c:	1000                	addi	s0,sp,32
    80004f6e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f70:	ffffd097          	auipc	ra,0xffffd
    80004f74:	a4c080e7          	jalr	-1460(ra) # 800019bc <myproc>
    80004f78:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f7a:	0d050793          	addi	a5,a0,208
    80004f7e:	4501                	li	a0,0
    80004f80:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f82:	6398                	ld	a4,0(a5)
    80004f84:	cb19                	beqz	a4,80004f9a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f86:	2505                	addiw	a0,a0,1
    80004f88:	07a1                	addi	a5,a5,8
    80004f8a:	fed51ce3          	bne	a0,a3,80004f82 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f8e:	557d                	li	a0,-1
}
    80004f90:	60e2                	ld	ra,24(sp)
    80004f92:	6442                	ld	s0,16(sp)
    80004f94:	64a2                	ld	s1,8(sp)
    80004f96:	6105                	addi	sp,sp,32
    80004f98:	8082                	ret
      p->ofile[fd] = f;
    80004f9a:	01a50793          	addi	a5,a0,26
    80004f9e:	078e                	slli	a5,a5,0x3
    80004fa0:	963e                	add	a2,a2,a5
    80004fa2:	e204                	sd	s1,0(a2)
      return fd;
    80004fa4:	b7f5                	j	80004f90 <fdalloc+0x2c>

0000000080004fa6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fa6:	715d                	addi	sp,sp,-80
    80004fa8:	e486                	sd	ra,72(sp)
    80004faa:	e0a2                	sd	s0,64(sp)
    80004fac:	fc26                	sd	s1,56(sp)
    80004fae:	f84a                	sd	s2,48(sp)
    80004fb0:	f44e                	sd	s3,40(sp)
    80004fb2:	f052                	sd	s4,32(sp)
    80004fb4:	ec56                	sd	s5,24(sp)
    80004fb6:	e85a                	sd	s6,16(sp)
    80004fb8:	0880                	addi	s0,sp,80
    80004fba:	8b2e                	mv	s6,a1
    80004fbc:	89b2                	mv	s3,a2
    80004fbe:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fc0:	fb040593          	addi	a1,s0,-80
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	e3c080e7          	jalr	-452(ra) # 80003e00 <nameiparent>
    80004fcc:	84aa                	mv	s1,a0
    80004fce:	14050f63          	beqz	a0,8000512c <create+0x186>
    return 0;

  ilock(dp);
    80004fd2:	ffffe097          	auipc	ra,0xffffe
    80004fd6:	66a080e7          	jalr	1642(ra) # 8000363c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fda:	4601                	li	a2,0
    80004fdc:	fb040593          	addi	a1,s0,-80
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	fffff097          	auipc	ra,0xfffff
    80004fe6:	b3e080e7          	jalr	-1218(ra) # 80003b20 <dirlookup>
    80004fea:	8aaa                	mv	s5,a0
    80004fec:	c931                	beqz	a0,80005040 <create+0x9a>
    iunlockput(dp);
    80004fee:	8526                	mv	a0,s1
    80004ff0:	fffff097          	auipc	ra,0xfffff
    80004ff4:	8ae080e7          	jalr	-1874(ra) # 8000389e <iunlockput>
    ilock(ip);
    80004ff8:	8556                	mv	a0,s5
    80004ffa:	ffffe097          	auipc	ra,0xffffe
    80004ffe:	642080e7          	jalr	1602(ra) # 8000363c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005002:	000b059b          	sext.w	a1,s6
    80005006:	4789                	li	a5,2
    80005008:	02f59563          	bne	a1,a5,80005032 <create+0x8c>
    8000500c:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd2d4>
    80005010:	37f9                	addiw	a5,a5,-2
    80005012:	17c2                	slli	a5,a5,0x30
    80005014:	93c1                	srli	a5,a5,0x30
    80005016:	4705                	li	a4,1
    80005018:	00f76d63          	bltu	a4,a5,80005032 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000501c:	8556                	mv	a0,s5
    8000501e:	60a6                	ld	ra,72(sp)
    80005020:	6406                	ld	s0,64(sp)
    80005022:	74e2                	ld	s1,56(sp)
    80005024:	7942                	ld	s2,48(sp)
    80005026:	79a2                	ld	s3,40(sp)
    80005028:	7a02                	ld	s4,32(sp)
    8000502a:	6ae2                	ld	s5,24(sp)
    8000502c:	6b42                	ld	s6,16(sp)
    8000502e:	6161                	addi	sp,sp,80
    80005030:	8082                	ret
    iunlockput(ip);
    80005032:	8556                	mv	a0,s5
    80005034:	fffff097          	auipc	ra,0xfffff
    80005038:	86a080e7          	jalr	-1942(ra) # 8000389e <iunlockput>
    return 0;
    8000503c:	4a81                	li	s5,0
    8000503e:	bff9                	j	8000501c <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005040:	85da                	mv	a1,s6
    80005042:	4088                	lw	a0,0(s1)
    80005044:	ffffe097          	auipc	ra,0xffffe
    80005048:	45c080e7          	jalr	1116(ra) # 800034a0 <ialloc>
    8000504c:	8a2a                	mv	s4,a0
    8000504e:	c539                	beqz	a0,8000509c <create+0xf6>
  ilock(ip);
    80005050:	ffffe097          	auipc	ra,0xffffe
    80005054:	5ec080e7          	jalr	1516(ra) # 8000363c <ilock>
  ip->major = major;
    80005058:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000505c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005060:	4905                	li	s2,1
    80005062:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005066:	8552                	mv	a0,s4
    80005068:	ffffe097          	auipc	ra,0xffffe
    8000506c:	50a080e7          	jalr	1290(ra) # 80003572 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005070:	000b059b          	sext.w	a1,s6
    80005074:	03258b63          	beq	a1,s2,800050aa <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005078:	004a2603          	lw	a2,4(s4)
    8000507c:	fb040593          	addi	a1,s0,-80
    80005080:	8526                	mv	a0,s1
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	cae080e7          	jalr	-850(ra) # 80003d30 <dirlink>
    8000508a:	06054f63          	bltz	a0,80005108 <create+0x162>
  iunlockput(dp);
    8000508e:	8526                	mv	a0,s1
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	80e080e7          	jalr	-2034(ra) # 8000389e <iunlockput>
  return ip;
    80005098:	8ad2                	mv	s5,s4
    8000509a:	b749                	j	8000501c <create+0x76>
    iunlockput(dp);
    8000509c:	8526                	mv	a0,s1
    8000509e:	fffff097          	auipc	ra,0xfffff
    800050a2:	800080e7          	jalr	-2048(ra) # 8000389e <iunlockput>
    return 0;
    800050a6:	8ad2                	mv	s5,s4
    800050a8:	bf95                	j	8000501c <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050aa:	004a2603          	lw	a2,4(s4)
    800050ae:	00003597          	auipc	a1,0x3
    800050b2:	66a58593          	addi	a1,a1,1642 # 80008718 <syscalls+0x2a0>
    800050b6:	8552                	mv	a0,s4
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	c78080e7          	jalr	-904(ra) # 80003d30 <dirlink>
    800050c0:	04054463          	bltz	a0,80005108 <create+0x162>
    800050c4:	40d0                	lw	a2,4(s1)
    800050c6:	00003597          	auipc	a1,0x3
    800050ca:	65a58593          	addi	a1,a1,1626 # 80008720 <syscalls+0x2a8>
    800050ce:	8552                	mv	a0,s4
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	c60080e7          	jalr	-928(ra) # 80003d30 <dirlink>
    800050d8:	02054863          	bltz	a0,80005108 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800050dc:	004a2603          	lw	a2,4(s4)
    800050e0:	fb040593          	addi	a1,s0,-80
    800050e4:	8526                	mv	a0,s1
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	c4a080e7          	jalr	-950(ra) # 80003d30 <dirlink>
    800050ee:	00054d63          	bltz	a0,80005108 <create+0x162>
    dp->nlink++;  // for ".."
    800050f2:	04a4d783          	lhu	a5,74(s1)
    800050f6:	2785                	addiw	a5,a5,1
    800050f8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050fc:	8526                	mv	a0,s1
    800050fe:	ffffe097          	auipc	ra,0xffffe
    80005102:	474080e7          	jalr	1140(ra) # 80003572 <iupdate>
    80005106:	b761                	j	8000508e <create+0xe8>
  ip->nlink = 0;
    80005108:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000510c:	8552                	mv	a0,s4
    8000510e:	ffffe097          	auipc	ra,0xffffe
    80005112:	464080e7          	jalr	1124(ra) # 80003572 <iupdate>
  iunlockput(ip);
    80005116:	8552                	mv	a0,s4
    80005118:	ffffe097          	auipc	ra,0xffffe
    8000511c:	786080e7          	jalr	1926(ra) # 8000389e <iunlockput>
  iunlockput(dp);
    80005120:	8526                	mv	a0,s1
    80005122:	ffffe097          	auipc	ra,0xffffe
    80005126:	77c080e7          	jalr	1916(ra) # 8000389e <iunlockput>
  return 0;
    8000512a:	bdcd                	j	8000501c <create+0x76>
    return 0;
    8000512c:	8aaa                	mv	s5,a0
    8000512e:	b5fd                	j	8000501c <create+0x76>

0000000080005130 <sys_dup>:
{
    80005130:	7179                	addi	sp,sp,-48
    80005132:	f406                	sd	ra,40(sp)
    80005134:	f022                	sd	s0,32(sp)
    80005136:	ec26                	sd	s1,24(sp)
    80005138:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000513a:	fd840613          	addi	a2,s0,-40
    8000513e:	4581                	li	a1,0
    80005140:	4501                	li	a0,0
    80005142:	00000097          	auipc	ra,0x0
    80005146:	dc2080e7          	jalr	-574(ra) # 80004f04 <argfd>
    return -1;
    8000514a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000514c:	02054363          	bltz	a0,80005172 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005150:	fd843503          	ld	a0,-40(s0)
    80005154:	00000097          	auipc	ra,0x0
    80005158:	e10080e7          	jalr	-496(ra) # 80004f64 <fdalloc>
    8000515c:	84aa                	mv	s1,a0
    return -1;
    8000515e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005160:	00054963          	bltz	a0,80005172 <sys_dup+0x42>
  filedup(f);
    80005164:	fd843503          	ld	a0,-40(s0)
    80005168:	fffff097          	auipc	ra,0xfffff
    8000516c:	310080e7          	jalr	784(ra) # 80004478 <filedup>
  return fd;
    80005170:	87a6                	mv	a5,s1
}
    80005172:	853e                	mv	a0,a5
    80005174:	70a2                	ld	ra,40(sp)
    80005176:	7402                	ld	s0,32(sp)
    80005178:	64e2                	ld	s1,24(sp)
    8000517a:	6145                	addi	sp,sp,48
    8000517c:	8082                	ret

000000008000517e <sys_read>:
{
    8000517e:	7179                	addi	sp,sp,-48
    80005180:	f406                	sd	ra,40(sp)
    80005182:	f022                	sd	s0,32(sp)
    80005184:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005186:	fd840593          	addi	a1,s0,-40
    8000518a:	4505                	li	a0,1
    8000518c:	ffffe097          	auipc	ra,0xffffe
    80005190:	964080e7          	jalr	-1692(ra) # 80002af0 <argaddr>
  argint(2, &n);
    80005194:	fe440593          	addi	a1,s0,-28
    80005198:	4509                	li	a0,2
    8000519a:	ffffe097          	auipc	ra,0xffffe
    8000519e:	936080e7          	jalr	-1738(ra) # 80002ad0 <argint>
  if(argfd(0, 0, &f) < 0)
    800051a2:	fe840613          	addi	a2,s0,-24
    800051a6:	4581                	li	a1,0
    800051a8:	4501                	li	a0,0
    800051aa:	00000097          	auipc	ra,0x0
    800051ae:	d5a080e7          	jalr	-678(ra) # 80004f04 <argfd>
    800051b2:	87aa                	mv	a5,a0
    return -1;
    800051b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051b6:	0007cc63          	bltz	a5,800051ce <sys_read+0x50>
  return fileread(f, p, n);
    800051ba:	fe442603          	lw	a2,-28(s0)
    800051be:	fd843583          	ld	a1,-40(s0)
    800051c2:	fe843503          	ld	a0,-24(s0)
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	43e080e7          	jalr	1086(ra) # 80004604 <fileread>
}
    800051ce:	70a2                	ld	ra,40(sp)
    800051d0:	7402                	ld	s0,32(sp)
    800051d2:	6145                	addi	sp,sp,48
    800051d4:	8082                	ret

00000000800051d6 <sys_write>:
{
    800051d6:	7179                	addi	sp,sp,-48
    800051d8:	f406                	sd	ra,40(sp)
    800051da:	f022                	sd	s0,32(sp)
    800051dc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051de:	fd840593          	addi	a1,s0,-40
    800051e2:	4505                	li	a0,1
    800051e4:	ffffe097          	auipc	ra,0xffffe
    800051e8:	90c080e7          	jalr	-1780(ra) # 80002af0 <argaddr>
  argint(2, &n);
    800051ec:	fe440593          	addi	a1,s0,-28
    800051f0:	4509                	li	a0,2
    800051f2:	ffffe097          	auipc	ra,0xffffe
    800051f6:	8de080e7          	jalr	-1826(ra) # 80002ad0 <argint>
  if(argfd(0, 0, &f) < 0)
    800051fa:	fe840613          	addi	a2,s0,-24
    800051fe:	4581                	li	a1,0
    80005200:	4501                	li	a0,0
    80005202:	00000097          	auipc	ra,0x0
    80005206:	d02080e7          	jalr	-766(ra) # 80004f04 <argfd>
    8000520a:	87aa                	mv	a5,a0
    return -1;
    8000520c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000520e:	0007cc63          	bltz	a5,80005226 <sys_write+0x50>
  return filewrite(f, p, n);
    80005212:	fe442603          	lw	a2,-28(s0)
    80005216:	fd843583          	ld	a1,-40(s0)
    8000521a:	fe843503          	ld	a0,-24(s0)
    8000521e:	fffff097          	auipc	ra,0xfffff
    80005222:	4a8080e7          	jalr	1192(ra) # 800046c6 <filewrite>
}
    80005226:	70a2                	ld	ra,40(sp)
    80005228:	7402                	ld	s0,32(sp)
    8000522a:	6145                	addi	sp,sp,48
    8000522c:	8082                	ret

000000008000522e <sys_close>:
{
    8000522e:	1101                	addi	sp,sp,-32
    80005230:	ec06                	sd	ra,24(sp)
    80005232:	e822                	sd	s0,16(sp)
    80005234:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005236:	fe040613          	addi	a2,s0,-32
    8000523a:	fec40593          	addi	a1,s0,-20
    8000523e:	4501                	li	a0,0
    80005240:	00000097          	auipc	ra,0x0
    80005244:	cc4080e7          	jalr	-828(ra) # 80004f04 <argfd>
    return -1;
    80005248:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000524a:	02054463          	bltz	a0,80005272 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	76e080e7          	jalr	1902(ra) # 800019bc <myproc>
    80005256:	fec42783          	lw	a5,-20(s0)
    8000525a:	07e9                	addi	a5,a5,26
    8000525c:	078e                	slli	a5,a5,0x3
    8000525e:	97aa                	add	a5,a5,a0
    80005260:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005264:	fe043503          	ld	a0,-32(s0)
    80005268:	fffff097          	auipc	ra,0xfffff
    8000526c:	262080e7          	jalr	610(ra) # 800044ca <fileclose>
  return 0;
    80005270:	4781                	li	a5,0
}
    80005272:	853e                	mv	a0,a5
    80005274:	60e2                	ld	ra,24(sp)
    80005276:	6442                	ld	s0,16(sp)
    80005278:	6105                	addi	sp,sp,32
    8000527a:	8082                	ret

000000008000527c <sys_fstat>:
{
    8000527c:	1101                	addi	sp,sp,-32
    8000527e:	ec06                	sd	ra,24(sp)
    80005280:	e822                	sd	s0,16(sp)
    80005282:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005284:	fe040593          	addi	a1,s0,-32
    80005288:	4505                	li	a0,1
    8000528a:	ffffe097          	auipc	ra,0xffffe
    8000528e:	866080e7          	jalr	-1946(ra) # 80002af0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005292:	fe840613          	addi	a2,s0,-24
    80005296:	4581                	li	a1,0
    80005298:	4501                	li	a0,0
    8000529a:	00000097          	auipc	ra,0x0
    8000529e:	c6a080e7          	jalr	-918(ra) # 80004f04 <argfd>
    800052a2:	87aa                	mv	a5,a0
    return -1;
    800052a4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052a6:	0007ca63          	bltz	a5,800052ba <sys_fstat+0x3e>
  return filestat(f, st);
    800052aa:	fe043583          	ld	a1,-32(s0)
    800052ae:	fe843503          	ld	a0,-24(s0)
    800052b2:	fffff097          	auipc	ra,0xfffff
    800052b6:	2e0080e7          	jalr	736(ra) # 80004592 <filestat>
}
    800052ba:	60e2                	ld	ra,24(sp)
    800052bc:	6442                	ld	s0,16(sp)
    800052be:	6105                	addi	sp,sp,32
    800052c0:	8082                	ret

00000000800052c2 <sys_link>:
{
    800052c2:	7169                	addi	sp,sp,-304
    800052c4:	f606                	sd	ra,296(sp)
    800052c6:	f222                	sd	s0,288(sp)
    800052c8:	ee26                	sd	s1,280(sp)
    800052ca:	ea4a                	sd	s2,272(sp)
    800052cc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052ce:	08000613          	li	a2,128
    800052d2:	ed040593          	addi	a1,s0,-304
    800052d6:	4501                	li	a0,0
    800052d8:	ffffe097          	auipc	ra,0xffffe
    800052dc:	838080e7          	jalr	-1992(ra) # 80002b10 <argstr>
    return -1;
    800052e0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052e2:	10054e63          	bltz	a0,800053fe <sys_link+0x13c>
    800052e6:	08000613          	li	a2,128
    800052ea:	f5040593          	addi	a1,s0,-176
    800052ee:	4505                	li	a0,1
    800052f0:	ffffe097          	auipc	ra,0xffffe
    800052f4:	820080e7          	jalr	-2016(ra) # 80002b10 <argstr>
    return -1;
    800052f8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052fa:	10054263          	bltz	a0,800053fe <sys_link+0x13c>
  begin_op();
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	d00080e7          	jalr	-768(ra) # 80003ffe <begin_op>
  if((ip = namei(old)) == 0){
    80005306:	ed040513          	addi	a0,s0,-304
    8000530a:	fffff097          	auipc	ra,0xfffff
    8000530e:	ad8080e7          	jalr	-1320(ra) # 80003de2 <namei>
    80005312:	84aa                	mv	s1,a0
    80005314:	c551                	beqz	a0,800053a0 <sys_link+0xde>
  ilock(ip);
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	326080e7          	jalr	806(ra) # 8000363c <ilock>
  if(ip->type == T_DIR){
    8000531e:	04449703          	lh	a4,68(s1)
    80005322:	4785                	li	a5,1
    80005324:	08f70463          	beq	a4,a5,800053ac <sys_link+0xea>
  ip->nlink++;
    80005328:	04a4d783          	lhu	a5,74(s1)
    8000532c:	2785                	addiw	a5,a5,1
    8000532e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005332:	8526                	mv	a0,s1
    80005334:	ffffe097          	auipc	ra,0xffffe
    80005338:	23e080e7          	jalr	574(ra) # 80003572 <iupdate>
  iunlock(ip);
    8000533c:	8526                	mv	a0,s1
    8000533e:	ffffe097          	auipc	ra,0xffffe
    80005342:	3c0080e7          	jalr	960(ra) # 800036fe <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005346:	fd040593          	addi	a1,s0,-48
    8000534a:	f5040513          	addi	a0,s0,-176
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	ab2080e7          	jalr	-1358(ra) # 80003e00 <nameiparent>
    80005356:	892a                	mv	s2,a0
    80005358:	c935                	beqz	a0,800053cc <sys_link+0x10a>
  ilock(dp);
    8000535a:	ffffe097          	auipc	ra,0xffffe
    8000535e:	2e2080e7          	jalr	738(ra) # 8000363c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005362:	00092703          	lw	a4,0(s2)
    80005366:	409c                	lw	a5,0(s1)
    80005368:	04f71d63          	bne	a4,a5,800053c2 <sys_link+0x100>
    8000536c:	40d0                	lw	a2,4(s1)
    8000536e:	fd040593          	addi	a1,s0,-48
    80005372:	854a                	mv	a0,s2
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	9bc080e7          	jalr	-1604(ra) # 80003d30 <dirlink>
    8000537c:	04054363          	bltz	a0,800053c2 <sys_link+0x100>
  iunlockput(dp);
    80005380:	854a                	mv	a0,s2
    80005382:	ffffe097          	auipc	ra,0xffffe
    80005386:	51c080e7          	jalr	1308(ra) # 8000389e <iunlockput>
  iput(ip);
    8000538a:	8526                	mv	a0,s1
    8000538c:	ffffe097          	auipc	ra,0xffffe
    80005390:	46a080e7          	jalr	1130(ra) # 800037f6 <iput>
  end_op();
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	cea080e7          	jalr	-790(ra) # 8000407e <end_op>
  return 0;
    8000539c:	4781                	li	a5,0
    8000539e:	a085                	j	800053fe <sys_link+0x13c>
    end_op();
    800053a0:	fffff097          	auipc	ra,0xfffff
    800053a4:	cde080e7          	jalr	-802(ra) # 8000407e <end_op>
    return -1;
    800053a8:	57fd                	li	a5,-1
    800053aa:	a891                	j	800053fe <sys_link+0x13c>
    iunlockput(ip);
    800053ac:	8526                	mv	a0,s1
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	4f0080e7          	jalr	1264(ra) # 8000389e <iunlockput>
    end_op();
    800053b6:	fffff097          	auipc	ra,0xfffff
    800053ba:	cc8080e7          	jalr	-824(ra) # 8000407e <end_op>
    return -1;
    800053be:	57fd                	li	a5,-1
    800053c0:	a83d                	j	800053fe <sys_link+0x13c>
    iunlockput(dp);
    800053c2:	854a                	mv	a0,s2
    800053c4:	ffffe097          	auipc	ra,0xffffe
    800053c8:	4da080e7          	jalr	1242(ra) # 8000389e <iunlockput>
  ilock(ip);
    800053cc:	8526                	mv	a0,s1
    800053ce:	ffffe097          	auipc	ra,0xffffe
    800053d2:	26e080e7          	jalr	622(ra) # 8000363c <ilock>
  ip->nlink--;
    800053d6:	04a4d783          	lhu	a5,74(s1)
    800053da:	37fd                	addiw	a5,a5,-1
    800053dc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053e0:	8526                	mv	a0,s1
    800053e2:	ffffe097          	auipc	ra,0xffffe
    800053e6:	190080e7          	jalr	400(ra) # 80003572 <iupdate>
  iunlockput(ip);
    800053ea:	8526                	mv	a0,s1
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	4b2080e7          	jalr	1202(ra) # 8000389e <iunlockput>
  end_op();
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	c8a080e7          	jalr	-886(ra) # 8000407e <end_op>
  return -1;
    800053fc:	57fd                	li	a5,-1
}
    800053fe:	853e                	mv	a0,a5
    80005400:	70b2                	ld	ra,296(sp)
    80005402:	7412                	ld	s0,288(sp)
    80005404:	64f2                	ld	s1,280(sp)
    80005406:	6952                	ld	s2,272(sp)
    80005408:	6155                	addi	sp,sp,304
    8000540a:	8082                	ret

000000008000540c <sys_unlink>:
{
    8000540c:	7151                	addi	sp,sp,-240
    8000540e:	f586                	sd	ra,232(sp)
    80005410:	f1a2                	sd	s0,224(sp)
    80005412:	eda6                	sd	s1,216(sp)
    80005414:	e9ca                	sd	s2,208(sp)
    80005416:	e5ce                	sd	s3,200(sp)
    80005418:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000541a:	08000613          	li	a2,128
    8000541e:	f3040593          	addi	a1,s0,-208
    80005422:	4501                	li	a0,0
    80005424:	ffffd097          	auipc	ra,0xffffd
    80005428:	6ec080e7          	jalr	1772(ra) # 80002b10 <argstr>
    8000542c:	18054163          	bltz	a0,800055ae <sys_unlink+0x1a2>
  begin_op();
    80005430:	fffff097          	auipc	ra,0xfffff
    80005434:	bce080e7          	jalr	-1074(ra) # 80003ffe <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005438:	fb040593          	addi	a1,s0,-80
    8000543c:	f3040513          	addi	a0,s0,-208
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	9c0080e7          	jalr	-1600(ra) # 80003e00 <nameiparent>
    80005448:	84aa                	mv	s1,a0
    8000544a:	c979                	beqz	a0,80005520 <sys_unlink+0x114>
  ilock(dp);
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	1f0080e7          	jalr	496(ra) # 8000363c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005454:	00003597          	auipc	a1,0x3
    80005458:	2c458593          	addi	a1,a1,708 # 80008718 <syscalls+0x2a0>
    8000545c:	fb040513          	addi	a0,s0,-80
    80005460:	ffffe097          	auipc	ra,0xffffe
    80005464:	6a6080e7          	jalr	1702(ra) # 80003b06 <namecmp>
    80005468:	14050a63          	beqz	a0,800055bc <sys_unlink+0x1b0>
    8000546c:	00003597          	auipc	a1,0x3
    80005470:	2b458593          	addi	a1,a1,692 # 80008720 <syscalls+0x2a8>
    80005474:	fb040513          	addi	a0,s0,-80
    80005478:	ffffe097          	auipc	ra,0xffffe
    8000547c:	68e080e7          	jalr	1678(ra) # 80003b06 <namecmp>
    80005480:	12050e63          	beqz	a0,800055bc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005484:	f2c40613          	addi	a2,s0,-212
    80005488:	fb040593          	addi	a1,s0,-80
    8000548c:	8526                	mv	a0,s1
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	692080e7          	jalr	1682(ra) # 80003b20 <dirlookup>
    80005496:	892a                	mv	s2,a0
    80005498:	12050263          	beqz	a0,800055bc <sys_unlink+0x1b0>
  ilock(ip);
    8000549c:	ffffe097          	auipc	ra,0xffffe
    800054a0:	1a0080e7          	jalr	416(ra) # 8000363c <ilock>
  if(ip->nlink < 1)
    800054a4:	04a91783          	lh	a5,74(s2)
    800054a8:	08f05263          	blez	a5,8000552c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054ac:	04491703          	lh	a4,68(s2)
    800054b0:	4785                	li	a5,1
    800054b2:	08f70563          	beq	a4,a5,8000553c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054b6:	4641                	li	a2,16
    800054b8:	4581                	li	a1,0
    800054ba:	fc040513          	addi	a0,s0,-64
    800054be:	ffffc097          	auipc	ra,0xffffc
    800054c2:	814080e7          	jalr	-2028(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054c6:	4741                	li	a4,16
    800054c8:	f2c42683          	lw	a3,-212(s0)
    800054cc:	fc040613          	addi	a2,s0,-64
    800054d0:	4581                	li	a1,0
    800054d2:	8526                	mv	a0,s1
    800054d4:	ffffe097          	auipc	ra,0xffffe
    800054d8:	514080e7          	jalr	1300(ra) # 800039e8 <writei>
    800054dc:	47c1                	li	a5,16
    800054de:	0af51563          	bne	a0,a5,80005588 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054e2:	04491703          	lh	a4,68(s2)
    800054e6:	4785                	li	a5,1
    800054e8:	0af70863          	beq	a4,a5,80005598 <sys_unlink+0x18c>
  iunlockput(dp);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	3b0080e7          	jalr	944(ra) # 8000389e <iunlockput>
  ip->nlink--;
    800054f6:	04a95783          	lhu	a5,74(s2)
    800054fa:	37fd                	addiw	a5,a5,-1
    800054fc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005500:	854a                	mv	a0,s2
    80005502:	ffffe097          	auipc	ra,0xffffe
    80005506:	070080e7          	jalr	112(ra) # 80003572 <iupdate>
  iunlockput(ip);
    8000550a:	854a                	mv	a0,s2
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	392080e7          	jalr	914(ra) # 8000389e <iunlockput>
  end_op();
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	b6a080e7          	jalr	-1174(ra) # 8000407e <end_op>
  return 0;
    8000551c:	4501                	li	a0,0
    8000551e:	a84d                	j	800055d0 <sys_unlink+0x1c4>
    end_op();
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	b5e080e7          	jalr	-1186(ra) # 8000407e <end_op>
    return -1;
    80005528:	557d                	li	a0,-1
    8000552a:	a05d                	j	800055d0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000552c:	00003517          	auipc	a0,0x3
    80005530:	1fc50513          	addi	a0,a0,508 # 80008728 <syscalls+0x2b0>
    80005534:	ffffb097          	auipc	ra,0xffffb
    80005538:	00a080e7          	jalr	10(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000553c:	04c92703          	lw	a4,76(s2)
    80005540:	02000793          	li	a5,32
    80005544:	f6e7f9e3          	bgeu	a5,a4,800054b6 <sys_unlink+0xaa>
    80005548:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000554c:	4741                	li	a4,16
    8000554e:	86ce                	mv	a3,s3
    80005550:	f1840613          	addi	a2,s0,-232
    80005554:	4581                	li	a1,0
    80005556:	854a                	mv	a0,s2
    80005558:	ffffe097          	auipc	ra,0xffffe
    8000555c:	398080e7          	jalr	920(ra) # 800038f0 <readi>
    80005560:	47c1                	li	a5,16
    80005562:	00f51b63          	bne	a0,a5,80005578 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005566:	f1845783          	lhu	a5,-232(s0)
    8000556a:	e7a1                	bnez	a5,800055b2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000556c:	29c1                	addiw	s3,s3,16
    8000556e:	04c92783          	lw	a5,76(s2)
    80005572:	fcf9ede3          	bltu	s3,a5,8000554c <sys_unlink+0x140>
    80005576:	b781                	j	800054b6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005578:	00003517          	auipc	a0,0x3
    8000557c:	1c850513          	addi	a0,a0,456 # 80008740 <syscalls+0x2c8>
    80005580:	ffffb097          	auipc	ra,0xffffb
    80005584:	fbe080e7          	jalr	-66(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005588:	00003517          	auipc	a0,0x3
    8000558c:	1d050513          	addi	a0,a0,464 # 80008758 <syscalls+0x2e0>
    80005590:	ffffb097          	auipc	ra,0xffffb
    80005594:	fae080e7          	jalr	-82(ra) # 8000053e <panic>
    dp->nlink--;
    80005598:	04a4d783          	lhu	a5,74(s1)
    8000559c:	37fd                	addiw	a5,a5,-1
    8000559e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055a2:	8526                	mv	a0,s1
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	fce080e7          	jalr	-50(ra) # 80003572 <iupdate>
    800055ac:	b781                	j	800054ec <sys_unlink+0xe0>
    return -1;
    800055ae:	557d                	li	a0,-1
    800055b0:	a005                	j	800055d0 <sys_unlink+0x1c4>
    iunlockput(ip);
    800055b2:	854a                	mv	a0,s2
    800055b4:	ffffe097          	auipc	ra,0xffffe
    800055b8:	2ea080e7          	jalr	746(ra) # 8000389e <iunlockput>
  iunlockput(dp);
    800055bc:	8526                	mv	a0,s1
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	2e0080e7          	jalr	736(ra) # 8000389e <iunlockput>
  end_op();
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	ab8080e7          	jalr	-1352(ra) # 8000407e <end_op>
  return -1;
    800055ce:	557d                	li	a0,-1
}
    800055d0:	70ae                	ld	ra,232(sp)
    800055d2:	740e                	ld	s0,224(sp)
    800055d4:	64ee                	ld	s1,216(sp)
    800055d6:	694e                	ld	s2,208(sp)
    800055d8:	69ae                	ld	s3,200(sp)
    800055da:	616d                	addi	sp,sp,240
    800055dc:	8082                	ret

00000000800055de <sys_open>:

uint64
sys_open(void)
{
    800055de:	7131                	addi	sp,sp,-192
    800055e0:	fd06                	sd	ra,184(sp)
    800055e2:	f922                	sd	s0,176(sp)
    800055e4:	f526                	sd	s1,168(sp)
    800055e6:	f14a                	sd	s2,160(sp)
    800055e8:	ed4e                	sd	s3,152(sp)
    800055ea:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800055ec:	f4c40593          	addi	a1,s0,-180
    800055f0:	4505                	li	a0,1
    800055f2:	ffffd097          	auipc	ra,0xffffd
    800055f6:	4de080e7          	jalr	1246(ra) # 80002ad0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055fa:	08000613          	li	a2,128
    800055fe:	f5040593          	addi	a1,s0,-176
    80005602:	4501                	li	a0,0
    80005604:	ffffd097          	auipc	ra,0xffffd
    80005608:	50c080e7          	jalr	1292(ra) # 80002b10 <argstr>
    8000560c:	87aa                	mv	a5,a0
    return -1;
    8000560e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005610:	0a07c963          	bltz	a5,800056c2 <sys_open+0xe4>

  begin_op();
    80005614:	fffff097          	auipc	ra,0xfffff
    80005618:	9ea080e7          	jalr	-1558(ra) # 80003ffe <begin_op>

  if(omode & O_CREATE){
    8000561c:	f4c42783          	lw	a5,-180(s0)
    80005620:	2007f793          	andi	a5,a5,512
    80005624:	cfc5                	beqz	a5,800056dc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005626:	4681                	li	a3,0
    80005628:	4601                	li	a2,0
    8000562a:	4589                	li	a1,2
    8000562c:	f5040513          	addi	a0,s0,-176
    80005630:	00000097          	auipc	ra,0x0
    80005634:	976080e7          	jalr	-1674(ra) # 80004fa6 <create>
    80005638:	84aa                	mv	s1,a0
    if(ip == 0){
    8000563a:	c959                	beqz	a0,800056d0 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000563c:	04449703          	lh	a4,68(s1)
    80005640:	478d                	li	a5,3
    80005642:	00f71763          	bne	a4,a5,80005650 <sys_open+0x72>
    80005646:	0464d703          	lhu	a4,70(s1)
    8000564a:	47a5                	li	a5,9
    8000564c:	0ce7ed63          	bltu	a5,a4,80005726 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	dbe080e7          	jalr	-578(ra) # 8000440e <filealloc>
    80005658:	89aa                	mv	s3,a0
    8000565a:	10050363          	beqz	a0,80005760 <sys_open+0x182>
    8000565e:	00000097          	auipc	ra,0x0
    80005662:	906080e7          	jalr	-1786(ra) # 80004f64 <fdalloc>
    80005666:	892a                	mv	s2,a0
    80005668:	0e054763          	bltz	a0,80005756 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000566c:	04449703          	lh	a4,68(s1)
    80005670:	478d                	li	a5,3
    80005672:	0cf70563          	beq	a4,a5,8000573c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005676:	4789                	li	a5,2
    80005678:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000567c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005680:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005684:	f4c42783          	lw	a5,-180(s0)
    80005688:	0017c713          	xori	a4,a5,1
    8000568c:	8b05                	andi	a4,a4,1
    8000568e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005692:	0037f713          	andi	a4,a5,3
    80005696:	00e03733          	snez	a4,a4
    8000569a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000569e:	4007f793          	andi	a5,a5,1024
    800056a2:	c791                	beqz	a5,800056ae <sys_open+0xd0>
    800056a4:	04449703          	lh	a4,68(s1)
    800056a8:	4789                	li	a5,2
    800056aa:	0af70063          	beq	a4,a5,8000574a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800056ae:	8526                	mv	a0,s1
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	04e080e7          	jalr	78(ra) # 800036fe <iunlock>
  end_op();
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	9c6080e7          	jalr	-1594(ra) # 8000407e <end_op>

  return fd;
    800056c0:	854a                	mv	a0,s2
}
    800056c2:	70ea                	ld	ra,184(sp)
    800056c4:	744a                	ld	s0,176(sp)
    800056c6:	74aa                	ld	s1,168(sp)
    800056c8:	790a                	ld	s2,160(sp)
    800056ca:	69ea                	ld	s3,152(sp)
    800056cc:	6129                	addi	sp,sp,192
    800056ce:	8082                	ret
      end_op();
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	9ae080e7          	jalr	-1618(ra) # 8000407e <end_op>
      return -1;
    800056d8:	557d                	li	a0,-1
    800056da:	b7e5                	j	800056c2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800056dc:	f5040513          	addi	a0,s0,-176
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	702080e7          	jalr	1794(ra) # 80003de2 <namei>
    800056e8:	84aa                	mv	s1,a0
    800056ea:	c905                	beqz	a0,8000571a <sys_open+0x13c>
    ilock(ip);
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	f50080e7          	jalr	-176(ra) # 8000363c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056f4:	04449703          	lh	a4,68(s1)
    800056f8:	4785                	li	a5,1
    800056fa:	f4f711e3          	bne	a4,a5,8000563c <sys_open+0x5e>
    800056fe:	f4c42783          	lw	a5,-180(s0)
    80005702:	d7b9                	beqz	a5,80005650 <sys_open+0x72>
      iunlockput(ip);
    80005704:	8526                	mv	a0,s1
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	198080e7          	jalr	408(ra) # 8000389e <iunlockput>
      end_op();
    8000570e:	fffff097          	auipc	ra,0xfffff
    80005712:	970080e7          	jalr	-1680(ra) # 8000407e <end_op>
      return -1;
    80005716:	557d                	li	a0,-1
    80005718:	b76d                	j	800056c2 <sys_open+0xe4>
      end_op();
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	964080e7          	jalr	-1692(ra) # 8000407e <end_op>
      return -1;
    80005722:	557d                	li	a0,-1
    80005724:	bf79                	j	800056c2 <sys_open+0xe4>
    iunlockput(ip);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	176080e7          	jalr	374(ra) # 8000389e <iunlockput>
    end_op();
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	94e080e7          	jalr	-1714(ra) # 8000407e <end_op>
    return -1;
    80005738:	557d                	li	a0,-1
    8000573a:	b761                	j	800056c2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000573c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005740:	04649783          	lh	a5,70(s1)
    80005744:	02f99223          	sh	a5,36(s3)
    80005748:	bf25                	j	80005680 <sys_open+0xa2>
    itrunc(ip);
    8000574a:	8526                	mv	a0,s1
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	ffe080e7          	jalr	-2(ra) # 8000374a <itrunc>
    80005754:	bfa9                	j	800056ae <sys_open+0xd0>
      fileclose(f);
    80005756:	854e                	mv	a0,s3
    80005758:	fffff097          	auipc	ra,0xfffff
    8000575c:	d72080e7          	jalr	-654(ra) # 800044ca <fileclose>
    iunlockput(ip);
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	13c080e7          	jalr	316(ra) # 8000389e <iunlockput>
    end_op();
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	914080e7          	jalr	-1772(ra) # 8000407e <end_op>
    return -1;
    80005772:	557d                	li	a0,-1
    80005774:	b7b9                	j	800056c2 <sys_open+0xe4>

0000000080005776 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005776:	7175                	addi	sp,sp,-144
    80005778:	e506                	sd	ra,136(sp)
    8000577a:	e122                	sd	s0,128(sp)
    8000577c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	880080e7          	jalr	-1920(ra) # 80003ffe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005786:	08000613          	li	a2,128
    8000578a:	f7040593          	addi	a1,s0,-144
    8000578e:	4501                	li	a0,0
    80005790:	ffffd097          	auipc	ra,0xffffd
    80005794:	380080e7          	jalr	896(ra) # 80002b10 <argstr>
    80005798:	02054963          	bltz	a0,800057ca <sys_mkdir+0x54>
    8000579c:	4681                	li	a3,0
    8000579e:	4601                	li	a2,0
    800057a0:	4585                	li	a1,1
    800057a2:	f7040513          	addi	a0,s0,-144
    800057a6:	00000097          	auipc	ra,0x0
    800057aa:	800080e7          	jalr	-2048(ra) # 80004fa6 <create>
    800057ae:	cd11                	beqz	a0,800057ca <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	0ee080e7          	jalr	238(ra) # 8000389e <iunlockput>
  end_op();
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	8c6080e7          	jalr	-1850(ra) # 8000407e <end_op>
  return 0;
    800057c0:	4501                	li	a0,0
}
    800057c2:	60aa                	ld	ra,136(sp)
    800057c4:	640a                	ld	s0,128(sp)
    800057c6:	6149                	addi	sp,sp,144
    800057c8:	8082                	ret
    end_op();
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	8b4080e7          	jalr	-1868(ra) # 8000407e <end_op>
    return -1;
    800057d2:	557d                	li	a0,-1
    800057d4:	b7fd                	j	800057c2 <sys_mkdir+0x4c>

00000000800057d6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057d6:	7135                	addi	sp,sp,-160
    800057d8:	ed06                	sd	ra,152(sp)
    800057da:	e922                	sd	s0,144(sp)
    800057dc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	820080e7          	jalr	-2016(ra) # 80003ffe <begin_op>
  argint(1, &major);
    800057e6:	f6c40593          	addi	a1,s0,-148
    800057ea:	4505                	li	a0,1
    800057ec:	ffffd097          	auipc	ra,0xffffd
    800057f0:	2e4080e7          	jalr	740(ra) # 80002ad0 <argint>
  argint(2, &minor);
    800057f4:	f6840593          	addi	a1,s0,-152
    800057f8:	4509                	li	a0,2
    800057fa:	ffffd097          	auipc	ra,0xffffd
    800057fe:	2d6080e7          	jalr	726(ra) # 80002ad0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005802:	08000613          	li	a2,128
    80005806:	f7040593          	addi	a1,s0,-144
    8000580a:	4501                	li	a0,0
    8000580c:	ffffd097          	auipc	ra,0xffffd
    80005810:	304080e7          	jalr	772(ra) # 80002b10 <argstr>
    80005814:	02054b63          	bltz	a0,8000584a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005818:	f6841683          	lh	a3,-152(s0)
    8000581c:	f6c41603          	lh	a2,-148(s0)
    80005820:	458d                	li	a1,3
    80005822:	f7040513          	addi	a0,s0,-144
    80005826:	fffff097          	auipc	ra,0xfffff
    8000582a:	780080e7          	jalr	1920(ra) # 80004fa6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000582e:	cd11                	beqz	a0,8000584a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005830:	ffffe097          	auipc	ra,0xffffe
    80005834:	06e080e7          	jalr	110(ra) # 8000389e <iunlockput>
  end_op();
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	846080e7          	jalr	-1978(ra) # 8000407e <end_op>
  return 0;
    80005840:	4501                	li	a0,0
}
    80005842:	60ea                	ld	ra,152(sp)
    80005844:	644a                	ld	s0,144(sp)
    80005846:	610d                	addi	sp,sp,160
    80005848:	8082                	ret
    end_op();
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	834080e7          	jalr	-1996(ra) # 8000407e <end_op>
    return -1;
    80005852:	557d                	li	a0,-1
    80005854:	b7fd                	j	80005842 <sys_mknod+0x6c>

0000000080005856 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005856:	7135                	addi	sp,sp,-160
    80005858:	ed06                	sd	ra,152(sp)
    8000585a:	e922                	sd	s0,144(sp)
    8000585c:	e526                	sd	s1,136(sp)
    8000585e:	e14a                	sd	s2,128(sp)
    80005860:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005862:	ffffc097          	auipc	ra,0xffffc
    80005866:	15a080e7          	jalr	346(ra) # 800019bc <myproc>
    8000586a:	892a                	mv	s2,a0
  
  begin_op();
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	792080e7          	jalr	1938(ra) # 80003ffe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005874:	08000613          	li	a2,128
    80005878:	f6040593          	addi	a1,s0,-160
    8000587c:	4501                	li	a0,0
    8000587e:	ffffd097          	auipc	ra,0xffffd
    80005882:	292080e7          	jalr	658(ra) # 80002b10 <argstr>
    80005886:	04054b63          	bltz	a0,800058dc <sys_chdir+0x86>
    8000588a:	f6040513          	addi	a0,s0,-160
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	554080e7          	jalr	1364(ra) # 80003de2 <namei>
    80005896:	84aa                	mv	s1,a0
    80005898:	c131                	beqz	a0,800058dc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	da2080e7          	jalr	-606(ra) # 8000363c <ilock>
  if(ip->type != T_DIR){
    800058a2:	04449703          	lh	a4,68(s1)
    800058a6:	4785                	li	a5,1
    800058a8:	04f71063          	bne	a4,a5,800058e8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058ac:	8526                	mv	a0,s1
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	e50080e7          	jalr	-432(ra) # 800036fe <iunlock>
  iput(p->cwd);
    800058b6:	15093503          	ld	a0,336(s2)
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	f3c080e7          	jalr	-196(ra) # 800037f6 <iput>
  end_op();
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	7bc080e7          	jalr	1980(ra) # 8000407e <end_op>
  p->cwd = ip;
    800058ca:	14993823          	sd	s1,336(s2)
  return 0;
    800058ce:	4501                	li	a0,0
}
    800058d0:	60ea                	ld	ra,152(sp)
    800058d2:	644a                	ld	s0,144(sp)
    800058d4:	64aa                	ld	s1,136(sp)
    800058d6:	690a                	ld	s2,128(sp)
    800058d8:	610d                	addi	sp,sp,160
    800058da:	8082                	ret
    end_op();
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	7a2080e7          	jalr	1954(ra) # 8000407e <end_op>
    return -1;
    800058e4:	557d                	li	a0,-1
    800058e6:	b7ed                	j	800058d0 <sys_chdir+0x7a>
    iunlockput(ip);
    800058e8:	8526                	mv	a0,s1
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	fb4080e7          	jalr	-76(ra) # 8000389e <iunlockput>
    end_op();
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	78c080e7          	jalr	1932(ra) # 8000407e <end_op>
    return -1;
    800058fa:	557d                	li	a0,-1
    800058fc:	bfd1                	j	800058d0 <sys_chdir+0x7a>

00000000800058fe <sys_exec>:

uint64
sys_exec(void)
{
    800058fe:	7145                	addi	sp,sp,-464
    80005900:	e786                	sd	ra,456(sp)
    80005902:	e3a2                	sd	s0,448(sp)
    80005904:	ff26                	sd	s1,440(sp)
    80005906:	fb4a                	sd	s2,432(sp)
    80005908:	f74e                	sd	s3,424(sp)
    8000590a:	f352                	sd	s4,416(sp)
    8000590c:	ef56                	sd	s5,408(sp)
    8000590e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005910:	e3840593          	addi	a1,s0,-456
    80005914:	4505                	li	a0,1
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	1da080e7          	jalr	474(ra) # 80002af0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000591e:	08000613          	li	a2,128
    80005922:	f4040593          	addi	a1,s0,-192
    80005926:	4501                	li	a0,0
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	1e8080e7          	jalr	488(ra) # 80002b10 <argstr>
    80005930:	87aa                	mv	a5,a0
    return -1;
    80005932:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005934:	0c07c263          	bltz	a5,800059f8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005938:	10000613          	li	a2,256
    8000593c:	4581                	li	a1,0
    8000593e:	e4040513          	addi	a0,s0,-448
    80005942:	ffffb097          	auipc	ra,0xffffb
    80005946:	390080e7          	jalr	912(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000594a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000594e:	89a6                	mv	s3,s1
    80005950:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005952:	02000a13          	li	s4,32
    80005956:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000595a:	00391793          	slli	a5,s2,0x3
    8000595e:	e3040593          	addi	a1,s0,-464
    80005962:	e3843503          	ld	a0,-456(s0)
    80005966:	953e                	add	a0,a0,a5
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	0ca080e7          	jalr	202(ra) # 80002a32 <fetchaddr>
    80005970:	02054a63          	bltz	a0,800059a4 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005974:	e3043783          	ld	a5,-464(s0)
    80005978:	c3b9                	beqz	a5,800059be <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000597a:	ffffb097          	auipc	ra,0xffffb
    8000597e:	16c080e7          	jalr	364(ra) # 80000ae6 <kalloc>
    80005982:	85aa                	mv	a1,a0
    80005984:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005988:	cd11                	beqz	a0,800059a4 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000598a:	6605                	lui	a2,0x1
    8000598c:	e3043503          	ld	a0,-464(s0)
    80005990:	ffffd097          	auipc	ra,0xffffd
    80005994:	0f4080e7          	jalr	244(ra) # 80002a84 <fetchstr>
    80005998:	00054663          	bltz	a0,800059a4 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000599c:	0905                	addi	s2,s2,1
    8000599e:	09a1                	addi	s3,s3,8
    800059a0:	fb491be3          	bne	s2,s4,80005956 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059a4:	10048913          	addi	s2,s1,256
    800059a8:	6088                	ld	a0,0(s1)
    800059aa:	c531                	beqz	a0,800059f6 <sys_exec+0xf8>
    kfree(argv[i]);
    800059ac:	ffffb097          	auipc	ra,0xffffb
    800059b0:	03e080e7          	jalr	62(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059b4:	04a1                	addi	s1,s1,8
    800059b6:	ff2499e3          	bne	s1,s2,800059a8 <sys_exec+0xaa>
  return -1;
    800059ba:	557d                	li	a0,-1
    800059bc:	a835                	j	800059f8 <sys_exec+0xfa>
      argv[i] = 0;
    800059be:	0a8e                	slli	s5,s5,0x3
    800059c0:	fc040793          	addi	a5,s0,-64
    800059c4:	9abe                	add	s5,s5,a5
    800059c6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800059ca:	e4040593          	addi	a1,s0,-448
    800059ce:	f4040513          	addi	a0,s0,-192
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	172080e7          	jalr	370(ra) # 80004b44 <exec>
    800059da:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059dc:	10048993          	addi	s3,s1,256
    800059e0:	6088                	ld	a0,0(s1)
    800059e2:	c901                	beqz	a0,800059f2 <sys_exec+0xf4>
    kfree(argv[i]);
    800059e4:	ffffb097          	auipc	ra,0xffffb
    800059e8:	006080e7          	jalr	6(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ec:	04a1                	addi	s1,s1,8
    800059ee:	ff3499e3          	bne	s1,s3,800059e0 <sys_exec+0xe2>
  return ret;
    800059f2:	854a                	mv	a0,s2
    800059f4:	a011                	j	800059f8 <sys_exec+0xfa>
  return -1;
    800059f6:	557d                	li	a0,-1
}
    800059f8:	60be                	ld	ra,456(sp)
    800059fa:	641e                	ld	s0,448(sp)
    800059fc:	74fa                	ld	s1,440(sp)
    800059fe:	795a                	ld	s2,432(sp)
    80005a00:	79ba                	ld	s3,424(sp)
    80005a02:	7a1a                	ld	s4,416(sp)
    80005a04:	6afa                	ld	s5,408(sp)
    80005a06:	6179                	addi	sp,sp,464
    80005a08:	8082                	ret

0000000080005a0a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a0a:	7139                	addi	sp,sp,-64
    80005a0c:	fc06                	sd	ra,56(sp)
    80005a0e:	f822                	sd	s0,48(sp)
    80005a10:	f426                	sd	s1,40(sp)
    80005a12:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a14:	ffffc097          	auipc	ra,0xffffc
    80005a18:	fa8080e7          	jalr	-88(ra) # 800019bc <myproc>
    80005a1c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a1e:	fd840593          	addi	a1,s0,-40
    80005a22:	4501                	li	a0,0
    80005a24:	ffffd097          	auipc	ra,0xffffd
    80005a28:	0cc080e7          	jalr	204(ra) # 80002af0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a2c:	fc840593          	addi	a1,s0,-56
    80005a30:	fd040513          	addi	a0,s0,-48
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	dc6080e7          	jalr	-570(ra) # 800047fa <pipealloc>
    return -1;
    80005a3c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a3e:	0c054463          	bltz	a0,80005b06 <sys_pipe+0xfc>
  fd0 = -1;
    80005a42:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a46:	fd043503          	ld	a0,-48(s0)
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	51a080e7          	jalr	1306(ra) # 80004f64 <fdalloc>
    80005a52:	fca42223          	sw	a0,-60(s0)
    80005a56:	08054b63          	bltz	a0,80005aec <sys_pipe+0xe2>
    80005a5a:	fc843503          	ld	a0,-56(s0)
    80005a5e:	fffff097          	auipc	ra,0xfffff
    80005a62:	506080e7          	jalr	1286(ra) # 80004f64 <fdalloc>
    80005a66:	fca42023          	sw	a0,-64(s0)
    80005a6a:	06054863          	bltz	a0,80005ada <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a6e:	4691                	li	a3,4
    80005a70:	fc440613          	addi	a2,s0,-60
    80005a74:	fd843583          	ld	a1,-40(s0)
    80005a78:	68a8                	ld	a0,80(s1)
    80005a7a:	ffffc097          	auipc	ra,0xffffc
    80005a7e:	bfe080e7          	jalr	-1026(ra) # 80001678 <copyout>
    80005a82:	02054063          	bltz	a0,80005aa2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a86:	4691                	li	a3,4
    80005a88:	fc040613          	addi	a2,s0,-64
    80005a8c:	fd843583          	ld	a1,-40(s0)
    80005a90:	0591                	addi	a1,a1,4
    80005a92:	68a8                	ld	a0,80(s1)
    80005a94:	ffffc097          	auipc	ra,0xffffc
    80005a98:	be4080e7          	jalr	-1052(ra) # 80001678 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a9c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a9e:	06055463          	bgez	a0,80005b06 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005aa2:	fc442783          	lw	a5,-60(s0)
    80005aa6:	07e9                	addi	a5,a5,26
    80005aa8:	078e                	slli	a5,a5,0x3
    80005aaa:	97a6                	add	a5,a5,s1
    80005aac:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ab0:	fc042503          	lw	a0,-64(s0)
    80005ab4:	0569                	addi	a0,a0,26
    80005ab6:	050e                	slli	a0,a0,0x3
    80005ab8:	94aa                	add	s1,s1,a0
    80005aba:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005abe:	fd043503          	ld	a0,-48(s0)
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	a08080e7          	jalr	-1528(ra) # 800044ca <fileclose>
    fileclose(wf);
    80005aca:	fc843503          	ld	a0,-56(s0)
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	9fc080e7          	jalr	-1540(ra) # 800044ca <fileclose>
    return -1;
    80005ad6:	57fd                	li	a5,-1
    80005ad8:	a03d                	j	80005b06 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ada:	fc442783          	lw	a5,-60(s0)
    80005ade:	0007c763          	bltz	a5,80005aec <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ae2:	07e9                	addi	a5,a5,26
    80005ae4:	078e                	slli	a5,a5,0x3
    80005ae6:	94be                	add	s1,s1,a5
    80005ae8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005aec:	fd043503          	ld	a0,-48(s0)
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	9da080e7          	jalr	-1574(ra) # 800044ca <fileclose>
    fileclose(wf);
    80005af8:	fc843503          	ld	a0,-56(s0)
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	9ce080e7          	jalr	-1586(ra) # 800044ca <fileclose>
    return -1;
    80005b04:	57fd                	li	a5,-1
}
    80005b06:	853e                	mv	a0,a5
    80005b08:	70e2                	ld	ra,56(sp)
    80005b0a:	7442                	ld	s0,48(sp)
    80005b0c:	74a2                	ld	s1,40(sp)
    80005b0e:	6121                	addi	sp,sp,64
    80005b10:	8082                	ret
	...

0000000080005b20 <kernelvec>:
    80005b20:	7111                	addi	sp,sp,-256
    80005b22:	e006                	sd	ra,0(sp)
    80005b24:	e40a                	sd	sp,8(sp)
    80005b26:	e80e                	sd	gp,16(sp)
    80005b28:	ec12                	sd	tp,24(sp)
    80005b2a:	f016                	sd	t0,32(sp)
    80005b2c:	f41a                	sd	t1,40(sp)
    80005b2e:	f81e                	sd	t2,48(sp)
    80005b30:	fc22                	sd	s0,56(sp)
    80005b32:	e0a6                	sd	s1,64(sp)
    80005b34:	e4aa                	sd	a0,72(sp)
    80005b36:	e8ae                	sd	a1,80(sp)
    80005b38:	ecb2                	sd	a2,88(sp)
    80005b3a:	f0b6                	sd	a3,96(sp)
    80005b3c:	f4ba                	sd	a4,104(sp)
    80005b3e:	f8be                	sd	a5,112(sp)
    80005b40:	fcc2                	sd	a6,120(sp)
    80005b42:	e146                	sd	a7,128(sp)
    80005b44:	e54a                	sd	s2,136(sp)
    80005b46:	e94e                	sd	s3,144(sp)
    80005b48:	ed52                	sd	s4,152(sp)
    80005b4a:	f156                	sd	s5,160(sp)
    80005b4c:	f55a                	sd	s6,168(sp)
    80005b4e:	f95e                	sd	s7,176(sp)
    80005b50:	fd62                	sd	s8,184(sp)
    80005b52:	e1e6                	sd	s9,192(sp)
    80005b54:	e5ea                	sd	s10,200(sp)
    80005b56:	e9ee                	sd	s11,208(sp)
    80005b58:	edf2                	sd	t3,216(sp)
    80005b5a:	f1f6                	sd	t4,224(sp)
    80005b5c:	f5fa                	sd	t5,232(sp)
    80005b5e:	f9fe                	sd	t6,240(sp)
    80005b60:	d9ffc0ef          	jal	ra,800028fe <kerneltrap>
    80005b64:	6082                	ld	ra,0(sp)
    80005b66:	6122                	ld	sp,8(sp)
    80005b68:	61c2                	ld	gp,16(sp)
    80005b6a:	7282                	ld	t0,32(sp)
    80005b6c:	7322                	ld	t1,40(sp)
    80005b6e:	73c2                	ld	t2,48(sp)
    80005b70:	7462                	ld	s0,56(sp)
    80005b72:	6486                	ld	s1,64(sp)
    80005b74:	6526                	ld	a0,72(sp)
    80005b76:	65c6                	ld	a1,80(sp)
    80005b78:	6666                	ld	a2,88(sp)
    80005b7a:	7686                	ld	a3,96(sp)
    80005b7c:	7726                	ld	a4,104(sp)
    80005b7e:	77c6                	ld	a5,112(sp)
    80005b80:	7866                	ld	a6,120(sp)
    80005b82:	688a                	ld	a7,128(sp)
    80005b84:	692a                	ld	s2,136(sp)
    80005b86:	69ca                	ld	s3,144(sp)
    80005b88:	6a6a                	ld	s4,152(sp)
    80005b8a:	7a8a                	ld	s5,160(sp)
    80005b8c:	7b2a                	ld	s6,168(sp)
    80005b8e:	7bca                	ld	s7,176(sp)
    80005b90:	7c6a                	ld	s8,184(sp)
    80005b92:	6c8e                	ld	s9,192(sp)
    80005b94:	6d2e                	ld	s10,200(sp)
    80005b96:	6dce                	ld	s11,208(sp)
    80005b98:	6e6e                	ld	t3,216(sp)
    80005b9a:	7e8e                	ld	t4,224(sp)
    80005b9c:	7f2e                	ld	t5,232(sp)
    80005b9e:	7fce                	ld	t6,240(sp)
    80005ba0:	6111                	addi	sp,sp,256
    80005ba2:	10200073          	sret
    80005ba6:	00000013          	nop
    80005baa:	00000013          	nop
    80005bae:	0001                	nop

0000000080005bb0 <timervec>:
    80005bb0:	34051573          	csrrw	a0,mscratch,a0
    80005bb4:	e10c                	sd	a1,0(a0)
    80005bb6:	e510                	sd	a2,8(a0)
    80005bb8:	e914                	sd	a3,16(a0)
    80005bba:	6d0c                	ld	a1,24(a0)
    80005bbc:	7110                	ld	a2,32(a0)
    80005bbe:	6194                	ld	a3,0(a1)
    80005bc0:	96b2                	add	a3,a3,a2
    80005bc2:	e194                	sd	a3,0(a1)
    80005bc4:	4589                	li	a1,2
    80005bc6:	14459073          	csrw	sip,a1
    80005bca:	6914                	ld	a3,16(a0)
    80005bcc:	6510                	ld	a2,8(a0)
    80005bce:	610c                	ld	a1,0(a0)
    80005bd0:	34051573          	csrrw	a0,mscratch,a0
    80005bd4:	30200073          	mret
	...

0000000080005bda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bda:	1141                	addi	sp,sp,-16
    80005bdc:	e422                	sd	s0,8(sp)
    80005bde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005be0:	0c0007b7          	lui	a5,0xc000
    80005be4:	4705                	li	a4,1
    80005be6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005be8:	c3d8                	sw	a4,4(a5)
}
    80005bea:	6422                	ld	s0,8(sp)
    80005bec:	0141                	addi	sp,sp,16
    80005bee:	8082                	ret

0000000080005bf0 <plicinithart>:

void
plicinithart(void)
{
    80005bf0:	1141                	addi	sp,sp,-16
    80005bf2:	e406                	sd	ra,8(sp)
    80005bf4:	e022                	sd	s0,0(sp)
    80005bf6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bf8:	ffffc097          	auipc	ra,0xffffc
    80005bfc:	d98080e7          	jalr	-616(ra) # 80001990 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c00:	0085171b          	slliw	a4,a0,0x8
    80005c04:	0c0027b7          	lui	a5,0xc002
    80005c08:	97ba                	add	a5,a5,a4
    80005c0a:	40200713          	li	a4,1026
    80005c0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c12:	00d5151b          	slliw	a0,a0,0xd
    80005c16:	0c2017b7          	lui	a5,0xc201
    80005c1a:	953e                	add	a0,a0,a5
    80005c1c:	00052023          	sw	zero,0(a0)
}
    80005c20:	60a2                	ld	ra,8(sp)
    80005c22:	6402                	ld	s0,0(sp)
    80005c24:	0141                	addi	sp,sp,16
    80005c26:	8082                	ret

0000000080005c28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c28:	1141                	addi	sp,sp,-16
    80005c2a:	e406                	sd	ra,8(sp)
    80005c2c:	e022                	sd	s0,0(sp)
    80005c2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c30:	ffffc097          	auipc	ra,0xffffc
    80005c34:	d60080e7          	jalr	-672(ra) # 80001990 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c38:	00d5179b          	slliw	a5,a0,0xd
    80005c3c:	0c201537          	lui	a0,0xc201
    80005c40:	953e                	add	a0,a0,a5
  return irq;
}
    80005c42:	4148                	lw	a0,4(a0)
    80005c44:	60a2                	ld	ra,8(sp)
    80005c46:	6402                	ld	s0,0(sp)
    80005c48:	0141                	addi	sp,sp,16
    80005c4a:	8082                	ret

0000000080005c4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c4c:	1101                	addi	sp,sp,-32
    80005c4e:	ec06                	sd	ra,24(sp)
    80005c50:	e822                	sd	s0,16(sp)
    80005c52:	e426                	sd	s1,8(sp)
    80005c54:	1000                	addi	s0,sp,32
    80005c56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	d38080e7          	jalr	-712(ra) # 80001990 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c60:	00d5151b          	slliw	a0,a0,0xd
    80005c64:	0c2017b7          	lui	a5,0xc201
    80005c68:	97aa                	add	a5,a5,a0
    80005c6a:	c3c4                	sw	s1,4(a5)
}
    80005c6c:	60e2                	ld	ra,24(sp)
    80005c6e:	6442                	ld	s0,16(sp)
    80005c70:	64a2                	ld	s1,8(sp)
    80005c72:	6105                	addi	sp,sp,32
    80005c74:	8082                	ret

0000000080005c76 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c76:	1141                	addi	sp,sp,-16
    80005c78:	e406                	sd	ra,8(sp)
    80005c7a:	e022                	sd	s0,0(sp)
    80005c7c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c7e:	479d                	li	a5,7
    80005c80:	04a7cc63          	blt	a5,a0,80005cd8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005c84:	0001c797          	auipc	a5,0x1c
    80005c88:	fac78793          	addi	a5,a5,-84 # 80021c30 <disk>
    80005c8c:	97aa                	add	a5,a5,a0
    80005c8e:	0187c783          	lbu	a5,24(a5)
    80005c92:	ebb9                	bnez	a5,80005ce8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c94:	00451613          	slli	a2,a0,0x4
    80005c98:	0001c797          	auipc	a5,0x1c
    80005c9c:	f9878793          	addi	a5,a5,-104 # 80021c30 <disk>
    80005ca0:	6394                	ld	a3,0(a5)
    80005ca2:	96b2                	add	a3,a3,a2
    80005ca4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005ca8:	6398                	ld	a4,0(a5)
    80005caa:	9732                	add	a4,a4,a2
    80005cac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005cb0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005cb4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005cb8:	953e                	add	a0,a0,a5
    80005cba:	4785                	li	a5,1
    80005cbc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005cc0:	0001c517          	auipc	a0,0x1c
    80005cc4:	f8850513          	addi	a0,a0,-120 # 80021c48 <disk+0x18>
    80005cc8:	ffffc097          	auipc	ra,0xffffc
    80005ccc:	400080e7          	jalr	1024(ra) # 800020c8 <wakeup>
}
    80005cd0:	60a2                	ld	ra,8(sp)
    80005cd2:	6402                	ld	s0,0(sp)
    80005cd4:	0141                	addi	sp,sp,16
    80005cd6:	8082                	ret
    panic("free_desc 1");
    80005cd8:	00003517          	auipc	a0,0x3
    80005cdc:	a9050513          	addi	a0,a0,-1392 # 80008768 <syscalls+0x2f0>
    80005ce0:	ffffb097          	auipc	ra,0xffffb
    80005ce4:	85e080e7          	jalr	-1954(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005ce8:	00003517          	auipc	a0,0x3
    80005cec:	a9050513          	addi	a0,a0,-1392 # 80008778 <syscalls+0x300>
    80005cf0:	ffffb097          	auipc	ra,0xffffb
    80005cf4:	84e080e7          	jalr	-1970(ra) # 8000053e <panic>

0000000080005cf8 <virtio_disk_init>:
{
    80005cf8:	1101                	addi	sp,sp,-32
    80005cfa:	ec06                	sd	ra,24(sp)
    80005cfc:	e822                	sd	s0,16(sp)
    80005cfe:	e426                	sd	s1,8(sp)
    80005d00:	e04a                	sd	s2,0(sp)
    80005d02:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d04:	00003597          	auipc	a1,0x3
    80005d08:	a8458593          	addi	a1,a1,-1404 # 80008788 <syscalls+0x310>
    80005d0c:	0001c517          	auipc	a0,0x1c
    80005d10:	04c50513          	addi	a0,a0,76 # 80021d58 <disk+0x128>
    80005d14:	ffffb097          	auipc	ra,0xffffb
    80005d18:	e32080e7          	jalr	-462(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d1c:	100017b7          	lui	a5,0x10001
    80005d20:	4398                	lw	a4,0(a5)
    80005d22:	2701                	sext.w	a4,a4
    80005d24:	747277b7          	lui	a5,0x74727
    80005d28:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d2c:	14f71c63          	bne	a4,a5,80005e84 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d30:	100017b7          	lui	a5,0x10001
    80005d34:	43dc                	lw	a5,4(a5)
    80005d36:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d38:	4709                	li	a4,2
    80005d3a:	14e79563          	bne	a5,a4,80005e84 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d3e:	100017b7          	lui	a5,0x10001
    80005d42:	479c                	lw	a5,8(a5)
    80005d44:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d46:	12e79f63          	bne	a5,a4,80005e84 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d4a:	100017b7          	lui	a5,0x10001
    80005d4e:	47d8                	lw	a4,12(a5)
    80005d50:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d52:	554d47b7          	lui	a5,0x554d4
    80005d56:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d5a:	12f71563          	bne	a4,a5,80005e84 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d5e:	100017b7          	lui	a5,0x10001
    80005d62:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d66:	4705                	li	a4,1
    80005d68:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d6a:	470d                	li	a4,3
    80005d6c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d6e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d70:	c7ffe737          	lui	a4,0xc7ffe
    80005d74:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9ef>
    80005d78:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d7a:	2701                	sext.w	a4,a4
    80005d7c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d7e:	472d                	li	a4,11
    80005d80:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005d82:	5bbc                	lw	a5,112(a5)
    80005d84:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d88:	8ba1                	andi	a5,a5,8
    80005d8a:	10078563          	beqz	a5,80005e94 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d8e:	100017b7          	lui	a5,0x10001
    80005d92:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005d96:	43fc                	lw	a5,68(a5)
    80005d98:	2781                	sext.w	a5,a5
    80005d9a:	10079563          	bnez	a5,80005ea4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d9e:	100017b7          	lui	a5,0x10001
    80005da2:	5bdc                	lw	a5,52(a5)
    80005da4:	2781                	sext.w	a5,a5
  if(max == 0)
    80005da6:	10078763          	beqz	a5,80005eb4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    80005daa:	471d                	li	a4,7
    80005dac:	10f77c63          	bgeu	a4,a5,80005ec4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80005db0:	ffffb097          	auipc	ra,0xffffb
    80005db4:	d36080e7          	jalr	-714(ra) # 80000ae6 <kalloc>
    80005db8:	0001c497          	auipc	s1,0x1c
    80005dbc:	e7848493          	addi	s1,s1,-392 # 80021c30 <disk>
    80005dc0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005dc2:	ffffb097          	auipc	ra,0xffffb
    80005dc6:	d24080e7          	jalr	-732(ra) # 80000ae6 <kalloc>
    80005dca:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005dcc:	ffffb097          	auipc	ra,0xffffb
    80005dd0:	d1a080e7          	jalr	-742(ra) # 80000ae6 <kalloc>
    80005dd4:	87aa                	mv	a5,a0
    80005dd6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005dd8:	6088                	ld	a0,0(s1)
    80005dda:	cd6d                	beqz	a0,80005ed4 <virtio_disk_init+0x1dc>
    80005ddc:	0001c717          	auipc	a4,0x1c
    80005de0:	e5c73703          	ld	a4,-420(a4) # 80021c38 <disk+0x8>
    80005de4:	cb65                	beqz	a4,80005ed4 <virtio_disk_init+0x1dc>
    80005de6:	c7fd                	beqz	a5,80005ed4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80005de8:	6605                	lui	a2,0x1
    80005dea:	4581                	li	a1,0
    80005dec:	ffffb097          	auipc	ra,0xffffb
    80005df0:	ee6080e7          	jalr	-282(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005df4:	0001c497          	auipc	s1,0x1c
    80005df8:	e3c48493          	addi	s1,s1,-452 # 80021c30 <disk>
    80005dfc:	6605                	lui	a2,0x1
    80005dfe:	4581                	li	a1,0
    80005e00:	6488                	ld	a0,8(s1)
    80005e02:	ffffb097          	auipc	ra,0xffffb
    80005e06:	ed0080e7          	jalr	-304(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005e0a:	6605                	lui	a2,0x1
    80005e0c:	4581                	li	a1,0
    80005e0e:	6888                	ld	a0,16(s1)
    80005e10:	ffffb097          	auipc	ra,0xffffb
    80005e14:	ec2080e7          	jalr	-318(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e18:	100017b7          	lui	a5,0x10001
    80005e1c:	4721                	li	a4,8
    80005e1e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e20:	4098                	lw	a4,0(s1)
    80005e22:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e26:	40d8                	lw	a4,4(s1)
    80005e28:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e2c:	6498                	ld	a4,8(s1)
    80005e2e:	0007069b          	sext.w	a3,a4
    80005e32:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e36:	9701                	srai	a4,a4,0x20
    80005e38:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e3c:	6898                	ld	a4,16(s1)
    80005e3e:	0007069b          	sext.w	a3,a4
    80005e42:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e46:	9701                	srai	a4,a4,0x20
    80005e48:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e4c:	4705                	li	a4,1
    80005e4e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005e50:	00e48c23          	sb	a4,24(s1)
    80005e54:	00e48ca3          	sb	a4,25(s1)
    80005e58:	00e48d23          	sb	a4,26(s1)
    80005e5c:	00e48da3          	sb	a4,27(s1)
    80005e60:	00e48e23          	sb	a4,28(s1)
    80005e64:	00e48ea3          	sb	a4,29(s1)
    80005e68:	00e48f23          	sb	a4,30(s1)
    80005e6c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005e70:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e74:	0727a823          	sw	s2,112(a5)
}
    80005e78:	60e2                	ld	ra,24(sp)
    80005e7a:	6442                	ld	s0,16(sp)
    80005e7c:	64a2                	ld	s1,8(sp)
    80005e7e:	6902                	ld	s2,0(sp)
    80005e80:	6105                	addi	sp,sp,32
    80005e82:	8082                	ret
    panic("could not find virtio disk");
    80005e84:	00003517          	auipc	a0,0x3
    80005e88:	91450513          	addi	a0,a0,-1772 # 80008798 <syscalls+0x320>
    80005e8c:	ffffa097          	auipc	ra,0xffffa
    80005e90:	6b2080e7          	jalr	1714(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005e94:	00003517          	auipc	a0,0x3
    80005e98:	92450513          	addi	a0,a0,-1756 # 800087b8 <syscalls+0x340>
    80005e9c:	ffffa097          	auipc	ra,0xffffa
    80005ea0:	6a2080e7          	jalr	1698(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80005ea4:	00003517          	auipc	a0,0x3
    80005ea8:	93450513          	addi	a0,a0,-1740 # 800087d8 <syscalls+0x360>
    80005eac:	ffffa097          	auipc	ra,0xffffa
    80005eb0:	692080e7          	jalr	1682(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80005eb4:	00003517          	auipc	a0,0x3
    80005eb8:	94450513          	addi	a0,a0,-1724 # 800087f8 <syscalls+0x380>
    80005ebc:	ffffa097          	auipc	ra,0xffffa
    80005ec0:	682080e7          	jalr	1666(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80005ec4:	00003517          	auipc	a0,0x3
    80005ec8:	95450513          	addi	a0,a0,-1708 # 80008818 <syscalls+0x3a0>
    80005ecc:	ffffa097          	auipc	ra,0xffffa
    80005ed0:	672080e7          	jalr	1650(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80005ed4:	00003517          	auipc	a0,0x3
    80005ed8:	96450513          	addi	a0,a0,-1692 # 80008838 <syscalls+0x3c0>
    80005edc:	ffffa097          	auipc	ra,0xffffa
    80005ee0:	662080e7          	jalr	1634(ra) # 8000053e <panic>

0000000080005ee4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ee4:	7119                	addi	sp,sp,-128
    80005ee6:	fc86                	sd	ra,120(sp)
    80005ee8:	f8a2                	sd	s0,112(sp)
    80005eea:	f4a6                	sd	s1,104(sp)
    80005eec:	f0ca                	sd	s2,96(sp)
    80005eee:	ecce                	sd	s3,88(sp)
    80005ef0:	e8d2                	sd	s4,80(sp)
    80005ef2:	e4d6                	sd	s5,72(sp)
    80005ef4:	e0da                	sd	s6,64(sp)
    80005ef6:	fc5e                	sd	s7,56(sp)
    80005ef8:	f862                	sd	s8,48(sp)
    80005efa:	f466                	sd	s9,40(sp)
    80005efc:	f06a                	sd	s10,32(sp)
    80005efe:	ec6e                	sd	s11,24(sp)
    80005f00:	0100                	addi	s0,sp,128
    80005f02:	8aaa                	mv	s5,a0
    80005f04:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f06:	00c52d03          	lw	s10,12(a0)
    80005f0a:	001d1d1b          	slliw	s10,s10,0x1
    80005f0e:	1d02                	slli	s10,s10,0x20
    80005f10:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005f14:	0001c517          	auipc	a0,0x1c
    80005f18:	e4450513          	addi	a0,a0,-444 # 80021d58 <disk+0x128>
    80005f1c:	ffffb097          	auipc	ra,0xffffb
    80005f20:	cba080e7          	jalr	-838(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005f24:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f26:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f28:	0001cb97          	auipc	s7,0x1c
    80005f2c:	d08b8b93          	addi	s7,s7,-760 # 80021c30 <disk>
  for(int i = 0; i < 3; i++){
    80005f30:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f32:	0001cc97          	auipc	s9,0x1c
    80005f36:	e26c8c93          	addi	s9,s9,-474 # 80021d58 <disk+0x128>
    80005f3a:	a08d                	j	80005f9c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005f3c:	00fb8733          	add	a4,s7,a5
    80005f40:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f44:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f46:	0207c563          	bltz	a5,80005f70 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005f4a:	2905                	addiw	s2,s2,1
    80005f4c:	0611                	addi	a2,a2,4
    80005f4e:	05690c63          	beq	s2,s6,80005fa6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005f52:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f54:	0001c717          	auipc	a4,0x1c
    80005f58:	cdc70713          	addi	a4,a4,-804 # 80021c30 <disk>
    80005f5c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005f5e:	01874683          	lbu	a3,24(a4)
    80005f62:	fee9                	bnez	a3,80005f3c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005f64:	2785                	addiw	a5,a5,1
    80005f66:	0705                	addi	a4,a4,1
    80005f68:	fe979be3          	bne	a5,s1,80005f5e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005f6c:	57fd                	li	a5,-1
    80005f6e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005f70:	01205d63          	blez	s2,80005f8a <virtio_disk_rw+0xa6>
    80005f74:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005f76:	000a2503          	lw	a0,0(s4)
    80005f7a:	00000097          	auipc	ra,0x0
    80005f7e:	cfc080e7          	jalr	-772(ra) # 80005c76 <free_desc>
      for(int j = 0; j < i; j++)
    80005f82:	2d85                	addiw	s11,s11,1
    80005f84:	0a11                	addi	s4,s4,4
    80005f86:	ffb918e3          	bne	s2,s11,80005f76 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f8a:	85e6                	mv	a1,s9
    80005f8c:	0001c517          	auipc	a0,0x1c
    80005f90:	cbc50513          	addi	a0,a0,-836 # 80021c48 <disk+0x18>
    80005f94:	ffffc097          	auipc	ra,0xffffc
    80005f98:	0d0080e7          	jalr	208(ra) # 80002064 <sleep>
  for(int i = 0; i < 3; i++){
    80005f9c:	f8040a13          	addi	s4,s0,-128
{
    80005fa0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005fa2:	894e                	mv	s2,s3
    80005fa4:	b77d                	j	80005f52 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fa6:	f8042583          	lw	a1,-128(s0)
    80005faa:	00a58793          	addi	a5,a1,10
    80005fae:	0792                	slli	a5,a5,0x4

  if(write)
    80005fb0:	0001c617          	auipc	a2,0x1c
    80005fb4:	c8060613          	addi	a2,a2,-896 # 80021c30 <disk>
    80005fb8:	00f60733          	add	a4,a2,a5
    80005fbc:	018036b3          	snez	a3,s8
    80005fc0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005fc2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005fc6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fca:	f6078693          	addi	a3,a5,-160
    80005fce:	6218                	ld	a4,0(a2)
    80005fd0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fd2:	00878513          	addi	a0,a5,8
    80005fd6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fd8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005fda:	6208                	ld	a0,0(a2)
    80005fdc:	96aa                	add	a3,a3,a0
    80005fde:	4741                	li	a4,16
    80005fe0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005fe2:	4705                	li	a4,1
    80005fe4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005fe8:	f8442703          	lw	a4,-124(s0)
    80005fec:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005ff0:	0712                	slli	a4,a4,0x4
    80005ff2:	953a                	add	a0,a0,a4
    80005ff4:	058a8693          	addi	a3,s5,88
    80005ff8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005ffa:	6208                	ld	a0,0(a2)
    80005ffc:	972a                	add	a4,a4,a0
    80005ffe:	40000693          	li	a3,1024
    80006002:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006004:	001c3c13          	seqz	s8,s8
    80006008:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000600a:	001c6c13          	ori	s8,s8,1
    8000600e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006012:	f8842603          	lw	a2,-120(s0)
    80006016:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000601a:	0001c697          	auipc	a3,0x1c
    8000601e:	c1668693          	addi	a3,a3,-1002 # 80021c30 <disk>
    80006022:	00258713          	addi	a4,a1,2
    80006026:	0712                	slli	a4,a4,0x4
    80006028:	9736                	add	a4,a4,a3
    8000602a:	587d                	li	a6,-1
    8000602c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006030:	0612                	slli	a2,a2,0x4
    80006032:	9532                	add	a0,a0,a2
    80006034:	f9078793          	addi	a5,a5,-112
    80006038:	97b6                	add	a5,a5,a3
    8000603a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000603c:	629c                	ld	a5,0(a3)
    8000603e:	97b2                	add	a5,a5,a2
    80006040:	4605                	li	a2,1
    80006042:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006044:	4509                	li	a0,2
    80006046:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000604a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000604e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006052:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006056:	6698                	ld	a4,8(a3)
    80006058:	00275783          	lhu	a5,2(a4)
    8000605c:	8b9d                	andi	a5,a5,7
    8000605e:	0786                	slli	a5,a5,0x1
    80006060:	97ba                	add	a5,a5,a4
    80006062:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006066:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000606a:	6698                	ld	a4,8(a3)
    8000606c:	00275783          	lhu	a5,2(a4)
    80006070:	2785                	addiw	a5,a5,1
    80006072:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006076:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000607a:	100017b7          	lui	a5,0x10001
    8000607e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006082:	004aa783          	lw	a5,4(s5)
    80006086:	02c79163          	bne	a5,a2,800060a8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000608a:	0001c917          	auipc	s2,0x1c
    8000608e:	cce90913          	addi	s2,s2,-818 # 80021d58 <disk+0x128>
  while(b->disk == 1) {
    80006092:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006094:	85ca                	mv	a1,s2
    80006096:	8556                	mv	a0,s5
    80006098:	ffffc097          	auipc	ra,0xffffc
    8000609c:	fcc080e7          	jalr	-52(ra) # 80002064 <sleep>
  while(b->disk == 1) {
    800060a0:	004aa783          	lw	a5,4(s5)
    800060a4:	fe9788e3          	beq	a5,s1,80006094 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800060a8:	f8042903          	lw	s2,-128(s0)
    800060ac:	00290793          	addi	a5,s2,2
    800060b0:	00479713          	slli	a4,a5,0x4
    800060b4:	0001c797          	auipc	a5,0x1c
    800060b8:	b7c78793          	addi	a5,a5,-1156 # 80021c30 <disk>
    800060bc:	97ba                	add	a5,a5,a4
    800060be:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800060c2:	0001c997          	auipc	s3,0x1c
    800060c6:	b6e98993          	addi	s3,s3,-1170 # 80021c30 <disk>
    800060ca:	00491713          	slli	a4,s2,0x4
    800060ce:	0009b783          	ld	a5,0(s3)
    800060d2:	97ba                	add	a5,a5,a4
    800060d4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060d8:	854a                	mv	a0,s2
    800060da:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060de:	00000097          	auipc	ra,0x0
    800060e2:	b98080e7          	jalr	-1128(ra) # 80005c76 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060e6:	8885                	andi	s1,s1,1
    800060e8:	f0ed                	bnez	s1,800060ca <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060ea:	0001c517          	auipc	a0,0x1c
    800060ee:	c6e50513          	addi	a0,a0,-914 # 80021d58 <disk+0x128>
    800060f2:	ffffb097          	auipc	ra,0xffffb
    800060f6:	b98080e7          	jalr	-1128(ra) # 80000c8a <release>
}
    800060fa:	70e6                	ld	ra,120(sp)
    800060fc:	7446                	ld	s0,112(sp)
    800060fe:	74a6                	ld	s1,104(sp)
    80006100:	7906                	ld	s2,96(sp)
    80006102:	69e6                	ld	s3,88(sp)
    80006104:	6a46                	ld	s4,80(sp)
    80006106:	6aa6                	ld	s5,72(sp)
    80006108:	6b06                	ld	s6,64(sp)
    8000610a:	7be2                	ld	s7,56(sp)
    8000610c:	7c42                	ld	s8,48(sp)
    8000610e:	7ca2                	ld	s9,40(sp)
    80006110:	7d02                	ld	s10,32(sp)
    80006112:	6de2                	ld	s11,24(sp)
    80006114:	6109                	addi	sp,sp,128
    80006116:	8082                	ret

0000000080006118 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006118:	1101                	addi	sp,sp,-32
    8000611a:	ec06                	sd	ra,24(sp)
    8000611c:	e822                	sd	s0,16(sp)
    8000611e:	e426                	sd	s1,8(sp)
    80006120:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006122:	0001c497          	auipc	s1,0x1c
    80006126:	b0e48493          	addi	s1,s1,-1266 # 80021c30 <disk>
    8000612a:	0001c517          	auipc	a0,0x1c
    8000612e:	c2e50513          	addi	a0,a0,-978 # 80021d58 <disk+0x128>
    80006132:	ffffb097          	auipc	ra,0xffffb
    80006136:	aa4080e7          	jalr	-1372(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000613a:	10001737          	lui	a4,0x10001
    8000613e:	533c                	lw	a5,96(a4)
    80006140:	8b8d                	andi	a5,a5,3
    80006142:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006144:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006148:	689c                	ld	a5,16(s1)
    8000614a:	0204d703          	lhu	a4,32(s1)
    8000614e:	0027d783          	lhu	a5,2(a5)
    80006152:	04f70863          	beq	a4,a5,800061a2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006156:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000615a:	6898                	ld	a4,16(s1)
    8000615c:	0204d783          	lhu	a5,32(s1)
    80006160:	8b9d                	andi	a5,a5,7
    80006162:	078e                	slli	a5,a5,0x3
    80006164:	97ba                	add	a5,a5,a4
    80006166:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006168:	00278713          	addi	a4,a5,2
    8000616c:	0712                	slli	a4,a4,0x4
    8000616e:	9726                	add	a4,a4,s1
    80006170:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006174:	e721                	bnez	a4,800061bc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006176:	0789                	addi	a5,a5,2
    80006178:	0792                	slli	a5,a5,0x4
    8000617a:	97a6                	add	a5,a5,s1
    8000617c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000617e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006182:	ffffc097          	auipc	ra,0xffffc
    80006186:	f46080e7          	jalr	-186(ra) # 800020c8 <wakeup>

    disk.used_idx += 1;
    8000618a:	0204d783          	lhu	a5,32(s1)
    8000618e:	2785                	addiw	a5,a5,1
    80006190:	17c2                	slli	a5,a5,0x30
    80006192:	93c1                	srli	a5,a5,0x30
    80006194:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006198:	6898                	ld	a4,16(s1)
    8000619a:	00275703          	lhu	a4,2(a4)
    8000619e:	faf71ce3          	bne	a4,a5,80006156 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800061a2:	0001c517          	auipc	a0,0x1c
    800061a6:	bb650513          	addi	a0,a0,-1098 # 80021d58 <disk+0x128>
    800061aa:	ffffb097          	auipc	ra,0xffffb
    800061ae:	ae0080e7          	jalr	-1312(ra) # 80000c8a <release>
}
    800061b2:	60e2                	ld	ra,24(sp)
    800061b4:	6442                	ld	s0,16(sp)
    800061b6:	64a2                	ld	s1,8(sp)
    800061b8:	6105                	addi	sp,sp,32
    800061ba:	8082                	ret
      panic("virtio_disk_intr status");
    800061bc:	00002517          	auipc	a0,0x2
    800061c0:	69450513          	addi	a0,a0,1684 # 80008850 <syscalls+0x3d8>
    800061c4:	ffffa097          	auipc	ra,0xffffa
    800061c8:	37a080e7          	jalr	890(ra) # 8000053e <panic>
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
