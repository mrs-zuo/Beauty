/**
 * CustomerVocationListAdapter.java
 * cn.com.antika.adapter
 * tim.zhang@bizapper.com
 * 2015年5月25日 上午10:48:43
 * @version V1.0
 */
package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

import cn.com.antika.bean.CustomerVocation;
import cn.com.antika.bean.CustomerVocationEditAnswer;
import cn.com.antika.business.R;

/**
 * CustomerVocationListAdapter
 * TODO
 *
 * @author tim.zhang@bizapper.com
 * 2015年5月25日 上午10:48:43
 */

@SuppressLint("ResourceType")
public class CustomerVocationListAdapter extends BaseExpandableListAdapter {
	private ArrayList<ArrayList<CustomerVocationEditAnswer>> mCustomerVocationEditAnswerList;
	private ArrayList<CustomerVocation> mCustomerVocationList;
	private LayoutInflater layoutInflater;
	private Context mContext;
	private boolean mCustomerVocationEditable;
	private CustomerVocationItem       customerVocationItem;
    private CustomerVocationEditAnswerItem customerVocationEditAnswerItem;
	public  CustomerVocationListAdapter(Context context,ArrayList<CustomerVocation> customerVocationList,ArrayList<ArrayList<CustomerVocationEditAnswer>> customerVocationEditAnswerList){
		this.mContext=context;
		mCustomerVocationList=customerVocationList;
		mCustomerVocationEditAnswerList=customerVocationEditAnswerList;
		layoutInflater=LayoutInflater.from(mContext);
		mCustomerVocationEditable=false;
	}
	@Override
	public int getGroupCount() {
		// TODO Auto-generated method stub
		return mCustomerVocationList.size();
	}

	@Override
	public int getChildrenCount(int groupPosition) {
		// TODO Auto-generated method stub
		return mCustomerVocationEditAnswerList.get(groupPosition).size();
	}

	@Override
	public Object getGroup(int groupPosition) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object getChild(int groupPosition, int childPosition) {
		// TODO Auto-generated method stub
		return mCustomerVocationEditAnswerList.get(groupPosition).get(childPosition);
	}

	@Override
	public long getGroupId(int groupPosition) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public long getChildId(int groupPosition, int childPosition) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public boolean hasStableIds() {
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public View getGroupView(int groupPosition, boolean isExpanded,View convertView, ViewGroup parent) {
		convertView = layoutInflater.inflate(R.xml.customer_vocation_list_item,null);
		customerVocationItem = new CustomerVocationItem();
		customerVocationItem.customerVocationIndexText=(TextView)convertView.findViewById(R.id.customer_vocation_index);
		customerVocationItem.customerVocationQuestionNameText = (TextView)convertView.findViewById(R.id.customer_vocation_question_name);
		customerVocationItem.customerVocationStatusImageIcon=(ImageView)convertView.findViewById(R.id.customer_vocation_status_icon);
		convertView.setTag(customerVocationItem);
		int customerVocationType=mCustomerVocationList.get(groupPosition).getQuestionType();
		String questionName=mCustomerVocationList.get(groupPosition).getQuestionName();
		String questionTypeString="";
		if(customerVocationType==0)
			questionTypeString="【文本】";
		else if(customerVocationType==1)
			questionTypeString="【单选】";
		else if(customerVocationType==2)
			questionTypeString="【多选】";
		customerVocationItem.customerVocationIndexText.setText(String.valueOf(groupPosition+1));
		customerVocationItem.customerVocationQuestionNameText.setText(questionTypeString+questionName);
		if(!mCustomerVocationEditable){
			if(isExpanded)
				customerVocationItem.customerVocationStatusImageIcon.setBackgroundResource(R.drawable.report_main_up_icon);
			else if(!isExpanded)
				customerVocationItem.customerVocationStatusImageIcon.setBackgroundResource(R.drawable.report_main_down_icon);
		}
		else
			customerVocationItem.customerVocationStatusImageIcon.setBackgroundResource(R.drawable.record_template_is_editable);
		return convertView;
	}

	@Override
	public View getChildView(int groupPosition, int childPosition,boolean isLastChild, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		int questionType=mCustomerVocationList.get(groupPosition).getQuestionType();
		int isQuestionDescription=mCustomerVocationEditAnswerList.get(groupPosition).get(childPosition).getIsQuestionDescription();
	    convertView=layoutInflater.inflate(R.xml.customer_vocation_edit_answer_item,null);
	    customerVocationEditAnswerItem=new CustomerVocationEditAnswerItem();
	    customerVocationEditAnswerItem.customerVocationEditAnswerItemText=(TextView) convertView.findViewById(R.id.customer_vocation_edit_answer_item);
	    customerVocationEditAnswerItem.customerVocationEditAnswerIsCheckIcon=(ImageView) convertView.findViewById(R.id.vocation_item_check_image);
		customerVocationEditAnswerItem.customerVocationEditAnswerItemText.setText(mCustomerVocationEditAnswerList.get(groupPosition).get(childPosition).getAnswerContent());
		if(questionType!=0){
			int isAnswer=mCustomerVocationEditAnswerList.get(groupPosition).get(childPosition).getIsAnswer();
			if(isAnswer==0)
				customerVocationEditAnswerItem.customerVocationEditAnswerIsCheckIcon.setBackgroundResource(R.drawable.no_select_btn);
			else if(isAnswer==1)
				customerVocationEditAnswerItem.customerVocationEditAnswerIsCheckIcon.setBackgroundResource(R.drawable.select_btn);
		}
		else if(questionType==0)
			customerVocationEditAnswerItem.customerVocationEditAnswerIsCheckIcon.setVisibility(View.GONE);
		if(isQuestionDescription==1){
			 customerVocationEditAnswerItem.customerVocationEditAnswerIsCheckIcon.setVisibility(View.GONE);
			 customerVocationEditAnswerItem.customerVocationEditAnswerItemText.setTextSize(TypedValue.COMPLEX_UNIT_SP,16);
			 customerVocationEditAnswerItem.customerVocationEditAnswerItemText.setTextColor(mContext.getResources().getColor(R.color.black));
		}
		return convertView;
	}

	@Override
	public boolean isChildSelectable(int groupPosition, int childPosition) {
		// TODO Auto-generated method stub
		return false;
	}
	public final class CustomerVocationItem{
		public TextView customerVocationIndexText;
		public TextView customerVocationQuestionNameText;
		public ImageView customerVocationStatusImageIcon;
	}
	public final class CustomerVocationEditAnswerItem{
		public ImageView  customerVocationEditAnswerIsCheckIcon;
		public TextView   customerVocationEditAnswerItemText;
	}
	public void setCustomerVocationEditStatus(boolean customerVocationEditable){
		mCustomerVocationEditable=customerVocationEditable;
		this.notifyDataSetChanged();
	}

}
