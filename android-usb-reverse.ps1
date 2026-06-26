$ErrorActionPreference = "Stop"

$adb = "C:\Users\asus\AppData\Local\Android\sdk\platform-tools\adb.exe"

if (-not (Test-Path $adb)) {
    throw "adb.exe not found: $adb"
}

& $adb reverse tcp:8081 tcp:8081
& $adb reverse tcp:8082 tcp:8082
& $adb reverse tcp:8083 tcp:8083
& $adb reverse tcp:8084 tcp:8084
& $adb reverse tcp:8085 tcp:8085

& $adb reverse --list
