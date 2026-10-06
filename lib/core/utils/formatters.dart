/// Formata pontuações: inteiro quando for exato (65) e uma casa decimal
/// com vírgula quando for média (68,4).
String formatarPontos(double valor) {
  if (valor == valor.roundToDouble()) return valor.toInt().toString();
  return valor.toStringAsFixed(1).replaceAll('.', ',');
}
