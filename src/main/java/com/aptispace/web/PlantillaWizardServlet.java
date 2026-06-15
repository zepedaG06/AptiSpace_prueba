package com.aptispace.web;

import java.io.IOException;
import java.util.Comparator;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
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
        Long id = largoOpcional(request, "id");
        if (id != null) {
            Prueba prueba = cargarPrueba(XPersistence.getManager(), id);
            if (prueba != null) {
                prueba.getEjercicios().sort(Comparator.comparing(Ejercicio::getNumero));
                for (Ejercicio ejercicio : prueba.getEjercicios()) {
                    ejercicio.getOpciones().sort(Comparator.comparing(OpcionEjercicio::getLetra));
                }
                request.setAttribute("plantilla", prueba);
            }
            else {
                request.setAttribute("error", "No existe la plantilla indicada.");
            }
        }
        request.getRequestDispatcher("/WEB-INF/jsp/plantilla-wizard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        EntityManager em = XPersistence.getManager();
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            Long pruebaId = largoOpcional(request, "pruebaId");
            String nombre = valor(request, "nombre");
            if (nombre.isEmpty()) throw new IllegalArgumentException("El nombre de la plantilla es obligatorio.");
            if (existePruebaConNombre(em, nombre, pruebaId)) throw new IllegalArgumentException("Ya existe una plantilla con ese nombre.");
            Prueba prueba = pruebaId == null ? new Prueba() : cargarPrueba(em, pruebaId);
            if (prueba == null) throw new IllegalArgumentException("No existe la plantilla indicada.");
            prueba.setNombre(nombre);
            prueba.setDescripcion(valor(request, "descripcion"));
            prueba.setTiempoLimite(entero(request, "tiempoLimite", 30));
            prueba.setCantidadEjercicios(entero(request, "cantidadEjercicios", 1));
            prueba.setEstado(Prueba.EstadoPrueba.valueOf(valor(request, "estado", prueba.getEstado().name())));
            if (pruebaId == null) em.persist(prueba);

            int cantidad = prueba.getCantidadEjercicios();
            for (java.util.Iterator<Ejercicio> it = prueba.getEjercicios().iterator(); it.hasNext(); ) {
                Ejercicio existente = it.next();
                if (existente.getNumero() != null && existente.getNumero() > cantidad) {
                    if (ejercicioTieneRespuestas(em, existente)) {
                        throw new IllegalArgumentException("No se puede reducir la cantidad porque el ejercicio " + existente.getNumero() + " ya tiene respuestas registradas.");
                    }
                    it.remove();
                }
            }
            for (int numero = 1; numero <= cantidad; numero++) {
                Ejercicio ejercicio = ejercicioPorNumero(prueba, numero);
                boolean nuevoEjercicio = ejercicio == null;
                if (nuevoEjercicio) ejercicio = new Ejercicio();
                ejercicio.setPrueba(prueba);
                ejercicio.setNumero(numero);
                ejercicio.setEnunciado(valor(request, "enunciado" + numero));
                TipoRespuesta tipoRespuesta = TipoRespuesta.valueOf(valor(request, "tipoRespuesta" + numero, "UNICA"));
                ejercicio.setTipoRespuesta(tipoRespuesta);
                ejercicio.setImagenModelo(guardarArchivoOpcional(em, request, "imagenModelo" + numero, ejercicio.getImagenModelo(), "imagen modelo del ejercicio " + numero));
                if (nuevoEjercicio) {
                    prueba.getEjercicios().add(ejercicio);
                    em.persist(ejercicio);
                }

                int correctas = 0;
                for (LetraOpcion letra : LetraOpcion.values()) {
                    OpcionEjercicio opcion = opcionPorLetra(ejercicio, letra);
                    boolean nuevaOpcion = opcion == null;
                    if (nuevaOpcion) opcion = new OpcionEjercicio();
                    opcion.setEjercicio(ejercicio);
                    opcion.setLetra(letra);
                    opcion.setImagenOpcion(guardarArchivoOpcional(em, request, "opcion" + numero + letra.name(), opcion.getImagenOpcion(), "imagen de opcion " + letra.name() + " del ejercicio " + numero));
                    boolean correcta = esCorrecta(request, numero, letra);
                    opcion.setEsCorrecta(correcta);
                    if (correcta) correctas++;
                    if (nuevaOpcion) {
                        ejercicio.getOpciones().add(opcion);
                        em.persist(opcion);
                    }
                }
                if (TipoRespuesta.UNICA.equals(tipoRespuesta) && correctas != 1) {
                    throw new IllegalArgumentException("El ejercicio " + numero + " debe tener una sola opcion correcta.");
                }
                if (TipoRespuesta.MULTIPLE.equals(tipoRespuesta) && correctas < 2) {
                    throw new IllegalArgumentException("El ejercicio " + numero + " debe tener dos o mas opciones correctas.");
                }
            }

            confirmarSiEsPropia(em, transaccionPropia);
            response.sendRedirect(request.getContextPath() + "/plantillas?ok=1");
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            String id = valor(request, "pruebaId");
            String destino = request.getContextPath() + "/plantilla-wizard";
            if (!id.isEmpty()) destino += "?id=" + id + "&error=";
            else destino += "?error=";
            response.sendRedirect(destino + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }

    private String guardarArchivo(EntityManager em, HttpServletRequest request, String nombreParte) throws IOException, ServletException {
        Part part = request.getPart(nombreParte);
        return UploadStorage.guardarImagen(em, part, true, "Solo se permiten imagenes.");
    }

    private String guardarArchivoRequerido(EntityManager em, HttpServletRequest request, String nombreParte, String etiqueta) throws IOException, ServletException {
        String ruta = guardarArchivo(em, request, nombreParte);
        if (ruta == null) throw new IllegalArgumentException("Falta la " + etiqueta + ".");
        return ruta;
    }

    private String guardarArchivoOpcional(EntityManager em, HttpServletRequest request, String nombreParte, String rutaActual, String etiqueta) throws IOException, ServletException {
        String ruta = guardarArchivo(em, request, nombreParte);
        if (ruta != null) return ruta;
        if (rutaActual == null || rutaActual.isBlank()) throw new IllegalArgumentException("Falta la " + etiqueta + ".");
        return rutaActual;
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

    private Prueba cargarPrueba(EntityManager em, Long id) {
        try {
            return em.createQuery("select distinct p from Prueba p left join fetch p.ejercicios where p.id = :id", Prueba.class)
                .setParameter("id", id)
                .getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private Ejercicio ejercicioPorNumero(Prueba prueba, int numero) {
        for (Ejercicio ejercicio : prueba.getEjercicios()) {
            if (ejercicio.getNumero() != null && ejercicio.getNumero() == numero) return ejercicio;
        }
        return null;
    }

    private OpcionEjercicio opcionPorLetra(Ejercicio ejercicio, LetraOpcion letra) {
        for (OpcionEjercicio opcion : ejercicio.getOpciones()) {
            if (letra.equals(opcion.getLetra())) return opcion;
        }
        return null;
    }

    private boolean existePruebaConNombre(EntityManager em, String nombre, Long idActual) {
        String jpql = "select count(p) from Prueba p where lower(p.nombre) = lower(:nombre)";
        if (idActual != null) jpql += " and p.id <> :idActual";
        javax.persistence.TypedQuery<Long> query = em.createQuery(jpql, Long.class).setParameter("nombre", nombre);
        if (idActual != null) query.setParameter("idActual", idActual);
        Long total = query.getSingleResult();
        return total > 0;
    }

    private boolean ejercicioTieneRespuestas(EntityManager em, Ejercicio ejercicio) {
        if (ejercicio.getId() == null) return false;
        Long total = em.createQuery("select count(r) from RespuestaEvaluado r where r.ejercicio = :ejercicio", Long.class)
            .setParameter("ejercicio", ejercicio)
            .getSingleResult();
        return total > 0;
    }

    private Long largoOpcional(HttpServletRequest request, String nombre) {
        String valor = valor(request, nombre);
        if (valor.isEmpty()) return null;
        try { return Long.valueOf(valor); }
        catch (NumberFormatException ex) { throw new IllegalArgumentException("Hay un identificador invalido."); }
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
