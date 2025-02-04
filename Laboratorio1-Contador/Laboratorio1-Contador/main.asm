;
; Laboratorio1-Contador.asm
;
; Created: 01/02/2025
//Encabezado 
//Bryan Samuel Morales Paredes 23283
// Este código es un contador doble binario de 4 bits el cual puede generar la suma de los contadores
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
//=================================================================================
//Configurar el microcontrolador (MCU)
SETUP:
	//Configurar pines de entrada y salida (DDRx, PORTx, PINx)
	//Le voy a hablar a todo el puerto B y no un solo bit, por simplicidad
	//PORTB como entrada
	LDI		R16, 0x00
	OUT		DDRDB, R16	//Setear puerto B como entrada
	LDI		R16, 0xFF
	OUT		PORTB, R16	//Habilidar pull-up en puerto B

	
	//PORTD y PORTC como salida inicialmente apagado 
	LDI		R16, 0xFF
	OUT		DDRC, R16	//Setear puerto C como salida
	OUT		DDRD, R16	//Setear puerto D como salida 
	LDI		R16, 0x00
	OUT		PORTC, R16	//Apagar puerto C
	OUT		PORTD, R16	//Apagar puerto D
//====================================================================================
//Establecer valores iniciales de algunos registros

	LDI		R21, 0x00	//Iinica el contador 2 en 0
	LDI		R20, 0x0F	//Variable para guardar valor maximo y comparar (16)
	LDI		R19, 0x00   //Inicializa el contador 1 en 0
	LDI		R17, 0x00	//Variable para guardar estado de botones

//Loop infinito (ciclo infinito)
MAIN:
 	IN		R16, PIND	//Escribe el valor de PIND en un registro
	CP		R17, R16	//Compara los registros, salta si son diferentes
	BREQ	MAIN		//Regresa al loop principal
	CALL	DELAY		//LLama a la subrutina DELAY
	IN		R16, PIND	//Coloca el valor del PIND en R16
	CP		R17, R16			
	BREQ	MAIN
	//Volver a leer PIND
	MOV		R17, R16	//Mueve el registro actual al registro previo
	SBIS	PINB, 0
	CALL	SUM_1
	SBIS	PINB, 1
	CALL	RESTA_1
	SBIS	PINB, 2
	CALL	SUM_2
	SBIS	PINB, 3
	CALL	RESTA_2
	RJMP	MAIN

//Sub-rutina (no de interrupción)





//Sub-rutina (no de interrupción)
REVISAR_SI:			//Sirve para la lógica cuando no se presionan botones
	SBRS	R16, 3
	RJMP	MAIN		//Regresa al loop principal
REVISAR_INC_DEC:
	SBRS	R16, 2		//En esta subrutina se selecciona la operación a realizar
	RJMP	DECREMENTAR
	RJMP	INCREMENTAR
INCREMENTAR:
	INC		R19			//Incrementa R19
	CPI		R19, 0x10	//Verifica si sobrepasa el valor máximo
	BRNE	ACTUALIZAR	//Actualiza el valor
	LDI		R19, 0x00	//Si R19 sobrepasa el valor máximo se resetea
	RJMP	ACTUALIZAR
DECREMENTAR:
	CPI		R19, 0x00	//Verifica si se encuentra en el valor mínimo, si no este salta
	BREQ	SET_MAX		//Subrutina
	DEC		R19			//Disminuye el valor de R19
	RJMP	ACTUALIZAR
SET_MAX:
	LDI		R19, 0x0F	//Si baja más del valor mínimo se setea en 0x0F (valor máximo)
ACTUALIZAR:
	OUT		PORTB,R19	//Coloca el valor del contador en el puerto B
	RJMP	MAIN		//Regresa al loop principal




//=====================================================================================

DELAY:		//Antirebote
	LDI		R18, 0xFF
SUB_DELAY1:
	DEC		R18
	CPI		R18, 0		//Compara, salta si son iguales
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