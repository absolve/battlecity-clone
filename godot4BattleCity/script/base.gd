extends Area2D



@onready var ani=$ani
@onready var shape=$shape
@onready var explosion=$explosion

var destroy=false #是否摧毁
var objType=Game.objType.BASE


func addexplode():
	
	pass


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
