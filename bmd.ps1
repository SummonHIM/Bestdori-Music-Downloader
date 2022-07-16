<#
    .SYNOPSIS
    A script that automatically downloads music from Bestdori and fills in the music information.
    һ���ܴ� Bestdori ���Զ��������ֲ�����������Ϣ�Ľű���

    .DESCRIPTION
    A script that automatically downloads music from Bestdori and fills in the music information.(Song title, Artist, Album, Composer and Front cover)
    һ���ܴ� Bestdori ���Զ��������ֲ�����������Ϣ���������⡢���֡�ר����������Ա�ͷ��棩�Ľű���

    .PARAMETER listFile
    Specify the song ID file.
    ָ������ID�ļ���

    .PARAMETER mainServer
    Specify the download server.
    ָ�����ط�������

    .PARAMETER customAlbumName
    Specify the album name.
    ָ��ר�����ơ�

    .PARAMETER forceReDownload
    Enable forced redownload. Will redownload even if the file exists.
    ����ǿ���������ء���ʹ�ļ�����Ҳ���������ء�

    .PARAMETER clean
    Clean up downloaded data when script finished
    �ű���ɺ������������ݡ�

    .PARAMETER ignore
    Ignore error's pause
    ���д���ʱ����ͣ���нű���

    .INPUTS
    Input -listFile Specify the song ID file.
    ���� -listFile ָ���ĸ���ID�ļ�
    
    .OUTPUTS
    Origin Folder - Save origin music file to Origin folder.
    Origin �ļ��� - ����Դ�����ļ��� Origin �ļ��С�
    Jacket Folder - Save origin front cover file to Origin folder.
    Jacket �ļ��� - ����Դ�����ļ��� Origin �ļ��С�
    Output Folder - Convert and save music to Output folder.
    Output Folder - ת�������������� Output �ļ��С�

    .EXAMPLE
    .\bmd.ps1 -listFile listFile.sample.json
    Simplest/���

    .EXAMPLE
    .\bmd.ps1 -listFile listFile.sample.json -mainServer cn -customAlbumName "BanG Dream!" -forceReDownload -clean
    Fullest/��ȫ

    .LINK
    https://github.com/SummonHIM/Bestdori-Music-Downloader
#>

param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$listFile,
    [Parameter(ValueFromPipeline = $true)][string]$mainServer = "jp",
    [string]$customAlbumName = "�Х�ɥ꣡ ���`�륺�Х�ɥѩ`�ƥ���",
    [switch]$forceReDownload = $false,
    [switch]$clean = $false,
    [switch]$ignore = $false
)

function downloadSongs {
    # If folder "Origin" not exist, mkdir.
    $isOriginExist = Test-Path Origin
    if (! $isOriginExist) {
        Write-Host "Folder Origin not found, Creating..." -ForegroundColor Yellow
        mkdir Origin > $null
    }
    
    # Generate music download url.
    $musicDownloadUrl = "https://bestdori.com/assets/" + $mainServer + "/sound/" + $songInfo_bgmId + "_rip/" + $songInfo_bgmId + ".mp3"
    # If music already downloaded, skip. else go download.
    $isMusicDownloaded = Test-Path "Origin\$songInfo_bgmId.mp3"
    if ((! $isMusicDownloaded) -or ($forceReDownload)) {
        Write-Host "Downloading $musicDownloadUrl to Origin\$songInfo_bgmId.mp3..." -ForegroundColor Green
        Invoke-WebRequest "$musicDownloadUrl" -OutFile "Origin\$songInfo_bgmId.mp3"
    }
    else {
        Write-Host "$songInfo_bgmId.mp3(Origin\$songInfo_bgmId.mp3) is already downloaded." -ForegroundColor Yellow
    }
}

