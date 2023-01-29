<#
    .SYNOPSIS
    一个能从 Bestdori 上自动下载音乐并填入音乐信息的脚本。
    A script that automatically downloads music from Bestdori and fills in the music information.

    .DESCRIPTION
    一个能从 Bestdori 上自动下载音乐并填入音乐信息（歌曲标题、歌手、专辑、作曲人员和封面）的脚本。
    A script that automatically downloads music from Bestdori and fills in the music information.(Song title, Artist, Album, Composer and Front cover)

    .PARAMETER listFile
    指定歌曲ID文件。若值为“all”则下载全部歌曲。
    Specify the song ID file. If value is "all", download all songs.

    .PARAMETER mainServer
    指定下载服务器。
    Specify the download server.

    .PARAMETER customAlbumName
    指定专辑名称。
    Specify the album name.

    .PARAMETER defaultJacket
    指定默认歌曲图片ID。若不存在则为0。
    Specify default song image ID. Will auto reset to 0 if not exist.

    .PARAMETER forceRedownload
    启用强制重新下载。即使文件存在也将重新下载。
    Enable forced redownload. Will redownload even if the file exists.

    .PARAMETER Clean
    脚本完成后清理下载数据。
    Clean up downloaded data when script finished.

    .PARAMETER Ignore
    当有错误时不暂停运行脚本。
    Ignore error's pause.

    .PARAMETER moreInfo
    脚本执行时显示更多信息。
    Show more information when script execution.

    .INPUTS
    输入 -listFile 指定的歌曲ID文件。
    Input -listFile Specify the song ID file.
    
    .OUTPUTS
    Origin 文件夹 - 保存源音乐文件至 Origin 文件夹。
    Origin Folder - Save origin music file to Origin folder.
    Jacket 文件夹 - 保存源封面文件至 Origin 文件夹。
    Jacket Folder - Save origin front cover file to Origin folder.
    Output Folder - 转换并保存音乐至 Output 文件夹。
    Output Folder - Convert and save music to Output folder.

    .EXAMPLE
    .\bmd.ps1 -listFile listFile.sample.json
    最简/Simplest

    .EXAMPLE
    .\bmd.ps1 -listFile listFile.sample.json -mainServer cn -customAlbumName "BanG Dream!" -forceRedownload -Clean
    最全/Fullest

    .LINK
    https://github.com/SummonHIM/Bestdori-Music-Downloader
#>

param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$listFile,
    [string]$mainServer = "jp",
    [string]$customAlbumName = "バンドリ！　ガールズバンドパーティ！",
    [int]$defaultJacket = 0,
    [switch]$forceRedownload = $false,
    [switch]$Clean = $false,
    [switch]$Ignore = $false,
    [switch]$moreInfo = $false
)

if ($host.Version -le 5.1) {
    Write-Output ""
    Write-Output "Your PowerShell version is too low. Please upgrade your PowerShell."
    Write-Output "You can download the Windows Management Framework 5.1 to upgrade your PowerShell to 5.1:"
    Write-Output "https://docs.microsoft.com/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-5.1"
    Write-Output ""
    Write-Output "Press Ctrl+C or wait 60 second to exit..."
    Start-Sleep 60
    exit
}

