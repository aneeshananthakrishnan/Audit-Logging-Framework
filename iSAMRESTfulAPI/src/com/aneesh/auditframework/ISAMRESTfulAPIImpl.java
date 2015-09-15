package com.aneesh.auditframework;

import java.util.Iterator;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import sun.misc.BASE64Decoder;

import org.json.JSONObject;
import org.json.JSONException;
import org.json.JSONArray;


import oracle.ucp.jdbc.PoolDataSource;

import com.sun.jersey.api.client.ClientResponse.Status;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@Path("/transactions")
public class ISAMRESTfulAPIImpl { 
  @Path("/{ServiceName}")
  @POST
  @Consumes("application/json")
  public Response postAuditTrail(@PathParam("ServiceName") String serviceName, 
		  							@DefaultValue("") @HeaderParam("Authorization") String basicAuthStr,
		  								String txnAudTrailJSONString) 
  {
	  try{
		  if(basicAuthStr == null || basicAuthStr.equals("")){
			  return Response.status(Status.UNAUTHORIZED).entity("Authentication header parameter is missing in the request !!").build();
		  }
		  String authResponseCode = authenticateUserID(basicAuthStr, serviceName);
		  if(authResponseCode.equals("200")){
			JSONObject txnAudTrailJSON = new JSONObject(txnAudTrailJSONString) ;
			JSONObject auditTrail = txnAudTrailJSON.getJSONObject("AuditTrail");
			String searchKey1 = null;
			String searchKey2 = null;
			String searchKey3 = null;
			String searchKey4 = null;
			String searchKey5 = null;
			String genSearchStr = null;
			String payload = null;
					
			if(auditTrail.has("SEARCH_KEY_1")){
				searchKey1 = auditTrail.get("SEARCH_KEY_1").toString();
			}
			if(auditTrail.has("SEARCH_KEY_2")){
				searchKey2 = auditTrail.get("SEARCH_KEY_2").toString();
			}
			if(auditTrail.has("SEARCH_KEY_3")){
				searchKey3 = auditTrail.get("SEARCH_KEY_3").toString();
			}
			if(auditTrail.has("SEARCH_KEY_4")){
				searchKey4 = auditTrail.get("SEARCH_KEY_4").toString();
			}
			if(auditTrail.has("SEARCH_KEY_5")){
				searchKey5 = auditTrail.get("SEARCH_KEY_5").toString();
			}
			if(auditTrail.has("GENERIC_SEARCH_STRING")){
				genSearchStr = auditTrail.get("GENERIC_SEARCH_STRING").toString();
			}
			String eventSrcAddr = auditTrail.get("EVENT_SRC_ADDR").toString();
			String eventName = auditTrail.get("EVENT_NAME").toString();
			String counter = auditTrail.get("COUNTER").toString();
			String txnId = auditTrail.get("TRANSACTION_ID").toString();
			String brkrName = auditTrail.get("BRKR_NAME").toString();
			String egName = auditTrail.get("EG_NAME").toString(); 
			String mfName = auditTrail.get("MSGFLOW_NM").toString(); 
			String nodeName = auditTrail.get("NODE_NM").toString(); 
			if(auditTrail.has("PAYLOAD")){
				payload = auditTrail.get("PAYLOAD").toString();
			}
						
			if(eventSrcAddr == null || eventSrcAddr.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing EVENT_SRC_ADDR Value").build();
			}
			if(eventName == null || eventName.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing EVENT_NAME Value").build();
			}
			if(counter == null || counter.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing COUNTER Value").build();
			}
			if(txnId == null || txnId.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing TRANSACTION_ID Value").build();
			}
			if(brkrName == null || brkrName.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing BRKR_NAME Value").build();
			}
			if(egName == null || egName.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing EG_NAME Value").build();
			}
			if(mfName == null || mfName.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing MSGFLOW_NM Value").build();
			}
			if(nodeName == null || nodeName.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Missing NODE_NM Value").build();
			}
			if(serviceName == null || serviceName.equals("")){
				return Response.status(Status.BAD_REQUEST).entity("Specify SERVICE_NM Value in URL !!").build();
			}
			if((searchKey1 == null || searchKey1.equals("")) && 
					(searchKey2 == null || searchKey2.equals("")) && 
						(searchKey3 == null || searchKey3.equals("")) && 
							(searchKey4 == null || searchKey4.equals("")) && 
								(searchKey5 == null || searchKey5.equals(""))){
				return Response.status(Status.BAD_REQUEST).entity("Value need to be provided for at-least one Seqrch Key !!").build();
			}
			InsertAuditTrailRecord insertAuditTrailRecord = new InsertAuditTrailRecord();
			insertAuditTrailRecord.insetAuditTrailRecordintoDB(serviceName, searchKey1,
																searchKey2, searchKey3, searchKey4,
																searchKey5, genSearchStr, eventSrcAddr, 
																eventName, counter, txnId, 
																brkrName, egName, mfName, 
																nodeName, payload);
			return Response.status(Status.OK).entity("Transaction audit trail record successfully inserted into Audit database").build();
		  }
		  else if (authResponseCode.equals("401")) {
			  return Response.status(Status.UNAUTHORIZED).entity("Authentication failed for the User ID !!").build();
		  }
		  else if (authResponseCode.equals("403")) {
			  return Response.status(Status.FORBIDDEN).entity("User ID is not authorized to access the service !!").build();
		  }
	  } catch (Exception e) {
		  e.printStackTrace();
		  return Response.status(Status.INTERNAL_SERVER_ERROR).entity(e.getMessage()).build();
	  }
	  
	  return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Request failed due to some internal server error !!").build();
  }

