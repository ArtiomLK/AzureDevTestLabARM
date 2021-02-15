param (
	[Parameter(Mandatory)]
	$subscriptionId,
		
	[Parameter(Mandatory)]
	$projectName,
	
	[ValidateSet('prod','uat','qa','dev','test')]
	$environment = 'dev',
	
	$location = 'eastus2'
)

## Variables
#Environment suffix for resources
$environmentSuffix = "-" + $environment.ToLower()
#Don't add -prod suffix to names
if ($environmentSuffix -eq '-prod')
{
	$environmentSuffix = ''
}

##Resource Names
$resourceGroupName = "rg-$projectName$environmentSuffix";

#set subscription
az account set -s $subscriptionId
$subDetails = az account show | ConvertFrom-Json

$subName = $subDetails.name
Write-Host "Using Subscription '$subName'"

#create resource group
$checkRG = az group exists -g $resourceGroupName
if ($checkRG -eq $true){
	Write-Host "Resource Group '$resourceGroupName' exists. Skipping..."
}
else{
	Write-Host "Creating Resource Group '$resourceGroupName'"
	az group create `
		--resource-group $resourceGroupName `
		--location $location `
		--tags Environment=$environment Project=$projectName
}

Write-Host "Starting template deployment..."
az deployment group create `
	--resource-group $resourceGroupName `
	--template-file mainTemplate.json `
	--parameters projectName=$projectName env=$environment

