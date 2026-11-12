/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: triggers/TR_HistorialEstado.sql
    Alcance: trigger TR_HistorialEstado (AFTER UPDATE en OrdenesReparacion)

    Registra en HistorialEstados cada cambio de estado de una orden.
    En un UPDATE, deleted tiene los valores viejos e inserted los nuevos:
    comparandolos se detecta que ordenes cambiaron de estado. Un UPDATE de
    otra columna (diagnostico, mano de obra) no genera historial.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE TRIGGER dbo.TR_HistorialEstado
ON dbo.OrdenesReparacion
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(estado)
        RETURN;

    INSERT INTO dbo.HistorialEstados (idOrden, estadoAnterior, estadoNuevo)
    SELECT i.idOrden, d.estado, i.estado
    FROM inserted i
        INNER JOIN deleted d ON d.idOrden = i.idOrden
    WHERE i.estado <> d.estado;
END
GO
