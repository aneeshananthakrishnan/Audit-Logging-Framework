package com.aneesh.auditframework;

public class ExceptionData {

	private String ROW_NUM;
	private String TRANSACTION_ID;
	private String MSG_ID;
	private String BRKR_NAME;
	private String EG_NAME;
	private String MSGFLOW_NM;
	private String NODE_NM;
	private String ERROR_CD;
	private String ERROR_MSG;	
	private String CREATE_TIMESTAMP;	
	private String SERVICE_NM;
	private String SEARCH_KEY_1;
	private String SEARCH_KEY_2;
	private String SEARCH_KEY_3;
	private String SEARCH_KEY_4;
	private String SEARCH_KEY_5;

	/* Setter Methods */
	public void setROW_NUM(String row_num) {
		this.ROW_NUM = row_num;
	}
	public void setTRANSACTION_ID(String transaction_Id) {
		this.TRANSACTION_ID = transaction_Id;
	}	
	public void setMSG_ID(String messsage_Id) {
		this.MSG_ID = messsage_Id;
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
	public void setCREATE_TIMESTAMP(String create_TimeStamp) {
		this.CREATE_TIMESTAMP = create_TimeStamp;
	}	
	public void setNODE_NM(String node_Name) {
		this.NODE_NM = node_Name;
	}		
	public void setERROR_CD(String error_Code) {
		this.ERROR_CD = error_Code;
	}
	public void setERROR_MSG(String error_Message) {
		this.ERROR_MSG = error_Message;
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

	/* Getter Methods */
	public String getROW_NUM() {
		return this.ROW_NUM;
	}
	public String getTRANSACTION_ID() {
		return this.TRANSACTION_ID;
	}
	public String getMSG_ID() {
		return this.MSG_ID;
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
	public String getERROR_CD() {
		return this.ERROR_CD;
	}
	public String getERROR_MSG() {
		return this.ERROR_MSG;
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
	public String getCREATE_TIMESTAMP() {
		return this.CREATE_TIMESTAMP;
	}
}
