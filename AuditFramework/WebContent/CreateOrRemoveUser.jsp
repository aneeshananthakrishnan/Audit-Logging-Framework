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
				border: #D8D8D8 7.5px solid;
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
			function createUserId() {
				if (document.getElementById('newUserId').value == '') {
					alert("Please enter user id !!");
					return false;
				}
				if (document.getElementById('initPwd').value == '') {
					alert("Please enter password !!");
					return false;
				}
				document.forms.CreateNewUserForm.submit();
			}
			
			function deleteUserId() {
				document.forms.DeleteUserForm.submit();
			}
			
			function updateUserAcess() {
				document.forms.UpdateUserAccessForm.submit();
			}
			
			function enableFormForEdit() {
				var radios = document.getElementsByName("radioCreateOrRemoveUser");
				for (var i = 0; i < radios.length; i++) {
					if (radios[i].checked) {
						var checked_value = radios[i].value;
						if (checked_value == 'createUser') {
							document.getElementById('newUserId').disabled = false;
							document.getElementById('initPwd').disabled = false;
							document.getElementById('accessLevelDropdown').disabled = false;
							document.getElementById('submitCrtUserButton').disabled = false;
							
							document.getElementById('userIdDropdown').disabled = true;
							document.getElementById('submitDelUserButton').disabled = true;
							
							document.getElementById('userIdDropdown1').disabled = true;
							document.getElementById('accessLevelDropdown1').disabled = true;
							document.getElementById('submitUpdtUserAccessButton').disabled = true;
						}
						else if (checked_value == 'removeUser'){
							document.getElementById('newUserId').disabled = true;
							document.getElementById('initPwd').disabled = true;
							document.getElementById('accessLevelDropdown').disabled = true;
							document.getElementById('submitCrtUserButton').disabled = true;
							
							document.getElementById('userIdDropdown').disabled = false;
							document.getElementById('submitDelUserButton').disabled = false;
							
							document.getElementById('userIdDropdown1').disabled = true;
							document.getElementById('accessLevelDropdown1').disabled = true;
							document.getElementById('submitUpdtUserAccessButton').disabled = true;							
						}
						else{
							document.getElementById('userIdDropdown1').disabled = false;
							document.getElementById('accessLevelDropdown1').disabled = false;
							document.getElementById('submitUpdtUserAccessButton').disabled = false;							
							
							document.getElementById('newUserId').disabled = true;
							document.getElementById('initPwd').disabled = true;
							document.getElementById('accessLevelDropdown').disabled = true;
							document.getElementById('submitCrtUserButton').disabled = true;
							
							document.getElementById('userIdDropdown').disabled = true;
							document.getElementById('submitDelUserButton').disabled = true;
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
	<br>
	<br>
	<br>
	<div id="header">
		<H2 align="center" FACE="Times New Roman">Create/Update/Delete Users</H2>
	</div>
	<br>
	<br>
	<br>
	<div style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #FF0000; text-align: center">${errorMessage}</div>
	<div style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #088A08; text-align: center">${logMessage}</div>
	<br>
	<div align="center">
		<input type='radio' name='radioCreateOrRemoveUser' id='createUser' value='createUser' onclick="enableFormForEdit()" /><i><Strong>Create User</Strong></i>
		<input type='radio' name='radioCreateOrRemoveUser' id='removeUser' value='removeUser' onclick="enableFormForEdit()" /><i><Strong>Remove User</Strong></i>
		<input type='radio' name='radioCreateOrRemoveUser' id='updateUserAccess' value='updateUserAccess' onclick="enableFormForEdit()" /><i><Strong>Update User Access</Strong></i>
	</div>
	<br>
	<form autocomplete="off" name="CreateNewUserForm" action="UserMaintenanceServlet" method="post">
		<input type="text" style='display: none'>
		<input type="password" style='display: none'>
		<input type="hidden" name="action" value="createUser" />
		<div class="centerDiv" style="width: 20.5%; overflow: hidden; border-width: 2px; border-style: solid; border-color: #D73636; padding-top: .15cm; padding-left: .15cm; padding-right: .15cm; padding-bottom: .15cm;">
			<table>
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>User Id:</i></FONT></Strong></td>
					<td align="right"><input type="text" name="newUserId" id="newUserId" value="" style="width: 175px;" disabled="disabled"></td>
				</tr>
				<tr><td></td></tr>
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Password:</i></FONT></Strong></td>
					<td align="right"><input type="password" name="initPwd" id="initPwd" value="" style="width: 175px;" disabled="disabled"></td>
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
				<button type="button" name="submitCrtUserButton" id="submitCrtUserButton"
					onclick='return createUserId();' disabled="disabled">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Create</i></FONT></Strong>
				</button>
			</div>
		</div>
	</form>
	<br><br><br><br><br><br><br><br>
	<form autocomplete="off" name="DeleteUserForm" action="UserMaintenanceServlet" method="post">
		<input type="text" style='display: none'>
		<input type="password" style='display: none'>
		<input type="hidden" name="action" value="deleteUser" />
		<div class="centerDiv" style="width: 20.5%; overflow: hidden; border-width: 2px; border-style: solid; border-color: #D73636; padding-top: .15cm; padding-left: .15cm; padding-right: .15cm; padding-bottom: .15cm;">
			<table>
		        <%
				PoolDataSource dbConnectionPool	= null;									
				Connection dbConnection = null;
				Statement statement = null;
				ResultSet resultset = null;
				try{
					dbConnectionPool	= DBConnectionPool.getDBConnection();									
					dbConnection = dbConnectionPool.getConnection();
					statement = dbConnection.createStatement() ;
		            String sql = "SELECT DISTINCT USER_NM FROM USER_CREDS_T ORDER BY USER_NM";
		            resultset = statement.executeQuery(sql);
		        %>					
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>User ID:</i></FONT></Strong></td>
					<td align="left"><select name="userIdDropdown" id="userIdDropdown" style="width: 150px;" disabled="disabled">						
							<% while(resultset.next()){ %>
								<option value=<%= resultset.getString(1) %>><%= resultset.getString(1) %></option>
				            <% }%>
						</select>
					</td>
				</tr>
				<tr><td></td></tr>
			</table>
			<div style='float: right'>
				<button type="button" name="submitDelUserButton" id="submitDelUserButton" onclick='return deleteUserId();' disabled="disabled">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Delete</i></FONT></Strong>
				</button>
			</div>
		</div>
		<br><br><br><br><br>
	</form>
	<form autocomplete="off" name="UpdateUserAccessForm" action="UserMaintenanceServlet" method="post">
		<input type="text" style='display: none'>
		<input type="password" style='display: none'>
		<input type="hidden" name="action" value="updateUserAccess" />
		<div class="centerDiv" style="width: 20.5%; overflow: hidden; border-width: 2px; border-style: solid; border-color: #D73636; padding-top: .15cm; padding-left: .15cm; padding-right: .15cm; padding-bottom: .15cm;">
			<table>
		        <%
		            sql = "SELECT DISTINCT USER_NM FROM USER_CREDS_T ORDER BY USER_NM";
		            resultset = statement.executeQuery(sql);
		        %>					
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>User ID:</i></FONT></Strong></td>
					<td align="left"><select name="userIdDropdown1" id="userIdDropdown1" style="width: 150px;" disabled="disabled">						
							<% while(resultset.next()){ %>
								<option value=<%= resultset.getString(1) %>><%= resultset.getString(1) %></option>
				            <% }
						} catch(Exception e){
							e.printStackTrace();
							System.out.println("Error in CreateOrRemoveUser.jsp");
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
				<tr><td></td></tr>
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Access Level:</i></FONT></Strong></td>
					<td align="left"><select name="accessLevelDropdown1" id="accessLevelDropdown1" style="width: 35px;" disabled="disabled">
							<option value=1 selected="selected">1</option>
							<option value=2>2</option>
							<option value=3>3</option>
							<option value=4>4</option>
					</select></td>
				</tr>					
				</tr>
				<tr><td></td></tr>
			</table>
			<div style='float: right'>
				<button type="button" name="submitUpdtUserAccessButton" id="submitUpdtUserAccessButton" onclick='return updateUserAcess();' disabled="disabled">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Update</i></FONT></Strong>
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