/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: 01_Creacion_Grupo65_ServicioTecnico.sql
    Alcance: creacion de la base de datos, 8 tablas y sus restricciones

    Ejecutar en Microsoft SQL Server Management Studio (SSMS).
*/

USE master;
GO

CREATE DATABASE TPIGrupo65_ServicioTecnico;
GO

USE TPIGrupo65_ServicioTecnico;
GO

-- 1. CLIENTES
-- Cada cliente puede registrar varios equipos.
CREATE TABLE dbo.Clientes
    (
        idCliente INT IDENTITY(1,1) NOT NULL,
        dni VARCHAR(8) NOT NULL,
        apellidos VARCHAR(100) NOT NULL,
        nombres VARCHAR(100) NOT NULL,
        telefono VARCHAR(20) NULL,
        email VARCHAR(150) NULL,

        CONSTRAINT PK_Clientes PRIMARY KEY (idCliente),
        CONSTRAINT UQ_Clientes_Dni UNIQUE (dni)
    );
GO

-- 2. TECNICOS
-- Un tecnico puede atender varias ordenes de reparacion.
CREATE TABLE dbo.Tecnicos
    (
        idTecnico INT IDENTITY(1,1) NOT NULL,
        dni VARCHAR(8) NOT NULL,
        apellidos VARCHAR(100) NOT NULL,
        nombres VARCHAR(100) NOT NULL,
        especialidad VARCHAR(50) NULL,
        fechaIngreso DATE NOT NULL
            CONSTRAINT DF_Tecnicos_FechaIngreso DEFAULT (CONVERT(DATE, GETDATE())),
        activo BIT NOT NULL
            CONSTRAINT DF_Tecnicos_Activo DEFAULT (1),

        CONSTRAINT PK_Tecnicos PRIMARY KEY (idTecnico),
        CONSTRAINT UQ_Tecnicos_Dni UNIQUE (dni)
    );
GO

-- 3. EQUIPOS
-- Cada equipo pertenece a un cliente.
CREATE TABLE dbo.Equipos
    (
        idEquipo INT IDENTITY(1,1) NOT NULL,
        idCliente INT NOT NULL,
        tipo VARCHAR(15) NOT NULL,
        marca VARCHAR(50) NOT NULL,
        modelo VARCHAR(50) NOT NULL,
        nroSerie VARCHAR(50) NULL,

        CONSTRAINT PK_Equipos PRIMARY KEY (idEquipo),
        CONSTRAINT FK_Equipos_Clientes FOREIGN KEY (idCliente)
            REFERENCES dbo.Clientes (idCliente),
        CONSTRAINT CK_Equipos_Tipo CHECK
            (tipo IN ('Celular', 'Notebook', 'Tablet', 'PC', 'Consola', 'Otro'))
    );
GO

-- 4. REPUESTOS
-- El stock inicial es 0 y nunca puede ser negativo.
CREATE TABLE dbo.Repuestos
    (
        idRepuesto INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(100) NOT NULL,
        precio DECIMAL(10,2) NOT NULL,
        stock INT NOT NULL
            CONSTRAINT DF_Repuestos_Stock DEFAULT (0),

        CONSTRAINT PK_Repuestos PRIMARY KEY (idRepuesto),
        CONSTRAINT UQ_Repuestos_Descripcion UNIQUE (descripcion),
        CONSTRAINT CK_Repuestos_Precio CHECK (precio > 0),
        CONSTRAINT CK_Repuestos_Stock CHECK (stock >= 0)
    );
GO

