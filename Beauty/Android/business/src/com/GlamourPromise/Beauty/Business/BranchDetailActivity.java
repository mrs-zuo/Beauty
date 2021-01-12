package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByWebserviceThread;
import com.GlamourPromise.Beauty.adapter.ViewPagerAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.GetServerBranchDetailDataTaskImpl;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.MapStatusUpdate;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.model.LatLngBounds;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

@SuppressLint("ResourceType")
public class BranchDetailActivity extends BaseActivity {
    private BranchDetailActivityHandler mHandler = new BranchDetailActivityHandler(this);
    private Thread getBranchDetailDataThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userInfoApplication;
    private GetServerBranchDetailDataTaskImpl getBranchDetailDataTask;
    private BranchInfo branchInfo;
    private BaiduMap mBaiduMap;
    private MapView mMapView = null;
    private LayoutInflater mLayoutInflater;
    private ImageLoader imageLoader;
    private int imageCount;
    private ImageView arrowRight;
    private ImageView arrowLeft;
    private ViewPager viewPager;
    private ViewPagerAdapter PagerAdapter;
    private String branchID;
    private String branchtype;
    private PackageUpdateUtil packageUpdateUtil;
    private DisplayImageOptions displayImageOptions;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class BranchDetailActivityHandler extends Handler {
        private final BranchDetailActivity branchDetailActivity;

        private BranchDetailActivityHandler(BranchDetailActivity activity) {
            WeakReference<BranchDetailActivity> weakReference = new WeakReference<BranchDetailActivity>(activity);
            branchDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (branchDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (branchDetailActivity.progressDialog != null) {
                branchDetailActivity.progressDialog.dismiss();
                branchDetailActivity.progressDialog = null;
            }
            if (branchDetailActivity.getBranchDetailDataThread != null) {
                branchDetailActivity.getBranchDetailDataThread.interrupt();
                branchDetailActivity.getBranchDetailDataThread = null;
            }
            if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR) {
                DialogUtil.createShortDialog(branchDetailActivity, "您的网络貌似不给力，请重试");
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
                DialogUtil.createShortDialog(branchDetailActivity, (String) msg.obj);
            } else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
                branchDetailActivity.branchInfo = (BranchInfo) msg.obj;
                branchDetailActivity.branchInfo.setId(branchDetailActivity.branchID);
                ((TextView) branchDetailActivity.findViewById(R.id.company_information_title_text)).setText(branchDetailActivity.branchInfo.getName());
                RelativeLayout accountAccountLayout = (RelativeLayout) branchDetailActivity.findViewById(R.id.account_count_layout);
                if (branchDetailActivity.branchInfo.getAccountCount().equals("0"))
                    accountAccountLayout.setVisibility(View.GONE);
                else {
                    TextView accountCountView = (TextView) branchDetailActivity.findViewById(R.id.account_list_count);
                    accountCountView.setText("(" + branchDetailActivity.branchInfo.getAccountCount() + ")");
                    accountAccountLayout.setOnClickListener(new OnClickListener() {

                        @Override
                        public void onClick(View arg0) {
                            // TODO Auto-generated method stub
                            Intent intent = new Intent(branchDetailActivity, AccountListActivity.class);
                            intent.putExtra("Flag", branchDetailActivity.branchtype);
                            intent.putExtra("BranchID", branchDetailActivity.branchID);
                            intent.putExtra("BranchName", branchDetailActivity.branchInfo.getName());
                            branchDetailActivity.startActivity(intent);
                        }
                    });
                }
                branchDetailActivity.createMapView();
                branchDetailActivity.createImageLayout();
                branchDetailActivity.createTableSummary();
                branchDetailActivity.createTableBusinessHours();
                branchDetailActivity.createTableContact();
                branchDetailActivity.createTableAddress();
                branchDetailActivity.createTableWeb();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(branchDetailActivity, branchDetailActivity.getString(R.string.login_error_message));
                branchDetailActivity.userInfoApplication.exitForLogin(branchDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + branchDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(branchDetailActivity);
                branchDetailActivity.packageUpdateUtil = new PackageUpdateUtil(branchDetailActivity, branchDetailActivity.mHandler, fileCache, downloadFileUrl, false, branchDetailActivity.userInfoApplication);
                branchDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                branchDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = branchDetailActivity.getFileStreamPath(filename);
                file.getName();
                branchDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_branch_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
        arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
        mMapView = (MapView) findViewById(R.id.bmapView);
        Intent intent = getIntent();
        branchID = intent.getStringExtra("BranchID");
        branchtype = intent.getStringExtra("Flag");
        userInfoApplication = (UserInfoApplication) getApplication();
        mLayoutInflater = getLayoutInflater();
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
        //如果是商家信息 则隐藏服务团队
        if (branchID.equals(""))
            findViewById(R.id.account_count_layout).setVisibility(View.GONE);

    }

    @Override
    protected void onResume() {
        mMapView.onResume();
        super.onResume();
        getServerBranchDetail();
    }

    @Override
    protected void onPause() {
        mMapView.onPause();
        super.onPause();
    }

    private void createGetBranchDetailTask() {
        JSONObject branchDetailJsonParam = new JSONObject();
        try {
            if (!branchID.equals(""))
                branchDetailJsonParam.put("BranchID", String.valueOf(branchID));
            else
                branchDetailJsonParam.put("BranchID", 0);
            branchDetailJsonParam.put("ImageHeight", (userInfoApplication.getScreenWidth() - 20) * 0.75);
            branchDetailJsonParam.put("ImageWidth", userInfoApplication.getScreenWidth() - 20);
        } catch (JSONException e) {

        }
        getBranchDetailDataTask = new GetServerBranchDetailDataTaskImpl(branchDetailJsonParam, mHandler, userInfoApplication);
    }

    private void dismissProgressDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
        }
    }

