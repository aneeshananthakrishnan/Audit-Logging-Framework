package com.aneesh.auditframework;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import oracle.ucp.jdbc.PoolDataSource;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import com.aneesh.auditframework.DBConnectionPool;
import com.ibm.mq.MQC;
import com.ibm.mq.MQEnvironment;
import com.ibm.mq.MQException;
import com.ibm.mq.MQGetMessageOptions;
import com.ibm.mq.MQMessage;
import com.ibm.mq.MQPutMessageOptions;
import com.ibm.mq.MQQueue;
import com.ibm.mq.MQQueueManager;
import com.ibm.mq.constants.CMQC;

public class UpdateLoggingLevelResposeToDB {

	final static Logger logger = Logger.getLogger(UpdateLoggingLevelResposeToDB.class);

	public static void main(String[] args) {
		try {
			String hostName = null;
			String channel = null;
			int port = 0;
			String qManager = null;
			String qName = null;
					
			String stcriptExtn = null;
			String logBaseDir = null;

			for (int i = 0; i < args.length; i++) {
				if (i == 0) {
					hostName = args[i].toString();
				}
				if (i == 1) {
					channel = args[i].toString();
				}
				if (i == 2) {
					port = Integer.parseInt(args[i].toString());
				}
				if (i == 3) {
					qManager = args[i].toString();
				}
				if (i == 4) {
					qName = args[i].toString();
				}							
				if (i == 5) {
					stcriptExtn = args[i].toString();
				}
				if (i == 6) {
					logBaseDir = args[i].toString();
				}
			}
			BasicConfigurator.configure();
			logger.debug("Monitoring Profile level request MQ connection details: " + hostName + " : " + channel + " : " + port + " : " + qManager + " : " + qName + " : " + stcriptExtn);
			UpdateLoggingLevelResposeToDB updtLogLvlResToDB = new UpdateLoggingLevelResposeToDB();
			updtLogLvlResToDB.readSetLogLvlMsgFromMQ(hostName, channel, port, qManager, qName, stcriptExtn, logBaseDir);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void readSetLogLvlMsgFromMQ(String hostName, String channel, int port,
		String qManager, String qName, String stcriptExtn, String logBaseDir) 
		throws MQException {
		int mqDepth = 0;
		MQQueue queue = null;
		MQQueueManager qMgr = null;
		String msgFlowNm = null;
		String applNm = null;
		String egNm = null;
		String nodeNm =  null;
		String monProfLvl = null; 
		String status = null; 
		String timeStamp = null; 
		
		Connection dbConnection = null;
		Statement statement = null;
		String sqlQueryString = null;
		ResultSet resultSet = null;
		  
		try {
			MQEnvironment.hostname = hostName;
			MQEnvironment.channel = channel;
			MQEnvironment.port = port;
			MQEnvironment.properties.put(MQC.TRANSPORT_PROPERTY,MQC.TRANSPORT_MQSERIES);
			int openOptions = CMQC.MQOO_INQUIRE + CMQC.MQOO_FAIL_IF_QUIESCING + CMQC.MQOO_INPUT_SHARED;
			qMgr = new MQQueueManager(qManager);
			queue = qMgr.accessQueue(qName, openOptions);
			mqDepth = queue.getCurrentDepth();
			logger.debug("Current MQ depth is: " + mqDepth);

			if (mqDepth == 0) {
				logger.debug("No messages to read from MQ. Returning....");
				return;
			}

			MQGetMessageOptions getOptions = new MQGetMessageOptions();
			getOptions.options = CMQC.MQGMO_NO_WAIT	+ CMQC.MQGMO_FAIL_IF_QUIESCING + CMQC.MQGMO_CONVERT;
			while (true) {
				MQMessage message = new MQMessage();
				queue.get(message, getOptions);
				byte[] b = new byte[message.getMessageLength()];
				message.readFully(b);
				logger.debug(new String(b));
				
				Document document = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(new InputSource(new StringReader(new String(b))));
				NodeList nodeList = document.getElementsByTagName("LoggingLevel");
				Element loggingLevelElement = (Element)nodeList.item(0);
				
				nodeNm = loggingLevelElement.getElementsByTagName("IIBNode").item(0).getTextContent();
				msgFlowNm = loggingLevelElement.getElementsByTagName("MessageFlow").item(0).getTextContent();
				applNm = loggingLevelElement.getElementsByTagName("Application").item(0).getTextContent();
				egNm = loggingLevelElement.getElementsByTagName("ExecutionGroup").item(0).getTextContent();
				monProfLvl = loggingLevelElement.getElementsByTagName("MonitoringProfileLevel").item(0).getTextContent();
				status = loggingLevelElement.getElementsByTagName("ResponseMessage").item(0).getTextContent();
				timeStamp = loggingLevelElement.getElementsByTagName("TimeStamp").item(0).getTextContent();
				
				PoolDataSource dbConnectionPool = DBConnectionPool.getDBConnection();
				dbConnection = dbConnectionPool.getConnection();
				statement = dbConnection.createStatement();

				sqlQueryString = "INSERT INTO AUDADM.USER_ACTIONS_HISTORY_T "
									+ "("
									+ "ACTION_TIMESTAMP, "
									+ "USER_NM, "
									+ "ACTION_DESC"
									+ ")"
									+ " VALUES "
									+ "(TO_TIMESTAMP('"
									+ timeStamp 
									+ "', 'YYYY-MM-DD HH24:MI:SS.FF'), "
									+ "'admin', '"
									+ "Status of Request to set logging level of "
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
									+ monProfLvl
									+ " is:- "
									+ status
									+ "')";
				logger.debug(sqlQueryString);
				resultSet = statement.executeQuery(sqlQueryString);
				
				message.clearMessage();
				
				if (queue.getCurrentDepth() == 0) {
					logger.debug("All the Set-Log-Level response messages are read. Breaking the loop....");
					break;
				}
			}
		} catch (IOException e) {
			logger.error("IOException during MQ GET: " + e.getMessage());
		} catch (MQException e) {
			if (e.completionCode == 2
					&& e.reasonCode == CMQC.MQRC_NO_MSG_AVAILABLE) {
				if (mqDepth == 0) {
					logger.debug("All the Set-Log-Level response messages are read.");
				}
			} else {
				e.printStackTrace();
				logger.error("Exception during MQ GET: " + e.getMessage());
				throw e;
			}
		} catch (Exception e) {
			logger.error("Exception during MQ GET: " + e.getMessage());
			e.printStackTrace();
		}
		queue.close();
		qMgr.disconnect();
	}
	
}
