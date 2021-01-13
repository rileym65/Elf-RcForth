; *******************************************************************
; *** This software is copyright 2006 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

;[RLA] These are defined on the rcasm command line!
;[RLA] #define ELFOS            ; build the version that runs under Elf/OS
;[RLA] #define STGROM           ; build the STG EPROM version
;[RLA] #define PICOROM          ; define for Mike's PIcoElf version

;[RLA]   rcasm doesn't have any way to do a logical "OR" of assembly
;[RLA} options, so define a master "ANYROM" option that's true for
;[RLA} any of the ROM conditions...
#ifdef PICOROM
#define ANYROM
#endif
#ifdef STGROM
#define ANYROM
#endif

#ifdef STGROM
include config.inc              ;[RLA] STG ROM addresses and options
#endif

include    bios.inc

#ifdef PICOROM
xopenw:    equ     08006h
xopenr:    equ     08009h
xread:     equ     0800ch
xwrite:    equ     0800fh
xclosew:   equ     08012h
xcloser:   equ     08015h
#endif

#ifdef STGROM
;[RLA] XMODEM entry vectors for the STG EPROM ...
xopenw:    equ     XMODEM + 0*3
xopenr:    equ     XMODEM + 1*3
xread:     equ     XMODEM + 2*3
xwrite:    equ     XMODEM + 3*3
xclosew:   equ     XMODEM + 4*3
xcloser:   equ     XMODEM + 5*3
#endif

#ifdef ELFOS
include    kernel.inc
           org     8000h
           lbr     0ff00h
           db      'rcforth',0
           dw      9000h
           dw      endrom+7000h
           dw      2000h
           dw      endrom-2000h
           dw      2000h
           db      0
#endif

;  R2   - program stack
;  R3   - Main PC
;  R4   - standard call
;  R5   - standard ret
;  R6   - used by Scall/Sret linkage
;  R9   - Data segment

FWHILE:    equ     81h
FREPEAT:   equ     FWHILE+1
FIF:       equ     FREPEAT+1
FELSE:     equ     FIF+1
FTHEN:     equ     FELSE+1
FVARIABLE: equ     FTHEN+1
FCOLON:    equ     FVARIABLE+1
FSEMI:     equ     FCOLON+1
FDUP:      equ     FSEMI+1
FDROP:     equ     FDUP+1
FSWAP:     equ     FDROP+1
FPLUS:     equ     FSWAP+1
FMINUS:    equ     FPLUS+1
FMUL:      equ     FMINUS+1
FDIV:      equ     FMUL+1
FDOT:      equ     FDIV+1
FUDOT:     equ     FDOT+1
FI:        equ     FUDOT+1
FAND:      equ     FI+1
FOR:       equ     FAND+1
FXOR:      equ     FOR+1
FCR:       equ     FXOR+1
FMEM:      equ     FCR+1
FDO:       equ     FMEM+1
FLOOP:     equ     FDO+1
FPLOOP:    equ     FLOOP+1
FEQUAL:    equ     FPLOOP+1
FUNEQUAL:  equ     FEQUAL+1
FBEGIN:    equ     FUNEQUAL+1
FUNTIL:    equ     FBEGIN+1
FRGT:      equ     FUNTIL+1
FGTR:      equ     FRGT+1
FWORDS:    equ     FGTR+1
FEMIT:     equ     FWORDS+1
FDEPTH:    equ     FEMIT+1
FROT:      equ     FDEPTH+1
FMROT:     equ     FROT+1
FOVER:     equ     FMROT+1
FAT:       equ     FOVER+1
FEXCL:     equ     FAT+1
FCAT:      equ     FEXCL+1
FCEXCL:    equ     FCAT+1
FDOTQT:    equ     FCEXCL+1
FKEY:      equ     FDOTQT+1
FALLOT:    equ     FKEY+1
FERROR:    equ     FALLOT+1
FSEE:      equ     FERROR+1
FFORGET:   equ     FSEE+1

saveaddr:  equ     0c000h

T_NUM:     equ     255
T_ASCII:   equ     254

#ifdef ANYROM
buffer:    equ     0200h
himem:     equ     300h
rstack:    equ     302h
tos:       equ     304h
freemem:   equ     306h
fstack:    equ     308h
jump:      equ     30ah
storage:   equ     30dh
stack:     equ     01ffh
#endif


#ifdef ELFOS
stack:     equ     00ffh;
           org     02000h
           br      start
include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0
#endif

#ifdef PICOROM
           org     0a000h
#endif
#ifdef STGROM
           org     FORTH
#endif

#ifdef     ANYROM
           lbr     new
           mov     r2,stack
           mov     r6,old
           lbr     f_initcall
new:       mov     r2,stack
           mov     r6,start
           lbr     f_initcall
#endif

start:     ldi     high himem          ; get page of data segment
           phi     r9                  ; place into r9
#ifdef ANYROM
           ldi     0ch                ; form feed
           sep     scall               ; clear screen
           dw      f_type
#endif
           ldi     high hello          ; address of signon message
           phi     rf                  ; place into r6
           ldi     low hello
           plo     rf
           sep     scall               ; call bios to display message
           dw      f_msg               ; function to display a message

; ************************************************
; **** Determine how much memory is installed ****
; ************************************************
#ifdef ELFOS
           mov     rf,0442h            ; point to high memory pointer
           lda     rf                  ; retrieve it
           phi     rb
           lda     rf
           plo     rb
#else
           sep     scall                ; ask BIOS for memory size
           dw      f_freemem
           mov     rb,rf
#endif

           ldi     low freemem         ; free memory pointer
           plo     r9                  ; place into data pointer
           ldi     storage.1
           str     r9
           inc     r9
           ldi     storage.0
           str     r9



;memlp:     ldi     0                   ; get a zero
;           str     rb                  ; write to memory
;           ldn     rb                  ; recover retrieved byte
;           bnz     memdone             ; jump if not same
;           ldi     255                 ; another value
;           str     rb                  ; write to memory
;           ldn     rb                  ; retrieve it
;           smi     255                 ; compare against written
;           bnz     memdone             ; jump if not same
;           ghi     rb
;           adi     1                   ; point to next page
;           phi     rb                  ; and put it back
;           smi     7fh                 ; prevent from going over 7f00h
;           bnz     memlp
memdone:   ldi     low himem           ; memory pointer
           plo     r9                  ; place into r9
           ghi     rb                  ; get high of last memory
           str     r9                  ; write to data
           phi     r2                  ; and to machine stack
           inc     r9                  ; point to low byte
           glo     rb                  ; get low of himem
           str     r9                  ; and store
           plo     r2
           ldi     low rstack          ; get return stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     1                   ; 1 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low tos             ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     high storage        ; point to storage
           phi     rf
           ldi     low storage
           plo     rf
           ldi     0
           str     rf                  ; write zeroes as storage terminator
           inc     rf
           str     rf
           inc     rf
           str     rf
           inc     rf
           str     rf
           inc     rf
           lbr     mainlp

old:       ldi     low himem           ; memory pointer
           plo     r9                  ; place into r9
           lda     r9                  ; retreive high memory
           phi     rb
           phi     r2                  ; and to machine stack
           lda     r9
           plo     rb
           plo     r2
           ldi     low rstack          ; get return stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     1                   ; 1 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low tos             ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     rb                  ; get hi memory
           smi     2                   ; 2 page lower for forth stack
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     rb                  ; get low byte
           str     r9                  ; and store

; *************************
; *** Main program loop ***
; *************************
mainlp:    ldi     high prompt         ; address of prompt
           phi     rf                  ; place into r6
           ldi     low prompt
           plo     rf
           sep     scall               ; display prompt
           dw      f_msg               ; function to display a message
           ldi     high buffer         ; point to input buffer
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall               ; read a line
           dw      f_input             ; function to read a line
           ldi     high crlf           ; address of CR/LF
           phi     rf                  ; place into r6
           ldi     low crlf  
           plo     rf
           sep     scall               ; call bios
           dw      f_msg               ; function to display a message
           mov     rf,buffer           ; convert to uppercase
           sep     scall
           dw      touc
           sep     scall               ; call tokenizer
           dw      tknizer

       ldi     low freemem         ; get free memory pointer
       plo     r9                  ; place into data segment
       lda     r9                  ; get free memory pointer
       phi     rb                  ; place into rF
       ldn     r9
       plo     rb
   inc rb
   inc rb
       sep     scall
       dw      exec


           lbr     mainlp              ; return to beginning of main loop

; **************************************
; *** Display a character, char in D ***
; **************************************
disp:      sep     scall               ; call bios
           dw      f_type              ; function to type a charactr
           sep     sret                ; return to caller

; ********************************
; *** Read a key, returns in D ***
; ********************************
getkey:    sep     scall               ; call bios
           dw      f_read              ; function to read a key
           sep     sret                ; return to caller

; ***************************************************
; *** Function to retrieve value from forth stack ***
; *** Returns R[B] = value                        ***
; ***         DF=0 no error, DF=1 error           ***
; ***************************************************
pop:       sex     r2                  ; be sure x points to stack
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           ldi     low tos             ; pointer to maximum stack value
           plo     r9                  ; put into data frame
           lda     r9                  ; get high value
           str     r2                  ; place into memory
           ghi     ra                  ; get high byte of forth stack
           sm                          ; check if same
           lbnz    stackok             ; jump if ok
           ldn     r9                  ; get low byte of tos
           str     r2
           glo     ra                  ; check low byte of stack pointer
           sm
           lbnz    stackok             ; jump if ok
           ldi     1                   ; signal error
