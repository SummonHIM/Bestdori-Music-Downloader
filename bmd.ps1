<#
    .SYNOPSIS
    A script that automatically downloads music from Bestdori and fills in the music information.
    一个能从 Bestdori 上自动下载音乐并填入音乐信息的脚本。

    .DESCRIPTION
    A script that automatically downloads music from Bestdori and fills in the music information.(Song title, Artist, Album, Composer and Front cover)
    一个能从 Bestdori 上自动下载音乐并填入音乐信息（歌曲标题、歌手、专辑、作曲人员和封面）的脚本。

    .PARAMETER listFile
    Specify the song ID file.
    指定歌曲ID文件。

    .PARAMETER mainServer
    Specify the download server.
    指定下载服务器。

    .PARAMETER customAlbumName
    Specify the album name.
    指定专辑名称。

    .PARAMETER forceReDownload
    Enable forced redownload. Will redownload even if the file exists.
    启用强制重新下载。即使文件存在也将重新下载。

    .PARAMETER clean
    Clean up downloaded data when script finished.
    脚本完成后清理下载数据。

    .PARAMETER ignore
    Ignore error's pause.
    当有错误时不暂停运行脚本。

    .PARAMETER moreInfo
    Show more information when script execution.
    脚本执行时显示更多信息。

    .PARAMETER defaultJacket
    Specify default song image ID. Will auto reset to zero if not exist.
    指定默认歌曲图片ID。若不存在则为0。

    .INPUTS
    Input -listFile Specify the song ID file.
    输入 -listFile 指定的歌曲ID文件。
    
    .OUTPUTS
    Origin Folder - Save origin music file to Origin folder.
    Origin 文件夹 - 保存源音乐文件至 Origin 文件夹。
    Jacket Folder - Save origin front cover file to Origin folder.
    Jacket 文件夹 - 保存源封面文件至 Origin 文件夹。
    Output Folder - Convert and save music to Output folder.
    Output Folder - 转换并保存音乐至 Output 文件夹。

    .EXAMPLE
    .\bmd.ps1 -listFile listFile.sample.json
    Simplest/最简

    .EXAMPLE
    .\bmd.ps1 -listFile listFile.sample.json -mainServer cn -customAlbumName "BanG Dream!" -forceReDownload -clean
    Fullest/最全

    .LINK
    https://github.com/SummonHIM/Bestdori-Music-Downloader
#>

param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$listFile,
    [Parameter(ValueFromPipeline = $true)][string]$mainServer = "jp",
    [string]$customAlbumName = "バンドリ！　ガールズバンドパーティ！",
    [switch]$forceReDownload = $false,
    [switch]$clean = $false,
    [switch]$ignore = $false,
    [switch]$moreInfo = $false,
    [int]$defaultJacket = 0
)

[System.IO.Directory]::SetCurrentDirectory("$(Get-Location)")

if ($host.Version -le 5.1) {
    Write-Output ""
    Write-Output "Your PowerShell version is too low. Please upgrade your PowerShell."
    Write-Output "You can download the Windows Management Framework 5.1 to upgrade your PowerShell version:"
    Write-Output "https://docs.microsoft.com/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-5.1"
    Write-Output ""
    Write-Output "Press Ctrl+C or wait 60 second to exit..."
    Start-Sleep 60
    exit
}

