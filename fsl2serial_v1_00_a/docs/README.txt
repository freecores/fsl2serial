In order to use the FSL2Serial module in XPS, follow these steps:

1) Place the entire containing folder, fsl2serial_v1_00_a, into your pcores directory.
2) Start XPS (or restart - this may be necessary).

3) Click on the "IP Catalog" tab, expand "Project Repository", and insert the FSL2Serial module.
4) Right click on the module name in the "System Assembly View", and select "Configure IP."
	- make sure you indicate the correct system reset polarity (usually board reset polarity)
	- set your clock speed in MHz (eg, 100).  The range is 0-200.
	- set your baud rate.  Default is 115200, normal people use 9600
5) Insert the following information into the following places:
	- pcores/fsl2serial_v1_00_a/docs/fsl2serial.ucf --> data/system.ucf
	- pcores/fsl2serial_v1_00_a/docs/fsl2serial.mhs --> system.mhs 

	Note: if XPS is open and you make this change using some other editor,
	XPS will override your changes!!

6) In the "Ports" view, expand fsl2serial and connect the clock, rst, and rs232 pins.


Adding the FSL busses:

1) In the "IP Catalog" tab, expand "Bus", and add TWO instances of the fsl_v20 bus.
2) For each of these instances,

	- right click, select "Configure IP"
	- uncheck the box that says "External Reset Active High" (if appropriate)
	- click "Ok"

	- in the "Ports" view, expand the bus
	- connect the FSL_Clk and FSL_Rst to the system clock and reset

3) Back in the "Bus Interface" view:
	- attach the Master port of your processor and the Slave port of FSL2serial to one FSL bus.
	- attach the Slave port of your processor and the Master port of FSL2serial to the other.


You should now be ready to write programs that use the FSL2Serial link as serial output.
Sample code is available in the fsl2serial_v1_00_a/code/ directory.


2007.03.12
Alex Marschner





