import os

wdFile = open(os.getcwd() + '/Working_Directory.txt')
roi_sorted = wdFile.read() + 'medium_products/sorted_roi.txt'

def smooth(y, box_pts):
    box = [1 / box_pts for i in range(box_pts)]
    y_smooth = []
    for i in range(len(y) - box_pts + 1):
        temp_y = 0
        for j in range(box_pts):
            temp_y += y[i + j] * box[j]
        y_smooth.append(temp_y)
    return y_smooth


f = open(roi_sorted, "r")
data = f.readlines()
data = [i.split("\n")[0] for i in data]
ff = data[0].split(" ")[0]
roi_xs = []
roi_ys = []
roi_x = []
roi_y = []
roi_slide_nums = []
roi_slide_num = []
for d in data:
    temp = d.split(" ")
    if temp[0] == ff:
        roi_x.append(float(temp[2]))
        roi_y.append(float(temp[3]))
        roi_slide_num.append(int(temp[1]))
        if d == data[-1]:
            roi_x = [round(sum(roi_x) / len(roi_x), 1)] + roi_x
            roi_y = [round(sum(roi_y) / len(roi_y), 1)] + roi_y
            roi_x = smooth(roi_x, 2)
            roi_y = smooth(roi_y, 2)
            roi_xs.append(roi_x)
            roi_ys.append(roi_y)
            roi_slide_nums.append(roi_slide_num)
    else:
        ff = temp[0]
        roi_x = [round(sum(roi_x) / len(roi_x), 1)] + roi_x
        roi_y = [round(sum(roi_y) / len(roi_y), 1)] + roi_y
        roi_x = smooth(roi_x, 2)
        roi_y = smooth(roi_y, 2)
        roi_xs.append(roi_x)
        roi_ys.append(roi_y)
        roi_slide_nums.append(roi_slide_num)
        roi_x = [float(temp[2])]
        roi_y = [float(temp[3])]
        roi_slide_num = [int(temp[1])]
        
redirect_data = []
index = 0
for i in range(len(roi_xs)):
    for j in range(len(roi_xs[i])):
        temp = str(index) + " " + str(roi_slide_nums[i][j]) + " " + str(roi_xs[i][j]) + " " + str(roi_ys[i][j])
        redirect_data.append(temp)
    index += 1

    
with open(roi_sorted, "w") as text_file:
    for d in redirect_data:
        text_file.write(d + "\n")

    

    
    
    
    
    
    
    