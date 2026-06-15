<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.aptispace.modelo.*" %>
<%!
    String h(Object v) {
        if (v == null) return "";
        return String.valueOf(v).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    String js(Object v) {
        if (v == null) return "";
        return String.valueOf(v)
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\r", "\\r")
            .replace("\n", "\\n");
    }
    OpcionEjercicio opcion(Ejercicio ejercicio, OpcionEjercicio.LetraOpcion letra) {
        if (ejercicio == null || ejercicio.getOpciones() == null) return null;
        for (OpcionEjercicio opcion : ejercicio.getOpciones()) if (letra.equals(opcion.getLetra())) return opcion;
        return null;
    }
    String imgUrl(javax.servlet.http.HttpServletRequest request, String ruta) {
        if (ruta == null || ruta.isBlank()) return "";
        if (ruta.startsWith("http://") || ruta.startsWith("https://")) return h(ruta);
        String limpia = ruta.replace("\\", "/");
        while (limpia.startsWith("/")) limpia = limpia.substring(1);
        return request.getContextPath() + "/" + h(limpia);
    }
%>
<%
    String ok = request.getParameter("ok");
    String error = request.getParameter("error");
    if (error == null) error = (String) request.getAttribute("error");
    Prueba plantilla = (Prueba) request.getAttribute("plantilla");
    boolean editando = plantilla != null && plantilla.getId() != null;
    List<Ejercicio> ejerciciosGuardados = editando ? plantilla.getEjercicios() : Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | <%= editando ? "Editar plantilla" : "Crear plantilla" %></title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #e8f0f5; }
        header { padding: 28px 6vw; background: linear-gradient(135deg, #203a43 0%, #1f6f8b 100%); color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; border-bottom: 4px solid #6aaec5; }
        header h1 { margin: 0; font-size: 28px; letter-spacing: 0; }
        header a { color: white; text-decoration: none; font-weight: 700; border: 1px solid rgba(255,255,255,.35); border-radius: 6px; padding: 10px 13px; background: rgba(255,255,255,.10); }
        main { max-width: 1180px; margin: 24px auto 42px; padding: 0 18px; }
        .notice { padding: 12px 14px; border-radius: 8px; margin-bottom: 14px; border: 1px solid #badbcc; background: #edf8f1; color: #0f5132; }
        .error { border-color: #f2b8b5; background: #fff1f0; color: #8a1f17; }
        form { display: grid; gap: 18px; }
        section { background: #f8fbfd; border: 1px solid #c5d8e2; border-radius: 8px; padding: 0; overflow: hidden; box-shadow: 0 10px 26px rgba(32, 58, 67, .08); }
        section > h2 { margin: 0; padding: 14px 18px; font-size: 20px; color: white; background: #203a43; border-bottom: 3px solid #1f6f8b; }
        section > .grid, section > #ejercicios { padding: 18px; }
        h2 { margin: 0 0 14px; font-size: 20px; color: #203a43; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; }
        .options { display: grid; grid-template-columns: repeat(5, minmax(135px, 1fr)); gap: 12px; }
        .exercise { display: none; gap: 16px; margin-top: 16px; padding: 16px; border: 1px solid #c5d8e2; border-left: 5px solid #1f6f8b; border-radius: 8px; background: white; }
        .exercise.active { display: grid; }
        .exercise:first-child { margin-top: 0; }
        .exercise h2 { margin: 0; padding-bottom: 8px; border-bottom: 1px solid #d7e0e7; }
        label { display: grid; gap: 6px; font-size: 13px; font-weight: 700; color: #344453; }
        input, textarea { width: 100%; min-height: 42px; border: 1px solid #b7c9d4; border-radius: 6px; padding: 9px 11px; font: inherit; background: white; }
        input:focus, textarea:focus { outline: 2px solid rgba(31, 111, 139, .22); border-color: #1f6f8b; }
        textarea { min-height: 84px; resize: vertical; }
        .option { border: 1px solid #c5d8e2; border-radius: 8px; padding: 0; background: #f3f8fb; display: grid; overflow: hidden; }
        .option:hover { border-color: #6aaec5; background: #eef7fa; }
        .option label:first-child { padding: 10px; gap: 8px; }
        .option input[type="file"] { min-height: 36px; padding: 6px; font-size: 12px; background: white; }
        .check { display: flex; gap: 8px; align-items: center; margin: 0; padding: 10px; font-weight: 700; border-top: 1px solid #cfe0e9; background: white; }
        .check input { width: 18px; min-height: 18px; }
        .actions { display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .button, button { border: 0; border-radius: 6px; padding: 11px 16px; font-weight: 700; text-decoration: none; cursor: pointer; }
        .secondary { background: #dfe7ee; color: #243441; }
        .primary { background: #1f6f8b; color: white; }
        .answer-mode { max-width: 420px; }
        .answer-mode select { display: none; }
        .mode-control { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 6px; border: 1px solid #b7c9d4; border-radius: 8px; padding: 6px; background: #e8f0f5; }
        .mode-control button { min-height: 52px; padding: 9px 10px; border: 1px solid transparent; border-radius: 6px; background: transparent; color: #344453; text-align: left; }
        .mode-control button strong { display: block; color: #203a43; font-size: 14px; margin-bottom: 2px; }
        .mode-control button span { display: block; color: #52606d; font-size: 12px; line-height: 1.25; }
        .mode-control button.active { background: #1f6f8b; border-color: #1f6f8b; color: white; box-shadow: 0 6px 14px rgba(31, 111, 139, .20); }
        .mode-control button.active strong, .mode-control button.active span { color: white; }
        .preview { display: grid; border: 1px solid #d7e0e7; border-radius: 8px; background: #ffffff; width: 100%; height: 108px; padding: 8px; place-items: center; color: #6b7f8c; font-size: 12px; overflow: hidden; }
        .preview:empty::before { content: "Vista previa"; }
        .preview img { max-width: 100%; max-height: 100%; width: auto; height: auto; object-fit: contain; display: block; }
        .model-preview { width: 220px; max-width: 100%; height: 118px; justify-self: start; }
        .exercise-nav { display: flex; justify-content: space-between; align-items: center; gap: 12px; margin-top: 14px; padding: 12px; border: 1px solid #c5d8e2; border-radius: 8px; background: #edf5f8; }
        .exercise-nav strong { color: #203a43; }
        .exercise-nav div { display: flex; gap: 8px; flex-wrap: wrap; }
        @media (max-width: 900px) { .grid, .options { grid-template-columns: 1fr; } header { align-items: flex-start; flex-direction: column; } }
        @media (max-width: 560px) { .mode-control { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <header>
        <h1><%= editando ? "Editar plantilla visual" : "Crear plantilla visual" %></h1>
        <a href="<%= request.getContextPath() %>/evaluador-home.jsp">Volver al panel</a>
    </header>
    <main>
        <% if ("1".equals(ok)) { %><div class="notice">Plantilla guardada. Ya puedes crear otra o revisarla en Pruebas/Ejercicios.</div><% } %>
        <% if (error != null && !error.isEmpty()) { %><div class="notice error"><%= error %></div><% } %>
        <div id="client-error" class="notice error" style="display:none;"></div>
        <form id="plantillaForm" method="post" action="<%= request.getContextPath() %>/plantilla-wizard" enctype="multipart/form-data" novalidate>
            <% if (editando) { %><input type="hidden" name="pruebaId" value="<%= plantilla.getId() %>"/><% } %>
            <section>
                <h2>1. Datos de la plantilla</h2>
                <div class="grid">
                    <label>Nombre <input name="nombre" required placeholder="Ej. S2 Grupo A" value="<%= editando ? h(plantilla.getNombre()) : "" %>"/></label>
                    <label>Tiempo limite en minutos <input name="tiempoLimite" type="number" min="1" max="180" value="<%= editando ? h(plantilla.getTiempoLimite()) : "30" %>" required/></label>
                    <label>Cantidad de ejercicios de la prueba <input id="cantidadEjercicios" name="cantidadEjercicios" type="number" min="1" max="40" value="<%= editando ? h(plantilla.getCantidadEjercicios()) : "1" %>" required/></label>
                    <label>Estado <select name="estado">
                        <option value="ACTIVA" <%= editando && Prueba.EstadoPrueba.ACTIVA.equals(plantilla.getEstado()) ? "selected" : "" %>>Activa</option>
                        <option value="INACTIVA" <%= editando && Prueba.EstadoPrueba.INACTIVA.equals(plantilla.getEstado()) ? "selected" : "" %>>Inactiva</option>
                        <option value="ARCHIVADA" <%= editando && Prueba.EstadoPrueba.ARCHIVADA.equals(plantilla.getEstado()) ? "selected" : "" %>>Archivada</option>
                    </select></label>
                    <label>Descripcion <textarea name="descripcion" placeholder="Uso o indicaciones de esta plantilla"><%= editando ? h(plantilla.getDescripcion()) : "" %></textarea></label>
                </div>
            </section>
            <section>
                <h2>2. Ejercicios de la prueba</h2>
                <div id="ejercicios"></div>
                <div class="exercise-nav">
                    <strong id="exercise-counter">Ejercicio 1 de 1</strong>
                    <div>
                        <button class="secondary" type="button" id="prevExercise">Anterior</button>
                        <button class="primary" type="button" id="nextExercise">Siguiente</button>
                    </div>
                </div>
            </section>
            <div class="actions">
                <a class="button secondary" href="<%= request.getContextPath() %>/evaluador-home.jsp">Cancelar</a>
                <button class="primary" type="submit"><%= editando ? "Guardar cambios" : "Guardar plantilla" %></button>
            </div>
        </form>
    </main>
    <template id="tpl-ejercicio">
        <div class="exercise">
            <h2>Ejercicio __N__</h2>
            <div class="grid">
                <label>Enunciado <textarea name="enunciado__N__" required>Seleccione las figuras que corresponden al desplazamiento indicado.</textarea></label>
                <label>Imagen modelo <input name="imagenModelo__N__" type="file" accept="image/*" onchange="previsualizar(this)"/><span class="preview model-preview" data-existing=""></span></label>
                <label class="answer-mode">Tipo de respuesta
                    <select name="tipoRespuesta__N__" onchange="actualizarModoRespuesta(__N__)">
                        <option value="UNICA">Solo una opcion correcta</option>
                        <option value="MULTIPLE">Varias opciones correctas</option>
                    </select>
                    <span class="mode-control">
                        <button class="active" type="button" data-mode="UNICA" onclick="seleccionarTipo(this, __N__, 'UNICA')"><strong>Unica</strong><span>Una respuesta correcta</span></button>
                        <button type="button" data-mode="MULTIPLE" onclick="seleccionarTipo(this, __N__, 'MULTIPLE')"><strong>Multiple</strong><span>Dos o mas correctas</span></button>
                    </span>
                </label>
            </div>
            <div class="options">
                <div class="option"><label>Opcion A <input name="opcion__N__A" type="file" accept="image/*" onchange="previsualizar(this)"/><span class="preview" data-existing=""></span></label><label class="check"><input type="radio" name="correcta__N__" value="A"/> Correcta</label></div>
                <div class="option"><label>Opcion B <input name="opcion__N__B" type="file" accept="image/*" onchange="previsualizar(this)"/><span class="preview" data-existing=""></span></label><label class="check"><input type="radio" name="correcta__N__" value="B"/> Correcta</label></div>
                <div class="option"><label>Opcion C <input name="opcion__N__C" type="file" accept="image/*" onchange="previsualizar(this)"/><span class="preview" data-existing=""></span></label><label class="check"><input type="radio" name="correcta__N__" value="C"/> Correcta</label></div>
                <div class="option"><label>Opcion D <input name="opcion__N__D" type="file" accept="image/*" onchange="previsualizar(this)"/><span class="preview" data-existing=""></span></label><label class="check"><input type="radio" name="correcta__N__" value="D"/> Correcta</label></div>
                <div class="option"><label>Opcion E <input name="opcion__N__E" type="file" accept="image/*" onchange="previsualizar(this)"/><span class="preview" data-existing=""></span></label><label class="check"><input type="radio" name="correcta__N__" value="E"/> Correcta</label></div>
            </div>
        </div>
    </template>
    <script>
        const contextPath = '<%= request.getContextPath() %>';
        const datosGuardados = {
            ejercicios: [
                <% for (int i = 0; i < ejerciciosGuardados.size(); i++) {
                    Ejercicio e = ejerciciosGuardados.get(i);
                %>
                {
                    numero: <%= e.getNumero() %>,
                    enunciado: "<%= js(e.getEnunciado()) %>",
                    tipoRespuesta: "<%= e.getTipoRespuesta() == null ? "UNICA" : e.getTipoRespuesta().name() %>",
                    imagenModelo: "<%= js(e.getImagenModelo()) %>",
                    opciones: {
                        <% for (OpcionEjercicio.LetraOpcion letra : OpcionEjercicio.LetraOpcion.values()) {
                            OpcionEjercicio op = opcion(e, letra);
                        %>
                        <%= letra.name() %>: { imagen: "<%= js(op == null ? "" : op.getImagenOpcion()) %>", correcta: <%= op != null && Boolean.TRUE.equals(op.getEsCorrecta()) %> },
                        <% } %>
                    }
                }<%= i + 1 < ejerciciosGuardados.size() ? "," : "" %>
                <% } %>
            ]
        };
        const cantidad = document.getElementById('cantidadEjercicios');
        const contenedor = document.getElementById('ejercicios');
        const template = document.getElementById('tpl-ejercicio').innerHTML;
        const counter = document.getElementById('exercise-counter');
        const prevExercise = document.getElementById('prevExercise');
        const nextExercise = document.getElementById('nextExercise');
        let ejercicioActivo = 1;
        document.addEventListener('submit', function (event) {
            if (!event.target || event.target.id !== 'plantillaForm') return;
            const nombre = document.querySelector('[name="nombre"]');
            if (!nombre || nombre.value.trim()) return;
            event.preventDefault();
            event.stopImmediatePropagation();
            mostrarErrorCliente(['Datos de la plantilla: escribe el nombre.']);
            nombre.focus();
        }, true);
        function renderEjercicios() {
            const total = Math.max(1, Math.min(40, parseInt(cantidad.value || '1', 10)));
            const actuales = {};
            contenedor.querySelectorAll('textarea').forEach(el => actuales[el.name] = el.value);
            contenedor.querySelectorAll('select').forEach(el => actuales[el.name] = el.value);
            contenedor.querySelectorAll('input[name^="correcta"]').forEach(el => {
                if (el.checked) actuales[el.name + ':' + el.value] = true;
            });
            contenedor.innerHTML = '';
            for (let i = 1; i <= total; i++) {
                contenedor.insertAdjacentHTML('beforeend', template.replaceAll('__N__', i));
            }
            aplicarDatosGuardados();
            contenedor.querySelectorAll('textarea').forEach(el => { if (actuales[el.name] !== undefined) el.value = actuales[el.name]; });
            contenedor.querySelectorAll('select').forEach(el => { if (actuales[el.name] !== undefined) el.value = actuales[el.name]; });
            for (let i = 1; i <= total; i++) actualizarModoRespuesta(i);
            if (Object.keys(actuales).some(nombre => nombre.startsWith('correcta'))) {
                contenedor.querySelectorAll('input[name^="correcta"]').forEach(el => {
                    el.checked = actuales[el.name + ':' + el.value] === true || actuales[el.name + '[]:' + el.value] === true;
                });
            }
            ejercicioActivo = Math.min(ejercicioActivo, total);
            mostrarEjercicio(ejercicioActivo);
        }
        function aplicarDatosGuardados() {
            datosGuardados.ejercicios.forEach(ejercicio => {
                const numero = ejercicio.numero;
                const enunciado = document.querySelector('[name="enunciado' + numero + '"]');
                const tipo = document.querySelector('[name="tipoRespuesta' + numero + '"]');
                if (enunciado) enunciado.value = ejercicio.enunciado || '';
                if (tipo) tipo.value = ejercicio.tipoRespuesta || 'UNICA';
                mostrarImagenExistente('imagenModelo' + numero, ejercicio.imagenModelo);
                ['A', 'B', 'C', 'D', 'E'].forEach(letra => {
                    const opcion = ejercicio.opciones[letra] || {};
                    mostrarImagenExistente('opcion' + numero + letra, opcion.imagen);
                    const correcta = document.querySelector('[name="correcta' + numero + '"][value="' + letra + '"]');
                    if (correcta) correcta.checked = opcion.correcta === true;
                });
            });
        }
        function mostrarImagenExistente(nombreInput, ruta) {
            if (!ruta) return;
            const input = document.querySelector('[name="' + nombreInput + '"]');
            const preview = input ? input.parentElement.querySelector('.preview') : null;
            if (!preview) return;
            preview.dataset.existing = ruta;
            const limpia = ruta.replace(/^[\/\\]+/, '').replaceAll('\\', '/');
            preview.innerHTML = '<img src="' + contextPath + '/' + limpia + '" alt="Vista previa guardada"/>';
        }
        function mostrarEjercicio(numero) {
            const total = Math.max(1, Math.min(40, parseInt(cantidad.value || '1', 10)));
            ejercicioActivo = Math.max(1, Math.min(numero, total));
            contenedor.querySelectorAll('.exercise').forEach((el, index) => {
                el.classList.toggle('active', index + 1 === ejercicioActivo);
            });
            counter.textContent = 'Ejercicio ' + ejercicioActivo + ' de ' + total;
            prevExercise.disabled = ejercicioActivo === 1;
            nextExercise.textContent = ejercicioActivo === total ? 'Ultimo ejercicio' : 'Siguiente';
            nextExercise.disabled = ejercicioActivo === total;
        }
        function actualizarModoRespuesta(numero) {
            const modo = document.querySelector('[name="tipoRespuesta' + numero + '"]');
            const multiple = modo && modo.value === 'MULTIPLE';
            document.querySelectorAll('[name="correcta' + numero + '"], [name="correcta' + numero + '[]"]').forEach(el => {
                const marcado = el.checked;
                el.type = multiple ? 'checkbox' : 'radio';
                el.name = multiple ? 'correcta' + numero + '[]' : 'correcta' + numero;
                el.checked = marcado;
            });
            sincronizarControlModo(numero);
        }
        function seleccionarTipo(button, numero, modo) {
            const select = document.querySelector('[name="tipoRespuesta' + numero + '"]');
            if (!select) return;
            select.value = modo;
            actualizarModoRespuesta(numero);
        }
        function sincronizarControlModo(numero) {
            const select = document.querySelector('[name="tipoRespuesta' + numero + '"]');
            const control = select ? select.parentElement.querySelector('.mode-control') : null;
            if (!select || !control) return;
            control.querySelectorAll('button').forEach(button => {
                button.classList.toggle('active', button.dataset.mode === select.value);
            });
        }
        function previsualizar(input) {
            const preview = input.parentElement.querySelector('.preview');
            if (!preview) return;
            if (!input.files || !input.files[0]) {
                preview.innerHTML = '';
                preview.style.display = 'grid';
                return;
            }
            const url = URL.createObjectURL(input.files[0]);
            preview.innerHTML = '<img src="' + url + '" alt="Vista previa"/>';
            preview.style.display = 'grid';
        }
        cantidad.addEventListener('change', renderEjercicios);
        cantidad.addEventListener('input', renderEjercicios);
        prevExercise.addEventListener('click', () => mostrarEjercicio(ejercicioActivo - 1));
        nextExercise.addEventListener('click', () => mostrarEjercicio(ejercicioActivo + 1));
        renderEjercicios();
        document.getElementById('plantillaForm').addEventListener('submit', function (event) {
            const total = Math.max(1, Math.min(40, parseInt(cantidad.value || '1', 10)));
            const errores = [];
            const nombre = document.querySelector('[name="nombre"]');
            const tiempoLimite = document.querySelector('[name="tiempoLimite"]');
            if (!nombre.value.trim()) errores.push('Datos de la plantilla: escribe el nombre.');
            const minutos = parseInt(tiempoLimite.value || '0', 10);
            if (!minutos || minutos < 1 || minutos > 180) errores.push('Datos de la plantilla: el tiempo limite debe estar entre 1 y 180 minutos.');
            if (total < 1 || total > 40) errores.push('Datos de la plantilla: la cantidad de ejercicios debe estar entre 1 y 40.');
            for (let i = 1; i <= total; i++) {
                const enunciado = document.querySelector('[name="enunciado' + i + '"]').value.trim();
                const modo = document.querySelector('[name="tipoRespuesta' + i + '"]').value;
                const marcadas = document.querySelectorAll('[name="correcta' + i + '"]:checked, [name="correcta' + i + '[]"]:checked');
                const faltantes = [];
                if (!enunciado) faltantes.push('enunciado');
                if (!archivoDisponible('imagenModelo' + i)) faltantes.push('modelo');
                ['A', 'B', 'C', 'D', 'E'].forEach(letra => {
                    if (!archivoDisponible('opcion' + i + letra)) faltantes.push('opcion ' + letra);
                });
                let respuesta = '';
                if (marcadas.length === 0) respuesta = 'marca la respuesta correcta';
                else if (modo === 'UNICA' && marcadas.length !== 1) respuesta = 'deja solo una correcta';
                else if (modo === 'MULTIPLE' && marcadas.length < 2) respuesta = 'marca dos o mas correctas';
                if (faltantes.length || respuesta) {
                    let mensaje = 'Ejercicio ' + i + ': ';
                    const partes = [];
                    if (faltantes.length) partes.push('sube imagenes faltantes (' + faltantes.join(', ') + ')');
                    if (respuesta) partes.push(respuesta);
                    errores.push(mensaje + partes.join(' y '));
                }
            }
            if (errores.length) {
                event.preventDefault();
                const primerError = errores[0].match(/Ejercicio (\d+)/);
                if (primerError) mostrarEjercicio(parseInt(primerError[1], 10));
                mostrarErrorCliente(errores);
            }
        });
        function mostrarErrorCliente(errores) {
            const error = document.getElementById('client-error');
            error.innerHTML = '<strong>Revisa la plantilla antes de guardar:</strong><ul><li>' + errores.join('</li><li>') + '</li></ul>';
            error.style.display = 'block';
            error.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
        function archivoSeleccionado(nombre) {
            const input = document.querySelector('[name="' + nombre + '"]');
            return input && input.files && input.files.length > 0;
        }
        function archivoDisponible(nombre) {
            const input = document.querySelector('[name="' + nombre + '"]');
            const preview = input ? input.parentElement.querySelector('.preview') : null;
            return archivoSeleccionado(nombre) || (preview && preview.dataset.existing);
        }
    </script>
</body>
</html>
