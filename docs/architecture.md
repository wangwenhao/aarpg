项目架构概要

1. 总体
- 该项目基于 Godot（4.5+）构建，采用场景（.tscn）+ 脚本（.gd）组合的形式组织游戏逻辑与资源。
- 核心运行入口由 `project.godot` 指定（`run/main_scene`）。

2. Autoload（单例）
- `00_Globals/` 目录包含多个单例（通过 `project.godot` 的 `autoload` 注册）：
  - `LevelManager` (`global_level_manager.gd`)：负责关卡加载、暂停控制、与 `LevelTransition` 的协作。
  - `PlayerManager` (`global_player_manager.gd`)：管理玩家实例、位置设置与相关 API。
  - `AudioManager`：全局音频控制。
  - `SaveManager`、`SceneTransition`、`PauseMenu` 等：分别处理存档、全局淡入/淡出效果与暂停菜单。

3. 关卡/传送逻辑（简述）
- `LevelTransition`（`Levels/Scripts/level_transition.gd`）为场景中的 Area2D，用于检测玩家进入并请求 `LevelManager` 切换关卡。
- `LevelManager.load_new_level(...)` 负责：
  - 暂停场景树（`get_tree().paused = true`），播放淡出，切换场景，播放淡入，恢复暂停并发出 `level_loaded` 信号。
  - 为避免重入，已加入 `is_loading` 标志防止并发加载。

4. NPC/行为系统
- `NPC/` 目录包含敌人、NPC 场景与行为脚本（如 `npc_behavior_wander.gd`）。运动与碰撞相关的更新应放在 `_physics_process`，视觉/插值可在 `_process` 中做额外渲染平滑。

5. 调试与扩展点
- 关卡切换相关的关键信号：`LevelManager.level_load_started` 与 `LevelManager.level_loaded`，可用于显示 loading UI 或在加载期间调整连接逻辑。
- 若要更严格的加载序列控制，可在 `LevelManager` 中加入更详细的状态机或队列机制（current, queued level 等）。