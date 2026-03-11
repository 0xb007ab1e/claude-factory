# ==============================================================================
# ARTIFACT: platforms/windows/install.ps1
# DESCRIPTION: Windows-specific installer for the AI Factory.
#              Handles winget/scoop package installation and installs
#              prerequisites: git, curl, Docker Desktop or podman.
# USAGE: .\platforms\windows\install.ps1
# ==============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FactoryRoot = (Resolve-Path "$ScriptDir\..\..")

Write-Host "AI Factory - Windows installer"
Write-Host "Factory root: $FactoryRoot"
Write-Host ""
Write-Host "TODO: Implement Windows-specific prerequisite installation."
Write-Host "      - Install winget packages: Git.Git, Docker.DockerDesktop"
Write-Host "      - Or use scoop: scoop install git docker"
Write-Host "      - Run WSL2 + Ubuntu, then: ./bin/factory-bootstrap.sh"
