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
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

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
public class TreatmentGroupTreatmentDetailActivity extends BaseActivity implements
        OnClickListener {
    private TreatmentGroupTreatmentDetailActivityHandler mHandler = new TreatmentGroupTreatmentDetailActivityHandler(this);
    private ViewPager beforeTreatmentViewPager;
    private ViewPager afterTreatmentViewPager;
    private Thread requestWebServiceThread;
    private String groupNo;
    private List<TreatmentImage> beforeTreatmentImageList;
    private List<TreatmentImage> afterTreatmentImageList;
    private List<Treatment> treatmentList;
    private List<View> mViewList, mViewList2;
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
    private TreatmentAfterViewPagerAdapter treatmentImageViewAfterPagerAdapter;
    private ImageButton editTreatmentTreatmentDetailBtn;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private DisplayImageOptions displayImageOptions;
    private LinearLayout treatmentListLinearLayout;
    private int orderEditFlag, customerID;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        setContentView(R.layout.activity_treatment_group_treatment_detail);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class TreatmentGroupTreatmentDetailActivityHandler extends Handler {
        private final TreatmentGroupTreatmentDetailActivity treatmentGroupTreatmentDetailActivity;

        private TreatmentGroupTreatmentDetailActivityHandler(TreatmentGroupTreatmentDetailActivity activity) {
            WeakReference<TreatmentGroupTreatmentDetailActivity> weakReference = new WeakReference<TreatmentGroupTreatmentDetailActivity>(activity);
            treatmentGroupTreatmentDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (treatmentGroupTreatmentDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 1) {
                treatmentGroupTreatmentDetailActivity.mViewList = new ArrayList<View>();
                treatmentGroupTreatmentDetailActivity.mViewList2 = new ArrayList<View>();
                for (TreatmentImage treatmentImage : treatmentGroupTreatmentDetailActivity.beforeTreatmentImageList) {
                    treatmentGroupTreatmentDetailActivity.childView = treatmentGroupTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
                    ImageView beforeTreatmentImageView = (ImageView) treatmentGroupTreatmentDetailActivity.childView.findViewById(R.id.company_image);
                    treatmentGroupTreatmentDetailActivity.imageLoader.displayImage(treatmentImage.getTreatmentImageURL(), beforeTreatmentImageView, treatmentGroupTreatmentDetailActivity.displayImageOptions);
                    treatmentGroupTreatmentDetailActivity.mViewList.add(treatmentGroupTreatmentDetailActivity.childView);
                }
                for (TreatmentImage afterTreatmentImage : treatmentGroupTreatmentDetailActivity.afterTreatmentImageList) {
                    treatmentGroupTreatmentDetailActivity.childView2 = treatmentGroupTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
                    ImageView afterTreatmentImageView = (ImageView) treatmentGroupTreatmentDetailActivity.childView2.findViewById(R.id.company_image);
                    treatmentGroupTreatmentDetailActivity.imageLoader.displayImage(afterTreatmentImage.getTreatmentImageURL(), afterTreatmentImageView, treatmentGroupTreatmentDetailActivity.displayImageOptions);
                    treatmentGroupTreatmentDetailActivity.mViewList2.add(treatmentGroupTreatmentDetailActivity.childView2);
                }
                treatmentGroupTreatmentDetailActivity.createTreatmentBeforeImageViewPager(treatmentGroupTreatmentDetailActivity.mViewList);
                treatmentGroupTreatmentDetailActivity.createTreatmentAfterImageViewPager(treatmentGroupTreatmentDetailActivity.mViewList2);
                //循环遍历出Treatment的列表
                if (treatmentGroupTreatmentDetailActivity.treatmentList != null && treatmentGroupTreatmentDetailActivity.treatmentList.size() > 0) {
                    treatmentGroupTreatmentDetailActivity.treatmentListLinearLayout.removeAllViews();
                    for (final Treatment treatment : treatmentGroupTreatmentDetailActivity.treatmentList) {
                        View treatmentView = treatmentGroupTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.treatment_group_treatment_item, null);
                        TextView subServiceNameText = (TextView) treatmentView.findViewById(R.id.subservice_name);
                        subServiceNameText.setText(treatment.getSubServiceName());
                        treatmentView.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                // TODO Auto-generated method stub
                                TreatmentGroup treatmentGroup = new TreatmentGroup();
                                treatmentGroup.setTreatmentGroupID(Long.valueOf(treatmentGroupTreatmentDetailActivity.groupNo));
                                Intent destIntent = new Intent();
                                destIntent.putExtra("treatment", treatment);
                                destIntent.putExtra("treatmentGroup", treatmentGroup);
                                destIntent.putExtra("orderEditFlag", treatmentGroupTreatmentDetailActivity.orderEditFlag);
                                destIntent.putExtra("CustomerID", treatmentGroupTreatmentDetailActivity.customerID);
                                destIntent.putExtra("current_tab", 1);
                                destIntent.setClass(treatmentGroupTreatmentDetailActivity, TreatmentDetailActivity.class);
                                treatmentGroupTreatmentDetailActivity.startActivity(destIntent);
                            }
                        });
                        treatmentGroupTreatmentDetailActivity.treatmentListLinearLayout.addView(treatmentView);
                    }
                }

            } else if (msg.what == 2)
                DialogUtil.createShortDialog(treatmentGroupTreatmentDetailActivity, "您的网络貌似不给力，请重试！");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(treatmentGroupTreatmentDetailActivity, treatmentGroupTreatmentDetailActivity.getString(R.string.login_error_message));
                treatmentGroupTreatmentDetailActivity.userinfoApplication.exitForLogin(treatmentGroupTreatmentDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + treatmentGroupTreatmentDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(treatmentGroupTreatmentDetailActivity);
                treatmentGroupTreatmentDetailActivity.packageUpdateUtil = new PackageUpdateUtil(treatmentGroupTreatmentDetailActivity, treatmentGroupTreatmentDetailActivity.mHandler, fileCache, downloadFileUrl, false, treatmentGroupTreatmentDetailActivity.userinfoApplication);
                treatmentGroupTreatmentDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                treatmentGroupTreatmentDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = treatmentGroupTreatmentDetailActivity.getFileStreamPath(filename);
                file.getName();
                treatmentGroupTreatmentDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (treatmentGroupTreatmentDetailActivity.requestWebServiceThread != null) {
                treatmentGroupTreatmentDetailActivity.requestWebServiceThread.interrupt();
                treatmentGroupTreatmentDetailActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        afterTreatmentViewPager = (ViewPager) findViewById(R.id.after_treatment_viewpager);
        groupNo = getIntent().getStringExtra("GroupNo");
        customerID = getIntent().getIntExtra("CustomerID", 0);
        arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
        arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
        arrowRight2 = (ImageView) findViewById(R.id.arrow_right_icon_2);
        arrowLeft2 = (ImageView) findViewById(R.id.arrow_left_icon_2);
        treatmentBroswerSwitch = (Switch) findViewById(R.id.treatment_broswer_switch);
        treatmentListLinearLayout = (LinearLayout) findViewById(R.id.treatment_list_linearlayout);
        editTreatmentTreatmentDetailBtn = (ImageButton) findViewById(R.id.treatment_treatment_detail_edit_btn);
        editTreatmentTreatmentDetailBtn.setOnClickListener(this);
        if (userinfoApplication.getAccountInfo().getAuthMyOrderWrite() == 0)
            editTreatmentTreatmentDetailBtn.setVisibility(View.GONE);
        beforeTreatmentImageList = new ArrayList<TreatmentImage>();
        afterTreatmentImageList = new ArrayList<TreatmentImage>();
        mLayoutInflater = getLayoutInflater();
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
        orderEditFlag = getIntent().getIntExtra("orderEditFlag", 0);
        //判断是都有修改服务效果的权限
        if (orderEditFlag == 0)
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
        treatmentImageViewBeforePagerAdapter = new TreatmentBeforeViewPagerAdapter(mViewList, beforeTreatmentImageList, this);
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
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
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
                JSONObject getTreatmentImageJsonParam = new JSONObject();
                try {
                    getTreatmentImageJsonParam.put("GroupNo", groupNo);
                    if (screenWidth == 720) {
                        getTreatmentImageJsonParam.put("ImageThumbHeight", "150");
                        getTreatmentImageJsonParam.put("ImageThumbWidth", "150");
                    } else if (screenWidth == 1536) {
                        getTreatmentImageJsonParam.put("ImageThumbHeight", "300");
                        getTreatmentImageJsonParam.put("ImageThumbWidth", "300");
                    }
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getTreatmentImageJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    JSONObject treatmentJson = null;
                    JSONArray beforeImageJsonArray = null;
                    JSONArray afterImageJsonArray = null;
                    JSONArray treatmentListJsonArray = null;
                    int code = 0;
                    beforeTreatmentImageList = new ArrayList<TreatmentImage>();
                    afterTreatmentImageList = new ArrayList<TreatmentImage>();
                    treatmentList = new ArrayList<Treatment>();
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        try {
                            treatmentJson = resultJson.getJSONObject("Data");
                            beforeImageJsonArray = treatmentJson.getJSONArray("ImageBeforeTreatment");
                            afterImageJsonArray = treatmentJson.getJSONArray("ImageAfterTreatment");
                            treatmentListJsonArray = treatmentJson.getJSONArray("TMList");
                        } catch (JSONException e) {
                        }
                        if (beforeImageJsonArray != null) {
                            for (int i = 0; i < beforeImageJsonArray.length(); i++) {
                                JSONObject beforeImageJson = null;
                                try {
                                    beforeImageJson = beforeImageJsonArray.getJSONObject(i);
                                } catch (JSONException e) {
                                }
                                TreatmentImage beforeTreatmentImage = new TreatmentImage();
                                int treatmentImageID = 0;
                                String originalImageURL = "";
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
                        if (afterImageJsonArray != null) {
                            for (int i = 0; i < afterImageJsonArray.length(); i++) {
                                JSONObject afterImageJson = null;
                                try {
                                    afterImageJson = afterImageJsonArray.getJSONObject(i);
                                } catch (JSONException e) {
                                }
                                TreatmentImage afterTreatmentImage = new TreatmentImage();
                                int treatmentImageID = 0;
                                String originalImageURL = "";
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
                        if (treatmentListJsonArray != null) {
                            for (int i = 0; i < treatmentListJsonArray.length(); i++) {
                                JSONObject treatmentObjectJson = null;
                                Treatment treatment = new Treatment();
                                try {
                                    treatmentObjectJson = treatmentListJsonArray.getJSONObject(i);
                                } catch (JSONException e) {
                                }
                                int treatmentID = 0;
                                String subserviceName = "";
                                try {
                                    if (treatmentObjectJson.has("TreatmentID") && !treatmentObjectJson.isNull("TreatmentID"))
                                        treatmentID = treatmentObjectJson.getInt("TreatmentID");
                                    if (treatmentObjectJson.has("SubServiceName") && !treatmentObjectJson.isNull("SubServiceName"))
                                        subserviceName = treatmentObjectJson.getString("SubServiceName");
                                } catch (JSONException e) {

                                }
                                treatment.setId(treatmentID);
                                treatment.setSubServiceName(subserviceName);
                                treatmentList.add(treatment);
                            }
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
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
        treatmentImageViewAfterPagerAdapter = new TreatmentAfterViewPagerAdapter(mViewList, afterTreatmentImageList, this);
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
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
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
                Intent destIntent = new Intent(this, EditTreatmentTreatmentDetailActivity.class);
                destIntent.putExtra("groupNo", groupNo);
                destIntent.putExtra("CustomerID", customerID);
                destIntent.putExtra("orderEditFlag", orderEditFlag);
                startActivity(destIntent);
                break;
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
