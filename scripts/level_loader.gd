class_name LevelLoader
extends RefCounted

## 关卡加载器
## 负责从JSON文件加载关卡数据

## 加载关卡数据
static func load_level(level_id: String) -> Dictionary:
	var file_path = "res://content/levels/%s.json" % level_id
	
	if not FileAccess.file_exists(file_path):
		push_error("关卡文件不存在: %s" % file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法打开关卡文件: %s" % file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		push_error("JSON解析错误 at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return {}
	
	return json.data

## 加载角色数据
static func load_characters() -> Dictionary:
	var file_path = "res://content/chars/characters.json"
	
	if not FileAccess.file_exists(file_path):
		push_error("角色文件不存在: %s" % file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法打开角色文件: %s" % file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		push_error("JSON解析错误: %s" % json.get_error_message())
		return {}
	
	return json.data.get("characters", {})

## 获取角色颜色
static func get_character_color(character_id: String, characters: Dictionary) -> Color:
	if character_id in characters:
		var color_string = characters[character_id].get("color", "#FFFFFF")
		return Color(color_string)
	return Color.WHITE

## 获取角色名称
static func get_character_name(character_id: String, characters: Dictionary) -> String:
	if character_id in characters:
		return characters[character_id].get("name", character_id)
	return character_id
