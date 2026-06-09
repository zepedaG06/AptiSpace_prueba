package com.aptispace.modelo;

import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "respuesta_evaluado", uniqueConstraints = @UniqueConstraint(columnNames = {"aplicacion_id", "ejercicio_id"}))
@View(members = "aplicacion, ejercicio; seleccion [opcionA, opcionB, opcionC, opcionD, opcionE]; correccion [esAcierto, esError, fechaRespuesta]")
@Tab(properties = "aplicacion.id, ejercicio.numero, opcionA, opcionB, opcionC, opcionD, opcionE, esAcierto, esError")
public class RespuestaEvaluado {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @ManyToOne(optional = false)
    @JoinColumn(name = "aplicacion_id", nullable = false)
    private AplicacionPrueba aplicacion;

    @Required @ManyToOne(optional = false, fetch = FetchType.EAGER)
    @JoinColumn(name = "ejercicio_id", nullable = false)
    private Ejercicio ejercicio;

    @Column(name = "opcion_a", nullable = false) private boolean opcionA;
    @Column(name = "opcion_b", nullable = false) private boolean opcionB;
    @Column(name = "opcion_c", nullable = false) private boolean opcionC;
    @Column(name = "opcion_d", nullable = false) private boolean opcionD;
    @Column(name = "opcion_e", nullable = false) private boolean opcionE;

    @ReadOnly @Column(name = "es_acierto") private Boolean esAcierto = Boolean.FALSE;
    @ReadOnly @Column(name = "es_error") private Boolean esError = Boolean.FALSE;
    @ReadOnly @Column(name = "fecha_respuesta") private LocalDateTime fechaRespuesta = LocalDateTime.now();

    public Set<String> getLetrasMarcadas() {
        Set<String> letras = new LinkedHashSet<>();
        if (opcionA) letras.add("A"); if (opcionB) letras.add("B"); if (opcionC) letras.add("C"); if (opcionD) letras.add("D"); if (opcionE) letras.add("E");
        return letras;
    }

    public int calcularErrores() {
        Set<String> correctas = ejercicio != null ? ejercicio.getLetrasCorrectas() : new LinkedHashSet<>();
        int errores = 0;
        for (String marcada : getLetrasMarcadas()) if (!correctas.contains(marcada)) errores++;
        return errores;
    }

    public void corregir() {
        Set<String> marcadas = getLetrasMarcadas();
        Set<String> correctas = ejercicio != null ? ejercicio.getLetrasCorrectas() : new LinkedHashSet<>();
        esAcierto = !marcadas.isEmpty() && marcadas.equals(correctas);
        esError = !marcadas.isEmpty() && !Boolean.TRUE.equals(esAcierto);
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public AplicacionPrueba getAplicacion() { return aplicacion; }
    public void setAplicacion(AplicacionPrueba aplicacion) { this.aplicacion = aplicacion; }
    public Ejercicio getEjercicio() { return ejercicio; }
    public void setEjercicio(Ejercicio ejercicio) { this.ejercicio = ejercicio; }
    public boolean isOpcionA() { return opcionA; }
    public void setOpcionA(boolean opcionA) { this.opcionA = opcionA; }
    public boolean isOpcionB() { return opcionB; }
    public void setOpcionB(boolean opcionB) { this.opcionB = opcionB; }
    public boolean isOpcionC() { return opcionC; }
    public void setOpcionC(boolean opcionC) { this.opcionC = opcionC; }
    public boolean isOpcionD() { return opcionD; }
    public void setOpcionD(boolean opcionD) { this.opcionD = opcionD; }
    public boolean isOpcionE() { return opcionE; }
    public void setOpcionE(boolean opcionE) { this.opcionE = opcionE; }
    public Boolean getEsAcierto() { return esAcierto; }
    public void setEsAcierto(Boolean esAcierto) { this.esAcierto = esAcierto; }
    public Boolean getEsError() { return esError; }
    public void setEsError(Boolean esError) { this.esError = esError; }
    public LocalDateTime getFechaRespuesta() { return fechaRespuesta; }
    public void setFechaRespuesta(LocalDateTime fechaRespuesta) { this.fechaRespuesta = fechaRespuesta; }
    public String toString() { return "Respuesta " + (ejercicio != null ? ejercicio.getNumero() : ""); }
}
