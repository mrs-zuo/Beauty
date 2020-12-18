package com.glamourpromise.beauty.customer.util;

import java.util.List;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.TableRowItemInformation;
import com.glamourpromise.beauty.customer.custom.view.TextViewBorderUnder;

import android.content.Context;
import android.content.res.Resources;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import android.widget.TableRow.LayoutParams;

public class CreateLayoutInTableLayout {
	TableRowItemInformation rowItemInformation;

	public void CreateLayoutWithOneChildView(Context context,
			TableRow tablerow, String Content, int ContentType) {
		TextView textView = new TextView(context);
		if (ContentType == 1) {
			textView.setTextColor(context.getResources().getColor(R.color.text_color));
			textView.setTextSize(20);
		} else {
			textView.setTextSize(18);
		}
		textView.setText(Content);
		// tablerow.setBackgroundResource(R.xml.shape_straight_line);
		tablerow.addView(textView);
		tablerow.setPadding(5, 5, 5, 5);
	}

	public void createLayoutWithTwoChildView(Context context,
			TableRow tablerow, String Content, int ContentType) {
		TextView textView = new TextView(context);

		textView.setText(Content);
		if (ContentType == 1) {
			textView.setTextSize(20);
			textView.setTextColor(context.getResources().getColor(R.color.text_color));
			tablerow.setPadding(8, 8, 8, 8);
		} else {
			textView.setTextSize(18);
			// textview.setGravity(Gravity.CENTER);
			TableRow.LayoutParams lp = new TableRow.LayoutParams();
			// lp.gravity = Gravity.RIGHT & Gravity.CENTER_VERTICAL;
			// lp.width = LayoutParams.MATCH_PARENT;
			textView.setLayoutParams(lp);
			textView.setGravity(Gravity.CENTER);
		}
		// tablerow.setBackgroundResource(R.xml.shape_straight_line);
		tablerow.addView(textView);
	}

	
	public void createTableLayout(Context context, TableLayout tableLayout,
			List<TableRowItemInformation> rowItemInformationList,
			RelativeLayout.LayoutParams lParam1) {
		// 设置TableLayout的属性
		tableLayout.setBackgroundResource(R.xml.shape_corner_round);
//		tableLayout.setPadding(5, 5, 5, 5);

		Resources res = context.getResources(); 
		
		// 根据list的大小创建每行的内容
		for (int i = 0; i < rowItemInformationList.size(); i++) {

			rowItemInformation = rowItemInformationList.get(i);
			rowItemInformation.getRelativeLayoutOne().setPadding(8, 10, 8, 10);
			TextView titleView = new TextView(context);
			TextView contentView = new TextView(context);

			// 先显示标题
			if (!rowItemInformation.getTitleName().equals("")) {
				titleView.setText(rowItemInformation.getTitleName());
				titleView.setTextColor(context.getResources().getColor(
						R.color.text_color));
				titleView.setTextSize(TypedValue.COMPLEX_UNIT_PX, res.getDimension(R.dimen.text_size_normal));
				
				rowItemInformation.getRelativeLayoutOne().addView(titleView);
			}

			// 内容
			if (rowItemInformation.getType() == 0) {
				contentView.setText(rowItemInformation.getContent());
			} else if (rowItemInformation.getType() == 1) {
				contentView.setText("¥  " + rowItemInformation.getContent());
			}

			contentView.setTextSize(TypedValue.COMPLEX_UNIT_PX, res.getDimension(R.dimen.text_size_normal));
			contentView.setId(1300);

			if (rowItemInformation.getFlag() == 0) {
				// 内容
				RelativeLayout.LayoutParams lParam = new RelativeLayout.LayoutParams(
						LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
				if (!rowItemInformation.getTitleName().equals("")) {
					lParam.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
				}
				contentView.setLayoutParams(lParam);

				rowItemInformation.getRelativeLayoutOne().addView(contentView);

				if (!rowItemInformation.getContentTwo().equals("")) {
					com.glamourpromise.beauty.customer.custom.view.TextViewBorderUnder textViewBorderUnder = new TextViewBorderUnder(
							context, null);
					if (rowItemInformation.getType() == 0) {
						textViewBorderUnder.setText(rowItemInformation
								.getContentTwo());
					} else if (rowItemInformation.getType() == 1) {
						textViewBorderUnder.setText("¥  "
								+ rowItemInformation.getContentTwo());
					}

					RelativeLayout.LayoutParams lParamTwo = new RelativeLayout.LayoutParams(
							LayoutParams.WRAP_CONTENT,
							LayoutParams.WRAP_CONTENT);
					lParamTwo.addRule(RelativeLayout.LEFT_OF, 1300);
					lParamTwo.addRule(RelativeLayout.CENTER_VERTICAL);

					textViewBorderUnder.setLayoutParams(lParamTwo);
					rowItemInformation.getRelativeLayoutOne().addView(
							textViewBorderUnder);
				}
				tableLayout.addView(rowItemInformation.getRelativeLayoutOne(),
						new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT,
								LayoutParams.WRAP_CONTENT));

			} else {
				Log.v("Flag", String.valueOf(1));

				tableLayout.addView(rowItemInformation.getRelativeLayoutOne(),
						new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT,
								LayoutParams.WRAP_CONTENT));

				tableLayout.addView(rowItemInformation.getTwoChildLineView(),
						new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT,
								1));

				rowItemInformation.getRelativeLayoutTwo()
						.setPadding(8,10, 8, 10);
				rowItemInformation.getRelativeLayoutTwo().addView(contentView);
				tableLayout.addView(rowItemInformation.getRelativeLayoutTwo(),
						new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT,
								LayoutParams.WRAP_CONTENT));
			}
			if (rowItemInformation.getRowLineView() != null) {
				tableLayout.addView(rowItemInformation.getRowLineView(),
						new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT,
								1));
			}
		}

	}
}
