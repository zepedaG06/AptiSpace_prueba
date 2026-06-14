package com.aptispace.web;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import javax.persistence.EntityManager;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.ArchivoSubido;

public class UploadsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        Long idArchivo = UploadStorage.idDesdeRuta(pathInfo);
        if (idArchivo != null && servirDesdeBaseDatos(idArchivo, response)) return;

        Path archivo = UploadStorage.resolver(pathInfo);
        if (archivo == null || !Files.isRegularFile(archivo)) {
            archivo = respaldoDesplegado(request, pathInfo);
        }
        if (archivo == null || !Files.isRegularFile(archivo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(archivo.getFileName().toString());
        response.setContentType(contentType == null ? "application/octet-stream" : contentType);
        response.setHeader("Cache-Control", "public, max-age=86400");
        try (ServletOutputStream out = response.getOutputStream()) {
            Files.copy(archivo, out);
        }
    }

    private boolean servirDesdeBaseDatos(Long idArchivo, HttpServletResponse response) throws IOException {
        EntityManager em = XPersistence.getManager();
        ArchivoSubido archivo = em.find(ArchivoSubido.class, idArchivo);
        if (archivo == null || archivo.getDatos() == null) return false;
        response.setContentType(archivo.getContentType());
        response.setContentLengthLong(archivo.getDatos().length);
        response.setHeader("Cache-Control", "public, max-age=86400");
        try (ServletOutputStream out = response.getOutputStream()) {
            out.write(archivo.getDatos());
        }
        return true;
    }

    private Path respaldoDesplegado(HttpServletRequest request, String pathInfo) {
        String rutaReal = request.getServletContext().getRealPath("/uploads" + (pathInfo == null ? "" : pathInfo));
        return rutaReal == null ? null : Path.of(rutaReal);
    }
}
