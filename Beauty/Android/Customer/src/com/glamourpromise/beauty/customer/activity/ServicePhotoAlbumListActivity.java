package com.glamourpromise.beauty.customer.activity;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.framework.Platform.ShareParams;
import cn.sharesdk.onekeyshare.OnekeyShare;
import cn.sharesdk.onekeyshare.ShareContentCustomizeCallback;
import cn.sharesdk.wechat.favorite.WechatFavorite;
import cn.sharesdk.wechat.friends.Wechat;
import cn.sharesdk.wechat.moments.WechatMoments;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.TreatmentImageListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.ServicePhotoAlbum;
import com.glamourpromise.beauty.customer.bean.TGPhotoAlbum;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.OrigianlImageView;
import com.glamourpromise.beauty.customer.handler.ShareContentCustomize;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DateUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.view.TreatmentImageGridView;
import com.squareup.picasso.Picasso;
/*
 * 某一个服务下的图片
 * */
public class ServicePhotoAlbumListActivity extends BaseActivity implements IConnectTask,OnClickListener{
	private static final String CATEGORY_NAME = "Image";
	private static final String GET_Photo_LIST = "getCustomerServicePic";
	private static final String SHARE_CATEGORY_NAME="ShareToOther",SHARE_METHOD_NAME="ShareGroupNo";
	private String       serviceCode;
	private int          serviceYear;
	private LinearLayout servicePhotoAlbumLL;
	private TextView   photoAlbumYearTitle;
	private ServicePhotoAlbum servicePhotoAlbum;
	private LayoutInflater layoutInflater;
	private int TASK_FLAG = 1;
	private int   urlType=1;
	private String groupNo;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_service_photo_album_list);
		super.setTitle(getString(R.string.title_photo_album_list));
		photoAlbumYearTitle=(TextView)findViewById(R.id.photo_album_year_title);
		Intent intent=getIntent();
		serviceCode=intent.getStringExtra("serviceCode");
		serviceYear=intent.getIntExtra("serviceYear",0);
		servicePhotoAlbumLL=(LinearLayout)findViewById(R.id.service_photo_album_ll);
		layoutInflater=LayoutInflater.from(this);
		ShareSDK.initSDK(this);
		TASK_FLAG=1;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		TASK_FLAG=1;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String categoryName="";
		String methodName="";
		if(TASK_FLAG==1){
			categoryName=CATEGORY_NAME;
			methodName=GET_Photo_LIST;
		}
		else if(TASK_FLAG==2){
			categoryName=SHARE_CATEGORY_NAME;
			methodName=SHARE_METHOD_NAME;
		}
		JSONObject para = new JSONObject();
		try {
			if(TASK_FLAG==1){
				para.put("ServiceCode",serviceCode);
				para.put("ServiceYear",serviceYear);
				para.put("ImageWidth",160);
				para.put("ImageHeight",160);
			}
			else if(TASK_FLAG==2){
				para.put("GroupNo",groupNo);
				para.put("Type",urlType);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName,methodName, para.toString());
		if(header.getFormalFlag()==0 || header.getFormalFlag()==1)
			urlType=1;
		else
			urlType=2;
		WebApiRequest request = new WebApiRequest(categoryName,methodName,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(TASK_FLAG==1){
					servicePhotoAlbum=new ServicePhotoAlbum();
					servicePhotoAlbum.parseByJson(response.getStringData());
					initPhotoAlbumListView();
				}
				else if(TASK_FLAG==2){
					String shareURL=response.getStringData();
					showShare(shareURL);
				}
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
		photoAlbumYearTitle.setText(servicePhotoAlbum.getServiceName());
		List<TGPhotoAlbum> tgPhotoAlbumList=servicePhotoAlbum.getTgPhotolAlbumList();
		if(tgPhotoAlbumList!=null && tgPhotoAlbumList.size()>0){
			servicePhotoAlbumLL.removeAllViews();
			for(final TGPhotoAlbum tgPhotoAlbum:tgPhotoAlbumList){
				View treatmentDetailView=layoutInflater.inflate(R.xml.service_photo_album_list_item,null);
				TextView  tgStartTime=(TextView)treatmentDetailView.findViewById(R.id.tg_start_time);
				tgStartTime.setText(DateUtil.getFormateDateByString(tgPhotoAlbum.getTgStartTime()));
				View      tgCommentDivideView=treatmentDetailView.findViewById(R.id.tg_photo_album_comments_divide_view);
				final TreatmentImageGridView tgTreatmentImageGridView=(TreatmentImageGridView)treatmentDetailView.findViewById(R.id.tg_treatment_image_list);
				if(tgPhotoAlbum.getImageURLs()!=null && tgPhotoAlbum.getImageURLs().size()>0){
					tgCommentDivideView.setVisibility(View.VISIBLE);
					tgTreatmentImageGridView.setVisibility(View.VISIBLE);
					TreatmentImageListAdapter  treatmentImageListAdapter=new TreatmentImageListAdapter(getApplicationContext(),tgPhotoAlbum.getImageURLs());
					tgTreatmentImageGridView.setAdapter(treatmentImageListAdapter);
				}
				else{
					tgCommentDivideView.setVisibility(View.GONE);
					tgTreatmentImageGridView.setVisibility(View.GONE);
				}
				ImageView tgPhotoEditIcon=(ImageView)treatmentDetailView.findViewById(R.id.tg_photo_edit_icon);
				ImageView tgShareIcon=(ImageView)treatmentDetailView.findViewById(R.id.tg_photo_share_icon);
				tgPhotoEditIcon.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent=new Intent(ServicePhotoAlbumListActivity.this,EditServicePhotoAlbumActivity.class);
						destIntent.putExtra("groupNO",tgPhotoAlbum.getGroupNo());
						startActivity(destIntent);
					}
				});
				tgShareIcon.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						groupNo=tgPhotoAlbum.getGroupNo();
						getShareData();
					}
				});
				TextView  tgBranchName=(TextView)treatmentDetailView.findViewById(R.id.tg_branch_name);
				tgBranchName.setText(tgPhotoAlbum.getBranchName());
				TextView tgPhotoAlbumComments=(TextView)treatmentDetailView.findViewById(R.id.tg_photo_album_comments);
				tgPhotoAlbumComments.setText(tgPhotoAlbum.getComments());
				servicePhotoAlbumLL.addView(treatmentDetailView);
			}
		}
	}
	private void getShareData(){
		TASK_FLAG=2;
		super.asyncRefrshView(this);
	}
	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}
	private void showShare(String shareURL) {	 
		 OnekeyShare oks = new OnekeyShare();
		 oks.setShareContentCustomizeCallback(new ShareContentCustomize(shareURL,this));
		 oks.show(this);
	}
}
