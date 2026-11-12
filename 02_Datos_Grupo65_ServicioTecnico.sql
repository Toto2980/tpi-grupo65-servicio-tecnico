/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: 02_Datos_Grupo65_ServicioTecnico.sql
    Alcance: datos de ejemplo para las 8 tablas

    Orden de ejecucion: Creacion -> Datos -> Vistas -> Procedimientos -> Triggers.
    Los datos se cargan ANTES de crear los triggers, por eso el stock de Repuestos
    ya refleja lo consumido por las ordenes de abajo (el trigger TR_DescontarStock
    se encarga de descontarlo para las ordenes nuevas que se carguen despues).

    Los datos estan pensados para que cada objeto tenga algo que mostrar:
    - Ordenes en todos los estados (Ingresado, En reparación, Listo, Entregado, Anulado)
    - Ordenes pagadas, con pago parcial y sin pagos (saldo pendiente)
    - Repuestos con stock menor a 5 (reposicion)
    - Un tecnico inactivo (validacion de SP_RegistrarOrden)
    - Ordenes repartidas entre agosto y octubre (rango de fechas de SP_ReporteTecnico)
*/

USE TPIGrupo65_ServicioTecnico;
GO

-- 1. CLIENTES
INSERT INTO dbo.Clientes (dni, apellidos, nombres, telefono, email)
VALUES
    ('40123456', 'Gomez', 'Lucia', '1123456789', 'lucia@gmail.com'),
    ('38987654', 'Perez', 'Martin', '1198765432', 'martin@gmail.com'),
    ('42555111', 'Fernandez', 'Sofia', '1145671234', 'sofia.fernandez@hotmail.com'),
    ('33444777', 'Rodriguez', 'Juan', '1156789012', NULL),
    ('45222333', 'Acosta', 'Valentina', '1167890123', 'valen.acosta@gmail.com'),
    ('37888999', 'Sosa', 'Diego', NULL, 'diegososa@yahoo.com');
GO

-- 2. TECNICOS
-- Medina queda inactiva: sirve para probar que no se le asignen ordenes nuevas.
INSERT INTO dbo.Tecnicos (dni, apellidos, nombres, especialidad, fechaIngreso, activo)
VALUES
    ('35111222', 'Lopez', 'Carlos', 'Celulares', '2022-03-01', 1),
    ('36777888', 'Diaz', 'Ana', 'Computadoras', '2023-06-15', 1),
    ('39222444', 'Romero', 'Pablo', 'Consolas', '2024-02-10', 1),
    ('34666555', 'Medina', 'Laura', 'Celulares', '2021-08-01', 0);
GO

-- 3. EQUIPOS
INSERT INTO dbo.Equipos (idCliente, tipo, marca, modelo, nroSerie)
VALUES
    (1, 'Celular', 'Samsung', 'Galaxy A54', 'R58T12AB34'),
    (1, 'Notebook', 'Lenovo', 'IdeaPad 3', 'PF3K9X21'),
    (2, 'PC', 'Armada', 'Torre Gamer', NULL),
    (3, 'Consola', 'Sony', 'PlayStation 5', 'E01234567'),
    (4, 'Notebook', 'HP', 'Pavilion 15', '5CD1234XYZ'),
    (5, 'Celular', 'Apple', 'iPhone 12', 'F2LD3456N0'),
    (6, 'Tablet', 'Samsung', 'Galaxy Tab A8', 'R9PT50ABCD'),
    (2, 'Celular', 'Motorola', 'Moto G84', 'ZY22H7KL9');
GO

-- 4. REPUESTOS
-- Stock actual (ya descontado lo usado en las ordenes cargadas abajo).
-- Con stock menor a 5: Memoria RAM, Joystick, Teclado Lenovo y Bateria iPhone.
INSERT INTO dbo.Repuestos (descripcion, precio, stock)
VALUES
    ('Pantalla Samsung A54', 85000, 10),
    ('Bateria Notebook', 45000, 5),
    ('Disco SSD 500GB', 60000, 8),
    ('Modulo de carga USB-C', 12000, 15),
    ('Memoria RAM 8GB DDR4', 35000, 3),
    ('Joystick analogico PS5', 18000, 2),
    ('Pasta termica', 6000, 20),
    ('Teclado Notebook Lenovo', 40000, 4),
    ('Bateria iPhone 12', 55000, 1);
GO

-- 5. ORDENES DE REPARACION
-- fechaEntrega solo se completa en las ordenes entregadas.
INSERT INTO dbo.OrdenesReparacion
    (idEquipo, idTecnico, fechaIngreso, fechaEntrega, problema, diagnostico, estado, manoObra)
