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
		<script>
			function enterLoginCreds() {
				document.forms.EnterLoginCreds.submit();
			}
		</script>
        <style type="text/css">
			#footer {
			   position:fixed;
			   bottom:0;
			   width:99%;
			   background:#8181F7;
			   text-align: right;
			}
			p.padding {
			    padding-right: .5cm;
			}
		</style>		
	</HEAD>
	
	<BODY BGCOLOR="#CEF6F5">
		<H1 align="center">Service Activity Monitor</H1>
	    <%
		PoolDataSource dbConnectionPool	= null;									
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultset = null;
		try{
	        String userName=request.getParameter("UserName");
	        String password=request.getParameter("Password");
			dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement() ;
	        String sql = "SELECT  PASSWORD, ACCESS_LVL, PWD_RESET_REQD FROM USER_CREDS_T WHERE USER_NM = '" + userName + "'";
	        resultset = statement.executeQuery(sql);

        	if(!resultset.isBeforeFirst()){
        		request.setAttribute("errorMessage", "User ID is not set-up. Please contact Admin !!");
        		request.getRequestDispatcher("/Login.jsp").forward(request, response);
        	}
        	
            while(resultset.next()){
            	if(resultset.getString(1).equals(new EncryptPassword().getEncryptedPassword(password)) && resultset.getString(3).equals("N")){
            		session.setAttribute("userAccessLevel", resultset.getString(2));
            		session.setAttribute("UserName", request.getParameter("UserName"));
            		session.setAttribute("Password", request.getParameter("Password"));
            		request.getRequestDispatcher("/Index.jsp").forward(request, response);
            	}
            	else if(resultset.getString(1).equals(new EncryptPassword().getEncryptedPassword(password)) && resultset.getString(3).equals("Y")){
            		session.setAttribute("userAccessLevel", resultset.getString(2));
            		session.setAttribute("UserName", request.getParameter("UserName"));
            		session.setAttribute("Password", request.getParameter("Password"));
            		request.setAttribute("logMessage", "One-time password reset is required for new users !!");
            		request.getRequestDispatcher("/PasswordReset.jsp").forward(request, response);
            	}            	
            	else{
            		request.setAttribute("errorMessage", "Incorrect login credentials !!");
            		request.getRequestDispatcher("/Login.jsp").forward(request, response);
            	}
            }
		} catch(Exception e){
			e.printStackTrace();
			System.out.println("Error in ValidateLoginCreds.jsp");
		}
		finally{
			try{
				resultset.close();
				statement.close();
				dbConnection.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}       
	    %>	
	    <div id="footer"><p class="padding"><Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong></p></div>
	</BODY>
</HTML>