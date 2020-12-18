package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.Switch;

import com.GlamourPromise.Beauty.adapter.TreatmentAfterViewPagerAdapter;
import com.GlamourPromise.Beauty.adapter.TreatmentBeforeViewPagerAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.Treatment;
import com.GlamourPromise.Beauty.bean.TreatmentGroup;
import com.GlamourPromise.Beauty.bean.TreatmentImage;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
/*
 * 服务效果
 * */
@SuppressLint("ResourceType")
public class TreatmentTreatmentDetailActivity extends BaseActivity implements
		OnClickListener {
	private TreatmentTreatmentDetailActivityHandler mHandler = new TreatmentTreatmentDetailActivityHandler(this);
	private ViewPager beforeTreatmentViewPager;
	private ViewPager afterTreatmentViewPager;
	private Thread requestWebServiceThread;
	private TreatmentGroup  treatmentGroup;
	private Treatment treatment;
	private List<TreatmentImage> beforeTreatmentImageList;
	private List<TreatmentImage> afterTreatmentImageList;
	private List<View> mViewList,mViewList2;
	private View childView;
	private View childView2;
	private LayoutInflater mLayoutInflater;
	private ImageLoader imageLoader;
	private ImageView arrowRight;
	private ImageView arrowLeft;
	private ImageView arrowRight2;
	private ImageView arrowLeft2;
	private int imageCount;
	private int imageCount2;
	private Switch treatmentBroswerSwitch;
	private TreatmentBeforeViewPagerAdapter treatmentImageViewBeforePagerAdapter;
	private TreatmentAfterViewPagerAdapter  treatmentImageViewAfterPagerAdapter;
	private ImageButton editTreatmentTreatmentDetailBtn;
	private UserInfoApplication userinfoApplication;
	private PackageUpdateUtil packageUpdateUtil;
	private DisplayImageOptions displayImageOptions;
	private int orderEditFlag,customerID;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_treatment_treatment_detail);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class TreatmentTreatmentDetailActivityHandler extends Handler {
		private final TreatmentTreatmentDetailActivity treatmentTreatmentDetailActivity;

		private TreatmentTreatmentDetailActivityHandler(TreatmentTreatmentDetailActivity activity) {
			WeakReference<TreatmentTreatmentDetailActivity> weakReference = new WeakReference<TreatmentTreatmentDetailActivity>(activity);
			treatmentTreatmentDetailActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 1) {
				treatmentTreatmentDetailActivity.mViewList = new ArrayList<View>();
				treatmentTreatmentDetailActivity.mViewList2 = new ArrayList<View>();
				for (TreatmentImage treatmentImage : treatmentTreatmentDetailActivity.beforeTreatmentImageList) {
					treatmentTreatmentDetailActivity.childView = treatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
					ImageView beforeTreatmentImageView = (ImageView) treatmentTreatmentDetailActivity.childView.findViewById(R.id.company_image);
					treatmentTreatmentDetailActivity.imageLoader.displayImage(treatmentImage.getTreatmentImageURL(), beforeTreatmentImageView, treatmentTreatmentDetailActivity.displayImageOptions);
					treatmentTreatmentDetailActivity.mViewList.add(treatmentTreatmentDetailActivity.childView);
				}
				for (TreatmentImage afterTreatmentImage : treatmentTreatmentDetailActivity.afterTreatmentImageList) {
					treatmentTreatmentDetailActivity.childView2 = treatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
					ImageView afterTreatmentImageView = (ImageView) treatmentTreatmentDetailActivity.childView2.findViewById(R.id.company_image);
					treatmentTreatmentDetailActivity.imageLoader.displayImage(afterTreatmentImage.getTreatmentImageURL(), afterTreatmentImageView, treatmentTreatmentDetailActivity.displayImageOptions);
					treatmentTreatmentDetailActivity.mViewList2.add(treatmentTreatmentDetailActivity.childView2);
				}
				treatmentTreatmentDetailActivity.createTreatmentBeforeImageViewPager(treatmentTreatmentDetailActivity.mViewList);
				treatmentTreatmentDetailActivity.createTreatmentAfterImageViewPager(treatmentTreatmentDetailActivity.mViewList2);
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(treatmentTreatmentDetailActivity, "您的网络貌似不给力，请重试！");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(treatmentTreatmentDetailActivity, treatmentTreatmentDetailActivity.getString(R.string.login_error_message));
				treatmentTreatmentDetailActivity.userinfoApplication.exitForLogin(treatmentTreatmentDetailActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + treatmentTreatmentDetailActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(treatmentTreatmentDetailActivity);
				treatmentTreatmentDetailActivity.packageUpdateUtil = new PackageUpdateUtil(treatmentTreatmentDetailActivity, treatmentTreatmentDetailActivity.mHandler, fileCache, downloadFileUrl, false, treatmentTreatmentDetailActivity.userinfoApplication);
				treatmentTreatmentDetailActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				treatmentTreatmentDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = treatmentTreatmentDetailActivity.getFileStreamPath(filename);
				file.getName();
				treatmentTreatmentDetailActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (treatmentTreatmentDetailActivity.requestWebServiceThread != null) {
				treatmentTreatmentDetailActivity.requestWebServiceThread.interrupt();
				treatmentTreatmentDetailActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		afterTreatmentViewPager = (ViewPager) findViewById(R.id.after_treatment_viewpager);
		treatment = (Treatment) getIntent().getSerializableExtra("treatment");
		treatmentGroup=(TreatmentGroup)getIntent().getSerializableExtra("treatmentGroup");
		arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
		arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
		arrowRight2 = (ImageView) findViewById(R.id.arrow_right_icon_2);
		arrowLeft2 = (ImageView) findViewById(R.id.arrow_left_icon_2);
		treatmentBroswerSwitch = (Switch) findViewById(R.id.treatment_broswer_switch);
		editTreatmentTreatmentDetailBtn = (ImageButton) findViewById(R.id.treatment_treatment_detail_edit_btn);
		editTreatmentTreatmentDetailBtn.setOnClickListener(this);
		if (userinfoApplication.getAccountInfo().getAuthMyOrderWrite()== 0)
			editTreatmentTreatmentDetailBtn.setVisibility(View.GONE);
		beforeTreatmentImageList = new ArrayList<TreatmentImage>();
		afterTreatmentImageList = new ArrayList<TreatmentImage>();
		mLayoutInflater = getLayoutInflater();
		imageLoader=ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
		orderEditFlag=getIntent().getIntExtra("orderEditFlag",0);
		customerID=getIntent().getIntExtra("CustomerID",0);
		//判断是都有修改服务效果的权限
		if(orderEditFlag==0)
			editTreatmentTreatmentDetailBtn.setVisibility(View.GONE);
		requestWebService();
	}

	private void createTreatmentBeforeImageViewPager(List<View> mViewList) {
		imageCount = mViewList.size();
		arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
		if (imageCount == 1) {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
		} else {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
		}
		beforeTreatmentViewPager = (ViewPager) findViewById(R.id.before_treatment_viewpager);
		treatmentImageViewBeforePagerAdapter = new TreatmentBeforeViewPagerAdapter(mViewList,beforeTreatmentImageList,this);
		beforeTreatmentViewPager.setAdapter(treatmentImageViewBeforePagerAdapter);
		beforeTreatmentViewPager.setOnPageChangeListener(new OnPageChangeListener() {
					@Override
					public void onPageSelected(int position) {
						if (position == 0) {
							arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
						} else {
							arrowLeft.setBackgroundResource(R.drawable.arrow_left_red);
						}
						if (position == imageCount - 1) {
							arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
						} else {
							arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
						}
						if (treatmentBroswerSwitch.isChecked()) {
							afterTreatmentViewPager.setCurrentItem(position);
						}
					}
					@Override
					public void onPageScrolled(int position,float positionOffset, int positionOffsetPixels) {
					}
					@Override
					public void onPageScrollStateChanged(int state) {
					}
				});
	}

	protected void requestWebService() {
		final int screenWidth = userinfoApplication.getScreenWidth();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				String methodName = "getServiceEffectImage";
				String endPoint = "Image";
				JSONObject getTreatmentImageJsonParam=new JSONObject();
				try {
					getTreatmentImageJsonParam.put("TreatmentID", String.valueOf(treatment.getId()));
					if (screenWidth == 720) {
						getTreatmentImageJsonParam.put("ImageThumbHeight","150");
						getTreatmentImageJsonParam.put("ImageThumbWidth","150");
					}
					else if (screenWidth ==1536) {
						getTreatmentImageJsonParam.put("ImageThumbHeight", "300");
						getTreatmentImageJsonParam.put("ImageThumbWidth", "300");
					}
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,getTreatmentImageJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson=null;
					JSONObject treatmentJson=null;
					JSONArray  beforeImageJsonArray=null;
					JSONArray  afterImageJsonArray=null;
					int code=0;
					beforeTreatmentImageList = new ArrayList<TreatmentImage>();
					afterTreatmentImageList = new ArrayList<TreatmentImage>();
					try {
						resultJson=new JSONObject(serverRequestResult);
						code=resultJson.getInt("Code");
					} catch (JSONException e) {
					}
			        if(code==1){
			        	try {
							treatmentJson=resultJson.getJSONObject("Data");
							beforeImageJsonArray=treatmentJson.getJSONArray("ImageBeforeTreatment");
							afterImageJsonArray=treatmentJson.getJSONArray("ImageAfterTreatment");
						} catch (JSONException e) {
						}
			        	if(beforeImageJsonArray!=null){
			        		for (int i = 0; i < beforeImageJsonArray.length(); i++) {
								JSONObject beforeImageJson=null;
								try {
									beforeImageJson=beforeImageJsonArray.getJSONObject(i);
								} catch (JSONException e) {
								}
								TreatmentImage beforeTreatmentImage = new TreatmentImage();
								int    treatmentImageID = 0;
								String originalImageURL="";
								String treatmentImageURL = "";
								try {
									if (beforeImageJson.has("TreatmentImageID") && !beforeImageJson.isNull("TreatmentImageID"))
										treatmentImageID = beforeImageJson.getInt("TreatmentImageID");
									if (beforeImageJson.has("OriginalImageURL") && !beforeImageJson.isNull("OriginalImageURL"))
										originalImageURL = beforeImageJson.getString("OriginalImageURL");
									if (beforeImageJson.has("ThumbnailURL") && !beforeImageJson.isNull("ThumbnailURL"))
										treatmentImageURL = beforeImageJson.getString("ThumbnailURL");
								} catch (JSONException e) {
								}
								beforeTreatmentImage.setTreatmentImageID(treatmentImageID);
								beforeTreatmentImage.setTreatmentImageURL(treatmentImageURL);
								beforeTreatmentImage.setOrigianlImageURL(originalImageURL);
								beforeTreatmentImageList.add(beforeTreatmentImage);
							}
			        	}
			        	if(afterImageJsonArray!=null){
			        		for (int i = 0; i < afterImageJsonArray.length(); i++) {
								JSONObject afterImageJson=null;
								try {
									afterImageJson=afterImageJsonArray.getJSONObject(i);
								} catch (JSONException e) {
								}
								TreatmentImage afterTreatmentImage = new TreatmentImage();
								int treatmentImageID = 0;
								String originalImageURL="";
								String treatmentImageURL = "";
								try {
									if (afterImageJson.has("TreatmentImageID") && !afterImageJson.isNull("TreatmentImageID"))
										treatmentImageID = afterImageJson.getInt("TreatmentImageID");
									if (afterImageJson.has("OriginalImageURL") && !afterImageJson.isNull("OriginalImageURL"))
										originalImageURL = afterImageJson.getString("OriginalImageURL");
									if (afterImageJson.has("ThumbnailURL") && !afterImageJson.isNull("ThumbnailURL"))
										treatmentImageURL = afterImageJson.getString("ThumbnailURL");
								} catch (JSONException e) {
								}
								afterTreatmentImage.setTreatmentImageID(treatmentImageID);
								afterTreatmentImage.setTreatmentImageURL(treatmentImageURL);
								afterTreatmentImage.setOrigianlImageURL(originalImageURL);
								afterTreatmentImageList.add(afterTreatmentImage);
							}
			        	}
			        	mHandler.sendEmptyMessage(1);
			        }
			        else
			        	mHandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}

	private void createTreatmentAfterImageViewPager(List<View> mViewList) {
		imageCount2 = mViewList.size();
		arrowLeft2.setBackgroundResource(R.drawable.arrow_left_gray);
		if (imageCount2 == 1) {
			arrowRight2.setBackgroundResource(R.drawable.arrow_right_gray);
		} else {
			arrowRight2.setBackgroundResource(R.drawable.arrow_right_red);
		}
		afterTreatmentViewPager = (ViewPager) findViewById(R.id.after_treatment_viewpager);
		treatmentImageViewAfterPagerAdapter = new TreatmentAfterViewPagerAdapter(mViewList,afterTreatmentImageList,this);
		afterTreatmentViewPager.setAdapter(treatmentImageViewAfterPagerAdapter);
		afterTreatmentViewPager.setOnPageChangeListener(new OnPageChangeListener() {

					@Override
					public void onPageSelected(int position) {
						if (position == 0) {
							arrowLeft2.setBackgroundResource(R.drawable.arrow_left_gray);
						} else {
							arrowLeft2.setBackgroundResource(R.drawable.arrow_left_red);
						}
						if (position == imageCount2 - 1) {
							arrowRight2.setBackgroundResource(R.drawable.arrow_right_gray);
						} else {
							arrowRight2.setBackgroundResource(R.drawable.arrow_right_red);
						}
						if (treatmentBroswerSwitch.isChecked()) {
							beforeTreatmentViewPager.setCurrentItem(position);
						}
					}
					@Override
					public void onPageScrolled(int position,float positionOffset, int positionOffsetPixels) {
					}
					@Override
					public void onPageScrollStateChanged(int state) {
					}
				});
	}
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		requestWebService();
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch (view.getId()) {
		case R.id.treatment_treatment_detail_edit_btn:
			Intent destIntent = new Intent(this,EditTreatmentTreatmentDetailActivity.class);
			Bundle bundle = new Bundle();
			bundle.putSerializable("treatmentGroup",treatmentGroup);
			bundle.putSerializable("treatment", treatment);
			destIntent.putExtras(bundle);
			destIntent.putExtra("CustomerID",customerID);
			destIntent.putExtra("orderEditFlag",orderEditFlag);
			startActivity(destIntent);
			break;
		}
	}
}
