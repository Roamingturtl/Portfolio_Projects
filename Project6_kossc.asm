; String Primitives and Macros     (proj6_kossc.asm)

; Author: Collin Koss
; Last Modified: 3/13/2022
; OSU email address: kossc@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:    6             Due Date: 3/13/2022
; Description: This program does not use ReadInt, ReadDec, WriteInt, and WriteDec.  Program prompts user to input 10 signed integers within a range and invokes a macro to read the input,
;	then saves as numeric values in an array.  Then displays the list of integers, their sum, and truncated avaerage using WriteVal which uses a macro to write to display.
;             

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Display an instruction prompt, then get the user’s keyboard input using ReadString.  Saves input into a memory location passed by stringAddress (output parameter, by reference).
; Saves the length from EAX via ReadString into the memory location passed into chars (output parameter, by reference).
;
; Preconditions: prompt isa string array, stringAddress is a stringArray, chars is a DWORD.
;
; Receives:
; prompt = array address (by reference)
; stringAddress = array address (by reference)
; chars = DWORD address (by reference)
;
; returns: User input string in stringAddress, number of digits from ReadString stored in chars.
; ---------------------------------------------------------------------------------

mGetString MACRO prompt:REQ, stringAddress:REQ, chars:REQ
	PUSH	ECX
	PUSH	EAX
	mDisplayString prompt
	mov		EDX, stringAddress
	mov		ECX, 200
	call	ReadString
	mov		chars, EAX
	POP		EAX
	POP		ECX
	ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Print the string which is stored at the memory location passed in the parameter.
;
; Preconditions: passed a string array address.
;
; Receives:
; asciiString = array address (by reference)
;
; returns: Displays the string using WriteString.
; ---------------------------------------------------------------------------------

mDisplayString MACRO asciiString:REQ
	PUSH	EDX
	mov		EDX, asciiString
	call	WriteString
	POP		EDX
	ENDM


.data

	intro			BYTE	"PROGRAMMING ASSIGNMENT 6: String Primitives and Macros",13,10 
					BYTE	"Written by: Collin Koss", 13,10,13,10,0
	directions		BYTE	"Please provide 10 signed decimal integers.", 13, 10
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the",13,10
					BYTE	"raw numbers I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
	macPrompt		BYTE	"Please enter a signed number: ", 0
	error			BYTE	"ERROR: You did not enter a signed number or your number was too big.",0
	displayInts		BYTE	"You entered the following numbers: ",13,10,0
	commaSpace		BYTE	", ", 0
	sum				BYTE	"The sum of these numbers is: ", 0
	average			BYTE	"The truncated average is: ", 0
	numArray		SDWORD	0,0,0,0,0,0,0,0,0,0
	bufferString	SDWORD	200 DUP (?)
	macNumRead		SDWORD	0
	byteCount		DWORD	?			



.code
main PROC
	
;------------------------------
;	Displays greeting and program Description
;		Uses mDisplayString
;------------------------------

	mDisplayString	OFFSET intro
	mDisplayString	OFFSET directions
	

;------------------------------
;	Gets 10 numbers from the user and adds them to numArray.
;		Calls ReadVal to invoke the mGetString macro which receives one
;		number from the user.  Adds the number to numArray at designated index
;		starting from index 0.  Loops 10 times to get 10 numbers.
;------------------------------

	mov		ESI, OFFSET numArray
	mov		ECX, 10
_GetNums:
	PUSH	OFFSET macPrompt
	PUSH	OFFSET bufferString
	PUSH	OFFSET byteCount
	PUSH	OFFSET error
	PUSH	ESI
	call	ReadVal
	add		ESI, 4												; Increment to next index of numArray
	loop	_GetNums
	call	CrLf


;------------------------------
;	Displays all the numbers in numArray.
;		Call WriteVal which invokes mDisplayString macro to display
;		the full list of numbers in numArray.  Prints one number per loop.
;------------------------------
	
	mDisplayString	OFFSET displayInts
	mov		ESI, OFFSET numArray
	mov		ECX, LENGTHOF numArray
_PrintLoop:
	PUSH	[ESI]
	call	WriteVal
	cmp		ECX, 1
	JE		_Pass
	mDisplayString OFFSET commaSpace
	add		ESI, 4
	LOOP	_PrintLoop
_Pass:
	call	CrLf


;------------------------------
;	Calculates and displays the sum and truncated average of the
;	numbers in numArray.
;		Loops through the indices of numArray and sums the values.
;		Display the sum calling WriteVal.
;		Calculates the average using the sum.
;		Display the truncated average calling Writeval.
;------------------------------

	mDisplayString	OFFSET sum
	mov		ESI, OFFSET numArray
	mov		ECX, LENGTHOF numArray
	sub		ECX, 1
	mov		EAX, [ESI]
