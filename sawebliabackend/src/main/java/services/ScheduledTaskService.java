package services;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZonedDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.cloud.Date;
import com.google.firebase.messaging.FirebaseMessagingException;

import jakarta.transaction.Transactional;
import model.Artisan;
import model.Mission;
import model.NotificationMessage;
import repository.ArtisanRepository;
import repository.MissionRepository;

@Service
@Transactional
@Component
public class ScheduledTaskService {

	private final ArtisanService artisanService;
	private final FirebaseMessagingService firebaseMessagingService;
	private SMSservice smsservice;
	private final ArtisanRepository artisanRepository;
	private final MissionService missionService;
	private final MissionRepository missionRepository;
	private final FeedbackService feedbackService ;

	@Autowired
	public ScheduledTaskService(FirebaseMessagingService firebaseMessagingService, SMSservice smsservice,
			ArtisanService artisanService, ArtisanRepository artisanRepository, MissionService missionService,
			MissionRepository missionRepository,FeedbackService feedbackService) {
		this.artisanRepository = artisanRepository;
		this.artisanService = artisanService;
		this.firebaseMessagingService = firebaseMessagingService;
		this.smsservice = smsservice;
		this.missionService = missionService;
		this.missionRepository = missionRepository;
		this.feedbackService = feedbackService ;

	}

	@Scheduled(fixedRate = 60000)
	public void scheduledTasks() throws JsonMappingException, JsonProcessingException, ParseException, FirebaseMessagingException {

		HandleArtisans();
		HandleMissions();
		HandleArtisans();
		HandleMissions();

	}

	public void HandleArtisans() throws JsonMappingException, JsonProcessingException {
		List<Artisan> fetchedArtisans = artisanService.fetchartisanFromExternalAPI();
		List<Artisan> existingArtisans = artisanRepository.findAll(); // Fetch all existing Artisans from the database
		List<Artisan> artisansToSaveOrUpdate = new ArrayList<>();


		//DELETE THE DELETED RECORDS FROM AIRTABLE : 
		
		 List<Artisan> deletedArtisans = existingArtisans.stream()
	                .filter(existingArtisan -> fetchedArtisans.stream()
	                        .noneMatch(fetchedArtisan -> fetchedArtisan.getId_record().equals(existingArtisan.getId_record())))
	                .collect(Collectors.toList());
		 for (Artisan deletedArtisan : deletedArtisans) {
	            artisanRepository.delete(deletedArtisan);
	     }
		
		
		// CHECK IF THE ARTISAN ALREADY EXISTS
		for (Artisan fetchedArtisan : fetchedArtisans) {
			// Check if an Artisan with the same id record exists in the database
			Optional<Artisan> existingArtisanOptional = existingArtisans.stream()
					.filter(artisan -> (artisan.getId_record()).equals(fetchedArtisan.getId_record())).findFirst();
			// If an Artisan with the same id record exists, update the existing Artisan'
			if (existingArtisanOptional.isPresent()) {
				Artisan existingArtisan = existingArtisanOptional.get();
				// Update the fields of the existing Artisan with the data from the fetcheD
				// ARTISAN
				existingArtisan.setNomComplet(fetchedArtisan.getNomComplet());
				existingArtisan.setTel(fetchedArtisan.getTel());
				existingArtisan.setCin(fetchedArtisan.getCin());
				existingArtisan.setLogin(fetchedArtisan.getLogin());
				existingArtisan.setPassword(fetchedArtisan.getPassword());

				existingArtisan.setMissions(fetchedArtisan.getMissions());

				existingArtisan.setAdresse(fetchedArtisan.getAdresse());
				existingArtisan.setBlocked(fetchedArtisan.getBlocked());

				existingArtisan.setMetiers(fetchedArtisan.getMetiers());

				// Save the updated Artisan to the database
				artisansToSaveOrUpdate.add(existingArtisan);
			} else {
				// If an Artisan with the same id record does not exist, save the fetched
				// Artisan to the database
				artisansToSaveOrUpdate.add(fetchedArtisan);
			}
		}
		artisanRepository.saveAll(artisansToSaveOrUpdate);

	}

