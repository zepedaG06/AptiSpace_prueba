package com.aptispace.web;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

final class RoleSessionSupport {
    private static final String COOKIE_PREFIX = "aptispace_role_";
    private static final String SECRET = System.getProperty(
        "aptispace.session.secret",
        System.getenv().getOrDefault("APTISPACE_SESSION_SECRET", "aptispace-local-session-key")
    );

    private RoleSessionSupport() { }

    static void guardar(HttpServletRequest request, HttpServletResponse response, String tipo, String usuario) {
        request.getSession(true).setAttribute(atributo(tipo), usuario);
        Cookie cookie = new Cookie(COOKIE_PREFIX + tipo, firmarValor(usuario));
        cookie.setHttpOnly(true);
        cookie.setPath(path(request));
        cookie.setMaxAge(-1);
        response.addCookie(cookie);
    }

    static String usuario(HttpServletRequest request, String tipo) {
        String usuario = (String) request.getSession(true).getAttribute(atributo(tipo));
        if (usuario != null && !usuario.isBlank()) return usuario;
        usuario = usuarioDesdeCookie(request, tipo);
        if (usuario != null) request.getSession(true).setAttribute(atributo(tipo), usuario);
        return usuario;
    }

    static void limpiar(HttpServletRequest request, HttpServletResponse response) {
        limpiarCookie(request, response, "ADMINISTRADOR");
        limpiarCookie(request, response, "PSICOLOGO");
        limpiarCookie(request, response, "EVALUADO");
    }

    static void limpiar(HttpServletRequest request, HttpServletResponse response, String tipo) {
        if (tipo == null || tipo.isBlank()) return;
        request.getSession(true).removeAttribute(atributo(tipo));
        limpiarCookie(request, response, tipo);
    }

    private static String atributo(String tipo) {
        return "aptispace.usuario." + tipo;
    }

    private static String path(HttpServletRequest request) {
        return request.getContextPath().isEmpty() ? "/" : request.getContextPath();
    }

    private static void limpiarCookie(HttpServletRequest request, HttpServletResponse response, String tipo) {
        Cookie cookie = new Cookie(COOKIE_PREFIX + tipo, "");
        cookie.setHttpOnly(true);
        cookie.setPath(path(request));
        cookie.setMaxAge(0);
        response.addCookie(cookie);
    }

    private static String usuarioDesdeCookie(HttpServletRequest request, String tipo) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        String nombre = COOKIE_PREFIX + tipo;
        for (Cookie cookie : cookies) {
            if (nombre.equals(cookie.getName())) return verificarValor(cookie.getValue());
        }
        return null;
    }

    private static String firmarValor(String usuario) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(usuario.getBytes(StandardCharsets.UTF_8))
            + "." + firma(usuario);
    }

    private static String verificarValor(String valor) {
        if (valor == null) return null;
        int punto = valor.indexOf('.');
        if (punto < 1) return null;
        try {
            String usuario = new String(Base64.getUrlDecoder().decode(valor.substring(0, punto)), StandardCharsets.UTF_8);
            String esperada = firma(usuario);
            String recibida = valor.substring(punto + 1);
            return MessageDigest.isEqual(esperada.getBytes(StandardCharsets.UTF_8), recibida.getBytes(StandardCharsets.UTF_8)) ? usuario : null;
        }
        catch (RuntimeException ex) {
            return null;
        }
    }

    private static String firma(String usuario) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(mac.doFinal(usuario.getBytes(StandardCharsets.UTF_8)));
        }
        catch (Exception ex) {
            throw new IllegalStateException("No se pudo firmar la sesion.", ex);
        }
    }
}
