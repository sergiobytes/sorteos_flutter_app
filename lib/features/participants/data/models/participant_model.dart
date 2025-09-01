import '../../domain/entities/participant_entity.dart';

class ParticipantModel extends ParticipantEntity {
  const ParticipantModel({
    super.id,
    required super.nombre,
    required super.telefono,
    required super.cedula,
    required super.boletos,
    required super.pagado,
    super.comprobante,
    super.fechaCreacion,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'] ?? '',
      cedula: json['cedula'] ?? '',
      boletos: json['boletos'] ?? 0,
      pagado: json['pagado'] ?? false,
      comprobante: json['comprobante'],
      fechaCreacion:
          json['fecha_creacion'] != null
              ? DateTime.parse(json['fecha_creacion'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'cedula': cedula,
      'boletos': boletos,
      'pagado': pagado,
      'comprobante': comprobante,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }
}
