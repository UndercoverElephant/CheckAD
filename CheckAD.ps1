#CheckAD.ps1
[CmdletBinding()]
param (  
 [parameter(mandatory=$false)]
 [switch] $h = $false,
 [parameter(mandatory=$false)]
 [string] $u,
 [parameter(mandatory=$false)]
 [switch] $o = $false,
 [string] $p,
 [string] $f
 )

Function Asking-Help{  
""
"Usage .\CheckAD.ps1 [options]"
"A tool to quickly search AD and output relevant details"
""
"Options:"
"  -o: output to txt file"
"  -p: define path to save log file"
"  -u: specify the user to search for. can be either by username or email address"
"  -h: show this help message"
"  -f: define path to file for list of users to search for"
""
"Examples:"
"Searching for a user with output printed to screen."
".\CheckAD.ps1 [username\email]"
"Searching for a user with a log file created in current directory"
".\CheckAD.ps1 [username\email] -o"
"Searching for a user with a log file created in a specific directory"
".\CheckAD.ps1 [username\email] -o -p C:\path\to\directory"
"Searching for a list of users. CSV log created in current directory."
".\CheckAD.ps1 -f C:\path\to\userlist.csv"
"Searching for a list of users. CSV log created in specific directory."
".\CheckAD.ps1 -f C:\path\to\userlist.csv -p C:\path\to\directory"
""
Exit  
}

function Output-User($u, $p, $o, $m){  
    #Compare counter to the domain count, if = then it user is not listed in AD
    If ($DomainCount -eq $count){
        "$u not found in Active Directory!"
    }

    else{

        #Did they specify a directory to save the file in?
        if ($p -eq ""){
            #If not, drop file in current directory
            $p = (Get-Item -Path ".\" -Verbose).FullName
        }
        #$p needs to end with a "\" to ensure it is saved to the directory properly
        $check = $p.EndsWith("\")
        if ($check -eq $false){
            $p = $p + "\"
        }
        #if a list was provided save info to csv document
        if($m -eq $true){
            $filename = $p + "AD_User_Info.csv"     
            $userinfo | export-csv $filename -NoTypeInformation -Append
        }
        #if only one user provided
        else{
            #Print the results to screen.
            $userinfo

            #they want it saved to a file
            if ($o -eq $true){
                $filename = $p + "User_Info-" + $u + ".txt"
                $userinfo | Out-File $filename
            }
        }
    }
}

function Search-AD ($u, $p, $o, $m){  
    # Import ActiveDirectory PowerShell Module
    Import-Module ActiveDirectory

    #Determine all Domains in the environment
    $objForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    $DomainList = @($objForest.Domains)
    $Domains = $DomainList | foreach { $_.name }

    #Create counters for confirming if user is not in AD
    $DomainCount = $DomainList.Count
    $Count = 0

    #Check if input is username or email
    if($u -like '*@*'){
        $field = "Mail"    
    }
    else {
        $field = "sAMAccountName"
    }

    #Display status
    "Searching for $u in $domaincount domain(s)..."

    #Loop to search each identified domain for the user
    foreach ($Domain in $Domains)
    {   
        #Check domain for user   
        $User = Get-ADUser -Server $Domain -LDAPFilter "($field=$u)"

        If ($User -eq $Null) {
            $count = $count + 1
        }

        #If user is found, list user attributes
        Else {
            $userinfo = Get-ADUser -Server $Domain -LDAPFilter "($field=$u)" -properties * | 
            Select-Object @{Label = "Display Name";Expression = {$_.DisplayName}}, 
                          @{Label = "Logon Name";Expression = {$_.sAMAccountName}}, 
                          @{Label = "Domain";Expression = {$Domain}},
                          @{Label = "City";Expression = {$_.City}}, 
                          @{Label = "State";Expression = {$_.st}}, 
                          @{Label = "Post Code";Expression = {$_.PostalCode}}, 
                          @{Label = "Country/Region";Expression = {$_.Country}}, 
                          @{Label = "Job Title";Expression = {$_.Title}}, 
                          @{Label = "Company";Expression = {$_.Company}},  
                          @{Label = "Department";Expression = {$_.Department}}, 
                          @{Label = "Phone";Expression = {$_.telephoneNumber}}, 
                          @{Label = "Email";Expression = {$_.Mail}}, 
                          @{Label = "Manager";Expression = {%{(Get-AdUser $_.Manager -Properties DisplayName).DisplayName}}}, 
                          @{Label = "Account Status";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}} # the 'if statement# replaces $_.Enabled}
        }
    }

    Output-User $u $p $o $m
}

If ($h -eq $true){  
    Asking-Help
}

else {  
    If ($f -ne ""){
        $Users = Get-Content $f
        $m = $true
        Foreach ($user in $users){
            $u = $User
            Search-AD $u $p $o $m
        }  
    }
    else{
        if($u -ne ""){
            $m = $false
            Search-AD $u $p $o $m
        }
        else{Asking-Help}
    }
}
