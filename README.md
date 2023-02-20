## :knot: Handle selection criteria as class
### Description
This development shows how to deal with selection criteria dynamically. The transfer of all selection criteria of a report to the constructor of the application class should be simplified. For that an instance of the local helper class pushes parameters and select options of the report dynamically to an instance of a global class. Afterwards the instance of the global class is given to the constructor of the application class.  
### Development Objects
* global class ZCL_SEL_CRITERIA: class to manage parameters and select options
* global class ZCL_SEL_CRITERIA_TEST: class that selects data from database table and list them
* report ZSEL_CRITERIA_TEST: report uses local helper class LCL_SELECTION_CRITERIA to handle selection criteria and afterwards uses an instance of global class ZCL_SEL_CRITERIA_TEST to select and list data
