<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="java.sql.*" import="java.util.*"%>
<HTML>
	<HEAD>
		<TITLE>Audit-Log Framework</TITLE>
		<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>	
        <style type="text/css">
			#footer {
			   position:absolute;
			   bottom:0;
			   width:99%;
			   background:#3333FF;
			   text-align: right;
			}
			p.padding {
			    padding-right: .5cm;
			}

			.centerDiv {
			    position: absolute;
			    top: 26%;
			    left: 27.25%;
			    border-width: 2px;
			    background-color:#D8D8D8
			}		
			#header {
			   position:fixed;
			   width:99%;
			   text-align: center;
			}				
		</style>	
		<script type="text/javascript">
			function submitCreateOrDeleteUser(){
				var x = <%= session.getAttribute("userAccessLevel") %>;
				if ( x != '4'){
					alert("Insufficient access to create or remove users");
					return false;
				}
				else {
					window.location.href = "CreateOrRemoveUser.jsp";
				}
			}	
		</script>	
		<script type="text/javascript">
			function submitCreateOrDeleteService(){
				var x = <%= session.getAttribute("userAccessLevel") %>;
				if ( x != '4'){
					alert("Insufficient access to create or remove services");
					return false;
				}
				else {
					window.location.href = "CreateOrRemoveService.jsp";
				}
			}	
		</script>	
		<script>
			function confirmLogOut() {
				var userInput = confirm("Confirm Logout?");
				if (userInput == true) {
					window.location.href = "Logout.jsp";
				}
			}		
		</script>	
	</HEAD>
	
	<BODY BGCOLOR="CCEBFF">
		<%
			if (session.getAttribute("userAccessLevel") == null){
				response.sendRedirect("Login.jsp");
			}
			String SearchType = request.getParameter("SearchType");
		%>
		<div id="header">
			<H1 align="center" FACE="Times New Roman">iSAM (Interactive Service Activity Monitor)</H1>
		</div>
		<br>
		<br>
		<br>
		<div id="header">
			<H2 align="center" FACE="Times New Roman">Index</H2>
		</div>
		<br>
		<div
			style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #088A08; text-align: center">${logMessage}
		</div>		
		<div class="centerDiv" style="width: 44%; overflow: hidden; border-style: solid; border-color: #D73636; padding-top: .25cm; padding-left: .25cm; padding-right: .25cm; padding-bottom: .25cm;">
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>1. </i></FONT></Strong></a>
			<a href=PasswordReset.jsp> <Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Change password</i></FONT></Strong></a>
			<br>
			<br>
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>2. </i></FONT></Strong></a>
			<a href=DisplayServiceAttributes.jsp> <Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Service Attributes - CRUD</i></FONT></Strong></a>
			<br>
			<br>
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>3. </i></FONT></Strong></a>
			<a href="CaptureUserInputSearchParams.jsp?SearchType=ExceptionDetails"> <Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Search Exception Details </i></FONT></Strong></a>
			<br>
			<br>
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>4. </i></FONT></Strong></a>
			<a href="CaptureUserInputSearchParams.jsp?SearchType=AuditTrail"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Search Transaction Audit Trail </i></FONT></Strong></a>
			<br>
			<br>
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>5. </i></FONT></Strong></a>
			<a href="SetOrUpdateMFLoggingLevel.jsp"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Set/Update Message Flow Logging Level </i></FONT></Strong></a>
			<br>
			<br>			
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>6. </i></FONT></Strong></a>
			<a href="javascript:void(0);" onClick="submitCreateOrDeleteUser();"> <Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Create/Remove/Update a User (Admin Access Required)</i></FONT></Strong></a>
			<br>
			<br>
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>7. </i></FONT></Strong></a>
			<a href="javascript:void(0);" onClick="submitCreateOrDeleteService();"> <Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Register/Deregister a Service (Admin Access Required)</i></FONT></Strong></a>
			<br>
			<br>
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>8. </i></FONT></Strong></a>
			<a href=DisplayServiceMetrics.jsp> <Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Service Metrics</i></FONT></Strong></a>
			<br>
			<br>
			<a style="padding-right: .25cm"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>9. </i></FONT></Strong></a>
			<a href="javascript:void(0)" onClick="confirmLogOut();"> <Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=5><i>Logout</i></FONT></Strong></a>
		</div>
	    <div id="footer"><p class="padding"><Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong></p></div>
	</BODY>
</HTML>