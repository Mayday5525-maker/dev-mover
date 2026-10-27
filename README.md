# Dev Mover

便携版 Windows 工具 / Portable Windows tool

把 **OpenAI Codex、TRAE CN、WorkBuddy、VS Code、Claude Code** 的数据与工作区从爆满的 C 盘迁移到另一个盘（如 G 盘）。原路径保留为**目录联接（junction）**，所有工具无需任何配置即可继续工作。全程带备份、逐项校验与自动回滚。

Move OpenAI Codex / TRAE CN / WorkBuddy / VS Code / Claude Code data and workspace folders off a full C: drive to another drive. Original paths stay valid as directory junctions, so every tool keeps working without configuration changes. Every step is backed up, verified, and rolled back on failure.

> 本工具参照 [codex-mover](https://github.com/ZhaowTao/codex-mover) 的设计实现：保留其 OpenAI Codex 迁移能力，并额外支持 TRAE CN / WorkBuddy / VS Code / Claude Code。

## 迁移内容 / What gets moved

默认迁移以下目录（GUI 里可以取消勾选，不存在的路径自动跳过）:

| 应用 | C: 路径 | 说明 |
| --- | --- | --- |
| OpenAI Codex | `%USERPROFILE%\.codex` | Codex CLI：会话记录、配置、登录凭证 |
| OpenAI Codex | `%USERPROFILE%\.cache\codex-runtimes` | Codex 运行时缓存（体积可能很大） |
| OpenAI Codex | `%LOCALAPPDATA%\OpenAI\Codex` | Codex 桌面应用数据 |
| OpenAI Codex | `%APPDATA%\Codex` | Codex 应用漫游数据 |
| OpenAI Codex | `Documents\Codex`（我的文档内） | Codex 文档与工作区 |
| TRAE CN | `%APPDATA%\Trae CN` | 用户数据：设置、缓存、AI 对话记录（ModularData）、日志 |
| TRAE CN | `%USERPROFILE%\.trae` | 扩展（extensions）、CLI 数据 |
| WorkBuddy | `%USERPROFILE%\Tencent WorkBuddy` | 默认工作区：任务文件、历史工作空间 |
| WorkBuddy | `%APPDATA%\CodeBuddyExtension` | 登录凭证、授权与插件数据 |
| VS Code | `%APPDATA%\Code` | 用户数据：设置、workspaceStorage、缓存、日志 |
| VS Code | `%USERPROFILE%\.vscode` | 扩展（extensions）与 CLI 缓存 |
| Claude Code | `%USERPROFILE%\.claude` | 项目、会话记录、skills、plugins、todos、缓存 |
| Claude Code | `%USERPROFILE%\.local\share\claude` | 原生安装器的版本文件（versions） |

不迁移的内容：

- 各应用**安装目录**（如 `%LOCALAPPDATA%\Programs\Microsoft VS Code`、`...\Programs\Tencent WorkBuddy`）。如需一并迁移，可在 GUI 里用「添加自定义目录」加入。
- Claude Code 的配置**文件** `%USERPROFILE%\.claude.json`（junction 只适用于目录；该文件通常只有几 KB，留在 C 盘即可）。

## 使用 / Usage

### 图形向导（推荐）/ GUI wizard

1. 双击 `DevMover-GUI.cmd` 启动向导。
2. 勾选要迁移的目录、选择目标盘（默认目标文件夹 `DevData`）。
3. 正式迁移前需完全退出 OpenAI Codex、TRAE CN、WorkBuddy、VS Code 和 Claude Code（含托盘图标）；只想预览的话勾选「演练模式」即可，无需关闭应用。
4. 点击「开始迁移」，日志实时滚动；右上角状态徽章变绿「完成」后即可重新打开各应用。

### 命令行 / Console

```powershell
# 先演练一遍（不修改任何东西）
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev-mover.ps1 -TargetRoot G:\DevData -DryRun

# 正式迁移
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev-mover.ps1 -TargetRoot G:\DevData
```

或直接双击 `DevMover.cmd` 使用交互式向导。

### 自定义迁移目录 / Custom sources

写一个 JSON 文件（源路径 -> 目标文件夹名），用 `-SourcesFile` 传入：

```json
{
  "C:\\Users\\me\\.claude": ".claude",
  "D:\\MyProjects": "MyProjects"
}
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev-mover.ps1 -TargetRoot G:\DevData -SourcesFile .\my-sources.json
```

## 安全机制 / Safety

- 先复制到目标盘并校验（文件数、字节数、robocopy 反向对比），确认一致才动原目录。
- 原目录先改名、后建联接；备份再次校验后才释放 C 盘副本。
- 任何失败自动回滚；中断后可自动从备份修复缺失文件。
- 迁移前检查目标盘剩余空间（源数据的 2.2 倍）并拒绝在空间不足时运行。
- 运行日志保存在目标盘 `migration-<时间戳>.log`，GUI 内同步滚动显示。

## 验证 / Verify

```powershell
Get-Item "$env:APPDATA\Trae CN" | Format-List LinkType,Target
Get-Item "$env:USERPROFILE\.claude"    | Format-List LinkType,Target
```

应显示 `LinkType : Junction`，`Target` 指向目标盘。

## 回滚 / Restore

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\dev-mover.ps1 -TargetRoot G:\DevData -Restore
```

会移除联接，并从目标盘最新的 `_backup-*` 备份把数据移回原路径。

## 注意事项 / Notes

- 仅 Windows（Windows 10/11，Windows PowerShell 5.1 与 .NET Framework 4.x 自带支持）。
- Claude Code 也可以用 `CLAUDE_CONFIG_DIR` 环境变量方案替代联接，但目录联接对所有工具是统一的通用方案，无需逐个配置。
- VS Code 官方另有 `--user-data-dir` / `--extensions-dir` 启动参数方案；junction 方案无需改快捷方式。
- WorkBuddy 升级时提示「应用安装目录下存在用户项目目录」属于安装目录问题，与本工具迁移的工作区无关。
- 迁移后先保留 `G:\DevData\_backup-*` 几天，确认稳定后再删除。
- 迁移中断后可能出现 `*.pre-migration-*` 残留目录，不影响使用；重启后可删除，或由后续运行自动清理。

## 已知不适用场景 / Known limitations

下面这些情况**不要**直接迁移，先看最后一列怎么绕。

| 场景 | 为什么不行 | 怎么办 |
| --- | --- | --- |
| 目标盘是 exFAT 或 FAT32（多数移动硬盘、U 盘的默认格式） | 目录联接只能在 NTFS 上创建，`mklink /J` 会直接报错 | 把目标盘格式化成 NTFS，或改用环境变量方案 |
| 目标盘是外接盘、U 盘或网络盘 | 盘一拔，C 盘那个联接点就指向空气，应用启动报找不到目录 | 换成内置硬盘的另一个分区 |
| 公司电脑被组策略禁用符号链接 | 创建联接点返回拒绝访问 | 让 IT 放开策略，否则改用环境变量方案 |
| 相关应用还在运行（包括托盘图标没退） | 文件被占用，复制会漏文件，后面的校验必然失败 | 完全退出；或在 GUI 勾选「自动关闭」 |
| 目标盘剩余空间不足源数据的两倍 | 迁移过程中源数据和备份会同时存在，中途耗尽会触发回滚 | 先腾空间，留出源数据两倍的余量 |
| 目标路径下已经有同名目录 | 工具会拒绝覆盖，避免误删你已有的数据 | 换一个空目录，或先把旧目录移走 |

## 遇到问题 / Something broke

迁移动的是目录联接和真实文件，**出问题先看日志再操作，不要自己硬删残留目录**，容易把回滚要用的备份一起删掉。

| 要提供什么 | 怎么拿到 |
| --- | --- |
| Windows 版本 | `winver`，或 设置 → 系统 → 关于 |
| PowerShell 版本 | `$PSVersionTable.PSVersion` |
| 卡在哪一步 | GUI 右上角状态徽章，加目标盘 `migration-*.log` 最后 20 行 |
| 报错截图 | 有红字的那一屏 |
| 目标盘文件系统 | `Get-Volume -DriveLetter G \| Format-List FileSystem` |

日志里会带你的用户名和本地路径，贴之前把 `C:\Users\你的名字` 这类替换掉。

## 许可 / License

MIT
