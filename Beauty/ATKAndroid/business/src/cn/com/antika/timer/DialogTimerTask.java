package cn.com.antika.timer;
import java.util.Timer;
import java.util.TimerTask;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
public class DialogTimerTask extends TimerTask{
	private AlertDialog  dialog;
	private Timer        timer;
	private Activity     activity;
	private Intent       intent;
	public DialogTimerTask(AlertDialog dialog,Timer timer,Activity activity,Intent intent){
		this.dialog=dialog;
		this.timer=timer;
		this.intent=intent;
		this.activity=activity;
	}
	@Override
	public void run() {
		// TODO Auto-generated method stub
		dialog.dismiss();
		dialog=null;
		timer.cancel();
		activity.startActivity(intent);
		activity.finish();
	}

}
