	.org 4096
	la 	r29,TOP 
	la 	r24, POLL3
	la	r23, POLL2
	la	r22, POLL1
	la	r21, POLL0
	la	r20, FOR1
	la	r19, FOR0

	; DO FOREVER
TOP: 	ld 	r26,-24(r0)  ; Read RX_DATA_FLAG
	brzr 	r29, r26       ; Poll For RX_DATA_FLAG = 1
	
	; Set Gain (SPI)
	ld	r26, -20(r0) ; Read UART Byte
	st	r26, -60(r0) ; Write UART Byte to SPI     
	
	; Write XADC Channels 4 and 12 to Buffer
	la	r15, BUFF
	la	r18, 512
FOR0:	addi	r18, r18, -1
POLL0:	ld	r28, -944(r0) ; Read XADC_BUSY
	brmi	r21, r28         ; Poll for 0
	ld	r27, -912(r0)  
	shl	r27, r27, 16
	or	r28, r28, r27
	st	r28, 0(r15)
POLL1:  ld	r28, -944(r0) ; Read XADC_BUSY
	brpl	r22, r28         ; Poll for 1
	addi	r15, r15, 4
	brnz	r19, r18

	; Write Buffer To UART Output    
	la	r15, BUFF
	la	r18, 512
FOR1:	addi	r18, r18, -1
POLL2:	ld	r28, -32(r0) ; Poll For TX_BUSY_FLAG = 0
	brnz	r23, r28
	ld	r28, 0(r15)
	shr	r28, r28, 8
	st	r28, -28(r0)
POLL3:   ld	r12, -32(r0) ; Poll For TX_BUSY_FLAG = 0
	brnz	r24, r12
	shr	r28, r28, 16
	st	r28, -28(r0)
	addi	r15, r15, 4
	brnz	r20, r18
	br 	r29
	stop

BUFF:	.dw 512
