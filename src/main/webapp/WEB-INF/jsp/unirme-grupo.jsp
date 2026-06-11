<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.aptispace.modelo.*" %>
<%
    List<GrupoEvaluacion> grupos = (List<GrupoEvaluacion>) request.getAttribute("grupos");
    String ok = request.getParameter("ok");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Unirme a grupo</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; background: #eef3f7; color: #1f2937; }
        header { padding: 24px 6vw; background: linear-gradient(135deg, rgba(31, 75, 93, .94), rgba(45, 156, 219, .76)), url("<%= request.getContextPath() %>/images/s2/modelo-06.svg"); background-size: cover; background-position: center; color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; }
        header h1 { margin: 0; font-size: 24px; letter-spacing: 0; }
        header a { border-radius: 6px; background: #1f6f8b; color: white; text-decoration: none; font-weight: 700; padding: 10px 13px; }
        main { max-width: 860px; margin: 24px auto 40px; padding: 0 18px; }
        .panel { background: #d9edf4; border: 1px solid #6aaec5; border-radius: 8px; overflow: hidden; box-shadow: 0 10px 26px rgba(31, 111, 139, .12); }
        .panel h2 { margin: 0; padding: 14px 18px; color: white; font-size: 20px; background: #1f6f8b; }
        .content { padding: 18px; display: grid; gap: 16px; }
        .box { border: 1px solid #b9d5df; border-radius: 8px; background: #f6fbfd; padding: 16px; }
        .notice { padding: 12px 14px; border-radius: 8px; margin-bottom: 14px; border: 1px solid #badbcc; background: #edf8f1; color: #0f5132; }
        .error { border-color: #f2b8b5; background: #fff1f0; color: #8a1f17; }
        form { display: grid; gap: 14px; }
        label { display: grid; gap: 6px; font-size: 13px; font-weight: 700; color: #334155; }
        input { width: 100%; min-height: 44px; border: 1px solid #cbd5e1; border-radius: 6px; padding: 9px 11px; font: inherit; text-transform: uppercase; }
        .actions { display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
        .button, button { border: 0; border-radius: 6px; padding: 11px 16px; font-weight: 700; cursor: pointer; text-decoration: none; }
        .secondary { background: #1f4b5d; color: white; border: 1px solid #17384d; }
        .primary { background: #1f6f8b; color: white; }
        .muted { color: #52606d; line-height: 1.45; }
        .group-list { display: grid; gap: 8px; }
        .group-item { display: block; border: 1px solid #b9d5df; border-radius: 8px; background: #f6fbfd; padding: 12px; color: #1f2937; text-decoration: none; }
        .group-item strong { color: #1f4b5d; }
        @media (max-width: 680px) { header { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Unirme a grupo</h1>
        <a href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
    </header>
    <main>
        <% if ("grupo".equals(ok)) { %><div class="notice">Te uniste al grupo correctamente.</div><% } %>
        <% if ("ya-grupo".equals(ok)) { %><div class="notice">Ya estas dentro de ese grupo.</div><% } %>
        <% if (error != null && !error.isEmpty()) { %><div class="notice error"><%= error %></div><% } %>
        <section class="panel">
            <h2>Ingresar codigo de espacio</h2>
            <div class="content">
                <form class="box" method="post" action="<%= request.getContextPath() %>/unirme-grupo">
                    <input type="hidden" name="accion" value="unirGrupo"/>
                    <label>Codigo del grupo <input name="codigoEspacio" placeholder="Ej. S2-A2026" required/></label>
                    <div class="actions">
                        <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Cancelar</a>
                        <button class="primary" type="submit">Unirme</button>
                    </div>
                </form>
                <div class="box">
                    <h3>Mis grupos (<%= grupos == null ? 0 : grupos.size() %>)</h3>
                    <% if (grupos == null || grupos.isEmpty()) { %>
                        <p class="muted">Todavia no estas unido a ningun grupo.</p>
                    <% } else { %>
                        <div class="group-list">
                        <% for (GrupoEvaluacion grupo : grupos) { %>
                            <a class="group-item" href="<%= request.getContextPath() %>/mi-grupo?id=<%= grupo.getId() %>"><strong><%= grupo.getNombre() %></strong><br/><span class="muted">Codigo: <%= grupo.getCodigo() %></span></a>
                        <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </section>
    </main>
</body>
</html>
