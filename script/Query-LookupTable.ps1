
#$GitHubToken

Write-Host "$env:TableName"
Write-Host "$env:Query"

$TableName = $env:TableName
if ([string]::IsNullOrEmpty($env:Query)) {
    $Query = ''
}
else {
    $Query = $env:Query
}

$LookupServiceIdentifier = "$env:LookupServiceIdentifier"
$ClientId = "$env:ClientId"
$ClientSecret = "$env:ClientSecret"
$TenantId = "$env:TenantId"

Write-Host "Fetching lookup details from Table: $($TableName)"
Write-Host "Query: $($Query)"

Write-Host "LookupServiceIdentifier: $($LookupServiceIdentifier)"
Write-Host "TenantId: $($TenantId)"
Write-Host "ClientId: $($ClientId)"
Write-Host "ClientSecret: $($ClientSecret)"


#################################################################################################################
Write-Host "Getting access token"

$env:LookupResourceId
try {
    $requestURL = "https://login.microsoftonline.com/$($TenantId)/oauth2/token"
    Write-Host "Request URL: $($requestURL)"

    $reqBody = @{
        resource      = $LookupServiceIdentifier; 
        grant_type    = "client_credentials"; 
        client_id     = $ClientId; 
        client_secret = $ClientSecret
    }

    Write-Host "Request Body: $($reqBody)"
    $res = Invoke-RestMethod -Method POST -Uri $requestURL -Body $reqBody -ContentType "application/x-www-form-urlencoded"

    Write-Host "Response: $($res)"
    $access_token = $res.access_token
    #$access_token
    if ($access_token) {
        Write-Host "Access token fetched successfully"
    }
}
catch {
    Write-Host "An exception occurred while fetching access token for lookup: $($_.Exception.Message)"
    throw "An exception occurred while fetching access token for lookup: $($_.Exception.Message)"
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
