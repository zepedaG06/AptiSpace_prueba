package com.aptispace.acciones;

import org.openxava.actions.ViewBaseAction;
import com.aptispace.modelo.ResultadoPrueba;
import com.aptispace.servicio.ServicioCorreccion;

public class CalcularResultadoAction extends ViewBaseAction {
    public void execute() throws Exception {
        Long id = Long.valueOf(getView().getValue("id").toString());
        ResultadoPrueba resultado = ServicioCorreccion.corregirYGuardar(id);
        addMessage("Corrección automática calculada. S2 = " + resultado.getPuntuacionS2());
        getView().refresh();
    }
}
