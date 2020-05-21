

//close("Results");
//roiManager("Deselect");
//roiManager("Measure");
//
//count = nResults;
//std = Table.getColumn("StdDev");
//Array.getStatistics(std, min, max, mean, stdDev);
//limit = mean;
//j = 0;
//for (i = 0; i < count; i++) {
//	if (Table.get("StdDev", i) <= limit) {
//		roiManager("select", j);
//		roiManager("delete");
//		j = j - 1;
//	}
//	j = j + 1;
//}


// Input the oval position data and draw ovals separately and save them to Image_Result
//f = File.openAsString("/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/temp.txt");
//lines = split(f, "\n");
//fdf = 0
//for (i = 0; i < lines.length; i++) {
//	line = split(lines[i], ", ");
//	run("Duplicate...", "title=Stage duplicate");
//	selectWindow("Stage");
//	makeOval(line[0], line[1], 18, 18);
//	run("Add Selection...");
//	saveAs("png", "/Users/zhangyujie/Desktop/NanoBio_main_folder/NanoTools_Bioscience/proj_cardiomyocytes_movement/new_algorithm/Image_Result/ROI_" + line[2]);
//	close();
//}



//getResult("pixel_value_11", row)


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
//for (i = 0; i < low.length; i++) {
//	print(ranges[i]);	
//}
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
