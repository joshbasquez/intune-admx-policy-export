# Microsoft Intune admx policies

## for exporting/importing of Microsoft Intune device configuration policies based on admx administrative templates.

This is a fork of the repo github.com/sandytsang/MSIntune. Some updates for modern authentication using delegated permissions and a deviceCode for obtaining admin accesstoken. 

credits: SandyTsang, SCConfigMgr.com/MSEndpointmgr.com, @powers-hell and @onpremcloudguy

Pre-requisites:
-app registration must have delegated permission: Microsoft Graph\DeviceManagementConfiguration.Readwrite.all
-intune displayname of the policy must not contain any special characters (export creates a folder with the displayname of the policy)

TODO: 
-Add support for authentication via client/secret and certAuth
-add support for exporting/importing groupAssignments
