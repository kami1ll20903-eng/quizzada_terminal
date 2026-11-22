import 'jogador.dart';
import 'pergunta.dart';

class Partida {
  final List<Jogador> jogadores;
  final List<Pergunta> perguntas;

  Partida({required this.jogadores, required this.perguntas});

  int calcularTotalPossivelPorJogador(List<Pergunta> perguntasDoJogador) {
    return perguntasDoJogador.fold(
      0,
      (soma, pergunta) => soma + pergunta.dificuldade.pontos,
    );
  }

  List<Jogador> obterRanking() {
    final copia = List<Jogador>.from(jogadores);
    copia.sort((a, b) => b.pontos.compareTo(a.pontos));
    return copia;
  }
}
