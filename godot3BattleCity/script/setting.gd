extends Control

onready var masterSliderNode=$TabContainer/General/MarginContainer3/vbox/master
onready var bgSliderNode=$TabContainer/General/MarginContainer3/vbox/bg
onready var sfxSliderNode=$TabContainer/General/MarginContainer3/vbox/sfx
onready var useExtensionMapNode=$TabContainer/General/MarginContainer2/CheckButton

func _ready():
#	VisualServer.set_default_clear_color('#646464')
	VisualServer.set_default_clear_color('#000')
	masterSliderNode.setName('Master')
	bgSliderNode.setName('bg')
	sfxSliderNode.setName('sfx')
	
	masterSliderNode.slider.value=Game.config.Volume.Master*100
	bgSliderNode.slider.value=Game.config.Volume.Bg*100
	sfxSliderNode.slider.value=Game.config.Volume.Sfx*100
	
	masterSliderNode.slider.connect("value_changed",self,"_on_master_value_changed")
	bgSliderNode.slider.connect("value_changed",self,"_on_bg_value_changed")
	sfxSliderNode.slider.connect("value_changed",self,"_on_sfx_value_changed")
	
	useExtensionMapNode.pressed=Game.config.Base.useExtensionMap
	
func _on_master_value_changed(value):
	masterSliderNode.setVolume(value)
	masterSliderNode.sound.play()
	Game.config.Volume.Master=value/100
	Game.saveConfig()
	
func _on_bg_value_changed(value):	
	bgSliderNode.setVolume(value)
	bgSliderNode.sound.play()
	Game.config.Volume.Bg=value/100
	Game.saveConfig()
	
func _on_sfx_value_changed(value):
	sfxSliderNode.setVolume(value)
	sfxSliderNode.sound.play()
	Game.config.Volume.Sfx=value/100
	Game.saveConfig()


func _on_CheckButton_toggled(button_pressed):
	print(button_pressed)
	Game.config.Base.useExtensionMap=button_pressed
	Game.saveConfig()
	Game.initMap()


func _on_TextureButton_pressed():
	Game.changeScene("res://scene/welcome.tscn")
