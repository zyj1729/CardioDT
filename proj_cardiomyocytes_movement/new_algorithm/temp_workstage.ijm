
roiManager("reset");

// Get the ROI track mate data by calling 2 functions. 
originId = getImageID();
run("get track mate data");
run("roi xml to txt");

// Calculate oval redius. 
getDimensions(width, height, channels, slices, frames);
var ovalRadius = 0;
refRadius = 10;
refWidth = 1000;
refHeight = 700;
ovalRadius = round(sqrt(pow(refRadius, 2) * ((width * height) / (refWidth * refHeight))));


var f = File.openAsString("/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/sorted_roi.txt");
var lines = split(f, "\n");
var mark;
var markCount = 0;
// Filter out the ROIs that has pixel value 255, which are the white shadow. 
function filter255(array) {
	mark = newArray(array.length);
	markCount = 0;
	for (l = 0; l < array.length; l++) {
		line = split(array[l], " ");
//		print(getValue(parseInt(line[2]), parseInt(line[3])));
		if (getValue(parseInt(line[2]), parseInt(line[3])) == 255) {
			mark[l] = 1;
			if (l < array.length - 1) {
				nextLine = split(array[l + 1], " ");
			} else {
				break;	
			}
			if (parseInt(line[0]) != parseInt(nextLine[0])) {
				markCount++;
			}
		}	
	}
}

// A function to draw the ROIs in the first slice as preview. 
function preview() {
	f = File.openAsString("/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/sorted_roi.txt");
	lines = split(f, "\n");
	filter255(lines);
	setSlice(1);
	// draw all the selected roi in the first slice as a preview. 
	for (sInd = 0; sInd < lines.length; sInd++) {
		if (mark[sInd] == 1) {
			continue;	
		}
		temp = lines[sInd];
		slice = split(temp, " ");
		if (slice[1] == 0) {
			x1 = round(slice[2] - ovalRadius);
			xC = ovalRadius * 2;
			y1 = round(slice[3] - ovalRadius);
			yC = ovalRadius * 2;
			makeOval(x1, y1, xC, yC);
			roiManager("add");
		}
	}
	roiManager("Show All");
	temp = lines[lines.length - 1];
	roiNums = split(temp, " ");
	spotNum = parseInt(roiNums[0]) - markCount;
}

// A preview window to let users decide if the number of ROIs is acceptable. 
satisfaction = false;
time = 0;
while (satisfaction == false) {
	if (time != 0) {
		run("get track mate data");
		run("roi xml to txt");
		roiManager("reset");
	}
	time++;
	selectImage(originId);
	preview();
	Dialog.create("Preview");
	Dialog.addCheckbox("Satisfied ?", false);
	Dialog.show();
	satisfaction = Dialog.getCheckbox();
}


// Draw arrows. 
run("Duplicate...", "title=Stage duplicate");
sliceCount = 0;
if (slices >= frames) {
	sliceCount = slices;
} else {
	sliceCount = frames;	
}

numRoi = newArray(lines.length);
slide = newArray(lines.length);
x = newArray(lines.length);
y = newArray(lines.length);

a = 4;
selectWindow("Stage");
min_square_mov = 0;
for (i = 1; i < lines.length; i++ ) {
//	if (i < sliceCount) {
//		setResult("Slice Number", i - 1, i + 1);
//	}
	if (mark[i] == 1) {
		continue;	
	}
	lastL = split(lines[i - 1], " ");
	currL = split(lines[i], " ");
//	if (parseInt(currL[1]) < sliceCount - 1) {
//		nextL = split(lines[i + 1], " ");
//	}
	if (lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) > min_square_mov) {
		setSlice(currL[1] + 1);
		makeArrow(round(lastL[2]), round(lastL[3]), round(lastL[2]) + a * (round(currL[2]) - round(lastL[2])), round(lastL[3]) + a * (round(currL[3]) - round(lastL[3])), "filled");
		run("Arrow Tool...", "width=1 size=4 color=Green style=Open");	
		Roi.setStrokeColor("green");
		run("Add Selection...");	
	} 
