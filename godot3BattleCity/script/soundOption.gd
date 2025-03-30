extends VBoxContainer



export var busName='Master'
export var volume:float=0.0 

onready var slider=$HSlider
onready var label=$Label
onready var sound=$AudioStreamPlayer



func setName(busName):
	self.busName=busName
	label.text=str(busName)
	sound.bus=self.busName

func setVolume(volume:float):
#	print(volume)
	self.volume=volume
#	slider.value=volume*100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear2db(self.volume/100))
