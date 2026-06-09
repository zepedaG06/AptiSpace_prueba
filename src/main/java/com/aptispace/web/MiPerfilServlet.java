package com.aptispace.web;

import java.io.IOException;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.Evaluado;
import com.aptispace.modelo.Usuario;

public class MiPerfilServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = obtenerUsuarioActual(request);
        request.setAttribute("usuarioCuenta", usuario);
        request.setAttribute("evaluado", usuario == null ? null : usuario.getEvaluado());
        request.getRequestDispatcher("/WEB-INF/jsp/mi-perfil.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        EntityManager em = XPersistence.getManager();
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            Usuario usuario = obtenerUsuarioActual(request);
            if (usuario == null || usuario.getEvaluado() == null) throw new IllegalStateException("No se encontro el perfil.");

            Evaluado evaluado = usuario.getEvaluado();
            usuario.setNombres(valor(request, "nombres"));
            usuario.setApellidos(valor(request, "apellidos"));
            usuario.setCorreo(valor(request, "correo"));
            evaluado.setNombres(usuario.getNombres());
            evaluado.setApellidos(usuario.getApellidos());
            evaluado.setEdad(entero(request, "edad"));
            evaluado.setSexo(Evaluado.Sexo.valueOf(valor(request, "sexo")));
            evaluado.setCarrera(valor(request, "carrera"));
            evaluado.setAnioCarrera(enteroOpcional(request, "anioCarrera"));
            evaluado.setEstudiosRealizados(evaluado.getCarrera());
            evaluado.setProfesion(evaluado.getCarrera());
            em.merge(usuario);
            em.merge(evaluado);
            confirmarSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getContextPath() + "/mi-perfil?ok=1");
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getContextPath() + "/mi-perfil?error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }

    private Usuario obtenerUsuarioActual(HttpServletRequest request) {
        String nombreUsuario = (String) request.getSession(true).getAttribute("aptispace.usuario");
        EntityManager em = XPersistence.getManager();
        TypedQuery<Usuario> query = em.createQuery(
            "select u from Usuario u left join fetch u.evaluado where u.nombreUsuario = :usuario",
            Usuario.class);
        query.setParameter("usuario", nombreUsuario);
        try {
            return query.getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private String valor(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }

    private Integer entero(HttpServletRequest request, String nombre) {
        Integer valor = enteroOpcional(request, nombre);
        if (valor == null) throw new IllegalArgumentException("El campo " + nombre + " es obligatorio.");
        return valor;
    }

    private Integer enteroOpcional(HttpServletRequest request, String nombre) {
        String valor = valor(request, nombre);
        if (valor.isEmpty()) return null;
        try {
            return Integer.valueOf(valor);
        }
        catch (NumberFormatException ex) {
            throw new IllegalArgumentException("El campo " + nombre + " debe ser numerico.");
        }
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
