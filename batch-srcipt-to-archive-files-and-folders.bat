@ECHO off
setlocal enabledelayedexpansion

REM ===================================================
REM
REM Batch-Script to archive files and subfolders from a give sourcefolder
REM the Script don't use WMIC
REM 
REM to archive, specify the folder from which you want to archive [sourceFolder]
REM then specify the filetype (e.g. *.pdf, *.xml,...) [filterFileType] 
REM specify the archive folder you want to archive to [archiveFolder]
REM next specify the depth of archive that will be build - only years, with month or days (year, month,day) [depth]
REM at last give the days that shall be past as a number [numberOfDays]
REM
REM @owner CAI UG, Hansestadt Wipperfürth, GERMANY
REM @author Kai R. Emde
REM @verion 1.0
REM @date 07.02.2024
REM
REM ================================

ECHO --------------------------------------------------------------------------
ECHO SCRIPT for archiving files and subfolders
ECHO --------------------------------------------------------------------------
ECHO\
ECHO Specify the folder from which you want to archive - full path is necessary (E:\..\ArchiveFolder)
ECHO Enter the file type (e.g., *.txt, *.pdf, *.xml)
ECHO Enter the archive folder path
ECHO Enter the depth of the archive to be created. 
ECHO 	possible are: year (only years); month (year/month) and day (year/month/day)
ECHO At last give the days that shall be past as a number (ex. 30)
ECHO\
ECHO\
ECHO ---------------------------------------------------------------------------
ECHO\
ECHO\
REM Prompt the user to enter a text
set /p "choice=Would you like to start archiving? (y/n): "