$getSysLang = Get-WinSystemLocale
if ($getSysLang.LCID -eq 2052 -or $getSysLang.LCID -eq 4096 -or $getSysLang.LCID -eq 4 -or $getSysLang.LCID -eq 4100) {
    $langFolder = "文件夹"
    $langNotFoundMkdir = "未找到，正在创建"
    $langDownloading = "正在下载"
    $langTo = "至"
    $langIsAlreadyDownloaded = "已下载"
    $langJacketTypeError = "图片类型不正确！"
    $langJacketTryRedown = "正在尝试重新下载…"
    $langJacketSkip = "跳过添加图片。"
    $langJacketWriting = "正在使用 TagLibSharp.dll 写入歌曲信息…"
    $langCopying = "正在复制"
    $langTagLibSharpLoading = "正在加载库 TagLibSharp.dll！"
    $langTagLibSharpNotFound = "未找到库 TagLibSharp.dll！无法写入歌曲信息…"
    $langBandInfo = "乐队信息…"
    $langSongInfo = "歌曲信息…"
    $langEnableClean = "已启用清理，正在删除 Jacket 和 Origin 文件夹…"
    $langServerNotFound = "指定的服务器未找到。"
}
elseif ($getSysLang.LCID -eq 3076 -or $getSysLang.LCID -eq 5124) {
    # Processed by 繁化姬 https://zhconvert.org 
    $langFolder = "文件夾"
    $langNotFoundMkdir = "未找到，正在創建"
    $langDownloading = "正在下載"
    $langTo = "至"
    $langIsAlreadyDownloaded = "已下載"
    $langJacketTypeError = "圖片類型不正確！"
    $langJacketTryRedown = "正在嘗試重新下載…"
    $langJacketSkip = "跳過添加圖片。"
    $langJacketWriting = "正在使用 TagLibSharp.dll 寫入歌曲訊息…"
    $langCopying = "正在複製"
    $langTagLibSharpLoading = "正在加載庫 TagLibSharp.dll！"
    $langTagLibSharpNotFound = "未找到庫 TagLibSharp.dll！無法寫入歌曲訊息…"
    $langBandInfo = "樂隊訊息…"
    $langSongInfo = "歌曲訊息…"
    $langEnableClean = "已啟用清理，正在刪除 Jacket 和 Origin 文件夾…"
    $langServerNotFound = "指定的伺服器未找到。"
}
elseif ($getSysLang.LCID -eq 31748 -or $getSysLang.LCID -eq 1028) {
    # Processed by 繁化姬 https://zhconvert.org 
    $langFolder = "資料夾"
    $langNotFoundMkdir = "未找到，正在建立"
    $langDownloading = "正在下載"
    $langTo = "至"
    $langIsAlreadyDownloaded = "已下載"
    $langJacketTypeError = "圖片類型不正確！"
    $langJacketTryRedown = "正在嘗試重新下載…"
    $langJacketSkip = "跳過添加圖片。"
    $langJacketWriting = "正在使用 TagLibSharp.dll 寫入歌曲訊息…"
    $langCopying = "正在複製"
    $langTagLibSharpLoading = "正在載入庫 TagLibSharp.dll！"
    $langTagLibSharpNotFound = "未找到庫 TagLibSharp.dll！無法寫入歌曲訊息…"
    $langBandInfo = "樂隊訊息…"
    $langSongInfo = "歌曲訊息…"
    $langEnableClean = "已啟用清理，正在刪除 Jacket 和 Origin 資料夾…"
    $langServerNotFound = "指定的伺服器未找到。"
}
else {
    $langFolder = "Folder"
    $langNotFoundMkdir = "not found, Creating..."
    $langDownloading = "Downloading"
    $langTo = "to"
    $langIsAlreadyDownloaded = "is already downloaded."
    $langJacketTypeError = "Image type not correct!"
    $langJacketTryRedown = "Try redownload..."
    $langJacketSkip = "skip image adding."
    $langJacketWriting = "Writing music information by using TagLibSharp.dll..."
    $langCopying = "Copying"
    $langTagLibSharpNotFound = "Library TagLibSharp.dll Not found! Can't fill in song information."
    $langBandInfo = " band information..."
    $langSongInfo = " song information..."
    $langEnableClean = "Clean is enable, removing Jacket and Origin..."
    $langServerNotFound = "The server you specified was not found."
}

function downloadSongs {
    # If folder "Origin" not exist, mkdir.
    $isOriginExist = Test-Path Origin
    if (! $isOriginExist) {
        Write-Host "$langFolder Origin $langNotFoundMkdir" -ForegroundColor Yellow
        if ($moreInfo) { mkdir Origin } else { mkdir Origin > $null }
    }
    
    # Generate music download url.
    $musicDownloadUrl = "https://bestdori.com/assets/" + $mainServer + "/sound/" + $songInfo_bgmId + "_rip/" + $songInfo_bgmId + ".mp3"
    # If music already downloaded, skip. else go download.
    $isMusicDownloaded = Test-Path "Origin\$songInfo_bgmId.mp3"
    if ((! $isMusicDownloaded) -or ($forceReDownload)) {
        Write-Host "$langDownloading $musicDownloadUrl $langTo Origin\$songInfo_bgmId.mp3..." -ForegroundColor Green
        Invoke-WebRequest "$musicDownloadUrl" -OutFile "Origin\$songInfo_bgmId.mp3"
    }
    else {
        Write-Host "$songInfo_bgmId.mp3(Origin\$songInfo_bgmId.mp3) $langIsAlreadyDownloaded" -ForegroundColor Yellow
    }
}

