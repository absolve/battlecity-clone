extends Control

@export var autoHide=true
@onready var timer=$Timer

func _ready():
	if autoHide:
		timer.start()



func _on_timer_timeout():
	queue_free()
