<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.aptispace.modelo.*" %>
<%!
    java.time.format.DateTimeFormatter fechaCorta = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String h(Object v) {
        if (v == null) return "";
        return String.valueOf(v).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    String nombre(Evaluado e) { return e == null ? "" : h(e.getApellidos() + ", " + e.getNombres()); }
    String imagenPortada(Prueba p) {
        if (p == null || p.getEjercicios() == null) return "";
        for (Ejercicio ejercicio : p.getEjercicios()) {
            if (ejercicio.getImagenModelo() != null && !ejercicio.getImagenModelo().isBlank()) return h(ejercicio.getImagenModelo());
        }
        return "";
    }
    boolean marcada(RespuestaEvaluado r, String letra) {
        if ("A".equals(letra)) return r.isOpcionA();
        if ("B".equals(letra)) return r.isOpcionB();
        if ("C".equals(letra)) return r.isOpcionC();
        if ("D".equals(letra)) return r.isOpcionD();
        return r.isOpcionE();
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
    String fechaAplicacion(AplicacionPrueba a) {
        if (a == null) return "";
        if (a.getFechaInicio() != null) return f(a.getFechaInicio());
        return "Sin iniciar";
    }
    String f(java.time.LocalDateTime fecha) {
        return fecha == null ? "" : fecha.format(fechaCorta);
    }
    List<Evaluado> unicos(Collection<Evaluado> origen) {
        List<Evaluado> salida = new ArrayList<>();
        Set<String> vistos = new LinkedHashSet<>();
        if (origen == null) return salida;
        for (Evaluado e : origen) {
            if (e == null) continue;
            String clave = e.getUsuario() != null && e.getUsuario().getCorreo() != null && !e.getUsuario().getCorreo().isBlank()
                ? "correo:" + e.getUsuario().getCorreo().toLowerCase()
                : "id:" + e.getId();
            if (vistos.add(clave)) salida.add(e);
        }
        return salida;
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
        header { padding: 30px 7vw 28px; background: linear-gradient(135deg, rgba(20, 42, 71, .93), rgba(31, 111, 139, .82)), url("<%= request.getContextPath() %>/images/s2/modelo-03.svg"); background-size: cover; background-position: center; color: white; }
        header h1 { margin: 0 0 8px; font-size: 30px; letter-spacing: 0; }
        header p { margin: 0; color: #dbe8ef; line-height: 1.5; }
        main { max-width: 1180px; margin: 22px auto 44px; padding: 0 20px; }
        nav { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 18px; }
        nav a, .button { border: 0; border-radius: 6px; padding: 10px 13px; background: #dfe7ee; color: #243441; font-weight: 700; text-decoration: none; cursor: pointer; }
        nav a.active, .button.primary { background: #1f6f8b; color: white; }
        .top { display: flex; justify-content: space-between; gap: 12px; align-items: center; margin-bottom: 16px; padding: 12px; background: white; border: 1px solid #d7e0e7; border-radius: 8px; }
        .top a { display: inline-flex; align-items: center; justify-content: center; min-height: 40px; border-radius: 6px; padding: 10px 13px; font-weight: 700; text-decoration: none; }
        .top .back-link { background: #1f6f8b; color: white; }
        .top .logout-link { background: #eef3f7; color: #203a43; border: 1px solid #cbd5df; }
        .grid { display: grid; grid-template-columns: .9fr 1.3fr; gap: 16px; align-items: start; }
        .panel { background: white; border: 1px solid #c5d8e2; border-radius: 8px; padding: 18px; box-shadow: 0 10px 24px rgba(31, 75, 93, .08); }
        .panel > h2:first-child { margin: -18px -18px 16px; padding: 14px 18px; color: white; background: #1f6f8b; border-radius: 8px 8px 0 0; }
        h2 { margin: 0 0 12px; color: #203a43; }
        form { display: grid; gap: 12px; }
        label { display: grid; gap: 6px; font-weight: 700; color: #334155; }
        input, select, textarea { width: 100%; border: 1px solid #b7c9d4; border-radius: 6px; padding: 10px; font: inherit; background: white; }
        input:focus, select:focus, textarea:focus { outline: 2px solid rgba(31, 111, 139, .20); border-color: #1f6f8b; }
        textarea { min-height: 96px; resize: vertical; }
        .checks { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; max-height: 260px; overflow: auto; border: 1px solid #d7e0e7; border-radius: 8px; padding: 10px; }
        .checks label, label.inline { display: flex; gap: 8px; align-items: center; font-weight: 400; }
        .checks input, label.inline input { width: auto; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; background: white; }
        th, td { padding: 11px 10px; border-bottom: 1px solid #e3e9ef; text-align: left; vertical-align: top; }
        th { color: #203a43; font-size: 13px; text-transform: uppercase; background: #eef7fa; }
        tr[data-search]:hover td { background: #f6fbfd; }
        .muted { color: #64748b; }
        .section-toolbar { display: flex; justify-content: space-between; gap: 14px; align-items: center; margin-bottom: 14px; }
        .section-toolbar h2 { margin: 0 0 4px; }
        .section-toolbar p { margin: 0; }
        .search-box { min-width: 260px; max-width: 360px; position: relative; }
        .search-box input { background: #f8fbfd; }
        .empty-filter { display: none; padding: 14px; border: 1px dashed #9cc9d8; border-radius: 8px; color: #64748b; background: #f8fbfd; text-align: center; }
        .notice { margin-bottom: 14px; padding: 12px; border-radius: 8px; background: #e8f6ef; color: #166534; border: 1px solid #b9e2ca; }
        .error { margin-bottom: 14px; padding: 12px; border-radius: 8px; background: #fff1f2; color: #9f1239; border: 1px solid #fecdd3; }
        .row-actions { display: flex; flex-wrap: wrap; gap: 8px; }
        .row-actions form { display: inline; }
        .assignment-layout { display: grid; grid-template-columns: minmax(290px, .8fr) minmax(0, 1.35fr); gap: 16px; align-items: start; }
        .assignment-card { padding: 0; overflow: hidden; }
        .assignment-hero { padding: 18px; background: linear-gradient(135deg, #f8fbfd, #e8f4f8); border-bottom: 1px solid #c5d8e2; }
        .assignment-hero h2 { margin-bottom: 6px; }
        .assignment-hero p { margin: 0; line-height: 1.45; }
        .assignment-stats { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; margin-top: 14px; }
        .assignment-stat { border: 1px solid #d7e0e7; border-radius: 8px; background: white; padding: 11px; }
        .assignment-stat span { display: block; color: #64748b; font-size: 12px; margin-bottom: 4px; }
        .assignment-stat strong { color: #203a43; font-size: 22px; }
        .assignment-form { padding: 18px; }
        .assignment-form .field-note { color: #64748b; font-size: 13px; line-height: 1.35; margin-top: -2px; }
        .assignment-toggle { border: 1px solid #d7e0e7; border-radius: 8px; background: #f8fafc; padding: 10px; }
        .assignment-submit { width: 100%; min-height: 44px; }
        .assignments-head { display: flex; justify-content: space-between; gap: 12px; align-items: center; margin-bottom: 14px; }
        .assignments-head h2 { margin-bottom: 4px; }
        .assignments-head p { margin: 0; line-height: 1.4; }
        .assignments-head form { margin: 0; }
        .assignment-table { border-collapse: separate; border-spacing: 0 10px; background: transparent; }
        .assignment-table th { border-bottom: 0; padding: 0 10px 2px; }
        .assignment-table td { background: #f8fafc; border-top: 1px solid #d7e0e7; border-bottom: 1px solid #d7e0e7; padding: 12px 10px; }
        .assignment-table td:first-child { border-left: 1px solid #d7e0e7; border-radius: 8px 0 0 8px; }
        .assignment-table td:last-child { border-right: 1px solid #d7e0e7; border-radius: 0 8px 8px 0; }
        .assignment-table strong { color: #203a43; }
        .status-badge { display: inline-block; border-radius: 999px; padding: 5px 9px; background: #e2e8f0; color: #334155; font-weight: 700; font-size: 12px; }
        .observations-layout { display: grid; grid-template-columns: minmax(300px, .85fr) minmax(0, 1.25fr); gap: 16px; align-items: start; }
        .observation-compose { padding: 0; overflow: hidden; }
        .observation-head { padding: 18px; background: linear-gradient(135deg, #f8fbfd, #e8f4f8); border-bottom: 1px solid #c5d8e2; }
        .observation-head h2 { margin-bottom: 6px; }
        .observation-head p { margin: 0; line-height: 1.45; }
        .observation-form { padding: 18px; }
        .observation-form textarea { min-height: 190px; line-height: 1.45; }
        .observation-context { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; margin-top: 14px; }
        .observation-context div { border: 1px solid #d7e0e7; border-radius: 8px; background: white; padding: 11px; }
        .observation-context span { display: block; color: #64748b; font-size: 12px; margin-bottom: 4px; }
        .observation-context strong { color: #203a43; font-size: 22px; }
        .observation-board { display: grid; gap: 14px; }
        .observation-toolbar { display: flex; justify-content: space-between; gap: 12px; align-items: center; }
        .observation-toolbar h2 { margin-bottom: 4px; }
        .observation-toolbar p { margin: 0; line-height: 1.4; }
        .observation-count { border: 1px solid #d7e0e7; border-radius: 8px; background: #f8fafc; padding: 10px 12px; color: #203a43; font-weight: 800; white-space: nowrap; }
        .observation-list { display: grid; gap: 12px; }
        .observation-card { display: grid; grid-template-columns: 44px minmax(0, 1fr); gap: 12px; border: 1px solid #d7e0e7; border-radius: 8px; background: #f8fafc; padding: 14px; }
        .observation-avatar { width: 44px; height: 44px; border-radius: 8px; display: grid; place-items: center; background: #1f6f8b; color: white; font-weight: 800; }
        .observation-card-head { display: flex; justify-content: space-between; gap: 10px; align-items: flex-start; margin-bottom: 8px; }
        .observation-card h3 { margin: 0 0 3px; color: #203a43; font-size: 16px; line-height: 1.25; }
        .observation-card p { margin: 0; line-height: 1.45; }
        .observation-note { background: white; border: 1px solid #e3e9ef; border-radius: 8px; padding: 11px; color: #334155; overflow-wrap: anywhere; }
        .observation-empty { border: 1px dashed #a9bac7; border-radius: 8px; background: #f8fafc; padding: 18px; color: #64748b; text-align: center; }
        .metrics { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 16px; }
        .metric { border: 1px solid #d7e0e7; border-radius: 8px; background: #f8fafc; padding: 14px; }
        .metric span { display: block; color: #64748b; margin-bottom: 6px; }
        .metric strong { color: #203a43; font-size: 26px; }
        details { border: 1px solid #d7e0e7; border-radius: 8px; background: #f8fafc; padding: 10px 12px; margin-top: 8px; }
        summary { cursor: pointer; font-weight: 700; color: #203a43; }
        .template-head { display: flex; justify-content: space-between; gap: 14px; align-items: flex-start; margin-bottom: 16px; }
        .template-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 16px; align-items: start; }
        .template-card { border: 1px solid #d7e0e7; border-radius: 8px; background: white; overflow: hidden; min-width: 0; }
        .template-card:hover { border-color: #a7bac8; box-shadow: 0 8px 22px rgba(32, 58, 67, .10); }
        .template-preview { height: 150px; background: #f1f5f9; display: grid; place-items: center; border-bottom: 1px solid #e3e9ef; overflow: hidden; }
        .template-preview img { width: 100%; height: 100%; object-fit: contain; padding: 14px; background: #f8fafc; }
        .template-placeholder { width: 74px; height: 56px; border: 2px solid #c7d4df; border-radius: 7px; display: grid; place-items: center; color: #597184; font-size: 22px; font-weight: 800; background: white; }
        .template-body { padding: 13px; display: grid; gap: 11px; }
        .template-title { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 10px; align-items: start; }
        .template-title h3 { margin: 0 0 5px; color: #203a43; font-size: 16px; line-height: 1.25; overflow-wrap: anywhere; }
        .template-title p { margin: 0; font-size: 13px; line-height: 1.35; }
        .pill { display: inline-block; border-radius: 999px; padding: 5px 9px; background: #e2e8f0; color: #334155; font-weight: 700; font-size: 12px; }
        .pill.active { background: #dcfce7; color: #166534; }
        .pill.inactive { background: #fef3c7; color: #92400e; }
        .pill.archived { background: #e2e8f0; color: #475569; }
        .template-meta { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px; }
        .template-meta span { border: 1px solid #e2e8f0; border-radius: 7px; background: #f8fafc; padding: 8px 7px; color: #64748b; font-size: 12px; line-height: 1.2; }
        .template-meta strong { display: block; color: #203a43; font-size: 15px; margin-bottom: 2px; }
        .template-actions { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
        .template-actions form { display: inline; }
        .template-edit { border-top: 1px solid #e3e9ef; border-radius: 0; background: #f8fafc; margin: 0; }
        .template-edit summary { padding: 11px 13px; }
        .template-edit form { padding: 0 13px 13px; }
        .edit-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; }
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
        @media (max-width: 900px) { .grid, .assignment-layout, .observations-layout { grid-template-columns: 1fr; } .checks { grid-template-columns: 1fr; } .assignments-head, .observation-toolbar { align-items: stretch; flex-direction: column; } .assignments-head .button { width: 100%; } }
        @media (max-width: 980px) { .template-table tr { grid-template-columns: 1fr; } }
        @media (max-width: 700px) { .top { align-items: stretch; flex-direction: column; } .top a { width: 100%; } .template-head, .template-title { grid-template-columns: 1fr; display: grid; } .template-grid { grid-template-columns: 1fr; } .edit-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <header>
        <h1>Entorno del Evaluador</h1>
        <p>Gestion moderna por codigo de grupo, asignaciones, catalogo, resultados y observaciones.</p>
    </header>
    <main>
        <div class="top">
            <a class="back-link" href="<%= request.getContextPath() %>/evaluador-home.jsp">Volver al panel</a>
            <a class="logout-link" href="<%= request.getContextPath() %>/logout">Cerrar sesion</a>
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
                <% for (GrupoEvaluacion g : grupos) { List<Evaluado> miembros = unicos(g.getEvaluados()); %><tr data-filter-item="grupos-list" data-search="<%= h(g.getNombre()) %> <%= h(g.getCodigo()) %> <% for (Evaluado e : miembros) { %> <%= nombre(e) %> <%= e.getUsuario() == null ? "" : h(e.getUsuario().getCorreo()) %><% } %>"><td><%= h(g.getNombre()) %>
                    <details>
                        <summary>Ver integrantes</summary>
                        <% if (miembros.isEmpty()) { %><p class="muted">Todavia no hay evaluados unidos.</p><% } %>
                        <% for (Evaluado e : miembros) { %><p><%= nombre(e) %> <span class="muted"><%= h(e.getCarrera()) %></span></p><% } %>
                    </details>
                </td><td><strong><%= h(g.getCodigo()) %></strong></td><td><%= miembros.size() %></td><td><%= Boolean.TRUE.equals(g.getActivo()) ? "Activo" : "Inactivo" %></td></tr><% } %>
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
        <section class="assignment-layout">
            <div class="panel assignment-card">
                <div class="assignment-hero">
                    <h2>Asignar prueba</h2>
                    <p class="muted">Selecciona una plantilla y el grupo que recibira la evaluacion.</p>
                    <div class="assignment-stats">
                        <div class="assignment-stat"><span>Plantillas</span><strong><%= pruebas.size() %></strong></div>
                        <div class="assignment-stat"><span>Grupos</span><strong><%= grupos.size() %></strong></div>
                    </div>
                </div>
                <form class="assignment-form" method="post">
                    <input type="hidden" name="accion" value="asignarPrueba"/>
                    <label>Prueba
                        <select name="pruebaId" required>
                            <% for (Prueba p : pruebas) { %><option value="<%= p.getId() %>"><%= h(p.getNombre()) %> · <%= h(p.getCantidadEjercicios()) %> ejercicios · <%= h(p.getTiempoLimite()) %> min</option><% } %>
                        </select>
                        <span class="field-note">Usa una plantilla activa y con ejercicios cargados.</span>
                    </label>
                    <label>Grupo
                        <select name="grupoId" required>
                            <option value="">Seleccionar grupo</option>
                            <% for (GrupoEvaluacion g : grupos) { %><option value="<%= g.getId() %>"><%= h(g.getNombre()) %> · <%= h(g.getCodigo()) %> · <%= g.getEvaluados().size() %> unidos</option><% } %>
                        </select>
                        <span class="field-note">La asignacion se creara para todos los evaluados unidos al grupo.</span>
                    </label>
                    <label class="inline assignment-toggle"><input type="checkbox" name="reaplicacion"/> Autorizar reaplicacion</label>
                    <button class="button primary assignment-submit" type="submit">Asignar prueba al grupo</button>
                </form>
            </div>
            <div class="panel table-wrap">
                <div class="assignments-head">
                    <div>
                        <h2>Asignaciones</h2>
                        <p class="muted">Controla el inicio y cierre de las pruebas preparadas.</p>
                    </div>
                    <form method="post">
                        <input type="hidden" name="accion" value="iniciarTodas"/>
                        <button class="button primary" type="submit">Iniciar asignadas</button>
                    </form>
                </div>
                <table class="assignment-table"><tr><th>Evaluado</th><th>Prueba</th><th>Intento</th><th>Estado</th><th>Acciones</th></tr>
                <% for (AplicacionPrueba a : aplicaciones) { %><tr><td><strong><%= nombre(a.getEvaluado()) %></strong></td><td><%= h(a.getPrueba()) %></td><td>Intento <%= intento(a, aplicaciones) %></td><td><span class="status-badge"><%= h(a.getEstado()) %></span></td><td class="row-actions">
                    <form method="post"><input type="hidden" name="accion" value="iniciarPrueba"/><input type="hidden" name="aplicacionId" value="<%= a.getId() %>"/><button class="button" type="submit">Iniciar</button></form>
                    <form method="post"><input type="hidden" name="accion" value="finalizarPrueba"/><input type="hidden" name="aplicacionId" value="<%= a.getId() %>"/><button class="button" type="submit">Finalizar</button></form>
                    <% if (AplicacionPrueba.EstadoAplicacion.FINALIZADA.equals(a.getEstado()) && !Boolean.TRUE.equals(a.getAutorizadaReaplicacion())) { %>
                        <form method="post"><input type="hidden" name="accion" value="autorizarReaplicacion"/><input type="hidden" name="aplicacionId" value="<%= a.getId() %>"/><button class="button" type="submit">Autorizar repetir</button></form>
                    <% } %>
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
            <div class="template-grid">
            <% for (Prueba p : pruebas) {
                String portada = imagenPortada(p);
                String estadoClase = Prueba.EstadoPrueba.ACTIVA.equals(p.getEstado()) ? "active" : (Prueba.EstadoPrueba.INACTIVA.equals(p.getEstado()) ? "inactive" : "archived");
            %>
                <article class="template-card">
                    <div class="template-preview">
                        <% if (!portada.isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/<%= portada %>" alt="Vista previa de <%= h(p.getNombre()) %>"/>
                        <% } else { %>
                            <div class="template-placeholder">S2</div>
                        <% } %>
                    </div>
                    <div class="template-body">
                        <div class="template-title">
                            <div>
                                <h3><%= h(p.getNombre()) %></h3>
                                <p class="muted"><%= h(p.getDescripcion()) %></p>
                            </div>
                            <span class="pill <%= estadoClase %>"><%= h(p.getEstado()) %></span>
                        </div>
                        <div class="template-meta">
                            <span><strong><%= h(p.getTiempoLimite()) %></strong>min</span>
                            <span><strong><%= h(p.getCantidadEjercicios()) %></strong>indicados</span>
                            <span><strong><%= p.getEjercicios().size() %></strong>cargados</span>
                        </div>
                        <div class="template-actions">
                            <form method="post" onsubmit="return confirm('Borrar esta plantilla solo si no fue asignada. ¿Continuar?');">
                                <input type="hidden" name="accion" value="eliminarPrueba"/>
                                <input type="hidden" name="pruebaId" value="<%= p.getId() %>"/>
                                <button class="button" type="submit">Borrar</button>
                            </form>
                        </div>
                    </div>
                    <details class="template-edit">
                        <summary>Editar plantilla</summary>
                        <form method="post">
                            <input type="hidden" name="accion" value="actualizarPrueba"/>
                            <input type="hidden" name="pruebaId" value="<%= p.getId() %>"/>
                            <label>Nombre <input name="nombre" value="<%= h(p.getNombre()) %>" required/></label>
                            <label>Descripcion <textarea name="descripcion"><%= h(p.getDescripcion()) %></textarea></label>
                            <div class="edit-grid">
                                <label>Tiempo <input type="number" min="1" max="180" name="tiempoLimite" value="<%= h(p.getTiempoLimite()) %>"/></label>
                                <label>Cantidad <input type="number" min="1" max="200" name="cantidadEjercicios" value="<%= h(p.getCantidadEjercicios()) %>"/></label>
                            </div>
                            <label>Estado <select name="estado">
                                <option value="ACTIVA" <%= Prueba.EstadoPrueba.ACTIVA.equals(p.getEstado()) ? "selected" : "" %>>ACTIVA</option>
                                <option value="INACTIVA" <%= Prueba.EstadoPrueba.INACTIVA.equals(p.getEstado()) ? "selected" : "" %>>INACTIVA</option>
                                <option value="ARCHIVADA" <%= Prueba.EstadoPrueba.ARCHIVADA.equals(p.getEstado()) ? "selected" : "" %>>ARCHIVADA</option>
                            </select></label>
                            <button class="button primary" type="submit">Guardar</button>
                        </form>
                    </details>
                </article>
            <% } %>
            </div>
        </section>
        <% } else if ("resultados".equals(seccion)) { %>
        <section class="panel table-wrap">
            <div class="section-toolbar">
                <div>
                    <h2>Resultados</h2>
                    <p class="muted">Busca por estudiante, prueba, intento o estado.</p>
                </div>
                <label class="search-box"><input data-filter-input="resultados-list" placeholder="Buscar persona o prueba"/></label>
            </div>
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
            <table><tr><th>Evaluado</th><th>Prueba</th><th>Intento</th><th>Fecha inicio</th><th>Fecha fin</th><th>Estado</th><th>Aciertos</th><th>Errores</th><th>S2</th></tr>
            <% for (AplicacionPrueba a : aplicaciones) { ResultadoPrueba r = a.getResultado(); %><tr data-filter-item="resultados-list" data-search="<%= nombre(a.getEvaluado()) %> <%= h(a.getPrueba()) %> Intento <%= intento(a, aplicaciones) %> <%= h(a.getEstado()) %>"><td><%= nombre(a.getEvaluado()) %>
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
            </td><td><%= h(a.getPrueba()) %></td><td>Intento <%= intento(a, aplicaciones) %></td><td><%= f(a.getFechaInicio()) %></td><td><%= f(a.getFechaFin()) %></td><td><%= h(a.getEstado()) %></td><td><%= r == null ? "-" : h(r.getAciertos()) %></td><td><%= r == null ? "-" : h(r.getErrores()) %></td><td><strong><%= r == null ? "-" : h(r.getPuntuacionS2()) %></strong></td></tr><% } %>
            </table>
            <div class="empty-filter" data-empty-filter="resultados-list">No hay resultados para esa busqueda.</div>
        </section>
        <% } else if ("observaciones".equals(seccion)) { %>
        <section class="observations-layout">
            <div class="panel observation-compose">
                <div class="observation-head">
                    <h2>Registrar observacion</h2>
                    <p class="muted">Documenta hallazgos, seguimiento o incidencias vinculadas a una aplicacion concreta.</p>
                    <div class="observation-context">
                        <div><span>Aplicaciones</span><strong><%= aplicaciones.size() %></strong></div>
                        <div><span>Notas</span><strong><%= observaciones.size() %></strong></div>
                    </div>
                </div>
                <form class="observation-form" method="post">
                    <input type="hidden" name="accion" value="crearObservacion"/>
                    <label>Aplicacion
                        <select name="aplicacionId" required>
                            <% for (AplicacionPrueba a : aplicaciones) { %><option value="<%= a.getId() %>"><%= nombre(a.getEvaluado()) %> · <%= h(a.getPrueba()) %> · <%= h(a.getEstado()) %></option><% } %>
                        </select>
                    </label>
                    <label>Observacion <textarea name="comentario" required placeholder="Escribe una nota clara para seguimiento del evaluado..."></textarea></label>
                    <button class="button primary assignment-submit" type="submit">Guardar observacion</button>
                </form>
            </div>
            <div class="panel observation-board">
                <div class="observation-toolbar">
                    <div>
                        <h2>Historial de observaciones</h2>
                        <p class="muted">Consulta las notas recientes con contexto de estudiante, prueba y estado.</p>
                    </div>
                    <div class="observation-count"><%= observaciones.size() %> registradas</div>
                </div>
                <div class="observation-list">
                    <% if (observaciones.isEmpty()) { %>
                        <div class="observation-empty">Todavia no hay observaciones registradas.</div>
                    <% } %>
                    <% for (ObservacionPsicologica o : observaciones) {
                        AplicacionPrueba app = o.getAplicacion();
                        Evaluado evaluado = app == null ? null : app.getEvaluado();
                        String inicial = evaluado == null || evaluado.getNombres() == null || evaluado.getNombres().isBlank() ? "?" : h(evaluado.getNombres().substring(0, 1).toUpperCase());
                    %>
                        <article class="observation-card">
                            <div class="observation-avatar"><%= inicial %></div>
                            <div>
                                <div class="observation-card-head">
                                    <div>
                                        <h3><%= nombre(evaluado) %></h3>
                                        <p class="muted"><%= app == null ? "" : h(app.getPrueba()) %></p>
                                    </div>
                                    <span class="status-badge"><%= app == null ? "" : h(app.getEstado()) %></span>
                                </div>
                                <p class="muted"><%= f(o.getFechaObservacion()) %></p>
                                <div class="observation-note"><%= h(o.getComentario()) %></div>
                            </div>
                        </article>
                    <% } %>
                </div>
            </div>
        </section>
        <% } %>
    </main>
    <script>
        document.querySelectorAll('[data-filter-input]').forEach(input => {
            const key = input.dataset.filterInput;
            const items = Array.from(document.querySelectorAll('[data-filter-item="' + key + '"]'));
            const empty = document.querySelector('[data-empty-filter="' + key + '"]');
            input.addEventListener('input', () => {
                const text = input.value.trim().toLowerCase();
                let visibles = 0;
                items.forEach(item => {
                    const match = !text || (item.dataset.search || item.textContent).toLowerCase().includes(text);
                    item.style.display = match ? '' : 'none';
                    if (match) visibles++;
                });
                if (empty) empty.style.display = visibles === 0 ? 'block' : 'none';
            });
        });
    </script>
</body>
</html>
