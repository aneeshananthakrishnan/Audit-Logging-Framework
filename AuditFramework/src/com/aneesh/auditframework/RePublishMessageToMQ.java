package com.aneesh.auditframework;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;

import oracle.ucp.jdbc.PoolDataSource;

import com.ibm.mq.*;
import com.ibm.mq.constants.*;

public class RePublishMessageToMQ  {

	private MQQueueManager qMgr;

	public void getMessagePayload(String srvcNm, String txnIds) throws ServletException {
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		try {
			PoolDataSource dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement();
			String sqlQueryString = null;
			String srcDetails = null;
			String channel = null;
			String hostName = null;
			int port = 0;
			String qManager = null;
			String qName = null;
			
			sqlQueryString = "SELECT SRC_NM, SRC_DETS FROM SERVICE_ATTRIBUTES_T WHERE SRVC_NM = '" + srvcNm + "'";
			resultSet = statement.executeQuery(sqlQueryString);
			while (resultSet.next()) {
				qName = resultSet.getString(1).trim();
				srcDetails = resultSet.getString(2);
				
				channel = srcDetails.substring(0, srcDetails.indexOf(";")).trim();
				
				srcDetails = srcDetails.substring(srcDetails.indexOf(";") + 1, srcDetails.length());
				hostName = srcDetails.substring(0, srcDetails.indexOf(";")).trim();
				
				srcDetails = srcDetails.substring(srcDetails.indexOf(";") + 1, srcDetails.length());
				port = Integer.parseInt(srcDetails.substring(0, srcDetails.indexOf(";")).trim());
				
				srcDetails = srcDetails.substring(srcDetails.indexOf(";") + 1, srcDetails.length());
				qManager = srcDetails.substring(0, srcDetails.indexOf(";")).trim();
			}
			
			String dataToPublish = null;
			sqlQueryString = "SELECT UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_DECODE(PAYLOAD)) FROM PAYLOAD_CLOB_T WHERE COUNTER = 1 AND TRANSACTION_ID IN (" + txnIds + ")";
			//System.out.println(sqlQueryString);
			resultSet = statement.executeQuery(sqlQueryString);
			while (resultSet.next()) {
				dataToPublish = resultSet.getString(1);
				//System.out.println(resultSet.getString(1));
				publishMsgToMQ(hostName, channel, port, qManager, qName, dataToPublish);
			}
		} 
		catch (Throwable e) {
			System.out.println("Error occured in RePublishMessageToMQ.getMessagePayload()");
			throw new ServletException("Error: " + e.getMessage(), e); 
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
	
	public void publishMsgToMQ(String hostName, String channel, int port, String qManager, String qName, String dataToPublish) throws MQException {
        MQEnvironment.hostname = hostName;
        MQEnvironment.channel = channel;
        MQEnvironment.port = port;
        //MQEnvironment.properties.put(MQC.TRANSPORT_PROPERTY, MQC.TRANSPORT_MQSERIES_CLIENT);
        MQEnvironment.properties.put(MQC.TRANSPORT_PROPERTY, MQC.TRANSPORT_MQSERIES);
		try {
			qMgr = new MQQueueManager(qManager);
			int openOptions = CMQC.MQOO_INPUT_AS_Q_DEF | CMQC.MQOO_OUTPUT;
			MQQueue mqQueue = qMgr.accessQueue(qName, openOptions);
			MQMessage mqMessage = new MQMessage();
			mqMessage.writeString(dataToPublish);
			MQPutMessageOptions mqPutMsgOptions = new MQPutMessageOptions();
			mqQueue.put(mqMessage, mqPutMsgOptions);
			mqQueue.close();
			qMgr.disconnect();
		} catch (Throwable e) {
			System.out.println("Error occured in RePublishMessageToMQ.publishMsgToMQ()");
			throw new MQException(1, 1, e); 
		}
	}
}