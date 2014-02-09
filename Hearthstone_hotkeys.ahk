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

;; FUNCTIONS
; Convert relative positions of buttons on screen into absolute 
; pixels for AHK commands. Allows for different resolutions.
GetAbsolutePixels(RatioX, RatioY) {
	WinGetPos,,, Width, Height
	AbsoluteX := Round(Width * RatioX)
	AbsoluteY := Round(Height * RatioY)
	return [AbsoluteX, AbsoluteY]
}

; Emote takes relative position of emote to click
Emote(EmoteX, EmoteY) {
	BlockInput, On
	Avatar := GetAbsolutePixels(0.5, 0.775)
	Emote := GetAbsolutePixels(EmoteX, EmoteY)
	MouseGetPos, MouseX, MouseY
	MouseClick, right, Avatar[1], Avatar[2]
	Sleep, 400 ; Wait until bubbles have popped up
	MouseClick, left, Emote[1], Emote[2]
	Sleep, 100
	MouseMove, %MouseX%, %MouseY%
	BlockInput, Off
}

; Presses the "END TURN" button on the right side
PassTurn() {
	BlockInput, On
	Button := GetAbsolutePixels(0.8, 0.46)
	MouseGetPos, MouseX, MouseY
	MouseClick, left, Button[1], Button[2]
	Sleep, 10
	MouseClick, left, Button[1], Button[2]
	MouseMove, %MouseX%, %MouseY%
	BlockInput, Off
	return
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

ToggleFakeFullscreen() {
	WinGet, WindowStyle, Style
	if (WindowStyle & +0xC00000) {
		WinMove,,, 0, 0, A_ScreenWidth, A_ScreenHeight
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
