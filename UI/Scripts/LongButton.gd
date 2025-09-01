extends TextureButton

@export var text = ""
@onready var label = $RichTextLabel

func _ready():
	label.push_font()
	label.text = text
