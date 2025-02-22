extends Area2D


var destroy=false #是否摧毁
var objType=Game.objType.BASE
onready var ani=$ani
onready var shape=$shape
onready var explosion=$explosion
var explode=preload("res://scene/explode.tscn")

func _ready():
	pass # Replace with function body.

func addexplode():
	var temp = explode.instance()
	temp.position=position
	temp.big=true
	Game.map.addOther(temp)
	
func _on_base_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:
		if !destroy:
			shape.call_deferred('set_disabled',true)
			destroy=true
			ani.play("destroy")
			Game.emit_signal("baseDestroyed")
			explosion.play()
			addexplode()
