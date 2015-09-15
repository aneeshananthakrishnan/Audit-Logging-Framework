<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" 
	import="java.sql.*" 
	import="java.util.*"
	import="javax.naming.Context"
	import="javax.naming.InitialContext"
	import="oracle.ucp.jdbc.PoolDataSourceFactory"
	import="oracle.ucp.jdbc.PoolDataSource"
	import="com.aneesh.auditframework.DBConnectionPool"
	import="com.aneesh.auditframework.EncryptPassword"
	%>
<% Class.forName("oracle.jdbc.driver.OracleDriver"); %>
<HTML>
	<HEAD>
		<TITLE>Audit-Log Framework</TITLE>
		<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
	</HEAD>
	
	<BODY BGCOLOR="#CEF6F5">
		<H1 align="center">Service Activity Monitor</H1>
	    <%
			try{
				session.setAttribute("userAccessLevel", null);
				response.sendRedirect("Login.jsp");
			} catch(Exception e){
				System.out.println("Error in Logout.jsp");
				e.printStackTrace();
				response.sendRedirect("Login.jsp");
			}     
	    %>	
	</BODY>
</HTML>