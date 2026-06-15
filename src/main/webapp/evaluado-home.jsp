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
        main { max-width: 980px; margin: 28px auto; padding: 0 20px; }
        .top { display: flex; justify-content: space-between; gap: 16px; align-items: center; margin-bottom: 18px; padding: 12px; border: 1px solid #9cc9d8; border-radius: 8px; background: #e8f4f8; }
        .top h2 { margin: 0; font-size: 22px; }
        .logout { border-radius: 6px; background: #1f6f8b; color: white; font-weight: 700; text-decoration: none; padding: 10px 13px; }
        .panel { background: #d9edf4; border: 1px solid #6aaec5; border-radius: 8px; overflow: hidden; box-shadow: 0 10px 26px rgba(31, 111, 139, .12); }
        .panel h3 { margin: 0; padding: 14px 18px; color: white; font-size: 19px; background: #1f6f8b; }
        .grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; }
        .panel .grid { padding: 18px; }
        a.tile { display: block; min-height: 128px; padding: 18px; border: 1px solid #b9d5df; border-radius: 8px; background: #f6fbfd; text-decoration: none; color: #1f2937; box-shadow: 0 8px 20px rgba(31, 75, 93, .06); }
        a.tile:hover { border-color: #9cc9d8; box-shadow: 0 10px 24px rgba(31, 75, 93, .10); }
        .tile strong { display: block; margin-bottom: 8px; font-size: 18px; color: #1f4b5d; }
        .tile span { color: #52606d; line-height: 1.45; }
        @media (max-width: 700px) { .grid { grid-template-columns: 1fr; } .top { align-items: flex-start; flex-direction: column; } }
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
            <a class="logout" href="logout">Cerrar sesion</a>
        </div>
        <section class="panel">
            <h3>Accesos del evaluado</h3>
            <div class="grid">
            <a class="tile" href="mi-prueba"><strong>Responder prueba</strong><span>Realiza la prueba una pregunta a la vez, con imagen modelo y opciones visuales.</span></a>
            <a class="tile" href="mi-resultados"><strong>Mi resultado</strong><span>Consulta un dashboard por prueba, intento, aciertos y fallos.</span></a>
            <a class="tile" href="mi-perfil"><strong>Mi informacion</strong><span>Revisa o actualiza sexo, edad, carrera, año y datos de contacto.</span></a>
                <a class="tile" href="unirme-grupo"><strong>Unirme a grupo</strong><span>Ingresa el codigo que te comparta tu evaluador para recibir una prueba.</span></a>
            </div>
        </section>
    </main>
</body>
</html>
