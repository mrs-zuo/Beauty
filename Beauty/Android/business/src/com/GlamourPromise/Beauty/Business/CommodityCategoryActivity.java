package com.GlamourPromise.Beauty.Business;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.CategoryListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CategoryInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

public class CommodityCategoryActivity extends BaseActivity implements OnItemClickListener {
    private CommodityCategoryActivityHandler mHandler = new CommodityCategoryActivityHandler(this);
    private ListView commodityCategoryListView;
    private String parentCategoryName = "全部商品";
    private int parentCategoryID = 0;
    private List<CategoryInfo> categoryInfoList = new ArrayList<CategoryInfo>();
    private Thread requestWebServiceThread;
    private Stack<List<CategoryInfo>> categoryInfoListStack = new Stack<List<CategoryInfo>>();
    private UserInfoApplication userinfoApplication;
    private TextView commodityCategoryTitle;
    private String categoryProductCount;//每一层的productCount
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_commodity_category);
        initView();
    }

    protected void initView() {
        commodityCategoryListView = (ListView) findViewById(R.id.commodity_category_list);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        commodityCategoryTitle = (TextView) findViewById(R.id.commodity_category_title_text);
        commodityCategoryTitle.setText(R.string.commodity_category);
        userinfoApplication = UserInfoApplication.getInstance();
        commodityCategoryListView.setOnItemClickListener(this);
        categoryProductCount = "0";
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "getCategoryListByCompanyID";
                String endPoint = "Category";
                JSONObject categoryJsonParam = new JSONObject();
                try {
                    categoryJsonParam.put("Type", String.valueOf(Constant.COMMODITY_TYPE));
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, categoryJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject resultJson = null;
                    JSONObject dataJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        JSONArray categoryArray = null;
                        try {
                            categoryArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        CategoryInfo categoryInfo = new CategoryInfo();
                        categoryInfo.setCategoryID("-10");
                        categoryInfo.setNextCategoryCount(String.valueOf(categoryArray.length()));
                        categoryInfoList.add(categoryInfo);
                        for (int i = 0; i < categoryArray.length(); i++) {
                            JSONObject categoryJson = null;
                            try {
                                categoryJson = categoryArray.getJSONObject(i);
                            } catch (JSONException e) {
                            }
                            categoryInfo = new CategoryInfo();
                            categoryInfo.setParentCategoryName(parentCategoryName);
                            String categroyID = "0";
                            String categoryName = "";
                            String nextCategoryCount = "0";
                            try {
                                if (categoryJson.has("CategoryID") && !categoryJson.isNull("CategoryID"))
                                    categroyID = categoryJson.getString("CategoryID");
                                if (categoryJson.has("CategoryName") && !categoryJson.isNull("CategoryName"))
                                    categoryName = categoryJson.getString("CategoryName");
                                if (categoryJson.has("NextCategoryCount") && !categoryJson.isNull("NextCategoryCount"))
                                    nextCategoryCount = categoryJson.getString("NextCategoryCount");
                            } catch (JSONException e) {
                            }
                            categoryInfo.setCategoryID(categroyID);
                            categoryInfo.setCategoryName(categoryName);
                            categoryInfo.setNextCategoryCount(nextCategoryCount);
                            categoryInfoList.add(categoryInfo);
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    private static class CommodityCategoryActivityHandler extends Handler {
        private final CommodityCategoryActivity commodityCategoryActivity;

        private CommodityCategoryActivityHandler(CommodityCategoryActivity activity) {
            WeakReference<CommodityCategoryActivity> weakReference = new WeakReference<CommodityCategoryActivity>(activity);
            commodityCategoryActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (commodityCategoryActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 1) {
                if (commodityCategoryActivity.categoryInfoList != null && commodityCategoryActivity.categoryInfoList.size() != 0) {
                    commodityCategoryActivity.commodityCategoryListView.setAdapter(new CategoryListAdapter(commodityCategoryActivity, commodityCategoryActivity.categoryInfoList));
                }
            } else if (msg.what == 3) {
                commodityCategoryActivity.updateLayout(commodityCategoryActivity.categoryInfoList);
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(commodityCategoryActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(commodityCategoryActivity, commodityCategoryActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(commodityCategoryActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + commodityCategoryActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(commodityCategoryActivity);
                commodityCategoryActivity.packageUpdateUtil = new PackageUpdateUtil(commodityCategoryActivity, commodityCategoryActivity.mHandler, fileCache, downloadFileUrl, false, commodityCategoryActivity.userinfoApplication);
                commodityCategoryActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                commodityCategoryActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = commodityCategoryActivity.getFileStreamPath(filename);
                file.getName();
                commodityCategoryActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (commodityCategoryActivity.requestWebServiceThread != null) {
                commodityCategoryActivity.requestWebServiceThread.interrupt();
                commodityCategoryActivity.requestWebServiceThread = null;
            }
        }
    }

    @Override
    public void onItemClick(AdapterView<?> arg0, View view, int position,
                            long id) {
        // TODO Auto-generated method stub
        if (position == 0) {
            Intent destIntent = new Intent(this, CommodityListActivity.class);
            if (categoryInfoList.size() == 1 || categoryInfoList.get(position + 1).getParentCategoryID() == 0) {
                destIntent.putExtra("CategoryID", String.valueOf(0));
            } else {
                destIntent.putExtra("CategoryID", String.valueOf(categoryInfoList.get(position + 1).getParentCategoryID()));
                destIntent.putExtra("CategoryName", categoryInfoList.get(position + 1).getParentCategoryName());
            }

            startActivity(destIntent);
        } else {
            if (Integer.parseInt(categoryInfoList.get(position).getNextCategoryCount()) != 0) {
                categoryInfoListStack.push(categoryInfoList);
                parentCategoryName = categoryInfoList.get(position).getCategoryName();
                parentCategoryID = Integer.parseInt(categoryInfoList.get(position).getCategoryID());
                getNextCategoryList(categoryInfoList.get(position).getCategoryID());
            } else {
                //if (Integer.parseInt(categoryInfoList.get(position).getCommodityCount()) != 0) {
                Intent destIntent = new Intent(this, CommodityListActivity.class);
                destIntent.putExtra("CategoryID", String.valueOf(categoryInfoList.get(position).getCategoryID()));
                destIntent.putExtra("CategoryName", categoryInfoList.get(position).getCategoryName());
                startActivity(destIntent);
                //}
            }
        }
    }

    private void getNextCategoryList(String nextCategoryID) {
        Thread getNextCategoryThread = new GetNextCategoryThread(nextCategoryID);
        getNextCategoryThread.start();
    }

    private void updateLayout(List<CategoryInfo> newCategoryList) {
        commodityCategoryListView.setAdapter(new CategoryListAdapter(this,
                newCategoryList));
    }

    class GetNextCategoryThread extends Thread {
        private String nextCategoryID;

        public GetNextCategoryThread(String nextCategoryID) {
            this.nextCategoryID = nextCategoryID;
        }

        @Override
        public void run() {
            // TODO Auto-generated method stub
            String methodName = "getCategoryListByCategoryID";
            String endPoint = "Category";
            JSONObject nextCategoryJson = new JSONObject();
            try {
                nextCategoryJson.put("CategoryID", nextCategoryID);
                nextCategoryJson.put("Type", String.valueOf(Constant.COMMODITY_TYPE));
            } catch (JSONException e) {
            }
            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, nextCategoryJson.toString(), userinfoApplication);
            if (serverRequestResult == null || serverRequestResult.equals(""))
                mHandler.sendEmptyMessage(2);
            else {
                int code = 0;
                JSONObject resultJson = null;
                JSONObject dataJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                    code = resultJson.getInt("Code");
                } catch (JSONException e) {
                }
                if (code == 1) {
                    JSONArray categoryArray = null;
                    try {
                        categoryArray = resultJson.getJSONArray("Data");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    categoryInfoList = new ArrayList<CategoryInfo>();
                    CategoryInfo categoryInfo = new CategoryInfo();
                    categoryInfo.setCategoryID("-10");
					/*try {
						categoryInfo.setTotalCommodityCount(dataJson.getString("ProductCount"));
					} catch (JSONException e) {
						categoryInfo.setTotalCommodityCount("0");
					}*/
                    categoryInfo.setNextCategoryCount(String.valueOf(categoryArray.length()));
                    categoryInfoList.add(categoryInfo);
                    for (int i = 0; i < categoryArray.length(); i++) {
                        JSONObject categoryJson = null;
                        try {
                            categoryJson = categoryArray.getJSONObject(i);
                        } catch (JSONException e) {
                        }
                        categoryInfo = new CategoryInfo();
                        categoryInfo.setParentCategoryID(parentCategoryID);
                        categoryInfo.setParentCategoryName(parentCategoryName);
                        String categroyID = "0";
                        String categoryName = "";
                        String nextCategoryCount = "0";
                        try {
                            if (categoryJson.has("CategoryID") && !categoryJson.isNull("CategoryID"))
                                categroyID = categoryJson.getString("CategoryID");
                            if (categoryJson.has("CategoryName") && !categoryJson.isNull("CategoryName"))
                                categoryName = categoryJson.getString("CategoryName");
                            if (categoryJson.has("NextCategoryCount") && !categoryJson.isNull("NextCategoryCount"))
                                nextCategoryCount = categoryJson.getString("NextCategoryCount");
                        } catch (JSONException e) {
                        }
                        categoryInfo.setCategoryID(categroyID);
                        categoryInfo.setCategoryName(categoryName);
                        categoryInfo.setNextCategoryCount(nextCategoryCount);
                        categoryInfoList.add(categoryInfo);
                    }
                    mHandler.sendEmptyMessage(3);
                }
            }
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            mHandler = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
