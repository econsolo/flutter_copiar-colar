class Copiado {

  final int id;
  final String valor;
  final DateTime data;

  Copiado({this.id, this.valor, this.data});

  factory Copiado.fromJson(Map<String, dynamic> json) {
    return Copiado(
      id: json["id"],
      valor: json["valor"],
      data: json["data"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "valor": valor,
      "data": data
    };
  }
}