# nagisafetch

查系统信息的小工具。纯 Python 标准库写的，一个依赖都不用装。

布局这套是从 [fastfetch](https://github.com/fastfetch-cli/fastfetch) 那儿学来的，`-c PRESET` 选预设，检测不到的字段直接跳过，不写死某个发行版或桌面环境。31 个字段、7 套主题、6 个 ASCII logo，也能贴一张 PNG 当 logo（走 kitty 图片协议）。

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

- 零依赖，Python 3 标准库就够，pip 包一个不用装。
- 预设照着 fastfetch 做。`-c default|minimal|all|sora`，`-c all` 把所有字段都列出来。
- 7 套主题。arch、nord、dracula、gruvbox、kanagawa、rose 是单色，sora 是分组四色。
- 自动检测。发行版、WM 这些从 `/etc/os-release`、`/proc`、`gsettings` 和你自己的 rice 配置里读，读不到就跳过这一项。
- Termux 上也能跑。它会认出 Termux，IP 用 UDP 法拿，电池从 Binder 读，Android 封掉的 `/proc` 路径绕开。
- 图片 logo 用 `--logo-image` 传 PNG，走 kitty graphics 协议，SSH 里也能显示。
- 窗口窄的时候 logo 自动挪到顶上，不跟文字挤一块。

## 安装

Python 3.8 以上。跑一键脚本，它会认出系统是普通 Linux 还是 Termux，装到对应的目录（`~/.local/bin` 或 `$PREFIX/bin`），装完顺手验证一下：

```bash
curl -fsSL https://raw.githubusercontent.com/ibukifuuko-arch/nagisafetch/master/install.sh | bash
```

不想跑脚本，手动也行：

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/ibukifuuko-arch/nagisafetch/master/nagisafetch \
  -o ~/.local/bin/nagisafetch
chmod +x ~/.local/bin/nagisafetch
```

记得把 `~/.local/bin` 加进 `PATH`，然后直接敲 `nagisafetch`。

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

### 图片 logo（kitty）

```bash
nagisafetch --logo-image ~/wallpaper.png --logo-image-width 22
```

只收 PNG，kitty 数据直传；JPEG 得先转一下。终端要支持 kitty graphics 协议，kitty 自己就行。

### 默认参数文件

在 `~/.config/nagisafetch/default-args` 里写命令行参数，按 shell 的风格写，每次启动自动带上：

```
-c sora --theme rose --logo-image ~/.config/nagisafetch/logo.png --logo-image-width 22
```

命令行里显式传的参数会盖掉文件里的同名参数。老路径 `~/.config/sysfetch/default-args` 也认。

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
- Windows 原生：不支持，它依赖 `/proc`、`/sys`、`/etc/os-release`。WSL 里能用，不过读到的是 WSL 虚拟机自己的信息

## License

MIT
