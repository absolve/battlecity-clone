extends Area2D


var destroy=false

onready var ani=$ani

func _ready():
	pass # Replace with function body.




func _on_base_body_entered(body):
	if !destroy:
		destroy=true
		ani.play("destroy")
