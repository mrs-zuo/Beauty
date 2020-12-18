package cn.com.antika.view;
import cn.com.antika.view.menu.BusinessRightMenu;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageButton;

public class BusinessRightImageButton extends ImageButton{
	private BusinessRightMenu businessRightMenu;
	public BusinessRightImageButton(Context context) {
		super(context);
	}
	public BusinessRightImageButton(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	public void createBusinessRightMenu(BusinessRightMenu businessRightMenu) {
		this.businessRightMenu = businessRightMenu;
		final BusinessRightMenu brm=this.businessRightMenu;
		this.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (brm != null)
				{
					brm.getMenu().toggle();
				}	
			}
		});
	}
}
