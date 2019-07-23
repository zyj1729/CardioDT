
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

// A preview window to let users decide if the number of ROIs is acceptable. 
satisfaction = false;
time = 0;
while (satisfaction == false) {
	if (time != 0) {
		run("get track mate data");
		run("roi xml to txt");
		roiManager("deselect");
		roiManager("Delete");
	}
	time++;
	selectImage(originId);
	preview();
	Dialog.create("Preview");
	Dialog.addCheckbox("Satisfied ?", false);
	Dialog.show();
	satisfaction = Dialog.getCheckbox();
}
roiManager("deselect");
roiManager("Delete");

// A function to draw the ROIs in the first slice as preview. 
function preview() {
	f = File.openAsString("/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/sorted_roi.txt");
	lines = split(f, "\n");
	setSlice(1);
	// draw all the selected roi in the first slice as a preview. 
	for (sInd = 0; sInd < lines.length; sInd++) {
		temp = lines[sInd];
		slice = split(temp, " ");
		if (slice[1] == 0) {
			x1 = round(slice[2] - ovalRadius * (sqrt(2) / 2));
			xC = ovalRadius * sqrt(2);
			y1 = round(slice[3] - ovalRadius * (sqrt(2) / 2));
			yC = ovalRadius * sqrt(2);
			makeOval(x1, y1, xC, yC);
			roiManager("add");
		}
	}
	roiManager("Show All");
	temp = lines[lines.length - 1];
	roiNums = split(temp, " ");
	print(roiNums[0]);
}

// Draw arrows. 
run("Duplicate...", "title=Stage duplicate");
sliceCount = 0;
if (slices >= frames) {
	sliceCount = slices;
} else {
	sliceCount = frames;	
}

f = File.openAsString("/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/sorted_roi.txt");
lines = split(f, "\n");
numRoi = newArray(lines.length);
slide = newArray(lines.length);
x = newArray(lines.length);
y = newArray(lines.length);

selectWindow("Stage");
min_square_mov = 0;
//firstL = split(lines[0], " ");
for (i = 1; i < lines.length; i++ ) {
	lastL = split(lines[i - 1], " ");
	currL = split(lines[i], " ");
	if (lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) > min_square_mov) {
		setSlice(currL[1] + 1);
		makeArrow(round(lastL[2]), round(lastL[3]), round(lastL[2]) + ovalRadius * (round(currL[2]) - round(lastL[2])), round(lastL[3]) + ovalRadius * (round(currL[3]) - round(lastL[3])), "filled");
//		makeArrow(round(firstL[2]), round(firstL[3]), round(firstL[2]) + a * (round(currL[2]) - round(firstL[2])), round(firstL[3]) + a * (round(currL[3]) - round(firstL[3])), "filled");
		run("Arrow Tool...", "width=1 size=4 color=Green style=Open");	
		Roi.setStrokeColor("green");
		run("Add Selection...");	
	} 
}
	

/*  .1. trackMate will recognize white space as ROIs, need to remove it to save time. 
 *  .2. Need to find a way to automatically find the proper threshold or at least let the user
 *  change the threshold in a preview window. 
 *  .3. call the 3 plugins in the main script.
 *  .4. push codes to github.
 */