$lang = Data {
    #culture="en-US"
    ConvertFrom-StringData -StringData @'
    infoLoadLibrary = Loading library
    successLoadLibrary = Loaded successfully!
    errorLoadLibrary = Loading failed!
    infoDwlAllSongsID = Fetching all songs ID
    infoLoadSongID = Reading the song ID in file
    successLoadSongID1 = 
    successLoadSongID2 = song IDs have been read!
    errorLoadSongID = No song IDs were read! Please check your song ID list file.
    infoDownloadBandInfo = Downloading band information
    successDownloadBandInfo = Band information downloaded successfully!
    errorDownloadBandInfo = No band information has been downloaded! Please check your network connection.
    errorSpecifiedServerNotFound = Specified server was not found.
    infoSongIDGetInfo1 = Downloading song information by song
    infoSongIDGetInfo2 = 
    successSongIDGetInfo = Song information downloaded successfully!
    errorSongIDGetInfo = No song information has been downloaded! Please check your network connection.
    infoBandTitle = Band - Title:
    infoLyCoAr = Lyricist, Composer, Arranger:
    errorTagLibNotFound = Library TagLibSharp.dll not found! Unable to write song information!
    errorParsedSongInfo = Failed to get song information! Please check your song ID, the specified download server and network connection.
    infoClean = Cleanup is enabled, deleting Jacket and Origin folders
    infoFolderNotFound1 = Folder
    infoFolderNotFound2 = not found, creating
    successFolderNotFound = Folder created successfully!
    errorFolderNotFound1 = Failed to create folder
    errorFolderNotFound2 = !
    infoDownloadingTo1 = Downloading
    infoDownloadingTo2 = to
    successDownloadingTo = Downloaded successfully!
    errorDownloadingTo = Download error! Please check your song ID, the specified download server and network connection.
    errorDownloadJacketType = Download error! The image does not exist on this server. Please check your song ID and specified download server.
    infoDownloadFileExist = Existed. Skip the download!
    infoCopyTo1 = Copying
    infoCopyTo2 = to
    successCopyTo = Copy successfully!
    errorCopyTo = Copy failed!
    infoWriteByTagLib = Writing song information using TagLibSharp.dll
    successWriteByTagLib = Image not found, skip!
    errorWriteByTagLibImgNotFound = Information written successfully!
    errorWriteByTagLib = Failed to write information!
'@
}
Import-LocalizedData -BindingVariable lang -BaseDirectory Localized -ErrorAction:SilentlyContinue

