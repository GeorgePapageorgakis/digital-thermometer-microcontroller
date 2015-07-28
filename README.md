# digital-thermometer-microcontroller
Design and implementation of a simple digital thermometer using Atmel MEGA16-P microcontroller

Design and implementation of a digital thermometer using an AVR microcontroller and a thermometer 
eg LM35 the National). The temperature reading is expressed to one decimal digit in liquid crystal 
display symbols with integrated control circuit with one or two lines (eg LCD withi controller 
(2x16) Datavision 1624451FBLY).

**The thermometer has the following characteristics:**

1.The temperature is sampled every 30 seconds
2.The system must manage and negative temperatures.
3.With the touch of a button switches to the scale of temperature between Celsius and Fahrenheit 
and displayed the corresponding indication.

**Complete Circuit**
![Main circuit](/digital-thermometer-microcontroller/blob/master/circuit.JPG?raw=true "Digital Thermometer")

**Powering**

We use a 9V battery for powering our circuit. Because the circuit requires a constant voltage, we 
use stabilizer LM7805 achieving a downgrade of voltage to 5V, which is the voltage of the AVR, LCD,
LM35, ICL7660 and LM358N. In our circuit, we nominate a tendency voltage reference (Vref) of the AVR 
to 5V, that we get by putting an lm358N in connection with potentiometers.

**Voltage Adder**

To problem we face in this circuit is that our sensor outputs and negative voltages, so you have to sum the absolute maximum negative value so as to have 0V as smaller value to the output of the adder.
To solve this problem put an effector in connection adder.

For values ​​of the components we have:

**C1** 10	mF 	electrolytic
**C2** 10	mF 	electrolytic
**C3** 22	pF 	ceramic
**C4** 22	pF 	ceramic
**C5** 0.1	mF 	ceramic
**C6** 0.33	mF 	ceramic
**C7** 100	nF 	ceramic

**IC1** LM358N  ST

![Image of Yaktocat](https://github.com/GeorgePapageorgakis/digital-thermometer-microcontroller/blob/master/LM358N%20%20ST.jpg)


**IC2**	MEGA16-P Atmel
![Alt text](/relative/path/to/img.jpg?raw=true "Optional Title")


**IC3**	ICL7660 Intersil
![Alt text](/relative/path/to/img.jpg?raw=true "Optional Title")
 
**IC4** LM7805C-V ST electronics
![Alt text](/relative/path/to/img.jpg?raw=true "Optional Title")

**IC5** LM35 National
![Alt text](/relative/path/to/img.jpg?raw=true "Optional Title")

**L1**	10μH		inductor-neosid
**Q1**	12MHz		XTAL    AEC
**R1**	100KOhm			1%      
**R2**	100KOhm			1%
**R3**	100KOhm			1%
**R4**	100KOhm			1%
**R5**	100KOhm			1%
**R6**	100KOhm		precise trimmer  
**R7**	10KOhm		trimmer 
