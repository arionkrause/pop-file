#persistent
#noEnv
#singleInstance force
#noTrayIcon
setWorkingDir %A_ScriptDir%

menu tray, tip, Pop File
iniRead origin, Pop File.ini, app, origin
iniRead destination, Pop File.ini, app, destination

validatePath(origin)
validatePath(destination)

files := getFiles(origin)
destinationOnly := false

if (files == "") {
	destinationOnly := true
	files := getFiles(destination)
}

amount := getFilesAmount(files)

; Construct GUI
gui add, text, x5 y10 w310 center vloadedFiles
gui add, button, x60 y50 w200 h60 vbutton gpop, Pop!

updateLoadedFiles()

positionY := A_ScreenHeight - 205

gui show, w320 h135 y%positionY%, Pop File, mainWindow
controlSend Button1, {tab}, A
return


validatePath(path)
{
	if (!fileExist(path)) {
		msgBox 16, Directory invalid!, Directory "%path%" does not exist!
		exitApp
	}
}


updateLoadedFiles()
{
	global amount, origin, destination, destinationOnly
	plural := getPlural(amount)

	if (destinationOnly) {
		guiControl, , loadedFiles, %amount% file%plural% loaded from "%destination%"
	} else {
		guiControl, , loadedFiles, %amount% file%plural% loaded from "%origin%"
	}
}


getFiles(path)
{
	files := ""

	loop files, %path%\*
	{
		addFile(files, A_LoopFileName)
	}

	return files
}


addFile(byRef list, fileName)
{
	if (list == "") {
		list := fileName
	} else {
		list .= "`n" . fileName
	}
}


getFilesAmount(files)
{
	amount := 0

	loop parse, files, `n
	{
		amount++
	}

	return amount
}


getPlural(amount)
{
	if (amount == 0 || amount == 1) {
		return ""
	} else {
		return "s"
	}
}


pop:
	file := getRandom()

	if (!destinationOnly) {
		fileMove %origin%\%file%, %destination%, 1

		if (errorLevel) {
			msgBox 16, Catastrophic failure!, An error ocurred while moving file "%file%"
			exitApp
		}
	}

	run %destination%\%file%

	if (destinationOnly) {
		files := getFiles(destination)
	} else {
		files := getFiles(origin)

		if (files == "") {
			destinationOnly := true
			files := getFiles(destination)
			sleep 500
			toolTip, The origin directory is now empty!
			sleep 1500
			toolTip
		}
	}

	amount := getFilesAmount(files)
	updateLoadedFiles()
	return


getRandom()
{
	global amount, files
	random randomIndex, 1, %amount%

	loop parse, files, `n
	{
		if (A_Index == randomIndex) {
			return A_LoopField
		}
	}
}


guiClose:
	exitApp
	return