<#
    Serialize Sitecore items for Site backup and restore.
    
    Uses:
        :\>get-help Serialize-Item 
        :\>get-help Export-Item
        
        By default, this will export serialized .item files to the host directory :\inetpub\wwwroot\SitecoreInstance\Data\serialization
        
    Requires: Sitecore Powershell Extensions: https://marketplace.sitecore.net/en/Modules/Sitecore_PowerShell_console.aspx
    
    Author: Mark Taylor https://github.com/Toastbuster
#>

function Get-DefaultSerilizationFolder
{
	$serializationFolder = ([Sitecore.Configuration.Settings]::GetSetting("SerializationFolder")).Replace("/","");
	return $serializationFolder
}

function New-ZipFile ($sourceFolder,$destinationFolder)
{
	# Set the destination of the zip file to the default Sitecore serialization folder if a destination is not specified.
	if ($destinationFolder.Length -eq 0) {
		$destinationFolder = Get-DefaultSerilizationFolder
	}

	# Get the name of root source folder for the zip file name creation
	$zipFile = (Get-Date -Format "yyyyMMddThhmmss") + "-" + (Split-Path $sourceFolder -Leaf) + ".zip"
	$zipFilePath = $destinationFolder + "\" + $zipFile

	# Create new zip file with .NET library
	Add-Type -Assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::CreateFromDirectory($sourceFolder,$zipFilePath)

	return $zipFilePath
}


# Serializes entire Sitecore tree 'Export-Item "master:\" -Recurse -Verbose'
# Then creates a zip archive of the export
# Then performs a cleanup and removes unzipped files.
# 
#-------------------------------------------------------------------------------------------------
Write-Host "BEGIN Serialization"

# Export entire sitecore master database content tree
Export-Item "master:\" -Recurse


# Create zip archive
Write-Host "creating new zip file..."
$sourceFolder      = (Get-DefaultSerilizationFolder) + "\master"
$destinationFolder = Get-DefaultSerilizationFolder
$zipFilePath       = New-ZipFile $sourceFolder $desintationFolder
Write-Host "Successfully created new zip file " $zipFilePath -foreground green


# Perform cleanup
Write-Host "performing cleanup..."
Remove-Item $sourceFolder -Recurse

Write-Host "END Serialization. Operation complete." -NewLine


