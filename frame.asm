;.286
.model tiny
.data
	top_symbols    db 201, 196, 187
	bottom_symbols db 200, 205, 188
    left_symbol    db 03h
    right_symbol   db 03h

.code

org 100h

locals @@

VIDEO_SEG              equ 0b800h
STR_BEFORE  	       equ 0
LEN_CMD_ADR    	       equ 80h
LENGTH_FRAME           equ 20
HEIGHT_FRAME           equ 7
CENTER_OF_SCREEN       equ 80
WIDTH_OF_SCREEN	       equ 160
COLOR                  equ 5fh or 80h


Start:	mov ax, VIDEO_SEG
		mov es, ax


		call ShiftLeftTop
        mov dx, offset top_symbols
		call Horizontal

        call ShiftLeftBottom
        mov dx, offset bottom_symbols
        call Horizontal

        call GetShiftLeft
        mov al, left_symbol
        call Vertical

        call GetShiftRight
        mov al, right_symbol
        call Vertical

		call PutCmdLineInCenter

		mov ax, 4c00h
		int 21h
; Start -> ... save data, helping actions -> main { ... }

;//////////////////////////////////////////////////////////////////////////////




;//////////////////////////////////////////////////////////////////////////////

; PrintCmdline -- prints command line

; src: bx - absolute (n*length_of_screen + shift)
; change: di, cx, bx = bx + cx

PrintCmdline 		proc

					mov di, LEN_CMD_ADR
					mov byte ptr cl, [di]
					sub cx, 1

					mov si, 82h
					mov ah, COLOR

					; for (i = N; i > 0; i--) { addr[i] = pixel[i] }
@@NextSymbol:		mov al, ds: [si]
					add si, 1

					mov es: [bx], ax
					add bx, 2

					LOOP @@NextSymbol

					ret
					endp

;//////////////////////////////////////////////////////////////////////////////

; PrintCmdline -- prints command line in the center of frame

; change: di, cx, bx

PutCmdLineInCenter  proc

					mov di, LEN_CMD_ADR
					mov byte ptr cl, [di]

					cmp cx, 0
					je Finish

     				sub cx, 1 ;for space

					test cx, 1
					JZ @@Chetnoe
					add cx, 1

@@Chetnoe:			mov bx, CENTER_OF_SCREEN
					sub bx, cx

                    mov ax, HEIGHT_FRAME
                    shr ax, 1

                    mov cx, WIDTH_OF_SCREEN
                    mul cx

					add bx, ax

					call PrintCmdLine

Finish:				ret
					endp

;//////////////////////////////////////////////////////////////////////////////

; SymbN -- prints symbol N times

; src:      cx - N times
;        	al - ascii code of symbol
;	 	    ah - color of symbol
;		    bx - place where prints absolute
; change:   cx, bx = bx + cx

SymbN   			proc

					; for (i = N; i > 0; i--) { addr[i] = pixel  }
@@NextSymbol:	    mov es:[bx], ax
					add bx, 2

					LOOP @@NextSymbol

					ret
					endp

;//////////////////////////////////////////////////////////////////////////////


; Horizontal -- prints horizontal parts of frame + angles

; src:      dx - pointer to array with ascii codes of 3 symb
;           bx - position
; change:   si, ax, cx, bx = bx + 2 * cx

Horizontal          proc

                    mov si, dx
                    mov al, [si]
					mov ah, COLOR
					mov es:[bx], ax ;top left angle
	    			add bx, 2

					inc si
                    mov al, [si]
                    mov cx, LENGTH_FRAME
					sub cx, 2
					call SymbN

					inc si
                    mov al, [si]
					mov es:[bx], ax ;top right angle
	    			add bx, 2

					ret
					endp


;//////////////////////////////////////////////////////////////////////////////

; Vertical -- prints vertical parts of frame

; src:      al - ascii code of symbol
;           bx - position
; change:   si, ax, cx, bx = bx + 2 * cx

Vertical    	    proc

					mov cx, HEIGHT_FRAME
					sub cx, 2 ;without angles

					mov al, 03h
					mov ah, COLOR

@@NextSymbol:	    mov es:[bx], ax
					add bx, WIDTH_OF_SCREEN

					LOOP @@NextSymbol

					ret
					endp



;//////////////////////////////////////////////////////////////////////////////

; GetShiftRight -- records offset in bx - center - length of frame

; change: cx, bx bx = center - cx

GetShiftRight    	proc

					mov cx, LENGTH_FRAME
					test cx, 1
					JZ @@Chetnoe
					sub cx, 1

@@Chetnoe:			mov bx, CENTER_OF_SCREEN
					add bx, cx

                    add bx, WIDTH_OF_SCREEN
					sub bx, 2

					ret
					endp


;//////////////////////////////////////////////////////////////////////////////

; GetShiftLeft -- records offset in bx - center + length of frame

; change: cx, bx = center + cx


GetShiftLeft    	proc

					call ShiftLeftTop

                    add bx, WIDTH_OF_SCREEN


					ret
					endp

;//////////////////////////////////////////////////////////////////////////////

; GetShiftLeft -- records offset in bx - center + length of frame

; change: cx, bx = center + cx

ShiftLeftTop  	    proc

					mov bx, CENTER_OF_SCREEN
					mov cx, LENGTH_FRAME
					test cx, 1
					JZ @@Chetnoe
					add cx, 1

@@Chetnoe:			sub bx, cx

					ret
					endp


;//////////////////////////////////////////////////////////////////////////////

ShiftLeftBottom     proc

                    Call ShiftLeftTop

					mov cx, HEIGHT_FRAME
					sub cx, 1

					mov ax, WIDTH_OF_SCREEN
					mul cx
					add bx, ax

					mov cx, LENGTH_FRAME

					test cx, 1
					JZ @@Chetnoe
					add cx, 1

@@Chetnoe:			ret
                    endp

;//////////////////////////////////////////////////////////////////////////////

end    	 Start

