OriginId = getImageID();
run("Duplicate...", "title=Stage duplicate");
getDimensions(width, height, channels, slices, frames);
sliceCount = 0;
if (slices >= frames) {
	sliceCount = slices;
} else {
	sliceCount = frames;	
}

f = File.openAsString("/Users/zhangyujie/Desktop/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/sorted_roi.txt");
lines = split(f, "\n");
numRoi = newArray(lines.length);
slide = newArray(lines.length);
x = newArray(lines.length);
y = newArray(lines.length);

a = 4;
selectWindow("Stage");
min_square_mov = 0;
//firstL = split(lines[0], " ");
for (i = 1; i < lines.length; i++ ) {
	lastL = split(lines[i - 1], " ");
	currL = split(lines[i], " ");
	if (lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) > min_square_mov) {
		setSlice(currL[1] + 1);
		makeArrow(round(lastL[2]), round(lastL[3]), round(lastL[2]) + a * (round(currL[2]) - round(lastL[2])), round(lastL[3]) + a * (round(currL[3]) - round(lastL[3])), "filled");
//		makeArrow(round(firstL[2]), round(firstL[3]), round(firstL[2]) + a * (round(currL[2]) - round(firstL[2])), round(firstL[3]) + a * (round(currL[3]) - round(firstL[3])), "filled");
		run("Arrow Tool...", "width=1 size=4 color=Green style=Open");	
		Roi.setStrokeColor("green");
		run("Add Selection...");	
	} 
	
//	else {
//		firstL = split(lines[i], " ");
//	}
}
	

/*  .1. trackMate will recognize white space as ROIs, need to remove it to save time. 
 *  .2. Need to find a way to automatically find the proper threshold or at least let the user
 *  change the threshold in a preview window. 
 *  .3. call the 3 plugins in the main script.
 *  .4. push codes to github.
 */

