
#Check if required inputs are null/empty
if ([string]::IsNullOrEmpty($env:TableName)) {
    Write-Error "TableName input is required"
    throw "TableName input is required"
}

if ([string]::IsNullOrEmpty($env:ClientId)) {
    Write-Error "ClientId input is required"
    throw "ClientId input is required"
}

if ([string]::IsNullOrEmpty($env:ClientSecret)) {
    Write-Error "ClientSecret input is required"
    throw "ClientSecret input is required"
}

if ([string]::IsNullOrEmpty($env:TenantId)) {
    Write-Error "TenantId input is required"
    throw "TenantId input is required"
}

if ([string]::IsNullOrEmpty($env:LookupServiceIdentifier)) {
    Write-Error "LookupServiceIdentifier input is required"
    throw "LookupServiceIdentifier input is required"
}

if ([string]::IsNullOrEmpty($env:HostURL)) {
    Write-Error "HostURL input is required"
    throw "HostURL input is required"
}

$TableName = $env:TableName
if ([string]::IsNullOrEmpty($env:Query)) {
    Write-Host "Query parameter is null, setting it to empty string"
    $Query = ''
}
else {
    $Query = $env:Query
}

if ([string]::IsNullOrEmpty($env:FirstOrDefault)) {
    Write-Host "FirstOrDefault flag is null/empty, setting it to false"
    $FirstOrDefault = 'false'
}
else {
    $env:FirstOrDefault
    $FirstOrDefault = $env:FirstOrDefault.toLower()
    if ($FirstOrDefault -eq 'true') {
        Write-Host "FirstOrDefault is set to true, updated query to return only top item"
        $Query = $Query + '&$top=1'
    }
}

Write-Host "Fetching lookup details from Table: $($TableName)"
Write-Host "Query: $($Query)"


#################################################################################################################
Write-Host "Getting access token"

try {
    $requestURL = "https://login.microsoftonline.com/$($env:TenantId)/oauth2/token"

    $reqBody = @{
        resource      = $env:LookupServiceIdentifier; 
        grant_type    = "client_credentials"; 
        client_id     = $env:ClientId; 
        client_secret = $env:ClientSecret
    }

    $res = Invoke-RestMethod -Method POST -Uri $requestURL -Body $reqBody -ContentType "application/x-www-form-urlencoded"

    if (![string]::IsNullOrEmpty($res)) {
        $access_token = $res.access_token
        if ($access_token) {
            Write-Host "Access token fetched successfully"
        }    
    }
    else {
        Write-Error "Unable to fetch the access token"
        throw "Unable to fetch the access token"
    }
}
catch {
    Write-Error "An exception occurred while fetching access token for lookup: $($_.Exception.Message)"
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

    $lookupResponse

    if ($lookupResponse) {
        if ($FirstOrDefault -eq 'true') {
            Write-Host "FirstOrDefault is set to true, returning response object"
            $LkupValue = $lookupResponse | ConvertTo-Json -Compress
        }
        else {
            Write-Host "FirstOrDefault is set to false, returning output as an array"
            $LkupValue = $lookupResponse | ConvertTo-Json -Compress -AsArray
            #$LkupValue
        }
    }
    
    $LkupValue

    Write-Host "Setting JSON Object/Array as Github output"
    Write-Output "LookupValue=$LkupValue" >> $env:GITHUB_OUTPUT

    #$env:GITHUB_OUTPUT
}
catch {
    Write-Error "An exception occurred while fetching lookup values $($_.Exception.Message)"
    throw "An exception occurred while fetching lookup values $($_.Exception.Message)"
}
