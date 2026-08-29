extends Control

@export_file("*.tscn") var next_scene: String = "res://scenes/MainMenu.tscn"
@export var video_path: String = "res://assets/videos/intro.ogv"
@export var fade_duration: float = 0.45

var video: VideoStreamPlayer
var fade: ColorRect
var skip_label: Label
var finished := false

func _ready() -> void:
    _build_ui()
    _start_video()

func _build_ui() -> void:
    video = VideoStreamPlayer.new()
    video.name = "IntroVideo"
    video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    video.expand = true
    video.autoplay = false
    video.loop = false
    video.finished.connect(_on_video_finished)
    add_child(video)

    skip_label = Label.new()
    skip_label.text = "PRESS ENTER TO SKIP"
    skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    skip_label.add_theme_font_size_override("font_size", 18)
    skip_label.add_theme_color_override("font_color", Color("#d7e5ff"))
    skip_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
    skip_label.add_theme_constant_override("shadow_offset_x", 2)
    skip_label.add_theme_constant_override("shadow_offset_y", 2)
    skip_label.anchor_left = 0.5
    skip_label.anchor_top = 1.0
    skip_label.anchor_right = 0.5
    skip_label.anchor_bottom = 1.0
    skip_label.offset_left = -220
    skip_label.offset_top = -72
    skip_label.offset_right = 220
    skip_label.offset_bottom = -35
    skip_label.modulate.a = 0.0
    add_child(skip_label)

    fade = ColorRect.new()
    fade.color = Color.BLACK
    fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fade.modulate.a = 1.0
    add_child(fade)

func _start_video() -> void:
    if not ResourceLoader.exists(video_path):
        push_warning("Intro video not found: " + video_path)
        _finish_intro()
        return

    var stream = load(video_path)
    if stream == null or not (stream is VideoStream):
        push_warning("Invalid intro video: " + video_path)
        _finish_intro()
        return

    video.stream = stream
    video.play()

    var intro_tween := create_tween()
    intro_tween.tween_property(fade, "modulate:a", 0.0, fade_duration)
    intro_tween.parallel().tween_property(skip_label, "modulate:a", 1.0, 0.4).set_delay(0.5)

    var pulse := create_tween()
    pulse.set_loops()
    pulse.tween_property(skip_label, "modulate:a", 0.35, 0.8).set_trans(Tween.TRANS_SINE)
    pulse.tween_property(skip_label, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
    if finished:
        return

    if event.is_action_pressed("ui_accept"):
        _finish_intro()
        get_viewport().set_input_as_handled()

func _on_video_finished() -> void:
    _finish_intro()

func _finish_intro() -> void:
    if finished:
        return
    finished = true

    if video != null:
        video.stop()

    var tween := create_tween()
    tween.tween_property(fade, "modulate:a", 1.0, fade_duration)
    tween.tween_callback(_change_scene)

func _change_scene() -> void:
    if ResourceLoader.exists(next_scene):
        get_tree().change_scene_to_file(next_scene)
    else:
        push_error("Main menu scene not found: " + next_scene)