//	if (parseInt(currL[1]) < sliceCount - 1) {
//		dir = getDirection(parseFloat(currL[2]), parseFloat(currL[3]), parseFloat(nextL[2]), parseFloat(nextL[3]), parseFloat(lastL[2]), parseFloat(lastL[3]), parseFloat(currL[2]), parseFloat(currL[3]));
//		setResult("Start X" + currL[0], lastL[1], lastL[2]);
//		setResult("Start Y" + currL[0], lastL[1], lastL[3]);
//		setResult("End X" + currL[0], lastL[1], currL[2]);
//		setResult("End X" + currL[0], lastL[1], currL[3]);
//		setResult("Movement Length " + currL[0], lastL[1], sqrt(pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2)));
//		setResult("Direction Change " + currL[0] + " (degree)", lastL[1], dir);
//	}
	
}

for (i = 1; i < lines.length; i++ ) {
	if (i < sliceCount) {
		setResult("Slice Number", i - 1, i + 1);
	}
	if (mark[i] == 1) {
		continue;	
	}
	lastL = split(lines[i - 1], " ");
	currL = split(lines[i], " ");
	if (parseInt(currL[1]) < sliceCount - 1) {
		nextL = split(lines[i + 1], " ");
	}
	if (parseInt(currL[1]) < sliceCount - 1) {
		dir = getDirection(parseFloat(currL[2]), parseFloat(currL[3]), parseFloat(nextL[2]), parseFloat(nextL[3]), parseFloat(lastL[2]), parseFloat(lastL[3]), parseFloat(currL[2]), parseFloat(currL[3]));
		setResult("Start X" + currL[0], lastL[1], lastL[2]);
		setResult("Start Y" + currL[0], lastL[1], lastL[3]);
		setResult("End X" + currL[0], lastL[1], currL[2]);
		setResult("End X" + currL[0], lastL[1], currL[3]);
		setResult("Movement Length " + currL[0], lastL[1], sqrt(pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2)));
		setResult("Direction Change " + currL[0] + " (degree)", lastL[1], dir);
	}
}

function getDirection(oriX, oriY, desX, desY, formOriX, formOriY, formDesX, formDesY) {

	if ((oriX == desX && oriY == desY) || (formOriX == formDesX && formOriY == formDesY)) {
		return NaN;	
	}

	infinity = 1/0;
	
	if (formDesX - formOriX == 0) {
		if (formDesY - formOriY < 0) {
			k1 = infinity;	
		} else {
			k1 = -infinity;
		}
	} else {
		k1 = (formDesY - formOriY) / (formDesX - formOriX);		
	}

	b1 = formOriY - k1 * formOriX;

	if (desX - oriX == 0) {
		if (desY - oriY < 0) {
			k2 = infinity;	
		} else {
			k2 = -infinity;
		}
	} else {
		k2 = (desY - oriY) / (desX - oriX);		
	}
	
	b2 = oriY - k2 * oriX;
	
	constant = (1 - k1 * k2) / (k1 + k2);
	bisecK = sqrt(1 + pow(constant, 2)) - constant;

	formDist = sqrt(pow(formDesX - formOriX, 2) + pow(formDesY - formOriY, 2));
	currDist = sqrt(pow(desX - oriX, 2) + pow(desY - oriY, 2));
	formOriToCurrDes = sqrt(pow(desX - formOriX, 2) + pow(desY - formOriY, 2));

	cosDegree = (pow(formDist, 2) + pow(currDist, 2) - pow(formOriToCurrDes, 2)) / (2 * formDist * currDist);
	degree = 180 - acos(cosDegree) * (180 / PI);

	deltaX = formDesX - formOriX;
	deltaY = formDesY - formOriY;
	
	if (deltaX > 0) {
		if (desY <= desX * k1 + b1) {
			return degree;	
		} else {
			return -degree;	
		}
	} else if (deltaY < 0) {
		if (desY >= desX * k1 + b1) {
			return degree;	
		} else {
			return -degree;	
		}	
	} else {
		if (deltaY < 0) {
			if (desX < oriX) {
				return degree;	
			} else {
				return -degree;	
			}
		} else {
			if (desX > oriX) {
				return degree;	
			} else {
				return -degree;	
			}
		}
	}
}
	

/*  .1. trackMate will recognize white space as ROIs, need to remove it to save time. done. 
 *  .2. Need to find a way to automatically find the proper threshold or at least let the user
 *  change the threshold in a preview window. 
 *  .3. call the 3 plugins in the main script. done.
 *  .4. push codes to github. done. 
 *  .5. add orientation and graph. decide whether use python or ijm. 
 */

