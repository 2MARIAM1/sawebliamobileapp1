package services;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;

@Component
@Transactional
@Service
public class SMSservice {

    public void sendSms(String phoneNumber, String message) {
        String url = "your_inwi_business_sms_url";
        String codeClient = "your_inwi_business_codeclient";
        String login = "";
        String password = "";
        String from = "SAWEBLIA";

        // Build the request body
        String requestBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:push=\"http://push.inwi.ma/\">"
                + "<soapenv:Header/><soapenv:Body><push:send><sms><codeClient>" + codeClient + "</codeClient><login>"
                + login + "</login><password>" + password + "</password><from>" + from + "</from><to>" + phoneNumber
                + "</to><message>" + message + "</message></sms></push:send></soapenv:Body></soapenv:Envelope>";

        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpPost httpPost = new HttpPost(url);
            httpPost.addHeader("Content-Type", "text/xml");
            httpPost.setEntity(new StringEntity(requestBody));

            HttpResponse response = httpClient.execute(httpPost);

            // Handle the response here (optional)
            // You can check the status code and process the response accordingly

        } catch (Exception e) {
            e.printStackTrace();
            // Handle exceptions
        }
    }
}
