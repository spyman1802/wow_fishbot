;+--------------------------------+----------------------------------+
;| Luvmachine's Fishbot GUI & All | Original design by Pantless Krab |
;+-------------------------+------+-------+--------------------------+
;                          |Version 1.11.2|
;    +---------------------+--------------+----------------------+
; +--+By using this in conjunction with 魔兽世界 you are+--+
; |violating your EULA and TOS.  Using this bot can result in a temp|
; |or even a permanent ban.  The creator takes no responsibility for|
; +-----+what may happen to anyone who uses this original code.+----+
;     +-+------------------------------------------------------+--+
;     | Written for my friends at http://rpg-exploiters.shoq.net/ |
;     +-----------------------------------------------------------+

#include <GUIConstants.au3>
#include <ScreenCapture.au3>
#Include <WinAPI.au3>
#include "soundDetect.au3"

Global $wait_time = 30000
Global $tolerance = IniRead("hex.ini", "Variables", "Tolerance", 20)
Global $sear_step = IniRead("hex.ini", "Variables", "Step", 2)
Global $MaxSoundLevel = 15
Global $ProgressBar = 0
;$spla_colo = 0xF6F6F6

HotKeySet("{F11}", "End")
HotKeySet("{F6}", "Set_Bobber")

GUI_Gene()

Func GUI_Gene()
    GUICreate(Random(0,9999),150,127)

   Local $menu_menu = GUICtrlCreateMenu("Menu")
   Local $menu_abou = GUICtrlCreateMenuItem("About",$menu_menu)
   Local $menu_line = GUICtrlCreateMenuItem("",$menu_menu)
   Local $menu_exit = GUICtrlCreateMenuItem("Exit",$menu_menu)

   Local $help_menu = GUICtrlCreateMenu("Help")
   Local $help_gene = GUICtrlCreateMenuItem("Generate Ini",$help_menu)

   Local $start = GUICtrlCreateButton("Start",37,58,76,23)

   Local $arra = IniReadSection("hex.ini","Values")
    If @error == 1 Then
        MsgBox(4096,"","Error loading ""Values"" from Ini" & @CRLF & "Generating basic Ini setup")
        Ini_Gene()
        $arra = IniReadSection("hex.ini","Values")
    EndIf

   Local $list = GUICtrlCreateCombo("", 25, 25, 100, 23)
    For $i = 1 to $arra[0][0]
        GUICtrlSetData($list,$arra[$i][0])
    Next

    GUISetState()

   ; 创建音量条
   $ProgressBar = GUICtrlCreateProgress(10, 10, 10, 115, 0x04)

    While 1
      Local  $mess = GUIGetMsg()

        If $mess = $start Then
            global $colo_use =IniRead("hex.ini","Values",GUICtrlRead($list),"")
            Start_Bot()
        EndIf
        If $mess = $help_gene Then Ini_Gene()
        If $mess = $GUI_EVENT_CLOSE or $mess = $menu_exit Then Exit
        If $mess = $menu_abou Then MsgBox(0,"About","Written by Luvmachine" & @CRLF & "Original design Pantless Krab")
    WEnd
EndFunc

Func Ini_Gene()
    IniWrite("hex.ini","Values","Dark Purple","0x463B4D")
    IniWrite("hex.ini","Values","Red","0xA72C0B")
    IniWrite("hex.ini","Values","Stormwind Red","0x6B1F0C")
    IniWrite("hex.ini","Values","Beige","0xBB9B3D")
    IniWrite("hex.ini","Values","Wailing Caverns","0x210B04")
    IniWrite("hex.ini","Variables","Tolerance","20")
   IniWrite("hex.ini","Variables","Step","2")
EndFunc

Func Start_Bot()
   PrintLog("Hello...");
    GUIDelete()

    If Not WinExists("魔兽世界") Then
        MsgBox(0, Random(0, 9999), "魔兽世界 must be open.")
        Exit
    EndIf

    WinActivate("魔兽世界")
    WinSetOnTop("魔兽世界", "", 0)
    Sleep(500)
    Set_Size()

   WinSetOnTop("魔兽世界", "", 1)

   MouseMove($wind_left, $wind_top, 5)
   MouseMove($wind_righ, $wind_top, 5)
   MouseMove($wind_righ, $wind_bott, 5)
   MouseMove($wind_left, $wind_bott, 5)

   Cast_Pole()
	Sleep(200)
    Find_Float()
EndFunc

Func Set_Size()
   PrintLog("[Set_Size] ==> run")
   Local $bord_vert = 23
   Local $bord_hori = 4
   Local $wind_size = WinGetClientSize("魔兽世界")
	;If @error Then MyErrFunc(@ScriptLineNumber, @error)
	;ConsoleWrite("[Set_Size] ==> " & PrintList($wind_size))
	PrintList($wind_size)
   Local $wind_posi = WinGetPos("魔兽世界")
   PrintList($wind_posi)
   Local $wind_x = $wind_posi[0] + $bord_hori
   Local $wind_y = $wind_posi[1] + $bord_vert
   global $wind_top = $wind_y + (.25 * $wind_size[1])
   global $wind_bott = $wind_top + (.35 * $wind_size[1]) - 1
   global $wind_left = $wind_x + (.15 * $wind_size[0])
   global $wind_righ = $wind_left + $wind_size[0] - (.3 * $wind_size[0]) - 1
   PrintLog("[Set_Size] ==> " & $wind_top & "," & $wind_bott & "," & $wind_left & "," & $wind_righ)
EndFunc