VALUES
    -- 1: entregada y pagada completa
    (1, 1, '2026-08-03', '2026-08-07', 'Pantalla rota', 'Display dañado por golpe', 'Entregado', 25000),
    -- 2: entregada, pagada en dos veces
    (2, 2, '2026-08-18', '2026-08-25', 'No carga la bateria', 'Bateria agotada', 'Entregado', 15000),
    -- 3: entregada y pagada completa
    (3, 2, '2026-09-02', '2026-09-10', 'Funciona muy lenta', 'Disco rigido con sectores dañados', 'Entregado', 20000),
    -- 4: lista para retirar, con pago parcial
    (4, 3, '2026-09-15', NULL, 'El personaje se mueve solo', 'Joystick analogico gastado (drift)', 'Listo', 18000),
    -- 5: en reparacion, con seña
    (5, 2, '2026-10-05', NULL, 'Teclas que no responden', 'Teclado con liquido derramado', 'En reparación', 20000),
    -- 6: en reparacion, sin pagos
    (6, 1, '2026-10-14', NULL, 'La bateria dura poco', 'Bateria al 70% de salud', 'En reparación', 15000),
    -- 7 y 8: recien ingresadas, sin diagnostico
    (7, 1, '2026-10-22', NULL, 'No enciende', NULL, 'Ingresado', 0),
    (8, 1, '2026-10-26', NULL, 'Puerto de carga flojo', NULL, 'Ingresado', 0),
    -- 9: anulada (el cliente desistio antes de la reparacion)
    (1, 4, '2026-07-10', NULL, 'Revision general', 'Cliente desistio del presupuesto', 'Anulado', 0),
    -- 10: lista para retirar, sin pagos
    (3, 2, '2026-10-20', NULL, 'Se apaga sola', 'Sobrecalentamiento y memoria con fallas', 'Listo', 10000);
GO

-- 6. DETALLE DE REPARACION
-- precioUnitario = precio del repuesto al momento de la reparacion.
INSERT INTO dbo.DetalleReparacion (idOrden, idRepuesto, cantidad, precioUnitario)
VALUES
    (1, 1, 1, 85000),   -- Pantalla Samsung A54
    (2, 2, 1, 45000),   -- Bateria Notebook
    (3, 3, 1, 60000),   -- Disco SSD 500GB
    (3, 7, 1, 6000),    -- Pasta termica
    (4, 6, 2, 18000),   -- Joystick analogico PS5 x2
    (5, 8, 1, 40000),   -- Teclado Notebook Lenovo
    (6, 9, 1, 55000),   -- Bateria iPhone 12
    (10, 5, 1, 35000),  -- Memoria RAM 8GB DDR4
    (10, 7, 1, 6000);   -- Pasta termica
GO

-- 7. PAGOS
-- Totales (mano de obra + repuestos): orden 1 = 110000, 2 = 60000, 3 = 86000,
-- 4 = 54000, 5 = 60000, 6 = 70000, 10 = 51000.
INSERT INTO dbo.Pagos (idOrden, fechaPago, monto, formaPago)
VALUES
    (1, '2026-08-07', 110000, 'Transferencia'),
    (2, '2026-08-18', 30000, 'Efectivo'),
    (2, '2026-08-25', 30000, 'Débito'),
    (3, '2026-09-10', 86000, 'Crédito'),
    (4, '2026-09-15', 20000, 'Efectivo'),
    (5, '2026-10-05', 20000, 'Transferencia');
GO

-- 8. HISTORIAL DE ESTADOS
-- Transiciones que llevaron a cada orden a su estado actual.
-- (A partir de aca, TR_HistorialEstado las registra solo.)
INSERT INTO dbo.HistorialEstados (idOrden, estadoAnterior, estadoNuevo, fechaCambio)
VALUES
    (1, 'Ingresado', 'En reparación', '2026-08-04 10:00'),
    (1, 'En reparación', 'Listo', '2026-08-06 17:30'),
    (1, 'Listo', 'Entregado', '2026-08-07 11:15'),
    (2, 'Ingresado', 'En reparación', '2026-08-19 09:30'),
    (2, 'En reparación', 'Listo', '2026-08-24 16:00'),
    (2, 'Listo', 'Entregado', '2026-08-25 12:00'),
    (3, 'Ingresado', 'En reparación', '2026-09-03 10:00'),
    (3, 'En reparación', 'Listo', '2026-09-09 18:00'),
    (3, 'Listo', 'Entregado', '2026-09-10 10:30'),
    (4, 'Ingresado', 'En reparación', '2026-09-16 11:00'),
    (4, 'En reparación', 'Listo', '2026-10-02 15:00'),
    (5, 'Ingresado', 'En reparación', '2026-10-06 09:00'),
    (6, 'Ingresado', 'En reparación', '2026-10-15 10:00'),
    (9, 'Ingresado', 'Anulado', '2026-07-12 12:00'),
    (10, 'Ingresado', 'En reparación', '2026-10-21 09:30'),
    (10, 'En reparación', 'Listo', '2026-10-27 17:00');
GO
