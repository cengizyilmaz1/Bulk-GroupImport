<#
=============================================================================================
Name = Cengiz YILMAZ
Date = 1.03.2023
www.cengizyilmaz.net
www.cozumpark.com/author/cengizyilmaz
============================================================================================
#>

[CmdletBinding(SupportsShouldProcess)]

Param()

Start-Transcript -Path "C:\Import.csv"

# CSV Path

$csvPath = Read-Host "Enter the path of the CSV file: "

# CSV Read

$csv = Import-Csv -Path $csvPath

# Group Name

$groupName = Read-Host "Enter the name of the group: "

# Group Search
try {
$group = Get-ADGroup -Identity $groupName -ErrorAction Stop
}
catch {
Write-Error "$groupname group not found"
return
}
 
# Group Check

if ($group -eq $null) {

    Write-Error "$groupName group not found."

    return

}

# Hashtable and Colors

$successMessage = @{

    ForegroundColor = "Green"

}

$errorMessage = @{

    ForegroundColor = "Red"

}

$alreadyMemberMessage = @{

    ForegroundColor = "Cyan"

}

# Transcript

$messages = @()

foreach ($row in $csv) {

    # In the CSV file, the user's name will be in the UserPrincipalName column.

    $userPrincipalName = $row.UserPrincipalName

    # Let's find the user.

    $user = Get-ADUser -Filter { UserPrincipalName -eq $userPrincipalName } -Properties MemberOf

    # If there is no user, let's print an error message.

    if ($user -eq $null) {

        $messages += @{

            Message = "$userPrincipalName user not found in Active Directory."

            Options = $errorMessage

        }

        continue

    }

 

    # If the user is already a member of this group, let's print a message.

    if ($user.MemberOf -contains $group.DistinguishedName) {

        $messages += @{

            Message = "$userPrincipalName user is already a member of $groupName group."

            Options = $alreadyMemberMessage

        }

        continue

    }

 

    # Let's add the user to the group.

    if ($group -ne $null -and $PSCmdlet.ShouldProcess("$userPrincipalName user", "Add to $groupName group")) {

        Add-ADGroupMember -Identity $groupName -Members $user

    }

 

    # Let's write a successful message.

    $messages += @{

        Message = "$userPrincipalName user added to $groupName group."

        Options = $successMessage

    }

}

 

# Let's print the messages on the screen.

$messages | ForEach-Object {

    Write-Host $_.Message -ForegroundColor $_.Options.ForegroundColor

}

 

# End

Stop-Transcript
