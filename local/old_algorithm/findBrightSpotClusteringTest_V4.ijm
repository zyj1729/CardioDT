// .1. 现在getDiffGV好像只是用了第一张做reference, 看要不要改成dynamic variable. 
// .2. 自动找到用于做reference 的一张slice. 

// .3. 在movie 08 sample里改roi 大小(r = 4)，注释了删除meaen255 的初始ROI,
// neighbor 改成10， numMax 改成1
//
var count = 0;
var locationX;
var locationY;
var OriginId;
var slices;
var frames;
var stageFileName;
var width;
var height;
var sliceCount;
function locateROI() {
	roiManager("reset")
	getDimensions(width, height, channels, slices, frames);
	if (slices > frames) {
		sliceCount = slices;	
	} else {
		sliceCount = frames;	
	}
	
	selectImage(OriginId);
	run("Find Maxima...", "prominence=" + tolerance + " output=[Point Selection]");	
	roiManager("add");
	roiManager("Deselect");
	roiManager("Measure");

	
	delete = 0;
	for (i = 0; i < nResults; i++) {
		if (delete == 1) {
			i -= 1;	
			delete = 0;
		}
		if (Table.get("Mean", i) == 255) {
			IJ.deleteRows(i, i);
			delete = 1;
		}
	}


	count = nResults;

	IJ.renameResults("ROI");

	locationX = newArray(count);
	locationY = newArray(count);
	roiManager("deselect")
	roiManager("delete");
}

//function locateROI() {
//	roiManager("reset")
//	Dialog.create("Set Parameters");
//	minGray = 190;
//	minSize = 50;
//	maxSize = 100;
//	Dialog.addNumber("Minimum Grayscale Value:", minGray);
//	Dialog.addNumber("Minimum Size:", minSize);
//	Dialog.addNumber("Maximum Size:", maxSize);
//	Dialog.show();
//	minGray = Dialog.getNumber();
//	minSize = Dialog.getNumber();
//	maxSize = Dialog.getNumber();
//	getDimensions(width, height, channels, slices, frames);
//	if (slices > frames) {
//		sliceCount = slices;	
//	} else {
//		sliceCount = frames;	
//	}
//	run("Duplicate...", "title=CopyOfOriginal duplicate");
//	setAutoThreshold("Default dark");
//	setThreshold(minGray, 255);
//	run("Create Mask");
//	run("Analyze Particles...", "size=" + minSize + "-" + maxSize + " exclude add");
//	//selectWindow(fileName);
//	selectImage(OriginId);
//	
//	roiManager("Deselect");
//	roiManager("Measure");
//	IJ.renameResults("ROI");
//
//	count = roiManager("count");
//	locationX = newArray(count);
//	locationY = newArray(count);
//	roiManager("deselect")
//	roiManager("delete");
//}

function drawCircle() {
	for (c = 1; c <= count; c++) {
		selectWindow("ROI");
		locationX[c - 1] = Table.get("X", c - 1);
		locationY[c - 1] = Table.get("Y", c - 1);
		makeOval(locationX[c - 1] - 15, locationY[c - 1] - 12, 24, 24);
//		makeOval(locationX[c - 1] - 4, locationY[c - 1] - 4, 8, 8);
		roiManager("Add");
	}
}

var satisfaction = false;
var tolerance = 45;
var maxRange = 8;
var minRange = 2;
function preview() {
	Dialog.create("Set Parameters");
	Dialog.addNumber("Maxima Tolerance:", tolerance);
	Dialog.addNumber("Minima Movement Range (1 ~ 3):", minRange);
	Dialog.addNumber("Maxima Movement Range (8 ~ 10):", maxRange);
	Dialog.addNumber("Arrows Augmentation:", 5);
	Dialog.show();
	tolerance = Dialog.getNumber();
	minRange = Dialog.getNumber();
	maxRange = Dialog.getNumber();
	augment = Dialog.getNumber();
	selectImage(OriginId);
	run("Find Maxima...", "prominence=" + tolerance + " output=[Point Selection]");	
}

