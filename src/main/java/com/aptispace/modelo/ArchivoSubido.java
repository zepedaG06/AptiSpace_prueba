package com.aptispace.modelo;

import java.time.LocalDateTime;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "archivo_subido")
@Tab(properties = "nombreOriginal, contentType, tamano, fechaSubida")
public class ArchivoSubido {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @Size(max = 180)
    @Column(name = "nombre_original", nullable = false, length = 180)
    private String nombreOriginal;

    @Required @Size(max = 80)
    @Column(name = "content_type", nullable = false, length = 80)
    private String contentType;

    @Column(name = "tamanio", nullable = false)
    private Long tamano = 0L;

    @Lob
    @Basic(fetch = FetchType.LAZY)
    @Column(name = "datos", nullable = false)
    private byte[] datos;

    @ReadOnly
    @Column(name = "fecha_subida", nullable = false)
    private LocalDateTime fechaSubida = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombreOriginal() { return nombreOriginal; }
    public void setNombreOriginal(String nombreOriginal) { this.nombreOriginal = nombreOriginal; }
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    public Long getTamano() { return tamano; }
    public void setTamano(Long tamano) { this.tamano = tamano; }
    public byte[] getDatos() { return datos; }
    public void setDatos(byte[] datos) { this.datos = datos; }
    public LocalDateTime getFechaSubida() { return fechaSubida; }
    public void setFechaSubida(LocalDateTime fechaSubida) { this.fechaSubida = fechaSubida; }
    public String toString() { return nombreOriginal; }
}
