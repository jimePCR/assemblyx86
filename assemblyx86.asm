stacksg segment para stack 'stack'
	dw 100 dup(0)
stacksg ends

datasg segment para 'data'
	mens1 db 'F1: Menu$'
	mens2 db 'F2: Cambiar atributo F5: Limpiar pantalla F10: Terminar el programa$'
	atributo db 07
datasg ends

codesg segment para 'code'
	assume cs:codesg, ds:datasg, ss:stacksg
princi proc far

inicio: push ds
	xor ax,ax
	push ax
	mov ax,datasg
	mov ds,ax
	call limpiar
	call centro

	ciclo: xor ax,ax
	int 16h ;realiza lectura 
	cmp al,0
	je flechas

	;Backspace, borra caracter.
	cmp ah,0EH
	jne enter
	call borrar
	jmp ciclo

	;ENTER
	enter: cmp ah,1CH
	jne caracter
	call salto
	call abajo
	jmp ciclo

	;Lee las letras que sean tecleadas 
	caracter: call imprime
	jmp fin

	;lectura de las flechas
	flechas: call flecha

	;Muestra el menu en linea 24
	cmp ah,3bH
	jne cambia_atributo
	call mostar_menu
	jmp ciclo

	;Cambiar el atributo con F2
	cambia_atributo:cmp ah,3Ch
	jne pantalla
	inc atributo
	jmp ciclo

	;limpiar pantalla con F5
	pantalla: cmp ah,3Fh
	jne fin
	call limpiar
	call centro
	jmp ciclo

	;Termina el programa con F10
	fin: cmp ah,44h
	jne ciclo
	ret
princi endp

;Limpia la pantalla
limpiar proc
	mov ah,0h
	mov al,03h
	int 10h
	mov cx,101h
	mov ah,1h
	int 10h
	mov ah,2h
	mov bh,0
	xor dx,dx
	int 10h
	mov ax,0600h
	mov bh,07h
	xor cx,cx
	mov dx,184Fh
	int 10h
	push dx
	mov dh,24
	mov dl,0
	mov bh,0
	mov ah,02H
	int 10H
	lea dx,mens1
	call escribe_cad
	pop dx
	ret
limpiar endp

;manda al cursor al centro de la pantalla
centro proc
	mov dh,12
	mov dl,39
	mov bh,0
	mov ah,02H
	int 10H
	ret
centro endp

busca proc ; busca y lee la posición del cursor
mov ah,03H
xor bh,bh
int 10H
ret
busca endp

;colocación del cursor de acuerdo a dh y dl
coloca_cur proc
	push ax
	push bx
	push cx
	push dx
	mov bh,0
	mov ah,02
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
coloca_cur endp

borrar proc ;efectúa la acción de borrar con Backspace
	push ax
	call izquierda
	mov al,20h
	mov ah,09h
	mov bh,0
	mov bl,07
	mov cx,1
	int 10H
	pop ax
	ret
borrar endp

;Salto de linea con enter
salto proc
	push ax
	mov ah,0eh
	int 10H
	pop ax
	ret
salto endp

imprime proc
	push ax
	mov ah,09h
	mov bh,0
	mov bl,atributo
	mov cx,1
	int 10H
	call derecha
	pop ax
	ret
imprime endp

;Escritura de cadena
escribe_cad proc
	push ax
	push bx
	push cx
	push dx
	mov ah,9
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
escribe_cad endp

escribe_a proc
	push ax
	push bx
	push cx
	push dx
	mov ah,2
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
escribe_a endp

;saltos de linea
ali_lin proc
	push dx
	mov dl,0ah
	call escribe_a
	mov dl,0dh
	call escribe_a
	pop dx
	ret
ali_lin endp

;censa por las flechas
flecha proc 
	push ax
	cmp ah,48H
	jne sigue
	call arriba
	jmp regresa

	sigue: cmp ah,50H
	jne sigue1
	call abajo
	jmp regresa

	sigue1:
	cmp ah,4DH
	jne sigue2
	call derecha
	jmp regresa

	sigue2: cmp ah,4BH
	jne regresa
	call izquierda
	
	regresa: pop ax
	ret
flecha endp


;Uso de las flechas
arriba proc
	call busca
	cmp dh,0
	je acomoda_b
	dec dh
	mov ah,02
	int 10H
	jmp fin_a
	acomoda_b:mov dh,23
	call coloca_cur
	fin_a: ret
arriba endp

abajo proc
	call busca
	cmp dh,23
	je acomoda_n
	inc dh
	mov ah,02
	int 10H
	jmp fin_ab
	acomoda_n:mov dh,0
	call coloca_cur
	fin_ab: ret	
abajo endp

derecha proc
	call busca
	cmp dl,79
	je 	acomoda_i
	inc dl
	mov ah,02
	int 10H
	jmp fin_d
	acomoda_i:mov dl,0
	call coloca_cur
	fin_d: ret	
derecha endp

izquierda proc
	call busca
	cmp dl,0
	je 	acomoda_d
	dec dl
	mov ah,02
	int 10H
	jmp fin_i
	acomoda_d: mov dl,79
	call coloca_cur
	fin_i: ret	
izquierda endp
;Ultima funcion de flechas


;impresion de menu
mostar_menu proc
	push ax
	push dx
	call limpiar
	;push dx
	mov dh,24
	mov dl,0
	mov bh,0
	mov ah,02H
	int 10H
	lea dx,mens2
	call escribe_cad
	call centro
	;pop dx
	pop dx
	pop ax
	ret
mostar_menu endp

codesg ends
end inicio
end