;
; Sumador_4_Bits.asm
;
; Created: 13/02/2025 10:15:38
; Author : Mario Alejandro Betancourt Franco
; Nota importante: El uC no me funcionaba durante el lab. Encontramos con Hector que era un problema de Drivers
; Nota importante 2: Olvidé crear el repositorio al inicio del lab. Voy a subir ese archivo como muestra de que si trabajé ese día
; pero creé este archivo para mostrar que si lo hice yo xd.


; Replace with your application code
start:
    inc r16
    rjmp start

/* DELAY CON CONTEO
Este segmento de código permite crear un delay donde el uC no hace absolutamente nada
mientras disminuye el valor de 3 contadores.

El algoritmo utiliza los registros R16, R17 y R18
- El contador R16 cuenta desde 255 a 0 por cada decremento de R17
- El contador R17 cuenta desde 255 a 0 por cada decremento de R18

Sea N16, N17 y N18 los valores iniciales de los contadores en R16-R18, respectivamente
El número de iteraciones es

No. Iteraciones = [(N16)*(N17)]*N18

Donde * representa una multiplicación

Por las limitaciones de memoria en el ATMega328P este contador puede hacer 255^3 conteos en menos de 30 líneas de código (Eficiente, yuju).
*/

/*
Con los valores de R16, R17 y R18 el tiempo tomado por la función DELAY_255_POW3 asumiendo una frecuencia de oscilador de
f = 16 MHz o 16 Millones de conteos por segundo es

t = 256*256*8 conteos / (16 x 10^6 conteos/s) = 0.032

¡Dado que 256^3 es aproximadamente 16 millones, al colocar R16 = 0XFF, R17 = 0XFF y R18 = 0XFF podemos hacer delays de hasta 1 segundo!
*/

DELAY_255_POW3:
    LDI     R18, 32		// ESTABLECER R18 AQUÍ

DELAY_255_POW3_LOOP:
    CALL    DELAY_SETUP
    DEC     R18
    BRNE    DELAY_255_POW3_LOOP
    RET

DELAY_SETUP:
    LDI     R17, 255	// ESTABLECER EL VALOR MÁXIMO DE R17 AQUÍ

DELAY_LOOP:
    LDI     R16, 0xFF	// ESTABLECER EL VALOR MÁXIMO DE R16 AQUÍ
    CPI     R17, 0		// Comparar el valor de R17 con 0
    BREQ    DELAY_END	// Si el valor de R17 es cero, ir a DELAY_END
    DEC     R17			// Disminuir el valor de R17 si no es igual a cero

CONTEO_R16:
    DEC     R16			// Decrementamos R16
    BRNE    CONTEO_R16  // Si R16 no es cero, repetir la subrutina
    RJMP    DELAY_LOOP	// Si R16 es cero, regresar a DELAY_LOOP

DELAY_END:
    RET


