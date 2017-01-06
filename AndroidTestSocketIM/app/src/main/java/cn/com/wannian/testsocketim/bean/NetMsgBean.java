package cn.com.wannian.testsocketim.bean;

/**
 * Created by Wan.N
 * Date      :2017/1/3
 * Desc      :${TODO}
 */

public class NetMsgBean extends NetBaseBean {
    private MsgBean data;

    public NetMsgBean() {
    }

    public MsgBean getData() {
        return data;
    }

    public void setData(MsgBean data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "NetMsgBean{" +
                "data=" + data +
                '}';
    }
}
