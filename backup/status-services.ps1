$ErrorActionPreference = "Stop"

$services = @(
    @{ Name = "auth-service"; Port = 8084 },
    @{ Name = "soil-service"; Port = 8081 },
    @{ Name = "control-service"; Port = 8082 },
    @{ Name = "temperature-service"; Port = 8083 }
)

foreach ($service in $services) {
    $connections = Get-NetTCPConnection -LocalPort $service.Port -State Listen -ErrorAction SilentlyContinue

    if (-not $connections) {
        Write-Host ("{0,-20} port {1}: STOPPED" -f $service.Name, $service.Port) -ForegroundColor Red
        continue
    }

    $processIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($processId in $processIds) {
        $process = Get-CimInstance Win32_Process -Filter "ProcessId = $processId" -ErrorAction SilentlyContinue
        Write-Host ("{0,-20} port {1}: RUNNING pid {2}" -f $service.Name, $service.Port, $processId) -ForegroundColor Green
        if ($process -and $process.CommandLine) {
            Write-Host ("  {0}" -f $process.CommandLine)
        }
    }
}
