**项目概览**:
- **名称**: AARPG — 一个以瓦片/像素风格实现的动作角色扮演样例工程。
- **引擎**: Godot 4.5（项目配置中标注的最低特性为 4.5）。请使用 Godot 4.5+ 打开和运行此项目。

**快速上手**:
- **打开项目**: 在 Godot 编辑器中选择项目根目录（包含 `project.godot` 的目录）。
- **命令行打开**（示例，取决于你的 Godot 可执行名）:

```
# macOS 示例（若可执行名为 godot）
godot --path /Users/bryant/Documents/code.me/godot_projects/aarpg
```

- **主要入口**: 项目主场景由 `project.godot` 的 `run/main_scene` 指定。项目使用若干 Autoload（单例）来管理音频、关卡、玩家等，位于 `00_Globals/`。

**项目结构（重点目录）**:
- `00_Globals/` : 全局单例管理器（例如 `global_level_manager.gd`, `global_player_manager.gd` 等）。
- `Player/` : 玩家场景、脚本、能力与资源。
- `NPC/` : 敌人与 NPC 的场景与行为脚本（例如 `NPC/Scripts/npc_behavior_wander.gd`）。
- `Levels/` : 地图、传送与关卡脚本（包括 `Levels/Scripts/level_transition.gd`）。
- `GUI/` : 界面与场景切换、暂停菜单等。
- `Items/`, `Props/`, `TileMaps/` 等：资源与场景组织按功能划分。

**运行与调试提示**:
- Godot 版本务必使用 4.5 或更高，否则资源、API 兼容性可能出现问题。
- 若某些 Area2D 触发导致“跳过”下一个场景的行为，相关保护位于：
  - `Levels/Scripts/level_transition.gd`：对进入体验证、在触发时临时关闭 `monitoring`、断开信号，并检查 `LevelManager.is_loading`。
  - `00_Globals/global_level_manager.gd`：新增 `is_loading` 重入保护，防止并发/重复加载。
- 若要追踪加载流程，请关注信号：`LevelManager.level_load_started` 与 `LevelManager.level_loaded`，可以在这些点打日志或断点。

**开发与贡献**:
- 代码风格：遵循 Godot/GDScript 习惯（函数和变量使用下划线分隔，方法返回类型声明在脚本中）。
- 提交前建议跑编辑器并手动验证：主要流程包括玩家移动到 `LevelTransition` 触发区、观察 `LevelManager` 的加载过程和玩家放置位置。
- 若要修复或新增功能，优先修改相关 `00_Globals` 单例或对应场景脚本，并在同目录添加注释以便维护。

**已知注意事项**:
- 传送/切换场景时可能产生链式触发（玩家被放置到新的 trigger 区并立刻触发）：项目中已添加三层保护（断开信号、`monitoring=false`、`LevelManager.is_loading`）。如果仍有问题，可开启更多日志以定位触发顺序。

**联系与帮助**:
- 如果需要我继续：我可以添加加载日志、写单元式的运行检查脚本示例，或者把关键流程的时序图写入 `docs/` 目录。

**许可证**:
- 本仓库当前未包含 LICENSE 文件。若要公开发布，请补充合适的许可证（例如 MIT）。

---
生成于本工作区；需要我把 README 翻译为英文、补充运行截图或在 `docs/` 下生成更详细开发文档吗？

**附加开发说明**

- **开发环境**:
  - 推荐使用 Godot 4.5 或更高版本。
  - 可选：在本地安装 Godot CLI（macOS 例如直接使用 `godot` 可执行文件），便于从终端打开或运行项目。

- **启动与调试（快速命令）**:
  - 在项目根目录打开编辑器：
```
godot --path /path/to/aarpg
```
  - 在运行时查看输出面板获取 `print()` 日志；若需要更详细的持久日志，可临时在代码中添加 `print()` 或写入文件。

- **建议的日志点（用于调试关卡切换）**:
  - `Levels/Scripts/level_transition.gd::player_entered`：打印触发的传送点名、进入者与 `LevelManager.is_loading` 状态。
  - `00_Globals/global_level_manager.gd::load_new_level`：在开始/结束处打印 `START` / `END` 与目标路径、目标传送点名。
  - `Levels/Scripts/level_transition.gd::place_player`：打印放置玩家的位置以确认偏移是否正确。

- **常用开发流程**:
  1. 新功能或修复请在本地新建分支：`git checkout -b feat/描述`。
  2. 实现并在 Godot 中手动验证关键流程（例如传送、玩家放置、AI 行为）。
  3. 提交并推送：`git add . && git commit -m "说明" && git push origin feat/描述`。
  4. 创建 Pull Request，注明测试步骤与复现方法。

- **贡献规则（建议）**:
  - 保持小而明确的提交，每个 PR 专注一个改动点。
  - 在修改关键单例（`00_Globals`）时，附上对现有流程如何影响的简短说明（例如 load 流程是否会改变）。
  - 为非显而易见的行为添加注释与/或文档（`docs/`）。

- **测试与 QA 建议**:
  - 手动测试：重点检查 `LevelTransition`（传送点）相关场景的连锁触发、玩家放置偏移与 NPC 行为。
  - 若要自动化测试，可考虑编写 Godot 的场景驱动脚本（EditorPlugins 或自定义测试 Runner），此处不包含现成测试套件。

**License 建议**

如果你决定对外发布，推荐添加 `LICENSE` 文件，例如 MIT：

```
MIT License

Copyright (c) <year> <owner>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[...standard MIT text omitted for brevity...]
```

如果你希望，我可以：
- 把 README 翻译为英文并追加为 `README_en.md`；
- 在 `README.md` 中加入项目截图（你可以提供截图或我可以在本地生成并保存）；
- 或者为 `LevelTransition` / `LevelManager` 自动在关键点加入临时 `print()` 日志并说明如何清理。