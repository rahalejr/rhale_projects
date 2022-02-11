### Assignment 4-1


#1
func = lambda: print("Hello World!")


#2
func2 = lambda name: print(f"Hi! My name is {name}.")


#3
func3 = lambda x,y,z: x if z else y


#4
func4 = lambda x,y: x*y


#5
is_even = lambda x: x%2 == 0


#6
greater_than = lambda x,y: x > y


#7
sum_args = lambda *args: sum(args)


#8
even_args = lambda *args: [i for i in args if i%2 == 0]


#9
alt_string = lambda x: ''.join([x[i].upper() if i%2 > 0 else x[i].lower() for i in range(len(x))])


#10
# need clarification on what the question is asking


#11
two_string = lambda x,y: x[0] == y[0]


#12
# need clarification on what the question is asking


#13
one_four = lambda x: ''.join([x[i].upper() if i == 0 or i == 3 else x[i] for i in range(len(x))])




### Assignment 4-2


## 1 & 2
# I am assuming each element of the list of lists is a row from the table

order_calc = lambda orders: [(i[0], i[2]*i[3]) if i[2]*i[3] >= 100 else (i[0], i[2]*(i[3]+10)) for i in orders]


## 3

def new_order(orders):
    output = []
    for i in orders:
        summed = 0
        for j in i[1:]:
            if j[1]*j[2] >= 100:
                summed += j[1]*j[2]
            else:
                summed += j[1]*(j[2]+10)
        output += [(i[0],summed)]
    return output

test_input = [[234,(345,4,15),(654,6,20)], [345,(838,3,29),(454,4,8)]]

print(new_order(test_input)) # output: [(234, 220), (345, 189)]
