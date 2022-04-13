// Macro for segmenting four channels 
// a) apply thresholding values to .tif files 
// b) option to calculate the % area and / or cell counts in each channel
// c) create a "Results" folder with the output in a .csv file 

// Helper shorthand variables for the available types of analysis.
var PercentArea = "percentArea" 
var CellCount = "cellCount" //for cell count or particle count with manual threshold
var StarCount = "starCount" // for cell count with StarDist plugin - good for circular shaped nuclei and plaques

// Start of Settings // -------------------------------------------------------------------------------
//set the name, color, min, max and thresholds here for all the channels 
// Channel 1 
C1name = "Neun";
C1color = "Yellow Hot";
// threshold values 
c1Tmin = 2000;
c1Tmax = 65535;
// Choose the analysis you want to do for this channel (PercentArea, CellCount, StarCount, or leave blank)
c1Analysis = newArray(CellCount, PercentArea);

// Channel 2 
C2name = "GFAP";
C2color = "Cyan";
c2Tmin = 5000;
c2Tmax = 65535;
c2Analysis = newArray(PercentArea, CellCount);

// Channel 3
C3name = "DAPI";
C3color = "Blue";
c3Tmin = 3000;
c3Tmax = 65535;
c3Analysis = newArray() 

// Channel 4 
C4name = "AT8";
C4color = "Magenta";
c4Tmin = 12000;
c4Tmax = 65535;
c4Analysis = newArray(PercentArea) 

//Edit analyze particles parameters below for cellCount function 
analyzeParticleParametersC = "size=40-Infinity circularity=0.0-1.00 show=Outlines display exclude include summarize add"

//Edit analyze particles parameters below for starCount function 
analyzeParticleParametersS = "size=0-Infinity circularity=0.0-1.00 show=Outlines display exclude include summarize add"

// End of Settings //	----------------------------------------------------------------------------------------				

// Bring up the directory and set up folders for filtered images and results
path = getDirectory("Choose a Directory"); 
filename = getFileList(path); 
resultsDir = path + "Results" + File.separator; 

File.makeDirectory(resultsDir); 

 // Segmenting // ----------------------------------------------------------------------------------------

// Function for calculating %area
function percentArea(channelID, channelName, channelMin, channelMax) { 
	for (i=0; i<filename.length; i++) { 
	        if(endsWith(filename[i], ".tif")) { 
	                open(path+filename[i]); 
					run("Split Channels");
					selectWindow(channelID + "-" +filename[i]);
	                setThreshold(channelMin, channelMax);  
					run("Convert to Mask");
					run("Set Measurements...", "area area_fraction limit display redirect=None decimal=2");
					run("Measure");
	        }    
		}				
		close("*");		 
		selectWindow("Results");
		saveAs("Results", resultsDir + channelName + "_area" + ".csv");
		selectWindow("Results");
		run("Close");
}

// Function for calculating cell counts with manual threshold
function cellCount(channelID, channelName, channelMin, channelMax) { 
	for (i=0; i<filename.length; i++) { 
	        if(endsWith(filename[i], ".tif")) { 
	                open(path+filename[i]); 
	                run("Split Channels"); 
					selectWindow(channelID + "-" +filename[i]);
	                setThreshold(channelMin, channelMax);  
					run("Convert to Mask");
					run("Analyze Particles...", analyzeParticleParametersC);
	        }    
		}				
		close("*");		 
		selectWindow("Summary");
		saveAs("Results", resultsDir + channelName + "_counts" + ".csv");
		selectWindow("Results");
		run("Close");
}

// Function for StarDist counts with machine-learning thresholding of round objects
function starCount(channelID, channelName) { 
	for (i=0; i<filename.length; i++) { 
	        if(endsWith(filename[i], ".tif")) { 
	                open(path+filename[i]); 
	                run("Split Channels"); 
					selectWindow(channelID + "-" +filename[i]);
					starDistArgs = "['input':'" + channelID + "-" +filename[i] + "','modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'100.0', 'probThresh':'0.6', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false']";
					print(starDistArgs);
					run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D],args="+starDistArgs+", process=[false]");
					selectWindow("Label Image");
					setOption("BlackBackground", false);
					run("Convert to Mask");
					run("Analyze Particles...", analyzeParticleParametersS);
					selectWindow("ROI Manager");
					run("Close");
					selectWindow("Label Image");
					run("Close");
	        }    
		}				
		close("*");		 
		selectWindow("Summary");
		saveAs("Results", resultsDir + channelName + "_starCounts" + ".csv");
		selectWindow("Results");
		run("Close");
}

for (i = 0; i < c1Analysis.length; i++) {
	if (c1Analysis[i] == PercentArea) {
		percentArea("C1", C1name, c1Tmin, c1Tmax);
	} else if (c1Analysis[i] == CellCount) { 
		cellCount("C1", C1name, c1Tmin, c1Tmax);
	} else if (c1Analysis[i] == StarCount) { 
		starCount("C1", C1name);
	}
}

for (i = 0; i < c2Analysis.length; i++) {
	if (c2Analysis[i] == PercentArea) {
		percentArea("C2", C2name, c2Tmin, c2Tmax);
	} else if (c2Analysis[i] == CellCount) { 
		cellCount("C2", C2name, c2Tmin, c2Tmax);
	} else if (c2Analysis[i] == StarCount) { 
		starCount("C2", C2name);
	}
}

for (i = 0; i < c3Analysis.length; i++) {
	if (c3Analysis[i] == PercentArea) {
		percentArea("C3", C3name, c3Tmin, c3Tmax);
	} else if (c3Analysis[i] == CellCount) { 
		cellCount("C3", C3name, c3Tmin, c3Tmax);
	} else if (c3Analysis[i] == StarCount) { 
		starCount("C3", C3name);
	}
}


for (i = 0; i < c4Analysis.length; i++) {
	if (c4Analysis[i] == PercentArea) {
		percentArea("C4", C4name, c4Tmin, c4Tmax);
	} else if (c4Analysis[i] == CellCount) { 
		cellCount("C4", C4name, c4Tmin, c4Tmax);
	} else if (c4Analysis[i] == StarCount) { 
		starCount("C4", C4name);
	}
}
close("*");