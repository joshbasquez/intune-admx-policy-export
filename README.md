# Microsoft Intune admx policies export

This is a fork of the repo github.com/sandytsang/MSIntune. Some updates for modern authentication using delegated permissions and a deviceCode for obtaining admin accesstoken. 

credits: SandyTsang, SCConfigMgr.com/MSEndpointmgr.com, @powers-hell and @onpremcloudguy

Pre-requisites:<BR>
-app registration must have delegated permission: Microsoft Graph\DeviceManagementConfiguration.Readwrite.all<BR>
-intune displayname of the policy must not contain any special characters (export creates a folder with the displayname of the policy)

<BR>
## When an update to the admx template for a third party application is released, Microsoft Intune may require you to remove any policies using that template prior to removing and re-adding the updated admx file. There are other workarounds, including importing the admx file with a modified namespace (causes duplicate policy options), but this export/import script will allow you to backup your policies so that the policies and old admx file can be removed. Be advised that the new admx must include the old policy options. 

This script is experimental and for learning purposes only. Use at your own risk. Document any policies prior to deleting them in your own production environment. 

TODO: <BR>
-Add support for authentication via client/secret and certAuth<BR>
-add support for exporting/importing groupAssignments
