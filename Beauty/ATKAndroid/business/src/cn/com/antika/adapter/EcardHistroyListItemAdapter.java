package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.EcardHistroy;
import cn.com.antika.business.R;
import cn.com.antika.util.NumberFormatUtil;

@SuppressLint("ResourceType")
public class EcardHistroyListItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<EcardHistroy> ecardHistroyList;
	private int     mEcardType;
	public EcardHistroyListItemAdapter(Context context,List<EcardHistroy> ecardHistroyList,int ecardType) {
		this.mContext = context;
		this.ecardHistroyList = ecardHistroyList;
		layoutInflater = LayoutInflater.from(mContext);
		mEcardType=ecardType;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return ecardHistroyList.size();
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
		EcardHistroyItem ecardHistroyItem = null;
		if (convertView == null) {
			ecardHistroyItem = new EcardHistroyItem();
			convertView = layoutInflater.inflate(R.xml.ecard_history_list_item,null);
			ecardHistroyItem.ecardHistroyRemarkRechargeModeText = (TextView) convertView.findViewById(R.id.ecard_histroy_remark_rechargemode);
			ecardHistroyItem.ecardHistroyTimeText = (TextView) convertView.findViewById(R.id.ecard_histroy_time);
			ecardHistroyItem.ecardHistroyAmountText = (TextView) convertView.findViewById(R.id.ecard_histroy_amount);
			ecardHistroyItem.ecardHistroyBalanceText = (TextView) convertView.findViewById(R.id.ecard_histroy_balance);
			ecardHistroyItem.ecardHistroyJoinIn=(ImageView) convertView.findViewById(R.id.ecard_histroy_arrowhead);
			convertView.setTag(ecardHistroyItem);
		} else {
			ecardHistroyItem = (EcardHistroyItem) convertView.getTag();
		}
		String rechargeOrPay = "";
		//充值
		if (ecardHistroyList.get(position).getActionType() == 0) {
			rechargeOrPay = "+";
			ecardHistroyItem.ecardHistroyAmountText.setTextColor(Color.GREEN);
		} else if (ecardHistroyList.get(position).getActionType() == 1) {
			ecardHistroyItem.ecardHistroyAmountText.setTextColor(Color.RED);
		}
		ecardHistroyItem.ecardHistroyRemarkRechargeModeText.setText(ecardHistroyList.get(position).getActionModeName());
		ecardHistroyItem.ecardHistroyTimeText.setText(ecardHistroyList.get(position).getCreateTime());
		if(mEcardType!=2){
			ecardHistroyItem.ecardHistroyBalanceText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency()+ NumberFormatUtil.currencyFormat(ecardHistroyList.get(position).getBalance()));
		}
		else{
			ecardHistroyItem.ecardHistroyBalanceText.setText(NumberFormatUtil.currencyFormat(ecardHistroyList.get(position).getBalance()));
		}
		ecardHistroyItem.ecardHistroyAmountText.setText(rechargeOrPay+NumberFormatUtil.currencyFormat(ecardHistroyList.get(position).getAmount()));	
		return convertView;
	}

	public final class EcardHistroyItem {
		public TextView ecardHistroyRemarkRechargeModeText;
		public TextView ecardHistroyTimeText;
		public TextView ecardHistroyAmountText;
		public TextView ecardHistroyBalanceText;
		public ImageView ecardHistroyJoinIn;
	}
}
