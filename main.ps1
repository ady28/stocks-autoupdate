# Install-Module -Name dotenv
# Install-Module mdbc

. $PSScriptRoot\functions.ps1

#If the APP_ENV variable is dev or $null then load .env file
if(($null -eq $Env:APP_ENV) -or ($Env:APP_ENV -eq 'dev'))
{
    Get-Env
}

$Stocks=Get-StocksFromDB

foreach($Stock in $Stocks)
{
    Update-Stock -Stock $Stock
}