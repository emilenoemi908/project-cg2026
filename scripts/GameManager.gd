extends Node

signal desafio_pronto
signal placar_mudou

var modo: String = "soma_subtracao"
const PESO_UNITARIO_MULTIPLICACAO = 0.5

var peixes_pescaria_atual: Array = []
var pescaria_a: Dictionary = {}
var pescaria_b: Dictionary = {}
var tem_pescaria_a: bool = false

var operacao: String = ""
var resposta_correta: float = 0.0
var acertos: int = 0

func reiniciar():
	peixes_pescaria_atual.clear()
	pescaria_a = {}
	pescaria_b = {}
	tem_pescaria_a = false
	acertos = 0
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
	else:
		processar_soma_subtracao(pescaria)

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

func gerar_desafio_multiplicacao(pescaria: Dictionary):
	operacao = "multiplicacao"
	pescaria_a = {"quantidade": pescaria.quantidade, "peso": PESO_UNITARIO_MULTIPLICACAO}
	resposta_correta = snappedf(pescaria.quantidade * PESO_UNITARIO_MULTIPLICACAO, 0.1)
	desafio_pronto.emit()

func verificar_resposta(valor_digitado: float) -> bool:
	var correto = abs(valor_digitado - resposta_correta) < 0.05
	if correto:
		acertos += 1
		placar_mudou.emit()
	return correto
