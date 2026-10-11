class_name PainelTarrafa
extends CanvasLayer

var label_tarrafa: Label
var label_primeira: Label
var label_rodada: Label

func _ready():
	label_tarrafa = _novo_label(22, Vector2(20, 520), Color.WHITE)
	label_primeira = _novo_label(22, Vector2(20, 462), Color("ffd978"))
	label_rodada = _novo_label(24, Vector2(20, 76), Color("ffd978"))
	GameManager.pescaria_mudou.connect(_atualizar)
	GameManager.rodada_mudou.connect(_atualizar)
	_atualizar()

func _novo_label(tamanho: int, pos: Vector2, cor: Color) -> Label:
	var l := Label.new()
	EstiloUI.rotulo(l, tamanho, cor, 4)
	EstiloUI.placa(self, l, pos)
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
