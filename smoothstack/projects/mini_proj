import openpyxl as op, logging as log
from datetime import datetime as dt


log.basicConfig(filename='mini_proj.log', level=log.INFO,
    format='%(asctime)s[%(levelname)s] - %(message)s')


# requesting filename from user
filename = input("Please provide the name of the Excel file you wish to process: ")


# extracting date from filename; formatting string as 'MONTH YEAR'
date = filename.split('_')[-2:] 
date[1] = date[1].split('.')[0]
date = ' '.join(date).upper()


# extracting rows from 'Summary Rolling MoM' sheet
lines = op.load_workbook(filename)['Summary Rolling MoM'].rows


# initializing 'cells' list
next(lines)
cells = [i.value for i in next(lines)]


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

        break

    # row date does not match, replacing 'cells' with the next row
    cells = [i.value for i in next(lines)]
    
