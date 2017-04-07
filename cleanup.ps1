#******************************************************************************
# File:cleanup.ps1 ��Դ��ɾ���ű����ְ汾�µ�ģ���ɾ��ָ����Դ�������е���Դ�����ֻ��ɾ���ض�����Դ��
#                  ��Ҫ��������Դ��ģ�帴��һ�ݣ�Ȼ����ģ����ȥ��Ҫɾ������Դ���ɡ�
# Author:wesley wu
# Email:weswu@microsoft.com
# Version:1.0
#******************************************************************************
#******************************************************************************
# Global Parameters
# Caution: Only the resources declared in your template will exist in the resource group
# ע��: һ����Դ���������Դ��Ӧ�þ���һ�����������ڣ��ְ汾�µ�ģ���ɾ��ָ����Դ�������е���Դ��
#      ���ֻ��ɾ���ض�����Դ����Ҫ��������Դ��ģ�帴��һ�ݣ�Ȼ����ģ����ȥ��Ҫɾ������Դ���ɡ�
#******************************************************************************
# ��β鿴����ID, ʹ��powershell:
# 1.Login-AzureRmAccount �CEnvironmentName AzureChinaCloud 
# 2.Get-AzureRMSubscription
$subscriptionId = "subscriptionId-here"
# Ҫɾ������Դ�飬�����Դ���ڵ�������Դ�ᱻɾ��
$resourceGroupName = "resourceGroupName-here"
# ��Դ���Region,��ѡ���ǣ�China East/China North
$resourceGroupLocation = "Location-here"
# ��Դ�����ģ���ļ���λ�ã����ֻ��ɾ���ض�����Դ����Ҫ��������Դ��ģ�帴��һ�ݣ�Ȼ����ģ����ȥ��Ҫɾ������Դ����
$templateFilePath = "your-path-here\cleanup.json"
# deployMode --Complete: Only the resources declared in your template will exist in the resource group
# deployMode --Incremental:  Non-existing resources declared in your template will be added.
# ����ģʽ,����incremental��ʽ��������������Դ�����Ҫɾ����Դ��completeģʽ
$deployMode = "Complete"


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

# ������е���Դ��
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "The resource group '$resourceGroupName' in location '$resourceGroupLocation does not exist!'";
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# ���Բ���ģ��
Write-Host "Testing cleanup...";
Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile  $templateFilePath -Verbose;


# ��ʼ�µĲ���
Write-Host "Starting cleanup...";
New-AzureRmResourceGroupDeployment -Mode $deployMode -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath;

# �г�ʣ�����Դ
Write-Host "Resources which are still remaining in the resource group...";
Get-AzureRmResource | Where {$_.ResourceGroupName �Ceq $resourceGroupName} | ft
