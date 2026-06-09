package com.aptispace.modelo;

import java.util.LinkedHashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "plantilla_correccion")
@View(members = "datos [descripcion, activa]; ejercicios")
@Tab(properties = "descripcion, activa")
public class PlantillaCorreccion {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @Stereotype("MEMO") @Size(max = 300)
    @Column(name = "descripcion", nullable = false, length = 300)
    private String descripcion;

    @Column(name = "activa", nullable = false)
    private Boolean activa = Boolean.TRUE;

    @ManyToMany
    @JoinTable(name = "plantilla_ejercicio", joinColumns = @JoinColumn(name = "plantilla_id"), inverseJoinColumns = @JoinColumn(name = "ejercicio_id"))
    private Set<Ejercicio> ejercicios = new LinkedHashSet<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public Boolean getActiva() { return activa; }
    public void setActiva(Boolean activa) { this.activa = activa; }
    public Set<Ejercicio> getEjercicios() { return ejercicios; }
    public void setEjercicios(Set<Ejercicio> ejercicios) { this.ejercicios = ejercicios; }
    public String toString() { return descripcion; }
}
