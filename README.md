## handle selection criteria as class
### description
This development shows how to deal with selection criteria dynamically. The transfer of all selection criteria of a report to the constructor of the application class should be simplified. For that an instance of the local helper class pushes parameters and select options of the report dynamically to an instance of a global class. Afterwards the instance of the global class is given to the constructor of the application class.  
### development objects
* global class ZCL_SEL_CRITERIA: class to work with parameters and select options
* global class ZCL_SEL_CRITERIA_TEST: class to demonstrate the use
* report ZSEL_CRITERIA_TEST: report uses local helper class LCL_SELECTION_CRITERIA to handle selection criteria and afterwards uses an instance of global class ZCL_SEL_CRITERIA_TEST to select and list
