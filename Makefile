CC = arm-none-eabi-gcc

SRCS = src/main.c
SRCS += src/delay.c
SRCS += src/stm32f4xx_it.c
SRCS += src/system_stm32f4xx.c
SRCS += lib/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_gpio.c
SRCS += lib/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_rcc.c
SRCS += lib/startup_stm32f401xx.s

OBJS = $(SRCS:.c=.o)

CFLAGS = -Ilib -Ilib/STM32F4xx_StdPeriph_Driver/inc -Isrc
CFLAGS += -DSTM32F401xx -DUSE_STDPERIPH_DRIVER -DHSE_VALUE=8000000
CFLAGS += -g -O0
CFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -std=c99
#CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
#CFLAGS += -fsingle-precision-constant -mthumb-interwork -Wl,--gc-sections

LDFLAGS = -Tlib/STM32F401RE_FLASH.ld
LDFLAGS += -lc -lnosys

stm_template.elf: $(OBJS)
	$(CC) $(LDFLAGS) $(CFLAGS) $^ -o $@

all: stm_template.elf

flash: stm_template.elf
	openocd -f interface/stlink-v2-1.cfg -f target/stm32f4x_stlink.cfg \
	-c init -c "flash probe 0" -c "program stm_template.elf verify reset"

debug: stm_template.elf
	openocd -f interface/stlink-v2-1.cfg -f target/stm32f4x_stlink.cfg -c init

clean:
	rm stm_template.elf src/*.o lib/STM32F4xx_StdPeriph_Driver/src/*.o || true