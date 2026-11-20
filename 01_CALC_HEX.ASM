; 01_CALC_HEX.ASM - Calculadora de bytes hexadecimales (MASM/TASM, DOS)
.MODEL SMALL
.STACK 100h
.DATA
 titulo DB 13,10,'=== CALCULADORA HEXADECIMAL (8 BITS) ===',13,10,'$'
 msg1 DB 'Primer byte (00-FF): $'
 msg2 DB 13,10,'Segundo byte (00-FF): $'
 msgOp DB 13,10,'Operador (+ o -): $'
 msgError DB 13,10,'Entrada invalida. Vuelva a intentarlo.',13,10,'$'
 msgRes DB 13,10,'Resultado de 8 bits: $'
 msgCarry DB 13,10,'Acarreo (CF): $'
 msgBorrow DB 13,10,'Prestamo (CF): $'
 msgFin DB 13,10,'$'
 entrada DB 4,0,4 DUP(0)
 num1 DB ?
 num2 DB ?
 operador DB ?
 resultado DB ?
 bandera DB 0
.CODE
PUBLIC INICIO
INICIO:
 mov ax,@DATA
 mov ds,ax
 lea dx,titulo
 call Escribir
 lea dx,msg1
 call Escribir
 call LeerByteHex
 mov num1,al
 lea dx,msg2
 call Escribir
 call LeerByteHex
 mov num2,al
LEER_OPERADOR:
 lea dx,msgOp
 call Escribir
 lea dx,entrada
 mov ah,0Ah
 int 21h
 cmp BYTE PTR [entrada+1],1
 jne OP_INVALIDO
 mov al,[entrada+2]
 cmp al,'+'
 je OP_OK
 cmp al,'-'
 je OP_OK
OP_INVALIDO:
 lea dx,msgError
 call Escribir
 jmp LEER_OPERADOR
OP_OK:
 mov operador,al
 mov bandera,0
 mov al,num1
 cmp operador,'+'
 je SUMAR
 sub al,num2
 jnc GUARDAR_RESULTADO
 mov bandera,1
 jmp GUARDAR_RESULTADO
SUMAR:
 add al,num2
 jnc GUARDAR_RESULTADO
 mov bandera,1
GUARDAR_RESULTADO:
 mov resultado,al
 lea dx,msgRes
 call Escribir
 mov al,resultado
 call ImprimirByteHex
 cmp operador,'+'
 je MOSTRAR_ACARREO
 lea dx,msgBorrow
 jmp MOSTRAR_BANDERA
MOSTRAR_ACARREO:
 lea dx,msgCarry
MOSTRAR_BANDERA:
 call Escribir
 mov dl,bandera
 add dl,'0'
 mov ah,02h
 int 21h
 lea dx,msgFin
 call Escribir
 mov ax,4C00h
 int 21h

; Escribe cadena terminada en '$', direccion en DX
Escribir PROC
 mov ah,09h
 int 21h
 ret
Escribir ENDP

; Entrada DOS 0Ah: lee una linea y exige exactamente 2 digitos hex.
; Devuelve byte en AL. Si es invalido, solicita otra vez.
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

; Convierte AL ('0'-'9', 'A'-'F', 'a'-'f') a valor 0..15.
; CF=0 si valido; CF=1 si no valido.
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
