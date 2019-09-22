#include <WinAPICom.au3>
#include <Process.au3>
#include <Array.au3>

Opt("MustDeclareVars", 1)
;==============================================================================================
Global Const $CLSCTX_INPROC_SERVER = 0x01 + 0x02 + 0x04 + 0x10
Global Enum $eRender, $eCapture, $eAll, $EDataFlow_enum_count
Global Enum $AudioSessionStateInactive, $AudioSessionStateActive, $AudioSessionStateExpired
Global Const $eMultimedia = 1
Local $aApp =0

Global Const $sCLSID_MMDeviceEnumerator = "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
Global Const $sIID_IMMDeviceEnumerator = "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
Global Const $sTagIMMDeviceEnumerator = _
        "EnumAudioEndpoints hresult(int;dword;ptr*);" & _
        "GetDefaultAudioEndpoint hresult(int;int;ptr*);" & _
        "GetDevice hresult(wstr;ptr*);" & _
        "RegisterEndpointNotificationCallback hresult(ptr);" & _
        "UnregisterEndpointNotificationCallback hresult(ptr)"

Global Const $sIID_IAudioMeterInformation = "{C02216F6-8C67-4B5B-9D00-D008E73E0064}"
Global Const $sTagIAudioMeterInformation = "GetPeakValue hresult(float*);" & _
        "GetMeteringChannelCount hresult(dword*);" & _
        "GetChannelsPeakValues hresult(dword;float*);" & _
        "QueryHardwareSupport hresult(dword*);"

Global Const $sIID_IMMDevice = "{D666063F-1587-4E43-81F1-B948E807363F}"
Global Const $sTagIMMDevice = _
        "Activate hresult(clsid;dword;ptr;ptr*);" & _
        "OpenPropertyStore hresult(dword;ptr*);" & _
        "GetId hresult(wstr*);" & _
        "GetState hresult(dword*)"

Global Const $sIID_IAudioSessionManager2 = "{77aa99a0-1bd6-484f-8bc7-2c654c9a9b6f}"
Global Const $sTagIAudioSessionManager = "GetAudioSessionControl hresult(ptr;dword;ptr*);" & _
        "GetSimpleAudioVolume hresult(ptr;dword;ptr*);"
Global Const $sTagIAudioSessionManager2 = $sTagIAudioSessionManager & "GetSessionEnumerator hresult(ptr*);" & _
        "RegisterSessionNotification hresult(ptr);" & _
        "UnregisterSessionNotification hresult(ptr);" & _
        "RegisterDuckNotification hresult(wstr;ptr);" & _
        "UnregisterDuckNotification hresult(ptr)"

Global Const $sIID_IAudioSessionEnumerator = "{e2f5bb11-0570-40ca-acdd-3aa01277dee8}"
Global Const $sTagIAudioSessionEnumerator = "GetCount hresult(int*);GetSession hresult(int;ptr*)"

Global Const $sIID_IAudioSessionControl = "{f4b1a599-7266-4319-a8ca-e70acb11e8cd}"
Global Const $sTagIAudioSessionControl = "GetState hresult(int*);GetDisplayName hresult(wstr*);" & _
        "SetDisplayName hresult(wstr);GetIconPath hresult(wstr*);" & _
        "SetIconPath hresult(wstr;ptr);GetGroupingParam hresult(ptr*);" & _
        "SetGroupingParam hresult(ptr;ptr);RegisterAudioSessionNotification hresult(ptr);" & _
        "UnregisterAudioSessionNotification hresult(ptr);"

Global Const $sIID_IAudioSessionControl2 = "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
Global Const $sTagIAudioSessionControl2 = $sTagIAudioSessionControl & "GetSessionIdentifier hresult(wstr*);" & _
        "GetSessionInstanceIdentifier hresult(wstr*);" & _
        "GetProcessId hresult(dword*);IsSystemSoundsSession hresult();" & _
        "SetDuckingPreferences hresult(bool);"
