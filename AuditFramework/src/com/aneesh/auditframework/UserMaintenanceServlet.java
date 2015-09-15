package com.aneesh.auditframework;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import oracle.ucp.jdbc.PoolDataSource;

public class UserMaintenanceServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public UserMaintenanceServlet() {
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

			if(action.equals("createUser")){
				String newUserId = request.getParameter("newUserId");
				String initPwd = request.getParameter("initPwd");
				String accessLevel = request.getParameter("accessLevelDropdown");
				ResultSet resultSet = statement.executeQuery("SELECT 1 FROM USER_CREDS_T WHERE USER_NM = '" + newUserId + "'");
				if(!resultSet.isBeforeFirst()){
					sqlQueryString = "INSERT INTO USER_CREDS_T "
							+ "(USER_NM, PASSWORD, PWD_RESET_REQD, ACCESS_LVL, CREATE_TIMESTAMP) "
							+ "VALUES ('"
							+ newUserId + "', '"
							+ new EncryptPassword().getEncryptedPassword(initPwd)
							+ "', 'Y', " 
							+ accessLevel + ", "
							+ "SYSDATE)";
					statement.executeQuery(sqlQueryString);
					request.setAttribute("logMessage", "User successfully created !!");
					getServletConfig().getServletContext().getRequestDispatcher("/CreateOrRemoveUser.jsp").forward(request, response);				
				}
				else{
					request.setAttribute("errorMessage", "User already exists !!");
					request.getRequestDispatcher("/CreateOrRemoveUser.jsp").forward(request, response);
				}
			}
			
			
			else if(action.equals("deleteUser")){
				String userIdToDel = request.getParameter("userIdDropdown");
				sqlQueryString = "DELETE FROM USER_CREDS_T WHERE USER_NM = '"+ userIdToDel +"'";
				statement.executeQuery(sqlQueryString);
				request.setAttribute("logMessage", "User successfully deleted !!");
				getServletConfig().getServletContext().getRequestDispatcher("/CreateOrRemoveUser.jsp").forward(request, response);	
			}

			else if(action.equals("updateUserAccess")){
				String userIdToUpdt = request.getParameter("userIdDropdown1");
				String accessLvl = request.getParameter("accessLevelDropdown1");
				sqlQueryString = "UPDATE USER_CREDS_T SET ACCESS_LVL = "+ accessLvl +" WHERE USER_NM = '" + userIdToUpdt +"'";
				statement.executeQuery(sqlQueryString);
				request.setAttribute("logMessage", "User access level is successfully updated !!");
				getServletConfig().getServletContext().getRequestDispatcher("/CreateOrRemoveUser.jsp").forward(request, response);	
			}
			
			else if(action.equals("resetPassword")){
				HttpSession session = request.getSession(true);
		        String userName=session.getAttribute("UserName").toString();
		        String password=session.getAttribute("Password").toString();
				String newPassword = request.getParameter("newPwd");
				String oldPassword = request.getParameter("oldPwd");
				if ((new EncryptPassword().getEncryptedPassword(password)).equals(new EncryptPassword().getEncryptedPassword(oldPassword))){
					sqlQueryString = "UPDATE USER_CREDS_T SET PASSWORD = '" 
										+ new EncryptPassword().getEncryptedPassword(newPassword)
										+ "', PWD_RESET_REQD = 'N' WHERE USER_NM = '" + userName + "'";
					statement.executeQuery(sqlQueryString);
					request.setAttribute("logMessage", "Password successfully reset. Please re-login !!");
					session.setAttribute("userAccessLevel", null);
					getServletConfig().getServletContext().getRequestDispatcher("/Login.jsp").forward(request, response);
				}
				else{
	        		request.setAttribute("errorMessage", "Current password value is not matching with entered 'Old Password' value. Please retry or contact admin!!");
	        		request.getRequestDispatcher("/PasswordReset.jsp").forward(request, response);
				}	
			}
		} catch (Exception e) {
			e.printStackTrace();
			if(action.equals("createUser")){
				request.setAttribute("errorMessage", "New user id creation not successful. Please retry or contact admin !!");
				request.getRequestDispatcher("/CreateOrRemoveUser.jsp").forward(request, response);
			}
			else if(action.equals("deleteUser")){
				request.setAttribute("errorMessage", "User id delete not successful. Please retry or contact admin !!");
				request.getRequestDispatcher("/CreateOrRemoveUser.jsp").forward(request, response);
			}
			else if(action.equals("resetPassword")){
	    		request.setAttribute("errorMessage", "Password update not successful. Please retry or contact admin !!");
	    		request.getRequestDispatcher("/PasswordReset.jsp").forward(request, response);
			}
			else if(action.equals("updateUserAccess")){
	    		request.setAttribute("errorMessage", "User access level update not successful. Please retry or contact admin !!");
	    		request.getRequestDispatcher("/PasswordReset.jsp").forward(request, response);
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