  @Path("/{ServiceName}/All")
  @GET
  @Produces("application/json")
  public Response getAuditTrailForAllTransactions(@PathParam("ServiceName") String serviceName,
		  											@DefaultValue("") @HeaderParam("Authorization") String basicAuthStr
													  ) throws JSONException 
  {
	  if(basicAuthStr == null || basicAuthStr.equals("")){
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication header parameter is missing in the request !!").build();
	  }
	  String authResponseCode = authenticateUserID(basicAuthStr, serviceName);
	  if(authResponseCode.equals("200")){
		   List<EventPointData> dbQueryResult = new GetAuditTrailOfAllTxns().getAuditList(serviceName);
		   JSONObject audTrailHeader = createResponseJSON(dbQueryResult);
		   return Response.status(Status.OK).entity(audTrailHeader.toString()).build();
	  }
	  else if (authResponseCode.equals("401")) {
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication failed for the User ID !!").build();
	  }
	  else if (authResponseCode.equals("403")) {
		  return Response.status(Status.FORBIDDEN).entity("User ID is not authorized to access the service !!").build();
	  }
	  return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Request failed due to some internal server error !!").build();
  }

  @Path("/{ServiceName}/DateRange")
  @GET
  @Produces("application/json")
  public Response getAuditTrailForDateRange(
		  @PathParam("ServiceName") String serviceName,
		  	@DefaultValue("") @HeaderParam("Authorization") String basicAuthStr,
		  		@DefaultValue("") @QueryParam("StartDateTime") String StartDateTime,
		  			@DefaultValue("") @QueryParam("EndDateTime") String EndDateTime
		  				) throws JSONException 
  {
	  if(basicAuthStr == null || basicAuthStr.equals("")){
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication header parameter is missing in the request !!").build();
	  }
	  String authResponseCode = authenticateUserID(basicAuthStr, serviceName);
	  if(authResponseCode.equals("200")){
		  if(StartDateTime.equals("") && EndDateTime.equals("")){
			  	return Response.status(Status.BAD_REQUEST).entity("Missing Queryparam Values").build();
		  } else {
				List<EventPointData> dbQueryResult = new SearchForAuditTrailOnDateRange().getAuditList(
							serviceName, 
							StartDateTime.substring(0, StartDateTime.indexOf("T") - 1), 
							StartDateTime.substring(StartDateTime.indexOf("T") + 1, StartDateTime.length()),
							EndDateTime.substring(0, EndDateTime.indexOf("T") - 1), 
							EndDateTime.substring(EndDateTime.indexOf("T") + 1, EndDateTime.length()),
							"1", 
							"2500"
						);
				JSONObject audTrailHeader = createResponseJSON(dbQueryResult);
				return Response.status(Status.OK).entity(audTrailHeader.toString()).build();
		  }		  
	  }
	  else if (authResponseCode.equals("401")) {
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication failed for the User ID !!").build();
	  }
	  else if (authResponseCode.equals("403")) {
		  return Response.status(Status.FORBIDDEN).entity("User ID is not authorized to access the service !!").build();
	  }
	  return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Request failed due to some internal server error !!").build();
  }

