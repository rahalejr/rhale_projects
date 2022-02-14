### Assignment 5-1


def bmi_calc():
    
    num, bmis = int(input("How many individuals? ")), []
    
    for i in range(num):
        bmis += [input(f"Individual {i + 1}: (Format: weight height) ")]
        bmis[i] = [float(j) for j in bmis[i].split()]
        bmis[i] = round(bmis[i][0] / bmis[i][1]**2,1)
    
    return  ['obese' if i>= 30 else 'over' if i>=25 else 'normal' if i>=18.5 else 'under' for i in bmis]
    

print(bmi_calc())




### Weekend Mini-Project


import openpyxl as op, logging as log
from datetime import datetime as dt



log.basicConfig(filename='mini_proj.log', level=log.INFO,
    format='%(asctime)s[%(levelname)s] - %(message)s')



# requesting filename from user
filename = input("Please provide the name of the Excel file you wish to process: ")



# extracting rows from 'Summary Rolling MoM' sheet
try:
    lines = op.load_workbook(filename)['Summary Rolling MoM'].rows
    log.info(f"Reading file: {filename}")
except FileNotFoundError:
    log.error(f"File '{filename}' not found in directory")



# extracting date from filename; formatting string as 'MONTH YEAR'
date = filename.split('_')[-2:] 
date[1] = date[1].split('.')[0]
date = ' '.join(date).upper()

# initializing 'cells' list
next(lines)
cells, found = [i.value for i in next(lines)], False

# iterating through rows, determining if row date matches filename, log.infoing requested information if so
while type(cells[0]) == dt:
    # formatting row date to match format of the 'date' variable (i.e. 'MONTH YEAR')
    cell_date = dt.strftime(cells[0], '%^B %Y')

    # printing requested info from matching row; leaving while loop
    if cell_date == date:
        cells[2:6] = list(map(lambda x: format(x, '.2%'), cells[2:6]))
        
        log.info(f"Info retrieved for {date.capitalize()}:")
        log.info(f"Calls Offered: {cells[1]}")
        log.info(f"Abandon after 30s: {cells[2]}")
        log.info(f"FCR: {cells[3]}")
        log.info(f"DSAT: {cells[4]}")
        log.info(f"CSAT: {cells[5]}")

        found = True
        break

    # row date does not match, replacing 'cells' with the next row
    cells = [i.value for i in next(lines)]

if not found:
    log.error(f"No entry found for {date.capitalize()}")
