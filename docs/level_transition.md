LevelTransition（关卡传送）详细说明

文件： `Levels/Scripts/level_transition.gd`

目的
- 在场景中定义玩家进入时触发的传送区域，将玩家移动到另一个关卡或同一关卡的另一个传送点。

关键导出属性
- `level` (.tscn): 目标场景文件。
- `target_transition_area` (String): 目标场景中要定位的传送点名称（例如 `LevelTransition`）。
- `center_player` (bool): 是否在目标传送点处将玩家居中。
- `size` (int): 区域主轴方向上的瓦片数量（影响碰撞区域大小）。
- `side` (LEFT/RIGHT/TOP/BOTTOM)：指示传送区面向的方向，影响偏移计算。
- `snap_to_grid` (bool)：是否在编辑器中将节点对齐到网格。

主要函数行为
- `_ready()`：调用 `update_area()` 更新碰撞区域；运行时先关闭 `monitoring`、调用 `place_player()`（如果当前为目标传送点），等待 `LevelManager.level_loaded` 后再开启 `monitoring` 并连接 `body_entered` 信号。

- `player_entered(_player)`：触发入口，注意几点保护逻辑：
  - 只对 `PlayerManager.player` 响应，忽略其他进入物体。
  - 若 `LevelManager.is_loading` 为真则忽略（防止在加载中重复触发）。
  - 触发时将 `monitoring = false` 并断开信号连接以避免链式触发。
  - 最后调用 `LevelManager.load_new_level(level, target_transition_area, get_offset())`。

- `get_offset()`：返回玩家相对于传送点的偏移。横向传送（LEFT/RIGHT）保持 x 固定偏移而 y 可选保留或居中；纵向传送保持 y 固定偏移而 x 可选保留或居中。

常见问题与建议
- 问题：玩家被放置到新场景的传送点后，可能再次重叠并触发目标场景中的另一个 `LevelTransition`，从而出现“直接进入下下个场景”的现象。
  - 已有防护措施：
    1. 在触发时 `monitoring = false` 并断开 `body_entered` 信号；
    2. 在 `player_entered` 里检查 `LevelManager.is_loading`；
    3. 在 `LevelManager` 里加入 `is_loading` 重入保护。
- 建议：在目标场景的传送点 `place_player()` 中避免直接创建/激活会立即触发的其他交互体，或在放置玩家后等几帧再开启该传送点的 `monitoring`（如果需要手动控制）。

调试点（快速）
- 在 `player_entered` 起始位置添加 `print("player_entered: ", name, " is_loading=", LevelManager.is_loading)` 以观察触发时机。
- 在 `LevelManager.load_new_level` 开始与结束处打印日志（或使用 `level_load_started` / `level_loaded` 信号监听器）以确认加载时序。