package com.aptispace.acciones;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.persistence.EntityManager;
import org.openxava.actions.ViewBaseAction;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.AplicacionPrueba;
import com.aptispace.modelo.Ejercicio;
import com.aptispace.modelo.RespuestaEvaluado;

public class IniciarPruebaAction extends ViewBaseAction {
    public void execute() throws Exception {
        Long id = Long.valueOf(getView().getValue("id").toString());
        EntityManager em = XPersistence.getManager();
        AplicacionPrueba aplicacion = em.find(AplicacionPrueba.class, id);
        asignarEjerciciosAleatorios(aplicacion);
        aplicacion.iniciar();
        em.merge(aplicacion);
        addMessage("Prueba iniciada. Se asignaron ejercicios aleatorios y el cronometro queda registrado.");
        getView().refresh();
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
}
