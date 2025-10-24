# Summary
This macro is a crucial first step in the process of converting an InfoSewer (IEDB) or InfoSWMM (ISDB) model to InfoWorks ICM. The script is designed to convert all DBF files, which are used in InfoSewer and InfoSWMM models, to CSV files, in the IEDB/ISDB folder and its subfolders. InfoWorks ICM cannot interact with DBF files, but can easily import CSV files, hence this conversion is necessary.

The script works by enabling the user to select a folder, and then it processes each DBF file in that folder as well as in its subfolders. Each DBF file is opened, saved as a CSV file with the same name, and then closed. The script keeps track of the total number of converted files and displays this count in Sheet1 of the Excel workbook.

In summary, this script automates the labor-intensive process of manually converting each DBF file to a CSV format, making the transition from InfoSewer or InfoSWMM to InfoWorks ICM more efficient.

## Instructions
1. Open the DBF_to_CSV macro (this macro). Run 'Convert DBF to CSV', following the instructions provided in the macro file.

## Assumptions
- Each CSV will be saved in the same location as its corresponding DBF