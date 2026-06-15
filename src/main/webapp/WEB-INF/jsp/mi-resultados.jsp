<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.aptispace.modelo.*" %>
<%!
    java.time.format.DateTimeFormatter fechaCorta = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String h(Object v) {
        if (v == null) return "";
        return String.valueOf(v).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    String f(java.time.LocalDateTime fecha) {
        return fecha == null ? "" : fecha.format(fechaCorta);
    }
    int intento(AplicacionPrueba actual, List<AplicacionPrueba> aplicaciones) {
        if (actual == null || actual.getEvaluado() == null || actual.getPrueba() == null) return 1;
        int intento = 1;
        for (AplicacionPrueba otra : aplicaciones) {
            if (otra == null || otra.getId() == null || actual.getId() == null) continue;
            if (otra.getId() >= actual.getId()) continue;
            if (otra.getEvaluado() != null && otra.getPrueba() != null
                && otra.getEvaluado().getId().equals(actual.getEvaluado().getId())
                && otra.getPrueba().getId().equals(actual.getPrueba().getId())) intento++;
        }
        return intento;
    }
%>
<%
    List<AplicacionPrueba> historial = (List<AplicacionPrueba>) request.getAttribute("historial");
    if (historial == null) historial = Collections.emptyList();
    AplicacionPrueba seleccionada = (AplicacionPrueba) request.getAttribute("seleccionada");
    ResultadoPrueba resultado = seleccionada == null ? null : seleccionada.getResultado();
    int total = seleccionada == null ? 0 : seleccionada.getRespuestas().size();
    int aciertos = resultado == null ? 0 : resultado.getAciertos();
    int porcentaje = total == 0 ? 0 : Math.round((float) aciertos * 100 / total);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Mis resultados</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #172033; background: #eef5fb; }
        header { padding: 28px 7vw; background: linear-gradient(135deg, #16324f, #1f7fa3); color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; }
        header h1 { margin: 0 0 6px; font-size: 28px; }
        header p { margin: 0; color: #d7ecf6; }
        header a, .button { border: 0; border-radius: 6px; padding: 10px 13px; font-weight: 700; text-decoration: none; cursor: pointer; }
        header a { color: white; border: 1px solid rgba(255,255,255,.35); }
        main { max-width: 1180px; margin: 24px auto 44px; padding: 0 18px; }
        .shell { display: grid; grid-template-columns: 360px minmax(0, 1fr); gap: 18px; align-items: start; }
        .panel { background: linear-gradient(180deg, #ffffff, #f5fbfe); border: 1px solid #c5ddec; border-radius: 8px; box-shadow: 0 14px 30px rgba(22, 50, 79, .08); overflow: hidden; }
        .panel-head { padding: 16px 18px; background: linear-gradient(135deg, #16324f, #1f7fa3); color: white; }
        .panel-head h2 { margin: 0 0 4px; font-size: 19px; }
        .panel-head p { margin: 0; color: #dff3fa; line-height: 1.4; }
        .panel-body { padding: 18px; }
        label { display: grid; gap: 7px; font-weight: 700; color: #20374d; }
        .selector-box { display: grid; gap: 12px; padding: 14px; border: 1px solid #9cc9d8; border-radius: 8px; background: linear-gradient(135deg, #dff1f8, #ffffff); box-shadow: inset 0 1px 0 rgba(255,255,255,.8), 0 10px 22px rgba(31, 127, 163, .10); }
        .selector-box span { color: #52606d; font-size: 13px; line-height: 1.35; }
        select {
            width: 100%;
            min-height: 56px;
            border: 1px solid #5fa5c0;
            border-radius: 6px;
            padding: 12px 44px 12px 13px;
            font: inherit;
            font-weight: 800;
            color: #16324f;
            appearance: none;
            background:
                linear-gradient(45deg, transparent 50%, #1f6f8b 50%) calc(100% - 23px) 50% / 8px 8px no-repeat,
                linear-gradient(135deg, #ffffff 0%, #eef8fc 100%);
            box-shadow: inset 0 1px 0 rgba(255,255,255,.8), 0 10px 20px rgba(31, 127, 163, .12);
        }
        select:hover { border-color: #1f7fa3; }
        select:focus { outline: 3px solid rgba(31, 127, 163, .22); border-color: #1f6f8b; }
        .metrics { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 16px; }
        .metric { border: 1px solid #c5ddec; border-radius: 8px; padding: 14px; background: linear-gradient(180deg, #f8fcff, #edf6fb); }
        .metric span { display: block; color: #5b6f82; margin-bottom: 6px; font-size: 13px; }
        .metric strong { color: #16324f; font-size: 28px; }
        .scoreboard { display: grid; grid-template-columns: minmax(180px, .8fr) minmax(0, 1.2fr); gap: 16px; align-items: stretch; margin-bottom: 16px; }
        .score-main { border-radius: 8px; padding: 18px; background: linear-gradient(135deg, #16324f, #1f7fa3); color: white; display: grid; align-content: center; }
        .score-main span { color: #dff3fa; font-weight: 700; }
        .score-main strong { display: block; font-size: 52px; line-height: 1; margin-top: 8px; }
        .score-context { border: 1px solid #c5ddec; border-radius: 8px; padding: 16px; background: #f8fcff; display: grid; gap: 10px; }
        .score-context h3 { margin: 0; color: #16324f; }
        .score-context p { margin: 0; color: #52606d; line-height: 1.45; }
        .summary { display: grid; gap: 10px; margin-bottom: 16px; padding: 14px; border-radius: 8px; background: #e7f5fb; border: 1px solid #b8d9e9; color: #20374d; }
        .summary strong { color: #0f5f7f; }
        .answers { display: grid; gap: 10px; }
        .answer { display: grid; grid-template-columns: 82px minmax(0, 1fr) auto; gap: 12px; align-items: center; border: 1px solid #d4e3ee; border-radius: 8px; padding: 12px; background: linear-gradient(180deg, #ffffff, #f6fbfe); }
        .answer.ok { border-left: 5px solid #148f5b; }
        .answer.bad { border-left: 5px solid #c0392b; }
        .badge { display: inline-block; border-radius: 999px; padding: 5px 9px; font-weight: 800; font-size: 12px; background: #e1edf5; color: #20374d; }
        .badge.ok { background: #dff7ea; color: #12633f; }
        .badge.bad { background: #fde5e1; color: #8a2419; }
        .empty { padding: 24px; text-align: center; color: #5b6f82; }
        @media (max-width: 900px) { .shell { grid-template-columns: 1fr; } .metrics { grid-template-columns: repeat(2, 1fr); } .scoreboard { grid-template-columns: 1fr; } }
        @media (max-width: 560px) { header { align-items: flex-start; flex-direction: column; } .metrics, .answer { grid-template-columns: 1fr; } .score-main strong { font-size: 42px; } }
    </style>
</head>
<body>
    <header>
        <div>
            <h1>Mis resultados</h1>
            <p>Selecciona una prueba o intento para revisar tu desempeño.</p>
        </div>
        <a href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
    </header>
    <main>
        <% if (historial.isEmpty()) { %>
            <section class="panel empty">Todavía no tienes resultados finalizados.</section>
        <% } else { %>
            <div class="shell">
                <aside class="panel">
                    <div class="panel-head">
                        <h2>Prueba e intento</h2>
                        <p>Cambia entre tus aplicaciones finalizadas.</p>
                    </div>
                    <div class="panel-body">
                        <form method="get" class="selector-box">
                            <span>Elige la prueba y el intento que quieres revisar.</span>
                            <label>Resultado
                                <select name="aplicacionId" onchange="this.form.submit()">
                                    <% for (AplicacionPrueba app : historial) { %>
                                        <option value="<%= app.getId() %>" <%= seleccionada != null && app.getId().equals(seleccionada.getId()) ? "selected" : "" %>>
                                            <%= h(app.getPrueba() == null ? "Prueba" : app.getPrueba().getNombre()) %> - Intento <%= intento(app, historial) %> - <%= f(app.getFechaFin()) %>
                                        </option>
                                    <% } %>
                                </select>
                            </label>
                        </form>
                    </div>
                </aside>
                <section class="panel">
                    <div class="panel-head">
                        <h2><%= h(seleccionada.getPrueba() == null ? "Resultado" : seleccionada.getPrueba().getNombre()) %></h2>
                        <p>Intento <%= intento(seleccionada, historial) %> · finalizado <%= f(seleccionada.getFechaFin()) %></p>
                    </div>
                    <div class="panel-body">
                        <div class="scoreboard">
                            <div class="score-main"><span>Puntuacion S2</span><strong><%= resultado.getPuntuacionS2() %></strong></div>
                            <div class="score-context">
                                <h3>Dashboard del intento <%= intento(seleccionada, historial) %></h3>
                                <p><%= h(seleccionada.getPrueba() == null ? "Prueba" : seleccionada.getPrueba().getNombre()) %> finalizada el <%= f(seleccionada.getFechaFin()) %>.</p>
                                <p>Este panel es solo para revisar resultados; para responder una aplicacion usa Hacer prueba.</p>
                            </div>
                        </div>
                        <div class="metrics">
                            <div class="metric"><span>Aciertos</span><strong><%= resultado.getAciertos() %></strong></div>
                            <div class="metric"><span>Errores</span><strong><%= resultado.getErrores() %></strong></div>
                            <div class="metric"><span>Sin responder</span><strong><%= resultado.getSinResponder() %></strong></div>
                            <div class="metric"><span>S2</span><strong><%= resultado.getPuntuacionS2() %></strong></div>
                        </div>
                        <div class="summary">
                            <div>Desempeño general: <strong><%= porcentaje %>%</strong> de respuestas correctas.</div>
                            <div>Revisa abajo cada ejercicio para identificar dónde acertaste y dónde debes mejorar.</div>
                        </div>
                        <div class="answers">
                            <% for (RespuestaEvaluado resp : seleccionada.getRespuestas()) {
                                boolean ok = Boolean.TRUE.equals(resp.getEsAcierto());
                            %>
                                <article class="answer <%= ok ? "ok" : "bad" %>">
                                    <strong>Ej. <%= resp.getEjercicio().getNumero() %></strong>
                                    <div>
                                        Marcaste: <%= h(resp.getLetrasMarcadas().isEmpty() ? "Sin responder" : resp.getLetrasMarcadas()) %><br/>
                                        Correcta: <%= h(resp.getEjercicio().getLetrasCorrectas()) %>
                                    </div>
                                    <span class="badge <%= ok ? "ok" : "bad" %>"><%= ok ? "Bien" : "Falló" %></span>
                                </article>
                            <% } %>
                        </div>
                    </div>
                </section>
            </div>
        <% } %>
    </main>
</body>
</html>