function getDiffMaxGV(count) {
	selectImage(OriginId);
	run("Stack Difference", "gap=1");
	selectWindow("Difference Image");
	setSlice(1);
	maxDiffGV = newArray(count);
	maxDiffGV[0] = 0;
	for (i = 1; i < count; i++) {
		getStatistics(area, mean, min, max);
		maxDiffGV[i] = max;
		run("Next Slice [>]");
	}
	selectImage(OriginId);
	return maxDiffGV;
	
}


function SumColumn(num, column) {
	sumN = 0;
	for (i = 0; i < num; i++) {
		sumN = sumN + getResult(column, i);
	}
	return sumN;
}

function Sum(array) {
	sumN = 0;
	for (i = 0; i < array.length; i++) {
		sumN = sumN + array[i];
	}
	return sumN;
}


var averageX;
var averageY;
var averageX2;
var averageY2;

var resultX1;
var resultY1;
var resultX2;
var resultY2;
var resultListCount = 0;
function getMovement(times) {	
	averageX = newArray(times);
	averageY = newArray(times);
	averageX2 = newArray(times);
	averageY2 = newArray(times);
	if (resultListInitial == false) {
		// Create 2 results lists to contain the data to show up on the result table. 
		// The size should be change to slices number in the final version. 
		resultX1 = newArray(times * sliceCount);
		resultY1 = newArray(times * sliceCount);
		resultX2 = newArray(times * sliceCount);
		resultY2 = newArray(times * sliceCount);
		resultListInitial = true;
	}
	arrowResult = "Arrow Values";
	for (i = 1; i <= times; i++) {
		
		roiManager("select", i - 1);

		weightedCoordinate();
		averageX[i - 1] = weightedX;
		averageY[i - 1] = weightedY;

		resultX1[resultListCount] = averageX[i - 1];
		resultY1[resultListCount] = averageY[i - 1];
			
		roiManager("select", i - 1);
		selectImage(OriginId);
		run("Next Slice [>]");
		roiManager("Update");

		weightedCoordinate();
		averageX2[i - 1] = weightedX;
		averageY2[i - 1] = weightedY;
		
		run("Previous Slice [<]");

		resultX2[resultListCount] = averageX2[i - 1];
		resultY2[resultListCount] = averageY2[i - 1];	
		resultListCount ++;
	}
}

var weightedX;
var weightedY;
//var ROIPositionX;
//var ROIPositionY;
function weightedCoordinate() {
//		maxPosition();
		neighborNum = 20;
		sumXs = 0;
		sumYs = 0;
//		for (i = 0; i < numMax; i++) {
//			nearestNBrightest(maxX[i], maxY[i], neighborNum);
//			sumXs = sumXs + Sum(outputXCo);
//			sumYs = sumYs + Sum(outputYCo);
//			//print(outputXCo.length);
//		}

//		nearestNBrightest(maxX[i], maxY[i], neighborNum);
		getSelectionBounds(x, y, ROIWidth, ROIHeight);
		nearestNBrightest(floor(x + (ROIWidth / 2)), floor(y + (ROIHeight / 2)), neighborNum);
		sumXs = sumXs + Sum(outputXCo);
		sumYs = sumYs + Sum(outputYCo);
		//print(outputXCo.length);
		
		weightedX = sumXs / (numMax * neighborNum);
		weightedY = sumYs / (numMax * neighborNum);
		
}


