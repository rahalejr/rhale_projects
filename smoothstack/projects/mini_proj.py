import os, openpyxl as op, logging as log
from datetime import datetime as dt



def main():
    """ finds relevant FILES in current directory and logs the information from the date specified in a given FILENAME """

    # formatting logging output
    log.basicConfig(filename='revised.log', level=log.INFO, 
        format='%(asctime)s [%(levelname)s] - %(message)s')


    files = [i for i in os.listdir() if i[0:22] == 'expedia_report_monthly']
    processed = []

    for filename in files:

        if filename in processed:
            continue

        # extracting date from FILENAME
        date = get_date(filename)

        # reading file
        try:
            rows = get_rows(filename)
            log.info(f"Reading file: {filename}")
        except FileNotFoundError:
            log.error(f"File '{filename}' not found in directory")
            continue

        # locating date in file
        log.info(f"Searching for {date.capitalize()} in {filename}")
        req_info = find_date(rows,date)
        if req_info == None:
            log.error(f"No entry found for {date.capitalize()}")
            continue
            
        # formatting REQ_INFO and outputting to logfile
        for cell in format_info(req_info, rows[1]):
            log.info(cell)

        processed += [filename]

  
    
def get_rows(filename):
    """ Reads file matching FILENAME; returns generator of rows and a dictionary specifying the order of columns """

    lines = op.load_workbook(filename)['Summary Rolling MoM'].rows

    cell_order, order_dict = [i.value for i in next(lines)][0:6], {}
    for i in cell_order:
        if i == None:
            order_dict['Date'] = cell_order.index(i)
        else: order_dict[i.strip()] = cell_order.index(i)
    
    return lines, order_dict



def get_date(filename):
    """ Extracts date from FILENAME as string, formatted as 'MONTH YEAR' """

    date = filename.split('_')[-2:] 
    date[1] = date[1].split('.')[0]
    return ' '.join(date).upper()
    


def find_date(rows, date): 
    """ returns row from ROWS corresponding to DATE as a list """
    
    cells = [i.value for i in next(rows[0])]

    while type(cells[0]) == dt:
        # formatting row date to match format of DATE (i.e. 'MONTH YEAR')
        cell_date = dt.strftime(cells[rows[1]['Date']], '%^B %Y')

        if cell_date == date:
            return cells[0:6]
    
        cells = [i.value for i in next(rows[0])]



def format_info(info, order_dict):
    """ converts INFO to a list of properly formatted strings """
    
    formatted = []

    for i in list(order_dict):
        if i == 'Date':
            date = dt.strftime(info[order_dict[i]], '%^B %Y')
            formatted += [f"Info retrieved for {date.capitalize()}:"]
        elif info[order_dict[i]] < 1:
            formatted += [f"{i}: {format(info[order_dict[i]],'.2%')}"]
        else: formatted += [f"{i}: {info[order_dict[i]]}"]
    return formatted



if __name__ == '__main__':
    main()
