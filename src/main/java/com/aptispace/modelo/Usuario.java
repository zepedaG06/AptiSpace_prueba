package com.aptispace.modelo;

import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "usuario", uniqueConstraints = @UniqueConstraint(columnNames = "nombre_usuario"))
@View(members = "datos [nombreUsuario, contrasena, estado, fechaCreacion]; persona [nombres, apellidos, correo]; roles")
@Tab(properties = "nombreUsuario, nombres, apellidos, correo, estado, fechaCreacion")
public class Usuario {
    public enum EstadoUsuario { ACTIVO, INACTIVO, BLOQUEADO }

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @NotBlank @Size(max = 50)
    @Column(name = "nombre_usuario", nullable = false, length = 50)
    private String nombreUsuario;

    @Required @Stereotype("PASSWORD") @Size(min = 6, max = 120)
    @Column(name = "contrasena", nullable = false, length = 120)
    private String contrasena;

    @Required @NotBlank @Size(max = 80)
    @Column(name = "nombres", nullable = false, length = 80)
    private String nombres;

    @Required @NotBlank @Size(max = 80)
    @Column(name = "apellidos", nullable = false, length = 80)
    private String apellidos;

    @Email @Size(max = 120)
    @Column(name = "correo", length = 120)
    private String correo;

    @Required @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private EstadoUsuario estado = EstadoUsuario.ACTIVO;

    @ReadOnly
    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion = LocalDateTime.now();

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "usuario_rol", joinColumns = @JoinColumn(name = "usuario_id"), inverseJoinColumns = @JoinColumn(name = "rol_id"))
    private Set<Rol> roles = new LinkedHashSet<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }
    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }
    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }
    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    public EstadoUsuario getEstado() { return estado; }
    public void setEstado(EstadoUsuario estado) { this.estado = estado; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public Set<Rol> getRoles() { return roles; }
    public void setRoles(Set<Rol> roles) { this.roles = roles; }
    public String toString() { return nombreUsuario; }
}