var neighborNum;
var outputXCo;
var outputYCo;
function nearestNBrightest(x, y, n) {
	currentNum = 0;
	xCo = newArray(0);
	yCo = newArray(0);
	outputXCo = newArray(0);
	outputYCo = newArray(0);
	valueArray = newArray(0);
	while (currentNum < n) {
		if (positionUsedCheck(x - 1, y, x, y) == false) {
			valueArray = Array.concat(valueArray, getPixel(x - 1, y));
			xCo = Array.concat(xCo, x - 1);
			yCo = Array.concat(yCo, y);
			//print("concat1");
		}
		if (positionUsedCheck(x, y - 1, x, y) == false) {
			valueArray = Array.concat(valueArray, getPixel(x, y - 1));
			xCo = Array.concat(xCo, x);
			yCo = Array.concat(yCo, y - 1);
			//print("concat2");
		}
		if (positionUsedCheck(x + 1, y, x, y) == false) {
			valueArray = Array.concat(valueArray, getPixel(x + 1, y));
			xCo = Array.concat(xCo, x + 1);
			yCo = Array.concat(yCo, y);
//			print("concat3");
		}
		if (positionUsedCheck(x, y + 1, x, y) == false) {
			valueArray = Array.concat(valueArray, getPixel(x, y + 1));
			xCo = Array.concat(xCo, x);
			yCo = Array.concat(yCo, y + 1);
//			print("concat4");
		}
		sortPixels(xCo, yCo, valueArray);
		x = xCo[xCo.length - 1];
		y = yCo[yCo.length - 1];
		outputXCo = Array.concat(outputXCo, x);
		outputYCo = Array.concat(outputYCo, y);
		//print(x + ", " + y);
		xCo = Array.trim(xCo, xCo.length - 1);
		yCo = Array.trim(yCo, yCo.length - 1);
		valueArray = Array.trim(valueArray, valueArray.length - 1);
		//print(xCo.length);
		currentNum++;
	}
}

var maxX;
var maxY;
var numMax = 1;
function maxPosition() {
	maxX = newArray(numMax);
	maxY = newArray(numMax);
	getRawStatistics(nPixels, mean, min, max);
	Roi.getContainedPoints(xpoints, ypoints);
	value = newArray(xpoints.length);
	for (i = 0; i < value.length; i++) {
		value[i] = getPixel(xpoints[i], ypoints[i]);
	}
	for (j = 0; j < numMax; j++) {
		temp = Array.findMaxima(value, 0.01);
		max = temp[0];
		maxX[j] = xpoints[max];
		maxY[j] = ypoints[max];
		value[max] = 0;
	}	
}

//The size of the check arrays are hardcode for now. 
//var check;
function positionUsedCheck(x1, y1, centerX, centerY) {
	xCorner = centerX - neighborNum/2;
	yCorner = centerY - neighborNum/2;
	check = newArray(pow(neighborNum, 2));
	if (x1 >= (centerX - neighborNum/2) && x1 <= (centerX + neighborNum/2) && y1 >= (centerY - neighborNum/2) && y1 <= (centerY + neighborNum/2)) {
		index = (y1 - yCorner) * neighborNum + (x1 - xCorner);
		if (check[index] == 0) {
			check[index] = 1;
			return false;	
		} else {
			return true;	
		}
	} else {
		print("pixel out of checking range!");	
	}
}


