extends Node2D

export var disableInput=false

func _ready():
	if disableInput:
		set_physics_process(false)
	


func _input(event):
	if Input.is_action_pressed("select"):
		Game.changeScene("res://scene/welcome.tscn")
	
