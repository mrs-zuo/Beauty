package com.GlamourPromise.Beauty.adapter;
import java.text.NumberFormat;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.ReportListBean;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class ReportDetailListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<ReportListBean> reportListBeanList;
	private int productType;
	private int extractItemType;
	private double totalCount;
	public ReportDetailListAdapter(Context context,
			List<ReportListBean> reportListBeanList, int extractItemType,
			int productType, double totalCount) {
		this.mContext = context;
		this.reportListBeanList = reportListBeanList;
		layoutInflater = LayoutInflater.from(mContext);
		this.extractItemType = extractItemType;
		this.productType = productType;
		this.totalCount = totalCount;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return reportListBeanList.size();
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
		ReportListItem reportListItem = null;
		if (convertView == null) {
			reportListItem = new ReportListItem();
			convertView = layoutInflater.inflate(
					R.xml.report_detail_list_item, null);
			reportListItem.objectName = (TextView) convertView
					.findViewById(R.id.report_detail_list_object_name);
			reportListItem.salesAmount = (TextView) convertView
					.findViewById(R.id.report_detail_list_sales_amount);
			convertView.setTag(reportListItem);
		} else {
			reportListItem = (ReportListItem) convertView.getTag();
		}
		NumberFormat nf = NumberFormat.getInstance();
		nf.setMaximumFractionDigits(2);
		double itemAmount = Double.valueOf(reportListBeanList.get(position).getSalesAmount());
		double percent = 0;
		if (totalCount != 0)
			percent = itemAmount / totalCount;
		String percentNumberFormat = nf.format(percent * 100);
		reportListItem.objectName.setText(reportListBeanList.get(position)
				.getObjectName() + "(" + (percentNumberFormat) + "%" + ")");
		if (extractItemType == 0)
			reportListItem.salesAmount.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency()
					+ NumberFormatUtil.currencyFormat(reportListBeanList.get(position).getSalesAmount()));
		else if (extractItemType == 1 && productType == 0)
			reportListItem.salesAmount.setText(reportListBeanList.get(position)
					.getSalesAmount() + "项");
		else if (extractItemType == 1 && productType == 1)
			reportListItem.salesAmount.setText(reportListBeanList.get(position)
					.getSalesAmount() + "件");
		//服务次数
		else if(extractItemType == 2)
			reportListItem.salesAmount.setText(reportListBeanList.get(position)
					.getSalesAmount() + "次");
		else if(extractItemType == 5)
			reportListItem.salesAmount.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency()
					+ NumberFormatUtil.currencyFormat(reportListBeanList.get(position).getSalesAmount()));
		return convertView;
	}

	public final class ReportListItem {
		public TextView objectName;
		public TextView salesAmount;
	}

}
