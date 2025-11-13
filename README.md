# Microsoft Intune admx policies

## for exporting/importing of Microsoft Intune device configuration policies based on admx administrative templates.


Pre-requisites:
-app registration must have delegated permission: Microsoft Graph\DeviceManagementConfiguration.Readwrite.all
-intune displayname of the policy must not contain any special characters (export creates a folder with the displayname of the policy)


TODO: Add support for authentication via
-app registration clientID + clientSecret
-clientID + certificate based authentication
