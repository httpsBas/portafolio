param(
  [string]$Branch = "gh-pages",
  [switch]$SkipBuild,
  [switch]$NoPush
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
  param(
    [string]$FilePath,
    [string[]]$Arguments
  )

  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed: $FilePath $($Arguments -join ' ')"
  }
}

function Get-RepositoryBasePath {
  $repoUrl = (git remote get-url origin).Trim()

  if (-not $repoUrl) {
    return ""
  }

  if ($repoUrl -match '[:/]([^/:\s]+?)(?:\.git)?$') {
    $repoName = $Matches[1]

    if ($repoName -and $repoName -notmatch '^[^/]+\.github\.io$') {
      return "/$repoName"
    }
  }

  return ""
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$outDir = Join-Path $repoRoot "out"
$tempRoot = Join-Path $repoRoot ".tmp"
$worktreeDir = Join-Path $tempRoot "gh-pages-worktree"
$nvsPath = Join-Path $env:LOCALAPPDATA "nvs\nvs.cmd"
$basePath = Get-RepositoryBasePath

Push-Location $repoRoot

try {
  if (-not $SkipBuild) {
    if (Test-Path $nvsPath) {
      Invoke-Step "cmd.exe" @("/c", "set `"NEXT_PUBLIC_BASE_PATH=$basePath`" && call `"$nvsPath`" use 22.12.0 && npm run build")
    }
    else {
      Invoke-Step "cmd.exe" @("/c", "set `"NEXT_PUBLIC_BASE_PATH=$basePath`" && npm run build")
    }
  }

  if (-not (Test-Path $outDir)) {
    throw "Static export folder not found: $outDir"
  }

  New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

  if (Test-Path $worktreeDir) {
    & git worktree remove --force $worktreeDir 2>$null
    if (Test-Path $worktreeDir) {
      Remove-Item -LiteralPath $worktreeDir -Recurse -Force
    }
  }

  & git ls-remote --exit-code --heads origin $Branch *> $null
  $remoteBranchExists = $LASTEXITCODE -eq 0
  & git show-ref --verify --quiet "refs/heads/$Branch"
  $localBranchExists = $LASTEXITCODE -eq 0

  if ($remoteBranchExists -or $localBranchExists) {
    Invoke-Step "git" @("worktree", "add", "--force", $worktreeDir, $Branch)
  }
  else {
    Invoke-Step "git" @("worktree", "add", "--detach", $worktreeDir, "HEAD")
    Push-Location $worktreeDir
    try {
      Invoke-Step "git" @("checkout", "--orphan", $Branch)
    }
    finally {
      Pop-Location
    }
  }

  Get-ChildItem -LiteralPath $worktreeDir -Force |
    Where-Object { $_.Name -ne ".git" } |
    Remove-Item -Recurse -Force

  Copy-Item (Join-Path $outDir "*") $worktreeDir -Recurse -Force
  New-Item -ItemType File -Force -Path (Join-Path $worktreeDir ".nojekyll") | Out-Null

  Push-Location $worktreeDir
  try {
    Invoke-Step "git" @("add", "--all")
    $status = git status --porcelain

    if (-not $status) {
      Write-Host "No changes to publish on $Branch."

      if (-not $NoPush -and -not $remoteBranchExists) {
        Invoke-Step "git" @("push", "-u", "origin", $Branch)
      }
    }
    else {
      Invoke-Step "git" @("commit", "-m", "Deploy static site to GitHub Pages")

      if (-not $NoPush) {
        if ($remoteBranchExists) {
          Invoke-Step "git" @("push", "origin", $Branch)
        }
        else {
          Invoke-Step "git" @("push", "-u", "origin", $Branch)
        }
      }
    }
  }
  finally {
    Pop-Location
  }
}
finally {
  Push-Location $repoRoot
  try {
    & git worktree remove --force $worktreeDir 2>$null
  }
  finally {
    Pop-Location
    Pop-Location
  }
}
