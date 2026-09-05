extends Control

## 谜题覆盖层
## 重用原有的关卡播放器逻辑，但作为可开关的覆盖层

signal puzzle_completed(success: bool)

enum GameState {
	INTRO,
	INVESTIGATE,
	CHOICE,
	RESULT,
	RECAP
}

var current_state: GameState = GameState.INVESTIGATE
var level_data: Dictionary = {}
var characters: Dictionary = {}
var fail_count: int = 0
var unlocked_tips: Array = []
var selected_choice: String = ""
var portrait_textures: Dictionary = {}

# UI节点引用
@onready var TitleLabel: Label = %TitleLabel
@onready var SpeakerLabel: Label = %SpeakerLabel
@onready var DialogueLabel: Label = %DialogueLabel
@onready var Portrait: TextureRect = %Portrait
@onready var ContinueBtn: Button = %ContinueBtn
@onready var TipsBtn: Button = %TipsBtn
@onready var CloseBtn: Button = %CloseBtn
@onready var TipPanel: PanelContainer = %TipPanel
@onready var TipLabel: Label = %TipLabel
@onready var InvestigateRow: VBoxContainer = %InvestigateRow
@onready var ChoiceRow: VBoxContainer = %ChoiceRow
@onready var RecapPanel: PanelContainer = %RecapPanel
@onready var RecapLabel: Label = %RecapLabel
@onready var StatusLabel: Label = %StatusLabel

func _ready() -> void:
	# 加载肖像
	load_portraits()
	
	# 连接信号
	if ContinueBtn:
		ContinueBtn.pressed.connect(_on_continue_pressed)
	if TipsBtn:
		TipsBtn.pressed.connect(_on_tips_pressed)
	if CloseBtn:
		CloseBtn.pressed.connect(_on_close_pressed)
	
	# 初始化UI状态
	if TipPanel:
		TipPanel.hide()
	if RecapPanel:
		RecapPanel.hide()
	if Portrait:
		Portrait.hide()

func load_portraits() -> void:
	portrait_textures["rixen"] = load("res://assets/portrait_rixen_placeholder.png")
	portrait_textures["mori"] = load("res://assets/portrait_mori_placeholder.png")

func start_puzzle(data: Dictionary, chars: Dictionary) -> void:
	level_data = data
	characters = chars
	fail_count = 0
	unlocked_tips = ["tip1"]
	
	if TitleLabel:
		TitleLabel.text = level_data.get("title", "未命名关卡")
	
	show_investigate()

func show_investigate() -> void:
	current_state = GameState.INVESTIGATE
	
	var investigate = level_data.get("investigate", {})
	var text = investigate.get("text", "")
	var scene_desc = investigate.get("scene_description", "")
	
	if SpeakerLabel:
		SpeakerLabel.text = ""
	if DialogueLabel:
		DialogueLabel.text = text + "\n\n" + scene_desc
	
	if ContinueBtn:
		ContinueBtn.hide()
	if TipsBtn:
		TipsBtn.show()
	if InvestigateRow:
		InvestigateRow.show()
	if ChoiceRow:
		ChoiceRow.hide()
	if RecapPanel:
		RecapPanel.hide()
	
	show_choices()

func show_choices() -> void:
	current_state = GameState.CHOICE
	
	if not ChoiceRow:
		return
	
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
	
	show_result(response, result)

func show_result(response: Dictionary, result: String) -> void:
	current_state = GameState.RESULT
	
	var speaker = response.get("speaker", "")
	var text = response.get("text", "")
	var outcome = response.get("outcome", "")
	
	update_dialogue(speaker, text + "\n\n" + outcome)
	
	if InvestigateRow:
		InvestigateRow.hide()
	if ChoiceRow:
		ChoiceRow.hide()
	
	if result == "fail":
		fail_count += 1
		
		# 检查提示解锁
		var tips = level_data.get("tips", [])
		for tip in tips:
			var unlock_after = tip.get("unlock_after_fails", 0)
			if unlock_after > 0 and fail_count >= unlock_after:
				if not unlocked_tips.has(tip.get("id", "")):
					unlocked_tips.append(tip.get("id", ""))
		
		await get_tree().create_timer(2.0).timeout
		show_fail_lines()
	else:
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
	
	if SpeakerLabel:
		SpeakerLabel.text = ""
	if DialogueLabel:
		DialogueLabel.text = ""
	if RecapLabel:
		RecapLabel.text = title + "\n\n" + content
	if RecapPanel:
		RecapPanel.show()
	
	if ContinueBtn:
		ContinueBtn.text = "完成"
		ContinueBtn.show()

func _on_continue_pressed() -> void:
	if current_state == GameState.RECAP:
		# 完成谜题
		puzzle_completed.emit(true)

func _on_close_pressed() -> void:
	# 关闭谜题面板（未完成）
	puzzle_completed.emit(false)

func _on_tips_pressed() -> void:
	if TipPanel and TipPanel.visible:
		TipPanel.hide()
		return
	
	var tips = level_data.get("tips", [])
	var tip_text = "【提示】\n\n"
	
	for tip in tips:
		var tip_id = tip.get("id", "")
		if unlocked_tips.has(tip_id):
			tip_text += tip.get("text", "") + "\n\n"
	
	var locked_count = 0
	for tip in tips:
		if not unlocked_tips.has(tip.get("id", "")):
			locked_count += 1
	
	if locked_count > 0:
		tip_text += "还有 %d 个提示未解锁。" % locked_count
	
	if TipLabel:
		TipLabel.text = tip_text
	if TipPanel:
		TipPanel.show()

func update_dialogue(speaker_id: String, text: String) -> void:
	if speaker_id != "":
		var speaker_name = LevelLoader.get_character_name(speaker_id, characters)
		var speaker_color = LevelLoader.get_character_color(speaker_id, characters)
		if SpeakerLabel:
			SpeakerLabel.text = speaker_name
			SpeakerLabel.modulate = speaker_color
		
		if speaker_id in portrait_textures and Portrait:
			Portrait.texture = portrait_textures[speaker_id]
			Portrait.show()
		elif Portrait:
			Portrait.hide()
	else:
		if SpeakerLabel:
			SpeakerLabel.text = ""
		if Portrait:
			Portrait.hide()
	
	if DialogueLabel:
		DialogueLabel.text = text
