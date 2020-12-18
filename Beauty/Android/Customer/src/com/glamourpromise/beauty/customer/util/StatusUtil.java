package com.glamourpromise.beauty.customer.util;

import com.glamourpromise.beauty.customer.R;

import android.content.Context;

public class StatusUtil {
	public StatusUtil() {

	}

	public static String PaymentStatusUtil(Context context, int value) {
		String status = "";
		switch (value) {
		case 1:
			status = context.getString(R.string.order_ispaid_1);
			break;
		case 2:
			status = context.getString(R.string.order_ispaid_2);
			break;
		case 3:
			status = context.getString(R.string.order_ispaid_3);
			break;
		case 4:
			status = context.getString(R.string.order_ispaid_4);
			break;
		case 5:
			status = context.getString(R.string.order_ispaid_5);
			break;
		}
		;
		return status;
	}

	public static String OrderStatusUtil(Context mContext, int value) {
		String orderStatus = "";
		switch (value) {
		case 1:
			orderStatus = mContext.getString(R.string.order_status_1);
			break;
		case 2:
			orderStatus = mContext.getString(R.string.order_status_2);
			break;
		case 3:
			orderStatus = mContext.getString(R.string.order_status_3);
			break;
		case 4:
			orderStatus = mContext.getString(R.string.order_status_4);
			break;
		default:
			orderStatus = mContext.getString(R.string.order_status_1);
			break;
		}
		;
		return orderStatus;
	}

	public static String PaymentStatusUtil(Context context, String valueStr) {
		String status = "";
		int value = Integer.valueOf(valueStr);
		switch (value) {
		case 1:
			status = context.getString(R.string.order_ispaid_1);
			break;
		case 2:
			status = context.getString(R.string.order_ispaid_2);
			break;
		case 3:
			status = context.getString(R.string.order_ispaid_3);
			break;
		case 4:
			status = context.getString(R.string.order_ispaid_4);
			break;
		case 5:
			status = context.getString(R.string.order_ispaid_5);
			break;
		}
		;
		return status;
	}

	public static String OrderStatusUtil(Context mContext, String valueStr) {
		String orderStatus = "";
		int value = Integer.valueOf(valueStr);
		switch (value) {
		case 1:
			orderStatus = mContext.getString(R.string.order_status_1);
			break;
		case 2:
			orderStatus = mContext.getString(R.string.order_status_2);
			break;
		case 3:
			orderStatus = mContext.getString(R.string.order_status_3);
			break;
		case 4:
			orderStatus = mContext.getString(R.string.order_status_4);
			break;
		default:
			orderStatus = mContext.getString(R.string.order_status_1);
			break;
		}
		;
		return orderStatus;
	}

	public static String TGStatusUtil(Context mContext, String valueStr) {
		String tgStatus = "";
		int value = Integer.valueOf(valueStr);
		switch (value) {
		case 1:
			tgStatus = mContext.getString(R.string.tg_status_1);
			break;
		case 2:
			tgStatus = mContext.getString(R.string.tg_status_2);
			break;
		case 3:
			tgStatus = mContext.getString(R.string.tg_status_3);
			break;
		case 4:
			tgStatus = mContext.getString(R.string.tg_status_4);
			break;
		case 5:
			tgStatus = mContext.getString(R.string.tg_status_5);
			break;
		default:
			tgStatus = mContext.getString(R.string.tg_status_1);
			break;
		}
		;
		return tgStatus;
	}

	public static String TGStatusUtil(Context mContext, int value) {
		String tgStatus = "";
		switch (value) {
		case 1:
			tgStatus = mContext.getString(R.string.tg_status_1);
			break;
		case 2:
			tgStatus = mContext.getString(R.string.tg_status_2);
			break;
		case 3:
			tgStatus = mContext.getString(R.string.tg_status_3);
			break;
		case 4:
			tgStatus = mContext.getString(R.string.tg_status_4);
			break;
		case 5:
			tgStatus = mContext.getString(R.string.tg_status_5);
			break;
		default:
			tgStatus = mContext.getString(R.string.tg_status_1);
			break;
		}
		;
		return tgStatus;
	}

	public static String TaskStatusUtil(Context context, int value) {
		String status = "";
		switch (value) {
		case 1:
			status = context.getString(R.string.task_status_1);
			break;
		case 2:
			status = context.getString(R.string.task_status_2);
			break;
		case 3:
			status = context.getString(R.string.task_status_3);
			break;
		case 4:
			status = context.getString(R.string.task_status_4);
			break;
		default:
			status = context.getString(R.string.task_status_2);
			break;
		}
		;
		return status;
	}

