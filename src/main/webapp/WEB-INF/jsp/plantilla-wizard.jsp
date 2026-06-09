<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ok = request.getParameter("ok");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Crear plantilla</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #eef3f7; }
        header { padding: 24px 6vw; background: #203a43; color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; }
        header h1 { margin: 0; font-size: 26px; letter-spacing: 0; }
        header a { color: #dbe8ef; text-decoration: none; font-weight: 700; }
        main { max-width: 1120px; margin: 24px auto 42px; padding: 0 18px; }
        .notice { padding: 12px 14px; border-radius: 8px; margin-bottom: 14px; border: 1px solid #badbcc; background: #edf8f1; color: #0f5132; }
        .error { border-color: #f2b8b5; background: #fff1f0; color: #8a1f17; }
        form { display: grid; gap: 16px; }
        section { background: white; border: 1px solid #d7e0e7; border-radius: 8px; padding: 18px; }
        h2 { margin: 0 0 14px; font-size: 20px; color: #203a43; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; }
        .options { display: grid; grid-template-columns: repeat(5, minmax(120px, 1fr)); gap: 12px; }
        label { display: grid; gap: 6px; font-size: 13px; font-weight: 700; color: #344453; }
        input, textarea { width: 100%; min-height: 42px; border: 1px solid #c5d0da; border-radius: 6px; padding: 9px 11px; font: inherit; background: white; }
        textarea { min-height: 84px; resize: vertical; }
        .option { border: 1px solid #d7e0e7; border-radius: 8px; padding: 12px; background: #f8fafc; }
        .check { display: flex; gap: 8px; align-items: center; margin-top: 10px; font-weight: 700; }
        .check input { width: 18px; min-height: 18px; }
        .actions { display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .button, button { border: 0; border-radius: 6px; padding: 11px 16px; font-weight: 700; text-decoration: none; cursor: pointer; }
        .secondary { background: #dfe7ee; color: #243441; }
        .primary { background: #1f6f8b; color: white; }
        @media (max-width: 900px) { .grid, .options { grid-template-columns: 1fr; } header { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Crear plantilla visual</h1>
        <a href="<%= request.getContextPath() %>/evaluador-home.jsp">Volver al panel</a>
    </header>
    <main>
        <% if ("1".equals(ok)) { %><div class="notice">Plantilla guardada. Ya puedes crear otra o revisarla en Pruebas/Ejercicios.</div><% } %>
        <% if (error != null && !error.isEmpty()) { %><div class="notice error"><%= error %></div><% } %>
        <form method="post" action="<%= request.getContextPath() %>/plantilla-wizard" enctype="multipart/form-data">
            <section>
                <h2>1. Datos de la plantilla</h2>
                <div class="grid">
                    <label>Nombre <input name="nombre" required placeholder="Ej. S2 Grupo A"/></label>
                    <label>Tiempo limite en minutos <input name="tiempoLimite" type="number" min="1" max="180" value="30" required/></label>
                    <label>Cantidad de ejercicios por aplicacion <input name="cantidadEjercicios" type="number" min="1" max="200" value="1" required/></label>
                    <label>Descripcion <textarea name="descripcion" placeholder="Uso o indicaciones de esta plantilla"></textarea></label>
                </div>
            </section>
            <section>
                <h2>2. Pregunta e imagen modelo</h2>
                <div class="grid">
                    <label>Enunciado <textarea name="enunciado" required>Seleccione las figuras que corresponden al desplazamiento indicado.</textarea></label>
                    <label>Imagen modelo <input name="imagenModelo" type="file" accept="image/*" required/></label>
                </div>
            </section>
            <section>
                <h2>3. Opciones A-E</h2>
                <div class="options">
                    <% for (String letra : new String[]{"A","B","C","D","E"}) { %>
                        <div class="option">
                            <label>Opcion <%= letra %> <input name="opcion<%= letra %>" type="file" accept="image/*" required/></label>
                            <label class="check"><input type="checkbox" name="correcta<%= letra %>"/> Correcta</label>
                        </div>
                    <% } %>
                </div>
            </section>
            <div class="actions">
                <a class="button secondary" href="<%= request.getContextPath() %>/evaluador-home.jsp">Cancelar</a>
                <button class="primary" type="submit">Guardar plantilla</button>
            </div>
        </form>
    </main>
</body>
</html>
