package com.saweblia.sawebliabackend;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import model.SMSrequest;
import services.SMSservice;

@RestController
public class SMScontroller {

    private final SMSservice smsService;

    public SMScontroller(SMSservice smsService) {
        this.smsService = smsService;
    }

    @PostMapping("/send-sms")
    public ResponseEntity<String> sendSms(@RequestBody SMSrequest smsRequest) {
        String phoneNumber = smsRequest.getPhoneNumber();
        String message = smsRequest.getMessage();

        // Send the SMS using the SmsService
        smsService.sendSms(phoneNumber, message);

        return ResponseEntity.ok("SMS sent successfully");
    }
}
