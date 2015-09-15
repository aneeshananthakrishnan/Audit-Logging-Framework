<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="java.sql.*" import="java.util.*"%>
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
				position: fixed;
				top: 28%;
				left: 43%;
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
			function changePassword() {
				if (document.getElementById('oldPwd').value == "") {
					alert("Please enter old password !!");
					return false;
				}
				if (document.getElementById('newPwd').value == "") {
					alert("Please enter new password !!");
					return false;
				}
				if (document.getElementById('newPwdReEnt').value == "") {
					alert("Please re-enter new password !!");
					return false;
				}
				if (document.getElementById('newPwd').value != document
						.getElementById('newPwdReEnt').value) {
					alert("New password value does not match with re-enter value !!");
					return false;
				}
				document.forms.PasswordResetForm.submit();
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
	<div id="header">
		<H1 align="center" FACE="Times New Roman">iSAM (Interactive Service Activity Monitor)</H1>
	</div>
	<br>
	<br>
	<br>
	<br>
	<div id="header">
		<H2 align="center" FACE="Times New Roman">Password Reset Page</H2>
	</div>
	<br>
	<br>
	<div style="font-weight:bold; font-style: italic; font-size:20px; font-family:Times New Roman; color:#FF0000; text-align:center">${errorMessage} </div> 
	<div style="font-weight:bold; font-style: italic; font-size:20px; font-family:Times New Roman; color:#088A08; text-align:center">${logMessage} </div> 
	<br>
	<br>
	<form name="PasswordResetForm" action="UserMaintenanceServlet" method="post">
		<input type="hidden" name="action" value="resetPassword" />
		<div class="centerDiv" style="width: 13.5%; overflow: hidden; border-width: 2px; border-style: solid; border-color: #D73636; padding-top: .15cm; padding-left: .15cm; padding-right: .15cm; padding-bottom: .15cm;">
			<table>
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Old Password:</i></FONT></Strong></td>
				</tr>
				<tr>							
					<td align="right"><input type="password" name="oldPwd" id="oldPwd" style="width: 175px;"></td>
				</tr>
				<tr>
					<td></td>
				</tr>
				<tr>
					<td></td>
				</tr>	
				<tr>
					<td></td>
				</tr>		
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>New Password:</i></FONT></Strong></td>
				</tr>
				<tr>							
					<td align="right"><input type="password" name="newPwd" id="newPwd"
						style="width: 175px;"></td>
				</tr>
				<tr>
					<td></td>
				</tr>
				<tr>
					<td></td>
				</tr>	
				<tr>
					<td></td>
				</tr>								
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK
							FACE="Times New Roman" SIZE=3><i>Re-enter New Password:</i></FONT></Strong></td>
				</tr>
				<tr>							
					<td align="right"><input type="password" name="newPwdReEnt"
						id="newPwdReEnt" style="width: 175px;"></td>
				</tr>
			</table>
			<br>
			<div style='float: right'>
				<button type="button" name="submitButton" id="submitButton"
					onclick='return changePassword();'>
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Submit</i></FONT></Strong>
				</button>
			</div>		
		</div>
		<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
		<div style='padding-left: .5cm;'>
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