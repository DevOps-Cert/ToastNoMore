<#
    Deserialize Sitecore items for backup and restore.
    
    Uses:
        :\>get-help Deserialize-Item 
        :\>get-help Import-Item
        
    Requires: Sitecore Powershell Extensions: https://marketplace.sitecore.net/en/Modules/Sitecore_PowerShell_console.aspx
	
	Author: Mark Taylor https://github.com/Toastbuster
#>
[bool] $isPerformCleanup = $true
[bool] $isListDeserializeItems = $true
[bool] $isOverwrite = $true

[string] $defaultRoot = $serializationFolder = [Sitecore.Configuration.Settings]::GetSetting("SerializationFolder");
[string] $specifiedRoot = ""

[string[]] $deserialize = 
    "C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\master\sitecore\content\Home-20160519T1155554836.zip"


# Deserialize Sitecore Items
#-------------------------------------------------------------------------------------------------
if ($specifiedRoot -eq "")  {
    $specifiedRoot = ($defaultRoot.Replace("/","\") + "\").Replace("\\", "\") #Ensure end / is added - this is required by Import-Ite and then clean up any double backslash (\\) to single (\)
}

 foreach($archive in $deserialize) {
    Write-Host "Deserializing '$archive'"
    
    $archiveFileExists = if ((Get-Item $archive -ErrorAction SilentlyContinue).Length -ne 0) { $true } else { $false}  
    if (-Not $archiveFileExists)
    {
        Write-Host "'$archive' not found." -foreground red -background black
        continue
    }
    
    $extractDirectory = $archive.Substring(0, $archive.LastIndexOf("."))
    
    #Extract zip files and overwrite if appropriate
    $directoryExists = if ((Get-Item $extractDirectory -ErrorAction SilentlyContinue).Length -ne 0) { $true } else { $false}  
    
    if ($directoryExists -And (-Not $isOverwrite)) 
    {
        Write-Host "Extract directory" $extractDirectory "already exists. Serializing from this directory. Please re-run the script and use the isOverwrite switch to replace the existing directory." -foreground red -background black    
    }
    else 
    {
        if ($directoryExists -And $isOverwrite) 
        {
            Write-Host "Overwrite enabled. Removing existing directory" $extractDirectory
            Remove-Item $extractDirectory -Recurse
        }
        
        Write-Host "Extracting" $archive "to directory" $extractDirectory -foreground yellow
        [io.compression.zipfile]::ExtractToDirectory($archive, $extractDirectory)
    }

    Write-Host "Deserializing archive to sitecore from" $extractDirectory
    if ($isListDeserializeItems -eq $true)  {
        Get-ChildItem $extractDirectory -Recurse
    }
    
    deserialize-item -Path $extractDirectory -Root $specifiedRoot -Recurse -ForceUpdate
    Write-Host "Items deserialized ..." -foreground green
     
    if ($isPerformCleanup -eq $true)  {
        Write-Host "Clean Up. Remove directory files:" $extractDirectory
        Remove-Item $extractDirectory -Recurse
    }
}

Write-Host "End of deserialization"

