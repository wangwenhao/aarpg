快速上手

前提：请使用 Godot 4.5 或更高版本打开本项目（`project.godot` 中指定的特性为 4.5）。

1) 在 Godot 编辑器中打开
- 启动 Godot 编辑器，选择包含 `project.godot` 的项目根目录：

```bash
# macOS 示例（若系统可执行名为 godot）
# 将路径替换为你的本地路径
godot --path /Users/bryant/Documents/code.me/godot_projects/aarpg
```

2) 运行项目
- 在编辑器中点击运行（Play）按钮，项目会打开 `project.godot` 中配置的主场景。

3) 关键位置
- Autoload / 单例：位于 `00_Globals/`，包含 `global_level_manager.gd`（LevelManager）、`global_player_manager.gd`（PlayerManager）、`global_audio_manager.gd` 等。
- 关卡传送：`Levels/Scripts/level_transition.gd`（负责触发关卡切换并计算玩家偏移）。

4) 本地调试建议
- 在编辑器中运行时可在输出面板查看 `print()` 日志。若需要更持久的日志，可添加文件写入或调试断点。