Func Cast_Pole()
   PrintLog("[Cast_Pole] ==> Start")
    global $star_time = TimerInit()
    WinActivate("魔兽世界")
    Send("1")
    Sleep(1000)
EndFunc

Func Find_Float()
   PrintLog("[Find_Float] ==> Start")

   local $hCursor, $hOldCursor = 0
   local $found = false

   While 1
	  $found = false
	  $hCursor = 0
	  $hOldCursor = 0
	  For $Y = $wind_top to $wind_bott step 20
		 For $X = $wind_left to $wind_righ step 20
			MouseMove($X, $Y, 1)
			$hCursor = _WinAPI_GetCursorInfo()
			if $hOldCursor = 0 Then
			   PrintLog("First ... ")
			   $hOldCursor = $hCursor[2]
			   ContinueLoop
			EndIf
			If $hOldCursor <> $hCursor[2] Then
			   PrintLog("DONE!!" & $X & ":" & $Y)
			   $found = true
			   ExitLoop
			EndIf
			$hOldCursor = $hCursor[2]
		 Next

		 if $found Then
			CheckFloat($X, $Y)
			Cast_Pole()
			ExitLoop
		 EndIf
	  Next

	  Sleep(10)

   WEnd

   ;While 1
   ;   If TimerDiff($star_time) >= $wait_time Then
   ;      Cast_Pole()
   ;   EndIf
;
   ;   PrintLog("[Find_Float] ==> " & $colo_use & "," & $tolerance & "," & $sear_step)
	;  ;$pos = PixelSearch($wind_left, $wind_top, $wind_righ, $wind_bott, $colo_use, $tolerance, $sear_step)
	;  $pos = PixelSearch($wind_left, $wind_top, $wind_righ, $wind_bott, $colo_use, $tolerance)
   ;   If @error Then
	;	 PrintLog("[Find_Float] ==> Error")
   ;      SetError(0)
   ;   Else
	;	 PrintLog("[Find_Float] ==> " & PrintList($pos))
	;	 ;MouseMove(100, 100, 10)
	;	 _ScreenCapture_Capture("D:\Game\Autoit\GDIPlus_Image2.jpg", $pos[1] - 100, 100, $pos[1] + 100, 500, true)
   ;      MouseMove($pos[0], $pos[1], 20)
   ;      Find_Splash($pos[0], $pos[1] )
   ;   EndIf
;
   ;   Sleep(10)
;
   ;WEnd
EndFunc

Func CheckFloat($float_x, $float_y)
   $star_time = TimerInit()
   While TimerDiff($star_time) < $wait_time
	  Local $peakLevel = getApplicationPeakLevel()
	  GUICtrlSetData($ProgressBar, $peakLevel)
	  if $peakLevel > $MaxSoundLevel Then
		 PrintLog("FOUND !!!!!")
		 MouseClick("right", $float_x, $float_y, 1, 2)
		 Sleep(2000)
		 ExitLoop
      EndIf
	  Sleep(10)
   WEnd
EndFunc

Func Find_Splash($float_x, $float_y)
    $sear_left = $float_x - 32
    $sear_righ = $sear_left + 52
    $sear_top = $float_y - 32
    $sear_bott = $sear_top + 64

	;MouseMove(100, 100, 5)

    $star_time = TimerInit()
	While TimerDiff($star_time) < $wait_time
	   MouseMove($sear_left, $sear_top, 25)
	   MouseMove($sear_righ, $sear_top, 25)
	   MouseMove($sear_righ, $sear_bott, 25)
	   MouseMove($sear_left, $sear_bott, 25)

        $pos = PixelSearch($sear_left, $sear_top, $sear_righ, $sear_bott, 0xFFFFFF, 0)
        If @error Then
            SetError(0)
		 Else
			PrintLog("FOUND !!!!!")
            ;Send("{SHIFTDOWN}")
            MouseClick("right", $float_x, $float_y, 1, 2)
            ;Send("{ShiftUP}")
            Sleep(5500)
            ExitLoop
        EndIf
        Sleep(10)
    WEnd

    Cast_Pole()
EndFunc

Func End()
   WinSetOnTop("魔兽世界", "", 0)
   Exit
EndFunc

Func Set_Bobber()
   $bob_pos = MouseGetPos()
   MouseMove(0, 0, 0)
   $colo_use = "0x" & Hex(PixelGetColor($bob_pos[0], $bob_pos[1]), 6)
   IniWrite("hex.ini","Values", $colo_use, $colo_use)
EndFunc

Func MyErrFunc($iLineNumer, $iError)
    $iLineNumer = $iLineNumer - 1
    ConsoleWriteError("ERROR GENERATED ON SCRIPT LINE: " & $iLineNumer & @CRLF & "ERROR CODE: " & $iError)
 EndFunc


Func PrintList($List)
    If IsArray($List) Then
        Local $txt = ""
        For $i = 0 to UBound($List) -1
            $txt = $txt & "," & $List[$i]
        Next
        Local $out = StringMid($txt,2)
        Global $Result = "[" & $out & "]" & @CRLF
        ConsoleWrite($Result)
        Return $Result
    Else
        MsgBox(0, "List Error", "Variable is not an array or a list")
    EndIf
EndFunc

Func PrintLog($msg)
   ConsoleWrite($msg & @CRLF)
EndFunc

Func getApplicationPeakLevel()
   $aApp = _GetAppsPlayingSound()
   If (UBound($aApp)>1) then
	  For $i= 0 to UBound($aApp)-1
		 If ($aApp[$i][0] == "Wow.exe") then
			return Int($aApp[$i][1]*100)
		 EndIf
	  Next
   EndIf
   return 0
EndFunc