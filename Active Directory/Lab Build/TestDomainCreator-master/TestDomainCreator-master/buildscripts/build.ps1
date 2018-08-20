try {
	$ErrorActionPreference = 'Stop'

	$azrVmName = 'LABDC'

	## Authenticate to Azure here because we'll be using Azure Automation DSC
	Write-Host 'Authenticating to Azure...'
	Disable-AzureRmDataCollection

	$azrPwd = ConvertTo-SecureString $env:azure_pass -AsPlainText -Force
	$azrCred = New-Object System.Management.Automation.PSCredential ($env:azure_appId, $azrPwd)

	## Use a SPN for easy authentication
	$connParams = @{
		ServicePrincipal = $true
		TenantId = $env:azure_tenantId
		Credential = $azrCred
		SubscriptionId = $env:azure_subscriptionid
	}
	$null = Add-AzureRmAccount @connParams

	## Start up the test VM if it's not already
	Write-Host 'Starting test VM...'
	$null = Get-AzureRmVM -Name LABDC -ResourceGroupName Group | Start-AzureRmVM

	$sharedParams = @{
		AutomationAccountName = 'adamautomation'
		ResourceGroupName = 'Group'
	}

	## Send the changed DSC configuration to Azure
	Write-Host 'Sending DSC configuration to Azure Automation...'
	$null = Import-AzureRmAutomationDscConfiguration @sharedParams -SourcePath 'C:\projects\testdomaincreator\NewTestEnvironment.ps1' -Published -Force

	## Grab config data from source
	Write-Host 'Getting ConfigData from source...'
	$configDataFilePath = "$env:TEMP\ConfigData.psd1"
	$iwrParams = @{
		Uri = 'https://raw.githubusercontent.com/adbertram/TestDomainCreator/master/ConfigurationData.psd1'
		UseBasicParsing = $true
		OutFile = $configDataFilePath
	}
	Invoke-WebRequest @iwrParams
	$configData = Invoke-Expression (Get-Content -Path $configDataFilePath -Raw)

	## Start the DSC compile in Azure
	Write-Host 'Begin Azure Automation DSC compile...'
	$compParams = $sharedParams + @{
		ConfigurationName = 'NewTestEnvironment'
		ConfigurationData = $configData
	}
	$CompilationJob = Start-AzureRmAutomationDscCompilationJob @compParams

	## Wait for the DSC compile
	Write-Host 'Waiting for Azure Automation DSC compile...'
	while($CompilationJob.EndTime -eq $null -and $CompilationJob.Exception -eq $null)
	{
		$CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob
		Start-Sleep -Seconds 3
	}

	## Assign the configuration to the node and run the config
	Write-Host 'Assigning DSC configuration to node...'
	$nodeId = (Get-AzureRmAutomationDscNode @sharedParams -Name $azrVmName).Id
	$nodeParams = @{
		NodeConfigurationName = "NewTestEnvironment.$azrVmName"
		ResourceGroupName = 'Group'
		Id = $nodeId
		AutomationAccountName = 'adamautomation'
		Force = $true
	}
	$node = Set-AzureRmAutomationDscNode @nodeParams

	Write-Host 'Updating DSC configuration on node...'
	$vm = Get-AzureRmVm -Name $azrVmName -ResourceGroupName 'Group'
	$ipAddress = (Get-AzureRmPublicIpAddress -ResourceGroupName 'Group' -Name "$azrVmName-ip").IpAddress
	Set-Item -Path wsman:\localhost\Client\TrustedHosts -Value $ipAddress -Force
	$adminUsername = $vm.osProfile.AdminUsername
	$adminPwd = ConvertTo-SecureString $env:vm_admin_pass -AsPlainText -Force
	$cred = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPwd)

	Invoke-Command -ComputerName $ipAddress -ScriptBlock { Update-DscConfiguration -Wait -Verbose } -Credential $cred

} catch {
	throw $_.Exception.Message
}