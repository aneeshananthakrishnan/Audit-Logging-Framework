package com.aneesh.auditframework;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import oracle.ucp.jdbc.PoolDataSource;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;

public class ServiceMetricsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public ServiceMetricsServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {	

		try {
			String srvcNm = request.getParameter("srvcNm");
			//System.out.println(srvcNm);
			String sTemp = "";
			String metricType = request.getParameter("metricType");
			String date = request.getParameter("date");
			JSONObject metricsJSON = new JSONObject();
			if(srvcNm.indexOf("Combined")  != -1){
				metricsJSON.accumulate("metricsHeader", new JSONObject().put("metricsPayload", this.getAggregatedMetrics(metricType, date)));
			}
			if (srvcNm.indexOf(",") != -1) {
				while(srvcNm.indexOf(",") != -1){
					sTemp = srvcNm.substring(0, srvcNm.indexOf(","));
					//System.out.println("sTemp :" + sTemp);
					if(!sTemp.equals("Combined")){
						metricsJSON.accumulate("metricsHeader", new JSONObject().put("metricsPayload", this.getMetricsForService(sTemp, metricType, date)));
					}
					//System.out.println(metricsJSON);
					srvcNm = srvcNm.substring(srvcNm.indexOf(",") + 1, srvcNm.length());
				}
				//System.out.println("srvcNm :" + srvcNm);
				if(!srvcNm.equals("Combined")){
					metricsJSON.accumulate("metricsHeader", new JSONObject().put("metricsPayload", this.getMetricsForService(srvcNm, metricType, date)));
				}
			} else {
				//System.out.println("srvcNm :" + srvcNm);
				if(!srvcNm.equals("Combined")){
					metricsJSON.put("metricsHeader", new JSONObject().put("metricsPayload", this.getMetricsForService(srvcNm, metricType, date)));
				}	
			}
			
			//System.out.println(metricsJSON);
	        PrintWriter printWriter = response.getWriter();
	        printWriter.print(metricsJSON);
		} catch (Exception e) {
			System.out.println("Error occured in RequeueServlet.doGet()");
			e.printStackTrace();
	        PrintWriter printWriter = response.getWriter();
	        printWriter.print("Request for Service Metrics failed !!");			
		}
	}

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
	}
	
	protected JSONArray getAggregatedMetrics(String metricType, String date) {
		String sqlQueryString = null;
		Connection dbConnection = null;
		ResultSet resultSet = null;
		Statement statement = null;
		JSONArray metricsHeader = null;
		JSONObject metricsPayload = null;
		try {
			PoolDataSource dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);	
			if(metricType.equals("Hourly")){
				sqlQueryString = "SELECT "
								+ " 'All (Aggregated)' AS SRVC_NM, TO_CHAR(A.METRIC_DATE,'MM/DD/YYYY'), A.METRIC_TIME, A.TOTAL_CNT, B.SUCCESS_CNT, C.FAIL_CNT"
								+ " 	FROM"
								+ " 	  (SELECT "
								+ " 	    SUM(RUN_COUNT) AS TOTAL_CNT, METRIC_DATE, METRIC_TIME FROM SERVICE_METRICS "
								+ " 	  GROUP BY METRIC_DATE, METRIC_TIME) A,"
								+ " 	  (SELECT "
								+ " 	    SUM(RUN_COUNT) AS SUCCESS_CNT, METRIC_DATE, METRIC_TIME FROM SERVICE_METRICS "
								+ " 	  WHERE "
								+ " 	    TXN_STATUS = 'SUCCESS' "
								+ " 	  GROUP BY METRIC_DATE, METRIC_TIME) B, "
								+ " 	  (SELECT "
								+ " 	    SUM(RUN_COUNT) AS FAIL_CNT, METRIC_DATE, METRIC_TIME FROM SERVICE_METRICS "
								+ " 	  WHERE "
								+ " 	    TXN_STATUS = 'FAIL' "
								+ " 	  GROUP BY METRIC_DATE, METRIC_TIME) C"
								+ " 	WHERE"
								+ " 	   A.METRIC_DATE = B.METRIC_DATE AND"
								+ " 	   A.METRIC_TIME = B.METRIC_TIME AND"
								+ " 	   A.METRIC_DATE = C.METRIC_DATE AND"
								+ " 	   A.METRIC_TIME = C.METRIC_TIME AND"
								+ " 	   A.METRIC_DATE = TO_DATE('" + date + "', 'MM/DD/YYYY')"
								+ " 	ORDER BY A.METRIC_DATE, A.METRIC_TIME";
				resultSet = statement.executeQuery(sqlQueryString);
			} else {
				sqlQueryString = "SELECT "
								+ "  'All (Aggregated)' AS SRVC_NM, TO_CHAR(A.METRIC_DATE,'MM/DD/YYYY'), A.TOTAL_CNT, B.SUCCESS_CNT, C.FAIL_CNT"
								+ "  FROM"
								+ "    (SELECT "
								+ "      SUM(RUN_COUNT) AS TOTAL_CNT, METRIC_DATE FROM SERVICE_METRICS "
								+ "    GROUP BY METRIC_DATE) A,"
								+ "    (SELECT "
								+ "      SUM(RUN_COUNT) AS SUCCESS_CNT, METRIC_DATE FROM SERVICE_METRICS "
								+ "    WHERE "
								+ "      TXN_STATUS = 'SUCCESS'"
								+ "    GROUP BY METRIC_DATE) B,"
								+ "    (SELECT "
								+ "      SUM(RUN_COUNT) AS FAIL_CNT, METRIC_DATE FROM SERVICE_METRICS "
								+ "    WHERE "
								+ "      TXN_STATUS = 'FAIL'" 
								+ "    GROUP BY METRIC_DATE) C"
								+ "  WHERE"
								+ "     A.METRIC_DATE = B.METRIC_DATE AND"
								+ "     A.METRIC_DATE = C.METRIC_DATE AND"
								+ "     A.METRIC_DATE > SYSDATE - 14"
								+ "  ORDER BY A.METRIC_DATE";
				resultSet = statement.executeQuery(sqlQueryString);
			}

			JSONArray metricsRowsArrayJson = new JSONArray();

			if (metricType.equals("Daily")){
				while (resultSet.next()) {
					JSONObject metricsRowJson = new JSONObject();
					metricsRowJson.put("METRIC_DATE", resultSet.getString(2));
					metricsRowJson.put("TOTAL_CNT", resultSet.getString(3));
					metricsRowJson.put("FAIL_CNT", resultSet.getString(4));
					metricsRowJson.put("SUCCESS_CNT", resultSet.getString(5));
					metricsRowsArrayJson.put(metricsRowJson);
				}
			} else {
				while (resultSet.next()) {
					JSONObject metricsRowJson = new JSONObject();
					metricsRowJson.put("METRIC_DATE", resultSet.getString(2));
					metricsRowJson.put("METRIC_TIME", resultSet.getString(3));
					metricsRowJson.put("TOTAL_CNT", resultSet.getString(4));
					metricsRowJson.put("FAIL_CNT", resultSet.getString(5));
					metricsRowJson.put("SUCCESS_CNT", resultSet.getString(6));
					metricsRowsArrayJson.put(metricsRowJson);	
				}
			}

			metricsHeader = new JSONArray();
			metricsPayload = new JSONObject();
			metricsPayload.put("recCounts", metricsRowsArrayJson);
			metricsHeader.put(new JSONObject().put("SRVC_NM", "All (Aggregated)"));
			metricsHeader.put(metricsPayload);
			//System.out.println(metricsHeader);
		} catch (Exception e) {
			System.out.println("Error occured in RequeueServlet.doGet()");
			e.printStackTrace();		
		}
		finally{
			try{
				statement.close();
				resultSet.close();
				dbConnection.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		//System.out.println(metricsHeader);
		return metricsHeader;
	}
	
	protected JSONArray getMetricsForService(String srvcNm, String metricType, String date) {
		String sqlQueryString = null;
		Connection dbConnection = null;
		ResultSet resultSet = null;
		Statement statement = null;
		JSONArray metricsHeader = null;
		
		try {
			PoolDataSource dbConnectionPool	= DBConnectionPool.getDBConnection();									
			dbConnection = dbConnectionPool.getConnection();
	        statement = dbConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);	
			if(metricType.equals("Hourly")){
				sqlQueryString = "SELECT  A.SRVC_NM, TO_CHAR(A.METRIC_DATE,'MM/DD/YYYY') AS METRIC_DATE, A.METRIC_TIME, A.TOTAL_CNT, B.FAIL_CNT, C.SUCCESS_CNT"
	                             +  " FROM"
								 +  "  (SELECT SRVC_NM, METRIC_DATE, METRIC_TIME, SUM(RUN_COUNT) AS TOTAL_CNT FROM"
								 +  "    ("
								 +  "      (SELECT SRVC_NM, RUN_COUNT, METRIC_DATE, METRIC_TIME FROM SERVICE_METRICS WHERE TXN_STATUS = 'FAIL')"
								 +  "        UNION"
								 +  "      (SELECT SRVC_NM, RUN_COUNT, METRIC_DATE, METRIC_TIME FROM SERVICE_METRICS WHERE TXN_STATUS = 'SUCCESS')"
								 +  "    )"
								 +  "  GROUP BY SRVC_NM, METRIC_DATE, METRIC_TIME) A,"
								 +  "  (SELECT SRVC_NM, RUN_COUNT AS FAIL_CNT, METRIC_DATE, METRIC_TIME FROM SERVICE_METRICS WHERE TXN_STATUS = 'FAIL') B,"
								 +  "  (SELECT SRVC_NM, RUN_COUNT AS SUCCESS_CNT, METRIC_DATE, METRIC_TIME FROM SERVICE_METRICS WHERE TXN_STATUS = 'SUCCESS') C"
								 +  " WHERE"
								 +  "  A.SRVC_NM = B.SRVC_NM AND"
								 +  "  A.SRVC_NM = C.SRVC_NM AND"
								 +  "  A.METRIC_DATE = B.METRIC_DATE AND"
								 +  "  A.METRIC_DATE = C.METRIC_DATE AND"
								 +  "  A.METRIC_TIME = B.METRIC_TIME AND"
								 +  "  A.METRIC_TIME = C.METRIC_TIME AND"
								 +  "  A.METRIC_DATE = TO_DATE('" + date + "', 'MM/DD/YYYY') AND"
								 +  "  A.SRVC_NM = '"+  srvcNm +"'"
								 +  " ORDER BY A.METRIC_TIME ASC";
				//System.out.println(sqlQueryString);
				resultSet = statement.executeQuery(sqlQueryString);
			} else {
				sqlQueryString = "SELECT A.SRVC_NM, TO_CHAR(A.METRIC_DATE,'MM/DD/YYYY') AS METRIC_DATE, SUM(A.TOTAL_CNT) AS TOTAL_CNT, SUM(B.FAIL_CNT) AS FAIL_CNT, SUM(C.SUCCESS_CNT) AS SUCCESS_CNT"
								  +  " FROM"
								  +  " (SELECT SRVC_NM, METRIC_DATE, SUM(RUN_COUNT) AS TOTAL_CNT FROM"
								  +  " ("
								  +  " (SELECT SRVC_NM, RUN_COUNT, METRIC_DATE FROM SERVICE_METRICS WHERE TXN_STATUS = 'FAIL')"
								  +  "     UNION"
								  +  "   (SELECT SRVC_NM, RUN_COUNT, METRIC_DATE FROM SERVICE_METRICS WHERE TXN_STATUS = 'SUCCESS')"
								  +  " )"
								  +  " GROUP BY SRVC_NM, METRIC_DATE) A,"
								  +  " (SELECT SRVC_NM, SUM(RUN_COUNT) AS FAIL_CNT, METRIC_DATE FROM" 
								  +  "   SERVICE_METRICS" 
								  +  " WHERE" 
								  +  "   TXN_STATUS = 'FAIL'"
								  +  " GROUP BY SRVC_NM, METRIC_DATE) B,"
								  +  " (SELECT SRVC_NM, SUM(RUN_COUNT) AS SUCCESS_CNT, METRIC_DATE FROM" 
								  +  "   SERVICE_METRICS" 
								  +  " WHERE" 
								  +  "   TXN_STATUS = 'SUCCESS'"
								  +  " GROUP BY SRVC_NM, METRIC_DATE) C"
								  +  " WHERE" 
								  +  " A.SRVC_NM = B.SRVC_NM AND"
								  +  " A.SRVC_NM = C.SRVC_NM AND"
								  +  " A.METRIC_DATE = B.METRIC_DATE AND"
								  +  " A.METRIC_DATE = C.METRIC_DATE AND"
								  +  " A.METRIC_DATE > SYSDATE - 14 AND"
								  +  " A.SRVC_NM = '"+  srvcNm +"'"
								  +  " GROUP BY A.SRVC_NM, A.METRIC_DATE"
								  +  " ORDER BY A.SRVC_NM, A.METRIC_DATE";
				//System.out.println(sqlQueryString);
				resultSet = statement.executeQuery(sqlQueryString);
			}
			
			metricsHeader = new JSONArray();
			JSONObject metricsPayload = new JSONObject();
			JSONArray metricsRowsArrayJson = new JSONArray();
			
			if (metricType.equals("Daily")){
				while (resultSet.next()) {
					JSONObject metricsRowJson = new JSONObject();
					metricsRowJson.put("METRIC_DATE", resultSet.getString(2));
					metricsRowJson.put("TOTAL_CNT", resultSet.getString(3));
					metricsRowJson.put("FAIL_CNT", resultSet.getString(4));
					metricsRowJson.put("SUCCESS_CNT", resultSet.getString(5));
					metricsRowsArrayJson.put(metricsRowJson);
				}
			} else {
				while (resultSet.next()) {
					JSONObject metricsRowJson = new JSONObject();
					metricsRowJson.put("METRIC_DATE", resultSet.getString(2));
					metricsRowJson.put("METRIC_TIME", resultSet.getString(3));
					//System.out.println(resultSet.getString(3));
					metricsRowJson.put("TOTAL_CNT", resultSet.getString(4));
					metricsRowJson.put("FAIL_CNT", resultSet.getString(5));
					metricsRowJson.put("SUCCESS_CNT", resultSet.getString(6));
					metricsRowsArrayJson.put(metricsRowJson);
				}
			}
			metricsPayload.put("recCounts", metricsRowsArrayJson);
			metricsHeader.put(new JSONObject().put("SRVC_NM", srvcNm));
			metricsHeader.put(metricsPayload);
			
		} catch (Exception e) {
			System.out.println("Error occured in RequeueServlet.doGet()");
			e.printStackTrace();	
		}
		finally{
			try{
				statement.close();
				resultSet.close();
				dbConnection.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}	
		//System.out.println(metricsHeader);
		return metricsHeader;
	}	
}