	public static String TaskStatusUtil(Context context, String value) {
		String status = "";
		int intValue = Integer.parseInt(value);
		switch (intValue) {
		case 1:
			status = context.getString(R.string.task_status_1);
			break;
		case 2:
			status = context.getString(R.string.task_status_2);
			break;
		case 3:
			status = context.getString(R.string.task_status_3);
			break;
		case 4:
			status = context.getString(R.string.task_status_4);
			break;
		default:
			status = context.getString(R.string.task_status_2);
			break;
		}
		;
		return status;
	}

	public static String OrderAndPaymentStatusTextUtil(Context mContext,
			String orderStatus, String paymentStatus) {
		String statusStr = "";
		String paymentStr = "";

		statusStr = OrderStatusUtil(mContext, orderStatus);
		paymentStr = PaymentStatusUtil(mContext, paymentStatus);
		return statusStr + "|" + paymentStr;
	}

	public static String OrderAndPaymentStatusTextUtil(Context mContext,
			String orderStatus, int paymentStatus) {
		String statusStr = "";
		String paymentStr = "";

		statusStr = OrderStatusUtil(mContext, orderStatus);
		paymentStr = PaymentStatusUtil(mContext, paymentStatus);
		return statusStr + "|" + paymentStr;
	}

	public static String OrderAndPaymentStatusTextUtil(Context mContext,
			int orderStatus, String paymentStatus) {
		String statusStr = "";
		String paymentStr = "";

		statusStr = OrderStatusUtil(mContext, orderStatus);
		paymentStr = PaymentStatusUtil(mContext, paymentStatus);
		return statusStr + "|" + paymentStr;
	}

	public static String OrderAndPaymentStatusTextUtil(Context mContext,
			int orderStatus, int paymentStatus) {
		String statusStr = "";
		String paymentStr = "";

		statusStr = OrderStatusUtil(mContext, orderStatus);
		paymentStr = PaymentStatusUtil(mContext, paymentStatus);
		return statusStr + "|" + paymentStr;
	}

	public static String CardTypeUtil(Context mContext, int value) {
		String cardType = "";
		switch (value) {
		case 1:
			cardType = mContext.getString(R.string.card_type_title_1);
			break;
		case 2:
			cardType = mContext.getString(R.string.card_type_title_2);
			break;
		case 3:
			cardType = mContext.getString(R.string.card_type_title_3);
			break;
		}
		;
		return cardType;
	}

	public static String CardTypeUtil(Context context, String valueStr) {
		String status = "";
		int intValue = Integer.parseInt(valueStr);
		switch (intValue) {
		case 1:
			status = context.getString(R.string.card_type_title_1);
			break;
		case 2:
			status = context.getString(R.string.card_type_title_2);
			break;
		case 3:
			status = context.getString(R.string.card_type_title_3);
			break;
		default:
			status = context.getString(R.string.card_type_title_1);
			break;
		}
		;
		return status;
	}

	public static String ProductTypeUtil(Context mContext, int value) {
		String productType = "";
		switch (value) {
		case 0:
			productType = mContext.getString(R.string.product_type_status_0);
			break;
		case 1:
			productType = mContext.getString(R.string.product_type_status_1);
			break;
		}
		;
		return productType;
	}

	public static String ProductTypeTitleUtil(Context mContext, int value) {
		String productType = "";
		switch (value) {
		case 0:
			productType = mContext.getString(R.string.product_type_status_0);
			break;
		case 1:
			productType = mContext
					.getString(R.string.product_type_status_1_title);
			break;
		}
		;
		return productType;
	}

	// (次/共)
	// or (件/共)
	public static String ProductTypeCalUtil(Context mContext, int value) {
		String productType = "";
		switch (value) {
		case 0:
			productType = mContext
					.getString(R.string.product_type_status_0_cal);
			break;
		case 1:
			productType = mContext
					.getString(R.string.product_type_status_1_cal);
			break;
		}
		;
		return productType;
	}

	// (次)
	// or (件)
	public static String ProductTypeUnitUtil(Context mContext, int value) {
		String productType = "";
		switch (value) {
		case 0:
			productType = mContext
					.getString(R.string.product_type_status_0_unit);
			break;
		case 1:
			productType = mContext
					.getString(R.string.product_type_status_1_unit);
			break;
		}
		;
		return productType;
	}

