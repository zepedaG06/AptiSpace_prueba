package com.aptispace.web;

import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openxava.util.Users;

public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        RoleSessionSupport.limpiar(request, response);
        request.getSession(true).removeAttribute("naviox.user");
        try {
            Users.setCurrent(request);
        }
        catch (RuntimeException ignored) {
        }
        request.getSession(true).invalidate();
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.sendRedirect(request.getContextPath() + "/");
    }
}