function downloadImgs {
    # If folder "Jacket" not exist, mkdir.
    $isJacketExist = Test-Path Jacket
    if (! $isJacketExist) {
        Write-Host "Folder Jacket not found, Creating..." -ForegroundColor Yellow
        mkdir Jacket > $null
    }

    # Generate music jacket download url.
    $musicJacketUrl = "https://bestdori.com/assets/" + $mainServer + "/musicjacket/musicjacket" + $songJacketPkgID + "_rip/assets-star-forassetbundle-startapp-musicjacket-musicjacket" + $songJacketPkgID + "-" + $songInfo_jacketImage + "-jacket.png"
    # If music jacket already downloaded, skip. else go download.
    $isJacketDownloaded = Test-Path "Jacket\$songInfo_jacketImage.png"
    if ((! $isJacketDownloaded) -or ($forceReDownload)) {
        Write-Host "Downloading $musicJacketUrl to Jacket\$songInfo_jacketImage.png..." -ForegroundColor Green
        Invoke-WebRequest "$musicJacketUrl" -OutFile "Jacket\$songInfo_jacketImage.png"
    }
    else {
        # If music jacket is bestdori 404(html), try redownload.
        $CheckJacket = Get-Content "Jacket\$songInfo_jacketImage.png" | Select-String DOCTYPE
        if ($CheckJacket) {
            Write-Host "Image type not correct! Try redownload..." -ForegroundColor Red
            if (! $ignore) { Pause }
            Write-Host "Downloading $musicJacketUrl to Jacket\$songInfo_jacketImage.png..." -ForegroundColor Green
            Invoke-WebRequest "$musicJacketUrl" -OutFile "Jacket\$songInfo_jacketImage.png"    
        }
        else {
            Write-Host "$songInfo_jacketImage.png(Jacket\$songInfo_jacketImage.png) is already downloaded." -ForegroundColor Yellow
        }
    }
}

function writeSongInfo {
    Write-Host ""
    # If folder "Output" not exist, mkdir.
    $isOutputExist = Test-Path Output
    if (! $isOutputExist) {
        Write-Host "Folder Output not found, Creating..." -ForegroundColor Yellow
        mkdir Output > $null
    }

    # Copy music to Output folder
    Write-Host "Copying Origin\$songInfo_bgmId.mp3 to Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3..." -ForegroundColor Green
    Copy-Item "Origin\$songInfo_bgmId.mp3" -Destination "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    # If music jacket is bestdori 404(html), skip add-image.
    $CheckPNG = Get-Content "Jacket\$songInfo_jacketImage.png" | Select-String DOCTYPE
    $CheckEyeD3 = eyed3 --version
    if ($CheckPNG) {
        Write-Host "Image type not correct! skip image adding." -ForegroundColor Red
        if (! $ignore) { Pause }
        Write-Host "Writing music information by using eyeD3..." -ForegroundColor Green
        eyeD3 --title "$songInfo_musicTitle" --artist "$bandName" --album "$customAlbumName" --composer "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger" --v2 --to-v2.3 "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    }
    elseif ($CheckEyeD3) {
        Write-Host "Writing music information by using eyeD3..." -ForegroundColor Green
        eyeD3 --title "$songInfo_musicTitle" --artist "$bandName" --album "$customAlbumName" --composer "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger" --add-image "Jacket\$songInfo_jacketImage.png:FRONT_COVER" --v2 --to-v2.3 "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    }
    else {
        Write-Host "eyeD3 Not found! Can't fill in song information." -ForegroundColor Red
        if (! $ignore) { Pause }
    }
}

# Get song list in $listFile
$getSongList = Get-Content $listFile | ConvertFrom-Json
$bandInfo = Invoke-RestMethod "https://bestdori.com/api/bands/all.1.json"
foreach ($songList in $getSongList.songs) {
    Write-Host ""
    # Download song information from https://bestdori.com/api/songs/$songList.json
    Write-Host "Downloading song information..." -ForegroundColor Green
    $songInfo = Invoke-RestMethod "https://bestdori.com/api/songs/$songList.json"
    # Get bgmID
    $songInfo_bgmId = $songInfo.bgmId
    # Get bandName
    $bandNameNG = $bandInfo.($songInfo.bandId)
    $bandName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($bandNameNG.bandName[0]))
    $bandName_RenameAble = $bandName.replace('\', '-').replace('/', '-').replace(':', '��').replace('*', '��').replace('?', '��').replace('"', '`').replace('<', '��').replace('>', '��').replace('|', '-')
    # Get musicTitle
    $songInfo_musicTitle = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.musicTitle[0]))
    $songInfo_musicTitle_RenameAble = $songInfo_musicTitle.replace('\', '-').replace('/', '-').replace(':', '��').replace('*', '��').replace('?', '��').replace('"', '`').replace('<', '��').replace('>', '��').replace('|', '-')
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