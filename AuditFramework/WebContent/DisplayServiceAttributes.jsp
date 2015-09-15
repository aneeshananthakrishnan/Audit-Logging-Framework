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
</style>
<script>
	var newRowAdded = false;
	function addNewTableRow() {
		try {
			if(newRowAdded == true){
				alert("Please save changes before adding the new row !!");
				return false;
			}
			
			<% 
			PoolDataSource dbConnectionPool	= null;									
			Connection dbConnection = null;
			Statement statement = null;
			ResultSet resultset = null;
			try{ 				
				dbConnectionPool	= DBConnectionPool.getDBConnection();									
				dbConnection = dbConnectionPool.getConnection();
				statement = dbConnection.createStatement() ;
	            String sql = "SELECT SRVC_NM FROM (SELECT SRVC_NM FROM SERVICE_NAMES_T MINUS SELECT DISTINCT SRVC_NM FROM SERVICE_ATTRIBUTES_T)";
	            resultset = statement.executeQuery(sql);
	            
	        	if(!resultset.isBeforeFirst()){
	        %>
	        	alert("No new Servive available to configure !!");
	        	return false;
			<%
	        	}
   		 	%>		
			var serviceListTable = document.getElementById("ServiceList");
			var currTableRowCnt = serviceListTable.rows.length;
			var newRow = serviceListTable.insertRow(-1);
			newRow.style.backgroundColor ="#FAFAFA";
			newRow.style.height = "25px";
	
			var delRow = newRow.insertCell(0);
			var delRowCheckBox = document.createElement("input");	
			delRowCheckBox.setAttribute("type", "checkbox");
			delRowCheckBox.setAttribute("name", "Row-"+currTableRowCnt+"_Col-0");
			delRowCheckBox.setAttribute("id", "Row-"+currTableRowCnt+"_Col-0");
			delRowCheckBox.setAttribute("value", "newRowDeleteNotSet");
			delRow.appendChild(delRowCheckBox);
			delRow.setAttribute("align", "center");

			var editRow = newRow.insertCell(1);
			editRow.setAttribute("align", "center");
			var editRowCheckBox = document.createElement("input");
			editRowCheckBox.setAttribute("type", "checkbox");
			editRowCheckBox.setAttribute("name", "Row-"+currTableRowCnt+"_Col-1");
			editRowCheckBox.setAttribute("id", "Row-"+currTableRowCnt+"_Col-1");
			editRowCheckBox.setAttribute("value", "newRowEditNotSet");
			editRowCheckBox.setAttribute("disabled", true);
			editRow.appendChild(editRowCheckBox);
      		 
			var srvcNmCol = newRow.insertCell(2);
			srvcNmCol.setAttribute("align", "center");
			var srvcNmColSelsrvcNm = document.createElement("select");
			srvcNmColSelsrvcNm.setAttribute("type", "select");
			srvcNmColSelsrvcNm.style.fontFamily = "Times New Roman";
			srvcNmColSelsrvcNm.style.fontSize = "15px";
			srvcNmColSelsrvcNm.style.width = "175px";
			srvcNmColSelsrvcNm.setAttribute("name", "Row-"+currTableRowCnt+"_Col-2");
			srvcNmColSelsrvcNm.setAttribute("id", "Row-"+currTableRowCnt+"_Col-2");			
			<% 
				while(resultset.next()){ 
			%>
			var srvcNmColSelsrvcNmOption = document.createElement("option");		
			srvcNmColSelsrvcNmOption.value = "<%= resultset.getString(1) %>";
			srvcNmColSelsrvcNmOption.text = "<%= resultset.getString(1) %>";
			srvcNmColSelsrvcNmOption.style.fontFamily = "Times New Roman";
			srvcNmColSelsrvcNmOption.style.fontSize = "15px";
			srvcNmColSelsrvcNm.appendChild(srvcNmColSelsrvcNmOption);
            <%
            	}
        	%>
        	srvcNmCol.appendChild(srvcNmColSelsrvcNm);
			
			for (i = 3; i < 20; i++) {
				var j = newRow.insertCell(i);
				if(i==7||i==8||i==9||i==12){
					var k = document.createElement('textarea');
					k.style.width = "245px";
					k.style.fontFamily = "Times New Roman";
					k.style.fontSize = "15px";
				}				
				else if(i==13){
					var k = document.createElement('textarea');
					k.style.width = "445px";
					k.style.fontFamily = "Times New Roman";
					k.style.fontSize = "15px";
				}
				else{
					var k = document.createElement('input');
					k.style.fontFamily = "Times New Roman";
					k.style.fontSize = "15px";
				}
				j.appendChild(k);
			}
			currTableRowCnt = currTableRowCnt + 1;
			newRowAdded = true;
		} catch (e) {
			alert(e);
		}
	}

	function saveModifications() {
		try{
			var serviceList = document.getElementById("ServiceList");
			
			var serviceListRowCnt = serviceList.rows.length;
			var tempInput = document.createElement("input");
			tempInput.setAttribute("type", "hidden");
			tempInput.setAttribute("name", "serviceListRowCnt");
			tempInput.setAttribute("id", "serviceListRowCnt");
			tempInput.setAttribute("value", serviceListRowCnt);
			document.getElementById("ServiceAttributesForm").appendChild(tempInput);	
			
			var serviceListColCnt = serviceList.rows[1].cells.length;
			var tempInput1 = document.createElement("input");
			tempInput1.setAttribute("type", "hidden");
			tempInput1.setAttribute("name", "serviceListColCnt");
			tempInput1.setAttribute("id", "serviceListColCnt");
			tempInput1.setAttribute("value", serviceListColCnt);
			document.getElementById("ServiceAttributesForm").appendChild(tempInput1);	
	
			for (i = 1; i < serviceListRowCnt; i++) {
				for (j = 0; j < serviceListColCnt; j++) {
					if(j >= 2 && (document.getElementById("ServiceList").rows[i].cells[j].children[0].value == '') && (document.getElementById("Row-"+ i +"_Col-0").value != "setRowToDelete") && (document.getElementById("Row-"+ i +"_Col-1").value != "existingRowEditSet")){
						alert("Please fill-in values for all the columns. If not applicable, please fill-in 'N/A'  !! ");
						return false;
					}
					var tempInput = document.createElement("input");
					tempInput.setAttribute("type", "hidden");
					tempInput.setAttribute("name", "Row-" + i + "_Col-" + j);
					tempInput.setAttribute("id", "Row-" + i + "_Col-" + j);
					if(((document.getElementById("Row-" + i + "_Col-0").value == "existingRowDeleteNotSet") ||  (document.getElementById("Row-" + i + "_Col-0").value == "setRowToDelete")) && (document.getElementById("Row-" + i + "_Col-1").value == "existingRowEditNotSet")){
						tempInput.setAttribute("value", trim(document.getElementById("ServiceList").rows[i].cells.item(j).innerText));
						//alert(document.getElementById("ServiceList").rows[i].cells.item(j).innerText);
					}
					else{
						tempInput.setAttribute("value", document.getElementById("ServiceList").rows[i].cells[j].children[0].value);
					}
					document.getElementById("ServiceAttributesForm").appendChild(tempInput);				
				}		
			}
			document.forms.ServiceAttributesForm.submit();
		} catch (e) {
			alert(e);
		}
	}

	function trim(string)
	{
	   return string.replace(/^[\s]+/,'').replace(/[\s]+$/,'');
	}	
	
	function deleteTableRows() {
		try {
			var serviceList = document.getElementById("ServiceList");
			var rowCnt = serviceList.rows.length;
			for (var i = 1; i < rowCnt; i++) {
				var row = serviceList.rows[i];
				var checkBox = row.cells[0].childNodes[0];
				if (document.getElementById("Row-"+i+"_Col-0").checked == true) {					
					serviceList.rows[i].style.display = "none";
					var x = document.getElementById("Row-"+ i +"_Col-0");
					x.setAttribute("value", "setRowToDelete");
				}
			}
		} catch (e) {
			alert(e);
		}
	}


	function disableEditCheckbox(i) {
		try {
			var x = document.getElementById("Row-"+i+"_Col-0").checked;
			if (x == true) {
				document.getElementById("Row-"+ i +"_Col-1").setAttribute("disabled", true);
			}
			if (x == false){
				document.getElementById("Row-"+ i +"_Col-1").removeAttribute("disabled");
			}
		} catch (e) {
			alert(e);
		}
	}		
	
	var existingRowAlreadyEdited = ";";
	function enableRowForEdit(i) {
		try {
			var serviceList = document.getElementById("ServiceList");
			var serviceListRowCnt = serviceList.rows.length;
			var serviceListColCnt = serviceList.rows[1].cells.length;	
			var x = document.getElementById("Row-"+ i +"_Col-1").checked;
			if (x == true && existingRowAlreadyEdited.indexOf(";"+ i + ";") == -1) {
				for (j = 2; j < serviceListColCnt; j++) {		
						if(j==4){
							var tempInput = document.createElement('textarea');
							tempInput.style.width = "450px";
							tempInput.style.fontFamily = "Times New Roman";
							tempInput.style.fontSize = "13px";
							tempInput.value = document.getElementById("ServiceList").rows[i].cells.item(j).innerText;
						}	
						else if(j==8||j==13){
							var tempInput = document.createElement('textarea');
							tempInput.style.width = "400px";
							tempInput.style.fontFamily = "Times New Roman";
							tempInput.style.fontSize = "13px";
							tempInput.value = document.getElementById("ServiceList").rows[i].cells.item(j).innerText;
						}	
						else if(j==9||j==10){
							var tempInput = document.createElement('textarea');
							tempInput.style.width = "245px";
							tempInput.style.fontFamily = "Times New Roman";
							tempInput.style.fontSize = "13px";
							tempInput.value = document.getElementById("ServiceList").rows[i].cells.item(j).innerText;
						}				
						else if(j==14){
							var tempInput = document.createElement('textarea');
							tempInput.style.width = "445px";
							tempInput.style.fontFamily = "Times New Roman";
							tempInput.style.fontSize = "13px";
							tempInput.value = document.getElementById("ServiceList").rows[i].cells.item(j).innerText;
						}
						else{
							var tempInput = document.createElement('input');
							tempInput.setAttribute("value", document.getElementById("ServiceList").rows[i].cells.item(j).innerText);
							tempInput.style.fontFamily = "Times New Roman";
							tempInput.style.fontSize = "13px";
							if(j==2){
								tempInput.setAttribute("disabled", true);
								tempInput.style.width = "175px";
							}
						}
					document.getElementById("ServiceList").rows[i].cells.item(j).innerHTML = '';
					document.getElementById("ServiceList").rows[i].cells[j].appendChild(tempInput);		
				}	
				var x = document.getElementById("Row-"+ i +"_Col-1");
				x.setAttribute("value", "existingRowEditSet");	
				existingRowAlreadyEdited = existingRowAlreadyEdited + i + ";";
				document.getElementById("Row-"+ i +"_Col-0").setAttribute("disabled", true);
			}
			if (x == true && existingRowAlreadyEdited.indexOf(";"+ i + ";") != -1) {
				document.getElementById("Row-"+ i +"_Col-0").setAttribute("disabled", true);
			}
			if (x == false){
				document.getElementById("Row-"+ i +"_Col-0").removeAttribute("disabled");
			}			
		} catch (e) {
			alert(e);
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
	<br>
	<div id="header">
		<H2 align="center" FACE="Times New Roman">Service Attribute Details</H2>
	</div>
	<br>
	<br>
	<div style="font-weight: bold; font-style: italic; font-size: 20px; font-family: Times New Roman; color: #FF0000; text-align: center">${errorMessage}</div>
	<form name="ServiceAttributesForm" id="ServiceAttributesForm" action="ServiceAttributesMaintenanceServlet" method="post">
		<br>
		<br>
		<br>
		<br>
		<div id="header">
			<table>
				<tr>
			        <td>
			        	<button type="button" name="AddNewEntry" onclick='return addNewTableRow();'><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Add Service</i></FONT></Strong></button>
	    			</td>
	    			<td>
	    			&nbsp;&nbsp;
			        	<button type="button" name="deleteTableRow" onclick='return deleteTableRows();'><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Delete Service</i></FONT></Strong></button>
	    			</td>
	    		    <td>
	    		    &nbsp;&nbsp;
			        	<button type="button" name="saveMods" onclick='return saveModifications();'><Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Save Changes</i></FONT></Strong></button>
	    			</td>
	    		    <td>
	    		    &nbsp;&nbsp;
			        	<button type="button" name="discardChanges" onclick="window.location.reload();"> <Strong><FONT COLOR=BLACK FACE="Times New Roman" SIZE=4><i>Discard Changes</i></FONT></Strong></button>
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
				            &nbsp;&nbsp;
							<a href="javascript:void(0)" onClick="confirmLogOut();"><Strong><FONT COLOR=#0000FF FACE="Times New Roman" SIZE=3><i>Logout</i></FONT></Strong></a>
						    <br>
						</div>
			        </td>
		        </tr>
	    	</table>
	    </div>	
		<br> <br> <br> <br> <br>
			<%
				sql = "SELECT SRVC_NM, APPL_NM, IIBNODE_DETS, MSGFLOW_NM, SRC_TYPE, SRC_NM, trim(SRC_DETS), XFM_WS_DETS, XFM_DB_DETS, TGT_TYPE, TGT_NM, TGT_DETS, ADDNL_DETS, SRCH_KY_1_NM,  SRCH_KY_2_NM, SRCH_KY_3_NM, SRCH_KY_4_NM, SRCH_KY_5_NM FROM SERVICE_ATTRIBUTES_T";
				//System.out.println(sql);
				resultset = statement.executeQuery(sql);
			%>		
		<TABLE class="sortable" BORDER="1" width=4250 BORDERCOLOR="#100719"
			style="border-collapse: collapse; border-width: 2px;"
			id="ServiceList">
			<TR BGCOLOR="#E6E6E6">
				<TH class="sorttable_nosort"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>DELETE</FONT></TH>
				<TH class="sorttable_nosort"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>EDIT</FONT></TH>
				<TH width=180><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SERVICE NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>APPLICATION NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>IIB NODE DETAILS</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>MESSAGE FLOW NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SOURCE TYPE</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SOURCE NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SOURCE DETAILS</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>XFM WEBSERVICE DETAILS</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>XFM DATABASE DETAILS</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>TARGET TYPE</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>TARGET NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>TARGET DETAILS</FONT></TH>
				<TH width=450><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>ADDITIONAL DETAILS OF THE SERVICE</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH KEY 1 - NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH KEY 2 - NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH KEY 3 - NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH KEY 4 - NAME</FONT></TH>
				<TH><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>SEARCH KEY 5 - NAME</FONT></TH>
			</TR>
			<%
				int i = 1;
				while (resultset.next()) {
			%>
			<TR BGCOLOR="#FAFAFA">
				<TD align="center"><input type='checkbox' name='Row-<%=i%>_Col-0' id='Row-<%=i%>_Col-0' value='existingRowDeleteNotSet' onclick="disableEditCheckbox(<%=i%>)" /> 
				<input type='hidden' name='Row-<%=i%>_Col-0' id='Row-<%=i%>_Col-0' value='existingRowDeleteNotSet' /></TD>
				<TD align="center"><input type='checkbox' name='Row-<%=i%>_Col-1' id='Row-<%=i%>_Col-1' value='existingRowEditNotSet' onclick="enableRowForEdit(<%=i%>)" />
				<input type='hidden' name='Row-<%=i%>_Col-1' id='Row-<%=i%>_Col-1' value='existingRowEditNotSet' /></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%=resultset.getString(1)%></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2> <%
				 	if (resultset.getString(2) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(2)%><%
				 	}
				 %>
				</FONT></TD>	
				<TD align="center" style="white-space: pre;"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				 	if (resultset.getString(3) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(3)%><%
				 	}
				 %></FONT></TD>			
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2> <%
				 	if (resultset.getString(4) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(4)%><%
				 	}
				 %>
				</FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				 if (resultset.getString(5) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(5)%><%
				 	}
				 %></FONT></TD>
				<TD align="center" style="white-space: pre;"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(6) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(6)%><%
				 	}
				 %></FONT></TD>
 				<TD align="center" style="white-space: pre;"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(7) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(7)%><%
				 	}
				 %></FONT></TD>
				<TD align="center" style="white-space: pre;"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(8) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(8)%><%
				 	}
				 %></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(9) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(9)%><%
				 	}
				 %></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2> <%
				if (resultset.getString(10) == null) {
				 %><%=""%><%
				 	} else {
				 %><%=resultset.getString(10)%><%
				 	}
				 %></FONT></TD>
				<TD align="center" style="white-space: pre;"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(11) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(11)%><%
					}
				%></FONT></TD>
				<TD align="center" style="white-space: pre;"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(12) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(12)%><%
					}
				%></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(13) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(13)%><%
					}
				%></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(14) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(14)%><%
					}
				%></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(15) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(15)%><%
					}
				%></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(16) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(16)%><%
					}
				%></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(17) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(17)%><%
					}
				%></FONT></TD>
				<TD align="center"><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%
				if (resultset.getString(18) == null) {
				%><%=""%><%
					} else {
				%><%=resultset.getString(18)%><%
					}
				%></FONT></TD>
			</TR>
			<%
				i = i + 1;
				}
				} catch(Exception e){
					e.printStackTrace();
					System.out.println("Error in DisplayServiceAttributes.jsp");
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
	</form>
	<br>
	<div id="footer">
		<p class="padding">
			<Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong>
		</p>
	</div>
</BODY>
</HTML>