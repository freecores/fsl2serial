HDRDIR_1=-I/project/software/Xilinx/EDK8.2/sw/XilinxProcessorIPLib/drivers/common_v1_00_a/src/
HDRDIR_2=-I/project/software/Xilinx/EDK8.2/sw/lib/bsp/standalone_v1_00_a/src/microblaze/

all:
	mb-gcc -Wall -o ../executable.elf fsl_interface.c openfire_src.c $(HDRDIR_1) $(HDRDIR_2)

clean:
	rm -rf *~
	rm -rf *.o
	rm -rf ../executable.elf
