extends Node

signal desafio_pronto
signal placar_mudou
signal meta_mudou
signal meta_atingida
signal pescaria_mudou
signal rodada_mudou
signal acerto_feito
signal ultimo_respondido

const LIMITE_DESAFIOS := 8

var modo: String = "soma_subtracao"

# Os pesos são DIDÁTICOS (múltiplos de 0,5 kg), escolhidos para facilitar as contas.
var especies: Array = [
	{"nome": "Tainha", "plural": "tainhas", "pesos": [1.0, 1.5, 2.0], "cor": Color("9aa7ad"), "nadadeira": Color("6f7b82"), "comp": 1.15, "alt": 1.0, "linha": false, "barbilhoes": false},
	{"nome": "Curimã", "plural": "curimãs", "pesos": [0.5, 1.0], "cor": Color("aab5a6"), "nadadeira": Color("d8c46a"), "comp": 1.0, "alt": 1.0, "linha": false, "barbilhoes": false},
	{"nome": "Carapeba", "plural": "carapebas", "pesos": [0.5, 1.0], "cor": Color("c5ccd0"), "nadadeira": Color("e0c35a"), "comp": 0.9, "alt": 1.3, "linha": false, "barbilhoes": false},
	{"nome": "Camurim", "plural": "camurins", "pesos": [1.5, 2.0, 2.5], "cor": Color("cfcf9e"), "nadadeira": Color("a8a574"), "comp": 1.3, "alt": 0.85, "linha": true, "barbilhoes": false},
	{"nome": "Mandim", "plural": "mandins", "pesos": [0.5], "cor": Color("6b6258"), "nadadeira": Color("4d463f"), "comp": 0.9, "alt": 0.8, "linha": false, "barbilhoes": true},
]

# multiplicação: numa rodada todos os peixes são da mesma espécie e pesam o mesmo
var especie_rodada: Dictionary = {}
var peso_rodada: float = 1.0

var peixes_pescaria_atual: Array = []
var pescaria_a: Dictionary = {}
var pescaria_b: Dictionary = {}
var tem_pescaria_a: bool = false

var operacao: String = ""
var resposta_correta: float = 0.0
var unidade_resposta: String = "kg"
var passo_opcoes: float = 0.5
var erro_tipico: float = -1.0
var enunciado: String = ""
var explicacao: String = ""

var acertos: int = 0
var acertos_perguntas: int = 0
var respondidos: int = 0
var acabou: bool = false

# meta de pesca
var meta_tipo: String = "peso"
var meta_valor: float = 0.0
var meta_acumulado: float = 0.0

# ---------- formatação ----------
func fmt_kg(v: float) -> String:
	return ("%.1f" % v).replace(".", ",") + " kg"

func fmt_peixes(n: int) -> String:
	if n == 1:
		return "1 peixe"
	return "%d peixes" % n

func texto_valor(v: float) -> String:
	if meta_tipo == "peso":
		return fmt_kg(v)
	return fmt_peixes(int(round(v)))

func texto_opcao(v: float) -> String:
	if unidade_resposta == "peixes":
		return fmt_peixes(int(round(v)))
	if unidade_resposta == "kg_int":
		return "%d kg" % int(round(v))
	return fmt_kg(v)

# ---------- início ----------
func reiniciar():
	peixes_pescaria_atual.clear()
	pescaria_a = {}
	pescaria_b = {}
	tem_pescaria_a = false
	acertos = 0
	acertos_perguntas = 0
	respondidos = 0
	acabou = false
	enunciado = ""
	explicacao = ""
	
	if modo == "multiplicacao":
		_nova_rodada(false)
	elif modo == "meta":
		sortear_meta()
		
	placar_mudou.emit()

# ---------- espécies ----------
func sortear_especie() -> Dictionary:
	if modo == "multiplicacao":
		if especie_rodada.is_empty():
			_nova_rodada(false)
		return especie_rodada
	return especies.pick_random()

