<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="javax.servlet.*" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String email = request.getParameter("email");
    String action = request.getParameter("action");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String url = "jdbc:mysql://localhost:3306/LSA";
    String dbUsername = "root";
    String dbPassword = "n0m3l0";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, dbUsername, dbPassword);

        if ("register".equals(action)) { 
            // Verificar si el usuario ya existe
            ps = con.prepareStatement("SELECT * FROM usuarios WHERE username = ? OR email = ?");
            ps.setString(1, username);
            ps.setString(2, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                out.println("<script>alert('El usuario o el correo electr�nico ya est�n registrados.'); window.location='login.jsp';</script>");
            } else {
                // Registrar nuevo usuario
                ps = con.prepareStatement("INSERT INTO usuarios (username, email, password) VALUES (?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.executeUpdate();
                
                // Obtener el ID autogenerado
                rs = ps.getGeneratedKeys();
                int userID = -1;
                if (rs.next()) {
                    userID = rs.getInt(1);
                }

                // Guarda el userID en la sesi�n
                HttpSession userSession = request.getSession(true);
                userSession.setAttribute("userId", userID);

                out.println("<script> window.location='success.html';</script>");
            }

        } else if ("login".equals(action)) {
            // Autenticaci�n de usuario
            ps = con.prepareStatement("SELECT * FROM usuarios WHERE username = ? AND password = ?");
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) {
                // Guardar el userID y username en la sesi�n
                int userId = rs.getInt("id"); // Ajusta el nombre de columna "id" seg�n tu BD
                HttpSession userSession = request.getSession(true);
                userSession.setAttribute("userId", userId);
                userSession.setAttribute("username", username);
                userSession.setMaxInactiveInterval(30 * 60); // 30 minutos de inactividad

                // Crear cookie de sesi�n
                Cookie userCookie = new Cookie("username", username);
                userCookie.setMaxAge(60 * 60 * 24); // 24 horas
                userCookie.setHttpOnly(true);
                response.addCookie(userCookie);

                // Redireccionar a la p�gina principal
                response.sendRedirect("success.html"); // Cambia a la p�gina JSP que muestra la informaci�n
            } else {
                out.println("<script>alert('Usuario o contrase�a incorrectos.'); window.location='login.jsp';</script>");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('Ocurri� un error');</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
        if (ps != null) try { ps.close(); } catch (Exception e) { e.printStackTrace(); }
        if (con != null) try { con.close(); } catch (Exception e) { e.printStackTrace(); }
    }
%>
