package com.glamourpromise.beauty.customer.activity;
import java.io.ByteArrayOutputStream;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.ImageView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.TGPhotoAlbum;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.Base64Util;
import com.glamourpromise.beauty.customer.util.CropUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.UploadImageUtil;
/*
 * 编辑某一个TG下的图片
 * */
public class AddNewServicePhotoAlbumActivity extends BaseActivity implements IConnectTask, OnClickListener {
	private static final String CATEGORY_NAME = "Image",ADD_NEW_PHOTO = "UpdateServiceEffectImage";
	private ImageView    addNewPhotoAlbumImageView;
	private String       addNewPhotoImageString;
	private TGPhotoAlbum tgPhotoAlbum;
	private Uri imageUri;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_add_new_service_photo_album);
		super.setTitle(getString(R.string.add_new_photo_album));
		findViewById(R.id.add_new_photo_album_submit).setOnClickListener(this);
		addNewPhotoAlbumImageView=(ImageView)findViewById(R.id.add_new_photo_album_image);
		addNewPhotoAlbumImageView.setOnClickListener(this);
		tgPhotoAlbum=(TGPhotoAlbum)getIntent().getSerializableExtra("tgPhotoAlbum");
		imageUri=Uri.parse(Constant.IMAGE_FILE_LOCATION);
	}
	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("GroupNo",tgPhotoAlbum.getGroupNo());
			para.put("CustomerID",Integer.parseInt(mCustomerID));
			para.put("Comment",tgPhotoAlbum.getComments());
			JSONArray addPhotoJsonArray=new JSONArray();
			JSONObject newPhotoJson=new JSONObject();
			newPhotoJson.put("ImageFormat",".JPEG");
			newPhotoJson.put("ImageType",0);
			newPhotoJson.put("ImageString",addNewPhotoImageString);
			String imageTag=((EditText)findViewById(R.id.add_new_photo_album_tag)).getText().toString();
			if(imageTag!=null && !"".equals(imageTag))
				newPhotoJson.put("ImageTag",imageTag);
			addPhotoJsonArray.put(newPhotoJson);
			para.put("AddImage",addPhotoJsonArray);
		} catch (NumberFormatException e) {
			e.printStackTrace();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, ADD_NEW_PHOTO,para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, ADD_NEW_PHOTO,para.toString(), header);
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
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		super.onClick(view);
		switch(view.getId()){
		case R.id.add_new_photo_album_submit:
			if(addNewPhotoImageString==null || "".equals(addNewPhotoImageString))
				DialogUtil.createShortDialog(this,"请选择一张照片上传");
			else{
				super.asyncRefrshView(this);
			}
			break;
		case R.id.add_new_photo_album_image:
			final CharSequence[] items = { "本地选择", "拍照" };
			AlertDialog dlg = new AlertDialog.Builder(this).setTitle("选择照片")
					.setItems(items, new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							// TODO Auto-generated method stub
							if (which == 1) {
								Intent getImageByCamera = new Intent("android.media.action.IMAGE_CAPTURE");
								getImageByCamera.putExtra(MediaStore.EXTRA_OUTPUT,imageUri);
								startActivityForResult(getImageByCamera,1);
							} else {
								Intent getImage = new Intent(Intent.ACTION_GET_CONTENT);
								getImage.addCategory(Intent.CATEGORY_OPENABLE);
								getImage.setType("image/jpeg");
								startActivityForResult(getImage,0);
							}
						}
					}).create();
			dlg.show();
			break;
		}
	}
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if(resultCode!=RESULT_OK)
			return;
		Bitmap myBitmap = null;
		byte[] mContent = null;
		if (requestCode == 0 && resultCode==RESULT_OK) {
			try {
				if (data != null) {
					Uri selectedImage = data.getData();
					CropUtil.cropImageByPhoto(this,selectedImage,imageUri,Constant.CROPIMAGEWIDTH,Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		// 拍照获取图片
		else if (requestCode == 1 && resultCode==RESULT_OK) {
			CropUtil.cropImageByCamera(this,imageUri,Constant.CROPIMAGEWIDTH,Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
		} else if (requestCode == Constant.CROP_PICTURE) {
			if (imageUri != null) {
				myBitmap = CropUtil.decodeBitmapImageUri(this,imageUri);
				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				myBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
				// 压缩图片
				myBitmap = UploadImageUtil.resizeBitmap(myBitmap,Constant.RESIZEBITMAPMAXWIDTH,Constant.RESIZEBITMAPMAXWIDTH);
				if (baos != null)
					mContent = baos.toByteArray();
				addNewPhotoAlbumImageView.setImageBitmap(myBitmap);
			}
			if (mContent != null)
				addNewPhotoImageString = new String(Base64Util.encode(mContent));
		}
	}
}
