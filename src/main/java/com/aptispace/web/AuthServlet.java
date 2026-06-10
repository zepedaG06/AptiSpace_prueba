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
import com.aptispace.modelo.GrupoEvaluacion;
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
        Usuario encontrado = buscarUsuario(em, usuario);
        if (encontrado == null && esCuentaDemo(usuario, contrasena)) {
            asegurarCuentaDemo(em, usuario);
            encontrado = buscarUsuario(em, usuario);
        }
        if (encontrado == null || !encontrado.getContrasena().equals(contrasena)) {
            throw new IllegalArgumentException("Usuario o contrasena incorrectos.");
        }
        if (!tieneRol(encontrado, tipo)) {
            throw new IllegalArgumentException("La cuenta no pertenece al entorno seleccionado.");
        }

        request.getSession(true).setAttribute("aptispace.usuario", encontrado.getNombreUsuario());
        request.getSession(true).setAttribute("aptispace.tipo", tipo);
        request.getSession(true).setAttribute("aptispace.admin", false);
        response.sendRedirect(destino(request, tipo));
    }

    private void registrar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String tipo = valor(request, "tipo");
        String contrasena = valor(request, "contrasena");
        String nombres = valor(request, "nombres");
        String apellidos = valor(request, "apellidos");
        String correo = valor(request, "correo");

        if (contrasena.length() < 6) throw new IllegalArgumentException("La contrasena debe tener al menos 6 caracteres.");
        if (nombres.isEmpty() || apellidos.isEmpty()) throw new IllegalArgumentException("Nombres y apellidos son obligatorios.");
        if (correo.isEmpty()) throw new IllegalArgumentException("El correo es obligatorio.");

        EntityManager em = XPersistence.getManager();
        String usuario = generarNombreUsuario(em, correo, nombres, apellidos);
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            if (buscarPorCorreo(em, correo) != null) throw new IllegalArgumentException("Ese correo ya esta registrado.");

            Usuario nuevo = new Usuario();
            nuevo.setNombreUsuario(usuario);
            nuevo.setContrasena(contrasena);
            nuevo.setNombres(nombres);
            nuevo.setApellidos(apellidos);
            nuevo.setCorreo(correo);
            nuevo.getRoles().add(obtenerRol(em, tipo));
            em.persist(nuevo);

            if ("EVALUADO".equals(tipo)) crearEvaluadoDesdeRegistro(em, request, nuevo);

            confirmarSiEsPropia(em, transaccionPropia);
            request.getSession(true).setAttribute("aptispace.usuario", usuario);
            request.getSession(true).setAttribute("aptispace.tipo", tipo);
            request.getSession(true).setAttribute("aptispace.admin", false);
            response.sendRedirect(destino(request, tipo));
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private Usuario buscarUsuario(EntityManager em, String nombreUsuario) {
        TypedQuery<Usuario> query = em.createQuery("select u from Usuario u where u.nombreUsuario = :usuario or u.correo = :usuario", Usuario.class);
        query.setParameter("usuario", nombreUsuario);
        try {
            return query.getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private Usuario buscarPorCorreo(EntityManager em, String correo) {
        TypedQuery<Usuario> query = em.createQuery("select u from Usuario u where lower(u.correo) = lower(:correo)", Usuario.class);
        query.setParameter("correo", correo);
        try {
            return query.getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private String generarNombreUsuario(EntityManager em, String correo, String nombres, String apellidos) {
        String base = correo.contains("@") ? correo.substring(0, correo.indexOf('@')) : nombres + "." + apellidos;
        base = base.toLowerCase()
            .replaceAll("[^a-z0-9]+", ".")
            .replaceAll("^\\.+|\\.+$", "");
        if (base.length() < 4) base = "usuario";
        String candidato = base;
        int consecutivo = 2;
        while (buscarUsuario(em, candidato) != null) candidato = base + consecutivo++;
        return candidato;
    }

    private Rol obtenerRol(EntityManager em, String tipo) {
        TypedQuery<Rol> query = em.createQuery("select r from Rol r where r.nombreRol = :rol", Rol.class);
        query.setParameter("rol", tipo);
        return query.getSingleResult();
    }

    private void asegurarDatosBase(EntityManager em) {
        if (buscarRol(em, "PSICOLOGO") != null && buscarRol(em, "EVALUADO") != null) return;

        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            guardarRol(em, "PSICOLOGO", "Registra evaluados, aplica pruebas y consulta resultados.");
            guardarRol(em, "EVALUADO", "Realiza la prueba asignada.");
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

    private boolean esCuentaDemo(String usuario, String contrasena) {
        return ("evaluador".equals(usuario) && "evaluador123".equals(contrasena))
            || ("evaluado".equals(usuario) && "evaluado123".equals(contrasena));
    }

    private void asegurarCuentaDemo(EntityManager em, String usuario) {
        boolean transaccionPropia = iniciarTransaccionSiHaceFalta(em);
        try {
            insertarRolSiNoExiste(em, "PSICOLOGO", "Registra evaluados, aplica pruebas y consulta resultados.");
            insertarRolSiNoExiste(em, "EVALUADO", "Realiza la prueba asignada.");

            if ("evaluador".equals(usuario)) {
                insertarUsuarioSiNoExiste(em, "evaluador", "evaluador123", "Evaluador", "Demo", "evaluador@aptispace.local");
                asignarRol(em, "evaluador", "PSICOLOGO");
            }
            else if ("evaluado".equals(usuario)) {
                insertarUsuarioSiNoExiste(em, "evaluado", "evaluado123", "Persona", "Demo", "evaluado@aptispace.local");
                asignarRol(em, "evaluado", "EVALUADO");
                Usuario cuenta = buscarUsuario(em, "evaluado");
                if (cuenta != null && cuenta.getEvaluado() == null) crearEvaluadoDemo(em, cuenta);
            }

            confirmarSiEsPropia(em, transaccionPropia);
        }
        catch (RuntimeException ex) {
            revertirSiEsPropia(em, transaccionPropia);
            throw ex;
        }
    }

    private void insertarRolSiNoExiste(EntityManager em, String nombre, String descripcion) {
        em.createNativeQuery(
            "merge into rol (nombre_rol, descripcion) key(nombre_rol) values (?, ?)")
            .setParameter(1, nombre)
            .setParameter(2, descripcion)
            .executeUpdate();
    }

    private void insertarUsuarioSiNoExiste(EntityManager em, String usuario, String contrasena, String nombres, String apellidos, String correo) {
        em.createNativeQuery(
            "merge into usuario (nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion) "
                + "key(nombre_usuario) values (?, ?, ?, ?, ?, 'ACTIVO', CURRENT_TIMESTAMP)")
            .setParameter(1, usuario)
            .setParameter(2, contrasena)
            .setParameter(3, nombres)
            .setParameter(4, apellidos)
            .setParameter(5, correo)
            .executeUpdate();
    }

    private void asignarRol(EntityManager em, String usuario, String rol) {
        em.createNativeQuery(
            "merge into usuario_rol (usuario_id, rol_id) key(usuario_id, rol_id) "
                + "select u.id, r.id from usuario u, rol r "
                + "where u.nombre_usuario = ? and r.nombre_rol = ?")
            .setParameter(1, usuario)
            .setParameter(2, rol)
            .executeUpdate();
    }

    private Usuario crearUsuarioDemoSiAplica(EntityManager em, String nombreUsuario, String contrasena) {
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

    private void crearEvaluadoDesdeRegistro(EntityManager em, HttpServletRequest request, Usuario usuario) {
        String sexo = valor(request, "sexo");
        String carrera = valor(request, "carrera");
        Integer anioCarrera = enteroOpcional(valor(request, "anioCarrera"));
        Integer edad = enteroOpcional(valor(request, "edad"));
        String codigoEspacio = valor(request, "codigoEspacio").toUpperCase();

        if (sexo.isEmpty()) throw new IllegalArgumentException("El sexo es obligatorio para la cuenta de evaluado.");
        if (edad == null) throw new IllegalArgumentException("La edad es obligatoria para la cuenta de evaluado.");
        if (edad < 10 || edad > 99) throw new IllegalArgumentException("La edad debe estar entre 10 y 99 anos.");

        Evaluado evaluado = new Evaluado();
        evaluado.setUsuario(usuario);
        evaluado.setNombres(usuario.getNombres());
        evaluado.setApellidos(usuario.getApellidos());
        evaluado.setFechaNacimiento(java.time.LocalDate.now().minusYears(edad).withDayOfYear(1));
        evaluado.setEdad(edad);
        evaluado.setSexo(Evaluado.Sexo.valueOf(sexo));
        evaluado.setCarrera(carrera);
        evaluado.setAnioCarrera(anioCarrera);
        evaluado.setEstudiosRealizados(carrera.isEmpty() ? "Pendiente" : carrera);
        evaluado.setProfesion(carrera);
        em.persist(evaluado);

        if (!codigoEspacio.isEmpty()) {
            GrupoEvaluacion grupo = buscarGrupoPorCodigo(em, codigoEspacio);
            if (grupo == null) throw new IllegalArgumentException("No existe un espacio con el codigo indicado.");
            grupo.getEvaluados().add(evaluado);
        }
    }

    private void crearEvaluadoDemo(EntityManager em, Usuario usuario) {
        Evaluado evaluado = new Evaluado();
        evaluado.setUsuario(usuario);
        evaluado.setNombres(usuario.getNombres());
        evaluado.setApellidos(usuario.getApellidos());
        evaluado.setFechaNacimiento(java.time.LocalDate.of(2000, 1, 1));
        evaluado.setEdad(26);
        evaluado.setSexo(Evaluado.Sexo.OTRO);
        evaluado.setCarrera("Demo");
        evaluado.setAnioCarrera(1);
        evaluado.setEstudiosRealizados("Demo");
        evaluado.setProfesion("Demo");
        em.persist(evaluado);
    }

    private GrupoEvaluacion buscarGrupoPorCodigo(EntityManager em, String codigo) {
        TypedQuery<GrupoEvaluacion> query = em.createQuery("select g from GrupoEvaluacion g where g.codigo = :codigo and g.activo = true", GrupoEvaluacion.class);
        query.setParameter("codigo", codigo);
        try {
            return query.getSingleResult();
        }
        catch (NoResultException ex) {
            return null;
        }
    }

    private Integer enteroOpcional(String valor) {
        if (valor == null || valor.isEmpty()) return null;
        try {
            return Integer.valueOf(valor);
        }
        catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Hay un valor numerico invalido.");
        }
    }

    private String destino(HttpServletRequest request, String tipo) {
        if ("EVALUADO".equals(tipo)) return request.getContextPath() + "/evaluado-home.jsp";
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
