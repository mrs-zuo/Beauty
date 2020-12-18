package com.glamourpromise.beauty.customer.activity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.PopupWindow.OnDismissListener;
import android.widget.ProgressBar;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.PhotoAlbumDetailAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.PhotoAlbumDetailInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.FileCache;

public class PhotoAlbumDetailActivity extends BaseActivity implements OnClickListener, OnItemClickListener, IConnectTask {
	private static final String GET_FILE_ERROR = "图像预览失败";
	private static final String CATEGORY_NAME = "Image";
	private static final String GET_Photo_DETAIL = "getPhotoAlbumDetail";	
	private Thread subThread;
	private GridView photoAlbumGriView;
	private ImageButton shareBotton;
	private PhotoAlbumDetailAdapter imageListAdapter;
	private String createDate;
	private List<PhotoAlbumDetailInformation> photoAlbumdetailList;
	private View originalImageLayout;
	private ImageView originalImage;
	private PopupWindow mOriginalImageWindow;
	private ProgressBar progressBar;
	private Bitmap mLastOriBitmap;
	private FileCache fileCache;
	private String currentPhotoDetailName;
	private UserInfoApplication userInfo;
	private boolean mIsCancelDownload;
	private Handler mHandler;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_photo_album_detail);
		Intent intent = getIntent();
		createDate = intent.getStringExtra("CreateDate");
		photoAlbumdetailList = new ArrayList<PhotoAlbumDetailInformation>();
		super.setTitle(createDate);
		photoAlbumGriView = (GridView) findViewById(R.id.photo_album_gridview);
		photoAlbumGriView.setOnItemClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.btn_main_back).setOnClickListener(this);

		userInfo = (UserInfoApplication)getApplication();
		fileCache = new FileCache(this);
		mIsCancelDownload = false;
		mHandler = new PhotoDownloadHandler(new WeakReference<PhotoAlbumDetailActivity>(this));

		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		mHandler.removeCallbacksAndMessages(null);
	}
	
	@Override
	protected void onStop() {
		super.onStop();
		//回收显示大图的bitmap
		if (mLastOriBitmap != null) {
			mLastOriBitmap = null;
			System.gc();
		}
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
	}
	
	
	private static class PhotoDownloadHandler extends Handler{
		WeakReference<PhotoAlbumDetailActivity> mActivity;

		public PhotoDownloadHandler(WeakReference<PhotoAlbumDetailActivity> activity) {
			super();
			mActivity = activity;
		}

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 1:
				if(mActivity != null)
					mActivity.get().onDownloaded();
				break;
			case 2:
				if(mActivity != null)
					mActivity.get().onDonwloadError();
				break;

			default:
				break;
			}
		}		
	}
	
	public void onDownloaded(){
		if (!mIsCancelDownload) {
			Bitmap lastBitmap = mLastOriBitmap;
			mLastOriBitmap = createBitmap(fileCache.getFilePath(currentPhotoDetailName));
			originalImage.setImageBitmap(mLastOriBitmap);
			if (lastBitmap != null) {
				lastBitmap.recycle();
				System.gc();
			}
		
			if (progressBar != null) {
				progressBar.setVisibility(View.GONE);
			}
		}
	}

	/**
	 * 根据图片路径生成大图的Bitmap
	 * @param path
	 * @return
	 */
	private Bitmap createBitmap(String path) {
		//先判断图片的尺寸
		BitmapFactory.Options op = new BitmapFactory.Options();
		op.inJustDecodeBounds = true;
		BitmapFactory.decodeFile(path, op);
		//源图片的尺寸
		final int height = op.outHeight;
	    final int width = op.outWidth;
	    //目标图片的尺寸
	    int inSampleSize = calSampleSize(height, width);
	    
	    //生成真正的Bitmap
	    op.inJustDecodeBounds = false;
	    op.inSampleSize = inSampleSize;
	    Bitmap bitmap = BitmapFactory.decodeFile(path, op);
		
		return bitmap;
	}
	
	private int calSampleSize(int height, int width){
		//目标图片的尺寸
	    int reqHeight = userInfo.getScreedHeight();
	    int reqWidth = userInfo.getScreenWidth();
	    int inSampleSize = 1;	    
	    if (width > reqWidth) {
	    	inSampleSize = Math.round((float) width / (float) reqWidth);  
	    }
		return inSampleSize;
	}
	
	public void onDonwloadError(){
		DialogUtil.createShortDialog(this, "下载失败");
		if (progressBar != null) {
			progressBar.setVisibility(View.GONE);
		}
	}

	public void removeProgressBar() {
		if (originalImageLayout != null) {
			ImageButton ib = (ImageButton) originalImageLayout.findViewById(R.id.share_button);
			ib.setVisibility(View.VISIBLE);
		}

	}
	
	private void handlePopwindowDismiss() {
		if(subThread != null)
			subThread.interrupt();
		mIsCancelDownload = true;
		if (mLastOriBitmap != null) {
			mLastOriBitmap.recycle();
			System.gc();
		}
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		mIsCancelDownload = false;
		
		//创建显示大图的PopupWindow
		LayoutInflater inflater = LayoutInflater.from(this);
		originalImageLayout = inflater.inflate(R.xml.photo_album_original_image, null);
		mOriginalImageWindow = new PopupWindow(originalImageLayout, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.MATCH_PARENT,true);
		mOriginalImageWindow.setBackgroundDrawable(new BitmapDrawable());
		progressBar = (ProgressBar) originalImageLayout.findViewById(R.id.pb);
		originalImage = (ImageView) originalImageLayout.findViewById(R.id.original_image);
		mOriginalImageWindow.setOnDismissListener(new OnDismissListener() {
			
			@Override
			public void onDismiss() {
				handlePopwindowDismiss();
			}
		});
		
		progressBar.setVisibility(View.VISIBLE);
		currentPhotoDetailName= photoAlbumdetailList.get(position).getName();
		mOriginalImageWindow.showAtLocation(this.findViewById(R.id.photo_album_gridview), Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,0);

		// 分享按钮
		shareBotton = (ImageButton) originalImageLayout.findViewById(R.id.share_button);
		shareBotton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent intent = new Intent(Intent.ACTION_SEND);
				intent.setType("image/png");
				File file = fileCache.getFileWithType(currentPhotoDetailName, ".png");
				Uri uri = Uri.fromFile(file);
				intent.putExtra(Intent.EXTRA_STREAM,uri);
				startActivity(Intent.createChooser(intent,getTitle()));
			}

		});
		
		originalImageLayout.setOnClickListener(new OnClickListener() {
			public void onClick(View paramView) {
				mOriginalImageWindow.dismiss();
			}
		});
		
		// 下载原图像
		try {
			File f = fileCache.getFileWithType(currentPhotoDetailName, ".png");
			// 判断是否已经存在
			if (!f.exists()) {
				downFile(photoAlbumdetailList.get(position).getOriginalImageURL(), currentPhotoDetailName);
			} else {
				mHandler.sendEmptyMessage(1);
			}
		} catch (Exception e) {
			DialogUtil.createShortDialog(this, GET_FILE_ERROR);
			if(mOriginalImageWindow != null){
				mOriginalImageWindow.dismiss();
			}
		}

	}
	/**
	 * 下载图片文件
	 * @param url
	 * @param name
	 */
	private void downFile(final String url, final String name) {
		subThread = new Thread() {
			@Override
			public void run() {
				try {
					URL imageUrl = new URL(url);
					HttpURLConnection conn = (HttpURLConnection) imageUrl.openConnection();
					conn.setInstanceFollowRedirects(true);
					InputStream is = conn.getInputStream();

					File file = fileCache.getFileWithType(name, ".png");
					FileOutputStream fileOutPutStream = new FileOutputStream(file);

					byte[] buffer = new byte[4096];
					int len = 0;
					do {
						len = is.read(buffer);
						if (len <= 0)
							break;
						fileOutPutStream.write(buffer, 0, len);
					} while (true);

					is.close();
					fileOutPutStream.close();
					if(!mIsCancelDownload){
						mHandler.sendEmptyMessage(1);
					}
					
				} catch (Exception ex) {
					ex.printStackTrace();
					if(!mIsCancelDownload){
						mHandler.sendEmptyMessage(2);
					}
					
				}
			}
		};
		subThread.start();
	}

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("CustomerID", mCustomerID);
			para.put("CreateDate", createDate);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_Photo_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_Photo_DETAIL, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				ArrayList<PhotoAlbumDetailInformation> tmp = PhotoAlbumDetailInformation.parseListByJson(response.getStringData());
				photoAlbumdetailList.clear();
				photoAlbumdetailList.addAll(tmp);
				if(imageListAdapter == null){
					imageListAdapter = new PhotoAlbumDetailAdapter(PhotoAlbumDetailActivity.this, photoAlbumdetailList);
					photoAlbumGriView.setAdapter(imageListAdapter);
				}else{
					imageListAdapter.notifyDataSetChanged();
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

	@Override
	public void parseData(WebApiResponse response) {
		
	}
}
