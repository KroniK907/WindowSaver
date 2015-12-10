;-----------------------------------------------;
;             KroniK's Window Saver             ;
;                 December 2015                 ;
;                     v.0.1                     ;
;-----------------------------------------------;
;-----------------------------------------------;
; This script is used to save and restore       ;
; my windows and applications after a reboot    ;
;                                               ;
; Based on DockWin v0.3 by Paul Troiano         ;
;-----------------------------------------------;
;-----------------------------------------------;
; Changelog v.0.1                               ;
;   Inital Commit                               ;
;-----------------------------------------------;



;-------------------;
; Header            ;
;-------------------;

#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2      ;A window's title can contain WinTitle anywhere inside it to be a match
SetTitleMatchMode, Fast     ;Fast is default
DetectHiddenWindows, off     ;off is default 

global FileName := "WinPos.txt" 
global CrLf := "`r`n"

;-------------------;
; Actions           ;
;-------------------;

if (%0% < 1)
{
    MsgBox, "This script requires an argument`nUse 'snap' to save window positions`nUse 'restore' to restore window positions"
    ExitApp
}

loop, %0%
{
    arg := %A_Index%
    Break
}

if (arg == "snap") {
    snapshot()
} else if (arg == "restore") {
    restore()
} else {
    MsgBox, arg "The argument you passed is not valid. Please use 'snap' or 'restore'"
    ExitApp
}

;-------------------;
; Functions         ;
;-------------------;

; Restore Windows
;-----------------------------------------------

restore() {
  WinGetActiveTitle, SavedActiveWindow
  ParmVals := "Title desktop minmax x y height width path"
  SectionToFind := SectionHeader()
  SectionFound := 0

  Loop, Read, %FileName%
  {
    if !SectionFound
    {
      ;Read through file until correction section found
      If (A_LoopReadLine<>SectionToFind) 
      Continue
    }   

    ;Exit if another section reached
    If ( SectionFound and SubStr(A_LoopReadLine,1,8)="SECTION:")
      Break

    SectionFound := 1
    Win_Title:="", Win_desktop:=0, Win_minmax:=0, Win_x:=0, Win_y:=0, Win_width:=0, Win_height:=0, Win_path:=""

    Loop, Parse, A_LoopReadLine, CSV 
    {
      EqualPos:=InStr(A_LoopField,"=")
      Var:=SubStr(A_LoopField,1,EqualPos-1)
      Val:=SubStr(A_LoopField,EqualPos+1)
      IfInString, ParmVals, %Var%
      {
        ;Remove any surrounding double quotes (")
        If (SubStr(Val,1,1)=Chr(34)) 
        {
            StringMid, Val, Val, 2, StrLen(Val)-2
        }
        Win_%Var% := Val  
      }
    }

    If ( (StrLen(Win_Title) > 0) and WinExist(Win_Title) )
    { 
      WinRestore, %Win_Title%
      WinActivate, %Win_Title%
      WinWait, %Win_Title%, , 3
      if ErrorLevel
      {
        WinActivate, %Win_Title%
        WinWait, %Win_Title%, , 3
        if ErrorLevel
        {
          WinActivate, %Win_Title%
        }
      }
      if (Win_minmax == 1) {
        WinMaximize
      } else if (Win_minmax == -1) {
        WinMinimize
      } else {
        WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
      }
      sleep 300
      desktop := moveActiveWindowToDesktop(Win_desktop, false)
    }

  }

  if !SectionFound
  {
    msgbox,,Dock Windows, Section does not exist in %FileName% `nLooking for: %SectionToFind%`n`nTo save a new section, use Win-Shift-0 (zero key above letter P on keyboard)
  }
  ;Restore window that was active at beginning of script
  WinActivate, %SavedActiveWindow%
  ExitApp
}

; Create System Snapshot
;-----------------------------------------------

snapshot() {
  SectionToFind := SectionHeader()
  SectionFound := 0
  file := FileOpen(FileName, "a")
  file2 := FileOpen("staging.txt", "w") 
  Loop, Read, file, file2
  {
    if !SectionFound
    {
      ;Read through file until correction section found
      If (A_LoopReadLine<>SectionToFind) 
      {
        FileAppend, %A_LoopReadLine%
        Continue
      }

      SectionFound := 1
    }

    ;Exit if another section reached
    If (SectionFound and SubStr(A_LoopReadLine,1,8)="SECTION:")
    {
      SectionFound := 0
    }
  }

  file.Close()
  file2.Close()
  FileMove, staging.txt, %FileName%, 1

  file := FileOpen(FileName, "a")

  MsgBox, 4,Dock Windows,Save window positions?
  IfMsgBox, NO, Return

  WinGetActiveTitle, SavedActiveWindow

  if !IsObject(file)
  {
    MsgBox, Can't open "%FileName%" for writing.
    Return
  }

  line := SectionHeader() . CrLf
  file.Write(line)

  ; Loop through all windows on the entire system
  WinGet, id, list,,, Program Manager
  Loop, %id%
  {
    this_id := id%A_Index%
    WinActivate, ahk_id %this_id%
    WinGetPos, x, y, Width, Height, A ;Wintitle
    WinGet, path, ProcessPath, A ;Wintitle 
    winGet, minmax, MinMax, A
    desktop := getCurrentDesktopNumber(false)
    WinGetClass, this_class, ahk_id %this_id%
    WinGetTitle, this_title, ahk_id %this_id%

    if ( (StrLen(this_title)>0) and (this_title<>"Start") )
    {
      this_title .= " ahk_class " . this_class

      line=Title="%this_title%"`,desktop=%desktop%`,minmax=%minmax%`,x=%x%`,y=%y%`,width=%width%`,height=%height%`,path="%path%"`r`n
      file.Write(line)
    }
  }

  file.write(CrLf)  ;Add blank line after section
  file.Close()

  ;Restore active window
  WinActivate, %SavedActiveWindow%
  ExitApp
}


;Create standardized section header for later retrieval
;-----------------------------------------------

SectionHeader() {
    SysGet, MonitorCount, MonitorCount
    SysGet, MonitorPrimary, MonitorPrimary
    line = SECTION: Monitors=%MonitorCount%,MonitorPrimary=%MonitorPrimary%
    WinGetPos, x, y, Width, Height, Program Manager
    line := line . "; Desktop size:" . x . "," . y . "," . width . "," . height

    Return %line%
}

;-------------------;
; Include           ;
;-------------------;

#Include contextMenu.ahk
#Include desktopChanger.ahk