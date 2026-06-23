package com.aptispace.modelo;

import java.time.LocalDateTime;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "bitacora")
@View(members = "fecha, usuario, rol, accion; detalle")
@Tab(properties = "fecha, usuario, rol, accion")
public class Bitacora {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @ReadOnly
    @Column(name = "fecha", nullable = false)
    private LocalDateTime fecha = LocalDateTime.now();

    @Size(max = 80)
    @Column(name = "usuario", length = 80)
    private String usuario;

    @Size(max = 40)
    @Column(name = "rol", length = 40)
    private String rol;

    @Required @NotBlank @Size(max = 80)
    @Column(name = "accion", nullable = false, length = 80)
    private String accion;

    @Stereotype("MEMO") @Size(max = 500)
    @Column(name = "detalle", length = 500)
    private String detalle;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }
    public String getUsuario() { return usuario; }
    public void setUsuario(String usuario) { this.usuario = usuario; }
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }
    public String getAccion() { return accion; }
    public void setAccion(String accion) { this.accion = accion; }
    public String getDetalle() { return detalle; }
    public void setDetalle(String detalle) { this.detalle = detalle; }
}
