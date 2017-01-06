package cn.com.wannian.testsocketim.bean;

/**
 * Created by Wan.N
 * Date      :2017/1/3
 * Desc      :${TODO}
 */

public class NetUserInfo extends NetBaseBean {
    private UserBean data;

    public NetUserInfo() {
    }

    public UserBean getData() {
        return data;
    }

    public void setData(UserBean data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "NetUserInfo{" +
                "data=" + data +
                '}';
    }
}
