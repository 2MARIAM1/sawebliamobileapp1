package model;

import java.util.Map;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Data
public class NotificationMessage {
	private String recipientToken;
	private String title;
	private String body;
	private Map<String,String> data;
	
	public String getRecipientToken() {
		return recipientToken;
	}
	public void setRecipientToken(String recipientToken) {
		this.recipientToken = recipientToken;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getBody() {
		return body;
	}
	public void setBody(String body) {
		this.body = body;
	}
	public Map<String, String> getData() {
		return data;
	}
	public void setData(Map<String, String> data) {
		this.data = data;
	}
	
	public NotificationMessage() {}
	public NotificationMessage(String recipientToken, String title, String body, Map<String, String> data) {
		super();
		this.recipientToken = recipientToken;
		this.title = title;
		this.body = body;
		this.data = data;
	}
	
	
	


}
