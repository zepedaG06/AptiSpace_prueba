package com.aptispace.modelo;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "evaluado")
@View(members = "datosPersonales [nombres, apellidos, fechaNacimiento, edad, sexo]; datosAcademicos [estudiosRealizados, profesion]; control [fechaRegistro]; aplicaciones")
@Tab(properties = "apellidos, nombres, edad, sexo, estudiosRealizados, profesion, fechaRegistro")
public class Evaluado {
    public enum Sexo { MASCULINO, FEMENINO, OTRO }

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @NotBlank @Size(max = 100)
    @Column(name = "nombres", nullable = false, length = 100)
    private String nombres;

    @Required @NotBlank @Size(max = 100)
    @Column(name = "apellidos", nullable = false, length = 100)
    private String apellidos;

    @Required @NotNull
    @Column(name = "fecha_nacimiento", nullable = false)
    private LocalDate fechaNacimiento;

    @Required @Min(10) @Max(99)
    @Column(name = "edad", nullable = false)
    private Integer edad;

    @Required @Enumerated(EnumType.STRING)
    @Column(name = "sexo", nullable = false, length = 20)
    private Sexo sexo;

    @Size(max = 150)
    @Column(name = "estudios_realizados", length = 150)
    private String estudiosRealizados;

    @Size(max = 120)
    @Column(name = "profesion", length = 120)
    private String profesion;

    @ReadOnly
    @Column(name = "fecha_registro", nullable = false)
    private LocalDate fechaRegistro = LocalDate.now();

    @OneToMany(mappedBy = "evaluado", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AplicacionPrueba> aplicaciones = new ArrayList<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }
    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }
    public LocalDate getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(LocalDate fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }
    public Integer getEdad() { return edad; }
    public void setEdad(Integer edad) { this.edad = edad; }
    public Sexo getSexo() { return sexo; }
    public void setSexo(Sexo sexo) { this.sexo = sexo; }
    public String getEstudiosRealizados() { return estudiosRealizados; }
    public void setEstudiosRealizados(String estudiosRealizados) { this.estudiosRealizados = estudiosRealizados; }
    public String getProfesion() { return profesion; }
    public void setProfesion(String profesion) { this.profesion = profesion; }
    public LocalDate getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(LocalDate fechaRegistro) { this.fechaRegistro = fechaRegistro; }
    public List<AplicacionPrueba> getAplicaciones() { return aplicaciones; }
    public void setAplicaciones(List<AplicacionPrueba> aplicaciones) { this.aplicaciones = aplicaciones; }
    public String toString() { return apellidos + ", " + nombres; }
}
