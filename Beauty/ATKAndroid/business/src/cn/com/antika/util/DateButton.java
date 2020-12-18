package cn.com.antika.util;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.DatePicker.OnDateChangedListener;
import android.widget.EditText;
import android.widget.LinearLayout;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;

@SuppressLint("ResourceType")
public class DateButton extends Button {
	public Calendar time = Calendar.getInstance(Locale.CHINA);
	public static final SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
	private DatePicker datePicker;
	private Button dataView;
	private AlertDialog dialog;
	private EditText editText = null;
	private int dateDialogShowType;// 0： 默认 1：服务有效期 3：带有清除功能的
	private ChangeServiceExpirationDateListener changeServiceExpirationDateListener;

	public DateButton(Context context,AttributeSet attrs,EditText editText,int dateDialogShowType,ChangeServiceExpirationDateListener changeServiceExpirationDateListener) {
		super(context, attrs);
		this.editText = editText;
		this.dateDialogShowType = dateDialogShowType;
		if (changeServiceExpirationDateListener != null) {
			this.changeServiceExpirationDateListener = changeServiceExpirationDateListener;
		}
		init();
	}

	public DateButton(Context context,EditText editText,int dateDialogShowType,ChangeServiceExpirationDateListener changeServiceExpirationDateListener) {
		super(context);
		this.editText = editText;
		this.dateDialogShowType = dateDialogShowType;
		if (changeServiceExpirationDateListener != null) {
			this.changeServiceExpirationDateListener = changeServiceExpirationDateListener;
		}
		init();
	}

	// 增加构造器
	public DateButton(Context context, Button dataView) {
		super(context);
		this.dataView = dataView;
	}

	public AlertDialog datePickerDialog() {
		LinearLayout dateLayout = (LinearLayout) LayoutInflater.from(getContext()).inflate(R.xml.date_picker, null);
		datePicker = (DatePicker) dateLayout.findViewById(R.id.date_picker);
		if (dataView == null)
			init();
		OnDateChangedListener dateListener = new OnDateChangedListener() {

			@Override
			public void onDateChanged(DatePicker view, int year,
					int monthOfYear, int dayOfMonth) {
				// TODO Auto-generated method stub
				time.set(Calendar.YEAR, year);
				time.set(Calendar.MONTH, monthOfYear);
				time.set(Calendar.DAY_OF_MONTH, dayOfMonth);
			}
		};

		datePicker.init(time.get(Calendar.YEAR), time.get(Calendar.MONTH),
				time.get(Calendar.DAY_OF_MONTH), dateListener);
		datePicker
				.setDescendantFocusability(DatePicker.FOCUS_BLOCK_DESCENDANTS);
		// 选择服务有效期的日期对话框
		if (dateDialogShowType == Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION) {
			dialog = new AlertDialog.Builder(getContext(),
					R.style.CustomerAlertDialog)
					.setTitle("选择日期")
					.setView(dateLayout)
					.setPositiveButton("确定",
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method stub
									updateLabel();
									time.set(Calendar.YEAR,datePicker.getYear());
									time.set(Calendar.MONTH,datePicker.getMonth());
									time.set(Calendar.DAY_OF_MONTH,datePicker.getDayOfMonth());
									updateEditText();
								}
							})
					.setNegativeButton("无有效期",new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									// TODO Auto-generated method stub
									setDefaultExpirationDate();
								}
							})
					.setNeutralButton("取消",
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method stub

								}
							}).show();
		} else if (dateDialogShowType == Constant.DATE_DIALOG_SHOW_TYPE_ClEAR) {
			dialog = new AlertDialog.Builder(getContext(),R.style.CustomerAlertDialog)
					.setTitle("选择日期").setView(dateLayout).setPositiveButton("确定",new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									// TODO Auto-generated method stub
									updateLabel();
									time.set(Calendar.YEAR,datePicker.getYear());
									time.set(Calendar.MONTH,datePicker.getMonth());
									time.set(Calendar.DAY_OF_MONTH,datePicker.getDayOfMonth());
									updateEditText();
								}
							})
					.setNegativeButton("清空",new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									// TODO Auto-generated method stub
									clearTextValue();
								}
							})
					.setNeutralButton("取消",new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									// TODO Auto-generated method stub

								}
							}).show();
		} else if (dateDialogShowType == Constant.DATE_DIALOG_SHOW_TYPE_DEFAULT) {
			dialog = new AlertDialog.Builder(getContext(),
					R.style.CustomerAlertDialog)
					.setTitle("选择日期")
					.setView(dateLayout)
					.setPositiveButton("确定",
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method stub
									updateLabel();
									time.set(Calendar.YEAR,
											datePicker.getYear());
									time.set(Calendar.MONTH,
											datePicker.getMonth());
									time.set(Calendar.DAY_OF_MONTH,
											datePicker.getDayOfMonth());

									updateEditText();
								}
							})
					.setNegativeButton("取消",
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method stub

								}
							}).show();
		}
		return dialog;
	}

	/** 
     *  
     */
	private void init() {
		// this.setBackgroundResource(R.drawable.datebutton_bg);
		this.setGravity(Gravity.LEFT);
		this.setTextColor(Color.BLACK);

		this.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View view) {
				// 生成一个DatePickerDialog对象，并显示。显示的DatePickerDialog控件可以选择年月日，并设置
				datePickerDialog();
			}
		});

		updateLabel();
	}

	/**
	 * 更新标签
	 */
	public void updateLabel() {
		if (dataView != null) {
			dataView.setText(format.format(time.getTime()));
		}
		this.setText(format.format(time.getTime()));

	}

	/*
	 * 将时间信息填充到文本框上
	 */
	public void updateEditText() {
		if (dateDialogShowType == Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION) {
			if (DateUtil.compareDate(format.format(time.getTime()))) {
				DialogUtil.createShortDialog(getContext(),"所选日期不能在今天之前!");
			} else {
				this.editText.setText(format.format(time.getTime()));
				if (this.changeServiceExpirationDateListener != null) {
					changeServiceExpirationDateListener.changeServiceExpirationDate(this.editText.getText().toString());
				}
			}
		}
		else if(dateDialogShowType==Constant.DATE_DIALOG_SHOW_TYPE_DEFAULT){
			this.editText.setText(format.format(time.getTime()));
			if(this.changeServiceExpirationDateListener!=null){
				changeServiceExpirationDateListener.changeServiceExpirationDate(this.editText.getText().toString());
			}
		}
		else {
			this.editText.setText(format.format(time.getTime()));
		}
	}

	public void setDefaultExpirationDate() {
		this.editText.setText("2099-12-31");
		if (this.changeServiceExpirationDateListener != null) {
			changeServiceExpirationDateListener.changeServiceExpirationDate(this.editText.getText().toString());
		}
	}

	// 清除文本上的值
	public void clearTextValue() {
		this.editText.setText("");
	}

	/**
	 * @return 获得时间字符串"yyyy-MM-dd HH:mm:ss"
	 */
	public String getDateString() {
		return format.format(time.getTime());
	}

	public void setDate(String datestr) {
		try {
			time.setTime(format.parse(datestr));
			updateLabel();
		} catch (ParseException e) {
			e.printStackTrace();
		}
	}
}
