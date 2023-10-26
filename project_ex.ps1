# Install AD DS role 
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote server to DC and create new forest
$domainName = "SunToWater.com"
$safeModeAdminPassword = ConvertTo-SecureString "P@ssw0rd1" -AsPlainText -Force
Install-ADDSForest `
  -DomainName $domainName `
  -DomainNetbiosName "SUNTOWATER" `
  -ForestMode "WinThreshold" ` 
  -DomainMode "WinThreshold"
  -InstallDns:$true `
  -SafeModeAdministratorPassword $safeModeAdminPassword `
  -Force:$true

# Configure DNS server
$ipAddress = "10.0.0.1"  
$nic = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
$dnsServer = Get-DnsServer
$dnsServer.NetworkInterfaces[$nic.Name].IPv4Addresses = $ipAddress
$dnsServer.Zones[0].DynamicUpdate = "Secure"

# Create OU
New-ADOrganizationalUnit `
  -Name "Chiefs" `
  -Path "DC=$domainName" 

# Create user
$username = "MScott"
$password = ConvertTo-SecureString "Password1" -AsPlainText -Force
New-ADUser `
  -Name "Michael Scott"
  -GivenName "Michael"
  -Surname "Scott" 
  -SamAccountName $username 
  -AccountPassword $password
  -Enabled $true
