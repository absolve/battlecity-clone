extends Node2D


@onready var timer=$Timer
@onready var sound=$sound


func _ready():
	timer.start()



func _on_timer_timeout():
	sound.play()
	await sound.finished
	for i in range(90):
		await get_tree().physics_frame
	Game.changeScene("res://scene/welcome.tscn")	
		
