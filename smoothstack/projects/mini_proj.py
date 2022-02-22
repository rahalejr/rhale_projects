import sys, os, calendar, openpyxl as op, logging as log
from datetime import datetime as dt

# formatting logging output
log.basicConfig(filename='mini_proj.log', level=log.INFO, 
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

    # locating valid files in current directory; removing files with invalid filenames 
    files, errored = ordered_files(dir_path)
    for i in errored:
        log.error(f"Invalid Filename: '{i}'")
        move_error(i,dir_path)

    # writing processed filenames to file.lst
    processed = open('file.lst','a+')

    for filename in files:

        # checking for duplicate files
        processed.seek(0)
        if filename in processed.read().split('\n'):
            log.error(f"File: '{filename}' has already been processed")
            move_error(filename,dir_path)
            continue

        # reading file; extracting rows from sheet one
        try:
            log.info(f"Reading file: {filename}")
            date = get_date(filename) 
            rows = rows_and_order(filename)
        except:
            log.error(f"Unable to locate requested information from 'Summary Rolling MoM' in {filename}")
            move_error(filename,dir_path)
            continue

        # locating info from first sheet matching FILENAME
        log.info(f"Searching for {date.capitalize()} in {filename}")
        req_info = match_date(rows,date)
        if req_info == None:
            log.error(f"No entry found for {date.capitalize()}")
            move_error(filename,dir_path)
            continue
            
        # formatting REQ_INFO from first sheet and outputting to logfile
        for cell in format_info(req_info, rows[1]):
            log.info(cell)

        # formatting and outputting matching info from second sheet
        try:
            for cell in sheet_two(filename):
                log.info(cell)
        except:
            log.error(f"Unable to locate requested information from 'VOC Rolling MoM' in {filename}")
            move_error(filename,dir_path)
            continue

        # appending FILENAME to file.lst and moving to archive directory
        processed.write(f'{filename}\n')
        os.rename(f"{dir_path}/{filename}",f"{dir_path}/archive/{filename}")
    
    processed.close()


def ordered_files(directory):
    """ returns: list of valid files from directory (ordered by month in filename), list of invalid files from directory """

    # dictionary for converting month names to integers 1-12
    month_dict = {month.upper(): index for index, month in enumerate(calendar.month_name) if month}
    # assigning file names of monthly report files found in current directory
    files = [i for i in os.listdir(directory) if i.startswith('expedia_report_monthly') and i.endswith('.xlsx')]

    order, errored = [],[]
    for i in files:
        try: order += [month_dict[get_date(i).split()[0]]]
        except:
            errored += [i]
    [files.remove(i) for i in errored]  
    return [y for x, y in sorted(zip(order, files))], errored 

    
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


def match_date(rows, date): 
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


def sheet_two(filename):
    """ finds requested info from second sheet in FILENAME; returns formatted info as a list of strings """

    # getting iterator of rows from file
    lines = op.load_workbook(filename)['VOC Rolling MoM'].rows
    row = [i.value for i in next(lines)][1:24]

    # reformatting date columns as 'MONTH YEAR'; saving matching column index
    date_cols = [dt.strftime(i,'%^B %Y') if type(i) == dt else i.upper() + ' 2018' for i in row]
    matched_col = date_cols.index(get_date(filename)) + 1

    info,n = [],0
    while len(info)<3 and n<20:
        row, labels, n = [i.value for i in next(lines)], ['Promoters', 'Passives', 'Dectractors'], n + 1
        if type(row[0]) == str:
            label = row[0].split()[0]
            if label in labels:
                val,cond = row[matched_col],100
                if label == 'Promoters': cond = 200
                info += [f"{label}: {val} ({'bad' if val < cond else 'good'})"]        
    return info


move_error = lambda filename, dir_path: os.rename(f"{dir_path}/{filename}",f"{dir_path}/errored/{filename}") 


if __name__ == '__main__':
    try: main()
    except:
        log.critical('Unknown error occured: some files may not have been processed')
