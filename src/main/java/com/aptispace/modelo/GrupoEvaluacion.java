package com.aptispace.modelo;

import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "grupo_evaluacion", uniqueConstraints = @UniqueConstraint(columnNames = "codigo"))
@View(members = "datos [nombre, codigo, psicologo, fechaCreacion, activo]; evaluados")
@Tab(properties = "nombre, codigo, psicologo.nombreUsuario, activo, fechaCreacion")
public class GrupoEvaluacion {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @NotBlank @Size(max = 100)
    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    @Required @NotBlank @Size(max = 20)
    @Column(name = "codigo", nullable = false, length = 20)
    private String codigo;

    @ManyToOne
    @JoinColumn(name = "psicologo_id")
    private Usuario psicologo;

    @ReadOnly
    @Column(name = "fecha_creacion", nullable = false)
    private LocalDate fechaCreacion = LocalDate.now();

    @Column(name = "activo", nullable = false)
    private Boolean activo = Boolean.TRUE;

    @ManyToMany
    @JoinTable(
        name = "grupo_evaluado",
        joinColumns = @JoinColumn(name = "grupo_id"),
        inverseJoinColumns = @JoinColumn(name = "evaluado_id")
    )
    private Set<Evaluado> evaluados = new LinkedHashSet<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo == null ? null : codigo.trim().toUpperCase(); }
    public Usuario getPsicologo() { return psicologo; }
    public void setPsicologo(Usuario psicologo) { this.psicologo = psicologo; }
    public LocalDate getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDate fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public Boolean getActivo() { return activo; }
    public void setActivo(Boolean activo) { this.activo = activo; }
    public Set<Evaluado> getEvaluados() { return evaluados; }
    public void setEvaluados(Set<Evaluado> evaluados) { this.evaluados = evaluados; }
    public String toString() { return nombre + " (" + codigo + ")"; }
}
