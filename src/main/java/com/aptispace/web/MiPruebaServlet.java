package com.aptispace.web;

import java.io.IOException;
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
import com.aptispace.modelo.OpcionEjercicio;
import com.aptispace.modelo.RespuestaEvaluado;
import com.aptispace.servicio.ServicioCorreccion;

public class MiPruebaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        EntityManager em = XPersistence.getManager();
        AplicacionPrueba aplicacion = obtenerAplicacionActual(em, request);
        if (aplicacion == null) {
            request.setAttribute("sinPrueba", true);
            request.getRequestDispatcher("/WEB-INF/jsp/mi-prueba.jsp").forward(request, response);
            return;
        }

        int indice = obtenerIndice(request, aplicacion.getRespuestas().size());
        request.setAttribute("aplicacion", aplicacion);
        request.setAttribute("respuesta", aplicacion.getRespuestas().get(indice));
        request.setAttribute("indice", indice);
        request.setAttribute("total", aplicacion.getRespuestas().size());
        request.getRequestDispatcher("/WEB-INF/jsp/mi-prueba.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        EntityManager em = XPersistence.getManager();
        AplicacionPrueba aplicacion = obtenerAplicacionActual(em, request);
        if (aplicacion == null) {
            response.sendRedirect(request.getContextPath() + "/mi-prueba");
            return;
        }

        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        int indice = obtenerIndice(request, aplicacion.getRespuestas().size());
        try {
            RespuestaEvaluado respuesta = aplicacion.getRespuestas().get(indice);
            guardarSeleccion(request, respuesta);

            String accion = request.getParameter("accion");
            if ("finalizar".equals(accion)) {
                aplicacion.finalizar();
                ServicioCorreccion.corregir(aplicacion);
                em.merge(aplicacion);
                confirmarSiEsPropia(em, transaccionPropia);
                response.sendRedirect(request.getContextPath() + "/mi-prueba?i=" + indice);
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
        String usuario = (String) request.getSession(true).getAttribute("aptispace.usuario");
        TypedQuery<AplicacionPrueba> query = em.createQuery(
            "select distinct a from AplicacionPrueba a left join fetch a.respuestas r left join fetch r.ejercicio e "
                + "where lower(a.evaluado.nombres) = lower(:usuario) or lower(a.evaluado.apellidos) = lower(:usuario) "
                + "order by a.id desc",
            AplicacionPrueba.class);
        query.setParameter("usuario", usuario);
        query.setMaxResults(1);
        List<AplicacionPrueba> aplicaciones = query.getResultList();
        if (aplicaciones.isEmpty()) {
            aplicaciones = em.createQuery(
                "select distinct a from AplicacionPrueba a left join fetch a.respuestas r left join fetch r.ejercicio e "
                    + "where a.estado in :estados order by a.id desc",
                AplicacionPrueba.class)
                .setParameter("estados", List.of(EstadoAplicacion.ASIGNADA, EstadoAplicacion.EN_PROCESO, EstadoAplicacion.FINALIZADA))
                .setMaxResults(1)
                .getResultList();
        }
        if (aplicaciones.isEmpty()) return null;
        AplicacionPrueba aplicacion = aplicaciones.get(0);
        aplicacion.getRespuestas().sort((a, b) -> a.getEjercicio().getNumero().compareTo(b.getEjercicio().getNumero()));
        for (RespuestaEvaluado respuesta : aplicacion.getRespuestas()) {
            respuesta.getEjercicio().getOpciones().size();
        }
        return aplicacion;
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

    private void guardarSeleccion(HttpServletRequest request, RespuestaEvaluado respuesta) {
        respuesta.setOpcionA(request.getParameter("A") != null);
        respuesta.setOpcionB(request.getParameter("B") != null);
        respuesta.setOpcionC(request.getParameter("C") != null);
        respuesta.setOpcionD(request.getParameter("D") != null);
        respuesta.setOpcionE(request.getParameter("E") != null);
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
