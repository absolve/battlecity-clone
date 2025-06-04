extends Node2D




func _on_VideoPlayer_finished():
	Game.changeScene("res://scene/welcome.tscn")

func _input(event):
	if Input.is_action_pressed("select")||event is InputEventKey:
		Game.changeScene("res://scene/welcome.tscn")
