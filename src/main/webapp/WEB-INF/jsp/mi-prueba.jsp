<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.aptispace.modelo.*" %>
<%@ page import="com.aptispace.web.MiPruebaServlet" %>
<%
    Boolean sinPrueba = (Boolean) request.getAttribute("sinPrueba");
    AplicacionPrueba aplicacion = (AplicacionPrueba) request.getAttribute("aplicacion");
    RespuestaEvaluado respuesta = (RespuestaEvaluado) request.getAttribute("respuesta");
    int indice = request.getAttribute("indice") == null ? 0 : (Integer) request.getAttribute("indice");
    int total = request.getAttribute("total") == null ? 0 : (Integer) request.getAttribute("total");
    boolean finalizada = aplicacion != null && AplicacionPrueba.EstadoAplicacion.FINALIZADA.equals(aplicacion.getEstado());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Mi prueba</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; background: #eef3f7; color: #1f2937; }
        header { padding: 22px 6vw; background: linear-gradient(135deg, rgba(31, 75, 93, .94), rgba(45, 156, 219, .76)), url("<%= request.getContextPath() %>/images/s2/modelo-06.svg"); background-size: cover; background-position: center; color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; }
        header h1 { margin: 0; font-size: 24px; letter-spacing: 0; }
        header a { color: #d8e5ee; text-decoration: none; font-weight: 700; }
        main { max-width: 1180px; margin: 24px auto 40px; padding: 0 18px; }
        .status { display: flex; justify-content: space-between; gap: 14px; align-items: center; margin-bottom: 16px; color: #1f4b5d; background: #e8f4f8; border: 1px solid #9cc9d8; border-radius: 8px; padding: 12px; }
        .bar { height: 8px; background: #d9e2ec; border-radius: 999px; overflow: hidden; margin-bottom: 18px; }
        .bar span { display: block; height: 100%; background: #1f6f8b; width: <%= total == 0 ? 0 : ((indice + 1) * 100 / total) %>%; }
        .card { background: #d9edf4; border: 1px solid #6aaec5; border-radius: 8px; padding: 20px; box-shadow: 0 10px 26px rgba(31, 111, 139, .12); }
        .question { display: grid; grid-template-columns: minmax(0, 1.05fr) minmax(320px, .95fr); gap: 20px; align-items: start; }
        .model { border: 1px solid #b9d5df; border-radius: 8px; background: #f6fbfd; padding: 16px; }
        .model img { width: 100%; display: block; max-height: 430px; object-fit: contain; }
        .model h2 { margin: 0 0 12px; font-size: 20px; }
        .model p { margin: 0 0 14px; color: #52606d; line-height: 1.45; }
        .options { display: grid; gap: 12px; }
        .option { display: grid; grid-template-columns: 42px 1fr; gap: 12px; align-items: center; border: 1px solid #b9d5df; border-radius: 8px; padding: 10px; cursor: pointer; background: #f6fbfd; }
        .option input { width: 20px; height: 20px; justify-self: center; }
        .option img { width: 100%; max-height: 120px; object-fit: contain; display: block; transition: transform .18s ease; }
        .image-tools { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
        .image-tools button { padding: 8px 10px; background: #e2e8f0; color: #1f2937; }
        .actions { display: flex; justify-content: space-between; gap: 12px; margin-top: 18px; flex-wrap: wrap; }
        button, .button { border: 0; border-radius: 6px; padding: 11px 16px; font-weight: 700; cursor: pointer; text-decoration: none; display: inline-block; }
        .secondary { background: #e2e8f0; color: #1f2937; }
        .primary { background: #1f6f8b; color: white; }
        .danger { background: #b42318; color: white; }
        .empty { max-width: 760px; }
        .result { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-top: 16px; }
        .metric { border: 1px solid #b9d5df; border-radius: 8px; padding: 14px; background: #f6fbfd; }
        .metric strong { display: block; font-size: 24px; color: #17384d; }
        @media (max-width: 900px) { .question { grid-template-columns: 1fr; } .result { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 560px) { header { align-items: flex-start; flex-direction: column; } .result { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <header>
        <h1>AptiSpace | Mi prueba</h1>
        <a href="<%= request.getContextPath() %>/logout">Cerrar sesion</a>
    </header>
    <main>
        <% if (Boolean.TRUE.equals(sinPrueba)) { %>
            <section class="card empty">
                <h2>No hay una prueba asignada</h2>
                <p>Cuando el evaluador asigne e inicie una aplicacion, aparecera aqui para responderla una pregunta a la vez.</p>
                <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
            </section>
        <% } else if (total == 0) { %>
            <section class="card empty">
                <h2>La aplicacion no tiene ejercicios asignados</h2>
                <p>El evaluador debe iniciar la prueba para generar los ejercicios aleatorios.</p>
                <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
            </section>
        <% } else { %>
            <div class="status">
                <span><%= aplicacion.getPrueba().getNombre() %></span>
                <strong>Pregunta <%= indice + 1 %> de <%= total %></strong>
            </div>
            <div class="bar"><span></span></div>
            <section class="card">
                <% if (finalizada && aplicacion.getResultado() != null) { %>
                    <h2>Prueba finalizada</h2>
                    <p>Tu resultado ya fue calculado para esta aplicacion.</p>
                    <div class="result">
                        <div class="metric"><span>Aciertos</span><strong><%= aplicacion.getResultado().getAciertos() %></strong></div>
                        <div class="metric"><span>Errores</span><strong><%= aplicacion.getResultado().getErrores() %></strong></div>
                        <div class="metric"><span>Sin responder</span><strong><%= aplicacion.getResultado().getSinResponder() %></strong></div>
                        <div class="metric"><span>S2</span><strong><%= aplicacion.getResultado().getPuntuacionS2() %></strong></div>
                    </div>
                    <div class="actions">
                        <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
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
                                <% for (OpcionEjercicio opcion : respuesta.getEjercicio().getOpciones()) { %>
                                    <label class="option">
                                        <input type="radio" name="opcion" value="<%= opcion.getLetra().name() %>" <%= MiPruebaServlet.seleccionada(respuesta, opcion.getLetra()) ? "checked" : "" %>/>
                                        <span>
                                            <strong>Opcion <%= opcion.getLetra().name() %></strong>
                                            <% if (opcion.getImagenOpcion() != null) { %>
                                                <img class="rotatable" data-rotation="0" src="<%= request.getContextPath() %>/<%= opcion.getImagenOpcion() %>" alt="Opcion <%= opcion.getLetra().name() %>"/>
                                                <div class="image-tools">
                                                    <button type="button" onclick="rotar(this, -90)">Izq.</button>
                                                    <button type="button" onclick="rotar(this, 90)">Der.</button>
                                                </div>
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
        function rotar(button, grados) {
            const box = button.closest('.model, .option');
            const img = box.querySelector('.rotatable');
            const actual = parseInt(img.dataset.rotation || '0', 10);
            const nuevo = (actual + grados + 360) % 360;
            img.dataset.rotation = nuevo;
            img.style.transform = 'rotate(' + nuevo + 'deg)';
        }
    </script>
</body>
</html>
