import 'dart:io';
import 'dart:math';

import 'package:quizzada_terminal/dados_perguntas.dart';
import 'package:quizzada_terminal/dificuldade.dart';
import 'package:quizzada_terminal/excecoes.dart';
import 'package:quizzada_terminal/jogador.dart';
import 'package:quizzada_terminal/partida.dart';
import 'package:quizzada_terminal/pergunta.dart';

String lerTextoNaoVazio(String prompt) {
  while (true) {
    stdout.write(prompt);
    final entrada = stdin.readLineSync();
    final textoLimpo = entrada?.trim() ?? '';
    if (textoLimpo.isNotEmpty) {
      return textoLimpo;
    }
    print('Aviso: A entrada não pode ser vazia. Tente novamente.');
  }
}

int lerNumeroJogadores() {
  while (true) {
    final entrada = lerTextoNaoVazio('Quantos jogadores vão participar (1, 2 ou 3)? ');
    final numero = int.tryParse(entrada);
    if (numero != null && (numero >= 1 && numero <= 3)) {
      return numero;
    }
    print('Aviso: Digite apenas 1, 2 ou 3.');
  }
}

List<Jogador> cadastrarJogadores(int quantidade) {
  final jogadores = <Jogador>[];
  for (var i = 1; i <= quantidade; i++) {
    while (true) {
      final nome = lerTextoNaoVazio('Nome do Jogador $i: ');
      final nomeJaExiste = jogadores.any(
        (j) => j.nome.toLowerCase() == nome.toLowerCase(),
      );
      if (nomeJaExiste) {
        print('Aviso: Esse nome já foi escolhido por outro jogador. Digite um nome diferente.');
      } else {
        jogadores.add(Jogador(nome: nome));
        break;
      }
    }
  }
  return jogadores;
}

String escolherTema() {
  const temas = [
    'Engenharia de Controle e Automação',
    'Engenharia de Computação',
    'Engenharia Elétrica',
    'Engenharia Mecânica',
  ];

  print('\nEscolha o tema das perguntas:');
  for (var i = 0; i < temas.length; i++) {
    print('  ${i + 1}) ${temas[i]}');
  }

  while (true) {
    final entrada = lerTextoNaoVazio('Digite o número do tema (1 a 4): ');
    final opcao = int.tryParse(entrada);
    if (opcao != null && opcao >= 1 && opcao <= temas.length) {
      return temas[opcao - 1];
    }
    print('Aviso: Opção inválida. Escolha um número entre 1 e 4.');
  }
}

int validarRespostaLetra(String? entrada) {
  final limpo = entrada?.trim().toUpperCase() ?? '';
  if (limpo.isEmpty) {
    throw RespostaInvalidaException('Aviso: Digite uma letra.');
  }
  if (limpo.length > 1) {
    throw RespostaInvalidaException('Aviso: Digite apenas uma letra (A, B, C ou D).');
  }
  const letrasValidas = ['A', 'B', 'C', 'D'];
  final indice = letrasValidas.indexOf(limpo);
  if (indice == -1) {
    throw RespostaInvalidaException('Aviso: "$limpo" não é uma alternativa. Use A, B, C, D.');
  }
  return indice;
}

int lerRespostaAlternativa() {
  while (true) {
    stdout.write('Sua resposta (A, B, C ou D): ');
    final entrada = stdin.readLineSync();
    try {
      return validarRespostaLetra(entrada);
    } on RespostaInvalidaException catch (e) {
      print(e.mensagem);
    }
  }
}

void exibirPergunta(Pergunta pergunta, int numeroAtual, int total) {
  const letras = ['A', 'B', 'C', 'D'];
  print('\nPergunta $numeroAtual/$total (${pergunta.dificuldade.rotulo}, ${pergunta.dificuldade.pontos} pts)');
  print(pergunta.texto);
  for (var i = 0; i < pergunta.alternativas.length; i++) {
    print('  ${letras[i]}) ${pergunta.alternativas[i]}');
  }
}

List<Pergunta> sortearPerguntasPorJogador(
  List<Pergunta> todasDoTema,
  Random random,
) {
  final faceis = todasDoTema.where((p) => p.dificuldade == Dificuldade.facil).toList()
    ..shuffle(random);
  final medias = todasDoTema.where((p) => p.dificuldade == Dificuldade.media).toList()
    ..shuffle(random);
  final dificeis = todasDoTema.where((p) => p.dificuldade == Dificuldade.dificil).toList()
    ..shuffle(random);

  return [
    ...faceis.take(2),
    ...medias.take(2),
    ...dificeis.take(2),
  ];
}

