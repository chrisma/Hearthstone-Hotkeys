#SingleInstance force ; Replace an existing script
#NoEnv ; Don't check empty variables to see if they are environment variables
SetDefaultMouseSpeed, 0 ; Move mouse instantly

; Changes the tray icon's tooltip (displayed when mouse hovers over it)
Menu, tray, Tip, Hearthstone Hotkeys
; Show Tooltip in the tray that the script is active
TrayTip, Hearthstone Hotkeys, running...,,1

; Makes subsequent hotkeys only function if specified window is active
#IfWinActive Hearthstone ahk_class UnityWndClass 


;; HOTKEYS
; Pass the turn
MButton:: ; Middle mouse button
^Space:: ; Ctrl + Spacebar
^Enter:: ; Ctrl + Enter
PassTurn()
return

; Target enemy hero
^LButton:: ; Ctrl + Left mouse button
TargetEnemyHero()
return

; Emote "Greetings"
F1:: ; F1 function key on top of the keyboard
Numpad1:: ; 1 on Numpad
NumpadEnd:: ; 1 on Numpad when Numlock is off
Emote(0.42, 0.80)
return

; Emote "Well Played"
F2::
Numpad2::
NumpadDown::
Emote(0.42, 0.72)
return

; Emote "Thanks"
F3::
Numpad3::
NumpadPgDn::
Emote(0.42, 0.64)
return

; Emote "Sorry"
F4::
Numpad4::
NumpadLeft::
Emote(0.58, 0.64)
return

; Emote "Oops"
F5::
Numpad5::
NumpadClear::
Emote(0.58, 0.72)
return

; Emote "Threaten"
F6::
Numpad6::
NumpadRight::
Emote(0.58, 0.80)
return

; Toggle borderless fullscreen window mode
F12::
ToggleFakeFullscreen()
return

; Concede the match
^Esc:: ; Ctrl + Escape
Concede()
return

; Toggle "Sound in Background" option
^m:: ; Ctrl + m
ToggleBackgroundSound()
return



;; FUNCTIONS
; Convert relative positions of buttons on screen into absolute 
; pixels for AHK commands. Allows for different resolutions.
GetAbsolutePixels(RatioX, RatioY) {
	WinGetPos,,, Width, Height
	AbsoluteX := Round(Width * RatioX)
	AbsoluteY := Round(Height * RatioY)
	return [AbsoluteX, AbsoluteY]
}

; Open (and wait for) the game menu
OpenMenu() {
	SendInput, {Esc} ; Bring up the menu
	Sleep, 200 ; Wait until it has popped up
}

; Emote takes relative position of emote to click
Emote(EmoteX, EmoteY) {
	BlockInput, On
	; if not in battle, don't click around
	Avatar := GetAbsolutePixels(0.5, 0.775)
	Emote := GetAbsolutePixels(EmoteX, EmoteY)
	MouseGetPos, MouseX, MouseY
	MouseClick, right, Avatar[1], Avatar[2]
	Sleep, 120 ; Wait until bubbles have popped up
	MouseClick, left, Emote[1], Emote[2]
	Sleep, 100
	MouseMove, %MouseX%, %MouseY%
	BlockInput, Off
}

; Presses the "END TURN" button on the right side, if possible
PassTurn() {
	BlockInput, On
	; the area to be searched for the "end turn" button
	TopLeft := GetAbsolutePixels(0.75, 0.46)
	BottomRight := GetAbsolutePixels(0.95, 0.46)
	BottomRight[2] := BottomRight[2] + 1

	; Green button
	; PixelSearch, OutputVarX, OutputVarY, X1, Y1, X2, Y2, ColorID [, Variation, Fast|RGB]
	PixelSearch, FoundGreenX, FoundGreenY, TopLeft[1], TopLeft[2], BottomRight[1], BottomRight[2], 0x00FF00, 50, Fast RGB
	if (FoundGreenX) {
		FoundGreenX := FoundGreenX + 20 ;We found the edge of the button. Hit it towards the middle.
		ClickAndRestorePos(FoundGreenX, FoundGreenY)
		return
	}
	
	; Yellow Button
	PixelSearch, FoundYellowX, FoundYellowY, TopLeft[1], TopLeft[2], BottomRight[1], BottomRight[2], 0xFFFF00, 50, Fast RGB
	if (FoundYellowX) {
		FoundYellowX := FoundYellowX + 20 ;We found the edge of the button. Hit it towards the middle.
		ClickAndRestorePos(FoundYellowX, FoundYellowY)
		return
	}
	
	BlockInput, Off
	return
}

ClickAndRestorePos(x,y) {
	MouseGetPos, MouseX, MouseY
	MouseClick, left, x, y
	Sleep, 20
	; Seems to work better if we click twice
	MouseClick, left, x, y
	MouseMove, %MouseX%, %MouseY%
}

; Drags from current mouse location to enemy hero
TargetEnemyHero() {
	BlockInput, On
	Hero := GetAbsolutePixels(0.5, 0.211)
	MouseGetPos, MouseX, MouseY
	Click down
	Sleep, 10
	Click down
	MouseMove, Hero[1], Hero[2], 5
	Sleep, 10
	Click up left
	; MouseClickDrag, L,,, HeroX, HeroY, 5 ; unreliable
	Sleep, 50
	MouseMove, %MouseX%, %MouseY%
	BlockInput, Off
	return
}

; Bring up the menu and click the "Concede" button
Concede() {
	OpenMenu()
	Button := GetAbsolutePixels(0.5, 0.4)
	MouseClick, left, Button[1], Button[2]
}

; Toggle fullscreen window without border and sreen dimensions
ToggleFakeFullscreen() {
	WinGet, WindowStyle, Style
	if (WindowStyle & +0xC00000) {
		WinMove,,, 25, 2, A_ScreenWidth, A_ScreenHeight
		WinSet, Style, -0xC00000 ; remove title bar
		; Works best if done twice, no idea why
		WinMove,,, 0, 0, A_ScreenWidth, A_ScreenHeight
		WinSet, Style, -0xC00000
	} else {
		; Resize slightly smaller than screen, position at the top
		WinMove,,, 25, 2, A_ScreenWidth-50, A_ScreenHeight-50
		WinSet, Style, +0xC00000 ; restore title bar
	}
}

; Go to the options menu and toggle "Sound In Background" option
ToggleBackgroundSound() {
	BlockInput, On
	MouseGetPos, MouseX, MouseY
	OpenMenu()
	OptionsButton := GetAbsolutePixels(0.5, 0.53)
	MouseClick, left, OptionsButton[1], OptionsButton[2]
	Sleep, 200 ; Wait for the menu to pop up
	SoundInBackgroundCheckBox := GetAbsolutePixels(0.56, 0.34)
	MouseClick, left, SoundInBackgroundCheckBox[1], SoundInBackgroundCheckBox[2]
	Sleep, 50
	SendInput, {Esc} ; Exit out of the menus
	Sleep, 100
	SendInput, {Esc}
	MouseMove, %MouseX%, %MouseY%
	BlockInput, Off
}