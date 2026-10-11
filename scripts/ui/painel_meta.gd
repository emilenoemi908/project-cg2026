class_name PainelMeta
extends CanvasLayer

var label_meta: Label
var label_aviso: Label

func _ready():
	if GameManager.modo != "meta":
		return

	label_meta = Label.new()
	EstiloUI.rotulo(label_meta, 24, Color("ffd978"), 4)
	EstiloUI.placa(self, label_meta, Vector2(20, 76))

	label_aviso = Label.new()
	label_aviso.position = Vector2(0, 300)
	label_aviso.size = Vector2(get_viewport().get_visible_rect().size.x, 80)
	label_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloUI.rotulo(label_aviso, 52, Color.WHITE, 12)
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
