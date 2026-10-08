extends MarginContainer

@onready var stage_label: Label = $PanelContainer/VBoxContainer/PanelContainer/PanelContainer/HBoxContainer/StageLabel
@onready var stage_num: Label = $PanelContainer/VBoxContainer/PanelContainer/PanelContainer/HBoxContainer/StageNum
@onready var step_label: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer2/StepLabel
@onready var step_num: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer2/StepNum
@onready var limit_label: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer3/LimitLabel
@onready var limit_num: Label = $PanelContainer/VBoxContainer/PanelContainer2/PanelContainer/VBoxContainer/HBoxContainer3/LimitNum

func set_stage_num(num: int) -> void:
	stage_num.text = "%02d" % num

func set_step_num(num: int) -> void:
	step_num.text = "%04d" % num
	
func set_limit_num(num: int) -> void:
	limit_num.text = "%04d" % num
