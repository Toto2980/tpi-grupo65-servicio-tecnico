/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: pruebas/Pruebas_Triggers.sql
    Alcance: casos de prueba de TR_DescontarStock, TR_AnularOrden y TR_HistorialEstado

    Ejecutar de a un caso, sobre los datos de Datos.sql y con los tres
    triggers ya creados. Cada caso abre una transaccion y termina con
    ROLLBACK: se ve el efecto del trigger y los datos quedan como estaban,
    asi el caso se puede repetir.
*/

USE TPIGrupo65_ServicioTecnico;
GO

-- TR_DescontarStock

-- Caso 1: hay stock. La orden 7 usa 2 Modulos de carga USB-C (id 4, stock 15): queda en 13.
BEGIN TRANSACTION;
SELECT idRepuesto, descripcion, stock AS stockAntes FROM dbo.Repuestos WHERE idRepuesto = 4;
INSERT INTO dbo.DetalleReparacion (idOrden, idRepuesto, cantidad, precioUnitario) VALUES (7, 4, 2, 12000);
SELECT idRepuesto, descripcion, stock AS stockDespues FROM dbo.Repuestos WHERE idRepuesto = 4;
ROLLBACK TRANSACTION;
GO

-- Caso 2: no alcanza. Bateria iPhone 12 (id 9) tiene stock 1 y se piden 2. Error y no se inserta nada.
BEGIN TRANSACTION;
INSERT INTO dbo.DetalleReparacion (idOrden, idRepuesto, cantidad, precioUnitario) VALUES (8, 9, 2, 55000);
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO
-- Despues del error: el stock sigue en 1 y la orden 8 no tiene detalle.
SELECT stock FROM dbo.Repuestos WHERE idRepuesto = 9;
SELECT COUNT(*) AS renglonesOrden8 FROM dbo.DetalleReparacion WHERE idOrden = 8;
GO

-- Caso 3: INSERT de varias filas con el mismo repuesto. Pasta termica (id 7, stock 20): baja a 18.
BEGIN TRANSACTION;
INSERT INTO dbo.DetalleReparacion (idOrden, idRepuesto, cantidad, precioUnitario)
VALUES (7, 7, 1, 6000), (8, 7, 1, 6000);
SELECT idRepuesto, stock AS stockDespues FROM dbo.Repuestos WHERE idRepuesto = 7;
ROLLBACK TRANSACTION;
GO

-- Caso 4: dos filas que por separado alcanzan pero juntas no. Id 9 tiene stock 1 y se piden 1 + 1.
BEGIN TRANSACTION;
INSERT INTO dbo.DetalleReparacion (idOrden, idRepuesto, cantidad, precioUnitario)
VALUES (7, 9, 1, 55000), (8, 9, 1, 55000);
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

-- TR_AnularOrden

-- Caso 5: orden con pagos (la 1). No se borra: pasa a Anulado y queda registrado en el historial.
BEGIN TRANSACTION;
DELETE FROM dbo.OrdenesReparacion WHERE idOrden = 1;
SELECT idOrden, estado FROM dbo.OrdenesReparacion WHERE idOrden = 1;
SELECT idOrden, estadoAnterior, estadoNuevo FROM dbo.HistorialEstados WHERE idOrden = 1 ORDER BY idHistorial;
ROLLBACK TRANSACTION;
GO

-- Caso 6: orden sin pagos y con repuestos (la 6 usa la Bateria iPhone 12, stock 1).
-- Se borra la orden y el repuesto vuelve al stock: queda en 2.
BEGIN TRANSACTION;
DELETE FROM dbo.OrdenesReparacion WHERE idOrden = 6;
SELECT COUNT(*) AS ordenesConId6 FROM dbo.OrdenesReparacion WHERE idOrden = 6;
SELECT COUNT(*) AS renglonesDetalle FROM dbo.DetalleReparacion WHERE idOrden = 6;
SELECT idRepuesto, stock AS stockDespues FROM dbo.Repuestos WHERE idRepuesto = 9;
ROLLBACK TRANSACTION;
GO

-- Caso 7: un DELETE con varias ordenes a la vez. La 1 (con pagos) se anula y la 7 (sin pagos) se borra.
BEGIN TRANSACTION;
DELETE FROM dbo.OrdenesReparacion WHERE idOrden IN (1, 7);
SELECT idOrden, estado FROM dbo.OrdenesReparacion WHERE idOrden IN (1, 7);
ROLLBACK TRANSACTION;
GO

-- TR_HistorialEstado

-- Caso 8: cambia el estado de la orden 7. Se agrega una fila Ingresado -> Listo.
BEGIN TRANSACTION;
UPDATE dbo.OrdenesReparacion SET estado = 'Listo' WHERE idOrden = 7;
SELECT idOrden, estadoAnterior, estadoNuevo, fechaCambio FROM dbo.HistorialEstados WHERE idOrden = 7;
ROLLBACK TRANSACTION;
GO

-- Caso 9: se modifica otra columna (diagnostico). No se agrega nada al historial.
BEGIN TRANSACTION;
UPDATE dbo.OrdenesReparacion SET diagnostico = 'Placa con falla' WHERE idOrden = 7;
SELECT COUNT(*) AS filasHistorialOrden7 FROM dbo.HistorialEstados WHERE idOrden = 7;
ROLLBACK TRANSACTION;
GO

-- Caso 10: se cambia el estado de dos ordenes en un solo UPDATE. Se agregan dos filas.
BEGIN TRANSACTION;
UPDATE dbo.OrdenesReparacion SET estado = 'Listo' WHERE idOrden IN (7, 8);
SELECT idOrden, estadoAnterior, estadoNuevo FROM dbo.HistorialEstados WHERE idOrden IN (7, 8);
ROLLBACK TRANSACTION;
GO
