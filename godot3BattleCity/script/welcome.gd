extends Node2D

var posY=[240,265,295,320,350] #选择是坦克的位置
var index=0 #
enum mode{
	P1,P2,CONFIGMAP,SETTING,MAPVIEW
}

var selectedMode=mode.P1

onready var tankAni=$main/tankAni
onready var player=$player
onready var tipDialog=$PopupPanel

func _ready():
	VisualServer.set_default_clear_color('#000')
	player.play("move")
	

func setMode(index):
	tankAni.position.y=posY[index]
	if index==0:
		selectedMode=mode.P1
	elif index==1:
		selectedMode=mode.P2
	elif index==2:
		selectedMode=mode.CONFIGMAP
	elif index==3:
		selectedMode=mode.SETTING
	elif index==4:
		selectedMode=mode.MAPVIEW			

func startGame():
	if selectedMode in [mode.P1,mode.P2]:
		if Game.mapList.size()==0: #地图为空进行判断
			tipDialog.popup_centered()
			return
		var temp=load("res://scene/splash.tscn")
		Game.resetData()
		if selectedMode==mode.P1:
			Game.mode=Game.gameMode.SINGLE
		elif selectedMode==mode.P2:
			Game.mode=Game.gameMode.DOUBLE
		var scene=temp.instance()
		scene.selectLevel=true
		get_tree().root.add_child(scene)
		get_tree().current_scene=scene
		queue_free()
	elif selectedMode==	mode.MAPVIEW:
		Game.changeScene("res://scene/mapView.tscn")
	elif selectedMode==mode.SETTING:
		Game.changeScene("res://scene/setting.tscn")	
	elif selectedMode==mode.CONFIGMAP:
		Game.changeScene("res://scene/editmap.tscn")

func _input(event):
	if Input.is_action_just_pressed("p1_up")||Input.is_action_just_pressed("p2_up"):
		if index>0:
			index-=1
			setMode(index)
	elif Input.is_action_just_pressed("p1_down")||Input.is_action_just_pressed("p2_down"):
		if index<posY.size()-1:
			index+=1
			setMode(index)
	if Input.is_action_just_pressed("select"):
		if player.is_playing():
			player.play("RESET")
			return
		startGame()
	


func _on_Button_pressed():
	tipDialog.hide()
