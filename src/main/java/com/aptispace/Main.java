package com.aptispace;

import java.nio.file.Files;
import java.nio.file.Path;
import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import org.apache.tomcat.util.scan.StandardJarScanner;

public class Main {
    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getProperty("app.port", System.getenv().getOrDefault("PORT", "8081")));
        Path projectRoot = Path.of("").toAbsolutePath();
        Path webapp = projectRoot.resolve("src/main/webapp");
        Path classes = projectRoot.resolve("target/classes");
        Path base = projectRoot.resolve("target/embedded-tomcat");

        if (!Files.isDirectory(webapp)) {
            throw new IllegalStateException("No se encontro src/main/webapp. Ejecuta desde la raiz del proyecto AptiSpace.");
        }
        if (!Files.isDirectory(classes)) {
            throw new IllegalStateException("No se encontro target/classes. Ejecuta primero: mvn package -DskipTests");
        }
        Files.createDirectories(base);

        Tomcat tomcat = new Tomcat();
        tomcat.setBaseDir(base.toString());
        tomcat.setPort(port);
        tomcat.getConnector();

        Context context = tomcat.addWebapp("/AptiSpace", webapp.toString());
        context.setParentClassLoader(Main.class.getClassLoader());
        StandardJarScanner jarScanner = new StandardJarScanner();
        jarScanner.setScanClassPath(false);
        context.setJarScanner(jarScanner);

        WebResourceRoot resources = new StandardRoot(context);
        resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes", classes.toString(), "/"));
        context.setResources(resources);

        tomcat.start();
        System.out.println("AptiSpace iniciado en http://localhost:" + port + "/AptiSpace/");
        tomcat.getServer().await();
    }
}
