package com.aptispace.web;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import javax.persistence.EntityManager;
import javax.servlet.ServletException;
import javax.servlet.http.Part;
import com.aptispace.modelo.ArchivoSubido;

public final class UploadStorage {
    private UploadStorage() { }

    public static String guardarImagen(EntityManager em, Part part, boolean permiteSvg, String mensajeError) throws IOException, ServletException {
        if (part == null || part.getSize() == 0) return null;

        String contentType = part.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException(mensajeError);
        }

        String nombreArchivo = nombreSeguro(part.getSubmittedFileName(), permiteSvg);
        ArchivoSubido archivo = new ArchivoSubido();
        archivo.setNombreOriginal(nombreArchivo);
        archivo.setContentType(contentType);
        archivo.setTamaño(part.getSize());
        archivo.setDatos(part.getInputStream().readAllBytes());
        em.persist(archivo);
        em.flush();
        return "uploads/db/" + archivo.getId() + "/" + nombreArchivo;
    }

    public static Long idDesdeRuta(String ruta) {
        String limpia = ruta == null ? "" : ruta.replace('\\', '/');
        while (limpia.startsWith("/")) limpia = limpia.substring(1);
        if (limpia.startsWith("uploads/")) limpia = limpia.substring("uploads/".length());
        if (!limpia.startsWith("db/")) return null;
        String resto = limpia.substring("db/".length());
        int slash = resto.indexOf('/');
        String id = slash >= 0 ? resto.substring(0, slash) : resto;
        try { return Long.valueOf(id); }
        catch (NumberFormatException ex) { return null; }
    }

    public static Path resolver(String rutaRelativa) {
        String limpia = rutaRelativa == null ? "" : rutaRelativa.replace('\\', '/');
        while (limpia.startsWith("/")) limpia = limpia.substring(1);
        if (limpia.startsWith("uploads/")) limpia = limpia.substring("uploads/".length());
        Path destino = base().resolve(limpia).normalize();
        if (!destino.startsWith(base())) return null;
        return destino;
    }

    public static Path base() {
        String configurada = System.getProperty("aptispace.uploads.dir");
        if (configurada != null && !configurada.isBlank()) return Path.of(configurada).toAbsolutePath().normalize();
        return Path.of(System.getProperty("user.home"), "AptiSpace", "uploads").toAbsolutePath().normalize();
    }

    private static String nombreSeguro(String nombre, boolean permiteSvg) {
        String base = nombre == null || nombre.isBlank() ? "imagen.png" : Path.of(nombre).getFileName().toString();
        base = base.replaceAll("[^A-Za-z0-9._-]", "_");
        int punto = base.lastIndexOf('.');
        String extension = punto < 0 ? ".png" : base.substring(punto).toLowerCase();
        String permitidas = permiteSvg ? "\\.(png|jpg|jpeg|gif|svg|webp)" : "\\.(png|jpg|jpeg|gif|webp)";
        if (!extension.matches(permitidas)) base = (punto < 0 ? base : base.substring(0, punto)) + ".png";
        return base;
    }
}
