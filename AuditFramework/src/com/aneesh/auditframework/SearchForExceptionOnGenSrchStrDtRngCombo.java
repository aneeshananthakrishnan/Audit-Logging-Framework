package com.aneesh.auditframework;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;

import oracle.ucp.jdbc.PoolDataSourceFactory;
import oracle.ucp.jdbc.PoolDataSource;

public class SearchForExceptionOnGenSrchStrDtRngCombo {

	public List<ExceptionData> getExceptionList(String txnName, String genSearchString, String startDate, String startTime,
			String endDate, String endTime, String startRowNum, String endRowNum) {
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		List<ExceptionData> dbQueryResult = new ArrayList<ExceptionData>();
		try {
			PoolDataSource dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement();			
			String sqlQueryString = null;

			if (!txnName.equals("All")) {
				txnName = "B.SERVICE_NM = '" + txnName +"' AND ";
			} else {
				txnName = "";
			}
			sqlQueryString = "SELECT   ROW_NUM, TRANSACTION_ID, MSG_ID, BRKR_NAME, EG_NAME, MSGFLOW_NM, NODE_NM, ERROR_CD, ERROR_MSG, SERVICE_NM, SEARCH_KEY_1, SEARCH_KEY_2, SEARCH_KEY_3, SEARCH_KEY_4, SEARCH_KEY_5, CREATE_TIMESTAMP FROM ( "
					+ "SELECT " 
					+ "ROWNUM AS ROW_NUM, "
					+ "A.TRANSACTION_ID, " 
					+ "A.MSG_ID, "
					+ "A.BRKR_NAME, " 
					+ "A.EG_NAME, " 
					+ "A.MSGFLOW_NM, "
					+ "A.NODE_NM, " 
					+ "A.ERROR_CD, " 
					+ "A.ERROR_MSG, "
					+ "B.SERVICE_NM,  " 
					+ "B.SEARCH_KEY_1, "
					+ "B.SEARCH_KEY_2, " 
					+ "B.SEARCH_KEY_3, "
					+ "B.SEARCH_KEY_4, " 
					+ "B.SEARCH_KEY_5, "
					+ "A.CREATE_TIMESTAMP " 
					+ "FROM " 
					+ "EXCEPTION_T A, "
					+ "SEARCH_KEY_T B " 
					+ "WHERE "
					+ "A.TRANSACTION_ID = B.TRANSACTION_ID AND "
					+ txnName
					+ "B.GENERIC_SEARCH_STRING LIKE '%" + genSearchString
					+ "%' AND A.CREATE_TIMESTAMP BETWEEN TO_TIMESTAMP('"
					+ startDate 
					+ " " 
					+ startTime
					+ "', 'MM/DD/YYYY HH24:MI:SS') AND TO_TIMESTAMP('"
					+ endDate + " " 
					+ endTime + "', 'MM/DD/YYYY HH24:MI:SS')"
					+ " AND ROWNUM <= 2500 ) WHERE ROW_NUM BETWEEN "
					+ startRowNum
					+ " AND "
					+ endRowNum;
			//System.out.println(sqlQueryString);
			resultSet = statement.executeQuery(sqlQueryString);
			while (resultSet.next()) {
				ExceptionData exceptionData = new ExceptionData();
				exceptionData.setROW_NUM(resultSet.getString("ROW_NUM"));
				exceptionData.setTRANSACTION_ID(resultSet.getString("TRANSACTION_ID"));
				exceptionData.setMSG_ID(resultSet.getString("MSG_ID"));
				exceptionData.setBRKR_NAME(resultSet.getString("BRKR_NAME"));
				exceptionData.setEG_NAME(resultSet.getString("EG_NAME"));
				exceptionData.setMSGFLOW_NM(resultSet.getString("MSGFLOW_NM"));
				exceptionData.setNODE_NM(resultSet.getString("NODE_NM"));		
				exceptionData.setERROR_CD(resultSet.getString("ERROR_CD"));
				exceptionData.setERROR_MSG(resultSet.getString("ERROR_MSG"));
				exceptionData.setCREATE_TIMESTAMP(resultSet.getString("CREATE_TIMESTAMP"));
				exceptionData.setSERVICE_NM(resultSet.getString("SERVICE_NM"));
				exceptionData.setSEARCH_KEY_1(resultSet.getString("SEARCH_KEY_1"));
				exceptionData.setSEARCH_KEY_2(resultSet.getString("SEARCH_KEY_2"));
				exceptionData.setSEARCH_KEY_3(resultSet.getString("SEARCH_KEY_3"));
				exceptionData.setSEARCH_KEY_4(resultSet.getString("SEARCH_KEY_4"));
				exceptionData.setSEARCH_KEY_5(resultSet.getString("SEARCH_KEY_5"));	
				dbQueryResult.add(exceptionData);
			}
		} catch (Exception e) {
			e.printStackTrace();
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
		return dbQueryResult;
	}

}
