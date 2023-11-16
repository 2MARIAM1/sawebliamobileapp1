package com.saweblia.sawebliabackend;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


import model.NotificationMessage;
import services.FirebaseMessagingService;



@RestController
@RequestMapping("/notifications")
public class NotificationController {
	
	@Autowired
	FirebaseMessagingService firebaseMessagingService;
	

    @PostMapping("/send_notification")
    public String sendNotificationByToken(@RequestBody NotificationMessage notificationMessage) {
    	       return firebaseMessagingService.sendNotificationByToken(notificationMessage);
    	    }
    	
}