-- 5. ORDENES DE REPARACION
-- Una orden corresponde a un equipo y a un tecnico.
CREATE TABLE dbo.OrdenesReparacion
    (
        idOrden INT IDENTITY(1,1) NOT NULL,
        idEquipo INT NOT NULL,
        idTecnico INT NOT NULL,
        fechaIngreso DATE NOT NULL
            CONSTRAINT DF_Ordenes_FechaIngreso DEFAULT (CONVERT(DATE, GETDATE())),
        fechaEntrega DATE NULL,
        problema VARCHAR(300) NOT NULL,
        diagnostico VARCHAR(300) NULL,
        estado VARCHAR(15) NOT NULL
            CONSTRAINT DF_Ordenes_Estado DEFAULT ('Ingresado'),
        manoObra DECIMAL(10,2) NOT NULL
            CONSTRAINT DF_Ordenes_ManoObra DEFAULT (0),

        CONSTRAINT PK_OrdenesReparacion PRIMARY KEY (idOrden),
        CONSTRAINT FK_Ordenes_Equipos FOREIGN KEY (idEquipo)
            REFERENCES dbo.Equipos (idEquipo),
        CONSTRAINT FK_Ordenes_Tecnicos FOREIGN KEY (idTecnico)
            REFERENCES dbo.Tecnicos (idTecnico),
        CONSTRAINT CK_Ordenes_Estado CHECK
            (estado IN ('Ingresado', 'En reparación', 'Listo', 'Entregado', 'Anulado')),
        CONSTRAINT CK_Ordenes_ManoObra CHECK (manoObra >= 0),
        CONSTRAINT CK_Ordenes_Fechas CHECK
            (fechaEntrega IS NULL OR fechaEntrega >= fechaIngreso)
    );
GO

-- 6. DETALLE DE REPARACION
-- Tabla intermedia entre las ordenes y los repuestos.
-- Su PK es compuesta: una fila por repuesto dentro de cada orden.
-- El precio unitario preserva el precio cobrado en ese momento.
CREATE TABLE dbo.DetalleReparacion
    (
        idOrden INT NOT NULL,
        idRepuesto INT NOT NULL,
        cantidad INT NOT NULL,
        precioUnitario DECIMAL(10,2) NOT NULL,

        CONSTRAINT PK_DetalleReparacion PRIMARY KEY (idOrden, idRepuesto),
        CONSTRAINT FK_Detalle_Ordenes FOREIGN KEY (idOrden)
            REFERENCES dbo.OrdenesReparacion (idOrden),
        CONSTRAINT FK_Detalle_Repuestos FOREIGN KEY (idRepuesto)
            REFERENCES dbo.Repuestos (idRepuesto),
        CONSTRAINT CK_Detalle_Cantidad CHECK (cantidad > 0),
        CONSTRAINT CK_Detalle_PrecioUnitario CHECK (precioUnitario > 0)
    );
GO

-- 7. PAGOS
-- Una orden puede tener uno o varios pagos.
CREATE TABLE dbo.Pagos
    (
        idPago INT IDENTITY(1,1) NOT NULL,
        idOrden INT NOT NULL,
        fechaPago DATE NOT NULL
            CONSTRAINT DF_Pagos_FechaPago DEFAULT (CONVERT(DATE, GETDATE())),
        monto DECIMAL(10,2) NOT NULL,
        formaPago VARCHAR(15) NOT NULL,

        CONSTRAINT PK_Pagos PRIMARY KEY (idPago),
        CONSTRAINT FK_Pagos_Ordenes FOREIGN KEY (idOrden)
            REFERENCES dbo.OrdenesReparacion (idOrden),
        CONSTRAINT CK_Pagos_Monto CHECK (monto > 0),
        CONSTRAINT CK_Pagos_FormaPago CHECK
            (formaPago IN ('Efectivo', 'Transferencia', 'Débito', 'Crédito'))
    );
GO

-- 8. HISTORIAL DE ESTADOS
-- Registra las transiciones de estado de cada orden.
CREATE TABLE dbo.HistorialEstados
    (
        idHistorial INT IDENTITY(1,1) NOT NULL,
        idOrden INT NOT NULL,
        estadoAnterior VARCHAR(15) NOT NULL,
        estadoNuevo VARCHAR(15) NOT NULL,
        fechaCambio DATETIME NOT NULL
            CONSTRAINT DF_Historial_FechaCambio DEFAULT (GETDATE()),

        CONSTRAINT PK_HistorialEstados PRIMARY KEY (idHistorial),
        CONSTRAINT FK_Historial_Ordenes FOREIGN KEY (idOrden)
            REFERENCES dbo.OrdenesReparacion (idOrden)
    );
GO