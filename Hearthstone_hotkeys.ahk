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
	; if not in battle, don't click around
	if not IsDuringMatch() {
		return
	}
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

; Presses the "END TURN" button on the right side
PassTurn() {
	BlockInput, On
	Button := GetAbsolutePixels(0.81, 0.46)
	PixelGetColor, color, Button[1], Button[2], RGB
	; only click when "END TURN" button is active
	; background		yellow		green
	; squash/kite	 	0xEFE000	0x2DE302
	; catapult/zeppelin 0xDDAB00	0x2AAD02
	; jungle/waterfall	0xEFE000	0x2DE202
	; Inn/Hippogriff	0xD6Ca00	0x29CC00
	yellow := 0xEFE000
	green := 0x2DE302
	current := color
	if ( SameShade(current, yellow) ) or ( SameShade(current, green) ) {
		MouseGetPos, MouseX, MouseY
		MouseClick, left, Button[1], Button[2]
		Sleep, 10
		MouseClick, left, Button[1], Button[2]
		MouseMove, %MouseX%, %MouseY%
	}
	BlockInput, Off
	return
}

; Split colors into their RGB values
; Taken from stackoverflow.com/questions/16872911/how-to-determine-whether-colour-is-within-a-range-of-shades
SplitColors(color) {
    return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
}

; Determine if the RGB values of colors are within variance of each other 
SameShade(c1, c2, variance=60) {
	c1 := SplitColors(c1)
	c2 := SplitColors(c2)
    rdiff := Abs( c1.r - c2.r )
    gdiff := Abs( c1.g - c2.g )
    bdiff := Abs( c1.b - c2.b )
    return rdiff <= variance && gdiff <= variance && bdiff <= variance
}

IsDuringMatch() {
	PlayfieldPoint := GetAbsolutePixels(0.4, 0.3)
	PixelGetColor, currentColor, PlayfieldPoint[1], PlayfieldPoint[2], RGB
	playfieldColor := 0xD5985B
	return SameShade(currentColor, playfieldColor)
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

Concede() {
	SendInput, {Esc} ; Bring up the menu
	Sleep, 300 ; Wait until it has popped up
	Button := GetAbsolutePixels(0.5, 0.4)
	MouseClick, left, Button[1], Button[2]
}

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
