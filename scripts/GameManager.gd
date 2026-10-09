extends Node

signal desafio_pronto
signal placar_mudou
signal meta_mudou
signal meta_atingida

var modo: String = "soma_subtracao"
const PESO_UNITARIO_MULTIPLICACAO = 0.5

var peixes_pescaria_atual: Array = []
var pescaria_a: Dictionary = {}
var pescaria_b: Dictionary = {}
var tem_pescaria_a: bool = false

var operacao: String = ""
var resposta_correta: float = 0.0
var acertos: int = 0

# modo meta de pesca
var meta_tipo: String = "peso"
var meta_valor: float = 0.0
var meta_acumulado: float = 0.0
var desafio_acumulado: float = 0.0

# formato das opções de resposta
var resposta_inteira: bool = false
var passo_opcoes: float = 0.5

func reiniciar():
	peixes_pescaria_atual.clear()
	pescaria_a = {}
	pescaria_b = {}
	tem_pescaria_a = false
	acertos = 0
	resposta_inteira = false
	passo_opcoes = 0.5
	if modo == "meta":
		sortear_meta()
	placar_mudou.emit()

func registrar_peixe(quantidade: int, peso: float):
	peixes_pescaria_atual.append({"quantidade": quantidade, "peso": peso})

func finalizar_pescaria():
	if peixes_pescaria_atual.is_empty():
		return

	var total_quantidade = 0
	var total_peso = 0.0
	for peixe in peixes_pescaria_atual:
		total_quantidade += peixe.quantidade
		total_peso += peixe.peso
	total_peso = snappedf(total_peso, 0.1)

	var pescaria = {"quantidade": total_quantidade, "peso": total_peso}
	peixes_pescaria_atual.clear()

	if modo == "multiplicacao":
		gerar_desafio_multiplicacao(pescaria)
	elif modo == "meta":
		processar_meta(pescaria)
	else:
		processar_soma_subtracao(pescaria)

# ---------- soma e subtração ----------
func processar_soma_subtracao(pescaria: Dictionary):
	if not tem_pescaria_a:
		pescaria_a = pescaria
		tem_pescaria_a = true
	else:
		pescaria_b = pescaria
		tem_pescaria_a = false
		gerar_desafio_soma_subtracao()

func gerar_desafio_soma_subtracao():
	operacao = "soma" if randi() % 2 == 0 else "subtracao"
	if operacao == "soma":
		resposta_correta = snappedf(pescaria_a.peso + pescaria_b.peso, 0.1)
	else:
		if pescaria_a.peso < pescaria_b.peso:
			var troca = pescaria_a
			pescaria_a = pescaria_b
			pescaria_b = troca
		resposta_correta = snappedf(pescaria_a.peso - pescaria_b.peso, 0.1)
	desafio_pronto.emit()

# ---------- multiplicação ----------
func gerar_desafio_multiplicacao(pescaria: Dictionary):
	operacao = "multiplicacao"
	pescaria_a = {"quantidade": pescaria.quantidade, "peso": PESO_UNITARIO_MULTIPLICACAO}
	resposta_correta = snappedf(pescaria.quantidade * PESO_UNITARIO_MULTIPLICACAO, 0.1)
	desafio_pronto.emit()

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

func preparar_formato_meta():
	resposta_inteira = (meta_tipo == "quantidade")
	passo_opcoes = 1.0 if resposta_inteira else 0.5

func processar_meta(pescaria: Dictionary):
	var ganho = pescaria.peso if meta_tipo == "peso" else float(pescaria.quantidade)
	meta_acumulado += ganho
	meta_mudou.emit()

	if is_equal_approx(meta_acumulado, meta_valor):
		acertos += 1
		placar_mudou.emit()
		meta_atingida.emit()
		sortear_meta()
	elif meta_acumulado < meta_valor:
		operacao = "falta"
		desafio_acumulado = meta_acumulado
		resposta_correta = meta_valor - meta_acumulado
		preparar_formato_meta()
		desafio_pronto.emit()
	else:
		operacao = "excesso"
		desafio_acumulado = meta_acumulado
		resposta_correta = meta_acumulado - meta_valor
		preparar_formato_meta()
		meta_acumulado = 0.0
		meta_mudou.emit()
		desafio_pronto.emit()

# ---------- textos ----------
func texto_valor(v: float) -> String:
	if meta_tipo == "peso":
		return "%.1f kg" % v
	return "%d peixes" % int(round(v))

func texto_resposta(v: float) -> String:
	if resposta_inteira:
		return str(int(round(v)))
	return "%.1f" % v

func verificar_resposta(valor_digitado: float) -> bool:
	var correto = abs(valor_digitado - resposta_correta) < 0.05
	if correto:
		acertos += 1
		placar_mudou.emit()
	return correto
