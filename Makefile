PROJECT = forth

$(PROJECT).rom: $(PROJECT).asm
	echo Building for Elf/OS
	../dateextended.pl > date.inc
	../build.pl > build.inc
	asm02 -l -L -DELFOS $(PROJECT).asm
	mv $(PROJECT).prg x.prg
	cat x.prg | sed -f adjust.sed > $(PROJECT).prg
	rm x.prg

elfos: $(PROJECT).asm
	echo Building for Elf/OS
	../dateextended.pl > date.inc
	../build.pl > build.inc
	asm02 -l -L -DELFOS $(PROJECT).asm
	mv $(PROJECT).prg x.prg
	cat x.prg | sed -f adjust.sed > $(PROJECT).prg
	rm x.prg

picoelf: $(PROJECT).asm
	asm02 -l -L -DPICOROM $(PROJECT).asm

mchip: $(PROJECT).asm
	asm02 -l -L -DMCHIP $(PROJECT).asm

stg: $(PROJECT).asm
	../date.pl > date.inc
	asm02 -l -L -DSTGROM $(PROJECT).asm
	mv $(PROJECT).prg x.prg
	cat x.prg | sed -f adjust.sed > $(PROJECT).prg
	rm x.prg


clean:
	-rm $(PROJECT).prg

