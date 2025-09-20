extends Node2D


func _ready():
	$CanvasLayer/AnimatedSprite2D.play("default")
	$CanvasLayer/RichTextLabel.text = "0"
