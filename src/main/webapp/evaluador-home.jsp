<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Evaluador</title>
    <style>
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #f4f7fb; }
        header { padding: 34px 7vw; background: #163b4f; color: white; }
        header h1 { margin: 0 0 8px; font-size: 34px; letter-spacing: 0; }
        header p { margin: 0; max-width: 760px; line-height: 1.5; color: #d8e5ee; }
        main { max-width: 1000px; margin: 28px auto; padding: 0 20px; }
        .top { display: flex; justify-content: space-between; gap: 16px; align-items: center; margin-bottom: 18px; }
        .top h2 { margin: 0; font-size: 22px; }
        .logout { color: #1f6f8b; font-weight: 700; text-decoration: none; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
        a.tile { display: block; min-height: 128px; padding: 18px; border: 1px solid #d9e2ec; border-radius: 8px; background: white; text-decoration: none; color: #1f2937; }
        .tile strong { display: block; margin-bottom: 8px; font-size: 18px; color: #163b4f; }
        .tile span { color: #52606d; line-height: 1.45; }
        @media (max-width: 760px) { .grid { grid-template-columns: 1fr; } .top { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Entorno del Evaluador</h1>
        <p>Usa las plantillas preparadas por administracion para registrar evaluados, asignar aplicaciones y revisar resultados sin modificar el banco de ejercicios.</p>
    </header>
    <main>
        <div class="top">
            <h2>Operacion psicologica</h2>
            <a class="logout" href="logout">Cerrar sesion</a>
        </div>
        <section class="grid">
            <a class="tile" href="m/Evaluado"><strong>Evaluados</strong><span>Registrar o consultar personas evaluadas.</span></a>
            <a class="tile" href="m/AplicacionPrueba"><strong>Aplicaciones</strong><span>Asignar prueba, iniciar, finalizar y calcular resultados.</span></a>
            <a class="tile" href="m/ResultadoPrueba"><strong>Resultados</strong><span>Consultar puntuacion S2, aciertos, errores y pendientes.</span></a>
            <a class="tile" href="m/ObservacionPsicologica"><strong>Observaciones</strong><span>Agregar comentarios profesionales sobre una aplicacion.</span></a>
        </section>
    </main>
</body>
</html>
