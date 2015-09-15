<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="java.sql.*" import="java.util.*"
	import="javax.naming.Context" import="javax.naming.InitialContext"
	import="oracle.ucp.jdbc.PoolDataSourceFactory"
	import="oracle.ucp.jdbc.PoolDataSource"
	import="com.aneesh.auditframework.DBConnectionPool"
	import="com.aneesh.auditframework.EventPointData"%>

<HTML>
<HEAD>
<TITLE>Audit-Log Framework</TITLE>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
	<link
		href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/smoothness/jquery-ui.css"
		rel="stylesheet" type="text/css" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.js"></script>
	<script
		src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.js"></script>
	
	<script type="text/javascript">
		function getServiceMetrics() {
			
			//document.getElementById("resMessage").innerText = "";
			var x = document.getElementById('servicenamedropdown');
			var srvcNm = "";
			for(var i=0; i < x.options.length; i++){
				if(x.options[i].selected){
					if (srvcNm == ""){
						srvcNm = x.options[i].value;
					}
					else{
						srvcNm = x.options[i].value + "," + srvcNm;
					}
				}
			}

			var getServiceMetricsUrl = "./ServiceMetricsServlet?srvcNm=" + srvcNm;
			//alert(getServiceMetricsUrl);
			var x = document.getElementById('selectmetrictypedropdown');
			var metricType = x.options[x.selectedIndex].value;
			if ((document.getElementById('dpDate').value.trim() == "") && (metricType == "Hourly")){
				alert("Please enter value for the Date field !!")
				return false;
			}
			getServiceMetricsUrl = getServiceMetricsUrl + "&metricType=" + metricType + "&date=" + document.getElementById('dpDate').value;
			var ajaxHttpReq;
	
			if (window.XMLHttpRequest) {
				ajaxHttpReq = new XMLHttpRequest();
			} else {
				ajaxHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
			}
	
			var metricsList = document.getElementById("MetricsList");

			ajaxHttpReq.onreadystatechange = function() {
				if (ajaxHttpReq.readyState == 4 && ajaxHttpReq.status == 200) {
					
			 		//var servletRes = ajaxHttpReq.responseText;
			 		//if((servletRes != null) && (servletRes.indexOf("failed") != -1)){
			 			//document.getElementById("resMessage").innerText = servletRes;
			 			//document.getElementById("resMessage").style.color = '#FF0000';
			 		//}

					var metricsListRowCnt = metricsList.rows.length;
					for (var i = 0; i < metricsListRowCnt; i++) {
						metricsList.deleteRow(0);
					}
			 		
					var resJSON = JSON.parse(ajaxHttpReq.responseText);
					
					var iLen;
					if (srvcNm.indexOf(",") > 0){
						iLen = resJSON.metricsHeader.length;
					} else {
						iLen = 1;
					}

					if(iLen >= 1){
						var newRow = metricsList.insertRow(-1);
						newRow.style.height = "22px";
						
						var k = newRow.insertCell(0);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.setAttribute("align", "center");
						k.innerText = "SERVICE NAME";
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#E6E6E6";						
						//k.colSpan = "2";
					
						var k = newRow.insertCell(1);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.setAttribute("align", "center");
						k.innerText = "STATUS";
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#E6E6E6";
						
						var y;
						var resJSONRowCnt;
						if (srvcNm.indexOf(",") > 0){
							var metricRow = resJSON.metricsHeader[0];
							y = resJSON.metricsHeader[0].metricsPayload[1].recCounts.length;
						} else {
							var metricRow = resJSON.metricsHeader[0];
							y = resJSON.metricsHeader.metricsPayload[1].recCounts.length;
						}					

						for (var j = 0; j < y; j++) {
							var k = newRow.insertCell(j+2);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "14px";
							k.style.width = "75px";
							k.setAttribute("align", "center");
							k.style.fontWeight = "bold";
							k.style.backgroundColor ="#E6E6E6";
							if(metricType == "Hourly"){
								if(j + 1 != y){
									if (srvcNm.indexOf(",") > 0){
										k.innerText = resJSON.metricsHeader[0].metricsPayload[1].recCounts[j].METRIC_TIME + " - " 
														+ resJSON.metricsHeader[0].metricsPayload[1].recCounts[j+1].METRIC_TIME;
									} else {
										k.innerText = resJSON.metricsHeader.metricsPayload[1].recCounts[j].METRIC_TIME + " - " 
														+ resJSON.metricsHeader.metricsPayload[1].recCounts[j+1].METRIC_TIME;
									}	
								}
								else{
									if (srvcNm.indexOf(",") > 0){
										k.innerText = resJSON.metricsHeader[0].metricsPayload[1].recCounts[j].METRIC_TIME + " - 00";
									} else {
										k.innerText = resJSON.metricsHeader.metricsPayload[1].recCounts[j].METRIC_TIME + " - 00";
									}	
								}							
							} else {
								if (srvcNm.indexOf(",") > 0){
									k.innerText = resJSON.metricsHeader[0].metricsPayload[1].recCounts[j].METRIC_DATE;
								} else {
									k.innerText = resJSON.metricsHeader.metricsPayload[1].recCounts[j].METRIC_DATE;
								}
							}
						}
					}
								
					
					for (var i = 0; i < iLen; i++) {
						var newRow = metricsList.insertRow(-1);
						newRow.style.height = "22px";			
						var k = newRow.insertCell(0);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.style.width = "125px";
						k.setAttribute("align", "center");
						k.rowSpan = "3";
						if (srvcNm.indexOf(",") > 0){
							k.innerText = resJSON.metricsHeader[i].metricsPayload[0].SRVC_NM;
						} else {
							k.innerText = resJSON.metricsHeader.metricsPayload[0].SRVC_NM;
						}
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#E6E6E6";
						
						var y;
						if (srvcNm.indexOf(",") > 0) {
							y = resJSON.metricsHeader[i].metricsPayload[1].recCounts.length;
						} else {
							y = resJSON.metricsHeader.metricsPayload[1].recCounts.length;
						}

						var k = newRow.insertCell(1);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.style.color = "#04B404";
						k.style.width = "125px";
						k.setAttribute("align", "center");
						k.innerText = "SUCCESS";
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#FAFAFA";						
						for (var j = 0; j < y; j++) {
							var k = newRow.insertCell(j+2);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "14px";
							k.setAttribute("align", "center");
							if (srvcNm.indexOf(",") > 0) {
								k.innerText = resJSON.metricsHeader[i].metricsPayload[1].recCounts[j].SUCCESS_CNT;
							} else {
								k.innerText = resJSON.metricsHeader.metricsPayload[1].recCounts[j].SUCCESS_CNT;
							}
							k.style.backgroundColor ="#FAFAFA";
						}
						
						
						var newRow = metricsList.insertRow(-1);
						newRow.style.height = "22px";		
/*						
						var k = newRow.insertCell(0);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.style.width = "125px";
						k.setAttribute("align", "center");
						if (srvcNm.indexOf(",") > 0){
							k.innerText = resJSON.metricsHeader[i].metricsPayload[0].SRVC_NM;
						} else {
							k.innerText = resJSON.metricsHeader.metricsPayload[0].SRVC_NM;
						}
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#E6E6E6";	
*/						
						var k = newRow.insertCell(0);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.style.color = "#FF0000";
						k.style.width = "125px";
						k.setAttribute("align", "center");
						k.innerText = "FAIL";
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#FAFAFA";					
						for (var j = 0; j < y; j++) {
							var k = newRow.insertCell(j+1);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "14px";
							k.setAttribute("align", "center");
							if (srvcNm.indexOf(",") > 0) {
								k.innerText = resJSON.metricsHeader[i].metricsPayload[1].recCounts[j].FAIL_CNT;
							} else {
								k.innerText = resJSON.metricsHeader.metricsPayload[1].recCounts[j].FAIL_CNT;
							}
							k.style.backgroundColor ="#FAFAFA";
						}

						var newRow = metricsList.insertRow(-1);
/*						
						newRow.style.height = "22px";		
						var k = newRow.insertCell(0);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.style.width = "125px";
						k.setAttribute("align", "center");
						if (srvcNm.indexOf(",") > 0){
							k.innerText = resJSON.metricsHeader[i].metricsPayload[0].SRVC_NM;
						} else {
							k.innerText = resJSON.metricsHeader.metricsPayload[0].SRVC_NM;
						}
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#E6E6E6";			
*/						
						var k = newRow.insertCell(0);
						k.style.fontFamily = "Times New Roman";
						k.style.fontSize = "14px";
						k.style.width = "125px";
						k.setAttribute("align", "center");
						k.innerText = "TOTAL";
						k.style.fontWeight = "bold";
						k.style.backgroundColor ="#81BEF7";								
						for (var j = 0; j < y; j++) {
							var k = newRow.insertCell(j+1);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "14px";
							k.setAttribute("align", "center");
							if (srvcNm.indexOf(",") > 0) {
								k.innerText = resJSON.metricsHeader[i].metricsPayload[1].recCounts[j].TOTAL_CNT;
							} else {
								k.innerText = resJSON.metricsHeader.metricsPayload[1].recCounts[j].TOTAL_CNT;
							}
							k.style.backgroundColor ="#81BEF7";
							k.style.fontWeight = "bold";
						}
					}	
				}
			}

			ajaxHttpReq.open("GET", getServiceMetricsUrl, true);
			ajaxHttpReq.send();
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
	
	#header {
		position: fixed;
		width: 99%;
		text-align: center;
	}
	
	.ui-datepicker {
		font-family: Times New Roman;
		font-size: 12px;
		margin-left: 10px
	}
	</style>
	<script>
		$(document).ready(function() {
			$("#dpDate").datepicker();
		});
	</script>
	<script>
		function enabledpDate() {
			var x = document.getElementById('selectmetrictypedropdown');
			var selRows = x.options[x.selectedIndex].value;
			if(selRows == "Hourly"){
				document.getElementById('dpDate').disabled=false;
			}
			else{
				document.getElementById('dpDate').value = "";
				document.getElementById('dpDate').disabled=true;
			}
		}
	</script>	
