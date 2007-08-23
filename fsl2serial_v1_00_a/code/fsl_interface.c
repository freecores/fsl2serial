// This is the source file implementing the FSL interface developed for use with the FSL2Serial
// module.  Data can also be sent over this link, but the assumption is that text will be sent.
//
// This requires the Xilinx FSL interface code, which can generally be found in fsl.h,
// mb_interface.h, and xbasic_types.h
//
// Alex Marschner
// 2007.03.12

#include "fsl_interface.h"

// Put a string of data through the specified FSL port.
void fsl0print(const char* s)
{
    while(*s)
    {
        putfsl(*s, FSL0);
        ++s;
    }
	return;
}

// Put a string of data through the specified FSL port.
void fsl0nprint(const char* s)
{
    while(*s)
    {
        nputfsl(*s, FSL0);
        ++s;
    }
	return;
}

// Print a single character to the specified FSL port.  (BLOCKING)
void fsl0put(const char s)
{
   	putfsl(s, FSL0);
	return;
}

// Print a single character to the specified FSL port.	(NONBLOCKING)
void fsl0nput(const char s)
{
	nputfsl(s, FSL0);
	return;
}

// Get a single character from the specified FSL port.	(BLOCKING)
char fsl0get(char * s)
{
	char inchar;
	
	getfsl(inchar, FSL0);
	if(s!=NULL) (*s) = inchar;

	return inchar;
}

// Get a single character from the specified FSL port.	(NONBLOCKING)
char fsl0nget(char * s)
{
	char inchar;
	
	ngetfsl(inchar, FSL0);
	if(s!=NULL) (*s) = inchar;

	return inchar;
}

// Print the hexadecimal representation of a 32-bit integer to the specified FSL port.
void fsl0hex(const unsigned int val)
{
	char hexstring[10];
	unsigned int shiftval = val;
	char maskval;
	int ctr;

	for(ctr=9; ctr>1; ctr--)
	{
		maskval = shiftval & 0x0000000F;

		if(maskval < 10)
			hexstring[ctr] = maskval + 0x30;
		else
			hexstring[ctr] = maskval + (0x41-0xA);

		shiftval = shiftval >> 4;
	}

	hexstring[0] = '0';
	hexstring[1] = 'x';

	fsl0print(hexstring);
	
	return;
}

