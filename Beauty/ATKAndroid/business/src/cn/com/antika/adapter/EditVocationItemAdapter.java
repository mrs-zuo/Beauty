package cn.com.antika.adapter;
import java.util.List;

import cn.com.antika.bean.CustomerVocation;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TableLayout;
import android.widget.TextView;

public class EditVocationItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context context;
	private List<CustomerVocation> vocationList;
	public static View[] vocationItemViews;

	public EditVocationItemAdapter(Context context,
			List<CustomerVocation> vocationList) {
		this.context = context;
		layoutInflater = (LayoutInflater) this.context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.vocationList = vocationList;
		vocationItemViews = new View[vocationList.size()];
	}

	@Override
	public int getCount() {
		return vocationList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return vocationItemViews[position];
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {/*
		// TODO Auto-generated method stub
		final int pos = position;
		EditVocationItem editVocationItem = null;
		if (vocationItemViews[position] == null) {
			editVocationItem = new EditVocationItem();
			vocationItemViews[position] = layoutInflater.inflate(
					R.xml.edit_vocation_list_item, null);
			editVocationItem.editVocationQuestionNameText = (TextView) vocationItemViews[position]
					.findViewById(R.id.edit_vocation_question_name);
			editVocationItem.editVocationListItemTable = (TableLayout) vocationItemViews[position]
					.findViewById(R.id.customer_vocation_list_item_table);
			vocationItemViews[position].setTag(editVocationItem);
		} else {
			editVocationItem = (EditVocationItem) vocationItemViews[position]
					.getTag();
		}
		editVocationItem.editVocationQuestionNameText.setText(vocationList.get(
				position).getQuestionName());
		String questionContent = vocationList.get(position)
				.getQuestionContent();
		String[] questionContentArray = questionContent.split(",");
		final String answerContent = vocationList.get(position)
				.getAnswerContent();
		int questionType = vocationList.get(position).getQuestionType();
		final List<CustomerVocationEditAnswer> customerVocationEditAnswer = vocationList
				.get(position).getCustomerVocationEditAnswer();
		View vocationListItemView = null;
		// 问题类型为文本类型的
		if (questionType == 0) {
			if (editVocationItem.editVocationListItemTable.getChildCount() - 2 != questionContentArray.length) {
				vocationListItemView = layoutInflater.inflate(
						R.xml.vocation_item_type_text, null);
				EditText vocationItemText = (EditText) vocationListItemView
						.findViewById(R.id.vocation_item_text);
				vocationItemText.setText(questionContent);
				if (answerContent != null && !(("").equals(answerContent)))
					vocationItemText.setText(answerContent);
				editVocationItem.editVocationListItemTable
						.addView(vocationListItemView);
			}
		}
		// 问题类型为单项选择的
		else if (questionType == 1) {
			if (editVocationItem.editVocationListItemTable.getChildCount() - 2 != questionContentArray.length) {
				if (questionContentArray.length >= 1) {
					for (int i = 0; i < customerVocationEditAnswer.size(); i++) {
						final int h = i;
						vocationListItemView = layoutInflater.inflate(
								R.xml.vocation_item_type_check, null);
						TextView vocationItemText = (TextView) vocationListItemView
								.findViewById(R.id.vocation_item_check_text);
						ImageView vocationItemCheckBox = (ImageView) vocationListItemView
								.findViewById(R.id.vocation_item_check_image);
						vocationItemText.setText(questionContentArray[i]);
						final int isAnswer = customerVocationEditAnswer.get(i)
								.getIsAnswer();
						vocationItemCheckBox
								.setOnClickListener(new OnClickListener() {
									@Override
									public void onClick(View view) {
										if (vocationList
												.get(pos)
												.getCustomerVocationEditAnswer()
												.get(h).getIsAnswer() == 0) {
											view.setBackgroundResource(R.drawable.select_btn);
											customerVocationEditAnswer.get(h)
													.setIsAnswer(1);
											for (int j = 0; j < customerVocationEditAnswer
													.size(); j++) {
												if (j != h) {
													customerVocationEditAnswer
															.get(j)
															.setIsAnswer(0);
												}
											}
											vocationList
													.get(pos)
													.setCustomerVocationEditAnswer(
															customerVocationEditAnswer);
										} else if (vocationList
												.get(pos)
												.getCustomerVocationEditAnswer()
												.get(h).getIsAnswer() == 1) {
											view.setBackgroundResource(R.drawable.no_select_btn);
											customerVocationEditAnswer.get(h)
													.setIsAnswer(0);
											vocationList
													.get(pos)
													.setCustomerVocationEditAnswer(customerVocationEditAnswer);
										}
										EditCustomerVocationActivity.editVocationItemAdapter
												.notifyDataSetChanged();
									}

								});
						if (isAnswer == 1)
							vocationItemCheckBox
									.setBackgroundResource(R.drawable.select_btn);
						else
							vocationItemCheckBox
									.setBackgroundResource(R.drawable.no_select_btn);
						editVocationItem.editVocationListItemTable
								.addView(vocationListItemView);
					}
				}
			}
			else if(editVocationItem.editVocationListItemTable.getChildCount() - 2 == questionContentArray.length){
				for (int i = 0; i < customerVocationEditAnswer.size(); i++) {
					ImageView singleCheck=(ImageView)(editVocationItem.editVocationListItemTable.getChildAt(i+2).findViewById(R.id.vocation_item_check_image));
					if(customerVocationEditAnswer.get(i).getIsAnswer()==1)
						singleCheck.setBackgroundResource(R.drawable.select_btn);
					else if(customerVocationEditAnswer.get(i).getIsAnswer()==0)
						singleCheck.setBackgroundResource(R.drawable.no_select_btn);
				}
			}
		}
		// 问题类型为多项选择的
		else if (questionType == 2) {
			if (editVocationItem.editVocationListItemTable.getChildCount() - 2 != questionContentArray.length) {
				if (questionContentArray.length >= 1) {
					for (int i = 0; i < customerVocationEditAnswer.size(); i++) {
						final int h = i;
						vocationListItemView = layoutInflater.inflate(
								R.xml.vocation_item_type_check, null);
						TextView vocationItemText = (TextView) vocationListItemView
								.findViewById(R.id.vocation_item_check_text);
						ImageView vocationItemCheckBox = (ImageView) vocationListItemView
								.findViewById(R.id.vocation_item_check_image);
						vocationItemText.setText(questionContentArray[i]);
						final int isAnswer = customerVocationEditAnswer.get(i)
								.getIsAnswer();
						vocationItemCheckBox
								.setOnClickListener(new OnClickListener() {
									@Override
									public void onClick(View view) {
										if (vocationList
												.get(pos)
												.getCustomerVocationEditAnswer()
												.get(h).getIsAnswer() == 0) {
											view.setBackgroundResource(R.drawable.select_btn);
											customerVocationEditAnswer.get(h)
													.setIsAnswer(1);
											vocationList
													.get(pos)
													.setCustomerVocationEditAnswer(
															customerVocationEditAnswer);
										} else if (vocationList
												.get(pos)
												.getCustomerVocationEditAnswer()
												.get(h).getIsAnswer() == 1) {
											view.setBackgroundResource(R.drawable.no_select_btn);
											customerVocationEditAnswer.get(h)
													.setIsAnswer(0);
											vocationList
													.get(pos)
													.setCustomerVocationEditAnswer(
															customerVocationEditAnswer);
										}
										EditCustomerVocationActivity.editVocationItemAdapter
												.notifyDataSetChanged();
									}
								});
						if (isAnswer == 1)
							vocationItemCheckBox
									.setBackgroundResource(R.drawable.select_btn);
						else
							vocationItemCheckBox
									.setBackgroundResource(R.drawable.no_select_btn);

						editVocationItem.editVocationListItemTable
								.addView(vocationListItemView);
					}
				}
			}
		}
		return vocationItemViews[position];
	*/
		return null;
		}

	public final class EditVocationItem {
		public TextView editVocationQuestionNameText;
		public TableLayout editVocationListItemTable;
	}
}
