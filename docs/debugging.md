调试指南：复现与定位“跳过场景”问题

目标：提供可靠的复现步骤与可添加的日志点，帮助定位为何有时会直接进入下下个场景。

复现场景准备
1. 在同一关卡中创建两个相邻的 `LevelTransition` 节点（A -> B -> C），A 指向 B，B 指向 C。
2. 将 B 的目标传送点放在位置上，使得当玩家被放置到 B 的传送点时，会与 B 的检测区域存在短暂重叠。

复现步骤
1. 从场景 A 中进入 A 的传送区，触发跳转到 B。
2. 观察玩家在 B 场景中被放置的位置；若玩家初始放置位置立刻与 B 或 C 的传送区重叠，可能触发连锁切换。

建议日志点（在代码中临时添加 `print()`）
- `Levels/Scripts/level_transition.gd::player_entered`：
  - 在函数开头打印 `print("player_entered: ", name, " by=", _player, " LevelManager.is_loading=", LevelManager.is_loading)`。
- `00_Globals/global_level_manager.gd::load_new_level`：
  - 在函数开始处打印 `print("load_new_level START:", level_path, " target=", _target_transition)`，并在结束前打印 `print("load_new_level END")`。
- `PlayerManager.set_player_position` 或 `place_player()`：
  - 打印玩家被放置的位置 `print("place_player: ", global_position + LevelManager.position_offset)`。

临时修复建议（可快速验证）
- 在 `place_player()` 中，在设置玩家位置后延迟几帧再启用目标场景的传送区：
  - 例如，在目标 `LevelTransition` 上使用 `yield(get_tree(), "process_frame")` 等待 1-2 帧，然后再 `monitoring = true` 或 `body_entered.connect(...)`。
- 或者把 `LevelManager` 在 `level_loaded` 发出后延迟一帧再发出，确保 `place_player()` 的执行完成并且新场景上的传送区尚未激活。

如何收集日志并回传
- 在编辑器 Play 时，打开输出控制台，执行复现步骤并保存输出。
- 将输出中的关键时间点（load start/end、player_entered 信息、place_player 的坐标）截取并发给我，我可以根据时序定位是哪一步触发了额外调用。

下一步我可以：
- 帮你把上述 `print()` 日志点自动打进代码（临时补丁），并在测试完成后把这些日志点清理掉；
- 或者实现一种更稳妥的默认策略：在 `place_player()` 后对目标传送点延迟激活一小段时间（例如 3 帧），并把该延迟实现为可配置的参数。