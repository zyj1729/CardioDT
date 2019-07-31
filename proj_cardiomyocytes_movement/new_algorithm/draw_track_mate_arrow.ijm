OriginId = getImageID();
run("Duplicate...", "title=Stage duplicate");
getDimensions(width, height, channels, slices, frames);
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

a = 4;
selectWindow("Stage");
min_square_mov = 0;
for (i = 1; i < lines.length; i++ ) {
//	if (i < sliceCount) {
//		setResult("Slice Number", i - 1, i + 1);
//	}
	lastL = split(lines[i - 1], " ");
	currL = split(lines[i], " ");
	if (parseInt(currL[1]) < sliceCount - 1) {
		nextL = split(lines[i + 1], " ");
	}
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

/*  .1. trackMate will recognize white space as ROIs, need to remove it to save time. 
 *  .2. Need to find a way to automatically find the proper threshold or at least let the user
 *  change the threshold in a preview window. 
 *  .3. call the 3 plugins in the main script.
 *  .4. push codes to github.
 */

