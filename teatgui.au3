#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>

; ---------------- CONFIG ----------------
Global Const $SIZE = 240
Global Const $UPDATE_MS = 250

Global $gProgress = 0
Global $gTarget = 0
Global $gLevel = 1
Global $gPulse = 0
Global $gPulseActive = False

; ---------------- GUI ----------------
$hGUI = GUICreate("XP Ring (Adlib)", $SIZE, $SIZE)
GUISetState(@SW_SHOW)

; ---------------- GDI+ ----------------
_GDIPlus_Startup()
$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI)
_GDIPlus_GraphicsSetSmoothingMode($hGraphics, 2)

; Colors
Global Const $BG        = 0xFF181818
Global Const $RING_BG  = 0xFF4A4A4A
Global Const $RING_FILL= 0xFFFF8C00
Global Const $TEXT     = 0xFFFFFFFF
Global Const $LABEL    = 0xFFB0B0B0

; Pens
$hBackPen = _GDIPlus_PenCreate($RING_BG, 14)
$hFillPen = _GDIPlus_PenCreate($RING_FILL, 14)

; Fonts
$hFam = _GDIPlus_FontFamilyCreate("Segoe UI")
$hFontLvl = _GDIPlus_FontCreate($hFam, 28)
$hFontLbl = _GDIPlus_FontCreate($hFam, 14)
$hFormat = _GDIPlus_StringFormatCreate()
_GDIPlus_StringFormatSetAlign($hFormat, 1)
_GDIPlus_StringFormatSetLineAlign($hFormat, 1)

; ---------------- ADLIB ----------------
AdlibRegister("_UpdateXP", $UPDATE_MS)

; ---------------- MAIN LOOP ----------------
While GUIGetMsg() <> $GUI_EVENT_CLOSE
    Sleep(10)
WEnd

; ---------------- CLEANUP ----------------
AdlibUnRegister("_UpdateXP")
_GDIPlus_Shutdown()
Exit

; ======================================================
; 🔁 ADLIB UPDATE FUNCTION (called every 250ms)
; ======================================================
Func _UpdateXP()

    ; Fake XP gain (TEST LOGIC)
    _FakeXPGain()

    ; Smooth approach to target
    If $gProgress < $gTarget Then
        $gProgress += 2
    EndIf

    ; Level up
    If $gProgress >= 100 Then
        _LevelUp()
    EndIf

    _DrawRing()
EndFunc

; ======================================================
; 🧪 TEST FUNCTION – SIMULATED XP GAIN
; ======================================================
Func _FakeXPGain()
    ; Random XP bumps
    If Random(0, 100) < 35 Then
        $gTarget += Random(5, 15, 1)
        If $gTarget > 100 Then $gTarget = 100
    EndIf
EndFunc

; ======================================================
; 💥 LEVEL UP LOGIC
; ======================================================
Func _LevelUp()
    $gLevel += 1
    $gProgress = 0
    $gTarget = 0
    $gPulse = 0
    $gPulseActive = True
EndFunc

; ======================================================
; 🎨 DRAW FUNCTION
; ======================================================
Func _DrawRing()
    _GDIPlus_GraphicsClear($hGraphics, $BG)

    Local $cx = $SIZE / 2
    Local $cy = 95
    Local $r = 70

    ; Pulse glow
    If $gPulseActive Then
        $gPulse += 3
        Local $alpha = 120 - ($gPulse * 2)
        If $alpha <= 0 Then
            $gPulseActive = False
        Else
            Local $glowPen = _GDIPlus_PenCreate( _
                BitOR(BitShift($alpha, -24), 0xFFAA5500), _
                14 + $gPulse)

            _GDIPlus_GraphicsDrawArc($hGraphics, _
                $cx - $r - $gPulse, $cy - $r - $gPulse, _
                ($r * 2) + ($gPulse * 2), _
                ($r * 2) + ($gPulse * 2), _
                -90, 360, $glowPen)

            _GDIPlus_PenDispose($glowPen)
        EndIf
    EndIf

    ; Background ring
    _GDIPlus_GraphicsDrawArc($hGraphics, _
        $cx - $r, $cy - $r, $r * 2, $r * 2, _
        0, 360, $hBackPen)

    ; Progress ring
    Local $angle = ($gProgress / 100) * 360
    _GDIPlus_GraphicsDrawArc($hGraphics, _
        $cx - $r, $cy - $r, $r * 2, $r * 2, _
        -90, $angle, $hFillPen)

    ; Level text
    Local $rect = _GDIPlus_RectFCreate(0, $cy - 20, $SIZE, 40)
    _GDIPlus_GraphicsDrawStringEx($hGraphics, _
        "Lv " & $gLevel, $hFontLvl, $rect, $hFormat, _
        _GDIPlus_BrushCreateSolid($TEXT))

    ; Label text
    Local $rect2 = _GDIPlus_RectFCreate(0, $cy + $r + 10, $SIZE, 30)
    _GDIPlus_GraphicsDrawStringEx($hGraphics, _
        "XP Progress", $hFontLbl, $rect2, $hFormat, _
        _GDIPlus_BrushCreateSolid($LABEL))
EndFunc