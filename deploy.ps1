#******************************************************************************
# File:deploy.ps1 ��Դ�Ĳ���ű�
# Author:wesley wu
# Email:weswu@microsoft.com
# Version:1.0
#******************************************************************************
#******************************************************************************
# Global Parameters
# Caution: the lifecycle of resources in the same resource group shoulb be the same
# ע��: һ����Դ���������Դ��Ӧ�þ���һ������������
#******************************************************************************
# ��β鿴����ID, ʹ��powershell:
# 1.Login-AzureRmAccount �CEnvironmentName AzureChinaCloud 
# 2.Get-AzureRMSubscription
$subscriptionId = "subscriptionId-here"
# Ҫ�������Դ�飬�����Դ���ǽű���̬������
$resourceGroupName = "resourceGroupName-here"
# ��Դ���Region,��ѡ���ǣ�China East/China North
$resourceGroupLocation = "Location-here"
# Master�ű��Ĵ��λ��
$templateFilePath = "your-path-here\cleanup.json\deploy-master.json"
# deployMode --Complete: Only the resources declared in your template will exist in the resource group
# deployMode --Incremental:  Non-existing resources declared in your template will be added.
# ����ģʽ,����incremental��ʽ��������������Դ�����Ҫɾ����Դ��completeģʽ
$deployMode = "Incremental"
# ��β��������
$deployName = "produciton"


#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
# ���ÿ�����нű���Ҫ��½���������·�ʽ��ȡ��½��Token,ʹ��powershell:
# 1.Login-AzureRmAccount �CEnvironmentName AzureChinaCloud
# 2.Save-AzureRmProfile -Path "C:\your-path-here\accesstoken.json"
# �����½Token��·����ע��Ҫ��֤����ļ��İ�ȫ
$cnProfile = "C:\your-path-here\accesstoken.json"
Select-AzureRmProfile -Path $cnProfile

# ѡ����Ӧ�Ķ���
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# �����������е���Դ��
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# ���Բ���ģ��
Write-Host "Testing deployment...";
Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -location $resourceGroupLocation -TemplateFile  $templateFilePath -Verbose;

# ֹͣ��Ծ�Ĳ���
#if ($activeDeployment = Get-AzureRmResourceGroupDeployment -ResourceGroupName "epay" | Where {$_.ProvisioningState -eq 'Running'}){
if (Get-AzureRmResourceGroupDeployment -ResourceGroupName "epay" | Where {$_.ProvisioningState -eq 'Running'}){
    Write-Host "Clear previous active deployment...";
#    ForEach ($activeDeployment in $activeDeployments){
#    Stop-AzureRMResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deployName
#    }
}

# ��ʼ�µĲ���
Write-Host "Starting deployment...";
New-AzureRmResourceGroupDeployment -Mode $deployMode -Name $deployName -ResourceGroupName $resourceGroupName -location $resourceGroupLocation -TemplateFile $templateFilePath;

# �г������õ���Դ
Write-Host "Resources which are created...";
Get-AzureRmResource | Where {$_.ResourceGroupName �Ceq $resourceGroupName} | ft