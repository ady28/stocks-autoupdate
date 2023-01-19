Function Get-Env
{
    $Version=(Get-Module dotenv -ListAvailable | Select-Object -ExpandProperty Version).ToString()
    Import-Module "/usr/local/share/powershell/Modules/dotenv/$Version/dotenv.psm1"
    Set-DotEnv -path "$PSScriptRoot/.env"
}

Function Get-DBCred
{
    if($Env:APP_ENV -eq 'dev')
    {
        $o=[pscustomobject]@{
            DB_USER = $Env:MONGO_USER
            DB_PASS = $Env:MONGO_PASSWORD
        }
    }
    else
    {
        $u=Get-Content '/run/secrets/stocksmongouser'
        $p=Get-Content '/run/secrets/stocksmongopassword'
        $o=[pscustomobject]@{
            DB_USER = $u.Replace("`n","")
            DB_PASS = $p.Replace("`n","")
        }
    }

    $o
}

Function Get-StocksFromDB
{
    $DBCreds=Get-DBCred

    Import-Module mdbc
    Connect-Mdbc -ConnectionString "mongodb://$($DBCreds.DB_USER):$($DBCreds.DB_PASS)@$($Env:MONGO_SERVER):$($Env:MONGO_PORT)"
    $db=Get-MdbcDatabase -Name $Env:MONGO_DB
    $col=Get-MdbcCollection -Name 'stocks' -Database $db
    $Stocks=Get-MdbcData -Collection $col -Sort '{lastupdated : 1}' -First $Env:NO_STOCKS -As PS -Project '{ticker : 1, _id : 0}' | Select-Object -ExpandProperty ticker
    $Stocks
}

Function Update-Stock
{
    param(
        [string]$Stock
    )

    Invoke-RestMethod -Uri "http://$($Env:STOCK_API_NAME):$($Env:STOCK_API_PORT)/v1/import/$Stock" | Out-Null
    Start-Sleep -Seconds 15
}