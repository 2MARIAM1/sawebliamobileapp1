package services;

import java.io.IOException;
import java.io.InputStream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;

import jakarta.transaction.Transactional;
import model.NotificationMessage;

@Service
@Transactional
@Component
public class FirebaseMessagingService {

    private final FirebaseMessaging firebaseMessaging;

    @Autowired
    public FirebaseMessagingService() {
        this.firebaseMessaging = initializeFirebaseMessaging();
    }

    private FirebaseMessaging initializeFirebaseMessaging() {
        try {
            InputStream serviceAccount = new ClassPathResource("saweblia-mobile-app-firebase-adminsdk.json")
                    .getInputStream();

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            FirebaseApp.initializeApp(options);

            return FirebaseMessaging.getInstance();
        } catch (IOException e) {
            throw new RuntimeException("Error initializing Firebase Messaging", e);
        }
    }

    public String sendNotificationByToken(NotificationMessage notificationMessage) {
        Notification notification = Notification.builder()
                .setTitle(notificationMessage.getTitle())
                .setBody(notificationMessage.getBody())
              
                .build();
        Message message = Message.builder()
                .setToken(notificationMessage.getRecipientToken())
                .setNotification(notification)
                .putAllData(notificationMessage.getData())
             
                .build();

        try {
            firebaseMessaging.send(message);
            return "Success sending notification";
        } catch (Exception e) {
            e.printStackTrace();
            return "Error sending notification";
        }
    }
}