;==============================================================================================

_WinAPI_CoInitialize()




Func _GetAppsPlayingSound()
   Local $pIMMDevice = 0
   Local $oMMDevice = 0
   Local $pIAudioSessionManager2 = 0
   Local $oIAudioSessionManager2 = 0
   Local $pIAudioSessionEnumerator = 0
   Local $oIAudioSessionEnumerator = 0
   Local $nSessions = 0
   Local $oMMDeviceEnumerator = 0
   Local $aApp[1][1]
   Local $pIAudioSessionControl2 = 0
   Local $oIAudioSessionControl2 = 0
   Local $oIAudioMeterInformation = 0
   Local $ProcessID = 0
   Local $fPeakValue = 0
   Local $iState = 0
   Local $oErrorHandler = 0

   $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")
   $oMMDeviceEnumerator = ObjCreateInterface($sCLSID_MMDeviceEnumerator, $sIID_IMMDeviceEnumerator, $sTagIMMDeviceEnumerator)
   If @error Then Return $aApp

   If ($oMMDeviceEnumerator.GetDefaultAudioEndpoint($eRender, $eMultimedia, $pIMMDevice) >= 0) Then ;eRender
	  $oMMDevice = ObjCreateInterface($pIMMDevice, $sIID_IMMDevice, $sTagIMMDevice)
	  $oMMDevice.Activate($sIID_IAudioSessionManager2, $CLSCTX_INPROC_SERVER, 0, $pIAudioSessionManager2)
	  $oIAudioSessionManager2 = ObjCreateInterface($pIAudioSessionManager2, $sIID_IAudioSessionManager2, $sTagIAudioSessionManager2)
	  $oIAudioSessionManager2.GetSessionEnumerator($pIAudioSessionEnumerator)
	  $oIAudioSessionEnumerator = ObjCreateInterface($pIAudioSessionEnumerator, $sIID_IAudioSessionEnumerator, $sTagIAudioSessionEnumerator)
	  $oIAudioSessionEnumerator.GetCount($nSessions)

	  For $i = 0 To $nSessions - 1
		 $oIAudioSessionEnumerator.GetSession($i, $pIAudioSessionControl2)
		 $oIAudioSessionControl2 = ObjCreateInterface($pIAudioSessionControl2, $sIID_IAudioSessionControl2, $sTagIAudioSessionControl2)
		 $oIAudioSessionControl2.GetState($iState)

		 If $iState = $AudioSessionStateActive Then
			 $oIAudioSessionControl2.GetProcessId($ProcessID)
			 $oIAudioMeterInformation = ObjCreateInterface($pIAudioSessionControl2, $sIID_IAudioMeterInformation, $sTagIAudioMeterInformation)
			 $oIAudioSessionControl2.AddRef
			 $oIAudioMeterInformation.GetPeakValue($fPeakValue)
			 If $fPeakValue > 0 Then
				 ReDim $aApp[UBound($aApp) + 1][2]
				 $aApp[UBound($aApp) - 1][0] = _ProcessGetName($ProcessID)
				 $aApp[UBound($aApp) - 1][1] = $fPeakValue
			 EndIf
		  EndIf

		 $fPeakValue = 0
		 $iState = 0
		 $ProcessID = 0
		 $oIAudioMeterInformation = 0
		 $oIAudioSessionControl2 = 0
	  Next

	  $oIAudioSessionEnumerator = 0
	  $oIAudioSessionManager2 = 0
	  $oMMDevice = 0
	  $oMMDeviceEnumerator = 0

	  If UBound($aApp) = 0 Then $aApp = 0
		 Return $aApp
	  Else
        Return 0
	  EndIf
EndFunc   ;==>_GetAppsPlayingSound

; User's COM error function. Will be called if COM error occurs
Func _ErrFunc($oError)
    ; Do anything here.
    ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
            @TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
            @TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
            @TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
            @TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
            @TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
            @TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
            @TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
            @TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
            @TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc