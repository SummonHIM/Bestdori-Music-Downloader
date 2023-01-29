<div align="center">

# Bestdori Music Downloader
一个能从 Bestdori 上自动下载歌曲并填入歌曲信息（歌曲标题、歌手、专辑、作曲人员和封面）的 PowerShell 脚本。

</div>

### 下载
[![GitHub Release](https://img.shields.io/github/actions/workflow/status/SummonHIM/Bestdori-Music-Downloader/Release.yml?label=GitHub%20Release&style=for-the-badge)](https://github.com/SummonHIM/Bestdori-Music-Downloader/releases/latest)

### 参数介绍
```PowerShell
.\bmd.ps1 [-listFile] <String> [[-mainServer] <String>] [[-customAlbumName] <String>] [[-defaultJacket] <Int32>] [-forceRedownload] [-Clean] [-Ignore] [-moreInfo] [<CommonParameters>]

-listFile <String>			指定歌曲ID文件。若值为“all”则下载全部歌曲。（必须）
					Specify the song ID file. If value is "all", download all songs. (Mandatory)
-mainServer <string>			指定下载服务器。（默认：jp）
					Specify the download server. (Default: jp)
-customAlbumName <string>		指定专辑名称。（默认：バンドリ！ ガールズバンドパーティ！）
					Specify the album name. (Default: バンドリ！ ガールズバンドパーティ！)
-defaultJacket <Int32>			指定默认歌曲图片ID。若不存在则为0。
					Specify default song image ID. Will auto reset to zero if not exist.
-forceRedownload			启用强制重新下载。即使文件存在也将重新下载。
					Enable forced redownload. Will redownload even if the file exists.
-Clean					脚本完成后清理下载数据。
					Clean up downloaded data when script finished
-Ignore					当有错误时不暂停运行脚本。
					Ignore error's pause
-moreInfo				脚本执行时显示更多信息。
					Show more information when script execution.

# 或在 PowerShell 中键入 `Get-Help .\bmd.ps1 -full` 来显示更详细的帮助。
# Or use "Get-Help .\bmd.ps1 -full" in PowerShell to show full help.
```
#### 简易使用教程
中文：[单击查看简易使用教程](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/%E7%AE%80%E6%98%93%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B) | [单击查看歌曲ID文件模板](https://github.com/SummonHIM/Bestdori-Music-Downloader/blob/master/listFile.sample.json)

English: [Click here to check the Easy use tutorial](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/Easy-use-tutorial) | [Click here to check the song ID template](https://github.com/SummonHIM/Bestdori-Music-Downloader/blob/master/listFile.sample.json)

### 疑难解答
[中文](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/%E7%96%91%E9%9A%BE%E8%A7%A3%E7%AD%94) | [English](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/Troubleshooting)