	public void HandleMissions() throws JsonMappingException, JsonProcessingException, ParseException, FirebaseMessagingException {

		List<Mission> fetchedMissions = missionService.fetchMissionsFromExternalAPI();

		List<Mission> existingMissions = missionRepository.findAll(); // Fetch all existing Missions from the database
		
		//DELETE THE DELETED RECORDS FROM AIRTABLE : 
		
		 List<Mission> deletedMissions = existingMissions.stream()
	                .filter(existingMission -> fetchedMissions.stream()
	                        .noneMatch(fetchedMission -> fetchedMission.getId_record().equals(existingMission.getId_record())))
	                .collect(Collectors.toList());
		 
		 for (Mission deletedMission : deletedMissions) {
		        feedbackService.deleteFeedbackByMission(deletedMission.getIdMission());
	            missionRepository.delete(deletedMission);
	        }
		
		

		for (Mission fetchedMission : fetchedMissions) {
			// System.out.println("DAAATEEE : " + fetchedMission.getDebutPrevu());

			// Check if a Mission with the same id record exists in the database
			String fetchedMissionIdRecord = fetchedMission.getId_record();
			if (fetchedMissionIdRecord != null) {

				Optional<Mission> existingMissionOptional = existingMissions.stream()
						.filter(mission -> mission.getId_record().equals(fetchedMission.getId_record())).findFirst();

				if (existingMissionOptional.isPresent()) {
					// If a Mission with the same id record exists, update the existing Mission's
					// data
					Mission existingMission = existingMissionOptional.get();
					// Update the fields of the existing Mission with the data from the fetched
					// Mission
					// System.out.println("existing DAAATEEE : " + existingMission.getDebutPrevu());
					existingMission.setTelClient(fetchedMission.getTelClient());
					existingMission.setNomClient(fetchedMission.getNomClient());
					existingMission.setDebutPrevu(fetchedMission.getDebutPrevu());

					existingMission.setStatutMission(fetchedMission.getStatutMission());
					existingMission.setTypeMission(fetchedMission.getTypeMission());

					existingMission.setEnvoyerNotif(fetchedMission.getEnvoyerNotif());
					existingMission.setAutoAffectation(fetchedMission.getAutoAffectation());

					existingMission.setArtisans(fetchedMission.getArtisans());
					existingMission.setMetier(fetchedMission.getMetier());
					existingMission.setQuartier(fetchedMission.getQuartier());
					existingMission.setAdresse(fetchedMission.getAdresse());
					existingMission.setLocalisation(fetchedMission.getLocalisation());
					existingMission.setLongitude(fetchedMission.getLongitude());
					existingMission.setLatitude(fetchedMission.getLatitude());
					existingMission.setPrixAAPayer(fetchedMission.getPrixAAPayer());
					existingMission.setPrixMaxFournitures(fetchedMission.getPrixMaxFournitures());
					existingMission.setDescription(fetchedMission.getDescription());
					existingMission.setMoyenPaiement(fetchedMission.getMoyenPaiement());
					existingMission.setPaiementCollecte(fetchedMission.getPaiementCollecte());

					// Save the updated Mission to the database
					missionRepository.save(existingMission);

				} else {
					// If a Mission with the same id record does not exist, save the fetched Mission
					// to the database
					missionRepository.save(fetchedMission);
				}

			} else {
				// Handle the case where the fetchedMission's id record is null
				System.out.println("Warning: Fetched Mission has a null id record.");
			}

		}

		// THIS PART IS FOR SENDING NOTIFICATIONS to the selected artisans

		for (Mission savedMission : existingMissions) {

			// SENDING AN SMS AN HOUR BEFORE MISSION STARTS
			if (!savedMission.isReminderSent() && "Programmée".equals(savedMission.getStatutMission())) {

				// ZoneId casablancaTimeZone = ZoneId.of("Africa/Casablanca");

				OffsetDateTime debutPrevu = savedMission.getDebutPrevu();
				OffsetDateTime currentDateTime = OffsetDateTime.now();

				String formattedDebutPrevu = debutPrevu.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
				String formattedCurrentTime = currentDateTime
						.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

				if (debutPrevu != null) {
					SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

					// long minutesDifference = ChronoUnit.MINUTES.between(currentDateTime,
					// debutPrevu.minusHours(1));
					java.util.Date date1 = dateFormat.parse(formattedCurrentTime);
					java.util.Date date2 = dateFormat.parse(formattedDebutPrevu);

					long timeDifferenceInMillis = date2.getTime() - date1.getTime();

					// Convert milliseconds to minutes
					long minutesDifference = timeDifferenceInMillis / (60 * 1000);

					for (Artisan artisan : savedMission.getArtisans()) {

						if (minutesDifference > 0 && minutesDifference <= 100) {
							if (artisan.getFcmToken() != null) {

								smsservice.sendSms(artisan.getTel(), String.format(
										"Salam %s, matnsach bli 3ndek khedma dyal %s lyouma m3a %s.",
										artisan.getNomComplet(),savedMission.getMetier(),
										savedMission.getDebutPrevu().format(DateTimeFormatter.ofPattern("HH:mm"))));
								// Set the flag to indicate that the SMS has been sent
								savedMission.setReminderSent(true);
							}
						}
					}
				}
			}
		}

		// HANDLING NOTIFICATIONS
		for (Mission savedMission : existingMissions) {

			if ("ON".equalsIgnoreCase(savedMission.getEnvoyerNotif()) && !savedMission.isNotificationSent()
					) {   
				System.out.println("ENVOYER NOTIF IS ON");

				// Iterate over all artisans associated with the mission
				for (Artisan artisan : savedMission.getArtisans()) {
					// Check if the artisan has an FCM token
					if (artisan.getFcmToken() != null) {
						// Send the notification to the artisan
						NotificationMessage notificationMessage = new NotificationMessage();
						notificationMessage.setTitle("Khedma dyalk");
						notificationMessage.setBody("Endek khedma jdida f "
								+ savedMission.getMetier() + " nhar "
								+ savedMission.getDebutPrevu().format(DateTimeFormatter.ofPattern("dd-MM-yyyy"))+" mea "+ savedMission.getDebutPrevu().format(DateTimeFormatter.ofPattern("HH:mm")));

						notificationMessage.setRecipientToken(artisan.getFcmToken());

						// Add any additional data you want to pass in the notification message
						Map<String, String> data = new HashMap<>();
						data.put("missionIdRecord", String.valueOf(savedMission.getId_record()));
						data.put("missionId", String.valueOf(savedMission.getIdMission()));
						notificationMessage.setData(data);

						// Send the notification
						String result = firebaseMessagingService.sendNotificationByToken(notificationMessage);
						savedMission.setNotificationSent(true);

						System.out.println("Notification Result for Artisan " + artisan.getIdArtisan() + ": " + result);

						// ENVOYER SMS
						String phoneNumber = artisan.getTel();
						String message = String.format("Salam %s, 3tawk khedma f %s nhar %s mea %s.",
								artisan.getNomComplet(),savedMission.getMetier(),
								savedMission.getDebutPrevu().format(DateTimeFormatter.ofPattern("dd-MM-yyyy")),savedMission.getDebutPrevu().format(DateTimeFormatter.ofPattern("HH:mm")));

						smsservice.sendSms(phoneNumber, message);

					} else {
						System.out.println("Could not find Artisan Token");
					}
				}
			}
		}
		for (Mission savedMission : existingMissions) {

			if ("ON".equalsIgnoreCase(savedMission.getAutoAffectation()) && !savedMission.isNotificationSent()
					&& "A Programmer".equals(savedMission.getStatutMission())) {
				// THIS PART IS FOR SENDING NOTIFICATIONS with AUTO AFFECTATION

				System.out.println("AUTO AFFECTATION IS ON");

				List<Artisan> existingArtisans = artisanRepository.findAll(); // Fetch all existing Artisans from the
																				// database

				// Iterate over all artisans associated with the mission
				for (Artisan artisan : existingArtisans) {
					System.out.println("////////////////// ARTISAN");

					// Check if any metier in the mission's metiers list exists in the artisan's
					// metiers list
					boolean isMetierMatchFound = false;
						if (artisan.getMetiers().stream().anyMatch(m -> m.equalsIgnoreCase(savedMission.getMetier()))) {
							isMetierMatchFound = true;
						}
					
					// Send the notification to the artisan
					if (isMetierMatchFound ) {
						// Check if the artisan has an FCM token
						if (artisan.getFcmToken() != null &&  artisan.getBlocked()==false) {

							NotificationMessage notificationMessage = new NotificationMessage();
							notificationMessage.setTitle("Khedma jdida");
							notificationMessage.setBody("Kayna khedma jdida katsennak f " + savedMission.getMetier()
									+ " nhar "
									+ savedMission.getDebutPrevu().format(DateTimeFormatter.ofPattern("dd-MM-yyyy")));
							notificationMessage.setRecipientToken(artisan.getFcmToken());

							// Add any additional data you want to pass in the notification message
							Map<String, String> data = new HashMap<>();
							data.put("missionIdRecord", String.valueOf(savedMission.getId_record()));
							data.put("missionId", String.valueOf(savedMission.getIdMission()));
							notificationMessage.setData(data);

							// Send the notification
							String result = firebaseMessagingService.sendNotificationByToken(notificationMessage);

							System.out.println("NOTIFICATION RESULT : " + result);
							savedMission.setNotificationSent(true);
							String phoneNumber = artisan.getTel();
							String message = String.format("Salam %s, Kayna khedma jdida f %s nhar %s.",
									artisan.getNomComplet(),savedMission.getMetier(),
									savedMission.getDebutPrevu().format(DateTimeFormatter.ofPattern("dd-MM-yyyy")));
							try {
								smsservice.sendSms(phoneNumber, message);
							} catch (Exception e) {
								e.printStackTrace();
							}

						} else {
							System.out.println("Could not find Artisan token");
						}
					} else {
						System.out.println("Could not find Metier match");
					}

				}

			}

		}

	}

}
