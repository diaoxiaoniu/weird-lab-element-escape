extends Area2D
class_name Hotspot

## 可交互热点
## 玩家靠近后可以按 E 或点击交互

signal interacted(hotspot_id: String)

@export var hotspot_id: String = ""
@export var hotspot_name: String = "交互物品"
@export var interaction_hint: String = "[E] 交互"

var player_nearby: bool = false
var current_player: Player = null

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 初始化标签
	if label:
		label.text = ""
		label.hide()
	
	# 鼠标事件
	input_event.connect(_on_input_event)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		current_player = body
		body.set_nearest_hotspot(self)
		show_hint()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		if current_player == body:
			body.set_nearest_hotspot(null)
			current_player = null
		hide_hint()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 点击热点交互
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and player_nearby:
			interact()

func show_hint() -> void:
	if label:
		label.text = interaction_hint
		label.show()

func hide_hint() -> void:
	if label:
		label.hide()

func interact() -> void:
	interacted.emit(hotspot_id)
	print("交互热点: ", hotspot_id)
