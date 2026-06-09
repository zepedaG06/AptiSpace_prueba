package com.aptispace.modelo;

import java.time.LocalDateTime;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "resultado_prueba")
@View(members = "aplicacion; conteo [aciertos, errores, sinResponder, puntuacionS2]; fechaResultado")
@Tab(properties = "aplicacion.evaluado.apellidos, aplicacion.evaluado.nombres, aciertos, errores, sinResponder, puntuacionS2, fechaResultado")
public class ResultadoPrueba {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @OneToOne(optional = false)
    @JoinColumn(name = "aplicacion_id", nullable = false, unique = true)
    private AplicacionPrueba aplicacion;

    @ReadOnly @Min(0) @Column(name = "aciertos", nullable = false)
    private Integer aciertos = 0;

    @ReadOnly @Min(0) @Column(name = "errores", nullable = false)
    private Integer errores = 0;

    @ReadOnly @Min(0) @Column(name = "sin_responder", nullable = false)
    private Integer sinResponder = 0;

    @ReadOnly @Min(0) @Column(name = "puntuacion_s2", nullable = false)
    private Integer puntuacionS2 = 0;

    @ReadOnly @Column(name = "fecha_resultado", nullable = false)
    private LocalDateTime fechaResultado = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public AplicacionPrueba getAplicacion() { return aplicacion; }
    public void setAplicacion(AplicacionPrueba aplicacion) { this.aplicacion = aplicacion; }
    public Integer getAciertos() { return aciertos; }
    public void setAciertos(Integer aciertos) { this.aciertos = aciertos; }
    public Integer getErrores() { return errores; }
    public void setErrores(Integer errores) { this.errores = errores; }
    public Integer getSinResponder() { return sinResponder; }
    public void setSinResponder(Integer sinResponder) { this.sinResponder = sinResponder; }
    public Integer getPuntuacionS2() { return puntuacionS2; }
    public void setPuntuacionS2(Integer puntuacionS2) { this.puntuacionS2 = puntuacionS2; }
    public LocalDateTime getFechaResultado() { return fechaResultado; }
    public void setFechaResultado(LocalDateTime fechaResultado) { this.fechaResultado = fechaResultado; }
    public String toString() { return "S2=" + puntuacionS2; }
}
