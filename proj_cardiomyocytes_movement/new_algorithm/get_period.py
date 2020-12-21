import os


wdFile = open(os.getcwd() + '/Working_Directory.txt')
reference_file = wdFile.read() + 'medium_products/reference.txt'

f = open(reference_file, "r")
reference_data = f.readlines()
reference_data = [i.split("\n")[0] for i in reference_data]
stdCols = reference_data[0].split("\t")
stdCols = [i for i in range(len(stdCols)) if "StdDev" in stdCols[i]]
periods = []
for col in stdCols:
    std = [i.split("\t")[col] for i in reference_data][1:]
    std = [roundHalf(float(i)) for i in std]
    
    mini = min(std)
    maxi = max(std)
    few = True
    if maxi - mini < 0.25:
        sections = [mini]
    elif not few:
        sections = [mini - 0.1 + ((maxi - mini) / round(float(maxi - mini) * 2)) * i for i in range(round(float(maxi - mini) * 2 + 1))]
    else:
        sections = [mini - 0.1 + ((maxi - mini) / 2) * i for i in range(2)]
    gap_allowed = 0
    local_max_inds, local_min_inds = peakCalculate(std, gap_allowed, sections)
    periods.append(local_max_inds)

coordinates = reference_data[0].split("\t")
xCols = [i for i in range(len(coordinates)) if coordinates[i][0] == "X" in coordinates[i]]
yCols = [i for i in range(len(coordinates)) if coordinates[i][0] == "Y" in coordinates[i]]
coordinates = [(int(float(reference_data[1].split("\t")[xCols[i]])), int(float(reference_data[1].split("\t")[yCols[i]]))) for i in range(len(xCols))]
    
assert len(coordinates) == len(periods), "The number of coordinates doesn't match the number of periods."

data = redirect_data
ind = -1
temp_period = []
for i in range(len(data)):
    line = data[i].split(" ")
    if int(line[0]) == ind:
        if temp_period:
            if int(line[1]) in temp_period:
                data[i] += " M"
    else:
        ind = int(line[0])
        for c in range(len(coordinates)):
            if round(float(line[2])) == coordinates[c][0] and round(float(line[3])) == coordinates[c][1]:
                temp_period = periods[c]
                if int(line[1]) in temp_period:
                    data[i] += " M"
                break
            if c == len(coordinates) - 1:
                temp_period = []
        
    



def peakCalculate(gra_x, gap_allowed, sections):
    local_max_ind_x = []
    local_min_ind_x = []
    
    mini = min(gra_x)
    maxi = max(gra_x)
    
    for s in range(len(sections)):
    
        temp_max_x = min(gra_x)
        temp_max_ind_x = -1
        temp_min_x = max(gra_x)
        temp_min_ind_x = -1
        gap = 0
        std = stD(gra_x)
        mean = sections[s]
        if gra_x[0] < mean:
            neg_x = True
        else:
            neg_x = False
        for j in range(len(gra_x)):
            if gra_x[j] > mean and not neg_x:
                if gra_x[j] > temp_max_x:
                    temp_max_x = gra_x[j]
                    temp_max_ind_x = j
                gap += 1
            elif gra_x[j] <= mean and neg_x:
                if gra_x[j] < temp_min_x:
                    temp_min_x = gra_x[j]
                    temp_min_ind_x = j
                gap += 1
            elif gra_x[j] > mean and neg_x:
                if gap >= gap_allowed:
                    if temp_min_x > mean - 0.5 or len(sections) == 2:
                        local_min_ind_x.append(temp_min_ind_x)

                    temp_min_x = gra_x[j]
                    temp_min_ind_x = j
                    neg_x = False
                    if gra_x[j] > temp_max_x:
                        temp_max_ind_x = j
                        temp_max_x = gra_x[j]
                    gap = 0
                else:
                    neg_x = !neg_x
                    if gra_x[j] > temp_max_x:
                        temp_max_x = gra_x[j]
                        temp_max_ind_x = j
                    gap += 1
            elif gra_x[j] <= mean and not neg_x:
                if gap >= gap_allowed:
                    if temp_max_x < mean + 0.5 or len(sections) == 2:
                        local_max_ind_x.append(temp_max_ind_x)

                    temp_max_x = gra_x[j]
                    temp_max_ind_x = j
                    neg_x = True
                    if gra_x[j] < temp_min_x:
                        temp_min_ind_x = j
                        temp_min_x = gra_x[j]
                    gap = 0
                else:
                    neg_x = !neg_x
                    if gra_x[j] < temp_min_x:
                        temp_min_x = gra_x[j]
                        temp_min_ind_x = j
                    gap += 1
                    
            if j == len(gra_x) - 1:
                if neg_x:
                    if temp_min_x > mean - 0.5:
                        local_min_ind_x.append(temp_min_ind_x)
                else:
                    if temp_max_x < mean + 0.5:
                        local_max_ind_x.append(temp_max_ind_x)
                
    return sorted(local_max_ind_x), sorted(local_min_ind_x)
    

def roundHalf(number):
    result = ""
    if len(str(round(number, 1)).split(".")) == 1:
        result = float(number)
    elif float("0." + str(round(number, 1)).split(".")[1]) >= 0.3 and float("0." + str(round(number, 1)).split(".")[1]) <= 0.7:
        result = float(str(round(number, 1)).split(".")[0]) + 0.5
    elif float("0." + str(round(number, 1)).split(".")[1]) >= 0 and float("0." + str(round(number, 1)).split(".")[1]) <= 0.2:
        result = float(str(round(number, 1)).split(".")[0])
    elif float("0." + str(round(number, 1)).split(".")[1]) >= 0.8 and float("0." + str(round(number, 1)).split(".")[1]) < 0.99999999:
        result = float(str(round(number, 1)).split(".")[0]) + 1
    else:
        print(number)
    return result
