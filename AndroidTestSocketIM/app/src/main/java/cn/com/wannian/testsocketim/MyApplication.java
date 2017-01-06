package cn.com.wannian.testsocketim;

import android.app.Application;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.com.wannian.testsocketim.bean.NetMsgBean;
import cn.com.wannian.testsocketim.bean.UserBean;

/**
 * Created by Wan.N
 * Date      :2017/1/5
 * Desc      :${TODO}
 */

public class MyApplication extends Application {
    public static UserBean userBean = new UserBean();//存放用户信息
    public static Map<String, List<NetMsgBean>> msgMap = new HashMap<>();//存放聊天数据,<好友id，与好友聊天的数据>
}
