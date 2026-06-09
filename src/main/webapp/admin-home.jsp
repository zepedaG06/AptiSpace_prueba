<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Administrador</title>
    <style>
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #f4f7fb; }
        header { padding: 34px 7vw; background: #132f46; color: white; }
        header h1 { margin: 0 0 8px; font-size: 34px; letter-spacing: 0; }
        header p { margin: 0; max-width: 760px; line-height: 1.5; color: #d8e5ee; }
        main { max-width: 1100px; margin: 28px auto; padding: 0 20px; }
        .top { display: flex; justify-content: space-between; gap: 16px; align-items: center; margin-bottom: 18px; }
        .top h2 { margin: 0; font-size: 22px; }
        .logout { color: #1f6f8b; font-weight: 700; text-decoration: none; }
        .grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px; }
        a.tile { display: block; min-height: 128px; padding: 18px; border: 1px solid #d9e2ec; border-radius: 8px; background: white; text-decoration: none; color: #1f2937; }
        .tile strong { display: block; margin-bottom: 8px; font-size: 18px; color: #132f46; }
        .tile span { color: #52606d; line-height: 1.45; }
        @media (max-width: 820px) { .grid { grid-template-columns: 1fr; } .top { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Administrador de Plantillas</h1>
        <p>Cuenta interna para crear pruebas, cargar imagenes, marcar opciones correctas y mantener las plantillas que usaran todos los psicologos.</p>
    </header>
    <main>
        <div class="top">
            <h2>Configuracion del banco S2</h2>
            <a class="logout" href="logout">Cerrar sesion</a>
        </div>
        <section class="grid">
            <a class="tile" href="m/PlantillaCorreccion"><strong>Plantillas</strong><span>Agrupa los ejercicios que quedaran disponibles para los psicologos.</span></a>
            <a class="tile" href="m/Prueba"><strong>Pruebas</strong><span>Define nombre, tiempo limite y cantidad de ejercicios aleatorios por aplicacion.</span></a>
            <a class="tile" href="m/Ejercicio"><strong>Ejercicios</strong><span>Carga la imagen modelo y el enunciado de cada ejercicio espacial.</span></a>
            <a class="tile" href="m/OpcionEjercicio"><strong>Opciones</strong><span>Agrega imagenes A-E y marca cuales son correctas.</span></a>
            <a class="tile" href="m/Usuario"><strong>Usuarios</strong><span>Administra cuentas de psicologos, evaluados y administradores.</span></a>
            <a class="tile" href="m/Rol"><strong>Roles</strong><span>Control interno de permisos y tipos de cuenta.</span></a>
        </section>
    </main>
</body>
</html>
