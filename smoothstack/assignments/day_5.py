### Assignment 5-1


def bmi_calc():
    
    num, bmis = int(input("How many individuals? ")), []
    
    for i in range(num):
        bmis += [input(f"Individual {i + 1}: (Format: weight height) ")]
        bmis[i] = [float(j) for j in bmis[i].split()]
        bmis[i] = round(bmis[i][0] / bmis[i][1]**2,1)
    
    return  ['obese' if i>= 30 else 'over' if i>=25 else 'normal' if i>=18.5 else 'under' for i in bmis]
    

print(bmi_calc())

