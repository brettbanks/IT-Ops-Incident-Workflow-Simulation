<#  Fix-HighCPU.ps1
    Safely reduce high CPU on Windows 10/11.

    Features
    - Clear print queue & restart services
    - Kill Print Filter Pipeline Host if stuck
    - Show/optionally kill top CPU processes (with safelist)
    - Start Windows Defender Quick Scan
    - Optional: Disable/Enable print services if you never/again need printing

    Usage
      .\Fix-HighCPU.ps1 -QuickFix
      .\Fix-HighCPU.ps1                  # interactive menu
      .\Fix-HighCPU.ps1 -DisablePrinting # permanently disable print services
      .\Fix-HighCPU.ps1 -EnablePrinting  # re-enable print services
#>

[CmdletBinding()]
param(
  [switch]$QuickFix,
  [switch]$DisablePrinting,
  [switch]$EnablePrinting
)

function Assert-Admin {
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) {
    Write-Error "Run this script in an elevated PowerShell (Administrator)."
    exit 1
  }
}

function Write-Header($text) {
  Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Get-PrintWorkflowServices {
  # Spooler is the main one; PrintWorkflowUserSvc has a random suffix per user session
  Get-Service | Where-Object {
    $_.Name -eq 'Spooler' -or $_.Name -like 'PrintWorkflowUserSvc*'
  }
}

function Clear-PrintQueue {
  Write-Header "Clearing print queue"
  $services = Get-PrintWorkflowServices
  foreach ($svc in $services) {
    if ($svc.Status -ne 'Stopped') { Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue }
  }

  $spool = "$env:SystemRoot\System32\spool\PRINTERS"
  if (Test-Path $spool) {
    try {
      Get-ChildItem $spool -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
      Write-Host "Deleted stuck files in $spool"
    } catch { Write-Warning "Couldn't fully clear $spool: $($_.Exception.Message)" }
  }

  # Kill stuck pipeline host if present
  Get-Process -Name "printfilterpipelinesvc" -ErrorAction SilentlyContinue | ForEach-Object {
    try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue; Write-Host "Killed printfilterpipelinesvc.exe (PID $($_.Id))" }
    catch { Write-Warning "Couldn't kill printfilterpipelinesvc: $($_.Exception.Message)" }
  }

  # Restart services you actually use
  try {
    Start-Service -Name Spooler -ErrorAction SilentlyContinue
    Get-Service -Name 'PrintWorkflowUserSvc*' -ErrorAction SilentlyContinue | ForEach-Object {
      try { Start-Service -Name $_.Name -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host "Print services restarted."
  } catch { Write-Warning "Print services couldn't be restarted: $($_.Exception.Message)" }
}

function Disable-PrintServices {
  Write-Header "Disabling print services"
  $services = Get-PrintWorkflowServices
  foreach ($svc in $services) {
    try {
      Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
      Set-Service  -Name $svc.Name -StartupType Disabled
      Write-Host "Disabled $($svc.Name)"
    } catch { Write-Warning "Couldn't disable $($svc.Name): $($_.Exception.Message)" }
  }
}

function Enable-PrintServices {
  Write-Header "Enabling print services"
  $services = Get-PrintWorkflowServices
  foreach ($svc in $services) {
    try {
      Set-Service -Name $svc.Name -StartupType Automatic
      Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
      Write-Host "Enabled $($svc.Name)"
    } catch { Write-Warning "Couldn't enable $($svc.Name): $($_.Exception.Message)" }
  }
}

function Show-TopCpu {
  Write-Header "Top CPU processes (live sample ~2s)"
  $sample = Get-Counter '\Process(*)\% Processor Time' -SampleInterval 1 -MaxSamples 2 |
            Select-Object -ExpandProperty CounterSamples |
            Where-Object { $_.InstanceName -ne '_Total' -and $_.InstanceName -ne 'Idle' } |
            Group-Object InstanceName -NoElement |
            ForEach-Object {
              $name = $_.Name
              # average the two samples
              $vals = (Get-Counter "\Process($name)\% Processor Time" -SampleInterval 1 -MaxSamples 2
              ).CounterSamples.CookedValue
              [PSCustomObject]@{ Process=$name; CPU=([math]::Round(($vals | Measure-Object -Average).Average,1)) }
            }

  $byCpu = $sample | Sort-Object CPU -Descending | Select-Object -First 15
  $byCpu | Format-Table -AutoSize
  return $byCpu
}

function Kill-CPUHogs {
  param([int]$Threshold = 15)
  Write-Header "Killing CPU hogs > $Threshold% (safe list protected)"
  $safe = @('System','Idle','csrss','wininit','services','lsass','smss','svchost',
            'dwm','explorer','System Interrupts','Registry','fontdrvhost','sihost',
            'SearchIndexer','audiodg','Memory Compression','MsMpEng')

  $top = Show-TopCpu
  foreach ($row in $top) {
    if ($row.CPU -ge $Threshold -and ($safe -notcontains $row.Process)) {
      # Map process name to PID(s)
      $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -ieq $row.Process
      }
      foreach ($p in $procs) {
        try {
          Write-Host ("Stopping {0} (PID {1}) using {2}% CPU" -f $p.ProcessName,$p.Id,$row.CPU)
          Stop-Process -Id $p.Id -Force -ErrorAction Stop
        } catch { Write-Warning "Couldn't stop $($p.ProcessName) PID $($p.Id): $($_.Exception.Message)" }
      }
    }
  }
}

function Start-DefenderQuickScan {
  Write-Header "Windows Defender Quick Scan"
  try {
    if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) {
      Start-MpScan -ScanType QuickScan
      Write-Host "Quick scan started (you can keep working)."
    } else {
      Write-Warning "Windows Defender module not available on this system."
    }
  } catch { Write-Warning "Couldn't start scan: $($_.Exception.Message)" }
}