popret:    shr                         ; shift status into DF
           sep     sret                ; return to caller
stackok:   inc     ra                  ; point to high byte
           lda     ra                  ; get it
           phi     rb                  ; put into r6
           ldn     ra                  ; get low byte
           plo     rb
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           ldi     0                   ; signal no error
           lbr     popret              ; and return to caller

; ********************************************************
; *** Function to push value onto stack, value in R[B] ***
; ********************************************************
push:      ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           glo     rb                  ; get low byte of value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ghi     rb                  ; get high value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ldi     low fstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           sep     sret                ; return to caller

; ****************************************************
; *** Function to retrieve value from return stack ***
; *** Returns R[B] = value                         ***
; ***         D=0 no error, D=1 error              ***
; ****************************************************
rpop:      sex     r2                  ; be sure x points to stack
           ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           inc     ra                  ; point to high byte
           lda     ra                  ; get it
           phi     rb                  ; put into r6
           ldn     ra                  ; get low byte
           plo     rb
           ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           ldi     0                   ; signal no error
           sep     sret                ; and return

; ***************************************************************
; *** Function to push value onto return stack, value in R[B] ***
; ***************************************************************
rpush:     ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           lda     r9
           phi     ra
           ldn     r9
           plo     ra
           glo     rb                  ; get low byte of value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ghi     rb                  ; get high value
           str     ra                  ; store on forth stack
           dec     ra                  ; point to next byte
           ldi     low rstack          ; get stack address
           plo     r9                  ; select in data segment
           ghi     ra                  ; get hi memory
           str     r9                  ; write to pointer
           inc     r9                  ; point to low byte
           glo     ra                  ; get low byte
           str     r9                  ; and store
           sep     sret                ; return to caller

;           org     200h 
; ********************************************
; *** Function to find stored name address ***
; ***  Needs: name to search in R[8]       ***
; ***  returns: R[B] first byte in data    ***
; ***           R[7] Address of descriptor ***
; ***           R[8] first addr after name ***
; ***           DF = 1 if not found        ***
; ********************************************
findname:  ldi     high storage        ; get address of stored data
           phi     rb                  ; put into r6
           ldi     low storage
           plo     rb
           sex     r2                  ; make sure X points to stack
findlp:    ghi     rb                  ; copy address
           phi     r7
           glo     rb
           plo     r7
           lda     rb                  ; get link address
           lbnz    findgo              ; jump if nonzero
           ldn     rb                  ; get low byte
           lbnz    findgo              ; jump if non zero
           ldi     1                   ; not found
findret:   shr                         ; set DF
           sep     sret                ; and return to caller
findgo:    inc     rb                  ; pointing now at type
           inc     rb                  ; pointing at ascii indicator
           inc     rb                  ; first byte of name
           glo     r8                  ; save requested name
           stxd
           ghi     r8
           stxd
findchk:   ldn     r8                  ; get byte from requested name
           str     r2                  ; place into memory
           ldn     rb                  ; get byte from descriptor
           sm                          ; compare equality
           lbnz    findnext            ; jump if not found
           ldn     r8                  ; get byte
           lbz     findfound           ; entry is found
           inc     r8                  ; increment positions
           inc     rb
           lbr     findchk             ; and keep looking
findfound: inc     rb                  ; r6 now points to data
           irx                         ; remove r8 from stack
           irx
           inc     r8                  ; move past terminator in name
           ldi     0                   ; signal success
           lbr     findret             ; and return to caller
findnext:  irx                         ; recover start of requested name
           ldxa
           phi     r8
           ldx
           plo     r8
           lda     r7                  ; get next link address
           phi     rb
           ldn     r7
           plo     rb
           lbr     findlp              ; and check next entry

; *********************************************
; *** Function to multiply 2 16 bit numbers ***
; *********************************************
mul16:     ldi     0                   ; zero out total
           phi     r8
           plo     r8
           phi     rc
           plo     rc
           sex     r2                  ; make sure X points to stack
mulloop:   glo     r7                  ; get low of multiplier
           lbnz    mulcont             ; continue multiplying if nonzero
           ghi     r7                  ; check hi byte as well
           lbnz    mulcont
           ghi     r8                  ; transfer answer
           phi     rb
           glo     r8
           plo     rb
           sep     sret                ; return to caller
mulcont:   ghi     r7                  ; shift multiplier
           shr
           phi     r7
           glo     r7
           shrc
           plo     r7
           lbnf    mulcont2            ; loop if no addition needed
           glo     rb                  ; add 6 to 8
           str     r2
           glo     r8
           add
           plo     r8
           ghi     rb
           str     r2
           ghi     r8
           adc
           phi     r8
           glo     rc                  ; carry into high word
           adci    0
           plo     rc
           ghi     rc
           adci    0
           phi     rc
mulcont2:  glo     rb                  ; shift first number
           shl
           plo     rb
           ghi     rb
           shlc
           phi     rb
           lbr     mulloop             ; loop until done

; ************************************
; *** make both arguments positive ***
; *** Arg1 RB                      ***
; *** Arg2 R7                      ***
; *** Returns D=0 - signs same     ***
; ***         D=1 - signs difer    ***
; ************************************
mdnorm:    ghi     rb                  ; get high byte if divisor
           str     r2                  ; store for sign check
           ghi     r7                  ; get high byte of dividend
           xor                         ; compare
           shl                         ; shift into df
           ldi     0                   ; convert to 0 or 1
           shlc                        ; shift into D
           plo     re                  ; store into sign flag
           ghi     rb                  ; need to see if RB is negative
           shl                         ; shift high byte to df
           lbnf    mdnorm2             ; jump if not
           ghi     rb                  ; 2s compliment on RB
           xri     0ffh
           phi     rb
           glo     rb
           xri     0ffh
           plo     rb
           inc     rb
mdnorm2:   ghi     r7                  ; now check r7 for negative
           shl                         ; shift sign bit into df
           lbnf    mdnorm3             ; jump if not
           ghi     r7                  ; 2 compliment on R7
           xri     0ffh
           phi     r7
           glo     r7
           xri     0ffh
           plo     r7
           inc     r7
mdnorm3:   glo     re                  ; recover sign flag
           sep     sret                ; and return to caller
            
           

; *** RC = RB/R7 
; *** RB = remainder
; *** uses R8 and R9
div16:     sep     scall               ; normalize numbers
           dw      mdnorm
           plo     re                  ; save sign comparison
           ldi     0                   ; clear answer 
           phi     rc
           plo     rc
           phi     r8                  ; set additive
           plo     r8
           inc     r8
           glo     r7                  ; check for divide by 0
           lbnz    d16lp1
           ghi     r7
           lbnz    d16lp1
           ldi     0ffh                ; return 0ffffh as div/0 error
           phi     rc
           plo     rc
           sep     sret                ; return to caller
d16lp1:    ghi     r7                  ; get high byte from r7
           ani     128                 ; check high bit 
           lbnz    divst               ; jump if set
           glo     r7                  ; lo byte of divisor
           shl                         ; multiply by 2
           plo     r7                  ; and put back
           ghi     r7                  ; get high byte of divisor
           shlc                        ; continue multiply by 2
           phi     r7                  ; and put back
           glo     r8                  ; multiply additive by 2
           shl     
           plo     r8
           ghi     r8
           shlc
           phi     r8
           lbr     d16lp1              ; loop until high bit set in divisor
divst:     glo     r7                  ; get low of divisor
           lbnz    divgo               ; jump if still nonzero
           ghi     r7                  ; check hi byte too
           lbnz    divgo
           glo     re                  ; get sign flag
           shr                         ; move to df
           lbnf    divret              ; jump if signs were the same
           ghi     rc                  ; perform 2s compliment on answer
           xri     0ffh
           phi     rc
           glo     rc
           xri     0ffh
           plo     rc
           inc     rc
divret:    sep     sret                ; jump if done
divgo:     ghi     rb                  ; copy dividend
           phi     r9
           glo     rb
           plo     r9
           glo     r7                  ; get lo of divisor
           stxd                        ; place into memory
           irx                         ; point to memory
           glo     rb                  ; get low byte of dividend
           sm                          ; subtract
           plo     rb                  ; put back into r6
           ghi     r7                  ; get hi of divisor
           stxd                        ; place into memory
           irx                         ; point to byte
           ghi     rb                  ; get hi of dividend
           smb                         ; subtract
           phi     rb                  ; and put back
           lbdf    divyes              ; branch if no borrow happened
           ghi     r9                  ; recover copy
           phi     rb                  ; put back into dividend
           glo     r9
           plo     rb
           lbr     divno               ; jump to next iteration
divyes:    glo     r8                  ; get lo of additive
           stxd                        ; place in memory
           irx                         ; point to byte
           glo     rc                  ; get lo of answer
           add                         ; and add
           plo     rc                  ; put back
           ghi     r8                  ; get hi of additive
           stxd                        ; place into memory
           irx                         ; point to byte
           ghi     rc                  ; get hi byte of answer
           adc                         ; and continue addition
           phi     rc                  ; put back
divno:     ghi     r7                  ; get hi of divisor
           shr                         ; divide by 2
           phi     r7                  ; put back
           glo     r7                  ; get lo of divisor
           shrc                        ; continue divide by 2
           plo     r7
           ghi     r8                  ; get hi of divisor
           shr                         ; divide by 2
           phi     r8                  ; put back
           glo     r8                  ; get lo of divisor
           shrc                        ; continue divide by 2
           plo     r8
           lbr     divst               ; next iteration

