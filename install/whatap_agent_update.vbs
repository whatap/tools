dim filesys 
Set filesys = CreateObject("Scripting.FileSystemObject")

If filesys.FolderExists("C:\Program Files\Whatap\plugins\oracle") or filesys.FolderExists("C:\Program Files (x86)\Whatap\plugins\oracle") Then
    installerName = "whatap_db.exe"
else
    installerName = "whatap.exe"
end if
    
Set req = CreateObject("MSXML2.XMLHTTP")
req.open "GET", "http://repo.whatap.io/windows/x86/version.txt", False
req.send
latestAgentVersion= req.responseText
latestAgentVersion= Replace(latestAgentVersion, vbCr, "")
latestAgentVersion= Replace(latestAgentVersion, vbLf, "")

Set WSHShell = CreateObject("WScript.Shell")
installedAgentVersion = WSHShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Whatap_is1\DisplayVersion")

if latestAgentVersion <> installedAgentVersion Then
    Dim tempFolder: tempFolder = filesys.GetSpecialFolder(2)
    strFileURL = "http://repo.whatap.io/windows/x86/"&installerName
    strHDLocation = tempFolder & "\whatap_setup.exe"
    If filesys.FileExists(strHDLocation) Then
        filesys.DeleteFile(strHDLocation)
    End If

    Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
    objXMLHTTP.open "GET", strFileURL, false
    objXMLHTTP.send()
    If objXMLHTTP.Status = 200 Then
        Set objADOStream = CreateObject("ADODB.Stream")
        objADOStream.Open
        objADOStream.Type = 1
        objADOStream.Write objXMLHTTP.ResponseBody
        objADOStream.Position = 0   
        objADOStream.SaveToFile strHDLocation
        objADOStream.Close
        Set objADOStream = Nothing
    End if
    Set objXMLHTTP = Nothing
    Set objShell = CreateObject("WScript.Shell")
    updateCommand = strHDLocation & " /SILENT"
    Set updateProcess= objShell.Exec(updateCommand)
    
    Do While updateProcess.Status = 0
         WScript.Sleep 100
    Loop
    
    filesys.DeleteFile strHDLocation
end if