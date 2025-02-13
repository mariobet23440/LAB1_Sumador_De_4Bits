;
; Sumador_4_Bits.asm
;
; Created: 13/02/2025 10:15:38
; Author : Mario Alejandro Betancourt Franco
; Nota importante: El uC no me funcionaba durante el lab. Encontramos con Hector que era un problema de Drivers
; Nota importante 2: Olvidé crear el repositorio al inicio del lab. Voy a subir ese archivo como muestra de que si trabajé ese día
; pero creé este archivo para mostrar que si lo hice yo xd.


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

    // Activación de pines de salida en el puerto D
    LDI     R16, 0xFF
    OUT     DDRD, R16
    LDI     R16, 0x00
    OUT     PORTD, R16

    // Registros de contadores
    LDI     R21, 0x00
	LDI     R22, 0x00

MAINLOOP:
    // Incrementar contadores y sacarlos en los puertos
    INC     R21
    OUT     PORTB, R21
    CALL    DELAY_255_POW3

	INC     R22
    OUT     PORTD, R22
    CALL    DELAY_255_POW3

    RJMP    MAINLOOP


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


