// -------------------------------------------------------------------
// Macro for converting lif files to tif files 
// Options to batch files, merge files, save merge as RGB, or z-projection at maximum or average
// Adapted from macro by Patrice Mascalchi 
// https://github.com/pmascalchi/ImageJ_Export-LIF-as-Individual-Images/blob/master/Export-as-individual-images_1.6.ijm
// -------------------------------------------------------------------

run("Bio-Formats Macro Extensions");

// Dialog window for parameters choice ----------------
yesno = newArray("no", "yes");
Dialog.create("Settings for all files");
Dialog.addChoice("Batch process (multiple files in same folder)", yesno);
Dialog.addMessage("");
Dialog.addChoice("For multi-channel images, save merge as RGB? ", yesno);
Dialog.addChoice("For z-stack images, save maximum projection? ", yesno);
Dialog.addChoice("For z-stack images, save average projection? ", yesno);
Dialog.show();

batch = Dialog.getChoice;
merge = Dialog.getChoice;
maxproj = Dialog.getChoice;
avgproj = Dialog.getChoice;
// End of Dialog --------------------------------------

inputType = ".lif";

if (batch=="yes") {
	Mypath = getDirectory("Choose the directory containing files to convert");
	Mylist = SortFileList(Mypath, inputType);
} else {
	Mylist = newArray(1);
	tmppa = File.openDialog("Select file to convert");
	if (endsWith(tmppa, inputType)==0) exit("error while selecting "+inputType+" file..."); 
	Mylist[0] = File.getName(tmppa);
	Mypath = File.getParent(tmppa);
	if (!endsWith(Mypath, File.separator)) Mypath = Mypath + File.separator;
	print(Mypath);
}
setBatchMode(true);

count = 0;

for (i=0; i<Mylist.length; i++) {
	// Setting output folder
	outdir = Mypath + replace(Mylist[i], ".lif", "_TIF") + File.separator;		// TODO
	if (!File.exists(outdir)) {
		File.makeDirectory(outdir);
	}
	if (!File.exists(outdir)) exit("Cannot create export folder\n" + outdir);
	
	showProgress(i/(Mylist.length-1));
	
	Ext.setGroupFiles("false");
	Ext.setId(Mypath + Mylist[i]);
	Ext.getSeriesCount(count);
	tmpName = "";
	tmpSizeX = 0;
	tmpI = 0;
	pyramidal = false;

	for (f=1;f<count+1;f++) {
		Ext.setSeries(f-1);
		Ext.getSeriesName(sname);
		proceed = 1;
		if (indexOf(sname, "TileScan_") > -1) proceed = 0;
		if (indexOf(sname, "TileScan_") > -1 && indexOf(sname, "Merging") > -1) proceed = 1;
		
		// pyramidal detection
		tmpInd = indexOf(sname, "#");
		snamePart = sname;
		if (tmpInd > -1) snamePart = substring(sname, 0, tmpInd-1);
		
		// pixel size detection for pyramidal comparison
		Ext.getSizeX(sizeX);

		print("*"+ snamePart +"* // *"+ tmpName +"*,   sizeX="+ sizeX +" // "+tmpSizeX);
		if (snamePart == tmpName) {
			if (sizeX < tmpSizeX) {
				proceed = 0;
			} else {
				tmpI++;
				pyramidal = true;
			}
		}
		tmpSizeX = sizeX;
		tmpName = snamePart;
		
		if (proceed==1) {
			print("Processing: "+sname);
			run("Bio-Formats Importer", "open=[" + Mypath + Mylist[i] +"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT series_" + f);
			getDimensions(wi, he, ch, sl, fr);
			if (maxproj=="yes" && sl>1) run("Z Project...", "projection=[Max Intensity]");
			if (avgproj=="yes" && sl>1) run("Z Project...", "projection=[Average Intensity]");
			if (merge=="yes" && ch>1) run("Stack to RGB");
			
			// Rename images 
			t = getTitle();
			if (lengthOf(t) > lengthOf(Mylist[i])) t = replace(t, Mylist[i], "");
			t = substring(t, 3, lengthOf(t));
			t = replace(t,"/","_");
			if (startsWith(t, "_")) t = substring(t, 1);
			t = replace(t," - ","");
			t = replace(t, " #", "series");
			if (pyramidal) t = t + "_" + tmpI;
			
			// Only for multipositions filtering
			if (indexOf(t, "Pos0") > -1) t = replace(t, "Mark_and_Find_", "");
			saveAs("Tiff", outdir + t + ".tif");
			
			run("Close All");
		}
	}
	Ext.close();
}
setBatchMode(false);
print("done!");

// ************************ FUNCTIONS *************************************************
function SortFileList(path, filter) {		// Sort with endsWith
	flist = getFileList(path);
	OutAr = newArray(flist.length);
	ind = 0;
	for (f=0; f<flist.length; f++) {
		//print(flist[f] + " : "+endsWith(flist[f], filter));
		if (endsWith(flist[f], filter)) {
			OutAr[ind] = flist[f];
			ind++;
		}
	}
	return Array.trim(OutAr, ind);
}

