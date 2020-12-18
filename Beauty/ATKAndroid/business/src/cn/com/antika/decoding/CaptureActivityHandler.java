/*
 * Copyright (C) 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package cn.com.antika.decoding;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.Result;

import java.util.Vector;

import cn.com.antika.business.AccountAttendanceActivity;
import cn.com.antika.business.DecodeQRCodeActivity;
import cn.com.antika.business.HomePageActivity;
import cn.com.antika.business.PaymentActionThirdPartActivity;
import cn.com.antika.business.R;
import cn.com.antika.camera.CameraManager;
import cn.com.antika.view.ViewfinderResultPointCallback;

/**
 * This class handles all the messaging which comprises the state machine for capture.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
@SuppressLint("ResourceType")
public final class CaptureActivityHandler extends Handler {

  private static final String TAG = CaptureActivityHandler.class.getSimpleName();

  private final DecodeQRCodeActivity activity;
  private final DecodeThread decodeThread;
  private State state;
  private int   sourceType;
  private enum State {
    PREVIEW,
    SUCCESS,
    DONE
  }

  public CaptureActivityHandler(DecodeQRCodeActivity activity, Vector<BarcodeFormat> decodeFormats,String characterSet,int sourceType) {
    this.activity = activity;
    decodeThread = new DecodeThread(activity, decodeFormats, characterSet,
        new ViewfinderResultPointCallback(activity.getViewfinderView()));
    decodeThread.start();
    state = State.SUCCESS;
    this.sourceType=sourceType;
    // Start ourselves capturing previews and decoding.
    CameraManager.get().startPreview();
    restartPreviewAndDecode();
  }

  @Override
  public void handleMessage(Message message) {
    switch (message.what) {
      case R.id.auto_focus:
        //Log.d(TAG, "Got auto-focus message");
        // When one auto focus pass finishes, start another. This is the closest thing to
        // continuous AF. It does seem to hunt a bit, but I'm not sure what else to do.
        if (state == State.PREVIEW) {
          CameraManager.get().requestAutoFocus(this, R.id.auto_focus);
        }
        break;
      case R.id.restart_preview:
        Log.d(TAG, "Got restart preview message");
        restartPreviewAndDecode();
        break;
      case R.id.decode_succeeded:
        Log.d(TAG, "Got decode succeeded message");
        state = State.SUCCESS;
        Bundle bundle = message.getData();
        Bitmap barcode = bundle == null ? null :(Bitmap) bundle.getParcelable(DecodeThread.BARCODE_BITMAP);
        String str_result=((Result) message.obj).getText();
        activity.handleDecode((Result) message.obj, barcode);
    	Intent intent=null;
    	//从右侧菜单进来 返回到首页
    	if(sourceType==1)
    		intent=new Intent(activity,HomePageActivity.class);
    	//从扫码支付进来  返回到支付页
    	else if(sourceType==2){
    		intent=new Intent(activity,PaymentActionThirdPartActivity.class);	
    	}
    	//从考勤扫码进来 返回到考勤页
    	else if(sourceType==3){
    		intent=new Intent(activity,AccountAttendanceActivity.class);	
    	}
		intent.putExtra("code",str_result);
		activity.startActivity(intent);
		activity.finish();
        break;
      case R.id.decode_failed:
        // We're decoding as fast as possible, so when one decode fails, start another.
        state = State.PREVIEW;
        CameraManager.get().requestPreviewFrame(decodeThread.getHandler(), R.id.decode);
        break;
      case R.id.return_scan_result:
        Log.d(TAG, "Got return scan result message");
        activity.setResult(Activity.RESULT_OK, (Intent) message.obj);
        activity.finish();
        break;
    }
  }

  public void quitSynchronously() {
    state = State.DONE;
    CameraManager.get().stopPreview();
    Message quit = Message.obtain(decodeThread.getHandler(), R.id.quit);
    quit.sendToTarget();
    try {
      decodeThread.join();
    } catch (InterruptedException e) {
      // continue
    }

    // Be absolutely sure we don't send any queued up messages
    removeMessages(R.id.decode_succeeded);
    //removeMessages(R.id.return_scan_result);
    removeMessages(R.id.decode_failed);
  }

  private void restartPreviewAndDecode() {
    if (state == State.SUCCESS) {
      state = State.PREVIEW;
      CameraManager.get().requestPreviewFrame(decodeThread.getHandler(), R.id.decode);
      CameraManager.get().requestAutoFocus(this, R.id.auto_focus);
      activity.drawViewfinder();
    }
  }

}
