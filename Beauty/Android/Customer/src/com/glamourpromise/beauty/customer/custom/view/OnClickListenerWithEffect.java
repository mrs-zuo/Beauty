package com.glamourpromise.beauty.customer.custom.view;

import com.glamourpromise.beauty.customer.R;

import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

/**
 * 点击时添加效果
 * @author hongchuan.du
 *
 */
public class OnClickListenerWithEffect implements View.OnClickListener{
	private Animation aniClick;
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if(aniClick == null)
			aniClick = AnimationUtils.loadAnimation(v.getContext(), R.anim.anim_button_click);
		v.startAnimation(aniClick);
	}

}
