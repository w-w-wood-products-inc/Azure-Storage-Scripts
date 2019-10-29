#Server side storage copy
$SourceStorageAccount = "ACCOUNTNAME"
$SourceStorageKey = "ACCOUNTKEY"
$DestStorageAccount = "ACCOUNTNAME"
$DestStorageKey = "ACCOUNTKEY"
$SourceStorageContext = New-AzureStorageContext -StorageAccountName $SourceStorageAccount -StorageAccountKey $SourceStorageKey
$DestStorageContext = New-AzureStorageContext -StorageAccountName $DestStorageAccount -StorageAccountKey $DestStorageKey
$SourceContainerName = "CONTAINERNAME"
$DestContainerName = "CONTAINERNAME"

$BlobSpecies = @("value", "value", "value")

foreach ($Species in $BlobSpecies)
{
	$Blobs = Get-AzureStorageBlob -Context $SourceStorageContext -Container $SourceContainerName | Where-Object {$_.ICloudBlob.Metadata["species"] -eq $Species}
	$BlobCpyAry = @() #Create array of objects

	#Do the copy of everything
	foreach ($Blob in $Blobs)
	{
	   $BlobName = $Blob.Name
	   Write-Output "Copying $BlobName with species $Species from finishes to stain"
	   $BlobCopy = Start-CopyAzureStorageBlob -Context $SourceStorageContext -SrcContainer $SourceContainerName -SrcBlob $BlobName -DestContext $DestStorageContext -DestContainer $DestContainerName -DestBlob $BlobName -Force
	   $BlobCpyAry += $BlobCopy
	}

	#Check Status
	foreach ($BlobCopy in $BlobCpyAry)
	{
	   #Could ignore all rest and just run $BlobCopy | Get-AzureStorageBlobCopyState but I prefer output with % copied
	   $CopyState = $BlobCopy | Get-AzureStorageBlobCopyState
	   $Message = $CopyState.Source.AbsolutePath + " " + $CopyState.Status + " {0:N2}%" -f (($CopyState.BytesCopied/$CopyState.TotalBytes)*100) 
	   Write-Output $Message
	}
}
