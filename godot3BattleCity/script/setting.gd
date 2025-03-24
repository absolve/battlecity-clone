extends Control

onready var masterSliderNode=$TabContainer/general/VBoxContainer/master
onready var bgSliderNode=$TabContainer/general/VBoxContainer/bg
onready var sfxSliderNode=$TabContainer/general/VBoxContainer/sfx


func _ready():
	VisualServer.set_default_clear_color('#000')
	masterSliderNode.setName('Master')
	bgSliderNode.setName('bg')
	sfxSliderNode.setName('sfx')
	
	masterSliderNode.setVolume(Game.config.Volume.Master)
	bgSliderNode.setVolume(Game.config.Volume.Bg)
	sfxSliderNode.setVolume(Game.config.Volume.Sfx)
	
	masterSliderNode.slider.connect("value_changed",self,"_on_master_value_changed")
	bgSliderNode.slider.connect("value_changed",self,"_on_bg_value_changed")
	sfxSliderNode.slider.connect("value_changed",self,"_on_sfx_value_changed")
	
func _on_master_value_changed(value):
	masterSliderNode.setVolume(value)
	masterSliderNode.sound.play()
	
func _on_bg_value_changed(value):	
	bgSliderNode.setVolume(value)
	bgSliderNode.sound.play()
	
func _on_sfx_value_changed(value):
	sfxSliderNode.setVolume(value)
	sfxSliderNode.sound.play()
