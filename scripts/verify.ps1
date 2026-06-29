[CmdletBinding()]
param(
    [ValidateSet("quick", "full")]
    [string]$Mode = "full",

    [switch]$SkipGitHub
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$reportDirectory = Join-Path $repoRoot "verification-reports"
$results = [System.Collections.Generic.List[object]]::new()

Set-Location $repoRoot

function Add-Result {
    param(
        [string]$Name,
        [string]$Status,
        [double]$DurationSeconds,
        [string]$Detail
    )

    $results.Add([pscustomobject]@{
        name = $Name
        status = $Status
        duration_seconds = [Math]::Round($DurationSeconds, 2)
        detail = $Detail
    })
}

function Invoke-VerificationStep {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "==> $Name" -ForegroundColor Cyan
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        $output = @(& $Action 2>&1)
        $timer.Stop()
        $detail = ($output | Select-Object -Last 20) -join [Environment]::NewLine
        Add-Result $Name "PASS" $timer.Elapsed.TotalSeconds $detail
        Write-Host "PASS ($([Math]::Round($timer.Elapsed.TotalSeconds, 1))s)" -ForegroundColor Green
    }
    catch {
        $timer.Stop()
        $message = $_.Exception.Message
        if (-not $message) {
            $message = ($_ | Out-String).Trim()
        }
        if ($output) {
            $message = (($output | Select-Object -Last 20) -join [Environment]::NewLine) +
                [Environment]::NewLine + $message
        }
        Add-Result $Name "FAIL" $timer.Elapsed.TotalSeconds $message
        Write-Host "FAIL ($([Math]::Round($timer.Elapsed.TotalSeconds, 1))s)" -ForegroundColor Red
        Write-Host $message -ForegroundColor DarkRed
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

function Assert-ExitCode {
    param([string]$CommandName)
    if ($LASTEXITCODE -ne 0) {
        throw "$CommandName failed with exit code $LASTEXITCODE"
    }
}

function Resolve-BootstrapPython {
    $bundled = Join-Path $env:USERPROFILE `
        ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
    if (Test-Path -LiteralPath $bundled) {
        return $bundled
    }

    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python) {
        return $python.Source
    }

    throw "Python not found. Install Python 3.12 or run this repository from Codex once."
}

function Ensure-Docker {
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        throw "Docker CLI not found. Install Docker Desktop."
    }

    & docker info --format "{{.ServerVersion}}" 2>$null
    if ($LASTEXITCODE -eq 0) {
        return
    }

    $desktop = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (-not (Test-Path -LiteralPath $desktop)) {
        throw "Docker engine is unavailable and Docker Desktop was not found."
    }

    Write-Host "Starting Docker Desktop..."
    Start-Process -FilePath $desktop -WindowStyle Hidden
    for ($attempt = 0; $attempt -lt 60; $attempt++) {
        Start-Sleep -Seconds 2
        & docker info --format "{{.ServerVersion}}" 2>$null
        if ($LASTEXITCODE -eq 0) {
            return
        }
    }

    throw "Docker Desktop did not become ready within 120 seconds."
}

$venvPython = Join-Path $repoRoot ".venv\Scripts\python.exe"

Invoke-VerificationStep "Python environment" {
    if (-not (Test-Path -LiteralPath $venvPython)) {
        $bootstrapPython = Resolve-BootstrapPython
        & $bootstrapPython -m venv (Join-Path $repoRoot ".venv")
        Assert-ExitCode "python -m venv"
    }
    & $venvPython -m pip install -e ".[test]"
    Assert-ExitCode "pip install"
}

Invoke-VerificationStep "Python tests" {
    & $venvPython -m pytest -q -p no:cacheprovider
    Assert-ExitCode "pytest"
}

Invoke-VerificationStep "Ledger signatures" {
    & $venvPython -B tools\cli.py verify-event `
        ledger\events\genesis-proof-verified.json `
        keys\ledger-signing.pub.pem
    Assert-ExitCode "genesis proof signature"

    & $venvPython -B tools\cli.py verify-event `
        ledger\events\not-permitted-implies-not-obligatory-accepted.json `
        keys\ledger-signing.pub.pem
    Assert-ExitCode "corollary signature"
}

Invoke-VerificationStep "Lean" {
    $localElanHome = Join-Path $repoRoot "provers\lean\.provers\elan-home"
    $localLake = Join-Path $localElanHome "bin\lake.exe"
    if (Test-Path -LiteralPath $localLake) {
        $env:ELAN_HOME = $localElanHome
        $lake = $localLake
    }
    else {
        $lakeCommand = Get-Command lake -ErrorAction SilentlyContinue
        if (-not $lakeCommand) {
            throw "Lake not found. Install the toolchain from provers/lean/lean-toolchain."
        }
        $lake = $lakeCommand.Source
    }

    Push-Location (Join-Path $repoRoot "provers\lean")
    try {
        if ($Mode -eq "full") {
            & $lake clean
            Assert-ExitCode "lake clean"
        }
        & $lake build
        Assert-ExitCode "lake build"
    }
    finally {
        Pop-Location
    }
}

if ($Mode -eq "full") {
    Invoke-VerificationStep "Docker engine" {
        Ensure-Docker
    }

    Invoke-VerificationStep "Isabelle" {
        $image = "makarius/isabelle@sha256:9bd33b183c399327c5d554fc8cde27c29b5d2b20cdc6fe7a604caa3f951018fc"
        & docker run --rm `
            --mount "type=bind,source=$repoRoot,target=/workspace,readonly" `
            $image build -D /workspace/provers/isabelle TheoremDNA
        Assert-ExitCode "Isabelle build"
    }

    Invoke-VerificationStep "Rocq" {
        $image = "rocq/rocq-prover@sha256:29262a1a00095990b25b2f511147671bdda260f3e836a0e94737f75d5c8fb9a1"
        & docker run --rm `
            --mount "type=bind,source=$repoRoot,target=/workspace" `
            --workdir /workspace/provers/rocq `
            $image rocq makefile -f _RocqProject -o Makefile
        Assert-ExitCode "rocq makefile"

        & docker run --rm `
            --mount "type=bind,source=$repoRoot,target=/workspace" `
            --workdir /workspace/provers/rocq `
            $image make -f Makefile clean
        Assert-ExitCode "Rocq clean"

        & docker run --rm `
            --mount "type=bind,source=$repoRoot,target=/workspace" `
            --workdir /workspace/provers/rocq `
            $image make -f Makefile -j2
        Assert-ExitCode "Rocq build"
    }

    Invoke-VerificationStep "GitHub workflow syntax" {
        $image = "rhysd/actionlint@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667"
        & docker run --rm `
            --mount "type=bind,source=$repoRoot,target=/repo,readonly" `
            --workdir /repo `
            $image
        Assert-ExitCode "actionlint"
    }
}

if (-not $SkipGitHub) {
    Invoke-VerificationStep "GitHub checks" {
        $gh = Get-Command gh -ErrorAction SilentlyContinue
        if (-not $gh) {
            throw "GitHub CLI not found. Install gh or rerun with -SkipGitHub."
        }
        & gh auth status
        Assert-ExitCode "gh auth status"

        $currentCommit = (& git rev-parse HEAD).Trim()
        Assert-ExitCode "git rev-parse"

        $pr = & gh pr view --json number --jq ".number" 2>$null
        if ($LASTEXITCODE -eq 0 -and $pr) {
            & gh pr checks $pr
            Assert-ExitCode "gh pr checks"
            return
        }

        $runsJson = & gh run list --commit $currentCommit --limit 20 --json conclusion,status,name,url
        Assert-ExitCode "gh run list"
        $runsValue = $runsJson | ConvertFrom-Json
        $runs = @($runsValue)
        if ($runs.Count -gt 0) {
            $failedRuns = @($runs | Where-Object {
                $_.status -ne "completed" -or $_.conclusion -ne "success"
            })
            if ($failedRuns.Count -gt 0) {
                $summary = ($failedRuns | ForEach-Object {
                    "$($_.name): status=$($_.status), conclusion=$($_.conclusion), url=$($_.url)"
                }) -join [Environment]::NewLine
                throw "GitHub runs are not all successful:$([Environment]::NewLine)$summary"
            }
            Write-Output "All GitHub runs for $currentCommit passed."
            return
        }

        $mergedPrsJson = & gh pr list --state merged --base main --limit 20 `
            --json number,title,mergeCommit,url
        Assert-ExitCode "gh pr list"
        $mergedPrsValue = $mergedPrsJson | ConvertFrom-Json
        $mergedPrs = @($mergedPrsValue)
        $mergedPr = $mergedPrs | Where-Object {
            $_.mergeCommit.oid -eq $currentCommit
        } | Select-Object -First 1
        if (-not $mergedPr) {
            Write-Output "No pull request, workflow run, or merged PR found for $currentCommit."
            Write-Output "GitHub checks will be enforced after this branch has a pull request or workflow run."
            return
        }

        & gh pr checks $mergedPr.number
        Assert-ExitCode "gh pr checks merged PR"
    }
}

$overall = if ($results.status -contains "FAIL") { "FAIL" } else { "PASS" }
$commit = (& git rev-parse HEAD).Trim()
$report = [pscustomobject]@{
    schema_version = "0.1.0"
    generated_at = [DateTime]::UtcNow.ToString("o")
    repository = $repoRoot
    commit = $commit
    mode = $Mode
    overall = $overall
    results = $results
}

New-Item -ItemType Directory -Force -Path $reportDirectory | Out-Null
$reportPath = Join-Path $reportDirectory "last-report.json"
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $reportPath -Encoding UTF8
$htmlReportPath = Join-Path $reportDirectory "last-report.html"

try {
    & $venvPython -B tools\cli.py render-verification-report $reportPath `
        --output-dir $reportDirectory | Out-Null
}
catch {
    Write-Host "Could not render HTML report: $($_.Exception.Message)" `
        -ForegroundColor Yellow
}

Write-Host ""
Write-Host "THEOREM DNA VERIFICATION" -ForegroundColor White
Write-Host ("=" * 58)
foreach ($result in $results) {
    $color = if ($result.status -eq "PASS") { "Green" } else { "Red" }
    Write-Host ("{0,-28} {1,-5} {2,7:N1}s" -f `
        $result.name, $result.status, $result.duration_seconds) -ForegroundColor $color
}
Write-Host ("=" * 58)
Write-Host "Report: $reportPath"
if (Test-Path -LiteralPath $htmlReportPath) {
    Write-Host "HTML report: $htmlReportPath"
}

if ($overall -eq "PASS") {
    Write-Host "OVERALL RESULT: PASS" -ForegroundColor Green
    exit 0
}

Write-Host "OVERALL RESULT: FAIL" -ForegroundColor Red
exit 1
