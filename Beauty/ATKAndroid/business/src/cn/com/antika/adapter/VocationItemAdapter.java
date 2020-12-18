package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.CustomerVocation;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class VocationItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context context;
	private List<CustomerVocation> vocationList;
	public VocationItemAdapter(Context context,
			List<CustomerVocation> vocationList) {
		this.context = context;
		layoutInflater = (LayoutInflater) this.context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.vocationList = vocationList;
	}

	@Override
	public int getCount() {
		return vocationList.size();
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
		VocationItem vocationItem = null;
		if (convertView == null) {
			vocationItem = new VocationItem();
			convertView = layoutInflater
					.inflate(R.xml.vocation_list_item, null);
			vocationItem.vocationQuestionNameText = (TextView) convertView
					.findViewById(R.id.vocation_question_name);
			vocationItem.vocationAnswerContentText = (TextView) convertView
					.findViewById(R.id.vocation_answer_content);
			convertView.setTag(vocationItem);
		} else {
			vocationItem = (VocationItem) convertView.getTag();
		}
		vocationItem.vocationQuestionNameText.setText(vocationList
				.get(position).getQuestionName());
		
		if (vocationList.get(position).getQuestionType() == 0)
			vocationItem.vocationAnswerContentText.setText(vocationList.get(
					position).getAnswerContent());
		
		else if (vocationList.get(position).getQuestionType() == 2) {
			String[] vocationItemAnswer = vocationList.get(position)
					.getAnswerContent().split("\\|");
			String[] questionContent = vocationList.get(position)
					.getQuestionContent().split("\\|");
			StringBuffer vocationAnswerContent = new StringBuffer();
			for (int i = 0; i < vocationItemAnswer.length;i++) {
				if (vocationItemAnswer[i].equals("1")) {
					vocationAnswerContent.append(questionContent[i] + ",");
				}
			}
			if(vocationAnswerContent.length()>=1)
			{
				vocationAnswerContent.deleteCharAt(vocationAnswerContent.length()-1);
				vocationItem.vocationAnswerContentText
						.setText(vocationAnswerContent.toString());
			}
		} else if (vocationList.get(position).getQuestionType() == 1) {
			String[] vocationItemAnswer = vocationList.get(position)
					.getAnswerContent().split("\\|");
			String[] questionContent = vocationList.get(position)
					.getQuestionContent().split("\\|");
			StringBuffer vocationAnswerContent = new StringBuffer();
			for (int i = 0; i < vocationItemAnswer.length; i++) {
				if (vocationItemAnswer[i].equals("1")) {
					vocationAnswerContent.append(questionContent[i]);
				}
			}
			vocationItem.vocationAnswerContentText
					.setText(vocationAnswerContent.toString());
		}
		return convertView;
	}

	public final class VocationItem {
		public TextView vocationQuestionNameText;
		public TextView vocationAnswerContentText;
	}
}
