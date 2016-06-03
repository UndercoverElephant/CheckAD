#Import ActiveDirectory PowerShell Module
Import-Module ActiveDirectory

#Request Username
$Name = Read-Host "Enter User Name"

#Determine all Domains in the environment
$objForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$DomainList = @($objForest.Domains)
$Domains = $DomainList | foreach { $_.name }

#Create counter to check if user is in AD
$DomainCount = $DomainList.Count
$Count = 0

"Searching for $Name in $DomainCount domains..."

#Loop to search each identified domain for the user
foreach ($Domain in $Domains)
{
    #Check domain for username
    $User = Get-ADUser -Server $Domain -LDAPFilter "(sAMAccountName=$Name)"
    If ($User -eq $null) {
        $count = $count + 1
    }

    #If user is found, get user attributes
    Else {
        #Set output file name. To be dropped where script was executed
        $filename = "User_Info-" + $Name + ".txt"

        $userinfo = Get-ADUser -server $Domain -LDAPFilter "(sAMAccountName=$Name)" -properties * |
        Select-Object @{Label = "Display Name";Expression = {$_.DisplayName}},
                      @{Label = "Logon Name";Expression = {$_.sAMAccountName}},
                      @{Label = "Domain";Expression = {$_.Domain}},
                      @{Label = "City";Expression = {$_.City}},
                      @{Label = "State";Expression = {$_.st}},
                      @{Label = "Post Code";Expression = {$_.PostalCode}},
                      @{Label = "Country";Expression = {$_.Country}},
                      @{Label = "Job Title";Expression = {$_.Title}},
                      @{Label = "Company";Expression = {$_.Company}},
                      @{Label = "Department";Expression = {$_.Department}},
                      @{Label = "Phone";Expression = {$_.telephoneNumber}},
                      @{Label = "Email";Expression = {$_.Mail}},
                      @{Label = "Manager";Expression = {%{(Get-ADUser $_.Manager -Properties DisplayName).DisplayName}}},
                      @{Label = "Account Status";Expression = {if (($_.Enabled -eq 'TRUE')){'Enabled'} Else {'Disabled'}}}
        #Write results to file
        $userinfo | Out-File $filename
        "Done. Check $filename for details"
        
        #Break loop if user is found
        Break
        }
}

#If count = domain count then user was not found in AD
If ($DomainCount -eq $Count){
    "$name not found in Active Directory"
}