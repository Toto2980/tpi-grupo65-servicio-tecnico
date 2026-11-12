/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: procedimientos/SP_ReporteTecnico.sql
    Alcance: procedimiento de reporte SP_ReporteTecnico

    Recibe un rango de fechas y devuelve, por tecnico:
    - ordenesAtendidas: ordenes ingresadas en el rango, sin contar las anuladas
    - ordenesEntregadas: cuantas de esas ordenes ya se entregaron
    - totalFacturado: mano de obra + repuestos de las ordenes entregadas

    El rango se aplica sobre la fecha de ingreso de la orden.
    Los tecnicos sin ordenes en el rango aparecen igual, con valores en 0.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE PROCEDURE dbo.SP_ReporteTecnico
    (
        @fechaDesde DATE,
        @fechaHasta DATE
    )
AS
BEGIN
    IF @fechaDesde > @fechaHasta
    BEGIN
        RAISERROR('La fecha desde no puede ser mayor que la fecha hasta.', 16, 1);
        RETURN;
    END

    SELECT
        t.idTecnico,
        t.apellidos + ', ' + t.nombres AS tecnico,
        COUNT(o.idOrden) AS ordenesAtendidas,
        SUM(CASE WHEN o.estado = 'Entregado' THEN 1 ELSE 0 END) AS ordenesEntregadas,
        SUM(CASE
                WHEN o.estado = 'Entregado' THEN o.manoObra + ISNULL(r.totalRepuestos, 0)
                ELSE 0
            END) AS totalFacturado
    FROM dbo.Tecnicos t
    -- El filtro va en el ON y no en el WHERE: en el WHERE se perderian
    -- los tecnicos sin ordenes en el rango.
    LEFT JOIN dbo.OrdenesReparacion o
        ON o.idTecnico = t.idTecnico
        AND o.fechaIngreso BETWEEN @fechaDesde AND @fechaHasta
        AND o.estado <> 'Anulado'
    -- Los repuestos se suman primero por orden: unir el detalle directo
    -- repetiria la orden una vez por repuesto y duplicaria conteo y mano de obra.
    LEFT JOIN
        (
            SELECT idOrden, SUM(cantidad * precioUnitario) AS totalRepuestos
            FROM dbo.DetalleReparacion
            GROUP BY idOrden
        ) r
        ON r.idOrden = o.idOrden
    GROUP BY t.idTecnico, t.apellidos, t.nombres
    ORDER BY totalFacturado DESC, tecnico;
END
GO
