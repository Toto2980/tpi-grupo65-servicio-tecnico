/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: vistas/VW_SaldoOrdenes.sql
    Alcance: vista VW_SaldoOrdenes

    Informacion economica de cada orden: mano de obra, repuestos, total de la
    orden, total pagado y saldo pendiente. Usa SUM e ISNULL para que las ordenes
    sin repuestos o sin pagos aparezcan igual, con 0.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE VIEW VW_SaldoOrdenes
AS
SELECT
    o.idOrden,
    o.manoObra,
    ISNULL(d.totalRepuestos, 0) AS totalRepuestos,
    o.manoObra + ISNULL(d.totalRepuestos, 0) AS totalOrden,
    ISNULL(p.totalPagado, 0) AS totalPagado,
    o.manoObra + ISNULL(d.totalRepuestos, 0)
        - ISNULL(p.totalPagado, 0) AS saldoPendiente
FROM OrdenesReparacion o

LEFT JOIN (
    SELECT
        idOrden,
        SUM(cantidad * precioUnitario) AS totalRepuestos
    FROM DetalleReparacion
    GROUP BY idOrden
) d ON o.idOrden = d.idOrden

LEFT JOIN (
    SELECT
        idOrden,
        SUM(monto) AS totalPagado
    FROM Pagos
    GROUP BY idOrden
) p ON o.idOrden = p.idOrden;
GO
