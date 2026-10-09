class_name PainelMeta
extends CanvasLayer

var label_meta: Label
var label_aviso: Label

func _ready():
	if GameManager.modo != "meta":
		return

	label_meta = Label.new()
	label_meta.position = Vector2(20, 56)
	label_meta.add_theme_font_size_override("font_size", 24)
	label_meta.add_theme_color_override("font_color", Color("ffd978"))
	label_meta.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	label_meta.add_theme_constant_override("outline_size", 6)
	add_child(label_meta)

	label_aviso = Label.new()
	label_aviso.position = Vector2(0, 300)
	label_aviso.size = Vector2(get_viewport().get_visible_rect().size.x, 80)
	label_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_aviso.add_theme_font_size_override("font_size", 44)
	label_aviso.add_theme_color_override("font_color", Color.WHITE)
	label_aviso.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	label_aviso.add_theme_constant_override("outline_size", 10)
	label_aviso.modulate.a = 0.0
	add_child(label_aviso)

	GameManager.meta_mudou.connect(_atualizar)
	GameManager.meta_atingida.connect(_celebrar)
	_atualizar()

func _atualizar():
	label_meta.text = "Meta: %s\nJá pescou: %s" % [GameManager.texto_valor(GameManager.meta_valor), GameManager.texto_valor(GameManager.meta_acumulado)]

func _celebrar():
	label_aviso.text = "Meta atingida! +1 ponto"
	label_aviso.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.2)
	tw.tween_property(label_aviso, "modulate:a", 0.0, 0.8)
