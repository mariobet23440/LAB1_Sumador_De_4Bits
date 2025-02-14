;
; Sumador_4_Bits.asm
;
; Created: 13/02/2025 10:15:38
; Author : Mario Alejandro Betancourt Franco
; Nota importante: El uC no me funcionaba durante el lab. Encontramos con Hector que era un problema de Drivers
; Nota importante 2: Olvid� crear el repositorio al inicio del lab. Voy a subir ese archivo como muestra de que si trabaj� ese d�a
; pero cre� este archivo para mostrar que si lo hice yo xd.

/*
He aqu� un resumen de lo hecho en el laboratorio
1. Tom� el prelaboratorio y lo modifiqu� para que hubieran dos contadores
2. Por cada revisi�n de las entradas hay un delay para antirrebotes.
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
    // Activaci�n de pines de salida en el puerto B
    LDI     R16, 0xFF
    OUT     DDRB, R16
    LDI     R16, 0x00
    OUT     PORTB, R16

	// Activaci�n de pines de entrada en el puerto C
    LDI     R16, 0x00
    OUT     DDRC, R16
    LDI     R16, 0xFF		// Activar Pull-ups
    OUT     PORTC, R16

    // Activaci�n de pines de salida en el puerto D
    LDI     R16, 0xFF
    OUT     DDRD, R16
    LDI     R16, 0x00
    OUT     PORTD, R16

	// Configurar el oscilador para que oscile a 1 MHz
	LDI		R16, (1 << CLKPCE)	// CLKPCE es el bit 7 de CLKPR
	STS		CLKPR, R16
	LDI		R16, 0X04
	STS		CLKPR, R16		


MAINLOOP:
	// Ejecutar incremento y decremento de contadores
	CALL	CONTADOR1
	CALL	CONTADOR2

	// Una vez que se haya regresado, debemos unir los bits de R20 y R22
	// Para colocar los bits de R20 como los �ltimos bits de PORTD y los bits de R22 como los primeros
	// debemos desplazar los bits de R20 4 bits a la izquierda

	// Sacar los valores de los contadores en PORTD
	MOV		R23, R22	// Copiamos el valor de R21 en E23 para no alterar su valor
	SWAP	R23			// Con esto intercambiamos los nibbles de R20
	MOV		R24, R20	// Guardamos el valor de R20 en otro registro (Nos servir� m�s adelante)
	OR		R20, R23	// Ahora unimos los bits de R20 y R23
	OUT		PORTD, R20	// Sacamos los contadores en PORTD

	CALL	SUMA

	// Repetir todo
	RJMP MAINLOOP

CONTADOR1:
	// Guardamos el valor de PORTB en R19 (Aqu� van las dos entradas)
	IN		R19, PINC

	// Cambio de flujo - Decremento
	SBRC	R19, 3
	CALL	DELAY_255_POW3
	SBRC	R19, 3 
	DEC		R20

	// Cambio de flujo - Incremento
	SBRC	R19, 4
	CALL	DELAY_255_POW3
	SBRC	R19, 4
	INC		R20

	// Truncar resultado a s�lo cuatro bits
	ANDI	R20, 0x0F

	// Regresar a MAINLOOP
	RET

CONTADOR2:
	// Para este contador usaremos los bits 2 y 3 de PORTB
	// El bit 2 servir� para decrementar el valor del contador
	// El bit 3 se usar� para incrementar el valor del contador

	// Guardamos el valor de PORTB en R21 (Aqu� van las dos entradas)
	IN		R21, PINC

	// Cambio de flujo - Decremento
	SBRC	R21, 1
	CALL	DELAY_255_POW3
	SBRC	R21, 1 
	DEC		R22

	// Cambio de flujo - Incremento
	SBRC	R21, 2
	CALL	DELAY_255_POW3
	SBRC	R21, 2
	INC		R22

	// Truncar resultado a s�lo cuatro bits
	ANDI	R22, 0x0F

	// Desplazar los 4 bits hacia la izquierda
	// Regresar a MAINLOOP
	RET

// Mostrar la suma en PORTB
SUMA:
	IN		R25, PINC	// Guardamos el valor de PORTB en R19 (Aqu� van las dos entradas)
	ADC		R24, R22	// Sumamos el valor de R24 y R22 y lo guardamos en R24 (Dado que es solo una copia del contador)
	ANDI	R24, 0X1F	// Truncamos la suma a solo 5 bits (El acarreo es el �ltimo bit)

	// Rutina de antirrebote
	SBRS	R25, 0			// Por alguna extra�a raz��on, este bit est� SET por default
	CALL	DELAY_255_POW3
	SBRS	R25, 0			// Si el bit 0 del PINC est� apagado, mostrar la suma en PORTB 
	OUT		PORTB, R24		//

	RET



// NO TOCAR ------------------------------------------------------------------------
// Delay con conteo
DELAY_255_POW3:
    LDI     R18, 1		// ESTABLECER R18 AQU�

DELAY_255_POW3_LOOP:
    CALL    DELAY_SETUP
    DEC     R18
    BRNE    DELAY_255_POW3_LOOP
    RET

DELAY_SETUP:
    LDI     R17, 64	// ESTABLECER EL VALOR M�XIMO DE R17 AQU�

DELAY_LOOP:
    LDI     R16, 0xFF	// ESTABLECER EL VALOR M�XIMO DE R16 AQU�
    CPI     R17, 0		// Comparar el valor de R17 con 0
    BREQ    DELAY_END	// Si el valor de R17 es cero, ir a DELAY_END
    DEC     R17			// Disminuir el valor de R17 si no es igual a cero

CONTEO_R16:
    DEC     R16			// Decrementamos R16
    BRNE    CONTEO_R16  // Si R16 no es cero, repetir la subrutina
    RJMP    DELAY_LOOP	// Si R16 es cero, regresar a DELAY_LOOP

DELAY_END:
    RET


