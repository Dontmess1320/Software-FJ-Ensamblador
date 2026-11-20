; 03_CONTADOR.ASM - Cuenta hexadecimal 0h..Fh usando LOOP
.MODEL SMALL
.STACK 100h
.DATA
 titulo DB 13,10,'=== CONTADOR PROGRESIVO EN BASE 16 ===',13,10,'$'
 nueva DB 13,10,'$'
.CODE
PUBLIC INICIO
INICIO:
 mov ax,@DATA
 mov ds,ax
 lea dx,titulo
 mov ah,09h
 int 21h
 mov bl,0
 mov cx,16
SIGUIENTE:
 mov dl,bl
 cmp dl,9
 jbe ES_NUMERO
 add dl,7
ES_NUMERO:
 add dl,'0'
 mov ah,02h
 int 21h
 mov dl,'h'
 mov ah,02h
 int 21h
 mov dl,' '
 mov ah,02h
 int 21h
 inc bl
 cmp bl,8
 jne SIN_SALTO
 lea dx,nueva
 mov ah,09h
 int 21h
SIN_SALTO:
 loop SIGUIENTE
 lea dx,nueva
 mov ah,09h
 int 21h
 mov ax,4C00h
 int 21h
END INICIO
