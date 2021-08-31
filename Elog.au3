#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=radio.ico
#AutoIt3Wrapper_Outfile=..\..\elog.Exe
#AutoIt3Wrapper_Res_Comment=Alpha
#AutoIt3Wrapper_Res_Description=Software for HAM Radio Users
#AutoIt3Wrapper_Res_Fileversion=1.5.4.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductName=Elog
#AutoIt3Wrapper_Res_ProductVersion=1.5.4.1
#AutoIt3Wrapper_Res_CompanyName=GFMsoft
#AutoIt3Wrapper_Res_LegalCopyright=Ferdinand Marx - www.GFMSOFT.de
#AutoIt3Wrapper_Res_LegalTradeMarks=Ferdinand Marx - www.GFMSOFT.de
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; 01.07.2021 - Copyright © by Ferdinand Marx - www.GFMsoft.de / www.13OT4288.com - marx@gfmsoft.de



TraySetState(2)
AutoItSetOption("MustDeclareVars", 1)

;Internal Dokumentation
;~ ##############################################
;Projectstart - 01.07.21 - Target: Easy to use software for HAM-Radio users - Log a QSO easy

;26.07.2021
;Deletefunction created
;Reloadfunction created

;27.07.2021
;Editform complete
;There is a problem with _arraydisplay - This call collides with WM_noity
;Make sure to switch off wm_notify when testing with arrays

;28.07.2021
;Exportfunction is complete - all data can be exported into a csv

;29.07.2021
;Importfunction completed for CLUSTERDX
;Importfunctions for HDX.net and 11dx.net are planned

;30.07.2021
;Colors for edit and main GUI changed
;BG-Pic for editor created

;~ 03.08.2021
;Searchfunction completed

;~ 18.08.2021
;Changed docu to English
;Translated some varnames to english
;Program Version to 1.4.1.2
;Cleaned up the code
;Tested on different hardware and found some problems - all problems are solved

;~ 21.08.2021
;Added convert from locator to longitude and latitude
;Added distance calculation between to coordinates
;Added options.ini and functionality  of saving its own locator
;Added options GUI

;~ 27.08.2021
;Added language options
;minor changes to code due some errors
;we had some problems with distance calculations when no remote locator was given
;that problem is solved and 0 km is displayed when the remote locator is empty or incorrect

;Another test is necessary  before going into Alpha and releasing on Github
;Planned release is around 10 SEP of 2021
;When an earlier release is possible then go for it

;~ 30.08.2021
; Converted more of the code to a bilangual setting
; All errors and other prompts are now repsonding to the language settings

