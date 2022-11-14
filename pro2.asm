.MODEL SMALL
.STACK 100H

.DATA
ruta DB 'C:\IMAGEN.IER',0
ruta2 DB 'C:\IMAGEN2.IER',0
girarmsg DB 'GIRAR$'
salirmsg DB 'SALIR$'
guardarmsg DB 'GUARDAR$'
cargarmsg DB 'CARGAR$'
espejomsg DB 'REFLEJO$'
invertirmsg DB 'INVERTIR$'
char DB ?
color DB ?
opcion db 0
fila DW 0
columna DW 0
cont DW 0
handler DW ?

print macro texto
mov ah, 9
mov dx, offset texto
int 21h
endm

.CODE
main proc
mov ax,@DATA
mov ds, ax

call ini

mov ax, 0
int 33h

mov ax, 1
int 33h

call pintacuad

call botones

call botonesclick

call valores

call leerarchi

call creararchi

call guardarcarac

.exit

endp main

botonesclick proc
  ciclobotones:
    mov ax, 3
    int 33h

    mov columna, cx
    mov fila, dx

    cmp bx, 1
    je lados
    jmp ciclobotones

  lados:
    cmp columna, 501D
    jae filasabajo
    jmp ciclobotones

  filasabajo:
    cmp fila, 45D
    jbe ciclobtn
    cmp fila, 100D
    jbe ciclobtn
    cmp fila, 155D
    jbe ciclobtn
    cmp fila, 210D
    jbe ciclobtn
    cmp fila, 265D
    jbe ciclobtn
    cmp fila, 320D
    jbe ciclobtn
    jmp ciclobotones

  ciclobtn:
    cmp fila, 10D
    jae ciclobtn1
    cmp fila, 65D
    jae ciclobtn2
    cmp fila, 120D
    jae ciclobtn3
    cmp fila, 175D
    jae ciclobtn4
    cmp fila, 230D
    jae ciclobtn5
    cmp fila, 285D
    jae ciclobtn6
    jmp ciclobotones
  
  ciclobtn1:
    mov opcion, 1D
    jmp salirbotonesclick
  ciclobtn2:
    mov opcion, 2D
    jmp salirbotonesclick
  ciclobtn3:
    mov opcion, 3D
    jmp salirbotonesclick
  ciclobtn4:
    mov opcion, 4D
    jmp salirbotonesclick
  ciclobtn5:
    mov opcion, 5D
    jmp salirbotonesclick
  ciclobtn6:
    mov opcion, 6D
    jmp salirbotonesclick

  salirbotonesclick:
    ret
endp

opcioncargar proc
  mov ah, 0Fh     ; LIMPIA PANTALLA.
  INT 10H
  mov ah, 0
  INT 10h

  mov opcion, 5D
  call valores
  call leerarchi

  ret
endp

opciongirar proc
  mov ah, 0Fh     ; LIMPIA PANTALLA.
  INT 10H
  mov ah, 0
  INT 10h

  mov opcion, 1D
  call valores
  call leerarchi

  ret
endp

opcionreflejo proc
  mov ah, 0Fh     ; LIMPIA PANTALLA.
  INT 10H
  mov ah, 0
  INT 10h

  mov opcion, 2D
  call valores
  call leerarchi

  ret
endp

opcioninvertir proc
  mov ah, 0Fh     ; LIMPIA PANTALLA.
  INT 10H
  mov ah, 0
  INT 10h

  mov opcion, 3D
  call valores
  call leerarchi

  ret
endp

leerarchi proc
  ;lee el archivo
  mov ah, 3fh
  mov bx, handler
  mov dx, offset char
  mov cx, 1
  int 21H

  cmp ax, 0

  cmp char, 64 ; Compara el caracter con @ para salto de linea
  je salta

  cmp char, 37 ; Compara el caracter con % para terminar el archivo
  je CloseFile

  call colorsin ; Selecciona el color                                ; Cambia el efecto de color de la imagen.

  call pinta ; Pinta el pixel
  call cambiarcf
  jmp leerarchi ; Regresa al principio

  salta: ; Salta una fila
    call saltaf
    jmp leerarchi

  CloseFile: ; Cierra el archivo
    call cerrar

  ret
endp

creararchi proc
  ;crea el archivo
  mov ah, 3ch
  mov cx, 0
  mov dx, offset ruta2
  int 21H

  mov handler, ax

  call cerrar

  ret
endp

