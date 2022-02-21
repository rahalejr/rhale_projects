import sys, os, openpyxl as op, logging as log
from datetime import datetime as dt

# formatting logging output
log.basicConfig(filename='revised.log', level=log.INFO, 
    format='%(asctime)s [%(levelname)s] - %(message)s')

# getting path to current directory
dir_path = os.path.abspath(os.getcwd())

# creating directory for processed files if it does not already exist ('archive')
try: os.mkdir(f"{dir_path}/archive")
except FileExistsError: pass

# creating directory for files that threw an error, if it does not already exist ('errored')
try: os.mkdir(f"{dir_path}/errored")
except FileExistsError: pass



def main():
    """ finds relevant FILES in current directory and logs the information from the date specified in a given FILENAME """

    # assigning file names of monthly report files found in current directory
    files = [i for i in os.listdir(dir_path) if 'expedia_report_monthly' in i and i.endswith('.xlsx')]
    processed, errored = [],[]

    for filename in files:
        if filename in processed:
            continue

        # extracting date from FILENAME
        date = get_date(filename)

        # reading file
        try:
            rows = rows_and_order(filename)
            log.info(f"Reading file: {filename}")
        except FileNotFoundError:
            log.error(f"File '{filename}' not found in directory")
            os.rename(f"{dir_path}/{filename}",f"{dir_path}/errored/{filename}")
            continue

        # locating date in file
        log.info(f"Searching for {date.capitalize()} in {filename}")
        req_info = find_date(rows,date)
        if req_info == None:
            log.error(f"No entry found for {date.capitalize()}")
            os.rename(f"{dir_path}/{filename}",f"{dir_path}/errored/{filename}")
            continue
            
        # formatting REQ_INFO and outputting to logfile
        for cell in format_info(req_info, rows[1]):
            log.info(cell)

        # formatting and outputting matching info from second sheet
        for cell in part_two(filename):
           log.info(cell)

        processed += [filename]

        # moving file to archive directory
        os.rename(f"{dir_path}/{filename}",f"{dir_path}/archive/{filename}")

  
    
def rows_and_order(filename):
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
    date[0] = date[0]
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



def part_two(filename):

    lines = op.load_workbook(filename)['VOC Rolling MoM'].rows
    row = [i.value for i in next(lines)][1:24]

    date_cols = [dt.strftime(i,'%^B %Y') if type(i) == dt else i.upper() + ' 2018' for i in row]

    matched_col = date_cols.index(get_date(filename)) + 1

    next(lines)
    next(lines)

    info = []
    for i in ['Promoters', 'Passives', 'Detractors']:
        val,cond = [i.value for i in next(lines)][matched_col],100
        if i == 'Promoters': cond = 200
        info += [f"{i}: {'bad' if val < cond else 'good'}"]

    return info






if __name__ == '__main__':
    main()


#sys.stdout = open('file.lst','w')

#sys.stdout.close()

# filename = 'expedia_report_monthly_march_2018.xlsx'
