package com.aptispace.web;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.util.Users;

public class SesionAptiSpaceFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) { }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String path = http.getRequestURI().substring(http.getContextPath().length());

        if (esPublico(path)) {
            chain.doFilter(request, response);
            return;
        }

        String tipoRequerido = tipoRequerido(path);
        String usuario = usuarioParaRuta(http, tipoRequerido);
        String tipo = tipoRequerido != null ? tipoRequerido : (String) http.getSession(true).getAttribute("aptispace.tipo");
        if (usuario == null) {
            res.sendRedirect(http.getContextPath() + "/index.jsp");
            return;
        }

        if (usuario != null) {
            http.getSession(true).setAttribute("naviox.user", usuario);
            Users.setCurrent(usuario);
        }

        chain.doFilter(request, response);
    }

    private boolean esPublico(String path) {
        return path.equals("/")
            || path.equals("/index.jsp")
            || path.equals("/auth")
            || path.equals("/logout")
            || path.startsWith("/images/")
            || path.startsWith("/css/")
            || path.startsWith("/js/");
    }

    private String tipoRequerido(String path) {
        if (esRutaEvaluador(path)) return "PSICOLOGO";
        if (esRutaEvaluado(path)) return "EVALUADO";
        return null;
    }

    private String usuarioParaRuta(HttpServletRequest request, String tipoRequerido) {
        if (tipoRequerido != null) {
            return (String) request.getSession(true).getAttribute("aptispace.usuario." + tipoRequerido);
        }
        return (String) request.getSession(true).getAttribute("aptispace.usuario");
    }

    private boolean esModuloEvaluado(String path) {
        return path.startsWith("/m/RespuestaEvaluado") || path.startsWith("/m/ResultadoPrueba");
    }

    private boolean esRutaEvaluado(String path) {
        return path.equals("/evaluado-home.jsp")
            || path.equals("/mi-prueba")
            || path.equals("/mi-perfil")
            || path.equals("/unirme-grupo")
            || path.equals("/mi-grupo")
            || esModuloEvaluado(path);
    }

    private boolean esRutaEvaluador(String path) {
        return path.equals("/admin-home.jsp")
            || path.equals("/evaluador-home.jsp")
            || path.equals("/mi-informacion-evaluador")
            || path.equals("/plantilla-wizard")
            || path.equals("/grupos")
            || path.equals("/evaluados")
            || path.equals("/asignaciones")
            || path.equals("/resultados")
            || path.equals("/plantillas")
            || path.equals("/catalogo")
            || path.equals("/observaciones")
            || path.startsWith("/m/Usuario")
            || path.startsWith("/m/Rol")
            || path.startsWith("/m/Evaluado")
            || path.startsWith("/m/GrupoEvaluacion")
            || path.startsWith("/m/Prueba")
            || path.startsWith("/m/Ejercicio")
            || path.startsWith("/m/OpcionEjercicio")
            || path.startsWith("/m/PlantillaCorreccion")
            || path.startsWith("/m/AplicacionPrueba")
            || path.startsWith("/m/ObservacionPsicologica");
    }

    @Override
    public void destroy() { }
}
