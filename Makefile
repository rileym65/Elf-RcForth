PROJECT = forth

$(PROJECT).rom: $(PROJECT).asm
	../dateextended.pl > date.inc
	../build.pl > build.inc
	rcasm  -l -v -x -d 1802 -DELFOS $(PROJECT) 2>&1 | tee forth.lst
	cat $(PROJECT).prg | sed -f adjust.sed > x.prg
	rm $(PROJECT).prg
	mv x.prg $(PROJECT).prg

elfos: $(PROJECT).asm
	../dateextended.pl > date.inc
	../build.pl > build.inc
	rcasm  -l -v -x -d 1802 -DELFOS $(PROJECT) 2>&1 | tee forth.lst
	cat $(PROJECT).prg | sed -f adjust.sed > x.prg
	rm $(PROJECT).prg
	mv x.prg $(PROJECT).prg

picoelf: $(PROJECT).asm
	../date.pl > date.inc
	rcasm  -l -v -x -d 1802 -DPICOROM $(PROJECT) 2>&1 | tee forth.lst
	cat $(PROJECT).prg | sed -f adjust.sed > x.prg
	rm $(PROJECT).prg
	mv x.prg $(PROJECT).prg

stg: $(PROJECT).asm
	../date.pl > date.inc
	rcasm  -l -v -x -d 1802 -DSTGROM $(PROJECT) 2>&1 | tee forth.lst
	cat $(PROJECT).prg | sed -f adjust.sed > x.prg
	rm $(PROJECT).prg
	mv x.prg $(PROJECT).prg


clean:
	-rm $(PROJECT).prg