guardarcarac proc
; Se abre el archivo en escritura
  mov ah, 3dh
  mov al, 1
  mov dx, offset ruta2
  int 21H

  mov handler, ax

  mov columna, 1D
  mov fila, 1D
  
  cicloguar:
  call getpixel

  cmp fila, 479D
  je finalar

  continuar:
    cmp columna, 500D
    je salto

    inc columna

  escribe:
    mov ah, 40h
    mov bx, handler
    mov dx, offset char
    mov cx, 1
    int 21H

  cmp char, 37D
  je salirguarda

  jmp cicloguar

  salto:
    mov columna, 1D
    inc fila
    mov char, 64D
    jmp escribe

  finalar:
    cmp columna, 501D
    je finalarchivo
    jmp continuar

  finalarchivo:
    mov char, 37D
    jmp escribe

  salirguarda:
    ret
endp

valores proc
  jmp valor4                                           ; Para cambiar efecto de imagen.

  valor1:
    mov columna, 1D
    mov fila, 1D
    jmp salirvalores

  valor2:
    mov columna, 500D
    mov fila, 1D
    jmp salirvalores
  
  valor3:
    mov columna, 500D
    mov fila, 479D
    jmp salirvalores
  
  valor4:
    mov columna, 1D
    mov fila, 479D
    jmp salirvalores

  salirvalores:
    ret
endp

saltaf proc ; Salta de manera normal o inversa
  jmp salta6                                           ; Para cambiar efecto de imagen.

  salta1:
    mov columna, 1D
    inc fila
    jmp salirsalta

  salta2:
    sub columna, 1D
    mov fila, 1D
    jmp salirsalta
                                                            ; Imagen normal:            valor1 + salta1 + increc
  salta3:                                                   ; Imagen a la izquierda:    valor2 + salta2 + incref
    mov columna, 500D                                       ; Imagen hacia arriba:      valor3 + salta3 + decrec
    sub fila, 1D                                            ; Imagen hacia la derecha:  valor4 + salta4 + decref
    jmp salirsalta                                          ; Imagen espejo:            valor2 + salta5 + decrec
                                                            ; Imagen espejo arriba:     valor4 + salta6 + increc
  salta4:                                                   ; Imagen espejo arriba lado:valor3 + salta3 + decrec
    inc columna
    mov fila, 479D
    jmp salirsalta

  salta5:
    mov columna, 500D
    inc fila
    jmp salirsalta
  
  salta6:
    mov columna, 1D
    sub fila, 1D
    jmp salirsalta

  salirsalta:
    ret
endp

cambiarcf proc
  jmp increc                                                    

  increc:
    inc columna
    jmp salircambiarcf
  decrec:
    sub columna, 1D
    jmp salircambiarcf

  incref:
    inc fila
    jmp salircambiarcf
  decref:
    sub fila, 1D
    jmp salircambiarcf

  salircambiarcf:
    ret
endp

ini proc
  ;Inicia el modo grafico
  mov ds, ax
  mov ax, 12h
  int 10H

  ;Abre el archivo
  mov ah, 3dh
  mov al, 0
  mov dx, offset ruta
  int 21H

  mov handler, ax

  ret
endp

cerrar proc
  mov ah, 3eh
  mov bx, handler
  int 21h

  ret
endp

colors proc ; Selecciona el color con la tabla normal
  xor al, al
  mov al, char
  
  cmp al, '9'
  jbe menor
  cmp al, 'A'
  je a
  cmp al, 'B'
  je b
  cmp al, 'C'
  je c
  cmp al, 'D'
  je d
  cmp al, 'E'
  je e
  cmp al, 'F'
  je f

  a:
    mov color, 10D
    jmp fin1
  b:
    mov color, 11D
    jmp fin1
  c:
    mov color, 12D
    jmp fin1
  d:
    mov color, 13D
    jmp fin1
  e:
    mov color, 14D
    jmp fin1
  f:  
    mov color, 15D
    jmp fin1

menor:
  sub al, 48D
  mov color, al
  jmp fin1

fin1:
  ret
endp

colorsin proc ; Selecciona el color con la tabla invertida
  xor al, al
  mov al, char
  
  cmp al, '9'
  jbe menora
  cmp al, 'a'
  je aa
  cmp al, 'b'
  je ba
  cmp al, 'c'
  je ca
  cmp al, 'd'
  je da
  cmp al, 'e'
  je ea
  cmp al, 'f'
  je fa

  aa:
    mov color, 5D
    jmp fin2
  ba:
    mov color, 4D
    jmp fin2
  ca:
    mov color, 3D
    jmp fin2
  da:
    mov color, 2D
    jmp fin2
  ea:
    mov color, 1D
    jmp fin1
  fa:  
    mov color, 0D
    jmp fin2

menora:
  cmp char, '0'
  je n0
  cmp char, '1'
  je n1
  cmp char, '2'
  je n2
  cmp char, '3'
  je n3
  cmp char, '4'
  je n4
  cmp char, '5'
  je n5
  cmp char, '6'
  je n6
  cmp char, '7'
  je n7
  cmp char, '8'
  je n8
  cmp char, '9'
  je n9
n0:
  mov color, 15D
  jmp fin2
