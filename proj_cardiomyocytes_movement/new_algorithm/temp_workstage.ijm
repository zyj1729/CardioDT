run("get track mate data");
run("roi xml to txt");
print("Finished");
//run("draw track mate arrow");
//filter整个数目多少个，在find maxima附近多少范围的

//// Calculate oval redius. 
//getDimensions(width, height, channels, slices, frames);
//var ovalRadius = 0;
//var refRadius = 10;
//var refWidth = 1000;
//var refHeight = 700;
//ovalRadius = round(sqrt(pow(refRadius, 2) * ((width * height) / (refWidth * refHeight))));
//print(ovalRadius);

f = File.openAsString("/Users/zhangyujie/Desktop/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/sorted_roi.txt");
lines = split(f, "\n");
setSlice(1);
roiManager("deselect");
roiManager("Delete");
// draw all the selected roi in the first slice as a preview. 
for (sInd = 0; sInd < lines.length; sInd++) {
	temp = lines[sInd];
	slice = split(temp, " ");
	if (slice[1] == 0) {
		x1 = round(slice[2] - 2 * sqrt(2));
		xC = 4 * sqrt(2);
		y1 = round(slice[3] - 2 * sqrt(2));
		yC = 4 * sqrt(2);
		makeOval(x1, y1, xC, yC);
		roiManager("add");
	}
}
roiManager("Show All");

temp = lines[lines.length - 1];
roiNums = split(temp, " ");
print(roiNums[0]);

//while (satisfaction == false) {
//	preview();
//	Dialog.create("Preview");
//	Dialog.addCheckbox("Satisfied ?", false);
//	Dialog.show();
//	satisfaction = Dialog.getCheckbox();
//}
//
//
//var satisfaction = false;
//var tolerance = 45;
//var maxRange = 8;
//var minRange = 2;
//function preview() {
//	Dialog.create("Set Parameters");
//	Dialog.addNumber("Maxima Tolerance:", tolerance);
//	Dialog.addNumber("Minima Movement Range (1 ~ 3):", minRange);
//	Dialog.addNumber("Maxima Movement Range (8 ~ 10):", maxRange);
//	Dialog.addNumber("Arrows Augmentation:", 5);
//	Dialog.show();
//	tolerance = Dialog.getNumber();
//	minRange = Dialog.getNumber();
//	maxRange = Dialog.getNumber();
//	augment = Dialog.getNumber();
//	selectImage(OriginId);
//	run("Find Maxima...", "prominence=" + tolerance + " output=[Point Selection]");	
//}