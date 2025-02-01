;
; Laboratorio1-Contador.asm
;
; Created: 01/02/2025
//Encabezado 
//Bryan Samuel Morales Paredes 23283
// Este código es un contador binario de 4 bits
.include "M328PDEF.inc"
.cseg
.org 0x0000

/********************************************************/
//Configuración de la pila 
/********************************************************/
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16		// SPL 
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16		// SPH 

//Configurar el microcontrolador (MCU)
SETUP:
	//Configurar pines de entrada y salida (DDRx, PORTx, PINx)
	//Le voy a hablar a todo el puerto D y no un solo bit, por simplicidad
	//PORTD como entrada y PORTB como salida
	LDI		R16, 0x00
	OUT		DDRD, R16	//Setear puerto D como entrada
	LDI		R16, 0xFF
	OUT		PORTD, R16	//Habilidar pull-up en puerto D
	
	//PORTB como salida inicialmente apagado 
	LDI		R16, 0xFF
	OUT		DDRB, R16	//Setear puerto B como salida
	LDI		R16, 0x00
	OUT		PORTB, R16	//Apagar puerto B

	LDI R17, 0x00		//Variable para guardar estado de botones




//Loop infinito (ciclo infinito)
//Utilizaré el PIND2 y PIND3 para los botones ----- PINB0 al PINB3 para el resultado del contador (leds)
MAIN:
	IN		R16, PIND	//Escribe el valor de PIND en un registro
	CP		R17, R16	//Compara los registros, salta si son diferentes
	BREQ	MAIN		
	CALL	DELAY
	IN		R16, PIND	
	CP		R17, R16			
	BREQ	MAIN
	//Volver a leer PIND
	MOV		R17, R16	//Mueve el registro actual al registro previo
	SBRS	R16, 2		//Salta si el bit 2 de PIND (R16) está en 1
	SBRS	R16, 3		//Salta si el bit 3 de PIND (R16) está en 1
	DEC		R19			//Disminuye el valor
	INC		R19			//Aumenta el valor
	OUT		PORTB, R19	//Escribe el valor en PORTB
	RJMP	MAIN

//Sub-rutina (no de interrupción)
DELAY:		//Antirebote
	LDI		R18, 0xFF
SUB_DELAY1:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY1
	LDI		R18, 0xFF
SUB_DELAY2:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY2
	LDI		R18, 0xFF
SUB_DELAY3:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY3
	RET

//Rutina de interrupcióna