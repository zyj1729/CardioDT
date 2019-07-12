// .1. 尝试加入if condition。 只在变化剧烈的slices里画arrow. 
// .2. n to n + 1, ...n + k。 
// .3. 加长arrow 的 length to be more visulizable
// .4. 随时更新circle来判断位置变化

var count = 0;
var locationX;
var locationY;
var fileName;
var slices;
// stageFileName not used
var stageFileName;

function locateROI() {
	roiManager("reset")
	Dialog.create("Set Parameters");
	minGray = 190;
	minSize = 50;
	maxSize = 100;
	Dialog.addNumber("Minimum Grayscale Value:", minGray);
	Dialog.addNumber("Minimum Size:", minSize);
	Dialog.addNumber("Maximum Size:", maxSize);
	Dialog.show();
	minGray = Dialog.getNumber();
	minSize = Dialog.getNumber();
	maxSize = Dialog.getNumber();
	getDimensions(width, height, channels, slices, frames);
	run("Duplicate...", "title=CopyOfOriginal duplicate");
	setAutoThreshold("Default dark");
	setThreshold(minGray, 255);
	run("Create Mask");
	run("Analyze Particles...", "size=" + minSize + "-" + maxSize + " exclude add");
	selectWindow(fileName);
	
	//roiManager("Show All");
	//roiManager("multi measure");
	roiManager("Deselect");
	roiManager("Measure");
	IJ.renameResults("ROI");

	count = roiManager("count");
	locationX = newArray(count);
	locationY = newArray(count);
	//roiManager("reset");
	roiManager("deselect")
	roiManager("delete");
}
	
function drawCircle() {
	for (c = 1; c <= count; c++) {
		selectWindow("ROI");
		locationX[c - 1] = Table.get("X", c - 1);
		locationY[c - 1] = Table.get("Y", c - 1);
		makeOval(locationX[c - 1] - 15, locationY[c - 1] - 15, 30, 30);
		roiManager("Add");
	}
}

macro "Locate_ROI" {
	fileName = getInfo("image.filename");
	run("Duplicate...", "title=Stage duplicate");
	selectWindow("Stage")
	setSlice(1);
	setBatchMode(true);
	selectWindow(fileName);
	locateROI();
	l = 0;
	setSlice(1);
	while (l < 5) {
		l++;
		drawCircle();
		averageX = newArray(count);
		averageY = newArray(count);
		averageX2 = newArray(count);
		averageY2 = newArray(count);
		for (i = 1; i <= count; i++) {
			// locate the brightest point in the ROI
			roiManager("select", i - 1);
			//roiManager("deselect");
			noise=2; 
			run("Find Maxima...", "noise=" + noise + " output=[Point Selection]"); 
			run("Set Measurements...", "centroid redirect=None decimal=0"); 
			run("Measure"); 

			selectWindow("Results");
			xTop = newArray(nResults);
			yTop = newArray(nResults);
			sumX = 0;
			sumY = 0;
			for (j = 0; j < nResults; j++) {
				xTop[j] = getResult("X", j);
				yTop[j] = getResult("Y", j);
				sumX = sumX + getResult("X", j);
				sumY = sumY + getResult("Y", j);
				}
			averageX[i - 1] = sumX / nResults;
			averageY[i - 1] = sumY / nResults;
			
			//print (averageX + ", " + averageY + ", " + nResults);
			close("Results");
			
			//print(getSliceNumber());
			roiManager("select", i - 1);
			selectWindow(fileName);
			run("Next Slice [>]");
			roiManager("Update");
			run("Find Maxima...", "noise=" + noise + " output=[Point Selection]"); 
			run("Set Measurements...", "mean min centroid redirect=None decimal=6"); 
			run("Measure"); 
			selectWindow("Results");
			xTop2 = newArray(nResults);
			yTop2 = newArray(nResults);
			sumX2 = 0;
			sumY2 = 0;
			for (k = 0; k < nResults; k++) {
				xTop2[k] = getResult("X", k);
				yTop2[k] = getResult("Y", k);
				sumX2 = sumX2 + getResult("X", k);
				sumY2 = sumY2 + getResult("Y", k);
			}
			averageX2[i - 1] = sumX2 / nResults;
			averageY2[i - 1] = sumY2 / nResults;
			close("Results");
			run("Previous Slice [<]");
		}
		selectWindow("Stage");
		roiManager("deselect")
		roiManager("delete");
		run("Next Slice [>]");
		for (rA = 0; rA < count; rA++) {
			//print(averageX[rA] + ", " + averageY[rA] + ", " + averageX2[rA] + ", " + averageY2[rA]);
			makeArrow(averageX[rA], averageY[rA], averageX2[rA], averageY2[rA], "small");
			Roi.setStrokeColor("green");
			
			run("Add Selection...");
			run("Flatten", "stack");
		}
		selectWindow(fileName);
		run("Next Slice [>]");
		roiManager("show none");

	}
	
	}
	
//run("Read and Write Excel","file=[/Users/zhangyujie/desktop/testSpotFinder.xlsx] dataset_label=" + fileName);
