/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: triggers/TR_AnularOrden.sql
    Alcance: trigger TR_AnularOrden (INSTEAD OF DELETE en OrdenesReparacion)

    Se ejecuta EN LUGAR DE un DELETE sobre las ordenes.
    - Orden con pagos registrados: no se borra, pasa a estado 'Anulado' para
      no perder el historial de pagos.
    - Orden sin pagos: se borra de verdad. Antes se borran lo que depende de
      ella (detalle e historial) y los repuestos usados vuelven al stock.

    La tabla deleted tiene las ordenes que el DELETE queria borrar. Como el
    trigger reemplaza al DELETE, si no hace nada la orden queda intacta.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE TRIGGER dbo.TR_AnularOrden
ON dbo.OrdenesReparacion
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Ordenes con pagos: baja logica.
    UPDATE o
    SET o.estado = 'Anulado'
    FROM dbo.OrdenesReparacion o
        INNER JOIN deleted d ON d.idOrden = o.idOrden
    WHERE EXISTS (SELECT 1 FROM dbo.Pagos p WHERE p.idOrden = d.idOrden)
        AND o.estado <> 'Anulado';

    -- Ordenes sin pagos: los repuestos usados vuelven al stock...
    UPDATE r
    SET r.stock = r.stock + u.cantidad
    FROM dbo.Repuestos r
        INNER JOIN
            (
                SELECT dr.idRepuesto, SUM(dr.cantidad) AS cantidad
                FROM dbo.DetalleReparacion dr
                    INNER JOIN deleted d ON d.idOrden = dr.idOrden
                WHERE NOT EXISTS (SELECT 1 FROM dbo.Pagos p WHERE p.idOrden = d.idOrden)
                GROUP BY dr.idRepuesto
            ) u
            ON u.idRepuesto = r.idRepuesto;

    -- ... se borran el detalle y el historial (tienen FK hacia la orden) ...
    DELETE dr
    FROM dbo.DetalleReparacion dr
        INNER JOIN deleted d ON d.idOrden = dr.idOrden
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Pagos p WHERE p.idOrden = d.idOrden);

    DELETE h
    FROM dbo.HistorialEstados h
        INNER JOIN deleted d ON d.idOrden = h.idOrden
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Pagos p WHERE p.idOrden = d.idOrden);

    -- ... y por ultimo la orden.
    DELETE o
    FROM dbo.OrdenesReparacion o
        INNER JOIN deleted d ON d.idOrden = o.idOrden
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Pagos p WHERE p.idOrden = d.idOrden);
END
GO