function downloadImgs {
    # If folder "Jacket" not exist, mkdir.
    $isJacketExist = Test-Path Jacket
    if (! $isJacketExist) {
        Write-Host "$langFolder Jacket $langNotFoundMkdir" -ForegroundColor Yellow
        if ($moreInfo) { mkdir Jacket } else { mkdir Jacket > $null }
    }

    # Generate music jacket download url.
    $musicJacketUrl = "https://bestdori.com/assets/" + $mainServer + "/musicjacket/musicjacket" + $songJacketPkgID + "_rip/assets-star-forassetbundle-startapp-musicjacket-musicjacket" + $songJacketPkgID + "-" + $songInfo_jacketImage + "-jacket.png"
    # If music jacket already downloaded, skip. else go download.
    $isJacketDownloaded = Test-Path "Jacket\$songInfo_jacketImage.png"
    if ((! $isJacketDownloaded) -or ($forceReDownload)) {
        Write-Host "$langDownloading $musicJacketUrl $langTo Jacket\$songInfo_jacketImage.png..." -ForegroundColor Green
        Invoke-WebRequest "$musicJacketUrl" -OutFile "Jacket\$songInfo_jacketImage.png"
    }
    else {
        # If music jacket is bestdori 404(html), try redownload.
        $CheckJacket = Get-Content "Jacket\$songInfo_jacketImage.png" | Select-String DOCTYPE
        if ($CheckJacket) {
            Write-Error "$langJacketTypeError $langJacketTryRedown"
            if (! $ignore) { Pause }
            Write-Host "$langDownloading $musicJacketUrl $langTo Jacket\$songInfo_jacketImage.png..." -ForegroundColor Green
            Invoke-WebRequest "$musicJacketUrl" -OutFile "Jacket\$songInfo_jacketImage.png"
        }
        else {
            Write-Host "$songInfo_jacketImage.png(Jacket\$songInfo_jacketImage.png) $langIsAlreadyDownloaded" -ForegroundColor Yellow
        }
    }
}

function writeSongInfo {
    # If folder "Output" not exist, mkdir.
    $isOutputExist = Test-Path Output
    if (! $isOutputExist) {
        Write-Host "$langFolder Output $langNotFoundMkdir" -ForegroundColor Yellow
        if ($moreInfo) { mkdir Output } else { mkdir Output > $null }
    }

    # Copy music to Output folder
    Write-Host "$langCopying Origin\$songInfo_bgmId.mp3 $langTo Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3..." -ForegroundColor Green
    Copy-Item "Origin\$songInfo_bgmId.mp3" -Destination "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    # If music jacket is bestdori 404(html), skip add-image.
    $CheckPNG = Get-Content "Jacket\$songInfo_jacketImage.png" | Select-String DOCTYPE
    if ($CheckPNG) {
        Write-Error "$langJacketTypeError $langJacketSkip"
        if (! $ignore) { Pause }
        Write-Host "$langJacketWriting" -ForegroundColor Green
        $writeSongInfo = [TagLib.File]::Create("Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3")
        $writeSongInfo.Tag.Title = "$songInfo_musicTitle"
        $writeSongInfo.Tag.Artists = "$bandName"
        $writeSongInfo.Tag.Album = "$customAlbumName"
        $writeSongInfo.Tag.Composers = "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger"
        $writeSongInfo.Save()
    }
    elseif ($checkTagLib) {
        Write-Host "$langJacketWriting" -ForegroundColor Green
        $writeSongInfo = [TagLib.File]::Create("Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3")
        $writeSongInfo.Tag.Title = "$songInfo_musicTitle"
        $writeSongInfo.Tag.Artists = "$bandName"
        $writeSongInfo.Tag.Album = "$customAlbumName"
        $writeSongInfo.Tag.Composers = "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger"
        $writeSongInfo.Tag.Pictures = [TagLib.Picture]("Jacket\$songInfo_jacketImage.png")
        $writeSongInfo.Save()
    }
    else {
        Write-Error "$langTagLibSharpNotFound"
        if (! $ignore) { Pause }
    }
}

