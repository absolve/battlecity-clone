extends Node2D

@onready var mapCountNode=$Control/hbox/mapCount
@onready var pageNode=$Control/hbox/page
@onready var miniMap1=$miniMap
@onready var miniMap2=$miniMap2
@onready var miniMap3=$miniMap3
@onready var miniMap4=$miniMap4
@onready var miniMap5=$miniMap5
@onready var miniMap6=$miniMap6
@onready var miniMap1Name=$miniMap/Label
@onready var miniMap2Name=$miniMap2/Label
@onready var miniMap3Name=$miniMap3/Label
@onready var miniMap4Name=$miniMap4/Label
@onready var miniMap5Name=$miniMap5/Label
@onready var miniMap6Name=$miniMap6/Label

const mapDir="res://level"	#内置地图路径
var page=0

func _ready():
	RenderingServer.set_default_clear_color('#646464')
#	pageNode.add_item()
	page=ceil(Game.mapList.size()/6.0) 
	print(page)
	for i in range(1,page+1):
		pageNode.add_item(str(i))
	mapCountNode.text='mapcount:%d'%Game.mapList.size()
	showMap(0)

#设置地图	
func showMap(page):
	miniMap1.visible=false
	miniMap2.visible=false
	miniMap3.visible=false
	miniMap4.visible=false
	miniMap5.visible=false
	miniMap6.visible=false
	var start=page*6
	for i in range(6):
		if start+i<Game.mapList.size():
			if i==0:
				miniMap1.visible=true
				miniMap1.loadMap(mapDir+"/"+Game.mapList[start+i])
				miniMap1Name.text=str(Game.mapList[start+i])
			elif i==1:
				miniMap2.visible=true
				miniMap2.loadMap(mapDir+"/"+Game.mapList[start+i])	
				miniMap2Name.text=str(Game.mapList[start+i])
			elif i==2:
				miniMap3.visible=true
				miniMap3.loadMap(mapDir+"/"+Game.mapList[start+i])	
				miniMap3Name.text=str(Game.mapList[start+i])
			elif i==3:
				miniMap4.visible=true
				miniMap4.loadMap(mapDir+"/"+Game.mapList[start+i])	
				miniMap4Name.text=str(Game.mapList[start+i])
			elif i==4:
				miniMap5.visible=true
				miniMap5.loadMap(mapDir+"/"+Game.mapList[start+i])	
				miniMap5Name.text=str(Game.mapList[start+i])
			elif i==5:
				miniMap6.visible=true
				miniMap6.loadMap(mapDir+"/"+Game.mapList[start+i])	
				miniMap6Name.text=str(Game.mapList[start+i])


func _on_page_item_selected(index):
		showMap(index)


func _on_button_pressed():
	Game.changeScene("res://scene/welcome.tscn")
