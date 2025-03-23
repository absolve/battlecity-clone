extends VBoxContainer

export var disableInput=false
onready var label=$ScrollContainer/VBoxContainer/Label
onready var content=$ScrollContainer/VBoxContainer/RichTextLabel

func _ready():
	if disableInput:
		label.visible=true
		set_physics_process(false)
	else:
		label.visible=true
		content.visible=false

func _input(event):
	if Input.is_action_pressed("select"):
		Game.changeScene("res://scene/welcome.tscn")
	
