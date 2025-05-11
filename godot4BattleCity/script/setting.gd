extends Control

@onready var masterSliderNode=$TabContainer/General/MarginContainer3/vbox/master
@onready var bgSliderNode=$TabContainer/General/MarginContainer3/vbox/vg
@onready var sfxSliderNode=$TabContainer/General/MarginContainer3/vbox/sfx
@onready var useExtensionMapNode=$TabContainer/General/MarginContainer/CheckButton

func _ready() -> void:
	RenderingServer.set_default_clear_color('#000')
	masterSliderNode.setName('Master')
	bgSliderNode.setName('Bg')
	sfxSliderNode.setName('Sfx')

	masterSliderNode.slider.value=Game.config.Volume.Master*100
	bgSliderNode.slider.value=Game.config.Volume.Bg*100
	sfxSliderNode.slider.value=Game.config.Volume.Sfx*100
	
	masterSliderNode.slider.value_changed.connect(_on_master_value_changed)
	bgSliderNode.slider.value_changed.connect(_on_bg_value_changed)
	sfxSliderNode.slider.value_changed.connect(_on_sfx_value_changed)
	#print(Game.config.Base.useExtensionMap)
	useExtensionMapNode.button_pressed=Game.config.Base.useExtensionMap
	
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


func _on_check_button_toggled(toggled_on: bool) -> void:
	Game.config.Base.useExtensionMap=toggled_on
	Game.saveConfig()
	Game.initMap()
