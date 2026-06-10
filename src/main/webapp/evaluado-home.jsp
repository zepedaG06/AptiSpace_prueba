<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Evaluado</title>
    <style>
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #f4f7fb; }
        header { padding: 34px 7vw; background: #1f4b5d; color: white; }
        header h1 { margin: 0 0 8px; font-size: 34px; letter-spacing: 0; }
        header p { margin: 0; max-width: 760px; line-height: 1.5; color: #d8e5ee; }
        main { max-width: 980px; margin: 28px auto; padding: 0 20px; }
        .top { display: flex; justify-content: space-between; gap: 16px; align-items: center; margin-bottom: 18px; }
        .top h2 { margin: 0; font-size: 22px; }
        .logout { color: #1f6f8b; font-weight: 700; text-decoration: none; }
        .grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 14px; }
        a.tile { display: block; min-height: 128px; padding: 18px; border: 1px solid #d9e2ec; border-radius: 8px; background: white; text-decoration: none; color: #1f2937; }
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
        <section class="grid">
            <a class="tile" href="mi-prueba"><strong>Responder prueba</strong><span>Realiza la prueba una pregunta a la vez, con imagen modelo y opciones visuales.</span></a>
            <a class="tile" href="mi-prueba"><strong>Mi resultado</strong><span>Consulta el resultado cuando la prueba este finalizada.</span></a>
            <a class="tile" href="mi-perfil"><strong>Mi informacion</strong><span>Revisa o actualiza sexo, edad, carrera, año y datos de contacto.</span></a>
            <a class="tile" href="mi-perfil"><strong>Unirme a grupo</strong><span>Ingresa el codigo que te comparta tu evaluador para recibir una prueba.</span></a>
        </section>
    </main>
</body>
</html>
