extends Area2D



@onready var ani=$ani
@onready var shape=$shape
@onready var explosion=$explosion

var destroy=false #是否摧毁
var objType=Game.objType.BASE
var explode=preload("res://scene/explode.tscn")

func addexplode():
	var temp = explode.instantiate()
	temp.position=position
	temp.big=true
	Game.map.addOther(temp)


func _on_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:
		if !destroy:
			set_deferred('monitorable',false)
			set_deferred('monitoring',false)
			destroy=true
			ani.play("destroy")
			Game.emit_signal("baseDestroyed")
			explosion.play()
			addexplode()
