extends AudioStreamPlayer2D

@onready var InputHandler: Node = $"../InputHandler"

# BPM & Taktart der gewählten Musik, im Inspector anpassen:
@export var beats_per_minute := 100
@export var beats_per_measure := 4

# Variablen, um Beat & Sondposition zu tracken:
var song_position = 0.0
var song_position_in_beats = 1
var sec_per_beat = 60.0 / beats_per_minute
var last_reported_beat = 0
var beats_before_start = 0
var measure = 1

# sind Events / Player Inputs on beat:
@export var ON_BEAT_THRESHOLD = 0.2
var closest_beat = 0
var time_off_beat = 0.0

func _ready():
	sec_per_beat = 60.0 / beats_per_minute
	play()
	#play_with_beat_offset(8)
	#play_from_beat(20,8)
	
func _physics_process(delta: float) -> void:
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if measure > beats_per_measure:
			measure = 1
		Globals.beat.emit(song_position_in_beats)
		Globals.measure.emit(measure)
		last_reported_beat = song_position_in_beats
		measure += 1

# queue fake beats to allow game node to spawn events on time:
func play_with_beat_offset(num):
	beats_before_start = num
	$BeatOffsetTimer.wait_time = sec_per_beat
	$BeatOffsetTimer.start()
	
# start music from specific song_position_in_beats:
func play_from_beat(beat, offset):
	play()
	seek(beat * sec_per_beat)
	beats_before_start = offset
	measure = beat % beats_per_measure

func _on_beat_offset_timer_timeout() -> void:
	song_position_in_beats += 1
	if song_position_in_beats < beats_before_start - 1:
		$BeatOffsetTimer.start()
	elif song_position_in_beats == beats_before_start - 1:
		$BeatOffsetTimer.wait_time = $BeatOffsetTimer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		$BeatOffsetTimer.start()
	else:
		play()
		$BeatOffsetTimer.stop()
	_report_beat()

# berechnet, ob ein Input unterhalb der on_beat Schwelle ist (gibt true/false zurück):
func is_action_on_beat(action_song_position):
	var is_on_beat = false
	closest_beat = int(round(action_song_position / sec_per_beat))
	time_off_beat = abs(closest_beat * sec_per_beat - action_song_position)
	if time_off_beat < ON_BEAT_THRESHOLD:
		is_on_beat = true
	return is_on_beat
