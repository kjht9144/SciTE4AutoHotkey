;
; Active Window Info
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
CoordMode, Pixel, Screen

IfExist, ..\toolicon.icl ; Seems useful enough to support standalone operation.
	Menu, Tray, Icon, ..\toolicon.icl, 9

VarSetCapacity(rect, 16)
isUpd := true
txtNotFrozen := "(Win+A to freeze display)"
txtFrozen := "(Win+A to unfreeze display)"

Gui, New, hwndhGui AlwaysOnTop
Gui, Add, Text,, Window Title and Class:
Gui, Add, Edit, w320 r2 ReadOnly -Wrap vCtrl_Title
Gui, Add, Text,, Mouse Position:
Gui, Add, Edit, w320 r3 ReadOnly vCtrl_MousePos
Gui, Add, Text,, Control Under Mouse Position:
Gui, Add, Edit, w320 r3 ReadOnly vCtrl_MouseCur
Gui, Add, Text,, Active Window Position:
Gui, Add, Edit, w320 r2 ReadOnly vCtrl_Pos
Gui, Add, Text,, Status Bar Text:
Gui, Add, Edit, w320 r2 ReadOnly vCtrl_SBText
Gui, Add, Checkbox, vCtrl_IsSlow, Slow TitleMatchMode
Gui, Add, Text,, Visible Text:
Gui, Add, Edit, w320 r2 ReadOnly vCtrl_VisText
Gui, Add, Text,, All Text:
Gui, Add, Edit, w320 r2 ReadOnly vCtrl_AllText
Gui, Add, Text, w320 r1 vCtrl_Freeze, % txtNotFrozen
Gui, Show,, Active Window Info
SetTimer, Update, 250
return

Update:
Gui %hGui%:Default
curWin := WinExist("A")
if (curWin = hGui)
	return
WinGetTitle, t1
WinGetClass, t2
GuiControl,, Ctrl_Title, % t1 "`nahk_class " t2
CoordMode, Mouse, Screen
MouseGetPos, msX, msY, msWin, msCtrlHwnd, 2
CoordMode, Mouse, Relative
MouseGetPos, mrX, mrY,, msCtrl
CoordMode, Mouse, Client
MouseGetPos, mcX, mcY
GuiControl,, Ctrl_MousePos, % "Absolute:`t" msX ", " msY " (less often used)`nRelative:`t" mrX ", " mrY " (default)`nClient:`t" mcX ", " mcY " (recommended)"
PixelGetColor, mClr, %msX%, %msY%, RGB
mClr := SubStr(mClr, 3)
mText := "`nColor:`t" mClr " (Red=" SubStr(mClr, 1, 2) " Green=" SubStr(mClr, 3, 2) " Blue=" SubStr(mClr, 5) ")"
if (curWin = msWin)
{
	ControlGetText, ctrlTxt, %msCtrl%
	mText := "ClassNN:`t" msCtrl "`nText:`t" textMangle(ctrlTxt) mText
} else mText := "`n" mText
GuiControl,, Ctrl_MouseCur, % mText
WinGetPos, wX, wY, wW, wH
DllCall("GetClientRect", "ptr", curWin, "ptr", &rect)
wcW := NumGet(rect, 8, "int")
wcH := NumGet(rect, 12, "int")
GuiControl,, Ctrl_Pos, % "x: " wX "`ty: " wY "`tw: " wW "`th: " wH "`nClient:`t`tw: " wcW "`th: " wcH
sbTxt := ""
Loop
{
	StatusBarGetText, ovi, %A_Index%
	if ovi =
		break
	sbTxt .= "(" A_Index "):`t" textMangle(ovi) "`n"
}
StringTrimRight, sbTxt, sbTxt, 1
GuiControl,, Ctrl_SBText, % sbTxt
GuiControlGet, bSlow,, Ctrl_IsSlow
SetTitleMatchMode, % bSlow ? "Slow" : "Fast"
DetectHiddenText, Off
WinGetText, ovVisText
DetectHiddenText, On
WinGetText, ovAllText
GuiControl,, Ctrl_VisText, % ovVisText
GuiControl,, Ctrl_AllText, % ovAllText
return

GuiClose:
ExitApp

textMangle(x)
{
	if pos := InStr(x, "`n")
		x := SubStr(x, 1, pos-1), elli := true
	if StrLen(x) > 40
	{
		StringLeft, x, x, 40
		elli := true
	}
	if elli
		x .= " (...)"
	return x
}

#a::
Gui %hGui%:Default
isUpd := !isUpd
SetTimer, Update, % isUpd ? "On" : "Off"
GuiControl,, Ctrl_Freeze, % isUpd ? txtNotFrozen : txtFrozen
return
