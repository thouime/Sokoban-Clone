extends MarginContainer

@onready var stage_label: Label = $PanelContainer/VBoxContainer/PanelContainer/PanelContainer/HBoxContainer/StageLabel
@onready var stage_num: Label = $PanelContainer/VBoxContainer/PanelContainer/PanelContainer/HBoxContainer/StageNum
@onready var step_label: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer2/StepLabel
@onready var step_num: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer2/StepNum
@onready var limit_label: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer3/LimitLabel
@onready var limit_num: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer3/LimitNum
@onready var area_2d: Area2D = $PanelContainer/Area2D

func _ready() -> void:
	area_2d.body_entered.connect(_on_player_entered)

func set_stage_num(num: int) -> void:
	stage_num.text = "%02d" % num

func set_step_num(num: int) -> void:
	step_num.text = "%04d" % num
	
func set_limit_num(num: int) -> void:
	limit_num.text = "%04d" % num

func _on_player_entered(body: Node2D) -> void:
	if anchor_left == 0.0:
		set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	else:
		set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