  @Path("/{ServiceName}/SearchKeys")
  @GET
  @Produces("application/json")
  public Response getAuditTrailForSearchKeys(
		  @PathParam("ServiceName") String serviceName,
		  	@DefaultValue("") @HeaderParam("Authorization") String basicAuthStr,
		  		@DefaultValue("") @QueryParam("SearchKey1") String SearchKey1,
		  			@DefaultValue("") @QueryParam("SearchKey2") String SearchKey2,
		  				@DefaultValue("") @QueryParam("SearchKey3") String SearchKey3,
		  					@DefaultValue("") @QueryParam("SearchKey4") String SearchKey4,
		  						@DefaultValue("") @QueryParam("SearchKey5") String SearchKey5
		  							) throws JSONException 
  {
	  if(basicAuthStr == null || basicAuthStr.equals("")){
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication header parameter is missing in the request !!").build();
	  }
	  String authResponseCode = authenticateUserID(basicAuthStr, serviceName);
	  if(authResponseCode.equals("200")){
		  if(SearchKey1.equals("") && SearchKey2.equals("")
				  && SearchKey3.equals("") && SearchKey4.equals("") && SearchKey5.equals(""))
		  {
			  	return Response.status(Status.BAD_REQUEST).entity("Missing Queryparam Values").build();
		  } else {
				List<EventPointData> dbQueryResult = new SearchForAuditTrailOnSearchKeys().getAuditList(
							serviceName,
							SearchKey1, 
							SearchKey2, 
							SearchKey3, 
							SearchKey4, 
							SearchKey5,
							"1", 
							"2500"
						);
				JSONObject audTrailHeader = createResponseJSON(dbQueryResult);
				return Response.status(Status.OK).entity(audTrailHeader.toString()).build();
		  }		  
	  }
	  else if (authResponseCode.equals("401")) {
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication failed for the User ID !!").build();
	  }
	  else if (authResponseCode.equals("403")) {
		  return Response.status(Status.FORBIDDEN).entity("User ID is not authorized to access the service !!").build();
	  }
	  return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Request failed due to some internal server error !!").build();
  }