    private void getServerBranchDetail() {
        if (getBranchDetailDataThread == null) {
            progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
            progressDialog.show();
            createGetBranchDetailTask();
            getBranchDetailDataThread = new GetBackendServerDataByWebserviceThread(getBranchDetailDataTask, false);
            getBranchDetailDataThread.start();
        }
    }

    private void createMapView() {
        if (!branchInfo.getLatitude().equals("0.0") && !branchInfo.getLongitude().equals("0.0")) {
            TableLayout layout = (TableLayout) findViewById(R.id.company_map);
            layout.setVisibility(View.VISIBLE);

            //定义Maker坐标点
            LatLng point = new LatLng(Double.valueOf(branchInfo.getLatitude()), Double.valueOf(branchInfo.getLongitude()));
            //构建Marker图标
            BitmapDescriptor bitmap = BitmapDescriptorFactory.fromResource(R.drawable.icon_map_point);
            //构建MarkerOption，用于在地图上添加Marker
            OverlayOptions option = new MarkerOptions().position(point).perspective(false).icon(bitmap);
            //在地图上添加Marker，并显示
            mBaiduMap = mMapView.getMap();
            MapStatusUpdate msu = MapStatusUpdateFactory.zoomTo(18.0f);
            mBaiduMap.setMapStatus(msu);
            mBaiduMap.addOverlay(option);

            LatLngBounds bounds = new LatLngBounds.Builder().include(point).build();
            MapStatusUpdate u = MapStatusUpdateFactory.newLatLng(bounds.getCenter());
            mBaiduMap.setMapStatus(u);
        } else {
            mMapView.setVisibility(View.GONE);
        }

    }

