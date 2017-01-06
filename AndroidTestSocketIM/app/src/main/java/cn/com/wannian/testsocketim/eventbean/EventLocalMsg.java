package cn.com.wannian.testsocketim.eventbean;

import cn.com.wannian.testsocketim.bean.NetMsgBean;

/**
 * Created by Wan.N
 * Date      :2017/1/6
 * Desc      :${TODO}
 */

public class EventLocalMsg {
    private NetMsgBean netMsgBean;

    public EventLocalMsg() {
    }

    public NetMsgBean getNetMsgBean() {
        return netMsgBean;
    }

    public void setNetMsgBean(NetMsgBean netMsgBean) {
        this.netMsgBean = netMsgBean;
    }

    @Override
    public String toString() {
        return "EventLocalMsg{" +
                "netMsgBean=" + netMsgBean +
                '}';
    }
}
