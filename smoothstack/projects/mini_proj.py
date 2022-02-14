def main():
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
        return 



    # extracting date from filename; formatting string as 'MONTH YEAR'
    date = filename.split('_')[-2:] 
    date[1] = date[1].split('.')[0]
    date = ' '.join(date).upper()

    # extracting order of columns from first row, saving indices to dictionary
    cell_order, order_dict = [i.value for i in next(lines)][0:6], {}
    for i in cell_order:
        if i == None:
            order_dict['Date'] = cell_order.index(i)
        order_dict[i] = cell_order.index(i)

    # initializing 'cells' list (updated each iteration in the while loop below)
    cells, found = [i.value for i in next(lines)], False


    # iterating through rows, determining if row date matches filename, log.infoing requested information if so
    while type(cells[0]) == dt:
        # formatting row date to match format of the 'date' variable (i.e. 'MONTH YEAR')
        cell_date = dt.strftime(cells[order_dict['Date']], '%^B %Y')

        # printing requested info from matching row; leaving while loop
        if cell_date == date:
            # formatting percentages correctly
            cells[1:6] = [format(x,'.2%') if x<1 else x for x in cells[1:6]]
            
            log.info(f"Info retrieved for {date.capitalize()}:")
            log.info("Calls Offered: " + str(cells[order_dict['Calls Offered']]))
            log.info("Abandon after 30s: " + str(cells[order_dict[' Abandon after 30s']]))
            log.info("FCR: " + str(cells[order_dict['FCR']]))
            log.info("DSAT: " + str(cells[order_dict['DSAT ']]))
            log.info("CSAT: " + str(cells[order_dict['CSAT ']]))

            found = True
            break

        # row date does not match, replacing 'cells' with the next row
        cells = [i.value for i in next(lines)]

    if not found:
        log.error(f"No entry found for {date.capitalize()}")
        return


main()