function Format-Renameable {
    param ([Parameter(Mandatory = $true, ValueFromPipeline = $true)]$iptString)
    Return $iptString.Replace('\', '-').Replace('/', '-').Replace(':', '-').Replace('*', '-').Replace('?', '-').Replace('"', '-').Replace('<', '-').Replace('>', '-').Replace('|', '-')
}

function downloadSong {
    param([Parameter(Mandatory = $true, ValueFromPipeline = $true)]$iptSongInfo)

    # If folder "Origin" not exist, mkdir.
    if (!(Test-Path "Origin")) {
        Write-Host $lang.infoFolderNotFound1 "Origin" $lang.infoFolderNotFound2 "..." -ForegroundColor White -NoNewline
        try {
            if ($moreInfo) { New-Item -Name "Origin" -ItemType Directory }
            else { New-Item -Name "Origin" -ItemType Directory | Out-Null }
            Write-Host "  -" $lang.successFolderNotFound -ForegroundColor Green
        } catch {
            Write-Host ""
            $errorFolderOriginNotFound = $lang.errorFolderNotFound1 + " Origin " + $lang.errorFolderNotFound2
            Write-Error -Message $errorFolderOriginNotFound -Category WriteError -ErrorId 6
            if (! $Ignore) { Pause }
            Return 1
        }
    }
    if (Test-Path "Origin\.temp.mp3") { Remove-Item "Origin\.temp.mp3" }
    
    # Generate music download url.
    $downloadSongUrl = "https://bestdori.com/assets/" + $mainServer + "/sound/" + $iptSongInfo.bgmId + "_rip/" + $iptSongInfo.bgmId + ".mp3"
    $saveSongPath = "Origin\" + $iptSongInfo.bgmId + ".mp3"
    # If music already downloaded, skip. else go download.
    if ((!(Test-Path $saveSongPath)) -or ($forceRedownload)) {
        Write-Host $lang.infoDownloadingTo1 $downloadSongUrl $lang.infoDownloadingTo2 $saveSongPath... -ForegroundColor White -NoNewline
        try {
            Invoke-WebRequest $downloadSongUrl -OutFile "Origin\.temp.mp3"
            Rename-Item -Path "Origin\.temp.mp3" -NewName $saveSongPath.Split("\")[1]
            Write-Host "  -" $lang.successDownloadingTo -ForegroundColor Green
        } catch {
            Write-Host ""
            Write-Error -Message $lang.errorDownloadingTo -Category WriteError -ErrorId 7
            if (! $Ignore) { Pause }
            if (Test-Path $saveSongPath) { Remove-Item $saveSongPath }
            Return 2
        } finally {
            if (Test-Path "Origin\.temp.mp3") { Remove-Item "Origin\.temp.mp3" }
        }
    } else { Write-Host "$saveSongPath" $lang.infoDownloadFileExist -ForegroundColor Yellow }

    Return 0
}

function downloadJacket {
    param([Parameter(Mandatory = $true, ValueFromPipeline = $true)]$iptSongInfo)

    # If folder "Jacket" not exist, mkdir.
    if (!(Test-Path "Jacket")) {
        Write-Host $lang.infoFolderNotFound1 "Jacket" $lang.infoFolderNotFound2 "..." -ForegroundColor White -NoNewline
        try {
            if ($moreInfo) { New-Item -Name "Jacket" -ItemType Directory }
            else { New-Item -Name "Jacket" -ItemType Directory | Out-Null }
            Write-Host "  -" $lang.successFolderNotFound -ForegroundColor Green
        } catch {
            Write-Host ""
            $errorFolderJacketNotFound = $lang.errorFolderNotFound1 + " Jacket " + $lang.errorFolderNotFound2
            Write-Error -Message $errorFolderJacketNotFound -Category WriteError -ErrorId 8
            if (! $Ignore) { Pause }
            Return 1
        }
    }
    if (Test-Path "Jacket\.temp.png") { Remove-Item "Jacket\.temp.png" }

    # Generate music jacket download url.
    $downloadJacketUrl = "https://bestdori.com/assets/" + $mainServer + "/musicjacket/musicjacket" + $iptSongInfo.JacketPkgID + "_rip/assets-star-forassetbundle-startapp-musicjacket-musicjacket" + $iptSongInfo.JacketPkgID + "-" + $iptSongInfo.jacketImage + "-jacket.png"
    $saveJacketPath = "Jacket\" + $iptSongInfo.jacketImage + ".png"
    # If music jacket already downloaded, skip. else go download.
    if ((!(Test-Path $saveJacketPath)) -or ($forceReDownload)) {
        Write-Host $lang.infoDownloadingTo1 $downloadJacketUrl $lang.infoDownloadingTo2 $saveJacketPath... -ForegroundColor White -NoNewline
        try {
            Invoke-WebRequest $downloadJacketUrl -OutFile "Jacket\.temp.png"
            Rename-Item -Path "Jacket\.temp.png" -NewName $saveJacketPath.Split("\")[1]
            Write-Host "  -" $lang.successDownloadingTo -ForegroundColor Green
        } catch {
            Write-Host ""
            Write-Error -Message $lang.errorDownloadingTo -Category WriteError -ErrorId 9
            if (! $Ignore) { Pause }
            if (Test-Path $saveJacketPath) { Remove-Item $saveJacketPath }
            Return 2
        } finally {
            if (Test-Path "Jacket\.temp.png") { Remove-Item "Jacket\.temp.png" }
        }
        if (Get-Content $saveJacketPath | Select-String DOCTYPE) {
            Write-Host ""
            Write-Error -Message $lang.errorDownloadJacketType -Category WriteError -ErrorId 10
            if (! $Ignore) { Pause }
            Remove-Item $saveJacketPath
            Return 3
        }
    } else { Write-Host "$saveJacketPath" $lang.infoDownloadFileExist -ForegroundColor Yellow }

    Return 0
}

function writeSongInfo {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$iptSongInfo,
        [switch]$jacketExist = $false
    )

    # If folder "Output" not exist, mkdir.
    if (!(Test-Path "Output")) {
        Write-Host $lang.infoFolderNotFound1 "Output" $lang.infoFolderNotFound2 "..." -ForegroundColor White -NoNewline
        try {
            if ($moreInfo) { New-Item -Name "Output" -ItemType Directory }
            else { New-Item -Name "Output" -ItemType Directory | Out-Null }
            Write-Host "  -" $lang.successFolderNotFound -ForegroundColor Green
        } catch {
            Write-Host ""
            $errorFolderOutputNotFound = $lang.errorFolderNotFound1 + " Output " + $lang.errorFolderNotFound2
            Write-Error -Message $errorFolderOutputNotFound -Category WriteError -ErrorId 12
            if (! $Ignore) { Pause }
            Return
        }
    }
    if (Test-Path "Output\.temp.mp3") { Remove-Item "Output\.temp.mp3" }

    # Generate save path.
    $originSongPath = "Origin\" + $iptSongInfo.bgmId + ".mp3"
    $outputSongPath = "Output\" + $iptSongInfo.rBandName + " - " + $iptSongInfo.rMusicTitle + ".mp3"
    $jacketPath = "Jacket\" + $iptSongInfo.jacketImage + ".png"
    # Copy music to Output folder
    Write-Host $lang.infoCopyTo1 $originSongPath $lang.infoCopyTo2 $outputSongPath "..." -ForegroundColor White -NoNewline
    try {
        Copy-Item $originSongPath -Destination "Output\.temp.mp3"
        Write-Host "  -" $lang.successCopyTo -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Error -Message $lang.errorCopyTo -Category WriteError -ErrorId 13
        if (! $Ignore) { Pause }
        Remove-Item "Output\.temp.mp3"
        Return
    }
    
    # If music jacket is bestdori 404(html), skip add-image.
    Write-Host $lang.infoWriteByTagLib "..." -ForegroundColor White -NoNewline
    try {
        $writingSongInfo = [TagLib.File]::Create("Output\.temp.mp3")
        $writingSongInfo.Tag.Title = $iptSongInfo.musicTitle
        $writingSongInfo.Tag.Artists = $iptSongInfo.bandName
        $writingSongInfo.Tag.Album = $customAlbumName
        $writingSongInfo.Tag.Composers = $iptSongInfo.lyricist + ";" + $iptSongInfo.composer + ";" + $iptSongInfo.arranger
        if ($jacketExist) { $writingSongInfo.Tag.Pictures = [TagLib.Picture]($jacketPath) } 
        else { Write-Host "  - " $lang.successWriteByTagLib -ForegroundColor Yellow -NoNewline }
        $writingSongInfo.Save()
        Rename-Item -Path "Output\.temp.mp3" -NewName $outputSongPath.Split("\")[1]
        Write-Host "  -" $lang.errorWriteByTagLibImgNotFound -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Error -Message $lang.errorWriteByTagLib -Category WriteError -ErrorId 14
        if (! $Ignore) { Pause }
        if (Test-Path $outputSongPath) { Remove-Item $outputSongPath }
        Return
    } finally {
        if (Test-Path "Output\.temp.mp3") { Remove-Item "Output\.temp.mp3" }
    }
}

[System.IO.Directory]::SetCurrentDirectory("$(Get-Location)")

# Load TagLibSharp.dll if exist
if (Test-Path "TagLibSharp.dll") {
    Write-Host $lang.infoLoadLibrary "TagLibSharp.dll..." -ForegroundColor White -NoNewline
    try {
        if ($moreInfo) { [Reflection.Assembly]::LoadFrom("TagLibSharp.dll") }
        else { [Reflection.Assembly]::LoadFrom("TagLibSharp.dll") | Out-Null }
        $checkTagLib = $true
        Write-Host "  -" $lang.successLoadLibrary -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Error -Message $lang.errorLoadLibrary -Category ResourceUnavailable -ErrorId 11
    }
    Write-Host ""
}

# Get $listFile's song id
if ($listFile -eq "all") {
    Write-Host $lang.infoDwlAllSongsID "..." -ForegroundColor White -NoNewline
    $getAllSongId = Invoke-RestMethod "https://bestdori.com/api/songs/all.0.json"
    $getlistFile = @{ songs = $getAllSongId.PSObject.Properties.Name }
} else {
    Write-Host $lang.infoLoadSongID "..." -ForegroundColor White -NoNewline
    $getlistFile = Get-Content $listFile | ConvertFrom-Json
}
if ($getlistFile.songs.Count -gt 0) { Write-Host "  -" $lang.successLoadSongID1 $getlistFile.songs.Count $lang.successLoadSongID2 -ForegroundColor Green }
else {
    Write-Host ""
    Write-Error -Message $lang.errorLoadSongID -Category ObjectNotFound -ErrorId 1
    Exit 1
}


# Get bestdori all band name and id
Write-Host $lang.infoDownloadBandInfo "..." -ForegroundColor White -NoNewline
$getBandInfo = Invoke-RestMethod "https://bestdori.com/api/bands/all.1.json"
if ($getBandInfo) { Write-Host "  -" $lang.successDownloadBandInfo -ForegroundColor Green } 
else {
    Write-Host ""
    Write-Error -Message $lang.errorDownloadBandInfo -Category ResourceUnavailable -ErrorId 2
    Exit 2
}

# Parse server id
if ($mainServer -eq "jp") { $iMainServer = 0 }
elseif ($mainServer -eq "en") { $iMainServer = 1 }
elseif ($mainServer -eq "tw") { $iMainServer = 2 }
elseif ($mainServer -eq "cn") { $iMainServer = 3 }
elseif ($mainServer -eq "kr") { $iMainServer = 4 }
else {
    Write-Error -Message $lang.errorSpecifiedServerNotFound -Category ObjectNotFound -ErrorId 3
    Exit 3
}

# Loop $getlistFile.songs
$countLoop = 0
foreach ($songIdList in $getlistFile.songs) {
    $countLoop++

    # Clean all data
    Write-Host ""
    $getSongInfo = $null
    $parsedSongInfo = $null

    # Download song information from https://bestdori.com/api/songs/$songIdList.json
    Write-Host $lang.infoSongIDGetInfo1 "ID.$songIdList" $lang.infoSongIDGetInfo2 "(" $countLoop "/" $getlistFile.songs.Count ")..." -ForegroundColor White -NoNewline
    $getSongInfo = Invoke-RestMethod "https://bestdori.com/api/songs/$songIdList.json"
    if ($getSongInfo) { Write-Host "  -" $lang.successSongIDGetInfo -ForegroundColor Green }
    else {
        Write-Host ""
        Write-Error -Message $lang.errorSongIDGetInfo -Category ResourceUnavailable -ErrorId 4
    }

    # Set band name as bandId
    $setBandNameArray = $getBandInfo.($getSongInfo.bandId)

    # Init $parsedSongInfo then add/transcode song info
    $parsedSongInfo = @{
        bgmId      = $getSongInfo.bgmId
        musicTitle = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($getSongInfo.musicTitle[$iMainServer]))
        bandName   = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($setBandNameArray.bandName[$iMainServer]))
        lyricist   = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($getSongInfo.lyricist[$iMainServer]))
        composer   = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($getSongInfo.composer[$iMainServer]))
        arranger   = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($getSongInfo.arranger[$iMainServer]))
        rMusicTitle = Format-Renameable([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($getSongInfo.musicTitle[$iMainServer])))
        rBandName   = Format-Renameable([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($setBandNameArray.bandName[$iMainServer])))
    }

    # Get front cover image
    if ($getSongInfo.jacketImage[$defaultJacket]) { $parsedSongInfo.jacketImage = $getSongInfo.jacketImage[$defaultJacket].replace('Introduction', 'introduction') }
    else { $parsedSongInfo.jacketImage = $getSongInfo.jacketImage[0].replace('Introduction', 'introduction') }

    # Calculate front cover image's package id
    if (([int]$songIdList / 10) -isnot [int]) { $parsedSongInfo.JacketPkgID = [int]$songIdList + (10 - [int]$songIdList % 10) }
    else { $parsedSongInfo.JacketPkgID = [int]$songIdList }

    # if not empty, echo & exec next. if empty, say error and pause
    if ($parsedSongInfo) {
        Write-Host "--------------------------------------------------" -ForegroundColor Cyan
        if ($moreInfo) { Write-Output $parsedSongInfo }
        else {
            Write-Host $lang.infoBandTitle $parsedSongInfo.bandName "-" $parsedSongInfo.musicTitle
            Write-Host $lang.infoLyCoAr $parsedSongInfo.lyricist ";" $parsedSongInfo.composer ";" $parsedSongInfo.arranger
        }
        Write-Host "--------------------------------------------------" -ForegroundColor Cyan
        if ((downloadSong -iptSongInfo $parsedSongInfo) -eq 0) {
            if ((downloadJacket -iptSongInfo $parsedSongInfo) -eq 0) {
                if ($checkTagLib -eq $true) { writeSongInfo -iptSongInfo $parsedSongInfo -jacketExist }
                else {
                    Write-Error -Message $lang.errorTagLibNotFound -Category ResourceUnavailable -ErrorId 15
                    if (! $Ignore) { Pause }
                }
            } else {
                if ($checkTagLib -eq $true) { writeSongInfo -iptSongInfo $parsedSongInfo }
                else {
                    Write-Error -Message $lang.errorTagLibNotFound -Category ResourceUnavailable -ErrorId 15
                    if (! $Ignore) { Pause }
                }
            }
        }
    } else {
        Write-Error -Message $lang.errorParsedSongInfo -Category ResourceUnavailable -ErrorId 5
        if (! $Ignore) { Pause }
    }
}

if ($Clean) {
    Write-Host ""
    Write-Host $lang.infoClean -ForegroundColor Yellow
    Remove-Item Jacket -Recurse
    Remove-Item Origin -Recurse
}