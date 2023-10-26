# Define parameters
$StaticIPAddress = "192.168.1.10"
$SubnetMask = "255.255.255.0"
$Gateway = "192.168.1.1"
$DNS = "192.168.1.2"
$ServerName = "SonToWater"
$NewDomainName = "sontowater.local"
$CSVFile = "C:\Users\Administrator\Desktop\SunToWater.xlsx"  # Provide the path to your CSV file
$AdminPassword = ConvertTo-SecureString -AsPlainText "YourPassword" -Force

# Assign a static IPv4 address to the Windows Server VM
New-NetIPAddress -IPAddress $StaticIPAddress -PrefixLength 24 -InterfaceAlias "Ethernet" -DefaultGateway $Gateway

# Set DNS server address
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DNS

# Rename the Windows Server VM
Rename-Computer -NewName $ServerName -Restart

# Install Active Directory Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Create an Active Directory Forest
Install-ADDSForest -DomainName $NewDomainName -DomainMode Win2016 -ForestMode Win2016 -InstallDns -SafeModeAdministratorPassword $AdminPassword

# Create Organizational Units (OU)
New-ADOrganizationalUnit -Name "Sales" -Path "DC=$NewDomainName,DC=com"
New-ADOrganizationalUnit -Name "IT" -Path "DC=$NewDomainName,DC=com"

# Create users
New-ADUser -Name "John Doe" -SamAccountName "johnd" -UserPrincipalName "johnd@$NewDomainName" -Enabled $true -Path "OU=Sales,DC=$NewDomainName,DC=com" -AccountPassword $AdminPassword
New-ADUser -Name "Jane Smith" -SamAccountName "janes" -UserPrincipalName "janes@$NewDomainName" -Enabled $true -Path "OU=IT,DC=$NewDomainName,DC=com" -AccountPassword $AdminPassword

# Assign a static IPv4 address to the Windows Server VM
New-NetIPAddress -IPAddress $StaticIPAddress -PrefixLength 24 -InterfaceAlias "Ethernet" -DefaultGateway $Gateway

# Set DNS server address
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DNS

# Rename the Windows Server VM
Rename-Computer -NewName $ServerName -Restart

# Install Active Directory Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Create an Active Directory Forest
Install-ADDSForest -DomainName $NewDomainName -DomainMode Win2016 -ForestMode Win2016 -InstallDns -SafeModeAdministratorPassword $AdminPassword

# Create Organizational Units (OU)
New-ADOrganizationalUnit -Name "Sales" -Path "DC=$NewDomainName,DC=com"
New-ADOrganizationalUnit -Name "IT" -Path "DC=$NewDomainName,DC=com"

# Import user data from CSV and create users
$UserList = Import-Csv $CSVFile
foreach ($User in $UserList) {
    $FirstName = $User."Name"
    #$LastName = $User."Sobrenome"
    $Username = $User."Name"
    $Password = ConvertTo-SecureString -AsPlainText $User."password" -Force
    $Department = $User."Departamento"
    }
    New-ADUser -Name "$FirstName" -SamAccountName $Username -UserPrincipalName "$Username@$NewDomainName" -Enabled $true -Path "OU=$Department,DC=$NewDomainName,DC=com" -AccountPassword $Password