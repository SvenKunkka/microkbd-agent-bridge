# OpenMicro / microkbd → Codex Micro Agent Bridge

中文 | [English](#english)

This fork keeps Microbridge's MIT-licensed code and adds compatibility aliases
for the wire identifiers emitted by OpenMicro firmware `0.8.0+`:

- `ACT07` → Approve
- `ACT08` → Reject
- `ENC_CC` / `ENC_CW` → dial left / right
- `ENC` → dial press

The change is intentionally small and covered by unit tests in
`crates/mb-device/src/lib.rs`.

## 中文安装说明

### 适用范围

本说明面向开源 `conol-ai/openmicrokbd` 硬件及兼容板。已验证组合：

- OpenMicro 固件 `0.8.0`
- OpenMicro 桌面应用 `0.12.0`
- Microbridge `0.3.10` + 本仓库兼容补丁
- macOS Apple Silicon
- Codex CLI、Claude Code、ChatGPT/Codex Desktop 状态灯

Intel Mac 和 Linux 保留上游支持，但本补丁尚未完成对应硬件验证。

### 需要给使用者的软件

1. OpenMicro 官方固件/配置工具：
   <https://github.com/conol-ai/openmicrokbd/releases>
2. 本仓库的 Microbridge 源码。
3. macOS 构建依赖：Xcode Command Line Tools、Rust stable、Node.js 20+。

不要发送你自己的 `~/.codex`、`~/.claude`、`~/.microbridge` 或应用配置；
这些文件可能包含个人路径、会话标识或其他本机信息。

### 1. 安装固件

使用 OpenMicro 官方应用把设备升级到 `0.8.0` 或更高版本。升级前导出
设备配置。OpenMicro 板没有独立 BOOT0 恢复键，刷写期间不要断电；如果
DFU 被中断，可能需要 SWD 恢复。

不要为了“确认”而重复刷写相同版本；先在 OpenMicro 应用里读取当前版本。

### 2. 切换为 Codex Micro 兼容身份

任选一种方式：

- 在 OpenMicro 应用设置中选择 Codex Micro compatibility mode；或
- 拔下设备，按住第二排第二颗键（KEY 04 / slot 3）再插入 USB。

成功后系统应看到：

```text
Manufacturer: Work Louder
Product: Codex Micro
VID: 0x303A
PID: 0x8360
```

如需恢复 OpenMicro 原生身份，拔下设备，按住第二排第一颗键
（KEY 03 / slot 2）再插入。

### 3. 从本仓库安装 Microbridge

```sh
git clone https://github.com/SvenKunkka/microkbd-agent-bridge.git
cd microkbd-agent-bridge
./scripts/install.sh
```

首次打开后，在菜单栏 Microbridge 中选择 **Claim Codex Micro**。如果显示
设备被占用，关闭其他独占 HID 的工具后重试；macOS 要求时，在“隐私与安全性
→ 输入监控”中允许 Microbridge。

### 4. Agent 集成

Codex CLI：

```sh
codex app-server daemon start
```

Microbridge 状态应显示 Codex 的 `approval_acceptance`、
`approval_rejection` 和 `interrupt` 为 `true`。

Claude Code：Microbridge 首次运行时会把自己的 PermissionRequest/PreToolUse
hooks 合并到 `~/.claude/settings.json`，保留其他设置。Claude 下一次产生权限
请求时即可使用 Approve/Reject。

Cursor：打开 Microbridge → Settings → Integrations → Enable Cursor，然后
重新加载 Cursor。Cursor IDE 的公开接口目前主要支持生命周期状态；完整审批
和中断能力取决于 Cursor ACP/CLI。

### 5. 实体控制与灯光

| 控件 | 行为 |
|---|---|
| 顶部六颗 Agent 键 | 选择活动 Agent 会话；双击尝试打开支持聚焦的宿主 |
| Approve (`ACT07`) | 批准当前 Codex/Claude 权限请求 |
| Reject (`ACT08`) | 拒绝当前 Codex/Claude 权限请求 |
| 旋钮 (`ENC_*`) | 传递旋转/按下动作；最终行为由当前宿主能力决定 |
| 摇杆 | 在会话之间切换焦点 |
| Mic (`ACT10/ACT11`) | 只发送设备事件；本仓库尚未把它映射成全系统语音输入 |

默认灯光：

| 状态 | 颜色 |
|---|---|
| Working / Thinking | 蓝色 `#3D7EFF` |
| Awaiting approval | 琥珀色 `#FFB000` |
| Done | 绿色 `#30C463` |
| Error | 红色 `#FF453A` |
| Idle | 灰白色 `#E9E9E6` |
| 未分配 | 熄灭 |

### 6. 验证

```sh
microbridgectl status
cargo test -p mb-device
```

状态输出至少应包含：

```text
"device_connected": true
"device_name": "codex-micro-usb"
```

需要采集原始按键事件时，先从 Microbridge 释放设备，然后运行：

```sh
microbridgectl hid-capture 30
```

### 已知边界

- Mic 键不是麦克风，设备不采集音频；它只是 `ACT10/ACT11` 控制事件。
- 全系统语音输入需要额外的 macOS 听写或本地语音转写桥接。
- ChatGPT、Cursor 等宿主只会执行自己公开并声明支持的动作。
- Codex Micro 协议未正式公开，桌面应用升级可能改变行为。
- 本项目与 OpenAI、Work Louder、OpenMicro 作者无隶属或背书关系。

## English

### Required software

1. OpenMicro firmware/app `0.8.0+` from
   <https://github.com/conol-ai/openmicrokbd/releases>.
2. This Microbridge fork.
3. On macOS: Xcode Command Line Tools, stable Rust, and Node.js 20+.

Flash with the official OpenMicro app, then select Codex Micro compatibility
mode. The boot chord is KEY 04 (second key on the second row) while plugging in.
The device should enumerate as `303A:8360`, `Work Louder`, `Codex Micro`.

Install this fork:

```sh
git clone https://github.com/SvenKunkka/microkbd-agent-bridge.git
cd microkbd-agent-bridge
./scripts/install.sh
```

Open the menu bar app and choose **Claim Codex Micro**. Start Codex's local
control socket with `codex app-server daemon start`. Claude Code hooks are
installed by Microbridge when its Claude integration is enabled. Cursor's local
plugin is opt-in under Settings → Integrations.

Run `microbridgectl status` and confirm `device_connected: true`. The Mic key
is not an audio device: it emits `ACT10/ACT11`, and system-wide dictation is not
implemented by this fork yet.

## License and attribution

Microbridge and OpenMicro are MIT licensed. This repository preserves
Microbridge's original license and acknowledgments. OpenMicro firmware and
release binaries remain distributed by their upstream project; this guide links
to them instead of repackaging them.
