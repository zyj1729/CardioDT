currentFolder = getDirectory("startup");
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
	f = File.openAsString(folder + "medium_products/sorted_roi.txt");
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
	
	roiManager("Deselect");
	roiManager("Measure");
	count = nResults;
	std = Table.getColumn("StdDev");
	Array.getStatistics(std, min, max, mean, stdDev);
	limit = mean / 2;
	j = 0;
	del_x = newArray(0);
	del_y = newArray(0);
	for (i = 0; i < count; i++) {
		if (Table.get("StdDev", i) <= limit) {
			del_x = Array.concat(del_x, Table.get("X", i));
			del_y = Array.concat(del_y, Table.get("Y", i));
			roiManager("select", j);
			roiManager("delete");
			j = j - 1;
		}
		j = j + 1;
	}
	close("Results");
	to_del = -1;
	for (l = 0; l < lines.length; l++) {
		line = split(lines[l], " ");
		if (line[0] == to_del) {
			mark[l] = 1;
			continue;	
		}
		for (k = 0; k < del_x.length; k++) {
			if (parseInt(line[2]) == del_x[k] && parseInt(line[3]) == del_y[k]) {
//				print(parseInt(line[2]), del_x[k]);
				mark[l] = 1;
				markCount++;
				to_del = line[0];
				break;
			}
		}
	}
	
 
	roiManager("Show All");
	temp = lines[lines.length - 1];
	roiNums = split(temp, " ");
	spotNum = parseInt(roiNums[0]) - markCount;
}

// Filter out the pixel data that has certain spike_num.
// spike_num: the expected number of spikes.
// persistance: How long does the standardized spike has to continuously exceed 1 to be considered as a spike. 
// shortest_gap: The shortest distance between adjacent spikes.
// exact: boolean value. If true observed spike num == spike_num. If false, observed spike num >= spike_num.
function spike_filter(data, spike_num, persistance, shortest_gap, exact) {
	count = 0;
    temp_c = 0;
    escape = false;
    start = -1;
//    for i in range(len(data)):
	for (i = 0; i < data.length; i++){
//		print(escape);
        if (data[i] > 1 && !escape){
            temp_c++;
        } else {
            temp_c = 0;
        }
        if (start != -1 && (i - start) >= shortest_gap) {
            escape = false;
            start = -1;
        }
        if (temp_c >= persistance && !escape) {
            count++;
            escape = true;
            temp_c = 0;
        }
        if (escape && start == -1 && data[i] < 1){
            start = i;
        }
	}
    if (exact == true) {
	    if (spike_num == count){
	        return true;
	    }
    } else {
        if (spike_num <= count){
            return true;
        }
    }
    return false;
}


// Filter out v value in the list l.
function filterExtreme(l, v) {
	result = newArray(0);
	for (i = 0; i < l.length; i++) {
		if (l[i] != v) {
			result = Array.concat(result, l[i]);
		}	
	}	
	return result;
}

