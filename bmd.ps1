$garupaName = "¥Ð¥ó¥É¥ê£¡ ¥¬©`¥ë¥º¥Ð¥ó¥É¥Ñ©`¥Æ¥££¡"

function downloadSongs {
    $isOriginExist = Test-Path Origin
    if (! $isOriginExist) {
        mkdir Origin > $null
    }
    $songInfo_bgmId_rip = $songInfo_bgmId + "_rip"
    $isMusicDownloaded = Test-Path "Origin\$songInfo_bgmId.mp3"
    if (! $isMusicDownloaded) {
        Write-Host "Downloading https://bestdori.com/assets/jp/sound/$songInfo_bgmId_rip/$songInfo_bgmId.mp3..." -ForegroundColor Green
        Invoke-WebRequest "https://bestdori.com/assets/jp/sound/$songInfo_bgmId_rip/$songInfo_bgmId.mp3" -OutFile "Origin\$songInfo_bgmId.mp3"
    }
    else {
        Write-Host "Found Origin\$songInfo_bgmId.mp3, no need to download." -ForegroundColor Yellow
    }
}

function downloadImgs {
    $isOriginImgExist = Test-Path OriginImg
    if (! $isOriginImgExist) {
        mkdir OriginImg > $null
    }
    $isJacketDownloaded = Test-Path "OriginImg\$songInfo_jacketImage.png"
    if (! $isJacketDownloaded) {
        $musicJacketUrl = "https://bestdori.com/assets/jp/musicjacket/musicjacket" + $songJacketPkgID + "_rip/assets-star-forassetbundle-startapp-musicjacket-musicjacket" + $songJacketPkgID + "-" + $songInfo_jacketImage + "-jacket.png"
        Write-Host "Downloading $musicJacketUrl..." -ForegroundColor Green
        Invoke-WebRequest "$musicJacketUrl" -OutFile "OriginImg\$songInfo_jacketImage.png"
    }
    else {
        $CheckPNG = Get-Content "OriginImg\$songInfo_jacketImage.png" | grep DOCTYPE
        if ($CheckPNG) {
            Write-Host "Image type not correct! Try redownload." -ForegroundColor Red
            $musicJacketUrl = "https://bestdori.com/assets/jp/musicjacket/musicjacket" + $songJacketPkgID + "_rip/assets-star-forassetbundle-startapp-musicjacket-musicjacket" + $songJacketPkgID + "-" + $songInfo_jacketImage + "-jacket.png"
            Write-Host "Downloading $musicJacketUrl..." -ForegroundColor Green
            Invoke-WebRequest "$musicJacketUrl" -OutFile "OriginImg\$songInfo_jacketImage.png"    
        }
        else {
            Write-Host "Found OriginImg\$songInfo_jacketImage.png, no need to download." -ForegroundColor Yellow
        }
    }
}

function writeSongInfo {
    $isOutputExist = Test-Path Output
    if (! $isOutputExist) {
        mkdir Output > $null
    }
    Copy-Item "Origin\$songInfo_bgmId.mp3" -Destination "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    $CheckPNG = Get-Content "OriginImg\$songInfo_jacketImage.png" | grep DOCTYPE
    if ($CheckPNG) {
        Write-Host "Image type not correct!" -ForegroundColor Red
        eyeD3 --title "$songInfo_musicTitle" --artist "$bandName" --album "$garupaName" --composer "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger" "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    }
    else {
        eyeD3 --title "$songInfo_musicTitle" --artist "$bandName" --album "$garupaName" --composer "$songInfo_lyricist;$songInfo_composer;$songInfo_arranger" --add-image "OriginImg\$songInfo_jacketImage.png:FRONT_COVER" "Output\$bandName_RenameAble - $songInfo_musicTitle_RenameAble.mp3"
    }
}

$getSongList = Get-Content fav.json | ConvertFrom-Json
$bandList = "0", "Poppin'Party", "Afterglow", "Hello, Happy World!", "Pastel*Palettes", "Roselia", "RAISE A SUILEN", "Morfonica"
foreach ($songList in $getSongList.songs) {
    Write-Host ""
    $songInfo = Invoke-RestMethod "https://bestdori.com/api/songs/$songList.json"
    $songInfo_bgmId = $songInfo.bgmId
    if ($songInfo.bandId -eq 18) {
        $listBandID = 6
    }
    elseif ($songInfo.bandId -eq 21) {
        $listBandID = 7
    }
    else {
        $listBandID = $songInfo.bandId
    }
    $bandName = $bandList[$listBandID]
    $bandName_RenameAble = $bandList[$listBandID].replace('\', '').replace('/', '').replace(':', '').replace('*', 'x').replace('?', '').replace('"', '').replace('<', '').replace('>', '').replace('|', '')
    $songInfo_musicTitle = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.musicTitle[0]))
    $songInfo_musicTitle_RenameAble = $songInfo_musicTitle.replace('\', '').replace('/', '').replace(':', '').replace('*', 'x').replace('?', '').replace('"', '').replace('<', '').replace('>', '').replace('|', '')
    $songInfo_lyricist = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.lyricist[0]))
    $songInfo_composer = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.composer[0]))
    $songInfo_arranger = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($songInfo.arranger[0]))
    $songInfo_jacketImage = $songInfo.jacketImage[0].replace('Introduction', 'introduction')
    $songListTestInt = $songList / 10
    if ($songListTestInt -isnot [int]) {
        Write-Host "$songList + (10 - $songList % 10)" -ForegroundColor Yellow
        $songJacketPkgID = $songList + (10 - $songList % 10)
    }
    else {
        $songJacketPkgID = $songList
    }
    $echoAllInfo = "bgmId: " + $songInfo.bgmId + ", bandId(listBandID): " + $songInfo.bandId + "(" + $listBandID + "), bandName: " + $bandName + ", bandName_RenameAble: " + $bandName_RenameAble + ", musicTitle: " + $songInfo_musicTitle + ", songInfo_musicTitle_RenameAble: " + $songInfo_musicTitle_RenameAble + ", lyricist: " + $songInfo_lyricist + ", composer: " + $songInfo_composer + ", arranger: " + $songInfo_arranger + ", jacketImage: " + $songInfo.jacketImage + ", songJacketPkgID: " + $songJacketPkgID
    Write-Host $echoAllInfo -ForegroundColor Green
    downloadSongs
    downloadImgs
    writeSongInfo
}