;           org     300h
; ***************************
; *** Setup for tokenizer ***
; ***************************
tknizer:   ldi     high buffer         ; point to input buffer
           phi     rb
           ldi     low buffer
           plo     rb
           ldi     low freemem         ; get free memory pointer
           plo     r9                  ; place into data segment
           lda     r9                  ; get free memory pointer
           phi     rf                  ; place into rF
           ldn     r9
           plo     rf
   inc rf
   inc rf
           sex     r2                  ; make sure x is pointing to stack

; ******************************
; *** Now the tokenizer loop ***
; ******************************
tokenlp:   ldn     rb                  ; get byte from buffer
           lbz     tokendn             ; jump if found terminator
           smi     (' '+1)             ; check for whitespace
           lbdf    nonwhite            ; jump if not whitespace
           inc     rb                  ; move past white space
           lbr     tokenlp             ; and keep looking

; ********************************************
; *** Prepare to check against token table ***
; ********************************************
nonwhite:  ldi     high cmdTable       ; point to comand table
           phi     r7                  ; r7 will be command table pointer
           ldi     low cmdTable
           plo     r7
           ldi     1                   ; first command number
           plo     r8                  ; r8 will keep track of command number
; **************************
; *** Command check loop ***
; **************************
cmdloop:   ghi     rb                  ; save buffer address
           phi     rc
           glo     rb
           plo     rc
; ************************
; *** Check next token ***
; ************************
tokloop:   ldn     r7                  ; get byte from token table
           ani     128                 ; check if last byte of token
           lbnz    cmdend              ; jump if last byte
           ldn     r7                  ; reget token byte
           str     r2                  ; store to stack
           ldn     rb                  ; get byte from buffer
           sm                          ; do bytes match?
           lbnz    toknomtch           ; jump if no match
           inc     r7                  ; incrment token pointer
           inc     rb                  ; increment buffer pointer
           lbr     tokloop             ; and keep looking
; *********************************************************
; *** Token failed match, move to next and reset buffer ***
; *********************************************************
toknomtch: ghi     rc                  ; recover saved address
           phi     rb
           glo     rc
           plo     rb
nomtch1:   ldn     r7                  ; get byte from token
           ani     128                 ; looking for last byte of token
           lbnz    nomtch2             ; jump if found
           inc     r7                  ; point to next byte
           lbr     nomtch1             ; and keep looking
nomtch2:   inc     r7                  ; point to next token
           inc     r8                  ; increment command number
           ldn     r7                  ; get next token byte
           lbnz    cmdloop             ; jump if more tokens to check
           lbr     notoken             ; jump if no token found
; ***********************************************************
; *** Made it to last byte of token, check remaining byte ***
; ***********************************************************
cmdend:    ldn     r7                  ; get byte fro token
           ani     07fh                ; strip off end code
           str     r2                  ; save to stack
           ldn     rb                  ; get byte from buffer
           sm                          ; do they match
           lbnz    toknomtch           ; jump if not
           inc     rb                  ; point to next byte
           ldn     rb                  ; get it
           smi     (' '+1)             ; it must be whitespace
           lbdf    toknomtch           ; otherwise no match
; *************************************************************
; *** Match found, store command number into command buffer ***
; *************************************************************
           glo     r8                  ; get command number
           ori     128                 ; set high bit
           str     rf                  ; write to command buffer
           inc     rf                  ; point to next position
           smi     FDOTQT              ; check for ." function
           lbnz    tokenlp             ; jump if not
           inc     rb                  ; move past first space
           ldi     T_ASCII             ; need an ascii token
tdotqtlp:  str     rf                  ; write to command buffer
           inc     rf
           ldn     rb                  ; get next byte
           smi     34                  ; check for end quote
           lbz     tdotqtdn            ; jump if found
           lda     rb                  ; transfer character to code
           lbr     tdotqtlp            ; and keep looking
tdotqtdn:  ldn     rb                  ; retrieve quote
           str     rf                  ; put quote into output
           inc     rf
           ldi     0                   ; need string terminator
           str     rf
           inc     rf
           inc     rb                  ; move past quote
           lbr     tokenlp             ; then continue tokenizing
         



notoken:   ldi     0                   ; clear negative flag
           plo     re
           ldn     rb                  ; get byte
           smi     '-'                 ; is it negative
           lbnz    notoken1            ; jump if not
           inc     rb                  ; move past negative
           ldi     1                   ; set negative flag
           plo     re
notoken1:  ldn     rb                  ; get byte
           smi     '0'                 ; check for below numbers
           lbnf    nonnumber           ; jump if not a number
           ldn     rb
           smi     ('9'+1)
           lbdf    nonnumber
           ghi     rb                  ; save pointer in case of bad number
           phi     rc
           glo     rb
           plo     rc
; **********************
; *** Found a number ***
; **********************
isnumber:  ldi     0                   ; number starts out as zero
           phi     r7                  ; use r7 to compile number
           plo     r7
           sex     r2                  ; make sure x is pointing to stack
numberlp:  ghi     r7                  ; copy number to temp
           phi     r8
           glo     r7
           plo     r8
           glo     r7                  ; mulitply by 2
           shl
           plo     r7
           ghi     r7
           shlc
           phi     r7
           glo     r7                  ; mulitply by 4
           shl
           plo     r7
           ghi     r7
           shlc
           phi     r7
           glo     r8                  ; multiply by 5
           str     r2
           glo     r7
           add
           plo     r7
           ghi     r8
           str     r2
           ghi     r7
           adc
           phi     r7
           glo     r7                  ; mulitply by 10
           shl
           plo     r7
           ghi     r7
           shlc
           phi     r7
           lda     rb                  ; get byte from buffer
           smi     '0'                 ; convert to numeric
           str     r2                  ; store it
           glo     r7                  ; add to number
           add
           plo     r7
           ghi     r7                  ; propate through high byte
           adci    0
           phi     r7
           ldn     rb                  ; get byte
           smi     (' '+1)             ; check for space
           lbnf    numberdn            ; number also done
           ldn     rb
           smi     '0'                 ; check for below numbers
           lbnf    numbererr           ; jump if not a number
           ldn     rb
           smi     ('9'+1)
           lbdf    numbererr
           lbr     numberlp            ; get rest of number
numbererr: ghi     rc                  ; recover address
           phi     rb
           glo     rc
           plo     rb
           lbr     nonnumber
numberdn:  glo     re                  ; get negative flag
           lbz     numberdn1           ; jump if positive number
           ghi     r7                  ; negative, so 2s compliment number
           xri     0ffh
           phi     r7
           glo     r7
           xri     0ffh
           plo     r7
           inc     r7
numberdn1: ldi     T_NUM               ; code to signify a number
           str     rf                  ; write to code buffer
           inc     rf                  ; point to next position
           ghi     r7                  ; get high byte of number
           str     rf                  ; write to code buffer
           inc     rf                  ; point to next position
           glo     r7                  ; get lo byte of numbr
           str     rf                  ; write to code buffer
           inc     rf                  ; point to next position
           lbr     tokenlp             ; continue reading tokens

; *************************************************************
; *** Neither token or number found, insert as ascii string ***
; *************************************************************
nonnumber: ldi     T_ASCII             ; indicate ascii to follow
           dec     rb                  ; account for first increment
notokenlp: str     rf                  ; write to buffer
           inc     rf                  ; advance to next position
           inc     rb                  ; point to next position
           ldn     rb                  ; get next byte
           smi     (' '+1)             ; check for whitespace
           lbnf    notokwht            ; found whitespace
           ldn     rb                  ; get byte
           lbr     notokenlp           ; get characters til whitespace
notokwht:  ldi     0                   ; need ascii terminator
           str     rf                  ; store into buffer
           inc     rf                  ; point to next position
           lbr     tokenlp             ; and keep looking
tokendn:   ldi     0                   ; need to terminate command string
           str     rf                  ; write to buffer
           sep    sret                 ; return to caller
 
;           org     400h
; *******************************
; *** Output numbers in ascii ***
; *******************************
uintout:   lbr     positive
intout:    sex     r2                  ; point X to stack
           ghi     rb                  ; get high of number
           ani     128                 ; mask all bit sign bit
           lbz     positive            ; jump if number is positive
           ldi     '-'                 ; need a minus sign
           sep     scall
           dw      disp
           glo     rb                  ; get low byte
           str     r2                  ; store it
           ldi     0                   ; need to subtract from 0
           sm
           plo     rb                  ; put back
           ghi     rb                  ; get high byte
           str     r2                  ; place into memory
           ldi     0                   ; still subtracting from zero
           smb
           phi     rb                  ; and put back
positive:  ldi     27h                 ; hi byte of 10000
           phi     r7                  ; place into subtraction
           ldi     10h                 ; lo byte of 10000
           plo     r7
           ldi     0                   ; leading zero flag
           stxd                        ; store onto stack
nxtiter:   ldi     0                   ; star count at zero
           plo     r8                  ; place into low of r8
divlp:     glo     r7                  ; get low of number to subtrace
           str     r2                  ; place into memory
           glo     rb                  ; get low of number
           sm                          ; subtract
           phi     r8                  ; place into temp space
           ghi     r7                  ; get high of subtraction
           str     r2                  ; place into memory
           ghi     rb                  ; get high of number
           smb                         ; perform subtract
           lbnf    nomore              ; jump if subtraction was too large
           phi     rb                  ; store result
           ghi     r8
           plo     rb
           inc     r8                  ; increment count
           lbr     divlp               ; and loop back
nomore:    irx                         ; point back to leading zero flag
           glo     r8
           lbnz    nonzero             ; jump if not zero
           ldn     r2                  ; get flag
           lbnz    allow0              ; jump if no longer zero
           dec     r2                  ; keep leading zero flag
           lbr     findnxt             ; skip output
