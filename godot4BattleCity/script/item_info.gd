extends HBoxContainer


@export var img:CompressedTexture2D
@export var text:String

@onready var imgNode=$TextureRect
@onready var labelNode=$MarginContainer/Label

func _ready():
	imgNode.texture=img
	labelNode.text=text
