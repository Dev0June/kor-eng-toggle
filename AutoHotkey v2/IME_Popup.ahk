#Requires AutoHotkey v2.0
#SingleInstance Force

; 전역 변수
alertGui := ""
lastImeState := -1

; DPI 스케일링 값 가져오기 함수
GetDPIScale() {
    ; 시스템 DPI 가져오기 (기본값 96 DPI = 100%)
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    dpiX := DllCall("GetDeviceCaps", "Ptr", hdc, "Int", 88) ; LOGPIXELSX
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    
    ; 스케일링 비율 계산 (96 DPI = 1.0, 120 DPI = 1.25, 144 DPI = 1.5)
    return dpiX / 96.0
}

; DPI에 따른 위치 조정 함수
GetAdjustedPosition(baseX, baseY) {
    scale := GetDPIScale()
    
    ; 스케일링에 따른 위치 조정
    switch {
        case scale <= 1.0:  ; 100% (96 DPI)
            return {x: baseX, y: baseY}
        case scale <= 1.25: ; 125% (120 DPI)
            return {x: baseX - 5, y: baseY + 3}
        case scale <= 1.5:  ; 150% (144 DPI)
            return {x: baseX - 10, y: baseY + 8}
        case scale <= 1.75: ; 175% (168 DPI)
            return {x: baseX - 15, y: baseY + 12}
        case scale <= 2.0:  ; 200% (192 DPI)
            return {x: baseX - 20, y: baseY + 16}
        default:            ; 200% 이상
            return {x: baseX - 25, y: baseY + 20}
    }
}

; IME 상태 확인 함수들 (마우스 위치 기반 제거)
fnGetImeState(){
    ; 활성 창 기반으로 변경
    hWnd := WinExist("A")
    if (!hWnd) {
        return 0
    }
    return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd), 0x005, "")
}

Send_ImeControl(DefaultIMEWnd, wParam, lParam) {
    DetectHiddenWindows(true)
    rst := SendMessage(0x283, wParam, lParam,, "ahk_id " DefaultIMEWnd)
    return rst
}

ImmGetDefaultIMEWnd(hWnd) {
    return DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
}

; 배경 색상 설정 (글자는 흰색 고정)
KOREAN_BG_COLOR := "Blue"     ; 한글 배경 색상
ENGLISH_BG_COLOR := "Red"     ; 영문 배경 색상

; 컬러풀한 팝업 알림 표시 (흰색 글자, 색상 배경, 둥근 모서리)
ShowIMEAlert(text) {
    global alertGui, KOREAN_BG_COLOR, ENGLISH_BG_COLOR
    static textCtrl := ""
    
    ; 텍스트에 따른 배경 색상 선택
    bgColor := (text = "한글") ? KOREAN_BG_COLOR : ENGLISH_BG_COLOR
    
    ; GUI가 없으면 최초 생성
    if (!IsObject(alertGui)) {
        ; 새 GUI 생성 (작업표시줄에 나타나지 않음)
        alertGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox -Caption +ToolWindow +LastFound", "")
        alertGui.BackColor := bgColor
        alertGui.MarginX := 40
        alertGui.MarginY := 30
        
        ; 흰색 텍스트 추가
        textCtrl := alertGui.Add("Text", "Center c0xFFFFFF w200 h80", text)
        textCtrl.SetFont("s35 Bold", "Arial")
        
        ; DPI에 따른 위치 조정
        adjustedPos := GetAdjustedPosition(-10, -7)
        textCtrl.Move(adjustedPos.x, adjustedPos.y)

        ; 화면 중앙에 위치
        x := A_ScreenWidth // 2 - 100
        y := A_ScreenHeight // 3
        alertGui.Move(x, y)
        
        alertGui.Show("AutoSize NoActivate")
        
        ; 둥근 모서리 적용
        hWnd := alertGui.Hwnd
        DllCall("Gdi32.dll\DeleteObject", "Ptr", DllCall("Gdi32.dll\CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", 280, "Int", 140, "Int", 60, "Int", 60, "Ptr"))
        DllCall("User32.dll\SetWindowRgn", "Ptr", hWnd, "Ptr", DllCall("Gdi32.dll\CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", 280, "Int", 140, "Int", 60, "Int", 60, "Ptr"), "Int", 1)
        
    } else {
        ; 기존 GUI가 있으면 텍스트와 배경색 변경
        textCtrl.Text := text
        alertGui.BackColor := bgColor
        
        ; GUI가 숨겨져 있으면 다시 표시
        try {
            alertGui.Show("NoActivate")
        }
    }
    
    ; 1.5초 후 숨기기
    SetTimer(HideAlert, -1500)
}

; GUI 숨기기 함수
HideAlert() {
    global alertGui
    try {
        if (IsObject(alertGui)) {
            alertGui.Hide()
        }
    }
}

; IME 상태 변경 감지
CheckIMEChange() {
    global lastImeState
    
    current := fnGetImeState()
    
    ; 상태가 변경된 경우
    if (current != lastImeState && lastImeState != -1) {
        if (current) {
            ShowIMEAlert("한글")
        } else {
            ShowIMEAlert("영문")
        }
    }
    
    lastImeState := current
}

; 지연된 IME 상태 확인
DelayedIMECheck() {
    CheckIMEChange()
}

; 알림 표시 함수들
ShowEnglishAlert() {
    ShowIMEAlert("영문으로 변경")
}

ShowKoreanAlert() {
    ShowIMEAlert("한글로 변경")
}

; 한/영 키 직접 후킹 ($ 접두사로 무한 루프 방지)
$vk15:: {
    ; $ 접두사로 자기 호출 방지
    Send("{vk15}")
    
    ; 150ms 후 상태 확인 (IME 변경 완료 대기)
    SetTimer(DelayedIMECheck, -150)
}

; 프로그램 종료 시 정리
OnExit(ExitScript)

ExitScript(ExitReason, ExitCode) {
    try {
        if (IsObject(alertGui)) {
            alertGui.Close()
        }
    }
}

; 초기 상태 설정
lastImeState := fnGetImeState()