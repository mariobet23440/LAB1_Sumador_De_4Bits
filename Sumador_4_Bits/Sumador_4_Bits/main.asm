;
; Sumador_4_Bits.asm
;
; Created: 13/02/2025 10:15:38
; Author : Mario Alejandro Betancourt Franco
; Nota importante: El uC no me funcionaba durante el lab. Encontramos con Hector que era un problema de Drivers
; Nota importante 2: Olvidé crear el repositorio al inicio del lab. Voy a subir ese archivo como muestra de que si trabajé ese día
; pero creé este archivo para mostrar que si lo hice yo xd.

/*
He aquí un resumen de lo hecho en el laboratorio
1. Tomé el prelaboratorio y lo modifiqué para que hubieran dos contadores
2. Por cada revisión de las entradas hay un delay para antirrebotes.
*/


.include "M328PDEF.inc"
.cseg
.org    0x0000

// Configurar la pila
LDI     R16, LOW(RAMEND)
OUT     SPL, R16
LDI     R16, HIGH(RAMEND)
OUT     SPH, R16

SETUP:
    // Activación de pines de salida en el puerto B
    LDI     R16, 0xFF
    OUT     DDRB, R16
    LDI     R16, 0x00
    OUT     PORTB, R16

	// Activación de pines de entrada en el puerto C
    LDI     R16, 0x00
    OUT     DDRB, R16
    LDI     R16, 0xFF		// Activar Pull-ups
    OUT     PORTB, R16

    // Activación de pines de salida en el puerto D
    LDI     R16, 0xFF
    OUT     DDRD, R16
    LDI     R16, 0x00
    OUT     PORTD, R16


MAINLOOP:
	// Ejecutar incremento y decremento de contadores
	CALL	CONTADOR1
	CALL	CONTADOR2

	// Una vez que se haya regresado, debemos unir los bits de R16 y R20
	// Para colocar los bits de R16 como los últimos bits de PORTD y los bits de R20 como los primeros
	// debemos desplazar los bits de R20 4 bits a la izquierda

	// Afortunadamente ya existe una función precisamente para eso
	MOV		R23, R22	// Copiamos el valor de R20 en E21 para no alterar su valor
	SWAP	R23			// Con esto intercambiamos los nibbles de R20

	// Ahora unimos los bits de R16 y R21
	OR		R20, R23

	// Finalmente las sacamos en PORTD
	OUT		PORTD, R20


	// Repetir todo
	RJMP MAINLOOP

CONTADOR1:
	// Guardamos el valor de PORTB en R19 (Aquí van las dos entradas)
	IN		R19, PORTB

	// Cambio de flujo - Decremento
	SBRC	R19, 0
	CALL	DELAY_255_POW3
	SBRC	R19, 0 
	DEC		R20

	// Cambio de flujo - Incremento
	SBRC	R19, 1
	CALL	DELAY_255_POW3
	SBRC	R19, 1
	INC		R20

	// Truncar resultado a sólo cuatro bits
	ANDI	R20, 0x0F

	// Mostrar el resultado en PORTD
	// OUT		PORTD, R16

	// Regresar a MAINLOOP
	RET

CONTADOR2:
	// Para este contador usaremos los bits 2 y 3 de PORTB
	// El bit 2 servirá para decrementar el valor del contador
	// El bit 3 se usará para incrementar el valor del contador

	// Guardamos el valor de PORTB en R19 (Aquí van las dos entradas)
	IN		R21, PORTB

	// Cambio de flujo - Decremento
	SBRC	R21, 2
	CALL	DELAY_255_POW3
	SBRC	R21, 2 
	DEC		R22

	// Cambio de flujo - Incremento
	SBRC	R21, 3
	CALL	DELAY_255_POW3
	SBRC	R21, 3
	INC		R22

	// Truncar resultado a sólo cuatro bits
	ANDI	R22, 0x0F

	// Desplazar los 4 bits hacia la izquierda
	// Regresar a MAINLOOP
	RET



// NO TOCAR ------------------------------------------------------------------------
// Delay con conteo
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


