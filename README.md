![image of floating point coprocessor](https://www.emptytincan.com/e/g/1571961009-gumn3.png)

Written in VHDL, simulates a floating-point CPU. Not meant to be synthesizable. It is a proof-of-concept CPU for floating-point calculations.



## Usage
#### Refer to "assembler-guide.pdf" in Docs for usage examples.

* As the name implies, it handles floating-points, not just integers. "1.01", not just "1".
* This fpu project can do the following operations: add, subtract, divide, multiply, square root, min, max, negate, floor, ceiling, round, absolute value, exponent, power. 
* It follows the "IEEE-754" floating-point standard.  
* Hypothetically, floating-point coprocessors are used in science to do complex calculations. This project is an exercise in design.