allow0:    ldi     0                   ; recover the zero
nonzero:   adi     30h                 ; convert to ascii
           sep     scall
           dw      disp
           ldi     1                   ; need to set leading flag
           stxd                        ; store it
findnxt:   ghi     r7                  ; get high from subtraction byte
           smi     27h                 ; check for 10000
           lbnz    not10000            ; jump if not
           ldi     3                   ; high byte of 1000
           phi     r7                  ; place into r7
           ldi     0e8h                ; low byte of 1000
           plo     r7                  ; plate into r7
           lbr     nxtiter             ; perform next iteration
not10000:  ghi     r7                  ; get high byte of subtraction
           smi     3                   ; check for 1000
           lbnz    not1000             ; jump if not
           ldi     0                   ; high byte of 100
           phi     r7                  ; place into r7
           ldi     100                 ; low byte of 100
           plo     r7                  ; plate into r7
           lbr     nxtiter             ; perform next iteration
not1000:   glo     r7                  ; get byte from subtraction
           smi     100                 ; check for 100
           lbnz    not100              ; jump if not 100
           ldi     0                   ; high byte of 10
           phi     r7                  ; place into r7
           ldi     10                  ; low byte of 10
           plo     r7                  ; plate into r7
           lbr     nxtiter             ; perform next iteration
not100:    glo     r7                  ; get byte from subtraction
           smi     10                  ; check for 10
           lbnz    intdone             ; jump if done
  irx 
  ldi 1
  stxd
           ldi     0                   ; high byte of 1
           phi     r7                  ; place into r7
           ldi     1                   ; low byte of 1
           plo     r7                  ; plate into r7
           lbr     nxtiter             ; perform next iteration
intdone:   irx                         ; put x back where it belongs
           sep     sret                ; return to caller

;           org     500h
; ****************************************************
; *** Execute forth byte codes, RB points to codes ***
; ****************************************************
exec:      ldn     rb                  ; get byte from codestream
           lbz     execdn              ; jump if at end of stream
           smi     T_NUM               ; check for numbers
           lbz     execnum             ; code is numeric
           ldn     rb                  ; recover byte
           smi     T_ASCII             ; check for ascii data
           lbz     execascii           ; jump if ascii
           mov     r8, jump            ; point to jump address
           ldi     0c0h                ; need LBR
           str     r8                  ; store it
           inc     r8
           ldn     rb                  ; recover byte
           ani     07fh                ; strip high bit
           smi     1                   ; reset to origin
           shl                         ; addresses are two bytes
           sex     r2                  ; point X to stack
           str     r2                  ; write offset for addtion
           ldi     low cmdvecs
           add                         ; add offset
           plo     r7
           ldi     high cmdvecs        ; high address of command vectors
           adci    0                   ; propagate carry
           phi     r7                  ; r[7] now points to command vector
           lda     r7                  ; get high byte of vector
           str     r8
           inc     r8
           lda     r7                  ; get low byte of vector
           str     r8
           inc     rb                  ; point r6 to next command
           glo     rb                  ; save RF
           stxd
           ghi     rb
           stxd
           lbr     jump
execret:   sex     r2                  ; be sure X poits to stack
           plo     r7                  ; save return code
           irx                         ; recover RF
           lda     r2
           phi     rb
           ldn     r2
           plo     rb
           glo     r7                  ; get result code
           lbz     exec                ; jump if no error
           ldi     high msempty        ; get error message
           phi     rf
           ldi     low msempty
           plo     rf
execrmsg:  sep     scall
           dw      f_msg
           sep     sret                ; return to caller

execnum:   inc     rb                  ; point to number
           ghi     rb
           phi     r7
           glo     rb
           plo     r7
           lda     r7
           phi     rb
           lda     r7
           plo     rb
           sep     scall
           dw      push
           ghi     r7
           phi     rb
           glo     r7
           plo     rb
           lbr     exec                ; execute next code
execascii: inc     rb                  ; move past ascii code
           ghi     rb                  ; transfer name to R8
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; find entry
           dw      findname
           lbnf    ascnoerr            ; jump if name was found
ascerr:    ldi     high msgerr         ; get error message
           phi     rf
           ldi     low msgerr
           plo     rf
           lbr     execrmsg
ascnoerr:  inc     r7                  ; point to type
           inc     r7
           ldn     r7                  ; get type
           smi     86h                 ; check for variable
           lbz     execvar             ; jump if so
           ldn     r7                  ; get type
           smi     87h                 ; check for function
           lbnz    ascerr              ; jump if not
           sex     r2                  ; be sure X is pointing to stack
           glo     r8                  ; save position
           stxd                        ; and store on stack
           ghi     r8
           stxd
           sep     scall               ; call exec to execute stored program
           dw      exec
           irx                         ; recover pointer
           ldxa
           phi     rb
           ldx
           plo     rb
           lbr     exec                ; and continue execution
execvar:   sep     scall               ; push var address to stack
           dw      push
           ghi     r8                  ; transfer address back to rb
           phi     rb
           glo     r8
           plo     rb
           lbr     exec                ; execute next code
           
execdn:    sep     sret                ; return to caller

error:     ldi     1                   ; indicate error
           lbr     execret             ; return to caller
good:      ldi     0                   ; indicate success
           lbr     execret             ; return to caller

;          org     600h
cdup:      sep     scall               ; pop value from forth stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           sep     scall               ; push back twice
           dw      push
           sep     scall
           dw      push
           lbr     good                ; return

cdrop:     sep     scall               ; pop value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           lbr     good                ; return
           
cplus:     sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform addition
           str     r2
           glo     rb
           add
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           adc
           phi     rb
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good
           
 
cminus:    sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform addition
           str     r2
           glo     rb
           sm
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           smb
           phi     rb
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good

cdot:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           sep     scall               ; call integer out routine
           dw      intout
           ldi     ' '                 ; need a space
           sep     scall               ; need to call character out
           dw      disp
           lbr     good                ; return

cudot:     sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           sep     scall               ; call integer out routine
           dw      uintout
           ldi     ' '                 ; need a space
           sep     scall               ; need to call character out
           dw      disp
           lbr     good                ; return

cand:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           and
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           and
           phi     rb
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good

cor:       sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           or
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           or
           phi     rb
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good

cxor:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           xor
           plo     rb
           ghi     r7
           str     r2
           ghi     rb
           xor
           phi     rb
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good

ccr:       ldi     10                  ; line feed
           sep     scall               ; call character display
           dw      disp
           ldi     13                  ; now cr
           sep     scall               ; call character display
           dw      disp
           lbr     good                ; return

cswap:     sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r8
           glo     rb
           plo     r8
           ghi     r7                  ; move number 
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; put answer back on stack
           dw      push
           ghi     r8                  ; move number 
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good                ; return

ci:        sep     scall               ; get value from return stack
           dw      rpop
           sep     scall               ; put back on return stack
           dw      rpush 
           sep     scall               ; and forth stack
           dw      push
           lbr     good                ; return to caller

cmem:      sex     r2                  ; be sure x is pointing to stack
           ldi     low freemem         ; point to free memory pointer
           plo     r9                  ; place into data frame
           lda     r9                  ; get high byte of free memory pointer
           stxd                        ; store on stack
           lda     r9                  ; get low byte
           str     r2                  ; store on stack
           ldi     low fstack          ; get pointer to stack
           plo     r9                  ; set into data frame
           inc     r9                  ; point to lo byte
           ldn     r9                  ; get it
           sm                          ; perform subtract
           plo     rb                  ; put into result
           dec     r9                  ; high byte of stack pointer
           irx                         ; point to high byte os free mem
           ldn     r9                  ; get high byte of stack
           smb                         ; continue subtraction
           phi     rb                  ; store answer
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good                ; return
 

cdo:       sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r8
           glo     rb
           plo     r8
           ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at R[6] value high
           lda     ra                  ; get high of R[6]
           phi     rb                  ; put into r6
           lda     ra
           plo     rb
           sep     scall               ; store inst point on return stack
           dw      rpush
           ghi     r8                  ; transfer termination to rb
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; store termination on return stack
           dw      rpush
           ghi     r7                  ; transfer count to rb
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; store count on return stack
           dw      rpush
           lbr     good

cloop:     sep     scall               ; get top or return stack
           dw      rpop
           inc     rb                  ; add 1 to it
loopcnt:   ghi     rb                  ; move it
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get termination
           dw      rpop
           sex     r2                  ; make sure x is pointing to stack
           glo     rb                  ; get lo of termination
           str     r2                  ; place into memory 
           glo     r7                  ; get count
           sm                          ; perform subtract
           ghi     rb                  ; get hi of termination
           str     r2                  ; place into memory
           ghi     r7                  ; get high of count
           smb                         ; continue subtract
           lbdf    cloopdn             ; jump if loop complete
           ghi     rb                  ; move termination
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; get loop address
           dw      rpop
           sep     scall               ; keep on stack as well
           dw      rpush
           ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at R[6] value high
           ghi     rb
           str     ra                  ; and write it
           inc     ra                 
           glo     rb                  ; get R[6] lo value
           str     ra                  ; and write it
           ghi     r8                  ; transfer termination
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; push onto return stack
           dw      rpush
           ghi     r7                  ; transfer count
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; push onto return stack
           dw      rpush
           lbr     good                ; and return
cloopdn:   sep     scall               ; pop off start of loop address
           dw      rpop
           lbr     good                ; and return
