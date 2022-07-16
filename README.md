# Bestdori-Music-Downloader
[English](#English)/[中文](#中文)

## English
A script that automatically downloads music from Bestdori and fills in the music information.(Song title, Artist, Album, Composer and Front cover)

### Install eyeD3
eyeD3 is a Python tool for working with audio files, specifically MP3 files containing ID3 metadata (i.e. song info). This script uses eyeD3 to edit song information.(Official website: [https://eyed3.readthedocs.io/en/latest/index.html](https://eyed3.readthedocs.io/en/latest/index.html))
1. Download and install Python.（[https://www.python.org/downloads](https://www.python.org/downloads)）
2. Open the Terminal, Enter `pip install eyeD3` to install eyeD3.

### Usage
#### PowerShell version
Easy use tutorial: [https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/How-to-create-song-id-file-(Easy-use-tutorial)](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/How-to-create-song-id-file-(Easy-use-tutorial))

Full use sample:
```PowerShell
Start PowerShell
PS> cd Path\to\Script
PS> .\bmd.ps1 -listFile listFile.sample.json -mainServer en -customAlbumName "BanG Dream!" -forceReDownload -clean
```

Parameter:
```PowerShell
bmd.ps1 [-listFile] <Object> [[-mainServer] <Object>] [[-customAlbumName] <string>] [-forceReDownload] [-clean] [<CommonParameters>]

-listFile <Object>			Specify the song ID file.(Mandatory)
-mainServer <string>			Specify the download server.(Default: jp)
-customAlbumName <string>		Specify the album name.(Default: バンドリ！ ガールズバンドパーティ！)
-forceReDownload			Enable forced redownload. Will redownload even if the file exists.
-clean					Clean up downloaded data when script finished
-ignore					Ignore error's pause

# Or use "Get-Help .\bmd.ps1 -full" in PowerShell to show full help.
```

## 中文
一个能从 Bestdori 上自动下载歌曲并填入歌曲信息（歌曲标题、歌手、专辑、作曲人员和封面）的脚本。

### 安装前置软件（eyeD3）
eyeD3 是一个 Python 工具，用于处理包含ID3元数据（即歌曲信息）的 MP3 文件。本脚本使用 eyeD3 软件来编辑歌曲信息。（官网：[https://eyed3.readthedocs.io/en/latest/index.html](https://eyed3.readthedocs.io/en/latest/index.html)）
1. 下载并安装 Python（[https://www.python.org/downloads](https://www.python.org/downloads)）。安装时请注意安装捆绑 `pip`，Windows 用户记得勾选 `Add Python *.* to PATH`
2. 打开命令行终端，键入`pip install eyeD3`并回车。等待安装结束即可.

### 使用方法
#### PowerShell 版本
简易使用教程：[简易使用教程](https://github.com/SummonHIM/Bestdori-Music-Downloader/wiki/%E5%A6%82%E4%BD%95%E5%88%9B%E5%BB%BA%E6%AD%8C%E6%9B%B2ID%E6%96%87%E4%BB%B6%EF%BC%88%E7%AE%80%E6%98%93%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B%EF%BC%89)

最全使用范例
```PowerShell
打开 PowerShell
PS> cd 到\脚本的\路径
PS> .\bmd.ps1 -listFile listFile.sample.json -mainServer cn -customAlbumName "BanG Dream!" -forceReDownload -clean
```

参数介绍
```PowerShell
bmd.ps1 [-listFile] <Object> [[-mainServer] <String>] [[-customAlbumName] <String>] [-forceReDownload] [-clean] [-ignore] [<CommonParameters>]

-listFile <Object>			指定歌曲ID文件。（必须）
-mainServer <string>			指定下载服务器。（默认：jp）
-customAlbumName <string>		指定专辑名称。（默认：バンドリ！ ガールズバンドパーティ！）
-forceReDownload			启用强制重新下载。即使文件存在也将重新下载。
-clean					脚本完成后清理下载数据。
-ignore					当有错误时不暂停运行脚本。

# 或在 PowerShell 中键入 `Get-Help .\bmd.ps1 -full` 来显示更详细的帮助。
```

### 疑难解答
#### 无法在我的电脑运行 PowerShell 脚本。系统提示因为在此系统上禁止运行脚本。
PowerShell 默认不允许使用脚本，可使用管理员运行 PowerShell 并执行以下命令解除锁定。详细信息可前去 [https:/go.microsoft.com/fwlink/?LinkID=135170](https:/go.microsoft.com/fwlink/?LinkID=135170) 了解。
```PowerShell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

#### 无法在Win7、Win8运行这个脚本。
Win7 和 Win8 用户可以前去 [https://docs.microsoft.com/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-5.1](https://docs.microsoft.com/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-5.1) 下载并更新你的 PowerShell 版本（虽然能运行，但是脚本无法更改语言）。XP 用户请考虑升级 Win10