extends CanvasLayer  # 使用 CanvasLayer 保证过渡 UI 在场景最上层，不受相机移动影响

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer  # 延迟获取位于 Control 下的 AnimationPlayer 节点，用于播放淡入/淡出动画

func fade_in() -> bool:
	# 播放淡入动画并等待动画播放完毕，返回 true 表示完成（函数为 awaitable）
	animation_player.play('fade_in')
	#await animation_player.animation_finished
	return true

func fade_out() -> bool:
	# 播放淡出动画并等待动画播放完毕，返回 true 表示完成（函数为 awaitable）
	animation_player.play("fade_out")
	await animation_player.animation_finished
	return true
