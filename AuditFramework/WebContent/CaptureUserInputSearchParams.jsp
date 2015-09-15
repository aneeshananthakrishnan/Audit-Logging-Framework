<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" 
	import="java.sql.*" 
	import="java.util.*" 
	import="java.io.*" 
	import="javax.naming.Context"
	import="javax.naming.InitialContext"
	import="oracle.ucp.jdbc.PoolDataSourceFactory"
	import="oracle.ucp.jdbc.PoolDataSource"
	import="com.aneesh.auditframework.DBConnectionPool"	
%>
<% Class.forName("oracle.jdbc.driver.OracleDriver"); %>
<HTML>
	<HEAD>
		<TITLE>Audit-Log Framework</TITLE>
		<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
		<link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/smoothness/jquery-ui.css" rel="stylesheet" type="text/css" />
		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.js"></script>
		<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.js"></script>
		
		<script type="text/javascript">
		function getSearchKeyNames() {
		   var x = document.getElementById('servicenamedropdown');
		   var srvcName = x.options[x.selectedIndex].value;
		   
		   if (srvcName == "select" || srvcName == "All"){
			   document.getElementById("searchKeyList").rows[0].cells.item(0).innerText = "Search Key 1:";
			   document.getElementById("searchKeyList").rows[1].cells.item(0).innerText = "Search Key 2:";
			   document.getElementById("searchKeyList").rows[2].cells.item(0).innerText = "Search Key 3:";
			   document.getElementById("searchKeyList").rows[3].cells.item(0).innerText = "Search Key 4:";
			   document.getElementById("searchKeyList").rows[4].cells.item(0).innerText = "Search Key 5:";
			   return false;
		   }
		   
		   var getSearchKeyNameUrl = "./SearchAuditAndExceptionDBServlet?action=GetSearchKeyNames&srvcName=" + srvcName;
		   var ajaxHttpReq;
		   
		   if (window.XMLHttpRequest) {
			   ajaxHttpReq=new XMLHttpRequest();
		   } 
		   else {
			 ajaxHttpReq=new ActiveXObject("Microsoft.XMLHTTP");
		   }
	
		   ajaxHttpReq.onreadystatechange = function() {
			 if (ajaxHttpReq.readyState == 4 && ajaxHttpReq.status == 200) {
		   		var resJSON = JSON.parse(ajaxHttpReq.responseText);
	   			var sK1Nm = resJSON.searchKeyNm1;
	   			var sK2Nm = resJSON.searchKeyNm2;
	   			var sK3Nm = resJSON.searchKeyNm3;
	   			var sK4Nm = resJSON.searchKeyNm4;
	   			var sK5Nm = resJSON.searchKeyNm5;
	   			
				if(sK1Nm != "" && sK1Nm != null){
					 document.getElementById("searchKeyList").rows[0].cells.item(0).innerText = sK1Nm + ":";
				} else {
					document.getElementById("searchKeyList").rows[0].cells.item(0).innerText = "N/A:";
				}
				
				if(sK2Nm != "" && sK2Nm != null){
					 document.getElementById("searchKeyList").rows[1].cells.item(0).innerText = sK2Nm + ":";
				} else {
					document.getElementById("searchKeyList").rows[1].cells.item(0).innerText = "N/A:";
				}	
				
				if(sK3Nm != "" && sK3Nm != null){
					 document.getElementById("searchKeyList").rows[2].cells.item(0).innerText = sK3Nm + ":";
				} else {
					document.getElementById("searchKeyList").rows[2].cells.item(0).innerText = "N/A:";
				}	
				
				if(sK4Nm != "" && sK4Nm != null){
					 document.getElementById("searchKeyList").rows[3].cells.item(0).innerText = sK4Nm + ":";
				} else {
					document.getElementById("searchKeyList").rows[3].cells.item(0).innerText = "N/A:";
				}	
				
				if(sK5Nm != "" && sK5Nm != null){
					 document.getElementById("searchKeyList").rows[4].cells.item(0).innerText = sK5Nm + ":";
				} else {
					document.getElementById("searchKeyList").rows[4].cells.item(0).innerText = "N/A:";
				}			
		     }
		   }
		   
		   ajaxHttpReq.open("GET", getSearchKeyNameUrl, true);
		   ajaxHttpReq.send();
		}
		</script>
		<script>
			function displayAuditTrail() {
				
			   var x = document.getElementById('searchoptionsdropdown');
			   var srvcName = x.options[x.selectedIndex].value;
			   
			   if (srvcName == "select"){
				   alert("Please select a service to search !!")
				   return false;
			   }

			    var x = document.getElementById('searchoptionsdropdown');
			    var checked_value = x.options[x.selectedIndex].value;
			    
				if (checked_value == 'select') 
				{
					alert ( "Please select search criteria !!" );
					document.getElementById('dpStartDate').focus();
					return false;				
				}
				else if (checked_value == 'rGenSearchStr') 
				{
					if (document.getElementById('genSrchStr').value == "" ){
						alert ( "Please enter Generic Search String value !!" );
						document.getElementById('genSrchStr').focus();
						return false;
					}
				} 				
				else if (checked_value == 'rKeyFields') 
				{
					if (document.getElementById('searchkey1').value == "" 
							&& document.getElementById('searchkey2').value == "" 
								&& document.getElementById('searchkey3').value == ""
									&& document.getElementById('searchkey4').value == ""
										&& document.getElementById('searchkey5').value == "")
					{
						alert ( "Please enter Search Key values !!" );
						document.getElementById('searchkey1').focus();
						return false;
					}
				} 
				else if (checked_value == 'rDateRange') 
				{
					if (document.getElementById('dpStartDate').value == "" || document.getElementById('dpEndDate').value == "")
					{
						alert ( "Please enter Start & End Date values !!" );
						document.getElementsByName("radrioSearchAuditData").focus();
						return false;
					}						
				}
				else if ( checked_value == 'rDateRangeAndKeyFields'){
					if (document.getElementById('searchkey1').value == "" 
						&& document.getElementById('searchkey2').value == "" 
							&& document.getElementById('searchkey3').value == ""
								&& document.getElementById('searchkey4').value == ""
									&& document.getElementById('searchkey5').value == ""){
						alert ( "Please enter Search Key values !!" );
						document.getElementById('searchkey1').focus();
						return false;
					}						
					if (document.getElementById('dpStartDate').value == "" || document.getElementById('dpEndDate').value == "")
					{
						alert ( "Please enter Start & End Date values !!" );
						document.getElementsByName("radrioSearchAuditData").focus();
						return false;
					}						
				}	
				else {
					if (document.getElementById('genSrchStr').value == "")
					{
						alert ( "Please enter Search Key values !!" );
						document.getElementById('searchkey1').focus();
						return false;
					}						
					if (document.getElementById('dpStartDate').value == "" || document.getElementById('dpEndDate').value == "")
					{
						alert ( "Please enter Start & End Date values !!" );
						document.getElementsByName("radrioSearchAuditData").focus();
						return false;
					}						
				}		

				document.forms.SearchAuditDbForm.submit();
			}
		</script>
		<script>
			function enableFormForEdit() {		
			    var x = document.getElementById('searchoptionsdropdown');
			    var searchOption = x.options[x.selectedIndex].value;

				if (searchOption == 'rKeyFields') {
					document.getElementById('searchkey1').disabled = false;
					document.getElementById('searchkey2').disabled = false;
					document.getElementById('searchkey3').disabled = false;
					document.getElementById('searchkey4').disabled = false;
					document.getElementById('searchkey5').disabled = false;
					
					document.getElementById('genSrchStr').disabled = true;
					document.getElementById('dpStartDate').disabled = true;
					document.getElementById('dpStartTime').disabled = true;
					document.getElementById('dpEndDate').disabled = true;
					document.getElementById('dpEndTime').disabled = true;
					document.getElementById('dpEndTime').disabled = true;
				
				} else if (searchOption == 'rDateRange') {
					document.getElementById('searchkey1').disabled = true;
					document.getElementById('searchkey2').disabled = true;
					document.getElementById('searchkey3').disabled = true;
					document.getElementById('searchkey4').disabled = true;
					document.getElementById('searchkey5').disabled = true;
					document.getElementById('genSrchStr').disabled = true;

					document.getElementById('dpStartDate').disabled = false;
					document.getElementById('dpStartTime').disabled = false;
					document.getElementById('dpEndDate').disabled = false;
					document.getElementById('dpEndTime').disabled = false;
				}

				else if (searchOption == 'rGenSearchStr') {
					document.getElementById('searchkey1').disabled = true;
					document.getElementById('searchkey2').disabled = true;
					document.getElementById('searchkey3').disabled = true;
					document.getElementById('searchkey4').disabled = true;
					document.getElementById('searchkey5').disabled = true;
					document.getElementById('dpStartDate').disabled = true;
					document.getElementById('dpStartTime').disabled = true;
					document.getElementById('dpEndDate').disabled = true;
					document.getElementById('dpEndTime').disabled = true;
					
					document.getElementById('genSrchStr').disabled = false;
				}			
				
				else if (searchOption == 'rDateRangeAndKeyFields') {
					document.getElementById('searchkey1').disabled = false;
					document.getElementById('searchkey2').disabled = false;
					document.getElementById('searchkey3').disabled = false;
					document.getElementById('searchkey4').disabled = false;
					document.getElementById('searchkey5').disabled = false;
					document.getElementById('dpStartDate').disabled = false;
					document.getElementById('dpStartTime').disabled = false;
					document.getElementById('dpEndDate').disabled = false;
					document.getElementById('dpEndTime').disabled = false;
					
					document.getElementById('genSrchStr').disabled = true;
				}		
				
				else if (searchOption == 'rDateRangeAndGenSearchStr') {
					document.getElementById('searchkey1').disabled = true;
					document.getElementById('searchkey2').disabled = true;
					document.getElementById('searchkey3').disabled = true;
					document.getElementById('searchkey4').disabled = true;
					document.getElementById('searchkey5').disabled = true;
					
					document.getElementById('dpStartDate').disabled = false;
					document.getElementById('dpStartTime').disabled = false;
					document.getElementById('dpEndDate').disabled = false;
					document.getElementById('dpEndTime').disabled = false;
					document.getElementById('genSrchStr').disabled = false;
				}
				
				else {
					document.getElementById('searchkey1').disabled = true;
					document.getElementById('searchkey2').disabled = true;
					document.getElementById('searchkey3').disabled = true;
					document.getElementById('searchkey4').disabled = true;
					document.getElementById('searchkey5').disabled = true;
					
					document.getElementById('dpStartDate').disabled = true;
					document.getElementById('dpStartTime').disabled = true;
					document.getElementById('dpEndDate').disabled = true;
					document.getElementById('dpEndTime').disabled = true;
					document.getElementById('genSrchStr').disabled = true;
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
		<script>
			$(document).ready(function() {
				$("#dpStartDate").datepicker();
			});
		</script>
		<script>
			$(document).ready(function() {
				$("#dpEndDate").datepicker();
			});
		</script>
		<style type="text/css">
		.ui-datepicker {
			font-family: Times New Roman;
			font-size: 12px;
			margin-left: 10px
		}
		</style>
		<style type="text/css">
			#footer {
			   position:absolute;
			   bottom:0;
			   width:99%;
			   background: #3333FF;
			   text-align: right;
			}
			p.padding {
			    padding-right: .5cm;
			}
		</style>		
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
		<div id="header">
			<H2 align="center" FACE="Times New Roman">Enter Search Parameters</H2>
		</div>
		<div
			style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #088A08; text-align: center">${logMessage}
		</div>	
		<div
			style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #FF0000; text-align: center">${errorMessage}
		</div>	
		<br> 
		<br>	
		<form name="SearchAuditDbForm" action="SearchAuditAndExceptionDBServlet" method="post">
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
			            String sql = "SELECT DISTINCT SRVC_NM FROM SERVICE_ATTRIBUTES_T";
			            resultset = statement.executeQuery(sql);
			        %>					
					<tr>
						<td align="left"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><strong>Service Name:</strong></FONT></td>
						<td align="right"><select name="servicenamedropdown"  id="servicenamedropdown" style="width: 235px;" onChange="getSearchKeyNames()">
							<option value="select" selected>Select service</option>
							<option value="All">All</option>
							<% while(resultset.next()){ %>
								<option value=<%= resultset.getString(1) %>><%= resultset.getString(1) %></option>
				       		<% }
							} catch(Exception e){
								e.printStackTrace();
								System.out.println("Error in CaptureUserInputSearchParams.jsp");
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
						</select></td>
					</tr>
					<tr>
						<td align="left"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><strong>Search By:</strong></FONT></td>
						<td align="right">
							<select name="searchoptionsdropdown"  id="searchoptionsdropdown" style="width: 235px;" onChange="enableFormForEdit()">
								<option value="select" selected>Select search option</option>
								<option value="rKeyFields">Key fields</option>
								<option value="rGenSearchStr">Generic search string</option>
								<option value="rDateRange">Date range</option>
								<option value="rDateRangeAndKeyFields">Key fields & Date range</option>
								<option value="rDateRangeAndGenSearchStr">Generic search string & Date range</option>
							</select>
						</td>
					</tr>		
			</table>
			<br>
			<input type="hidden" name="SearchType" value="<%=SearchType%>" />
			<div style="width: 70%; overflow: hidden;">
				<div style='float: left'>
					<table id="searchKeyList">
						<tr>
							<td align="left" id="searchkey1NM">Search Key 1:</td>
							<td align="right"><input type="text" name="searchkey1" id="searchkey1" style="width: 175px;" disabled="disabled"></td>
						</tr>
						<tr>
							<td align="left" id="searchkey2NM">Search Key 2:</td>
							<td align="right"><input type="text" name="searchkey2" id="searchkey2" style="width: 175px;" disabled="disabled"></td>
						</tr>
						<tr>
							<td align="left" id="searchkey3NM">Search Key 3:</td>
							<td align="right"><input type="text" name="searchkey3" id="searchkey3" style="width: 175px;" disabled="disabled"></td>
						</tr>
						<tr>
							<td align="left" id="searchkey4NM">Search Key 4:</td>
							<td align="right"><input type="text" name="searchkey4" id="searchkey4" style="width: 175px;" disabled="disabled"></td>
						</tr>
						<tr>
							<td align="left" id="searchkey5NM">Search Key 5:</td>
							<td align="right"><input type="text" name="searchkey5" id="searchkey5" style="width: 175px;" disabled="disabled"></td>
						</tr>
					</table>
				</div>
				<div style='float: left'>
					<table>
						<tr>
							<td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Start Date:</td>
							<td align="left"><input type="text" name="dpStartDate" id="dpStartDate" style="width: 175px;" disabled="disabled"></td>
						</tr>	
						<tr>	
							<td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Start Time:</td>
							<td align="left"><input type="text" name="dpStartTime" id="dpStartTime" value="12:00:00" style="width: 175px;" disabled="disabled"></td>
						</tr>
						<tr><td>&nbsp;</td></tr>
						<tr>
							<td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;End Date:</td>
							<td align="left"><input type="text" name="dpEndDate" id="dpEndDate" style="width: 175px;" disabled="disabled"></td>
						</tr>	
						<tr>	
							<td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;End Time:</td>
							<td align="left"><input type="text" name="dpEndTime" id="dpEndTime" value="12:00:00" style="width: 175px;" disabled="disabled"></td>
						</tr>
					</table>
				</div>
				<br> <br> <br> <br> <br> <br> <br> <br>
				<div style='float: Left'>
					<table>
						<tr>
							<td align="left">Search String:</td>
							<td align="right"><input type="text" name="genSrchStr" id="genSrchStr" style="width: 175px;" disabled="disabled"></td>
						</tr>
					</table>
				</div>				
				<br><br>
				<div style='float: center'>
					<button type="button" name="SearchAuditDbButton" onclick='return displayAuditTrail();'><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Search</i></FONT></Strong></button>
				</div>
			</div>
		</form>
		<br>
		<div>
			<a href=Index.jsp><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Go back to Index </i></FONT></Strong></a>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="javascript:void(0)" onClick="confirmLogOut();"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Logout</i></FONT></Strong></a>
		</div>		
		<div id="footer"><p class="padding"><Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong></p></div>
	</BODY>
</HTML>