	// 0:(服务1次/共10次)
	// 1:(交付3件/共10件)
	public static String ProductTypeTextStringUtil(Context mContext,
			int productType, String finishedCount, String totalCount) {
		String textString = "";
		switch (productType) {
		case 0:
			if (totalCount.equals("0"))
				textString = mContext.getString(R.string.product_type_status_0)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_0_unlimited);

			else
				textString = mContext.getString(R.string.product_type_status_0)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_0_cal)
						+ totalCount
						+ mContext
								.getString(R.string.product_type_status_0_unit);
			break;
		case 1:

			if (totalCount.equals("0"))
				textString = mContext
						.getString(R.string.product_type_status_1_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_1_unlimited);

			else
				textString = mContext
						.getString(R.string.product_type_status_1_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_1_cal)
						+ totalCount
						+ mContext
								.getString(R.string.product_type_status_1_unit);
			break;
		}
		;
		return textString;
	}

	// 0:(完成1次/共10次)
	// 1:(交付3件/共10件)
	public static String OrderDetailTextStringUtil(Context mContext,
			int productType, String finishedCount, String totalCount) {
		String textString = "";
		switch (productType) {
		case 0:
			if (totalCount.equals("0"))
				textString = mContext
						.getString(R.string.order_detail_product_type_status_0_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_0_unlimited);
			else
				textString = mContext
						.getString(R.string.order_detail_product_type_status_0_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_0_cal)
						+ totalCount
						+ mContext
								.getString(R.string.product_type_status_0_unit);
			break;
		case 1:
			if (totalCount.equals("0"))
				textString = mContext
						.getString(R.string.order_detail_product_type_status_1_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_1_unlimited);
			else
				textString = mContext
						.getString(R.string.product_type_status_1_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_1_cal)
						+ totalCount
						+ mContext
								.getString(R.string.product_type_status_1_unit);
			break;
		}
		;
		return textString;
	}

	public static String OrderDetailTextStringUtil(Context mContext,
			int productType, int finishedCount, int totalCount) {
		String textString = "";
		switch (productType) {
		case 0:
			if (totalCount == 0)
				textString = mContext
						.getString(R.string.order_detail_product_type_status_0_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_0_unlimited);
			else
				textString = mContext
						.getString(R.string.order_detail_product_type_status_0_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_0_cal)
						+ totalCount
						+ mContext
								.getString(R.string.product_type_status_0_unit);
			break;
		case 1:
			if (totalCount == 0)
				textString = mContext
						.getString(R.string.order_detail_product_type_status_1_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_1_unlimited);
			else
				textString = mContext
						.getString(R.string.product_type_status_1_title)
						+ finishedCount
						+ mContext
								.getString(R.string.product_type_status_1_cal)
						+ totalCount
						+ mContext
								.getString(R.string.product_type_status_1_unit);
			break;
		}
		;
		return textString;
	}

	public static String ProductRemainCalcTextUtil(Context mContext,
			int productType, String surplusCount, String totalCount) {
		String remainCount = surplusCount;
		String textString = "";
		if (totalCount.equals("0"))
			textString = "不限次";
		else
			switch (productType) {
			case 0:
				textString = mContext
						.getString(R.string.product_type_status_remain_unit)
						+ remainCount
						+ mContext
								.getString(R.string.product_type_status_0_unit);
				break;
			case 1:
				textString = mContext
						.getString(R.string.product_type_status_remain_unit)
						+ remainCount
						+ mContext
								.getString(R.string.product_type_status_1_unit);
				break;
			}
		;
		return textString;
	}

	public static String ProductRemainCalcTextUtil(Context mContext,
			int productType, int surplusCount, int totalCount) {
		String remainCount = String.valueOf(surplusCount);
		String textString = "";
		if (totalCount == 0)
			textString = "不限次";
		else
			switch (productType) {
			case 0:
				textString = mContext
						.getString(R.string.product_type_status_remain_unit)
						+ remainCount
						+ mContext
								.getString(R.string.product_type_status_0_unit);
				break;
			case 1:
				textString = mContext
						.getString(R.string.product_type_status_remain_unit)
						+ remainCount
						+ mContext
								.getString(R.string.product_type_status_1_unit);
				break;
			}
		;
		return textString;
	}

}
