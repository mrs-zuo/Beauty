package com.GlamourPromise.Beauty.adapter;
import java.util.List;
import com.GlamourPromise.Beauty.Business.EditMessageTemplateActivity;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.FlyMessage;
import com.GlamourPromise.Beauty.bean.MessageTemplate;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.TextView;
import android.view.View.OnClickListener;
public class EMarketingMessageTemplateItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context context;
	private List<MessageTemplate> messageTemplateList;
	private String fromSource;
	private FlyMessage flyMessage;
	private String des;
	private String toUsersID;
	private String toUserName;

	public EMarketingMessageTemplateItemAdapter(Context context,
			List<MessageTemplate> messageTemplateList, String fromSource,
			FlyMessage flyMessage, String des, String toUsersID,
			String toUserName) {
		this.context = context;
		layoutInflater = (LayoutInflater) this.context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.messageTemplateList = messageTemplateList;
		this.fromSource = fromSource;
		this.flyMessage = flyMessage;
		this.des = des;
		this.toUsersID = toUsersID;
		this.toUserName = toUserName;
	}

	@Override
	public int getCount() {
		return messageTemplateList.size();
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
	public View getView(final int position, View convertView,
			ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		MessageTemplateItem messageTemplateItem = null;
		if (convertView == null) {
			messageTemplateItem = new MessageTemplateItem();
			convertView = layoutInflater.inflate(R.xml.emarketing_message_template_list_item, null);
			messageTemplateItem.templateSubjectText = (TextView) convertView.findViewById(R.id.template_subject);
			messageTemplateItem.templateContentText = (TextView) convertView.findViewById(R.id.template_content);
			messageTemplateItem.templateCreateTimeText = (TextView) convertView.findViewById(R.id.template_create_time);
			messageTemplateItem.templateEditBtn = (ImageButton) convertView.findViewById(R.id.edit_message_template);
			convertView.setTag(messageTemplateItem);
		} else {
			messageTemplateItem = (MessageTemplateItem) convertView.getTag();
		}
		messageTemplateItem.templateSubjectText.setText(messageTemplateList
				.get(position).getSubject());
		messageTemplateItem.templateContentText.setText(messageTemplateList
				.get(position).getTemplateContent());
		messageTemplateItem.templateCreateTimeText.setText(messageTemplateList
				.get(position).getTime());
		messageTemplateItem.templateEditBtn
				.setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent = new Intent(context,EditMessageTemplateActivity.class);
						Bundle bundle = new Bundle();
						bundle.putSerializable("template",messageTemplateList.get(position));
						bundle.putSerializable("flyMessage", flyMessage);
						if (toUserName != null) {
							destIntent.putExtra("toUsersName", toUserName);
							destIntent.putExtra("toUsersID", toUsersID);
						}
						destIntent.putExtras(bundle);
						destIntent.putExtra("Des", des);
						destIntent.putExtra("FROMSOURCE", fromSource);
						context.startActivity(destIntent);
					}
				});
		return convertView;
	}

	public final class MessageTemplateItem {
		public TextView templateSubjectText;
		public TextView templateContentText;
		public TextView templateCreateTimeText;
		public TextView templateCreatorNameText;
		public TextView templateUpdaterNameText;
		public ImageButton templateEditBtn;
	}
}
