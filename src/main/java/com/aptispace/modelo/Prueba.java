package com.aptispace.modelo;

import java.util.ArrayList;
import java.util.List;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "prueba")
@View(members = "datos [nombre, descripcion, tiempoLimite, cantidadEjercicios, estado]; ejercicios")
@Tab(properties = "nombre, tiempoLimite, cantidadEjercicios, estado")
public class Prueba {
    public enum EstadoPrueba { ACTIVA, INACTIVA, ARCHIVADA }

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @NotBlank @Size(max = 120)
    @Column(name = "nombre", nullable = false, length = 120)
    private String nombre;

    @Stereotype("MEMO") @Size(max = 500)
    @Column(name = "descripcion", length = 500)
    private String descripcion;

    @Required @Min(1) @Max(180)
    @Column(name = "tiempo_limite", nullable = false)
    private Integer tiempoLimite = 30;

    @Required @Min(1) @Max(200)
    @Column(name = "cantidad_ejercicios", nullable = false)
    private Integer cantidadEjercicios = 8;

    @Required @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private EstadoPrueba estado = EstadoPrueba.ACTIVA;

    @OneToMany(mappedBy = "prueba", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("numero ASC")
    private List<Ejercicio> ejercicios = new ArrayList<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public Integer getTiempoLimite() { return tiempoLimite; }
    public void setTiempoLimite(Integer tiempoLimite) { this.tiempoLimite = tiempoLimite; }
    public Integer getCantidadEjercicios() { return cantidadEjercicios; }
    public void setCantidadEjercicios(Integer cantidadEjercicios) { this.cantidadEjercicios = cantidadEjercicios; }
    public EstadoPrueba getEstado() { return estado; }
    public void setEstado(EstadoPrueba estado) { this.estado = estado; }
    public List<Ejercicio> getEjercicios() { return ejercicios; }
    public void setEjercicios(List<Ejercicio> ejercicios) { this.ejercicios = ejercicios; }
    public String toString() { return nombre; }
}
