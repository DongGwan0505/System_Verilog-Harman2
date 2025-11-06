################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/device/gpio/gpio.c 

OBJS += \
./src/device/gpio/gpio.o 

C_DEPS += \
./src/device/gpio/gpio.d 


# Each subdirectory must supply rules for building sources it contributes
src/device/gpio/%.o: ../src/device/gpio/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -IC:/Working/FPGA_Harman_sys_verilog_improve/sys_ver_imp_25_11_04/vitis/SV_25_11_04_wrapper/export/SV_25_11_04_wrapper/sw/SV_25_11_04_wrapper/standalone_microblaze_0/bspinclude/include -mlittle-endian -mcpu=v11.0 -mxl-soft-mul -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


