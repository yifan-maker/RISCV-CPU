.globl __start
.text
__start:

addi x1, x0, 2; //0
addi x2, x0, 2; // 1
add x3, x1, x2; //2
lw x4, x3, 0;   //3
;sub x5, x4, x0; //4
beq x3, x4, L;  //5
addi x6, x0, 6; //6
L:
addi x7, x0, 7; //7
