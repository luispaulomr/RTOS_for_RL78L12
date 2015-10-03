/***********************************************************************/
/*  													               */
/*      PROJECT NAME :  teste4                                         */
/*      FILE         :  reset_program.asm                              */
/*      DESCRIPTION  :  Reset Program                                  */
/*      CPU SERIES   :  RL78 - L12                                     */
/*      CPU TYPE     :  R5F10RLC                                       */
/*  													               */
/*      This file is generated by e2studio.                        */
/*  													               */
/***********************************************************************/                                                                       
                                                                                   


	/*reset_program.asm*/

	.list

	.global _PowerON_Reset  /*! global Start routine */
	.short _PowerON_Reset
	
#ifdef CPPAPP	
___dso_handle:
	.global ___dso_handle
#endif	


	.extern _HardwareSetup /*! external Sub-routine to initialise Hardware*/
	.extern _data
	.extern _mdata
	.extern _ebss
	.extern _bss
	
	.extern _edata
	.extern _main 
	.extern _stack
	.extern _exit

	/*  ;; HL = start of list
        ;; DE = end of list
        ;; BC = step direction (+2 or -2)
	*/
	
	.text

/* call to _PowerON_Reset */
_PowerON_Reset:
/* initialise user stack pointer */
	movw sp,#_stack /* Set stack pointer */


/* load data section from ROM to RAM */	
;; block move to initialize .data

        ;; we're copying from 00:[_romdatastart] to 0F:[_datastart]
        ;; and our data is not in the mirrored area.
    mov     es, #0
    sel     rb0         /*  ;;bank 0 */
    movw    de, #_mdata	/* src ROM address of data section in de */
    movw    hl, #_data 	/* dest start RAM address of data section in hl */
		
    sel     rb1              /* bank 1 */
    movw    hl, #_data 	/* dest start RAM address of data section in hl */
    movw    ax, #_edata   /*    ;; size of romdata section in ax */
    subw    ax,hl  		/* store data size */
    shrw	ax,1
1:
    cmpw    ax, #0		   /* check if end of data */
    bz      $1f
    decw    ax
    sel     rb0             /* bank 0 */
    movw    ax, es:[de]
    movw    [hl], ax
    incw    de
    incw	de
    incw    hl
	incw	hl
    sel     rb1         /* bank 1  -  compare and decrement*/
    br      $1b
1:

	
/* bss initialisation : zero out bss */
    sel     rb0         /* bank 0 */
    movw    hl, #_bss  	/* store the start address of bss in hl */
    movw    ax, #0		/* load AX reg with zero */
    sel     rb1         /* bank 1 */
    movw    ax, #_ebss  /* store the end address (size of) bss section in ax */
    subw    ax,hl ;; store data size
    shrw    ax,1
1:
    cmpw    ax, #0
    bz      $1f
    decw    ax
    sel     rb0         /* bank 0 */
    movw    [hl], ax
    incw    hl
    incw	hl
    sel     rb1
    br      $1b
1:
    sel     rb0             /* bank 0 */

/* call the hardware initialiser */
	call	!!_HardwareSetup
	nop

/* start user program */

    movw    ax, #0
    push    ax      /* envp */
    push    ax      /* argv */
    push    ax      /* argc */
    call	!!_main


/* call to exit*/
_exit:
     br	$_exit

	.end             
