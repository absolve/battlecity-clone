extends Label

onready var timer=$Timer

func _ready():
	
	pass

func setScore(s:int):
	text="%d"%s

func _on_Timer_timeout():
	queue_free()
