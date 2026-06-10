<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.aptispace.modelo.*" %>
<%!
    String h(Object v) {
        if (v == null) return "";
        return String.valueOf(v).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    Usuario usuario = (Usuario) request.getAttribute("usuarioCuenta");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Mi informacion</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; color: #1f2937; background: #eef3f7; }
        header { padding: 30px 7vw 28px; background: linear-gradient(135deg, rgba(20, 42, 71, .93), rgba(31, 111, 139, .82)), url("<%= request.getContextPath() %>/images/s2/modelo-03.svg"); background-size: cover; background-position: center; color: white; }
        header h1 { margin: 0 0 8px; font-size: 32px; letter-spacing: 0; }
        header p { margin: 0; color: #dbe8ef; line-height: 1.5; }
        main { max-width: 980px; margin: 22px auto 44px; padding: 0 20px; }
        .top { display: flex; justify-content: space-between; gap: 12px; align-items: center; margin-bottom: 16px; padding: 12px; background: white; border: 1px solid #d7e0e7; border-radius: 8px; }
        .top a, .button { display: inline-flex; align-items: center; justify-content: center; min-height: 40px; border: 0; border-radius: 6px; padding: 10px 13px; font-weight: 700; text-decoration: none; cursor: pointer; }
        .top a:first-child, .button.primary { background: #1f6f8b; color: white; }
        .top a:last-child { background: #eef3f7; color: #203a43; border: 1px solid #cbd5df; }
        .layout { display: grid; grid-template-columns: minmax(0, 1.1fr) .8fr; gap: 16px; align-items: start; }
        .panel { background: white; border: 1px solid #d7e0e7; border-radius: 8px; padding: 18px; }
        h2 { margin: 0 0 12px; color: #203a43; }
        p { line-height: 1.45; }
        .muted { color: #64748b; }
        form { display: grid; gap: 12px; }
        label { display: grid; gap: 6px; font-weight: 700; color: #334155; }
        input { width: 100%; border: 1px solid #cbd5df; border-radius: 6px; padding: 10px; font: inherit; background: white; }
        input[type="file"] { padding: 8px; }
        .notice { margin-bottom: 14px; padding: 12px; border-radius: 8px; background: #e8f6ef; color: #166534; border: 1px solid #b9e2ca; }
        .error { margin-bottom: 14px; padding: 12px; border-radius: 8px; background: #fff1f2; color: #9f1239; border: 1px solid #fecdd3; }
        .profile-card { display: grid; gap: 12px; }
        .avatar { width: 82px; height: 82px; border-radius: 8px; display: grid; place-items: center; background: #1f6f8b; color: white; font-size: 28px; font-weight: 800; overflow: hidden; }
        .avatar img { width: 100%; height: 100%; object-fit: cover; }
        .file-note { color: #64748b; font-size: 13px; font-weight: 400; line-height: 1.35; }
        .profile-row { border: 1px solid #e3e9ef; border-radius: 8px; background: #f8fafc; padding: 11px; }
        .profile-row span { display: block; color: #64748b; font-size: 12px; margin-bottom: 4px; }
        .profile-row strong { color: #203a43; }
        @media (max-width: 760px) { .layout { grid-template-columns: 1fr; } .top { align-items: stretch; flex-direction: column; } .top a { width: 100%; } }
    </style>
</head>
<body>
    <header>
        <h1>Mi informacion</h1>
        <p>Consulta y actualiza los datos de tu cuenta de evaluador.</p>
    </header>
    <main>
        <div class="top">
            <a href="<%= request.getContextPath() %>/evaluador-home.jsp">Volver al panel</a>
            <a href="<%= request.getContextPath() %>/logout">Cerrar sesion</a>
        </div>
        <% if ("1".equals(request.getParameter("ok"))) { %><div class="notice">Informacion actualizada.</div><% } %>
        <% if (request.getParameter("error") != null) { %><div class="error"><%= h(request.getParameter("error")) %></div><% } %>
        <section class="layout">
            <div class="panel">
                <h2>Editar cuenta</h2>
                <form method="post" enctype="multipart/form-data">
                    <label>Nombres <input name="nombres" value="<%= h(usuario == null ? "" : usuario.getNombres()) %>" required/></label>
                    <label>Apellidos <input name="apellidos" value="<%= h(usuario == null ? "" : usuario.getApellidos()) %>" required/></label>
                    <label>Correo <input type="email" name="correo" value="<%= h(usuario == null ? "" : usuario.getCorreo()) %>" required/></label>
                    <label>Foto de perfil
                        <input type="file" name="fotoPerfil" accept="image/png,image/jpeg,image/gif,image/webp"/>
                        <span class="file-note">PNG, JPG, GIF o WEBP. Si no seleccionas una nueva, se conserva la actual.</span>
                    </label>
                    <label>Nueva contrasena <input type="password" name="nuevaContrasena" minlength="6" placeholder="Dejar vacio para conservar la actual"/></label>
                    <button class="button primary" type="submit">Guardar cambios</button>
                </form>
            </div>
            <aside class="panel profile-card">
                <div class="avatar">
                    <% if (usuario != null && usuario.getFotoPerfil() != null && !usuario.getFotoPerfil().isBlank()) { %>
                        <img src="<%= request.getContextPath() %>/<%= h(usuario.getFotoPerfil()) %>" alt="Foto de perfil"/>
                    <% } else { %>
                        <%= usuario == null || usuario.getNombres() == null || usuario.getNombres().isBlank() ? "E" : h(usuario.getNombres().substring(0, 1).toUpperCase()) %>
                    <% } %>
                </div>
                <div>
                    <h2><%= h(usuario == null ? "" : usuario.getNombres() + " " + usuario.getApellidos()) %></h2>
                    <p class="muted">Cuenta de evaluador activa para gestionar grupos, plantillas, asignaciones y resultados.</p>
                </div>
                <div class="profile-row"><span>Usuario</span><strong><%= h(usuario == null ? "" : usuario.getNombreUsuario()) %></strong></div>
                <div class="profile-row"><span>Correo</span><strong><%= h(usuario == null ? "" : usuario.getCorreo()) %></strong></div>
                <div class="profile-row"><span>Estado</span><strong><%= h(usuario == null ? "" : usuario.getEstado()) %></strong></div>
                <div class="profile-row"><span>Creacion</span><strong><%= h(usuario == null ? "" : usuario.getFechaCreacion()) %></strong></div>
            </aside>
        </section>
    </main>
</body>
</html>
