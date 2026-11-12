/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: vistas/VW_RepuestosBajoStock.sql
    Alcance: vista VW_RepuestosBajoStock

    Repuestos con menos de 5 unidades en stock, para saber cuales reponer.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE VIEW VW_RepuestosBajoStock
AS
SELECT
    idRepuesto,
    descripcion,
    precio,
    stock
FROM Repuestos
WHERE stock < 5;
GO
