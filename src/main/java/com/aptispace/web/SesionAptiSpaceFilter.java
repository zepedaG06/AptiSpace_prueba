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

        if (path.equals("/index")) {
            res.sendRedirect(http.getContextPath() + "/");
            return;
        }

        if (esPublico(path)) {
            chain.doFilter(request, response);
            return;
        }

        String tipoRequerido = tipoRequerido(path);
        String usuario = usuarioParaRuta(http, tipoRequerido);
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
            || path.equals("/index")
            || path.equals("/index.jsp")
            || path.equals("/health")
            || path.equals("/auth")
            || path.equals("/logout")
            || path.startsWith("/images/")
            || path.startsWith("/uploads/")
            || path.startsWith("/css/")
            || path.startsWith("/js/");
    }

    private String tipoRequerido(String path) {
        if (esRutaAdministrador(path)) return "ADMINISTRADOR";
        if (esRutaEvaluador(path)) return "PSICOLOGO";
        if (esRutaEvaluado(path)) return "EVALUADO";
        return null;
    }

    private String usuarioParaRuta(HttpServletRequest request, String tipoRequerido) {
        if (tipoRequerido != null) {
            return RoleSessionSupport.usuario(request, tipoRequerido);
        }
        String administrador = RoleSessionSupport.usuario(request, "ADMINISTRADOR");
        if (administrador != null) return administrador;
        String evaluador = RoleSessionSupport.usuario(request, "PSICOLOGO");
        if (evaluador != null) return evaluador;
        return RoleSessionSupport.usuario(request, "EVALUADO");
    }

    private boolean esRutaAdministrador(String path) {
        return path.equals("/admin-home.jsp")
            || path.startsWith("/m/Usuario")
            || path.startsWith("/m/Rol")
            || path.startsWith("/m/GrupoEvaluacion")
            || path.startsWith("/m/Bitacora")
            || path.startsWith("/m/ConfiguracionBasica");
    }

    private boolean esModuloEvaluado(String path) {
        return false;
    }

    private boolean esRutaEvaluado(String path) {
        return path.equals("/evaluado-home.jsp")
            || path.equals("/mi-prueba")
            || path.equals("/mi-resultados")
            || path.equals("/mi-perfil")
            || path.equals("/unirme-grupo")
            || path.equals("/mi-grupo")
            || esModuloEvaluado(path);
    }

    private boolean esRutaEvaluador(String path) {
        return path.equals("/evaluador-home.jsp")
            || path.equals("/mi-informacion-evaluador")
            || path.equals("/plantilla-wizard")
            || path.equals("/grupos")
            || path.equals("/evaluados")
            || path.equals("/asignaciones")
            || path.equals("/resultados")
            || path.equals("/plantillas")
            || path.equals("/catalogo")
            || path.equals("/observaciones");
    }

    @Override
    public void destroy() { }
}
