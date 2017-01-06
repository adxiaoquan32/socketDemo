package cn.com.wannian.testsocketim.service;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;
import java.net.UnknownHostException;

import cn.com.wannian.testsocketim.bean.MsgBean;
import cn.com.wannian.testsocketim.bean.NetBaseBean;
import cn.com.wannian.testsocketim.bean.NetMsgBean;
import cn.com.wannian.testsocketim.bean.NetUserInfo;
import cn.com.wannian.testsocketim.bean.UserBean;
import cn.com.wannian.testsocketim.MyApplication;
import cn.com.wannian.testsocketim.bean.NetFriendList;
import de.greenrobot.event.EventBus;

/**
 * Created by Wan.N
 * Date      :2017/1/4
 * Desc      :维护socket通信线程
 */

public class SocketService extends Service {
    private static final String TAG = SocketService.class.getSimpleName();
    private Thread socketThread;
    private Socket socket;
    private BufferedWriter bufferedWriter;
    private InputStream inputStream;
    private MyBinder myBinder = new MyBinder();

    public SocketService() {
        super();
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return myBinder;
    }

    public class MyBinder extends Binder {
        public SocketService getService() {
            return SocketService.this;
        }
    }

    @Override
    public void onRebind(Intent intent) {
        super.onRebind(intent);
    }

    @Override
    public boolean onUnbind(Intent intent) {
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopSocketIM();
    }

    public void stopSocketIM() {
        try {
            if (bufferedWriter != null) {
                bufferedWriter.close();
                bufferedWriter = null;
            }
            if (inputStream != null) {
                inputStream.close();
                inputStream = null;
            }
            if (socket != null) {
                socket.close();
                socket = null;
            }
            if (socketThread != null) {
                socketThread.interrupt();
                socketThread = null;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void startSocektIM(String username, final String ip) {
        UserBean userBean = new UserBean();
        userBean.setState(1);
        userBean.setUserID(getDeviceId());
        userBean.setUserName(username);

        MyApplication.userBean = userBean;

        NetUserInfo netUserInfo = new NetUserInfo();
        netUserInfo.setTag("0");
        netUserInfo.setData(userBean);

        final Gson gson = new Gson();
        final String json = gson.toJson(netUserInfo);

        socketThread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Log.i(TAG, "startSocektIM--run..." + ip);
                    socket = new Socket();
                    SocketAddress address = new InetSocketAddress(ip, 59558);
                    socket.connect(address);

                    bufferedWriter = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), "UTF-8"));
                    Log.i(TAG, "上传用户信息：json:" + json);
                    bufferedWriter.write(json);
                    bufferedWriter.flush();

                    inputStream = socket.getInputStream();
                    //TODO 阻塞问题
                    byte[] data = new byte[1024 * 100];
                    int count = -1;
                    while ((count = inputStream.read(data)) != -1) {
                        String result = new String(data, 0, count);
                        dealmsg(result);
                        Log.i(TAG, "recieve result:" + result.toString());
                    }
                } catch (UnknownHostException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
        socketThread.start();
    }

    private void dealmsg(String result) {
        Gson gson = new Gson();
        NetBaseBean netBaseBean = gson.fromJson(result, NetBaseBean.class);

        String tag = netBaseBean.getTag();
        if (!TextUtils.isEmpty(tag) && tag.equals("0")) {
            //好友上线离线消息
            NetUserInfo netUserInfo = gson.fromJson(result, NetUserInfo.class);
            EventBus.getDefault().post(netUserInfo);
        } else if (!TextUtils.isEmpty(tag) && tag.equals("1")) {
            //好友列表
            NetFriendList netFriendList = gson.fromJson(result, NetFriendList.class);
            EventBus.getDefault().post(netFriendList);
        } else if (!TextUtils.isEmpty(tag) && tag.equals("2")) {
            //好友消息
            NetMsgBean netMsgBean = gson.fromJson(result, NetMsgBean.class);
            EventBus.getDefault().post(netMsgBean);
        }
    }

    public void sendMsg(MsgBean msg) {
        if (msg == null) {
            return;
        }
        NetMsgBean netMsgBean = new NetMsgBean();
        netMsgBean.setTag("2");
        netMsgBean.setData(msg);

        final Gson gson = new Gson();
        final String json = gson.toJson(netMsgBean);
        try {
            if (bufferedWriter != null) {
                bufferedWriter = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), "UTF-8"));
                Log.i(TAG, "sendMsg--json:" + json);
                bufferedWriter.write(json);
                bufferedWriter.flush();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    public String getDeviceId() {
        TelephonyManager tm = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        return tm.getDeviceId();
    }

}
