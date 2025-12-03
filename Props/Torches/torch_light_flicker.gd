
extends PointLight2D
class_name TorchLightFlicker


# 火把光晕抖动脚本（简单循环抖动）
# 作用：通过随机调整 PointLight2D 的 `energy` 与 `scale`，模拟火焰明暗与闪烁感。
# 实现要点：
# - 在 _ready() 启动一个异步循环 `flicker()`，每次调整后等待短时间再重复调用（递归 await）。
# - `energy` 在 [0.9, 1.0) 范围内小幅随机波动，配合 scale 视觉上更明显。
# - 定时器间隔约 0.1333 秒（约 7.5 次/秒），足够表现自然的火焰抖动但不会过于频繁。


func _ready() -> void:
	# 启动抖动循环
	flicker()


func flicker() -> void:
	# 随机能量（光强）在 0.9~1.0 之间微幅波动
	energy = randf() * 0.1 + 0.9
	# 将光源的 scale 与能量绑定，以便同时在强度和可视大小上表现抖动
	scale = Vector2(1, 1) * energy
	# 等待一小段时间后递归调用自身，形成持续的异步抖动循环
	await get_tree().create_timer(0.1333).timeout
	flicker()
