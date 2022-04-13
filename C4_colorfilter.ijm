// Macro for filtering the brightness / contrast in four channels 
// this macro will take a folder filled with .tif files that have already had max z-projection and do the following:
// a) allow the user to set the channel name, color, brightness/contrast min and max for up to three channels 
// b) apply these settings to all images in the chosen directory 
// c) save a merged images in a new folder of "Filtered_TIFs" 

// Start of Settings // -------------------------------------------------------------------------------
//set the name, color, min, max for all channels 
// Channel 1 
C1name = "Neun";
C1color = "Yellow Hot";
C1min = 7000;
C1max = 30000;

// Channel 2 
C2name = "GFAP";
C2color = "Cyan";
C2min = 200;
C2max = 20100;

// Channel 3
C3name = "DAPI";
C3color = "Blue";
C3min = 0;
C3max = 48000;

// Channel 4 
C4name = "AT8";
C4color = "Magenta";
C4min = 6000;
C4max = 60000;

// End of Settings //	----------------------------------------------------------------------------------------				

// Bring up the directory and set up folders for filtered images and results
path = getDirectory("Choose a Directory"); 
filename = getFileList(path); 
filteredDir = path + "Filtered_TIFs" + File.separator; 

File.makeDirectory(filteredDir); 

// Part I Filtering // ----------------------------------------------------------------------------------------
for (i=0; i<filename.length; i++) { 
        if(endsWith(filename[i], ".tif")) { 
                open(path+filename[i]); 
                run("Channels Tool...");
                Stack.setDisplayMode("color");
                run("Brightness/Contrast...");
                
                Stack.setChannel(1);
                setMinAndMax(C1min, C1max); 
                run(C1color); 
                 
                Stack.setChannel(2);
                setMinAndMax(C2min, C2max);
                run(C2color); 
                
                Stack.setChannel(3);
                setMinAndMax(C3min, C3max); 
                run(C3color); 

                Stack.setChannel(4);
                setMinAndMax(C4min, C4max);  
                run(C4color); 

                Stack.setDisplayMode("composite");
                rename(filename[i]);
                saveAs("tiff", filteredDir + getTitle);
      }    			
}
                close("*");	
                