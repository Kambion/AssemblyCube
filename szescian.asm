.386
rozkazy SEGMENT use16
ASSUME cs:rozkazy
rysuj_piksel PROC ;AX = y, BX = x
	push ax
	push bx
	push dx
	push es
	mov dx, 0A000H ; adres pamiêci ekranu dla trybu 13H
	mov es, dx
	mul cs:szerokosc
	add bx, ax
	cmp bx, 320*200
	jae skip
	mov al, cs:kolor
	mov es:[bx], al
	skip:
	pop es
	pop dx
	pop bx
	pop ax
	ret
	szerokosc dw 320
	kolor db 14
rysuj_piksel ENDP

wyczysc PROC
	push bx
	push es

	mov bx, 0A000H ; adres pamiêci ekranu dla trybu 13H
	mov es, bx

	mov bx, 0

	czysc:
		mov es:[bx], dword PTR 0
		add bx, 4
	cmp bx, 320*200
	jb czysc

	pop es
	pop bx
	ret
wyczysc ENDP


rysuj_linie PROC ;x1, x2, y1, y2
	push ax
	push bx
	push cx

	mov ax, cs:x1
	cmp ax, cs:x2
	jbe dalejX
	xchg ax, cs:x2
	xchg ax, cs:x1
	mov ax, cs:y1
	xchg ax, cs:y2
	xchg ax, cs:y1
	dalejX:

	mov ax, cs:x1
	cmp ax, cs:x2
	je pionowa


	finit

	fild word PTR cs:y1
	fild word PTR cs:x2
	fmulp st(1), st(0)
	fild word PTR cs:y2
	fild word PTR cs:x1
	fmulp st(1), st(0)
	fsubp st(1), st(0)
	fild word PTR cs:x2
	fild word PTR cs:x1
	fsubp st(1), st(0)
	fdivp st(1), st(0)
	fist word PTR cs:wsp_b

	fild word PTR cs:y2
	fild word PTR cs:y1
	fsubp st(1), st(0)
	fild word PTR cs:x2
	fild word PTR cs:x1
	fsubp st(1), st(0)

	fdivp st(1), st(0) ;y/x

	mov ax, cs:x2
	sub ax, cs:x1

	mov cx, ax
	mov bx, cs:x1
	linia:
		mov cs:temp, bx
		fild word PTR cs:temp
		fmul st(0), st(1)
		fistp word PTR cs:temp
		mov ax, cs:temp
		add ax, cs:wsp_b
		call rysuj_piksel	
		inc bx
	loop linia
	jmp zakoncz

	pionowa:
	mov bx, cs:x1
	mov ax, cs:y1
	linia_pionowa:
	call rysuj_piksel
	inc ax
	cmp ax, cs:y2
	jne linia_pionowa
	call rysuj_piksel	
	zakoncz:
	pop cx
	pop bx
	pop ax
	ret
	x1 dw ?
	x2 dw ?
	y1 dw ?
	y2 dw ?
	temp dw ?
	wsp_b dw ?
rysuj_linie ENDP

rzutuj_punkt PROC
	push ax
	push bx

	mov ax, cs:punkt_x
	mov cs:wynik_x, ax

	finit
	fild word PTR cs:punkt_y
	fld dword PTR cs:tan
	fild word PTR cs:punkt_z
	fmulp st(1), st(0)
	fsubp st(1), st(0)
	fist word PTR cs:wynik_y

	mov bx, cs:wynik_x
	mov ax, cs:wynik_y

	call rysuj_piksel	

	pop bx
	pop ax
	ret
	tan dd 0.26
	punkt_x dw ?
	punkt_y dw ?
	punkt_z dw ?
	wynik_x dw ?
	wynik_y dw ?
rzutuj_punkt ENDP

rotuj PROC
	
	finit
	fild word PTR cs:promien
	fld dword PTR cs:kat
	fldpi
	fld dword PTR cs:dwa
	fdivp st(1), st(0)
	faddp st(1), st(0)
	fsin	
	fmulp st(1), st(0)
	fild word PTR cs:pol_x
	faddp st(1), st(0)
	fistp word PTR cs:rot_x

	fild word PTR cs:promien
	fld dword PTR cs:kat
	fsin	
	fmulp st(1), st(0)
	fild word PTR cs:pol_z
	faddp st(1), st(0)
	fistp word PTR cs:rot_z

	ret
	pol_x dw 160
	pol_z dw 100
	kat dd 0.1
	dwa dd 2.0
	promien dw 50
	rot_x dw ?
	rot_z dw ?
	aktualny_kat dd 0.1
rotuj ENDP

