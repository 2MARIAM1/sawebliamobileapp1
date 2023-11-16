package model;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Data
public class SMSrequest {
    private String phoneNumber;
    private String message;
	public String getPhoneNumber() {
		return phoneNumber;
	}
	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public SMSrequest(String phoneNumber, String message) {
		super();
		this.phoneNumber = phoneNumber;
		this.message = message;
	}
	public SMSrequest() {

	}

    
    
}

