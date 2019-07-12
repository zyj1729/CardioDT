//function getDirection(oriX, oriY, desX, desY, formOriX, formOriY, formDesX, formDesY) {
//
//	if ((oriX == desX && oriY == desY) || (formOriX == formDesX && formOriY == formDesY)) {
//		return NaN;	
//	}
//
//	infinity = 1/0;
//	
//	if (formDesX - formOriX == 0) {
//		if (formDesY - formOriY < 0) {
//			k1 = infinity;	
//		} else {
//			k1 = -infinity;
//		}
//	} else {
//		k1 = (formDesY - formOriY) / (formDesX - formOriX);		
//	}
//
//	b1 = formOriY - k1 * formOriX;
//
//	if (desX - oriX == 0) {
//		if (desY - oriY < 0) {
//			k2 = infinity;	
//		} else {
//			k2 = -infinity;
//		}
//	} else {
//		k2 = (desY - oriY) / (desX - oriX);		
//	}
//	
//	b2 = oriY - k2 * oriX;
//	
//	constant = (1 - k1 * k2) / (k1 + k2);
//	bisecK = sqrt(1 + pow(constant, 2)) - constant;
//
//	formDist = sqrt(pow(formDesX - formOriX, 2) + pow(formDesY - formOriY, 2));
//	currDist = sqrt(pow(desX - oriX, 2) + pow(desY - oriY, 2));
//	formOriToCurrDes = sqrt(pow(desX - formOriX, 2) + pow(desY - formOriY, 2));
//
//	cosDegree = (pow(formDist, 2) + pow(currDist, 2) - pow(formOriToCurrDes, 2)) / (2 * formDist * currDist);
//	degree = 180 - acos(cosDegree) * (180 / PI);
//
//	deltaX = formDesX - formOriX;
//	deltaY = formDesY - formOriY;
//	
//	if (deltaX > 0) {
//		if (desY <= desX * k1 + b1) {
//			return degree;	
//		} else {
//			return -degree;	
//		}
//	} else if (deltaY < 0) {
//		if (desY >= desX * k1 + b1) {
//			return degree;	
//		} else {
//			return -degree;	
//		}	
//	} else {
//		if (deltaY < 0) {
//			if (desX < oriX) {
//				return degree;	
//			} else {
//				return -degree;	
//			}
//		} else {
//			if (desX > oriX) {
//				return degree;	
//			} else {
//				return -degree;	
//			}
//		}
//	}
//}

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

var fileName;
var augment;
macro "Locate_ROI" {
	OriginId = getImageID();
	fileName = File.name;
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
	
//
//		if (sliceTrack[sliceTrackIndex] != 1 && sqrt(pow(resultX2[ii] - resultX1[ii], 2) + pow(resultY2[ii] - resultY1[ii], 2)) <= maxRange && sqrt(pow(resultX2[ii] - resultX1[ii], 2) + pow(resultY2[ii] - resultY1[ii], 2)) >= minRange
//			&& sqrt(pow(resultX2[ii] - resultX1[ii % count + count * (startSlice - 1)], 2) + pow(resultY2[ii] - resultY1[ii % count + count * (startSlice - 1)], 2)) <= 1.5 * maxRange) {
//			destinateX = (resultX2[ii] - resultX1[ii % count + count * (startSlice - 1)]) * augment + resultX1[ii % count + count * (startSlice - 1)];
//			destinateY = (resultY2[ii] - resultY1[ii % count + count * (startSlice - 1)]) * augment + resultY1[ii % count + count * (startSlice - 1)];
//			makeArrow(resultX1[ii % count + count * (startSlice - 1)], resultY1[ii % count + count * (startSlice - 1)], destinateX, destinateY, "filled");
//			run("Arrow Tool...", "width=1 size=4 color=Green style=Open");
//			Roi.setStrokeColor("green");
//			run("Add Selection...");		
//		}
	setResult("Start X" + layer, rowNum, resultX1[ii]);
	setResult("Start Y" + layer, rowNum, resultY1[ii]);	
	setResult("End X" + layer, rowNum, resultX2[ii]);
	setResult("End Y" + layer, rowNum, resultY2[ii]);
	setResult("Movement Length " + layer, rowNum, sqrt(pow(resultX2[ii] - resultX1[ii], 2) + pow(resultY2[ii] - resultY1[ii], 2)));
	
	if (rowNum == 0) {
		setResult("Direction Change " + layer + " (degree)", rowNum, 0);	
	} else {
		setResult("Direction Change " + layer + " (degree)", rowNum, getDirection(resultX1[ii], resultY1[ii], resultX2[ii], resultY2[ii], resultX1[ii - count], resultY1[ii - count], resultX2[ii - count], resultY2[ii - count]));		
	}

	run("Select All");
}
	
//run("Read and Write Excel","file=[/Users/zhangyujie/desktop/testSpotFinder.xlsx] dataset_label=" + fileName);
