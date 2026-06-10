<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.aptispace.modelo.*" %>
<%!
    String h(Object v) {
        if (v == null) return "";
        return String.valueOf(v).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    String nombre(Evaluado e) { return e == null ? "" : h(e.getApellidos() + ", " + e.getNombres()); }
    boolean marcada(RespuestaEvaluado r, String letra) {
        if ("A".equals(letra)) return r.isOpcionA();
        if ("B".equals(letra)) return r.isOpcionB();
        if ("C".equals(letra)) return r.isOpcionC();
        if ("D".equals(letra)) return r.isOpcionD();
        return r.isOpcionE();
    }
%>
<%
    String seccion = (String) request.getAttribute("seccion");
    List<GrupoEvaluacion> grupos = (List<GrupoEvaluacion>) request.getAttribute("grupos");
    List<Evaluado> evaluados = (List<Evaluado>) request.getAttribute("evaluados");
    List<Prueba> pruebas = (List<Prueba>) request.getAttribute("pruebas");
    List<AplicacionPrueba> aplicaciones = (List<AplicacionPrueba>) request.getAttribute("aplicaciones");
    List<ObservacionPsicologica> observaciones = (List<ObservacionPsicologica>) request.getAttribute("observaciones");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Gestion</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #eef3f7; }
        header { padding: 26px 7vw; background: #203a43; color: white; }
        header h1 { margin: 0 0 8px; font-size: 30px; letter-spacing: 0; }
        header p { margin: 0; color: #dbe8ef; line-height: 1.5; }
        main { max-width: 1180px; margin: 22px auto 44px; padding: 0 20px; }
        nav { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 18px; }
        nav a, .button { border: 0; border-radius: 6px; padding: 10px 13px; background: #dfe7ee; color: #243441; font-weight: 700; text-decoration: none; cursor: pointer; }
        nav a.active, .button.primary { background: #1f6f8b; color: white; }
        .top { display: flex; justify-content: space-between; gap: 14px; align-items: center; margin-bottom: 16px; }
        .top a { color: #1f6f8b; font-weight: 700; text-decoration: none; }
        .grid { display: grid; grid-template-columns: .9fr 1.3fr; gap: 16px; align-items: start; }
        .panel { background: white; border: 1px solid #d7e0e7; border-radius: 8px; padding: 18px; }
        h2 { margin: 0 0 12px; color: #203a43; }
        form { display: grid; gap: 12px; }
        label { display: grid; gap: 6px; font-weight: 700; color: #334155; }
        input, select, textarea { width: 100%; border: 1px solid #cbd5df; border-radius: 6px; padding: 10px; font: inherit; background: white; }
        textarea { min-height: 96px; resize: vertical; }
        .checks { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; max-height: 260px; overflow: auto; border: 1px solid #d7e0e7; border-radius: 8px; padding: 10px; }
        .checks label, label.inline { display: flex; gap: 8px; align-items: center; font-weight: 400; }
        .checks input, label.inline input { width: auto; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; background: white; }
        th, td { padding: 11px 10px; border-bottom: 1px solid #e3e9ef; text-align: left; vertical-align: top; }
        th { color: #203a43; font-size: 13px; text-transform: uppercase; }
        .muted { color: #64748b; }
        .notice { margin-bottom: 14px; padding: 12px; border-radius: 8px; background: #e8f6ef; color: #166534; border: 1px solid #b9e2ca; }
        .error { margin-bottom: 14px; padding: 12px; border-radius: 8px; background: #fff1f2; color: #9f1239; border: 1px solid #fecdd3; }
        .row-actions { display: flex; flex-wrap: wrap; gap: 8px; }
        .row-actions form { display: inline; }
        .metrics { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 16px; }
        .metric { border: 1px solid #d7e0e7; border-radius: 8px; background: #f8fafc; padding: 14px; }
        .metric span { display: block; color: #64748b; margin-bottom: 6px; }
        .metric strong { color: #203a43; font-size: 26px; }
        details { border: 1px solid #d7e0e7; border-radius: 8px; background: #f8fafc; padding: 10px 12px; margin-top: 8px; }
        summary { cursor: pointer; font-weight: 700; color: #203a43; }
        .template-head { display: flex; justify-content: space-between; gap: 14px; align-items: flex-start; margin-bottom: 16px; }
        .template-list { display: grid; gap: 14px; }
        .template-card { border: 1px solid #d7e0e7; border-radius: 8px; background: white; padding: 16px; }
        .template-title { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 12px; align-items: start; }
        .template-title h3 { margin: 0 0 6px; color: #203a43; }
        .pill { display: inline-block; border-radius: 999px; padding: 5px 9px; background: #e2e8f0; color: #334155; font-weight: 700; font-size: 12px; }
        .template-meta { display: flex; flex-wrap: wrap; gap: 8px; margin: 12px 0; }
        .template-edit { background: #f8fafc; }
        .template-actions { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin-top: 12px; }
        .edit-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; margin-top: 12px; }
        .template-table { display: block; border-collapse: separate; background: transparent; }
        .template-table tbody { display: grid; gap: 14px; }
        .template-table tr { display: grid; grid-template-columns: minmax(0, 1.2fr) minmax(180px, .6fr) minmax(280px, 1fr) auto; gap: 14px; border: 1px solid #d7e0e7; border-radius: 8px; background: white; padding: 16px; }
        .template-table tr:first-child { display: none; }
        .template-table td { border-bottom: 0; padding: 0; }
        .template-table td:first-child strong { display: block; color: #203a43; font-size: 18px; margin-bottom: 6px; }
        .template-table td:nth-child(2) { color: #475569; line-height: 1.7; }
        .template-table td:nth-child(2)::before { content: "Configuración"; display: block; color: #203a43; font-weight: 700; margin-bottom: 4px; }
        .template-table td:nth-child(3) form { background: #f8fafc; border: 1px solid #d7e0e7; border-radius: 8px; padding: 12px; }
        .template-table td:nth-child(4) { align-self: end; }
        @media (max-width: 900px) { .grid { grid-template-columns: 1fr; } .checks { grid-template-columns: 1fr; } }
        @media (max-width: 980px) { .template-table tr { grid-template-columns: 1fr; } }
        @media (max-width: 700px) { .template-head, .template-title { grid-template-columns: 1fr; display: grid; } .edit-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <header>
        <h1>Entorno del Evaluador</h1>
        <p>Gestion moderna por codigo de grupo, asignaciones, catalogo, resultados y observaciones.</p>
    </header>
    <main>
        <div class="top">
            <a href="<%= request.getContextPath() %>/evaluador-home.jsp">Volver al panel</a>
            <a href="<%= request.getContextPath() %>/logout">Cerrar sesion</a>
        </div>
        <nav>
            <a class="<%= "grupos".equals(seccion) ? "active" : "" %>" href="grupos">Grupos</a>
            <a class="<%= "evaluados".equals(seccion) ? "active" : "" %>" href="evaluados">Evaluados</a>
            <a class="<%= "asignaciones".equals(seccion) ? "active" : "" %>" href="asignaciones">Asignaciones</a>
            <a class="<%= "plantillas".equals(seccion) ? "active" : "" %>" href="plantillas">Plantillas</a>
            <a class="<%= "resultados".equals(seccion) ? "active" : "" %>" href="resultados">Resultados</a>
            <a class="<%= "observaciones".equals(seccion) ? "active" : "" %>" href="observaciones">Observaciones</a>
        </nav>
        <% if ("1".equals(request.getParameter("ok"))) { %><div class="notice">Cambios guardados.</div><% } %>
        <% if (request.getParameter("error") != null) { %><div class="error"><%= h(request.getParameter("error")) %></div><% } %>

        <% if ("grupos".equals(seccion)) { %>
        <section class="grid">
            <div class="panel">
                <h2>Crear grupo</h2>
                <form method="post">
                    <input type="hidden" name="accion" value="crearGrupo"/>
                    <label>Nombre <input name="nombre" required placeholder="Ej. Seccion A"/></label>
                    <label>Codigo de espacio <input name="codigo" required maxlength="20" placeholder="S2-A2026"/></label>
                    <label class="inline"><input type="checkbox" name="activo" checked/> Activo</label>
                    <button class="button primary" type="submit">Guardar grupo</button>
                </form>
            </div>
            <div class="panel table-wrap">
                <h2>Grupos creados</h2>
                <table><tr><th>Grupo</th><th>Codigo</th><th>Unidos</th><th>Estado</th></tr>
                <% for (GrupoEvaluacion g : grupos) { %><tr><td><%= h(g.getNombre()) %>
                    <details>
                        <summary>Ver integrantes</summary>
                        <% if (g.getEvaluados().isEmpty()) { %><p class="muted">Todavia no hay evaluados unidos.</p><% } %>
                        <% for (Evaluado e : g.getEvaluados()) { %><p><%= nombre(e) %> <span class="muted"><%= h(e.getCarrera()) %></span></p><% } %>
                    </details>
                </td><td><strong><%= h(g.getCodigo()) %></strong></td><td><%= g.getEvaluados().size() %></td><td><%= Boolean.TRUE.equals(g.getActivo()) ? "Activo" : "Inactivo" %></td></tr><% } %>
                </table>
            </div>
        </section>
        <% } else if ("evaluados".equals(seccion)) { %>
        <section class="panel table-wrap">
            <h2>Evaluados unidos a tus grupos</h2>
            <table><tr><th>Nombre</th><th>Correo</th><th>Edad</th><th>Sexo</th><th>Carrera</th><th>Grupos</th></tr>
            <% for (Evaluado e : evaluados) { %><tr><td><%= nombre(e) %></td><td><%= e.getUsuario() == null ? "" : h(e.getUsuario().getCorreo()) %></td><td><%= h(e.getEdad()) %></td><td><%= h(e.getSexo()) %></td><td><%= h(e.getCarrera()) %><br/><span class="muted">Año <%= h(e.getAnioCarrera()) %></span></td><td><% for (GrupoEvaluacion g : e.getGrupos()) { %><%= h(g.getNombre()) %><br/><% } %></td></tr><% } %>
            </table>
        </section>
        <% } else if ("asignaciones".equals(seccion)) { %>
        <section class="grid">
            <div class="panel">
                <h2>Asignar prueba</h2>
                <form method="post">
                    <input type="hidden" name="accion" value="asignarPrueba"/>
                    <label>Prueba <select name="pruebaId" required><% for (Prueba p : pruebas) { %><option value="<%= p.getId() %>"><%= h(p.getNombre()) %></option><% } %></select></label>
                    <label>Grupo <select name="grupoId" required><option value="">Seleccionar grupo</option><% for (GrupoEvaluacion g : grupos) { %><option value="<%= g.getId() %>"><%= h(g.getNombre()) %> (<%= h(g.getCodigo()) %>) - <%= g.getEvaluados().size() %> unidos</option><% } %></select></label>
                    <label class="inline"><input type="checkbox" name="reaplicacion"/> Autorizar reaplicacion</label>
                    <button class="button primary" type="submit">Asignar</button>
                </form>
            </div>
            <div class="panel table-wrap">
                <h2>Asignaciones</h2>
                <form method="post" style="margin-bottom:12px;">
                    <input type="hidden" name="accion" value="iniciarTodas"/>
                    <button class="button primary" type="submit">Iniciar todas las asignadas</button>
                </form>
                <table><tr><th>Evaluado</th><th>Prueba</th><th>Estado</th><th>Acciones</th></tr>
                <% for (AplicacionPrueba a : aplicaciones) { %><tr><td><%= nombre(a.getEvaluado()) %></td><td><%= h(a.getPrueba()) %></td><td><%= h(a.getEstado()) %></td><td class="row-actions">
                    <form method="post"><input type="hidden" name="accion" value="iniciarPrueba"/><input type="hidden" name="aplicacionId" value="<%= a.getId() %>"/><button class="button" type="submit">Iniciar</button></form>
                    <form method="post"><input type="hidden" name="accion" value="finalizarPrueba"/><input type="hidden" name="aplicacionId" value="<%= a.getId() %>"/><button class="button" type="submit">Finalizar</button></form>
                </td></tr><% } %>
                </table>
            </div>
        </section>
        <% } else if ("plantillas".equals(seccion)) { %>
        <section class="panel templates-panel">
            <div class="template-head">
                <div>
                    <h2>Plantillas guardadas</h2>
                    <p class="muted">Administra las pruebas visuales disponibles para asignar a tus grupos.</p>
                </div>
                <a class="button primary" href="<%= request.getContextPath() %>/plantilla-wizard">Crear nueva plantilla</a>
            </div>
            <div class="metrics">
                <div class="metric"><span>Total</span><strong><%= pruebas.size() %></strong></div>
                <div class="metric"><span>Activas</span><strong><%= pruebas.stream().filter(p -> Prueba.EstadoPrueba.ACTIVA.equals(p.getEstado())).count() %></strong></div>
                <div class="metric"><span>Inactivas</span><strong><%= pruebas.stream().filter(p -> Prueba.EstadoPrueba.INACTIVA.equals(p.getEstado())).count() %></strong></div>
                <div class="metric"><span>Archivadas</span><strong><%= pruebas.stream().filter(p -> Prueba.EstadoPrueba.ARCHIVADA.equals(p.getEstado())).count() %></strong></div>
            </div>
            <table class="template-table"><tr><th>Plantilla</th><th>Configuracion</th><th>Editar</th><th>Borrar</th></tr>
            <% for (Prueba p : pruebas) { %>
                <tr>
                    <td>
                        <strong><%= h(p.getNombre()) %></strong><br/>
                        <span class="muted"><%= h(p.getDescripcion()) %></span>
                    </td>
                    <td>
                        <%= h(p.getTiempoLimite()) %> min<br/>
                        <%= h(p.getCantidadEjercicios()) %> ejercicios<br/>
                        <%= p.getEjercicios().size() %> cargados<br/>
                        <%= h(p.getEstado()) %>
                    </td>
                    <td>
                        <form method="post">
                            <input type="hidden" name="accion" value="actualizarPrueba"/>
                            <input type="hidden" name="pruebaId" value="<%= p.getId() %>"/>
                            <label>Nombre <input name="nombre" value="<%= h(p.getNombre()) %>" required/></label>
                            <label>Descripcion <textarea name="descripcion"><%= h(p.getDescripcion()) %></textarea></label>
                            <label>Tiempo <input type="number" min="1" max="180" name="tiempoLimite" value="<%= h(p.getTiempoLimite()) %>"/></label>
                            <label>Cantidad <input type="number" min="1" max="200" name="cantidadEjercicios" value="<%= h(p.getCantidadEjercicios()) %>"/></label>
                            <label>Estado <select name="estado">
                                <option value="ACTIVA" <%= Prueba.EstadoPrueba.ACTIVA.equals(p.getEstado()) ? "selected" : "" %>>ACTIVA</option>
                                <option value="INACTIVA" <%= Prueba.EstadoPrueba.INACTIVA.equals(p.getEstado()) ? "selected" : "" %>>INACTIVA</option>
                                <option value="ARCHIVADA" <%= Prueba.EstadoPrueba.ARCHIVADA.equals(p.getEstado()) ? "selected" : "" %>>ARCHIVADA</option>
                            </select></label>
                            <button class="button primary" type="submit">Guardar</button>
                        </form>
                    </td>
                    <td>
                        <form method="post" onsubmit="return confirm('Borrar esta plantilla solo si no fue asignada. ¿Continuar?');">
                            <input type="hidden" name="accion" value="eliminarPrueba"/>
                            <input type="hidden" name="pruebaId" value="<%= p.getId() %>"/>
                            <button class="button" type="submit">Borrar</button>
                        </form>
                    </td>
                </tr>
            <% } %>
            </table>
        </section>
        <% } else if ("resultados".equals(seccion)) { %>
        <section class="panel table-wrap">
            <h2>Resultados</h2>
            <%
                int totalAsignadas = aplicaciones.size();
                int finalizadas = 0;
                int conResultado = 0;
                int sumaS2 = 0;
                int mejorS2 = 0;
                for (AplicacionPrueba a : aplicaciones) {
                    if (AplicacionPrueba.EstadoAplicacion.FINALIZADA.equals(a.getEstado())) finalizadas++;
                    if (a.getResultado() != null) {
                        conResultado++;
                        sumaS2 += a.getResultado().getPuntuacionS2();
                        mejorS2 = Math.max(mejorS2, a.getResultado().getPuntuacionS2());
                    }
                }
                int promedioS2 = conResultado == 0 ? 0 : Math.round((float) sumaS2 / conResultado);
            %>
            <div class="metrics">
                <div class="metric"><span>Asignadas</span><strong><%= totalAsignadas %></strong></div>
                <div class="metric"><span>Finalizadas</span><strong><%= finalizadas %></strong></div>
                <div class="metric"><span>Promedio S2</span><strong><%= promedioS2 %></strong></div>
                <div class="metric"><span>Mejor S2</span><strong><%= mejorS2 %></strong></div>
            </div>
            <table><tr><th>Evaluado</th><th>Prueba</th><th>Estado</th><th>Aciertos</th><th>Errores</th><th>S2</th></tr>
            <% for (AplicacionPrueba a : aplicaciones) { ResultadoPrueba r = a.getResultado(); %><tr><td><%= nombre(a.getEvaluado()) %>
                <details>
                    <summary>Respuestas del estudiante</summary>
                    <table>
                        <tr><th>Ejercicio</th><th>Marcadas</th><th>Correctas</th><th>Resultado</th></tr>
                        <% for (RespuestaEvaluado resp : a.getRespuestas()) { %>
                            <tr>
                                <td><%= resp.getEjercicio().getNumero() %></td>
                                <td><%= h(resp.getLetrasMarcadas()) %></td>
                                <td><%= h(resp.getEjercicio().getLetrasCorrectas()) %></td>
                                <td><%= Boolean.TRUE.equals(resp.getEsAcierto()) ? "Acierto" : (resp.getLetrasMarcadas().isEmpty() ? "Sin responder" : "Error") %></td>
                            </tr>
                        <% } %>
                    </table>
                </details>
            </td><td><%= h(a.getPrueba()) %></td><td><%= h(a.getEstado()) %></td><td><%= r == null ? "-" : h(r.getAciertos()) %></td><td><%= r == null ? "-" : h(r.getErrores()) %></td><td><strong><%= r == null ? "-" : h(r.getPuntuacionS2()) %></strong></td></tr><% } %>
            </table>
        </section>
        <% } else if ("observaciones".equals(seccion)) { %>
        <section class="grid">
            <div class="panel">
                <h2>Nueva observacion</h2>
                <form method="post">
                    <input type="hidden" name="accion" value="crearObservacion"/>
                    <label>Asignacion <select name="aplicacionId" required><% for (AplicacionPrueba a : aplicaciones) { %><option value="<%= a.getId() %>"><%= nombre(a.getEvaluado()) %> - <%= h(a.getPrueba()) %></option><% } %></select></label>
                    <label>Comentario <textarea name="comentario" required></textarea></label>
                    <button class="button primary" type="submit">Guardar observacion</button>
                </form>
            </div>
            <div class="panel table-wrap">
                <h2>Historial</h2>
                <table><tr><th>Evaluado</th><th>Fecha</th><th>Comentario</th></tr>
                <% for (ObservacionPsicologica o : observaciones) { %><tr><td><%= nombre(o.getAplicacion().getEvaluado()) %></td><td><%= h(o.getFechaObservacion()) %></td><td><%= h(o.getComentario()) %></td></tr><% } %>
                </table>
            </div>
        </section>
        <% } %>
    </main>
</body>
</html>
