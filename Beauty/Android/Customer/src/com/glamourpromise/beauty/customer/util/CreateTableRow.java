package com.glamourpromise.beauty.customer.util;

import com.glamourpromise.beauty.customer.R;

import android.content.Context;
import android.view.Gravity;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import android.widget.TableRow.LayoutParams;

public class CreateTableRow
{
	public void createTableRowWithOneChildView(Context  context,RelativeLayout tablerow, TextView textview,String Content, int ContentType)
	{
		if(ContentType == 1)
		{
			textview.setTextColor(context.getResources().getColor(R.color.text_color)); 
			textview.setTextSize(20);
		}
		else
		{
			textview.setTextSize(18);
		}
		textview.setText(Content);  
		//tablerow.setBackgroundResource(R.xml.shape_straight_line);
		tablerow.addView(textview);
		tablerow.setPadding(8, 8, 8, 8);
	}
	public void createTableRowWithTwoChildView(Context  context,RelativeLayout tablerow, TextView textview,String Content, int ContentType)
	{
		textview.setText(Content);
		if(ContentType == 1)
		{
			textview.setTextSize(20);
			textview.setTextColor(context.getResources().getColor(R.color.text_color)); 
			tablerow.setPadding(8, 8, 8, 8);
		}
		else
		{
			textview.setTextSize(18);
		}	
		//tablerow.setBackgroundResource(R.xml.shape_straight_line);
		tablerow.addView(textview);
	}
}
