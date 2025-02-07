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

/******************************************************************/
//Configuración de la pila 
/*****************************************************************/
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
	OUT		DDRB, R16	//Setear puerto B como entrada
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

	LDI		R20, 0x00	//Iniciar el contador 2 en 0
	LDI		R19, 0x00   //Inicializa el contador 1 en 0
	LDI		R17, 0x00	//Variable para guardar estado de botones

//===================================================================================
//Prescaler del oscilador
	LDI		R16, (1 << CLKPCE)    ; Habilita la escritura en CLKPR
	STS		CLKPR, R16
	LDI		R16, (1 << CLKPS2)     ; Configura prescaler a 16 (16 MHz / 16 = 1 MHz)
	STS		CLKPR, R16
//====================================================================================

//Loop infinito (ciclo infinito)
MAIN:
 	IN		R16, PINB	//Escribe el valor de PIND en un registro
	CP		R17, R16	//Compara los registros, salta si son diferentes
	BREQ	MAIN		//Regresa al loop principal
	CALL	DELAY		//LLama a la subrutina DELAY
	IN		R16, PINB	//Coloca el valor del PIND en R16
	CP		R17, R16			
	BREQ	MAIN
	//Volver a leer PIND
	MOV		R17, R16	//Mueve el registro actual al registro previo
	SBIS	PINB, 1
	CALL	SUM_1
	SBIS	PINB, 0
	CALL	RESTA_1
	SBIS	PINB, 3
	CALL	SUM_2
	SBIS	PINB, 2
	CALL	RESTA_2
	SBIS	PINB, 4
	CALL	TOTAL
	//Muestro los datos en el PORTB
	MOV		R21, R20
	LSL		R21
	LSL		R21
	LSL		R21
	LSL		R21
	ADD		R21, R19
	OUT		PORTD, R21 	
	RJMP	MAIN

//Sub-rutina (no de interrupción)

SUM_1:
    INC     R19           ; Incrementar R19
    CPI     R19, 0x10     ; ¿Llegó a 0x10 (fuera del rango 0x00 - 0x0F)?
    BRNE    FIN_SUM_1     ; Si no, continuar
    LDI     R19, 0x00     ; Si sí, reiniciar a 0
FIN_SUM_1:
    RET

RESTA_1:
    CPI     R19, 0x00     ; ¿Está en 0?
    BREQ    SET_MAX_1     ; Si sí, colocar en 0x0F
    DEC     R19           ; Decrementar
    RET
SET_MAX_1:
    LDI     R19, 0x0F
    RET

SUM_2:
    INC     R20           ; Incrementar R20
    CPI     R20, 0x10     ; ¿Llegó a 0x10 (fuera del rango 0x00 - 0x0F)?
    BRNE    FIN_SUM_2     ; Si no, continuar
    LDI     R20, 0x00     ; Si sí, reiniciar a 0
FIN_SUM_2:
    RET

RESTA_2:
    CPI     R20, 0x00     ; ¿Está en 0?
    BREQ    SET_MAX_2     ; Si sí, colocar en 0x0F
    DEC     R20           ; Decrementar
    RET
SET_MAX_2:
    LDI     R20, 0x0F
    RET		

//====================================================================================

TOTAL:
	MOV		R22, R20
	ADD		R22, R19
	OUT		PORTC, R22
	RET		

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