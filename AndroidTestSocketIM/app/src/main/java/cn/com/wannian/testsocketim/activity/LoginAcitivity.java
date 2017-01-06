package cn.com.wannian.testsocketim.activity;

import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import cn.com.wannian.testsocketim.view.LoadingDialog;
import cn.com.wannian.testsocketim.bean.NetFriendList;
import cn.com.wannian.testsocketim.R;
import cn.com.wannian.testsocketim.service.SocketService;
import de.greenrobot.event.EventBus;
import de.greenrobot.event.Subscribe;
import de.greenrobot.event.ThreadMode;

/**
 * Created by Wan.N
 * Date      :2017/1/5
 * Desc      :登录界面
 */

public class LoginAcitivity extends AppCompatActivity {
    private static final String TAG = LoginAcitivity.class.getSimpleName();
    private SocketService socketService;
    private EditText username_et;
    private EditText ip_et;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_activity);
        setTitle("登录");
        EventBus.getDefault().register(this);

        Intent intent = new Intent(LoginAcitivity.this, SocketService.class);
        startService(intent);
        bindService(intent, conn, BIND_AUTO_CREATE);

        username_et = (EditText) findViewById(R.id.username_et);
        ip_et = (EditText) findViewById(R.id.ip_et);
        TextView login_btn = (TextView) findViewById(R.id.login_btn);

        login_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String username = username_et.getText().toString();
                String ip = ip_et.getText().toString();
                if (!TextUtils.isEmpty(username) && !TextUtils.isEmpty(ip)) {
                    socketService.startSocektIM(username, ip);
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            showLoading("登录中...");
                        }
                    });
                } else {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(LoginAcitivity.this, "内容不完整", Toast.LENGTH_SHORT).show();
                        }
                    });
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        username_et.setSelection(username_et.length());
    }

    private ServiceConnection conn = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            SocketService.MyBinder bind = (SocketService.MyBinder) service;
            socketService = bind.getService();
            Log.i(TAG, "onServiceConnected");
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.i(TAG, "onServiceDisconnected");
        }
    };

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void getFriendList(NetFriendList netFriendList) {
        Log.i(TAG, "getFriendList:" + netFriendList.toString());
        dismissLoading();
        Intent intent = new Intent(LoginAcitivity.this, FriendListActivity.class);
        intent.putExtra("friendList", netFriendList);
        startActivity(intent);
        finish();
    }

    LoadingDialog mLoadDialog;

    private void showLoading(String msg) {
        mLoadDialog = new LoadingDialog(msg);
        mLoadDialog.show(getSupportFragmentManager(), LoadingDialog.TAG);
        mLoadDialog.setCancelable(false);
    }

    private void dismissLoading() {
        if (mLoadDialog != null) {
            mLoadDialog.dismiss();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (conn != null) {
            unbindService(conn);
            conn = null;
        }
        EventBus.getDefault().unregister(this);
    }
}
