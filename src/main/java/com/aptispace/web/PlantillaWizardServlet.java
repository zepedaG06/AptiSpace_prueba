package com.aptispace.web;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import javax.persistence.EntityManager;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.Ejercicio;
import com.aptispace.modelo.Ejercicio.TipoRespuesta;
import com.aptispace.modelo.OpcionEjercicio;
import com.aptispace.modelo.OpcionEjercicio.LetraOpcion;
import com.aptispace.modelo.Prueba;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 35 * 1024 * 1024)
public class PlantillaWizardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/plantilla-wizard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        EntityManager em = XPersistence.getManager();
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            Prueba prueba = new Prueba();
            prueba.setNombre(valor(request, "nombre"));
            prueba.setDescripcion(valor(request, "descripcion"));
            prueba.setTiempoLimite(entero(request, "tiempoLimite", 30));
            prueba.setCantidadEjercicios(entero(request, "cantidadEjercicios", 1));
            em.persist(prueba);

            int cantidad = prueba.getCantidadEjercicios();
            for (int numero = 1; numero <= cantidad; numero++) {
                Ejercicio ejercicio = new Ejercicio();
                ejercicio.setPrueba(prueba);
                ejercicio.setNumero(numero);
                ejercicio.setEnunciado(valor(request, "enunciado" + numero));
                TipoRespuesta tipoRespuesta = TipoRespuesta.valueOf(valor(request, "tipoRespuesta" + numero, "UNICA"));
                ejercicio.setTipoRespuesta(tipoRespuesta);
                ejercicio.setImagenModelo(guardarArchivoRequerido(request, "imagenModelo" + numero, "imagen modelo del ejercicio " + numero));
                prueba.getEjercicios().add(ejercicio);
                em.persist(ejercicio);

                int correctas = 0;
                for (LetraOpcion letra : LetraOpcion.values()) {
                    OpcionEjercicio opcion = new OpcionEjercicio();
                    opcion.setEjercicio(ejercicio);
                    opcion.setLetra(letra);
                    opcion.setImagenOpcion(guardarArchivoRequerido(request, "opcion" + numero + letra.name(), "imagen de opcion " + letra.name() + " del ejercicio " + numero));
                    boolean correcta = esCorrecta(request, numero, letra);
                    opcion.setEsCorrecta(correcta);
                    if (correcta) correctas++;
                    ejercicio.getOpciones().add(opcion);
                    em.persist(opcion);
                }
                if (TipoRespuesta.UNICA.equals(tipoRespuesta) && correctas != 1) {
                    throw new IllegalArgumentException("El ejercicio " + numero + " debe tener una sola opcion correcta.");
                }
                if (TipoRespuesta.MULTIPLE.equals(tipoRespuesta) && correctas < 2) {
                    throw new IllegalArgumentException("El ejercicio " + numero + " debe tener dos o mas opciones correctas.");
                }
            }

            confirmarSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getContextPath() + "/plantilla-wizard?ok=1");
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getContextPath() + "/plantilla-wizard?error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }

    private String guardarArchivo(HttpServletRequest request, String nombreParte) throws IOException, ServletException {
        Part part = request.getPart(nombreParte);
        if (part == null || part.getSize() == 0) return null;

        String contentType = part.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Solo se permiten imagenes.");
        }

        String extension = extension(part.getSubmittedFileName());
        String nombreArchivo = UUID.randomUUID() + extension;
        String rutaReal = request.getServletContext().getRealPath("/uploads/s2");
        if (rutaReal == null) throw new IllegalStateException("No se pudo resolver la carpeta de cargas.");
        Path carpeta = Path.of(rutaReal);
        Files.createDirectories(carpeta);
        part.write(carpeta.resolve(nombreArchivo).toString());
        return "uploads/s2/" + nombreArchivo;
    }

    private String guardarArchivoRequerido(HttpServletRequest request, String nombreParte, String etiqueta) throws IOException, ServletException {
        String ruta = guardarArchivo(request, nombreParte);
        if (ruta == null) throw new IllegalArgumentException("Falta la " + etiqueta + ".");
        return ruta;
    }

    private String extension(String nombre) {
        if (nombre == null) return ".png";
        int punto = nombre.lastIndexOf('.');
        if (punto < 0) return ".png";
        String extension = nombre.substring(punto).toLowerCase();
        return extension.matches("\\.(png|jpg|jpeg|gif|svg|webp)") ? extension : ".png";
    }

    private Integer entero(HttpServletRequest request, String nombre, int defecto) {
        String valor = valor(request, nombre);
        if (valor.isEmpty()) return defecto;
        try {
            return Integer.valueOf(valor);
        }
        catch (NumberFormatException ex) {
            throw new IllegalArgumentException("El campo " + nombre + " debe ser numerico.");
        }
    }

    private String valor(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }

    private String valor(HttpServletRequest request, String nombre, String defecto) {
        String valor = valor(request, nombre);
        return valor.isEmpty() ? defecto : valor;
    }

    private boolean esCorrecta(HttpServletRequest request, int numero, LetraOpcion letra) {
        String unica = request.getParameter("correcta" + numero);
        if (letra.name().equals(unica)) return true;
        String[] multiples = request.getParameterValues("correcta" + numero + "[]");
        if (multiples == null) return false;
        for (String valor : multiples) if (letra.name().equals(valor)) return true;
        return false;
    }

    private boolean iniciarTransaccionSiHaceFalta(EntityManager em) {
        if (em.getTransaction().isActive()) return false;
        em.getTransaction().begin();
        return true;
    }

    private void confirmarSiEsPropia(EntityManager em, boolean transaccionPropia) {
        if (transaccionPropia && em.getTransaction().isActive()) em.getTransaction().commit();
    }

    private void revertirSiEsPropia(EntityManager em, boolean transaccionPropia) {
        if (transaccionPropia && em.getTransaction().isActive()) em.getTransaction().rollback();
    }
}
