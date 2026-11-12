/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: vistas/VW_OrdenesPendientes.sql
    Alcance: vista VW_OrdenesPendientes

    Ordenes de reparacion que todavia estan pendientes de entrega.
    Reune orden, cliente, equipo y tecnico, y calcula con DATEDIFF los dias
    que lleva el equipo en el taller. Excluye las ordenes Entregado y Anulado.
*/

USE TPIGrupo65_ServicioTecnico;
GO

CREATE VIEW VW_OrdenesPendientes
AS
SELECT
    o.idorden,
    c.apellidos,
    c.nombres,
    e.tipo,
    e.marca,
    e.modelo,
    t.apellidos AS ApellidoTecnico,
    t.nombres AS NombreTecnico,
    o.estado,
    o.fechaingreso,
    DATEDIFF(DAY, o.fechaingreso, GETDATE()) AS DiasEnTaller
FROM OrdenesReparacion o
INNER JOIN Equipos e ON o.idequipo = e.idequipo
INNER JOIN Clientes c ON e.idcliente = c.idcliente
INNER JOIN Tecnicos t ON o.idtecnico = t.idtecnico
WHERE o.estado NOT IN ('Entregado', 'Anulado');
GO
