extends CharacterBody2D
class_name Player

## 玩家角色控制器
## 支持 WASD/箭头键移动 + 点击移动

@export var move_speed: float = 200.0

var target_position: Vector2 = Vector2.ZERO
var is_moving_to_target: bool = false
var can_interact: bool = false
var nearest_hotspot: Area2D = null
var last_direction: Vector2 = Vector2.DOWN

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# 初始化
	target_position = global_position

func _physics_process(delta: float) -> void:
	var input_direction = Vector2.ZERO
	
	# 键盘输入（WASD 或箭头键）
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_direction.y -= 1
	
	# 如果有键盘输入，取消点击移动
	if input_direction.length() > 0:
		is_moving_to_target = false
		input_direction = input_direction.normalized()
		velocity = input_direction * move_speed
	elif is_moving_to_target:
		# 点击移动
		var direction = (target_position - global_position).normalized()
		var distance = global_position.distance_to(target_position)
		
		if distance > 5.0:
			velocity = direction * move_speed
		else:
			velocity = Vector2.ZERO
			is_moving_to_target = false
	else:
		velocity = Vector2.ZERO
	
	# 更新动画
	update_animation()
	
	move_and_slide()

func update_animation() -> void:
	if velocity.length() > 0:
		# 移动中 - 播放行走动画
		last_direction = velocity.normalized()
		
		# 根据方向选择动画
		# 判断主要方向（横向或纵向）
		if abs(velocity.x) > abs(velocity.y):
			# 横向移动
			if velocity.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			# 纵向移动
			if velocity.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
	else:
		# 静止 - 播放待机动画
		animated_sprite.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	# 点击地面移动
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_position = get_global_mouse_position()
			is_moving_to_target = true
	
	# E 键交互
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		if can_interact and nearest_hotspot:
			interact_with_hotspot()

func interact_with_hotspot() -> void:
	if nearest_hotspot and nearest_hotspot.has_method("interact"):
		nearest_hotspot.interact()

func set_nearest_hotspot(hotspot: Area2D) -> void:
	nearest_hotspot = hotspot
	can_interact = hotspot != null

func move_to(position: Vector2) -> void:
	target_position = position
	is_moving_to_target = true
