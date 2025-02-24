extends Node2D

onready var timer=$Timer
onready var label=$Label

func _ready():
	
	pass

func setScore(s:int):
	label.text="%d"%s

func _on_Timer_timeout():
	queue_free()
