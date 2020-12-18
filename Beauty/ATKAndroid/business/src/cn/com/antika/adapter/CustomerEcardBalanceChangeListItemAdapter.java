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
import cn.com.antika.bean.CustomerEcardBalanceChange;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class CustomerEcardBalanceChangeListItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<CustomerEcardBalanceChange> customerEcardBalanceChangeList;
	public CustomerEcardBalanceChangeListItemAdapter(Context context,List<CustomerEcardBalanceChange> customerEcardBalanceChangeList) {
		this.mContext = context;
		this.customerEcardBalanceChangeList=customerEcardBalanceChangeList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return customerEcardBalanceChangeList.size();
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
		EcardBalanceChangeItem ecardBalanceChangeItem = null;
		if (convertView == null) {
			ecardBalanceChangeItem = new EcardBalanceChangeItem();
			convertView = layoutInflater.inflate(R.xml.customer_ecard_balance_change_analytics_list_item,null);
			ecardBalanceChangeItem.ecardBalanceChangeCutomerNameText = (TextView) convertView.findViewById(R.id.customer_ecard_balance_change_customer_name);
			ecardBalanceChangeItem.ecardBalanceChangeBalanceText = (TextView) convertView.findViewById(R.id.customer_ecard_balance_change_balance);
			ecardBalanceChangeItem.ecardBalanceChangeRechargeText = (TextView) convertView.findViewById(R.id.customer_ecard_balance_change_recharge);
			ecardBalanceChangeItem.ecardBalanceChangeOutText = (TextView) convertView.findViewById(R.id.customer_ecard_balance_change_out);
			convertView.setTag(ecardBalanceChangeItem);
		} else {
			ecardBalanceChangeItem = (EcardBalanceChangeItem) convertView.getTag();
		}
		ecardBalanceChangeItem.ecardBalanceChangeCutomerNameText.setText(customerEcardBalanceChangeList.get(position).getCustomerName());
		ecardBalanceChangeItem.ecardBalanceChangeBalanceText.setText("净\t"+ UserInfoApplication.getInstance().getAccountInfo().getCurrency()+customerEcardBalanceChangeList.get(position).getCustomerEcardBalanceChangeBalance());
		ecardBalanceChangeItem.ecardBalanceChangeRechargeText.setText("充 \t"+UserInfoApplication.getInstance().getAccountInfo().getCurrency()+customerEcardBalanceChangeList.get(position).getCustomerEcardBalanceChangeRecharge());
		ecardBalanceChangeItem.ecardBalanceChangeOutText.setText("支\t"+UserInfoApplication.getInstance().getAccountInfo().getCurrency()+customerEcardBalanceChangeList.get(position).getCustomerEcardBalanceChangeOut());
		return convertView;
	}

	public final class EcardBalanceChangeItem {
		public TextView ecardBalanceChangeCutomerNameText;
		public TextView ecardBalanceChangeBalanceText;
		public TextView ecardBalanceChangeRechargeText;
		public TextView ecardBalanceChangeOutText;
	}
}
