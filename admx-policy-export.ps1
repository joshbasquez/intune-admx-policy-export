
<#
Script to export intune configuration policies.

Version 1.1 - 2025 NOV.11 First version of JoshBasquez fork, uses delegated permissions (requires admin interactive browser login).

Fork based on github.com/sandytsang/MSIntune. Updated to use app registration and admin delegated permissions.

Other credits to
https://scconfigmgr.com,https://msendpointmgr.com/
@powers-hell, @onpremcloudguy, 

alternate endpoints:

AzureCommercial
 -login:   login.microsoftonline.com
 -baseurl: graph.microsoft.com
AzureGov
 -login:   login.microsoftonline.us
 -baseurl: graph.microsoft.us
AzureUSGovDoD
 -login:   login.microsoftonline.us
 -baseurl: dod-graph.microsoft.us
   
#>

# set variables
$TenantId   = "tenant-id-number"   # e.g., "contoso.onmicrosoft.com" or GUID
$ClientId   = "entra-appId-number" # Application (client) ID from Entra app Registrations
$loginURL = "https://login.microsoftonline.com"
$baseURL = "https://graph.microsoft.com"
$ExportPath = "C:\IntuneExport"

# NOTE: permissions needed for clientID
# Microsoft Graph\DeviceManagementConfiguration.ReadWrite.All (delegated)

########### Authentication via DeviceCode

$DeviceCodeResponse = Invoke-RestMethod -Method POST `
    -Uri "$loginURL/$TenantId/oauth2/v2.0/devicecode" `
    -Body @{
        client_id = $ClientId
        scope     = "$baseURL/.default"
    } -ContentType "application/x-www-form-urlencoded"

if (-not $DeviceCodeResponse.device_code) {
    Write-Error "Failed to get device code. Check TenantId, ClientId, and network."
    exit 1
}

Write-Host "================================================================"
Write-Host "To sign in, open the following URL in a browser and enter the code:"
Write-Host $DeviceCodeResponse.verification_uri -f yellow
Write-Host "Code: $($DeviceCodeResponse.user_code)" -ForegroundColor yellow
Write-Host "================================================================"
Write-Host "Waiting for you to complete authentication..." -ForegroundColor Cyan

# Poll for token
$Token = $null
$PollInterval = $DeviceCodeResponse.interval
$ExpiryTime = (Get-Date).AddSeconds($DeviceCodeResponse.expires_in)

while ((Get-Date) -lt $ExpiryTime) {
    try {
        $TokenResponse = Invoke-RestMethod -Method POST `
            -Uri "$loginURL/$TenantId/oauth2/v2.0/token" `
            -Body @{
                grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
                client_id   = $ClientId
                device_code = $DeviceCodeResponse.device_code
            } -ContentType "application/x-www-form-urlencoded"

        if ($TokenResponse.access_token) {
            $Token = $TokenResponse
            break
        }
    }
    catch {
        # Expected until user completes authentication
        if ($_.ErrorDetails.Message -notmatch "authorization_pending") {
            Write-Error "Error retrieving token: $($_.Exception.Message)"
            exit 1
        }
    }
    Start-Sleep -Seconds $PollInterval
}

if (-not $Token) {
    Write-Error "Authentication timed out or failed."
    exit 1
}

Write-Host "`n✅ Authentication successful!" -ForegroundColor Green
Write-Host "Access Token (truncated): $($Token.access_token.Substring(0,40))..." -ForegroundColor Yellow

$token = $token.access_token
$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-Type" = "application/json"
}
write-host "graph API connected via delegated permissions and appID $clientID" -f Yellow

####### end authentication


########### export group policy

####### query for group Policy configurations
# get the group policy configurations
write-host "`n`nGroup Policy based configuration policies:" -f yellow
$queryURL = "$baseURL/beta/deviceManagement/groupPolicyConfigurations/"
$response = Invoke-RestMethod -Uri $queryUrl -Headers $headers
$response.value | ft id, displayname, createdDateTime
write-host "[NOTE: Ensure policy displayname contains no special characters before policy export]" -f yellow

# TODO: prompt whether to export all policies or single policyID

$policyID = read-host "Enter the id of the policy to export"

write-host "Collecting group policy configuration id: $policyID" -f yellow 
$queryURL = "$baseURL/beta/deviceManagement/groupPolicyConfigurations/$policyID"
$response = Invoke-RestMethod -Uri $queryUrl -Headers $headers
$foldername = $response.displayName

write-host "Creating folder for policy $foldername..."
New-Item "$ExportPath\$($FolderName)" -ItemType Directory -Force


#### Get defValues
$uri = "$baseURL/beta/deviceManagement/groupPolicyConfigurations/$policyID/definitionValues"
$GroupPolicyConfigurationsDefinitionValues = (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get).Value

foreach ($GroupPolicyConfigurationsDefinitionValue in $GroupPolicyConfigurationsDefinitionValues)
	{
        $defID = $GroupPolicyConfigurationsDefinitionValue.id 
        write-host "Processing definitionID " -f yellow 

        #### get a defvalue definition
        $uri = "$baseURL/beta/deviceManagement/groupPolicyConfigurations/$policyID/definitionValues/$defID/definition"
        $DefinitionValuedefinition = (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get)
		$DefinitionValuedefinitionID = $DefinitionValuedefinition.id
		$DefinitionValuedefinitionDisplayName = $DefinitionValuedefinition.displayName
        
        #### get dvaluePresentationValues EXPANDEDPRESENTATION
        $uri = "$baseURL/beta/deviceManagement/groupPolicyConfigurations/$policyID/definitionValues/$defID/presentationValues?`$expand=presentation"
        $GroupPolicyDefinitionsPresentations = (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get).Value.presentation

		#### get dvaluePresentationValues LISTVALUES
		$uri = "$baseURL/beta/deviceManagement/groupPolicyConfigurations/$policyID/definitionValues/$defID/presentationValues"
        $DefinitionValuePresentationValues = (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get).Value

        ### build object to store policy data

		$OutDef = New-Object -TypeName PSCustomObject
        $OutDef | Add-Member -MemberType NoteProperty -Name "definition@odata.bind" -Value "$baseURL/beta/deviceManagement/groupPolicyDefinitions('$definitionValuedefinitionID')"
        $OutDef | Add-Member -MemberType NoteProperty -Name "enabled" -value $($GroupPolicyConfigurationsDefinitionValue.enabled.tostring().tolower())
        if ($DefinitionValuePresentationValues) {
            $i = 0
            $PresValues = @()
            foreach ($Pres in $DefinitionValuePresentationValues) {
                $P = $pres | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version
                $GPDPID = $groupPolicyDefinitionsPresentations[$i].id
                $P | Add-Member -MemberType NoteProperty -Name "presentation@odata.bind" -Value "$baseURL/beta/deviceManagement/groupPolicyDefinitions('$definitionValuedefinitionID')/presentations('$GPDPID')"
                $PresValues += $P
                $i++
            }
            $OutDef | Add-Member -MemberType NoteProperty -Name "presentationValues" -Value $PresValues
        }
		$FileName = (Join-Path $DefinitionValuedefinition.categoryPath $($definitionValuedefinitionDisplayName)) -replace '\[|\]|\<|\>|:|"|/|\\|\||\?|\*', "_"
		$OutDefjson = ($OutDef | ConvertTo-Json -Depth 10).replace("\u0027","'")
		$OutDefjson | Out-File -FilePath "$ExportPath\$($folderName)\$fileName.json" -Encoding ascii
	}

####### EXPORT SECTION - END ########