// A preview window to let users decide if the number of ROIs is acceptable. 
var f;
var lines;
var folder;
var animation;
macro "workStage" {
	folder = getDirectory("Choose a Directory");
	File.saveString(folder, currentFolder + "Working_Directory.txt");
	isMp = File.isDirectory(folder + "medium_products/");
	
	if (isMp == 0) {
		File.makeDirectory(folder + "medium_products/");	
	}

	roiManager("reset");
	// Calculate oval redius. 
	getDimensions(width, height, channels, slices, frames);
	sliceCount = 0;
	if (slices >= frames) {
		sliceCount = slices;
	} else {
		sliceCount = frames;	
	}
	var ovalRadius = 0;
	refRadius = 10;
	refWidth = 1000;
	refHeight = 700;
	ovalRadius = round(sqrt(pow(refRadius, 2) * ((width * height) / (refWidth * refHeight))));
	File.saveString(d2s(ovalRadius, 0), folder + "medium_products/approx_roi_radius.txt");
	
	// Get the ROI track mate data by calling 2 functions. 
	originId = getImageID();
	run("get track mate data");
	run("roi xml to txt");
	f = File.openAsString(folder + "medium_products/sorted_roi.txt");
	lines = split(f, "\n");

	
	satisfaction = false;
	time = 0;
	Dialog.create("ROI Duration Setting");
	Dialog.addSlider("Minimum Duration (slices): ", 0, sliceCount, sliceCount * 0.75);
	Dialog.show();
	con_th = Dialog.getNumber();
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
		Dialog.addCheckbox("Draw Arrows ?", false);
		Dialog.show();
		satisfaction = Dialog.getCheckbox();
		animation = Dialog.getCheckbox();
	}
	
	repC = 0;
	start = 0;
	final = 0;
	const = "0";
	for (l = 0; l < lines.length; l++) {
		line = split(lines[l], " ");
		if (line[0] == const) {
			repC++;
			final = l;
		} else {
			if (repC < con_th) {
				for (tt = start; tt <= final; tt++) {
					mark[tt] = 1;	
				}
			}
			repC = 0;
			const = line[0];
			start = l;
			final = l;
		}
	}
	// Draw arrows. 
	run("Duplicate...", "title=Stage duplicate");

	numRoi = newArray(lines.length);
	slide = newArray(lines.length);
	x = newArray(lines.length);
	y = newArray(lines.length);

	if (animation == true) {
		a = 4;
		selectWindow("Stage");
		min_square_mov = 0;
		for (i = 1; i < lines.length; i++ ) {
			if (mark[i] == 1) {
				continue;	
			}
			lastL = split(lines[i - 1], " ");
			currL = split(lines[i], " ");
			if (lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) > min_square_mov) {
				setSlice(currL[1] + 1);
				makeArrow(round(lastL[2]), round(lastL[3]), round(lastL[2]) + a * (round(currL[2]) - round(lastL[2])), round(lastL[3]) + a * (round(currL[3]) - round(lastL[3])), "filled");
				run("Arrow Tool...", "width=1 size=4 color=Green style=Open");	
				Roi.setStrokeColor("green");
				run("Add Selection...");	
			} 
			
		}
	}

	close("Results");
	roiManager("Deselect");
	roiManager("Measure");
	
	
	for (i = 1; i < lines.length; i++ ) {
		if (i < sliceCount) {
			setResult("Slice Number", i - 1, i + 1);
		}
		if (mark[i] == 1) {
			continue;	
		}
		lastL = split(lines[i - 1], " ");
		currL = split(lines[i], " ");
		if (parseInt(currL[1]) < sliceCount - 1 && i != (lines.length - 1)) {
			nextL = split(lines[i + 1], " ");
		}
		if (parseInt(currL[1]) < sliceCount - 1 && lastL[0] == currL[0]) {
			dir = getDirection(parseFloat(currL[2]), parseFloat(currL[3]), parseFloat(nextL[2]), parseFloat(nextL[3]), parseFloat(lastL[2]), parseFloat(lastL[3]), parseFloat(currL[2]), parseFloat(currL[3]));
			bright = getPixel(lastL[2], lastL[3]);
			setResult("pixel_value_" + currL[0], lastL[1], bright);
			setResult("Start X_" + currL[0], lastL[1], lastL[2]);
			setResult("Start Y_" + currL[0], lastL[1], lastL[3]);
			setResult("End X_" + currL[0], lastL[1], currL[2]);
			setResult("End Y_" + currL[0], lastL[1], currL[3]);
			setResult("Movement Length_" + currL[0], lastL[1], sqrt(pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2)));
			setResult("Direction Change_" + currL[0] + " (degree)", lastL[1], dir);
		}
	}

	Dialog.create("Want to save the results?");
	Dialog.addCheckbox("Save the result table as excel?", 0);
	Dialog.addCheckbox("Save the arrows animation?", 0);
	Dialog.show();
	excelB = Dialog.getCheckbox();
	arrowB = Dialog.getCheckbox();
	if (excelB == 1) {
		isRe = File.isDirectory(folder + "results/");
		if (isRe == 0) {
			File.makeDirectory(folder + "results/");
			isReEx = File.isDirectory(folder + "results/excel_data/");
			if (isReEx == 0) {
				File.makeDirectory(folder + "results/excel_data/");
			}
		} else {
			isReEx = File.isDirectory(folder + "results/excel_data/");
			if (isReEx == 0) {
				File.makeDirectory(folder + "results/excel_data/");
			}
		}
		selectImage(originId);
		temp = getInfo("image.filename");
		wholeName = split(temp, ".");
		imageName = wholeName[0];
		run("Read and Write Excel", "file=[" + folder + "results/excel_data/" + imageName + "_data.xlsx]");
	}
	if (arrowB == 1) {
		isRe = File.isDirectory(folder + "results/");
		if (isRe == 0) {
			File.makeDirectory(folder + "results/");
			isReAr = File.isDirectory(folder + "results/arrows_animations/");
			if (isReAr == 0) {
				File.makeDirectory(folder + "results/arrows_animations/");	
			}
		} else {
			isReAr = File.isDirectory(folder + "results/arrows_animations/");
			if (isReAr == 0) {
				File.makeDirectory(folder + "results/arrows_animations/");	
			}	
		}
		selectImage(originId);
		temp = getInfo("image.filename");
		wholeName = split(temp, ".");
		imageName = wholeName[0];
		selectWindow("Stage");
		saveAs("Tiff", folder + "results/arrows_animations/" + imageName + "_stage");
	}
	
	heads = Table.headings;
	heads = split(heads, "	");
	selected = newArray(0);
	tt = 0;
	for (i = 0; i < heads.length; i++) {
		sep = split(heads[i], "_");
		if (sep[0] == "pixel") {
			data = Table.getColumn(heads[i]);
			data = filterExtreme(data, 0);
			Array.getStatistics(data, min, max, mean, stdDev);
			std_data = newArray(data.length);
			for (j = 0; j < std_data.length; j++) {
				std_data[j] = (data[j] - mean) / stdDev;
			}
			if (spike_filter(std_data, 2, 8, 20, false) == true) {
				selected = Array.concat(selected, sep[2]);
			}
		}
		tt++;
	}
	ranges = newArray(selected.length);
	for (z = 0; z < selected.length; z++) {
		data = Table.getColumn("Movement Length_" + selected[z]);
		Array.getStatistics(data, min, max, mean, stdDev);
		range = max - min;
		ranges[z] = range;
	}
	
	ranges = Array.sort(ranges);
	low_ind = floor(ranges.length * 0.3);
	mid_ind = low_ind + floor(ranges.length * 0.4);
	low = Array.slice(ranges, 0, low_ind);
	mid = Array.slice(ranges, low_ind, mid_ind);
	top = Array.slice(ranges, mid_ind, ranges.length);
	IJ.renameResults("output_data");
	
	Array.getStatistics(low, min_low, max_low, mean_low, stdDev_low);
	Array.getStatistics(mid, min_mid, max_mid, mean_mid, stdDev_mid);
	Array.getStatistics(top, min_top, max_top, mean_top, stdDev_top);
	mins = newArray(min_low, min_mid, min_top);
	maxs = newArray(max_low, max_mid, max_top);
	means = newArray(mean_low, mean_mid, mean_top);
	stds = newArray(stdDev_low, stdDev_mid, stdDev_top);
	
	Table.create("Movement_Layers");
	Table.setColumn("mean", means);
	Table.setColumn("stdDev", stds);
	Table.setColumn("max", maxs);
	Table.setColumn("min", mins);
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
	
