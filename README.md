# Bestdori Music Downloader
[English](#English)/[中文](#中文)

## English
A script that automatically downloads music from Bestdori and fills in the music information.(Song title, Artist, Album, Composer and Front cover)

### Download
[![Release](https://github.com/SummonHIM/Bestdori-Music-Downloader/actions/workflows/Release.yml/badge.svg)](https://github.com/SummonHIM/Bestdori-Music-Downloader/actions/workflows/Release.yml)

Provide `UTF-8`, `GBK`, `Shift-JIS` and `EUC-KR` version.

### Parameter
```PowerShell
bmd.ps1 [-listFile] <Object> [[-mainServer] <Object>] [[-customAlbumName] <string>] [-forceReDownload] [-clean] [<CommonParameters>]

-listFile <Object>			Specify the song ID file.(Mandatory)
-mainServer <string>			Specify the download server.(Default: jp)
-customAlbumName <string>		Specify the album name.(Default: バンドリ！ ガールズバンドパーティ！)
-forceReDownload			Enable forced redownload. Will redownload even if the file exists.
-clean					Clean up downloaded data when script finished
-ignore					Ignore error's pause
-moreinfo				Show more information when script execution.
-defaultJacket				Specify default song image ID. Will auto reset to zero if not exist.

# Or use "Get-Help .\bmd.ps1 -full" in PowerShell to show full help.
```
### Easy use tutorial
[Click here to check the Easy use tutorial](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/Easy-use-tutorial) | [Click here to check the song ID template](https://github.com/SummonHIM/Bestdori-Music-Downloader/blob/master/listFile.sample.json)

### Q&A
#### PowerShell say: "Cannot be loaded because running scripts is disabled on this system."
You need to exec this command on PowerShell to unlock PowerShell scripts usage restrictions. Learn more on [https://go.microsoft.com/fwlink/?LinkID=135170](https://go.microsoft.com/fwlink/?LinkID=135170).
```PowerShell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## 中文
一个能从 Bestdori 上自动下载歌曲并填入歌曲信息（歌曲标题、歌手、专辑、作曲人员和封面）的 PowerShell 脚本。

### 下载
[![Release](https://github.com/SummonHIM/Bestdori-Music-Downloader/actions/workflows/Release.yml/badge.svg)](https://github.com/SummonHIM/Bestdori-Music-Downloader/actions/workflows/Release.yml)

提供`UTF-8`、`GBK`、`Shift-JIS`和`EUC-KR`编码。请根据你的操作系统按需下载。

### 参数介绍
```PowerShell
bmd.ps1 [-listFile] <Object> [[-mainServer] <String>] [[-customAlbumName] <String>] [-forceReDownload] [-clean] [-ignore] [<CommonParameters>]

-listFile <Object>			指定歌曲ID文件。（必须）
-mainServer <string>			指定下载服务器。（默认：jp）
-customAlbumName <string>		指定专辑名称。（默认：バンドリ！ ガールズバンドパーティ！）
-forceReDownload			启用强制重新下载。即使文件存在也将重新下载。
-clean					脚本完成后清理下载数据。
-ignore					当有错误时不暂停运行脚本。
-moreinfo				脚本执行时显示更多信息。
-defaultJacket				指定默认歌曲图片ID。若不存在则为0。

# 或在 PowerShell 中键入 `Get-Help .\bmd.ps1 -full` 来显示更详细的帮助。
```
#### 简易使用教程
[单击查看简易使用教程](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/%E7%AE%80%E6%98%93%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B) | [单击查看歌曲ID文件模板](https://github.com/SummonHIM/Bestdori-Music-Downloader/blob/master/listFile.sample.json)

### 疑难解答
#### 无法在我的电脑运行 PowerShell 脚本。系统提示因为在此系统上禁止运行脚本。
PowerShell 默认不允许使用脚本，可使用 PowerShell 执行以下命令解除锁定。详细信息可前去 [https://go.microsoft.com/fwlink/?LinkID=135170](https://go.microsoft.com/fwlink/?LinkID=135170) 了解。
```PowerShell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

#### 无法在Win7、Win8运行这个脚本。脚本提示我的 PowerShell 版本过低
Win7 和 Win8 用户可以前去 [https://docs.microsoft.com/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-5.1](https://docs.microsoft.com/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-5.1) 下载并更新你的 PowerShell 版本（虽然能运行，但是脚本无法更改语言）。XP 用户请考虑升级 Win10