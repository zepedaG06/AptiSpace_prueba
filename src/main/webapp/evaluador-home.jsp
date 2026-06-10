<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Evaluador</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #eef3f7; }
        header { padding: 34px 7vw 32px; background: linear-gradient(135deg, rgba(20, 42, 71, .92), rgba(42, 92, 116, .86)), url("images/s2/modelo-01.svg"); background-size: cover; background-position: center; color: white; }
        header h1 { margin: 0 0 8px; font-size: 34px; letter-spacing: 0; }
        header p { margin: 0; max-width: 820px; line-height: 1.5; color: #dbe8ef; }
        main { max-width: 1180px; margin: 24px auto 44px; padding: 0 20px; }
        .top { display: flex; justify-content: space-between; gap: 16px; align-items: center; margin-bottom: 18px; }
        .top h2 { margin: 0; font-size: 22px; }
        .logout { color: #1f6f8b; font-weight: 700; text-decoration: none; }
        .layout { display: grid; grid-template-columns: 1.2fr .8fr; gap: 18px; align-items: start; }
        .panel { background: white; border: 1px solid #d7e0e7; border-radius: 8px; padding: 18px; }
        .panel h3 { margin: 0 0 12px; color: #203a43; font-size: 19px; }
        .steps { display: grid; gap: 12px; }
        .step { display: grid; grid-template-columns: 42px 1fr auto; gap: 12px; align-items: center; border: 1px solid #d7e0e7; border-radius: 8px; padding: 14px; background: #f8fafc; }
        .num { display: grid; place-items: center; width: 34px; height: 34px; border-radius: 50%; background: #1f6f8b; color: white; font-weight: 700; }
        .step strong { display: block; margin-bottom: 4px; color: #1f2937; }
        .step span, .note { color: #52606d; line-height: 1.4; }
        a.button { border-radius: 6px; padding: 10px 13px; background: #1f6f8b; color: white; font-weight: 700; text-decoration: none; white-space: nowrap; }
        .secondary { background: #dfe7ee !important; color: #243441 !important; }
        .quick { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; }
        .quick a { min-height: 96px; border: 1px solid #d7e0e7; border-radius: 8px; padding: 14px; text-decoration: none; color: #1f2937; background: #f8fafc; }
        .quick strong { display: block; margin-bottom: 6px; color: #203a43; }
        .code { margin-top: 14px; padding: 14px; border-radius: 8px; background: #f8fafc; border: 1px dashed #a9bac7; }
        .code strong { color: #203a43; }
        @media (max-width: 920px) { .layout { grid-template-columns: 1fr; } .step { grid-template-columns: 42px 1fr; } .step a { grid-column: 2; width: fit-content; } }
        @media (max-width: 620px) { .quick { grid-template-columns: 1fr; } .top { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Entorno del Evaluador</h1>
        <p>Controla el banco visual, organiza espacios por grupo, asigna pruebas y revisa resultados desde un flujo de trabajo unico.</p>
    </header>
    <main>
        <div class="top">
            <h2>Flujo principal</h2>
            <a class="logout" href="logout">Cerrar sesion</a>
        </div>
        <div class="layout">
            <section class="panel">
                <h3>Proceso recomendado</h3>
                <div class="steps">
                    <div class="step">
                        <span class="num">1</span>
                        <div><strong>Crear plantilla visual</strong><span>Carga imagen modelo, opciones A-E y marca las respuestas correctas.</span></div>
                        <a class="button" href="plantilla-wizard">Crear</a>
                    </div>
                    <div class="step">
                        <span class="num">2</span>
                        <div><strong>Gestionar plantillas</strong><span>Revisa las plantillas guardadas, edita sus datos o borra las que no fueron asignadas.</span></div>
                        <a class="button" href="plantillas">Plantillas</a>
                    </div>
                    <div class="step">
                        <span class="num">3</span>
                        <div><strong>Crear grupo o espacio</strong><span>Genera un codigo para que los evaluados entren al espacio del psicologo.</span></div>
                        <a class="button" href="grupos">Grupos</a>
                    </div>
                    <div class="step">
                        <span class="num">4</span>
                        <div><strong>Revisar evaluados</strong><span>Confirma datos personales, sexo, carrera, año y edad antes de asignar prueba.</span></div>
                        <a class="button" href="evaluados">Evaluados</a>
                    </div>
                    <div class="step">
                        <span class="num">5</span>
                        <div><strong>Asignar e iniciar prueba</strong><span>Selecciona evaluado, prueba y usa iniciar para generar sus ejercicios.</span></div>
                        <a class="button" href="asignaciones">Asignar</a>
                    </div>
                    <div class="step">
                        <span class="num">6</span>
                        <div><strong>Revisar resultados y observaciones</strong><span>Consulta S2, aciertos, errores y registra notas clinicas o academicas.</span></div>
                        <a class="button" href="resultados">Resultados</a>
                    </div>
                </div>
            </section>
            <aside class="panel">
                <h3>Seguimiento de prueba</h3>
                <div class="quick">
                    <a href="asignaciones"><strong>Reaplicaciones</strong><span class="note">Autoriza o inicia de nuevo una prueba cuando haga falta.</span></a>
                    <a href="grupos"><strong>Integrantes</strong><span class="note">Consulta quienes entraron con el codigo del espacio.</span></a>
                    <a href="resultados"><strong>Resultados</strong><span class="note">Revisa S2 y respuestas por estudiante.</span></a>
                    <a href="observaciones"><strong>Observaciones</strong><span class="note">Agregar seguimiento profesional.</span></a>
                </div>
                <div class="code">
                    <strong>Codigo del espacio</strong>
                    <p class="note">Crea un grupo y comparte su codigo. Al registrarse, el evaluado lo escribe y queda dentro de ese espacio.</p>
                </div>
            </aside>
        </div>
    </main>
</body>
</html>
