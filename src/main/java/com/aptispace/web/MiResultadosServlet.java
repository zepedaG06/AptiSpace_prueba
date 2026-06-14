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
import com.aptispace.modelo.RespuestaEvaluado;

public class MiResultadosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        EntityManager em = XPersistence.getManager();
        List<AplicacionPrueba> historial = obtenerHistorial(em, request);
        AplicacionPrueba seleccionada = seleccionar(historial, request.getParameter("aplicacionId"));
        if (seleccionada != null) {
            seleccionada.getRespuestas().size();
            for (RespuestaEvaluado respuesta : seleccionada.getRespuestas()) {
                respuesta.getEjercicio().getOpciones().size();
            }
        }
        request.setAttribute("historial", historial);
        request.setAttribute("seleccionada", seleccionada);
        request.getRequestDispatcher("/WEB-INF/jsp/mi-resultados.jsp").forward(request, response);
    }

    private List<AplicacionPrueba> obtenerHistorial(EntityManager em, HttpServletRequest request) {
        String usuario = (String) request.getSession(true).getAttribute("aptispace.usuario.EVALUADO");
        TypedQuery<AplicacionPrueba> query = em.createQuery(
            "select distinct a from AplicacionPrueba a "
                + "left join fetch a.resultado "
                + "left join fetch a.respuestas r "
                + "left join fetch r.ejercicio e "
                + "where a.evaluado.usuario.nombreUsuario = :usuario "
                + "and a.resultado is not null "
                + "order by a.id desc",
            AplicacionPrueba.class);
        query.setParameter("usuario", usuario);
        return query.getResultList();
    }

    private AplicacionPrueba seleccionar(List<AplicacionPrueba> historial, String id) {
        if (historial.isEmpty()) return null;
        if (id != null && !id.isBlank()) {
            try {
                Long buscado = Long.valueOf(id);
                for (AplicacionPrueba aplicacion : historial) {
                    if (buscado.equals(aplicacion.getId())) return aplicacion;
                }
            }
            catch (NumberFormatException ex) {
                return historial.get(0);
            }
        }
        return historial.get(0);
    }
}
