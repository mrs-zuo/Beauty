package com.glamourpromise.beauty.customer.activity;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.ImageView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.RecordImage;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.squareup.picasso.Picasso;
/*
 * 编辑某一张图片
 * */
public class EditServicePhotoAlbumSingleActivity extends BaseActivity implements IConnectTask, OnClickListener {
	private static final String CATEGORY_NAME = "Image",EDIT_PHOTO = "editCustomerPic";	
	private String       groupNo;
	private RecordImage  recordImage;
	private ImageView    photoAlbumImageView;
	private EditText     photoAlbumTagText;
	private int          TASK_FLAG=0;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_edit_service_photo_album_single);
		super.setTitle(getString(R.string.edit_photo_album_single));
		photoAlbumImageView=(ImageView)findViewById(R.id.photo_album_image);
		photoAlbumTagText=(EditText)findViewById(R.id.photo_album_tag);
		groupNo=getIntent().getStringExtra("groupNo");
		recordImage=(RecordImage)getIntent().getSerializableExtra("recordImage");
		if(recordImage.getRecordImageUrl().equals("")){
			photoAlbumImageView.setImageResource(R.drawable.head_image_null);
		}else{
			String originalImageUrl=recordImage.getRecordImageUrl().split("&")[0];
			Picasso.with(getApplicationContext()).load(originalImageUrl).error(R.drawable.head_image_null).into(photoAlbumImageView);
		}
		photoAlbumTagText.setText(recordImage.getRecordImageTag());
		findViewById(R.id.photo_album_delete).setOnClickListener(this);
		findViewById(R.id.photo_album_update).setOnClickListener(this);
	}
	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para=new JSONObject();
		try {
			para.put("GroupNo",groupNo);
			para.put("RecordImgID",recordImage.getRecordImageID());
			if(TASK_FLAG==1){
				para.put("Type",2);
			}
			else if(TASK_FLAG==2){
				para.put("Type",3);
				String imageTag=photoAlbumTagText.getText().toString();
				if(imageTag==null || "".equals(imageTag))
					para.put("ImageTag","");
				else
					para.put("ImageTag",imageTag);
			}
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,EDIT_PHOTO,para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,EDIT_PHOTO,para.toString(),header);
		return request;
	}
	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				this.finish();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}
	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
	}
	private void deletePhoto(){
		TASK_FLAG=1;
		super.asyncRefrshView(this);
	}
	private void updatePhoto(){
		TASK_FLAG=2;
		super.asyncRefrshView(this);
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		super.onClick(view);
		switch(view.getId()){
		case R.id.photo_album_delete:
			Dialog dialog = new AlertDialog.Builder(this)
			.setTitle(getString(R.string.delete_dialog_title))
			.setMessage(R.string.delete_tg_photo_alubm)
			.setPositiveButton(getString(R.string.ok),
					new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog,
								int which) {
							deletePhoto();
						}
					})
			.setNegativeButton(getString(R.string.cancel),
					new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog,
								int which) {
							dialog.dismiss();
							dialog = null;
						}
					}).create();
	dialog.show();
	dialog.setCancelable(false);
			break;
		case R.id.photo_album_update:
			updatePhoto();
			break;
		}
	}
}