cploop:    sep     scall               ; get top or return stack
           dw      rpop
           sex     r2                  ; make sure X points to stack
           ghi     rb                  ; put count into memory
           stxd
           glo     rb
           stxd
           sep     scall               ; get word from data stack
           dw      pop
           lbdf    error
           irx
           glo     rb                  ; add to count
           add
           plo     rb
           ghi     rb
           irx
           adc
           phi     rb
           lbr     loopcnt             ; then standard loop code

cbegin:    ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at R[6] value high
           lda     ra                  ; get high of R[6]
           phi     rb                  ; put into r6
           lda     ra
           plo     rb
           sep     scall               ; store inst point on return stack
           dw      rpush
           lbr     good                ; and return

cuntil:    sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           glo     rb                  ; check for nonzero
           lbnz    untilyes            ; jump if non zero
           ghi     rb                  ; check high byte
           lbnz    untilyes            ; for non zero
           sep     scall               ; pop off begin address
           dw      rpop
           lbr     good                ; we are done, just return
untilyes:  sep     scall               ; get return address
           dw      rpop
           sep     scall               ; also keep on stack
           dw      rpush
           ghi     r2                  ; get copy of machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; pointing at R[6] value high
           ghi     rb
           str     ra                  ; and write it
           inc     ra                 
           glo     rb                  ; get R[6] lo value
           str     ra                  ; and write it
           lbr     good                ; now return

crgt:      sep     scall               ; get value from return stack
           dw      rpop
           sep     scall               ; push to data stack
           dw      push
           lbr     good                ; return to caller

cgtr:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           sep     scall               ; push to return stack
           dw      rpush
           lbr     good                ; return to caller

cunequal:  sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           xor
           lbnz    unequal             ; jump if not equal
           ghi     r7
           str     r2
           ghi     rb
           xor
           lbnz    unequal             ; jump if not equal
           phi     rb                  ; set return result
           plo     rb
eq2:       sep     scall               ; put answer back on stack
           dw      push
           lbr     good
unequal:   ldi     0                   ; set return result
           phi     rb
           plo     rb
           inc     rb                  ; it is now 1
           lbr     eq2

cwords:    ldi     high cmdtable       ; point to command table
           phi     r7                  ; put into a pointer register
           ldi     low cmdtable
           plo     r7
cwordslp:  lda     r7                  ; get byte
           lbz     cwordsdn            ; jump if done
           plo     rb                  ; save it
           ani     128                 ; check for final of token
           lbnz    cwordsf             ; jump if so
           glo     rb                  ; get byte
           sep     scall               ; display it
           dw      disp 
           lbr      cwordslp           ; and loop back
cwordsf:   glo     rb                  ; get byte
           ani     07fh                ; strip high bit
           sep     scall               ; display it
           dw      disp
           ldi     ' '                 ; display a space
           sep     scall               ; display it
           dw      disp
           lbr     cwordslp            ; and loop back
cwordsdn:  ldi     10
           sep     scall               ; display it
           dw      disp
           ldi     13                  ; display a space
           sep     scall               ; display it
           dw      disp
           ldi     high storage        ; get beginning of program memory
           phi     r7
           ldi     low storage
           plo     r7
cwordslp2: lda     r7                  ; get pointer to next entry
           phi     r8                  ; put into r8
           lda     r7                  ; now pointing at type indicator
           plo     r8                  ; save low of link
           lbnz    cwordsnot           ; jump if not link terminator
           ghi     r8                  ; check high byte too
           lbnz    cwordsnot
cwordsdn1: ldi     10                  ; display a space
           sep     scall               ; display it
           dw      disp
           ldi     13                  ; display a space
           sep     scall               ; display it
           dw      disp
           lbr     good                ; return to caller
cwordsnot: inc     r7                  ; now pointing at ascii indicator
           inc     r7                  ; first character of name
wordsnotl: lda     r7                  ; get byte from string
           lbz     wordsnxt            ; jump if end of string
           sep     scall               ; display it
           dw      disp
           lbr     wordsnotl           ; keep going
wordsnxt:  ldi     ' '                 ; want a space
           sep     scall               ; display it
           dw      disp
           ghi     r8                  ; transfer next word address to r7
           phi     r7
           glo     r8
           plo     r7
           lbr     cwordslp2           ; and check next word

cemit:     sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; get low of return value
           sep     scall               ; and display ti
           dw      disp
           lbr     good                ; return to caller

cwhile:    sep     scall               ; get top of stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; need to check for zero
           lbnz    whileno             ; jump if not zero
           ghi     rb                  ; check high byte
           lbnz    whileno
           ghi     r2                  ; copy machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; get command stream
           phi     rb                  ; put into r6
           ldn     ra
           plo     rb
           ldi     0                   ; set while count to zero
           plo     r7
findrep:   ldn     rb                  ; get byte from stream
           smi     81h                 ; was a while found
           lbnz    notwhile            ; jump if not
           inc     r7                  ; increment while count
notrep:    inc     rb                  ; point to next byte
           lbr     findrep             ; and keep looking
notwhile:  ldn     rb                  ; retrieve byte
           smi     82h                 ; is it a repeat
           lbnz    notrep              ; jump if not
           glo     r7                  ; get while count
           lbz     fndrep              ; jump if not zero
           dec     r7                  ; decrement count
           lbr     notrep              ; and keep looking
fndrep:    inc     rb                  ; move past the while
           glo     rb                  ; now put back into R[6]
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; then return to caller
whileno:   ghi     r2                  ; copy machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing to high byte of R[6]
           lda     ra                  ; get it
           phi     rb                  ; and put into r6
           ldn     ra                  ; get low byte
           plo     rb
           dec     rb                  ; point back to while command
           sep     scall               ; put onto return stack
           dw      rpush
           lbr     good                ; then return

crepeat:   sep     scall               ; get address on return stack
           dw      rpop
           ghi     r2                  ; transfer machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing at high byte of R[6]
           ghi     rb                  ; get while address
           str     ra                  ; and place into R[6]
           inc     ra
           glo     rb
           str     ra
           lbr     good                ; then return
           
cif:       sep     scall               ; get top of stack 
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; check for zero
           lbnz    ifno                ; jump if not zero
           ghi     rb                  ; check hi byte too
           lbnz    ifno                ; jump if not zero
           ghi     r2                  ; transfer machine stack to RA
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing at R[6]
           lda     ra                  ; get R[6]
           phi     rb
           ldn     ra
           plo     rb
           ldi     0                   ; set IF count
           plo     r7                  ; put into counter
iflp1:     ldn     rb                  ; get next byte
           smi     83h                 ; check for IF
           lbnz    ifnotif             ; jump if not
           inc     r7                  ; increment if count
ifcnt:     inc     rb                  ; point to next byte
           lbr     iflp1               ; keep looking
ifnotif:   ldn     rb                  ; retrieve byte
           smi     84h                 ; check for ELSE
           lbnz    ifnotelse           ; jump if not
           glo     r7                  ; get IF count
           lbnz    ifcnt               ; jump if it is not zero
           inc     rb                  ; move past the else
ifsave:    glo     rb                  ; store back into instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; and return
ifnotelse: ldn     rb                  ; retrieve byte
           smi     85h                 ; check for THEN
           lbnz    ifcnt               ; jump if not
           glo     r7                  ; get if count
           dec     r7                  ; decrement if count
           lbnz    ifcnt               ; jump if not zero
           lbr     ifsave              ; otherwise found
ifno:      lbr     good                ; no action needed, just return

celse:     ghi     r2                  ; transfer machine stack to ra
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; now pointing at R[6]
           lda     ra                  ; get current R[6]
           phi     rb                  ; and place into r6
           ldn     ra
           plo     rb
           ldi     0                   ; count of IFs
           plo     r7                  ; put into R7
elselp1:   ldn     rb                  ; get next byte from stream
           smi     83h                 ; check for IF
           lbnz    elsenif             ; jump if not if
           inc     r7                  ; increment IF count
elsecnt:   inc     rb                  ; point to next byte
           lbr     elselp1             ; keep looking
elsenif:   ldn     rb                  ; retrieve byte
           smi     85h                 ; is it THEN
           lbnz    elsecnt             ; jump if not
           glo     r7                  ; get IF count
           dec     r7                  ; minus 1 IF
           lbnz    elsecnt             ; jump if not 0
           glo     rb                  ; put into instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; now pointing at a then

cthen:     lbr     good                ; then is nothing but a place holder

cequal:    sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump if stack was empty
           ghi     rb                  ; move number 
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get next number
           dw      pop
           lbdf    error               ; jump if stack was empty
           sex     r2                  ; be sure X points to stack
           glo     r7                  ; perform and
           str     r2
           glo     rb
           xor
           lbnz    unequal2            ; jump if not equal
           ghi     r7
           str     r2
           ghi     rb
           xor
           lbnz    unequal2            ; jump if not equal
           phi     rb                  ; set return result
           plo     rb
           inc     rb
eq3:       sep     scall               ; put answer back on stack
           dw      push
           lbr     good
unequal2:  ldi     0                   ; set return result
           phi     rb
           plo     rb
           lbr     eq3

