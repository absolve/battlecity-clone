extends HBoxContainer


export var img:StreamTexture
export var text:String

onready var imgNode=$TextureRect
onready var labelNode=$MarginContainer/Label

func _ready():
	imgNode.texture=img
	labelNode.text=text

