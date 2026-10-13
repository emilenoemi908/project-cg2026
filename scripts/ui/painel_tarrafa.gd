class_name PainelTarrafa
extends CanvasLayer

var label_tarrafa: Label
var label_primeira: Label
var label_rodada: Label
var placa_tarrafa: Control
var placa_primeira: Control

func _ready():
	label_tarrafa = _novo_label(20, Vector2(20, 480), Color.WHITE)
	label_primeira = _novo_label(20, Vector2(20, 422), Color("ffd978"))
	label_rodada = _novo_label(24, Vector2(20, 76), Color("ffd978"))
	placa_tarrafa = label_tarrafa.get_parent()
	placa_primeira = label_primeira.get_parent()
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
	
	var linhas_extras := 0
	if n == 0:
		label_tarrafa.text = "Na tarrafa: vazia"
	else:
		var partes := []
		var linha_atual := []
		for i in range(itens.size()):
			linha_atual.append(itens[i])
			if linha_atual.size() == 3 or i == itens.size() - 1:
				partes.append(" + ".join(linha_atual))
				linha_atual = []
		
		linhas_extras = partes.size() - 1
		var texto_formatado = "\n".join(partes)
		label_tarrafa.text = "Na tarrafa: %s\n%s" % [GameManager.fmt_peixes(n), texto_formatado]

	var deslocamento := minf(linhas_extras * 28.0, 60.0)
	placa_tarrafa.position.y = 480.0 - deslocamento
	placa_primeira.position.y = 422.0 - deslocamento

	label_primeira.visible = GameManager.modo == "soma_subtracao" and GameManager.tem_pescaria_a
	if label_primeira.visible:
		label_primeira.text = "1ª tarrafa: %s" % GameManager.fmt_kg(GameManager.pescaria_a["peso"])

	label_rodada.visible = GameManager.modo == "multiplicacao" and not GameManager.especie_rodada.is_empty()
	if label_rodada.visible:
		label_rodada.text = "Hoje: %s de %s cada" % [GameManager.especie_rodada["plural"], GameManager.fmt_kg(GameManager.peso_rodada)]
