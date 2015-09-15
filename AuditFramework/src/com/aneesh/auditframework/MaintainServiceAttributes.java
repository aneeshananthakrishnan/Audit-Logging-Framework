package com.aneesh.auditframework;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.List;
import java.util.Properties;
import java.io.InputStream;

import javax.naming.Context;
import javax.naming.InitialContext;

import oracle.ucp.jdbc.PoolDataSourceFactory;
import oracle.ucp.jdbc.PoolDataSource;

public class MaintainServiceAttributes {

	public void maintainSrvcRepo(List<ServiceAttributes> serviceInsertList,
			List<ServiceAttributes> serviceDeleteList,
			List<ServiceAttributes> serviceUpdateList) {
		Connection dbConnection = null;
		Statement statement = null;
		try {
			PoolDataSource dbConnectionPool = DBConnectionPool.getDBConnection();
			dbConnection = dbConnectionPool.getConnection();
			dbConnection.setAutoCommit(false);
			statement = dbConnection.createStatement();

			String sqlQueryString = null;
			if (!serviceInsertList.isEmpty()) {
				for (int i = 0; i < serviceInsertList.size(); i++) {
					ServiceAttributes serviceAttributes = (ServiceAttributes) serviceInsertList.get(i);
					sqlQueryString = "INSERT INTO SERVICE_ATTRIBUTES_T "
							+ "(SRVC_NM, SRC_TYPE, SRC_NM, SRC_DETS, XFM_WS_DETS, XFM_DB_DETS, TGT_TYPE, TGT_NM, TGT_DETS, "
							+ "ADDNL_DETS, SRCH_KY_1_NM, SRCH_KY_2_NM, SRCH_KY_3_NM, SRCH_KY_4_NM, SRCH_KY_5_NM, CREATE_TIMESTAMP, MSGFLOW_NM, APPL_NM, IIBNODE_DETS) "
							+ "VALUES ('"
							+ serviceAttributes.getSRVC_NM()
							+ "', '"
							+ serviceAttributes.getSRC_TYPE()
							+ "', '"
							+ serviceAttributes.getSRC_NM()
							+ "', '"
							+ serviceAttributes.getSRC_DETS().trim()
							+ "', '"
							+ serviceAttributes.getXFM_WS_DETS().trim()
							+ "', '"
							+ serviceAttributes.getXFM_DB_DETS().trim()
							+ "', '"
							+ serviceAttributes.getTGT_TYPE()
							+ "', '"
							+ serviceAttributes.getTGT_NM()
							+ "', '"
							+ serviceAttributes.getTGT_DETS().trim()
							+ "', '"
							+ serviceAttributes.getADDNL_DETS().trim()
							+ "', '"
							+ serviceAttributes.getSRCH_KY_1_NM()
							+ "', '"
							+ serviceAttributes.getSRCH_KY_2_NM()
							+ "', '"
							+ serviceAttributes.getSRCH_KY_3_NM()
							+ "', '"
							+ serviceAttributes.getSRCH_KY_4_NM()
							+ "', '"
							+ serviceAttributes.getSRCH_KY_5_NM()
							+ "', "
							+ "SYSTIMESTAMP"
							+ ", '"
							+ serviceAttributes.getMSGFLOW_NM()
							+ "', '"
							+ serviceAttributes.getAPPL_NM()
							+ "', '"
							+ serviceAttributes.getIIBNODE_DETS().trim()
							+ "'"
							+ ")";
					// System.out.println(sqlQueryString);
					statement.executeQuery(sqlQueryString);
				}
			}

			if (!serviceDeleteList.isEmpty()) {
				for (int i = 0; i < serviceDeleteList.size(); i++) {
					ServiceAttributes serviceAttributes = (ServiceAttributes) serviceDeleteList
							.get(i);
					sqlQueryString = "DELETE FROM SERVICE_ATTRIBUTES_T WHERE SRVC_NM = '"
							+ serviceAttributes.getSRVC_NM() + "'";
					// System.out.println(sqlQueryString);
					statement.executeQuery(sqlQueryString);
				}
			}

			if (!serviceUpdateList.isEmpty()) {
				for (int i = 0; i < serviceUpdateList.size(); i++) {
					ServiceAttributes serviceAttributes = (ServiceAttributes) serviceUpdateList.get(i);
					sqlQueryString = "UPDATE SERVICE_ATTRIBUTES_T SET "
							+ " SRC_TYPE  = '"
							+ serviceAttributes.getSRC_TYPE()
							+ "', "
							+ " SRC_NM = '"
							+ serviceAttributes.getSRC_NM()
							+ "', "
							+ " SRC_DETS = '"
							+ serviceAttributes.getSRC_DETS().trim()
							+ "', "
							+ " XFM_WS_DETS = '"
							+ serviceAttributes.getXFM_WS_DETS().trim()
							+ "', "
							+ " XFM_DB_DETS =  '"
							+ serviceAttributes.getXFM_DB_DETS().trim()
							+ "', "
							+ " TGT_TYPE = '"
							+ serviceAttributes.getTGT_TYPE()
							+ "', "
							+ " TGT_NM = '"
							+ serviceAttributes.getTGT_NM()
							+ "', "
							+ " TGT_DETS = '"
							+ serviceAttributes.getTGT_DETS().trim()
							+ "', "
							+ " ADDNL_DETS = '"
							+ serviceAttributes.getADDNL_DETS().trim()
							+ "', "
							+ " SRCH_KY_1_NM = '"
							+ serviceAttributes.getSRCH_KY_1_NM()
							+ "', "
							+ " SRCH_KY_2_NM = '"
							+ serviceAttributes.getSRCH_KY_2_NM()
							+ "', "
							+ " SRCH_KY_3_NM = '"
							+ serviceAttributes.getSRCH_KY_3_NM()
							+ "', "
							+ " SRCH_KY_4_NM = '"
							+ serviceAttributes.getSRCH_KY_4_NM()
							+ "', "
							+ " SRCH_KY_5_NM = '"
							+ serviceAttributes.getSRCH_KY_5_NM()
							+ "', "
							+ " CREATE_TIMESTAMP = SYSTIMESTAMP "
							+ ", "
							+ " MSGFLOW_NM = '"
							+ serviceAttributes.getMSGFLOW_NM()
							+ "', "
							+ " APPL_NM = '"
							+ serviceAttributes.getAPPL_NM()
							+ "', "		
							+ " IIBNODE_DETS = '"
							+ serviceAttributes.getIIBNODE_DETS().trim()
							+ "' "	
							+ "WHERE "
							+ "SRVC_NM = '"
							+ serviceAttributes.getSRVC_NM()
							+ "'";
					// System.out.println(sqlQueryString);
					statement.executeQuery(sqlQueryString);
				}
			}
			dbConnection.commit();
		} catch (Exception e) {
			try {
				dbConnection.rollback();
			} catch (Exception exception) {
				exception.printStackTrace();
			}
			e.printStackTrace();
		} finally {
			try {
				statement.close();
				dbConnection.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

}