function Show-WindowsUpdateStatus {
  Write-Header "Windows Update status (read-only)"
  try {
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $result = $searcher.Search("IsInstalled=0 and Type='Software'")
    $count = $result.Updates.Count
    Write-Host "Pending updates: $count"
    if ($count -gt 0) {
      $result.Updates | Select-Object -First 10 | ForEach-Object {
        Write-Host " - $($_.Title)"
      }
      if ($count -gt 10) { Write-Host " ... (more not shown)" }
    }
  } catch { Write-Warning "Couldn't query Windows Update: $($_.Exception.Message)" }
}

function Quick-Fix {
  Clear-PrintQueue
  $null = Show-TopCpu
  Start-DefenderQuickScan
  Show-WindowsUpdateStatus
  Write-Host "`nQuickFix complete. If CPU is still high, run:`n  .\Fix-HighCPU.ps1  (interactive menu)" -ForegroundColor Yellow
}

function Menu {
  while ($true) {
    Write-Host "`nChoose an action:"
    Write-Host " 1) Clear print queue / reset print services"
    Write-Host " 2) Show top CPU processes (live sample)"
    Write-Host " 3) Kill CPU hogs over 15% (safe list)"
    Write-Host " 4) Start Windows Defender Quick Scan"
    Write-Host " 5) Show Windows Update status"
    Write-Host " 6) Disable print services (if you never print)"
    Write-Host " 7) Enable print services"
    Write-Host " 0) Exit"
    $choice = Read-Host "Select"
    switch ($choice) {
      '1' { Clear-PrintQueue }
      '2' { Show-TopCpu | Out-Null }
      '3' { Kill-CPUHogs -Threshold 15 }
      '4' { Start-DefenderQuickScan }
      '5' { Show-WindowsUpdateStatus }
      '6' { Disable-PrintServices }
      '7' { Enable-PrintServices }
      '0' { return }
      default { Write-Host "Invalid selection." }
    }
  }
}

# ---- Main ----
Assert-Admin

if ($DisablePrinting) { Disable-PrintServices; exit 0 }
if ($EnablePrinting)  { Enable-PrintServices;  exit 0 }
if ($QuickFix)        { Quick-Fix;             exit 0 }

Menu
