If BuildMacMachOx86 then
  
  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Xojo build script by App Wrapper Mini 1.2.2 (152) - ©2013 Ohanaware Co., Ltd.
  // Script Built: Jul 11, 2014 @ 4:32:30 PM
  // Script Format: 0007
  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Set-up the globally required variables
  ////////////////////////////////////////////////////////////////////////////////////////////////
  
  dim appPath as string = currentBuildLocation + "/" + shellEncode( currentBuildAppName )
  if right( appPath, 4 ) <> ".app" then appPath = appPath + ".app"
  if appPath = "/.app" then// - Validate that the script occurs _after_ the Build stage!
    msgBox( "Critical Script Error: Unable to get the path to the built application.", "Please ensure the App Wrapper Mini script is below the 'Build' action in the 'OS X' build settings." )
    
  else
    dim resourcesFolder as string = appPath + "/Contents/Resources/"
    dim plistFile as string = appPath+"/Contents/Info.plist"
    dim plistEntries( -1 ) as string
    const documentUUID = "63DB1CE3080DB8BA34"
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Adding in a custom application icon file
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    Try
      Dim iconFileName as string = readValue( plistFile, "CFBundleIconFile" )
      If trim( iconFileName ) = "" then
        msgbox( "There was an issue reading the apps plist file, the icon cannot be correctly installed." )
      else
        call copyFile( "/Users/jjoyce2/Library/Containers/com.ohanaware.appWrapperMini/Data/Library/Application\ Support/com.ohanaware.appWrapperMini/63DB1CE3080DB8BA34/applicationIcon.icns", resourcesFolder+ shellEncode( iconFileName ), "Installing custom icon" )
      End If
    End Try
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Begin Converting Version Numbers to Hybrid format.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    Try
      Dim versionString as string = readValue( plistFile, "CFBundleVersion" )
      plistEntries.append "CFBundleGetInfoString -string """+nthfield( versionString, ".", 1 )+"."+nthfield( versionString, ".", 2 )+"."+nthfield( versionString, ".", 3 )+""""
      plistEntries.append "CFBundleVersion -string """+nthfield( versionString, ".", 1 )+"."+nthfield( versionString, ".", 2 )+"."+nthfield( versionString, ".", 3 )+""""
    End Try
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Begin Building Property List Entries
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    plistEntries.append "LSApplicationCategoryType -string ""public.app-category.utilities"""
    plistEntries.append "NSHumanReadableCopyright -string ""© 2014 John Joyce"""
    // End Building Property List Entries
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Begin Adding Property List Entries
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    Try
      call writeValue( plistFile, "AppWrapperMini -int 1" )
      If readValue( plistFile, "AppWrapperMini" ) <> "1" then
        msgBox( "Failed to write to the plist file successfully" )
      Else
        Dim n,l as integer
        n = ubound( plistEntries )
        for l=0 to n
          If writeValue( plistFile, plistEntries( l ) ) = false then exit
        next
      End If
      call deleteValue( plistFile, "AppWrapperMini" )
    End Try
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Begin cleaning up the permissions
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    call execute( "/bin/chmod -RN "+appPath, "Resetting Permissions" )
    call execute( "/bin/chmod -R 755 "+appPath, "Resetting Permissions" )
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Touching the file....
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    call execute( "/usr/bin/touch -acm "+appPath, "Touching the app" )
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Build an Apple OS X Installer Package
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    Try
      Dim command as string = "productbuild --component "+appPath+" /Applications"
      // Make the installer file name safe for online
      Dim safeName as string = replaceAll( TitleCase( currentBuildAppName ), " ", "" )
      safeName = replaceAll( safeName, chr( 34 ), "" )
      safeName = replaceAll( safeName, "&", "" )
      safeName = replaceAll( safeName, "/", "" )
      safeName = replaceAll( safeName, ":", "" )
      safeName = replaceAll( safeName, "-", "\-" )
      command = command + " " + currentBuildLocation + "/" + safeName + ".pkg"
      Dim result as string = DoShellCommand( command )
      If instr( result, "error:" ) > 0 then msgbox( "An error occured while building the installer package", result )
    End Try
    
  End if // End Execution Block - after validating the script is in the correct location.
  
Else
  msgBox( "App Wrapper Mini currently only support Mac builds" )
End If // End Macintosh Specific Block

////////////////////////////////////////////////////////////////////////////////////////////////
// Helper functions for this script
////////////////////////////////////////////////////////////////////////////////////////////////

Function execute( inCommand as string, inMethodName as string ) as boolean
  Dim result as string = DoShellCommand( inCommand )
  if result <> "" then
    msgbox( "An error occurred while "+inMethodName, "Message: "+result )
    return false
  else
    return true
  end if
End Function
Function shellEncode( inValue as string ) as string
  Dim rvalue as string = replaceAll( inValue, " ", "\ " )
  rvalue = replaceAll( rvalue, "&", "\&" )
  rvalue = replaceAll( rvalue, "-", "\-" )
  rvalue = replaceAll( rvalue, "(", "\(" )
  rvalue = replaceAll( rvalue, ")", "\)" )
  return rvalue
End Function
Sub msgBox( inMessage as string, inSecondLine as string = "" )
  call showDialog( inMessage, inSecondLine, "OK", "", "", 0 )
End Sub
Function copyFile( inSource as string, inTarget as string, inMethodName as string ) as boolean
  return execute( "/bin/cp -fR "+inSource+" "+inTarget, inMethodName )
End Function
Function readValue( plistFile as string, key as string ) as string
  return trim( DoShellCommand( "/usr/bin/defaults read "+plistfile+" "+key ) )
End Function
Function writeValue( plistFile as string, value as string ) as boolean
  return execute( "/usr/bin/defaults write "+plistFile+" " + value, "Adding "+value+" to the info.plist file." )
End Function
Function deleteValue( plistFile as string, key as string ) as boolean
  return execute( "/usr/bin/defaults delete "+plistFile+" "+key, "Deleting "+key+" from info.plist file." )
End Function