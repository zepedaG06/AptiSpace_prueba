package com.aptispace.acciones;

import javax.persistence.EntityManager;
import org.openxava.actions.ViewBaseAction;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.AplicacionPrueba;

public class FinalizarPruebaAction extends ViewBaseAction {
    public void execute() throws Exception {
        Long id = Long.valueOf(getView().getValue("id").toString());
        EntityManager em = XPersistence.getManager();
        AplicacionPrueba aplicacion = em.find(AplicacionPrueba.class, id);
        aplicacion.finalizar();
        em.merge(aplicacion);
        addMessage("Prueba finalizada. El tiempo utilizado fue calculado automáticamente.");
        getView().refresh();
    }
}
