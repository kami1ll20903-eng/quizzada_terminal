import 'dificuldade.dart';

class Pergunta {
  final String tema;
  final String texto;
  final List<String> alternativas;
  final int indiceCorreta;
  final Dificuldade dificuldade;

  Pergunta({
    required this.tema,
    required this.texto,
    required this.alternativas,
    required this.indiceCorreta,
    required this.dificuldade,
  });

  factory Pergunta.fromMap(Map<String, dynamic> map) {
    final alternativasList = map['alternativas'];
    final alternativasConvertidas = alternativasList is List
        ? alternativasList.map((e) => e.toString()).toList()
        : <String>[];

    return Pergunta(
      tema: map['tema']?.toString() ?? '',
      texto: map['texto']?.toString() ?? '',
      alternativas: alternativasConvertidas,
      indiceCorreta: map['indiceCorreta'] is int ? map['indiceCorreta'] as int : 0,
      dificuldade: Dificuldade.deTexto(map['dificuldade']?.toString() ?? 'facil'),
    );
  }
}