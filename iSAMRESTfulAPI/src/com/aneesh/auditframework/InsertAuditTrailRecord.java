package com.aneesh.auditframework;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.io.InputStream;

import javax.naming.Context;
import javax.naming.InitialContext;

import oracle.ucp.jdbc.PoolDataSourceFactory;
import oracle.ucp.jdbc.PoolDataSource;

public class InsertAuditTrailRecord {

	public void insetAuditTrailRecordintoDB(String srvcName, String searchKey1,
										String searchKey2, String searchKey3, String searchKey4,
										String searchKey5, String genSearchStr, String eventSrcAddr, 
										String eventName, String counter, String txnId, 
										String brkrName, String egName, String mfName, 
										String nodeName, String payload) throws Exception {
		PoolDataSource dbConnectionPool = null;
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		try {
			dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
			dbConnection.setAutoCommit(false);
	        statement = dbConnection.createStatement();
	        
            if(searchKey1 == null){
            	searchKey1 = "";
            }
            if(searchKey2 == null){
            	searchKey2 = "";
            }
            if(searchKey3 == null){
            	searchKey3 = "";
            }
            if(searchKey4 == null){
            	searchKey4 = "";
            }
            if(searchKey5 == null){
            	searchKey5 = "";
            }
	        
            String sqlQueryString = "INSERT INTO AUDADM.EVNTPNT_DATA_T "
									+ "("
									+ "	EVENT_SRC_ADDR,"
									+ "	EVENT_NAME,"
									+ "	COUNTER,"
									+ "	TRANSACTION_ID,"
									+ "	BRKR_NAME,"
									+ "	EG_NAME,"
									+ "	MSGFLOW_NM,"
									+ "	NODE_NM,"
									+ "	CREATE_TIMESTAMP"
									+ ")"
									+ " VALUES "
									+ "('"
									+ eventSrcAddr + "', '" 
									+ eventName+ "', '" 
									+ counter+ "', '" 
									+ txnId + "', '" 
									+ brkrName + "', '" 
									+ egName + "', '" 
									+ mfName + "', '" 
									+ nodeName + "', "
									+ "SYSTIMESTAMP)";	
            //System.out.println(sqlQueryString);
            resultSet = statement.executeQuery(sqlQueryString);
            
           
            sqlQueryString = "SELECT COUNT(*) AS ROW_CNT FROM AUDADM.SEARCH_KEY_T WHERE TRANSACTION_ID = '" + txnId + "'";
            resultSet = statement.executeQuery(sqlQueryString);
            resultSet.next();
            if (resultSet.getInt("ROW_CNT") == 0){
	            if(!srvcName.equals("")){
	                sqlQueryString = "INSERT INTO AUDADM.SEARCH_KEY_T "
	    					+ "("
	    					+ "	TRANSACTION_ID,"
	    					+ "	SERVICE_NM,"
	    					+ "	SEARCH_KEY_1,"
	    					+ "	SEARCH_KEY_2,"
	    					+ "	SEARCH_KEY_3,"
	    					+ "	SEARCH_KEY_4,"
	    					+ "	SEARCH_KEY_5,"	
	    					+ " GENERIC_SEARCH_STRING,"
	    					+ "	CREATE_TIMESTAMP"
	    					+ ")"
	    					+ " VALUES "
	    					+ "('"
	    					+ txnId + "', '" 
	    					+ srvcName + "', '" 
	    					+ searchKey1 + "', '" 
	    					+ searchKey2 + "', '" 
	    					+ searchKey3 + "', '"
	    					+ searchKey4 + "', '" 
	    					+ searchKey5 + "', '"		
	    					+ genSearchStr + "', "	
	    					+ "SYSTIMESTAMP)";	
	                //System.out.println(sqlQueryString);
	                resultSet = statement.executeQuery(sqlQueryString);
	            }
            }
            if (payload != null){
            	if (!(payload.equals(""))){
	                sqlQueryString = "INSERT INTO AUDADM.PAYLOAD_CLOB_T "
	    					+ "( "
	    					+ "	TRANSACTION_ID,"
	    					+ "	EVENT_SRC_ADDR,"
	    					+ "	COUNTER,"
	    					+ "	PAYLOAD,"				
	    					+ "	CREATE_TIMESTAMP"
	    					+ ")"
	    					+ " VALUES "
	    					+ "('"
	    					+ txnId + "', '" 
	    					+ eventSrcAddr + "', '" 
	    					+ counter + "', " 
	    					+ payload + ", '" 			
	    					+ "SYSTIMESTAMP)";	
	                //System.out.println(sqlQueryString);
	                resultSet = statement.executeQuery(sqlQueryString);
	            }
            }
            dbConnection.commit();
		} catch (Exception e) {
			dbConnection.rollback();
			e.printStackTrace();
			throw e;
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
