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
<script type="text/javascript" src="resources/js/sorttable.js"></script> 
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
			left: 34.5%;
			background-color: #D8D8D8
		}
		.centerDiv1 {
			position: absolute;
			left: 12.5%;
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
			function submitsetLogLvl() {
				
				var x = document.getElementById("msgFlowNameDropdown");
				var msgFlowNm = x.options[x.selectedIndex].value;
				var y = document.getElementById("loggingLevelDropdown");
				var logLevel = y.options[y.selectedIndex].value;
				
				var setLogLevelUrl = "./LoggingLevelServlet" ;
				
				var postReqParams = "&msgFlowNm=" + msgFlowNm + "&logLevel=" +  logLevel;
				
				var ajaxHttpReq;
				
				if (window.XMLHttpRequest) {
					ajaxHttpReq = new XMLHttpRequest();
				} else {
					ajaxHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
				}
		
				ajaxHttpReq.onreadystatechange = function() {
					if (ajaxHttpReq.readyState == 4 && ajaxHttpReq.status == 200) {
				 		var servletRes = ajaxHttpReq.responseText;
				 		document.getElementById("resMessage").innerText = servletRes;
				 		if(servletRes.indexOf("failed") != -1){
				 			document.getElementById("resMessage").style.color = '#FF0000';
				 		}
				 		else {
				 			document.getElementById("resMessage").style.color = '#088A08';
				 		}
					}
				}
				
				ajaxHttpReq.open("POST", setLogLevelUrl, true);
				ajaxHttpReq.setRequestHeader("Content-type","application/x-www-form-urlencoded")
				ajaxHttpReq.send(postReqParams);
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
		<H2 align="center" FACE="Times New Roman">Set/Update Message Flow Logging Level</H2>
	</div>
	<br><br><br>
	<div id="header">	
		<div style="font-weight: bold; font-style: italic; font-size: 18px; font-family: Times New Roman; text-align: center" id="resMessage">  </div>	
	</div>
	<br>
	<br>
	<form autocomplete="off" name="SetLoggingLevelForm" action="SetLoggingLevelServlet" method="post">
		<input type="text" style='display: none'>
		<input type="password" style='display: none'>
		<div class="centerDiv" style="width: 30%; overflow: hidden; border-width: 2px; border-style: solid; border-color: #D73636; padding-top: .15cm; padding-left: .15cm; padding-right: .15cm; padding-bottom: .15cm;">
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
		            String sql = "SELECT DISTINCT MSGFLOW_NM FROM SERVICE_ATTRIBUTES_T ORDER BY MSGFLOW_NM";
		            resultset = statement.executeQuery(sql);
		        %>		
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Message Flow Name:</i></FONT></Strong></td>
					<td align="left"><select name="msgFlowNameDropdown" id="msgFlowNameDropdown" style="width: 250px;">						
							<% while(resultset.next()){ %>
								<option value=<%=resultset.getString(1)%>><%=resultset.getString(1)%></option>
				            <%}%>
						</select>
					</td>
				</tr>
				<tr><td></td></tr>
				<tr>
					<td align="left"><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=3><i>Logging Level:</i></FONT></Strong></td>
					<td align="left"><select name="loggingLevelDropdown" id="loggingLevelDropdown" style="width: 80px;" >
							<option value=Low selected="selected">Low</option>
							<option value=Medium>Medium</option>
							<option value=High>High</option>
					</select></td>
				</tr>
				<tr><td></td></tr>
			</table>
			<div style='float: right'>
				<button type="button" name="submitsetLogLvlButton" id="submitsetLogLvlButton" onclick='return submitsetLogLvl();'>
					<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Set</i></FONT></Strong>
				</button>
			</div>
		</div>
			<br><br><br><br><br><br>		
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
		
		<div id="header">
			<H2 align="center" FACE="Times New Roman">Set-Logging-Level request status [Last 25 requests]</H2>
		</div>	
		<br><br><br><br>
	  <div class="centerDiv1" style="overflow-y: scroll; height:212px;">
        <TABLE class="sortable" BORDER="1" width=1000 BORDERCOLOR="#100719" style="border-collapse: collapse; border-width: 2px;" id="setLogLvlHistoryList" >
            <TR BGCOLOR="#E6E6E6"> 
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ROW_NUM</FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ACTION_TIMESTAMP</FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>USER_NM</FONT></TH>
				<TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ACTION_DESC</FONT></TH>                          
            </TR>
			<%
		        String sqlQueryString = "SELECT ACTION_TIMESTAMP, USER_NM, ACTION_DESC FROM AUDADM.USER_ACTIONS_HISTORY_T WHERE ROWNUM <= 25 ORDER BY ACTION_TIMESTAMP DESC";
		        resultset = statement.executeQuery(sqlQueryString);
		        int i = 1;
		        while(resultset.next()) {
			%>      
	            <TR BGCOLOR="#FAFAFA"> 
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=i%></FONT></TD>     	  					
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(1)%></FONT></TD>     	                
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(2)%></FONT></TD> 
	                <TD align="left"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(3)%></FONT></TD>   																						                                                                                
	            </TR>
			<%     
					i = i + 1;
				}
			} catch(Exception e){
				e.printStackTrace();
				System.out.println("Error in DisplayAuditTrail.jsp");
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
        </TABLE>
        </div>  
	</form>
	<div id="footer">
		<p class="padding">
			<Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong>
		</p>
	</div>
</BODY>
</HTML>