extends Node2D


func _ready():
	$CanvasLayer/RichTextLabel/AnimatedSprite2D.play("default")
	$CanvasLayer/RichTextLabel.text = "0"
