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