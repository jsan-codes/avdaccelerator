param(
    [Parameter(Mandatory=$true)][string]$GitHubDestinationPAT,
    [Parameter(Mandatory=$true)][string]$ADOSourcePAT,
    [Parameter(Mandatory=$true)][string]$AzureRepoName,
    [Parameter(Mandatory=$true)][string]$ADOCloneURL,
    [Parameter(Mandatory=$true)][string]$GitHubCloneURL
)

# --- Variables ---
$workingDir = Join-Path $env:TEMP "RepoSync"
$repoDir = Join-Path $workingDir "$AzureRepoName.git"

# Construct Clone URLs with PAT
$githubURL = "https://$($GitHubDestinationPAT)@$($GitHubCloneURL -replace '^https://')"
$adoURL    = "https://$($ADOSourcePAT)@$($ADOCloneURL -replace '^https://')"

# Output debug info
Write-Host "GitHub URL: $githubURL"
Write-Host "Azure DevOps URL: $adoURL"
Write-Host "Working Dir: $workingDir"
Write-Host "Repo Dir: $repoDir"

# Clean previous directories
if (Test-Path $workingDir) {
    Remove-Item -Path $workingDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -Path $workingDir -ItemType Directory | Out-Null

# Clone GitHub repo as mirror (source is GitHub)
Set-Location $workingDir
git clone --mirror $githubURL $repoDir

# Navigate to cloned repo
Set-Location $repoDir

# Configure Azure DevOps as secondary remote
git remote add azure $adoURL

# Push all refs to Azure DevOps (destination)
git push azure --mirror --force

Write-Host "**GitHub repo synced to Azure DevOps repo successfully!**"

# Cleanup working directory
Set-Location $workingDir
Remove-Item -Path $repoDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Job completed, cleanup done."
