package com.aneesh.auditframework;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import oracle.ucp.jdbc.PoolDataSource;

import org.json.*;

public class SearchAuditAndExceptionDBServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public SearchAuditAndExceptionDBServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		PoolDataSource dbConnectionPool = null;
		Connection dbConnection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		try {
			if(request.getParameter("action").toString().equals("GetSearchKeyNames")){
				dbConnectionPool	= DBConnectionPool.getDBConnection();									
				dbConnection = dbConnectionPool.getConnection();
		        statement = dbConnection.createStatement();
		        
		        String srvcName = request.getParameter("srvcName");
		        String sqlQueryString = "SELECT SRCH_KY_1_NM, SRCH_KY_2_NM, SRCH_KY_3_NM, SRCH_KY_4_NM, SRCH_KY_5_NM FROM SERVICE_ATTRIBUTES_T WHERE SRVC_NM = '" + srvcName + "'";
		        resultSet = statement.executeQuery(sqlQueryString);
		        
		        String searchKeyNm1 = null;
		        String searchKeyNm2 = null;
		        String searchKeyNm3 = null;
		        String searchKeyNm4 = null;
		        String searchKeyNm5 = null;
		        
		        while (resultSet.next()) {
			        searchKeyNm1 = resultSet.getString(1);
			        searchKeyNm2 = resultSet.getString(2);
			        searchKeyNm3 = resultSet.getString(3);
			        searchKeyNm4 = resultSet.getString(4);
			        searchKeyNm5 = resultSet.getString(5);
		        }
		        
		        JSONObject searchKeyNames = new JSONObject();
		        searchKeyNames.put("searchKeyNm1", searchKeyNm1);
		        searchKeyNames.put("searchKeyNm2", searchKeyNm2);
		        searchKeyNames.put("searchKeyNm3", searchKeyNm3);
		        searchKeyNames.put("searchKeyNm4", searchKeyNm4);
		        searchKeyNames.put("searchKeyNm5", searchKeyNm5);
		        
		        PrintWriter printWriter = response.getWriter();
		        printWriter.print(searchKeyNames);
			}
			else if(request.getParameter("action").toString().equals("GetAuditTrail")){

				String startRowNum = request.getParameter("startRowNum");
				String endRowNum = request.getParameter("endRowNum");
				String searchCriteria = request.getParameter("searchCriteria");
				String srvcName = request.getParameter("srvcName");

				String searchKey1 = request.getParameter("searchkey1");
				if (searchKey1 != null && searchKey1.equals("/") ){
					searchKey1 = "";
				}
				String searchKey2 = request.getParameter("searchkey2");
				if (searchKey2 != null && searchKey2.equals("/") ){
					searchKey2 = "";
				}				
				String searchKey3 = request.getParameter("searchkey3");
				if (searchKey3 != null && searchKey3.equals("/") ){
					searchKey3 = "";
				}				
				String searchKey4 = request.getParameter("searchkey4");
				if (searchKey4 != null && searchKey4.equals("/") ){
					searchKey4 = "";
				}				
				String searchKey5 = request.getParameter("searchkey5");	
				if (searchKey5 != null && searchKey5.equals("/") ){
					searchKey5 = "";
				}				
				String startDate = request.getParameter("dpStartDate");
				if (startDate != null && startDate.equals("/") ){
					startDate = "";
				}		
				String startTime = request.getParameter("dpStartTime");
				if (startTime != null && startTime.equals("/") ){
					startTime = "";
				}		
				String endDate = request.getParameter("dpEndDate");
				if (endDate != null && endDate.equals("/") ){
					endDate = "";
				}		
				String endTime = request.getParameter("dpEndTime");		
				if (endTime != null && endTime.equals("/") ){
					endTime = "";
				}		
				String genSrchStr = request.getParameter("genSrchStr");		
				if (genSrchStr != null && genSrchStr.equals("/") ){
					genSrchStr = "";
				}		

				List<EventPointData> dbQueryResult = null;
				if ("rKeyFields".equals(searchCriteria)) {
					dbQueryResult = new SearchForAuditTrailOnSearchKeys().getAuditList(
															srvcName, searchKey1, searchKey2, searchKey3,
															searchKey4, searchKey5, startRowNum, endRowNum);
				} else if ("rDateRange".equals(searchCriteria)) {
					dbQueryResult =
							new SearchForAuditTrailOnDateRange()
									.getAuditList(srvcName, startDate, startTime,
											endDate, endTime, startRowNum, endRowNum);
				} else if ("rGenSearchStr".equals(searchCriteria)) {
					dbQueryResult =
							new SearchForAuditTrailOnGenSearchString()
									.getAuditList(srvcName, genSrchStr, startRowNum, endRowNum);
				}
				else if ("rDateRangeAndGenSearchStr".equals(searchCriteria)) {
					dbQueryResult =
							new SearchForAuditTrailOnGenSrchStrDtRngCombo()
									.getAuditList(srvcName, genSrchStr, startDate, startTime, endDate,
											endTime, startRowNum, endRowNum);
				}
				else {
					dbQueryResult =
							new SearchForAuditTrailOnSrchKeyDtRngCombo().getAuditList(srvcName,
									searchKey1, searchKey2, searchKey3, searchKey4,
									searchKey5, startDate, startTime, endDate,
									endTime, startRowNum, endRowNum);
				}
				
                Iterator<EventPointData> epdIterator = dbQueryResult.iterator();
                JSONArray audRowsArrayJson = new JSONArray();
				while (epdIterator.hasNext()) {
					JSONObject audRowJson = new JSONObject();
					EventPointData eventPointData = epdIterator.next();
			        audRowJson.put("ROW_NUM", eventPointData.getROW_NUM());
			        audRowJson.put("TRANSACTION_ID", eventPointData.getTRANSACTION_ID());
			        audRowJson.put("SERVICE_NM", eventPointData.getSERVICE_NM());
			        audRowJson.put("SEARCH_KEY_1", eventPointData.getSEARCH_KEY_1());
			        audRowJson.put("SEARCH_KEY_2", eventPointData.getSEARCH_KEY_2());
			        audRowJson.put("SEARCH_KEY_3", eventPointData.getSEARCH_KEY_3());
			        audRowJson.put("SEARCH_KEY_4", eventPointData.getSEARCH_KEY_4());
			        audRowJson.put("SEARCH_KEY_5", eventPointData.getSEARCH_KEY_5());
			        audRowJson.put("BRKR_NAME", eventPointData.getBRKR_NAME());
			        audRowJson.put("EG_NAME", eventPointData.getEG_NAME());
			        audRowJson.put("MSGFLOW_NM", eventPointData.getMSGFLOW_NM());
			        audRowJson.put("NODE_NM", eventPointData.getNODE_NM());
			        audRowJson.put("START_TIME", eventPointData.getSTART_TIME());
			        audRowJson.put("END_TIME", eventPointData.getEND_TIME());
			        audRowJson.put("ELAPSED_TIME", eventPointData.getELAPSED_TIME());
			        audRowJson.put("STATUS", eventPointData.getSTATUS()	);
			        audRowsArrayJson.put(audRowJson);
				}
				JSONObject audTrailHeader = new JSONObject();
				audTrailHeader.put("audTrailHeader", audRowsArrayJson);
				
		        PrintWriter printWriter = response.getWriter();
		        printWriter.print(audTrailHeader);
			} else {
				String startRowNum = request.getParameter("startRowNum");
				String endRowNum = request.getParameter("endRowNum");
				String searchCriteria = request.getParameter("searchCriteria");
				String srvcName = request.getParameter("srvcName");

				String searchKey1 = request.getParameter("searchkey1");
				if (searchKey1 != null && searchKey1.equals("/") ){
					searchKey1 = "";
				}
				String searchKey2 = request.getParameter("searchkey2");
				if (searchKey2 != null && searchKey2.equals("/") ){
					searchKey2 = "";
				}				
				String searchKey3 = request.getParameter("searchkey3");
				if (searchKey3 != null && searchKey3.equals("/") ){
					searchKey3 = "";
				}				
				String searchKey4 = request.getParameter("searchkey4");
				if (searchKey4 != null && searchKey4.equals("/") ){
					searchKey4 = "";
				}				
				String searchKey5 = request.getParameter("searchkey5");	
				if (searchKey5 != null && searchKey5.equals("/") ){
					searchKey5 = "";
				}				
				String startDate = request.getParameter("dpStartDate");
				if (startDate != null && startDate.equals("/") ){
					startDate = "";
				}		
				String startTime = request.getParameter("dpStartTime");
				if (startTime != null && startTime.equals("/") ){
					startTime = "";
				}		
				String endDate = request.getParameter("dpEndDate");
				if (endDate != null && endDate.equals("/") ){
					endDate = "";
				}		
				String endTime = request.getParameter("dpEndTime");		
				if (endTime != null && endTime.equals("/") ){
					endTime = "";
				}
				String genSrchStr = request.getParameter("genSrchStr");		
				if (genSrchStr != null && genSrchStr.equals("/") ){
					genSrchStr = "";
				}

				List<ExceptionData> dbQueryResult = null;
				if ("rKeyFields".equals(searchCriteria)) {
					dbQueryResult = new SearchForExceptionOnSearchKeys().getExceptionList(
															srvcName, searchKey1, searchKey2, searchKey3,
															searchKey4, searchKey5, startRowNum, endRowNum);
				} else if ("rDateRange".equals(searchCriteria)) {
					dbQueryResult =
							new SearchForExceptionOnDateRange()
									.getExceptionList(srvcName, startDate, startTime,
											endDate, endTime, startRowNum, endRowNum);
				} else if ("rGenSearchStr".equals(searchCriteria)) {
					dbQueryResult =
							new SearchForExceptionOnGenSearchString()
									.getExceptionList(srvcName, genSrchStr, startRowNum, endRowNum);
				} else if ("rDateRangeAndGenSearchStr".equals(searchCriteria)) {
					dbQueryResult =
							new SearchForExceptionOnGenSrchStrDtRngCombo()
									.getExceptionList(srvcName, genSrchStr, startDate, startTime, endDate,
											endTime, startRowNum, endRowNum);
				} else {
					dbQueryResult =
							new SearchForExceptionOnSrchKeyDtRngCombo().getExceptionList(srvcName,
									searchKey1, searchKey2, searchKey3, searchKey4,
									searchKey5, startDate, startTime, endDate,
									endTime, startRowNum, endRowNum);
				}
				
                Iterator<ExceptionData> epdIterator = dbQueryResult.iterator();
                JSONArray exceptionRowsArrayJson = new JSONArray();
				while (epdIterator.hasNext()) {
					JSONObject exceptionRowJson = new JSONObject();
					ExceptionData exceptionData = epdIterator.next();
					exceptionRowJson.put("ROW_NUM", exceptionData.getROW_NUM());
					exceptionRowJson.put("TRANSACTION_ID", exceptionData.getTRANSACTION_ID());
					exceptionRowJson.put("MSG_ID", exceptionData.getMSG_ID());
					exceptionRowJson.put("SERVICE_NM", exceptionData.getSERVICE_NM());
					exceptionRowJson.put("SEARCH_KEY_1", exceptionData.getSEARCH_KEY_1());
					exceptionRowJson.put("SEARCH_KEY_2", exceptionData.getSEARCH_KEY_2());
					exceptionRowJson.put("SEARCH_KEY_3", exceptionData.getSEARCH_KEY_3());
					exceptionRowJson.put("SEARCH_KEY_4", exceptionData.getSEARCH_KEY_4());
					exceptionRowJson.put("SEARCH_KEY_5", exceptionData.getSEARCH_KEY_5());
					exceptionRowJson.put("BRKR_NAME", exceptionData.getBRKR_NAME());
					exceptionRowJson.put("EG_NAME", exceptionData.getEG_NAME());
					exceptionRowJson.put("MSGFLOW_NM", exceptionData.getMSGFLOW_NM());
					exceptionRowJson.put("NODE_NM", exceptionData.getNODE_NM());
					exceptionRowJson.put("CREATE_TIMESTAMP", exceptionData.getCREATE_TIMESTAMP());
					exceptionRowJson.put("ERROR_CD", exceptionData.getERROR_CD());
					exceptionRowJson.put("ERROR_MSG", exceptionData.getERROR_MSG());
			        exceptionRowsArrayJson.put(exceptionRowJson);
				}
				JSONObject exceptionTrailHeader = new JSONObject();
				exceptionTrailHeader.put("exceptionHeader", exceptionRowsArrayJson);
				
		        PrintWriter printWriter = response.getWriter();
		        printWriter.print(exceptionTrailHeader);
			}
			
		}
		catch (Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if (resultSet != null) {
					resultSet.close();
				}
				if (statement != null) {
					statement.close();
				}
				if (dbConnection != null) {
					dbConnection.close();
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
	}

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		try {
			String searchCriteria = request.getParameter("searchoptionsdropdown").toString();
			String srvcName = request.getParameter("servicenamedropdown").toString();
			String startRowNum = "1";
			String endRowNum = "250";
			
			String searchKey1 = request.getParameter("searchkey1");
			if (searchKey1 == null){
				searchKey1 = "";
			}
			String searchKey2 = request.getParameter("searchkey2");
			if (searchKey2 == null){
				searchKey2 = "";
			}				
			String searchKey3 = request.getParameter("searchkey3");
			if (searchKey3 == null){
				searchKey3 = "";
			}				
			String searchKey4 = request.getParameter("searchkey4");
			if (searchKey4 == null){
				searchKey4 = "";
			}				
			String searchKey5 = request.getParameter("searchkey5");	
			if (searchKey5 == null){
				searchKey5 = "";
			}				
			String startDate = request.getParameter("dpStartDate");
			if (startDate == null){
				startDate = "";
			}		
			String startTime = request.getParameter("dpStartTime");
			if (startTime == null){
				startTime = "";
			}		
			String endDate = request.getParameter("dpEndDate");
			if (endDate == null){
				endDate = "";
			}		
			String endTime = request.getParameter("dpEndTime");		
			if (endTime == null){
				endTime = "";
			}	
			String genSrchStr = request.getParameter("genSrchStr");		
			if (genSrchStr != null && genSrchStr.equals("/") ){
				genSrchStr = "";
			}
			
			request.setAttribute("searchCriteria", searchCriteria);
			request.setAttribute("srvcName", srvcName);
			request.setAttribute("searchkey1", searchKey1);
			request.setAttribute("searchkey2", searchKey2);
			request.setAttribute("searchkey3", searchKey3);
			request.setAttribute("searchkey4", searchKey4);
			request.setAttribute("searchkey5", searchKey5);
			request.setAttribute("genSrchStr", genSrchStr);
			request.setAttribute("dpStartDate", startDate);
			request.setAttribute("dpStartTime", startTime);
			request.setAttribute("dpEndDate", endDate);
			request.setAttribute("dpEndTime", endTime);	
			
			if (request.getParameter("SearchType").equals("AuditTrail")) {
				//System.out.println(searchCriteria);
				if ("rKeyFields".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForAuditTrailOnSearchKeys().getAuditList(
									srvcName, searchKey1, searchKey2, searchKey3,
									searchKey4, searchKey5, startRowNum, endRowNum));
				} else if ("rDateRange".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForAuditTrailOnDateRange()
									.getAuditList(srvcName, startDate, startTime,
											endDate, endTime, startRowNum, endRowNum));
				} else if ("rGenSearchStr".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForAuditTrailOnGenSearchString()
									.getAuditList(srvcName, genSrchStr, startRowNum, endRowNum));
				} else if ("rDateRangeAndGenSearchStr".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForAuditTrailOnGenSrchStrDtRngCombo()
									.getAuditList(srvcName, genSrchStr, startDate, startTime, endDate,
											endTime, startRowNum, endRowNum));
				} 
				else {
					request.setAttribute("resultSet",
							new SearchForAuditTrailOnSrchKeyDtRngCombo().getAuditList(srvcName,
									searchKey1, searchKey2, searchKey3, searchKey4,
									searchKey5, startDate, startTime, endDate,
									endTime, startRowNum, endRowNum));
				}
				getServletConfig().getServletContext()
						.getRequestDispatcher("/DisplayAuditTrail.jsp")
						.forward(request, response);
			} else {
				if ("rKeyFields".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForExceptionOnSearchKeys().getExceptionList(
									srvcName, searchKey1, searchKey2, searchKey3,
									searchKey4, searchKey5, startRowNum, endRowNum));
				} else if ("rDateRange".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForExceptionOnDateRange()
									.getExceptionList(srvcName, startDate, startTime,
											endDate, endTime, startRowNum, endRowNum));
				} else if ("rGenSearchStr".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForExceptionOnGenSearchString()
									.getExceptionList(srvcName, genSrchStr, startRowNum, endRowNum));
				} else if ("rDateRangeAndGenSearchStr".equals(searchCriteria)) {
					request.setAttribute("resultSet",
							new SearchForExceptionOnGenSrchStrDtRngCombo()
									.getExceptionList(srvcName, genSrchStr, startDate, startTime, endDate,
											endTime, startRowNum, endRowNum));
				} else {
					request.setAttribute("resultSet",
							new SearchForExceptionOnSrchKeyDtRngCombo().getExceptionList(srvcName,
									searchKey1, searchKey2, searchKey3, searchKey4,
									searchKey5, startDate, startTime, endDate,
									endTime, startRowNum, endRowNum));
				}
				getServletConfig().getServletContext()
						.getRequestDispatcher("/DisplayExceptions.jsp")
						.forward(request, response);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
