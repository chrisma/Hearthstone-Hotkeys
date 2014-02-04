#SingleInstance force ; Replace an existing script
SetDefaultMouseSpeed, 0 ; move mouse instantly

^Space:: ; Ctrl + Space
~MButton:: ; Middle mouse button
IfWinActive Hearthstone ahk_class UnityWndClass
{
	WinGetPos, Xpos, Ypos, Width, Height
	ButtonX := Round(Width * 0.8)
	ButtonY := Round(Height * 0.46)
	MouseGetPos, MouseX, MouseY
	BlockInput, On
	MouseMove, %ButtonX%, %ButtonY%
	Click
	Sleep, 10
	Click
	MouseMove, %MouseX%, %MouseY%
	BlockInput, Off
}
return
