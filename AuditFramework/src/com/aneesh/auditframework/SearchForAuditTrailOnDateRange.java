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

public class SearchForAuditTrailOnDateRange {

	public List<EventPointData> getAuditList(String txnName, String startDate, String startTime, String endDate, String endTime, String startRowNum, String endRowNum) {
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		List<EventPointData> dbQueryResult = new ArrayList<EventPointData>();
		try {
			PoolDataSource dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement();
			if (!txnName.equals("All")) {
				txnName = "A.SERVICE_NM = '" + txnName +"' AND ";
			} else {
				txnName = "";
			}	        
			String sqlQueryString =  "SELECT ROW_NUM, TRANSACTION_ID, SERVICE_NM, SEARCH_KEY_1, SEARCH_KEY_2, SEARCH_KEY_3, SEARCH_KEY_4, SEARCH_KEY_5, BRKR_NAME, EG_NAME, MSGFLOW_NM, NODE_NM, START_TIME, END_TIME, ELAPSED_TIME, STATUS FROM ( "
					+ "SELECT "
					+ "ROWNUM AS ROW_NUM,"
					+ "A.TRANSACTION_ID,"
					+ "A.SERVICE_NM,"
					+ "A.SEARCH_KEY_1,"
					+ "A.SEARCH_KEY_2,"
					+ "A.SEARCH_KEY_3,"
					+ "A.SEARCH_KEY_4,"
					+ "A.SEARCH_KEY_5,"
					+ "A.BRKR_NAME,"
					+ "A.EG_NAME,"
					+ "A.MSGFLOW_NM,"
					+ "A.NODE_NM,"
					+ "A.START_TIME,"
					+ "COALESCE (C.END_TIME, B.END_TIME) AS END_TIME,"
					+ "COALESCE (C.END_TIME, B.END_TIME) - A.START_TIME AS ELAPSED_TIME,"
					+ "CASE "
					+ "WHEN C.TRANSACTION_ID IS NOT NULL THEN 'FAIL' "
					+ "ELSE 'SUCCESS'  END AS STATUS  FROM  ( "
					+ "SELECT  A.EVENT_SRC_ADDR, A.TRANSACTION_ID,"
					+ "A.EVENT_NAME, A.BRKR_NAME, A.EG_NAME,"
					+ "A.MSGFLOW_NM, A.NODE_NM, A.CREATE_TIMESTAMP AS START_TIME,"
					+ "B.SERVICE_NM, B.SEARCH_KEY_1,"
					+ "B.SEARCH_KEY_2, B.SEARCH_KEY_3, B.SEARCH_KEY_4,"
					+ "B.SEARCH_KEY_5     FROM  EVNTPNT_DATA_T A,"
					+ "SEARCH_KEY_T B  WHERE "
					+ "A.EVENT_NAME = 'TransactionStart' AND "
					+ "A.TRANSACTION_ID = B.TRANSACTION_ID  ) A  "
					+ "LEFT OUTER JOIN  (  SELECT  EVENT_SRC_ADDR,"
					+ "TRANSACTION_ID, CREATE_TIMESTAMP AS END_TIME "
					+ "FROM  EVNTPNT_DATA_T  WHERE "
					+ "EVENT_NAME = 'TransactionEnd'  ) B   ON "
					+ "A.TRANSACTION_ID = B.TRANSACTION_ID  "
					+ "LEFT OUTER JOIN  ( SELECT EVENT_SRC_ADDR,"
					+ "TRANSACTION_ID, CREATE_TIMESTAMP AS END_TIME "
					+ "FROM  EVNTPNT_DATA_T  WHERE "
					+ "EVENT_NAME = 'TransactionFail'  ) C   ON "
					+ "A.TRANSACTION_ID = C.TRANSACTION_ID WHERE "
					+ txnName
					+ "A.START_TIME BETWEEN TO_TIMESTAMP('"
					+ startDate + " " + startTime
					+ "', 'MM/DD/YYYY HH24:MI:SS') AND TO_TIMESTAMP('"
					+ endDate + " " + endTime
					+ "', 'MM/DD/YYYY HH24:MI:SS')"
					+ " AND ROWNUM <= 2500 ) WHERE ROW_NUM BETWEEN "
					+ startRowNum
					+ " AND "
					+ endRowNum;
			resultSet = statement.executeQuery(sqlQueryString);
			while (resultSet.next()) {
				EventPointData eventPointData = new EventPointData();
				eventPointData.setROW_NUM(resultSet.getString("ROW_NUM"));
				eventPointData.setTRANSACTION_ID(resultSet.getString("TRANSACTION_ID"));
				eventPointData.setSERVICE_NM(resultSet.getString("SERVICE_NM"));
				eventPointData.setSEARCH_KEY_1(resultSet.getString("SEARCH_KEY_1"));
				eventPointData.setSEARCH_KEY_2(resultSet.getString("SEARCH_KEY_2"));
				eventPointData.setSEARCH_KEY_3(resultSet.getString("SEARCH_KEY_3"));
				eventPointData.setSEARCH_KEY_4(resultSet.getString("SEARCH_KEY_4"));
				eventPointData.setSEARCH_KEY_5(resultSet.getString("SEARCH_KEY_5"));
				eventPointData.setBRKR_NAME(resultSet.getString("BRKR_NAME"));
				eventPointData.setEG_NAME(resultSet.getString("EG_NAME"));
				eventPointData.setMSGFLOW_NM(resultSet.getString("MSGFLOW_NM"));
				eventPointData.setNODE_NM(resultSet.getString("NODE_NM"));
				eventPointData.setSTART_TIME(resultSet.getString("START_TIME"));
				eventPointData.setEND_TIME(resultSet.getString("END_TIME"));
				eventPointData.setELAPSED_TIME(resultSet.getString("ELAPSED_TIME"));
				eventPointData.setSTATUS(resultSet.getString("STATUS"));
				dbQueryResult.add(eventPointData);
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
