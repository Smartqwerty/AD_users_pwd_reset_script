#test - show user names, else - run change pwd
$TEST_SCRIPT = $True
#$TEST_SCRIPT = $False

#Console output User/last pwd date
$Print_result = $True

#old pwd days count
$days = 30
$days = [DateTime]::Today.AddDays(-$days)

#users in $excluded_users - will be excluded from pwd reset
$group_to_reset_name = 'password_hard'
$group_to_exclude_name = 'password_excluded_users'

#check admin priveleges
$currPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$Admin = $currPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


if ($Admin)
{
    if ($Print_result -eq $True)
        {
        #print date
        "{0} {1}" -f 'Change all passwords older:', $days
        }

    #get group to reset
    $password_hard = Get-ADGroup $group_to_reset_name | Get-ADGroupMember -Recursive
    #get group to exclude 
    $excluded_users =  Get-ADGroup $group_to_exclude_name | Get-ADGroupMember -Recursive
  
    foreach ($user in $password_hard)
    {
    $ex = $False
        foreach ($ex_user in $excluded_users)
        {
         
         if ($user.SamAccountName -eq 'Dubrovsky')
         {
             $ex = $True
             break
         } 
         
         if ($user.SamAccountName -eq $ex_user.SamAccountName)
         {
             $ex = $True
             break
         }     
        }
    if ($ex -ne $True)
        {
        if ($TEST_SCRIPT -eq $True) #print user & PasswordLastSet date
            {  
                $user_tab =@{}             
                $user = $user | Get-ADUser -Properties *
                $uDate = $user.PasswordLastSet        
                if (($uDate -lt $days) -and ($user.Enabled -eq $true))
                { 
                    $user_tab.Add($user.SamAccountName,$uDate)
                }
            if ($Print_result -eq $True)
                {
                $user_tab
                }
            }
        else #change password
            {
                $user_tab =@{} 
                $user = $user | Get-ADUser -Properties *
                $uDate = $user.PasswordLastSet
                #Force to change
                if ($uDate -lt $days)
                {
                    $user | Set-ADuser -ChangePasswordAtLogon $True 
                    $user_tab.Add($user.SamAccountName,$uDate)  
                }
            if ($Print_result -eq $True)
                {
                $user_tab
                }
            }
        }
    }
}
else
{
"User is not administrator. Run as administrator!"
}
