Param(

    [Parameter(Mandatory=$true, HelpMessage='File path to check for duplicates.')]
    [ValidateScript({ Test-Path -Path $_ -PathType 'Container' })]
    [String]$UserPath,

    [Parameter(Mandatory=$false, HelpMessage='Type "Remove" to move duplicates to new file for deletion. Leave empty to just show duplicates')]
    [String]$RemoveFiles,

    [Parameter(Mandatory=$false, HelpMessage='Directory to move deleted files to. Default: "DELETE ME"')]
    [String]$RemovalDirectoryName = "Remove Me"

)

$Files = Get-ChildItem -Path $UserPath -File |
Where-Object {$_.Length -lt 50MB} |
Get-FileHash -Algorithm SHA256 |
Group-Object 'Hash' |
Where-Object {$_.Count -gt 1} | 
ForEach-Object {
    $_.Group.Path |
    select -First ($_.Count -1)
}


Write-Output($Files)

if ($RemoveFiles.ToLower() -eq 'remove'){
    
    $NewDirectory = mkdir $RemovalDirectoryName
    ForEach ($File in $Files){
        Move-Item $File $NewDirectory
    }
    Write-Output ("Duplicate files have been moved to:", $NewDirectory.FullName)
}