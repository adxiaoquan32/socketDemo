package cn.com.wannian.testsocketim.activity;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import cn.com.wannian.testsocketim.eventbean.EventLocalMsg;
import cn.com.wannian.testsocketim.bean.MsgBean;
import cn.com.wannian.testsocketim.MyApplication;
import cn.com.wannian.testsocketim.bean.NetMsgBean;
import cn.com.wannian.testsocketim.bean.NetUserInfo;
import cn.com.wannian.testsocketim.R;
import cn.com.wannian.testsocketim.service.SocketService;
import cn.com.wannian.testsocketim.bean.UserBean;
import de.greenrobot.event.EventBus;
import de.greenrobot.event.Subscribe;
import de.greenrobot.event.ThreadMode;

/**
 * Created by Wan.N
 * Date      :2017/1/4
 * Desc      :聊天界面
 */

public class ChatActivity extends AppCompatActivity {

    private static final String TAG = ChatActivity.class.getSimpleName();

    private List<NetMsgBean> netMsgBeanList = new ArrayList<>();
    private LinearLayoutManager linearLayoutManager;
    private MsgListAdapter msgListAdapter;
    private RecyclerView msg_lv;
    private SocketService socketService;
    private TextView send_btn;
    private EditText msg_et;
    private UserBean friendBean;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(TAG, "onCreate");
        setContentView(R.layout.activity_main);

        EventBus.getDefault().register(this);

        Intent intent = new Intent(ChatActivity.this, SocketService.class);
        bindService(intent, conn, BIND_AUTO_CREATE);

        msg_lv = (RecyclerView) findViewById(R.id.msg_lv);
        send_btn = (TextView) findViewById(R.id.send_btn);
        msg_et = (EditText) findViewById(R.id.msg_et);

