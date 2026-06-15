<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.aptispace.modelo.*" %>
<%@ page import="com.aptispace.web.MiPruebaServlet" %>
<%
    Boolean sinPrueba = (Boolean) request.getAttribute("sinPrueba");
    AplicacionPrueba aplicacion = (AplicacionPrueba) request.getAttribute("aplicacion");
    RespuestaEvaluado respuesta = (RespuestaEvaluado) request.getAttribute("respuesta");
    int indice = request.getAttribute("indice") == null ? 0 : (Integer) request.getAttribute("indice");
    int total = request.getAttribute("total") == null ? 0 : (Integer) request.getAttribute("total");
    int segundosRestantes = request.getAttribute("segundosRestantes") == null ? 0 : (Integer) request.getAttribute("segundosRestantes");
    boolean finalizada = aplicacion != null && AplicacionPrueba.EstadoAplicacion.FINALIZADA.equals(aplicacion.getEstado());
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Responder prueba</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; background: #edf5fb; color: #172033; }
        header { padding: 22px 6vw; background: linear-gradient(135deg, #16324f, #1f7fa3); color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; }
        header h1 { margin: 0; font-size: 24px; }
        header a { border-radius: 6px; border: 1px solid rgba(255,255,255,.35); color: white; text-decoration: none; font-weight: 700; padding: 10px 13px; }
        main { max-width: 1180px; margin: 24px auto 40px; padding: 0 18px; }
        .status { display: flex; justify-content: space-between; gap: 14px; align-items: center; margin-bottom: 16px; color: #16324f; background: #e3f3fa; border: 1px solid #b7d9e8; border-radius: 8px; padding: 12px; }
        .timer { display: inline-flex; align-items: center; justify-content: center; min-width: 96px; border-radius: 6px; background: #16324f; color: white; padding: 8px 10px; font-weight: 800; }
        .timer.warn { background: #b42318; }
        .bar { height: 8px; background: #d9e7f0; border-radius: 999px; overflow: hidden; margin-bottom: 18px; }
        .bar span { display: block; height: 100%; background: #1f7fa3; width: <%= total == 0 ? 0 : ((indice + 1) * 100 / total) %>%; }
        .card { background: linear-gradient(180deg, #ffffff, #f4fbfe); border: 1px solid #b9d5df; border-radius: 8px; padding: 20px; box-shadow: 0 14px 30px rgba(22, 50, 79, .10); }
        .question { display: grid; grid-template-columns: minmax(0, 1.05fr) minmax(320px, .95fr); gap: 20px; align-items: start; }
        .model { border: 1px solid #c6dce8; border-radius: 8px; background: #f7fcff; padding: 16px; }
        .model img { width: 100%; display: block; max-height: 430px; object-fit: contain; }
        .model h2 { margin: 0 0 12px; font-size: 20px; color: #16324f; }
        .model p { margin: 0 0 14px; color: #52606d; line-height: 1.45; }
        .options { display: grid; gap: 12px; }
        .option { display: grid; grid-template-columns: 42px 1fr; gap: 12px; align-items: center; border: 1px solid #c6dce8; border-radius: 8px; padding: 10px; cursor: pointer; background: #f7fcff; }
        .option:hover { border-color: #1f7fa3; background: #eef8fc; }
        .option input { width: 20px; height: 20px; justify-self: center; }
        .option img { width: 100%; max-height: 120px; object-fit: contain; display: block; }
        .actions { display: flex; justify-content: space-between; gap: 12px; margin-top: 18px; flex-wrap: wrap; }
        button, .button { border: 0; border-radius: 6px; padding: 11px 16px; font-weight: 700; cursor: pointer; text-decoration: none; display: inline-block; }
        .secondary { background: #16324f; color: white; }
        .primary { background: #1f7fa3; color: white; }
        .danger { background: #b42318; color: white; }
        .empty { max-width: 760px; }
        .notice { margin-bottom: 14px; padding: 12px; border-radius: 8px; border: 1px solid #f2b8b5; background: #fff1f0; color: #8a1f17; }
        .result { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-top: 16px; }
        .metric { border: 1px solid #c6dce8; border-radius: 8px; padding: 14px; background: #f7fcff; }
        .metric strong { display: block; font-size: 24px; color: #16324f; }
        @media (max-width: 900px) { .question { grid-template-columns: 1fr; } .result { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 560px) { header { align-items: flex-start; flex-direction: column; } .result { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <header>
        <h1>AptiSpace | Responder prueba</h1>
        <a href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
    </header>
    <main>
        <% if (error != null && !error.isEmpty()) { %><div class="notice"><%= error %></div><% } %>
        <% if (Boolean.TRUE.equals(sinPrueba)) { %>
            <section class="card empty">
                <h2>No hay una prueba asignada</h2>
                <p>Cuando el evaluador asigne e inicie una aplicación, aparecerá aquí para responderla.</p>
                <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
            </section>
        <% } else if (total == 0) { %>
            <section class="card empty">
                <h2>La aplicación no tiene ejercicios asignados</h2>
                <p>El evaluador debe iniciar la prueba para generar los ejercicios.</p>
                <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
            </section>
        <% } else { %>
            <div class="status">
                <span><%= aplicacion.getPrueba().getNombre() %></span>
                <strong>Pregunta <%= indice + 1 %> de <%= total %></strong>
                <% if (!finalizada) { %><span id="contador" class="timer" data-seconds="<%= segundosRestantes %>">--:--</span><% } %>
            </div>
            <div class="bar"><span></span></div>
            <section class="card">
                <% if (finalizada && aplicacion.getResultado() != null) { %>
                    <h2>Felicidades, completaste la prueba</h2>
                    <p>Tu resultado ya fue guardado. Puedes verlo con más detalle en el dashboard de resultados.</p>
                    <div class="result">
                        <div class="metric"><span>Aciertos</span><strong><%= aplicacion.getResultado().getAciertos() %></strong></div>
                        <div class="metric"><span>Errores</span><strong><%= aplicacion.getResultado().getErrores() %></strong></div>
                        <div class="metric"><span>Sin responder</span><strong><%= aplicacion.getResultado().getSinResponder() %></strong></div>
                        <div class="metric"><span>S2</span><strong><%= aplicacion.getResultado().getPuntuacionS2() %></strong></div>
                    </div>
                    <div class="actions">
                        <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
                        <a class="button primary" href="<%= request.getContextPath() %>/mi-resultados?aplicacionId=<%= aplicacion.getId() %>">Ver resultado</a>
                        <% if (Boolean.TRUE.equals(aplicacion.getAutorizadaReaplicacion())) { %>
                            <form method="post" action="<%= request.getContextPath() %>/mi-prueba">
                                <button class="primary" type="submit" name="accion" value="reaplicar">Volver a hacer</button>
                            </form>
                        <% } %>
                    </div>
                <% } else { %>
                    <form method="post" action="<%= request.getContextPath() %>/mi-prueba">
                        <input type="hidden" name="i" value="<%= indice %>"/>
                        <div class="question">
                            <div class="model">
                                <h2>Ejercicio <%= respuesta.getEjercicio().getNumero() %></h2>
                                <p><%= respuesta.getEjercicio().getEnunciado() == null ? "Seleccione las opciones correctas." : respuesta.getEjercicio().getEnunciado() %></p>
                                <% if (respuesta.getEjercicio().getImagenModelo() != null) { %>
                                    <img src="<%= request.getContextPath() %>/<%= respuesta.getEjercicio().getImagenModelo() %>" alt="Imagen del ejercicio"/>
                                <% } %>
                            </div>
                            <div class="options">
                                <% boolean multiple = Ejercicio.TipoRespuesta.MULTIPLE.equals(respuesta.getEjercicio().getTipoRespuesta()); %>
                                <% for (OpcionEjercicio opcion : respuesta.getEjercicio().getOpciones()) { %>
                                    <label class="option">
                                        <input type="<%= multiple ? "checkbox" : "radio" %>" name="<%= multiple ? "opciones" : "opcion" %>" value="<%= opcion.getLetra().name() %>" <%= MiPruebaServlet.seleccionada(respuesta, opcion.getLetra()) ? "checked" : "" %>/>
                                        <span>
                                            <strong>Opción <%= opcion.getLetra().name() %></strong>
                                            <% if (opcion.getImagenOpcion() != null) { %>
                                                <img src="<%= request.getContextPath() %>/<%= opcion.getImagenOpcion() %>" alt="Opción <%= opcion.getLetra().name() %>"/>
                                            <% } %>
                                        </span>
                                    </label>
                                <% } %>
                            </div>
                        </div>
                        <div class="actions">
                            <button class="secondary" type="submit" name="accion" value="anterior" <%= indice == 0 ? "disabled" : "" %>>Anterior</button>
                            <% if (indice + 1 == total) { %>
                                <button class="danger" type="submit" name="accion" value="finalizar">Finalizar prueba</button>
                            <% } else { %>
                                <button class="primary" type="submit" name="accion" value="siguiente">Guardar y siguiente</button>
                            <% } %>
                        </div>
                    </form>
                <% } %>
            </section>
        <% } %>
    </main>
    <script>
        const contador = document.getElementById('contador');
        if (contador) {
            let restantes = parseInt(contador.dataset.seconds || '0', 10);
            const form = document.querySelector('form[action$="/mi-prueba"]');
            function pintarContador() {
                const minutos = Math.floor(Math.max(0, restantes) / 60);
                const segundos = Math.max(0, restantes) % 60;
                contador.textContent = String(minutos).padStart(2, '0') + ':' + String(segundos).padStart(2, '0');
                contador.classList.toggle('warn', restantes <= 60);
                if (restantes <= 0 && form) {
                    const accion = document.createElement('input');
                    accion.type = 'hidden';
                    accion.name = 'accion';
                    accion.value = 'finalizar';
                    form.appendChild(accion);
                    form.submit();
                    return;
                }
                restantes--;
                window.setTimeout(pintarContador, 1000);
            }
            pintarContador();
        }
    </script>
</body>
</html>
