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
        .grid { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 14px; }
        a.tile { display: block; min-height: 128px; padding: 18px; border: 1px solid #d9e2ec; border-radius: 8px; background: white; text-decoration: none; color: #1f2937; }
        .tile strong { display: block; margin-bottom: 8px; font-size: 18px; color: #132f46; }
        .tile span { color: #52606d; line-height: 1.45; }
        @media (max-width: 900px) { .grid { grid-template-columns: 1fr; } .top { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Administración AptiSpace</h1>
        <p>Gestión de cuentas, roles, estado de acceso, bitácora y configuración básica del sistema.</p>
    </header>
    <main>
        <div class="top">
            <h2>Módulos administrativos</h2>
            <a class="logout" href="logout?tipo=ADMINISTRADOR">Cerrar sesión</a>
        </div>
        <section class="grid">
            <a class="tile" href="m/Usuario"><strong>Usuarios</strong><span>Crea cuentas institucionales y administra datos de acceso.</span></a>
            <a class="tile" href="m/Rol"><strong>Roles</strong><span>Mantén los perfiles ADMINISTRADOR, EVALUADOR y EVALUADO.</span></a>
            <a class="tile" href="m/GrupoEvaluacion"><strong>Grupos</strong><span>Consulta los grupos registrados en AptiSpace.</span></a>
            <a class="tile" href="m/Bitacora"><strong>Bitácora</strong><span>Consulta eventos básicos de acceso al sistema.</span></a>
            <a class="tile" href="m/ConfiguracionBasica"><strong>Configuración</strong><span>Administra parámetros generales no clínicos.</span></a>
        </section>
    </main>
</body>
</html>
