<#
    Zip or Remove Log files from a specified folder location 
    
    Author: mark.a.taylor@gmail.com
#>

# HOWTO: Add directories for file zip archiving or deletion using the $filePaths Tuples.
#
#     Tuples are in the format: [tuple]::Create($source, "zip", $destination)
#     If no destination is specified, then the destination is the same folder/ directory as the $source.
#
# Specify directorys and whether to "zip", "delete", "zipdelete" them e.g.
#
# [tuple]::Create("C:\inetpub\wwwroot\Sitecore\Data\logs\", "zip"),
# [tuple]::Create("C:\inetpub\wwwroot\Sitecore\Data\logs\", "delete"),
# [tuple]::Create("C:\inetpub\wwwroot\Sitecore\Data\logs\", "zipdelete")
#
# IMPORTANT: Comma separate Tuples.
#
# IMPORTANT: Remember that when using directories from the "inetpub" folder or other system folders, 
# to please ensure that the script is run with the appropriate priviledges i.e. "Run as administrator" mode.
#
# NOTE: zipdelete = zip + delete. These operations are equivalent.
#-------------------------------------------------------------------------------------------------
$filePaths = 
    [tuple]::Create("C:\inetpub\wwwroot\Sitecore\Data\logs", "zip"),
    #[tuple]::Create("C:\inetpub\wwwroot\Sitecore\Data\logs", "zipdelete"),
    [tuple]::Create("C:\inetpub\wwwroot\Sitecore\Data\logs", "delete")



# HELPER FUNCTIONS 
#-------------------------------------------------------------------------------------------------
function CreateZip ($source, $destination) {
    #Copy source directory to a temporary directory, in the case that any processes are writing to log files and have them locked.
    $tmpDirectory = new-object system.io.DirectoryInfo($source.Parent.FullName + "\" + $source.Name + "tmp" + (get-date -Format FileDateTime).toString() + "\")
    $zipFile = new-object system.io.DirectoryInfo($destination.FullName + "\" + $destination.Name  + "-" + (get-date -Format FileDateTime).toString() + ".zip")
			
    try { 
        # Create a temporary directory and then copy the items to that directory for archiving.
        New-Item $tmpDirectory.FullName -Type directory | Out-Null
        Get-ChildItem $source.FullName -Recurse | where {$_.FullName -notmatch "\.zip"} | Copy-Item -Destination {Join-Path $tmpDirectory.FullName $_.FullName.Substring($source.FullName.Length)}

        #*- 
	Write-Host ("Compressing directory:'{0}', to zip archive:'{1}'" -f $source, $zipFile.FullName)
        #-*
			        
	Add-Type -assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($tmpDirectory.FullName, $zipFile.FullName)

        #*- 
	Write-Host "Archive creation complete." -ForegroundColor Yellow 
        #-*
    }
    finally {
        # Remove the created temporary directory and its files.
        if ($tmpDirectory.Exists) {
            Remove-Item $tmpDirectory -Recurse
        }
    }
}

function DeleteFiles ($source, $isIncludeZipFiles) {
    #*- 
    Write-Host ("Deleting files in source path:'{0}'" -f $source) -NoNewline
    #-*
    if ($isIncludeZipFiles) {         
        Remove-Item -Path $source.FullName -Recurse
    }
    else {
        #*- 
	Write-Host ("Deleting files in source path, excluding .zip files:'{0}'" -f $source)
        #-*

        Remove-Item -Path $source.FullName -Recurse -Exclude "*.zip"
        
        #*- 
	Write-Host "File deletion complete" -ForegroundColor Yellow
        #-*
    }
}

# MAIN METHOD LogClean
#-------------------------------------------------------------------------------------------------
function LogClean ($tuples) {  
    #*- Start all output on a new line
    Write-Host ""
    #-*

    foreach($tuple in $tuples) {
        #*-
        # Write-Host user output
        Write-Host "Processing Tuple: '" -ForegroundColor Yellow -NoNewline 
        Write-Host $tuple -ForegroundColor Green -NoNewline
        Write-Host "': " -ForegroundColor Yellow
		#-*

        try {
            $destination = $source = new-object System.IO.DirectoryInfo($tuple.Item1)
            
            if($tuple.Item3 -ne $null) {
                $destination = new-object System.IO.DirectoryInfo($tuple.Item3)
            }
            
            $isZip        = if($tuple.Item2 -eq "zip") {$true} else {$false} 
            $isDelete     = if($tuple.Item2 -eq "delete") {$true} else {$false}
            $isZipDelete  = if($tuple.Item2 -eq "zipdelete") {$true} else {$false}


            #*- Write-Host user output
            Write-Host "+---- Source directory:" $source.FullName  
            Write-Host "+---- Destination directory:" $destination.FullName  
            
            if($isZip) { 
                Write-Host "+---- Creating zip archive for source" 
            }
            if($isZipDelete) { 
                Write-Host "+---- Creating zip archive for source and deleting original files" 
            }
            if($isDelete) {
                Write-Host "+---- Deleting log files and clearing the source directory" 
            }
            #-*
            
            if($source.Exists -and $destination.Exists) {

                # Process Zip Files
                #-------------------------------------------------------------------------------------------------
		if($isZip) {
                    CreateZip $source $destination
		}

                # Process ZipDelete Files
                # Zip files, then delete everything except the zip files. Equivalent to running Zip then Delete.
                #-------------------------------------------------------------------------------------------------
		if($isZipDelete) {
                    CreateZip $source $destination
                    DeleteFiles $source $false
		}

                # Process Delete Files
                #-------------------------------------------------------------------------------------------------
                if($isDelete) {
                    DeleteFiles $source $false
                }
            }
            else {
                #*- Write-Host user output
                Write-Host "Error processing Tuple '"-ForegroundColor red -BackgroundColor Black -NoNewline
                Write-Host ${tuple} -ForegroundColor Gray -BackgroundColor Black -NoNewline
                Write-Host "': " -ForegroundColor Red -BackgroundColor Black

                if (!$source.Exists) { 
                    Write-Host "+---- Source does not exist. Source: " -ForegroundColor red -BackgroundColor Black -NoNewline
                    Write-Host $source.FullName -ForegroundColor Gray -BackgroundColor Black
                }
                if (!$destination.Exists) {
                    Write-Host "+---- Destination does not exist. Destination: " -ForegroundColor red -BackgroundColor Black -NoNewline
                    Write-Host $destination.FullName -ForegroundColor Gray -BackgroundColor Black
                }
                #-*
            }
        }
        catch [System.Management.Automation.MethodInvocationException] {
            Write-Host $_.Exception.Message "for" $tuple -ForegroundColor Red
        }
        catch {
            Write-Host $_.Exception.Message "for" $tuple -ForegroundColor Red
        }
        finally {
            Write-Host ""
        }
    }
}#:~


LogClean $filePaths


