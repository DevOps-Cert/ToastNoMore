<#
    Serialize Sitecore items for Site backup and restore.
    
    Uses:
        :\>get-help Serialize-Item 
        :\>get-help Export-Item
        
        By default, this will export serialized .item files to the host directory :\inetpub\wwwroot\SitecoreInstance\Data\serialization\
        
    Requires: Sitecore Powershell Extensions: https://marketplace.sitecore.net/en/Modules/Sitecore_PowerShell_console.aspx
    
    Author: Mark Taylor (mark.a.taylor@gmail.com) https://github.com/Toastbuster
#>
[bool] $isSerialize_Sites = $true
[bool] $isSerialize_Layouts = $false
[bool] $isSerialize_Templates = $false

# Serialize Sites 
#-------------------------------------------------------------------------------------------------
[string[]] $sites = 
    "master:\content\Home", 
    "master:\content\Global", 
    "master:\content\Developing-in-Sitecore",
    "master:\content\DoesNotExist"
    
# Serialize Layouts
#-------------------------------------------------------------------------------------------------
[string[]] $layouts = 
    "master:\layout\layouts", 
    "master:\layout\renderings",
    "master:\layout\sublayouts"
    
# Serialize Templates
#-------------------------------------------------------------------------------------------------
[string[]] $templates = 
    "master:\Templates\Common"


# SerializeSitecore
#-------------------------------------------------------------------------------------------------
function SerializeSitecore ($treeNode)
{
    foreach($node in $treeNode) {
        $item = Get-Item $node -ErrorAction SilentlyContinue 
    
        if ($item.Length -ne 0) {
            $serializationFolder = [Sitecore.Configuration.Settings]::GetSetting("SerializationFolder");
          
            #Create -Root argument for Export-Item. This also makes zip file creation easy.
            $database     = ($node -split ":")[0]
            $fullPath     =  $serializationFolder.Replace("/","") + "\\" + $database + $item.Paths.Path.Replace("/","\\")
            $targetPath   = [system.io.Path]::GetFullPath($fullPath + "\..\")
            $zipFilePath  = $targetPath + $item.Name + "-" + (get-date -Format FileDateTime).toString()
               
            # Create zip and delete non zip folder.
            Write-Host $node ": is being serialized." -foreground yellow
            $item | Export-Item -Root $zipFilePath -Recurse
            
            Add-Type -assembly "system.io.compression.filesystem"
            $destination = $zipFilePath + ".zip"
            [io.compression.zipfile]::CreateFromDirectory($zipFilePath, $destination)
            Write-Host $node "successfully serialized to " $destination -foreground green
            
            Write-Host "Clean Up. Remove directory files:" $zipFilePath
            Remove-Item $zipFilePath -Recurse
            Write-Host "`r`n" 
        }
        else {
            Write-Host $node ": has not been found. Cannot serialize node." -foreground red -background black
            Write-Host "`r`n" 
        }
    }
}#:~


# Invoke Serialization 
#-------------------------------------------------------------------------------------------------
$tuples = [System.Tuple]::Create($isSerialize_Sites, $sites),
          [System.Tuple]::Create($isSerialize_Layouts, $layouts),
          [System.Tuple]::Create($isSerialize_Templates, $templates)

foreach ($t in $tuples) {
    $isSerialize = $t.item1
    $nodes = $t.item2
    
    if ($isSerialize)  {
        SerializeSitecore $nodes
    }
}





