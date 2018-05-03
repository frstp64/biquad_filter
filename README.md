# biquad\_filter
A biquad filter design made in VHDL and synthetized using Synopsis

Note: This is not the report. For the location of the report, please see the file structure section below.

## Authors

* Frédéric St-Pierre
* Vahid Khojasteh Lazarjan

## Dependencies

* Xilinx ISE
* Jupyter Notebook (optional, to open the jupyter notebook file for presentation)
* Python (3.6 or above)

## File Structure

Some files are omitted since they are only kept for informational purposes and are not used in the project anymore.

* final.pdf : A report for the project
* biquad\_filter\_clk.ctstsh : The clock specification parameters for Encounter
* biquad\_filter.conf : The Encounter project configuration file
* biquad\_filter\_gate.v : The generated gate-level logic description from Design Vision, Verilog version
* biquad\_filter\_gate.vhd : The generated gate-level logic description from Design Vision, VHDL version
* biquadfilter.gds : The generated layout file from Encounter
* biquad\_filter\_placement.io : The pin placement description for Encounter
* biquad\_filtr.script : The script used to convert the initial vhdl representation of the project into a gate-level representation with Design Vision
* figures.pdf : A collection of figures used for the report
* others :
    * wallace\_tree\_generator.py : The Python code used to generate the wallace tree vhdl code
    * wallace\_tree\_generator.ipynb : The Python code used to generate the wallace tree vhdl code, version using jupyter notebooks for demonstration
* vhdl\_project :
    * biquad\_filter.xise : The project file for Xilinx ISE
    * biquad\_filter.vhd : The top-level vhdl file for the biquad filter project
    * clock\_divider : The clock division module folder
    * FA : A Full-Adder module for the Wallace Tree multiplier
    * HA : A Half-Adder module for the Wallace Tree Multiplier
    * lt\_comparator : A less-than signed number comparator, used by the unsigned divider module
    * nbitregister : A general-purpose n-bits register
    * shift\_register : A shift register with parallel load function used by the unsigned divider module
    * signed\_adder : A combinational signed adder, implementing two different architectures
    * signed\_contracter : A signed number contraction module with overflowing representation detection
    * signed\_divider : A wrapper for the pipelined unsigned divider
    * signed\_expander : A signed number width expansion module
    * signed\_inverter : A signed number inversion module
    * signed\_multiplier : A wrapper for the combinational unsigned multiplier
    * unsigned\_divider : A sequential divider, using shift registers to implement classic shift-and-substract division
    * unsigned\_multiplier : A Wallace Tree implementation of an unsigned multiplier
