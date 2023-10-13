
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

if ([string]::IsNullOrEmpty($env:FirstOrDefault)) {
    Write-Host "$env:FirstOrDefault is empty, setting it to false"
    $FirstOrDefault = 'false'
}
else {
    $env:FirstOrDefault
    $FirstOrDefault = $env:FirstOrDefault.toLower()
    if ($FirstOrDefault -eq 'true') {
        $Query = $Query + '&$top=1'
    }
}

Write-Host "Fetching lookup details from Table: $($TableName)"
Write-Host "Query: $($Query)"


#################################################################################################################
Write-Host "Getting access token"

$env:LookupResourceId
try {
    $requestURL = "https://login.microsoftonline.com/$($env:TenantId)/oauth2/token"

    $reqBody = @{
        resource      = $env:LookupServiceIdentifier; 
        grant_type    = "client_credentials"; 
        client_id     = $env:ClientId; 
        client_secret = $env:ClientSecret
    }

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
    $Uri

    $reqHeaders = @{
        "Authorization" = "Bearer $($access_token)";
        "Accept"        = "application/json";
    }

    $lookupResponse = Invoke-RestMethod -Method GET -Uri $Uri -Headers $reqHeaders

    #$lookupResponse

    if ($lookupResponse) {
        if ($FirstOrDefault -eq 'true') {
            Write-Host "FirstOrDefault is set to true, returning first item from the response array"
            #$LkupValue = $lookupResponse[0]
            $LkupValue = $lookupResponse | ConvertTo-Json -Compress
        }
        else {
            Write-Host "FirstOrDefault is set to false, returning output as an array"
            $lookupResponse = [array]$lookupResponse
            $lookupResponse
            $LkupValue = $lookupResponse | ConvertTo-Json -Compress
        }
    }
    
    $LkupValue

    Write-Output "LookupValue=$LkupValue" >> $env:GITHUB_OUTPUT

    $env:GITHUB_OUTPUT
}
catch {
    Write-Host "An exception occurred while fetching lookup values $($_.Exception.Message)"
}
