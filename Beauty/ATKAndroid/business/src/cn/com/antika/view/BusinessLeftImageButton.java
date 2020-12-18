package cn.com.antika.view;
import cn.com.antika.view.menu.BusinessLeftMenu;
import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageButton;
import android.view.View;

public class BusinessLeftImageButton extends ImageButton{
	private BusinessLeftMenu businessLeftMenu;
	public BusinessLeftImageButton(Context context) {
		super(context);
	}

	public BusinessLeftImageButton(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public void createBusinessLeftMenu(BusinessLeftMenu businessLeftMenu) {
		this.businessLeftMenu = businessLeftMenu;
		final BusinessLeftMenu blm=businessLeftMenu;
		this.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (blm != null)
					blm.getMenu().toggle();
			}
		});
	}
}
