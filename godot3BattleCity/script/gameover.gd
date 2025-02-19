extends Node2D


onready var timer=$Timer
onready var sound=$sound

func _ready():
	timer.start()


func _on_Timer_timeout():
	sound.play()
	yield(sound,"finished")
	Game.changeScene("res://scene/welcome.tscn")
