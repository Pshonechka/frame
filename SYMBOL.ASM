.286
.model tiny
.code
org 100h

locals @@
;160*(height/2) + 80-LenCmd
; [00110010][][][]...{ [10][5] } ...
;			90
;[][][][][][][][][][][][][][][][]

VIDEOSEG   		  equ 0b800h
STRBEFORE  		  equ 0
LENCMDADR    	  equ 80h
LENGTHFR          equ 30
HEIGHTFR          equ 7


Start:	mov ax, VIDEOSEG
		mov es, ax

		mov si, 82h

		call Top
		call Bottom
		call Left
		call Right

		call PrintCmdLine

		mov ax, 4c00h
		int 21h
; Start -> ... save data, helping actions -> main { ... }

;//////////////////////////////////////////////////////////////////////////////




;//////////////////////////////////////////////////////////////////////////////
; prints command line
; src: bx - absolute (n*length_of_screen + shift)
; change: cx, bx
Cmdline proc

	mov di, LENCMDADR
	mov byte ptr cl, [di]
	sub cx, 1

; while(addr[i] != 0) { addr[i] = pixel; addr++ }
L:	mov al, ds: [si]
	add si, 1

	mov es:[bx], ax
	add bx, 2

	LOOP L

	ret
	endp

;//////////////////////////////////////////////////////////////////////////////

PrintCmdLine    proc

				mov di, LENCMDADR
				mov byte ptr cl, [di]
				sub cx, 1

				mov bx, 80
				sub bx, cx

				add bx, 160*3

				call CmdLine

				ret
				endp

;//////////////////////////////////////////////////////////////////////////////

; SymbN -- prints symbol N times

; entry: cx - N times
;      	 al - ascii code of symbol
;	 ah - color of symbol
;	 bx - place where prints absolute
; kill:   cx, bx = bx + cx

SymbN   proc

; for (i = N; i > 0; i--) { addr[i] = pixel  }
M:	mov es:[bx], ax
	add bx, 2

	LOOP M

	ret
	endp

;//////////////////////////////////////////////////////////////////////////////
;<.........> - 1
;{...1ss...} - 2
;{...sss...} - 2
;(.........) - 3

Top     proc
		mov cx, LENGTHFR

		mov bx, 80
		sub bx, cx

		mov al, 201
		mov ah, 5fh or 80h

		mov es:[bx], ax ;top left angle
	    add bx, 2

		mov al, 196
		mov ah, 5fh or 80h
		sub cx, 2
		call SymbN
		mov al, 187
		mov ah, 5fh or 80h

		mov es:[bx], ax ;top right angle
	    add bx, 2

		ret
		endp


;//////////////////////////////////////////////////////////////////////////////

Bottom  proc
		mov cx, LENGTHFR

		mov bx, 80
		sub bx, cx
		mov cx, HEIGHTFR
		sub cx, 1

		mov ax, 160
		mul cx

		;mov cx, 640
		add bx, ax

		mov cx, LENGTHFR


		   ;add bx, 640 ;4*160
		;mov bx, 610;(hight-1)*160 - len

		mov al, 200
		mov ah, 5fh or 80h

		mov es:[bx], ax ;bottom left angle
	    add bx, 2

		mov al, 205
		mov ah, 5fh or 80h
		sub cx, 2
		call SymbN
		mov al, 188
		mov ah, 5fh or 80h

		mov es:[bx], ax ;bottom right angle
	    add bx, 2

		ret
		endp

;//////////////////////////////////////////////////////////////////////////////

Left    proc
		mov cx, LENGTHFR

		mov bx, 80
		sub bx, cx

		add bx, 160

		mov al, 03h
		mov ah, 5fh or 80h

		mov cx, LENGTHFR
		sub cx, 2

		mov al, 03h
		mov ah, 5fh or 80h

N:	    mov es:[bx], ax
		add bx, 160

		LOOP N

		ret
		endp

;//////////////////////////////////////////////////////////////////////////////

Right   proc
		mov cx, LENGTHFR

		mov bx, 80
		add bx, cx
		add bx, 160
		sub bx, 2

		mov cx, HEIGHTFR
		sub cx, 2

		mov al, 03h
		mov ah, 5fh or 80h

R:	    mov es:[bx], ax
		add bx, 160

		LOOP R

		ret
		endp


;//////////////////////////////////////////////////////////////////////////////

end    	 Start

