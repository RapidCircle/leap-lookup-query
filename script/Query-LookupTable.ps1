param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $TableName,

    [Parameter(Mandatory = $false)]
    [string] $Query,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $TenantId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ClientId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ClientSecret,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $LookupServiceIdentifier
)

#$GitHubToken

$TableName
$Query
$LookupServiceIdentifier

Write-Host "Fetching lookup details from Table: $($TableName)"
Write-Host "Query: $($Query)"


#################################################################################################################
Write-Host "Getting access token"

$env:LookupResourceId
try {
    $res = Invoke-RestMethod -Method POST `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" `
        -Body @{ resource = $LookupServiceIdentifier; grant_type = "client_credentials"; client_id = $ClientId; client_secret = $ClientSecret }`
        -ContentType "application/x-www-form-urlencoded"
    $access_token = $res.access_token
    #$access_token
    if ($access_token) {
        Write-Host "Access token fetched successfully"
    }
}
catch {
    Write-Host "An exception occurred while fetching access token for lookup $($_.Exception.Message)"
}

#################################################################################################################
#################################################################################################################

Write-Host "Getting lookup values"
try {
    $Uri = "$($env:HostURL)/api/Lookup/odata/$($TableName)?`$filter=$Query"

    $reqHeaders = @{
        "Authorization" = "Bearer $($access_token)";
        "Accept"        = "application/json";
    }

    $lookupResponse = Invoke-RestMethod -Method GET -Uri $Uri -Headers $reqHeaders

    $lookupResponse

    if ($lookupResponse) {
        $LkupValue = $lookupResponse | ConvertTo-Json -Compress
    }
    
    $LkupValue

    Write-Output "LookupValue=$LkupValue" >> $env:GITHUB_OUTPUT

    $env:GITHUB_OUTPUT
}
catch {
    Write-Host "An exception occurred while fetching access token for lookup $($_.Exception.Message)"
}
