function stackMask(minGray, minSize, maxSize) {

	fileName = getInfo("image.filename");
	run("Duplicate...", "title=CopyOfOriginal duplicate");
	stageFileName = getTitle();
	setAutoThreshold("Default dark");
	setThreshold(minGray, 255);
	//run("Create Mask");
	//run("Duplicate...", " ");
	//run("Analyze Particles...", "size=" + minSize + "-" + maxSize + " exclude add");
	//selectWindow(fileName);
	//roiManager("Show All");
	//roiManager("Multi Measure");
	//getResult( "Mean1", 9 );
	//a = Table.getColumn("Mean1");
	//for (i = 0; i < a.length; i++) {
	//	print(a[i]);
	//	}
	getDimensions(w, h, channels, slices, frames);
	
	newImage("Copy_Mask", "8-bit white", w, h, slices);
	maskFileName = getTitle();
	
	for (i = 100; i < 102; i++) {
		selectWindow(stageFileName);
		run("Next Slice [>]");
		run("Create Mask");
		run("Analyze Particles...", "size=" + minSize + "-" + maxSize + " exclude add");
		selectWindow(maskFileName);
		roiManager("Fill");
		close("mask");
		close("Roi Manager");
		run("Next Slice [>]");
		}
	}

macro "Mask_Stacks" {
	Dialog.create("Set Parameters");
	minGray = 190;
	minSize = 50;
	maxSize = 100;
	Dialog.addNumber("Minimum Grayscale Value:", minGray);
	Dialog.addNumber("Minimum Size:", minSize);
	Dialog.addNumber("Maximum Size:", maxSize);
	minGray = Dialog.getNumber();
	minSize = Dialog.getNumber();
	maxSize = Dialog.getNumber();
	setBatchMode(false);
	stackMask(minGray, minSize, maxSize);
	}
	
macro "Locate_ROI" {
	fileName = getInfo("image.filename");
	run("Duplicate...", "title=CopyOfOriginal duplicate");
	stageFileName = getTitle();
	setAutoThreshold("Default dark");
	setThreshold(minValue, 255);
	run("Analyze Particles...", "size=" + minSize + "-" + maxSize + " exclude add");
	}
//run("Read and Write Excel","file=[/Users/zhangyujie/desktop/testSpotFinder.xlsx] dataset_label=" + fileName);
