extends Node

signal desafio_pronto

var peixes_pescaria_atual: Array = []
var pescaria_a: Dictionary = {}
var pescaria_b: Dictionary = {}
var tem_pescaria_a: bool = false

var operacao: String = ""
var resposta_correta: float = 0.0

var acertos: int = 0

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

	if not tem_pescaria_a:
		pescaria_a = pescaria
		tem_pescaria_a = true
		print("Pescaria 1: ", pescaria_a.quantidade, " peixes, ", pescaria_a.peso, " kg")
	else:
		pescaria_b = pescaria
		tem_pescaria_a = false
		gerar_desafio()

func gerar_desafio():
	operacao = "soma" if randi() % 2 == 0 else "subtracao"

	if operacao == "soma":
		resposta_correta = snappedf(pescaria_a.peso + pescaria_b.peso, 0.1)
	else:
		resposta_correta = snappedf(abs(pescaria_a.peso - pescaria_b.peso), 0.1)

	print("Desafio: ", pescaria_a.peso, " ", operacao, " ", pescaria_b.peso, " = ", resposta_correta)
	desafio_pronto.emit()

func verificar_resposta(valor_digitado: float) -> bool:
	var correto = abs(valor_digitado - resposta_correta) < 0.05
	if correto:
		acertos += 1
	return correto