wyznacz_punkty PROC
	push ax
	push bx
	push cx

	finit

	mov eax, cs:aktualny_kat
	mov cs:kat, eax
	call rotuj
	mov ax, cs:rot_z
	mov bx, cs:rot_x
	mov cs:punkt_x, bx
	mov cs:punkt_z, ax
	mov cs:punkt_y, 50
	call rzutuj_punkt	
	mov ax, cs:wynik_y
	mov bx, cs:wynik_x
	mov cs:p_x1, bx
	mov cs:p_y1, ax
	;call rysuj_piksel	


	fld dword PTR cs:kat
	fldpi
	fld dword PTR cs:dwa
	fdivp st(1), st(0)
	faddp st(1), st(0)
	fstp dword PTR cs:kat

	call rotuj
	mov ax, cs:rot_z
	mov bx, cs:rot_x
	mov cs:punkt_x, bx
	mov cs:punkt_z, ax
	mov cs:punkt_y, 50
	call rzutuj_punkt	
	mov ax, cs:wynik_y
	mov bx, cs:wynik_x
	mov cs:p_x2, bx
	mov cs:p_y2, ax
	;call rysuj_piksel		

	fld dword PTR cs:kat
	fldpi
	fld dword PTR cs:dwa
	fdivp st(1), st(0)
	faddp st(1), st(0)
	fstp dword PTR cs:kat

	call rotuj
	mov ax, cs:rot_z
	mov bx, cs:rot_x
	mov cs:punkt_x, bx
	mov cs:punkt_z, ax
	mov cs:punkt_y, 50
	call rzutuj_punkt	
	mov ax, cs:wynik_y
	mov bx, cs:wynik_x
	mov cs:p_x3, bx
	mov cs:p_y3, ax
	;call rysuj_piksel

	fld dword PTR cs:kat
	fldpi
	fld dword PTR cs:dwa
	fdivp st(1), st(0)
	faddp st(1), st(0)
	fstp dword PTR cs:kat

	call rotuj
	mov ax, cs:rot_z
	mov bx, cs:rot_x
	mov cs:punkt_x, bx
	mov cs:punkt_z, ax
	mov cs:punkt_y, 50
	call rzutuj_punkt	
	mov ax, cs:wynik_y
	mov bx, cs:wynik_x
	mov cs:p_x4, bx
	mov cs:p_y4, ax
	;call rysuj_piksel


	pop cx
	pop bx
	pop ax
	ret
	p_x1 dw ?
	p_x2 dw ?
	p_x3 dw ?
	p_x4 dw ?
	p_y1 dw ?
	p_y2 dw ?
	p_y3 dw ?
	p_y4 dw ?
wyznacz_punkty ENDP

rysuj PROC
	push ax
	push bx
	push cx

	cmp cs:bazgraj, 0
	je nie_bazgraj

	finit

	call wyczysc	

	call wyznacz_punkty	

	call rysuj_szescian	
	
	;inc cs:kolor


	finit
	fld dword PTR cs:kat
	fld dword PTR cs:step
	faddp st(1), st(0)
	fstp dword PTR cs:aktualny_kat

	mov cs:bazgraj, 0
	nie_bazgraj:

	pop cx
	pop bx
	pop ax
	jmp dword PTR cs:wektor8
	bazgraj db 0
	wektor8 dd ?
	step dd 0.1
rysuj ENDP