func peso_para(esp: Dictionary) -> float:
	if modo == "multiplicacao":
		return peso_rodada
	return float(esp["pesos"].pick_random())

func _nova_rodada(avisar: bool = true):
	especie_rodada = especies.pick_random()
	peso_rodada = float(especie_rodada["pesos"].pick_random())
	if avisar:
		rodada_mudou.emit()

# ---------- pescaria ----------
func registrar_peixe(nome: String, peso: float):
	peixes_pescaria_atual.append({"nome": nome, "peso": peso})
	pescaria_mudou.emit()

func finalizar_pescaria():
	if peixes_pescaria_atual.is_empty():
		return
		
	# Fixa a espécie usável atual no momento da captura
	var especie_usada = especie_rodada if modo == "multiplicacao" and not especie_rodada.is_empty() else especies[0]
	
	var total_peso := 0.0
	for p in peixes_pescaria_atual:
		total_peso += float(p["peso"])
		
	var pescaria := {
		"quantidade": peixes_pescaria_atual.size(), 
		"peso": snappedf(total_peso, 0.1),
		"especie_nome": especie_usada.get("nome", "Peixe"),
		"especie_plural": especie_usada.get("plural", "peixes")
	}
	
	peixes_pescaria_atual.clear()
	pescaria_mudou.emit()

	if modo == "multiplicacao":
		_gerar_multiplicacao(pescaria)
	elif modo == "meta":
		_processar_meta(pescaria)
	else:
		_processar_soma_subtracao(pescaria)

# ---------- soma e subtração ----------
func _processar_soma_subtracao(pescaria: Dictionary):
	if not tem_pescaria_a:
		pescaria_a = pescaria
		tem_pescaria_a = true
		pescaria_mudou.emit()
	else:
		pescaria_b = pescaria
		tem_pescaria_a = false
		_gerar_soma_subtracao()
		pescaria_mudou.emit()

func _gerar_soma_subtracao():
	unidade_resposta = "kg"
	passo_opcoes = 0.5
	var a: float = pescaria_a["peso"]
	var b: float = pescaria_b["peso"]
	if randi() % 2 == 0:
		operacao = "soma"
		resposta_correta = snappedf(a + b, 0.1)
		erro_tipico = snappedf(absf(a - b), 0.1)
		enunciado = "Na 1ª tarrafa você pescou %s e na 2ª, %s.\nQuantos quilos pescou ao todo?" % [fmt_kg(a), fmt_kg(b)]
		explicacao = "%s + %s = %s" % [fmt_kg(a), fmt_kg(b), fmt_kg(resposta_correta)]
	else:
		operacao = "subtracao"
		var maior := maxf(a, b)
		var menor := minf(a, b)
		resposta_correta = snappedf(maior - menor, 0.1)
		erro_tipico = snappedf(a + b, 0.1)
		enunciado = "A 1ª tarrafa trouxe %s e a 2ª, %s.\nQual é a diferença, em quilos, entre as duas?" % [fmt_kg(a), fmt_kg(b)]
		explicacao = "%s - %s = %s" % [fmt_kg(maior), fmt_kg(menor), fmt_kg(resposta_correta)]
	desafio_pronto.emit()

# ---------- multiplicação ----------
func _gerar_multiplicacao(pescaria: Dictionary):
	unidade_resposta = "kg"
	passo_opcoes = 0.5
	var n: int = pescaria["quantidade"]
	var p: float = peso_rodada
	var nome: String = String(especie_rodada["plural"])
	if n == 1:
		nome = String(especie_rodada["nome"]).to_lower()
	operacao = "multiplicacao"
	resposta_correta = snappedf(n * p, 0.1)
	erro_tipico = snappedf(n + p, 0.1)
	enunciado = "Você pescou %d %s. Cada peixe pesa %s.\nQuantos quilos pescou ao todo?" % [n, nome, fmt_kg(p)]
	explicacao = "%d x %s = %s" % [n, fmt_kg(p), fmt_kg(resposta_correta)]
	desafio_pronto.emit()
	_nova_rodada()