void executarRodadaBonus(List<Jogador> empatados, List<Pergunta> perguntasBonus) {
  if (perguntasBonus.isEmpty) return;

  print('\n=== RODADA BÔNUS DE DESEMPATE (50 pts) ===');
  print('Jogadores empatados:');
  for (var i = 0; i < empatados.length; i++) {
    print('  ${i + 1}) ${empatados[i].nome}');
  }

  final pergunta = perguntasBonus.first;
  exibirPergunta(pergunta, 1, 1);

  final jaTentaram = <int>{};
  const letras = ['A', 'B', 'C', 'D'];

  while (jaTentaram.length < empatados.length) {
    int numeroEscolhido;
    while (true) {
      final entrada = lerTextoNaoVazio(
        '\nDigite o número do jogador que vai responder (1 a ${empatados.length}): ',
      );
      final parsed = int.tryParse(entrada);
      if (parsed == null || parsed < 1 || parsed > empatados.length) {
        print('Aviso: Número de jogador inválido.');
        continue;
      }
      if (jaTentaram.contains(parsed)) {
        print('Aviso: ${empatados[parsed - 1].nome} já respondeu esta pergunta!');
        continue;
      }
      numeroEscolhido = parsed;
      break;
    }

    jaTentaram.add(numeroEscolhido);
    final jogadorAtual = empatados[numeroEscolhido - 1];
    print('Vez de ${jogadorAtual.nome}:');
    final resposta = lerRespostaAlternativa();

    if (resposta == pergunta.indiceCorreta) {
      jogadorAtual.pontos += pergunta.dificuldade.pontos;
      jogadorAtual.acertos += 1;
      print('Acertou! ${jogadorAtual.nome} ganhou +${pergunta.dificuldade.pontos} pontos!');
      return;
    } else {
      print('Errou! Passando a chance para os demais...');
    }
  }

  print(
    'Ninguém acertou a pergunta bônus! A resposta certa era: '
    '${letras[pergunta.indiceCorreta]}) ${pergunta.alternativas[pergunta.indiceCorreta]}',
  );
}

void main() {
  print('=== BEM-VINDO AO QUIZZADA TERMINAL ===\n');

  final qtdJogadores = lerNumeroJogadores();
  final jogadores = cadastrarJogadores(qtdJogadores);
  final temaEscolhido = escolherTema();

  final random = Random();
  final todasPerguntas = dadosPerguntas.map((map) => Pergunta.fromMap(map)).toList();

  final perguntasDoTema = todasPerguntas
      .where((p) => p.tema == temaEscolhido && p.dificuldade != Dificuldade.bonus)
      .toList();

  // Separa 6 perguntas exclusivas (2 fáceis, 2 médias, 2 difíceis) para cada jogador
  final perguntasPorJogador = <Jogador, List<Pergunta>>{};
  final perguntasUsadas = <Pergunta>{};

  for (final jogador in jogadores) {
    final disponiveis = perguntasDoTema.where((p) => !perguntasUsadas.contains(p)).toList();
    final sorteadas = sortearPerguntasPorJogador(disponiveis, random);
    perguntasUsadas.addAll(sorteadas);
    perguntasPorJogador[jogador] = sorteadas;
  }

  final partida = Partida(
    jogadores: jogadores,
    perguntas: perguntasUsadas.toList(),
  );

  const letras = ['A', 'B', 'C', 'D'];

  // Loop de turnos: cada jogador responde suas próprias perguntas
  for (var rodada = 0; rodada < 6; rodada++) {
    for (final jogador in jogadores) {
      final listaDoJogador = perguntasPorJogador[jogador] ?? <Pergunta>[];
      if (rodada >= listaDoJogador.length) continue;

      final pergunta = listaDoJogador[rodada];
      print('\n----------------------------------------');
      print('Vez de: ${jogador.nome}');
      exibirPergunta(pergunta, rodada + 1, listaDoJogador.length);

      final indiceResposta = lerRespostaAlternativa();
      if (indiceResposta == pergunta.indiceCorreta) {
        final ganhos = pergunta.dificuldade.pontos;
        jogador.pontos += ganhos;
        jogador.acertos += 1;
        print('Acertou! +$ganhos pontos');
      } else {
        print(
          'Errou! A resposta certa era ${letras[pergunta.indiceCorreta]}) '
          '${pergunta.alternativas[pergunta.indiceCorreta]}',
        );
      }
    }
  }

  // Verifica se houve empate na liderança (com mais de 1 jogador)
  if (jogadores.length > 1) {
    final rankingParcial = partida.obterRanking();
    final maiorPontuacao = rankingParcial.first.pontos;
    final empatados = rankingParcial.where((j) => j.pontos == maiorPontuacao).toList();

    if (empatados.length > 1) {
      print('\nHouve empate com $maiorPontuacao pontos!');
      final desejaBonus = lerTextoNaoVazio('Desejam jogar a pergunta bônus de 50 pts? (S/N): ');
      if (desejaBonus.toUpperCase() == 'S') {
        final bonusDisponiveis = todasPerguntas
            .where((p) => p.dificuldade == Dificuldade.bonus)
            .toList()
          ..shuffle(random);
        executarRodadaBonus(empatados, bonusDisponiveis);
      }
    }
  }

  // Placar final ordenado (Ranking)
  print('\n================ PLACAR FINAL ================');
  final rankingFinal = partida.obterRanking();
  for (var i = 0; i < rankingFinal.length; i++) {
    final jogador = rankingFinal[i];
    final perguntasDele = perguntasPorJogador[jogador] ?? <Pergunta>[];
    final totalPossivel = partida.calcularTotalPossivelPorJogador(perguntasDele);
    print(
      '${i + 1}º ${jogador.nome}: ${jogador.pontos}/$totalPossivel pontos '
      '(${jogador.acertos}/${perguntasDele.length} acertos)',
    );
  }
}