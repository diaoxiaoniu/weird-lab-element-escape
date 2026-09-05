extends Control

## 关卡播放器
## 控制游戏流程：INTRO → INVESTIGATE/CHOICE → RESULT → RECAP

enum GameState {
	INTRO,
	INVESTIGATE,
	CHOICE,
	RESULT,
	RECAP
}

var current_state: GameState = GameState.INTRO
var level_data: Dictionary = {}
var characters: Dictionary = {}
var fail_count: int = 0
var unlocked_tips: Array = []
var selected_choice: String = ""

# 角色肖像纹理（占位符美术资源）
var portrait_textures: Dictionary = {}

# UI节点引用（使用唯一名称避免路径依赖）
@onready var TitleLabel: Label = %TitleLabel
@onready var SpeakerLabel: Label = %SpeakerLabel
@onready var DialogueLabel: Label = %DialogueLabel
@onready var Portrait: TextureRect = %Portrait
@onready var ContinueBtn: Button = %ContinueBtn
@onready var TipsBtn: Button = %TipsBtn
@onready var TipPanel: PanelContainer = %TipPanel
@onready var TipLabel: Label = %TipLabel
@onready var InvestigateRow: VBoxContainer = %InvestigateRow
@onready var ChoiceRow: VBoxContainer = %ChoiceRow
@onready var RecapPanel: PanelContainer = %RecapPanel
@onready var RecapLabel: Label = %RecapLabel
@onready var StatusLabel: Label = %StatusLabel

func _ready() -> void:
	# 加载角色数据
	characters = LevelLoader.load_characters()
	
	# 加载角色肖像纹理（占位符）
	load_portraits()
	
	# 加载第一关
	load_level("ch1_lv01_fire_edge")
	
	# 连接信号
	ContinueBtn.pressed.connect(_on_continue_pressed)
	TipsBtn.pressed.connect(_on_tips_pressed)
	
	# 初始化UI状态
	TipPanel.hide()
	InvestigateRow.hide()
	ChoiceRow.hide()
	RecapPanel.hide()
	Portrait.hide()
	
	# 开始游戏
	show_intro()

func load_portraits() -> void:
	# 加载占位符肖像图片
	portrait_textures["rixen"] = load("res://assets/portrait_rixen_placeholder.png")
	portrait_textures["mori"] = load("res://assets/portrait_mori_placeholder.png")
	# system 角色不显示肖像或使用默认图标

func load_level(level_id: String) -> void:
	level_data = LevelLoader.load_level(level_id)
	if level_data.is_empty():
		StatusLabel.text = "关卡加载失败！"
		return
	
	TitleLabel.text = level_data.get("title", "未命名关卡")
	fail_count = 0
	unlocked_tips = ["tip1"]  # 默认解锁第一个提示

func show_intro() -> void:
	current_state = GameState.INTRO
	
	var intro = level_data.get("intro", {})
	var speaker = intro.get("speaker", "")
	var text = intro.get("text", "")
	
	update_dialogue(speaker, text)
	ContinueBtn.text = "继续"
	ContinueBtn.show()
	TipsBtn.hide()
	InvestigateRow.hide()
	ChoiceRow.hide()
	RecapPanel.hide()

func show_investigate() -> void:
	current_state = GameState.INVESTIGATE
	
	var investigate = level_data.get("investigate", {})
	var text = investigate.get("text", "")
	var scene_desc = investigate.get("scene_description", "")
	
	SpeakerLabel.text = ""
	DialogueLabel.text = text + "\n\n" + scene_desc
	
	ContinueBtn.hide()
	TipsBtn.show()
	InvestigateRow.show()
	ChoiceRow.hide()
	RecapPanel.hide()
	
	show_choices()

func show_choices() -> void:
	current_state = GameState.CHOICE
	
	# 清空现有选项
	for child in ChoiceRow.get_children():
		child.queue_free()
	
	var choices = level_data.get("choices", [])
	for choice in choices:
		var btn = Button.new()
		btn.text = "[%s] %s" % [choice.get("id", ""), choice.get("text", "")]
		btn.pressed.connect(_on_choice_selected.bind(choice.get("id", "")))
		ChoiceRow.add_child(btn)
	
	ChoiceRow.show()

