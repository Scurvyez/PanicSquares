extends Node

## --------------------------------/+\--------------------------------
## sound_manager.gd
## 
## Another small script to handle sounds. Implements a short public
## function to call elsewhere and pass in a valid sfx sound from the 
## options listed below. 
## 
## Will probably refactor later at some point to handle other sound
## types such as music, ui, and more gameplay sound effects.
## --------------------------------\+/--------------------------------

@export_group("Game Sounds")
@export var Pickup : AudioStream
@export var GhostPhysics : AudioStream
@export var WallSpawn : AudioStream

var audio_player: AudioStreamPlayer2D


func _ready():
	# Create a single AudioStreamPlayer2D for playback
	audio_player = AudioStreamPlayer2D.new()
	add_child(audio_player)


func play_sound(sound: AudioStream):
	if sound:
		audio_player.stream = sound
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.bus = "SFX"
		audio_player.play()
	else:
		print("Error: Sound is null")
