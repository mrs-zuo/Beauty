package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.TreatmentImageListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.NewPhotoAlbumListInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.view.TreatmentImageGridView;
/*
 * 某一个年份下面的所有服务的图片
 * */
public class PhotoAlbumListActivity extends BaseActivity implements IConnectTask,OnClickListener{
	private static final String CATEGORY_NAME = "Image";
	private static final String GET_Photo_LIST = "getCustomerRecPic";
	private int    currentYear,filterYear;
	private LinearLayout photoAlbumLL;
	private TextView   photoAlbumYearTitle;
	private List<NewPhotoAlbumListInformation> photoAlbumList=new ArrayList<NewPhotoAlbumListInformation>();
	private LayoutInflater layoutInflater;
	private ImageView      photoAlbumYearFilterIcon;
	private PopupWindow    popupwindow;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_photo_album_list);
		super.setTitle(getString(R.string.title_photo_album_list));
		photoAlbumYearTitle=(TextView)findViewById(R.id.photo_album_year_title);
		Calendar nowDate=Calendar.getInstance();
		int      nowYear=nowDate.get(Calendar.YEAR);
		currentYear=nowYear;
		photoAlbumLL =(LinearLayout)findViewById(R.id.photo_album_ll);
		photoAlbumYearFilterIcon=(ImageView)findViewById(R.id.photo_album_filter);
		photoAlbumYearFilterIcon.setOnClickListener(this);
		layoutInflater=LayoutInflater.from(this);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("ServiceYear",currentYear);
			para.put("ImageWidth",160);
			para.put("ImageHeight",160);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_Photo_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_Photo_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				photoAlbumList = NewPhotoAlbumListInformation.parseListByJson(response.getStringData());
				initPhotoAlbumListView();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
		
	}
	private void  initPhotoAlbumListView(){
		photoAlbumYearTitle.setText(currentYear+"年");
		photoAlbumLL.removeAllViews();
		if(photoAlbumList!=null && photoAlbumList.size()>0){
			for(final NewPhotoAlbumListInformation newPhotoAlbum:photoAlbumList){
				View treatmentDetailView=layoutInflater.inflate(R.xml.new_photo_album_list_item,null);
				RelativeLayout servicePhotoAlbumRL=(RelativeLayout)treatmentDetailView.findViewById(R.id.tg_detail_rl);
				servicePhotoAlbumRL.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent=new Intent(PhotoAlbumListActivity.this,ServicePhotoAlbumListActivity.class);
						destIntent.putExtra("serviceCode",newPhotoAlbum.getServiceCode());
						destIntent.putExtra("serviceYear",currentYear);
						startActivity(destIntent);
					}
				});
				TextView  serviceName=(TextView)treatmentDetailView.findViewById(R.id.service_name);
				serviceName.setText(newPhotoAlbum.getServiceName());
				View  photoAlbumDivideView=treatmentDetailView.findViewById(R.id.photo_album_divide_view);
				
				final TreatmentImageGridView treatmentImageGridView=(TreatmentImageGridView)treatmentDetailView.findViewById(R.id.treatment_image_list);
				if(newPhotoAlbum.getImageURLs()!=null && newPhotoAlbum.getImageURLs().size()>0){
					photoAlbumDivideView.setVisibility(View.VISIBLE);
					treatmentImageGridView.setVisibility(View.VISIBLE);
					TreatmentImageListAdapter  treatmentImageListAdapter=new TreatmentImageListAdapter(getApplicationContext(),newPhotoAlbum.getImageURLs());
					treatmentImageGridView.setAdapter(treatmentImageListAdapter);
				}
				else{
					photoAlbumDivideView.setVisibility(View.GONE);
					treatmentImageGridView.setVisibility(View.GONE);
				}
				photoAlbumLL.addView(treatmentDetailView);
			}
		}
	}
	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}
	public void initmPopupWindowView(List<Integer> yearList) {  
		  
        // // 获取自定义布局文件pop.xml的视图  
        View customView = getLayoutInflater().inflate(R.xml.filter_year,null);
        final LinearLayout filterYearLL=(LinearLayout)customView.findViewById(R.id.filter_year_ll);
        filterYearLL.removeAllViews();
        for(final Integer year:yearList){
        	View yearItemView=getLayoutInflater().inflate(R.xml.filter_year_item,null);
        	final Button yearBtn=(Button)yearItemView.findViewById(R.id.year_btn);
        	yearBtn.setText(String.valueOf(year));
        	yearItemView.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					int childCount=filterYearLL.getChildCount();
					for(int i=0;i<childCount;i++){
						((Button)filterYearLL.getChildAt(i)).setTextSize(TypedValue.COMPLEX_UNIT_SP,16);
					}
					yearBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP,22);
					filterYear=year;
				}
			});
        	filterYearLL.addView(yearItemView);
        }
        Button cancelBtn=(Button)customView.findViewById(R.id.cancel_btn);
        cancelBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				if (popupwindow != null && popupwindow.isShowing()) {  
                    popupwindow.dismiss();  
                    popupwindow = null;  
                } 
			}
		});
        Button okBtn=(Button)customView.findViewById(R.id.ok_btn);
        okBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				filterByYear();
			}
		});
        popupwindow = new PopupWindow(customView,LayoutParams.MATCH_PARENT,LayoutParams.WRAP_CONTENT,true); 
        
        customView.setOnTouchListener(new OnTouchListener() { 
            @Override  
            public boolean onTouch(View v, MotionEvent event) {  
                if (popupwindow != null && popupwindow.isShowing()) {  
                    popupwindow.dismiss();  
                    popupwindow = null;  
                }  
                return false;  
            }  
        }); 
        popupwindow.showAtLocation(findViewById(R.id.photo_album_filter),Gravity.BOTTOM,0,0);
    }  
	private void filterByYear(){
		currentYear=filterYear;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		super.onClick(view);
		//展示可供选择年份PopWindow
		if(view.getId()==R.id.photo_album_filter){
			if(popupwindow!=null && popupwindow.isShowing())
				popupwindow.dismiss();
			else{
				//获取从2015年开始
				Calendar nowDate=Calendar.getInstance();
				int      nowYear=nowDate.get(Calendar.YEAR);
				List<Integer> yearList=new ArrayList<Integer>();
				for(int i=2015;i<nowYear+1;i++){
					yearList.add(i);
				}
				initmPopupWindowView(yearList);
			}
		}
	}
}