cdepth:    sex     r2                  ; be sure x is pointing to stack
           ldi     low fstack          ; point to free memory pointer
           plo     r9                  ; place into data frame
           lda     r9                  ; get high byte of free memory pointer
           stxd                        ; store on stack
           lda     r9                  ; get low byte
           str     r2                  ; store on stack
           ldi     low tos             ; get pointer to stack
           plo     r9                  ; set into data frame
           inc     r9                  ; point to lo byte
           ldn     r9                  ; get it
           sm                          ; perform subtract
           plo     rb                  ; put into result
           dec     r9                  ; high byte of stack pointer
           irx                         ; point to high byte os free mem
           ldn     r9                  ; get high byte of stack
           smb                         ; continue subtraction
           shr                         ; divide by 2
           phi     rb                  ; store answer
           glo     rb                  ; propagate the shift
           shrc
           plo     rb
           sep     scall               ; put answer back on stack
           dw      push
           lbr     good                ; return
 
crot:      sep     scall               ; get C
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get B
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; get A
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     rc
           glo     rb
           plo     rc
           ghi     r8                  ; get B
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     r7                  ; get C
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     rc                  ; get A
           phi     rb
           glo     rc
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           lbr     good                ; return to caller
 
cmrot:     sep     scall               ; get C
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get B
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; get A
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     rc
           glo     rb
           plo     rc
           ghi     r7                  ; get C
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     rc                  ; get A
           phi     rb
           glo     rc
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     r8                  ; get B
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           lbr     good                ; return to caller
 
cover:     sep     scall               ; get B
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get A
           dw      pop
           lbdf    error               ; jump if error
           ghi     rb                  ; transfer to R*
           phi     r8
           glo     rb
           plo     r8
           sep     scall               ; put onto stack
           dw      push
           ghi     r7                  ; get B
           phi     rb
           glo     r7
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           ghi     r8                  ; get A
           phi     rb
           glo     r8
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           lbr     good                ; return to caller
           
cat:       sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           lda     r7                  ; get word at address
           phi     rb
           ldn     r7
           plo     rb
           sep     scall               ; put onto stack
           dw      push
           lbr     good                ; return to caller
           
cexcl:     sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; date data word from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; write word to memory
           str     r7
           inc     r7
           glo     rb
           str     r7
           lbr     good                ; and return
           
ccat:      sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           lda     r7                  ; get word at address
           plo     rb
           ldi     0                   ; high byte is zero
           phi     rb
           sep     scall               ; put onto stack
           dw      push
           lbr     good                ; return to caller
           
ccexcl:    sep     scall               ; get address from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer address
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; date data word from stack
           dw      pop
           lbdf    error               ; jump on error
           glo     rb                  ; write byte to memory
           str     r7
           lbr     good                ; and return

cvariable: ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
varlp1:    lda     rb                  ; get byte
           lbnz    varlp1              ; jump if terminator not found
           inc     rb                  ; allow space for var value
           inc     rb                  ; new value of freemem
           ldi     low freemem         ; get current free memory pointer
           plo     r9                  ; put into data segment
           lda     r9                  ; get current pointer
           phi     r7                  ; place here
           ldn     r9                  ; get low byte
           plo     r7
           ghi     rb                  ; get memory pointer
           str     r7                  ; and store into link list
           inc     r7
           glo     rb
           str     r7
           glo     rb                  ; store new freemem value
           str     r9
           dec     r9
           ghi     rb
           str     r9
           ldi     0                   ; need zero at end of list
           str     rb                  ; store it
           inc     rb
           str     rb
           glo     rb                  ; write back to instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; return

ccolon:    ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
colonlp1:  lda     rb                  ; get byte
           smi     88h                 ; look for the ;
           lbnz    colonlp1            ; jump if terminator not found
           ldi     0                   ; want a command terminator
           str     rb                  ; write it
           inc     rb                  ; new value for freemem
           ldi     low freemem         ; get current free memory pointer
           plo     r9                  ; put into data segment
           lda     r9                  ; get current pointer
           phi     r7                  ; place here
           ldn     r9                  ; get low byte
           plo     r7
           ghi     rb                  ; get memory pointer
           str     r7                  ; and store into link list
           inc     r7
           glo     rb
           str     r7
           glo     rb                  ; store new freemem value
           str     r9
           dec     r9
           ghi     rb
           str     r9
           ldi     0                   ; need zero at end of list
           str     rb                  ; store it
           inc     rb
           str     rb
           glo     rb                  ; write back to instruction pointer
           str     ra
           dec     ra
           ghi     rb
           str     ra
           lbr     good                ; return

csemi:     lbr     good

csee:      ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     r8
           ldn     ra
           plo     r8
           ldn     r8                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     r8                  ; move into string
           sep     scall               ; find the name
           dw      findname
           lbdf    error               ; jump if not found
           glo     r8                  ; put new address into inst pointer
           str     ra 
           dec     ra
           ghi     r8
           str     ra
           inc     r7                  ; move past lind address
           inc     r7
           ldn     r7                  ; get type byte
           smi     86h                 ; check for variable
           lbnz    cseefunc            ; jump if not
           lda     rb                  ; get value
           phi     r7
           lda     rb
           plo     rb
           ghi     r7
           phi     rb
           sep     scall               ; display the value
           dw      intout
seeexit:   ldi     10                  ; display cr/lf
           sep     scall
           dw      disp
           ldi     13                  ; display cr/lf
           sep     scall
           dw      disp
           lbr     good                ; otherwise good
cseefunc:  ldi     ':'                 ; start with a colon
           sep     scall               ; display character
           dw      disp
           inc     r7                  ; move address to name
seefunclp: ldi     ' '                 ; need a spae
           sep     scall               ; display character
           dw      disp
           ldn     r7                  ; get next token
           lbz     seeexit             ; jump if done
           smi     T_ASCII             ; check for ascii
           lbnz    seenota             ; jump if not ascii
           inc     r7                  ; move into string
seestrlp:  ldn     r7                  ; get next byte
           lbz     seenext             ; jump if done with token
           sep     scall               ; display character
           dw      disp
           inc     r7                  ; point to next character
           lbr     seestrlp            ; and continue til done
seenext:   inc     r7                  ; point to next token
           lbr     seefunclp
seenota:   ldn     r7                  ; reget token
           smi     T_NUM               ; is it a number
           lbnz    seenotn             ; jump if not a number
           inc     r7                  ; move past token
           lda     r7                  ; get number into rb
           phi     rb
           ldn     r7
           plo     rb
           glo     r7                  ; save r7
           stxd
           ghi     r7
           stxd
           sep     scall               ; display the number
           dw      intout
           irx                         ; retrieve r7
           ldxa
           phi     r7
           ldx
           plo     r7
           lbr     seenext             ; on to next token
seenotn:   ldi     high cmdtable       ; point to command table
           phi     rb
           ldi     low cmdtable
           plo     rb
           ldn     r7                  ; get token
           ani     07fh                ; strip high bit
           plo     r8                  ; token counter
seenotnlp: dec     r8                  ; decrement count
           glo     r8                  ; get count
           lbz     seetoken            ; found the token
seelp3:    lda     rb                  ; get byte from token
           ani     128                 ; was it last one?
           lbnz    seenotnlp           ; jump if it was
           lbr     seelp3              ; keep looking
seetoken:  ldn     rb                  ; get byte from token
           ani     128                 ; is it last
           lbnz    seetklast           ; jump if so
           ldn     rb                  ; retrieve byte
           sep     scall               ; display it
           dw      disp
           inc     rb                  ; point to next character
           lbr     seetoken            ; and loop til done
seetklast: ldn     rb                  ; retrieve byte
           ani     07fh                ; strip high bit
           sep     scall               ; display it
           dw      disp
           lbr     seenext             ; jump for next token

cdotqt:    ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     r8
           ldn     ra
           plo     r8
           ldn     r8                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     r8                  ; move past ascii mark
cdotqtlp:  lda     r8                  ; get next byte
           lbz     cdotqtdn            ; jump if terinator
           smi     34                  ; check for quote
           lbz     cdotqtlp            ; do not display quotes
           dec     r8
           lda     r8
           sep     scall               ; display byte
           dw      disp
           lbr     cdotqtlp            ; loop back
cdotqtdn:  glo     r8                  ; put pointer back
           str     ra
           dec     ra
           ghi     r8
           str     ra
           lbr     good                ; and return

ckey:      sep     scall               ; go and get a key
           dw      getkey
           plo     rb                  ; put into r6
           ldi     0                   ; zero the high byte
           phi     rb
           sep     scall               ; place key on the stack
           dw      push
           lbr     good                ; then return to caller

callot:    ldi     high storage        ; get address of storage
           phi     r7
           ldi     low storage
           plo     r7
callotlp1: lda     r7                  ; get next link
           phi     r8
           ldn     r7
           plo     r8
           lda     r8                  ; get value at that link
           phi     rb
           ldn     r8
           dec     r8                  ; keep r8 pointing at link
           lbnz    callotno            ; jump if next link is not zero
           ghi     rb                  ; check high byte
           lbnz    callotno            ; jump if not zero
           lbr     callotyes
callotno:  ghi     r8                  ; transfer link to r7
           phi     r7
           glo     r8
           plo     r7
           lbr     callotlp1           ; and keep looking
callotyes: inc     r7                  ; point to type byte
           ldn     r7                  ; get it
           smi     FVARIABLE           ; it must be a variable
           lbnz    error               ; jump if not
           sep     scall               ; get word from stack
           dw      pop
           lbdf    error               ; jump if error
           glo     rb                  ; multiply by 2
           shl
           plo     rb
           ghi     rb
           shlc
           phi     rb
           sex     r2                  ; be sure X points to stack
           glo     rb                  ; add r6 to r8
           str     r2
           glo     r8
           add
           plo     r8
           ghi     rb
           str     r2
           ghi     r8
           adc
           phi     r8
           dec     r7                  ; point back to link
           glo     r8                  ; and write new pointer
           str     r7
           dec     r7
           ghi     r8
           str     r7
           ldi     low freemem         ; need to adjust free memory pointer
           plo     r9                  ; put into data frame
           ghi     r8                  ; and save new memory position
           str     r9
           inc     r9
           glo     r8
           str     r9
           ldi     0                   ; zero new position
           str     r8
           inc     r8
           str     r8
           lbr good

