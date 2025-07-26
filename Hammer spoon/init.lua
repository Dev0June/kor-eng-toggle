local inputSource = {
    english = "com.apple.keylayout.ABC",
    korean = "org.youknowone.inputmethod.Gureum.system.han2",
    gureum = "org.youknowone.inputmethod.Gureum.system",
}

-- 한글용 스타일 (파란색 계열)
local koreanStyle = {
    fillColor = { red = 0.1, green = 0.3, blue = 0.8, alpha = 0.75 },
    strokeColor = { alpha = 0 },
    textColor = { white = 1, alpha = 0.9 },
    textSize = 30,
    fadeOutDuration = 2.0
}

-- 영문용 스타일 (빨간색 계열)
local englishStyle = {
    fillColor = { red = 0.8, green = 0.2, blue = 0.2, alpha = 0.75 },
    strokeColor = { alpha = 0 },
    textColor = { white = 1, alpha = 0.9 },
    textSize = 30,
    fadeOutDuration = 2.0
}

-- 기타용 스타일 (회색 계열)
local defaultStyle = {
    fillColor = { white = 0, alpha = 0.75 },
    strokeColor = { alpha = 0 },
    textColor = { white = 0.75, alpha = 0.75 },
    textSize = 30,
    fadeOutDuration = 2.0
}

-- 전역 변수 초기화
local last_alerted_IM_ID = nil
local last_IM_alert_uuid = nil

function IM_alert()
    local current = hs.keycodes.currentSourceID()
    local language = nil
    local alertStyle = defaultStyle
    
    -- 입력기 감지 로직 및 스타일 선택
    if current == inputSource.korean or current == inputSource.gureum or string.find(current, "Gureum") then
        language = ' 한글 '
        alertStyle = koreanStyle
    elseif current == inputSource.english then
        language = ' 영문 '
        alertStyle = englishStyle
    elseif current == inputSource.japanese then
        language = ' 🇯🇵 あいう '
        alertStyle = defaultStyle
    else
        -- 알 수 없는 입력기의 경우 ID를 표시하되 더 짧게
        local shortId = string.match(current, "([^%.]+)$") or current
        language = ' ' .. shortId .. ' '
        alertStyle = defaultStyle
    end
    
    -- 같은 입력기로 연속 변경 시 알림 방지
    if current == last_alerted_IM_ID then 
        return 
    end
    
    -- 이전 알림 닫기
    if last_IM_alert_uuid then
        hs.alert.closeSpecific(last_IM_alert_uuid)
    end
    
    -- 새 알림 표시 (각 입력기에 맞는 스타일로)
    last_IM_alert_uuid = hs.alert.show(language, alertStyle, 0.3)
    last_alerted_IM_ID = current
end

-- 입력기 변경 감지 시작
hs.keycodes.inputSourceChanged(IM_alert)

-- 현재 입력기 ID 확인용 함수 (디버깅용)
function getCurrentInputMethod()
    local current = hs.keycodes.currentSourceID()
    print("현재 입력기: " .. current)
    return current
end