#Region Includes
;~ ##############################################
;~  _____            _           _           	#
;~ |_   _|          | |         | |          	#
;~   | |  _ __   ___| |_   _  __| | ___  ___ 	#
;~   | | | '_ \ / __| | | | |/ _` |/ _ \/ __|	#
;~  _| |_| | | | (__| | |_| | (_| |  __/\__ \	#
;~ |_____|_| |_|\___|_|\__,_|\__,_|\___||___/	#
;~ ##############################################
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <GuiListView.au3>
#EndRegion Includes

#Region ;Main declare of vars
;~ ##############################################
;~ __      __            						#
;~ \ \    / /            						#
;~  \ \  / /_ _ _ __ ___ 						#
;~   \ \/ / _` | '__/ __|						#
;~    \  / (_| | |  \__ \						#
;~     \/ \__,_|_|  |___/						#
;~ ##############################################
Global $version, $sql_status, $maincounter, $dbh, $ID, $Index_listload, $lastid, $cleardate, $cleartime
Global $searchtermfunc, $editcall, $nMsg, $ownlocator, $qthdistance, $dbsearchterm, $dbsearchdata, $searchquery, $olddbsearchterm
Global $editform, $edit_button1, $edit_button2, $edit_datum, $edit_zeit, $edit_Rufzeichen, $edit_Skip
Global $edit_RX, $edit_TX, $edit_Frequenz, $edit_Operatorname, $edit_Locator, $edit_QTH, $edit_Notiz, $edit_Combo1
Global $edit_label1, $edit_label2, $edit_label3, $edit_label4, $edit_label5, $edit_label6, $edit_label7, $edit_label8, $edit_label13
Global $edit_label9, $edit_label10, $edit_label11, $edit_label12, $edit_pic
Global $QSO, $List1, $Button1, $Button2, $Button3, $Button4, $Button5
Global $Datum, $Zeit, $Rufzeichen, $skip, $RX, $TX, $FREQ, $mode, $Name, $locator, $QTH, $notiz, $label1, $label2
Global $label7, $label8, $label9, $label10, $label11, $label12, $label13, $label14, $label3, $label4, $label5, $label6
Global $searchform, $searchform_Label1, $searchform_Button1, $searchform_Button2, $searchform_Input1, $latitude, $longtitude
Global $settingsform, $settingsform_Input1, $settingsform_Label1, $settingsform_Button1, $settingsform_Button2
Global $r, $settingsform_combo1, $settingsform_Label2, $global_language
#EndRegion ;Main declare of vars


;setting specific values into some vars
$r = 6371000 ;Radius of earth - usually i had this in the func - defined at every call - but this is obviously a const so it goes to global
$cleardate = 0
$cleartime = 0
$lastid = 0
$Index_listload = 0
$maincounter = 0
$sql_status = 0
$version = "1.5.4.1"
$dbsearchterm = ""
$searchtermfunc = ""
$global_language=""

;~ Program init and register WM_Notify event
init()
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

;set language
$global_language=IniRead(@ScriptDir&"\settings.ini","Settings","Language","")

if $global_language <> "EN" and $global_language <> "DE" Then
	$global_language="DE"
EndIf

;MainGUI
#Region ### START Koda GUI section for Maingui   	###
if $global_language = "DE" Then
	$QSO = GUICreate("Elog - " & $version, 1025, 645, -1, -1)
	GUISetIcon("radio.ico", 0, $QSO)
	GUISetBkColor(0x757575, $QSO)
	$List1 = GUICtrlCreateListView("ID | Datum | Zeit | Rufzeichen | Skip | RX | TX | FRQ | Mode | Name | Locator | QTH | Notiz", 8, 152, 1009, 474)
	$Button1 = GUICtrlCreateButton("Speichern", 818, 24, 110, 49)
	GUICtrlSetFont(-1, 11, 400, 0, "Arial")
	$Button2 = GUICtrlCreateButton("Löschen", 818, 88, 110, 49)
	GUICtrlSetFont(-1, 11, 400, 0, "Arial")
	$Button3 = GUICtrlCreateButton("Optionen", 940 + 11, 60 + 28, 50, 23)
	$Button4 = GUICtrlCreateButton("Export", 940 + 11, 95 + 19, 50, 23)
	$Button5 = GUICtrlCreateButton("Suche", 940 + 11, 50, 50, 23)
	$Datum = GUICtrlCreateInput("", 8, 26, 129, 21)
	$Zeit = GUICtrlCreateInput("", 160, 26, 129, 21)
	$Rufzeichen = GUICtrlCreateInput("", 8, 71, 129, 21)
	$skip = GUICtrlCreateInput("", 160, 71, 129, 21)
	$RX = GUICtrlCreateInput("", 312, 71, 73, 21)
	$TX = GUICtrlCreateInput("", 400, 71, 73, 21)
	$FREQ = GUICtrlCreateInput("", 496, 71, 153, 21)
	$mode = GUICtrlCreateCombo("Mode", 672, 71, 121, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "CW|AM|FM|USB|LSB")
	$Name = GUICtrlCreateInput("", 8, 117, 129, 21)
	$locator = GUICtrlCreateInput("", 160, 117, 129, 21)
	$QTH = GUICtrlCreateInput("", 312, 117, 161, 21)
	$notiz = GUICtrlCreateInput("", 496, 117, 297, 21)
	$label1 = GUICtrlCreateLabel("Datum:", 8, 8, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label2 = GUICtrlCreateLabel("Zeit:", 160, 8, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label4 = GUICtrlCreateLabel("Rufzeichen:", 8, 53, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label5 = GUICtrlCreateLabel("Skip:", 160, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label6 = GUICtrlCreateLabel("RX:", 312, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label7 = GUICtrlCreateLabel("TX:", 400, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label8 = GUICtrlCreateLabel("Frequenz:", 496, 51, 80, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label9 = GUICtrlCreateLabel("Mode:", 672, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label10 = GUICtrlCreateLabel("Operatorname:", 8, 99, 110, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label11 = GUICtrlCreateLabel("Locator:", 160, 99, 80, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label12 = GUICtrlCreateLabel("QTH:", 312, 99, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label13 = GUICtrlCreateLabel("Notiz:", 496, 99, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label14 = GUICtrlCreateLabel("www.GFMsoft.de - Ferdinand Marx - www.13OT4288.com", 10, 628, 500)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
Else
	$QSO = GUICreate("Elog - " & $version, 1025, 645, -1, -1)
	GUISetIcon("radio.ico", 0, $QSO)
	GUISetBkColor(0x757575, $QSO)
	$List1 = GUICtrlCreateListView("ID | Date | Time | Callsign | Skip | RX | TX | FRQ | Mode | Name | Locator | QTH | Note", 8, 152, 1009, 474)
	$Button1 = GUICtrlCreateButton("Save", 818, 24, 110, 49)
	GUICtrlSetFont(-1, 11, 400, 0, "Arial")
	$Button2 = GUICtrlCreateButton("Delete", 818, 88, 110, 49)
	GUICtrlSetFont(-1, 11, 400, 0, "Arial")
	$Button3 = GUICtrlCreateButton("Options", 940 + 11, 60 + 28, 50, 23)
	$Button4 = GUICtrlCreateButton("Export", 940 + 11, 95 + 19, 50, 23)
	$Button5 = GUICtrlCreateButton("Search", 940 + 11, 50, 50, 23)
	$Datum = GUICtrlCreateInput("", 8, 26, 129, 21)
	$Zeit = GUICtrlCreateInput("", 160, 26, 129, 21)
	$Rufzeichen = GUICtrlCreateInput("", 8, 71, 129, 21)
	$skip = GUICtrlCreateInput("", 160, 71, 129, 21)
	$RX = GUICtrlCreateInput("", 312, 71, 73, 21)
	$TX = GUICtrlCreateInput("", 400, 71, 73, 21)
	$FREQ = GUICtrlCreateInput("", 496, 71, 153, 21)
	$mode = GUICtrlCreateCombo("Mode", 672, 71, 121, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "CW|AM|FM|USB|LSB")
	$Name = GUICtrlCreateInput("", 8, 117, 129, 21)
	$locator = GUICtrlCreateInput("", 160, 117, 129, 21)
	$QTH = GUICtrlCreateInput("", 312, 117, 161, 21)
	$notiz = GUICtrlCreateInput("", 496, 117, 297, 21)
	$label1 = GUICtrlCreateLabel("Date:", 8, 8, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label2 = GUICtrlCreateLabel("Time:", 160, 8, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label4 = GUICtrlCreateLabel("Callsign:", 8, 53, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label5 = GUICtrlCreateLabel("Skip:", 160, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label6 = GUICtrlCreateLabel("RX:", 312, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label7 = GUICtrlCreateLabel("TX:", 400, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label8 = GUICtrlCreateLabel("Freq:", 496, 51, 80, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label9 = GUICtrlCreateLabel("Mode:", 672, 51, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label10 = GUICtrlCreateLabel("Operatorname:", 8, 99, 110, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label11 = GUICtrlCreateLabel("Locator:", 160, 99, 80, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label12 = GUICtrlCreateLabel("QTH:", 312, 99, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label13 = GUICtrlCreateLabel("Note:", 496, 99, 50, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$label14 = GUICtrlCreateLabel("www.GFMsoft.de - Ferdinand Marx - www.13OT4288.com", 10, 628, 500)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
EndIf
#EndRegion ### END Koda GUI section ###


;EditorGUI
#Region ### START Koda GUI section for EditorGUI 	###
if $global_language = "DE" Then
	$editform = GUICreate("Elog - Editor", 908 - 10, 437 - 60, -1, -1)
	GUISetIcon("radio.ico", 0, $editform)
	$edit_pic = GUICtrlCreatePic(@ScriptDir & "\bg2.jpg", 0, -50, 908, 437)
	GUICtrlSetState($edit_pic, $GUI_DISABLE)
	$edit_button1 = GUICtrlCreateButton("Speichern", 758 - 110, 300, 100, 40)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_button2 = GUICtrlCreateButton("Zurück", 758, 300, 100, 40)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_datum = GUICtrlCreateInput("", 40, 40, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_zeit = GUICtrlCreateInput("", 208, 40, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Rufzeichen = GUICtrlCreateInput("", 40, 120, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Skip = GUICtrlCreateInput("", 208, 120, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_RX = GUICtrlCreateInput("", 376, 120, 65, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_TX = GUICtrlCreateInput("", 456, 120, 65, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Frequenz = GUICtrlCreateInput("", 544, 120, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Operatorname = GUICtrlCreateInput("", 40, 192, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Locator = GUICtrlCreateInput("", 208, 192, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_label13 = GUICtrlCreateLabel("Distance: ", 208, 168 + 50, 150, 24)
	GUICtrlSetFont(-1, 11, 400, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_QTH = GUICtrlCreateInput("", 376, 192, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Notiz = GUICtrlCreateInput("", 544, 192, 313, 27)
	GUICtrlSetFont(-1, 11, 400, 0, "Arial")
	$edit_Combo1 = GUICtrlCreateCombo("", 704, 120, 153, 35, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "AM|FM|USB|LSB|CW")
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_label1 = GUICtrlCreateLabel("Datum", 40, 16, 52, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label2 = GUICtrlCreateLabel("Zeit", 208, 16, 31, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label3 = GUICtrlCreateLabel("Rufzeichen", 40, 96, 100, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label4 = GUICtrlCreateLabel("Skip", 208, 96, 39, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label5 = GUICtrlCreateLabel("RX", 376, 96, 27, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label6 = GUICtrlCreateLabel("TX", 456, 96, 24, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label7 = GUICtrlCreateLabel("Frequenz", 544, 96, 76, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label9 = GUICtrlCreateLabel("Operatorname", 40, 168, 125, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label10 = GUICtrlCreateLabel("Locator", 208, 168, 62, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label11 = GUICtrlCreateLabel("QTH", 376, 168, 41, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label12 = GUICtrlCreateLabel("Notiz", 544, 168, 44, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label8 = GUICtrlCreateLabel("Mode", 704, 96, 48, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
Else
	$editform = GUICreate("Elog - Editor", 908 - 10, 437 - 60, -1, -1)
	GUISetIcon("radio.ico", 0, $editform)
	$edit_pic = GUICtrlCreatePic(@ScriptDir & "\bg2.jpg", 0, -50, 908, 437)
	GUICtrlSetState($edit_pic, $GUI_DISABLE)
	$edit_button1 = GUICtrlCreateButton("Save", 758 - 110, 300, 100, 40)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_button2 = GUICtrlCreateButton("Back", 758, 300, 100, 40)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_datum = GUICtrlCreateInput("", 40, 40, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_zeit = GUICtrlCreateInput("", 208, 40, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Rufzeichen = GUICtrlCreateInput("", 40, 120, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Skip = GUICtrlCreateInput("", 208, 120, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_RX = GUICtrlCreateInput("", 376, 120, 65, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_TX = GUICtrlCreateInput("", 456, 120, 65, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Frequenz = GUICtrlCreateInput("", 544, 120, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Operatorname = GUICtrlCreateInput("", 40, 192, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Locator = GUICtrlCreateInput("", 208, 192, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_label13 = GUICtrlCreateLabel("Distance: ", 208, 168 + 50, 150, 24)
	GUICtrlSetFont(-1, 11, 400, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_QTH = GUICtrlCreateInput("", 376, 192, 145, 27)
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_Notiz = GUICtrlCreateInput("", 544, 192, 313, 27)
	GUICtrlSetFont(-1, 11, 400, 0, "Arial")
	$edit_Combo1 = GUICtrlCreateCombo("", 704, 120, 153, 35, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "AM|FM|USB|LSB|CW")
	GUICtrlSetFont(-1, 13, 400, 0, "Arial")
	$edit_label1 = GUICtrlCreateLabel("Date", 40, 16, 52, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label2 = GUICtrlCreateLabel("Time", 208, 16, 50, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label3 = GUICtrlCreateLabel("Callsign", 40, 96, 100, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label4 = GUICtrlCreateLabel("Skip", 208, 96, 39, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label5 = GUICtrlCreateLabel("RX", 376, 96, 27, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label6 = GUICtrlCreateLabel("TX", 456, 96, 24, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label7 = GUICtrlCreateLabel("Freq", 544, 96, 76, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label9 = GUICtrlCreateLabel("Operatorname", 40, 168, 125, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label10 = GUICtrlCreateLabel("Locator", 208, 168, 62, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label11 = GUICtrlCreateLabel("QTH", 376, 168, 41, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label12 = GUICtrlCreateLabel("Note", 544, 168, 44, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	$edit_label8 = GUICtrlCreateLabel("Mode", 704, 96, 48, 24)
	GUICtrlSetFont(-1, 13, 700, 0, "MS Sans Serif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
EndIf


GUISetState(@SW_HIDE, $editform)
#EndRegion ### END Koda GUI section ###


;SearchGUI
#Region ### START Koda GUI section for SearchGUI 	###
if $global_language = "DE" Then
	$searchform = GUICreate("Elog - Suchen...", 310, 125, -1, -1)
	GUISetIcon("radio.ico", 0, $searchform)
	GUISetBkColor(0x757575, $searchform)
	$searchform_Input1 = GUICtrlCreateInput("", 24, 48 - 7, 249, 21)
	$searchform_Label1 = GUICtrlCreateLabel("Suche:", 24, 24 - 7, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$searchform_Label1 = GUICtrlCreateLabel("Bitte nur Rufzeichen eingeben.", 24, 68 - 7, 130, 17)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	$searchform_Button1 = GUICtrlCreateButton("Suchen", 24, 88 - 7, 113, 33)
	$searchform_Button2 = GUICtrlCreateButton("Abbrechen", 160, 88 - 7, 113, 33)
Else
	$searchform = GUICreate("Elog - Search...", 310, 125, -1, -1)
	GUISetIcon("radio.ico", 0, $searchform)
	GUISetBkColor(0x757575, $searchform)
	$searchform_Input1 = GUICtrlCreateInput("", 24, 48 - 7, 249, 21)
	$searchform_Label1 = GUICtrlCreateLabel("Search:", 24, 24 - 7, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$searchform_Label1 = GUICtrlCreateLabel("Only callsigns!", 24, 68 - 7, 130, 17)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	$searchform_Button1 = GUICtrlCreateButton("Search", 24, 88 - 7, 113, 33)
	$searchform_Button2 = GUICtrlCreateButton("Abort", 160, 88 - 7, 113, 33)
EndIf
GUISetState(@SW_HIDE)
#EndRegion ### END Koda GUI section ###


;SettingsGUI
#Region ### START Koda GUI section for SettingsGUI 	###
if $global_language = "DE" Then
	$settingsform = GUICreate("Elog - Settings", 310, 225, -1, -1)
	GUISetIcon("radio.ico", 0, $settingsform)
	GUISetBkColor(0x757575, $settingsform)
	$settingsform_Input1 = GUICtrlCreateInput("", 24, 48 - 7, 249, 21)
	$settingsform_Label1 = GUICtrlCreateLabel("Dein Locator:", 24, 24 - 7, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$settingsform_Label1 = GUICtrlCreateLabel("Bitte Locator mit 6 Zeichen", 24, 68 - 7, 130, 17)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	$settingsform_Button1 = GUICtrlCreateButton("Speichern", 24, 175, 113, 33)
	$settingsform_Button2 = GUICtrlCreateButton("Abbrechen", 160, 175 , 113, 33)
	$settingsform_Label2 = GUICtrlCreateLabel("Sprache:", 24, 85, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$settingsform_combo1 = GUICtrlCreateCombo("Language",24,110)
	GUICtrlSetData($settingsform_combo1,"_______|German|English")
Else
	$settingsform = GUICreate("Elog - Settings", 310, 225, -1, -1)
	GUISetIcon("radio.ico", 0, $settingsform)
	GUISetBkColor(0x757575, $settingsform)
	$settingsform_Input1 = GUICtrlCreateInput("", 24, 48 - 7, 249, 21)
	$settingsform_Label1 = GUICtrlCreateLabel("Your locator:", 24, 24 - 7, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$settingsform_Label1 = GUICtrlCreateLabel("Only 6 characters long!", 24, 68 - 7, 130, 17)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	$settingsform_Button1 = GUICtrlCreateButton("Save", 24, 175, 113, 33)
	$settingsform_Button2 = GUICtrlCreateButton("Abort", 160, 175 , 113, 33)
	$settingsform_Label2 = GUICtrlCreateLabel("Language:", 24, 85, 100, 17)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial")
	$settingsform_combo1 = GUICtrlCreateCombo("Language",24,110)
	GUICtrlSetData($settingsform_combo1,"_______|German|English")
EndIf


GUISetState(@SW_HIDE)
#EndRegion ### END Koda GUI section ###



;Program initialisation
init_load()

;Showgui after init
GUISetState(@SW_SHOW,$QSO)



;Mainloop
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			If WinActive($editform) = True Or WinActive($searchform) = True Or WinActive($settingsform) = True Then
				GUISetState(@SW_HIDE, $editform)
				GUISetState(@SW_HIDE, $searchform)
				GUISetState(@SW_HIDE, $settingsform)
				GUISetState(@SW_SHOW, $QSO)
			Else
				Exit
			EndIf

		;Save
		Case $Button1
			speichern()

		;Delete highlighted entry
		Case $Button2
			loeschen()

		;Optionen aufrufen
		Case $Button3
			GUICtrlSetData($settingsform_Input1, $ownlocator)
			GUISetState(@SW_HIDE, $QSO)
			GUISetState(@SW_SHOW, $settingsform)

		;Save on EDITFORM
		Case $edit_button1
			edit_save()

		;Back on Editform
		Case $edit_button2
			GUISetState(@SW_HIDE, $editform)
			GUISetState(@SW_SHOW, $QSO)

		;Export
		Case $Button4
			export()

		;Start searchform
		Case $Button5
			GUISetState(@SW_HIDE, $QSO)
			GUISetState(@SW_SHOW, $searchform)

		;Start search
		Case $searchform_Button1
			$searchtermfunc = GUICtrlRead($searchform_Input1)
			search($searchtermfunc)

		;Close Searchform
		Case $searchform_Button2
			GUISetState(@SW_HIDE, $searchform)
			GUISetState(@SW_SHOW, $QSO)

		;Save on Settingsform
		Case $settingsform_Button1

			if GUICtrlRead($settingsform_Input1) <> IniRead(@ScriptDir&"\settings.ini","Settings","locator","") Then
				If MsgBox(4, "Überschreiben? - Overwrite?", "Möchten Sie wirklich überschreiben?"&@CRLF&"Do you really want to overwrite the locator?") = 6 Then
					If StringLen(GUICtrlRead($settingsform_Input1)) = 6 And GUICtrlRead($settingsform_Input1) <> "      " Then
						IniWrite(@ScriptDir & "\settings.ini", "Settings", "ownlocator", GUICtrlRead($settingsform_Input1))
					Else
						If GUICtrlRead($settingsform_Input1) = "      " Then
							MsgBox(16, "Falsche Eingabe! - Wrong input!", "Sie sollten auch Daten eingeben..."&@CRLF&"You should enter some data!")
						Else
							MsgBox(16, "Falsche Eingabe! - Wrong input!", "Der Locator muss aus 6 Zeichen bestehen!"&@CRLF&"The locator must have 6 characters! Not more - not less!")
						EndIf
					EndIf
				Else
					GUICtrlSetData($settingsform_Input1, $ownlocator)
				EndIf
			EndIf

			if GUICtrlRead($settingsform_combo1) <> IniRead(@ScriptDir&"\settings.ini","Settings","Language","") Then
				If MsgBox(4, "Überschreiben?", "Möchten Sie wirklich eine neue Sprache einstellen?"&@CRLF&"Do you really want to set a new language?") = 6 Then
					if GUICtrlRead($settingsform_combo1) = "English" Then
						IniWrite(@ScriptDir&"\settings.ini","Settings","Language","EN")
					Else
						IniWrite(@ScriptDir&"\settings.ini","Settings","Language","DE")
					EndIf
				EndIf
			EndIf

			GUISetState(@SW_HIDE, $settingsform)
			GUISetState(@SW_SHOW, $QSO)

		;Abort on settingsform
		Case $settingsform_Button2
			GUISetState(@SW_HIDE, $settingsform)
			GUISetState(@SW_SHOW, $QSO)

	EndSwitch


	;Callsign inputbox monitoring
	;If a callsign is  given by user start realtime search in DB
	If _IsFocused($QSO, $Rufzeichen) And GUICtrlRead($Rufzeichen) <> $olddbsearchterm Then

		If GUICtrlRead($Rufzeichen) <> "" Then

			$olddbsearchterm = GUICtrlRead($Rufzeichen)
			$dbsearchterm = GUICtrlRead($Rufzeichen)
			_SQLite_Startup()
			$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")

			If @error = True Then
				MsgBox(16, "SQL-Error - realtime search!", "Code: " & @error & @CRLF & "Extended: " & @extended)
			EndIf

			_SQLite_Query($dbh, "select * from daten where rufzeichen like '" & $dbsearchterm & "'", $searchquery)

			While _SQLite_FetchData($searchquery, $dbsearchdata) = $SQLITE_OK
				GUICtrlSetData($skip, $dbsearchdata[4])
				GUICtrlSetData($Name, $dbsearchdata[9])
				GUICtrlSetData($locator, $dbsearchdata[10])
				GUICtrlSetData($QTH, $dbsearchdata[11])
			WEnd

			_SQLite_QueryFinalize($searchquery)
		EndIf

		_SQLite_Close($dbh)
		_SQLite_Shutdown()

	EndIf


	;Autocomplete DATE and TIME when focussed
	;####################################################################################
	If _IsFocused($QSO, $Datum) And $cleardate = 0 Then
		GUICtrlSetData($Datum, @MDAY & "." & @MON & "." & @YEAR)
		$cleardate = 1
	EndIf

	If _IsFocused($QSO, $Zeit) And $cleartime = 0 Then
		GUICtrlSetData($Zeit, @HOUR & ":" & @MIN)
		$cleartime = 1
	EndIf
	;####################################################################################


WEnd ;--> Mainlooop end




;Functions

;Program-initialisation
Func init()

	Local $dbcheck

	;Check if bgpic for editform existent - if not then install
	If FileExists(@ScriptDir & "\bg2.jpg") = False Then
		FileInstall("bg2.jpg", "bg2.jpg")
	EndIf

	;Check if radio.ico existent - if not then install
	If FileExists(@ScriptDir & "\radio.ico") = False Then
		FileInstall("radio.ico", "radio.ico")
	EndIf

	;Check if sqlite.dll existent - if not then install
	If FileExists(@ScriptDir & "\sqlite3.dll") = False Then
		FileInstall("sqlite3.dll", "sqlite3.dll")
	EndIf

	;If sqlite3.dll still not in @scriptdir then exit
	;Prompt critical error
	If FileExists(@ScriptDir & "\sqlite3.dll") = False Then
		MsgBox(64, "Fehler - SQLITe3.dll", "sqlite3.dll liegt nicht im Programmverzeichnis! - Bitte runterladen und ins Programmverzeichnis legen!")
		MsgBox(64, "Error - SQLITe3.dll", "sqlite3.dll cant be found in >"&@ScriptDir&"< - Please download the sqlite3.dll manually and place it there!")
		Exit
	EndIf

	;Load SQL-Engine
	$sql_status = _SQLite_Startup("sqlite3.dll", 1)
	If @error = True Then
		MsgBox(16,"SQL-Engine ERROR","Error while loading the SQL-Engine!"&@CRLF&"This is a critical error!")
		Exit
	EndIf

	;Check database path - create pathstructure if not existent
	If FileExists(@ScriptDir & "\daten") = False Then
		DirCreate(@ScriptDir & "\daten")
	EndIf

	If FileExists(@ScriptDir & "\Daten\Datenbank.db") = False Then

		$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
		If @error = True Then
			MsgBox(16, "Fehler - SQLDatabase", "Code: " & @error & @CRLF & "Extended: " & @extended)
			Exit
		EndIf

		$dbcheck = _SQLite_Exec($dbh, "CREATE Table Daten (ID,datum,zeit,rufzeichen,skip,rx,tx,frequenz,mode,operatorname,locator,qth,notiz,delmark);")
		If $dbcheck = $SQLITE_OK Then
			;Hier test wert ausgabe möglich
			;Here is some room for some foo - checks - or more foo
		Else
			MsgBox(16, "Fehler - SQL", "Table Daten konnten nicht geschrieben werden!" & @CRLF & "Fehlermeldung: " & @error)
			MsgBox(16, "Error- SQL", "Database is unwriteable - This error is critical!" & @CRLF & "Error: " & @error)
			Exit
		EndIf
	EndIf

	_SQLite_Close($dbh)
	_SQLite_Shutdown()


	;Check for own locator in settings.ini - if not existent init everything
	If FileExists(@ScriptDir & "\settings.ini") = False Then
		IniWrite(@ScriptDir & "\settings.ini", "Settings", "ownlocator", "")
		Sleep(500)
		$ownlocator = InputBox("Enter your locator", "Please enter your locator (6 characters)!", "")

		If StringLen($ownlocator) <> 6 Or $ownlocator = "      " Then
			MsgBox(16, "Your entry was not correct!", "Your Locator is set to 0 - distances can't be calculated!" & @CRLF & "You can change your locator under settings.")
		Else
			IniWrite(@ScriptDir & "\settings.ini", "Settings", "ownlocator", $ownlocator)
		EndIf

	Else
		;Load ownlocator from settings.ini for later calculations
		$ownlocator = IniRead(@ScriptDir & "\settings.ini", "Settings", "ownlocator", "")
	EndIf

	;check if os is in en language - if not then set language to german
	if IniRead(@ScriptDir&"\settings.ini","Settings","Language","") = "" Then
		if @OSLang = 0409 Then
			IniWrite(@ScriptDir&"\settings.ini","Settings","Language","EN")
		Else
			IniWrite(@ScriptDir&"\settings.ini","Settings","Language","DE")
		EndIf
	Else
		if IniRead(@ScriptDir&"\settings.ini","Settings","Language","") = "EN" Then
			$global_language="EN"
			GUICtrlSetData($settingsform_combo1,"English")
			ConsoleWrite("LAN SET TO EN"&@CRLF)
		Else
			$global_language="DE"
			GUICtrlSetData($settingsform_combo1,"AAA","LOLOLOL")

			ConsoleWrite("LAN SET TO DE"&@CRLF)
		EndIf
	EndIf


EndFunc   ;==>init

;This function loads all data from the database into the listbox - CALL THIS FUNC ONLY ONCE FROM INIT
Func init_load()

	;Declare vars
	Local $query, $dbdata, $i, $temparray

	;set expected and needed values
	$i = 1
	$Index_listload = 0

	;Delete all items in Listview for cleaning purposes
	_GUICtrlListView_DeleteAllItems($List1)

	;Load sqlengine und start reading the database - also putting the incoming data into the Listview
	_SQLite_Startup()

	$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
	If @error = True Then
		MsgBox(16, "Fehler - SQLDatenbank", "Fehlerocode: " & @error & @CRLF & "Extended: " & @extended)
		Return 0
	EndIf

	_SQLite_Query($dbh, "select * from Daten", $query)

	While _SQLite_FetchData($query, $dbdata) = $SQLITE_OK


		;Upcoming code was for debugging - leave it - maybe we need it when we develop additions

		;~ _ArrayDisplay($dbdata)
		;~ (ID,Datum,Zeit,rufzeichen,skip,rx,tx,frequenz,mode,operatorname,locator,qth,notiz,delmark);")
				; So kommen die Daten zurück
		;~ 	Row|Col 0
		;~ 	[0]|ID
		;~ 	[1]|DATUM
		;~ 	[2]|ZEIT
		;~ 	[3]|RUFZEICHEN
		;~ 	[4]|SKIP
		;~ 	[5]|RX
		;~ 	[6]|TX
		;~ 	[7]|FREQUENZ
		;~ 	[8]|MODE
		;~ 	[9]|OPERATORNAME
		;~ 	[10]|LOCATOR
		;~ 	[11]|QTH
		;~ 	[12]|NOTIZ
		;~ 	[13]|delmark


		;Put data from database into listview
		If $dbdata[13] = "False" Then

			_GUICtrlListView_AddItem($List1, $dbdata[0], $Index_listload)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[1], 1, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[2], 2, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[3], 3, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[4], 4, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[5], 5, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[6], 6, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[7], 7, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[8], 8, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[9], 9, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[10], 10, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[11], 11, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[12], 12, 1)

			;Count the internal counter 1 up! - Dont you dare to touch my while loop!
			$Index_listload = $Index_listload + 1
		EndIf

	WEnd

	;Finishing the SQ query and closing the database - closing the SQLITe.dll afterwards
	_SQLite_QueryFinalize($query)
	_SQLite_Close($dbh)
	_SQLite_Shutdown()

	;Refreshing the width of the listview
	;if width of column 1,4,5,9,10,11,12 under 80px its sets it to 80px

	_GUICtrlListView_SetColumnWidth($List1, 1, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 4, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 5, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 9, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 10, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 11, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 12, $LVSCW_AUTOSIZE)


	if 	_GUICtrlListView_GetColumnWidth($List1,1) < 80 Then
		_GUICtrlListView_SetColumnWidth($List1, 1, 80)
	EndIf
	if 	_GUICtrlListView_GetColumnWidth($List1,4) < 80 Then
		_GUICtrlListView_SetColumnWidth($List1, 4, 80)
	EndIf
	if 	_GUICtrlListView_GetColumnWidth($List1,5) < 80 Then
		_GUICtrlListView_SetColumnWidth($List1, 5, 50)
	EndIf
	if 	_GUICtrlListView_GetColumnWidth($List1,9) < 80 Then
		_GUICtrlListView_SetColumnWidth($List1, 9, 80)
	EndIf
	if 	_GUICtrlListView_GetColumnWidth($List1,10) < 80 Then
		_GUICtrlListView_SetColumnWidth($List1, 10, 80)
	EndIf
	if 	_GUICtrlListView_GetColumnWidth($List1,11) < 80 Then
		_GUICtrlListView_SetColumnWidth($List1, 11, 80)
	EndIf
	if 	_GUICtrlListView_GetColumnWidth($List1,12) < 80 Then
		_GUICtrlListView_SetColumnWidth($List1, 12, 180)
	EndIf


EndFunc   ;==>init_load

;This function is for testing only.
;Delete this function when testing is finished
Func testeintrag()

	Local $dbcheck

	_SQLite_Startup()
	$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
	If @error = True Then
		MsgBox(16, "Fehler - SQLDatenbank", "Fehlerocode: " & @error & @CRLF & "Extended: " & @extended)
		Return 0
	EndIf

	;Variablen für Testeintrag füllen
	$ID = 1
	$Datum = "04.02.2021"
	$Zeit = "12:15"
	$Rufzeichen = "13OT4288"
	$skip = "UKO"
	$RX = "5/5"
	$TX = "5/9"
	$FREQ = "27.505"
	$mode = "USB"
	$Name = "jean paul"
	$locator = "JOPL5"
	$QTH = "Berlin"
	$notiz = "Sehr cooler Testkontakt mit Jean Paul. Er hat auch alles verstanden. Erster Kontakt mit der Außenwelt seit Jahren!"



	$dbcheck = _SQLite_Exec($dbh, "insert into Daten(ID,Datum,Zeit,rufzeichen,skip,rx,tx,frequenz,mode,operatorname,locator,qth,notiz,delmark) values ('" & $ID & "','" & $Datum & "','" & $Zeit & "','" & $Rufzeichen & "','" & $skip & "','" & $RX & "','" & $TX & "','" & $FREQ & "','" & $mode & "','" & $Name & "','" & $locator & "','" & $QTH & "','" & $notiz & "','False');")
;~ 	(ID,Datum,Zeit,rufzeichen,skip,rx,tx,frequenz,mode,operatorname,locator,qth,notiz,delmark)

;~ ('" & $lastid & "','" & GUICtrlRead($Form5_Date1) & "','" & GUICtrlRead($Form5_Combo1) & "','" & GUICtrlRead($Form5_Input1) & "','" & GUICtrlRead($Form5_Input2) & "','" & GUICtrlRead($Form5_Input3) & "','" & GUICtrlRead($Form5_Input4) & "','" & GUICtrlRead($Form5_Edit1) & "','" & $gender & "','" & GUICtrlRead($Form5_Input5) & "','False');")


EndFunc   ;==>testeintrag

;This function saves a new entry in database
Func speichern()

	;declare vars
	Local $query, $dbdata, $fehlergrenze, $dbcheck
	Local $id_data, $Datum_data, $zeit_data, $Rufzeichen_data, $skip_data, $rx_data, $tx_data
	Local $FREQ_data, $Mode_data, $Name_data, $Locator_data, $QTH_data, $Notiz_data

	;set values
	$fehlergrenze = 0
	$query = ""
	$dbdata = ""

	;Some testing and preventing erros
	if $global_language = "DE" Then
		If GUICtrlRead($Datum) = "" Then
			MsgBox(64, "Datum eingeben", "Bitte geben Sie ein Datum ein.")
			Return 0
		EndIf

		If GUICtrlRead($Zeit) = "" Then
			MsgBox(64, "Zeit eingeben", "Bitte geben Sie eine Uhrzeit an.")
			Return 0
		EndIf

		If GUICtrlRead($Rufzeichen) = "" Then
			MsgBox(64, "Rufzeichen angeben", "Bitte geben Sie das Rufzeichen Ihres Gesprächspartners an.")
			Return 0
		EndIf

		If GUICtrlRead($FREQ) = "" Then
			MsgBox(64, "Frequenz angeben", "Bitte geben Sie eine Frequenz an.")
			Return 0
		EndIf

		If GUICtrlRead($mode) = "" Or GUICtrlRead($mode) = "Mode" Then
			MsgBox(64, "Modus angeben", "Bitte geben Sie einen Modus (AM/FM/SSB) an.")
			ConsoleWrite("Modus: " & GUICtrlRead($mode) & @CRLF)
			Return 0
		EndIf
	Else
		If GUICtrlRead($Datum) = "" Then
			MsgBox(64, "Please set a date", "Please type in a correct date.")
			Return 0
		EndIf

		If GUICtrlRead($Zeit) = "" Then
			MsgBox(64, "Please set a time", "Please type in a correct time.")
			Return 0
		EndIf

		If GUICtrlRead($Rufzeichen) = "" Then
			MsgBox(64, "Please set a callsign", "Please type in a correct callsign of your QSO-Partner.")
			Return 0
		EndIf

		If GUICtrlRead($FREQ) = "" Then
			MsgBox(64, "Please set a Frequency", "Please type in a correct frequency.")
			Return 0
		EndIf

		If GUICtrlRead($mode) = "" Or GUICtrlRead($mode) = "Mode" Then
			MsgBox(64, "Set mode!", "Please set a correct mode (AM/FM/SSB).")
			ConsoleWrite("Modus: " & GUICtrlRead($mode) & @CRLF)
			Return 0
		EndIf

	EndIf





	;GET LAST ID
	_SQLite_Startup()
	$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
	If @error = True Then
		MsgBox(16, "Error - GET LAST ID!", "Code: " & @error & @CRLF & "Extended: " & @extended)
		Return
	EndIf


	_SQLite_Query($dbh, "select count(*) from daten", $query)
	While _SQLite_FetchData($query, $dbdata) = $SQLITE_OK
		$lastid = $dbdata[0]
	WEnd


	_SQLite_QueryFinalize($query)

	;Gather data
	;Write data into database
	$id_data = $lastid + 1
	$Datum_data = GUICtrlRead($Datum)
	$zeit_data = GUICtrlRead($Zeit)
	$Rufzeichen_data = GUICtrlRead($Rufzeichen)
	$skip_data = GUICtrlRead($skip)
	$rx_data = GUICtrlRead($RX)
	$tx_data = GUICtrlRead($TX)
	$FREQ_data = GUICtrlRead($FREQ)
	$Mode_data = GUICtrlRead($mode)
	$Name_data = GUICtrlRead($Name)
	$Locator_data = GUICtrlRead($locator)
	$QTH_data = GUICtrlRead($QTH)
	$Notiz_data = GUICtrlRead($notiz)


	$dbcheck = _SQLite_Exec($dbh, "insert into Daten(ID,Datum,Zeit,rufzeichen,skip,rx,tx,frequenz,mode,operatorname,locator,qth,notiz,delmark) values ('" & $id_data & "','" & $Datum_data & "','" & $zeit_data & "','" & $Rufzeichen_data & "','" & $skip_data & "','" & $rx_data & "','" & $tx_data & "','" & $FREQ_data & "','" & $Mode_data & "','" & $Name_data & "','" & $Locator_data & "','" & $QTH_data & "','" & $Notiz_data & "','False');")


	If $dbcheck = $SQLITE_OK Then
		if $global_language = "DE" Then
			MsgBox(0, "Eintrag erfolgreich!", "Neues QSO wurde angelegt!")
		Else
			MsgBox(0, "New entry is saved!", "New QSO is logged!")
		EndIf
	Else
		if $global_language = "DE" Then
			MsgBox(64, "Fehler!", "Neues QSO konnte nicht angelegt werden!")
			MsgBox(16, "Fehler - SQL", "Daten konnten nicht geschrieben werden!" & @CRLF & "Error: " & @error)
		Else
			MsgBox(64, "Error!", "New QSO cant be logged!")
			MsgBox(16, "Error! - SQL", "Data cant be written into database!" & @CRLF & "Error: " & @error)
		EndIf
	EndIf

	_SQLite_Close($dbh)
	_SQLite_Shutdown()

	;reload the Listview
	reload_listview()

	;clear inputboxes
	GUICtrlSetData($Datum, "")
	GUICtrlSetData($Zeit, "")
	GUICtrlSetData($Rufzeichen, "")
	GUICtrlSetData($skip, "")
	GUICtrlSetData($RX, "")
	GUICtrlSetData($TX, "")
	GUICtrlSetData($FREQ, "")
	GUICtrlSetData($Name, "")
	GUICtrlSetData($locator, "")
	GUICtrlSetData($QTH, "")
	GUICtrlSetData($notiz, "")

	$cleardate = 0
	$cleartime = 0
EndFunc   ;==>speichern

;This function loads all data into the Listview ANYTIME!
;This function can be called any time
Func reload_listview()

	;Declare vars
	Local $query, $dbdata

	;set values
	$Index_listload = 0

	;Clear Listview
	_GUICtrlListView_DeleteAllItems($List1)

	;Startup the SQLITE and read the database
	_SQLite_Startup()

	$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
	If @error = True Then
		MsgBox(16, "Error - SQLDatabase", "Code: " & @error & @CRLF & "Extended: " & @extended)
		Return 0
	EndIf

	_SQLite_Query($dbh, "select * from Daten", $query)

	While _SQLite_FetchData($query, $dbdata) = $SQLITE_OK

		;Hier Daten in die Listbox werfen, wenn Löschmarker = "False"
		;Fill the data into the listview - skip deleted entrys
		If $dbdata[13] = "False" Then

			_GUICtrlListView_AddItem($List1, $dbdata[0], $Index_listload)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[1], 1, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[2], 2, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[3], 3, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[4], 4, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[5], 5, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[6], 6, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[7], 7, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[8], 8, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[9], 9, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[10], 10, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[11], 11, 1)
			_GUICtrlListView_AddSubItem($List1, $Index_listload, $dbdata[12], 12, 1)

			;set inernal counter +1
			$Index_listload = $Index_listload + 1
		EndIf

	WEnd

	;Finishing dbstuff und closing the sql.dll
	_SQLite_QueryFinalize($query)
	_SQLite_Close($dbh)
	_SQLite_Shutdown()

	;Refresh the width of the listview
	_GUICtrlListView_SetColumnWidth($List1, 4, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 9, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 11, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 12, $LVSCW_AUTOSIZE)

EndFunc   ;==>reload_listview

;This function check the current focus of the user
Func _IsFocused($hWnd, $nCID)
	Return ControlGetHandle($hWnd, '', $nCID) = ControlGetHandle($hWnd, '', ControlGetFocus($hWnd))
EndFunc   ;==>_IsFocused

;Diese Funktion schaltet einen Eintrag auf nicht SICHTBAR - Setzt Loeschmarker
;This function sets a entry to invisible - sets deletemarker
;Name of this function is loeschen - its german for delete
Func loeschen()

	;Declare vars
	Local $delvalue, $delarray, $del_id, $dbcheck

	$delvalue = _GUICtrlListView_GetItemTextString($List1, _GUICtrlListView_GetSelectionMark($List1))
	$delarray = StringSplit($delvalue, "|")
	$del_id = $delarray[1]
	If $delvalue = 0 Then
		Return 0
	EndIf

	;Asking the user for permission

	if $global_language="DE" Then
		If MsgBox(4, "Eintrag löschen?", "Möchten Sie den ausgewählten Eintrag wirklich löschen?") = 6 Then

			_SQLite_Startup()
			$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
			If @error = True Then
				MsgBox(16, "Fehler - SQLDatenbank", "Fehlerocode: " & @error & @CRLF & "Extended: " & @extended)
			EndIf
			$dbcheck = _SQLite_Exec($dbh, "update Daten set delmark='True' where ID='" & $del_id & "';")

			;Check for erros
			If @error = True Then
				; Here are some errorcode meanings
				;~ -1 - SQLite reported an error (Check return value)
				;~ 1 - Error calling SQLite API 'sqlite3_exec'
				;~ 2 - Call prevented by SafeMode
				;~ 3 - Error Processing Callback from within _SQLite_GetTable2d()
				;~ 4 - Error while converting SQL statement to UTF-8
				MsgBox(16, "Fehler beim Löschen!", "Fehlercode: " & @error & @CRLF & "-1 - SQLite reported an error (Check return value)" & @CRLF & "1 - Error calling SQLite API 'sqlite3_exec'" & @CRLF & "2 - Call prevented by SafeMode" & @CRLF & "3 - Error Processing Callback from within _SQLite_GetTable2d()" & @CRLF & "4 - Error while converting SQL statement to UTF-8")
			Else
				MsgBox(64, "Eintrag löschen", "Eintrag wurde gelöscht!")
			EndIf

			;close sqlite
			_SQLite_Close($dbh)
			_SQLite_Shutdown()
		Else
			MsgBox(64, "Eintrag nicht löschen", "Eintrag wurde NICHT gelöscht!")
			Return
		EndIf
	Else
		If MsgBox(4, "Delete entry?", "Do you really want to delete tgis entry?") = 6 Then

			_SQLite_Startup()
			$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
			If @error = True Then
				MsgBox(16, "Error - SQLDatabase", "Code: " & @error & @CRLF & "Extended: " & @extended)
			EndIf
			$dbcheck = _SQLite_Exec($dbh, "update Daten set delmark='True' where ID='" & $del_id & "';")

			;Check for erros
			If @error = True Then
				; Here are some errorcode meanings
				;~ -1 - SQLite reported an error (Check return value)
				;~ 1 - Error calling SQLite API 'sqlite3_exec'
				;~ 2 - Call prevented by SafeMode
				;~ 3 - Error Processing Callback from within _SQLite_GetTable2d()
				;~ 4 - Error while converting SQL statement to UTF-8
				MsgBox(16, "Error while deleting!", "Code: " & @error & @CRLF & "-1 - SQLite reported an error (Check return value)" & @CRLF & "1 - Error calling SQLite API 'sqlite3_exec'" & @CRLF & "2 - Call prevented by SafeMode" & @CRLF & "3 - Error Processing Callback from within _SQLite_GetTable2d()" & @CRLF & "4 - Error while converting SQL statement to UTF-8")
			Else
				MsgBox(64, "Deleting", "Entry was deleted!")
			EndIf

			;close sqlite
			_SQLite_Close($dbh)
			_SQLite_Shutdown()
		Else
			MsgBox(64, "Data wont be deleted!", "Entry was NOT deleted!")
			Return
		EndIf

	EndIf


	;reload listview
	reload_listview()


EndFunc   ;==>loeschen

;Diese Funktion prüft auf einen Doppelklick - Wenn Doppelklick erkannt wird, dann wird der Datenbankaufruf ausgelöst
;This function checks for doubleclick
;If a doubleclick occurred then start the editform with choosen entry
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $String
	Local $stringarray
	$hWndListView = $List1
	If Not IsHWnd($List1) Then $hWndListView = GUICtrlGetHandle($List1)
	$tNMHDR = DllStructCreate("hwnd hWndFrom;uint_ptr IDFrom;INT Code", $lParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	If $hWndFrom = $hWndListView Then
		If $iCode = -3 Then
			$String = _GUICtrlListView_GetItemTextString($hWndListView, _GUICtrlListView_GetSelectionMark($hWndListView))
			$stringarray = StringSplit($String, "|")
			$editcall = $stringarray[1]
			$lastid = $editcall
			_exectute_editcall($editcall)
		EndIf
	EndIf
EndFunc   ;==>WM_NOTIFY

;Diese Funktion erhhält die ID vom Doppelklickevent und mach einen Datenbankaufruf und trägt die Daten in das EDITfenstern ein
;This function gets the id from the choosen entry when a doubleclick event is noticed. it gets the data from the database and fills the editform
Func _exectute_editcall($editcall)

	;check if given data is corrupt or empty
	If $editcall = "" Or $editcall = 0 Then
		ConsoleWrite("Keine Uebergabevar - no EDIT!" & @CRLF)
		Return 0
	EndIf

	;declare vars and arrays
	Local $query2, $dbdata2, $dbh2, $dbdata2_check[13]

	;start sqlite
	_SQLite_Startup()

	;Hide the mainform and show the editform
	GUISetState(@SW_HIDE, $QSO)
	GUISetState(@SW_SHOW, $editform)

	;Making sure that the editform is in displaycenter
	WinMove($editform, "", (@DesktopWidth - 898) / 2, (@DesktopHeight - 377) / 2)

	$dbh2 = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
	If @error = True Then
		MsgBox(16, "Error - SQLDatabase", "Code: " & @error & @CRLF & "Extended: " & @extended)
		_SQLite_Close($dbh2)
		_SQLite_Shutdown()
		Return 0
	EndIf

	_SQLite_Query($dbh2, "select * from Daten where ID='" & $editcall & "'", $query2)
	While _SQLite_FetchData($query2, $dbdata2) = $SQLITE_OK

		GUICtrlSetData($edit_datum, $dbdata2[1])
		GUICtrlSetData($edit_zeit, $dbdata2[2])
		GUICtrlSetData($edit_Rufzeichen, $dbdata2[3])
		GUICtrlSetData($edit_Skip, $dbdata2[4])
		GUICtrlSetData($edit_RX, $dbdata2[5])
		GUICtrlSetData($edit_TX, $dbdata2[6])
		GUICtrlSetData($edit_Frequenz, $dbdata2[7])
		GUICtrlSetData($edit_Combo1, $dbdata2[8])
		GUICtrlSetData($edit_Operatorname, $dbdata2[9])
		GUICtrlSetData($edit_Locator, $dbdata2[10])
		GUICtrlSetData($edit_QTH, $dbdata2[11])
		GUICtrlSetData($edit_Notiz, $dbdata2[12])

		;Putting the data into a comparison array to check if the user has changed any data

		$dbdata2_check[1] = $dbdata2[1]
		$dbdata2_check[2] = $dbdata2[2]
		$dbdata2_check[3] = $dbdata2[3]
		$dbdata2_check[4] = $dbdata2[4]
		$dbdata2_check[5] = $dbdata2[5]
		$dbdata2_check[6] = $dbdata2[6]
		$dbdata2_check[7] = $dbdata2[7]
		$dbdata2_check[8] = $dbdata2[8]
		$dbdata2_check[9] = $dbdata2[9]
		$dbdata2_check[10] = $dbdata2[10]
		$dbdata2_check[11] = $dbdata2[11]
		$dbdata2_check[12] = $dbdata2[12]

	WEnd

	;closing any databasequery or sqlite calls
	_SQLite_QueryFinalize($query2)
	_SQLite_Close($dbh2)
	_SQLite_Shutdown()


	;Calculate and show distance to QSO-Partner
	GUICtrlSetData($edit_label13, "Distance: " & calcdistance(GUICtrlRead($edit_Locator)) & " km")

EndFunc   ;==>_exectute_editcall

;Funktion zum Verändern eines Eintrags in der Datenbank
;This function changes overwrites a databaseentry - this is called by clickling the save-button on the editform
Func edit_save()

	if $global_language="DE" Then
		;Making sure that the user really wants to change the entry
		If MsgBox(4, "Datensatz überschreiben?", "Wollen Sie den Datensatz wirklich Überschreiben?") = 6 Then

			;declare vars
			Local $dbdata3, $dbh3, $dbcheck3

			;start database interactions
			_SQLite_Startup()
			$dbh3 = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
			If @error = True Then
				MsgBox(16, "Fehler - SQLDatenbank", "Fehlerocode: " & @error & @CRLF & "Extended: " & @extended)
				_SQLite_Close($dbh3)
				_SQLite_Shutdown()
				Return 0
			EndIf

			$dbcheck3 = _SQLite_Exec($dbh3, "update Daten set datum='" & GUICtrlRead($edit_datum) & "', zeit='" & GUICtrlRead($edit_zeit) & "', rufzeichen='" & GUICtrlRead($edit_Rufzeichen) & "', skip='" & GUICtrlRead($edit_Skip) & "', rx='" & GUICtrlRead($edit_RX) & "', tx='" & GUICtrlRead($edit_TX) & "', frequenz='" & GUICtrlRead($edit_Frequenz) & "', mode='" & GUICtrlRead($edit_Combo1) & "', operatorname='" & GUICtrlRead($edit_Operatorname) & "', locator='" & GUICtrlRead($edit_Locator) & "', qth='" & GUICtrlRead($edit_QTH) & "', notiz='" & GUICtrlRead($edit_Notiz) & "' where ID='" & $editcall & "';")
			If @error = True Then
				MsgBox(16, "Fehler beim Speichern!", "Daten konnten nicht gespeichert werden!" & @CRLF & "Fehlercode: " & @error & @CRLF & "-1 - SQLite reported an error (Check return value)" & @CRLF & "1 - Error calling SQLite API 'sqlite3_exec'" & @CRLF & "2 - Call prevented by SafeMode" & @CRLF & "3 - Error Processing Callback from within _SQLite_GetTable2d()" & @CRLF & "4 - Error while converting SQL statement to UTF-8")
			EndIf

			;close databaseinteractions
			_SQLite_Close($dbh3)
			_SQLite_Shutdown()

		Else
			;Placeholder for debugging
		EndIf

	Else

		;Making sure that the user really wants to change the entry
		If MsgBox(4, "Overwrite data?", "Do you really want to overwrite data?") = 6 Then

			;declare vars
			Local $dbdata3, $dbh3, $dbcheck3

			;start database interactions
			_SQLite_Startup()
			$dbh3 = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
			If @error = True Then
				MsgBox(16, "Error - SQLDatabase", "Code: " & @error & @CRLF & "Extended: " & @extended)
				_SQLite_Close($dbh3)
				_SQLite_Shutdown()
				Return 0
			EndIf

			$dbcheck3 = _SQLite_Exec($dbh3, "update Daten set datum='" & GUICtrlRead($edit_datum) & "', zeit='" & GUICtrlRead($edit_zeit) & "', rufzeichen='" & GUICtrlRead($edit_Rufzeichen) & "', skip='" & GUICtrlRead($edit_Skip) & "', rx='" & GUICtrlRead($edit_RX) & "', tx='" & GUICtrlRead($edit_TX) & "', frequenz='" & GUICtrlRead($edit_Frequenz) & "', mode='" & GUICtrlRead($edit_Combo1) & "', operatorname='" & GUICtrlRead($edit_Operatorname) & "', locator='" & GUICtrlRead($edit_Locator) & "', qth='" & GUICtrlRead($edit_QTH) & "', notiz='" & GUICtrlRead($edit_Notiz) & "' where ID='" & $editcall & "';")
			If @error = True Then
				MsgBox(16, "Error while saving!", "Data cant be saved!" & @CRLF & "Code: " & @error & @CRLF & "-1 - SQLite reported an error (Check return value)" & @CRLF & "1 - Error calling SQLite API 'sqlite3_exec'" & @CRLF & "2 - Call prevented by SafeMode" & @CRLF & "3 - Error Processing Callback from within _SQLite_GetTable2d()" & @CRLF & "4 - Error while converting SQL statement to UTF-8")
			EndIf

			;close databaseinteractions
			_SQLite_Close($dbh3)
			_SQLite_Shutdown()

		Else
			;Placeholder for debugging
		EndIf

	EndIf


	;Hide editform and show mainform
	GUISetState(@SW_HIDE, $editform)
	GUISetState(@SW_SHOW, $QSO)

	;reload listview
	reload_listview()

EndFunc   ;==>edit_save

;This function exports all data into a CSV. (only data without a deletemarker)
Func export()

	;CSV-Header
;~ ID | Datum | Zeit | Rufzeichen | SKIP | RX | TX | FRQ | MODE | NAME | LOCATOR | QTH | Notiz

	;Declare Vars
	Local $exportfilehandle, $exportfilepath, $exportdbh, $exportquery, $exportdbdata, $export_max_counter, $export_counter
	$export_counter = 1


	;################################################
	;WICHTIG BEVOR EXPORT GESTARTET WIRD MUSS DIE DATENBANK GEPRÜFT WERDEN - SIE MUSS INHALT HABEN!!
	;IMPORTANT! BEFORE EXPORTING ANY DATA CHECK IF THE USED DATABASE IS FILLED WITH SOME DATA!! DATABASE MUST HAVE DATA!
	;################################################

	;Asking the user for saving location
	if $global_language="DE" Then
		$exportfilepath = FileSelectFolder("Bitte geben Sie an, wo die Export-Datei gespeichert werden soll.", @DesktopDir)
	Else
		$exportfilepath = FileSelectFolder("Please select a location for the export to be saved.", @DesktopDir)
	EndIf

	;check if the user made a mistake - return 0 if he made a mistake
	If FileExists($exportfilepath) = False Then
		if $global_language="DE" Then
			MsgBox(16, "Fehler beim Export!", "Dieses Verzeichnis kann nicht genutzt werden oder existiert nicht. Vorgang wird abgebrochen.")
		Else
			MsgBox(16, "Error while exporting!", "This location cant be used or is non existend! Aborting export!")
		EndIf
		Return 0
	EndIf

	;check if the user already have an export in the given location
	;If so then ask for permission to overwrite the data
	;return 0 if permission rejected

	If FileExists($exportfilepath & "\Elog_Export_" & @MDAY & "-" & @MON & "-" & @YEAR & ".csv") = True Then

		if $global_language="DE" Then
			If MsgBox(4, "Alten Export entdeckt!", "Im gewählten Verzeichnis existiert bereits ein Export." & @CRLF & "Sollen die Daten überschrieben werden?") <> 6 Then
				Return 0
			EndIf
		Else
			If MsgBox(4, "Old exported data was found!", "There already is an export in the given location!" & @CRLF & "Do you want to overwrite it?") <> 6 Then
				Return 0
			EndIf
		EndIf
	EndIf

	;open filehandle and write data from database into csv
	$exportfilehandle = FileOpen($exportfilepath & "\Elog_Export_" & @MDAY & "-" & @MON & "-" & @YEAR & ".csv", 2)
	If $exportfilehandle = -1 Then
		MsgBox(16, "Export Error!", "Fileopen:" & @CRLF & "Code: " & @error)
		FileClose($exportfilehandle)
		Return 0
	EndIf
	ConsoleWrite("Write data: " & $exportfilepath & "\Elog_Export_" & @MDAY & "-" & @MON & "-" & @YEAR & ".csv" & @CRLF)
	FileWrite($exportfilehandle, "ID,Datum,Zeit,Rufzeichen,SKIP,RX,TX,FREQ,MODE,NAME,LOCATOR,QTH,Notiz,Geloescht" & @CRLF)



	_SQLite_Startup()
	$exportdbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
	If @error = True Then
		MsgBox(16, "SQLDatabase Error", "Code: " & @error & @CRLF & "Extended: " & @extended)
		_SQLite_Close($exportdbh)
		_SQLite_Shutdown()
		Return 0
	EndIf

	;Maximalwert des Primärschlüssels ermitteln damit später die Schleife korrekt gesteuert werden kann
	;Getting the maximum value for primarykey - its very important for loop coordination
	_SQLite_Query($exportdbh, "select max(ID) from Daten", $exportquery)

	While _SQLite_FetchData($exportquery, $exportdbdata) = $SQLITE_OK
		ConsoleWrite($exportdbdata[0] & @CRLF)
		$export_max_counter = $exportdbdata[0]
		ConsoleWrite("Export MAX COUNTER: " & $export_max_counter & @CRLF)
	WEnd

	_SQLite_QueryFinalize($exportquery)

	If $export_max_counter = 0 Then

		if $global_language="DE" Then
			MsgBox(16, "Fehler beim Export", "Export_Max_counter kann nicht ermittelt werden!" & @CRLF & "Datenbank leer oder defekt!")
		Else
			MsgBox(16, "Error while exporting!", "Export_Max_counter cant be determined!" & @CRLF & "Database empty or corrupted!")
		EndIf
		_SQLite_Close($exportdbh)
		_SQLite_Shutdown()
		FileClose($exportfilehandle)
		Return 0
	EndIf

	While $export_counter <> $export_max_counter + 1
		_SQLite_Query($exportdbh, "select * from Daten where ID='" & $export_counter & "'", $exportquery)
		While _SQLite_FetchData($exportquery, $exportdbdata) = $SQLITE_OK
			ConsoleWrite("EXPORT DATA: " & $exportdbdata[0] & "," & $exportdbdata[1] & "," & $exportdbdata[2] & "," & $exportdbdata[3] & "," & $exportdbdata[4] & "," & $exportdbdata[5] & "," & $exportdbdata[6] & "," & $exportdbdata[7] & "," & $exportdbdata[8] & "," & $exportdbdata[9] & "," & $exportdbdata[10] & "," & $exportdbdata[11] & "," & $exportdbdata[12] & "," & $exportdbdata[13] & @CRLF)

			$exportdbdata[0] = StringReplace($exportdbdata[0], ",", "")
			$exportdbdata[1] = StringReplace($exportdbdata[1], ",", "")
			$exportdbdata[2] = StringReplace($exportdbdata[2], ",", "")
			$exportdbdata[3] = StringReplace($exportdbdata[3], ",", "")
			$exportdbdata[4] = StringReplace($exportdbdata[4], ",", "")
			$exportdbdata[5] = StringReplace($exportdbdata[5], ",", "")
			$exportdbdata[6] = StringReplace($exportdbdata[6], ",", "")
			$exportdbdata[7] = StringReplace($exportdbdata[7], ",", "")
			$exportdbdata[8] = StringReplace($exportdbdata[8], ",", "")
			$exportdbdata[9] = StringReplace($exportdbdata[9], ",", "")
			$exportdbdata[10] = StringReplace($exportdbdata[10], ",", "")
			$exportdbdata[11] = StringReplace($exportdbdata[11], ",", "")
			$exportdbdata[12] = StringReplace($exportdbdata[12], ",", "")
			$exportdbdata[13] = StringReplace($exportdbdata[13], ",", "")

			FileWrite($exportfilehandle, $exportdbdata[0] & "," & $exportdbdata[1] & "," & $exportdbdata[2] & "," & $exportdbdata[3] & "," & $exportdbdata[4] & "," & $exportdbdata[5] & "," & $exportdbdata[6] & "," & $exportdbdata[7] & "," & $exportdbdata[8] & "," & $exportdbdata[9] & "," & $exportdbdata[10] & "," & $exportdbdata[11] & "," & $exportdbdata[12] & "," & $exportdbdata[13] & @CRLF)
		WEnd
		$export_counter = $export_counter + 1
	WEnd

	_SQLite_QueryFinalize($exportquery)
	_SQLite_Close($exportdbh)
	_SQLite_Shutdown()
	FileClose($exportfilehandle)

	if $global_language="DE" Then
		MsgBox(64, "Export erfolgreich.", "Export der Daten erfolgreich abgeschlossen.")
	Else
		MsgBox(64, "Export successfully.", "Data successfully exported.")
	EndIf
EndFunc   ;==>export

;Diese Funktion startet den Import - Import nur für Export von ClusterDX www.Clusterdx.nl
;This function imports DATA from CLUSTERDX - clusterdx.nl
Func import_clusterdx()

	;Declare Vars
	Local $importhandle, $importfile, $importarray1, $importarray2, $importcounter, $query, $dbdata
	Local $id_data, $Datum_data, $zeit_data, $Rufzeichen_data, $skip_data, $rx_data, $tx_data
	Local $FREQ_data, $Mode_data, $Name_data, $Locator_data, $QTH_data, $Notiz_data, $dbcheck
	$importcounter = 0


	;Incoming data is expected as follows:
	;CSV Header and first line of data from ClusterDX: (EXAMPLE DATA!)
	;  id    ; DX     ;loc_DX ; DATE      ;  UTC ;FREQUENCY ; SPLIT_FREQUENCY ; MODE ; RST ; WKD ; PATH ; SUBMITTER ; loc_SUBMITTER; REMARKS                               ;MEMBER ; ACTIVCALL ; LOG ; SQSL       ; RQSL       ; QSL_info ; FB ;REGION ; TIMESTAMP          ;
;~ 424133; 68DA011; IO64SS; 30/04/2021; 11:23; 27565    ;                 ; USB  ; 3/1 ; WKD ; SP   ;  13OT4288 ; JO51FD       ; Hello 68DA011 - 73 from Berlin Germany; 0     ; 0         ; 1   ; 0000-00-00 ; 0000-00-00 ;          ;    ;       ; 2021-04-30 13:23:18;

	; For comparing here is my DB-structure
	; ID | Datum | Zeit | Rufzeichen | SKIP | RX | TX | FRQ | MODE | NAME | LOCATOR | QTH | Notiz



	;getting the importfilepath
	if $global_language="DE" Then
		$importfile = FileOpenDialog("Bitte CSV Datei angeben.", @DesktopDir, "CSV (*.csv)")
	Else
		$importfile = FileOpenDialog("Please give CSV-File.", @DesktopDir, "CSV (*.csv)")
	EndIf


	;check for errors
	if $global_language = "DE" Then
		If FileExists($importfile) = False Then
			MsgBox(16, "Fehler beim Import!", "Importdatei existiert nicht oder kann nicht gelesen werden!" & @CRLF & "Import wird abgebrochen!")
			Return 0
		EndIf
	Else
		If FileExists($importfile) = False Then
			MsgBox(16, "Error while importing!", "Given data non existend or cant be accessed!" & @CRLF & "Aborting import!")
			Return 0
		EndIf
	EndIf

	;Read everything into a array and check for errors
	_FileReadToArray($importfile, $importarray1)
	If @error = True Then
		MsgBox(16, "Import ERROR!", "Array Error!" & @CRLF & "Code: " & @error)
		;Fehlercodes
;~ 		1 - Error opening specified file
;~ 		2 - Unable to split the file
;~ 		3 - File lines have different numbers of fields (only if $FRTA_INTARRAYS flag not set)
;~ 		4 - No delimiters found (only if $FRTA_INTARRAYS flag not set)
	EndIf

	;Datenbank öffnen
	;opening the database
	_SQLite_Startup()
	$dbh = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")

	;check for errors - give prompt and return 0 if an error occurs
	If @error = True Then
		MsgBox(16, "Import - SQLite open error!", "Code: " & @error & @CRLF & "Extended: " & @extended)
		Return 0
	EndIf

	;Start the import - for loop
	For $importcounter = 0 To $importarray1[0] Step 1
		$importarray2 = StringSplit($importarray1[$importcounter], ";")
		If UBound($importarray2) > 5 Then

			;Overview of array
			;row 1 id
			;row 2 callsign
			;row 3 Locator
			;row 4 Datum
			;row 5 Zeit
			;row 6 FREQ
			;row 7
			;row 8 Mode
			;row 9 RX TX
			;row 10
			;row 11
			;row 12
			;row 13
			;row 14 NOTIZ
			;row 15
			;row 16
			;row 17
			;row 18
			;row 19
			;row 20
			;row 21
			;row 22
			;row 23
			;row 24

			If $importarray2[1] <> "id" Then

				;write some debugfoo into the scite console
				ConsoleWrite("Durchgang: " & $importcounter & " - " & $importarray2[2] & "," & $importarray2[3] & "," & $importarray2[4] & "," & $importarray2[5] & "," & $importarray2[6] & "," & $importarray2[14] & @CRLF)

				;GET LAST ID
				_SQLite_Query($dbh, "select count(*) from daten", $query)
				While _SQLite_FetchData($query, $dbdata) = $SQLITE_OK
					$lastid = $dbdata[0]
				WEnd

				_SQLite_QueryFinalize($query)

				;GATHER / CORRECT AND CUDDLE SOME DATA
				$id_data = $lastid + 1
				$Datum_data = StringReplace($importarray2[4], "/", ".")
				$Datum_data = StringReplace($Datum_data, " ", "")
				$zeit_data = StringReplace($importarray2[5], " ", "")
				$Rufzeichen_data = StringReplace($importarray2[2], " ", "")
				$skip_data = ""
				$rx_data = $importarray2[9]
				$tx_data = ""
				$FREQ_data = StringReplace($importarray2[6], " ", "")
				$Mode_data = StringReplace($importarray2[8], " ", "")
				$Name_data = ""
				$Locator_data = StringReplace($importarray2[3], " ", "")
				$QTH_data = ""
				$Notiz_data = StringTrimLeft($importarray2[14], 1)

				;execut the databasecommand
				;this writes the new data into the database
				$dbcheck = _SQLite_Exec($dbh, "insert into Daten(ID,Datum,Zeit,rufzeichen,skip,rx,tx,frequenz,mode,operatorname,locator,qth,notiz,delmark) values ('" & $id_data & "','" & $Datum_data & "','" & $zeit_data & "','" & $Rufzeichen_data & "','" & $skip_data & "','" & $rx_data & "','" & $tx_data & "','" & $FREQ_data & "','" & $Mode_data & "','" & $Name_data & "','" & $Locator_data & "','" & $QTH_data & "','" & $Notiz_data & "','False');")

				;check for errors and output them into the scite console or stdout
				If $dbcheck = $SQLITE_OK Then
					ConsoleWrite("Import " & $importcounter & " erfolgreich!")
				Else
					ConsoleWrite("Import " & $importcounter & " Fehlerhaft!")
				EndIf

			EndIf
		EndIf
	Next

	;close database and reload listview
	_SQLite_Close($dbh)
	_SQLite_Shutdown()
	reload_listview()

	if $global_language="DE" Then
		MsgBox(64,"Import abgeschlossen!","Import von Daten abgeschlossen!")
	Else
		MsgBox(64,"Import done!","Import is completed!")
	EndIf

EndFunc   ;==>import_clusterdx

;This function searches the database
Func search($searchtermfunc)

	;Cleardate and cleattime to 0
	$cleardate = 0
	$cleartime = 0

	;declare vars
	Local $dbh_searchterm, $searchfunc_counter

	;set data - needed for steering the algorithm
	$searchfunc_counter = 0

	;check for errors and returm 0 if the user made a mistake
	If $searchtermfunc = "" Then
		reload_listview()
		GUISetState(@SW_HIDE, $searchform)
		GUISetState(@SW_SHOW, $QSO)
		Return 0
	EndIf

	;delete all items in listview
	_GUICtrlListView_DeleteAllItems($List1)

	;start database up - check for erros
	_SQLite_Startup()
	$dbh_searchterm = _SQLite_Open(@ScriptDir & "\Daten\Datenbank.db")
	If @error = True Then
		MsgBox(16, "Error while saving!", "Code: " & @error & @CRLF & "Extended: " & @extended)
	EndIf

	;Search for data in the databse
	;This is the SQL_QUERY
	_SQLite_Query($dbh_searchterm, "select * from daten where rufzeichen like '%" & $searchtermfunc & "%'", $searchquery)

	;Fetching the data from database
	While _SQLite_FetchData($searchquery, $dbsearchdata) = $SQLITE_OK

		;only catch data without a deletemarker
		If $dbsearchdata[13] = "False" Then

			_GUICtrlListView_AddItem($List1, $dbsearchdata[0], $searchfunc_counter)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[1], 1, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[2], 2, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[3], 3, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[4], 4, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[5], 5, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[6], 6, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[7], 7, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[8], 8, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[9], 9, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[10], 10, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[11], 11, 1)
			_GUICtrlListView_AddSubItem($List1, $searchfunc_counter, $dbsearchdata[12], 12, 1)

			$searchfunc_counter = $searchfunc_counter + 1 ;count the searchcounter 1 up
		EndIf

	WEnd

	;Finish the query and close the database and sqlite.dll
	_SQLite_QueryFinalize($searchquery)
	_SQLite_Close($dbh_searchterm)
	_SQLite_Shutdown()

	;Refresh the width of the listview
	_GUICtrlListView_SetColumnWidth($List1, 4, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 9, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 11, $LVSCW_AUTOSIZE)
	_GUICtrlListView_SetColumnWidth($List1, 12, $LVSCW_AUTOSIZE)

	;close searchgui and open maingui
	GUISetState(@SW_HIDE, $searchform)
	GUISetState(@SW_SHOW, $QSO)

EndFunc   ;==>search

;This function converts Maidenheadlocator to LAT LON
Func convertlocator($locator)


	;DEBUG
;~ 	MsgBox(0,"Convert locator","Converting: "&$locator)

	;This function is written by Ferdinand Marx - www.GFMsoft.de
	;Guided by the following tutorial
	;http://www.m0nwk.co.uk/how-to-convert-maidenhead-locator-to-latitude-and-longitude/

	Local $latitude, $longtitude, $array, $workarray, $asciiarray, $worklocator
	Local $lat_step1, $lat_step2, $lat_step3
	Local $lon_step1, $lon_step2, $lon_step3, $lon_step4


;~ 	$locator="FP64CI"

	If StringLen($locator) <> 6 Then
		ConsoleWrite("Targetlocator corrupt - cant calculate!"&@CRLF)
		return 0
	EndIf

	$worklocator = StringTrimLeft($locator, 4)
	$worklocator = StringLower($worklocator)
	$locator = StringTrimRight($locator, 2)
	$locator = $locator & $worklocator

;~ 	ConsoleWrite("Locator: "&$locator&@CRLF)

	$asciiarray = StringToASCIIArray($locator)
	$workarray = StringSplit($locator, "")


	If IsArray($workarray) = False Then
		;FEHLERmeldung
	EndIf
	If $workarray[0] <> 6 Then
		;Fehlermeldung
	EndIf


	;step 1 - find ascii char for 2th char in locator code
	$lat_step1 = $asciiarray[1]

	$lat_step1 = $lat_step1 - 65
	$lat_step1 = $lat_step1 * 10
;~ ConsoleWrite("lat step1: "&$lat_step1&@CRLF)

	;step2 - get number of position 4
	$lat_step2 = $workarray[4]
;~ ConsoleWrite("lat step2: "&$lat_step2 &@CRLF)

	;step 3 - find ascii char for 6th char of locator
	$lat_step3 = $asciiarray[5]


	$lat_step3 = $lat_step3 - 97
	$lat_step3 = $lat_step3 / 24
	$lat_step3 = $lat_step3 + (1 / 48)
	$lat_step3 = $lat_step3 - 90
;~ ConsoleWrite("lat step3: "&$lat_step3 &@CRLF)

	;step 4 - all together STEP1 + STEP2 + STEP3
	$latitude = $lat_step1 + $lat_step2 + $lat_step3
;~ ConsoleWrite("Latitude: "& $latitude &@CRLF)
;~ ConsoleWrite("Latitude (round): "& round($latitude,3) &@CRLF)
;~ ConsoleWrite("----------"&@CRLF)

;~ ___________
;~ LONGTITUDE

	;step1 - Find the ASCII charachter code for the 1st character of the locator code
	$lon_step1 = $asciiarray[0]


	$lon_step1 = $lon_step1 - 65
	$lon_step1 = $lon_step1 * 20
;~ ConsoleWrite("lon step1: "&$lon_step1&@CRLF)

	;step2 - Get number from position 3
	$lon_step2 = $workarray[3]
	$lon_step2 = $lon_step2 * 2
;~ ConsoleWrite("lon step2: "&$lon_step2&@CRLF)

	;step3 - Find the ASCII charachter code for the 5th character of the locator code
	$lon_step3 = $asciiarray[4]


	$lon_step3 = $lon_step3 - 97
	$lon_step3 = $lon_step3 / 12
	$lon_step3 = $lon_step3 + (1 / 24)
;~ ConsoleWrite("lon step3: "&$lon_step3&@CRLF)


	;step4 - Add results A, B and C then deduct 180
	$longtitude = ($lon_step1 + $lon_step2 + $lon_step3) - 180
;~ ConsoleWrite("Longtitude: "&$longtitude&@CRLF)
;~ 	ConsoleWrite(@CRLF)
;~ 	ConsoleWrite(round($latitude,3)&" / "&round($longtitude,3)&@CRLF)
;~ 	ConsoleWrite(@CRLF)
	Return Round($latitude, 3) & "," & Round($longtitude, 3)




EndFunc   ;==>convertlocator

;This function calculates the distance of two qth's
Func calcdistance($qthdistance)

	;checking for inputerrors
	if StringLen($qthdistance) <> 6 or $qthdistance = "" Then
		return 0
	EndIf

	;this is for users trying to crash your application
	if $qthdistance = "      " Then
		return 0
	EndIf

	;Calculate distance with Latitude/Longitude points
	;This script calculates the distance between to locations on planet earth given in LAT LON
	;Result is Rounded
	;This script is a convert from https://www.movable-type.co.uk/scripts/latlong.html
	;It uses the haversine formula.
	;~ https://www.nhc.noaa.gov/gccalc.shtml

	;Define local vars
	Local $lat1, $lat2, $lon1, $lon2, $point1, $point2
	Local $phi1, $phi2, $mathpi, $a, $c, $d



	; delta = Δφ
	Local $delta

	; spectral = Δλ
	Local $spectral

	;LAT and LON of Point 1
	;This is always your position
	$point1 = convertlocator($ownlocator)
	$point1 = StringSplit($point1, ",")

	;Check for errors
	if IsArray($point1) = False Then
		return 0
	EndIf

	$lat1 = $point1[1]
	$lon1 = $point1[2]

	;LAT and LON of Point 2
	$point2 = convertlocator($qthdistance)
	$point2 = StringSplit($point2, ",")

	;Check for errors
	If IsArray($point2) = False Then
		Return 0
	EndIf

	$lat2 = $point2[1]
	$lon2 = $point2[2]

	;3.141592653589793
	$mathpi = 3.14159

	$phi1 = $lat1 * $mathpi / 180
	$phi2 = $lat2 * $mathpi / 180
	$delta = ($lat2 - $lat1) * $mathpi / 180
	$spectral = ($lon2 - $lon1) * $mathpi / 180
	$a = Sin($delta / 2) * Sin($delta / 2) + Cos($phi1) * Cos($phi2) * Sin($spectral / 2) * Sin($spectral / 2)
	$c = 2 * _atan2(Sqrt($a), Sqrt(1 - $a))
	$d = $r * $c

	ConsoleWrite("Distance: " & Round($d / 1000, 0) & " km" & @CRLF)
	Return Round($d / 1000, 0)

EndFunc   ;==>calcdistance

;This function is needed for the distance calculation of two qth's
Func _atan2($y, $x)
	If $x > 0 Then
		Return ATan($y / $x)
	ElseIf $x < 0 And $y >= 0 Then
		Return ATan($y / $x) + ACos(-1)
	ElseIf $x < 0 And $y < 0 Then
		Return ATan($y / $x) - ACos(-1)
	ElseIf $x = 0 And $y > 0 Then
		Return ACos(-1) / 2
	ElseIf $x = 0 And $y < 0 Then
		Return -ACos(-1) / 2
	Else
		Return 0
	EndIf
EndFunc   ;==>_atan2




























