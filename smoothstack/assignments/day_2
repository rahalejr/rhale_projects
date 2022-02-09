### Assignment 2-1


#1
'Hello World'[8]

#2
'thinker'[2:5]

H = 'hello'
H[1] # 'e'

#3
S = 'Sammy'
S[2:] # 'mmy'

#4
''.join(set("Mississippi")) # 'Misp'

#5 
def is_palindrome(x):
    """ returns bool: is x a palindrome? (exluding punctation, case and spaces) """
    
    x = x.lower()

    if len(x) <= 0:
        return True 
    if not x[0].isalpha():
        return is_palindrome(x[1:])
    elif not x[-1].isalpha():
        return is_palindrome(x[0:-1])
    elif x[0] != x[-1]:
        return False
    else: return is_palindrome(x[1:-1])



### Assignment 2-2


#1
[1,'hi',1.1]

#2 (there appears to be a typo: correcting to [1,1,[1,2]])
[1,1,[1,2]][2][1] # 2

#3
lst = ['a','b','c']
['a','b','c'][1:] # ['b','c']

#4
{'sun':0,'mon':1,'tues':2,'wed':3,'thur':4,'fri':5,'sat':6}

#5
d={'k1':[1,2,3]} 
d['k1'][1] # 2

#6
tuple([1,[2,3]]) # (1, [2,3])

#7
misp = set("Mississippi") # {'M', 's', 'i', 'l'}

#8
misp.add('X') # {'M', 's', 'i', 'l', 'X'}

#9
set([1,1,2,3]) # {1, 2, 3}

#Q1

def q1 (start, end):
    """ returns list of all values between start and end that are divisible by 7 but not by 5 """

    i, nums = start, []
    while i <= end:
        if i%7 != 0:
            i += 7-(i%7)
        if i%5 != 0:
            nums.append(i)
        i += 7
    return nums

print(q1(2000,3200))

#Q2

def factorial(x):
    """ returns x! """
    if x == 1:
        return x
    return x * factorial(x-1)

print(factorial(int(input("Provide a number and I will return the factorial of that number: "))))

#Q3

def sqr_dict(x):
    """ returns dictionary of names 1 through x each paired with their squared value """

    return {i:i*i for i in range(1,x+1)}

print(sqr_dict(int(input('Provide an integer > 0. I will return a dictionary with names 1 through that number paired with their square: '))))

#Q4

user_seq = input("Provide a sequence of numbers, separated by commas, and I will return a list and tuple with those values: ")

user_lst = [int(i) for i in user_seq.split(',')]

print(user_lst, tuple(user_lst))

#Q5

class PrintInput(object):

    def __init__(self):
        self.input = ""
    
    def getString(self):
        self.input = input('Say something: ')
    
    def printString(self):
        if self.input == "":
            print("You must first say something")
        else:
            print(self.input.upper())

str_input = PrintInput()
str_input.getString()
str_input.printString()


### Assignment 2-3

# Three is a Crowd
# Part 1

names = ['Ricci', 'Aja', 'Tatem', 'Jul']

def crowd_test(names):
    """ tells you if the room is crowded """

    if len(names) > 3:
        print("The room is crowded.")

print("Names: " + str(names)[1:-1])
crowd_test(names)

names.pop()

print("Names: " + str(names)[1:-1])
crowd_test(names)

# Part 2

def new_and_improved_crowd_test(names):
    """ tells you if the room is crowded or is not crowded """

    if len(names) > 3:
        print("The room is crowded.")
    else:
        print("The room is not very crowded")

print("Names: " + str(names)[1:-1])
new_and_improved_crowd_test(names)

# Six is a Mob

def mob_test(names):
    """ describes the state of the room """
    
    if len(names) == 0:
        print("The room is empty.")
    elif len(names) < 3:
        print("The room is not very crowded.")
    elif len(names) < 6:
        print("The room is crowded")
    else:
        print("There is a mob in the room")

names += ['Florencia', 'Braelyn', 'Hope']

print("Names: " + str(names)[1:-1])
mob_test(names)