n1:
  mov color, 14D
  jmp fin2
n2:
  mov color, 13D
  jmp fin2
n3:
  mov color, 12D
  jmp fin2
n4:
  mov color, 11D
  jmp fin2
n5:
  mov color, 10D
  jmp fin2
n6:
  mov color, 9D
  jmp fin2
n7:
  mov color, 8D
  jmp fin2
n8:
  mov color, 7D
  jmp fin2
n9:
  mov color, 6D
  jmp fin2
fin2:
  ret
endp

pinta proc ; Pinta un pixel
  xor CX, CX
  mov cx, columna
  mov dx, fila

  mov al, color
  mov ah, 0CH
  int 10H

  ret
endp pinta

getpixel proc ; Obtiene el color de un pixel
  xor CX, CX
  mov cx, columna
  mov dx, fila
  mov color, 0D

  mov color, al
  mov ah, 0DH
  int 10H
  mov color, al
  
  call colorchar

  ret
endp

colorchar proc
  mov al, color

  cmp al, 9D
  jbe menora1

  cmp al, 10D
  je letraa
  cmp al, 11D
  je letrab
  cmp al, 12D
  je letrac
  cmp al, 13D
  je letrad
  cmp al, 14D
  je letrae
  cmp al, 15D
  je letraf

  letraa:
    mov al, 65D
    jmp fin3
  letrab:
    mov al, 66D
    jmp fin3
  letrac:
    mov al, 67D
    jmp fin3
  letrad:
    mov al, 68D
    jmp fin3
  letrae:
    mov al, 69D
    jmp fin3
  letraf:  
    mov al, 70D
    jmp fin3

  menora1:
    add al, 48D
    jmp fin3

  fin3:
    mov char, al
    ret
endp

pintacuad proc
  mov columna, 0D
  mov fila, 0D
  mov color, 15D

  ciclo:
    cmp columna, 501D                        
    je salirpintacuad
  
    call pinta

    inc columna
    jmp ciclo

  salirpintacuad:
    jmp pintacuad2
    ret
endp

pintacuad2 proc
  mov columna, 501D
  mov fila, 0D

  ciclo2:
    cmp fila, 501D                        
    je salirpintacuad2
  
    call pinta

    inc fila
    jmp ciclo2

  salirpintacuad2:
    jmp pintacuad3
    ret
endp

pintacuad3 proc
  mov columna, 0D
  mov fila, 0D

  ciclo3:
    cmp fila, 501D                        
    je salirpintacuad3
  
    call pinta

    inc fila
    jmp ciclo3

  salirpintacuad3:
    jmp pintacuad4
    ret

endp

pintacuad4 proc
  mov columna, 0D
  mov fila, 480D

  ciclo4:
    cmp columna, 501D                        
    je salirpintacuad4
  
    call pinta

    inc columna
    jmp ciclo4

  salirpintacuad4:
    jmp pintacuad5
    ret
endp

;------------------------------(Pinta los botones)------------------------------

botones proc
  call btngirar
  call btnespejo
  call btninver
  call btncargar
  call btnguardar
  call btnsalir

  ret
endp

btngirar proc
  
  mov bh, 0       ; Indico la pagina en la que estaremos, en este caso la 0.
  mov dh, 1       ; Indico el renglon donde se imprimira el texto. 0-24
  mov dl, 70       ; Indico la columna donde se imprimira el texto. 0-79
  mov ah, 2       ; Indico el servicio 2.
  INT 10h

  lea dx, girarmsg      ; IMPRIMIR TEXTO.
  mov ah,9
  INT 21H

  ret
endp

btncargar proc
  mov bh, 0       ; Indico la pagina en la que estaremos, en este caso la 0.
  mov dh, 15       ; Indico el renglon donde se imprimira el texto. 0-24
  mov dl, 70       ; Indico la columna donde se imprimira el texto. 0-79
  mov ah, 2       ; Indico el servicio 2.
  INT 10h

  lea dx, cargarmsg      ; IMPRIMIR TEXTO.
  mov ah,9
  INT 21H

  ret
endp 
btnsalir proc
  mov bh, 0       ; Indico la pagina en la que estaremos, en este caso la 0.
  mov dh, 18       ; Indico el renglon donde se imprimira el texto. 0-24
  mov dl, 70       ; Indico la columna donde se imprimira el texto. 0-79
  mov ah, 2       ; Indico el servicio 2.
  INT 10h

  lea dx, salirmsg      ; IMPRIMIR TEXTO.
  mov ah,9
  INT 21H

  ret
endp

btnguardar proc
  mov bh, 0       ; Indico la pagina en la que estaremos, en este caso la 0.
  mov dh,12       ; Indico el renglon donde se imprimira el texto. 0-24
  mov dl, 68       ; Indico la columna donde se imprimira el texto. 0-79
  mov ah, 2       ; Indico el servicio 2.
  INT 10h

  lea dx, guardarmsg      ; IMPRIMIR TEXTO.
  mov ah,9
  INT 21H

  ret
