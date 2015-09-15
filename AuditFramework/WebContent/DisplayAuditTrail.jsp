<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" 
	import="java.sql.*" 
	import="java.util.*"
	import="javax.naming.Context" 
	import="javax.naming.InitialContext"
	import="oracle.ucp.jdbc.PoolDataSourceFactory"
	import="oracle.ucp.jdbc.PoolDataSource"
	import="com.aneesh.auditframework.DBConnectionPool"
	import="com.aneesh.auditframework.EventPointData"
%>

<HTML>
    <HEAD>
        <TITLE>Audit-Log Framework</TITLE>  
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <script type="text/javascript" src="resources/js/sorttable.js"></script> 
        
        
	    <script>
	        function back2Search()
	        {	
	        	window.location.href = "CaptureUserInputSearchParams.jsp?SearchType=AuditTrail";
	        	return false;
	        }	
		</script>

	    <script>
	        function setColor()
	        {	
	        	var AuditTrailListRowCnt = document.getElementById("AuditTrailList").rows.length;
	        	var AuditTrailListColCnt = document.getElementById("AuditTrailList").rows[1].cells.length;
	        	
				for (i = 1; i < AuditTrailListRowCnt; i++) {
					for (j = 0; j < AuditTrailListColCnt; j++) {
			        	if(document.getElementById("AuditTrailList").rows[i].cells.item(3).innerText == "FAIL"){
			        		document.getElementById("AuditTrailList").rows[i].cells[j].children[0].style.color = "#DF0101";
			        	}
			        	else {
			        		document.getElementById("AuditTrailList").rows[i].cells[j].children[0].style.color = "#000000";
			        	}						
					}
				}
	        }	
	        
	        window.onload = setColor;
		</script>
		
		<script>
			function openPayLoad(control)
			{
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
			    	alert("Insufficient privilege to view payload !!");
			    	return false;
				<%
			    	}
			 	%>					
				window.open("DisplayPayload.jsp?SearchType=AuditTrail&txn_id="+control.innerText);
			}
		</script>	
		<script>
			function refreshAuditTrailPage()
			{
				location.reload(true);
			}
		</script>		
		<script>
			function submitRequeueReq()
			{
				var auditTrailList = document.getElementById("AuditTrailList");
				var auditTrailListRowCnt = auditTrailList.rows.length;
 			    var postReqParams = "&srvcNm=" + document.getElementById("Row-1_Col-5").value;
 			    
				var txnIds = '';
				var i = 0;
				var iCount = 0;
				for (var i = 1; i < auditTrailListRowCnt; i++) {
					if(document.getElementById("Row-" + i +"_Col-1").value == "requeueSet"){
						txnIds = txnIds + "'" + document.getElementById("Row-" + i +"_Col-3").value + "',";
						iCount = iCount + 1;
					}
				}
				
				var userInput = confirm(iCount + " rows selected for re-queue. Please confirm !!");
				if (userInput == false) {
					return false;
				}
				
				if(txnIds == ''){
					alert("No transactions selected for Re-Queue !!");
					return false;
				}
				
				if(i > 200){
					alert("Please limit number of transactions selected to Re-Queue to 200 or less !!");
					return false;
				}

				if (txnIds.indexOf(",", txnIds.length - 1) !== -1){
					txnIds = txnIds.substring(0, txnIds.length - 1);
				}
				
				postReqParams = postReqParams + "&txnIds=" + txnIds;
				var getSearchKeyNameUrl = "./RequeueServlet";
				var ajaxHttpReq;
				
				if (window.XMLHttpRequest) {
				 	ajaxHttpReq=new XMLHttpRequest();
				} 
				else {
					ajaxHttpReq=new ActiveXObject("Microsoft.XMLHTTP");
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
						for (var i = 1; i < auditTrailListRowCnt; i++) {
							document.getElementById("Row-" + i +"_Col-1").value = "requeueNotSet";
							document.getElementById("Row-"+ i +"_Col-1_CB").checked = false;
						}
						document.getElementById("requeueAll_CB").checked = false;
				   }
				}
				
				ajaxHttpReq.open("POST", getSearchKeyNameUrl, true);
				ajaxHttpReq.setRequestHeader("Content-type","application/x-www-form-urlencoded")
				ajaxHttpReq.send(postReqParams);
			}
		</script>
		<script>
			function setTxnToRequeue(control)
			{
				var x = control.id;
				var y = x.substring(0, x.length - 3);
				var z = document.getElementById(x).checked;
				if (z == true){
					 document.getElementById(y).value = 'requeueSet';
				}
			}
		</script>	
		<script>
			function setAllTxnToRequeue()
			{
				var auditTrailList = document.getElementById("AuditTrailList");
				var auditTrailListRowCnt = auditTrailList.rows.length;
				if(document.getElementById("requeueAll_CB").checked == true){
					for (var i = 1; i < auditTrailListRowCnt; i++) {
						document.getElementById("Row-" + i +"_Col-1").value = "requeueSet";
						document.getElementById("Row-" + i +"_Col-1_CB").checked = true;
					}
				}
				else{
					for (var i = 1; i < auditTrailListRowCnt; i++) {
						document.getElementById("Row-" + i +"_Col-1").value = "requeueNotSet";
						document.getElementById("Row-" + i +"_Col-1_CB").checked = false;
					}
				}
			}
		</script>	
		<script type="text/javascript">
			function getAudTrlRows() {
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
				    
				var getSearchKeyNameUrl = "./SearchAuditAndExceptionDBServlet?action=GetAuditTrail&" +  rowCountsStr;		
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
				
				var auditTrailList = document.getElementById("AuditTrailList");
				var auditTrailListRowCnt = auditTrailList.rows.length;
				
				for (var i = 1; i < auditTrailListRowCnt; i++) {
					auditTrailList.deleteRow(1);
				}
				
				
				ajaxHttpReq.onreadystatechange = function() {
					if (ajaxHttpReq.readyState == 4 && ajaxHttpReq.status == 200) {
						document.getElementById("resMessage").innerText = "";
				 		var resJSON = JSON.parse(ajaxHttpReq.responseText);
						var resJSONRowCnt = resJSON.audTrailHeader.length;
				 		for (var i = 0; i < resJSON.audTrailHeader.length; i++) {
							var x = i + 1;
							
				 		    var audTrailRow = resJSON.audTrailHeader[i];
				 		   	var newRow = auditTrailList.insertRow(-1);
							newRow.style.height = "22px";
							newRow.style.backgroundColor ="#FAFAFA";
							
							var reQueue = newRow.insertCell(0);
							var reQueueCheckBox = document.createElement("input");	
							reQueueCheckBox.setAttribute("type", "checkbox");
							reQueueCheckBox.setAttribute("name", "Row-" + x + "_Col-1_CB");
							reQueueCheckBox.setAttribute("id", "Row-" + x + "_Col-1_CB");
							reQueueCheckBox.setAttribute("value", "requeueNotSet");
							reQueueCheckBox.onclick = function() { setTxnToRequeue(this); };
							reQueue.appendChild(reQueueCheckBox);
							reQueue.setAttribute("align", "center");
							
							var reQueueIpHidden = document.createElement("input");	
							reQueueIpHidden.setAttribute("type", "hidden");
							reQueueIpHidden.setAttribute("name", "Row-" + x + "_Col-1");
							reQueueIpHidden.setAttribute("id", "Row-" + x + "_Col-1");
							reQueueIpHidden.setAttribute("value", "requeueNotSet");
							reQueue.appendChild(reQueueIpHidden);
							
							var k = newRow.insertCell(1);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.ROW_NUM;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
							
							var k = newRow.insertCell(2);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							var a = document.createElement('a');
							a.href = "#";
							a.innerText = audTrailRow.TRANSACTION_ID;
							a.onclick = function() { openPayLoad(this); };
							k.appendChild(a);
							
							var txnIdHidden = document.createElement("input");	
							txnIdHidden.setAttribute("type", "hidden");
							txnIdHidden.setAttribute("name", "Row-" + x + "_Col-3");
							txnIdHidden.setAttribute("id", "Row-" + x + "_Col-3");
							txnIdHidden.setAttribute("value", audTrailRow.TRANSACTION_ID);
							k.appendChild(txnIdHidden);
							
							var k = newRow.insertCell(3);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.STATUS;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(4);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.SERVICE_NM;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
							
							var srvcNmHidden = document.createElement("input");	
							srvcNmHidden.setAttribute("type", "hidden");
							srvcNmHidden.setAttribute("name", "Row-" + x + "_Col-5");
							srvcNmHidden.setAttribute("id", "Row-" + x + "_Col-5");
							srvcNmHidden.setAttribute("value", audTrailRow.SERVICE_NM);
							k.appendChild(srvcNmHidden);
														
							var k = newRow.insertCell(5);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (audTrailRow.SEARCH_KEY_1 != null){
								k.innerText = audTrailRow.SEARCH_KEY_1;
							}
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
							
							var k = newRow.insertCell(6);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (audTrailRow.SEARCH_KEY_2 != null){
								k.innerText = audTrailRow.SEARCH_KEY_2;
							}
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
							
							var k = newRow.insertCell(7);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (audTrailRow.SEARCH_KEY_3 != null){
								k.innerText = audTrailRow.SEARCH_KEY_3;
							}
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
							
							var k = newRow.insertCell(8);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (audTrailRow.SEARCH_KEY_4 != null){
								k.innerText = audTrailRow.SEARCH_KEY_4;
							}
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
							
							var k = newRow.insertCell(9);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							if (audTrailRow.SEARCH_KEY_5 != null){
								k.innerText = audTrailRow.SEARCH_KEY_5;
							}
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(10);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.BRKR_NAME;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(11);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.EG_NAME;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(12);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.MSGFLOW_NM;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(13);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.NODE_NM;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(14);
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.START_TIME;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(15);	
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.END_TIME;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
														
							var k = newRow.insertCell(16);	
							k.style.fontFamily = "Times New Roman";
							k.style.fontSize = "13px";
							k.setAttribute("align", "center");
							k.innerText = audTrailRow.ELAPSED_TIME;
							if (audTrailRow.STATUS == "FAIL"){
								k.style.color = "#DF0101";
							}
				 		}		
					}
				}
				
				ajaxHttpReq.open("GET", getSearchKeyNameUrl, true);
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
			   position:fixed;
			   bottom:0;
			   width:99%;
			   background:#3333FF;
			   text-align: right;
			}
			p.padding {
			    padding-right: .5cm;
			}
			#header {
			   position:fixed;
			   width:99%;
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
			if (session.getAttribute("userAccessLevel") == null){
				response.sendRedirect("Login.jsp");
			}
		%>
	<div id="header">
		<H1 align="center" FACE="Times New Roman">iSAM (Interactive Service Activity Monitor)</H1>
	</div>
	<br>
	<br>
	<div id="header">
		<H2 align="center" FACE="Times New Roman">Audit Trail List</H2>
	</div>
	<br>
	<br>
	<div id="header">	
		<div style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; text-align: center" id="resMessage">  </div>	
	</div>
	<br>
	<br>			
		<div id="header">
			<table>
				<tr>
			        <td>
			        	<button type="button" name="backToSearch" onclick='return back2Search();' ><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Back To Search</i></FONT></Strong></button>
			        </td>
			        <td>
			         	&nbsp;&nbsp;
			        	<button type="button" name="submitForRequeue" onclick='return submitRequeueReq();' ><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Re-Queue</i></FONT></Strong></button>
		       		</td>
			        <td>
			         	&nbsp;&nbsp;
			        	<button type="button" name="refreshPage" onclick='return refreshAuditTrailPage();' ><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Refresh</i></FONT></Strong></button>
		       		</td>	
		       		<td align="right">
						&nbsp;&nbsp;
		       			<select class="fontSettings" name="selectrowsdropdown"  id="selectrowsdropdown" style="width: 160px; height: 27px;" onChange="getAudTrlRows()">
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
							<a href=Index.jsp><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Go back to Index</i></FONT></Strong></a>
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
        <TABLE class="sortable" BORDER="1" width=2125 BORDERCOLOR="#100719" style="border-collapse: collapse; border-width: 2px;" id="AuditTrailList" >
            <TR BGCOLOR="#E6E6E6"> 
            	<TH align="center">
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
		            	<FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>RE-QUEUE</FONT>
		            	<input type='checkbox' name='requeueAll_CB' id='requeueAll_CB' onclick="setAllTxnToRequeue()" />
		            	
				</TH>
            	<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ROW_NUM</FONT></TH>
                <TH width=275><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>TRANSACTION_ID</FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>STATUS</FONT></TH>     
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SERVICE_NM</FONT></TH>
                <%
    	        String srvcName = request.getAttribute("srvcName").toString();
                String sqlQueryString = null;
                if (!srvcName.equals("All")) {
                	sqlQueryString = "SELECT COALESCE(SRCH_KY_1_NM, 'N/A'), COALESCE(SRCH_KY_2_NM, 'N/A'), COALESCE(SRCH_KY_3_NM, 'N/A'), COALESCE(SRCH_KY_4_NM, 'N/A'), COALESCE(SRCH_KY_5_NM, 'N/A') FROM SERVICE_ATTRIBUTES_T WHERE SRVC_NM = '" + srvcName + "'";
                } else {
                	sqlQueryString = "SELECT 'SEARCH_KEY_1' AS SEARCH_KEY_1, 'SEARCH_KEY_2' AS SEARCH_KEY_2, 'SEARCH_KEY_3' AS SEARCH_KEY_3, 'SEARCH_KEY_4' AS SEARCH_KEY_4, 'SEARCH_KEY_5' AS SEARCH_KEY_5 FROM DUAL";
                }
    	        resultset = statement.executeQuery(sqlQueryString);
		        if(resultset.next()) {
		        %>	
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(1).trim()%></FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(2).trim()%></FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(3).trim()%></FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(4).trim()%></FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(5).trim()%></FONT></TH>
                <% } %>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>BRKR_NAME</FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>EG_NAME</FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>MSGFLOW_NM</FONT></TH>
				<TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>NODE_NM</FONT></TH>
                <TH width=175><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>START_TIME</FONT></TH>
                <TH width=175><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>END_TIME</FONT></TH>
                <TH ><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ELAPSED_TIME</FONT></TH>
                          
            </TR>
			<%
				int i = 1;
                List resultSet = (ArrayList)request.getAttribute("resultSet");
                Iterator<EventPointData> epdIterator = resultSet.iterator();
				while (epdIterator.hasNext()) {
					EventPointData eventPointData = epdIterator.next();
			%>      
			
	            <TR BGCOLOR="#FAFAFA"> 
	            	<TD align="center">
		            	<input type='checkbox' name='Row-<%=i%>_Col-1_CB' id='Row-<%=i%>_Col-1_CB' onclick="setTxnToRequeue(this)" />
		            	<input type='hidden' name='Row-<%=i%>_Col-1' id='Row-<%=i%>_Col-1' value='requeueNotSet' />
					</TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getROW_NUM() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getROW_NUM()%><%
																						 	} 
																						%></FONT></TD>     	  					
	                <TD align="center">
						<FONT COLOR=BLACK FACE="Times New Roman" SIZE=2> <a href="#" onClick="openPayLoad(this);"><%=eventPointData.getTRANSACTION_ID()%></a></FONT>
						<input type='hidden' name='Row-<%=i%>_Col-3' id='Row-<%=i%>_Col-3' value='<%=eventPointData.getTRANSACTION_ID()%>' />
	                </TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getSTATUS() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getSTATUS()%><%
																						 	} 
																						%></FONT></TD>     	                
	                <TD align="center">
	                	<FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=eventPointData.getSERVICE_NM()%></FONT>
	                	<input type='hidden' name='Row-<%=i%>_Col-5' id='Row-<%=i%>_Col-5' value='<%=eventPointData.getSERVICE_NM()%>' />
	                </TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getSEARCH_KEY_1() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getSEARCH_KEY_1()%><%
																						 	} 
																						%></FONT></TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getSEARCH_KEY_2() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getSEARCH_KEY_2()%><%
																						 	} 
																						%></FONT></TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getSEARCH_KEY_3() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getSEARCH_KEY_3()%><%
																						 	} 
																						%></FONT></td>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getSEARCH_KEY_4() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getSEARCH_KEY_4()%><%
																						 	} 
																						%></FONT></TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getSEARCH_KEY_5() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getSEARCH_KEY_5()%><%
																						 	} 
																						%></FONT></TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getBRKR_NAME() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getBRKR_NAME()%><%
																						 	} 
																						%></FONT></TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getEG_NAME() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getEG_NAME()%><%
																						 	} 
																						%></FONT></TD>
					<TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getMSGFLOW_NM() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getMSGFLOW_NM()%><%
																						 	} 
																						%></FONT></TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getNODE_NM() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getNODE_NM()%><%
																						 	} 
																						%></FONT></TD>  
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getSTART_TIME() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getSTART_TIME()%><%
																						 	} 
																						%></FONT></TD>  
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getEND_TIME() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getEND_TIME()%><%
																						 	} 
																						%></FONT></TD>
	                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><% if (eventPointData.getELAPSED_TIME() == null) {
																						 %><%=""%><%
																						 	} else {
																						 %><%=eventPointData.getELAPSED_TIME()%><%
																						 	} 
																						%></FONT></TD>                                                                                   
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
        <div id="footer"><p class="padding"><Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong></p></div>
    </BODY>
</HTML>