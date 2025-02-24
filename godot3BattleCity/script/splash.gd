extends Node2D

export var selectLevel=false
export var nextScene:PackedScene

onready var player=$player
onready var level=$name

func _ready():
	set_process_input(false)
#	if !selectLevel:
#		set_process_input(false)
	player.play("in")
	yield(player,"animation_finished")
	level.text="stage %d"%(Game.gameLevel+1)
	if !selectLevel:
		for i in range(120):
			yield(get_tree(),"physics_frame")
		var temp=nextScene.instance()
		get_tree().root.add_child(temp)
		player.play("out")
		SoundsUtil.playMusic()
		yield(player,"animation_finished")
		queue_free()		
	else:
		set_process_input(true)	
		
func _input(event):
	if Input.is_action_pressed("select"):
		var temp=nextScene.instance()
		get_tree().root.add_child(temp)
		player.play("out")
		SoundsUtil.playMusic()
		set_process_input(false)
		yield(player,"animation_finished")
		set_physics_process(true)
		queue_free()
	if Input.is_action_pressed("p1_up"):
		if Game.gameLevel<Game.mapList.size()-1:
			Game.gameLevel+=1
			level.text="stage %d"%(Game.gameLevel+1)
	if Input.is_action_pressed("p1_down"):
		if Game.gameLevel>0:
			Game.gameLevel-=1
			level.text="stage %d"%(Game.gameLevel+1)
