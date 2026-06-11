<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.aptispace.modelo.*" %>
<%!
    String h(Object v) {
        if (v == null) return "";
        return String.valueOf(v).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    GrupoEvaluacion grupo = (GrupoEvaluacion) request.getAttribute("grupo");
    Usuario psicologo = grupo == null ? null : grupo.getPsicologo();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Mi grupo</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; background: #eef3f7; color: #1f2937; }
        header { padding: 24px 6vw; background: linear-gradient(135deg, rgba(31, 75, 93, .94), rgba(45, 156, 219, .76)), url("<%= request.getContextPath() %>/images/s2/modelo-06.svg"); background-size: cover; background-position: center; color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; }
        header h1 { margin: 0; font-size: 24px; letter-spacing: 0; }
        header a { border-radius: 6px; background: #1f6f8b; color: white; text-decoration: none; font-weight: 700; padding: 10px 13px; }
        main { max-width: 980px; margin: 24px auto 40px; padding: 0 18px; }
        .panel { background: #d9edf4; border: 1px solid #6aaec5; border-radius: 8px; overflow: hidden; box-shadow: 0 10px 26px rgba(31, 111, 139, .12); }
        .panel h2 { margin: 0; padding: 14px 18px; color: white; font-size: 20px; background: #1f6f8b; }
        .content { padding: 18px; display: grid; gap: 16px; }
        .grid { display: grid; grid-template-columns: .85fr 1.15fr; gap: 16px; align-items: start; }
        .box { border: 1px solid #b9d5df; border-radius: 8px; background: #f6fbfd; padding: 16px; }
        .box h3 { margin: 0 0 12px; color: #1f4b5d; }
        .muted { color: #52606d; line-height: 1.45; }
        .profile { display: grid; grid-template-columns: 58px minmax(0, 1fr); gap: 12px; align-items: center; }
        .avatar { width: 58px; height: 58px; border-radius: 8px; display: grid; place-items: center; background: #1f6f8b; color: white; font-size: 22px; font-weight: 800; overflow: hidden; }
        .avatar img { width: 100%; height: 100%; object-fit: cover; }
        .row { border-top: 1px solid #d7e0e7; padding-top: 10px; margin-top: 10px; }
        .participants { display: grid; gap: 10px; }
        .participant { border: 1px solid #d7e0e7; border-radius: 8px; background: white; padding: 11px; }
        .participant strong { color: #203a43; }
        @media (max-width: 760px) { header, .grid { grid-template-columns: 1fr; } header { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Informacion del grupo</h1>
        <a href="<%= request.getContextPath() %>/unirme-grupo">Volver</a>
    </header>
    <main>
        <section class="panel">
            <% if (grupo == null) { %>
                <h2>Grupo no disponible</h2>
                <div class="content"><div class="box"><p class="muted">No se encontro el grupo o no perteneces a el.</p></div></div>
            <% } else { %>
                <h2><%= h(grupo.getNombre()) %></h2>
                <div class="content grid">
                    <div class="box">
                        <h3>Datos del grupo</h3>
                        <p><strong>Codigo:</strong> <%= h(grupo.getCodigo()) %></p>
                        <p><strong>Estado:</strong> <%= Boolean.TRUE.equals(grupo.getActivo()) ? "Activo" : "Inactivo" %></p>
                        <p><strong>Creacion:</strong> <%= h(grupo.getFechaCreacion()) %></p>
                        <div class="row">
                            <h3>Evaluador</h3>
                            <div class="profile">
                                <div class="avatar">
                                    <% if (psicologo != null && psicologo.getFotoPerfil() != null && !psicologo.getFotoPerfil().isBlank()) { %>
                                        <img src="<%= request.getContextPath() %>/<%= h(psicologo.getFotoPerfil()) %>" alt="Foto del evaluador"/>
                                    <% } else { %>
                                        <%= psicologo == null || psicologo.getNombres() == null || psicologo.getNombres().isBlank() ? "E" : h(psicologo.getNombres().substring(0, 1).toUpperCase()) %>
                                    <% } %>
                                </div>
                                <div>
                                    <strong><%= psicologo == null ? "Sin evaluador" : h(psicologo.getNombres() + " " + psicologo.getApellidos()) %></strong><br/>
                                    <span class="muted"><%= psicologo == null ? "" : h(psicologo.getCorreo()) %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="box">
                        <h3>Participantes (<%= grupo.getEvaluados().size() %>)</h3>
                        <div class="participants">
                            <% for (Evaluado participante : grupo.getEvaluados()) { %>
                                <div class="participant">
                                    <strong><%= h(participante.getNombres() + " " + participante.getApellidos()) %></strong><br/>
                                    <span class="muted"><%= h(participante.getCarrera()) %><%= participante.getAnioCarrera() == null ? "" : " · Año " + participante.getAnioCarrera() %></span>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } %>
        </section>
    </main>
</body>
</html>