function sortPixels(xList, yList, values) {
	tempV = 0;
	tempX = 0;
	tempY = 0;
	for (i = 0; i < values.length; i++) {
		for (j = 0; j < values.length - i - 1; j++) {
			if (values[j] > values[j + 1]) {
				tempV = values[j + 1];
				tempX = xList[j + 1];
				tempY = yList[j + 1];
				values[j + 1] = values[j];
				xList[j + 1] = xList[j];
				yList[j + 1] = yList[j];
				values[j] = tempV;	
				xList[j] = tempX;
				yList[j] = tempY;
			}
		}
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


var l;
var sliceTrack;
var augment;
var resultListInitial = false;
macro "Locate_ROI" {
	OriginId = getImageID();
	setSlice(1);
	while (satisfaction == false) {
		preview();
		Dialog.create("Preview");
		Dialog.addCheckbox("Satisfied ?", false);
		Dialog.show();
		satisfaction = Dialog.getCheckbox();
	}
	run("Duplicate...", "title=Stage duplicate");
	selectWindow("Stage");
	setSlice(1);
	setBatchMode(true);
	selectImage(OriginId);
	locateROI();
	maxDiffValue = getDiffMaxGV(sliceCount);
	l = 1;
	everDrawCircle = false;
	setSlice(1);
	sliceTrack = newArray(sliceCount);
	run("Set Measurements...", "mean centroid redirect=None decimal=3");
	while (l < sliceCount) {
		threshold = 20;
		if (maxDiffValue[l] > threshold) {
			// Draw the Circle around the ROIs 
			if (everDrawCircle == false) {
				drawCircle();
				everDrawCircle = true;
			} else {
				selectImage(OriginId);
				for (o = 0; o < count; o++) {
//					makeOval(averageX2[o] - 4, averageY2[o] - 4, 8, 8);
					makeOval(averageX2[o] - 12, averageY2[o] - 12, 24, 24);
					roiManager("Add");
				}	
			}
			// Get the coordinates we need to draw the arrows
			getMovement(count);

			// Change to the next slice of the stage to prepare for drawing arrows
			selectWindow("Stage");
			roiManager("deselect");
			roiManager("delete");
			run("Next Slice [>]");

			// Set the multiplying values of the length of the arrows and Draw arrows 
		}

		selectImage(OriginId);
		run("Next Slice [>]");
		if (maxDiffValue[l] <= threshold) {
			resultListCount += count;
			sliceTrack[l] = 1;
			currentSlice = getSliceNumber();
			selectWindow("Stage");
			setSlice(currentSlice);
			selectImage(OriginId);
		} else {
			sliceTrack[l] = -1;	
		}
		l++;
	}

	rowNum = 0;
	layer = 0;
	sliceTrackIndex = 1;
	needToFlat = 0;
	selectWindow("Stage");
	setSlice(2);
	for (ii = 0; ii < count * (l - 1); ii++) {
		if (layer >= count) {
			layer = 0;	
			rowNum ++;
//			if (sliceTrack[sliceTrackIndex] != 1 && needToFlat == 1) {
//				run("Flatten", "stack");
//			}
			needToFlat = 0;
			run("Next Slice [>]");
			sliceTrackIndex ++;
		}			

		if (sliceTrack[sliceTrackIndex] != 1 && sqrt(pow(resultX2[ii] - resultX1[ii], 2) + pow(resultY2[ii] - resultY1[ii], 2)) <= maxRange && sqrt(pow(resultX2[ii] - resultX1[ii], 2) + pow(resultY2[ii] - resultY1[ii], 2)) >= minRange) {
			destinateX = (resultX2[ii] - resultX1[ii]) * augment + resultX1[ii];
			destinateY = (resultY2[ii] - resultY1[ii]) * augment + resultY1[ii];
			makeArrow(resultX1[ii], resultY1[ii], destinateX, destinateY, "filled");
			run("Arrow Tool...", "width=1 size=4 color=Green style=Open");
			Roi.setStrokeColor("green");
			run("Add Selection...");		
//			if (layer == count - 1) {
//				needToFlat = 1;	
//			}
		}
//		if (sqrt(pow(resultX2[ii] - resultX1[ii], 2) + pow(resultY2[ii] - resultY1[ii], 2)) <= maxRange) {
		setResult("Start X" + layer, rowNum, resultX1[ii]);
		setResult("Start Y" + layer, rowNum, resultY1[ii]);	
		setResult("End X" + layer, rowNum, resultX2[ii]);
		setResult("End Y" + layer, rowNum, resultY2[ii]);
		setResult("Arrow Length" + layer, rowNum, sqrt(pow(resultX2[ii] - resultX1[ii], 2) + pow(resultY2[ii] - resultY1[ii], 2)));
		if (rowNum == 0) {
			setResult("Direction Change" + layer + " (degree)", rowNum, 0);	
		} else {
			setResult("Direction Change" + layer + " (degree)", rowNum, getDirection(resultX1[ii], resultY1[ii], resultX2[ii], resultY2[ii], resultX1[ii - count], resultY1[ii - count], resultX2[ii - count], resultY2[ii - count]));		
		}
//		}
		layer ++;	
	}
	selectImage(OriginId);
	run("Select All");
}
	
//run("Read and Write Excel","file=[/Users/zhangyujie/desktop/testSpotFinder.xlsx] dataset_label=test");
