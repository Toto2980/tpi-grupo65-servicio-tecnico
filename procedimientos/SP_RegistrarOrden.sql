/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: procedimientos/SP_RegistrarOrden.sql
    Alcance: procedimiento de accion SP_RegistrarOrden

    Registra una orden nueva para un equipo y un tecnico.
    Valida que el equipo exista y que el tecnico exista y este activo.
    Si algo falla, deshace todo con ROLLBACK y devuelve un mensaje de error.

    La fecha de ingreso, el estado ('Ingresado') y la mano de obra (0) no se
    reciben por parametro: los completan los DEFAULT de la tabla.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE PROCEDURE dbo.SP_RegistrarOrden
    (
        @idEquipo INT,
        @idTecnico INT,
        @problema VARCHAR(300)
    )
AS
BEGIN
    DECLARE @idOrden INT;
    DECLARE @mensaje VARCHAR(2047);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Cada RAISERROR con severidad 16 salta directo al bloque CATCH.
        IF NOT EXISTS (SELECT 1 FROM dbo.Equipos WHERE idEquipo = @idEquipo)
            RAISERROR('El equipo indicado no existe.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM dbo.Tecnicos WHERE idTecnico = @idTecnico)
            RAISERROR('El tecnico indicado no existe.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM dbo.Tecnicos WHERE idTecnico = @idTecnico AND activo = 1)
            RAISERROR('El tecnico indicado esta inactivo y no puede recibir ordenes.', 16, 1);

        INSERT INTO dbo.OrdenesReparacion (idEquipo, idTecnico, problema)
        VALUES (@idEquipo, @idTecnico, @problema);

        -- Numero de orden que acaba de generar el IDENTITY.
        SET @idOrden = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @idOrden AS idOrden;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Se relanza el error para que lo reciba quien llamo al procedimiento.
        SET @mensaje = ERROR_MESSAGE();
        RAISERROR(@mensaje, 16, 1);
    END CATCH
END
GO