</HEAD>

<BODY BGCOLOR="CCEBFF">
	<%
		if (session.getAttribute("userAccessLevel") == null) {
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
		<H2 align="center" FACE="Times New Roman">Service Metrics</H2>
	</div>
	<br>
	<br>
	<br>
	<br>
	<div id="header">
		<table>
			<tr>
				<td align="left">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Service Name:</i></FONT></Strong>
				</td>
				<td>
					<select size=3 multiple name="servicenamedropdown" id="servicenamedropdown" style="width: 175px; font-family: Times New Roman; font-size: 15px;">
						<option value="Combined" selected>All (Aggregated)</option>
						<%
							PoolDataSource dbConnectionPool = null;
							Connection dbConnection = null;
							Statement statement = null;
							ResultSet resultset = null;
							try {
								dbConnectionPool = DBConnectionPool.getDBConnection();
								dbConnection = dbConnectionPool.getConnection();
								statement = dbConnection.createStatement();
								String sql = "SELECT SRVC_NM FROM SERVICE_ATTRIBUTES_T";
								resultset = statement.executeQuery(sql);
								while (resultset.next()) {
						%>
						<option value=<%=resultset.getString(1)%>><%=resultset.getString(1)%></option>
						<%
							}
							} catch (Exception e) {
								e.printStackTrace();
								System.out.println("Error in CaptureUserInputSearchParams.jsp");
							} finally {
								try {
									resultset.close();
									statement.close();
									dbConnection.close();
								} catch (Exception e) {
									e.printStackTrace();
								}
							}
						%>
				</select> 
				</td>
				<td align="left">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Metrics Type:</i></FONT></Strong>
				</td>
				<td>
					<select name="selectmetrictypedropdown" id="selectmetrictypedropdown" 
						style="height:25px; width: 160px; font-family: Times New Roman; font-size: 15px;" onChange="enabledpDate()">
						<option value="Daily" selected>Daily (Last 14 Days)</option>
						<option value="Hourly">Hourly</option>
					</select>
				</td>
				<td align="left">
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date:</i></FONT></Strong>
				</td>
				<td>
					<input type="text" name="dpDate" id="dpDate" style="height:25px; width: 100px; font-family: Times New Roman; font-size: 15px;" disabled="disabled">
				</td>
				<td></td><td></td><td></td><td></td><td></td><td></td>
				<td>
					<button style="height:25px;" type="button" name="fetchMetricsButton" onclick='return getServiceMetrics();'><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Fetch Metrics</i></FONT></Strong></button>
				</td>
			</tr>
		</table>
		<br>	
		<table>
			<tr>
				<td>
					<a href=Index.jsp><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Go back to Index</i></FONT></Strong></a>
				</td>
				<td></td><td></td><td></td><td></td><td></td><td></td>
				<td>
					<a href="javascript:void(0)" onClick="confirmLogOut();"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Logout</i></FONT></Strong></a>
				</td>
			</tr>
		</table>
	</div>
	<br>
	<br>
	<br>
	<br>
	<br>	
	<br>
	<br>	
	<div>
		<TABLE BORDER="1" BORDERCOLOR="#100719" style="border-collapse: collapse; border-width: 2px;" id="MetricsList">
		</TABLE>
	</div>
	<div id="footer">
		<p class="padding">
			<Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong>
		</p>
	</div>
</BODY>
</HTML>