<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = request.getParameter("error");
    String usuario = (String) session.getAttribute("aptispace.usuario");
    String tipo = (String) session.getAttribute("aptispace.tipo");
    if (usuario != null && tipo != null) {
        response.sendRedirect("EVALUADO".equals(tipo) ? "evaluado-home.jsp" : "evaluador-home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            color: #1f2937;
            background: #f4f7fb;
        }
        .hero {
            min-height: 42vh;
            padding: 56px 7vw 38px;
            background: linear-gradient(135deg, rgba(20, 42, 71, .92), rgba(42, 92, 116, .86)), url("images/s2/modelo-01.svg");
            background-size: cover;
            background-position: center;
            color: white;
        }
        .hero h1 {
            margin: 0 0 14px;
            font-size: clamp(34px, 6vw, 64px);
            line-height: 1;
            letter-spacing: 0;
        }
        .hero p {
            max-width: 720px;
            margin: 0;
            font-size: 18px;
            line-height: 1.55;
        }
        .shell {
            max-width: 1180px;
            margin: -28px auto 48px;
            padding: 0 20px;
        }
        .notice {
            margin-bottom: 16px;
            padding: 12px 14px;
            border: 1px solid #f2b8b5;
            background: #fff1f0;
            color: #8a1f17;
            border-radius: 8px;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
        }
        .panel {
            background: white;
            border: 1px solid #d9e2ec;
            border-radius: 8px;
            padding: 22px;
            box-shadow: 0 10px 28px rgba(31, 41, 55, .08);
        }
        .panel h2 {
            margin: 0 0 8px;
            font-size: 24px;
        }
        .panel p {
            margin: 0 0 18px;
            color: #52606d;
            line-height: 1.45;
        }
        .tabs {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 16px;
        }
        .tabs button {
            border: 0;
            padding: 11px;
            background: #f8fafc;
            cursor: pointer;
            font-weight: 700;
            color: #334155;
        }
        .tabs button.active {
            background: #1f6f8b;
            color: white;
        }
        form { display: grid; gap: 12px; }
        label {
            display: grid;
            gap: 6px;
            font-size: 13px;
            font-weight: 700;
            color: #334155;
        }
        input, select {
            width: 100%;
            min-height: 42px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            padding: 9px 11px;
            font: inherit;
        }
        .actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .primary {
            border: 0;
            border-radius: 6px;
            background: #1f6f8b;
            color: white;
            padding: 11px 16px;
            cursor: pointer;
            font-weight: 700;
        }
        .link {
            border: 0;
            background: transparent;
            color: #1f6f8b;
            cursor: pointer;
            font-weight: 700;
            padding: 8px 0;
        }
        .registro { display: none; }
        .show-register .login { display: none; }
        .show-register .registro { display: grid; }
        @media (max-width: 820px) {
            .grid { grid-template-columns: 1fr; }
            .hero { padding-top: 42px; }
        }
    </style>
</head>
<body>
    <section class="hero">
        <h1>AptiSpace</h1>
        <p>Sistema web para aplicar y corregir pruebas de aptitud espacial S2 con banco visual, asignacion aleatoria y entornos separados para evaluadores y evaluados.</p>
    </section>

    <main class="shell">
        <% if (error != null && !error.isEmpty()) { %>
            <div class="notice"><%= error %></div>
        <% } %>

        <section class="grid">
            <article class="panel" id="panel-evaluador">
                <h2>Evaluador</h2>
                <p>Crea plantillas visuales, organiza grupos, asigna pruebas, revisa resultados y registra observaciones.</p>
                <div class="tabs">
                    <button class="active" type="button" onclick="modo('panel-evaluador', false)">Iniciar</button>
                    <button type="button" onclick="modo('panel-evaluador', true)">Crear cuenta</button>
                </div>
                <form class="login" method="post" action="auth">
                    <input type="hidden" name="accion" value="login"/>
                    <input type="hidden" name="tipo" value="PSICOLOGO"/>
                    <label>Usuario <input name="usuario" autocomplete="username" required/></label>
                    <label>Contrasena <input name="contrasena" type="password" autocomplete="current-password" required/></label>
                    <div class="actions"><button class="primary" type="submit">Entrar como evaluador</button></div>
                </form>
                <form class="registro" method="post" action="auth">
                    <input type="hidden" name="accion" value="registro"/>
                    <input type="hidden" name="tipo" value="PSICOLOGO"/>
                    <label>Nombres <input name="nombres" required/></label>
                    <label>Apellidos <input name="apellidos" required/></label>
                    <label>Correo <input name="correo" type="email"/></label>
                    <label>Usuario <input name="usuario" autocomplete="username" required/></label>
                    <label>Contrasena <input name="contrasena" type="password" autocomplete="new-password" required minlength="6"/></label>
                    <div class="actions"><button class="primary" type="submit">Crear evaluador</button></div>
                </form>
            </article>

            <article class="panel" id="panel-evaluado">
                <h2>Evaluado</h2>
                <p>Ingresa al espacio de tu psicologo, responde la prueba asignada y consulta tu informacion personal.</p>
                <div class="tabs">
                    <button class="active" type="button" onclick="modo('panel-evaluado', false)">Iniciar</button>
                    <button type="button" onclick="modo('panel-evaluado', true)">Crear cuenta</button>
                </div>
                <form class="login" method="post" action="auth">
                    <input type="hidden" name="accion" value="login"/>
                    <input type="hidden" name="tipo" value="EVALUADO"/>
                    <label>Usuario <input name="usuario" autocomplete="username" required/></label>
                    <label>Contrasena <input name="contrasena" type="password" autocomplete="current-password" required/></label>
                    <div class="actions"><button class="primary" type="submit">Entrar como evaluado</button></div>
                </form>
                <form class="registro" method="post" action="auth">
                    <input type="hidden" name="accion" value="registro"/>
                    <input type="hidden" name="tipo" value="EVALUADO"/>
                    <label>Nombres <input name="nombres" required/></label>
                    <label>Apellidos <input name="apellidos" required/></label>
                    <label>Sexo
                        <select name="sexo" required>
                            <option value="">Seleccionar</option>
                            <option value="FEMENINO">Femenino</option>
                            <option value="MASCULINO">Masculino</option>
                            <option value="OTRO">Otro</option>
                        </select>
                    </label>
                    <label>Edad <input name="edad" type="number" min="10" max="99" required/></label>
                    <label>Carrera <input name="carrera" placeholder="Ej. Ingenieria, Arquitectura"/></label>
                    <label>Año de la carrera <input name="anioCarrera" type="number" min="1" max="12"/></label>
                    <label>Codigo de espacio <input name="codigoEspacio" placeholder="Opcional"/></label>
                    <label>Correo <input name="correo" type="email"/></label>
                    <label>Usuario <input name="usuario" autocomplete="username" required/></label>
                    <label>Contrasena <input name="contrasena" type="password" autocomplete="new-password" required minlength="6"/></label>
                    <div class="actions"><button class="primary" type="submit">Crear evaluado</button></div>
                </form>
            </article>
        </section>
    </main>

    <script>
        function modo(id, registro) {
            var panel = document.getElementById(id);
            panel.classList.toggle('show-register', registro);
            var buttons = panel.querySelectorAll('.tabs button');
            buttons[0].classList.toggle('active', !registro);
            buttons[1].classList.toggle('active', registro);
        }
    </script>
</body>
</html>
