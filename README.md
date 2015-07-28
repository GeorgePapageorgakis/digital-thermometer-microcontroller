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

![Main circuit](https://github.com/GeorgePapageorgakis/digital-thermometer-microcontroller/blob/master/ICs/circuit.JPG)

**Powering**

We use a 9V battery for powering our circuit. Because the circuit requires a constant voltage, we 
use stabilizer LM7805 achieving a downgrade of voltage to 5V, which is the voltage of the AVR, LCD,
LM35, ICL7660 and LM358N. In our circuit, we nominate a tendency voltage reference (Vref) of the AVR 
to 5V, that we get by putting an lm358N in connection with potentiometers.

**Voltage Adder**

To problem we face in this circuit is that our sensor outputs the negative voltages, so we have to sum the absolute maximum value so as to have 0V as smaller value to the output of the adder.
To solve this problem put an οperational αmplifier in adder connection.

For the values of the components we have:

* **C1** 10    mF 	electrolytic
* **C2** 10    mF 	electrolytic
* **C3** 22    pF 	ceramic
* **C4** 22    pF 	ceramic
* **C5** 0.1   mF 	ceramic
* **C6** 0.33  mF 	ceramic
* **C7** 100   nF 	ceramic

**IC1** LM358N ST

![LM358N ST](https://github.com/GeorgePapageorgakis/digital-thermometer-microcontroller/blob/master/ICs/LM358N%20%20ST.jpg)

**IC2**	MEGA16-P Atmel

![MEGA16-P Atmel](https://github.com/GeorgePapageorgakis/digital-thermometer-microcontroller/blob/master/ICs/MEGA16-P%20%20Atmel.jpg)

**IC3**	ICL7660 Intersil

![ICL7660 Intersil](https://github.com/GeorgePapageorgakis/digital-thermometer-microcontroller/blob/master/ICs/ICL7660%20Intersil.jpg)
 
**IC4** LM7805C-V ST electronics

![LM7805C-V ST electronics](https://github.com/GeorgePapageorgakis/digital-thermometer-microcontroller/blob/master/ICs/LM7805C-V%20%20ST%20electronics.jpg)

**IC5** LM35 National

![LM35 National](https://github.com/GeorgePapageorgakis/digital-thermometer-microcontroller/blob/master/ICs/LM35%20National.jpg)

* **L1**	10  μH		   inductor-neosid
* **Q1**	12  MHz		  XTAL AEC
* **R1**	100 KOhm			 1%      
* **R2**	100 KOhm			 1%
* **R3**	100 KOhm		 	1%
* **R4**	100 KOhm			 1%
* **R5**	100 KOhm			 1%
* **R6**	100 KOhm		 precise trimmer  
* **R7**	10  KOhm		 trimmer 