cmul:      sep     scall               ; get first value from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer to r7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get second number
           dw      pop
           lbdf    error               ; jump on error
           sep     scall               ; call multiply routine
           dw      mul16
           sep     scall               ; push onto stack
           dw      push
           lbr     good                ; return

cdiv:      sep     scall               ; get first value from stack
           dw      pop
           lbdf    error               ; jump on error
           ghi     rb                  ; transfer to r7
           phi     r7
           glo     rb
           plo     r7
           sep     scall               ; get second number
           dw      pop
           lbdf    error               ; jump on error
           sex     r2
           ghi     r9
           stxd
           sep     scall               ; call multiply routine
           dw      div16
           irx
           ldx
           phi     r9
           ghi     rc                  ; transfer answer
           phi     rb
           glo     rc
           plo     rb
           sep     scall               ; push onto stack
           dw      push
           lbr     good                ; return

cforget:   ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     r8
           ldn     ra
           plo     r8
           ldn     r8                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     r8                  ; move into string
           sep     scall               ; find the name
           dw      findname
           lbdf    error               ; jump if not found
           glo     r8
           str     ra
           dec     ra
           ghi     r8
           str     ra
           lda     r7                  ; get next entry
           phi     rb
           ldn     r7
           plo     rb
           dec     r7
           sex     r2                  ; be sure X is pointing to stack
           glo     r7                  ; find difference in pointers
           str     r2
           glo     rb
           sm
           plo     rc
           ghi     r7
           str     r2
           ghi     rb
           smb
           phi     rc                  ; RC now has offset, RB is next descr.
forgetlp1: lda     rb                  ; get pointer
           phi     ra                  ; put into ra
           str     r2
           ldn     rb
           plo     ra
           or                          ; see if it was zero
           lbz     forgetd1            ; jump if it was
           glo     rc                  ; subtract RC from RA
           str     r2
           glo     ra
           sm
           str     rb                  ; store back into pointer
           dec     rb
           ghi     rc
           str     r2
           ghi     ra
           smb
           str     rb
           ghi     ra                  ; transfer value
           phi     rb
           glo     ra
           plo     rb
           lbr     forgetlp1           ; loop until done

forgetd1:  lda     r7                  ; get next entry
           phi     rb
           ldn     r7
           plo     rb
           dec     r7

           ldi     low freemem         ; get end of memory pointer
           plo     r9                  ; and place into data frame
           lda     r9                  ; get free memory position
           phi     r8
           ldn     r9
           plo     r8
           inc     r8                  ; account for zero bytes at end
           inc     r8
           glo     rb                  ; subtract R6 from R8
           str     r2
           glo     r8
           sm
           plo     r8
           ghi     rb
           str     r2
           ghi     r8
           smb
           phi     r8                  ; r8 now has number of bytes to move
forgetlp:  lda     rb                  ; get byte from higher memory
           str     r7                  ; write to lower memory
           inc     r7                  ; point to next position
           dec     r8                  ; decrement the count
           glo     r8                  ; check for zero
           lbnz    forgetlp
           ghi     r8
           lbnz    forgetlp
           dec     r7                  ; move back to freemem position
           dec     r7 
           glo     r7                  ; store back into freemem pointer
           str     r9
           dec     r9
           ghi     r7
           str     r9
           lbr     good                ; and return

cerror:    sep     scall               ; get number fro stack
           dw      pop
           lbdf    error               ; jump on error
           glo     rb                  ; get returned value
           lbr     execret             ; return to caller

cout:      sep     scall               ; get value from stack
           dw      pop
           lbdf    error               ; jump on error
           glo     rb
           plo     r8                  ; hold onto it
           sep     scall               ; get port value
           dw      pop
           lbdf    error               ; jump on error
           glo     r8                  ; get vlue
           stxd                        ; store into memory for out
           irx                         ; point to value
           glo     rb                  ; get port
           smi     1                   ; try port 1
           lbnz    cout2               ; jump if not
           out     1                   ; prform out
           dec     r2                  ; move pointer back
           lbr     good                ; and return to caller
cout2:     smi     1                   ; try port 1
           lbnz    cout3               ; jump if not
           out     2                   ; prform out
           dec     r2                  ; move pointer back
           lbr     good                ; and return to caller
cout3:     smi     1                   ; try port 1
           lbnz    cout4               ; jump if not
           out     3                   ; prform out
           dec     r2                  ; move pointer back
           lbr     good                ; and return to caller
cout4:     smi     1                   ; try port 1
           lbnz    cout5               ; jump if not
           out     4                   ; prform out
           dec     r2                  ; move pointer back
           lbr     good                ; and return to caller
cout5:     smi     1                   ; try port 1
           lbnz    cout6               ; jump if not
           out     5                   ; prform out
           dec     r2                  ; move pointer back
           lbr     good                ; and return to caller
cout6:     smi     1                   ; try port 1
           lbnz    cout7               ; jump if not
           out     6                   ; prform out
           dec     r2                  ; move pointer back
           lbr     good                ; and return to caller
cout7:     smi     1                   ; try port 1
           lbnz    cout8               ; jump if not
           out     7                   ; prform out
           dec     r2                  ; move pointer back
cout8:     lbr     good                ; and return to caller

cinp:      sep     scall               ; get port
           dw      pop
           lbdf    error               ; jump on error
           glo     rb                  ; get port
           smi     1                   ; check port 1
           lbnz    cinp2               ; jump if not
           inp     1                   ; read port
           lbr     cinpd               ; complete
cinp2:     smi     1                   ; check port 1
           lbnz    cinp3               ; jump if not
           inp     2                   ; read port
           lbr     cinpd               ; complete
cinp3:     smi     1                   ; check port 1
           lbnz    cinp4               ; jump if not
           inp     3                   ; read port
           lbr     cinpd               ; complete
cinp4:     smi     1                   ; check port 1
           lbnz    cinp5               ; jump if not
           inp     4                   ; read port
           lbr     cinpd               ; complete
cinp5:     smi     1                   ; check port 1
           lbnz    cinp6               ; jump if not
           inp     5                   ; read port
           lbr     cinpd               ; complete
cinp6:     smi     1                   ; check port 1
           lbnz    cinp7               ; jump if not
           inp     6                   ; read port
           lbr     cinpd               ; complete
cinp7:     smi     1                   ; check port 1
           lbnz    error               ; jump if not
           inp     7                   ; read port
cinpd:     plo     rb                  ; prepare to put on stack
           ldi     0
           phi     rb
           sep     scall               ; push onto stack
           dw      push
           lbr     good

cef:       ldi     0                   ; start with zero
           bn1     cef1                ; jump if ef1 not on
           ori     1                   ; signal ef1 is on
cef1:      bn2     cef2                ; jump if ef2 ot on
           ori     2                   ; signal ef2 is on
cef2:      bn3     cef3                ; jump if ef3 not on
           ori     4                   ; signal ef3 is on
cef3:      bn4     cef4                ; jump if ef4 not on
           ori     8
cef4:      plo     rb                  ; prepare to put on stack
           ldi     0
           phi     rb
           sep     scall               ; push onto stack
           dw      push
           lbr     good

cstk:      mov     rb,fstack           ; get stack address
           sep     scall               ; push onto stack
           dw      push
           lbr     good
          
#ifdef ANYROM
csave:     push    rf                  ; save consumed registers
           push    rc
           sep     scall               ; open XMODEM channel for writing
           dw      xopenw
           mov     rf,freemem          ; need pointer to freemem
           lda     rf                  ; get high address of free memory
           smi     3                   ; subtract base address
           phi     rc                  ; store into count
           ldn     rf                  ; get low byte of free memory
           plo     rc                  ; store into count
           inc     rc                  ; account for terminator
           inc     rc
           mov     rf,buffer           ; temporary storage
           ghi     rc                  ; get high byte of count
           str     rf                  ; store it
           inc     rf                  ; point to low byte
           glo     rc                  ; get it
           str     rf                  ; store into buffer
           dec     rf                  ; move back to buffer
           mov     rc,2                ; 2 bytes of length
           sep     scall               ; write to XMODEM channel
           dw      xwrite
           mov     rf,buffer           ; point to where count is
           lda     rf                  ; retrieve high byte
           phi     rc                  ; set into count for write
           ldn     rf                  ; get low byte
           plo     rc                  ; rc now has count of bytes to save
           mov     rf,himem            ; point to forth data
           sep     scall               ; write it all out
           dw      xwrite
           sep     scall               ; close XMODEM channel
           dw      xclosew
           pop     rc                  ; recover consumed registers
           pop     rf
           lbr     good                ; all done
#endif

