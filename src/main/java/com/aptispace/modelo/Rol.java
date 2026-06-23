package com.aptispace.modelo;

import java.util.LinkedHashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "rol", uniqueConstraints = @UniqueConstraint(columnNames = "nombre_rol"))
@Tab(properties = "nombreRol, descripcion", baseCondition = "${nombreRol} <> 'PSICOLOGO'")
public class Rol {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @NotBlank @Size(max = 40)
    @Column(name = "nombre_rol", nullable = false, length = 40)
    private String nombreRol;

    @Stereotype("MEMO") @Size(max = 250)
    @Column(name = "descripcion", length = 250)
    private String descripcion;

    @ManyToMany(mappedBy = "roles")
    private Set<Usuario> usuarios = new LinkedHashSet<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombreRol() { return nombreRol; }
    public void setNombreRol(String nombreRol) { this.nombreRol = nombreRol; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public Set<Usuario> getUsuarios() { return usuarios; }
    public void setUsuarios(Set<Usuario> usuarios) { this.usuarios = usuarios; }
    public String toString() { return nombreRol; }
}
