package com.glamourpromise.beauty.customer.activity;

import java.io.ByteArrayOutputStream;
import java.io.File;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.view.View.OnClickListener;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CustomerInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.Base64Util;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.UploadImageUtil;
import com.squareup.picasso.Picasso;

public class EditPersonMessageActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private  CustomerInfo customer;
	private String updateHeadImageString;
	private static final String CATEGROY_NAME="Customer";
	private static final String UPDATE_CUSTOMER_BASIC="updateCustomerBasic";
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_edit_person_message);
		super.setTitle(getString(R.string.eidt_person_message));
		Intent intent=getIntent();
		customer=new CustomerInfo();
		customer.setCustomerID(intent.getIntExtra("customerID",0));
		customer.setCustomerName(intent.getStringExtra("customerName"));
		customer.setHeadImageUrl(intent.getStringExtra("customerHeadImage"));
		customer.setGender(intent.getIntExtra("customerGender",0));
		initView();
	}
	protected void initView(){
		ImageView headImageView=(ImageView) findViewById(R.id.edit_head_iamge);
		if(customer.getHeadImageUrl()==null || customer.getHeadImageUrl().equals(""))
			headImageView.setBackgroundResource(R.drawable.head_image_null);
		else
			Picasso.with(this).load(customer.getHeadImageUrl()).error(R.drawable.head_image_null).into(headImageView);
		((EditText)findViewById(R.id.person_message_name)).setText(customer.getCustomerName());
		if(customer.getGender()==0)
			((ImageView)findViewById(R.id.person_message_gender_female_select_icon)).setBackgroundResource(R.drawable.one_select_icon);
		else if(customer.getGender()==1)
			((ImageView)findViewById(R.id.person_message_gender_male_select_icon)).setBackgroundResource(R.drawable.one_select_icon);
		//设置点击监听
		findViewById(R.id.edit_head_iamge_relativelayout).setOnClickListener(this);
		findViewById(R.id.person_message_gender_female_select_icon).setOnClickListener(this);
		findViewById(R.id.person_message_gender_male_select_icon).setOnClickListener(this);
		findViewById(R.id.person_message_save_btn).setOnClickListener(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject jsonParam=new JSONObject();
		try {
			jsonParam.put("CustomerName",((EditText)findViewById(R.id.person_message_name)).getText().toString());
			jsonParam.put("Gender",customer.getGender());
			if(updateHeadImageString!=null && !updateHeadImageString.equals("")){
				jsonParam.put("HeadFlag",1);
				jsonParam.put("ImageString",updateHeadImageString);
			}
			else
				jsonParam.put("HeadFlag",0);
			jsonParam.put("ImageType",".jpg");
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGROY_NAME,UPDATE_CUSTOMER_BASIC,jsonParam.toString());
		WebApiRequest request = new WebApiRequest(CATEGROY_NAME,UPDATE_CUSTOMER_BASIC,jsonParam.toString(),header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				DialogUtil.createShortDialog(this,"修改资料成功！");
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
	public void onClick(View v) {
		super.onClick(v);
		switch (v.getId()) {
		case R.id.edit_head_iamge_relativelayout:
			final CharSequence[] items = { "本地选择", "拍照" };
			AlertDialog dlg = new AlertDialog.Builder(this).setTitle("更换头像")
					.setItems(items, new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							// TODO Auto-generated method stub
							if (which == 1) {
								Intent getImageByCamera = new Intent(
										"android.media.action.IMAGE_CAPTURE");
								getImageByCamera.putExtra(
										MediaStore.EXTRA_OUTPUT,
										Uri.fromFile(new File(Environment.getExternalStorageDirectory(),"xiaoma.jpg")));
								startActivityForResult(getImageByCamera, 1);
							} else {
								Intent getImage = new Intent(Intent.ACTION_GET_CONTENT);
								getImage.addCategory(Intent.CATEGORY_OPENABLE);
								getImage.setType("image/jpeg");
								startActivityForResult(getImage, 0);
							}
						}
					}).create();
			dlg.show();
			break;
		case R.id.person_message_gender_female_select_icon:
			changeCustomerGender();
			break;
		case R.id.person_message_gender_male_select_icon:
			changeCustomerGender();
			break;
		case R.id.person_message_save_btn:
			if(((EditText)findViewById(R.id.person_message_name)).getText()==null || ((EditText)findViewById(R.id.person_message_name)).getText().toString().trim().equals(""))
				DialogUtil.createShortDialog(this,"姓名不允许为空");
			else{
				super.showProgressDialog();
				super.asyncRefrshView(this);
			}
			break;
		}
	}
	protected void changeCustomerGender(){
		if(customer.getGender()==0){
			((ImageView)findViewById(R.id.person_message_gender_male_select_icon)).setBackgroundResource(R.drawable.one_select_icon);
			((ImageView)findViewById(R.id.person_message_gender_female_select_icon)).setBackgroundResource(R.drawable.one_unselect_icon);
			customer.setGender(1);
		}	
		else if(customer.getGender()==1){
			((ImageView)findViewById(R.id.person_message_gender_male_select_icon)).setBackgroundResource(R.drawable.one_unselect_icon);
			((ImageView)findViewById(R.id.person_message_gender_female_select_icon)).setBackgroundResource(R.drawable.one_select_icon);
			customer.setGender(0);
		}	
	}
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		Bitmap myBitmap = null;
		byte[] mContent = null;
		if (requestCode == 0) {
			if (data != null) {
				Uri selectedImage = data.getData();
				cropImage(selectedImage, 320, 320, Constant.CROP_PICTURE);
			}
		}
		else if (requestCode == 1 && resultCode!=RESULT_CANCELED ) {
			File temp = new File(Environment.getExternalStorageDirectory()+ "/xiaoma.jpg");
			cropImage(Uri.fromFile(temp), 320, 320, Constant.CROP_PICTURE);
		} else if (requestCode == Constant.CROP_PICTURE) {
			if (data != null) {
				Uri cropReturnUri = data.getData();
				if (cropReturnUri != null)
					myBitmap = BitmapFactory
							.decodeFile(cropReturnUri.getPath());
				ByteArrayOutputStream baos = null;
				if (myBitmap == null) {
					Bundle extra = data.getExtras();
					if (extra != null) {
						myBitmap = (Bitmap) extra.get("data");
						baos = new ByteArrayOutputStream();
						myBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
					}
				}
				myBitmap = UploadImageUtil.resizeBitmap(myBitmap,Constant.RESIZEBITMAPMAXWIDTH,Constant.RESIZEBITMAPMAXWIDTH);
				if (baos != null)
					mContent = baos.toByteArray();
				((ImageView)findViewById(R.id.edit_head_iamge)).setImageBitmap(myBitmap);
			}
			if (mContent != null) {
				updateHeadImageString = new String(Base64Util.encode(mContent));
			}

		}
	}
	public void cropImage(Uri uri, int outputX, int outputY, int requestCode) {		
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(uri, "image/*");
		intent.putExtra("crop", "true");
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		intent.putExtra("outputX", outputX);
		intent.putExtra("outputY", outputY);
		intent.putExtra("outputFormat", "JPEG");
		intent.putExtra("noFaceDetection", true);
		intent.putExtra("return-data", true);
		startActivityForResult(intent, requestCode);
	}
}
