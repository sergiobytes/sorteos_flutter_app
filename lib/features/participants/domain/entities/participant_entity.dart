class ParticipantEntity {
  final int? id;
  final String nombre;
  final String telefono;
  final String cedula;
  final int boletos;
  final bool pagado;
  final String? comprobante;
  final DateTime? fechaCreacion;

  const ParticipantEntity({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.cedula,
    required this.boletos,
    required this.pagado,
    this.comprobante,
    this.fechaCreacion,
  });
}
