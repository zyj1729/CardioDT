import xml.etree.ElementTree as ET
tree = ET.parse('/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/raw_movement_data.xml')
root = tree.getroot()

numRoi = []
slide = []
x = []
y = []
ind = 0
for child in root:
	for detect in child.iter('detection'):
		numRoi.append(ind)
		slide.append(int(detect.get('t')))
		x.append(detect.get('x'))
		y.append(detect.get('y'))
	ind += 1
	
set = list(zip(numRoi, slide, x, y))
#set.sort(key = lambda t: t[1])

#for i in set:
#	print(str(i[0]) + " " + str(i[1]) + " " + i[2] + " " + i[3])

min_square_mov = 4
with open("/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/sorted_roi.txt", "w") as text_file:
	for i in range(len(set)):
#		if set[i][0] == set[i + 1][0] and ((set[i + 1][2] - set[i][2])**2 + (set[i + 1][3] - set[i][3])**2 > min_square_mov):
			text_file.write(str(set[i][0]) + " " + str(set[i][1]) + " " + set[i][2] + " " + set[i][3] + "\n")
