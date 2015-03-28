CROSS_TARGET=arm-bmrpi2_sf-eabi
TARGET = mykernel

CC= $(CROSS_TARGET)-gcc
LD= $(CROSS_TARGET)-ld
OBJCOPY= $(CROSS_TARGET)-objcopy
OBJDUMP= $(CROSS_TARGET)-objdump
SIZE= $(CROSS_TARGET)-size
READELF= $(CROSS_TARGET)-readelf

PREFIX = $(shell which $(CC) | xargs dirname | sed "s/bin//")

GCC_VERSION=$(shell $(CC) --version | grep gcc | sed 's/^.* //g')

CFLAGS  = -mfloat-abi=soft -mlittle-endian
CFLAGS += -nostartfiles -ffreestanding
CFLAGS += -O0 -mcpu=cortex-a7 -march=armv7-a

INCLUDE  = -I./cmsis/ -I./TARGET_RASPBERRYPI2/
INCLUDE += -I./rpi_lib/

LDFLAGS = -L$(PREFIX)/lib/gcc/$(CROSS_TARGET)/$(GCC_VERSION)/
LDFLAGS += -L$(PREFIX)/$(CROSS_TARGET)/lib/
LDFLAGS += -lc -lgcc 

# linker script
LD_SCR  = bmrpi2.lds

# syscal
STARTUP= startup.o
SYSCALL= syscalls.o
MMU = mmu.o

# hal
HAL_PATH = ./rpi_lib/
HAL_OBJS = $(HAL_PATH)/rpi_init.o
HAL_OBJS += $(HAL_PATH)/gpio/gpio.o
HAL_OBJS += $(HAL_PATH)/timer/timer.o
HAL_OBJS += $(HAL_PATH)/delay/delay.o
HAL_OBJS += $(HAL_PATH)/serial/serial.o
HAL_OBJS += $(HAL_PATH)/bss/clearbss.o
HAL_OBJS += $(HAL_PATH)/interrupt.o

# source
OBJS  = main.o


all:	$(TARGET).bin

$(TARGET).elf: $(STARTUP) $(SYSCALL) $(HAL_OBJS) $(OBJS) $(MMU)
# $(TARGET).elf: $(STARTUP) $(OBJS) 
	$(LD) -static -nostartfiles -T $(LD_SCR) $^ -o $@ $(LDFLAGS)
	$(OBJDUMP) -D $(TARGET).elf > $(TARGET).disas
	$(SIZE) $(TARGET).elf > $(TARGET).size
	$(READELF) -a $(TARGET).elf > $(TARGET).readelf

.SUFFIXES: .elf .bin

.elf.bin:
	$(OBJCOPY) -O binary $< $@
.c.o:
	$(CC) $(CFLAGS) -c $< -o $@
.S.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean::
	$(RM) -f *.o *.bin *.elf */*.o */*/*.o 
	$(RM) -f tags *~ *.disas *.readelf *.size

tags::
	ctags *.[chS]


