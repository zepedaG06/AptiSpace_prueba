package com.aptispace.modelo;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "aplicacion_prueba", indexes = {
    @Index(name = "idx_aplicacion_evaluado", columnList = "evaluado_id"),
    @Index(name = "idx_aplicacion_prueba", columnList = "prueba_id")
})
@View(members = "asignacion [evaluado, prueba, psicologo, autorizadaReaplicacion]; tiempo [fechaInicio, fechaFin, tiempoUtilizado, estado]; respuestas; resultado; observaciones")
@Tab(properties = "evaluado.apellidos, evaluado.nombres, prueba.nombre, fechaInicio, fechaFin, estado, tiempoUtilizado")
public class AplicacionPrueba {
    public enum EstadoAplicacion { ASIGNADA, EN_PROCESO, FINALIZADA, CANCELADA }

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @ManyToOne(optional = false)
    @JoinColumn(name = "evaluado_id", nullable = false)
    private Evaluado evaluado;

    @Required @ManyToOne(optional = false)
    @JoinColumn(name = "prueba_id", nullable = false)
    private Prueba prueba;

    @ManyToOne
    @JoinColumn(name = "psicologo_id")
    private Usuario psicologo;

    @Column(name = "fecha_inicio")
    private LocalDateTime fechaInicio;

    @Column(name = "fecha_fin")
    private LocalDateTime fechaFin;

    @ReadOnly
    @Column(name = "tiempo_utilizado")
    private Integer tiempoUtilizado = 0;

    @Required @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private EstadoAplicacion estado = EstadoAplicacion.ASIGNADA;

    @Column(name = "autorizada_reaplicacion", nullable = false)
    private Boolean autorizadaReaplicacion = Boolean.FALSE;

    @OneToMany(mappedBy = "aplicacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RespuestaEvaluado> respuestas = new ArrayList<>();

    @OneToOne(mappedBy = "aplicacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private ResultadoPrueba resultado;

    @OneToMany(mappedBy = "aplicacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ObservacionPsicologica> observaciones = new ArrayList<>();

    public void iniciar() {
        if (fechaInicio == null) fechaInicio = LocalDateTime.now();
        estado = EstadoAplicacion.EN_PROCESO;
    }

    public void finalizar() {
        if (fechaFin == null) fechaFin = LocalDateTime.now();
        if (fechaInicio != null) tiempoUtilizado = (int) Duration.between(fechaInicio, fechaFin).getSeconds();
        estado = EstadoAplicacion.FINALIZADA;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Evaluado getEvaluado() { return evaluado; }
    public void setEvaluado(Evaluado evaluado) { this.evaluado = evaluado; }
    public Prueba getPrueba() { return prueba; }
    public void setPrueba(Prueba prueba) { this.prueba = prueba; }
    public Usuario getPsicologo() { return psicologo; }
    public void setPsicologo(Usuario psicologo) { this.psicologo = psicologo; }
    public LocalDateTime getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDateTime fechaInicio) { this.fechaInicio = fechaInicio; }
    public LocalDateTime getFechaFin() { return fechaFin; }
    public void setFechaFin(LocalDateTime fechaFin) { this.fechaFin = fechaFin; }
    public Integer getTiempoUtilizado() { return tiempoUtilizado; }
    public void setTiempoUtilizado(Integer tiempoUtilizado) { this.tiempoUtilizado = tiempoUtilizado; }
    public EstadoAplicacion getEstado() { return estado; }
    public void setEstado(EstadoAplicacion estado) { this.estado = estado; }
    public Boolean getAutorizadaReaplicacion() { return autorizadaReaplicacion; }
    public void setAutorizadaReaplicacion(Boolean autorizadaReaplicacion) { this.autorizadaReaplicacion = autorizadaReaplicacion; }
    public List<RespuestaEvaluado> getRespuestas() { return respuestas; }
    public void setRespuestas(List<RespuestaEvaluado> respuestas) { this.respuestas = respuestas; }
    public ResultadoPrueba getResultado() { return resultado; }
    public void setResultado(ResultadoPrueba resultado) { this.resultado = resultado; }
    public List<ObservacionPsicologica> getObservaciones() { return observaciones; }
    public void setObservaciones(List<ObservacionPsicologica> observaciones) { this.observaciones = observaciones; }
    public String toString() { return "Aplicación #" + id; }
}
