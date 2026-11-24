# nagisafetch

查系统信息的小工具。纯 Python 标准库写的，一个依赖都不用装。Linux / Termux / Windows 三端共用同一份脚本，Windows 下自动切到原生适配层。

布局这套是从 [fastfetch](https://github.com/fastfetch-cli/fastfetch) 那儿学来的，`-c PRESET` 选预设，检测不到的字段直接跳过，不写死某个发行版或桌面环境。31 个字段、7 套主题、6 个 ASCII logo，也能贴一张 PNG 当 logo（kitty / ansi / sixel 三种图片协议）。

```
✦ hardware
  CPU:        Intel(R) Core(TM) i3 CPU M 380 @ 2.53GHz (2c/4t)
  CPU Usage:  16%
  GPU:        AMD/ATI Park [Mobility Radeon HD 5430]
  Memory:     2.6 GiB / 3.7 GiB (70%)
  Disk (/):   19.1 GiB / 31.2 GiB (61%)
  Temperature: acpitz: 58°C
✦ software
  OS:         Arch Linux (x86_64)
  Kernel:     6.18.63-3-lts
  Packages:   1152 (pacman)
  Shell:      fish
✦ desktop
  WM:         niri
  Terminal:   kitty
  Resolution: 1366x768
✦ time
  Uptime:     2h 34m
  Load Average: 0.12 0.28 0.59
  Processes:  244
```

## 它能干什么

- 预设照着 fastfetch 做。`-c default|minimal|all|sora`，`-c all` 把所有字段都列出来。
- 7 套主题。arch、nord、dracula、gruvbox、kanagawa、rose 是单色，sora 是分组四色。
- 自动检测发行版、WM 等，读不到就跳过这一项。
- Termux 上也能跑。
- 图片 logo 用 `--logo-image` 传 PNG，支持 kitty graphics、ansi 真彩半块、Sixel 三种协议；Windows Terminal 与 SSH 走 ansi，抗重绘不崩坏
- 窗口窄的时候 logo 自动挪到顶上，不跟文字挤一块。

## 安装

Python 3.8 以上。

### Linux / Termux

跑一键脚本，自动装好并验证。**国内网络推荐 CNB 源**（GitHub 有时连不上）：

```bash
curl -fsSL https://cnb.cool/ibukifuuko/nagisafetch/-/git/raw/master/install-cn.sh | bash
```

能访问 GitHub 的话，用原始源也一样：

```bash
curl -fsSL https://raw.githubusercontent.com/ibukifuuko-arch/nagisafetch/master/install.sh | bash
```

不想跑脚本，手动也行（把链接换成 GitHub 源同样可以）：

```bash
mkdir -p ~/.local/bin
curl -fsSL https://cnb.cool/ibukifuuko/nagisafetch/-/git/raw/master/nagisafetch \
  -o ~/.local/bin/nagisafetch
chmod +x ~/.local/bin/nagisafetch
```

记得把 `~/.local/bin` 加进 `PATH`，然后直接敲 `nagisafetch`。

### Windows 10/11

系统里有 Python 3.8+ 就行（winget 装的、或绿色版解压的都可以）。

**国内网络推荐 CNB 源**（GitHub 有时连不上），在 PowerShell 里贴一行：

```powershell
irm https://cnb.cool/ibukifuuko/nagisafetch/-/git/raw/master/install-cn.ps1 | iex
```

它会直接从 CNB 下载脚本再安装，不用你先手动拿文件。想看明文也可以存下来再跑：

```powershell
powershell -ExecutionPolicy Bypass -File .\install-cn.ps1
```

能访问 GitHub 的话，原始方式的 `install.ps1` 一样能用。只是要先把本仓库的 `nagisafetch` 和 `install.ps1` 放到同一个目录：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

脚本会自动找 Python、安装、加进 PATH 并验证。**重开 Windows Terminal** 后直接敲 `nagisafetch`。

不想动系统、或 winget 装不了的话，用 [Python 官方绿色版](https://mirrors.huaweicloud.com/python/3.12.10/) 解压也能装，把 `python.exe` 的完整路径交给脚本就行。

## 用法

```bash
nagisafetch                      # 默认预设
nagisafetch -c all               # 全部字段（检测不到的自动跳过）
nagisafetch -c minimal           # 精简
nagisafetch -c sora --theme sora # 四色分组布局
nagisafetch --theme rose         # 换主题色
nagisafetch --bars on            # 内存/磁盘/CPU 显示进度条
nagisafetch --field cpu mem gpu  # 只显示指定字段
nagisafetch --logo off           # 不要 logo
nagisafetch --list-fields        # 列出所有可用字段
```

完整参数看 `nagisafetch --help`。

### 图片 logo（kitty / ansi / sixel）

```bash
# kitty / WezTerm：自动识别，走 kitty graphics 协议
nagisafetch --logo-image ~/wallpaper.png --logo-image-width 22

# Windows Terminal（含 SSH 到 Windows）：默认走 ansi 真彩半块
nagisafetch --logo-protocol ansi --logo-image ~/wallpaper.png --logo-image-width 22
```

只收 PNG，JPEG 得先转一下。`--logo-protocol` 四个值：

| 值 | 行为 |
|---|---|
| `auto`（默认） | kitty 终端用 kitty，其余一律用 ansi 真彩半块 |
| `kitty` | 强制 kitty graphics，终端不支持就退回 ASCII |
| `ansi` | 真彩半块字符画图片，Windows Terminal / SSH 最稳，不会崩坏 |
| `sixel` | 强制 Sixel，画质高但兼容性差，慎选 |

kitty 用于 kitty/WezTerm；Windows Terminal 和 SSH 用 ansi——它是普通文本，滚动、重绘都不丢图；sixel 画质高但兼容性差。图片宽度用 `--logo-image-width` 调。

### 默认参数文件

在 `~/.config/nagisafetch/default-args` 里写命令行参数，按 shell 的风格写，每次启动自动带上：

```
-c sora --theme rose --logo-image ~/.config/nagisafetch/logo.png --logo-image-width 22
```

命令行里显式传的参数会盖掉文件里的同名参数。

## 主题与预设

| 预设 | 说明 |
|---|---|
| `default` | 常用字段，分组布局 |
| `minimal` | 只留核心几行 |
| `all` | 全部 31 个字段 |
| `sora` | 四组布局（硬件/软件/桌面/时间），配 `--theme sora` 出四色效果 |

| 主题 | 颜色 |
|---|---|
| `arch` | Arch 蓝 |
| `nord` | Nord 冰蓝 |
| `dracula` | Dracula 紫 |
| `gruvbox` | Gruvbox 橙 |
| `kanagawa` | Kanagawa 青 |
| `rose` | 玫瑰粉 |
| `sora` | 分组四色（需配 sora 预设） |

## 字段

`--list-fields` 列出全部。常用的这些：OS、Host、Kernel、Uptime、Load Average、Processes、CPU、CPU Usage、GPU、Temperature、Memory、Swap、Disk、Battery、Packages、Shell、Terminal、WM、DE、Resolution、Locale、Fonts、Local/Public IP、VPN、Wi-Fi、Date & Time。

## 平台

- Linux：完整支持，Arch、Fedora、Debian 这些主流发行版都没问题
- Android (Termux)：适配过，温度、进程、`/proc/stat` 这几项受 Android 权限限制，读不到就自动跳过
- Windows 10/11：原生支持，不用 WSL。

## Windows 注意事项

- 启动快，不冷启 PowerShell。
- 台式机没电池时 `Battery` 字段自动跳过，不会显示 `-1%`。
- 温度默认跳过，设 `NF_WIN_WMI_TEMP=1` 可开启。
- Windows Terminal 不支持 kitty 图片协议；图片 logo 用 `--logo-protocol ansi --logo-image xxx.png`，ansi 真彩半块是普通文本，滚动和窗口重绘都不丢图（SSH 到本机跑也一样，不要求本地有该文件）。`auto` 默认就走 ansi。Sixel 虽支持但多图层在 WT 上易崩坏，不推荐。
- 字体建议 Nerd Font（如 JetBrainsMono NFM）。
- 默认参数文件除了 `~\.config\nagisafetch\default-args`，也认 `%APPDATA%\nagisafetch\default-args`。

## 更新

1.0.4 改了几处。Wi-Fi 只显示真正连着的那个 SSID，不再把扫描到的热点当成当前网络。PNG 解码加了 CRC、尺寸和解压长度校验，坏图直接跳过，不会拖垮程序。图片 logo 现在也认 `--logo-position left|top|auto`，kitty 下行高估算也补上了。另外加了 PNG 回归测试，CI 在 3.8 / 3.11 / 3.14 上跑。

## License

MIT
