package com.aptispace.web;

import java.io.IOException;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.Usuario;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 8 * 1024 * 1024)
public class MiInformacionEvaluadorServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = usuarioActual(request);
        request.setAttribute("usuarioCuenta", usuario);
        request.getRequestDispatcher("/WEB-INF/jsp/mi-informacion-evaluador.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        EntityManager em = XPersistence.getManager();
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            Usuario usuario = usuarioActual(request);
            if (usuario == null) throw new IllegalStateException("No se encontro la cuenta del evaluador.");

            String nombres = requerido(request, "nombres");
            String apellidos = requerido(request, "apellidos");
            String correo = requerido(request, "correo");
            String nuevaContrasena = valor(request, "nuevaContrasena");
            String fotoPerfil = guardarFoto(em, request);

            usuario.setNombres(nombres);
            usuario.setApellidos(apellidos);
            usuario.setCorreo(correo);
            if (fotoPerfil != null) usuario.setFotoPerfil(fotoPerfil);
            if (!nuevaContrasena.isEmpty()) {
                if (nuevaContrasena.length() < 6) throw new IllegalArgumentException("La contrasena debe tener al menos 6 caracteres.");
                usuario.setContrasena(nuevaContrasena);
            }
            em.merge(usuario);
            confirmarSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getContextPath() + "/mi-informacion-evaluador?ok=1");
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getContextPath() + "/mi-informacion-evaluador?error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }

    private String guardarFoto(EntityManager em, HttpServletRequest request) throws IOException, ServletException {
        Part part = request.getPart("fotoPerfil");
        return UploadStorage.guardarImagen(em, part, false, "La foto de perfil debe ser una imagen.");
    }

    private Usuario usuarioActual(HttpServletRequest request) {
        String nombreUsuario = (String) request.getSession(true).getAttribute("aptispace.usuario.PSICOLOGO");
        EntityManager em = XPersistence.getManager();
        TypedQuery<Usuario> query = em.createQuery("select u from Usuario u left join fetch u.roles where u.nombreUsuario = :usuario", Usuario.class);
        query.setParameter("usuario", nombreUsuario);
        try {
            return query.getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private String requerido(HttpServletRequest request, String nombre) {
        String valor = valor(request, nombre);
        if (valor.isEmpty()) throw new IllegalArgumentException("El campo " + nombre + " es obligatorio.");
        return valor;
    }

    private String valor(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }

    private boolean iniciarTransaccionSiHaceFalta(EntityManager em) {
        if (em.getTransaction().isActive()) return false;
        em.getTransaction().begin();
        return true;
    }

    private void confirmarSiEsPropia(EntityManager em, boolean transaccionPropia) {
        if (transaccionPropia && em.getTransaction().isActive()) em.getTransaction().commit();
    }

    private void revertirSiEsPropia(EntityManager em, boolean transaccionPropia) {
        if (transaccionPropia && em.getTransaction().isActive()) em.getTransaction().rollback();
    }
}
