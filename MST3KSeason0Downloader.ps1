###Suppress Progress bar because it significantly slows downloading in PS 5 and lower###
$ProgressPreference = 'SilentlyContinue'

###Get web links as Chrome###
$agent = ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)

###Get all links on the webpage###
$mst3k = iwr 'https://archive.org/details/mst3k_season_0' -UseBasicParsing -UserAgent $agent

###Get all mp4 links###
$links=$mst3k.links.href | where {$_ -like "*.mp4"}

###Where you want the files stored###
Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.Description = 'Select a folder'
$FolderBrowser.RootFolder = "MyComputer"
$FolderBrowser.SelectedPath = "$env:USERPROFILE\Downloads"
$FolderBrowser.ShowDialog()
$dest = $FolderBrowser.SelectedPath

###Create containing folder if necessary###
if($dest -notlike "*\MST3K"){
    $newfolder = New-Item "$dest\MST3K" -ItemType Directory -Force
    $dest = $newfolder.FullName
}

###Download all video files with the above links/parameters###
Foreach($link in $links){
    ###Set each video's variables###
    $decode = [System.Web.HttpUtility]::UrlDecode($link)
    $title = ($decode -split ' - ')[-1]
    $episode = ($decode -split ' - ')[1].Replace('K','0x')
    $filename = "MST3K - $episode - $title"
    $season = 'Specials'
    $seasonfolder = New-Item "$dest\$season" -ItemType Directory -Force | select -ExpandProperty Fullname
    ###Create folder if not present###
    if(!(Test-Path "$dest\$season")){
        
        @"
****************************
*********$($season.toupper())**********
****************************
"@
    }
    ###Download file if not present###
    if(!(Test-Path "$seasonFolder\$fileName")){
        ###Counter for retries as sometimes archive.org does rate limit and we just try again###
        $count = 0

        ###Loop the download until the file is present or retries up to 30 times###
        Do{
            try{
                "Downloading $filename"
                $null = Iwr "https://archive.org$link" -OutFile "$seasonFolder\$fileName" -UseBasicParsing -UserAgent $agent
                "Download SUCCESSFUL"
            } catch {
                if($count -lt 30){
                    "Download FAILED...Retrying in 60 seconds"
                    Start-Sleep -Seconds 60
                } else {
                    "Download FAILED...Moving on to next episode"
                    $_
                }
                
            }
            $count++
        } until ((Test-Path "$seasonFolder\$fileName") -or $count -ge 30)
    } else {
        "Already downloaded $filename"
    }
}
