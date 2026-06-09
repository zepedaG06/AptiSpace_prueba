package com.aptispace.modelo;

import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "opcion_ejercicio", uniqueConstraints = @UniqueConstraint(columnNames = {"ejercicio_id", "letra"}))
@Tab(properties = "ejercicio.numero, letra, esCorrecta")
public class OpcionEjercicio {
    public enum LetraOpcion { A, B, C, D, E }

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @ManyToOne(optional = false)
    @JoinColumn(name = "ejercicio_id", nullable = false)
    private Ejercicio ejercicio;

    @Required @Enumerated(EnumType.STRING)
    @Column(name = "letra", nullable = false, length = 1)
    private LetraOpcion letra;

    @Stereotype("PHOTO")
    @Column(name = "imagen_opcion", length = 255)
    private String imagenOpcion;

    @Column(name = "es_correcta", nullable = false)
    private Boolean esCorrecta = Boolean.FALSE;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Ejercicio getEjercicio() { return ejercicio; }
    public void setEjercicio(Ejercicio ejercicio) { this.ejercicio = ejercicio; }
    public LetraOpcion getLetra() { return letra; }
    public void setLetra(LetraOpcion letra) { this.letra = letra; }
    public String getImagenOpcion() { return imagenOpcion; }
    public void setImagenOpcion(String imagenOpcion) { this.imagenOpcion = imagenOpcion; }
    public Boolean getEsCorrecta() { return esCorrecta; }
    public void setEsCorrecta(Boolean esCorrecta) { this.esCorrecta = esCorrecta; }
    public String toString() { return letra != null ? letra.name() : "Opción"; }
}
