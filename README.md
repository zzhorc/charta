<h1 align="center">📜 Charta Theme</h1>

<p align="center">
  <em>A terminal aesthetic bridging hardcore productivity and vintage humanities.</em>
</p>

<p align="center">
  <img alt="Starship" src="https://img.shields.io/badge/Prompt-Starship-6C7086?style=flat-square">
  <img alt="Kaku" src="https://img.shields.io/badge/Primary-Kaku-E08999?style=flat-square">
  <img alt="Ghostty" src="https://img.shields.io/badge/Terminal-Ghostty-89B4FA?style=flat-square">
  <img alt="Warp" src="https://img.shields.io/badge/Terminal-Warp-1E66F5?style=flat-square">
  <img alt="Alacritty" src="https://img.shields.io/badge/Terminal-Alacritty-179299?style=flat-square">
  <img alt="iTerm2" src="https://img.shields.io/badge/Terminal-iTerm2-3C3836?style=flat-square">
</p>

<p align="center">
  <strong>Charta</strong> (Latin for Papyrus) 是一套专为现代终端打造的昼夜视觉方案，起源于为 Kaku 做的视觉优化。
  白天呈现温润的复古莎草纸光泽，夜晚坠入深邃的暗影；一抹标志性的西柚粉贯穿始终。
</p>

| Paper | Ink | Night | Rose |
| --- | --- | --- | --- |
| `#D5D0B5` | `#3C3836` | `#1E1E2E` | `#E08999` |

## ✨ Features

| Component | Status | Install path |
| --- | --- | --- |
| Starship prompt | 一键安装 | `~/.config/starship.toml` |
| Kaku | 一键安装 | `~/.config/kaku/kaku.lua` |
| Ghostty | 一键安装 | `~/.config/ghostty/themes/` |
| Warp | 一键安装 | `~/.warp/themes/` |
| Alacritty | 一键安装 | `~/.config/alacritty/themes/` |
| iTerm2 | 下载后导入 | `~/.config/charta/iterm2/` |

## 📦 Installation

你可以通过一键脚本直接安装提示符和终端色卡，不需要下载整个项目。

### 1. 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/zzhorc/charta/main/install.sh | bash
```

脚本会列出可安装组件，按编号选择即可。支持多选，例如输入 `1,3,4` 安装 Starship、Ghostty 和 Warp。

```text
1. Starship prompt
2. Kaku
3. Ghostty
4. Warp
5. Alacritty
6. iTerm2
7. All
```

也可以在无交互环境里指定组件：

```bash
CHARTA_COMPONENTS=starship,ghostty bash <(curl -fsSL https://raw.githubusercontent.com/zzhorc/charta/main/install.sh)
```

安装位置：

* Starship: `~/.config/starship.toml`
* Kaku: `~/.config/kaku/kaku.lua`
* Ghostty: `~/.config/ghostty/themes/`
* Warp: `~/.warp/themes/`
* Alacritty: `~/.config/alacritty/themes/`
* iTerm2: `~/.config/charta/iterm2/`

已有文件会先备份为 `.bak.<timestamp>-<pid>`。
*(注意：请确保你已经安装了 [Starship](https://starship.rs/))*

### 2. 终端色卡应用

安装后根据你使用的终端应用启用对应色卡：

* **Kaku**: 配置已写入 `~/.config/kaku/kaku.lua`
* **Ghostty**: 在配置中选择 `Charta-Light` 或 `Charta-Dark`
* **Warp**: 在主题设置中选择 `charta_light` 或 `charta_dark`
* **Alacritty**: 在你的 `alacritty.toml` 中 `import` 对应的色卡配置
* **iTerm2**: 
  1. 打开 iTerm2 设置 (Settings -> Profiles -> Colors)
  2. 点击右下角的 `Color Presets...` -> `Import...`
  3. 选择 `~/.config/charta/iterm2/` 目录下的 `.itermcolors` 文件即可
