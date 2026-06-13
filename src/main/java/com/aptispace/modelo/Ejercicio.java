package com.aptispace.modelo;

import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.*;
import org.openxava.annotations.*;

@Entity
@Table(name = "ejercicio", uniqueConstraints = @UniqueConstraint(columnNames = {"prueba_id", "numero"}))
@View(members = "datos [prueba, numero, imagenModelo, enunciado]; opciones")
@Tab(properties = "prueba.nombre, numero, enunciado")
public class Ejercicio {
    public enum TipoRespuesta { UNICA, MULTIPLE }

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) @Hidden
    private Long id;

    @Required @ManyToOne(optional = false)
    @JoinColumn(name = "prueba_id", nullable = false)
    private Prueba prueba;

    @Required @Min(1) @Max(200)
    @Column(name = "numero", nullable = false)
    private Integer numero;

    @Stereotype("PHOTO")
    @Column(name = "imagen_modelo", length = 255)
    private String imagenModelo;

    @Stereotype("MEMO") @Size(max = 300)
    @Column(name = "enunciado", length = 300)
    private String enunciado;

    @Required @Enumerated(EnumType.STRING)
    @Column(name = "tipo_respuesta", nullable = false, length = 20)
    private TipoRespuesta tipoRespuesta = TipoRespuesta.UNICA;

    @OneToMany(mappedBy = "ejercicio", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @OrderBy("letra ASC")
    private List<OpcionEjercicio> opciones = new ArrayList<>();

    public Set<String> getLetrasCorrectas() {
        Set<String> letras = new LinkedHashSet<>();
        for (OpcionEjercicio opcion : opciones) if (Boolean.TRUE.equals(opcion.getEsCorrecta())) letras.add(opcion.getLetra().name());
        return letras;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Prueba getPrueba() { return prueba; }
    public void setPrueba(Prueba prueba) { this.prueba = prueba; }
    public Integer getNumero() { return numero; }
    public void setNumero(Integer numero) { this.numero = numero; }
    public String getImagenModelo() { return imagenModelo; }
    public void setImagenModelo(String imagenModelo) { this.imagenModelo = imagenModelo; }
    public String getEnunciado() { return enunciado; }
    public void setEnunciado(String enunciado) { this.enunciado = enunciado; }
    public TipoRespuesta getTipoRespuesta() { return tipoRespuesta; }
    public void setTipoRespuesta(TipoRespuesta tipoRespuesta) { this.tipoRespuesta = tipoRespuesta; }
    public List<OpcionEjercicio> getOpciones() { return opciones; }
    public void setOpciones(List<OpcionEjercicio> opciones) { this.opciones = opciones; }
    public String toString() { return "Ejercicio " + numero; }
}
