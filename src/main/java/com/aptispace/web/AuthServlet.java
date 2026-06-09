package com.aptispace.web;

import java.io.IOException;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.jpa.XPersistence;
import com.aptispace.modelo.Evaluado;
import com.aptispace.modelo.Rol;
import com.aptispace.modelo.Usuario;

public class AuthServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String accion = valor(request, "accion");

        try {
            if ("registro".equals(accion)) registrar(request, response);
            else iniciarSesion(request, response);
        }
        catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=" + codificar(ex.getMessage()));
        }
    }

    private void iniciarSesion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String usuario = valor(request, "usuario");
        String contrasena = valor(request, "contrasena");
        String tipo = valor(request, "tipo");

        EntityManager em = XPersistence.getManager();
        asegurarDatosBase(em);
        Usuario encontrado = buscarUsuario(em, usuario);
        if (encontrado == null) encontrado = crearUsuarioDemoSiAplica(em, usuario, contrasena);
        if (encontrado == null || !encontrado.getContrasena().equals(contrasena)) {
            throw new IllegalArgumentException("Usuario o contrasena incorrectos.");
        }
        if (!tieneRol(encontrado, tipo)) {
            throw new IllegalArgumentException("La cuenta no pertenece al entorno seleccionado.");
        }

        boolean administrador = tieneRol(encontrado, "ADMINISTRADOR");
        request.getSession(true).setAttribute("aptispace.usuario", encontrado.getNombreUsuario());
        request.getSession(true).setAttribute("aptispace.tipo", tipo);
        request.getSession(true).setAttribute("aptispace.admin", administrador);
        response.sendRedirect(destino(request, tipo, administrador));
    }

    private void registrar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String tipo = valor(request, "tipo");
        String usuario = valor(request, "usuario");
        String contrasena = valor(request, "contrasena");
        String nombres = valor(request, "nombres");
        String apellidos = valor(request, "apellidos");
        String correo = valor(request, "correo");

        if (usuario.length() < 4) throw new IllegalArgumentException("El usuario debe tener al menos 4 caracteres.");
        if (contrasena.length() < 6) throw new IllegalArgumentException("La contrasena debe tener al menos 6 caracteres.");
        if (nombres.isEmpty() || apellidos.isEmpty()) throw new IllegalArgumentException("Nombres y apellidos son obligatorios.");

        EntityManager em = XPersistence.getManager();
        asegurarDatosBase(em);
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            if (buscarUsuario(em, usuario) != null) throw new IllegalArgumentException("Ese usuario ya existe.");

            Usuario nuevo = new Usuario();
            nuevo.setNombreUsuario(usuario);
            nuevo.setContrasena(contrasena);
            nuevo.setNombres(nombres);
            nuevo.setApellidos(apellidos);
            nuevo.setCorreo(correo);
            nuevo.getRoles().add(obtenerRol(em, tipo));
            em.persist(nuevo);

            if ("EVALUADO".equals(tipo)) crearEvaluadoDemo(em, nombres, apellidos);

            confirmarSiEsPropia(em, transaccionPropia);
            request.getSession(true).setAttribute("aptispace.usuario", usuario);
            request.getSession(true).setAttribute("aptispace.tipo", tipo);
            request.getSession(true).setAttribute("aptispace.admin", false);
            response.sendRedirect(destino(request, tipo, false));
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private Usuario buscarUsuario(EntityManager em, String nombreUsuario) {
        TypedQuery<Usuario> query = em.createQuery("select u from Usuario u where u.nombreUsuario = :usuario", Usuario.class);
        query.setParameter("usuario", nombreUsuario);
        try {
            return query.getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private Rol obtenerRol(EntityManager em, String tipo) {
        TypedQuery<Rol> query = em.createQuery("select r from Rol r where r.nombreRol = :rol", Rol.class);
        query.setParameter("rol", tipo);
        return query.getSingleResult();
    }

    private void asegurarDatosBase(EntityManager em) {
        if (buscarRol(em, "ADMINISTRADOR") != null && buscarRol(em, "PSICOLOGO") != null && buscarRol(em, "EVALUADO") != null) return;

        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            Rol admin = guardarRol(em, "ADMINISTRADOR", "Gestiona usuarios, pruebas y configuraciones.");
            guardarRol(em, "PSICOLOGO", "Registra evaluados, aplica pruebas y consulta resultados.");
            guardarRol(em, "EVALUADO", "Realiza la prueba asignada.");
            admin.getNombreRol();
            confirmarSiEsPropia(em, transaccionPropia);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
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

    private Rol guardarRol(EntityManager em, String nombre, String descripcion) {
        Rol rol = buscarRol(em, nombre);
        if (rol != null) return rol;
        rol = new Rol();
        rol.setNombreRol(nombre);
        rol.setDescripcion(descripcion);
        em.persist(rol);
        return rol;
    }

    private Rol buscarRol(EntityManager em, String nombre) {
        TypedQuery<Rol> query = em.createQuery("select r from Rol r where r.nombreRol = :rol", Rol.class);
        query.setParameter("rol", nombre);
        try {
            return query.getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private void guardarUsuario(EntityManager em, String nombreUsuario, String contrasena, String nombres, String apellidos, String correo, Rol... roles) {
        Usuario usuario = buscarUsuario(em, nombreUsuario);
        if (usuario == null) {
            usuario = new Usuario();
            usuario.setNombreUsuario(nombreUsuario);
            usuario.setContrasena(contrasena);
            usuario.setNombres(nombres);
            usuario.setApellidos(apellidos);
            usuario.setCorreo(correo);
            em.persist(usuario);
        }
        for (Rol rol : roles) usuario.getRoles().add(rol);
    }

    private Usuario crearUsuarioDemoSiAplica(EntityManager em, String nombreUsuario, String contrasena) {
        if ("admin".equals(nombreUsuario) && "admin123".equals(contrasena)) {
            return crearUsuarioConRol(em, "admin", "admin123", "Administrador", "AptiSpace", "admin@aptispace.local", "ADMINISTRADOR", "PSICOLOGO");
        }
        if ("evaluador".equals(nombreUsuario) && "evaluador123".equals(contrasena)) {
            return crearUsuarioConRol(em, "evaluador", "evaluador123", "Evaluador", "Demo", "evaluador@aptispace.local", "PSICOLOGO");
        }
        if ("evaluado".equals(nombreUsuario) && "evaluado123".equals(contrasena)) {
            return crearUsuarioConRol(em, "evaluado", "evaluado123", "Persona", "Demo", "evaluado@aptispace.local", "EVALUADO");
        }
        return null;
    }

    private Usuario crearUsuarioConRol(EntityManager em, String nombreUsuario, String contrasena, String nombres, String apellidos, String correo, String... roles) {
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            Usuario usuario = new Usuario();
            usuario.setNombreUsuario(nombreUsuario);
            usuario.setContrasena(contrasena);
            usuario.setNombres(nombres);
            usuario.setApellidos(apellidos);
            usuario.setCorreo(correo);
            for (String rol : roles) usuario.getRoles().add(obtenerRol(em, rol));
            em.persist(usuario);
            confirmarSiEsPropia(em, transaccionPropia);
            return usuario;
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private boolean tieneRol(Usuario usuario, String tipo) {
        return usuario.getRoles().stream().anyMatch(rol -> tipo.equals(rol.getNombreRol()));
    }

    private void crearEvaluadoDemo(EntityManager em, String nombres, String apellidos) {
        Evaluado evaluado = new Evaluado();
        evaluado.setNombres(nombres);
        evaluado.setApellidos(apellidos);
        evaluado.setFechaNacimiento(java.time.LocalDate.of(2000, 1, 1));
        evaluado.setEdad(26);
        evaluado.setSexo(Evaluado.Sexo.OTRO);
        evaluado.setEstudiosRealizados("Pendiente");
        evaluado.setProfesion("Pendiente");
        em.persist(evaluado);
    }

    private String destino(HttpServletRequest request, String tipo, boolean administrador) {
        if ("EVALUADO".equals(tipo)) return request.getContextPath() + "/evaluado-home.jsp";
        if (administrador) return request.getContextPath() + "/admin-home.jsp";
        return request.getContextPath() + "/evaluador-home.jsp";
    }

    private String valor(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }

    private String codificar(String texto) throws IOException {
        return java.net.URLEncoder.encode(texto == null ? "Error" : texto, "UTF-8");
    }
}