    private void createImageLayout() {
        ImageView CompanyImage;
        ArrayList<View> imageViewList = new ArrayList<View>();
        View childView;
        if (!branchInfo.getIamgeCount().equals("0")) {
            String[] imageArray = branchInfo.getImageURLs().split(",");
            for (int i = 0; i < imageArray.length; i++) {
                childView = mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
                CompanyImage = (ImageView) childView.findViewById(R.id.company_image);
                imageLoader.displayImage(imageArray[i], CompanyImage, displayImageOptions);
                imageViewList.add(childView);
            }
            createViewPager(imageViewList);
        } else {
            RelativeLayout layout = (RelativeLayout) findViewById(R.id.company_image_layout);
            layout.setVisibility(View.GONE);
        }

    }

    private void createViewPager(List<View> mViewList) {
        imageCount = mViewList.size();
        arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
        if (imageCount == 1) {
            arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
        } else {
            arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
        }
        viewPager = (ViewPager) findViewById(R.id.company_image_viewpager);
        PagerAdapter = new ViewPagerAdapter(mViewList);
        viewPager.setAdapter(PagerAdapter);
        viewPager.setOnPageChangeListener(new OnPageChangeListener() {
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
            }

            @Override
            public void onPageScrolled(int arg0, float arg1, int arg2) {
                // TODO Auto-generated method stub
            }

            @Override
            public void onPageScrollStateChanged(int arg0) {
                // TODO Auto-generated method stub
            }
        });

    }

    protected void createTableSummary() {
        TableLayout tableLayoutCompanySummary = (TableLayout) findViewById(R.id.company_Summary);
        tableLayoutCompanySummary.removeAllViews();
        if (!branchInfo.getSummary().equals("") && !branchInfo.getSummary().equals("anyType{}")) {
            createTableLayout(tableLayoutCompanySummary, 1,
                    getString(R.string.summary),
                    branchInfo.getSummary());
        } else {
            tableLayoutCompanySummary.setVisibility(View.GONE);
        }

    }

    protected void createTableBusinessHours() {
        TableLayout tableLayoutBusinessHours = (TableLayout) findViewById(R.id.company_business_hours);
        tableLayoutBusinessHours.removeAllViews();
        if (!branchInfo.getBusinessHours().equals("")
                && !branchInfo.getBusinessHours().equals("anyType{}")) {
            createTableLayout(tableLayoutBusinessHours, 1,
                    getString(R.string.business_time),
                    branchInfo.getBusinessHours());
        } else {
            tableLayoutBusinessHours.setVisibility(View.GONE);
        }

    }

    protected void createTableContact() {
        TableLayout tableLayoutContactInformation = (TableLayout) findViewById(R.id.company_contact_information);
        tableLayoutContactInformation.removeAllViews();
        if (!branchInfo.getContact().equals("")
                && !branchInfo.getContact().equals("anyType{}")) {
            RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(
                    R.xml.company_detail_contact_layout, null);

            TextView titleTextView = (TextView) Layout
                    .findViewById(R.id.left_textview);
            titleTextView.setText(getString(R.string.contact_person));
            titleTextView.setTextColor(this.getResources().getColor(
                    R.color.blue));

            TextView contentTextView = (TextView) Layout
                    .findViewById(R.id.right_textview);
            contentTextView.setText(branchInfo.getContact());

            tableLayoutContactInformation.addView(Layout);
        }
        if (!branchInfo.getPhone().equals("")
                && !branchInfo.getPhone().equals("anyType{}")) {
            tableLayoutContactInformation.addView(
                    mLayoutInflater.inflate(R.xml.shape_straight_line, null),
                    new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
            RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(
                    R.xml.company_detail_contact_layout, null);
            TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
            titleTextView.setText(getString(R.string.phone));
            titleTextView.setTextColor(this.getResources().getColor(
                    R.color.blue));

            TextView contentTextView = (TextView) Layout
                    .findViewById(R.id.right_textview);
            contentTextView.setText(branchInfo.getPhone());

            tableLayoutContactInformation.addView(Layout);
        }

        if (!branchInfo.getFax().equals("")
                && !branchInfo.getFax().equals("anyType{}")) {
            tableLayoutContactInformation.addView(
                    mLayoutInflater.inflate(R.xml.shape_straight_line, null),
                    new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
//			createTableLayout(tableLayoutContactInformation, 2,
//					getString(R.string.fax), companyInformation.getFax());

            RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(
                    R.xml.company_detail_contact_layout, null);
            TextView titleTextView = (TextView) Layout
                    .findViewById(R.id.left_textview);
            titleTextView.setText(getString(R.string.fax));
            titleTextView.setTextColor(this.getResources().getColor(
                    R.color.blue));

            TextView contentTextView = (TextView) Layout
                    .findViewById(R.id.right_textview);
            contentTextView.setText(branchInfo.getFax());

            tableLayoutContactInformation.addView(Layout);
        }

        if ((branchInfo.getContact().equals("") || branchInfo
                .getContact().equals("anyType{}"))
                && (branchInfo.getPhone().equals("") || branchInfo
                .getPhone().equals("anyType{}"))
                && (branchInfo.getFax().equals("") || branchInfo
                .getFax().equals("anyType{}"))) {
            tableLayoutContactInformation.setVisibility(View.GONE);
        }
    }

    protected void createTableAddress() {
        TableLayout tableLayoutAddress = (TableLayout) findViewById(R.id.company_address);
        tableLayoutAddress.removeAllViews();
        if (!branchInfo.getAddress().equals("")
                && !branchInfo.getAddress().equals("anyType{}")) {

            // 显示邮编
            if (!branchInfo.getZip().equals("")
                    && !branchInfo.getZip().equals("anyType{}")) {
                createTableLayout(tableLayoutAddress, 2,
                        getString(R.string.address),
                        branchInfo.getZip());
            } else {
                createTableLayout(tableLayoutAddress, 2,
                        getString(R.string.address), "");
            }

            RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater
                    .inflate(R.xml.relativelayout_has_one_child_view, null);

            TextView contentTextView = (TextView) contentLayout
                    .findViewById(R.id.left_textview);
            contentTextView.setText(branchInfo.getAddress());

            tableLayoutAddress.addView(
                    mLayoutInflater.inflate(R.xml.shape_straight_line, null),
                    new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
            tableLayoutAddress.addView(contentLayout);
        } else {
            tableLayoutAddress.setVisibility(View.GONE);
        }

    }

    protected void createTableWeb() {
        TableLayout tableLayoutWeb = (TableLayout) findViewById(R.id.company_web);
        tableLayoutWeb.removeAllViews();
        if (!branchInfo.getWeb().equals("")
                && !branchInfo.getWeb().equals("anyType{}")) {
            createTableLayout(tableLayoutWeb, 1,
                    getString(R.string.web_address),
                    branchInfo.getWeb());
        } else {
            tableLayoutWeb.setVisibility(View.GONE);
        }

    }

    private void createTableLayout(TableLayout tableLayout, int flag,
                                   String title, String content) {
        // 一行显示一个textview
        if (flag == 1) {
            RelativeLayout titleLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_view, null);
            RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_view, null);
            TextView titleTextView = (TextView) titleLayout.findViewById(R.id.left_textview);
            titleTextView.setText(title);
            titleTextView.setTextColor(this.getResources().getColor(R.color.blue));
            TextView contentTextView = (TextView) contentLayout.findViewById(R.id.left_textview);
            contentTextView.setText(content);
            tableLayout.addView(titleLayout);
            tableLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null), new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
            tableLayout.addView(contentLayout);
        } else if (flag == 2) {
            RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_two_child_view, null);
            TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
            titleTextView.setText(title);
            titleTextView.setTextColor(this.getResources().getColor(R.color.blue));
            TextView contentTextView = (TextView) Layout.findViewById(R.id.right_textview);
            contentTextView.setText(content);
            tableLayout.addView(Layout);
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
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (getBranchDetailDataThread != null) {
            getBranchDetailDataThread.interrupt();
            getBranchDetailDataThread = null;
        }
    }
}
