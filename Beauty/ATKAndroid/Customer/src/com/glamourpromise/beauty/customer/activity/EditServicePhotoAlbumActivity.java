package com.glamourpromise.beauty.customer.activity;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
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
import com.glamourpromise.beauty.customer.adapter.EditTgPhotoAlbumListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.TGPhotoAlbum;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.handler.ShareContentCustomize;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DateUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.view.TreatmentImageGridView;

/*
 * 编辑某一个TG下的图片
 * */
public class EditServicePhotoAlbumActivity extends BaseActivity implements IConnectTask, OnClickListener {
	private static final String CATEGORY_NAME = "Image",GET_Photo_LIST = "getCustomerTGPic",EDIT_PHOTO = "editCustomerPic",EDIT_PHOTO_COMMENT ="UpdateServiceEffectImage";
	private String groupNo;
	private TGPhotoAlbum tgPhotoAlbum;
	private int TASK_FLAG = 1;
	private EditText tgPhotoAlbumCommentText;
	private static final String SHARE_CATEGORY_NAME="ShareToOther",SHARE_METHOD_NAME="ShareGroupNo";
	private int   urlType=1;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_edit_service_photo_album);
		super.setTitle(getString(R.string.title_photo_album_list));
		Intent intent = getIntent();
		groupNo = intent.getStringExtra("groupNO");
		findViewById(R.id.edit_tg_photo_alubm_all_delete).setOnClickListener(this);
		findViewById(R.id.edit_tg_photo_album_submit).setOnClickListener(this);
		findViewById(R.id.share_tg_photo_album_rl).setOnClickListener(this);
		tgPhotoAlbumCommentText=(EditText)findViewById(R.id.edit_tg_photo_alubm_comments);
		ShareSDK.initSDK(this);
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
		super.showProgressDialog();
		TASK_FLAG=1;
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String categoryName="";
		String methodName = "";
		if (TASK_FLAG == 1) {
			categoryName=CATEGORY_NAME;
			methodName = GET_Photo_LIST;
		} else if (TASK_FLAG == 2) {
			categoryName=CATEGORY_NAME;
			methodName = EDIT_PHOTO;
		}
		else if(TASK_FLAG==3){
			categoryName=CATEGORY_NAME;
			methodName = EDIT_PHOTO_COMMENT;
		}
		else if(TASK_FLAG==4){
			categoryName=SHARE_CATEGORY_NAME;
			methodName=SHARE_METHOD_NAME;
		}
		JSONObject para = new JSONObject();
		try {
			if (TASK_FLAG == 1) {
				para.put("GroupNo", groupNo);
				para.put("ImageWidth", 160);
				para.put("ImageHeight", 160);
			} else if (TASK_FLAG == 2) {
				para.put("GroupNo", groupNo);
				para.put("Type", 1);
			}
			else if (TASK_FLAG == 3) {
				para.put("GroupNo", groupNo);
				para.put("CustomerID",Integer.parseInt(mCustomerID));
				para.put("Comment",tgPhotoAlbumCommentText.getText().toString());
			}
			else if(TASK_FLAG==4){
				para.put("GroupNo",groupNo);
				para.put("Type",urlType);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName, methodName, para.toString());
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
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if (TASK_FLAG == 1) {
					tgPhotoAlbum = new TGPhotoAlbum();
					tgPhotoAlbum.parseByJson(response.getStringData());
					((TextView) findViewById(R.id.edit_tg_photo_alubm_service_name)).setText(tgPhotoAlbum.getServiceName());
					((TextView) findViewById(R.id.edit_tg_photo_alubm_start_time)).setText(DateUtil.getFormateDateByString(tgPhotoAlbum.getTgStartTime()));
					((TextView) findViewById(R.id.edit_tg_photo_alubm_branch_name)).setText(tgPhotoAlbum.getBranchName());
					TreatmentImageGridView treatmentImageGridView = (TreatmentImageGridView) findViewById(R.id.eidt_tg_photo_album_grid_view);
					treatmentImageGridView.setOnItemClickListener(new OnItemClickListener() {
						@Override
						public void onItemClick(AdapterView<?> parentView, View arg1,int position, long id) {
							// TODO Auto-generated method stub
							Intent destIntent=null;
							if(position==tgPhotoAlbum.getRecordImageList().size()-1){
								destIntent=new Intent(EditServicePhotoAlbumActivity.this,AddNewServicePhotoAlbumActivity.class);
								destIntent.putExtra("tgPhotoAlbum",tgPhotoAlbum);
							}
							else{
								destIntent=new Intent(EditServicePhotoAlbumActivity.this,EditServicePhotoAlbumSingleActivity.class);
								destIntent.putExtra("groupNo",tgPhotoAlbum.getGroupNo());
								destIntent.putExtra("recordImage",tgPhotoAlbum.getRecordImageList().get(position));
							}
							startActivity(destIntent);
						}
					});
					EditTgPhotoAlbumListAdapter editTgPhotoAlbumListAdapter = new EditTgPhotoAlbumListAdapter(getApplicationContext(),tgPhotoAlbum.getRecordImageList());
					treatmentImageGridView.setAdapter(editTgPhotoAlbumListAdapter);
					tgPhotoAlbumCommentText.setText(tgPhotoAlbum.getComments());
				} else if (TASK_FLAG == 2) {
					Intent destIntent = new Intent(this,PhotoAlbumListActivity.class);
					startActivity(destIntent);
					this.finish();
				}
				else if(TASK_FLAG==3){
					DialogUtil.createShortDialog(this,response.getMessage());
				}
				else if(TASK_FLAG==4){
					String shareURL=response.getStringData();
					showShare(shareURL);
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),
						response.getMessage());
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
	private void editTgPhoto(){
		TASK_FLAG = 2;
		super.asyncRefrshView(EditServicePhotoAlbumActivity.this);
	}
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.edit_tg_photo_alubm_all_delete:
			Dialog dialog = new AlertDialog.Builder(this)
					.setTitle(getString(R.string.delete_dialog_title))
					.setMessage(R.string.delete_tg_photo_alubm)
					.setPositiveButton(getString(R.string.ok),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									editTgPhoto();
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
		case R.id.edit_tg_photo_album_submit:
			if(tgPhotoAlbumCommentText.getText().toString()==null || "".equals(tgPhotoAlbumCommentText))
				DialogUtil.createShortDialog(this,"请输入心情内容");
			else{
				TASK_FLAG = 3;
				super.asyncRefrshView(this);
			}
			break;
		case R.id.share_tg_photo_album_rl:
			TASK_FLAG=4;
			super.asyncRefrshView(this);
			break;
		}
	}
	private void showShare(String shareURL) {	 
		 OnekeyShare oks = new OnekeyShare();
		 oks.setShareContentCustomizeCallback(new ShareContentCustomize(shareURL,this));
		 oks.show(this);
	}
}
