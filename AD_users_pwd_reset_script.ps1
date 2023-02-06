#test - show user names, else - run change pwd
$TEST_SCRIPT = $True
#users in $excluded_users - will be excluded from pwd reset
$group_to_reset_name = 'password_hard'
$group_to_exclude_name = 'password_excluded_users'
#old pwd days count
$days = 20
$days = [DateTime]::Today.AddDays(-$days)
"{0} {1}" -f 'Change all passwords older:', $days
#check admin priveleges
$currPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$Admin = $currPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


if ($Admin)
{
    #get group to reset
    $password_hard = Get-ADGroup $group_to_reset_name |Get-ADGroupMember -Recursive
    #get group to exclude 
    $excluded_users =  Get-ADGroup $group_to_exclude_name |Get-ADGroupMember -Recursive
  
    foreach ($user in $password_hard)
    {
    $ex = $False
        foreach ($ex_user in $excluded_users)
        {
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
                $user = $user | Get-ADUser -Properties * # PasswordLastSet, PasswordExpired
                $uDate = $user.PasswordLastSet 
                if (($uDate -lt $days) -and ($user.Enabled -eq $true))
                {
                    "{0} | {1}" -f $user.SamAccountName, $uDate
                }
            }
        else #change password
            {
                $user = $user | Get-ADUser -Properties PasswordLastSet
                $uDate = $user.PasswordLastSet
                #Force to change
                if ($uDate -lt $days)
                {
                    $user | Set-ADuser -ChangePasswordAtLogon $True   
                }
            }
        }
    }
}
else
{
"User is not administrator. Run as administrator!"
}
