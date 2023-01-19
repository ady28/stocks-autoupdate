param(
    [switch]$NoDev
)

$ModList=Get-Content "$PSScriptRoot/modules.txt"

foreach($Module in $ModList)
{
    $Segments=$Module.Split(' ')

    if($NoDev -and ($Segments[2] -eq 'dev'))
    {
        continue
    }
    
    Install-Module -Name $Segments[0] -RequiredVersion $Segments[1] -Confirm:$false -Force -Scope AllUsers
}