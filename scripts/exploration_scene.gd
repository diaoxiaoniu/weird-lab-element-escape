extends Node2D

## 探索场景主控制器
## 管理玩家在实验室中的探索和与热点的交互

var level_data: Dictionary = {}
var characters: Dictionary = {}
var puzzle_active: bool = false

@onready var player: Player = $Player
@onready var puzzle_overlay: Control = $CanvasLayer/PuzzleOverlay
@onready var intro_label: Label = $CanvasLayer/IntroLabel

func _ready() -> void:
	# 加载关卡数据
	level_data = LevelLoader.load_level("ch1_lv01_fire_edge")
	characters = LevelLoader.load_characters()
	
	# 连接所有热点
	connect_hotspots()
	
	# 初始隐藏谜题覆盖层
	if puzzle_overlay:
		puzzle_overlay.hide()
	
	# 显示简短的开场
	show_intro()

func connect_hotspots() -> void:
	# 连接所有热点的交互信号
	var hotspots = get_tree().get_nodes_in_group("hotspots")
	for hotspot in hotspots:
		if hotspot.has_signal("interacted"):
			hotspot.interacted.connect(_on_hotspot_interacted)

func show_intro() -> void:
	if intro_label and level_data.has("intro"):
		var intro = level_data.get("intro", {})
		var text = intro.get("text", "")
		intro_label.text = text
		intro_label.show()
		
		# 3秒后自动隐藏
		await get_tree().create_timer(3.0).timeout
		intro_label.hide()

func _on_hotspot_interacted(hotspot_id: String) -> void:
	print("探索场景：热点交互 - ", hotspot_id)
	
	# 打开谜题覆盖层
	if not puzzle_active:
		open_puzzle()

func open_puzzle() -> void:
	puzzle_active = true
	
	# 禁用玩家移动
	player.set_physics_process(false)
	
	# 显示谜题 UI
	if puzzle_overlay:
		puzzle_overlay.show()
		if puzzle_overlay.has_method("start_puzzle"):
			puzzle_overlay.start_puzzle(level_data, characters)
		
		# 连接谜题完成信号
		if puzzle_overlay.has_signal("puzzle_completed") and not puzzle_overlay.puzzle_completed.is_connected(_on_puzzle_completed):
			puzzle_overlay.puzzle_completed.connect(_on_puzzle_completed)

func _on_puzzle_completed(success: bool) -> void:
	puzzle_active = false
	
	# 关闭谜题覆盖层
	if puzzle_overlay:
		puzzle_overlay.hide()
	
	# 恢复玩家移动
	player.set_physics_process(true)
	
	if success:
		print("关卡完成！")
		# 这里可以加载下一关或显示完成画面
	else:
		print("继续探索...")
