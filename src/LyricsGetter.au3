#include <String.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

$sURLPre = "https://genius.com/"
$sURLPost = "-lyrics"

$sHelp = "Play a song to show the lyrics!"
$bFoundSpotify = True
$hSpotify = WinGetHandle("Spotify")
If @error Then
   $bFoundSpotify = False
   $sHelp = "Run Spotify or stop the current song..."
EndIf
$sStartTitle = WinGetTitle($hSpotify)
$sLastTitle = $sStartTitle

$hGUI = GUICreate("LyricsGetter", 400, 620)
$hSongLabel = GUICtrlCreateLabel($sHelp & " | Powered by genius.com", 0, 0, 400, 20, $SS_CENTER)
$hLyricField = GUICtrlCreateEdit("The lyrics will appear here!", 0, 20, 400, 600)
GUISetState(@SW_SHOW)

While 1
   $nMsg = GUIGetMsg()
   Switch $nMsg
	  Case $GUI_EVENT_CLOSE
		 GuiDelete($hGUI)
		 ExitLoop
   EndSwitch
   If $bFoundSpotify Then
	  $sCurrentTitle = WinGetTitle($hSpotify)
	  If $sCurrentTitle <> $sLastTitle Then
		 If $sCurrentTitle <> $sStartTitle Then
			GUICtrlSetData($hSongLabel, $sCurrentTitle & " | Powered by genius.com")
			$aDelim = StringRegExp($sCurrentTitle, "\s-\s", $STR_REGEXPARRAYGLOBALFULLMATCH)
			$sArtist = ""
			$sTitle = ""
			If UBound($aDelim, 1) > 1 Then ; Parsing strings like "Duck Sauce - Barbra Streisand - Radio Edit"
			   $aRegExp = StringRegExp($sCurrentTitle, "([^-]*) - ", $STR_REGEXPARRAYGLOBALFULLMATCH)
			   $sArtist = ($aRegExp[0])[1]
			   $sTitle = ($aRegExp[1])[1]
			Else
			   $aRegExp = StringRegExp($sCurrentTitle, "(.*)\s-\s(.*)", $STR_REGEXPARRAYMATCH)
			   $sArtist = $aRegExp[0]
			   $sTitle = $aRegExp[1]
			EndIf
			If $sArtist <> "" And $sTitle <> "" Then
			   $sLyrics = ParseLyrics(GetLyrics($sArtist, $sTitle))
			   GUICtrlSetData($hLyricField, $sLyrics)
			Else
			   GUICtrlSetData($hLyricField, "There was a problem with parsing this song title or artist.")
			EndIf
		 EndIf
		 $sLastTitle = $sCurrentTitle
	  EndIf
   Else
	  $hSpotify = WinGetHandle("Spotify")
	  If Not @error Then
		 $bFoundSpotify = True
		 $sStartTitle = WinGetTitle($hSpotify)
		 $sLastTitle = $sStartTitle
		 GUICtrlSetData($hSongLabel, "Play a song to show the lyrics! | Powered by genius.com")
	  EndIf
   EndIf
WEnd

Func ParseLyrics($sUnparsed)
   $sCurrent = StringRegExpReplace($sUnparsed, "<[^>]*>", "")
   If @error Then
	  ConsoleWriteError("Problem with RegExpReplace.")
	  If @error = 2 Then
		 ConsoleWriteError("Pattern invalid at position " & @extended)
	  EndIf
   EndIf
   $sCurrent = StringStripWS($sCurrent, 3)
   If @error Then
	  ConsoleWriteError("Error stripping whitespace.")
   EndIf
   $sCurrent = StringReplace($sCurrent, @LF, @CRLF)
   $sCurrent = StringReplace($sCurrent, "&amp;", "&")
   Return $sCurrent
EndFunc


Func GetLyrics($sArtist, $sTitle)
   $sLyricsUnparsed = _StringBetween(GetPage($sArtist, $sTitle), '<div class="lyrics">', '</div>')
   If @error Then
	  Return "Lyrics could not be found."
   EndIf
   Return $sLyricsUnparsed[0]
EndFunc

Func GetPage($sArtist, $sTitle)
   $sFormattedArtist = Format($sArtist)
   $sFormattedTitle = Format($sTitle)
   $sFullURL = $sURLPre & $sFormattedArtist & "-" & $sFormattedTitle & $sURLPost
   $sInetRead = InetRead($sFullURL)
   If @error Then
	  Return "There was a problem when contacting " & $sFullURL & "." & @CRLF & "Please make sure you have a working internet connection."
   EndIf
   Return BinaryToString($sInetRead, 4)
EndFunc

Func Format($sText)
   $sText = StringLower($sText)
   $sText = StringReplace($sText, "&", "and")
   $sText = StringRegExpReplace($sText, "\s\(feat.*\)", "")
   $sText = StringReplace($sText, "ä", "a")
   $sText = StringReplace($sText, "ö", "o")
   $sText = StringReplace($sText, "ü", "u")
   $sText = StringReplace($sText, "í", "i")
   $sText = StringReplace($sText, "é", "e")
   $sText = StringReplace($sText, "á", "a")
   $sText = StringRegExpReplace($sText, "[^\w\d\s]", "")
   $sText = StringReplace($sText, "  ", " ")
   $sText = StringReplace($sText, " ", "-")
   Return $sText
EndFunc