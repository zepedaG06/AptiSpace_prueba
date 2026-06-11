package com.aptispace.web;

import java.io.IOException;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.Evaluado;
import com.aptispace.modelo.GrupoEvaluacion;
import com.aptispace.modelo.Usuario;

public class MiPerfilServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = obtenerUsuarioActual(request);
        request.setAttribute("usuarioCuenta", usuario);
        request.setAttribute("evaluado", usuario == null ? null : usuario.getEvaluado());
        request.setAttribute("grupos", usuario == null || usuario.getEvaluado() == null ? List.of() : gruposDelEvaluado(usuario.getEvaluado()));
        if (request.getServletPath().endsWith("/mi-grupo")) {
            request.setAttribute("grupo", grupoDelEvaluado(usuario == null ? null : usuario.getEvaluado(), largoOpcional(request, "id")));
            request.getRequestDispatcher("/WEB-INF/jsp/mi-grupo.jsp").forward(request, response);
            return;
        }
        if (request.getServletPath().endsWith("/unirme-grupo")) {
            request.getRequestDispatcher("/WEB-INF/jsp/unirme-grupo.jsp").forward(request, response);
            return;
        }
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

            if ("unirGrupo".equals(valor(request, "accion"))) {
                boolean unido = unirAGrupo(em, usuario.getEvaluado(), valor(request, "codigoEspacio"));
                confirmarSiEsPropia(em, transaccionPropia);
                response.sendRedirect(request.getContextPath() + "/unirme-grupo?ok=" + (unido ? "grupo" : "ya-grupo"));
                return;
            }

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

    private boolean unirAGrupo(EntityManager em, Evaluado evaluado, String codigo) {
        if (codigo == null || codigo.trim().isEmpty()) throw new IllegalArgumentException("Ingresa el codigo del grupo.");
        TypedQuery<GrupoEvaluacion> query = em.createQuery(
            "select distinct g from GrupoEvaluacion g left join fetch g.evaluados where g.codigo = :codigo and g.activo = true",
            GrupoEvaluacion.class);
        query.setParameter("codigo", codigo.trim().toUpperCase());
        GrupoEvaluacion grupo;
        try {
            grupo = query.getSingleResult();
        }
        catch (NoResultException ex) {
            throw new IllegalArgumentException("No existe un grupo activo con ese codigo.");
        }
        if (grupo.getEvaluados().stream().anyMatch(e -> e.getId().equals(evaluado.getId()))) {
            return false;
        }
        grupo.getEvaluados().add(evaluado);
        em.merge(grupo);
        return true;
    }

    private List<GrupoEvaluacion> gruposDelEvaluado(Evaluado evaluado) {
        EntityManager em = XPersistence.getManager();
        TypedQuery<GrupoEvaluacion> query = em.createQuery(
            "select g from GrupoEvaluacion g join g.evaluados e where e.id = :evaluadoId order by g.nombre",
            GrupoEvaluacion.class);
        query.setParameter("evaluadoId", evaluado.getId());
        return query.getResultList();
    }

    private GrupoEvaluacion grupoDelEvaluado(Evaluado evaluado, Long grupoId) {
        if (evaluado == null || grupoId == null) return null;
        EntityManager em = XPersistence.getManager();
        TypedQuery<GrupoEvaluacion> query = em.createQuery(
            "select distinct g from GrupoEvaluacion g left join fetch g.evaluados left join fetch g.psicologo where g.id = :grupoId and exists (select e from g.evaluados e where e.id = :evaluadoId)",
            GrupoEvaluacion.class);
        query.setParameter("grupoId", grupoId);
        query.setParameter("evaluadoId", evaluado.getId());
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

    private Long largoOpcional(HttpServletRequest request, String nombre) {
        String valor = valor(request, nombre);
        if (valor.isEmpty()) return null;
        try {
            return Long.valueOf(valor);
        }
        catch (NumberFormatException ex) {
            return null;
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
