; 02_MASCARAS.ASM - AND, OR y XOR en un byte (MASM/TASM, DOS)
.MODEL SMALL
.STACK 100h
.DATA
 titulo DB 13,10,'=== OPERADOR DE MASCARAS LOGICAS ===',13,10,'$'
 msgValor DB 'Byte inicial (00-FF): $'
 msgMascara DB 13,10,'Mascara (00-FF): $'
 msgOp DB 13,10,'Operacion (AND, OR, XOR): $'
 msgError DB 13,10,'Dato invalido. Intente nuevamente.',13,10,'$'
 msgBin DB 13,10,'Resultado binario (8 bits): $'
 msgHex DB 13,10,'Resultado hexadecimal: $'
 nueva DB 13,10,'$'
 entrada DB 5,0,5 DUP(0)
 numero DB ?
 mascara DB ?
 resultado DB ?
 operador DB ? ; 1=AND, 2=OR, 3=XOR
.CODE
PUBLIC INICIO
INICIO:
 mov ax,@DATA
 mov ds,ax
 lea dx,titulo
 call Escribir
 lea dx,msgValor
 call Escribir
 call LeerByteHex
 mov numero,al
 lea dx,msgMascara
 call Escribir
 call LeerByteHex
 mov mascara,al
LEER_OP:
 lea dx,msgOp
 call Escribir
 lea dx,entrada
 mov ah,0Ah
 int 21h
 cmp BYTE PTR [entrada+1],2
 je COMPROBAR_OR
 cmp BYTE PTR [entrada+1],3
 jne OP_ERR
 ; Aceptar AND / XOR sin importar mayusculas/minusculas
 mov al,[entrada+2]
 and al,0DFh
 mov bl,[entrada+3]
 and bl,0DFh
 mov cl,[entrada+4]
 and cl,0DFh
 cmp al,'A'
 jne COMPROBAR_XOR
 cmp bl,'N'
 jne COMPROBAR_XOR
 cmp cl,'D'
 jne COMPROBAR_XOR
 mov operador,1
 jmp OP_LISTA
COMPROBAR_XOR:
 cmp al,'X'
 jne OP_ERR
 cmp bl,'O'
 jne OP_ERR
 cmp cl,'R'
 jne OP_ERR
 mov operador,3
 jmp OP_LISTA
COMPROBAR_OR:
 mov al,[entrada+2]
 and al,0DFh
 mov bl,[entrada+3]
 and bl,0DFh
 cmp al,'O'
 jne OP_ERR
 cmp bl,'R'
 jne OP_ERR
 mov operador,2
 jmp OP_LISTA
OP_ERR:
 lea dx,msgError
 call Escribir
 jmp LEER_OP
OP_LISTA:
 mov al,numero
 cmp operador,1
 je HACER_AND
 cmp operador,2
 je HACER_OR
 xor al,mascara
 jmp MOSTRAR
HACER_AND:
 and al,mascara
 jmp MOSTRAR
HACER_OR:
 or al,mascara
MOSTRAR:
 mov resultado,al
 lea dx,msgBin
 call Escribir
 mov al,resultado
 call ImprimirBinario
 lea dx,msgHex
 call Escribir
 mov al,resultado
 call ImprimirByteHex
 lea dx,nueva
 call Escribir
 mov ax,4C00h
 int 21h

Escribir PROC
 mov ah,09h
 int 21h
 ret
Escribir ENDP

LeerByteHex PROC
PREGUNTAR:
 lea dx,entrada
 mov ah,0Ah
 int 21h
 cmp BYTE PTR [entrada+1],2
 jne BYTE_INVALIDO
 mov al,[entrada+2]
 call HexANibble
 jc BYTE_INVALIDO
 mov bl,al
 shl bl,1
 shl bl,1
 shl bl,1
 shl bl,1
 mov al,[entrada+3]
 call HexANibble
 jc BYTE_INVALIDO
 or al,bl
 ret
BYTE_INVALIDO:
 lea dx,msgError
 call Escribir
 jmp PREGUNTAR
LeerByteHex ENDP

HexANibble PROC
 cmp al,'0'
 jb NIB_INVALIDO
 cmp al,'9'
 jbe NIB_NUMERO
 cmp al,'A'
 jb NIB_MINUSCULA
 cmp al,'F'
 jbe NIB_MAYUSCULA
NIB_MINUSCULA:
 cmp al,'a'
 jb NIB_INVALIDO
 cmp al,'f'
 ja NIB_INVALIDO
 sub al,'a'-10
 clc
 ret
NIB_MAYUSCULA:
 sub al,'A'-10
 clc
 ret
NIB_NUMERO:
 sub al,'0'
 clc
 ret
NIB_INVALIDO:
 stc
 ret
HexANibble ENDP

; Desplaza BL ocho veces; imprime cada bit de MSB a LSB.
ImprimirBinario PROC
 push ax
 push bx
 push cx
 push dx
 mov bl,al
 mov cx,8
OTRO_BIT:
 shl bl,1
 mov dl,'0'
 jnc MOSTRAR_BIT
 mov dl,'1'
MOSTRAR_BIT:
 mov ah,02h
 int 21h
 loop OTRO_BIT
 pop dx
 pop cx
 pop bx
 pop ax
 ret
ImprimirBinario ENDP

ImprimirByteHex PROC
 push ax
 push bx
 mov bl,al
 shr al,1
 shr al,1
 shr al,1
 shr al,1
 call ImprimirNibble
 mov al,bl
 and al,0Fh
 call ImprimirNibble
 pop bx
 pop ax
 ret
ImprimirByteHex ENDP
ImprimirNibble PROC
 push ax
 push dx
 cmp al,9
 jbe NIB_DIGITO
 add al,7
NIB_DIGITO:
 add al,'0'
 mov dl,al
 mov ah,02h
 int 21h
 pop dx
 pop ax
 ret
ImprimirNibble ENDP
END INICIO
