package com.glamourpromise.beauty.customer.fragment;
import org.json.JSONException;
import org.json.JSONObject;

import com.baidu.location.BDLocation;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.EcardListActivity;
import com.glamourpromise.beauty.customer.activity.EvaluateServiceActivity;
import com.glamourpromise.beauty.customer.activity.FavoriteListActivity;
import com.glamourpromise.beauty.customer.activity.OrderListActivity;
import com.glamourpromise.beauty.customer.activity.OrderPayListActivity;
import com.glamourpromise.beauty.customer.activity.PhotoAlbumListActivity;
import com.glamourpromise.beauty.customer.activity.RecordTemplateListActivity;
import com.glamourpromise.beauty.customer.activity.SettingActivity;
import com.glamourpromise.beauty.customer.activity.UnconfirmActivity;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseFragment;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.CircleImageView;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.LocationService;
import com.squareup.picasso.Picasso;

import android.app.AlertDialog;
import android.content.Intent;
import android.location.LocationManager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
/**
 * 我的Fragment
 * @author tim.zhang@bizapper.com
 */
public class PersonalFragment extends BaseFragment implements IConnectTask{
	private String CATEGORY_NAME="Customer";
	private String GET_CUSTOMER_INFO="GetCustomerInfo";
	private String LOCATION_CATEGORY_NAME="WebUtility";
	private String UPDATE_LOCATION="CustomerLocation";
	private int    allOrderCount=0,unpaidOrderCount=0,unConfirmCount=0,unReviewCount=0;
	private String headImageURL="",myName="",myLoginMobile="";
	private CircleImageView myHeadImage;
	private TextView myNameText,myLoginMobileText,allOrderCountText,unpaidOrderCountText,unConfirmCountText,unReviewCountText;
	private RelativeLayout myEcardRelativelayout,myPhotoRelativelayout,myRecordRelativelayout,myFavoriteRelativelayout,mySettingRelativelayout;
	private RelativeLayout allOrderRelativelayout,unPaidOrderRelativelayout,unConfirmOrderRelativelayout,unReviewOrderRelativelayout;
	private int     taskType=1;
	private ImageView myQRCodeImage;
	private View originalImageView;
	private ProgressBar progressBar;
	private AlertDialog originalQRCodeViewDialog;
	@Override
	public View onCreateView(LayoutInflater inflater,ViewGroup container,Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreateView(inflater, container, savedInstanceState);
		View personalView=inflater.inflate(R.xml.personal_fragment_layout,container,false);
		myHeadImage=(CircleImageView)personalView.findViewById(R.id.my_head_image);
		myNameText=(TextView)personalView.findViewById(R.id.my_name_text);
		myLoginMobileText=(TextView)personalView.findViewById(R.id.my_login_mobile_text);
		allOrderCountText=(TextView)personalView.findViewById(R.id.all_order_count_text);
		unpaidOrderCountText=(TextView)personalView.findViewById(R.id.unpayment_order_count_text);
		unConfirmCountText=(TextView)personalView.findViewById(R.id.unconfirm_order_count_text);
		unReviewCountText=(TextView) personalView.findViewById(R.id.evaluate_service_order_count_text);
		myEcardRelativelayout=(RelativeLayout)personalView.findViewById(R.id.my_ecard_relativelayout);
		myEcardRelativelayout.setOnClickListener(this);
		myPhotoRelativelayout=(RelativeLayout)personalView.findViewById(R.id.my_photo_album_relativelayout);
		myPhotoRelativelayout.setOnClickListener(this);
		myRecordRelativelayout=(RelativeLayout)personalView.findViewById(R.id.my_record_relativelayout);
		myRecordRelativelayout.setOnClickListener(this);
		myFavoriteRelativelayout=(RelativeLayout)personalView.findViewById(R.id.my_favorite_relativelayout);
		myFavoriteRelativelayout.setOnClickListener(this);
		mySettingRelativelayout=(RelativeLayout)personalView.findViewById(R.id.my_setting_relativelayout);
		mySettingRelativelayout.setOnClickListener(this);
		allOrderRelativelayout=(RelativeLayout)personalView.findViewById(R.id.all_order_relativelayout);
		allOrderRelativelayout.setOnClickListener(this);
		unPaidOrderRelativelayout=(RelativeLayout)personalView.findViewById(R.id.unpaid_order_relativelayout);
		unPaidOrderRelativelayout.setOnClickListener(this);
		unConfirmOrderRelativelayout=(RelativeLayout)personalView.findViewById(R.id.unconfirm_order_relativelayout);
		unConfirmOrderRelativelayout.setOnClickListener(this);
		unReviewOrderRelativelayout=(RelativeLayout)personalView.findViewById(R.id.unreview_order_relativelayout);
		unReviewOrderRelativelayout.setOnClickListener(this);
		myQRCodeImage=(ImageView)personalView.findViewById(R.id.my_qrcode_image);
		myQRCodeImage.setOnClickListener(this);
		taskType=1;
	    super.asyncRefrshView(this);
		return personalView;
	}
	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub	
		Intent destIntent=new Intent();
		switch(view.getId()){
		case R.id.my_ecard_relativelayout:
			destIntent.setClass(getActivity(),EcardListActivity.class);
			startActivity(destIntent);
			break;
		case R.id.my_photo_album_relativelayout:
			destIntent.setClass(getActivity(),PhotoAlbumListActivity.class);
			startActivity(destIntent);
			break;
		case R.id.my_record_relativelayout:
			destIntent.setClass(getActivity(),RecordTemplateListActivity.class);
			startActivity(destIntent);
			break;
		case R.id.my_favorite_relativelayout:
			destIntent.setClass(getActivity(),FavoriteListActivity.class);
			startActivity(destIntent);
			break;
		case R.id.my_setting_relativelayout:
			destIntent.setClass(getActivity(),SettingActivity.class);
			startActivity(destIntent);
			break;
		case R.id.all_order_relativelayout:
			destIntent.setClass(getActivity(),OrderListActivity.class);
			destIntent.putExtra("OrderClassify","-1");
			destIntent.putExtra("OrderStatus","-1");
			destIntent.putExtra("OrderPayStatus","-1");
			startActivity(destIntent);
			break;
		case R.id.unpaid_order_relativelayout:
			destIntent.setClass(getActivity(),OrderPayListActivity.class);
			startActivity(destIntent);
			break;
		case R.id.unconfirm_order_relativelayout:
			destIntent.setClass(getActivity(),UnconfirmActivity.class);
			startActivity(destIntent);
			break;
		case R.id.unreview_order_relativelayout:
			destIntent.setClass(getActivity(),EvaluateServiceActivity.class);
			startActivity(destIntent);
			break;
		case R.id.my_qrcode_image:
			taskType=3;
			super.asyncRefrshView(this);
			break;
		}	 
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para=new JSONObject();
		String categoryName="";
		String methodName="";
		//获取顾客信息
		if(taskType==1){
			categoryName=CATEGORY_NAME;
			methodName=GET_CUSTOMER_INFO;
		}
		//上传当前手机坐标
		else if(taskType==2){
			LocationService locationService=new LocationService();
			BDLocation location=locationService.getBaiDuLocation(getActivity());
			categoryName=LOCATION_CATEGORY_NAME;
			methodName=UPDATE_LOCATION;
			try {
				para.put("Longitude",location.getLongitude());
				para.put("Latitude",location.getLatitude());
			} catch (JSONException e) {
			}
		}
		//获取顾客的二维码
		else if(taskType==3){
			categoryName=LOCATION_CATEGORY_NAME;
			methodName="GetQRCode";
			try {
				para.put("CompanyCode",mLogInInfo.getCompanyCode());
				para.put("Code", mLogInInfo.getCustomerID());
				para.put("Type", 0);
				if (mApp.getScreenWidth() == 720)
					para.put("QRCodeSize", String.valueOf(10));
				else if (mApp.getScreenWidth() == 480)
					para.put("QRCodeSize", String.valueOf(6));
				else if (mApp.getScreenWidth() == 1080)
					para.put("QRCodeSize", String.valueOf(20));
				else if (mApp.getScreenWidth() == 1536)
					para.put("QRCodeSize", String.valueOf(15));
				else
					para.put("QRCodeSize", String.valueOf(10));
			} catch (JSONException e) {
				
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName,methodName,para.toString());
		WebApiRequest request = new WebApiRequest(categoryName,methodName,para.toString(),header);
		return request;
	}
	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		String responseString=response.getStringData();
		if(taskType==1){
			if(responseString!=null && !"".equals(responseString)){
				try {
					JSONObject resultJson=new JSONObject(responseString);
					if(resultJson.has("HeadImageURL") && !resultJson.isNull("HeadImageURL"))
						headImageURL=resultJson.getString("HeadImageURL");
					if(resultJson.has("CustomerName") && !resultJson.isNull("CustomerName"))
						myName=resultJson.getString("CustomerName");
					if(resultJson.has("LoginMobile") && !resultJson.isNull("LoginMobile"))
						myLoginMobile=resultJson.getString("LoginMobile");
					if(resultJson.has("AllOrderCount") && !resultJson.isNull("AllOrderCount"))
						allOrderCount=resultJson.getInt("AllOrderCount");
					if(resultJson.has("UnPaidCount") && !resultJson.isNull("UnPaidCount"))
						unpaidOrderCount=resultJson.getInt("UnPaidCount");
					if(resultJson.has("NeedConfirmTGCount") && !resultJson.isNull("NeedConfirmTGCount"))
						unConfirmCount=resultJson.getInt("NeedConfirmTGCount");
					if(resultJson.has("NeedReviewTGCount") && !resultJson.isNull("NeedReviewTGCount"))
						unReviewCount=resultJson.getInt("NeedReviewTGCount");
				} catch (JSONException e) {
				}
			}
		}
		
	}
	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskType==1){
					if(headImageURL==null || "".equals(headImageURL))
						myHeadImage.setImageResource(R.drawable.head_image_null);
					else
						Picasso.with(getActivity()).load(headImageURL).error(R.drawable.head_image_null).into(myHeadImage);
					myNameText.setText(myName);
					myLoginMobileText.setText(myLoginMobile);
					allOrderCountText.setText(String.valueOf(allOrderCount));
					unpaidOrderCountText.setText(String.valueOf(unpaidOrderCount));
					unConfirmCountText.setText(String.valueOf(unConfirmCount));
					unReviewCountText.setText(String.valueOf(unReviewCount));
					LocationManager locationManager=(LocationManager)getActivity().getSystemService(getActivity().LOCATION_SERVICE);
					if(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) || locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)){
						LocationService locationService=new LocationService();
						BDLocation location=locationService.getBaiDuLocation(getActivity());
						if(location!=null && location.getLocType()==161 && location.getLatitude()>0 && location.getLongitude()>0){
							taskType=2;
							super.asyncRefrshView(this);
						}
					}
					
				}
				else if(taskType==3){
					setOriginalQRcodeView(response.getStringData());
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				//DialogUtil.createShortDialog(getActivity(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getActivity(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}
	//显示二维码
	private void setOriginalQRcodeView(String originalQRcodeURL) {
		if (originalImageView == null) {
			LayoutInflater inflater = LayoutInflater.from(getActivity());
			originalImageView = inflater.inflate(R.xml.qr_image_original_image,null);
		}
		progressBar = (ProgressBar) originalImageView.findViewById(R.id.pb);
		ImageView originalImage = (ImageView) originalImageView.findViewById(R.id.original_image);
		Picasso.with(getActivity().getApplicationContext()).load(originalQRcodeURL).into(originalImage);
		if (originalQRCodeViewDialog == null)
			originalQRCodeViewDialog = new AlertDialog.Builder(getActivity()).create();
		originalQRCodeViewDialog.setView(originalImageView, 0, 0, 0, 0);
		originalImageView.setOnClickListener(new OnClickListener() {
			public void onClick(View paramView) {
				originalQRCodeViewDialog.cancel();
			}
		});
		originalQRCodeViewDialog.show();
		progressBar.setVisibility(View.INVISIBLE);
	}
	
	@Override
	public void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
		(((UserInfoApplication)getActivity().getApplication()).mLocationClient).stop();
	}
}	
