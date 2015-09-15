package com.aneesh.auditframework;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import oracle.ucp.jdbc.PoolDataSource;

public class ServiceMaintenanceServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public ServiceMaintenanceServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
	}

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Connection dbConnection = null;
		Statement statement = null;
		String sqlQueryString = null;
		String action = request.getParameter("action");
		try {
			PoolDataSource dbConnectionPool = DBConnectionPool.getDBConnection();
			dbConnection = dbConnectionPool.getConnection();
			statement = dbConnection.createStatement();

			if(action.equals("createService")){
				String newSrvcNm = request.getParameter("newServiceName");
				String accessLevel = request.getParameter("accessLevelDropdown");
				ResultSet resultSet = statement.executeQuery("SELECT 1 FROM SERVICE_NAMES_T WHERE SRVC_NM = '" + newSrvcNm + "'");
				if(!resultSet.isBeforeFirst()){
					sqlQueryString = "INSERT INTO SERVICE_NAMES_T "
										+ "(SRVC_NM, ACCESS_LVL, CREATE_TIMESTAMP) "
										+ "VALUES ('"
										+ newSrvcNm + "', "
										+ accessLevel + ", "
										+ "SYSDATE)";
					statement.executeQuery(sqlQueryString);
					request.setAttribute("logMessage", "Service successfully created !!");
					getServletConfig().getServletContext().getRequestDispatcher("/CreateOrRemoveService.jsp").forward(request, response);				
				}
				else{
					request.setAttribute("errorMessage", "Service already exists !!");
					request.getRequestDispatcher("/CreateOrRemoveService.jsp").forward(request, response);
				}
			}
			
			
			else if(action.equals("deleteService")){
				String srvcNmToDel = request.getParameter("serviceDropdown");
				sqlQueryString = "DELETE FROM SERVICE_NAMES_T WHERE SRVC_NM = '"+ srvcNmToDel +"'";
				statement.executeQuery(sqlQueryString);
				sqlQueryString = "DELETE FROM SERVICE_ATTRIBUTES_T WHERE SRVC_NM = '"+ srvcNmToDel +"'";
				statement.executeQuery(sqlQueryString);
				request.setAttribute("logMessage", "Service successfully deleted !!");
				getServletConfig().getServletContext().getRequestDispatcher("/CreateOrRemoveService.jsp").forward(request, response);	
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
			if(action.equals("createService")){
				request.setAttribute("errorMessage", "New service creation not successful !!");
				request.getRequestDispatcher("/CreateOrRemoveService.jsp").forward(request, response);
			}
			else if(action.equals("deleteService")){
				request.setAttribute("errorMessage", "Service delete not successful !!");
				request.getRequestDispatcher("/CreateOrRemoveService.jsp").forward(request, response);
			}
		} finally {
			try {
				statement.close();
				dbConnection.close();
			} catch (Exception e) {
				e.printStackTrace();
			}

		}
	}

}
