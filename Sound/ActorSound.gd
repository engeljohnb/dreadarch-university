extends Node

class_name ActorSound

var stream : AudioStream
var looping : bool = false
var play_only_once : bool = false
var played : bool = false
# How long to delay sound once the action begins
var delay : float = 0.0
