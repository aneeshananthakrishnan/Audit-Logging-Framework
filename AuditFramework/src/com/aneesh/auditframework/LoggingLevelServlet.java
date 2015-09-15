package com.aneesh.auditframework;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import oracle.ucp.jdbc.PoolDataSource;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;

public class LoggingLevelServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	String channel = null;
	String hostName = null;
	int port = 0;
	String qManager = null;
	String qName = "QL.SETLOGLVL.REQ";;
	String applNm = null;
	String nodeNm = null;
	String egNm = null;
	String sqlQueryString = null;
	String msgFlowNm = null;
	String logLevel = null;
	HttpSession session = null;
	Statement statement = null;
	ResultSet resultSet = null;

	public LoggingLevelServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

	}
	

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Connection dbConnection = null;
		
		try {
			
			PoolDataSource dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement();
			int srvcAccessLvl = 0;
			msgFlowNm = request.getParameter("msgFlowNm");
			logLevel = request.getParameter("logLevel");
			String srvcNm = null;
			
			sqlQueryString = "SELECT ACCESS_LVL, SRVC_NM FROM SERVICE_NAMES_T WHERE SRVC_NM IN (SELECT DISTINCT SRVC_NM FROM SERVICE_ATTRIBUTES_T WHERE MSGFLOW_NM = '" + msgFlowNm + "')";
			resultSet = statement.executeQuery(sqlQueryString);
			
			while (resultSet.next()) {
				srvcAccessLvl = Integer.parseInt(resultSet.getString(1));
				srvcNm = resultSet.getString(2).toString();
			}
			
			session = request.getSession(true);
			if(srvcAccessLvl > Integer.parseInt(session.getAttribute("userAccessLevel").toString()))
			{
	    		request.setAttribute("errorMessage", "User id doesn't have privilege to alter the logging level !!");
				getServletConfig().getServletContext().getRequestDispatcher("/SetOrUpdateMFLoggingLevel.jsp").forward(request, response);				
			}
			else
			{
				sqlQueryString = "SELECT IIBNODE_DETS, APPL_NM FROM SERVICE_ATTRIBUTES_T WHERE SRVC_NM = '" + srvcNm + "'";
				resultSet = statement.executeQuery(sqlQueryString);
				String iibNodeDetails = null;

				while (resultSet.next()) {
					iibNodeDetails = resultSet.getString(1);
					applNm = resultSet.getString(2).toString();				
				}
				
				if (this.countLines(iibNodeDetails) > 1) {
					int iCnt = 1;
					String iibNodeDetail = null;
					int lineCnt = this.countLines(iibNodeDetails);
					while (iCnt <= lineCnt){
						if (iibNodeDetails.indexOf("\n") != -1) {
							iibNodeDetail = iibNodeDetails.substring(0, iibNodeDetails.indexOf("\n") - 1);
							iibNodeDetails = iibNodeDetails.substring(iibNodeDetails.indexOf("\n") + 1, iibNodeDetails.length());
						} else {
							iibNodeDetail = iibNodeDetails;
						}
						this.publishSetLogLvlMsg(iibNodeDetail);
						iCnt = iCnt + 1;
					}
				} else {
					this.publishSetLogLvlMsg(iibNodeDetails);
				}
				
			}
			
	        PrintWriter printWriter = response.getWriter();
	        printWriter.print("Successfully submitted the request to change the logging level. Please refresh this page after a few minutes to find out the request status.");	
		} catch (Exception e) {
			System.out.println("Error occured in LoggingLevelServlet.doGet()");
			e.printStackTrace();
	        PrintWriter printWriter = response.getWriter();
	        printWriter.print("Request to change the logging level failed !!");			
		}
		finally{
			try{
				resultSet.close();
				statement.close();
				dbConnection.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
	}
	
	private int countLines(String inputStr){
		int noOfLines= 1;
		while (inputStr.indexOf("\n") != -1){
			inputStr = inputStr.substring(inputStr.indexOf("\n") + 1, inputStr.length());
			noOfLines = noOfLines + 1;
		}
		//System.out.println("noOfLines is: " + noOfLines);
		return noOfLines;
	}
	
	private void publishSetLogLvlMsg(String iibNodeDetail)  throws Exception{
		try {
			channel = iibNodeDetail.substring(0, iibNodeDetail.indexOf(";")).trim();
			iibNodeDetail = iibNodeDetail.substring(iibNodeDetail.indexOf(";") + 1, iibNodeDetail.length());
			hostName = iibNodeDetail.substring(0, iibNodeDetail.indexOf(";")).trim();
			iibNodeDetail = iibNodeDetail.substring(iibNodeDetail.indexOf(";") + 1, iibNodeDetail.length());
			port = Integer.parseInt(iibNodeDetail.substring(0, iibNodeDetail.indexOf(";")).trim());
			iibNodeDetail = iibNodeDetail.substring(iibNodeDetail.indexOf(";") + 1, iibNodeDetail.length());
			qManager = iibNodeDetail.substring(0, iibNodeDetail.indexOf(";")).trim();
			iibNodeDetail = iibNodeDetail.substring(iibNodeDetail.indexOf(";") + 1, iibNodeDetail.length());
			nodeNm = iibNodeDetail.substring(0, iibNodeDetail.indexOf(";")).trim();
			iibNodeDetail = iibNodeDetail.substring(iibNodeDetail.indexOf(";") + 1, iibNodeDetail.length());
			egNm = iibNodeDetail.substring(0, iibNodeDetail.indexOf(";")).trim();
			
			DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
			Document document = documentBuilder.newDocument();
			
			Element rootElmt = document.createElement("LoggingLevel");
			document.appendChild(rootElmt);
			
			Element nodeElement = document.createElement("IIBNode");
			nodeElement.appendChild(document.createTextNode(nodeNm));
			rootElmt.appendChild(nodeElement);				
			
			Element egNmElement = document.createElement("ExecutionGroup");
			egNmElement.appendChild(document.createTextNode(egNm));
			rootElmt.appendChild(egNmElement);	
			
			Element msgFlowNmElement = document.createElement("MessageFlow");
			msgFlowNmElement.appendChild(document.createTextNode(msgFlowNm));
			rootElmt.appendChild(msgFlowNmElement);
			
			Element applNmElement = document.createElement("Application");
			applNmElement.appendChild(document.createTextNode(applNm));
			rootElmt.appendChild(applNmElement);
			
			Element monProfFileLvlElement = document.createElement("MonitoringProfileLevel");
			monProfFileLvlElement.appendChild(document.createTextNode(logLevel));
			rootElmt.appendChild(monProfFileLvlElement);
			
		    DOMSource domSource = new DOMSource(document);
		    TransformerFactory tf = TransformerFactory.newInstance();
		    Transformer transformer = tf.newTransformer();
		    
		    StringWriter stringWriter = new StringWriter();
		    StreamResult streamResult = new StreamResult(stringWriter);
		    
		    transformer.transform(domSource, streamResult);
		    			    
			RePublishMessageToMQ rePublishMessageToMQ = new RePublishMessageToMQ();
			rePublishMessageToMQ.publishMsgToMQ(hostName, channel, port, qManager, qName, stringWriter.toString());
			
			sqlQueryString = "INSERT INTO AUDADM.USER_ACTIONS_HISTORY_T "
					+ "("
					+ "ACTION_TIMESTAMP, "
					+ "USER_NM, "
					+ "ACTION_DESC"
					+ ")"
					+ " VALUES "
					+ "("
					+ "SYSTIMESTAMP, "
					+ "'"
					+ session.getAttribute("UserName").toString()
					+ "', '"
					+ "Request to set logging level of "
					+ hostName
					+ "-"
					+ nodeNm
					+ "-"
					+ egNm 
					+ "-"
					+ applNm 
					+ "-"
					+ msgFlowNm 
					+ " to "
					+ logLevel
					+ " is submitted by the user "
					+ "')";
			resultSet = statement.executeQuery(sqlQueryString);
		} catch (Throwable e) {
			System.out.println("Error occured in LoggingLevelServlet.publishSetLogLvlMsg()");
			throw new Exception("Error: " + e.getMessage(), e); 
		}
	}

}
