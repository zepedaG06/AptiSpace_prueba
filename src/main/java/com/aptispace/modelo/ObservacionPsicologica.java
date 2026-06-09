package com.aptispace.modelo;

import java.time.LocalDateTime;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "observacion_psicologica")
@View(members = "aplicacion, psicologo; comentario; fechaObservacion")
@Tab(properties = "aplicacion.evaluado.apellidos, aplicacion.evaluado.nombres, psicologo.nombreUsuario, fechaObservacion")
public class ObservacionPsicologica {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @ManyToOne(optional = false)
    @JoinColumn(name = "aplicacion_id", nullable = false)
    private AplicacionPrueba aplicacion;

    @ManyToOne
    @JoinColumn(name = "psicologo_id")
    private Usuario psicologo;

    @Required @Stereotype("MEMO") @Size(max = 2000)
    @Column(name = "comentario", nullable = false, length = 2000)
    private String comentario;

    @ReadOnly @Column(name = "fecha_observacion", nullable = false)
    private LocalDateTime fechaObservacion = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public AplicacionPrueba getAplicacion() { return aplicacion; }
    public void setAplicacion(AplicacionPrueba aplicacion) { this.aplicacion = aplicacion; }
    public Usuario getPsicologo() { return psicologo; }
    public void setPsicologo(Usuario psicologo) { this.psicologo = psicologo; }
    public String getComentario() { return comentario; }
    public void setComentario(String comentario) { this.comentario = comentario; }
    public LocalDateTime getFechaObservacion() { return fechaObservacion; }
    public void setFechaObservacion(LocalDateTime fechaObservacion) { this.fechaObservacion = fechaObservacion; }
    public String toString() { return "Observación " + fechaObservacion; }
}