REM Check user's choice
if /i not "%choice%"=="y" (
	goto :Cancelled
) 

	REM Prompt the user for source folder
	set /p "sourceFolder=Enter the source folder path: "
	if not exist "!sourceFolder!" (
		ECHO Source folder does not exist. Exiting.
		exit /b
	)

	REM Prompt the user for file type
	set /p "filterFileType=Enter the file type (e.g., *.txt, *.pdf, *.xml): "

	REM Prompt the user for archive folder
	set /p "archiveFolder=Enter the archive folder path: "
	if not exist "!archiveFolder!" (
		ECHO Archive folder does not exist. Creating.
		md "!archiveFolder!\" 2>nul
		if not exist "!archiveFolder!" (
			ECHO Archive folder can not be created. Exiting.
			exit /b
			)
	)

	REM Prompt the depth for the archive subfolders
	set /p "depth=Enter archive depth (e.g. year, month, day): "

	REM Prompt the user for the number of days
	set /p "numberOfDays=Enter the number of days: "

	ECHO Today is: %DATE%
	ECHO All Files will be archived that are older than: !numberOfDays!
	set /a "olderThanDays=!numberOfDays!"


	REM Parse the end date
	for /f "tokens=1-3 delims=." %%a in ("%DATE%") do (
		set /a "endDay=10%%a %% 100", "endMonth=10%%b %% 100", "endYear=%%c"
	)

	REM Loop through each file in the source folder
	for %%R in ("!sourceFolder!\!filterFileType!") do (

		ECHO File %%R

		REM catch the fileName
		for %%I IN (%%R) do (
			set fileName=%%~nxI
		)
		
		ECHO archiviere "!fileName!"
		
		REM get th creationDate from the file
		for /f "delims= " %%a in ('dir !sourceFolder!\*.*^|findstr /i /l "!fileName!"') do (
			set "creationDate=%%a"
		)
		
		ECHO creationDate !creationDate!
		
		REM Parse the start date
		for /f "tokens=1-3 delims=." %%a in ("!creationDate!") do (
			set /a "startDay=10%%a %% 100", "startMonth=10%%b %% 100", "startYear=%%c"
		)

		REM Calculate days between two dates
		set /a "totalDays = 365 * (!endYear! - !startYear!) + 30 * (!endMonth! - !startMonth!) + (!endDay! - !startDay!)"

		ECHO Days between !creationDate! and %Date%: !totalDays!

		REM Compare with the given number of days
		if !totalDays! gtr %olderThanDays% (
			ECHO !creationDate! is older than %olderThanDays% days.

			REM Extract the year from the creation date
			set "day=!creationDate:~0,2!"
			REM if !day:2,1! == "." set "day=0!day:1,1! 
			REM ECHO !day!
					
			REM Extract the year from the creation date
			set "month=!creationDate:~3,2!"
			REM ECHO !month!
						
			REM Extract the year from the creation date
			set "year=!creationDate:~6,4!"
			REM ECHO !year!
					
			REM Move the file to the corresponding archive subfolder
			if "%depth%" == "day" (
					md "!archiveFolder!\!year!\!month!\!day!\" 2>nul
					move "%%R" "!archiveFolder!\!year!\!month!\!day!\" >nul
					ECHO Moved "%%R" to "!archiveFolder!\!year!\!month!\!day!\"
				) else if "%depth%" == "month" (
					md "!archiveFolder!\!year!\!month!\" 2>nul
					move "%%R" "!archiveFolder!\!year!\!month!\" >nul
					ECHO Moved "%%R" to "!archiveFolder!\!year!\!month!\"
				) else (
					md "!archiveFolder!\!year!\" 2>nul
					move "%%R" "!archiveFolder!\!year!\" >nul
					ECHO Moved "%%R" to "!archiveFolder!\!year!\"
				)
		
		) else (
			ECHO !creationDate! is not older than %olderThanDays% days.
		)

	)	


	REM Loop through each subfolder in the source folder to catch all the other
	REM move the subfolder and the file in the given archive structure
	for /r "%sourceFolder%" /d %%D in ("*") do (
		
		ECHO folder %%D
		
		for %%S IN ("%%D") do (
			set subFolder=%%~nxS
			)
			
		ECHO subfolder "!subFolder!"

		set toArchiveFolder=%%D
		ECHO toArchiveFolder "!toArchiveFolder!"	


		REM Loop through each file in the source folder
		for %%F in (!toArchiveFolder!\!filterFileType!) do (
			
			ECHO File %%F

			REM catch the all the parameter of the fileName
			for %%I IN ("%%F") do (
				set dirName=%%~dpI
				set "fileName=%%~nI"
				set fileType=%%~xI
				set fileCreationTime=%%~tI
				
			)
			
			ECHO archiviere aus "!dirName!"
			ECHO File: "!fileName!" "!fileType!" "!fileCreationTime!"

			REM Extract the year from the creation date
			set "creationDate=!fileCreationTime:~0,10!"
			
			ECHO creationDate !creationDate!
			
			REM Parse the start date
			for /f "tokens=1-3 delims=." %%a in ("!creationDate!") do (
				set /a "startDay=10%%a %% 100", "startMonth=10%%b %% 100", "startYear=%%c"
			)

			REM Calculate days between two dates
			set /a "totalDays = 365 * (!endYear! - !startYear!) + 30 * (!endMonth! - !startMonth!) + (!endDay! - !startDay!)"

			ECHO Days between !creationDate! and %Date%: !totalDays!

			REM Compare with the given number of days
			if !totalDays! gtr %olderThanDays% (
				ECHO !creationDate! is older than %olderThanDays% days.

				REM Extract the year from the creation date
				set "day=!creationDate:~0,2!"
				REM if !day:2,1! == "." set "day=0!day:1,1! 
				REM ECHO !day!
						
				REM Extract the year from the creation date
				set "month=!creationDate:~3,2!"
				REM ECHO !month!
							
				REM Extract the year from the creation date
				set "year=!creationDate:~6,4!"
				REM ECHO !year!
						
				REM Move the file to the corresponding archive subfolder
				if "%depth%" == "day" (
						md "!archiveFolder!\!year!\!month!\!day!\!subFolder!\" 2>nul
						move "%%F" "!archiveFolder!\!year!\!month!\!day!\!subFolder!\" >nul
						ECHO Moved "%%F" to "!archiveFolder!\!year!\!month!\!day!\!subFolder!\"
					) else if "%depth%" == "month" (
						md "!archiveFolder!\!year!\!month!\!subFolder!\" 2>nul
						move "%%F" "!archiveFolder!\!year!\!month!\!subFolder!\" >nul
						ECHO Moved "%%F" to "!archiveFolder!\!year!\!month!\!subFolder!\"
					) else (
						md "!archiveFolder!\!year!\!subFolder!\" 2>nul
						move "%%F" "!archiveFolder!\!year!\!subFolder!\" >nul
						ECHO Moved "%%F" to "!archiveFolder!\!year!\!subFolder!\"
					)
			
			) else (
				ECHO !creationDate! is not older than %olderThanDays% days.
			)
		
		REM end of the files iteration
		)	

		REM Remove the subfolder to clear the sourceFolder
		rd !toArchiveFolder!

	REM end of the subFolder iteration
	)
	ECHO File archiving completed.
	pause


:Cancelled
 	ECHO archiving was cancelled
 	pause