func _on_choice_selected(choice_id: String) -> void:
	selected_choice = choice_id
	
	# 查找选中的选项
	var choices = level_data.get("choices", [])
	var selected = null
	for choice in choices:
		if choice.get("id", "") == choice_id:
			selected = choice
			break
	
	if selected == null:
		return
	
	var result = selected.get("result", "fail")
	var response = selected.get("response", {})
	
	# 显示结果
	show_result(response, result)

func show_result(response: Dictionary, result: String) -> void:
	current_state = GameState.RESULT
	
	var speaker = response.get("speaker", "")
	var text = response.get("text", "")
	var outcome = response.get("outcome", "")
	
	update_dialogue(speaker, text + "\n\n" + outcome)
	
	InvestigateRow.hide()
	ChoiceRow.hide()
	
	if result == "fail":
		fail_count += 1
		
		# 检查是否需要强制解锁tip1
		var tips = level_data.get("tips", [])
		for tip in tips:
			var unlock_after = tip.get("unlock_after_fails", 0)
			if unlock_after > 0 and fail_count >= unlock_after:
				if not unlocked_tips.has(tip.get("id", "")):
					unlocked_tips.append(tip.get("id", ""))
		
		# 显示失败台词
		await get_tree().create_timer(2.0).timeout
		show_fail_lines()
	else:
		# 显示成功台词
		await get_tree().create_timer(2.0).timeout
		show_success_lines()

func show_fail_lines() -> void:
	var fail_lines = level_data.get("fail_lines", [])
	if fail_lines.is_empty():
		show_investigate()
		return
	
	for line in fail_lines:
		var speaker = line.get("speaker", "")
		var text = line.get("text", "")
		update_dialogue(speaker, text)
		await get_tree().create_timer(2.0).timeout
	
	show_investigate()

func show_success_lines() -> void:
	var success_lines = level_data.get("success_lines", [])
	
	for line in success_lines:
		var speaker = line.get("speaker", "")
		var text = line.get("text", "")
		update_dialogue(speaker, text)
		await get_tree().create_timer(2.0).timeout
	
	show_recap()

func show_recap() -> void:
	current_state = GameState.RECAP
	
	var recap = level_data.get("recap", {})
	var title = recap.get("title", "关卡完成")
	var content = recap.get("content", "")
	
	SpeakerLabel.text = ""
	DialogueLabel.text = ""
	
	RecapLabel.text = title + "\n\n" + content
	RecapPanel.show()
	
	ContinueBtn.text = "下一关"
	ContinueBtn.show()

func _on_continue_pressed() -> void:
	if current_state == GameState.INTRO:
		show_investigate()
	elif current_state == GameState.RECAP:
		load_next_level()

func _on_tips_pressed() -> void:
	if TipPanel.visible:
		TipPanel.hide()
		return
	
	var tips = level_data.get("tips", [])
	var tip_text = "【提示】\n\n"
	
	for tip in tips:
		var tip_id = tip.get("id", "")
		if unlocked_tips.has(tip_id):
			tip_text += tip.get("text", "") + "\n\n"
	
	# 显示如何解锁更多提示
	var locked_count = 0
	for tip in tips:
		if not unlocked_tips.has(tip.get("id", "")):
			locked_count += 1
	
	if locked_count > 0:
		tip_text += "还有 %d 个提示未解锁。" % locked_count
	
	TipLabel.text = tip_text
	TipPanel.show()

func load_next_level() -> void:
	var next_level = level_data.get("next_level", "")
	if next_level != "":
		load_level(next_level)
		show_intro()
	else:
		StatusLabel.text = "恭喜通关！"
		ContinueBtn.hide()

func update_dialogue(speaker_id: String, text: String) -> void:
	if speaker_id != "":
		var speaker_name = LevelLoader.get_character_name(speaker_id, characters)
		var speaker_color = LevelLoader.get_character_color(speaker_id, characters)
		SpeakerLabel.text = speaker_name
		SpeakerLabel.modulate = speaker_color
		
		# 显示对应角色的肖像
		if speaker_id in portrait_textures:
			Portrait.texture = portrait_textures[speaker_id]
			Portrait.show()
		else:
			# system 或其他角色不显示肖像
			Portrait.hide()
	else:
		SpeakerLabel.text = ""
		Portrait.hide()
	
	DialogueLabel.text = text
