moveToDesktop(desktopNumber) {
	;after the left 10 it will be on window 1 so decrement the count by 1 to compensate
	desktopNumber--
	send {tab}{right %desktopNumber%}{return}
	return
}

moveActiveWindowToDesktop(newDesktopNumber, follow) { 
	desktopNumber := newDesktopNumber

	monitorNumber := getCurrentMonitor()
	SysGet, primaryMonitor, MonitorPrimary

	currentDesktopNumber := getCurrentDesktopNumber()
	if(currentDesktopNumber == newDesktopNumber)
	{
		return
	}
	;desktop starts at 1 so decrement the new desktopNumber by 1
	newDesktopNumber--
	if(currentDesktopNumber <= newDesktopNumber)
	{
		newDesktopNumber--
	}

	if(monitorNumber <> primaryMonitor)
	{
		send {Esc}{tab 2}{AppsKey}
	}

	send {m}{down %newDesktopNumber%}{return}

	if(follow == true)
	{
		moveToDesktop(desktopNumber)
	} else {
		send {return}
	}

	return  
}

/*
 * Gets the current desktop number by processing the contents of the right click context menu in 
 * the multitasking view frame (the view after pressing Windows key + tab)
 *
 * Pass false as the first parameter to close with multitasking view after getting the desktop number
 *
 * returns 0 if there was an error
 */
getCurrentDesktopNumber(leaveWinTabOpen := true) {
	currentDesktopNumber := 0
	send #{tab}
	sleep 100
	WinWait, ahk_class MultitaskingViewFrame, , 3
	if ErrorLevel
	{
		send #{tab}
		sleep 100
		WinWait, ahk_class MultitaskingViewFrame, , 3
		if ErrorLevel
		{
			 MsgBox, Error waiting for MultitaskingViewFrame
		}
	}
	send {Appskey}
	menuString := getMenuString(getContextMenuHwnd())

	while(instr(menuString, "Desktop"))
	{
		if(! regexMatch(menuString, ",Desktop " A_index ","))
		{
			currentDesktopNumber := A_Index
			break
		}
	}
	if(!leaveWinTabOpen)
	{
		send #{tab}
	}
	return currentDesktopNumber
}

GetCurrentMonitor() {
	SysGet, numberOfMonitors, MonitorCount
	WinGetPos, winX, winY, winWidth, winHeight, A
	winMidX := winX + winWidth / 2
	winMidY := winY + winHeight / 2
	Loop %numberOfMonitors%
	{
	SysGet, monArea, Monitor, %A_Index%
	if (winMidX > monAreaLeft && winMidX < monAreaRight && winMidY < monAreaBottom && winMidY > monAreaTop)
		return %A_Index%
	}
	return
}