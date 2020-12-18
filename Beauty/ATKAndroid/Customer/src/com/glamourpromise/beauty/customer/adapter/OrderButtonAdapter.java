package com.glamourpromise.beauty.customer.adapter;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;

import com.glamourpromise.beauty.customer.R;

public class OrderButtonAdapter extends BaseAdapter {
	private Context mContext;
	private ImageView[] imgItems;

	public OrderButtonAdapter(Context c, int[] picIds, int width, int height,
			int[] selResId) {
		mContext = c;
		
		imgItems = new ImageView[picIds.length];
		for (int i = 0; i < picIds.length; i++) {
			imgItems[i] = new ImageView(mContext);
			imgItems[i]
					.setLayoutParams(new GridView.LayoutParams(width, height));// ����ImageView���
			imgItems[i].setAdjustViewBounds(false);
			// imgItems[i].setScaleType(ImageView.ScaleType.CENTER_CROP);
			imgItems[i].setPadding(2, 2, 2, 2);
			imgItems[i].setImageResource(picIds[i]);
		}
	}

	public int getCount() {
		return imgItems.length;
	}

	public Object getItem(int position) {
		return position;
	}

	public long getItemId(int position) {
		return position;
	}

	/**
	 * ����ѡ�е�Ч��
	 */
	public void SetFocus(int index) {
//		for (int i = 0; i < imgItems.length; i++) {
//			if (i != index) {
//				imgItems[i].setBackgroundResource(notSelectResourseID[i]);// �ָ�δѡ�е���ʽ
//			}
//		}
//		imgItems[index].setBackgroundResource(selectResourseID[index]);// ����ѡ�е���ʽ
		if(index == 0){
			Log.v("SetFocus", String.valueOf(index));
			imgItems[0].setImageResource(R.drawable.service_detail_red);
			imgItems[1].setImageResource(R.drawable.service_effect_white);
		}
		else if(index == 1){
			Log.v("SetFocus", String.valueOf(index));
			imgItems[0].setImageResource(R.drawable.service_detail_white);
			imgItems[1].setImageResource(R.drawable.service_effect_red);
		}
	}

	public View getView(int position, View convertView, ViewGroup parent) {
		ImageView imageView;
		if (convertView == null) {
			imageView = imgItems[position];
		} else {
			imageView = (ImageView) convertView;
		}
		return imageView;
	}
}
