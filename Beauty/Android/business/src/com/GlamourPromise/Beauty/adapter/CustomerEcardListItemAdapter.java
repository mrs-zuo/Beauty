package com.GlamourPromise.Beauty.adapter;
import java.util.List;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class CustomerEcardListItemAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<EcardInfo> mCustomerEcardInfoList;
	
	public CustomerEcardListItemAdapter(Context context,List<EcardInfo>  customerEcardInfoList) {
		mContext = context;
		mCustomerEcardInfoList=customerEcardInfoList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mCustomerEcardInfoList.size();
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
		CustomerEcardItem customerEcardItem = null;
		if (convertView == null) {
			customerEcardItem = new CustomerEcardItem();
			convertView = layoutInflater.inflate(R.xml.customer_ecard_list_item,null);
			customerEcardItem.customerIsDefaultIcon=(ImageView)convertView.findViewById(R.id.customer_ecard_default);
			customerEcardItem.customerEcardNameText = (TextView) convertView.findViewById(R.id.customer_ecard_name);
			customerEcardItem.customerEcardBalanceText=(TextView) convertView.findViewById(R.id.customer_ecard_balance);
//			customerEcardItem.customerEcardBalanceCurText=(TextView) convertView.findViewById(R.id.customer_ecard_balance_cur);
			customerEcardItem.customerEcardNo=(TextView) convertView.findViewById(R.id.customer_ecardno);
			customerEcardItem.ecardTablelayout=(RelativeLayout) convertView.findViewById(R.id.ecard_tablelayout);
			
			
			convertView.setTag(customerEcardItem);
		} else {
			customerEcardItem =(CustomerEcardItem)convertView.getTag();
		}
		String currency=UserInfoApplication.getInstance().getAccountInfo().getCurrency();
		int userCardType=mCustomerEcardInfoList.get(position).getUserEcardType();
		customerEcardItem.customerEcardNameText.setText(mCustomerEcardInfoList.get(position).getUserEcardName());
		if(userCardType==1){
			customerEcardItem.ecardTablelayout.setBackgroundResource(R.drawable.ecard_background_orange);
		}
		if(userCardType==2){
			customerEcardItem.ecardTablelayout.setBackgroundResource(R.drawable.ecard_background_purple);
		}
		if(userCardType==3){
			customerEcardItem.ecardTablelayout.setBackgroundResource(R.drawable.ecard_background_green);
		}
		if(userCardType!=2)
			customerEcardItem.customerEcardBalanceText.setText(currency+mCustomerEcardInfoList.get(position).getUserEcardBalance());
		else
			customerEcardItem.customerEcardBalanceText.setText(mCustomerEcardInfoList.get(position).getUserEcardBalance());
		boolean isDefault=mCustomerEcardInfoList.get(position).isDefault();
		if(mCustomerEcardInfoList.get(position).getUserEcardNo()!=null){
			customerEcardItem.customerEcardNo.setText(mCustomerEcardInfoList.get(position).getUserEcardNo());
		}
		if(isDefault)
			customerEcardItem.customerIsDefaultIcon.setBackgroundResource(R.drawable.customer_ecard_is_default_icon);
		else
			customerEcardItem.customerIsDefaultIcon.setVisibility(View.INVISIBLE);
		return convertView;
	}

	public final class CustomerEcardItem {
		public ImageView customerIsDefaultIcon;
		public TextView customerEcardNameText;
		public TextView customerEcardBalanceText;
		public TextView customerEcardBalanceCurText;
		public TextView customerEcardNo;
		public RelativeLayout ecardTablelayout;
	}
}
