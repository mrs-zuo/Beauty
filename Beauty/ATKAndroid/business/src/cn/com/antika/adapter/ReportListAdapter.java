package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.ReportListBean;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class ReportListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<ReportListBean> reportListBeanList;

	public ReportListAdapter(Context context,
			List<ReportListBean> reportListBeanList) {
		this.mContext = context;
		this.reportListBeanList = reportListBeanList;
		layoutInflater = LayoutInflater.from(mContext);
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
			convertView = layoutInflater.inflate(R.xml.report_list_item,null);
			reportListItem.objectName = (TextView) convertView.findViewById(R.id.report_list_object_name);
			convertView.setTag(reportListItem);
		} else {
			reportListItem = (ReportListItem) convertView.getTag();
		}
		reportListItem.objectName.setText(reportListBeanList.get(position).getObjectName());
		return convertView;
	}

	public final class ReportListItem {
		public TextView objectName;
	}

}
