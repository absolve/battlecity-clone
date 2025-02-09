extends AnimatedSprite


var big=false


func _ready():
	if big:
		play("big")
	else:
		play("default")


func _on_explode_animation_finished():
	queue_free()
