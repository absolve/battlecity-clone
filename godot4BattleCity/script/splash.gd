extends Node2D

@export var selectLevel=false
@export var nextScene:PackedScene

@onready var level=$Label
@onready var player=$player

func _ready():
	set_process_input(false)
	player.play("in")
	await player.animation_finished
	level.text="stage %d"%(Game.gameLevel+1)
	if !selectLevel:
		await  get_tree().create_timer(1.5).timeout
		var temp=nextScene.instantiate()
		get_tree().root.add_child(temp)
		player.play("out")
		SoundsUtil.playMusic()
		await player.animation_finished
		get_tree().current_scene=temp
		queue_free()		
	else:
		set_process_input(true)	

func _input(event):
	if Input.is_action_pressed("select"):
		var temp=nextScene.instantiate()
		get_tree().root.add_child(temp)
		player.play("out")
		SoundsUtil.playMusic()
		set_process_input(false)
		await player.animation_finished
		set_physics_process(true)
		get_tree().current_scene=temp
		queue_free()
	if Input.is_action_pressed("p1_up"):
		if Game.gameLevel<Game.mapList.size()-1:
			Game.gameLevel+=1
			level.text="stage %d"%(Game.gameLevel+1)
	if Input.is_action_pressed("p1_down"):
		if Game.gameLevel>0:
			Game.gameLevel-=1
			level.text="stage %d"%(Game.gameLevel+1)