# ---------- meta de pesca ----------
func sortear_meta():
	meta_acumulado = 0.0
	if randi() % 2 == 0:
		meta_tipo = "peso"
		meta_valor = float(randi_range(8, 16)) * 0.5
	else:
		meta_tipo = "quantidade"
		meta_valor = float(randi_range(6, 12))
	meta_mudou.emit()

func _formato_meta():
	if meta_tipo == "quantidade":
		unidade_resposta = "peixes"
		passo_opcoes = 1.0
	else:
		unidade_resposta = "kg"
		passo_opcoes = 0.5

func _processar_meta(pescaria: Dictionary):
	var ganho: float = float(pescaria["quantidade"])
	if meta_tipo == "peso":
		ganho = pescaria["peso"]
	meta_acumulado += ganho
	meta_mudou.emit()

	if is_equal_approx(meta_acumulado, meta_valor):
		acertos += 1
		placar_mudou.emit()
		meta_atingida.emit()
		sortear_meta()
	elif meta_acumulado < meta_valor:
		operacao = "falta"
		_formato_meta()
		resposta_correta = meta_valor - meta_acumulado
		erro_tipico = meta_acumulado
		enunciado = "Meta do dia: %s.\nVocê já pescou %s.\nQuanto falta para a meta?" % [texto_valor(meta_valor), texto_valor(meta_acumulado)]
		explicacao = "%s - %s = %s" % [texto_valor(meta_valor), texto_valor(meta_acumulado), texto_valor(resposta_correta)]
		desafio_pronto.emit()
	else:
		operacao = "excesso"
		_formato_meta()
		resposta_correta = meta_acumulado - meta_valor
		erro_tipico = meta_valor
		enunciado = "Meta do dia: %s.\nVocê pescou %s e passou da meta.\nQuanto passou?" % [texto_valor(meta_valor), texto_valor(meta_acumulado)]
		explicacao = "%s - %s = %s" % [texto_valor(meta_acumulado), texto_valor(meta_valor), texto_valor(resposta_correta)]
		# Dica de correção de furo anterior: se desejar resetar o acumulado somente após responder, 
		# você pode mover essa linha para o método de verificação, ou mantê-la aqui se o fluxo exigir.
		meta_acumulado = 0.0
		meta_mudou.emit()
		desafio_pronto.emit()

# ---------- opções de resposta ----------
func gerar_opcoes() -> Array:
	var distratores: Array = []
	if erro_tipico >= 0.0 and not is_equal_approx(erro_tipico, resposta_correta):
		distratores.append(erro_tipico)
	
	var candidatas: Array = []
	for k in range(1, 5):
		candidatas.append(snappedf(resposta_correta + k * passo_opcoes, 0.1))
		var abaixo := snappedf(resposta_correta - k * passo_opcoes, 0.1)
		if abaixo >= 0.0:
			candidatas.append(abaixo)
	candidatas.shuffle()
	
	for c in candidatas:
		if distratores.size() >= 2:
			break
		var repetido := false
		for d in distratores:
			if is_equal_approx(d, c):
				repetido = true
		if not repetido:
			distratores.append(c)
			
	# Proteção caso faltem distratores (evita crash de índice)
	while distratores.size() < 2:
		distratores.append(snappedf(resposta_correta + (distratores.size() + 1) * passo_opcoes, 0.1))

	var lista: Array = [resposta_correta, distratores[0], distratores[1]]
	lista.shuffle()
	return lista

func verificar_resposta(valor: float) -> bool:
	var correto := is_equal_approx(valor, resposta_correta)
	respondidos += 1
	if correto:
		acertos += 1
		acertos_perguntas += 1
		acerto_feito.emit()
	placar_mudou.emit()
	if respondidos >= LIMITE_DESAFIOS and not acabou:
		acabou = true
		ultimo_respondido.emit()
	return correto
