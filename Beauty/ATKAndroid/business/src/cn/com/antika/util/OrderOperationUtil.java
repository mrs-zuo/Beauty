package cn.com.antika.util;

import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.Treatment;
import cn.com.antika.bean.TreatmentGroup;

/*
 * 订单的相关检测
 * */
public class OrderOperationUtil {
	public static int getTreatmentTotalNumber(OrderInfo orderInfo) {
		int totalTreatmentNumber = 0;
		for (TreatmentGroup treatmentGroup : orderInfo.getTreatmentGroupList()) {
			List<Treatment> treatmentList = treatmentGroup.getTreatmentList();
			if (treatmentList != null && treatmentList.size() > 0)
				totalTreatmentNumber += treatmentList.size();
		}
		return totalTreatmentNumber;
	}

	public static int getTreatmentGroupTotalNumber(OrderInfo orderInfo) {
		int totalTreatmentGroupNumber = 0;
		if (orderInfo.getTreatmentGroupList() != null
				&& orderInfo.getTreatmentGroupList().size() > 0) {
			totalTreatmentGroupNumber += orderInfo.getTreatmentGroupList()
					.size();
		}
		return totalTreatmentGroupNumber;
	}
	//订单的完成状态
	public static String getOrderStatus(int orderStatus) {
		String orderStatusString = "未知状态";
		switch (orderStatus) {
		case 1:
			orderStatusString = "未完成";
			break;
		case 2:
			orderStatusString = "已完成";
			break;
		case 3:
			orderStatusString = "已取消";
			break;
		case 4:
			orderStatusString = "已终止";
			break;
		default:
			orderStatusString = "未完成";
			break;
		}
		return orderStatusString;
	}
	//订单支付状态
	public static String getOrderPayemntStatus(int orderPaymentStatus) {
		String orderPaymentStatusString = "未知状态";
		switch (orderPaymentStatus) {
		case 1:
			orderPaymentStatusString="未支付";
			break;
		case 2:
			orderPaymentStatusString="部分付";
			break;
		case 3:
			orderPaymentStatusString="已支付";
			break;
		case 4:
			orderPaymentStatusString="已退款";
			break;
		case 5:
			orderPaymentStatusString="免支付";
			break;
		}
		return orderPaymentStatusString;
	}
	//订单服务组状态
	public static String getTGStatus(int tgStatus) {
		String tgStatusString = "未知状态";
		switch (tgStatus) {
		case 1:
			tgStatusString = "进行中";
			break;
		case 2:
			tgStatusString = "已完成";
			break;
		case 3:
			tgStatusString = "已取消";
			break;
		case 4:
			tgStatusString = "已终止";
			break;
		case 5:
			tgStatusString = "待确认";
			break;
		}
		return tgStatusString;
	}
	//订单服务状态
	public static String getTreatmentStatus(int tgStatus) {
			String tgStatusString = "未知状态";
			switch (tgStatus) {
			case 1:
				tgStatusString = "进行中";
				break;
			case 2:
				tgStatusString = "已完成";
				break;
			case 3:
				tgStatusString = "已取消";
				break;
			case 4:
				tgStatusString = "已终止";
				break;
			case 5:
				tgStatusString = "待确认";
				break;
			}
			return tgStatusString;
		}
	public static  int  checkPersonAuthOrderWrite(OrderInfo orderInfo,UserInfoApplication userInfoApplication){
		//管理所有订单的权限
		int authAllOrderWrite=userInfoApplication.getAccountInfo().getAuthAllOrderWrite();
		//管理我的订单权限
		int authMyOrderWrite=userInfoApplication.getAccountInfo().getAuthMyOrderWrite();
		int accountID=userInfoApplication.getAccountInfo().getAccountId();
		int currentBranchID=userInfoApplication.getAccountInfo().getBranchId();
		int authCheckResult=0;
		if(authAllOrderWrite==1 && orderInfo.getBranchID()==currentBranchID)
			authCheckResult=1;
		else{
			if(authMyOrderWrite==1){
				if(orderInfo.getCreatorID()==accountID || orderInfo.getResponsiblePersonID()==accountID || orderInfo.getSalesID()==accountID)
					authCheckResult=1;
			}
			else
				authCheckResult=0;
		}
		return authCheckResult;
	}
	//检测编辑我的订单权限 比如 开小单 或者是预约
	public static  int  checkPersonOwnerAuthOrderWrite(UserInfoApplication userInfoApplication){
		int authMyOrderWrite=userInfoApplication.getAccountInfo().getAuthMyOrderWrite();
		int authCheckResult=0;
		if(authMyOrderWrite==1)
			authCheckResult=1;
		else{
			authCheckResult=0;
		}
		return authCheckResult;
	}
	
	public static  int  checkPersonAuthTgWrite(OrderInfo orderInfo,UserInfoApplication userInfoApplication,TreatmentGroup tg){
		//管理所有订单的权限
		int authAllOrderWrite=userInfoApplication.getAccountInfo().getAuthAllOrderWrite();
		//管理我的订单权限
		int authMyOrderWrite=userInfoApplication.getAccountInfo().getAuthMyOrderWrite();
		int accountID=userInfoApplication.getAccountInfo().getAccountId();
		int currentBranchID=userInfoApplication.getAccountInfo().getBranchId();
		int authCheckResult=0;
		if(authAllOrderWrite==1 && orderInfo.getBranchID()==currentBranchID)
			authCheckResult=1;
		else{
			if(authMyOrderWrite==1){
				if(orderInfo.getCreatorID()==accountID || orderInfo.getResponsiblePersonID()==accountID || orderInfo.getSalesID()==accountID || tg.getServicePicID()==accountID)
					authCheckResult=1;
			}
			else
			{
				authCheckResult=0;
			}
				
		}
		return authCheckResult;
	}
}
