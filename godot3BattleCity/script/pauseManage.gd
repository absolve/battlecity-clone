extends Node2D

export var isPause=false
onready var label=$Label
onready var sound=$sound
onready var player=$player

func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("select"):
		if !isPause:
			isPause=true
			player.play("blink")
			get_tree().paused=true
		else:
			isPause=false
			player.play("RESET")
			get_tree().paused=false
		sound.play()	
