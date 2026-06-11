<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.aptispace.modelo.*" %>
<%
    Usuario usuarioCuenta = (Usuario) request.getAttribute("usuarioCuenta");
    Evaluado evaluado = (Evaluado) request.getAttribute("evaluado");
    List<GrupoEvaluacion> grupos = (List<GrupoEvaluacion>) request.getAttribute("grupos");
    String ok = request.getParameter("ok");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>AptiSpace | Mi informacion</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, Helvetica, sans-serif; background: #eef3f7; color: #1f2937; }
        header { padding: 22px 6vw; background: linear-gradient(135deg, rgba(31, 75, 93, .94), rgba(45, 156, 219, .76)), url("<%= request.getContextPath() %>/images/s2/modelo-06.svg"); background-size: cover; background-position: center; color: white; display: flex; justify-content: space-between; gap: 16px; align-items: center; }
        header h1 { margin: 0; font-size: 24px; letter-spacing: 0; }
        header a { border-radius: 6px; background: #1f6f8b; color: white; text-decoration: none; font-weight: 700; padding: 10px 13px; }
        main { max-width: 860px; margin: 24px auto 40px; padding: 0 18px; }
        .card { background: #d9edf4; border: 1px solid #6aaec5; border-radius: 8px; overflow: hidden; box-shadow: 0 10px 26px rgba(31, 111, 139, .12); }
        .card h2:first-child { margin: 0; padding: 14px 18px; color: white; font-size: 20px; background: #1f6f8b; }
        .card-body { padding: 18px; display: grid; gap: 16px; }
        .box { border: 1px solid #b9d5df; border-radius: 8px; background: #f6fbfd; padding: 16px; }
        .notice { padding: 12px 14px; border-radius: 8px; margin-bottom: 14px; border: 1px solid #badbcc; background: #edf8f1; color: #0f5132; }
        .error { border-color: #f2b8b5; background: #fff1f0; color: #8a1f17; }
        form { display: grid; gap: 14px; }
        .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; }
        label { display: grid; gap: 6px; font-size: 13px; font-weight: 700; color: #334155; }
        input, select { width: 100%; min-height: 42px; border: 1px solid #cbd5e1; border-radius: 6px; padding: 9px 11px; font: inherit; background: white; }
        .actions { display: flex; justify-content: space-between; gap: 12px; flex-wrap: wrap; margin-top: 4px; }
        .button, button { border: 0; border-radius: 6px; padding: 11px 16px; font-weight: 700; cursor: pointer; text-decoration: none; }
        .secondary { background: #1f4b5d; color: white; border: 1px solid #17384d; }
        .primary { background: #1f6f8b; color: white; }
        .group-link { display: block; border: 1px solid #d7e0e7; border-radius: 8px; background: white; padding: 11px; color: #1f2937; text-decoration: none; margin-top: 8px; }
        .group-link strong { color: #1f4b5d; }
        @media (max-width: 680px) { .grid { grid-template-columns: 1fr; } header { align-items: flex-start; flex-direction: column; } }
    </style>
</head>
<body>
    <header>
        <h1>Mi informacion</h1>
        <a href="<%= request.getContextPath() %>/evaluado-home.jsp">Volver</a>
    </header>
    <main>
        <% if ("1".equals(ok)) { %><div class="notice">Informacion actualizada.</div><% } %>
        <% if ("grupo".equals(ok)) { %><div class="notice">Te uniste al grupo correctamente.</div><% } %>
        <% if ("ya-grupo".equals(ok)) { %><div class="notice">Ya estas dentro de ese grupo.</div><% } %>
        <% if (error != null && !error.isEmpty()) { %><div class="notice error"><%= error %></div><% } %>
        <section class="card">
            <% if (usuarioCuenta == null || evaluado == null) { %>
                <h2>No se encontro el perfil</h2>
                <p>La cuenta no esta vinculada con un evaluado.</p>
            <% } else { %>
                <h2>Datos personales</h2>
                <div class="card-body">
                <form class="box" method="post" action="<%= request.getContextPath() %>/mi-perfil">
                    <div class="grid">
                        <label>Nombres <input name="nombres" value="<%= usuarioCuenta.getNombres() %>" required/></label>
                        <label>Apellidos <input name="apellidos" value="<%= usuarioCuenta.getApellidos() %>" required/></label>
                        <label>Correo <input name="correo" type="email" value="<%= usuarioCuenta.getCorreo() == null ? "" : usuarioCuenta.getCorreo() %>"/></label>
                        <label>Edad <input name="edad" type="number" min="10" max="99" value="<%= evaluado.getEdad() %>" required/></label>
                        <label>Sexo
                            <select name="sexo" required>
                                <option value="FEMENINO" <%= Evaluado.Sexo.FEMENINO.equals(evaluado.getSexo()) ? "selected" : "" %>>Femenino</option>
                                <option value="MASCULINO" <%= Evaluado.Sexo.MASCULINO.equals(evaluado.getSexo()) ? "selected" : "" %>>Masculino</option>
                                <option value="OTRO" <%= Evaluado.Sexo.OTRO.equals(evaluado.getSexo()) ? "selected" : "" %>>Otro</option>
                            </select>
                        </label>
                        <label>Carrera <input name="carrera" value="<%= evaluado.getCarrera() == null ? "" : evaluado.getCarrera() %>"/></label>
                        <label>Año de la carrera <input name="anioCarrera" type="number" min="1" max="12" value="<%= evaluado.getAnioCarrera() == null ? "" : evaluado.getAnioCarrera() %>"/></label>
                    </div>
                    <div class="actions">
                        <a class="button secondary" href="<%= request.getContextPath() %>/evaluado-home.jsp">Cancelar</a>
                        <button class="primary" type="submit">Guardar cambios</button>
                    </div>
                </form>
                <div class="box">
                    <h2>Mis grupos (<%= grupos == null ? 0 : grupos.size() %>)</h2>
                    <% if (grupos == null || grupos.isEmpty()) { %>
                        <p>Todavia no estas unido a ningun grupo.</p>
                    <% } else { %>
                        <% for (GrupoEvaluacion grupo : grupos) { %>
                            <a class="group-link" href="<%= request.getContextPath() %>/mi-grupo?id=<%= grupo.getId() %>"><strong><%= grupo.getNombre() %></strong><br/><span style="color:#64748b;">Codigo: <%= grupo.getCodigo() %></span></a>
                        <% } %>
                    <% } %>
                </div>
                </div>
            <% } %>
        </section>
    </main>
</body>
</html>
