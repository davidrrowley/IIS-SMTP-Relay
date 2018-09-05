#read in to an array from a .csv file the IP addresses you want to import the format is x.x.x.x, x.x.x.x in the file
$file1 = "c:\users\davidrow\documents\serverlistforimport.csv"
$read = New-Object System.IO.StreamReader($file1)
$serverarray1 = @()
while (($line = [string[]]($read.ReadLine()) -ne $null))
  {
    $serverarray1 += $line
  }
$read.Dispose()

#Establish connection to the IIS SMTP object and pull the current server list
$iisObject = new-object System.DirectoryServices.DirectoryEntry("IIS://localhost/smtpsvc/1")
$relays = $iisObject.Properties["RelayIpList"].Value
$bindingFlags = [Reflection.BindingFlags] "Public, Instance, GetProperty"
$ipList = ($relays.GetType().InvokeMember("IPGrant", $bindingFlags, $null, $relays, $null))

#Now export the current server list to a file both for audit and script purposes
$iplist | out-file -filepath "c:\users\davidrow\documents\currentiplistconfigured.csv" -Force

#read in the file that has the current IP list and added to a multi-line object array
$file2 = "c:\users\davidrow\documents\currentiplistconfigured.csv"
$read = New-Object System.IO.StreamReader($file2)
$serverarray2 = @()
while (($line = [string[]]($read.ReadLine()) -ne $null))
  {
    $serverarray2 += $line
  }
$read.Dispose()

#Merge the two arrays
$stagingarray = $serverarray1 + $serverarray2

#Export the merged array to a file, again for audit and script purposes
#We de-duplicate the array during this process to ensure we dont have duplicate values being imported which causes scrtip errors

#Note that this is the file that will be used for the import into the SMTP Object
$stagingarray | select-object -unique | out-file -filepath "c:\users\davidrow\documents\Current_and_New_Servers_for_import.csv"

#read in the data from the file and assign to the $IPlist object
$file3 = "c:\users\davidrow\documents\Current_and_New_Servers_for_import.csv"
$read = New-Object System.IO.StreamReader($file3)
$serverarray3 = @()
while (($line = [string[]]($read.ReadLine()) -ne $null))
  {
    $serverarray3 += $line
  }
$read.Dispose()
$iplist = $serverarray3

# This is important, we need to pass an object array of one element containing our ipList array
[Object[]] $ipArray = @()
$ipArray += , $ipList


# Establish the write connection to the IIS SMTP object and update
$bindingFlags = [Reflection.BindingFlags] "Public, Instance, SetProperty"
$ipList = $relays.GetType().InvokeMember("IPGrant", $bindingFlags, $null, $relays, $ipArray);

$iisObject.Properties["RelayIpList"].Value = $relays
$iisObject.CommitChanges()