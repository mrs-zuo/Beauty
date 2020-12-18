package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.ThirdPartPay;
import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.NumberFormatUtil;

@SuppressLint("ResourceType")
public class ThirdPartPayItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context context;
	private List<ThirdPartPay> thirdPartPayList;
	private static final String RESULT_USERPAYING = "USERPAYING";
	private static final String RESULT_USERNOTPAY = "NOTPAY";
	private static final String RESULT_USERPAYCLOSED = "CLOSED";
	private static final String RESULT_USERPAYREVOKED = "REVOKED";
	private static final String RESULT_USERPAYERROR = "PAYERROR";
	private static final String RESULT_SUCCESS = "SUCCESS";
	private static final String RESULT_SUCCESS_ALI = "TRADE_SUCCESS";
	private static final String RESULT_FAIL = "FAIL";

	public ThirdPartPayItemAdapter(Context context,
			List<ThirdPartPay> thirdPartPayList) {
		this.context = context;
		layoutInflater = (LayoutInflater) this.context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.thirdPartPayList = thirdPartPayList;
	}

	@Override
	public int getCount() {
		return thirdPartPayList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		ThirdPartPayItem thirdPartPayItem = null;
		if (convertView == null) {
			thirdPartPayItem = new ThirdPartPayItem();
			convertView = layoutInflater.inflate(
					R.xml.third_part_pay_list_item, null);
			thirdPartPayItem.thirdPartPayNetTradeNo = (TextView) convertView
					.findViewById(R.id.third_part_pay_result_trade_no);
			thirdPartPayItem.thirdPartPayVendor=(TextView) convertView.findViewById(R.id.third_part_pay_result_vendor);
			thirdPartPayItem.thirdPartPayAmount = (TextView) convertView
					.findViewById(R.id.third_part_pay_result_amount);
			thirdPartPayItem.thirdPartPayType = (TextView) convertView
					.findViewById(R.id.third_part_pay_result_type);
			thirdPartPayItem.thirdPartPayTime = (TextView) convertView
					.findViewById(R.id.third_part_pay_result_create_time);
			thirdPartPayItem.thirdPartPayStatus = (TextView) convertView
					.findViewById(R.id.third_part_pay_result_status);
			convertView.setTag(thirdPartPayItem);
		} else {
			thirdPartPayItem = (ThirdPartPayItem) convertView.getTag();
		}
		thirdPartPayItem.thirdPartPayNetTradeNo.setText(thirdPartPayList.get(
				position).getNetTradeNo());
		thirdPartPayItem.thirdPartPayAmount
				.setText(UserInfoApplication.getInstance().getAccountInfo()
						.getCurrency()
						+ NumberFormatUtil.currencyFormat(String
								.valueOf(thirdPartPayList.get(position)
										.getPayAmount())));
		thirdPartPayItem.thirdPartPayTime.setText(thirdPartPayList
				.get(position).getPayTime());
		thirdPartPayItem.thirdPartPayType.setText(thirdPartPayList
				.get(position).getChangeTypeName());
		String resultCode = thirdPartPayList.get(position).getResultCode();
		String tradeState = thirdPartPayList.get(position).getTradeState();
		int tradeVendor = thirdPartPayList.get(position).getNetTradeVendor();
		// 微信支付
		if (tradeVendor == Constant.PAYMENT_MODE_WEIXIN) {
			thirdPartPayItem.thirdPartPayVendor.setText("微信");
			// 支付成功
			if (RESULT_SUCCESS.equals(resultCode)
					&& RESULT_SUCCESS.equals(tradeState)) {
				thirdPartPayItem.thirdPartPayStatus
						.setText(context
								.getString(R.string.payment_action_result_status_success));
			}
			// 支付未成功状态
			else if (RESULT_SUCCESS.equals(resultCode) && tradeState != null
					&& !("").equals(tradeState)) {
				// 支付关闭
				if (RESULT_USERPAYCLOSED.equals(tradeState)) {
					thirdPartPayItem.thirdPartPayStatus
							.setText(context
									.getString(R.string.payment_action_result_status_closed));
				}
				// 已撤销
				else if (RESULT_USERPAYREVOKED.equals(tradeState)) {
					thirdPartPayItem.thirdPartPayStatus
							.setText(context
									.getString(R.string.payment_action_result_status_revoked));
				}
				// 支付失败
				else if (RESULT_USERPAYERROR.equals(tradeState)) {
					thirdPartPayItem.thirdPartPayStatus
							.setText(context
									.getString(R.string.payment_action_result_status_error));
				}
			}
			// 支付结果未知
			else if ("".equals(resultCode) || resultCode == null) {
				// 用户支付中
				if (RESULT_USERPAYING.equals(tradeState)) {
					thirdPartPayItem.thirdPartPayStatus
							.setText(context
									.getString(R.string.payment_action_result_status_waiting));
				}
				// 未支付
				else if (RESULT_USERNOTPAY.equals(tradeState)) {
					thirdPartPayItem.thirdPartPayStatus
							.setText(context
									.getString(R.string.payment_action_result_status_unpay));
				} else
					thirdPartPayItem.thirdPartPayStatus
							.setText(context
									.getString(R.string.payment_action_result_status_unknown));
			} else
				thirdPartPayItem.thirdPartPayStatus
						.setText(context
								.getString(R.string.payment_action_result_status_error));
		}
		// 支付宝支付
		else if (tradeVendor == Constant.PAYMENT_MODE_ALI) {
			thirdPartPayItem.thirdPartPayVendor.setText("支付宝");
			// 支付成功
			if (RESULT_SUCCESS_ALI.equals(tradeState)) {
				thirdPartPayItem.thirdPartPayStatus.setText(context.getString(R.string.payment_action_result_status_success));
			}
			// 用户支付中
			else if ("".equals(tradeState) || tradeState == null) {
				thirdPartPayItem.thirdPartPayStatus
						.setText(context
								.getString(R.string.payment_action_result_status_waiting));
			}
			// 支付失败
			else {
				thirdPartPayItem.thirdPartPayStatus
						.setText(context
								.getString(R.string.payment_action_result_status_error));
			}
		}
		return convertView;
	}

	public final class ThirdPartPayItem {
		public TextView thirdPartPayNetTradeNo;
		public TextView thirdPartPayVendor;
		public TextView thirdPartPayAmount;
		public TextView thirdPartPayType;
		public TextView thirdPartPayTime;
		public TextView thirdPartPayStatus;
	}
}
