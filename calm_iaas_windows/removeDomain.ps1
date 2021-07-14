function RemoveFromDomain {
  [CmdletBinding()]
  Param(
      [parameter(Mandatory=$true)]
      [string]$DomainName,
      [parameter(Mandatory=$true)]
      [string]$Username,
      [parameter(Mandatory=$true)]
      [string]$Password
  )

  $adminname = "$DomainName\$Username"
  $adminpassword = ConvertTo-SecureString -asPlainText -Force -String "$Password"
  Write-Host "$adminname , $password"
  $credential = New-Object System.Management.Automation.PSCredential($adminname,$adminpassword)
  Remove-computer -UnjoinDomaincredential $credential -PassThru -Verbose -Force
  Write-Host "Removed from domain @@{AD_DOMAIN}@@"
}

RemoveFromDomain -DomainName "@@{AD_DOMAIN}@@" -Username "@@{AD_ADMIN.username}@@" -Password "@@{AD_ADMIN.secret}@@"

