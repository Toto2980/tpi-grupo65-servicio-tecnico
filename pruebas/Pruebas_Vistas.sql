/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: pruebas/Pruebas_Vistas.sql
    Alcance: consultas de ejemplo sobre las tres vistas

    Ejecutar sobre los datos de 02_Datos_Grupo65_ServicioTecnico.sql.
    Son solo SELECT: no modifican nada.
*/

USE TPIGrupo65_ServicioTecnico;
GO

-- VW_OrdenesPendientes: solo ordenes que siguen en el taller (sin Entregado ni Anulado).
SELECT * FROM VW_OrdenesPendientes ORDER BY DiasEnTaller DESC;
GO

-- VW_SaldoOrdenes: todas las ordenes, con total, pagado y saldo.
SELECT * FROM VW_SaldoOrdenes ORDER BY idOrden;
GO

-- VW_SaldoOrdenes: solo las que todavia deben plata.
SELECT * FROM VW_SaldoOrdenes WHERE saldoPendiente > 0 ORDER BY saldoPendiente DESC;
GO

-- VW_RepuestosBajoStock: repuestos para reponer.
SELECT * FROM VW_RepuestosBajoStock ORDER BY stock;
GO
