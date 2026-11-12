/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: pruebas/Pruebas_Procedimientos.sql
    Alcance: casos de prueba de SP_RegistrarOrden y SP_ReporteTecnico

    Ejecutar de a un caso, seleccionandolo, sobre los datos de Datos.sql.
    Los casos con error muestran el mensaje del procedimiento.
    El caso 1 agrega una orden de verdad, con la fecha del dia.
*/

USE TPIGrupo65_ServicioTecnico;
GO

-- SP_RegistrarOrden

-- Caso 1: datos validos. Devuelve el numero de orden nuevo.
EXEC dbo.SP_RegistrarOrden 1, 1, 'Microfono no funciona';
GO

-- Caso 2: el equipo no existe.
EXEC dbo.SP_RegistrarOrden 999, 1, 'Equipo inexistente';
GO

-- Caso 3: el tecnico no existe.
EXEC dbo.SP_RegistrarOrden 1, 999, 'Tecnico inexistente';
GO

-- Caso 4: Medina (id 4) esta inactiva.
EXEC dbo.SP_RegistrarOrden 1, 4, 'Tecnico inactivo';
GO

-- Caso 5: problema NULL. Falla el INSERT y el CATCH devuelve el error del motor.
EXEC dbo.SP_RegistrarOrden 1, 1, NULL;
GO

-- SP_ReporteTecnico

-- Caso 6: rango completo. Medina aparece en 0: su unica orden esta anulada.
EXEC dbo.SP_ReporteTecnico '2026-08-01', '2026-10-31';
GO

-- Caso 7: solo agosto. Romero y Medina aparecen en 0.
EXEC dbo.SP_ReporteTecnico '2026-08-01', '2026-08-31';
GO

-- Caso 8: fechas invertidas.
EXEC dbo.SP_ReporteTecnico '2026-10-31', '2026-08-01';
GO
