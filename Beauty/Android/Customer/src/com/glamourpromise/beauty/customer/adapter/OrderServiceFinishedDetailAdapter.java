package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.ServiceOrderTreatmentDetailActivityGroup;
import com.glamourpromise.beauty.customer.activity.ServiceOrderTreatmentServiceDetailTabActivity;
import com.glamourpromise.beauty.customer.bean.TGListInfo;
import com.glamourpromise.beauty.customer.bean.TreatmentList;
import com.glamourpromise.beauty.customer.util.StatusUtil;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class OrderServiceFinishedDetailAdapter extends BaseAdapter {
	private Context context;
	private List<TGListInfo> tgList = new ArrayList<TGListInfo>();
	private LayoutInflater inflater;
	private String branchName;
	private int productType;
	private int orderID;

	public OrderServiceFinishedDetailAdapter(Context mContext,
			List<TGListInfo> mTGList, int mOrderID, String mBranchName,
			int mProductType) {
		this.context = mContext;
		this.tgList = mTGList;
		this.orderID = mOrderID;
		this.branchName = mBranchName;
		this.productType = mProductType;
		inflater = LayoutInflater.from(context);
	}

	@Override
	public int getCount() {
		return tgList.size();
	}

	@Override
	public Object getItem(int position) {
		return position;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ListItem listItem = null;
		if (convertView == null) {
			listItem = new ListItem();
			convertView = inflater.inflate(R.xml.service_finished_detail_list_item, null);
			listItem.titleCounterLayout = (RelativeLayout) convertView.findViewById(R.id.title_counter_layout);
			listItem.titleCounter = (TextView) convertView.findViewById(R.id.title_counter);
			listItem.finishedTime = (TextView) convertView.findViewById(R.id.finished_time);
			listItem.tgArrow = (ImageView) convertView.findViewById(R.id.service_finished_detail_tg_detail_arrowhead);
			listItem.responsiblePersonLayout = (RelativeLayout) convertView.findViewById(R.id.service_finished_detail_responsible_persone_name_layout);
			listItem.responsiblePersonName = (TextView) convertView.findViewById(R.id.service_finished_detail_responsible_person_name);
			listItem.responsiblePersonNameDetail = (TextView) convertView.findViewById(R.id.service_finished_detail_responsible_person_name_detail);
			listItem.listView = (NoScrollListView) convertView.findViewById(R.id.sub_service_list_view);
			convertView.setTag(listItem);
		} else
			listItem = (ListItem) convertView.getTag();

		if (productType == 1) {
			listItem.titleCounter.setText(StatusUtil.TGStatusUtil(context,
					tgList.get(position).getStatus())
					+ "|"
					+ context.getResources().getString(
							R.string.product_type_status_1_title)
					+ tgList.get(position).getQuantity()
					+ context.getResources().getString(
							R.string.product_type_status_1_unit));
		} else
			listItem.titleCounter.setText(StatusUtil.TGStatusUtil(context,
					tgList.get(position).getStatus()));

		listItem.finishedTime.setText(tgList.get(position).getStartTime());

		if (tgList.get(position).getServicePICName().equals(""))
			listItem.responsiblePersonName.setText("服务顾问");
		else
			listItem.responsiblePersonName.setText(tgList.get(position)
					.getServicePICName());

		final int mPosition = position;
		if (productType == 0) {
			listItem.tgArrow.setVisibility(View.VISIBLE);
			listItem.responsiblePersonNameDetail.setVisibility(View.GONE);
			listItem.responsiblePersonLayout.setOnClickListener(new OnClickListener() {

						@Override
						public void onClick(View v) {
							Intent intent = new Intent();
							intent.putExtra("GroupNo",tgList.get(mPosition).getGroupNo());
							intent.putExtra("OrderID",orderID);
							intent.putExtra("BranchName", branchName);
							intent.setClass(context,ServiceOrderTreatmentServiceDetailTabActivity.class);
							context.startActivity(intent);
						}

					});
		} else {
			listItem.tgArrow.setVisibility(View.GONE);
			listItem.responsiblePersonNameDetail.setVisibility(View.VISIBLE);
			listItem.responsiblePersonName.setText("服务顾问");
			listItem.responsiblePersonNameDetail.setText(tgList.get(position).getServicePICName());
		}
		listItem.arrAdapter = new TreatmentListAdapter(context,tgList.get(position).getTreatmentList(),orderID,tgList.get(position).getGroupNo());
		listItem.listView.setAdapter(listItem.arrAdapter);

		return convertView;
	}

	public final class ListItem {
		RelativeLayout titleCounterLayout;
		TextView titleCounter;
		TextView finishedTime;
		ImageView tgArrow;
		RelativeLayout responsiblePersonLayout;
		TextView responsiblePersonName;
		TextView responsiblePersonNameDetail;
		NoScrollListView listView;
		TreatmentListAdapter arrAdapter;
	}

	public class TreatmentListAdapter extends BaseAdapter {

		private List<TreatmentList> treatmentList = new ArrayList<TreatmentList>();
		private LayoutInflater inflater;
		private Context context;
		private int orderID;
		private String groupNo;
		public TreatmentListAdapter(Context mContext,List<TreatmentList> mTreatmentList, int mOrderID,String groupNo) {
			this.context = mContext;
			this.treatmentList = mTreatmentList;
			this.orderID = mOrderID;
			inflater = LayoutInflater.from(mContext);
			this.groupNo=groupNo;
		}

		@Override
		public int getCount() {
			return treatmentList.size();
		}

		@Override
		public Object getItem(int position) {
			return position;
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			SubServiceItem listItem = null;
			if (convertView == null) {
				listItem = new SubServiceItem();
				convertView = inflater.inflate(	R.xml.service_treatment_finished_detail_list_item,null);
				listItem.subServiceImg = (ImageView) convertView.findViewById(R.id.service_treatment_finished_detail_subservice_img);
				listItem.tmDetailLayout = (RelativeLayout) convertView.findViewById(R.id.tm_detail_layout);
				listItem.subServiceName = (TextView) convertView.findViewById(R.id.sub_service_name);
				listItem.executorName = (TextView) convertView.findViewById(R.id.executor_name);
				listItem.arrow = (ImageView) convertView.findViewById(R.id.sub_service_detail_arrowhead);
				convertView.setTag(listItem);
			} else
				listItem = (SubServiceItem) convertView.getTag();

			if (treatmentList.get(position).getSubServiceName().equals(""))
				listItem.subServiceName.setText("服务操作");
			else
				listItem.subServiceName.setText(treatmentList.get(position).getSubServiceName());
			listItem.executorName.setText(treatmentList.get(position).getExecutorName());
			final int mPosition = position;
			listItem.tmDetailLayout.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					Intent destIntent = new Intent();
					destIntent.putExtra("TreatmentID",treatmentList.get(mPosition).getTreatmentID());
					destIntent.putExtra("OrderID", String.valueOf(orderID));
					destIntent.putExtra("GroupNo",groupNo);
					destIntent.setClass(context,ServiceOrderTreatmentDetailActivityGroup.class);
					context.startActivity(destIntent);
				}

			});

			return convertView;
		}

		public final class SubServiceItem {
			// LinearLayout subserviceLayout;
			RelativeLayout tmDetailLayout;
			ImageView subServiceImg;
			TextView subServiceName;
			TextView executorName;
			ImageView arrow;
		}

	}

}
