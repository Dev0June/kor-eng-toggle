# IME 상태 팝업 도구

이 프로젝트는 Windows와 macOS에서 IME(입력기) 상태를 시각적으로 표시해주는 도구들을 포함하고 있습니다.

## Windows용 도구 (AutoHotkey)
`AutoHotkey v2` 폴더의 `IME_Popup.ahk` 스크립트는 Windows 환경에서 한영 전환 시 현재 IME 상태를 팝업으로 표시해줍니다.

## macOS용 도구 (Hammerspoon)
`Hammer spoon` 폴더의 `init.lua` 스크립트는 macOS 환경에서 한영 전환 시 현재 IME 상태를 팝업으로 표시해줍니다.

## 사용 방법

### Windows
1. [AutoHotkey v2](https://www.autohotkey.com/)를 설치합니다.
2. `IME_Popup.ahk` 파일을 실행 파일(.exe)로 컴파일합니다.
   - 스크립트 파일에서 우클릭 후 "Compile Script" 선택
3. 컴파일된 실행 파일을 시작 프로그램 폴더에 복사합니다:
   - `Win + R` 키를 눌러 실행 창을 엽니다.
   - `shell:startup`을 입력하고 확인을 클릭합니다.
   - 컴파일된 `.exe` 파일을 시작 프로그램 폴더에 복사합니다.

### macOS
1. [Hammerspoon](https://www.hammerspoon.org/)을 설치합니다.
2. `init.lua` 파일을 `~/.hammerspoon/` 디렉토리에 복사합니다.
3. Hammerspoon 메뉴바 아이콘에서 'Reload Config'를 클릭합니다.
