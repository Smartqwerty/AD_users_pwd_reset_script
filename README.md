# AD_users_pwd_reset_script
# Powershell script to reset users passwords in OU excluding users optionally. 
# After running - users will be forsed to change passwords on their first logon.
#
# Params:
# $TEST_SCRIPT = $True | if True - test and print users to change pwd, else - force to change passwords.
# $Print_result = $True | if True - shows users to be forced to change passwords in console.
# $group_to_reset_name = 'password_hard' | AD group like 'All users', etc.
# $group_to_exclude_name = 'password_excluded_users' | AD group to exclude some users from beeing forsed to change pwd.
# $days = 20 | if users pwd is older than this param, he will be forced to change it.
