extends PanelContainer

var eventName=''
onready var label=$MarginContainer/HBoxContainer/Label

func _ready():
	label.text=str(eventName)
	




