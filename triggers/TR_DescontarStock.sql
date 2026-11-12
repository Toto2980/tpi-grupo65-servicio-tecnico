/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: triggers/TR_DescontarStock.sql
    Alcance: trigger TR_DescontarStock (AFTER INSERT en DetalleReparacion)

    Se ejecuta cuando se cargan los repuestos usados en una orden.
    - Si la cantidad pedida supera el stock disponible del repuesto, rechaza
      la operacion (ROLLBACK) e informa el error.
    - Si hay stock suficiente, descuenta la cantidad usada del stock.

    Un mismo INSERT puede traer varias filas del mismo repuesto (de distintas
    ordenes), por eso se suma lo pedido por repuesto antes de compararlo con
    el stock. La tabla inserted tiene las filas que se acaban de insertar.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE TRIGGER dbo.TR_DescontarStock
ON dbo.DetalleReparacion
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
        (
            SELECT 1
            FROM
                (
                    SELECT idRepuesto, SUM(cantidad) AS pedido
                    FROM inserted
                    GROUP BY idRepuesto
                ) p
                INNER JOIN dbo.Repuestos r ON r.idRepuesto = p.idRepuesto
            WHERE p.pedido > r.stock
        )
    BEGIN
        -- El mensaje va antes del ROLLBACK: el ROLLBACK anula el INSERT que
        -- disparo el trigger y tambien todo lo que hubiera en la transaccion.
        RAISERROR('Stock insuficiente: la cantidad pedida supera el stock disponible del repuesto.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE r
    SET r.stock = r.stock - p.pedido
    FROM dbo.Repuestos r
        INNER JOIN
            (
                SELECT idRepuesto, SUM(cantidad) AS pedido
                FROM inserted
                GROUP BY idRepuesto
            ) p
            ON p.idRepuesto = r.idRepuesto;
END
GO
