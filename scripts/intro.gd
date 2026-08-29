extends Control

@export_file("*.tscn") var next_scene: String = "res://scenes/MainMenu.tscn"
@export var intro_duration := 5.5

var background: ColorRect
var glow: ColorRect
var logo: Label
var subtitle: Label
var skip_label: Label
var line_top: ColorRect
var line_bottom: ColorRect
var audio_player: AudioStreamPlayer
var leaving := false

func _ready() -> void:
    set_process_input(true)
    _build_ui()
    _start_intro()

func _build_ui() -> void:
    background = ColorRect.new()
    background.color = Color("#080a12")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    glow = ColorRect.new()
    glow.color = Color(0.10, 0.28, 0.55, 0.14)
    glow.position = Vector2(-220, -120)
    glow.size = Vector2(900, 600)
    background.add_child(glow)

    line_top = ColorRect.new()
    line_top.color = Color("#69b7ff")
    line_top.position = Vector2(0, 0)
    line_top.size = Vector2(0, 3)
    add_child(line_top)

    line_bottom = ColorRect.new()
    line_bottom.color = Color("#69b7ff")
    line_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    line_bottom.position = Vector2(0, -3)
    line_bottom.size = Vector2(0, 3)
    add_child(line_bottom)

    logo = Label.new()
    logo.text = "ESCAPE THE TENNIS COURT"
    logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    logo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    logo.add_theme_font_size_override("font_size", 54)
    logo.add_theme_color_override("font_color", Color("#f4f7ff"))
    logo.add_theme_color_override("font_shadow_color", Color(0.05, 0.15, 0.35, 0.9))
    logo.add_theme_constant_override("shadow_offset_x", 5)
    logo.add_theme_constant_override("shadow_offset_y", 5)
    logo.anchor_left = 0.5
    logo.anchor_top = 0.5
    logo.anchor_right = 0.5
    logo.anchor_bottom = 0.5
    logo.offset_left = -520
    logo.offset_top = -70
    logo.offset_right = 520
    logo.offset_bottom = 10
    logo.modulate = Color(1, 1, 1, 0)
    logo.scale = Vector2(0.82, 0.82)
    add_child(logo)

    subtitle = Label.new()
    subtitle.text = "A GAME BY STUPIDSSTUFF"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 16)
    subtitle.add_theme_color_override("font_color", Color("#8fa6c7"))
    subtitle.anchor_left = 0.5
    subtitle.anchor_top = 0.5
    subtitle.anchor_right = 0.5
    subtitle.anchor_bottom = 0.5
    subtitle.offset_left = -300
    subtitle.offset_top = 25
    subtitle.offset_right = 300
    subtitle.offset_bottom = 60
    subtitle.modulate = Color(1, 1, 1, 0)
    add_child(subtitle)

    skip_label = Label.new()
    skip_label.text = "PRESS ENTER TO SKIP"
    skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    skip_label.add_theme_font_size_override("font_size", 18)
    skip_label.add_theme_color_override("font_color", Color("#b8c6dd"))
    skip_label.anchor_left = 0.5
    skip_label.anchor_top = 1.0
    skip_label.anchor_right = 0.5
    skip_label.anchor_bottom = 1.0
    skip_label.offset_left = -220
    skip_label.offset_top = -72
    skip_label.offset_right = 220
    skip_label.offset_bottom = -35
    skip_label.modulate = Color(1, 1, 1, 0)
    add_child(skip_label)

    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

func _start_intro() -> void:
    var tween := create_tween()
    tween.set_parallel(true)

    tween.tween_property(line_top, "size:x", 220.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(line_bottom, "size:x", 220.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(glow, "modulate:a", 0.7, 0.9).from(0.0).set_trans(Tween.TRANS_SINE)
    tween.tween_property(logo, "modulate:a", 1.0, 0.75).set_delay(0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(logo, "scale", Vector2.ONE, 0.9).set_delay(0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(subtitle, "modulate:a", 1.0, 0.55).set_delay(0.75).set_trans(Tween.TRANS_SINE)
    tween.tween_property(skip_label, "modulate:a", 1.0, 0.45).set_delay(1.15).set_trans(Tween.TRANS_SINE)

    _play_tone(880.0, 0.10, 0.10, 0.15)
    await get_tree().create_timer(1.15).timeout
    if leaving:
        return
    _play_tone(1320.0, 0.16, 0.07, 0.2)

    var pulse := create_tween()
    pulse.set_loops()
    pulse.tween_property(skip_label, "modulate:a", 0.35, 0.75).set_trans(Tween.TRANS_SINE)
    pulse.tween_property(skip_label, "modulate:a", 1.0, 0.75).set_trans(Tween.TRANS_SINE)

    await get_tree().create_timer(intro_duration - 1.15).timeout
    if not leaving:
        _go_to_next_scene()

func _unhandled_input(event: InputEvent) -> void:
    if leaving:
        return
    if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
        _go_to_next_scene()

func _go_to_next_scene() -> void:
    if leaving:
        return
    leaving = true
    _play_tone(1760.0, 0.10, 0.08, 0.0)

    var tween := create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    await tween.finished

    if ResourceLoader.exists(next_scene):
        get_tree().change_scene_to_file(next_scene)
    else:
        get_tree().quit()

func _play_tone(frequency: float, duration: float, volume: float, delay: float) -> void:
    await get_tree().create_timer(delay).timeout
    if leaving and delay > 0.0:
        return

    var generator := AudioStreamGenerator.new()
    generator.mix_rate = 44100.0
    generator.buffer_length = max(duration + 0.05, 0.1)
    audio_player.stream = generator
    audio_player.volume_db = linear_to_db(clamp(volume, 0.001, 1.0))
    audio_player.play()

    var playback := audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
    if playback == null:
        return

    var frames := int(44100.0 * duration)
    var phase := 0.0
    var step := TAU * frequency / 44100.0
    for i in frames:
        var envelope := 1.0
        if i < 900:
            envelope = float(i) / 900.0
        elif i > frames - 1800:
            envelope = float(frames - i) / 1800.0
        envelope = clamp(envelope, 0.0, 1.0)
        var sample := sin(phase) * envelope * 0.32
        playback.push_frame(AudioFrame(sample, sample))
        phase += step

func _process(delta: float) -> void:
    if leaving:
        return
    glow.rotation = sin(Time.get_ticks_msec() * 0.00025) * 0.025
