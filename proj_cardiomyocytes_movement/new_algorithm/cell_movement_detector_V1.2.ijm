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

var act_threshold;
// A function to draw the ROIs in the first slice as preview. 
function preview(con_th) {
	f = File.openAsString(folder + "medium_products/sorted_roi.txt");
	lines = split(f, "\n");
	if (lines.length == 0) {
		exit("No ROI detected. Please run again with looser parameters.");	
	}
	filter255(lines);
	setSlice(1);

	// Filtering ROIs
	repC = 0;
	start = 0;
	final = 0;
	const = "0";
	rr = 0.03;
	maxConIncX = 0;
	maxConDecX = 0;
	pre = newArray();
	tempIncX = 0;
	tempDecX = 0;
	maxConIncY = 0;
	maxConDecY = 0;
	tempIncY = 0;
	tempDecY = 0;
	for (l = 0; l < lines.length; l++) {
		line = split(lines[l], " ");
		
		// Filter out border ROIs
		if (isBorder(parseInt(line[2]), parseInt(line[3]), width, height, rr) == true) {
			mark[l] = 1;
		}

		// Filter out ROIs based on present slides number and movement activity.
		if (line[0] == const) {
			repC++;
			final = l;
			if (pre.length != 0) {
				if (parseFloat(line[2]) > parseFloat(pre[2])) {
					tempDecX = 0;
					tempIncX++;
				} else if (parseFloat(line[2]) < parseFloat(pre[2])) {
					tempIncX = 0;
					tempDecX++;	
				}
				if (tempIncX > maxConIncX) {
					maxConIncX = tempIncX;	
				}
				if (tempDecX > maxConDecX) {
					maxConDecX = tempDecX;	
				}
				if (parseFloat(line[3]) > parseFloat(pre[3])) {
					tempDecY = 0;
					tempIncY++;
				} else if (parseFloat(line[3]) < parseFloat(pre[3])) {
					tempIncY = 0;
					tempDecY++;	
				}
				if (tempIncY > maxConIncY) {
					maxConIncY = tempIncY;	
				}
				if (tempDecY > maxConDecY) {
					maxConDecY = tempDecY;	
				}
			}
			pre = line;
		} else {
			// Filter out ROIs based on present slides number.
			if (repC < con_th) {
				for (tt = start; tt <= final; tt++) {
					mark[tt] = 1;	
				}
			}

			// Filter out ROIs based on movement activity.
			if (maxConIncX < act_threshold && maxConIncY < act_threshold && maxConDecX < act_threshold && maxConDecY < act_threshold) {
				for (tt = start; tt <= final; tt++) {
					mark[tt] = 1;	
				}
			}
			pre = "";
			maxConIncX = 0;
			maxConDecX = 0;
			tempIncX = 0;
			tempDecX = 0;
			maxConIncY = 0;
			maxConDecY = 0;
			tempIncY = 0;
			tempDecY = 0;
			repC = 0;
			const = line[0];
			start = l;
			final = l;
		}
	}
	
	
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
 
	roiManager("Show All");
	temp = lines[lines.length - 1];
	roiNums = split(temp, " ");
	spotNum = parseInt(roiNums[0]) - markCount;
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

// Check whether the ROI is on the border. If so, it is highly possible to be an outlier. 
function isBorder(xx, yy, width, height, ratio) {
	if (xx < width * ratio || xx > width * (1 - ratio) || yy < height * ratio || yy > height * (1 - ratio)) {
		return true	
	}
	return false
}

// Return a magnifier for arrow length. 
function dynamic_magnifier(x, base) {
	if (x >= 0) {
		return base * (1 - 0.8 * pow(PI, -1 * x))
	} else {
		return - base * (1 - 0.8 * pow(PI, -1 * abs(x)))	
	}
}

// Can count the unique ROIs from trackmate sorted roi output. 
// 		Set count_mode to true to count.
// Can also be used to find the centers for all unique ROIs. 
// 		Set count_mode to false and which_pattern to -1.
// Can also calculate the change patterns of a certain ROI. 
// 		Set count_mode to false and which_pattern to roi index.
// Note: seems like macro function cannot return long string. So set global variable instead.
var dyna_centers;
var dyna_patterns;
function filteredROICount(sorted_roi_list, mark_list, count_mode, which_pattern) {
	if (sorted_roi_list.length != mark_list.length) {
		exit("The roi list length doesn't equal to mark list length.");
	}
	count = 0;
	for (i = 1; i < sorted_roi_list.length; i++) {
		if (mark_list[i - 1] == 1) {
			continue;	
		} 
		last = split(sorted_roi_list[i - 1], " ");
		curr = split(sorted_roi_list[i], " ");
		if (last[0] != curr[0]) {
			count++;
		}
	}
	if (!count_mode) {
		positions = newArray(count);
		patterns = newArray();
		last = newArray("-1");
		curr = split(sorted_roi_list[0], " ");
		index = -1;
		for (i = 1; i < sorted_roi_list.length; i++) {
			if (mark_list[i - 1] == 1) {
				last = split(sorted_roi_list[i - 1], " ");
				curr = split(sorted_roi_list[i], " ");
				continue;	
			} 
			if (last[0] == curr[0] && which_pattern == index) {
				dx = parseFloat(curr[2]) - parseFloat(last[2]);
				dy = parseFloat(curr[3]) - parseFloat(last[3]);
				frame = parseInt(curr[1]) - parseInt(last[1]);
				patterns = Array.concat(patterns, d2s(frame, 0) + " " + d2s(dx, 5) + " " + d2s(dy, 5));
			}
			if (last[0] != curr[0]) {
				x = curr[2];
				y = curr[3];
				index++;
				for (j = 0; j < positions.length; j++) {
					if (positions[j] == 0) {
						positions[j] = d2s(x, 5) + " " + d2s(y, 5);
						break;
					}
				}
				
			}
			
			last = split(sorted_roi_list[i - 1], " ");
			curr = split(sorted_roi_list[i], " ");
		}
		if (which_pattern == -1) {
			positions = String.join(positions, "\n");
			dyna_centers = positions;
			return positions
		}
		patterns = String.join(patterns, "\n");
		dyna_patterns = patterns;
		return patterns
	} else {
		return count	
	}
	
}

// Generate a Gaussian random position with an ROI given its center and radius. 
function randomPosition(center, radius) {
	rnX = random("Gaussian");
	rnY = random("Gaussian");
	newX = 0;
	newY = 0;
	temp = split(center, " ");
	centerX = parseFloat(temp[0]);
	centerY = parseFloat(temp[1]);
	if (rnX >= 0) {
		newX = centerX + radius * (1 - pow(PI, -1.5 * rnX));
	} else {
		newX = centerX - radius * (1 - pow(PI, 1.5 * rnX));
	}
	if (rnY >= 0) {
		newY = centerY + radius * (1 - pow(PI, -1.5 * rnY));
	} else {
		newY = centerY - radius * (1 - pow(PI, 1.5 * rnY));
	}
	return d2s(newX, 5) + " " + d2s(newY, 5);
}

function getStillROIData(data) {
	ind = 0;
	for (i = 1; i < data.length; i++ ) {
		curr = split(data[i], " ");
		if (parseInt(curr[0]) != ind) {
				
		} else {
				
		}
	}
}


// A preview window to let users decide if the number of ROIs is acceptable. 
var f;
var lines;
var folder;
var animation;
macro "workStage" {
	run("8-bit");
//	setOption("Min & max gray value", true);
	setOption("mean", true);
	setOption("Std", true);
	run("Set Measurements...", "mean standard min centroid redirect=None decimal=3");
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
	refRadius = 30;
	refWidth = 1000;
	refHeight = 700;
	ovalRadius = round(sqrt(pow(refRadius, 2) * ((width * height) / (refWidth * refHeight))));
	originId = getImageID();
	satisfaction = false;
	
	while (satisfaction == false) {
		roiManager("reset");
		Dialog.create("ROI selection input");
		Dialog.addMessage("What is your expected ROI radius?");
		Dialog.addNumber("\t\t\t\t\t\t", ovalRadius, 0, 5, "pixels");
		Dialog.addMessage("What is the minimum duration for a qualified ROI?");
		Dialog.addSlider("\t\t\t\t\t\t", 0, sliceCount, sliceCount * 0.75);
		Dialog.addMessage("What is the minimum continuous moving frames for a qualified ROI?");
		Dialog.addNumber("\t\t\t\t\t\t", 5, 0, 5, "frames");
//		Dialog.addMessage("What is the minimum ROI movement to be considered?");
//		Dialog.addNumber("\t\t\t\t\t\t", 0.1, 2, 5, "pixel");
		Dialog.show();
		ovalRadius = Dialog.getNumber();
		con_th = Dialog.getNumber();
		act_threshold = Dialog.getNumber();
//		min_mov = Dialog.getNumber();
		File.saveString(d2s(ovalRadius, 0), folder + "medium_products/approx_roi_radius.txt");
//		File.saveString(d2s(act_threshold, 0) + "\n" + d2s(min_mov, 2), folder + "medium_products/periodic_parameters.txt");
		
		// Get the ROI track mate data by calling 2 functions. Then smooth the movement data. 
		message = "Detecting ROIs ...";
		Dialog.addMessage(message); 
		selectImage(originId);
		run("get track mate data");
		run("roi xml to txt");
		run("movement smoother");
		
		preview(con_th);
		Dialog.create("Preview");
		Dialog.addCheckbox("Satisfied ?", false);
		Dialog.show();
		satisfaction = Dialog.getCheckbox();
	}

	f = File.openAsString(folder + "medium_products/sorted_roi.txt");
	lines = split(f, "\n");
	count_mode = true;
	which_pattern = -1;
	numRoi = filteredROICount(lines, mark, count_mode, which_pattern);
	
	Dialog.create("Analysis parameters input");
	Dialog.addRadioButtonGroup("\t Do you want to draw arrow animation?", newArray("Yes", "No"), 0, 2, "Yes");
	Dialog.addMessage("Output saving settings");
	Dialog.addCheckbox("\t\t\t\t\t\tSave the result table as excel?", 0);
	Dialog.addCheckbox("\t\t\t\t\t\tSave the arrows animation?", 0);
	Dialog.addMessage(numRoi + " ROIs left after filtering. How many layers do you want to separate the results?");
	Dialog.addSlider("\t\t\t\t\t\t", 0, numRoi, 3);
	Dialog.show();
	animation = Dialog.getRadioButton();
	excelB = Dialog.getCheckbox();
	arrowB = Dialog.getCheckbox();
	ll = Dialog.getNumber();
	quality_threshold = File.openAsString(folder + "medium_products/quality_threshold.txt");

	close("Results");
	roiManager("Deselect");
	roiManager("multi measure");
	Table.save(folder + "medium_products/reference.txt");
//	run("Read and Write Excel", "file=[" + folder + "medium_products/reference.xlsx]");
	heads = Table.headings;
	heads = split(heads, "\t");
	xAxis = Array.getSequence(sliceCount);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	isRe = File.isDirectory(folder + "results/");
	if (isRe == 0) {
		File.makeDirectory(folder + "results/");
		isReFi = File.isDirectory(folder + "results/graphs/");
		if (isReFi == 0) {
			File.makeDirectory(folder + "results/graphs/");	
		}
	} else {
		isReFi = File.isDirectory(folder + "results/graphs/");
		if (isReFi == 0) {
			File.makeDirectory(folder + "results/graphs/");	
		}	
	}
	
	temp = getInfo("image.filename");
	if (temp == "") {
		imageName = "untitled";
	} else {
		wholeName = split(temp, ".");
		imageName = wholeName[0];
	}

	File.makeDirectory(folder + "results/graphs/" + imageName + "_" + year + "_" + month + "_" + dayOfMonth + "_" + hour + "-" + minute + "-" + second + "/");
	str_ovalRadius = d2s(ovalRadius, 0);
	str_con_th = d2s(con_th, 0);
	str_act_threshold = d2s(act_threshold, 0);
	Log = "Image: " + imageName + "\nOval Radius: " + str_ovalRadius + "\nMinimum Duration: " 
	+ str_con_th + "\nMinimum Continuous Moving Frames: " + str_act_threshold + "\nQuality Threshold: " 
	+ quality_threshold + "\nNumber of ROI: " + numRoi;
	File.saveString(Log, folder + "results/graphs/" + imageName + "_" + year + "_" + month + "_" + dayOfMonth + "_" + hour + "-" + minute + "-" + second + "/log.txt");

	xBrands = newArray(0);
	yBrands = newArray(0);
	for (i = 0; i < heads.length; i++) {
		if (startsWith(heads[i], "X")) {
			temp = Table.getColumn(heads[i]);
			temp = temp[0];
			xBrands = Array.concat(xBrands, temp);
		}
		if (startsWith(heads[i], "Y")) {
			temp = Table.getColumn(heads[i]);
			temp = temp[0];
			yBrands = Array.concat(yBrands, temp);
		}
	}

	brands = newArray(xBrands.length);
	for (i = 0; i < xBrands.length; i++) {
		for (j = 0; j < lines.length; j++) {
			line = split(lines[j], " ");
			if (round(parseFloat(line[2])) == xBrands[i] && round(parseFloat(line[3])) == yBrands[i]) {
				brands[i] = line[0];
				break;
			}
		}
	}

	ind = 0;
	for (i = 0; i < heads.length; i++) {
		if (startsWith(heads[i], "StdDev")) {
			temp = Table.getColumn(heads[i]);
			Plot.create("temp", "Frames", "StdDev", xAxis, temp);
			Plot.show();
			selectWindow("temp");
			saveAs("png", folder + "results/graphs/" + imageName + "_" + year + "_" + month + "_" + dayOfMonth + "_" + hour + "-" + minute + "-" + second + "/" + imageName + "_roi" + brands[ind] + ".png");
			close(imageName + "_roi" + brands[ind] + ".png");
			ind++;
		}
	}	

	close("Results");

	selectImage(originId);


	for (i = 1; i < lines.length; i++ ) {
		if (i < sliceCount) {
			setResult("Slice Number", i - 1, i + 1);
		}
		
		lastL = split(lines[i - 1], " ");
		currL = split(lines[i], " ");
		if (mark[i] == 1) {
			continue;	
		}
		if (parseInt(currL[1]) < sliceCount - 1 && i != (lines.length - 1)) {
			nextL = split(lines[i + 1], " ");
		}
		if (parseInt(currL[1]) < sliceCount - 1 && lastL[0] == currL[0]) {
			dir = getDirection(parseFloat(currL[2]), parseFloat(currL[3]), parseFloat(nextL[2]), parseFloat(nextL[3]), parseFloat(lastL[2]), parseFloat(lastL[3]), parseFloat(currL[2]), parseFloat(currL[3]));
			bright = getPixel(lastL[2], lastL[3]);
			
			setResult("pixel_value_" + currL[0], lastL[1], bright);
			setResult("start_x_" + currL[0], lastL[1], lastL[2]);
			setResult("start_y_" + currL[0], lastL[1], lastL[3]);
			setResult("end_x_" + currL[0], lastL[1], currL[2]);
			setResult("end_y_" + currL[0], lastL[1], currL[3]);
			setResult("movement_length_" + currL[0], lastL[1], sqrt(pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2)));
			setResult("direction_change_" + currL[0] + "_degree", lastL[1], dir);
//			setResult("periodic_ID_" + currL[0], lastL[1], currL[4]);
			if (parseInt(currL[1]) - parseInt(lastL[1]) > 1) {
				for (ind = 1; ind < parseInt(currL[1]) - parseInt(lastL[1]); ind++) {
					setResult("pixel_value_" + currL[0], lastL[1] + ind, NaN);
					setResult("start_x_" + currL[0], lastL[1] + ind, NaN);
					setResult("start_y_" + currL[0], lastL[1] + ind, NaN);
					setResult("end_x_" + currL[0], lastL[1] + ind, NaN);
					setResult("end_y_" + currL[0], lastL[1] + ind, NaN);
					setResult("movement_length_" + currL[0], lastL[1] + ind, NaN);
					setResult("direction_change_" + currL[0] + "_degree", lastL[1] + ind, NaN);
//					setResult("periodic_ID_" + currL[0], lastL[1], NaN);
				}	
			}
		}
	}

	heads = Table.headings;
	heads = split(heads, "	");
	selected = newArray(0);
	tt = 0;
	for (i = 0; i < heads.length; i++) {
		sep = split(heads[i], "_");
		if (sep[0] == "pixel") {
//			data = Table.getColumn(heads[i]);
//			data = filterExtreme(data, 0);
//			Array.getStatistics(data, min, max, mean, stdDev);
//			std_data = newArray(data.length);
//			for (j = 0; j < std_data.length; j++) {
//				std_data[j] = (data[j] - mean) / stdDev;
//			}
//			The ROI satisfied the spike_filter will be marked * in the begining.
			selected = Array.concat(selected, sep[2]);
//			if (spike_filter(std_data, spike_num, persis, spike_gap, exact) == true) {
//				selected = Array.concat(selected, sep[2]);
//				Table.renameColumn("pixel_value_" + sep[2], "*pixel_value_" + sep[2]);
//				Table.renameColumn("start_x_" + sep[2], "*start_x_" + sep[2]);
//				Table.renameColumn("start_y_" + sep[2], "*start_y_" + sep[2]);
//				Table.renameColumn("end_x_" + sep[2], "*end_x_" + sep[2]);
//				Table.renameColumn("end_y_" + sep[2], "*end_y_" + sep[2]);
//				Table.renameColumn("movement_length_" + sep[2], "*movement_length_" + sep[2]);
//				Table.renameColumn("direction_change_" + sep[2] + "_degree", "*direction_change_" + sep[2] + "_degree");
//			}
		}
		tt++;
	}

	
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
		if (temp == "") {
			imageName = "untitled";
		} else {
			wholeName = split(temp, ".");
			imageName = wholeName[0];
		}
		
		run("Read and Write Excel", "file=[" + folder + "results/excel_data/" + imageName + "_data.xlsx] sheet=" + year + "_" + month + "_" + dayOfMonth + "_" + hour + "-" + minute + "-" + second);
	}

	ranges = newArray(selected.length);
	IJ.renameResults("output_data");
	for (z = 0; z < selected.length; z++) {
//		data = Table.getColumn("*movement_length_" + selected[z]);
		data = Table.getColumn("movement_length_" + selected[z]);
		Array.getStatistics(data, min, max, mean, stdDev);
		range = max - min;
		ranges[z] = range;
	}
	
	ranges = Array.sort(ranges);
	start = 0;
	cap = floor(ranges.length * (1 / ll));
	k2 = ranges.length % ll;
	k1 = ll - k2;
	mins = newArray(ll);
	maxs = newArray(ll);
	means = newArray(ll);
	stds = newArray(ll);
	nums = newArray(ll);
	for (i = 0; i < ll; i++) {
		if (i <= k1) {
			curr = 	Array.slice(ranges, start, start + cap);
			start = start + cap;
		} else {
			curr = 	Array.slice(ranges, start, start + cap + 1);
			start = start + cap + 1;
		}
		Array.getStatistics(curr, min, max, mean, stdDev);
		mins[i] = min;
		maxs[i] = max;
		means[i] = mean;
		stds[i] = stdDev;
		nums[i] = curr.length;
	}
	
	Table.create("Movement_Layers");
	Table.setColumn("num", nums);
	Table.setColumn("mean", means);
	Table.setColumn("stdDev", stds);
	Table.setColumn("max", maxs);
	Table.setColumn("min", mins);

	if (animation == "Yes") {
		Dialog.create("Arrow Animation Settings");
		Dialog.addNumber("Arrow magnifier ", 30);
		Dialog.addNumber("Minimum movement length:", 0.1);
		Dialog.addNumber("Maximum movement length:", 4);
		Dialog.addNumber("Attachment ROI num:", 6);
		arrow_types = newArray(2);
		arrow_types[0] = "Between frames";
		arrow_types[1] = "Still start";
		Dialog.addRadioButtonGroup("Arrow type", arrow_types, 2, 1, "Between frames");
		Dialog.show();
		
		base = Dialog.getNumber();
		min_square_mov = pow(Dialog.getNumber(), 2);
		max_square_mov = pow(Dialog.getNumber(), 2);
		attach_num = Dialog.getNumber();
		a_t = Dialog.getRadioButton();
		run("Duplicate...", "title=Stage duplicate");
		selectWindow("Stage");

		print(Log);
		// Produce attachments ROIs
		count_mode = false;
		which_pattern = -1;
		_ = filteredROICount(lines, mark, count_mode, which_pattern);
		centers = split(dyna_centers, "\n");
		attachments = newArray();
		roi_ind = 0;
		for (i = 0; i < centers.length; i++) {
			which_pattern = i;
			_ = filteredROICount(lines, mark, count_mode, which_pattern);
			patterns = split(dyna_patterns, "\n");
			for (j = 0; j < attach_num; j++) {
				temp = randomPosition(centers[i], ovalRadius);
				temp = split(temp, " ");
				newX = parseFloat(temp[0]);
				newY = parseFloat(temp[1]);
				frame_ind = 0;
				attachments = Array.concat(attachments, d2s(roi_ind, 0) + " " + d2s(frame_ind, 0) + " " + d2s(newX, 5) + " " + d2s(newY, 5));
				for (p = 0; p < patterns.length; p++) {
					tempP = split(patterns[p], " ");
					pFrame = parseInt(tempP[0]);
					pX = parseFloat(tempP[1]);
					pY = parseFloat(tempP[2]);
					frame_ind = frame_ind + pFrame;
					newX = newX + pX;
					newY = newY + pY;
					attachments = Array.concat(attachments, d2s(roi_ind, 0) + " " + d2s(frame_ind, 0) + " " + d2s(newX, 5) + " " + d2s(newY, 5));
				}
				roi_ind++;
			}
		}
		f = File.open(folder + "medium_products/attachment_ROIs.txt");
		for (l = 0; l < attachments.length; l++) {
			print(f, attachments[l] + "\n");	
		}
		
		if (a_t == "Still start") {
			for (i = 1; i < lines.length; i++ ) {
				if (mark[i] == 1) {
					continue;	
				}
				reference = split(lines[i], " ");
				break;
			}
		}
		
		for (i = 1; i < lines.length; i++ ) {
			if (mark[i] == 1) {
				continue;	
			}
			lastL = split(lines[i - 1], " ");
			currL = split(lines[i], " ");
			
			if (lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) > min_square_mov && lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) < max_square_mov) {
				setSlice(currL[1] + 1);
				if (a_t == "Still start") {
					if (pow(currL[2] - reference[2], 2) + pow(currL[3] - reference[3], 2) > max_square_mov){
						reference = currL;
						continue;	
					}
					makeArrow(round(reference[2]), round(reference[3]), round(parseFloat(reference[2]) + dynamic_magnifier(parseFloat(currL[2]) - parseFloat(reference[2]), base)), round(parseFloat(reference[3]) + dynamic_magnifier(parseFloat(currL[3]) - parseFloat(reference[3]), base)), "filled");
				} else if (a_t == "Between frames") {
					makeArrow(round(lastL[2]), round(lastL[3]), round(parseFloat(lastL[2]) + dynamic_magnifier(parseFloat(currL[2]) - parseFloat(lastL[2]), base)), round(parseFloat(lastL[3]) + dynamic_magnifier(parseFloat(currL[3]) - parseFloat(lastL[3]), base)), "filled");
				}
				run("Arrow Tool...", "width=1 size=4 color=Green style=Open");	
				Roi.setStrokeColor("green");
				run("Add Selection...");	
				close("Exception");
			} else if (lastL[0] != currL[0] && a_t == "Still start") {
				reference = currL;
			}
		}

		// Draw attachments.
		if (a_t == "Still start") {
			for (i = 1; i < attachments.length; i++ ) {
				reference = split(attachments[i], " ");
				break;
			}
		}
		
		for (i = 1; i < attachments.length; i++ ) {
			lastL = split(attachments[i - 1], " ");
			currL = split(attachments[i], " ");
			
			if (lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) > min_square_mov && lastL[0] == currL[0] && pow(currL[2] - lastL[2], 2) + pow(currL[3] - lastL[3], 2) < max_square_mov) {
				setSlice(currL[1] + 1);
				if (a_t == "Still start") {
					if (pow(currL[2] - reference[2], 2) + pow(currL[3] - reference[3], 2) > max_square_mov){
						reference = currL;
						continue;	
					}
					makeArrow(round(reference[2]), round(reference[3]), round(parseFloat(reference[2]) + dynamic_magnifier(parseFloat(currL[2]) - parseFloat(reference[2]), base)), round(parseFloat(reference[3]) + dynamic_magnifier(parseFloat(currL[3]) - parseFloat(reference[3]), base)), "filled");
				} else if (a_t == "Between frames") {
					makeArrow(round(lastL[2]), round(lastL[3]), round(parseFloat(lastL[2]) + dynamic_magnifier(parseFloat(currL[2]) - parseFloat(lastL[2]), base)), round(parseFloat(lastL[3]) + dynamic_magnifier(parseFloat(currL[3]) - parseFloat(lastL[3]), base)), "filled");
				}
				run("Arrow Tool...", "width=1 size=4 color=Green style=Open");	
				Roi.setStrokeColor("green");
				run("Add Selection...");	
				close("Exception");
			} else if (lastL[0] != currL[0] && a_t == "Still start") {
				reference = currL;
			}
		}
	}


	
//	exit("test point");

	
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
	
//	constant = (1 - k1 * k2) / (k1 + k2);
//	bisecK = sqrt(1 + pow(constant, 2)) - constant;

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
	} else if (deltaX < 0) {
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
	