endp

btninver proc
  mov bh, 0       ; Indico la pagina en la que estaremos, en este caso la 0.
  mov dh, 8      ; Indico el renglon donde se imprimira el texto. 0-24
  mov dl, 68       ; Indico la columna donde se imprimira el texto. 0-79
  mov ah, 2       ; Indico el servicio 2.
  INT 10h

  lea dx, invertirmsg      ; IMPRIMIR TEXTO.
  mov ah,9
  INT 21H

  ret
endp

btnespejo proc
  mov bh, 0       ; Indico la pagina en la que estaremos, en este caso la 0.
  mov dh, 5       ; Indico el renglon donde se imprimira el texto. 0-24
  mov dl, 68       ; Indico la columna donde se imprimira el texto. 0-79
  mov ah, 2       ; Indico el servicio 2.
  INT 10h

  lea dx, espejomsg      ; IMPRIMIR TEXTO.
  mov ah,9
  INT 21H

  ret
endp 


pintacuad5 proc
  mov columna, 500D
  mov fila, 10D

  ciclo5:
    cmp columna, 640D                        
  je salirpintacuad5
  
    call pinta

    inc columna
    jmp ciclo5

  salirpintacuad5:
    jmp pintacuad6
    ret
endp

pintacuad6 proc
  mov columna, 500D
  mov fila, 45D

  ciclo6:
    cmp columna, 640D                        
    je salirpintacuad6
  
    call pinta

    inc columna
    jmp ciclo6

  salirpintacuad6:
    jmp pintacuad9
    ret
endp

pintacuad9 proc                  ; Es casi el mismo que el pintacuad6.
  mov columna, 500D
  mov fila, 65D

  ciclo9:
    cmp columna, 640D                        
    je salirpintacuad9
  
    call pinta

    inc columna
    jmp ciclo9

  salirpintacuad9:
    jmp pintacuad10
    ret
endp


pintacuad10 proc                  ; Es casi el mismo que el pintacuad6.
  mov columna, 500D
  mov fila, 100D

  ciclo10:
    cmp columna, 640D                        
    je salirpintacuad10
  
    call pinta

    inc columna
    jmp ciclo10

  salirpintacuad10:
    jmp pintacuad13
    ret
endp

pintacuad13 proc                  
  mov columna, 500D
  mov fila, 120D

  ciclo13:
    cmp columna, 640D                        
    je salirpintacuad13
  
    call pinta

    inc columna
    jmp ciclo13

  salirpintacuad13:
    jmp pintacuad14
    ret
endp


pintacuad14 proc                  
  mov columna, 500D
  mov fila, 155D

  ciclo14:
    cmp columna, 640D                        
  je salirpintacuad14
  
    call pinta

    inc columna
    jmp ciclo14

  salirpintacuad14:
    jmp pintacuad17
    ret
endp

pintacuad17 proc                  
  mov columna, 500D
  mov fila, 175D
 
  ciclo17:
    cmp columna, 640D                        
    je salirpintacuad17
  
    call pinta

    inc columna
    jmp ciclo17

  salirpintacuad17:
    jmp pintacuad18
    ret
endp


pintacuad18 proc                  
  mov columna, 500D
  mov fila, 210D
  
  ciclo18:
    cmp columna, 640D                        
    je salirpintacuad18
  
    call pinta

    inc columna
    jmp ciclo18

  salirpintacuad18:
    jmp pintacuad21
    ret
endp

pintacuad21 proc                  
  mov columna, 500D
  mov fila, 230D
 
  ciclo21:
    cmp columna, 640D                        
    je salirpintacuad21
  
    call pinta

    inc columna
    jmp ciclo21

  salirpintacuad21:
    jmp pintacuad22
    ret
endp


pintacuad22 proc                  
  mov columna, 500D
  mov fila, 265D
 
  ciclo22:
    cmp columna, 640D                        
    je salirpintacuad22
  
    call pinta

    inc columna
    jmp ciclo22

  salirpintacuad22:
    jmp pintacuad25
    ret
endp

pintacuad25 proc                  
  mov columna, 500D
  mov fila, 285D

  ciclo25:
    cmp columna, 640D                        
    je salirpintacuad25
  
    call pinta

    inc columna
    jmp ciclo25

  salirpintacuad25:
    jmp pintacuad26
    ret
endp


pintacuad26 proc                  
  mov columna, 500D
  mov fila, 320D

  ciclo26:
    cmp columna, 640D                        
    je salirpintacuad26
  
    call pinta

    inc columna
    jmp ciclo26

  salirpintacuad26:
    ret
endp

;------------------------------(Fin de Pinta los botones)------------------------------

END