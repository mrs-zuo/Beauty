package com.glamourpromise.beauty.customer.adapter;
import java.util.ArrayList;
import java.util.List;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.EvaluateServiceDetailActivity;
import com.glamourpromise.beauty.customer.bean.EvaluateServiceInfo;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class EvaluateServiceListAdapter extends BaseAdapter {
	private LayoutInflater     layoutInflater;
	private Context            mContext;
	private List<EvaluateServiceInfo>    evaluateServiceInfoList = new ArrayList<EvaluateServiceInfo>();
	public EvaluateServiceListAdapter(Context context,List<EvaluateServiceInfo> evaluateServiceInfo) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		evaluateServiceInfoList=evaluateServiceInfo;
	}
	@Override
	public int getCount() {
		return evaluateServiceInfoList.size();
	}
	@Override
	public Object getItem(int position) {
		return null;
	}
	@Override
	public long getItemId(int position) {
		return 0;
	}
	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		final int pos=position;
		DispenseCompleteOrderItem dispenseCompleteOrderItem = null;
		if (convertView == null) {
			dispenseCompleteOrderItem = new DispenseCompleteOrderItem();
			convertView = layoutInflater.inflate(R.xml.evaluate_service_list_item,null);
			dispenseCompleteOrderItem.evaluateServiceNameText=(TextView)convertView.findViewById(R.id.evaluate_service_name_text);
			dispenseCompleteOrderItem.evaluateServiceTime=(TextView)convertView.findViewById(R.id.evaluate_service_time);
			dispenseCompleteOrderItem.evaluateServiceResponsibleNameText=(TextView)convertView.findViewById(R.id.evaluate_service_responsible_name_text);
			dispenseCompleteOrderItem.evaluateServiceNum=(TextView) convertView.findViewById(R.id.evaluate_service_num);
			dispenseCompleteOrderItem.evaluateServiceButton=(Button) convertView.findViewById(R.id.evaluate_service_button);
			convertView.setTag(dispenseCompleteOrderItem);
		} else {
			dispenseCompleteOrderItem = (DispenseCompleteOrderItem)convertView.getTag();
		}
		dispenseCompleteOrderItem.evaluateServiceButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent it = new Intent(mContext, EvaluateServiceDetailActivity.class);
				Bundle bu=new Bundle();
				bu.putLong("GroupNo", evaluateServiceInfoList.get(pos).getGroupNo());
				it.putExtras(bu);
				mContext.startActivity(it);
			}
		});
		dispenseCompleteOrderItem.evaluateServiceNameText.setText(evaluateServiceInfoList.get(position).getServiceName());
		dispenseCompleteOrderItem.evaluateServiceTime.setText(evaluateServiceInfoList.get(position).getTgEndTime());
		dispenseCompleteOrderItem.evaluateServiceResponsibleNameText.setText(evaluateServiceInfoList.get(position).getResponsiblePersonName());
		if(evaluateServiceInfoList.get(position).getTgTotalCount()==0){
			dispenseCompleteOrderItem.evaluateServiceNum.setText("服务"+evaluateServiceInfoList.get(position).getTgFinishedCount()+"次/"+"不限次");
		}else{
			dispenseCompleteOrderItem.evaluateServiceNum.setText("服务"+evaluateServiceInfoList.get(position).getTgFinishedCount()+"次/"+"共"+evaluateServiceInfoList.get(position).getTgTotalCount()+"次");
		}
		return convertView;
	}
	public final class  DispenseCompleteOrderItem {
		public TextView  evaluateServiceNameText;
		public TextView  evaluateServiceTime;
		public TextView  evaluateServiceResponsibleNameText;
		public TextView  evaluateServiceNum;
		public Button    evaluateServiceButton;
	}
}
