// PRUSS program to flash a LED on GPIO1_17 gpio49 on P9_19
// Writen by Derek Molloy for the book Exploring BeagleBone

.origin 0               // offset of start of program in PRU memory
.entrypoint START       // program entry point used by the debugger

#define DELAY_MSEC 1000             // delay for 2 seconds on
#define CLOCKFREQ 200000000         // PRU clock frequency is 200 MHz
#define CLOCKS_PER_DELAY_LOOP 2     // loop contains two instructions, one clock each
#define DELAYCOUNT DELAY_MSEC * (CLOCKFREQ / (CLOCKS_PER_DELAY_LOOP * 1000))

#define PRU0_R31_VEC_VALID (1<<5)
#define SIGNUM 3 // corresponds to PRU_EVTOUT_0

START:
	LBCO	r0, C4, 4, 4
	CLR	r0, r0, 4
	SBCO	r0, C4, 4, 4

	// Map data to the BBB user space
	MOV	r5, 0x00000000	  //load the memory location
	LBBO	r6, r5, 0, 4	  //load the value into memory

	// Write to memory at the same address -- not necessary - just a test
//	MOV	r5, 9   	  //value
//	MOV	r6, 0x00000000    //address
//	SBBO	r5, r6, 0, 4

MAINLOOP:
	MOV	r1, DELAYCOUNT    // store the length of the delay
LEDON:  
	SET	r30.t5
DELAY:
	SUB	r1, r1, 1         // decrement loop counter
	QBNE	DELAY, r1, 0      // repeat loop unless zero
LEDOFF: 
	CLR	r30.t5
	MOV	r1, DELAYCOUNT    // reset the delay timer
DELAY2:
	SUB	r1, r1, 1         // decrement loop counter
	QBNE	DELAY2, r1, 0     // repeat loop unless zero


	SUB	r6, r6, 1
	QBNE	MAINLOOP, r6, 0
	QBBC	END, r31.t3     // quit the application if button pressed

END:
	MOV	R31.b0, PRU0_R31_VEC_VALID | SIGNUM
	HALT
