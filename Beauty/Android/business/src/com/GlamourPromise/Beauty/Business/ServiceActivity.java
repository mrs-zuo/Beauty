package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
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

public class ServiceActivity extends BaseActivity implements OnItemClickListener {
    private ServiceActivityHandler mHandler = new ServiceActivityHandler(this);
    private ListView serviceCategoryListView;
    private String parentCategoryName = "全部服务";
    private int parentCategoryID = 0;
    private List<CategoryInfo> categoryInfoList;
    private Thread requestWebServiceThread;
    private Stack<List<CategoryInfo>> categoryInfoListStack = new Stack<List<CategoryInfo>>();
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private TextView serviceCategroyTitle;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_service);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    protected void initView() {
        serviceCategoryListView = (ListView) findViewById(R.id.service_category_list);
        categoryInfoList = new ArrayList<CategoryInfo>();
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        serviceCategroyTitle = (TextView) findViewById(R.id.service_category_title_text);
        serviceCategroyTitle.setText(R.string.service_category);
        serviceCategoryListView.setOnItemClickListener(this);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "getCategoryListByCompanyID";
                String endPoint = "Category";
                JSONObject categoryJsonParam = new JSONObject();
                try {
                    categoryJsonParam.put("Type", Constant.SERVICE_TYPE);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, categoryJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(0);
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

    private static class ServiceActivityHandler extends Handler {
        private final ServiceActivity serviceActivity;

        private ServiceActivityHandler(ServiceActivity activity) {
            WeakReference<ServiceActivity> weakReference = new WeakReference<ServiceActivity>(activity);
            serviceActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (serviceActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (serviceActivity.progressDialog != null) {
                serviceActivity.progressDialog.dismiss();
                serviceActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                if (serviceActivity.categoryInfoList != null && serviceActivity.categoryInfoList.size() != 0)
                    serviceActivity.serviceCategoryListView.setAdapter(new CategoryListAdapter(serviceActivity, serviceActivity.categoryInfoList));
            } else if (msg.what == 2) {
                serviceActivity.updateLayout(serviceActivity.categoryInfoList);
            } else if (msg.what == 0)
                DialogUtil.createShortDialog(serviceActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(serviceActivity, serviceActivity.getString(R.string.login_error_message));
                serviceActivity.userinfoApplication.exitForLogin(serviceActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + serviceActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(serviceActivity);
                serviceActivity.packageUpdateUtil = new PackageUpdateUtil(serviceActivity, serviceActivity.mHandler, fileCache, downloadFileUrl, false, serviceActivity.userinfoApplication);
                serviceActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                serviceActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = serviceActivity.getFileStreamPath(filename);
                file.getName();
                serviceActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (serviceActivity.requestWebServiceThread != null) {
                serviceActivity.requestWebServiceThread.interrupt();
                serviceActivity.requestWebServiceThread = null;
            }

        }
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view,
                            int position, long id) {
        if (position == 0) {
            Intent destIntent = new Intent(this, ServiceListActivity.class);
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
                parentCategoryName = categoryInfoList.get(position)
                        .getCategoryName();
                parentCategoryID = Integer.parseInt(categoryInfoList
                        .get(position).getCategoryID());
                getNextCategoryList(categoryInfoList.get(position)
                        .getCategoryID());
            } else {
                //if (Integer.parseInt(categoryInfoList.get(position).getCommodityCount()) != 0) {
                Intent destIntent = new Intent(this, ServiceListActivity.class);
                destIntent.putExtra("CategoryID", String.valueOf(categoryInfoList.get(position).getCategoryID()));
                destIntent.putExtra("CategoryName", categoryInfoList.get(position).getCategoryName());
                startActivity(destIntent);
                //}

            }

        }
    }

    private void getNextCategoryList(String nextCategoryID) {
        Thread getNextCategroyThread = new GetNextCategoryThread(nextCategoryID);
        getNextCategroyThread.start();
    }

    private void updateLayout(List<CategoryInfo> newCategoryList) {
        serviceCategoryListView.setAdapter(new CategoryListAdapter(this,
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
                nextCategoryJson.put("Type", String.valueOf(Constant.SERVICE_TYPE));
            } catch (JSONException e) {
            }
            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, nextCategoryJson.toString(), userinfoApplication);
            if (serverRequestResult == null || serverRequestResult.equals(""))
                mHandler.sendEmptyMessage(0);
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
                    categoryInfoList = new ArrayList<CategoryInfo>();
                    CategoryInfo categoryInfo = new CategoryInfo();
                    categoryInfo.setCategoryID("-10");
					/*try {
						categoryInfo.setTotalCommodityCount(dataJson.getString("ProductCount"));
					} catch (JSONException e) {
						categoryInfo.setTotalCommodityCount("0");
					}*/
                    //categoryInfo.setNextCategoryCount(String.valueOf(categoryArray.length()));
                    categoryInfoList.add(categoryInfo);
                    for (int i = 0; i < categoryArray.length(); i++) {
                        JSONObject categoryJson = null;
                        try {
                            categoryJson = categoryArray.getJSONObject(i);
                        } catch (JSONException e) {
                        }
                        categoryInfo = new CategoryInfo();
						/*try {
							categoryInfo.setTotalCommodityCount(dataJson.getString("ProductCount"));
						} catch (JSONException e) {
							categoryInfo.setTotalCommodityCount("0");
						}*/
                        categoryInfo.setParentCategoryID(parentCategoryID);
                        categoryInfo.setParentCategoryName(parentCategoryName);
                        /*String productCount = "0";*/
                        String categroyID = "0";
                        String categoryName = "";
                        String nextCategoryCount = "0";
                        try {
							/*if (categoryJson.has("ProductCount") && !categoryJson.isNull("ProductCount"))
								productCount = categoryJson.getString("ProductCount");*/
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
                        //categoryInfo.setCommodityCount(productCount);
                        categoryInfo.setNextCategoryCount(nextCategoryCount);
                        categoryInfoList.add(categoryInfo);
                    }
                    mHandler.sendEmptyMessage(2);
                } else
                    mHandler.sendEmptyMessage(code);
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
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
