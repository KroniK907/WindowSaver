# WindowSaver
An AutoHotkey Script  
v0.1  
Created by [Daniel Kranich](https://github.com/KroniK907)  
Based on [DockWin v0.3](https://autohotkey.com/board/topic/112113-dockwin-storerecall-window-positions/) by Paul Troiano  

PgP Certificate Info:
Daniel Kranich (KroniK907)
Daniel@nusalaska.com
Fingerprint: A6B02662165767349DE1EB059A4AD6319313709B

###Description
This is a script that can save the location and size of all of your windows and then restore those windows to their correct positions at a later time.

###Features
- Specifically designed to work with Windows10 Virtual Desktops
  - Assigns a desktop to each window
  - Restores to the appropriate desktop
- Works well with multiple monitors
- Can save multiple layouts depending on monitor setup
  - If you switch between a single monitor and a dual screen setup, you can save a layout with each monitor setup
  - Restores the correct layout depending on number of monitors connected
- Saves weather a window is maximized or minimized
- Call from any ahk script

###Uses
I use this script when I need to do a windows update or need to restart my computer for any reason. I can simply save my layout before shutdown and then when I have rebooted, I can re open all the programs I had running and hit a hotkey and have it all back the way it was before. I also have a laptop which I may or may not have connected to a secondary monitor. I can save a layout, with and without my second monitor and every time I switch I can hit a hotkey and have all my windows arranged the way I like. 

###Installation
**Simple Install**  
Download WindowSaver.exe  
The exe must be run with one of the two following paramaters  

- snap
  - Takes a snapshot of your current layout and saves the details to WinPos.txt
- restore
  - Figures out which saved layout it should restore
  - Restores all windows to their appropriate places

Example:  
"C:\path\to\exe\WindowSaver.exe snap"   
"C:\path\to\exe\WindowSaver.exe restore"

**Install With Source**  
Downlad the source .ahk files.  
Use the same method as above but by calling your local AutoHotkey.exe  

Example:  
"C:\path\to\AutoHotkey.exe C:\path\to\WindowSaver.ahk snap"  
"C:\path\to\AutoHotkey.exe C:\path\to\WindowSaver.ahk restore"  

**Set Up Hotkey**  
You can set up a hotkey using the following

    key:: Run "C:\path\to\WindowSaver.exe" snap
    key:: Run "C:\path\to\WindowSaver.exe" restore
    
or
  
    key:: Run "C:\path\to\AutoHotkey.exe" "C:\path\to\WindowSaver.ahk" snap
    key:: Run "C:\path\to\AutoHotkey.exe" "C:\path\to\WindowSaver.ahk" restore
