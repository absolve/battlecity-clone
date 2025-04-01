tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("InputBind","res://addons/InputBind/InputBind.gd")



func _exit_tree():
	remove_autoload_singleton("InputBind")
