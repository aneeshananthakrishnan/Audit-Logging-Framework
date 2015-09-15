package com.aneesh.auditframework;

public class EventPointData {

	private String ROW_NUM;
	private String TRANSACTION_ID;
	private String SERVICE_NM;
	private String SEARCH_KEY_1;
	private String SEARCH_KEY_2;
	private String SEARCH_KEY_3;
	private String SEARCH_KEY_4;
	private String SEARCH_KEY_5;
	private String BRKR_NAME;
	private String EG_NAME;
	private String MSGFLOW_NM;
	private String NODE_NM;
	private String START_TIME;
	private String END_TIME;
	private String ELAPSED_TIME;
	private String STATUS;

	/* Setter Methods */
	public void setROW_NUM(String row_num) {
		this.ROW_NUM = row_num;
	}
	public void setTRANSACTION_ID(String transaction_Id) {
		this.TRANSACTION_ID = transaction_Id;
	}
	public void setSERVICE_NM(String Service_Name) {
		this.SERVICE_NM = Service_Name;
	}
	public void setSEARCH_KEY_1(String search_Key_1) {
		this.SEARCH_KEY_1 = search_Key_1;
	}
	public void setSEARCH_KEY_2(String search_Key_2) {
		this.SEARCH_KEY_2 = search_Key_2;
	}
	public void setSEARCH_KEY_3(String search_Key_3) {
		this.SEARCH_KEY_3 = search_Key_3;
	}
	public void setSEARCH_KEY_4(String search_Key_4) {
		this.SEARCH_KEY_4 = search_Key_4;
	}
	public void setSEARCH_KEY_5(String search_Key_5) {
		this.SEARCH_KEY_5 = search_Key_5;
	}
	public void setBRKR_NAME(String broker_Name) {
		this.BRKR_NAME = broker_Name;
	}
	public void setEG_NAME(String execution_Group_Name) {
		this.EG_NAME = execution_Group_Name;
	}
	public void setMSGFLOW_NM(String message_Flow_Name) {
		this.MSGFLOW_NM = message_Flow_Name;
	}
	public void setNODE_NM(String node_Name) {
		this.NODE_NM = node_Name;
	}			
	public void setSTART_TIME(String start_Time) {
		this.START_TIME = start_Time;
	}
	public void setEND_TIME(String end_Time) {
		this.END_TIME = end_Time;
	}	
	public void setELAPSED_TIME(String elapsed_Time) {
		this.ELAPSED_TIME = elapsed_Time;
	}
	public void setSTATUS(String transaction_Status) {
		this.STATUS = transaction_Status;
	}	
	
	
	/* Getter Methods */
	public String getROW_NUM() {
		return this.ROW_NUM;
	}	
	public String getTRANSACTION_ID() {
		return this.TRANSACTION_ID;
	}
	public String getSERVICE_NM() {
		return this.SERVICE_NM;
	}	
	public String getSEARCH_KEY_1() {
		return this.SEARCH_KEY_1;
	}
	public String getSEARCH_KEY_2() {
		return this.SEARCH_KEY_2;
	}
	public String getSEARCH_KEY_3() {
		return this.SEARCH_KEY_3;
	}
	public String getSEARCH_KEY_4() {
		return this.SEARCH_KEY_4;
	}
	public String getSEARCH_KEY_5() {
		return this.SEARCH_KEY_5;
	}
	public String getBRKR_NAME() {
		return this.BRKR_NAME;
	}
	public String getEG_NAME() {
		return this.EG_NAME;
	}
	public String getMSGFLOW_NM() {
		return this.MSGFLOW_NM;
	}
	public String getNODE_NM() {
		return this.NODE_NM;
	}		
	public String getSTART_TIME() {
		return this.START_TIME;
	}
	public String getEND_TIME() {
		return this.END_TIME;
	}
	public String getELAPSED_TIME() {
		return this.ELAPSED_TIME;
	}
	public String getSTATUS() {
		return this.STATUS;
	}
}
