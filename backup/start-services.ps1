$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$logs = Join-Path $root "logs"

$services = @(
    @{ Name = "auth-service"; Port = 8084; Jar = "auth-service-0.0.1-SNAPSHOT.jar" },
    @{ Name = "soil-service"; Port = 8081; Jar = "soil-service-0.0.1-SNAPSHOT.jar" },
    @{ Name = "control-service"; Port = 8082; Jar = "control-service-0.0.1-SNAPSHOT.jar" },
    @{ Name = "temperature-service"; Port = 8083; Jar = "temperature-service-0.0.1-SNAPSHOT.jar" }
)

New-Item -ItemType Directory -Force $logs | Out-Null

& (Join-Path $root "stop-services.ps1")

foreach ($service in $services) {
    $serviceDir = Join-Path $root $service.Name
    $jarPath = Join-Path $serviceDir ("target\" + $service.Jar)

    Write-Host "Building $($service.Name)..."
    Push-Location $serviceDir
    try {
        & ".\mvnw.cmd" "-DskipTests" "package"
    } finally {
        Pop-Location
    }

    if (-not (Test-Path $jarPath)) {
        throw "Jar not found: $jarPath"
    }

    Write-Host "Starting $($service.Name) on port $($service.Port)..."
    Start-Process `
        -FilePath "java" `
        -ArgumentList "-jar", ("target\" + $service.Jar) `
        -WorkingDirectory $serviceDir `
        -RedirectStandardOutput (Join-Path $logs "$($service.Name).out.log") `
        -RedirectStandardError (Join-Path $logs "$($service.Name).err.log") `
        -WindowStyle Hidden
}

Start-Sleep -Seconds 8
& (Join-Path $root "status-services.ps1")
