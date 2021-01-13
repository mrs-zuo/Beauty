package cn.com.antika.business;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import cn.com.antika.Thread.GetBackendServerDataByJsonThread;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.LabelInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.implementation.AddNoteTaskImpl;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.LabelView;

public class AddNoteActivity extends BaseActivity {
    private AddNoteActivityHandler mHandler = new AddNoteActivityHandler(this);
    private LinearLayout labelContainer;
    private EditText noteContentView;
    private HashMap<Integer, LabelInfo> labelViewList;
    private GetBackendServerDataByJsonThread addDataThread;
    private AddNoteTaskImpl addNoteTask;
    private UserInfoApplication userInfo;
    private ProgressDialog progressDialog;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AddNoteActivityHandler extends Handler {
        private final AddNoteActivity addNoteActivity;

        private AddNoteActivityHandler(AddNoteActivity activity) {
            WeakReference<AddNoteActivity> weakReference = new WeakReference<AddNoteActivity>(activity);
            addNoteActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            addNoteActivity.dismissProgressDialog();
            // 当activity未加载完成时,用户返回的情况
            if (addNoteActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (addNoteActivity.addDataThread != null) {
                addNoteActivity.addDataThread.interrupt();
                addNoteActivity.addDataThread = null;
            }
            if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR) {
                DialogUtil.createShortDialog(addNoteActivity, "您的网络貌似不给力，请重试");
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
                DialogUtil.createShortDialog(addNoteActivity, (String) msg.obj);
            } else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
                DialogUtil.createShortDialog(addNoteActivity, "添加笔记成功！");
                Intent destIntent = new Intent(addNoteActivity, CustomerInfoActivity.class);
                destIntent.putExtra("current_tab", 2);
                destIntent.putExtra("isByCustomerID", true);
                addNoteActivity.startActivity(destIntent);
                addNoteActivity.finish();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(addNoteActivity, addNoteActivity.getString(R.string.login_error_message));
                addNoteActivity.userInfo.exitForLogin(addNoteActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + addNoteActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(addNoteActivity);
                addNoteActivity.packageUpdateUtil = new PackageUpdateUtil(addNoteActivity, addNoteActivity.mHandler, fileCache, downloadFileUrl, false, addNoteActivity.userInfo);
                addNoteActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                addNoteActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = addNoteActivity.getFileStreamPath(filename);
                file.getName();
                addNoteActivity.packageUpdateUtil.showInstallDialog();
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
        setContentView(R.layout.activity_add_note);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userInfo = (UserInfoApplication) getApplication();
        noteContentView = (EditText) findViewById(R.id.content_edit);
        //添加标签
        ((ImageView) findViewById(R.id.add_label_icon)).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View arg0) {
                Intent intent = new Intent(AddNoteActivity.this, LabelListActivity.class);
                intent.putExtra(LabelListActivity.LIMIT_NUM_FLAG, true);
                ArrayList<Integer> ids = new ArrayList<Integer>();
                if (labelViewList != null && labelViewList.size() > 0) {
                    Iterator<LabelInfo> labelInfoIt = labelViewList.values().iterator();
                    while (labelInfoIt.hasNext()) {
                        ids.add(Integer.valueOf(labelInfoIt.next().getID()));
                    }
                }
                intent.putExtra(LabelListActivity.SELECT_LABEL_LIST_ID, ids);
                startActivityForResult(intent, 1);
            }
        });
        ((Button) findViewById(R.id.confirm_button)).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View arg0) {
                if (userInfo.getSelectedCustomerID() == 0) {
                    DialogUtil.createMakeSureDialog(AddNoteActivity.this, "温馨提示", "您未选中顾客，不能进行操作");
                } else {
                    // TODO Auto-generated method stub
                    if (!noteContentView.getText().toString().equals(""))
                        addNote();
                    else {
                        DialogUtil.createShortDialog(AddNoteActivity.this, "内容不能为空");
                    }
                }
            }
        });
        labelContainer = (LinearLayout) findViewById(R.id.label_container);
        labelViewList = new HashMap<Integer, LabelInfo>();
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == 1 && resultCode == RESULT_OK) {
            labelViewList = (HashMap<Integer, LabelInfo>) data.getSerializableExtra(LabelListActivity.LABEL_CONTENT_LIST);
            if (labelViewList != null) {
                labelContainer.removeAllViews();
                LabelView labelView;
                LabelInfo labelInfo;
                LinearLayout.LayoutParams rlp = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
                rlp.setMargins(10, 5, 10, 5);
                for (int i = 0; i < labelViewList.size(); i++) {
                    labelInfo = labelViewList.get(i);
                    labelView = new LabelView(this);
                    labelView.setLabelContent(labelInfo.getLabelName());
                    final int pos = i;
                    labelView.setTag(String.valueOf(i));
                    labelView.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View arg0) {
                            deleteLabel(pos);
                        }
                    });
                    labelContainer.addView(labelView, rlp);
                }
            }
        }
    }

    private void addNote() {
        if (addDataThread == null) {
            showProgressDialog();
            addDataThread = new GetBackendServerDataByJsonThread(getAddNoteTask());
            addDataThread.start();
        }
    }

    private AddNoteTaskImpl getAddNoteTask() {
        if (addNoteTask == null) {
            JSONObject paramJson = new JSONObject();
            try {
                paramJson.put("CompanyID", userInfo.getAccountInfo().getCompanyId());
                paramJson.put("BranchID", userInfo.getAccountInfo().getBranchId());
                paramJson.put("CreatorID", userInfo.getAccountInfo().getAccountId());
                paramJson.put("CustomerID", userInfo.getSelectedCustomerID());
                paramJson.put("Content", String.valueOf(noteContentView.getText()));
                StringBuilder tagIDs = new StringBuilder();
                if (labelViewList == null || labelViewList.size() == 0) {
                    tagIDs.append("");
                } else {
                    tagIDs.append("|");
                    Iterator<LabelInfo> labelInfoIt = labelViewList.values().iterator();
                    while (labelInfoIt.hasNext()) {
                        tagIDs.append(labelInfoIt.next().getID());
                        tagIDs.append("|");
                    }
					/*for(int i = 0; i < labelViewList.size(); i++){
						if(labelViewList.get(i)!=null){
							tagIDs.append(labelViewList.get(i).getID());
							tagIDs.append("|");
						}
					}*/
                }
                paramJson.put("TagIDs", tagIDs.toString());
                addNoteTask = new AddNoteTaskImpl(paramJson, mHandler, userInfo);
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

        }
        return addNoteTask;
    }

    private void deleteLabel(final int postion) {
        AlertDialog paymentDialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.confirm_delete_label))
                .setPositiveButton(getString(R.string.confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface arg0, int arg1) {
                                // TODO Auto-generated method stub
                                labelViewList.remove(postion);
                                LabelView tmp;
                                for (int i = 0; i < labelContainer.getChildCount(); i++) {
                                    if (((String) labelContainer.getChildAt(i).getTag()).equals(String.valueOf(postion))) {
                                        tmp = (LabelView) labelContainer.getChildAt(i);
                                        labelContainer.removeView(tmp);
                                        ;
                                    }
                                }
                            }
                        })
                .setNegativeButton(getString(R.string.cancel), null).show();
        paymentDialog.setCancelable(false);
    }

    private void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
        }
        progressDialog.show();
    }

    private void dismissProgressDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (addDataThread != null) {
            addDataThread.interrupt();
            addDataThread = null;
        }
    }
}
