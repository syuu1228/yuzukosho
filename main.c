#include "rpi_lib/rpi.h"
#include <stdio.h>
#include <stdint.h>

void swi_hello(uint32_t *reg){
	printf("swi called\n");
	printf("swi_hello: cpsr = %08x\n",getmode());

	printf("sp_irq: %08x\n",*reg++);

	printf("r0: %08x\n",*reg++);
	printf("r1: %08x\n",*reg++);
	printf("r2: %08x\n",*reg++);
	printf("r3: %08x\n",*reg++);
	printf("r4: %08x\n",*reg++);
	printf("r5: %08x\n",*reg++);
	printf("r6: %08x\n",*reg++);
	printf("r7: %08x\n",*reg++);
	printf("r8: %08x\n",*reg++);
	printf("r9: %08x\n",*reg++);
	printf("r10: %08x\n",*reg++);
	printf("r11: %08x\n",*reg++);
	printf("r12: %08x\n",*reg++);
	// 割り込み時にlrに突っ込まれる値は割り込み発生時のpc+4
	printf("pc: %08x\n",*(reg+13) - 4);

	// while(1);
}

int main(void){
	int i;
	rpi_init();

	// JTAG用設定
	// 3.3V			: ARM_VREF 
	// GPIO22 (ALT4): ARM_TRST
	// GPIO4  (ALT5): ARM_TDI
	// GPIO27 (ALT4): ARM_TMS
	// GPIO25 (ALT4): ARM_TCK
	// GPIO24 (ALT4): ARM_TDO
	// GND			: ARM_GND
	pinMode(22, ALT4);
	pinMode(4, ALT5);
	pinMode(27, ALT4);
	pinMode(25, ALT4);
	pinMode(24, ALT4);

	// LED init
	pinMode(47,OUTPUT);

	printf("main: cpsr = %08x\n",getmode());

	for(i = 0; i < 10; i++) {
		digitalWrite(47, HIGH);
		delay(1000);
		digitalWrite(47, LOW);
		delay(1000);
		printf("Hello\n");
	}
	vmentry();

	return 0;
}

void guest_prog(void) {
	while(1){
		digitalWrite(47, HIGH);
		delay(500);
		digitalWrite(47, LOW);
		delay(500);
		printf("World\n");
	}
}
