<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="java.sql.*" import="java.util.*"%>

<HTML>
	<HEAD>
		<TITLE>Audit-Log Framework</TITLE>
		<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
		<script>
			function enterLoginCreds() {
				if (document.getElementById('UserName').value == "" || document.getElementById('Password').value == "")
				{
					alert ( "Please enter login credentials !!" );
					document.getElementById("UserName").focus();
					return false;
				}				
				document.forms.EnterLoginCreds.submit();
			}
			
	
		</script>
		<style type="text/css">
			.centerDiv {
			    position: absolute;
			    top: 30%;
			    left: 39.5%;
			    width: 300px;
			    border-width: 2px;
			    border-style: solid;
			    border-color: #D73636;
			    background-color:#D8D8D8;
			}	
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
		</style>
	</HEAD>
	
	<BODY BGCOLOR="#CCEBFF" >
		<div id="header">
			<H1 align="center" FACE="Times New Roman">iSAM (Interactive Service Activity Monitor)</H1>
		</div>
		<br>
		<div id="header">
			<H2 align="center" FACE="Times New Roman">Welcome to Service Activity Monitor</H2>
		</div>
		<div
			style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #088A08; text-align: center">${logMessage}
		</div>			
		<form autocomplete="off" name="EnterLoginCreds" action="ValidateLoginCreds.jsp" method="post" >
			<input type="text" style='display: none'>
			<input type="password" style='display: none'>
			<div class="centerDiv" style="width: 20%; overflow: hidden; padding-right: .15cm; padding-bottom: .15cm; padding-left: .15cm; padding-top: .15cm;">
				<H3 align="center">Enter Log-in Credentials</H3>
				<div style="font-weight:bold; font-style: italic; font-size:15px; font-family:Times New Roman; color:#FF0000; text-align:left">${errorMessage} </div> 
				<table>
					<tr>
						<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>User Name:</i></FONT></Strong></td>
						<td align="right"><input type="text" id="UserName" name="UserName"></td>
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
						<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Password:</i></FONT></Strong></td>
						<td align="right"><input type="password" id="Password" name="Password"></td>
					</tr>	
					<tr>
						<td></td>
					</tr>		
					<tr>
						<td></td>
					</tr>	
				</table>
				<div style='float: right;' >
					<button  type="button" name="EnterLoginCreds" onclick='return enterLoginCreds();'><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Submit</i></FONT></Strong></button>
				</div>
				<br>
			</div>
		</form>    
		<div id="footer"><p class="padding"><Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong></p></div>
	</BODY>
</HTML>