#Requires AutoHotkey v2.0

; Ensure CapsLock is "off" so we can manage it
SetCapsLockState "AlwaysOff"

; --- 1. Shift + CapsLock = Normal CapsLock Behavior ---
+CapsLock:: {
    SetCapsLockState !GetKeyState("CapsLock", "T")
}

; --- 2. Hold CapsLock for Ctrl, Tap for Esc ---
*CapsLock:: {
    ; Set Control Down immediately
    Send "{Blind}{LControl Down}"
    
    ; Wait for key release
    KeyWait "CapsLock"
    
    ; Send Control Up
    Send "{Blind}{LControl Up}"
    
    ; If the key was not held for more than 200ms (tap)
    if (A_TimeSincePriorHotkey < 200) and (A_PriorKey == "CapsLock")
    {
        Send "{Esc}"
    }
}
*CapsLock Up::Return ; Necessary to make the hotkey work
