package com.aptispace.modelo;

import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "configuracion_basica", uniqueConstraints = @UniqueConstraint(columnNames = "clave"))
@View(members = "clave, valor; descripcion")
@Tab(properties = "clave, valor")
public class ConfiguracionBasica {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @NotBlank @Size(max = 80)
    @Column(name = "clave", nullable = false, length = 80)
    private String clave;

    @Required @NotBlank @Size(max = 250)
    @Column(name = "valor", nullable = false, length = 250)
    private String valor;

    @Stereotype("MEMO") @Size(max = 500)
    @Column(name = "descripcion", length = 500)
    private String descripcion;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getClave() { return clave; }
    public void setClave(String clave) { this.clave = clave; }
    public String getValor() { return valor; }
    public void setValor(String valor) { this.valor = valor; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public String toString() { return clave; }
}
