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
    Clean up downloaded data when script finished
    脚本完成后清理下载数据。

    .PARAMETER ignore
    Ignore error's pause
    当有错误时不暂停运行脚本。

    .INPUTS
    Input -listFile Specify the song ID file.
    输入 -listFile 指定的歌曲ID文件
    
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
    [switch]$ignore = $false
)

if ($host.Version -le 5.1) {
    Write-Output ""
    Write-Output "Your PowerShell version is too low. Please upgrade your PowerShell."
    Write-Output "你的 PowerShell 版本过低。请升级你的 PowerShell。"
    Write-Output "You can download the Windows Management Framework 5.1 to upgrade your PowerShell version:"
    Write-Output "你可在此处下载 Windows Management Framework 5.1 来升级你的 PowerShell 版本:"
    Write-Output "https://docs.microsoft.com/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-5.1"
    Write-Output ""
    Write-Output "Press Ctrl+C or wait 60 second to exit..."
    Write-Output "按 Ctrl+C 或等待 60 秒来退出..."
    Start-Sleep 60
    exit
}

$getSysLang = Get-WinSystemLocale
if ( $getSysLang.LCID -eq 2052 ) {
    $langFolder = "文件夹"
    $langNotFoundMkdir = "未找到，正在创建"
    $langDownloading = "正在下载"
    $langTo = "至"
    $langIsAlreadyDownloaded = "已下载"
    $langJacketTypeError = "图片类型不正确！"
    $langJacketTryRedown = "正在尝试重新下载..."
    $langJacketSkip = "跳过添加图片。"
    $langJacketWriting = "正在使用 eyeD3 写入歌曲信息..."
    $langCopying = "正在复制"
    $langEyeD3NotFound = "未找到 eyeD3！ 无法写入歌曲信息..."
    $langSongInfo = " 歌曲信息..."
} else {
    $langFolder = "Folder"
    $langNotFoundMkdir = "not found, Creating..."
    $langDownloading = "Downloading"
    $langTo = "to"
    $langIsAlreadyDownloaded = "is already downloaded."
    $langJacketTypeError = "Image type not correct!"
    $langJacketTryRedown = "Try redownload..."
    $langJacketSkip = "skip image adding."
    $langJacketWriting = "Writing music information by using eyeD3..."
    $langCopying = "Copying"
    $langEyeD3NotFound = "eyeD3 Not found! Can't fill in song information."
    $langSongInfo = " song information..."
}

function downloadSongs {
    # If folder "Origin" not exist, mkdir.
    $isOriginExist = Test-Path Origin
    if (! $isOriginExist) {
        Write-Host "$langFolder Origin $langNotFoundMkdir" -ForegroundColor Yellow
        mkdir Origin > $null
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
        mkdir Jacket > $null
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
            Write-Host "$langJacketTypeError $langJacketTryRedown" -ForegroundColor Red
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
    Write-Host ""
    # If folder "Output" not exist, mkdir.
    $isOutputExist = Test-Path Output
    if (! $isOutputExist) {
        Write-Host "$langFolder Output $langNotFoundMkdir" -ForegroundColor Yellow
        mkdir Output > $null
    }

    # Copy music to Output folder
    Write-Host "$langCopying Origin\$songInfo_bgmId.mp3 $langTo Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3..." -ForegroundColor Green
    Copy-Item "Origin\$songInfo_bgmId.mp3" -Destination "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    # If music jacket is bestdori 404(html), skip add-image.
    $CheckPNG = Get-Content "Jacket\$songInfo_jacketImage.png" | Select-String DOCTYPE
    $CheckEyeD3 = eyed3 --version
    if ($CheckPNG) {
        Write-Host "$langJacketTypeError $langJacketSkip" -ForegroundColor Red
        if (! $ignore) { Pause }
        Write-Host "$langJacketWriting" -ForegroundColor Green
        eyeD3 --title "$songInfo_musicTitle" --artist "$bandName" --album "$customAlbumName" --composer "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger" --v2 --to-v2.3 "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    }
    elseif ($CheckEyeD3) {
        Write-Host "$langJacketWriting" -ForegroundColor Green
        eyeD3 --title "$songInfo_musicTitle" --artist "$bandName" --album "$customAlbumName" --composer "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger" --add-image "Jacket\$songInfo_jacketImage.png:FRONT_COVER" --v2 --to-v2.3 "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    }
    else {
        Write-Host "$langEyeD3NotFound" -ForegroundColor Red
        if (! $ignore) { Pause }
    }
}

# Get song list in $listFile
$getSongList = Get-Content $listFile | ConvertFrom-Json
$bandInfo = Invoke-RestMethod "https://bestdori.com/api/bands/all.1.json"
foreach ($songList in $getSongList.songs) {
    Write-Host ""
    # Download song information from https://bestdori.com/api/songs/$songList.json
    Write-Host "$langDownloading$langSongInfo" -ForegroundColor Green
    $songInfo = Invoke-RestMethod "https://bestdori.com/api/songs/$songList.json"
    # Get bgmID
    $songInfo_bgmId = $songInfo.bgmId
    # Get bandName
    $bandNameNG = $bandInfo.($songInfo.bandId)
    $bandName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($bandNameNG.bandName[0]))
    $bandName_RenameAble = $bandName.replace('\', '-').replace('/', '-').replace(':', '：').replace('*', '＊').replace('?', '？').replace('"', '`').replace('<', '《').replace('>', '》').replace('|', '-')
    # Get musicTitle
    $songInfo_musicTitle = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.musicTitle[0]))
    $songInfo_musicTitle_RenameAble = $songInfo_musicTitle.replace('\', '-').replace('/', '-').replace(':', '：').replace('*', '＊').replace('?', '？').replace('"', '`').replace('<', '《').replace('>', '》').replace('|', '-')
    # Get composer
    $songInfo_lyricist = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.lyricist[0]))
    $songInfo_composer = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.composer[0]))
    $songInfo_arranger = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.arranger[0]))
    # Get front cover image
    $songInfo_jacketImage = $songInfo.jacketImage[0].replace('Introduction', 'introduction')
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
    Write-Output $echoAllInfo
    
    downloadSongs
    downloadImgs
    writeSongInfo
}

if ($clean) {
    Write-Host "Clean is enable, removing Jacket and Origin" -ForegroundColor Yellow
    Remove-Item Jacket -Recurse
    Remove-Item Origin -Recurse
}