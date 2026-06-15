package com.aptispace.web;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String tipo = request.getParameter("tipo");
        if ("PSICOLOGO".equals(tipo) || "EVALUADO".equals(tipo)) {
            RoleSessionSupport.limpiar(request, response, tipo);
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        RoleSessionSupport.limpiar(request, response);
        request.getSession(true).invalidate();
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}
