## Establish API connection
$tenantId = '######################' ### Paste your tenant ID here
$appId = '######################' ### Paste your Application ID here
$appSecret = '######################' ### Paste your Application secret here

$resourceAppIdUri = 'https://api.####center.microsoft.com'
$oAuthUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$body = [Ordered] @{
    resource      = "$resourceAppIdUri"
    client_id     = "$appId"
    client_secret = "$appSecret"
    grant_type    = "client_credentials"
     
}
$authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $body -ErrorAction Stop
$token = $authResponse.access_token

# Buile Headers
$headers = @{
    'Content-Type' = 'application/json'
    Accept         = 'application/json'
    Authorization  = "Bearer $token"
}
# Build tag body
function edit-tag ($tagv, $taga) {
    $Body = [Ordered]@{
        "Value"  = $tagv;
        "Action" = $taga;
    }
    $Body
}

# Query API for latest device data
function get-devices {
    $global:sec_centre_query = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token)" } -uri "https://api-us.####center.windows.com/api/machines" -Method Get      
    $global:inactive_devices = $sec_centre_query.value | Where-Object { $_.healthStatus -eq 'Inactive' }
}

function tag-action ($deviceGroup, $tag, $action) {

    foreach ($d in $deviceGroup) {
        $MachineId = $d.id
        $url = “https://api.####center.microsoft.com/api/machines/$MachineId/tags” 
        Invoke-WebRequest -Method Post -Uri $url -Headers $headers -Body (edit-tag "$tag" "$action" | ConvertTo-Json) -ContentType “application/json” -ErrorAction Stop
        $output = New-Object PSObject -Property ([Ordered]@{
            'Id'                  = $d.id
            'DeviceName'          = $d.computerDnsName
            'healthStatus'        = $d.healthStatus
            'Current machineTags' = $d.machineTags | Out-String
            'New machineTags'     = $tag
            'Action'              = $action
        })
        $output | Export-Excel -Path "$($home)\sec_centre_device_tagging.xlsx" -AutoSize -TableName Report -Append
    
    }

    

}

# Call function
get-devices

## Get Incorectly Tagged Devices

$incorrectly_tagged_inactive_devices = $sec_centre_query.value | Where-Object { $_.healthStatus -eq 'Active' -and $_.machineTags -like 'Inactive' }
tag-action -deviceGroup $incorrectly_tagged_inactive_devices -tag Inactive -action Remove

# Refresh Data
get-devices

## Get Devices not already tagged as inactive
$inactive_devices_not_tagged = $sec_centre_query.value | Where-Object { $_.healthStatus -eq 'Inactive' -and $_.machineTags -notcontains 'Inactive' } 
tag-action -deviceGroup $inactive_devices_not_tagged -tag Inactive -action Add

# Refresh Data
get-devices

$Win10_11 = $sec_centre_query.value | Where-Object { $_.osPlatform -eq 'Windows10' -or $_.osPlatform -eq 'Windows11' -and $_.healthStatus -eq 'Active' }

# Tag ###################### devices
$MDM_Laptop_#### = $Win10_11 | Where-Object { $_.computerDnsName -like '####*' -and $_.machineTags -notcontains '####' }
tag-action -deviceGroup $MDM_Laptop_#### -tag #### -action Add

# Tag ###################### devices
$MDM_Desktop_#### = $Win10_11 | Where-Object { $_.computerDnsName -like 'dtopuk*' -and $_.machineTags -notcontains 'DtopUK' }
tag-action -deviceGroup $MDM_Desktop_#### -tag DtopUK -action Add

# Tag ###################### devices
$MDM_Laptop_#### = $Win10_11 | Where-Object { $_.computerDnsName -like '####*' -and $_.machineTags -notcontains '####' }
tag-action -deviceGroup $MDM_Laptop_#### -tag #### -action Add

# Tag ###################### devices
$mdm_desktop_CstDev = $Win10_11 | Where-Object { $_.computerDnsName -like 'cstdev*' -and $_.machineTags -notcontains 'cstdev' }
tag-action -deviceGroup $mdm_desktop_CstDev -tag cstdev -action Add


# iterate through Windows Servers
$all_servers = $sec_centre_query.value | Where-Object { $_.osPlatform -match "WindowsServer*" -or $_.osPlatform -contains "Ubuntu" -or $_.osPlatform -match "Linux*" -or $_.osPlatform -contains "Debian" -or $_.osPlatform -contains "CentOS" }

# Untagged Server
$Untagged_servers = $all_servers | where-object { $_.machineTags -notcontains "Server" }
tag-action -deviceGroup $Untagged_servers -tag Server -action Add

$win_server = $all_servers | Where-Object { $_.osPlatform -match "WindowsServer*" }
$linux_server = $all_servers | Where-Object { $_.osPlatform -notmatch "WindowsServer*" }

# $Untagged_win_server
$Untagged_win_server = $win_server | Where-Object { $_.machineTags -notcontains 'Windows' }
tag-action -deviceGroup $Untagged_win_server -tag Windows -action Add

# $Untagged_linux_server
$Untagged_linux_server = $linux_server | Where-Object { $_.machineTags -notcontains 'Linux' }
tag-action -deviceGroup $Untagged_linux_server -tag Linux -action Add

$server_env_dev = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" -and $_.machineTags -notcontains 'Dev' }
tag-action -deviceGroup $server_env_dev -tag Dev -action Add

$server_env_lab = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" -and $_.machineTags -notcontains 'Lab' }
tag-action -deviceGroup $server_env_lab -tag Lab -action Add

$server_env_#### = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" -and $_.machineTags -notcontains '####' }
tag-action -deviceGroup $server_env_#### -tag #### -action Add

$server_env_prod = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" -and $_.machineTags -notcontains 'Prod' }
tag-action -deviceGroup $server_env_prod -tag Prod -action Add

$server_env_#### = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" -and $_.machineTags -notcontains '####' }
tag-action -deviceGroup $server_env_#### -tag #### -action Add

$server_env_#### = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" -and $_.machineTags -notcontains '####' }
tag-action -deviceGroup $server_env_#### -tag #### -action Add

$server_env_#### = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" -and $_.machineTags -notcontains ''####'' }
tag-action -deviceGroup $server_env_#### -tag #### -action Add

$server_env_#### = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" }
tag-action -deviceGroup $server_env_#### -tag #### -action Add

$server_env_#### = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" }
tag-action -deviceGroup $server_env_#### -tag #### -action Add

$server_env_####_storage = $all_servers | Where-Object { $_.vmMetadata.subscriptionId -eq "####################################" }
tag-action -deviceGroup $server_env_####_storage -tag ####_Storage -action Add

