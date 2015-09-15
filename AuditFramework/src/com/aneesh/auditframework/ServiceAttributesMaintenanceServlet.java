package com.aneesh.auditframework;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.*;

public class ServiceAttributesMaintenanceServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public ServiceAttributesMaintenanceServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			int tableRowCnt = Integer.parseInt(request.getParameter("serviceListRowCnt"));
			int tableColCnt = Integer.parseInt(request.getParameter("serviceListColCnt"));
			List<ServiceAttributes> serviceInsertList = new ArrayList<ServiceAttributes>();
			List<ServiceAttributes> serviceUpdateList = new ArrayList<ServiceAttributes>();
			List<ServiceAttributes> serviceDeleteList = new ArrayList<ServiceAttributes>();
			MaintainServiceAttributes maintainServiceAttributes = new MaintainServiceAttributes();
			for (int i = 1; i < tableRowCnt; i++) {
				ServiceAttributes serviceAttributes = new ServiceAttributes();
				for (int j = 0; j < tableColCnt; j++) {
					//System.out.println("Row-" + i + "_Col-" + j +":" + request.getParameter("Row-" + i + "_Col-" + j));
					if (j == 2) {
						serviceAttributes.setSRVC_NM(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 3) {
						serviceAttributes.setAPPL_NM(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 4) {
						serviceAttributes.setIIBNODE_DETS(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 5) {
						serviceAttributes.setMSGFLOW_NM(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 6) {
						serviceAttributes.setSRC_TYPE(request.getParameter("Row-" + i + "_Col-" + j));						
					} else if (j == 7) {
						serviceAttributes.setSRC_NM(request.getParameter("Row-"	+ i + "_Col-" + j));
					} else if (j == 8) {
						serviceAttributes.setSRC_DETS(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 9) {
						serviceAttributes.setXFM_WS_DETS(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 10) {
						serviceAttributes.setXFM_DB_DETS(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 11) {
						serviceAttributes.setTGT_TYPE(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 12) {
						serviceAttributes.setTGT_NM(request.getParameter("Row-"	+ i + "_Col-" + j));
					} else if (j == 13) {
						serviceAttributes.setTGT_DETS(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 14) {
						serviceAttributes.setADDNL_DETS(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 15) {
						serviceAttributes.setSRCH_KY_1_NM(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 16) {
						serviceAttributes.setSRCH_KY_2_NM(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 17) {
						serviceAttributes.setSRCH_KY_3_NM(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 18) {
						serviceAttributes.setSRCH_KY_4_NM(request.getParameter("Row-" + i + "_Col-" + j));
					} else if (j == 19) {
						serviceAttributes.setSRCH_KY_5_NM(request.getParameter("Row-" + i + "_Col-" + j));
					}
				}
				if ((request.getParameter("Row-" + i + "_Col-0").equals("setRowToDelete"))
						&& ((request.getParameter("Row-" + i + "_Col-1").equals("existingRowEditNotSet")) || (request
								.getParameter("Row-" + i + "_Col-1").equals("existingRowEditSet")))) {
					serviceDeleteList.add(serviceAttributes);
				} else if ((request.getParameter("Row-" + i + "_Col-0").equals("newRowDeleteNotSet"))
						&& (request.getParameter("Row-" + i + "_Col-1").equals("newRowEditNotSet"))) {
					serviceInsertList.add(serviceAttributes);
				} else if ((request.getParameter("Row-" + i + "_Col-0").equals("existingRowDeleteNotSet") )
						&& (request.getParameter("Row-" + i + "_Col-1").equals("existingRowEditSet"))) {
					serviceUpdateList.add(serviceAttributes);
				}
			}
			maintainServiceAttributes.maintainSrvcRepo(serviceInsertList, serviceDeleteList, serviceUpdateList);
			getServletConfig().getServletContext()
			.getRequestDispatcher("/DisplayServiceAttributes.jsp")
			.forward(request, response);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
