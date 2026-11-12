/*
    UTN FRGP - Bases de Datos II
    TPI - Grupo 65 - Servicio Tecnico
    Archivo: 00_Ejecutar_todo.sql
    Alcance: crea la base y carga todo, en el orden correcto

    Orden: Creacion -> Datos -> Vistas -> Procedimientos -> Triggers.
    Los triggers van al final a proposito: los datos de ejemplo ya tienen el
    stock descontado, y TR_DescontarStock no debe volver a descontarlo.

    Requiere el modo SQLCMD (usa :r). Desde la linea de comandos, parado en la
    carpeta del repositorio:

        sqlcmd -S .\SQLEXPRESS -E -C -f 65001 -i 00_Ejecutar_todo.sql

    En SSMS: menu Consulta > Modo SQLCMD, y ejecutar este archivo.
    Ojo: crea la base TPIGrupo65_ServicioTecnico; si ya existe, borrarla antes.
*/

:r 01_Creacion_Grupo65_ServicioTecnico.sql
:r 02_Datos_Grupo65_ServicioTecnico.sql

:r vistas/VW_OrdenesPendientes.sql
:r vistas/VW_SaldoOrdenes.sql
:r vistas/VW_RepuestosBajoStock.sql

:r procedimientos/SP_RegistrarOrden.sql
:r procedimientos/SP_ReporteTecnico.sql

:r triggers/TR_DescontarStock.sql
:r triggers/TR_AnularOrden.sql
:r triggers/TR_HistorialEstado.sql
