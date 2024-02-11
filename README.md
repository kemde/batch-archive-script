# batch-archive-script
Batch-Script to archive files and subfolders from a given sourcefolder without using WMIC

The following variables can be set:  
**[sourceFolder]** to archive, specify the folder from which you want to archive  
**[filterFileType]**  then specify the filetype (e.g. *.pdf, *.xml,...)  
**[archiveFolder]** specify the archive folder you want to archive to  
**[depth]** next specify the depth of archive that will be build - only years, with month or days (year, month,day)  
**[numberOfDays]** at last give the days that shall be past as a number  

The script starts with moving all files with given FilterFileType in the archive folder. The it iterates the given sourcefolder and moves the subfolder in the archive folder.  
The check for the set period is based on the storage date of the respective file. The date of the subfolder is not decisive.  
However, the subfolder is created in the archive structure.