# Load TagLibSharp.dll
$isTagLibSharpExist = Test-Path "TagLibSharp.dll"
if ($isTagLibSharpExist) {
    Write-Host "$langTagLibSharpLoading" -ForegroundColor Green
    [Reflection.Assembly]::LoadFrom("TagLibSharp.dll")
    $checkTagLib = $true
    Write-Host ""
}

# Get song list in $listFile
$getSongList = Get-Content $listFile | ConvertFrom-Json
Write-Host "$langDownloading$langBandInfo" -ForegroundColor Green
$bandInfo = Invoke-RestMethod "https://bestdori.com/api/bands/all.1.json"
if ($mainServer -eq "jp") { $songInfoLanguage = 0 }
elseif ($mainServer -eq "en") { $songInfoLanguage = 1 }
elseif ($mainServer -eq "tw") { $songInfoLanguage = 2 }
elseif ($mainServer -eq "cn") { $songInfoLanguage = 3 }
elseif ($mainServer -eq "kr") { $songInfoLanguage = 4 }
else {
    Write-Error $langServerNotFound
    exit 1
}
foreach ($songList in $getSongList.songs) {
    Write-Host ""
    # Download song information from https://bestdori.com/api/songs/$songList.json
    Write-Host "$langDownloading$langSongInfo" -ForegroundColor Green
    $songInfo = Invoke-RestMethod "https://bestdori.com/api/songs/$songList.json"
    # Get bgmID
    $songInfo_bgmId = $songInfo.bgmId
    # Get bandName
    $bandNameNG = $bandInfo.($songInfo.bandId)
    $bandName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($bandNameNG.bandName[$songInfoLanguage]))
    $bandName_RenameAble = $bandName.replace('\', '-').replace('/', '-').replace(':', '：').replace('*', '＊').replace('?', '？').replace('"', '`').replace('<', '《').replace('>', '》').replace('|', '-')
    # Get musicTitle
    $songInfo_musicTitle = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.musicTitle[$songInfoLanguage]))
    $songInfo_musicTitle_RenameAble = $songInfo_musicTitle.replace('\', '-').replace('/', '-').replace(':', '：').replace('*', '＊').replace('?', '？').replace('"', '`').replace('<', '《').replace('>', '》').replace('|', '-')
    # Get composer
    $songInfo_lyricist = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.lyricist[$songInfoLanguage]))
    $songInfo_composer = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.composer[$songInfoLanguage]))
    $songInfo_arranger = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.arranger[$songInfoLanguage]))
    # Get front cover image
    if ($songInfo.jacketImage[$defaultJacket]) {
        $songInfo_jacketImage = $songInfo.jacketImage[$defaultJacket].replace('Introduction', 'introduction')
    }
    else {
        $songInfo_jacketImage = $songInfo.jacketImage[0].replace('Introduction', 'introduction')
    }
    
    # Calculate front cover image's package id
    $songListTestInt = $songList / 10
    if ($songListTestInt -isnot [int]) {
        $songJacketPkgID = $songList + (10 - $songList % 10)
    }
    else {
        $songJacketPkgID = $songList
    }
    # Collect all information and print
    $echoAllInfo = '{"bgmId": "' + $songInfo.bgmId + '", "bandId": "' + $songInfo.bandId + '", "bandName": "' + $bandName + '", "bandName_RenameAble": "' + $bandName_RenameAble + '", "musicTitle": "' + $songInfo_musicTitle + '", "songInfo_musicTitle_RenameAble": "' + $songInfo_musicTitle_RenameAble + '", "lyricist": "' + $songInfo_lyricist + '", "composer": "' + $songInfo_composer + '", "arranger": "' + $songInfo_arranger + '", "jacketImage": "' + $songInfo.jacketImage + '", "songJacketPkgID": "' + $songJacketPkgID + '"}' | ConvertFrom-Json
    if ($moreInfo) { Write-Output $echoAllInfo }
    
    downloadSongs
    downloadImgs
    writeSongInfo
}

if ($clean) {
    Write-Host ""
    Write-Host "$langEnableClean" -ForegroundColor Yellow
    Remove-Item Jacket -Recurse
    Remove-Item Origin -Recurse
}