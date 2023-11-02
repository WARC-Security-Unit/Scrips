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

#Creating OUs and Users
# Define OUs
$OUs = @(
    "Marketing",
    "Financial",
    "HR",
    "Information",
    "Information Security",
    "Operations"
)

# Create OUs
foreach ($OU in $OUs) {
    New-ADOrganizationalUnit -Name $OU -Path "DC=$DomainName"
}

# Create the user list
$Users = @(
    ("Bill", "Lumbergh", "Bill", "CEO", "Marketing"),
    ("Peter", "Gibbons", "Peter", "Employee", "Marketing"),
    ("Ron", "Weasley", "Ron", "Employee", "Marketing"),
    ("Herry", "Potter", "Herry", "Employee", "Marketing"),
    ("Hermione", "Granger", "Hermione", "Employee", "Financial"),
    ("Bob", "Slydell", "Bob", "Employee", "Financial"),
    ("Luca", "Pacioli", "Luca", "Employee", "Financial"),
    ("Angela", "Martin", "Angela", "Employee", "Financial"),
    ("Kevin", "Malone", "Kevin", "Employee", "Financial"),
    ("Oscar", "Martinez", "Oscar", "Employee", "HR"),
    ("Minerva", "McGonagall", "Minerva", "Employee", "HR"),
    ("Sybill", "Trelawney", "Sybill", "Employee", "HR"),
    ("Remus", "Lupin", "Remus", "Employee", "HR"),
    ("Severus", "Snape", "Severus", "Employee", "Information"),
    ("Bade", "Habib", "Bade", "Employee", "Information"),
    ("Samir", "Nagheenanajar", "Samir", "Employee", "Information"),
    ("Jhon", "Dorian", "Jhon", "Employee", "Information"),
    ("Elliot", "Reid", "Elliot", "Employee", "Information"),
    ("Chris", "Turk", "Chris", "Employee", "Information Security"),
    ("Courtney", "Hans", "Courtney", "Employee", "Information Security"),
    ("Brian", "Krebs", "Brian", "Employee", "Information Security"),
    ("Milton", "Waddams", "Milton", "Employee", "Information Security"),
    ("Perry", "Cox", "Perry", "Employee", "Information Security"),
    ("Bob", "Kelso", "Bob", "Employee", "Operations"),
    ("Michael", "Scott", "Michael", "Employee", "Operations"),
    ("Dwight", "Schrute", "Dwight", "Employee", "Operations"),
    ("Jim", "Halpert", "Jim", "Employee", "Operations"),
    ("Andy", "Bernard", "Andy", "Employee", "Operations"),
    ("Kelly", "Kapoor", "Kelly", "Employee", "Operations"),
    ("Phyllis", "Lapin-Vance", "Phyllis", "Employee", "Operations"),
    ("Meredith", "Palmer", "Meredith", "Employee", "Operations")
)

# Create users in the corresponding OUs
foreach ($User in $Users) {
    $FirstName, $LastName, $Username, $Title, $OUName = $User
    $OUPath = "OU=$OUName,DC=$DomainName"
    $UserParameters = @{
        Name = "$FirstName $LastName"
        SamAccountName = $Username
        GivenName = $FirstName
        Surname = $LastName
        Title = $Title
        Path = "OU=$OUName,DC=$DomainName"
    }
    New-ADUser @UserParameters
}

Write-Host "Creation of OUs and users successfully completed."