#ifdef ELFOS
csave:     ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
           sep     scall               ; setup file descriptor
           dw      setupfd
           ghi     rb                  ; get filename
           phi     rf
           glo     rb
           plo     rf
           ldi     1                   ; create if nonexistant
           plo     r7
           sep     scall               ; open the file
           dw      o_open
           ldi     high freemem        ; point to control data
           phi     rf
           ldi     low freemem
           plo     rf
           ldi     0                   ; need to write 2 bytes
           phi     rc
           ldi     2
           plo     rc
           sep     scall               ; write the control block
           dw      o_write
           ldi     high storage        ; point to data storage
           phi     rf
           stxd                        ; store copy on stack for sub
           ldi     low storage
           plo     rf
           str     r2
           ldi     low freemem         ; pointer to free memory
           plo     r9                  ; put into data segment pointer
           inc     r9                  ; point to low byte 
           ldn     r9                  ; retrieve low byte 
           sm                          ; subtract start address
           plo     rc                  ; and place into count
           irx                         ; point to high byte
           dec     r9
           ldn     r9                  ; get high byte of free mem
           smb                         ; subtract start
           phi     rc                  ; place into count
           inc     rc                  ; account for terminator
           inc     rc
           sep     scall               ; write the data block
           dw      o_write
           sep     scall               ; close the file
           dw      o_close
           ldi     0                   ; terminate command
           dec     rb
           str     rb
           lbr     good                ; return
#endif

#ifdef ANYROM
cload:     push    rf                  ; save consumed registers
           push    rc
           sep     scall               ; open XMODEM channel for reading
           dw      xopenr
           mov     rf,buffer           ; point to buffer
           mov     rc,2                ; need to read 2 bytes
           sep     scall               ; read them
           dw      xread
           mov     rf,buffer           ; point to buffer
           lda     rf                  ; retrieve count
           phi     rc                  ; into rc
           ldn     rf
           plo     rc                  ; rc now has count of bytes to read
           mov     rf,himem            ; point to forth data
           sep     scall               ; now read program data
           dw      xread
           sep     scall               ; close XMODEM channel
           dw      xcloser
           pop     rc                  ; recover consumed registers
           pop     rf
           irx                         ; remove exec portions from stack
           irx
           irx
           irx
           lbr     mainlp              ; back to main loop
#endif

#ifdef ELFOS
cload:     ghi     r2                  ; transfer machine stack
           phi     ra
           glo     r2
           plo     ra
           inc     ra                  ; point to R[6]
           lda     ra                  ; and retrieve it
           phi     rb
           ldn     ra
           plo     rb
           ldn     rb                  ; get next byte
           smi     T_ASCII             ; it must be an ascii mark
           lbnz    error               ; jump if not
           inc     rb                  ; move into string
           sep     scall               ; setup file descriptor
           dw      setupfd
           ghi     rb                  ; get filename
           phi     rf
           glo     rb
           plo     rf
           ldi     0                   ; create if nonexistant
           plo     r7
           sep     scall               ; open the file
           dw      o_open
           lbdf    error               ; jump if file is not opened
           ldi     high freemem        ; point to control data
           phi     rf
           ldi     low freemem
           plo     rf
           ldi     0                   ; need to read 2 bytes
           phi     rc
           ldi     2
           plo     rc
           sep     scall               ; read the control block
           dw      o_read
           ldi     high storage        ; point to data storage
           phi     rf
           stxd                        ; store copy on stack for sub
           ldi     low storage
           plo     rf
           str     r2
           ldi     low freemem         ; pointer to free memory
           plo     r9                  ; put into data segment pointer
           inc     r9                  ; point to low byte 
           ldn     r9                  ; retrieve low byte 
           sm                          ; subtract start address
           plo     rc                  ; and place into count
           irx                         ; point to high byte
           dec     r9
           ldn     r9                  ; get high byte of free mem
           smb                         ; subtract start
           phi     rc                  ; place into count
           inc     rc                  ; account for terminator
           inc     rc
           sep     scall               ; read the data block
           dw      o_read
           sep     scall               ; close the file
           dw      o_close
           irx                         ; remove exec portions from stack
           irx
           irx
           irx
           lbr     mainlp              ; back to main loop
#endif

#ifdef ELFOS
cbye:      lbr     O_WRMBOOT           ; return to os
#endif

#ifdef ANYROM
cbye:      lbr     08003h              ; return to menu
#endif

#ifdef ELFOS
setupfd:   ldi     high fildes         ; get address of file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           inc     rd                  ; point to dta entry
           inc     rd
           inc     rd
           inc     rd
           ldi     high dta            ; get address of dta
           str     rd                  ; and store it
           inc     rd
           ldi     low dta
           str     rd
           ldi     high fildes         ; get address of file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           sep     sret                ; return to caller
#endif


; **********************************************************
; ***** Convert string to uppercase, honor quoted text *****
; **********************************************************
touc:      ldn     rf                  ; check for quote
           smi     022h
           lbz     touc_qt             ; jump if quote
           ldn     rf                  ; get byte from string
           lbz     touc_dn             ; jump if done
           smi     'a'                 ; check if below lc
           lbnf    touc_nxt            ; jump if so
           smi     27                  ; check upper rage
           lbdf    touc_nxt            ; jump if above lc
           ldn     rf                  ; otherwise convert character to lc
           smi     32
           str     rf
touc_nxt:  inc     rf                  ; point to next character
           lbr     touc                ; loop to check rest of string
touc_dn:   sep     sret                ; return to caller
touc_qt:   inc     rf                  ; move past quote
touc_qlp:  lda     rf                  ; get next character
           lbz     touc_dn             ; exit if terminator found
           smi     022h                ; check for quote charater
           lbz     touc                ; back to main loop if quote
           lbr     touc_qlp            ; otherwise keep looking


hello:     db      'Rc/Forth 0.1'
crlf:      db       10,13,0
prompt:    db      'ok ',0
msempty:   db      'stack empty',10,13,0
msgerr:    db      'err',10,13,0
cmdtable:  db      'WHIL',('E'+80h)
           db      'REPEA',('T'+80h)
           db      'I',('F'+80h)
           db      'ELS',('E'+80h)
           db      'THE',('N'+80h)
           db      'VARIABL',('E'+80h)
           db      (':'+80h)
           db      (';'+80h)
           db      'DU',('P'+80h)
           db      'DRO',('P'+80h)
           db      'SWA',('P'+80h)
           db      ('+'+80h)
           db      ('-'+80h)
           db      ('*'+80h)
           db      ('/'+80h)
           db      ('.'+80h)
           db      'U',('.'+80h)
           db      ('I'+80h)
           db      'AN',('D'+80h)
           db      'O',('R'+80h)
           db      'XO',('R'+80h)
           db      'C',('R'+80h)
           db      'ME',('M'+80h)
           db      'D',('O'+80h)
           db      'LOO',('P'+80h)
           db      '+LOO',('P'+80h)
           db      ('='+80h)
           db      '<',('>'+80h)
           db      'BEGI',('N'+80h)
           db      'UNTI',('L'+80h)
           db      'R',('>'+80h)
           db      '>',('R'+80h)
           db      'WORD',('S'+80h)
           db      'EMI',('T'+80h)
           db      'DEPT',('H'+80h)
           db      'RO',('T'+80h)
           db      '-RO',('T'+80h)
           db      'OVE',('R'+80h)
           db      ('@'+80h)
           db      ('!'+80h)
           db      'C',('@'+80h)
           db      'C',('!'+80h)
           db      '.',(34+80h)
           db      'KE',('Y'+80h)
           db      'ALLO',('T'+80h)
           db      'ERRO',('R'+80h)
           db      'SE',('E'+80h)
           db      'FORGE',('T'+80h)
           db      'OU',('T'+80h)
           db      'IN',('P'+80h)
           db      'E',('F'+80h)
           db      'SAV',('E'+80h)
           db      'LOA',('D'+80h)
           db      'BY',('E'+80h)
           db      'ST',('K'+80h)
           db      0                   ; no more tokens
cmdvecs:   dw      cwhile              ; 81h
           dw      crepeat             ; 82h
           dw      cif                 ; 83h
           dw      celse               ; 84h
           dw      cthen               ; 85h
           dw      cvariable           ; 86h
           dw      ccolon              ; 87h
           dw      csemi               ; 88h
           dw      cdup                ; 89h
           dw      cdrop               ; 8ah
           dw      cswap               ; 8bh
           dw      cplus               ; 8ch
           dw      cminus              ; 8dh
           dw      cmul
           dw      cdiv
           dw      cdot                ; 8eh
           dw      cudot               ; 8fh
           dw      ci                  ; 90h
           dw      cand                ; 91h
           dw      cor                 ; 92h
           dw      cxor                ; 93h
           dw      ccr                 ; 94h
           dw      cmem                ; 95h
           dw      cdo                 ; 96h
           dw      cloop               ; 97h
           dw      cploop              ; 98h
           dw      cequal              ; 99h
           dw      cunequal            ; 9ah
           dw      cbegin              ; 9bh
           dw      cuntil              ; 9ch
           dw      crgt                ; 9dh
           dw      cgtr                ; 9eh
           dw      cwords              ; 9fh
           dw      cemit               ; a0h
           dw      cdepth              ; a1h
           dw      crot                ; a2h
           dw      cmrot               ; a3h
           dw      cover               ; a4h
           dw      cat                 ; a5h
           dw      cexcl               ; a6h
           dw      ccat                ; a7h
           dw      ccexcl              ; a8h
           dw      cdotqt              ; a9h
           dw      ckey
           dw      callot
           dw      cerror
           dw      csee                ; aah
           dw      cforget             ; abh
           dw      cout                ; ach
           dw      cinp                ; adh
           dw      cef                 ; aeh
           dw      csave               ; afh
           dw      cload               ; b0h
           dw      cbye
           dw      cstk                ; b1h

endrom:    equ     $

#ifdef ELFOS
rstack:    dw      0
tos:       dw      0
freemem:   dw      storage
fstack:    dw      0
himem:     dw      0
jump:      ds      3
fildes:    ds      20
dta:       ds      512
buffer:    ds      256
storage:   dw      0
#endif

           end     start

