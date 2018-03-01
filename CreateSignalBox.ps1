Login-AzureRmAccount 

Get-AzureRmSubscription -SubscriptionName "HODDAT Sandbox 1"
Set-AzureRmContext -Subscription "HODDAT Sandbox 1"

<# Replace the following URL with a public GitHub repo URL
$gitrepo="https://github.com/diahughes/WebApp1.git"
$ServicePlan = "Signals"
$webappname="SignalBox"
$location="UK West"
#>

$ResourceGroup = "Developers"

$gitdirectory="C:\Users\VSadmin\Documents\GitHub\signalbox"
$webappname="SignalBox"
$location="UK West"

# Create a resource group.
#New-AzureRmResourceGroup -Name $ResourceGroup -Location $location

# Create an App Service plan in `Free` tier.
New-AzureRmAppServicePlan -Name $webappname -Location $location `
-ResourceGroupName $ResourceGroup -Tier Free

# Create a web app.
New-AzureRmWebApp -Name $webappname -Location $location -AppServicePlan $webappname `
-ResourceGroupName $ResourceGroup

# Configure GitHub deployment from your GitHub repo and deploy once.
$PropertiesObject = @{
    scmType = "LocalGit";
}
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $ResourceGroup `
-ResourceType Microsoft.Web/sites/config -ResourceName $webappname/web `
-ApiVersion 2015-08-01 -Force

# Get app-level deployment credentials
$xml = [xml](Get-AzureRmWebAppPublishingProfile -Name $webappname -ResourceGroupName $ResourceGroup `
-OutputFile null)
$username = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userName").value
$password = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userPWD").value

# Add the Azure remote to your local Git respository and push your code
#### This method saves your password in the git remote. You can use a Git credential manager to secure your password instead.
git remote add azure "https://${username}:$password@$webappname.scm.azurewebsites.net"
git push azure master