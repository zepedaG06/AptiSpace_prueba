package com.aptispace.web;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.AplicacionPrueba;
import com.aptispace.modelo.AplicacionPrueba.EstadoAplicacion;
import com.aptispace.modelo.Ejercicio;
import com.aptispace.modelo.OpcionEjercicio;
import com.aptispace.modelo.RespuestaEvaluado;
import com.aptispace.servicio.ServicioCorreccion;

public class MiPruebaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        EntityManager em = XPersistence.getManager();
        AplicacionPrueba aplicacion = obtenerAplicacionFinalizada(em, request);
        if (aplicacion == null) aplicacion = obtenerAplicacionActual(em, request);
        if (aplicacion == null) aplicacion = obtenerAplicacionReaplicable(em, request);
        if (aplicacion == null) {
            request.setAttribute("sinPrueba", true);
            request.getRequestDispatcher("/WEB-INF/jsp/mi-prueba.jsp").forward(request, response);
            return;
        }

        int total = aplicacion.getRespuestas().size();
        int indice = obtenerIndice(request, total);
        request.setAttribute("aplicacion", aplicacion);
        if (total > 0) request.setAttribute("respuesta", aplicacion.getRespuestas().get(indice));
        request.setAttribute("indice", indice);
        request.setAttribute("total", total);
        request.setAttribute("segundosRestantes", segundosRestantes(aplicacion));
        request.getRequestDispatcher("/WEB-INF/jsp/mi-prueba.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        EntityManager em = XPersistence.getManager();
        if ("reaplicar".equals(request.getParameter("accion"))) {
            try {
                AplicacionPrueba aplicacionFinalizada = obtenerAplicacionFinalizadaPorId(em, request, largoOpcional(request.getParameter("aplicacionId")));
                if (aplicacionFinalizada == null) throw new IllegalArgumentException("No se encontro el intento finalizado para repetir.");
                reaplicar(em, aplicacionFinalizada);
                response.sendRedirect(request.getContextPath() + "/mi-prueba");
            }
            catch (RuntimeException ex) {
                response.sendRedirect(request.getContextPath() + "/mi-prueba?error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
            }
            return;
        }

        AplicacionPrueba aplicacion = obtenerAplicacionActual(em, request);
        if (aplicacion == null) {
            response.sendRedirect(request.getContextPath() + "/mi-prueba");
            return;
        }
        if (aplicacion.getRespuestas().isEmpty() || EstadoAplicacion.FINALIZADA.equals(aplicacion.getEstado())) {
            response.sendRedirect(request.getContextPath() + "/mi-prueba");
            return;
        }

        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        int indice = obtenerIndice(request, aplicacion.getRespuestas().size());
        try {
            RespuestaEvaluado respuesta = aplicacion.getRespuestas().get(indice);
            String accion = request.getParameter("accion");
            if (!"anterior".equals(accion) && !tieneSeleccion(request, respuesta)) {
                revertirSiEsPropia(em, transaccionPropia);
                response.sendRedirect(request.getContextPath() + "/mi-prueba?i=" + indice + "&error=" + java.net.URLEncoder.encode("Selecciona una respuesta antes de continuar.", "UTF-8"));
                return;
            }
            if (tieneSeleccion(request, respuesta)) guardarSeleccion(request, respuesta);

            if ("finalizar".equals(accion)) {
                aplicacion.finalizar();
                ServicioCorreccion.corregir(aplicacion);
                em.merge(aplicacion);
                confirmarSiEsPropia(em, transaccionPropia);
                response.sendRedirect(request.getContextPath() + "/mi-prueba?finalizada=" + aplicacion.getId());
                return;
            }

            em.merge(respuesta);
            confirmarSiEsPropia(em, transaccionPropia);
            if ("anterior".equals(accion)) indice = Math.max(0, indice - 1);
            else indice = Math.min(aplicacion.getRespuestas().size() - 1, indice + 1);
            response.sendRedirect(request.getContextPath() + "/mi-prueba?i=" + indice);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private AplicacionPrueba obtenerAplicacionActual(EntityManager em, HttpServletRequest request) {
        String usuario = (String) request.getSession(true).getAttribute("aptispace.usuario.EVALUADO");
        TypedQuery<AplicacionPrueba> query = em.createQuery(
            "select distinct a from AplicacionPrueba a left join fetch a.respuestas r left join fetch r.ejercicio e "
                + "where a.evaluado.usuario.nombreUsuario = :usuario "
                + "and a.estado = :estado "
                + "order by a.id desc",
            AplicacionPrueba.class);
        query.setParameter("usuario", usuario);
        query.setParameter("estado", EstadoAplicacion.EN_PROCESO);
        List<AplicacionPrueba> aplicaciones = query.getResultList();
        if (aplicaciones.isEmpty()) return null;
        AplicacionPrueba aplicacion = null;
        for (AplicacionPrueba candidata : aplicaciones) {
            if (candidata.getFechaFin() != null) {
                marcarFinalizadaSiHaceFalta(em, candidata);
                continue;
            }
            aplicacion = candidata;
            break;
        }
        if (aplicacion == null) return null;
        prepararSiHaceFalta(em, aplicacion);
        finalizarSiTiempoVencido(em, aplicacion);
        aplicacion.getRespuestas().sort((a, b) -> a.getEjercicio().getNumero().compareTo(b.getEjercicio().getNumero()));
        for (RespuestaEvaluado respuesta : aplicacion.getRespuestas()) {
            respuesta.getEjercicio().getOpciones().size();
        }
        return aplicacion;
    }

    private void marcarFinalizadaSiHaceFalta(EntityManager em, AplicacionPrueba aplicacion) {
        if (aplicacion == null || !EstadoAplicacion.EN_PROCESO.equals(aplicacion.getEstado()) || aplicacion.getFechaFin() == null) return;
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            aplicacion.setEstado(EstadoAplicacion.FINALIZADA);
            em.merge(aplicacion);
            confirmarSiEsPropia(em, transaccionPropia);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private AplicacionPrueba obtenerAplicacionReaplicable(EntityManager em, HttpServletRequest request) {
        String usuario = (String) request.getSession(true).getAttribute("aptispace.usuario.EVALUADO");
        TypedQuery<AplicacionPrueba> query = em.createQuery(
            "select distinct a from AplicacionPrueba a left join fetch a.resultado left join fetch a.respuestas r left join fetch r.ejercicio e "
                + "where a.evaluado.usuario.nombreUsuario = :usuario "
                + "and a.estado = :estado "
                + "and a.autorizadaReaplicacion = true "
                + "order by a.id desc",
            AplicacionPrueba.class);
        query.setParameter("usuario", usuario);
        query.setParameter("estado", EstadoAplicacion.FINALIZADA);
        query.setMaxResults(1);
        List<AplicacionPrueba> aplicaciones = query.getResultList();
        if (aplicaciones.isEmpty()) return null;
        AplicacionPrueba aplicacion = aplicaciones.get(0);
        aplicacion.getRespuestas().sort((a, b) -> a.getEjercicio().getNumero().compareTo(b.getEjercicio().getNumero()));
        for (RespuestaEvaluado respuesta : aplicacion.getRespuestas()) respuesta.getEjercicio().getOpciones().size();
        return aplicacion;
    }

    private AplicacionPrueba obtenerAplicacionFinalizada(EntityManager em, HttpServletRequest request) {
        Long id = largoOpcional(request.getParameter("finalizada"));
        if (id == null) return null;
        return obtenerAplicacionFinalizadaPorId(em, request, id);
    }

    private AplicacionPrueba obtenerAplicacionFinalizadaPorId(EntityManager em, HttpServletRequest request, Long id) {
        if (id == null) return null;
        String usuario = (String) request.getSession(true).getAttribute("aptispace.usuario.EVALUADO");
        TypedQuery<AplicacionPrueba> query = em.createQuery(
            "select distinct a from AplicacionPrueba a left join fetch a.resultado left join fetch a.respuestas r left join fetch r.ejercicio e "
                + "where a.id = :id and a.evaluado.usuario.nombreUsuario = :usuario and a.estado = :estado",
            AplicacionPrueba.class);
        query.setParameter("id", id);
        query.setParameter("usuario", usuario);
        query.setParameter("estado", EstadoAplicacion.FINALIZADA);
        List<AplicacionPrueba> aplicaciones = query.getResultList();
        if (aplicaciones.isEmpty()) return null;
        AplicacionPrueba aplicacion = aplicaciones.get(0);
        aplicacion.getRespuestas().sort((a, b) -> a.getEjercicio().getNumero().compareTo(b.getEjercicio().getNumero()));
        for (RespuestaEvaluado respuesta : aplicacion.getRespuestas()) respuesta.getEjercicio().getOpciones().size();
        return aplicacion;
    }

    private void reaplicar(EntityManager em, AplicacionPrueba aplicacionAnterior) {
        if (!EstadoAplicacion.FINALIZADA.equals(aplicacionAnterior.getEstado())) {
            throw new IllegalArgumentException("Solo puedes repetir una prueba finalizada.");
        }
        if (!Boolean.TRUE.equals(aplicacionAnterior.getAutorizadaReaplicacion())) {
            throw new IllegalArgumentException("El evaluador todavia no autorizo repetir esta prueba.");
        }
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            aplicacionAnterior.setAutorizadaReaplicacion(Boolean.FALSE);
            AplicacionPrueba nueva = new AplicacionPrueba();
            nueva.setEvaluado(aplicacionAnterior.getEvaluado());
            nueva.setPrueba(aplicacionAnterior.getPrueba());
            nueva.setPsicologo(aplicacionAnterior.getPsicologo());
            nueva.setAutorizadaReaplicacion(Boolean.FALSE);
            asignarEjercicios(nueva);
            nueva.iniciar();
            em.persist(nueva);
            em.merge(aplicacionAnterior);
            confirmarSiEsPropia(em, transaccionPropia);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private void prepararSiHaceFalta(EntityManager em, AplicacionPrueba aplicacion) {
        if (!aplicacion.getRespuestas().isEmpty() || aplicacion.getPrueba() == null) return;
        aplicacion.getPrueba().getEjercicios().size();
        if (aplicacion.getPrueba().getEjercicios().isEmpty()) return;
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            asignarEjercicios(aplicacion);
            em.merge(aplicacion);
            confirmarSiEsPropia(em, transaccionPropia);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private void asignarEjercicios(AplicacionPrueba aplicacion) {
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

    private int obtenerIndice(HttpServletRequest request, int total) {
        if (total <= 0) return 0;
        try {
            int indice = Integer.parseInt(request.getParameter("i"));
            if (indice < 0) return 0;
            return Math.min(indice, total - 1);
        }
        catch (Exception ex) {
            return 0;
        }
    }

    private Long largoOpcional(String valor) {
        if (valor == null || valor.isBlank()) return null;
        try { return Long.valueOf(valor); }
        catch (NumberFormatException ex) { return null; }
    }

    private void guardarSeleccion(HttpServletRequest request, RespuestaEvaluado respuesta) {
        boolean multiple = Ejercicio.TipoRespuesta.MULTIPLE.equals(respuesta.getEjercicio().getTipoRespuesta());
        List<String> opciones = multiple
            ? valores(request.getParameterValues("opciones"))
            : valores(request.getParameter("opcion"));
        respuesta.setOpcionA(opciones.contains("A"));
        respuesta.setOpcionB(opciones.contains("B"));
        respuesta.setOpcionC(opciones.contains("C"));
        respuesta.setOpcionD(opciones.contains("D"));
        respuesta.setOpcionE(opciones.contains("E"));
    }

    private boolean tieneSeleccion(HttpServletRequest request, RespuestaEvaluado respuesta) {
        boolean multiple = Ejercicio.TipoRespuesta.MULTIPLE.equals(respuesta.getEjercicio().getTipoRespuesta());
        if (multiple) {
            String[] opciones = request.getParameterValues("opciones");
            return opciones != null && opciones.length > 0;
        }
        String opcion = request.getParameter("opcion");
        return opcion != null && !opcion.isBlank();
    }

    private void finalizarSiTiempoVencido(EntityManager em, AplicacionPrueba aplicacion) {
        if (!EstadoAplicacion.EN_PROCESO.equals(aplicacion.getEstado()) || aplicacion.getFechaInicio() == null || aplicacion.getPrueba() == null) return;
        int limiteSegundos = aplicacion.getPrueba().getTiempoLimite() * 60;
        long usados = Duration.between(aplicacion.getFechaInicio(), LocalDateTime.now()).getSeconds();
        if (usados < limiteSegundos) return;
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            aplicacion.finalizar();
            ServicioCorreccion.corregir(aplicacion);
            em.merge(aplicacion);
            confirmarSiEsPropia(em, transaccionPropia);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private int segundosRestantes(AplicacionPrueba aplicacion) {
        if (aplicacion == null || aplicacion.getPrueba() == null || aplicacion.getFechaInicio() == null || !EstadoAplicacion.EN_PROCESO.equals(aplicacion.getEstado())) return 0;
        int limiteSegundos = aplicacion.getPrueba().getTiempoLimite() * 60;
        long usados = Duration.between(aplicacion.getFechaInicio(), LocalDateTime.now()).getSeconds();
        return Math.max(0, limiteSegundos - (int) usados);
    }

    private List<String> valores(String valor) {
        if (valor == null || valor.isBlank()) return List.of();
        return List.of(valor);
    }

    private List<String> valores(String[] valores) {
        if (valores == null) return List.of();
        List<String> lista = new ArrayList<>();
        for (String valor : valores) if (valor != null && !valor.isBlank()) lista.add(valor);
        return lista;
    }

    public static boolean seleccionada(RespuestaEvaluado respuesta, OpcionEjercicio.LetraOpcion letra) {
        switch (letra) {
            case A: return respuesta.isOpcionA();
            case B: return respuesta.isOpcionB();
            case C: return respuesta.isOpcionC();
            case D: return respuesta.isOpcionD();
            case E: return respuesta.isOpcionE();
            default: return false;
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
