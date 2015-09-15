package com.aneesh.auditframework;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import oracle.ucp.jdbc.PoolDataSource;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;

public class RequeueServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public RequeueServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
	}

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		try {
			
			PoolDataSource dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement();
			int srvcAccessLvl = 0;
			String sqlQueryString = null;
			String srvcNm = request.getParameter("srvcNm");
			
			sqlQueryString = "SELECT ACCESS_LVL FROM SERVICE_NAMES_T WHERE SRVC_NM = '" + srvcNm + "'";
			resultSet = statement.executeQuery(sqlQueryString);
			
			while (resultSet.next()) {
				srvcAccessLvl = Integer.parseInt(resultSet.getString(1));
			}
			
			HttpSession session = request.getSession(true);
			if(srvcAccessLvl > Integer.parseInt(session.getAttribute("userAccessLevel").toString()))
			{
	    		request.setAttribute("errorMessage", "User id doesn't have privilege to requeue the transactions !!");
				getServletConfig().getServletContext()
				.getRequestDispatcher("/CaptureUserInputSearchParams.jsp?SearchType=AuditTrail")
				.forward(request, response);				
			}
			else
			{
				String txnIds = request.getParameter("txnIds");
				RePublishMessageToMQ rePublishMessageToMQ = new RePublishMessageToMQ();
				rePublishMessageToMQ.getMessagePayload(srvcNm, txnIds);
			}
			
	        PrintWriter printWriter = response.getWriter();
	        printWriter.print("Selected transactions are successfully re-queued !!");
			//request.setAttribute("logMessage", "Selected transactions are successfully re-queued !!");
			//getServletConfig().getServletContext().getRequestDispatcher("/CaptureUserInputSearchParams.jsp?SearchType=AuditTrail").forward(request, response);	
		} catch (Exception e) {
			System.out.println("Error occured in RequeueServlet.doPost()");
			e.printStackTrace();
			//request.setAttribute("errorMessage", "Requeue request failed !!");
			//getServletConfig().getServletContext().getRequestDispatcher("/CaptureUserInputSearchParams.jsp?SearchType=AuditTrail").forward(request, response);	
	        PrintWriter printWriter = response.getWriter();
	        printWriter.print("Re-queue request failed !!");			
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

}