        send_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String msg = msg_et.getText().toString();
                if (!TextUtils.isEmpty(msg)) {
                    MsgBean msgBean = new MsgBean();
                    msgBean.setBody(msg);
                    msgBean.setMsgState(0);
                    msgBean.setMsgTime(System.currentTimeMillis());
                    msgBean.setSender(MyApplication.userBean);
                    msgBean.setReceiver(friendBean);
                    socketService.sendMsg(msgBean);

                    Log.i(TAG, "sendMsg:" + msgBean.toString());
                    final NetMsgBean netMsgBean = new NetMsgBean();
                    netMsgBean.setTag("2");
                    netMsgBean.setData(msgBean);

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            addMsgToList(netMsgBean);
                            msg_et.setText("");
                        }
                    });
                    //保存用户发送的聊天数据
                    Map<String, List<NetMsgBean>> msgMap = MyApplication.msgMap;
                    if (msgMap.containsKey(friendBean.getUserID())) {
                        List<NetMsgBean> netMsgBeens = msgMap.get(friendBean.getUserID());
                        netMsgBeens.add(netMsgBean);
                    } else {
                        List<NetMsgBean> netMsgBeens = new ArrayList<>();
                        netMsgBeens.add(netMsgBean);
                        msgMap.put(msgBean.getReceiver().getUserID(), netMsgBeens);
                    }
                    //将本地msg发送出去，通知刷新最新聊天数据
                    EventLocalMsg localMsg = new EventLocalMsg();
                    localMsg.setNetMsgBean(netMsgBean);
                    EventBus.getDefault().post(localMsg);
                } else {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(ChatActivity.this, "内容不能为空", Toast.LENGTH_SHORT).show();
                        }
                    });
                }
            }
        });

        linearLayoutManager = new LinearLayoutManager(this);
        msg_lv.setLayoutManager(linearLayoutManager);
        msgListAdapter = new MsgListAdapter(netMsgBeanList);
        msg_lv.setAdapter(msgListAdapter);

        msg_lv.scrollToPosition(linearLayoutManager.findLastVisibleItemPosition());
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.i(TAG, "onResume");
        Intent intent = getIntent();
        friendBean = (UserBean) intent.getSerializableExtra("friend");
        Log.i(TAG, "friendBean:" + friendBean.toString());
        if (friendBean == null) {
            finish();
        }
        setTitle("与" + friendBean.getUserName() + "会话");

        addMsgToList(MyApplication.msgMap.get(friendBean.getUserID()));
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
    public void getFriendMsg(NetMsgBean netMsgBean) {
        Log.i(TAG, "getFriendMsg:" + netMsgBean.toString());
        if (netMsgBean != null && netMsgBean.getData() != null) {
            MsgBean data = netMsgBean.getData();
            if (data.getReceiver().getUserID().equals(getDeviceId()) && data.getSender().getUserID().equals(friendBean.getUserID())) {
                addMsgToList(netMsgBean);
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void getFriendOnLineState(NetUserInfo netUserInfo) {
        Log.i(TAG, "getFriendOnLineState:" + netUserInfo.toString());
        if (netUserInfo != null && netUserInfo.getData() != null) {
            UserBean data = netUserInfo.getData();
            if (data.getState() == 0 && data.getUserID().equals(getDeviceId())) {
                Toast.makeText(this, "掉线了", Toast.LENGTH_LONG).show();
                return;
            }
            if (data.getUserID().equals(friendBean.getUserID())) {
                if (data.getState() == 0) {
                    Toast.makeText(this, "好友已下线", Toast.LENGTH_LONG).show();
                } else if (data.getState() == 1) {
                    Toast.makeText(this, "好友上线了", Toast.LENGTH_LONG).show();
                    setTitle("与" + data.getUserName() + "会话");

                }
            }
        }
    }

    private void addMsgToList(NetMsgBean msg) {
        if (msg == null) {
            return;
        }
        netMsgBeanList.add(msg);
        msgListAdapter.notifyDataSetChanged();
        msg_lv.smoothScrollToPosition(netMsgBeanList.size() - 1);
    }

    private void addMsgToList(List<NetMsgBean> netMsgBeens) {
        if (netMsgBeens == null) {
            return;
        }
        netMsgBeanList.addAll(netMsgBeens);
        msgListAdapter.notifyDataSetChanged();
        msg_lv.smoothScrollToPosition(netMsgBeanList.size() - 1);
    }

    private class MsgListAdapter extends RecyclerView.Adapter<MyViewHolder> {

        private List<NetMsgBean> msgBeanList = new ArrayList<>();
        private LayoutInflater layoutInflater;

        public MsgListAdapter(List<NetMsgBean> msgBeanList) {
            this.msgBeanList = msgBeanList;
            if (layoutInflater == null) {
                layoutInflater = LayoutInflater.from(ChatActivity.this);
            }
        }

        @Override
        public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            if (layoutInflater != null) {
                View itemview = layoutInflater.inflate(R.layout.msg_itemview, parent, false);
                return new MyViewHolder(itemview);
            }
            return null;
        }

        @Override
        public void onBindViewHolder(MyViewHolder holder, int position) {
            NetMsgBean netMsgBean = msgBeanList.get(position);
            MsgBean data = netMsgBean.getData();
            if (data == null) {
                return;
            }
            UserBean sender = data.getSender();
            UserBean receiver = data.getReceiver();
            if (sender == null || receiver == null) {
                return;
            }
            if (sender.getUserID().equals(getDeviceId())) {
                //用户自己发送的消息
                holder.guest_view.setVisibility(View.GONE);
                holder.me_view.setVisibility(View.VISIBLE);
                holder.me_msg.setText(data.getBody());
            } else {
                //好友发送的消息
                holder.guest_view.setVisibility(View.VISIBLE);
                holder.me_view.setVisibility(View.GONE);
                holder.guest_msg.setText(data.getBody());
                holder.guest_name.setText(sender.getUserName());
            }
        }

        @Override
        public int getItemCount() {
            return msgBeanList.size();
        }
    }

    private class MyViewHolder extends RecyclerView.ViewHolder {
        LinearLayout guest_view;
        TextView guest_name;
        TextView guest_msg;
        //
        RelativeLayout me_view;
        TextView me_msg;

        public MyViewHolder(View itemView) {
            super(itemView);
            guest_view = (LinearLayout) itemView.findViewById(R.id.guest_view);
            guest_name = (TextView) itemView.findViewById(R.id.guest_name);
            guest_msg = (TextView) itemView.findViewById(R.id.guest_msg);
            me_view = (RelativeLayout) itemView.findViewById(R.id.me_view);
            me_msg = (TextView) itemView.findViewById(R.id.me_msg);
        }
    }

    public String getDeviceId() {
        TelephonyManager tm = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        return tm.getDeviceId();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK
                && event.getAction() == KeyEvent.ACTION_DOWN) {
            finish();
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "onDestroy");
        if (conn != null) {
            unbindService(conn);
            conn = null;
        }
        EventBus.getDefault().unregister(this);
    }
}
