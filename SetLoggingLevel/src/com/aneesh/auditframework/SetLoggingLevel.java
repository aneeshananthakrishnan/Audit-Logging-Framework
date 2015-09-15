package com.aneesh.auditframework;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;

import com.ibm.mq.MQC;
import com.ibm.mq.MQEnvironment;
import com.ibm.mq.MQException;
import com.ibm.mq.MQGetMessageOptions;
import com.ibm.mq.MQMessage;
import com.ibm.mq.MQPutMessageOptions;
import com.ibm.mq.MQQueue;
import com.ibm.mq.MQQueueManager;
import com.ibm.mq.constants.CMQC;

import java.io.File;
import java.sql.Timestamp;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

public class SetLoggingLevel {

	final static Logger logger = Logger.getLogger(SetLoggingLevel.class);

	public static void main(String[] args) {
		try {
			String hostName = null;
			String channel = null;
			int port = 0;
			String qManager = null;
			String qName = null;
			String resMsgHostName = null;
			String resMsgChannel = null;
			int resMsgPort = 0;
			String resMsgQManager = null;
			String resMsgQName = null;
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
					resMsgHostName = args[i].toString();
				}
				if (i == 6) {
					resMsgChannel = args[i].toString();
				}
				if (i == 7) {
					resMsgPort = Integer.parseInt(args[i].toString());
				}
				if (i == 8) {
					resMsgQManager = args[i].toString();
				}
				if (i == 9) {
					resMsgQName = args[i].toString();
				}				
				if (i == 10) {
					stcriptExtn = args[i].toString();
				}
				if (i == 11) {
					logBaseDir = args[i].toString();
				}
			}
			BasicConfigurator.configure();
			logger.debug("Monitoring Profile level request MQ connection details: " + hostName + " : " + channel + " : " + port + " : " + qManager + " : " + qName + " : " + stcriptExtn);
			logger.debug("Monitoring Profile level response MQ connection details: " + resMsgHostName + " : " + resMsgChannel + " : " + resMsgPort + " : " + resMsgQManager + " : " + resMsgQName);
			SetLoggingLevel setLoggingLevel = new SetLoggingLevel();
			setLoggingLevel.readLoggingMsgFromMQ(hostName, channel, port, qManager, qName, resMsgHostName ,resMsgChannel ,resMsgPort ,resMsgQManager, resMsgQName, stcriptExtn, logBaseDir);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void readLoggingMsgFromMQ(String hostName, String channel, int port,
			String qManager, String qName, String resMsgHostName, String resMsgChannel, 
			int resMsgPort, String resMsgQManager, String resMsgQName,
			String stcriptExtn, String logBaseDir) throws MQException {
		int mqDepth = 0;
		MQQueue queue = null;
		MQQueueManager qMgr = null;
		String msgFlowNm = null;
		String applNm = null;
		String egNm = null;
		String nodeNm = null;
		String monProfLvl = null; 
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
				logger.debug("Command to execute: " + logBaseDir + "SETLOGLVL_" + monProfLvl + "." + stcriptExtn + " " + applNm + " " + egNm + " " + msgFlowNm + " " + nodeNm);
				Runtime.getRuntime().exec("cmd /C " + logBaseDir + "SETLOGLVL_" + monProfLvl + "." + stcriptExtn + " " + applNm + " " + egNm + " " + msgFlowNm + " " + nodeNm);
				message.clearMessage();
				
                String responseMsg = createResponseMessage(nodeNm, msgFlowNm, applNm, egNm, monProfLvl, "Success");
				publishMsgToMQ(resMsgHostName ,resMsgChannel ,resMsgPort ,resMsgQManager, resMsgQName, responseMsg);
				
				if (queue.getCurrentDepth() == 0) {
					logger.debug("All the Set-Log-Level messages are read. Breaking the loop....");
					break;
				}
			}
		} catch (IOException e) {
			logger.error("IOException during MQ GET: " + e.getMessage());
		} catch (MQException e) {
			if (e.completionCode == 2
					&& e.reasonCode == CMQC.MQRC_NO_MSG_AVAILABLE) {
				if (mqDepth == 0) {
					logger.debug("All the Set-Log-Level messages are read.");
				}
			} else {
				e.printStackTrace();
				logger.error("Exception during MQ GET: " + e.getMessage());
				String responseMsg = createResponseMessage(nodeNm, msgFlowNm, applNm, egNm, monProfLvl, "Fail");
				publishMsgToMQ(resMsgHostName ,resMsgChannel ,resMsgPort ,resMsgQManager, resMsgQName, responseMsg);
				throw e;
			}
		} catch (Exception e) {
			logger.error("Exception during MQ GET: " + e.getMessage());
			String responseMsg = createResponseMessage(nodeNm, msgFlowNm, applNm, egNm, monProfLvl, "Fail");
			publishMsgToMQ(resMsgHostName ,resMsgChannel ,resMsgPort ,resMsgQManager, resMsgQName, responseMsg);
			e.printStackTrace();
		}
		queue.close();
		qMgr.disconnect();
	}
	
	public void publishMsgToMQ(String hostName, String channel, int port, String qManager, String qName, String dataToPublish) throws MQException {
		MQQueueManager qMgr = null;
		MQEnvironment.hostname = hostName;
        MQEnvironment.channel = channel;
        MQEnvironment.port = port;
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
			logger.error("Error occured in SetLoggingLevel.publishMsgToMQ()");
			System.out.println("Error occured in SetLoggingLevel.publishMsgToMQ()");
			throw new MQException(1, 1, e); 
		}
	}
	
	public String createResponseMessage(String nodeNm, String msgFlowNm, String applNm, String egNm, String monProfLvl, String status) throws MQException{
		String resMsg = null;
		try{
			Document document = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
			
			Element rootElmt = document.createElement("LoggingLevel");
			document.appendChild(rootElmt);
			
			Element nodeElement = document.createElement("IIBNode");
			nodeElement.appendChild(document.createTextNode(nodeNm));
			rootElmt.appendChild(nodeElement);	
			
			Element msgFlowNmElement = document.createElement("MessageFlow");
			msgFlowNmElement.appendChild(document.createTextNode(msgFlowNm));
			rootElmt.appendChild(msgFlowNmElement);
			
			Element applNmElement = document.createElement("Application");
			applNmElement.appendChild(document.createTextNode(applNm));
			rootElmt.appendChild(applNmElement);
			
			Element egNmElement = document.createElement("ExecutionGroup");
			egNmElement.appendChild(document.createTextNode(egNm));
			rootElmt.appendChild(egNmElement);				
			
			Element monProfFileLvlElement = document.createElement("MonitoringProfileLevel");
			monProfFileLvlElement.appendChild(document.createTextNode(monProfLvl));
			rootElmt.appendChild(monProfFileLvlElement);
			
			Element statusElement = document.createElement("ResponseMessage");
			if(status.equals("Success")){
				statusElement.appendChild(document.createTextNode("Success"));
				rootElmt.appendChild(statusElement);
				
			} else {
				statusElement.appendChild(document.createTextNode("Failure"));
				rootElmt.appendChild(statusElement);
			}
			
			Element monProfLvlSetTime = document.createElement("TimeStamp");
			monProfLvlSetTime.appendChild(document.createTextNode((new Timestamp(new java.util.Date().getTime())).toString()));
			rootElmt.appendChild(monProfLvlSetTime);
			
		    DOMSource domSource = new DOMSource(document);
		    TransformerFactory tf = TransformerFactory.newInstance();
		    Transformer transformer = tf.newTransformer();
		    
		    StringWriter stringWriter = new StringWriter();
		    StreamResult streamResult = new StreamResult(stringWriter);
		    
		    transformer.transform(domSource, streamResult);
			
		    resMsg = stringWriter.toString();
		} catch (Throwable e) {
			logger.error("Error occured in SetLoggingLevel.createResponseMessage()");
			System.out.println("Error occured in SetLoggingLevel.createResponseMessage()");
			throw new MQException(1, 1, e); 
		}
		
		return resMsg;
	}

}
