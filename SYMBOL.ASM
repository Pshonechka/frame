;.286
.model tiny
.data
	top_symbols    db 201, 196, 187
	bottom_symbols db 200, 205, 188
.code
org 100h

locals @@

VIDEO_SEG              equ 0b800h
STR_BEFORE  	       equ 0
LEN_CMD_ADR    	       equ 80h
LENGTH_FRAME           equ 30
HEIGHT_FRAME           equ 7
CENTER_OF_SCREEN       equ 80
WIDTH_OF_SCREEN	       equ 160
COLOR                  equ 5fh or 80h


Start:	mov ax, VIDEO_SEG
		mov es, ax

		mov si, 82h



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

					mov es:[bx], ax
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
					JZ Chetnoe
					add cx, 1

Chetnoe:			mov bx, CENTER_OF_SCREEN
					sub bx, cx

					add bx, WIDTH_OF_SCREEN*3 ;//TODO: replace

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

; Top -- prints top part of frame + top angles

; change:   ax, cx, bx = bx + 2 * cx

Top     proc

					Call GetShiftLeft

					mov al, 201
					mov ah, COLOR
					mov es:[bx], ax ;top left angle
	    			add bx, 2

					mov al, 196
					mov ah, COLOR
					sub cx, 2
					call SymbN

					mov al, 187
					mov ah, COLOR
					mov es:[bx], ax ;top right angle
	    			add bx, 2

					ret
					endp


;//////////////////////////////////////////////////////////////////////////////

; Bottom -- prints bottom part of frame + bottom angles

; change:   ax, cx, bx = bx + 2 * cx

Bottom  			proc

					Call GetShiftLeft

					mov cx, HEIGHT_FRAME
					sub cx, 1

					mov ax, WIDTH_OF_SCREEN
					mul cx

					;mov cx, 640
					add bx, ax

					mov cx, LENGTH_FRAME


		   			;add bx, 640 ;4*160
					;mov bx, 610;(hight-1)*160 - len

					mov al, 200
					mov ah, COLOR
					mov es:[bx], ax ;bottom left angle
	    			add bx, 2

					mov al, 205
					mov ah, COLOR
					sub cx, 2
					call SymbN

					mov al, 188
					mov ah, COLOR
					mov es:[bx], ax ;bottom right angle
	    			add bx, 2

					ret
					endp

;//////////////////////////////////////////////////////////////////////////////

Left    			proc

					Call GetShiftLeft

					add bx, WIDTH_OF_SCREEN

					mov cx, HEIGHT_FRAME
					sub cx, 2

					mov al, 03h
					mov ah, COLOR

@@NextSymbol:	    mov es:[bx], ax
					add bx, WIDTH_OF_SCREEN

					LOOP @@NextSymbol

					ret
					endp

;//////////////////////////////////////////////////////////////////////////////



Right   			proc

					Call GetShiftRight

					add bx, WIDTH_OF_SCREEN
					sub bx, 2

					mov cx, HEIGHT_FRAME
					sub cx, 2  ;without angles

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
					mov bx, CENTER_OF_SCREEN
					add bx, cx

					ret
					endp

;//////////////////////////////////////////////////////////////////////////////

; GetShiftLeft -- records offset in bx - center + length of frame

; change: cx, bx = center + cx

GetShiftLeft  	   proc

					mov cx, LENGTH_FRAME
					mov bx, CENTER_OF_SCREEN
					sub bx, cx

					ret
					endp

;//////////////////////////////////////////////////////////////////////////////

end    	 Start

