# Microsoft Intune admx policies export

This is a fork of the repo github.com/sandytsang/MSIntune. Some updates for modern authentication using delegated permissions and a deviceCode for obtaining admin accesstoken. 

credits: SandyTsang, SCConfigMgr.com/MSEndpointmgr.com, @powers-hell and @onpremcloudguy

Pre-requisites:<BR>
-app registration must have delegated permission: Microsoft Graph\DeviceManagementConfiguration.Readwrite.all<BR>
-intune displayname of the policy must not contain any special characters (export creates a folder with the displayname of the policy)

<BR>
Microsoft learn - Intune - Replace existing admx files:<BR>
https://learn.microsoft.com/en-us/intune/intune-service/configuration/administrative-templates-import-custom#replace-existing-admx-files

<BR><BR>This script is experimental and for learning purposes only. Use at your own risk. Document any policies prior to deleting them in your own production environment. 

TODO: <BR>
-Add support for authentication via client/secret and certAuth<BR>
-add support for exporting/importing groupAssignments