_SumLoop:
	mov		EBX, [ESI + 4]
	add		EAX, EBX											; Accumlate sum in EAX
	add		ESI, 4
	LOOP	_SumLoop
	PUSH	EAX
	call	WriteVal											; Display sum

	call	CrLf
	mDisplayString	OFFSET average
	MOV		EBX, 10
	CDQ
	IDIV	EBX													; Div by 10 for truncated average
	push	EAX
	call	WriteVal											; Display average
	call	CrLf


	Invoke ExitProcess,0	
main ENDP


;-------------------------------------------------------
; Name: ReadVal
;
; Invokes mGetString macro to get user input in the form of a string of digits.  Converts the ASCII
; digits to it's numeric value representation (SDWORD).  If not a valid number(string inc letters,symbols, 
; or number to large for 32-bit register) displays error message.  Stores this value into numArray
;
; Preconditions: macPrompt and error are strings. bufferString is an array, numArray is an array. byteCount is a DWORD, mGetString is a macro.
;
; Receives: macprompt for macro (by reference), bufferString for macro (by reference), byteCount for macro (by reference), error (by reference), 
; address of a numArray index (by reference).
;
; Returns: Adds the number input from mGetString macro to numArray. byteCount set to len of string input from macro call.
;-------------------------------------------------------


ReadVal PROC USES EAX EDX ECX ESI EDI
	LOCAL numInt:SDWORD, negative:SDWORD
	
	mov		negative, 0
_GetStringLoop:
	mGetString [EBP + 24], [EBP + 20], [EBP + 16]
	mov		ESI, [EBP + 20]										; Set ESI to bufferString
	mov		EDI, [EBP + 8]										; Set EDI to numArray
	mov		ECX, [EBP + 16]										; Set count to size of string for loop.
	mov		numInt, 0
_BaseCase:														; Check first ASCII for negative or positive characters
	LODSB
	cmp		AL, 45
	JE		_Negative
	CMP		AL, 43
	JE		_Positive
_Validate:
	cmp		AL, 57
	JG		_Error
	cmp		AL, 48
	JGE		_ConvertNum
_Error:
	mov		EAX, 0
	mDisplayString [EBP + 12]
	call	CrLF
	JMP		_GetStringLoop
_Negative:
	mov		negative, 1
	LODSB
	sub		ECX, 1
	JMP		_Validate
_Positive:
	LODSB
	sub		ECX, 1
	JMP		_Validate
_ConvertNum:
	MOVSX	EDX, AL
	mov		EAX, numInt
	imul	EAX, 10
	JO		_Error												; Check for overflow
	sub		EDX, 48
	cmp		negative, 1											; Check if number is neg
	JNE		_ContinueConvert
	NEG		EDX
_ContinueConvert:
	ADD		EAX, EDX
	JO		_Error												; Check for Overflow
	mov		numInt, Eax
	sub		ECX, 1
	cmp		ECX, 0												; Check if loop is finished
	JE		_Finish
	LODSB
	JMP		_Validate
_Finish:
	MOV		[EDI], EAX											; Add converted integer to the numArray
	RET		20

ReadVal ENDP


;-------------------------------------------------------
; Name: WriteVal
;
; Takes an integer parameter by value and converts it into an ascii string.  Then
; invokes mDisplayString to print the ascii string using WriteString.
;
; Preconditions: Must be passed an integer parameter by value. mDisplayString is a macro.
;
; Receives: integer passed by value.
;
; Returns: Writes the integer value passed as parameter to the display window.
;-------------------------------------------------------


Writeval PROC USES EAX EBX ECX EDX EDI
	LOCAL stringArray[22]:BYTE, negative:BYTE

	LEA		EAX, stringArray
	mov		negative, 0
	MOV		ECX, 0												; Initialize counter for pop loop
	MOV		EDI, EAX											; Initialize EDI to stringArray
	mov		EAX, [EBP + 8]
	cmp		EAX, 0
	JGE		_ConvertLoop
	mov		negative, 1
_ConvertLoop:
	mov		EBX, 10
	CDQ
	IDIV	EBX
	cmp		EDX, 0
	JGE		_ContinueConvert
	NEG		EDX
_ContinueConvert:
	ADD		EDX, 48
	PUSH	EDX													; Stash converted value on stack to fix order (reverse -> normal)
	ADD		ECX, 1												; Increment counter for pop loop
	cmp		EAX, 0
	JNE		_ConvertLoop
_Negative:
	cmp		negative, 1
	JNE		_PopLoop
	push	45
	add		ECX, 1
_PopLoop:														; pop stashed converted values on stack into stringArray in proper order.
	pop		EAX
	STOSB
	LOOP	_PopLoop
	mov		AL, 0												; null terminate converted string
	STOSB
	LEA		EDX, stringArray
	mDisplayString EDX
_Finish:
	RET		4

WriteVal ENDP

END main


 