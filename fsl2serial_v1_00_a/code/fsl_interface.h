// This is a header file describing the FSL interface developed for use with the FSL2Serial
// module.  Data can also be sent over this link, but the assumption is that text will be sent.
//
// This requires the Xilinx FSL interface code, which can generally be found in fsl.h,
// mb_interface.h, and xbasic_types.h
//
// These functions cannot take the FSL ID as a parameter because the fsl functions used are
// actually macros for asm inline commands.
//
// Alex Marschner
// 2007.03.12

#ifndef FSL_INTERFACE_H
#define FSL_INTERFACE_H

#include "fsl.h"	//  getfsl(val, id),  putfsl(val, id),	(blocking)
					// ngetfsl(val, id), nputfsl(val,id)	(non blocking)

#define BOOL int
#define TRUE 1
#define FALSE 0

#define FSL_BLOCKING 1
#define FSL_NONBLOCKING 0

#define FSL0 0 

// Put a string of data through the specified FSL port.
void fsl0print(const char* s);
void fsl0nprint(const char* s);

// Print a single character to the specified FSL port.
void fsl0put(const char s);
void fsl0nput(const char s);

// Get a single character from the specified FSL port.
char fsl0get(char * s);
char fsl0nget(char * s);

// Print the hexadecimal representation of a 32-bit integer to the specified FSL port.
void fsl0hex(const unsigned int val);

// Print the decimal representation of a 32-bit unsigned int to the specified FSL port.
//void fsldec(const unsigned int val, const unsigned int id);

#endif