rysuj_szescian PROC
	push ax

	mov ax, cs:p_x1
	mov cs:x1, ax
	mov ax, cs:p_y1 ;p1 - p2
	mov cs:y1, ax
	mov ax, cs:p_y2
	mov cs:y2, ax
	mov ax, cs:p_x2
	mov cs:x2, ax
	call rysuj_linie
	mov ax, cs:p_x3
	mov cs:x1, ax
	mov ax, cs:p_y3 ;p2 - p3
	mov cs:y1, ax
	mov ax, cs:p_y2
	mov cs:y2, ax
	mov ax, cs:p_x2
	mov cs:x2, ax
	call rysuj_linie
	mov ax, cs:p_x3
	mov cs:x1, ax
	mov ax, cs:p_y3 ;p3 - p4
	mov cs:y1, ax
	mov ax, cs:p_y4
	mov cs:y2, ax
	mov ax, cs:p_x4
	mov cs:x2, ax
	call rysuj_linie
	mov ax, cs:p_x1
	mov cs:x1, ax
	mov ax, cs:p_y1 ;p1 - p4
	mov cs:y1, ax
	mov ax, cs:p_y4
	mov cs:y2, ax
	mov ax, cs:p_x4
	mov cs:x2, ax
	call rysuj_linie

	mov ax, cs:p_x1
	mov cs:x1, ax
	mov ax, cs:p_y1 ;p5 - p6
	add ax, 50
	mov cs:y1, ax
	mov ax, cs:p_y2
	add ax, 50
	mov cs:y2, ax
	mov ax, cs:p_x2
	mov cs:x2, ax
	call rysuj_linie
	mov ax, cs:p_x3
	mov cs:x1, ax
	mov ax, cs:p_y3 ;p6 - p7
	add ax, 50
	mov cs:y1, ax
	mov ax, cs:p_y2
	add ax, 50
	mov cs:y2, ax
	mov ax, cs:p_x2
	mov cs:x2, ax
	call rysuj_linie
	mov ax, cs:p_x3
	mov cs:x1, ax
	mov ax, cs:p_y3 ;p7 - p8
	add ax, 50
	mov cs:y1, ax
	mov ax, cs:p_y4
	add ax, 50
	mov cs:y2, ax
	mov ax, cs:p_x4
	mov cs:x2, ax
	call rysuj_linie
	mov ax, cs:p_x1
	mov cs:x1, ax
	mov ax, cs:p_y1 ;p5 - p8
	add ax, 50
	mov cs:y1, ax
	mov ax, cs:p_y4
	add ax, 50
	mov cs:y2, ax
	mov ax, cs:p_x4
	mov cs:x2, ax
	call rysuj_linie


	mov ax, cs:p_x1
	mov cs:x1, ax
	mov ax, cs:p_y1 ;p1 - p5
	mov cs:y1, ax
	mov ax, cs:p_x1
	mov cs:x2, ax
	mov ax, cs:p_y1 
	add ax, 50
	mov cs:y2, ax
	call rysuj_linie
	mov ax, cs:p_x2
	mov cs:x1, ax
	mov ax, cs:p_y2 ;p2 - p6
	mov cs:y1, ax
	mov ax, cs:p_x2
	mov cs:x2, ax
	mov ax, cs:p_y2 
	add ax, 50
	mov cs:y2, ax
	call rysuj_linie
	mov ax, cs:p_x3
	mov cs:x1, ax
	mov ax, cs:p_y3 ;p3 - p7
	mov cs:y1, ax
	mov ax, cs:p_x3
	mov cs:x2, ax
	mov ax, cs:p_y3 
	add ax, 50
	mov cs:y2, ax
	call rysuj_linie
	mov ax, cs:p_x4
	mov cs:x1, ax
	mov ax, cs:p_y4 ;p4 - p8
	mov cs:y1, ax
	mov ax, cs:p_x4
	mov cs:x2, ax
	mov ax, cs:p_y4 
	add ax, 50
	mov cs:y2, ax
	call rysuj_linie

	pop ax
	ret
rysuj_szescian ENDP


; INT 10H, funkcja nr 0 ustawia tryb sterownika graficznego
zacznij:
	mov ah, 0
	mov al, 13H ; nr trybu
	int 10H

	mov bx, 0
	mov es, bx ; zerowanie rejestru ES
	mov eax, es:[32] ; odczytanie wektora nr 8
	mov cs:wektor8, eax; zapamiêtanie wektora nr 8

	mov ax, SEG rysuj
	mov bx, OFFSET rysuj
	cli ; zablokowanie przerwañ
	; zapisanie adresu procedury 'linia' do wektora nr 8
	mov es:[32], bx
	mov es:[32+2], ax
	sti ; odblokowanie przerwañ



	aktywne_oczekiwanie:
	mov ah,1
	int 16H
	; funkcja INT 16H (AH=1) BIOSu ustawia ZF=1 jeœli
	; naciœniêto jakiœ klawisz
	jz aktywne_oczekiwanie
	; odczytanie kodu ASCII naciœniêtego klawisza (INT 16H, AH=0)
	; do rejestru AL
	mov cs:bazgraj, 1
	mov ah, 0
	int 16H
	cmp al, 'x' ; porównanie z kodem litery 'm'
	jne aktywne_oczekiwanie ; skok, gdy inny znak

	mov ah, 0 ; funkcja nr 0 ustawia tryb sterownika
	mov al, 3H ; nr trybu
	int 10H
	; odtworzenie oryginalnej zawartoœci wektora nr 8
	
	mov bx, 0
	mov es, bx ; zerowanie rejestru ES
	mov eax, cs:wektor8
	cli
	mov es:[32], eax
	sti
	; zakoñczenie wykonywania programu
	mov ax, 4C00H
	int 21H
	rozkazy ENDS
	stosik SEGMENT stack
	db 256 dup (?)
	stosik ENDS
END zacznij