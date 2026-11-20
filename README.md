# nagisafetch

一个零依赖、可换主题的系统信息工具，纯 Python 标准库实现。

设计借鉴 [fastfetch](https://github.com/fastfetch-cli/fastfetch) 的预设机制：`-c PRESET` 加载布局，检测不到的字段自动跳过，不写死任何发行版或桌面环境。内置 31 个字段、7 套主题、6 个 ASCII logo，支持 kitty 图片 logo 和分组配色。

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

## 特性

- **零依赖**：只用 Python 3 标准库，不装任何 pip 包
- **预设机制**（照 fastfetch）：`-c default|minimal|all|sora`，`-c all` 列出全部字段
- **主题系统**：单色（arch/nord/dracula/gruvbox/kanagawa/rose）+ 分组四色（sora）
- **自动检测**：不写死发行版/WM，从 `/etc/os-release`、`/proc`、`gsettings`、rice 配置里读
- **Termux/Android 适配**：自动识别 Termux，走 UDP 法拿 IP、Binder 拿电池、避开被封的 `/proc`
- **kitty 图片 logo**：`--logo-image` 用 kitty graphics 协议直传 PNG（SSH 下也能用）
- **终端宽度自适应**：窄屏自动把 logo 挪到顶部，避免挤压文字

## 安装

需要 Python 3.8+。一键脚本会自动识别系统（Linux → `~/.local/bin`，Termux → `$PREFIX/bin`），下载并验证：

```bash
curl -fsSL https://raw.githubusercontent.com/ibukifuuko-arch/nagisafetch/master/install.sh | bash
```

不想跑脚本的话，手动下载也一样：

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/ibukifuuko-arch/nagisafetch/master/nagisafetch \
  -o ~/.local/bin/nagisafetch
chmod +x ~/.local/bin/nagisafetch
```

确保 `~/.local/bin` 在 `PATH` 里，然后 `nagisafetch` 就能用了。


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

完整参数见 `nagisafetch --help`。

### 图片 logo（kitty）

```bash
nagisafetch --logo-image ~/wallpaper.png --logo-image-width 22
```

只支持 PNG（kitty 数据直传），JPEG 需先转换。需 kitty 或兼容 kitty graphics 协议的终端。

### 默认参数文件

在 `~/.config/nagisafetch/default-args` 写命令行参数（shell 风格），每次启动自动前置：

```
-c sora --theme rose --logo-image ~/.config/nagisafetch/logo.png --logo-image-width 22
```

显式传入的参数会覆盖文件里的同名参数。兼容旧路径 `~/.config/sysfetch/default-args`。

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

`--list-fields` 查看全部。常用：OS、Host、Kernel、Uptime、Load Average、Processes、CPU、CPU Usage、GPU、Temperature、Memory、Swap、Disk、Battery、Packages、Shell、Terminal、WM、DE、Resolution、Locale、Fonts、Local/Public IP、VPN、Wi-Fi、Date & Time。

## 平台

- **Linux**：完整支持（推荐 Arch/Fedora/Debian 等主流发行版）
- **Android (Termux)**：适配支持，部分字段（温度/进程/`/proc/stat`）受 Android 权限限制自动跳过
- **Windows 原生**：不支持（依赖 `/proc`、`/sys`、`/etc/os-release`）；WSL 下可用但读到的是 WSL 虚拟机的信息

## License

MIT
