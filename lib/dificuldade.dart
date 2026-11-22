enum Dificuldade {
  facil,
  media,
  dificil,
  bonus;

  int get pontos {
    switch (this) {
      case Dificuldade.facil:
        return 10;
      case Dificuldade.media:
        return 20;
      case Dificuldade.dificil:
        return 30;
      case Dificuldade.bonus:
        return 50;
    }
  }

  String get rotulo {
    switch (this) {
      case Dificuldade.facil:
        return 'Fácil';
      case Dificuldade.media:
        return 'Média';
      case Dificuldade.dificil:
        return 'Difícil';
      case Dificuldade.bonus:
        return 'Bônus';
    }
  }

  static Dificuldade deTexto(String texto) {
    switch (texto.toLowerCase()) {
      case 'facil':
        return Dificuldade.facil;
      case 'media':
        return Dificuldade.media;
      case 'dificil':
        return Dificuldade.dificil;
      case 'bonus':
        return Dificuldade.bonus;
      default:
        return Dificuldade.facil;
    }
  }
}