extends VBoxContainer


@export var disableInput=false
@onready var label=$ScrollContainer/VBoxContainer/Label


func _ready():
	if disableInput:
		label.visible=true
		set_physics_process(false)
	else:
		label.visible=true
	
func _input(event):
	if Input.is_action_pressed("select"):
		Game.changeScene("res://scene/welcome.tscn")
