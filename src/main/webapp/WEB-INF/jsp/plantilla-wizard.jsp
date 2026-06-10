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
        .exercise { display: grid; gap: 14px; margin-top: 14px; padding-top: 14px; border-top: 1px solid #d7e0e7; }
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
        <div id="client-error" class="notice error" style="display:none;"></div>
        <form id="plantillaForm" method="post" action="<%= request.getContextPath() %>/plantilla-wizard" enctype="multipart/form-data">
            <section>
                <h2>1. Datos de la plantilla</h2>
                <div class="grid">
                    <label>Nombre <input name="nombre" required placeholder="Ej. S2 Grupo A"/></label>
                    <label>Tiempo limite en minutos <input name="tiempoLimite" type="number" min="1" max="180" value="30" required/></label>
                    <label>Cantidad de ejercicios de la prueba <input id="cantidadEjercicios" name="cantidadEjercicios" type="number" min="1" max="40" value="1" required/></label>
                    <label>Descripcion <textarea name="descripcion" placeholder="Uso o indicaciones de esta plantilla"></textarea></label>
                </div>
            </section>
            <section>
                <h2>2. Ejercicios de la prueba</h2>
                <div id="ejercicios"></div>
            </section>
            <div class="actions">
                <a class="button secondary" href="<%= request.getContextPath() %>/evaluador-home.jsp">Cancelar</a>
                <button class="primary" type="submit">Guardar plantilla</button>
            </div>
        </form>
    </main>
    <template id="tpl-ejercicio">
        <div class="exercise">
            <h2>Ejercicio __N__</h2>
            <div class="grid">
                <label>Enunciado <textarea name="enunciado__N__" required>Seleccione las figuras que corresponden al desplazamiento indicado.</textarea></label>
                <label>Imagen modelo <input name="imagenModelo__N__" type="file" accept="image/*" required/></label>
            </div>
            <div class="options">
                <div class="option"><label>Opcion A <input name="opcion__N__A" type="file" accept="image/*" required/></label><label class="check"><input type="checkbox" name="correcta__N__A"/> Correcta</label></div>
                <div class="option"><label>Opcion B <input name="opcion__N__B" type="file" accept="image/*" required/></label><label class="check"><input type="checkbox" name="correcta__N__B"/> Correcta</label></div>
                <div class="option"><label>Opcion C <input name="opcion__N__C" type="file" accept="image/*" required/></label><label class="check"><input type="checkbox" name="correcta__N__C"/> Correcta</label></div>
                <div class="option"><label>Opcion D <input name="opcion__N__D" type="file" accept="image/*" required/></label><label class="check"><input type="checkbox" name="correcta__N__D"/> Correcta</label></div>
                <div class="option"><label>Opcion E <input name="opcion__N__E" type="file" accept="image/*" required/></label><label class="check"><input type="checkbox" name="correcta__N__E"/> Correcta</label></div>
            </div>
        </div>
    </template>
    <script>
        const cantidad = document.getElementById('cantidadEjercicios');
        const contenedor = document.getElementById('ejercicios');
        const template = document.getElementById('tpl-ejercicio').innerHTML;
        function renderEjercicios() {
            const total = Math.max(1, Math.min(40, parseInt(cantidad.value || '1', 10)));
            const actuales = {};
            contenedor.querySelectorAll('textarea').forEach(el => actuales[el.name] = el.value);
            contenedor.querySelectorAll('input[type="checkbox"]').forEach(el => actuales[el.name] = el.checked);
            contenedor.innerHTML = '';
            for (let i = 1; i <= total; i++) {
                contenedor.insertAdjacentHTML('beforeend', template.replaceAll('__N__', i));
            }
            contenedor.querySelectorAll('textarea').forEach(el => { if (actuales[el.name] !== undefined) el.value = actuales[el.name]; });
            contenedor.querySelectorAll('input[type="checkbox"]').forEach(el => { if (actuales[el.name] !== undefined) el.checked = actuales[el.name]; });
        }
        cantidad.addEventListener('change', renderEjercicios);
        cantidad.addEventListener('input', renderEjercicios);
        renderEjercicios();
        document.getElementById('plantillaForm').addEventListener('submit', function (event) {
            const total = Math.max(1, Math.min(40, parseInt(cantidad.value || '1', 10)));
            const errores = [];
            for (let i = 1; i <= total; i++) {
                const marcada = ['A', 'B', 'C', 'D', 'E'].some(letra => {
                    const check = document.querySelector('[name="correcta' + i + letra + '"]');
                    return check && check.checked;
                });
                if (!marcada) errores.push('Ejercicio ' + i);
            }
            if (errores.length) {
                event.preventDefault();
                const error = document.getElementById('client-error');
                error.textContent = errores.join(', ') + ': marca al menos una opcion correcta antes de guardar.';
                error.style.display = 'block';
                error.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    </script>
</body>
</html>
