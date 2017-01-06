package cn.com.wannian.testsocketim.activity;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import cn.com.wannian.testsocketim.bean.MsgBean;
import cn.com.wannian.testsocketim.MyApplication;
import cn.com.wannian.testsocketim.bean.NetMsgBean;
import de.greenrobot.event.EventBus;
import de.greenrobot.event.Subscribe;
import de.greenrobot.event.ThreadMode;

/**
 * Created by Wan.N
 * Date      :2017/1/6
 * Desc      :acitivity基类，暂时没用到
 */

public class BaseActivity extends AppCompatActivity {

    private static final String TAG = BaseActivity.class.getSimpleName();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EventBus.getDefault().register(this);
        Log.i(TAG, "onCreate");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void getFriendMsg(NetMsgBean netMsgBean) {
        Log.i(TAG, "getFriendMsg:" + netMsgBean.toString());
        MsgBean msgBean = netMsgBean.getData();
        //保存服务器发来的聊天数据
        Map<String, List<NetMsgBean>> msgMap = MyApplication.msgMap;
        if (msgMap.containsKey(msgBean.getSender().getUserID())) {
            List<NetMsgBean> netMsgBeens = msgMap.get(msgBean.getSender().getUserID());
            netMsgBeens.add(netMsgBean);
        } else {
            List<NetMsgBean> netMsgBeens = new ArrayList<>();
            netMsgBeens.add(netMsgBean);
            msgMap.put(msgBean.getSender().getUserID(), netMsgBeens);
        }
    }
}
