# Assignment 1-2, 1/7/22

#1
print((50+50)+(100-10)) # 190

#2 (there appears to be a typo in the first subproblem: 30+*6 -- correcting to 30+6)
print(30+6) # 36
print(6^6) # 0
print(6**6) # 36
print(6+6+6+6+6+6) # 36

#3
print("Hello World") # Hello World
print("Hello World : 10") # Hello World : 10

#4
def monthly_payment(P,R,L):
     """ Calculates monthly payment on loan of P, with annual interest rate R over L months """

    R = R/100/12 # calculate monthly interest rate from annual rate

    return round((P*R*pow(1+R, L)) / (pow(1+R,L)-1))
