<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Evaluado</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #f4f7fb; }
        header { padding: 34px 7vw; background: linear-gradient(135deg, rgba(31, 75, 93, .94), rgba(45, 156, 219, .76)), url("images/s2/modelo-06.svg"); background-size: cover; background-position: center; color: white; }
        header h1 { margin: 0 0 8px; font-size: 34px; letter-spacing: 0; }
        header p { margin: 0; max-width: 760px; line-height: 1.5; color: #d8e5ee; }
        main { max-width: 1080px; margin: 28px auto; padding: 0 20px; }
        .top { display: flex; justify-content: space-between; gap: 16px; align-items: center; margin-bottom: 18px; padding: 12px; border: 1px solid #9cc9d8; border-radius: 8px; background: #e8f4f8; }
        .top h2 { margin: 0; font-size: 22px; }
        .logout { border-radius: 6px; background: #1f6f8b; color: white; font-weight: 700; text-decoration: none; padding: 10px 13px; }
        .panel { background: #d9edf4; border: 1px solid #6aaec5; border-radius: 8px; overflow: hidden; box-shadow: 0 10px 26px rgba(31, 111, 139, .12); }
        .panel h3 { margin: 0; padding: 14px 18px; color: white; font-size: 19px; background: #1f6f8b; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
        .panel .grid { padding: 18px; }
        a.tile { display: block; min-height: 128px; padding: 18px; border: 1px solid #b9d5df; border-radius: 8px; background: #f6fbfd; text-decoration: none; color: #1f2937; box-shadow: 0 8px 20px rgba(31, 75, 93, .06); }
        a.tile:hover { border-color: #9cc9d8; box-shadow: 0 10px 24px rgba(31, 75, 93, .10); }
        .tile strong { display: block; margin-bottom: 8px; font-size: 18px; color: #1f4b5d; }
        .tile span { color: #52606d; line-height: 1.45; }
        .main-actions { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; margin-bottom: 18px; }
        .action-card { min-height: 190px; padding: 22px; border: 1px solid #9cc9d8; border-radius: 8px; background: linear-gradient(180deg, #ffffff, #eef8fc); text-decoration: none; color: #1f2937; box-shadow: 0 12px 26px rgba(31, 75, 93, .10); display: grid; align-content: space-between; }
        .action-card.primary { background: linear-gradient(135deg, #16324f, #1f7fa3); color: white; }
        .action-card.primary span, .action-card.primary strong { color: white; }
        .action-card strong { display: block; margin-bottom: 10px; font-size: 24px; color: #16324f; }
        .action-card span { color: #52606d; line-height: 1.5; }
        .action-card em { font-style: normal; font-weight: 800; justify-self: start; border-radius: 6px; padding: 9px 12px; background: #dff1f8; color: #16476a; }
        .action-card.primary em { background: rgba(255,255,255,.18); color: white; border: 1px solid rgba(255,255,255,.32); }
        @media (max-width: 700px) { .grid, .main-actions { grid-template-columns: 1fr; } .top { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Entorno del Evaluado</h1>
        <p>Accede solo a tu prueba asignada y a tu resultado. Las pantallas administrativas no estan disponibles para este tipo de cuenta.</p>
    </header>
    <main>
        <div class="top">
            <h2>Mi prueba</h2>
            <a class="logout" href="logout?tipo=EVALUADO">Cerrar sesion</a>
        </div>
        <div class="main-actions">
            <a class="action-card primary" href="mi-prueba"><span><strong>Hacer prueba</strong>Entra a la aplicacion activa, responde pregunta por pregunta y guarda tu intento.</span><em>Responder ahora</em></a>
            <a class="action-card" href="mi-resultados"><span><strong>Ver resultados</strong>Consulta tu dashboard por prueba e intento, con aciertos, errores, S2 y detalle.</span><em>Abrir dashboard</em></a>
        </div>
        <section class="panel">
            <h3>Otros accesos</h3>
            <div class="grid">
            <a class="tile" href="mi-perfil"><strong>Mi informacion</strong><span>Revisa o actualiza sexo, edad, carrera, año y datos de contacto.</span></a>
                <a class="tile" href="unirme-grupo"><strong>Unirme a grupo</strong><span>Ingresa el codigo que te comparta tu evaluador para recibir una prueba.</span></a>
            </div>
        </section>
    </main>
</body>
</html>
