$ErrorActionPreference = "Stop"

$ports = @(8081, 8082, 8083, 8084)
$serviceJars = @(
    "auth-service-0.0.1-SNAPSHOT.jar",
    "soil-service-0.0.1-SNAPSHOT.jar",
    "control-service-0.0.1-SNAPSHOT.jar",
    "temperature-service-0.0.1-SNAPSHOT.jar"
)

foreach ($port in $ports) {
    $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue

    foreach ($connection in $connections) {
        $processId = $connection.OwningProcess
        $process = Get-CimInstance Win32_Process -Filter "ProcessId = $processId" -ErrorAction SilentlyContinue
        $commandLine = if ($process) { $process.CommandLine } else { "" }
        $isChiliService = $false

        foreach ($jar in $serviceJars) {
            if ($commandLine -like "*$jar*") {
                $isChiliService = $true
                break
            }
        }

        if ($isChiliService) {
            Write-Host "Stopping service on port $port, pid $processId"
            Stop-Process -Id $processId -Force
        } else {
            Write-Host "Port $port is used by another process, pid $processId. Not stopping it." -ForegroundColor Yellow
            if ($commandLine) {
                Write-Host "  $commandLine"
            }
        }
    }
}
