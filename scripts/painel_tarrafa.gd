class_name PainelTarrafa
extends CanvasLayer

var label_tarrafa: Label
var label_primeira: Label
var label_rodada: Label

func _ready():
	label_tarrafa = _criar_label(Vector2(20, 520), 22)
	label_primeira = _criar_label(Vector2(20, 486), 22)
	label_rodada = _criar_label(Vector2(20, 56), 24)
	label_rodada.add_theme_color_override("font_color", Color("ffd978"))
	GameManager.pescaria_mudou.connect(_atualizar)
	GameManager.rodada_mudou.connect(_atualizar)
	_atualizar()

func _criar_label(pos: Vector2, tam: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color("2d1b0e"))
	l.add_theme_constant_override("outline_size", 6)
	add_child(l)
	return l

func _atualizar():
	var itens := PackedStringArray()
	for p in GameManager.peixes_pescaria_atual:
		itens.append("%s %s" % [p["nome"], GameManager.fmt_kg(p["peso"])])
	var n: int = GameManager.peixes_pescaria_atual.size()
	if n == 0:
		label_tarrafa.text = "Na tarrafa: vazia"
	else:
		label_tarrafa.text = "Na tarrafa: %s\n%s" % [GameManager.fmt_peixes(n), " + ".join(itens)]

	label_primeira.visible = GameManager.modo == "soma_subtracao" and GameManager.tem_pescaria_a
	if label_primeira.visible:
		label_primeira.text = "1ª tarrafa: %s" % GameManager.fmt_kg(GameManager.pescaria_a["peso"])

	label_rodada.visible = GameManager.modo == "multiplicacao" and not GameManager.especie_rodada.is_empty()
	if label_rodada.visible:
		label_rodada.text = "Hoje: %s de %s cada" % [GameManager.especie_rodada["plural"], GameManager.fmt_kg(GameManager.peso_rodada)]