  @Path("/{ServiceName}/GenericSearchString")
  @GET
  @Produces("application/json")
  public Response getAuditTrailForGenSrchStr(
		  @PathParam("ServiceName") String serviceName,
		  	@DefaultValue("") @HeaderParam("Authorization") String basicAuthStr,
		  		@DefaultValue("") @QueryParam("GenSearchStr") String genSearchStr
		  			) throws JSONException 
  {
	  if(basicAuthStr == null || basicAuthStr.equals("")){
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication header parameter is missing in the request !!").build();
	  }
	  String authResponseCode = authenticateUserID(basicAuthStr, serviceName);
	  if(authResponseCode.equals("200")){
		  if(genSearchStr.equals(""))
		  {
			  	return Response.status(Status.BAD_REQUEST).entity("Missing Queryparam Values").build();
		  } else {
				List<EventPointData> dbQueryResult = new SearchForAuditTrailOnGenSearchString().getAuditList(
							serviceName,
							genSearchStr,
							"1", 
							"2500"
						);
				JSONObject audTrailHeader = createResponseJSON(dbQueryResult);
				return Response.status(Status.OK).entity(audTrailHeader.toString()).build();
		  }		  
	  }
	  else if (authResponseCode.equals("401")) {
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication failed for the User ID !!").build();
	  }
	  else if (authResponseCode.equals("403")) {
		  return Response.status(Status.FORBIDDEN).entity("User ID is not authorized to access the service !!").build();
	  }
	  return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Request failed due to some internal server error !!").build();
  }
  
  
  @Path("/{ServiceName}/GenericSearchStringDateRangeCombo")
  @GET
  @Produces("application/json")
  public Response getAuditTrailForGenSrchStrDtRngCombo(
		  @PathParam("ServiceName") String serviceName,
		  	@DefaultValue("") @HeaderParam("Authorization") String basicAuthStr,
		  		@DefaultValue("") @QueryParam("GenSearchStr") String genSearchStr,
		  			@DefaultValue("") @QueryParam("StartDateTime") String StartDateTime,
		  				@DefaultValue("") @QueryParam("EndDateTime") String EndDateTime
		  			) throws JSONException 
  {
	  if(basicAuthStr == null || basicAuthStr.equals("")){
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication header parameter is missing in the request !!").build();
	  }
	  String authResponseCode = authenticateUserID(basicAuthStr, serviceName);
	  if(authResponseCode.equals("200")){
		  if(genSearchStr.equals(""))
		  {
			  	return Response.status(Status.BAD_REQUEST).entity("Missing Queryparam Values").build();
		  } else {
				List<EventPointData> dbQueryResult = new SearchForAuditTrailOnGenSrchStrDtRngCombo().getAuditList(
							serviceName,
							genSearchStr,
							StartDateTime.substring(0, StartDateTime.indexOf("T")), 
							StartDateTime.substring(StartDateTime.indexOf("T") + 1, StartDateTime.length()),
							EndDateTime.substring(0, EndDateTime.indexOf("T")), 
							EndDateTime.substring(EndDateTime.indexOf("T") + 1, EndDateTime.length()),
							"1", 
							"2500"
						);
				JSONObject audTrailHeader = createResponseJSON(dbQueryResult);
				return Response.status(Status.OK).entity(audTrailHeader.toString()).build();
		  }		  
	  }
	  else if (authResponseCode.equals("401")) {
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication failed for the User ID !!").build();
	  }
	  else if (authResponseCode.equals("403")) {
		  return Response.status(Status.FORBIDDEN).entity("User ID is not authorized to access the service !!").build();
	  }
	  return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Request failed due to some internal server error !!").build();
  }  
  
  @Path("/{ServiceName}/SearchKeysDateRangeCombo")
  @GET
  @Produces("application/json")
  public Response getAuditTrailForCombo(
		  @PathParam("ServiceName") String serviceName,
		  	@DefaultValue("") @HeaderParam("Authorization") String basicAuthStr,
		  		@DefaultValue("") @QueryParam("SearchKey1") String SearchKey1,
		  			@DefaultValue("") @QueryParam("SearchKey2") String SearchKey2,
		  				@DefaultValue("") @QueryParam("SearchKey3") String SearchKey3,
		  					@DefaultValue("") @QueryParam("SearchKey4") String SearchKey4,
		  						@DefaultValue("") @QueryParam("SearchKey5") String SearchKey5,
		  							@DefaultValue("") @QueryParam("StartDateTime") String StartDateTime,
		  								@DefaultValue("") @QueryParam("EndDateTime") String EndDateTime
		  									) throws JSONException 
  {
	  if(basicAuthStr == null || basicAuthStr.equals("")){
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication header parameter is missing in the request !!").build();
	  }
	  String authResponseCode = authenticateUserID(basicAuthStr, serviceName);
	  if(authResponseCode.equals("200"))
	  {
		  if(SearchKey1.equals("") && SearchKey2.equals("")
				  && SearchKey3.equals("") && SearchKey4.equals("") && SearchKey5.equals("")
				  && StartDateTime.equals("") && EndDateTime.equals(""))
		  {
			  	return Response.status(Status.BAD_REQUEST).entity("Missing Queryparam Values").build();
		  } else {
				List<EventPointData> dbQueryResult = new SearchForAuditTrailOnSrchKeyDtRngCombo().getAuditList(
							serviceName,
							SearchKey1, 
							SearchKey2, 
							SearchKey3, 
							SearchKey4, 
							SearchKey5, 
							StartDateTime.substring(0, StartDateTime.indexOf("T")), 
							StartDateTime.substring(StartDateTime.indexOf("T") + 1, StartDateTime.length()),
							EndDateTime.substring(0, EndDateTime.indexOf("T")), 
							EndDateTime.substring(EndDateTime.indexOf("T") + 1, EndDateTime.length()),
							"1", 
							"2500"
						);
				JSONObject audTrailHeader = createResponseJSON(dbQueryResult);
				return Response.status(Status.OK).entity(audTrailHeader.toString()).build();
		  }		  
	  }
	  else if (authResponseCode.equals("401")) {
		  return Response.status(Status.UNAUTHORIZED).entity("Authentication failed for the User ID !!").build();
	  }
	  else if (authResponseCode.equals("403")) {
		  return Response.status(Status.FORBIDDEN).entity("User ID is not authorized to access the service !!").build();
	  }
	  return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Request failed due to some internal server error !!").build();
  }
  
