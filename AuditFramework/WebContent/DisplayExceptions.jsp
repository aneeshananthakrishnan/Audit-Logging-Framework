<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
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
		<script>
			function backToSearch() {
				window.location.href = "CaptureUserInputSearchParams.jsp?SearchType=ExceptionDetails";
				return false;
			}
		</script>
		<script>
			function openPayLoadforTxnId(control) {
				window.open("DisplayPayload.jsp?SearchType=ExceptionDetails&txn_id="
						+ control.innerText);
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
		<script type="text/javascript">
			function getExceptionRows() {
				var x = document.getElementById('selectrowsdropdown');
				var selRows = x.options[x.selectedIndex].value;
				var rowCountsStr;

				if(selRows == 1){
					 rowCountsStr = "startRowNum=1&endRowNum=250";
				} else if(selRows == 2){
				 rowCountsStr = "startRowNum=251&endRowNum=500";
				} else if (selRows == 3) {
				 rowCountsStr = "startRowNum=501&endRowNum=750";
				} else if (selRows == 4) {
				 rowCountsStr = "startRowNum=751&endRowNum=1000";
				} else if (selRows == 5) {
				 rowCountsStr = "startRowNum=1001&endRowNum=1250";
				} else if (selRows == 6) {
				 rowCountsStr = "startRowNum=1251&endRowNum=1500";
				} else if (selRows == 7) {
				 rowCountsStr = "startRowNum=1501&endRowNum=1750";
				} else if (selRows == 8) {
				 rowCountsStr = "startRowNum=1751&endRowNum=2000";
				} else if (selRows == 9) {
				 rowCountsStr = "startRowNum=2001&endRowNum=2250";
				} else if (selRows == 10) {
					 rowCountsStr = "startRowNum=2251&endRowNum=2500";
				} else{
				 	return false;
				}
				    
				var getSearchKeyNameUrl = "./SearchAuditAndExceptionDBServlet?action=GetExceptionList&" +  rowCountsStr;		
				var searchCriteria = document.getElementById('searchCriteria').value;
				getSearchKeyNameUrl = getSearchKeyNameUrl + "&searchCriteria=" + searchCriteria + "&srvcName=" + document.getElementById('srvcName').value;
			
				if (searchCriteria == "rKeyFields"){
					getSearchKeyNameUrl = getSearchKeyNameUrl 
											  + "&searchkey1=" + document.getElementById('searchkey1').value
											  + "&searchkey2=" + document.getElementById('searchkey2').value
											  + "&searchkey3=" + document.getElementById('searchkey3').value
											  + "&searchkey4=" + document.getElementById('searchkey4').value
											  + "&searchkey5=" + document.getElementById('searchkey5').value;		
				} else if (searchCriteria == "rDateRange"){
					getSearchKeyNameUrl = getSearchKeyNameUrl 
											  + "&dpStartDate=" + document.getElementById('dpStartDate').value
											  + "&dpStartTime=" + document.getElementById('dpStartTime').value
											  + "&dpEndDate=" + document.getElementById('dpEndDate').value
											  + "&dpEndTime=" + document.getElementById('dpEndTime').value;	
				} else {
					getSearchKeyNameUrl = getSearchKeyNameUrl 
											  + "&searchkey1=" + document.getElementById('searchkey1').value
											  + "&searchkey2=" + document.getElementById('searchkey2').value
											  + "&searchkey3=" + document.getElementById('searchkey3').value
											  + "&searchkey4=" + document.getElementById('searchkey4').value
											  + "&searchkey5=" + document.getElementById('searchkey5').value
											  + "&dpStartDate=" + document.getElementById('dpStartDate').value
											  + "&dpStartTime=" + document.getElementById('dpStartTime').value
											  + "&dpEndDate=" + document.getElementById('dpEndDate').value
											  + "&dpEndTime=" + document.getElementById('dpEndTime').value;						
				}

				var ajaxHttpReq;
				
				if (window.XMLHttpRequest) {
				 	ajaxHttpReq=new XMLHttpRequest();
				} 
				else {
					ajaxHttpReq=new ActiveXObject("Microsoft.XMLHTTP");
				}
				
				var ExceptionList = document.getElementById("ExceptionList");
				var ExceptionListRowCnt = ExceptionList.rows.length;
				
				for (var i = 1; i < ExceptionListRowCnt; i++) {
					ExceptionList.deleteRow(1);
				}
				
				
				ajaxHttpReq.onreadystatechange = function() {
					if (ajaxHttpReq.readyState == 4 && ajaxHttpReq.status == 200) {
				 		var resJSON = JSON.parse(ajaxHttpReq.responseText);
						var resJSONRowCnt = resJSON.exceptionHeader.length;
				 		for (var i = 0; i < resJSON.exceptionHeader.length; i++) {
				 		    var exceptionRow = resJSON.exceptionHeader[i];
				 		   	var newRow = ExceptionList.insertRow(-1);
							newRow.style.height = "22px";
							newRow.style.backgroundColor ="#FAFAFA";
							
						
							var k = newRow.insertCell(0);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.ROW_NUM;
							
							var k = newRow.insertCell(1);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							var a = document.createElement('a');
							a.href = "#";
							a.innerText = exceptionRow.MSG_ID;
							a.onclick = function() { openPayLoadforMsgId(this); };
							k.appendChild(a);
							
							var k = newRow.insertCell(2);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.SERVICE_NM;
														
							var k = newRow.insertCell(3);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.SEARCH_KEY_1;
														
							var k = newRow.insertCell(4);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (exceptionRow.SEARCH_KEY_2 != null){
								k.innerText = exceptionRow.SEARCH_KEY_2;
							}
							
							var k = newRow.insertCell(5);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (exceptionRow.SEARCH_KEY_3 != null){
								k.innerText = exceptionRow.SEARCH_KEY_3;
							}
							
							var k = newRow.insertCell(6);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (exceptionRow.SEARCH_KEY_4 != null){
								k.innerText = exceptionRow.SEARCH_KEY_4;
							}
							
							var k = newRow.insertCell(7);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (exceptionRow.SEARCH_KEY_5 != null){
								k.innerText = exceptionRow.SEARCH_KEY_5;
							}
							
							var k = newRow.insertCell(8);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.CREATE_TIMESTAMP;
														
							var k = newRow.insertCell(9);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.ERROR_CD;
														
							var k = newRow.insertCell(10);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.ERROR_MSG;
														
							var k = newRow.insertCell(11);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.BRKR_NAME;
														
							var k = newRow.insertCell(12);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.EG_NAME;
														
							var k = newRow.insertCell(13);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.MSGFLOW_NM;
														
							var k = newRow.insertCell(14);	
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.NODE_NM;
														
							var k = newRow.insertCell(15);	
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = exceptionRow.TRANSACTION_ID.trim();
				 		}		
					}
				}
				
				ajaxHttpReq.open("GET", getSearchKeyNameUrl, true);
				ajaxHttpReq.send();
			}
		</script>		
		<script>
			function openPayLoadforMsgId(control) {
				<%			
				PoolDataSource dbConnectionPool	= null;									
				Connection dbConnection = null;
				Statement statement = null;
				ResultSet resultset = null;
				try{ 		            
					dbConnectionPool	= DBConnectionPool.getDBConnection();									
					dbConnection = dbConnectionPool.getConnection();
					statement = dbConnection.createStatement() ;
			        String sql = "SELECT ACCESS_LVL FROM SERVICE_NAMES_T WHERE SRVC_NM = '"+ request.getAttribute("srvcName") +"'";
			        resultset = statement.executeQuery(sql);
			        int srcAccessLvl = 0;
			        if(resultset.next()) {
			        	  srcAccessLvl = Integer.parseInt(resultset.getString(1));
			        }
			    	if (srcAccessLvl > Integer.parseInt(session.getAttribute("userAccessLevel").toString())) {
		    	%>
			    	alert("Insufficient privilege to view payload !!")
			    	return false;
				<%
			    	}
			} catch(Exception e){
				e.printStackTrace();
				System.out.println("Error in DisplayExceptions.jsp");
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
				window.open("DisplayPayload.jsp?SearchType=ExceptionDetails&msg_id="
						+ control.innerText);
			}
		</script>
		<style type="text/css">
			#footer {
				position: fixed;
				bottom: 0;
				width: 99%;
				background:#3333FF;
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
			.fontSettings{
			   background-color: #F3F3F3;
		       font-size: 18px;
   			   font-family: 'Times New Roman';
   			   font-weight: bold;
   			   font-style: italic;
			}
		</style>
</HEAD>

<BODY BGCOLOR="#CCEBFF">
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
	<div id="header">
		<H2 align="center" FACE="Times New Roman">Exception List</H2>
	</div>
	<br>
	<br>
	<br>
	<br>
		<div id="header">
			<table>
				<tr>
			        <td>
						<button type="button" name="backToSearch"
							onclick='return backToSearch();'>
							<Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Back
										To Search</i></FONT></Strong>
						</button>
			        </td>
			        <td align="right">
		       		&nbsp;
			        &nbsp;
		       			<select class="fontSettings" name="selectrowsdropdown"  id="selectrowsdropdown" style="width: 160px; height: 27px;" onChange="getExceptionRows()">
							<option value=1 selected>Rows: 1-250</option>
							<option value=2 >Rows: 251-500</option>
							<option value=3 >Rows: 501-750</option>
							<option value=4 >Rows: 751-1000</option>
							<option value=5 >Rows: 1001-1250</option>
							<option value=6 >Rows: 1251-1500</option>
							<option value=7 >Rows: 1501-1750</option>
							<option value=8 >Rows: 1751-2000</option>
							<option value=9 >Rows: 2001-2250</option>
							<option value=10 >Rows: 2251-2500</option>
						</select>
					</td> 	
		        </tr>
		       	<tr>
			        <td>
				        <div>
				        <br>
							<a href=Index.jsp><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Go back to Index </i></FONT></Strong></a>
							<br>
						</div>
			        </td>
			       	<td>
				        <div>
				            <br>
							<a href="javascript:void(0)" onClick="confirmLogOut();"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Logout</i></FONT></Strong></a>
						    <br>
						</div>
			        </td>			        
		        </tr>
	        </table>	
	     </div>									
        <br>
	    <br>
        <br>
        <br>
	    <br> 
	<div style="overflow-x: scroll; height:370px;">
	<TABLE class="sortable" BORDER="1" width=2500 BORDERCOLOR="#100719"
		style="border-collapse: collapse; border-width: 2px;"
		id="ExceptionList">
		<TR BGCOLOR="#E6E6E6">
			<TH>
			    <input type='hidden' name='searchCriteria' id='searchCriteria' value=<%=request.getAttribute("searchCriteria").toString().trim()%> />	 
                <input type='hidden' name='srvcName' id='srvcName' value=<%=request.getAttribute("srvcName").toString().trim()%> />	
            	<input type='hidden' name='searchkey1' id='searchkey1' value=<%=request.getAttribute("searchkey1").toString().trim()%>/> 
            	<input type='hidden' name='searchkey2' id='searchkey2' value=<%=request.getAttribute("searchkey2").toString().trim()%> />
            	<input type='hidden' name='searchkey3' id='searchkey3' value=<%=request.getAttribute("searchkey3").toString().trim()%> />
            	<input type='hidden' name='searchkey4' id='searchkey4' value=<%=request.getAttribute("searchkey4").toString().trim()%> />
            	<input type='hidden' name='searchkey5' id='searchkey5' value=<%=request.getAttribute("searchkey5").toString().trim()%> />
            	<input type='hidden' name='dpStartDate' id='dpStartDate' value=<%=request.getAttribute("dpStartDate").toString().trim()%> /> 
            	<input type='hidden' name='dpStartTime' id='dpStartTime' value=<%=request.getAttribute("dpStartTime").toString().trim()%> /> 
            	<input type='hidden' name='dpEndDate' id='dpEndDate' value=<%=request.getAttribute("dpEndDate").toString().trim()%> /> 
            	<input type='hidden' name='dpEndTime' id='dpEndTime' value=<%=request.getAttribute("dpEndTime").toString().trim()%> /> 
				<FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ROW_NUM</FONT>
			</TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>MSG_ID</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SERVICE_NM</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH_KEY_1</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH_KEY_2</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH_KEY_3</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH_KEY_4</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH_KEY_5</FONT></TH>
			<TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>CREATE_TIMESTAMP</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ERROR_CD</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ERROR_MSG</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>BRKR_NAME</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>EG_NAME</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>MSGFLOW_NM</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>NODE_NM</FONT></TH>
			<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>TRANSACTION_ID</FONT></TH>
		</TR>
		<c:forEach items="${resultSet}" var="resultset">
			<TR BGCOLOR="#FAFAFA">
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.ROW_NUM} </FONT></TD>			
				<TD align="center"><FONT COLOR=BLACK
					FACE="Times New Roman" SIZE=2> <a href="#"
						onClick="openPayLoadforMsgId(this);">${resultset.MSG_ID}</a></FONT></td>			
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.SERVICE_NM}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.SEARCH_KEY_1}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.SEARCH_KEY_2}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.SEARCH_KEY_3}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.SEARCH_KEY_4}</FONT></td>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.SEARCH_KEY_5}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" 
				    SIZE=2>${resultset.CREATE_TIMESTAMP}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.ERROR_CD}</FONT></td>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.ERROR_MSG}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.BRKR_NAME}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.EG_NAME}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.MSGFLOW_NM}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman"
					SIZE=2>${resultset.NODE_NM}</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" 
					SIZE=2>${resultset.TRANSACTION_ID}</FONT></td>
			</TR>
		</c:forEach>
	</TABLE>
	</div>  
	<div id="footer"> <p class="padding"> <Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong> </p> </div>
</BODY>
</HTML>