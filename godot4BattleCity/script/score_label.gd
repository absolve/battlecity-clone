extends Node2D

@onready var timer=$Timer
@onready var label=$Label

func setScore(s:int):
	label.text="%d"%s

func _on_timer_timeout():
	queue_free()
