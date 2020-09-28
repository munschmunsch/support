function Get-WellFormedSoftware
{

   <#
.Synopsis
   Examine registry entries of installed software of 64 and 32 bit varities.
.DESCRIPTION
   Pull back software from both registry locations wow64 and wow32, examine all attributes of installation and present as individual attributes. This functions as an output only function at the moment.
.EXAMPLE
   Get-WellFormedSoftware 
.EXAMPLE
   Get-WellFormedSoftware -Verbose
#>

[CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
    <#
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Param1,

        # Param2 help description
        [int]
        $Param2
        #>
    )
 Begin
    {
    }
Process
{
$wellformedsoftware = @{}
Write-Verbose -Message "Getting Reg Entry 64bit"

$a =Get-CimInstance -ClassName Win32_Product | where {$_.Name -ne $null} | select Name, Version, InstallState, Caption, Description, IdentifyingNumber, Vendor, InstallDate, InstallSource, LocalPackage, PackageCache, PackageCode, PackageName

$reg = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -ne $null} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString
$count = $reg.Count
Write-Verbose "Count: $Count"

foreach ( $r in $reg)
{
Write-Verbose -Message "$r"

$name  = $r.DisplayName
Write-Verbose "Name: $name"
$date  = $r.InstallDate
$a = $r.UninstallString
Write-Verbose -Message "Before date assessment"
if($date -ne $null){
$date = $date.ToString()
Write-Verbose -Message "Date: $date"
$year  = $date.Substring(0,4)
$month = $date.Substring(4,2)
$day   = $date.SubString(6,2)
$date  = $month + "/" + $day + "/" + $year
}
else {$date = $null}

if($a){
$a = $r.UninstallString.Split("{""}")
$guid = $a[1]
}
else { $a=$null}


$wellformedsoftware["$name"] = New-Object PSObject
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $name
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $r.DisplayVersion
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "InstallDate" -Value $date
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $r.Publisher
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "GUID" -Value $guid


}

$reg = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -ne $null} |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, UninstallString

foreach ($r in $reg)
{

$name = $r.DisplayName
$date  = $r.InstallDate
$a = $r.UninstallString
if($date -ne $null){
$date  = $date.ToString()
$year  = $date.Substring(0,4)
$month = $date.Substring(4,2)
$day   = $date.SubString(6,2)
$date  = $month + "/" + $day + "/" + $year
}
else {$date = $null}


if($a){
$a = $r.UninstallString.Split("{""}")
$guid = $a[1]
}
else { $a=$null}



$wellformedsoftware["$name"] = New-Object PSObject
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $r.DisplayName
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $r.DisplayVersion
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "InstallDate" -Value $date
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $r.Publisher
$wellformedsoftware["$name"] | Add-Member -MemberType NoteProperty -Name "GUID" -Value $guid
}

}

End {
$wellformedsoftware.Values
}

}
