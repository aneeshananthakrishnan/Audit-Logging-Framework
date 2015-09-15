<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" 
	import="org.apache.commons.lang.StringEscapeUtils" 
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
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
        <%
		PoolDataSource dbConnectionPool	= null;									
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultset = null;
		try{
			dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
			statement = dbConnection.createStatement() ;
            if (request.getParameter("SearchType").equals("AuditTrail")){
                String sql = "SELECT COUNTER, EVENT_SRC_ADDR, UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_DECODE(PAYLOAD)) FROM PAYLOAD_CLOB_T WHERE TRANSACTION_ID = '" + (String)request.getParameter("txn_id") + "' ORDER BY COUNTER";
                //System.out.println(sql);
                resultset = statement.executeQuery(sql);            	
            } else {
            	if (request.getParameter("msg_id") != null){
                    String sql = "SELECT COUNTER, 'N/A' AS EVENT_SRC_ADDR, UTL_RAW.CAST_TO_VARCHAR2(PAYLOAD) FROM PAYLOAD_CLOB_T WHERE TRANSACTION_ID = '" + (String)request.getParameter("msg_id") + "' ORDER BY COUNTER";
                    //System.out.println(sql);
                    resultset = statement.executeQuery(sql);                   		
            	} else {
                    String sql = "SELECT COUNTER, EVENT_SRC_ADDR, UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_DECODE(PAYLOAD)) FROM PAYLOAD_CLOB_T WHERE TRANSACTION_ID = '" + (String)request.getParameter("txn_id") + "' ORDER BY COUNTER";
                    //System.out.println(sql);
                    resultset = statement.executeQuery(sql);                   		
            	}
            }
        %>	
        <br><br><br><br>
        <TABLE BORDER="1" width=1200 BORDERCOLOR="#100719" style="border-collapse: collapse; border-width: 2px;" id="PayloadList" >
            <TR BGCOLOR="#E6E6E6">
                <TH width=100><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>COUNTER</FONT></TH>
                <TH width=200><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>EVENT_SRC_ADDR</FONT></TH>
                <TH width=900><FONT COLOR=BLACK FACE="Times New Roman" SIZE=2>PAYLOAD</FONT></TH>                           
            </TR>
            <% while(resultset.next()){ %>
            <TR BGCOLOR="#FAFAFA">
                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%= resultset.getString(1) %></FONT></td>
                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%= resultset.getString(2) %></FONT></td>
                <TD align="center"> <FONT COLOR=BLACK FACE="Times New Roman" SIZE=2><%= StringEscapeUtils.escapeXml(resultset.getString(3)) %></FONT></TD>                                                                                  
            </TR>
            <% }
		} catch(Exception e){
			e.printStackTrace();
			System.out.println("Error in DisplayPayload.jsp");
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
        <div id="footer"><p class="padding"><Strong><i>@ Aneesh Anand A. (Infosys Ltd.)</i></Strong></p></div>
    </BODY>
</HTML>