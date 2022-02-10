### Assignment 3-1


#Q1

from math import ceil

def div_by_35(start, end):
    """ returns list of all values between start and end that are divisible by 7 and 5 (i.e. divisible by 35) """
    if start < 1:
        start = 1

    i, nums = ceil(start/(7*5)), []
    while  i*7*5 <= end:
        nums += [i*7*5]
        i += 1
    return nums

#Q2

def temp_convert(temp):
    degree = int(temp[0:-2])
    
    if temp[-1].upper() == 'C':
        return str(round(degree*(9/5) + 32)) + "°F"
    
    return str(round((degree-32)*(5/9))) + "°C"

#Q3

from random import randint

def guessing():
    guess, answer = 0, randint(1,9)

    while guess != answer:
        guess = int(input('Guess a number (1-9): '))
    
    print('Well Guessed!')

#Q4 & Q5

switch = (lambda x: x + 1, lambda x: x-1)
x = 0

for i in range(0,2):
    for j in range(0,5):
        x = switch[i](x)
        print('* '*x)

#Q6

def reverser():
    user_str = list(input('Say something: '))
    newstr = ''

    while len(user_str) > 0:
        newstr += user_str.pop()

    return newstr

#Q7

def even_odd(seq):
    num_e,num_o = 0,0
    for i in seq:
        if i%2 == 0:
            num_e += 1
        else:
            num_o += 1
    
    print(f'Number of even numbers: {num_e}')
    print(f'Number of odd numbers: {num_o}')

#Q8

def data_and_type(lst):
    for i in lst:
        print(str(i) + ': ' + str(type(i))[8:-2])

#Q9

for i in range(0,7):
    if i == 3 or i == 6:
        continue
    print(i) # output: 0 1 2 4 5
