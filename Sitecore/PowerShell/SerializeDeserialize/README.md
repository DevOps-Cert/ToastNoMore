# Serialize & Deserialize Sitecore using PowerShell

Requires the 'Sitecore Powershell Extensions' module from https://marketplace.sitecore.net/en/Modules/Sitecore_PowerShell_console.aspx  
This module allows two PowerShell commands to be run
 * Serialize-Item (alias Export-Item)
 * Deserialize-Item (alias Import-Item)
 
 There are some gotchas to note:
 
##Gotcha 1.
Root must end wtih a backslash  
 
Example: For <code>```:\>deserialize-item -Path $extractDirectory -Root $specifiedRoot -Recurse -ForceUpdate```</code>   
Correct when -Root equals   ```"C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\```   
Incorrect when -Root equals ```"C:\inetpub\wwwroot\SitecoreInstance\Data\serialization"```  
 
##Gotcha 2.
get-help states that -Path is the path to the serialized files without the .item extension. This is only the case when recursing directories, it is not the case for deserializing single items.
 
Example: For single .item file deserialization when <code>```:\>deserialize-item -Path $extractDirectory -Root $specifiedRoot```</code>  

Correct when -Path equals ```"C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\master\sitecore\content\Home.item"```  

Incorrect and will fail when -Path equals ```"C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\master\sitecore\content\Home```  

##Gotcha 3.
When using Deserialise-Item, if there are existing items in the Sitecore Content tree, the items will not update unless the -ForceUpdate argument is used. e.g.   
Correct: <code>```:\>deserialize-item -Path $extractDirectory -Root $specifiedRoot -Recurse -ForceUpdate```</code>  
Incorrect: <code>```:\>deserialize-item -Path $extractDirectory -Root $specifiedRoot -Recurse```</code>  

##Gotcha 4.
Using a -Path directory other than the defined "Serialization Folder" e.g. ```[Sitecore.Configuration.Settings]::GetSetting("SerializationFolder")``` during Deserialization will fail.

Example:  Using the following directory layout (at incorrect location ```C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\Home-20160519T0918127662```)
```
Directory: C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\Home-20160519T0918127662
 
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----       19/05/2016     13:48                Home
-a----       19/05/2016     09:18           7128 Home.item
 
 
    Directory: C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\Home-20160519T0918127662\Home
    
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----       19/05/2016     13:48                About-Launch-Sitecore
d-----       19/05/2016     13:48                Audience
d-----       19/05/2016     13:48                Glossary
d-----       19/05/2016     13:48                Team
-a----       19/05/2016     09:18           4659 About-Launch-Sitecore.item
-a----       19/05/2016     09:18           4010 Audience.item
-a----       19/05/2016     09:18           4746 Configuration.item
-a----       19/05/2016     09:18           6025 Error.item
-a----       19/05/2016     09:18           3488 Glossary.item
-a----       19/05/2016     09:18           4965 Login.item
-a----       19/05/2016     09:18           4854 Register.item
-a----       19/05/2016     09:18           7178 Search.item
-a----       19/05/2016     09:18           4230 Team.item
```

Using this diretory path the following command fails <code>```:\>deserialize-item -Path "C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\Home-20160519T0918127662" -Root "C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\" -Recurse -ForceUpdate```</code>   

The resulting error is:  
```
deserialize-item : Some directories could not be loaded: C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\Home-20160519T0918127662\Home
At line:1 char:1
+ deserialize-item -Path "C:\inetpub\wwwroot\SitecoreInstance\Data\serializa ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Import-Item], Exception
    + FullyQualifiedErrorId : System.Exception,Cognifide.PowerShell.Commandlets.Serialization.ImportItemCommand
```
Therefore, examples of correct and incorrect directory paths are:  
Correct: ```C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\master\sitecore\content\Home-20160519T0918127662\```   
Incorrect: ```C:\inetpub\wwwroot\SitecoreInstance\Data\serialization\\Home-20160519T0918127662\```  
