<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, javax.servlet.*, javax.servlet.http.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Servlet Information</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f4f4f4;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        table {
            width: 80%;
            margin: 0 auto;
            border-collapse: collapse;
            background-color: #fff;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <h1>Servlet Information</h1>
    <table>
        <tr>
            <th>Attribute</th>
            <th>Value</th>
        </tr>
        <tr>
            <td>Servlet Name</td>
	    <td><%= getServletConfig().getServletName() %></td>
        </tr>
	<%--
        <tr>
            <td>Context Path</td>
            <td><%= getServletContext().getContextPath() %></td>
        </tr>
	--%>
        <tr>
            <td>Server Name</td>
            <td><%= request.getServerName() %></td>
        </tr>
        <tr>
            <td>Server Port</td>
            <td><%= request.getServerPort() %></td>
        </tr>
        <tr>
            <td>Protocol</td>
            <td><%= request.getProtocol() %></td>
        </tr>
        <tr>
            <td>Remote Addr</td>
            <td><%= request.getRemoteAddr() %></td>
        </tr>
        <tr>
            <td>Remote Host</td>
            <td><%= request.getRemoteHost() %></td>
        </tr>
        <tr>
            <td>Scheme</td>
            <td><%= request.getScheme() %></td>
        </tr>
        <tr>
            <td>Request URI</td>
            <td><%= request.getRequestURI() %></td>
        </tr>
        <tr>
            <td>Request URL</td>
            <td><%= request.getRequestURL().toString() %></td>
        </tr>
        <tr>
            <td>Servlet Context Name</td>
            <td><%= getServletContext().getServletContextName() %></td>
        </tr>
        <tr>
            <td>Cookies - Client가 보낸 Session(쿠키) 정보</td>
            <td>
                <%
                    Cookie[] cookies = request.getCookies();
                    if (cookies != null) {
                        for (Cookie cookie : cookies) {
                            out.print(cookie.getName() + " = " + cookie.getValue() + "<br>");
                        }
                    } else {
                        out.print("No cookies found");
                    }
                %>
            </td>
        </tr>
        <tr>
            <td>Session ID - Server가 응답한 Session 정보</td>
            <td><%= session.getId() %></td>
        </tr>
    </table>
</body>
</html>
