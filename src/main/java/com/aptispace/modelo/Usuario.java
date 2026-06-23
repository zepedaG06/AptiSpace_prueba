package com.aptispace.modelo;

import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "usuario", uniqueConstraints = @UniqueConstraint(columnNames = "nombre_usuario"))
@View(members = "datos [nombreUsuario, contrasena, estado, fechaCreacion, rol]; persona [nombres, apellidos, correo]")
@Tab(properties = "nombreUsuario, nombres, apellidos, correo, rolPrincipal, estado, fechaCreacion")
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

    @Size(max = 120)
    @Column(name = "correo", length = 120)
    private String correo;

    @Stereotype("PHOTO")
    @Column(name = "foto_perfil", length = 255)
    private String fotoPerfil;

    @Required @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private EstadoUsuario estado = EstadoUsuario.ACTIVO;

    @ReadOnly
    @Column(name = "fecha_creacion", nullable = false)
    private LocalDateTime fechaCreacion = LocalDateTime.now();

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "usuario_rol", joinColumns = @JoinColumn(name = "usuario_id"), inverseJoinColumns = @JoinColumn(name = "rol_id"))
    private Set<Rol> roles = new LinkedHashSet<>();

    @OneToOne(mappedBy = "usuario", fetch = FetchType.LAZY)
    private Evaluado evaluado;

    @ManyToOne
    @JoinColumn(name = "rol_id")
    @DescriptionsList(descriptionProperties = "nombreRol", condition = "${nombreRol} <> 'PSICOLOGO'")
    private Rol rol;

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
    public String getFotoPerfil() { return fotoPerfil; }
    public void setFotoPerfil(String fotoPerfil) { this.fotoPerfil = fotoPerfil; }
    public EstadoUsuario getEstado() { return estado; }
    public void setEstado(EstadoUsuario estado) { this.estado = estado; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public Set<Rol> getRoles() { return roles; }
    public void setRoles(Set<Rol> roles) { this.roles = roles; }
    public Evaluado getEvaluado() { return evaluado; }
    public void setEvaluado(Evaluado evaluado) { this.evaluado = evaluado; }
    public Rol getRol() { return rolPrincipalEntidad(); }
    public void setRol(Rol rol) {
        this.rol = rol;
        sincronizarRolesConRol();
    }
    @ReadOnly
    public String getRolPrincipal() {
        Rol principal = rolPrincipalEntidad();
        if (principal == null) return "";
        return "PSICOLOGO".equals(principal.getNombreRol()) ? "EVALUADOR" : principal.getNombreRol();
    }
    private Rol rolPrincipalEntidad() {
        if (rol != null) return rol;
        Rol psicologo = null;
        for (Rol candidato : roles) {
            if ("PSICOLOGO".equals(candidato.getNombreRol())) {
                psicologo = candidato;
                continue;
            }
            return candidato;
        }
        return psicologo;
    }

    @PostLoad
    private void cargarRolPrincipal() {
        if (rol == null) rol = rolPrincipalEntidad();
    }

    @PrePersist
    @PreUpdate
    private void sincronizarRolesConRol() {
        Rol seleccionado = rolPrincipalEntidad();
        roles.clear();
        if (seleccionado != null) roles.add(seleccionado);
    }
    public String toString() { return nombreUsuario; }
}
