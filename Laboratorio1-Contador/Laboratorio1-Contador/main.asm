;
; Laboratorio1-Contador.asm
;
; Created: 01/02/2025
//Encabezado 
//Bryan Samuel Morales Paredes 23283

.include "M328PDEF.inc"
.cseg
.org 0x0000

/********************************************************/
//Configuración de la pila 
/********************************************************/
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16		// SPL = 0xFF
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16		// SPH = 0x03

//Configurar el microcontrolador (MCU)
SETUP:
	//Configurar pines de entrada y salida (DDRx, PORTx, PINx)
	//Le voy a hablar a todo el puerto D y no un solo bit, esto por simplicidad
	//PORTD como entrada y PORTB como salida
	LDI		R16, 0x00
	OUT		DDRD, R16	//Setear puerto D como entrada
	LDI		R16, 0xFF
	OUT		PORTD, R16	//Habilidar pull-up en puerto D
	
	//PORTB como salida inicialmente encendido 
	LDI		R16, 0xFF
	OUT		DDRB, R16	//Setear puerto B como salida
	LDI		R16, 0b00000001
	OUT		PORTB, R16	//Encender primer bit de puerto B

	LDI R17, 0xFF		//Variable para guardar estado de botones
//Loop infinito (ciclo infinito)
MAIN:
	IN		R16, PIND	//Guardando el estado de PORTD en R16 (leyendo los botones de PD0...PD7)
	SBRC	R16, 2		//Salta si el bit 2 está en 0
	RJMP	MAIN
	CP		R17, R16
	BREQ	MAIN
	MOV		R17, R16
	SBI		PINB, 0
	RJMP	MAIN
	dfasdfasdf
	asdfasdfas
//Sub-rutina (no de interrupción)
//Rutina de interrupcióna