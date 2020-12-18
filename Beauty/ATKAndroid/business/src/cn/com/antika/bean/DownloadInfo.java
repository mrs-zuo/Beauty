package cn.com.antika.bean;

import java.io.Serializable;

import android.app.ProgressDialog;

public class DownloadInfo implements Serializable {
	private int            downloadApkSize;
	private ProgressDialog updateDialog;
	public int getDownloadApkSize() {
		return downloadApkSize;
	}
	public void setDownloadApkSize(int downloadApkSize) {
		this.downloadApkSize = downloadApkSize;
	}
	public ProgressDialog getUpdateDialog() {
		return updateDialog;
	}
	public void setUpdateDialog(ProgressDialog updateDialog) {
		this.updateDialog = updateDialog;
	}
}
