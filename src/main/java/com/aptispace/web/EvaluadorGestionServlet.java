package com.aptispace.web;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.*;
import com.aptispace.servicio.ServicioCorreccion;

public class EvaluadorGestionServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        cargarDatos(request);
        request.getRequestDispatcher("/WEB-INF/jsp/evaluador-gestion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        EntityManager em = XPersistence.getManager();
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            ejecutarAccion(em, request);
            confirmarSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getRequestURI() + "?ok=1");
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getRequestURI() + "?error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }

    private void ejecutarAccion(EntityManager em, HttpServletRequest request) {
        String accion = valor(request, "accion");
        if ("crearGrupo".equals(accion)) crearGrupo(em, request);
        else if ("crearPrueba".equals(accion)) crearPrueba(em, request);
        else if ("actualizarPrueba".equals(accion)) actualizarPrueba(em, request);
        else if ("eliminarPrueba".equals(accion)) eliminarPrueba(em, request);
        else if ("asignarPrueba".equals(accion)) asignarPrueba(em, request);
        else if ("iniciarPrueba".equals(accion)) iniciarPrueba(em, request);
        else if ("iniciarTodas".equals(accion)) iniciarTodas(em, request);
        else if ("finalizarPrueba".equals(accion)) finalizarPrueba(em, request);
        else if ("autorizarReaplicacion".equals(accion)) autorizarReaplicacion(em, request);
        else if ("calcularResultado".equals(accion)) ServicioCorreccion.corregirYGuardar(largo(request, "aplicacionId"));
        else if ("crearObservacion".equals(accion)) crearObservacion(em, request);
        else throw new IllegalArgumentException("Accion no reconocida.");
    }

    private void cargarDatos(HttpServletRequest request) {
        EntityManager em = XPersistence.getManager();
        Usuario psicologo = usuarioActual(em, request);
        request.setAttribute("seccion", seccion(request));
        request.setAttribute("grupos", lista(em, "select distinct g from GrupoEvaluacion g left join fetch g.evaluados where g.psicologo = :psicologo order by g.fechaCreacion desc", GrupoEvaluacion.class, psicologo));
        request.setAttribute("evaluados", lista(em, "select distinct e from Evaluado e left join fetch e.usuario join e.grupos g where g.psicologo = :psicologo order by e.apellidos, e.nombres", Evaluado.class, psicologo));
        request.setAttribute("pruebas", lista(em, "select distinct p from Prueba p left join fetch p.ejercicios order by p.nombre", Prueba.class));
        List<AplicacionPrueba> aplicaciones = lista(em, "select distinct a from AplicacionPrueba a left join fetch a.resultado left join fetch a.respuestas where a.psicologo = :psicologo order by a.id desc", AplicacionPrueba.class, psicologo);
        for (AplicacionPrueba aplicacion : aplicaciones) {
            normalizarEstadoInconsistente(em, aplicacion);
            for (RespuestaEvaluado respuesta : aplicacion.getRespuestas()) {
                respuesta.getEjercicio().getOpciones().size();
            }
        }
        request.setAttribute("aplicaciones", aplicaciones);
        request.setAttribute("observaciones", lista(em, "select o from ObservacionPsicologica o where o.psicologo = :psicologo order by o.fechaObservacion desc", ObservacionPsicologica.class, psicologo));
    }

    private void normalizarEstadoInconsistente(EntityManager em, AplicacionPrueba aplicacion) {
        if (aplicacion == null || !AplicacionPrueba.EstadoAplicacion.EN_PROCESO.equals(aplicacion.getEstado())) return;
        if (aplicacion.getFechaFin() == null && aplicacion.getResultado() == null) return;
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            aplicacion.setEstado(AplicacionPrueba.EstadoAplicacion.FINALIZADA);
            em.merge(aplicacion);
            confirmarSiEsPropia(em, transaccionPropia);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private String seccion(HttpServletRequest request) {
        String path = request.getServletPath();
        if (path.endsWith("/grupos")) return "grupos";
        if (path.endsWith("/evaluados")) return "evaluados";
        if (path.endsWith("/asignaciones")) return "asignaciones";
        if (path.endsWith("/resultados")) return "resultados";
        if (path.endsWith("/plantillas")) return "plantillas";
        if (path.endsWith("/observaciones")) return "observaciones";
        return "asignaciones";
    }

    private void crearGrupo(EntityManager em, HttpServletRequest request) {
        String codigo = requerido(request, "codigo").toUpperCase();
        if (buscarGrupo(em, codigo) != null) throw new IllegalArgumentException("Ya existe un grupo con ese codigo.");
        GrupoEvaluacion grupo = new GrupoEvaluacion();
        grupo.setNombre(requerido(request, "nombre"));
        grupo.setCodigo(codigo);
        grupo.setPsicologo(usuarioActual(em, request));
        grupo.setFechaCreacion(LocalDate.now());
        grupo.setActivo(request.getParameter("activo") != null);
        em.persist(grupo);
    }

    private void crearPrueba(EntityManager em, HttpServletRequest request) {
        String nombre = requerido(request, "nombre");
        if (existePruebaConNombre(em, nombre, null)) throw new IllegalArgumentException("Ya existe una plantilla con ese nombre.");
        Prueba prueba = new Prueba();
        prueba.setNombre(nombre);
        prueba.setDescripcion(valor(request, "descripcion"));
        prueba.setTiempoLimite(entero(request, "tiempoLimite", 30));
        prueba.setCantidadEjercicios(entero(request, "cantidadEjercicios", 8));
        prueba.setEstado(Prueba.EstadoPrueba.valueOf(valor(request, "estado", "ACTIVA")));
        em.persist(prueba);
    }

    private void actualizarPrueba(EntityManager em, HttpServletRequest request) {
        Prueba prueba = em.find(Prueba.class, largo(request, "pruebaId"));
        if (prueba == null) throw new IllegalArgumentException("No existe la plantilla indicada.");
        String nombre = requerido(request, "nombre");
        if (existePruebaConNombre(em, nombre, prueba.getId())) throw new IllegalArgumentException("Ya existe otra plantilla con ese nombre.");
        prueba.setNombre(nombre);
        prueba.setDescripcion(valor(request, "descripcion"));
        prueba.setTiempoLimite(entero(request, "tiempoLimite", 30));
        prueba.setCantidadEjercicios(entero(request, "cantidadEjercicios", 1));
        prueba.setEstado(Prueba.EstadoPrueba.valueOf(valor(request, "estado", "ACTIVA")));
        em.merge(prueba);
    }

    private void eliminarPrueba(EntityManager em, HttpServletRequest request) {
        Prueba prueba = em.find(Prueba.class, largo(request, "pruebaId"));
        if (prueba == null) throw new IllegalArgumentException("No existe la plantilla indicada.");
        List<AplicacionPrueba> aplicaciones = em.createQuery("select a from AplicacionPrueba a where a.prueba = :prueba", AplicacionPrueba.class)
            .setParameter("prueba", prueba)
            .getResultList();
        for (AplicacionPrueba aplicacion : aplicaciones) em.remove(aplicacion);
        em.flush();
        em.remove(prueba);
    }

    private void asignarPrueba(EntityManager em, HttpServletRequest request) {
        Prueba prueba = em.find(Prueba.class, largo(request, "pruebaId"));
        if (prueba == null) throw new IllegalArgumentException("Selecciona una prueba valida.");
        if (!Prueba.EstadoPrueba.ACTIVA.equals(prueba.getEstado())) throw new IllegalArgumentException("Solo puedes asignar plantillas activas.");
        Usuario psicologo = usuarioActual(em, request);
        List<Long> evaluadoIds = new ArrayList<>();
        Long grupoId = largoOpcional(request, "grupoId");
        if (grupoId != null) {
            GrupoEvaluacion grupo = em.find(GrupoEvaluacion.class, grupoId);
            if (grupo != null && !psicologo.equals(grupo.getPsicologo())) throw new IllegalArgumentException("Ese grupo no pertenece a tu cuenta.");
            if (grupo != null) for (Evaluado evaluado : grupo.getEvaluados()) evaluadoIds.add(evaluado.getId());
        }
        if (evaluadoIds.isEmpty()) throw new IllegalArgumentException("El grupo no tiene evaluados unidos con el codigo.");
        for (Long id : new java.util.LinkedHashSet<>(evaluadoIds)) {
            Evaluado evaluado = em.find(Evaluado.class, id);
            if (evaluado == null) continue;
            if (existeAsignacion(em, evaluado, prueba)) {
                throw new IllegalArgumentException("La prueba ya esta asignada a " + evaluado.getNombres() + " " + evaluado.getApellidos() + ". Usa autorizar repetir si necesita otro intento.");
            }
            AplicacionPrueba aplicacion = new AplicacionPrueba();
            aplicacion.setEvaluado(evaluado);
            aplicacion.setPrueba(prueba);
            aplicacion.setPsicologo(psicologo);
            aplicacion.setAutorizadaReaplicacion(request.getParameter("reaplicacion") != null);
            asignarEjerciciosAleatorios(aplicacion);
            em.persist(aplicacion);
        }
    }

    private void iniciarPrueba(EntityManager em, HttpServletRequest request) {
        AplicacionPrueba aplicacion = em.find(AplicacionPrueba.class, largo(request, "aplicacionId"));
        if (aplicacion == null) throw new IllegalArgumentException("No existe la asignacion.");
        if (!AplicacionPrueba.EstadoAplicacion.ASIGNADA.equals(aplicacion.getEstado())) {
            throw new IllegalArgumentException("Solo se pueden iniciar asignaciones pendientes. Si ya finalizo, usa Autorizar repetir.");
        }
        asignarEjerciciosAleatorios(aplicacion);
        aplicacion.iniciar();
        em.merge(aplicacion);
    }

    private void iniciarTodas(EntityManager em, HttpServletRequest request) {
        Usuario psicologo = usuarioActual(em, request);
        List<AplicacionPrueba> pendientes = em.createQuery(
            "select distinct a from AplicacionPrueba a left join fetch a.respuestas where a.psicologo = :psicologo and a.estado = :estado",
            AplicacionPrueba.class)
            .setParameter("psicologo", psicologo)
            .setParameter("estado", AplicacionPrueba.EstadoAplicacion.ASIGNADA)
            .getResultList();
        for (AplicacionPrueba aplicacion : pendientes) {
            aplicacion.getPrueba().getEjercicios().size();
            asignarEjerciciosAleatorios(aplicacion);
            aplicacion.iniciar();
            em.merge(aplicacion);
        }
    }

    private void finalizarPrueba(EntityManager em, HttpServletRequest request) {
        AplicacionPrueba aplicacion = em.find(AplicacionPrueba.class, largo(request, "aplicacionId"));
        if (aplicacion == null) throw new IllegalArgumentException("No existe la asignacion.");
        if (!AplicacionPrueba.EstadoAplicacion.EN_PROCESO.equals(aplicacion.getEstado())) {
            throw new IllegalArgumentException("Solo se pueden finalizar pruebas en proceso.");
        }
        aplicacion.finalizar();
        ServicioCorreccion.corregir(aplicacion);
        em.merge(aplicacion);
    }

    private void autorizarReaplicacion(EntityManager em, HttpServletRequest request) {
        AplicacionPrueba aplicacion = em.find(AplicacionPrueba.class, largo(request, "aplicacionId"));
        if (aplicacion == null) throw new IllegalArgumentException("No existe la asignacion.");
        Usuario psicologo = usuarioActual(em, request);
        if (aplicacion.getPsicologo() == null || !aplicacion.getPsicologo().getId().equals(psicologo.getId())) {
            throw new IllegalArgumentException("Esa asignacion no pertenece a tu cuenta.");
        }
        aplicacion.setAutorizadaReaplicacion(Boolean.TRUE);
        em.merge(aplicacion);
    }

    private void crearObservacion(EntityManager em, HttpServletRequest request) {
        AplicacionPrueba aplicacion = em.find(AplicacionPrueba.class, largo(request, "aplicacionId"));
        if (aplicacion == null) throw new IllegalArgumentException("Selecciona una asignacion valida.");
        ObservacionPsicologica observacion = new ObservacionPsicologica();
        observacion.setAplicacion(aplicacion);
        observacion.setPsicologo(usuarioActual(em, request));
        observacion.setComentario(requerido(request, "comentario"));
        em.persist(observacion);
    }

    private void asignarEjerciciosAleatorios(AplicacionPrueba aplicacion) {
        if (!aplicacion.getRespuestas().isEmpty()) return;
        if (aplicacion.getPrueba() == null || aplicacion.getPrueba().getEjercicios().isEmpty()) {
            throw new IllegalStateException("La prueba no tiene ejercicios cargados.");
        }
        List<Ejercicio> ejercicios = new ArrayList<>(aplicacion.getPrueba().getEjercicios());
        Collections.shuffle(ejercicios);
        int cantidad = Math.min(aplicacion.getPrueba().getCantidadEjercicios(), ejercicios.size());
        for (int i = 0; i < cantidad; i++) {
            RespuestaEvaluado respuesta = new RespuestaEvaluado();
            respuesta.setAplicacion(aplicacion);
            respuesta.setEjercicio(ejercicios.get(i));
            aplicacion.getRespuestas().add(respuesta);
        }
    }

    private Usuario usuarioActual(EntityManager em, HttpServletRequest request) {
        String nombreUsuario = (String) request.getSession(true).getAttribute("aptispace.usuario.PSICOLOGO");
        TypedQuery<Usuario> query = em.createQuery("select u from Usuario u where u.nombreUsuario = :usuario", Usuario.class);
        query.setParameter("usuario", nombreUsuario);
        return query.getSingleResult();
    }

    private GrupoEvaluacion buscarGrupo(EntityManager em, String codigo) {
        TypedQuery<GrupoEvaluacion> query = em.createQuery("select g from GrupoEvaluacion g where g.codigo = :codigo", GrupoEvaluacion.class);
        query.setParameter("codigo", codigo);
        try { return query.getSingleResult(); }
        catch (NoResultException ex) { return null; }
    }

    private boolean existePruebaConNombre(EntityManager em, String nombre, Long idActual) {
        String jpql = "select count(p) from Prueba p where lower(p.nombre) = lower(:nombre)";
        if (idActual != null) jpql += " and p.id <> :idActual";
        TypedQuery<Long> query = em.createQuery(jpql, Long.class).setParameter("nombre", nombre);
        if (idActual != null) query.setParameter("idActual", idActual);
        Long total = query.getSingleResult();
        return total > 0;
    }

    private boolean existeAsignacion(EntityManager em, Evaluado evaluado, Prueba prueba) {
        Long total = em.createQuery(
            "select count(a) from AplicacionPrueba a where a.evaluado = :evaluado and a.prueba = :prueba and a.estado <> :cancelada",
            Long.class)
            .setParameter("evaluado", evaluado)
            .setParameter("prueba", prueba)
            .setParameter("cancelada", AplicacionPrueba.EstadoAplicacion.CANCELADA)
            .getSingleResult();
        return total > 0;
    }

    private <T> List<T> lista(EntityManager em, String jpql, Class<T> tipo) {
        return em.createQuery(jpql, tipo).getResultList();
    }

    private <T> List<T> lista(EntityManager em, String jpql, Class<T> tipo, Usuario psicologo) {
        return em.createQuery(jpql, tipo).setParameter("psicologo", psicologo).getResultList();
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

    private String valor(HttpServletRequest request, String nombre, String defecto) {
        String valor = valor(request, nombre);
        return valor.isEmpty() ? defecto : valor;
    }

    private Integer entero(HttpServletRequest request, String nombre, int defecto) {
        String valor = valor(request, nombre);
        if (valor.isEmpty()) return defecto;
        try { return Integer.valueOf(valor); }
        catch (NumberFormatException ex) { throw new IllegalArgumentException("El campo " + nombre + " debe ser numerico."); }
    }

    private Long largo(HttpServletRequest request, String nombre) {
        Long valor = largoOpcional(request, nombre);
        if (valor == null) throw new IllegalArgumentException("El campo " + nombre + " es obligatorio.");
        return valor;
    }

    private Long largoOpcional(HttpServletRequest request, String nombre) {
        String valor = valor(request, nombre);
        if (valor.isEmpty()) return null;
        try { return Long.valueOf(valor); }
        catch (NumberFormatException ex) { throw new IllegalArgumentException("Hay un identificador invalido."); }
    }

    private List<Long> largos(String[] valores) {
        List<Long> ids = new ArrayList<>();
        if (valores == null) return ids;
        for (String valor : valores) if (valor != null && !valor.isBlank()) ids.add(Long.valueOf(valor));
        return ids;
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