  public JSONObject createResponseJSON(List<EventPointData> dbQueryResult) throws JSONException{
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
		audTrailHeader.put("AuditTrail", audRowsArrayJson);
		return audTrailHeader;
  }
  
  private String authenticateUserID(String basicAuthStr, String serviceName){
	  String decodedAuthString = "";
	  Connection dbConnection = null;
	  Statement statement = null;
	  String sqlQueryString = null;
	  ResultSet resultSet = null;
	  try {
			String authInfo = basicAuthStr.split("\\s+")[1];
			byte[] bytes = null;

			bytes = new BASE64Decoder().decodeBuffer(authInfo);
			decodedAuthString = new String(bytes);
			//System.out.println(decodedAuthString);

			String[] userId_Pwd = decodedAuthString.split(":");
			String userId = userId_Pwd[0];
			String pwd = userId_Pwd[1];

			PoolDataSource dbConnectionPool = DBConnectionPool.getDBConnection();
			dbConnection = dbConnectionPool.getConnection();
			statement = dbConnection.createStatement();

			String pwdInDB = null;
			String accessLvlInDB = null;
			String srvcAccessLvlInDB = null;
			sqlQueryString = "SELECT PASSWORD, ACCESS_LVL FROM USER_CREDS_T WHERE USER_NM = '"	+ userId + "'";
			resultSet = statement.executeQuery(sqlQueryString);
			while (resultSet.next()) {
				pwdInDB = resultSet.getString("PASSWORD");
				accessLvlInDB = resultSet.getString("ACCESS_LVL");
			}
			
			sqlQueryString = "SELECT ACCESS_LVL FROM SERVICE_NAMES_T WHERE SRVC_NM = '"	+ serviceName + "'";
			resultSet = statement.executeQuery(sqlQueryString);
			while (resultSet.next()) {
				srvcAccessLvlInDB = resultSet.getString("ACCESS_LVL");
			}
			//System.out.println("Password: '" + pwd + "'");
			//System.out.println(new EncryptPassword().getEncryptedPassword(pwd));
			//System.out.println(pwdInDB);
			if (!(new EncryptPassword().getEncryptedPassword(pwd).equals(pwdInDB))){
				return "401";
			} else if (Integer.parseInt(accessLvlInDB) < Integer.parseInt(srvcAccessLvlInDB)){
				return "403";
			} 		  
	  } catch (Exception e) {
	      e.printStackTrace();
	      return "500";
	  } finally {
			try {
				statement.close();
				dbConnection.close();
				resultSet.close();
			} catch (Exception e) {
				e.printStackTrace();
				return "500";
			}

	  }
	  return "200";
  }
	
}
