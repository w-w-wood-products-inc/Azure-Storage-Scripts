#Server side storage copy
$SourceStorageAccount = "ACCOUNTNAME"
$SourceStorageKey = "ACCOUNTKEY"
$StorageContext = New-AzureStorageContext -StorageAccountName $SourceStorageAccount -StorageAccountKey $SourceStorageKey
$ContainerName = "CONTAINERNAME"

$BlobSpecies = @("value", "value")

foreach ($Species in $BlobSpecies)
{
	$Blobs = Get-AzureStorageBlob -Context $StorageContext -Container $ContainerName | Where-Object {$_.ICloudBlob.Metadata["species"] -eq $Species} 

	#Delete everything in list
	foreach ($Blob in $Blobs)
	{
		$BlobName = $Blob.Name
		Write-Output "Deleting $BlobName with species $Species from $ContainerName"
		Remove-AzureStorageBlob -Blob $BlobName -Container $ContainerName -Context $StorageContext
	}
}
