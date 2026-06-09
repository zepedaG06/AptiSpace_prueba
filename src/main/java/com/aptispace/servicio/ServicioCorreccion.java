package com.aptispace.servicio;

import java.time.LocalDateTime;
import javax.persistence.EntityManager;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.*;

public final class ServicioCorreccion {
    private ServicioCorreccion() { }

    public static ResultadoPrueba corregir(AplicacionPrueba aplicacion) {
        if (aplicacion == null) throw new IllegalArgumentException("La aplicación de prueba es obligatoria.");

        int aciertos = 0;
        int errores = 0;
        int sinResponder = 0;

        for (RespuestaEvaluado respuesta : aplicacion.getRespuestas()) {
            respuesta.corregir();
            if (respuesta.getLetrasMarcadas().isEmpty()) sinResponder++;
            else if (Boolean.TRUE.equals(respuesta.getEsAcierto())) aciertos++;
            else errores += respuesta.calcularErrores();
        }

        int puntuacionS2 = Math.max(0, aciertos - errores);
        ResultadoPrueba resultado = aplicacion.getResultado();
        if (resultado == null) {
            resultado = new ResultadoPrueba();
            resultado.setAplicacion(aplicacion);
            aplicacion.setResultado(resultado);
        }
        resultado.setAciertos(aciertos);
        resultado.setErrores(errores);
        resultado.setSinResponder(sinResponder);
        resultado.setPuntuacionS2(puntuacionS2);
        resultado.setFechaResultado(LocalDateTime.now());
        return resultado;
    }

    public static ResultadoPrueba corregirYGuardar(Long aplicacionId) {
        EntityManager em = XPersistence.getManager();
        AplicacionPrueba aplicacion = em.find(AplicacionPrueba.class, aplicacionId);
        if (aplicacion == null) throw new IllegalArgumentException("No existe la aplicación indicada.");
        aplicacion.getRespuestas().size();
        if (aplicacion.getPrueba() != null) aplicacion.getPrueba().getEjercicios().size();
        ResultadoPrueba resultado = corregir(aplicacion);
        em.persist(resultado);
        em.merge(aplicacion);
        return resultado;
    }
}
