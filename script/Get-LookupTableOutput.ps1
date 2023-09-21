param(
    [string] $TableName,
    [string] $Query,
    [string] $Column,
    [string] $TenantId,
    [string] $ClientId,
    [string] $ClientSecret,
    [string] $ServiceIdentifier
)

$GitHubToken

$TableName
$Column
$Query

Write-Host "Fetching lookup details from Table: $($TableName)"
Write-Host "Query: $($Query)"


#################################################################################################################
Write-Host "Getting access token"

$env:LookupResourceId
try {
    $res = Invoke-RestMethod -Method POST `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/token" `
        -Body @{ resource = $ServiceIdentifier; grant_type = "client_credentials"; client_id = $ClientId; client_secret = $ClientSecret }`
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
    $Uri = "https://staging-dna-lkup-api.azurewebsites.net/api/Lookup/odata/$($TableName)?`$filter=$Query"

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


# try {
#     $Uri = "https://api.github.com/repositories/672865066/environments/Staging/secrets"
#     $reqHeaders = @{
#         "Authorization"        = "Bearer $($GitHubToken)";
#         "Accept"               = "application/vnd.github+json";
#         "X-GitHub-Api-Version" = "2022-11-28"
#     }
#     $res = Invoke-RestMethod -Method GET -Uri $Uri -Headers $reqHeaders
#     $res
# }
# catch {
#     $_
# }
