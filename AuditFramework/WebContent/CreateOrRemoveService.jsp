<%@ page language="java" 
	contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" 
	import="java.sql.*" 
	import="java.util.*"
	import="javax.naming.Context"
	import="javax.naming.InitialContext"
	import="oracle.ucp.jdbc.PoolDataSourceFactory"
	import="oracle.ucp.jdbc.PoolDataSource"
	import="com.aneesh.auditframework.DBConnectionPool"		
%>
<HTML>
<HEAD>
<TITLE>Audit-Log Framework</TITLE>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
		<style type="text/css">
		#footer {
			position: fixed;
			bottom: 0;
			width: 99%;
			background: #3333FF;
			text-align: right;
		}
		
		p.padding {
			padding-right: .5cm;
		}
		
		.centerDiv {
			position: absolute;
			left: 39%;
			background-color: #D8D8D8
		}
		</style>
		<script>
			function confirmLogOut() {
				var userInput = confirm("Confirm Logout?");
				if (userInput == true) {
					window.location.href = "Logout.jsp";
				}
			}		
		</script>
		<script>
			function createService() {
				if (document.getElementById('newServiceName').value == '') {
					alert("Please enter Service Name !!");
					return false;
				}
				document.forms.CreateNewServiceForm.submit();
			}
			
			function deleteService() {
				document.forms.DeleteServiceForm.submit();
			}
			
			function enableFormForEdit() {
				var radios = document.getElementsByName("radioCreateOrRemoveService");
				for (var i = 0; i < radios.length; i++) {
					if (radios[i].checked) {
						var checked_value = radios[i].value;
						if (checked_value == 'createService') {
							document.getElementById('newServiceName').disabled = false;
							document.getElementById('accessLevelDropdown').disabled = false;
							document.getElementById('submitCrtSrvcButton').disabled = false;
							
							document.getElementById('serviceDropdown').disabled = true;
							document.getElementById('submitDelUserButton').disabled = true;
						}
						else{
							document.getElementById('newServiceName').disabled = true;
							document.getElementById('accessLevelDropdown').disabled = true;
							document.getElementById('submitCrtSrvcButton').disabled = true;
							
							document.getElementById('serviceDropdown').disabled = false;
							document.getElementById('submitDelUserButton').disabled = false;
						}
					}
				}
			}
		</script>
		<style type="text/css">
		#header {
				position: fixed;
				width: 99%;
				text-align: center;
			}
		</style>
</HEAD>

<BODY BGCOLOR="#CCEBFF">
   	<%
		if (session.getAttribute("userAccessLevel") == null){
			response.sendRedirect("Login.jsp");
		}
	%>
	<div id="header">
		<H1 align="center" FACE="Times New Roman">iSAM (Interactive Service Activity Monitor)</H1>
	</div>
	<br><br><br>
	<div id="header">
		<H2 align="center" FACE="Times New Roman">Register/Deregister Service</H2>
	</div>
	<br><br><br><br>
	<div style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #FF0000; text-align: center">${errorMessage}</div>
	<div style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #088A08; text-align: center">${logMessage}</div>
	<br>
	<div align="center">
		<input type='radio' name='radioCreateOrRemoveService' id='createService' value='createService' onclick="enableFormForEdit()" /><i><Strong>Register Service</Strong></i>
		<input type='radio' name='radioCreateOrRemoveService' id='removeService' value='removeService' onclick="enableFormForEdit()" /><i><Strong>Deregister Service</Strong></i>
	</div>
	<br><br>
	<form autocomplete="off" name="CreateNewServiceForm" action="ServiceMaintenanceServlet" method="post">
		<input type="text" style='display: none'>
		<input type="password" style='display: none'>
		<input type="hidden" name="action" value="createService" />
		<div class="centerDiv" style="width: 22.5%; overflow: hidden; border-width: 2px; border-style: solid; border-color: #D73636; padding-top: .15cm; padding-left: .15cm; padding-right: .15cm; padding-bottom: .15cm;">
			<table>
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Service Name:</i></FONT></Strong></td>
					<td align="right"><input type="text" name="newServiceName" id="newServiceName" value="" style="width: 175px;" disabled="disabled"></td>
				</tr>
				<tr><td></td></tr>
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Access Level:</i></FONT></Strong></td>
					<td align="left"><select name="accessLevelDropdown" id="accessLevelDropdown" style="width: 35px;" disabled="disabled">
							<option value=1 selected="selected">1</option>
							<option value=2>2</option>
							<option value=3>3</option>
							<option value=4>4</option>
					</select></td>
				</tr>
				<tr><td></td></tr>
			</table>
			<div style='float: right'>
				<button type="button" name="submitCrtSrvcButton" id="submitCrtSrvcButton"
					onclick='return createService();' disabled="disabled">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Register</i></FONT></Strong>
				</button>
			</div>
		</div>
	</form>
	<br><br><br><br><br><br><br>
	<form name="DeleteServiceForm" action="ServiceMaintenanceServlet" method="post">
		<input type="text" style='display: none'>
		<input type="password" style='display: none'>
		<input type="hidden" name="action" value="deleteService" />
		<div class="centerDiv" style="width: 22.5%; overflow: hidden; border-width: 2px; border-style: solid; border-color: #D73636; padding-top: .15cm; padding-left: .15cm; padding-right: .15cm; padding-bottom: .15cm;">
			<table>
		        <%
				PoolDataSource dbConnectionPool	= null;									
				Connection dbConnection = null;
				Statement statement = null;
				ResultSet resultset = null;
				try{
					dbConnectionPool = DBConnectionPool.getDBConnection();									
					dbConnection = dbConnectionPool.getConnection();
					statement = dbConnection.createStatement() ;
		            String sql = "SELECT DISTINCT SRVC_NM FROM SERVICE_NAMES_T ORDER BY SRVC_NM";
		            resultset = statement.executeQuery(sql);
		        %>					
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Service Name:</i></FONT></Strong></td>
					<td align="left"><select name="serviceDropdown" id="serviceDropdown" style="width: 175px;" disabled="disabled">						
							<% while(resultset.next()){ %>
								<option value=<%= resultset.getString(1) %>><%= resultset.getString(1) %></option>
				            <% }
						} catch(Exception e){
							e.printStackTrace();
							System.out.println("Error in CreateOrRemoveService.jsp");
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
						</select>
					</td>
				</tr>
				<tr><td></td></tr>
			</table>
			<div style='float: right'>
				<button type="button" name="submitDelUserButton" id="submitDelUserButton"
					onclick='return deleteService();' disabled="disabled">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Deregister</i></FONT></Strong>
				</button>
			</div>
		</div>
		<br><br><br><br><br><br>
		<div>
			<a href=Index.jsp><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Go back to Index </i></FONT></Strong></a>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="javascript:void(0)" onClick="confirmLogOut();"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Logout</i></FONT></Strong></a>
		</div>	
		
	</form>	
	<div id="footer">
		<p class="padding">
			<Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong>
		</p>
	</div>
</BODY>
</HTML>