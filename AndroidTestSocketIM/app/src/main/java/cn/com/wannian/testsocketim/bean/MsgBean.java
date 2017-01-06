package cn.com.wannian.testsocketim.bean;

/**
 * Created by Wan.N
 * Date      :2017/1/3
 * Desc      :${TODO}
 */

public class MsgBean {
    private String body;
    private UserBean sender;
    private int msgState;
    private long msgTime;
    private UserBean receiver;

    public MsgBean() {
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }

    public UserBean getSender() {
        return sender;
    }

    public void setSender(UserBean sender) {
        this.sender = sender;
    }

    public int getMsgState() {
        return msgState;
    }

    public void setMsgState(int msgState) {
        this.msgState = msgState;
    }

    public long getMsgTime() {
        return msgTime;
    }

    public void setMsgTime(long msgTime) {
        this.msgTime = msgTime;
    }

    public UserBean getReceiver() {
        return receiver;
    }

    public void setReceiver(UserBean receiver) {
        this.receiver = receiver;
    }

    @Override
    public String toString() {
        return "MsgBean{" +
                "body='" + body + '\'' +
                ", sender=" + sender +
                ", msgState='" + msgState + '\'' +
                ", msgTime='" + msgTime + '\'' +
                ", receiver=" + receiver +
                '}';
    }
}
