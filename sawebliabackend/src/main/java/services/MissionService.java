package services;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.context.annotation.Lazy;
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessaging;
import com.saweblia.sawebliabackend.Globalskeys;

import jakarta.transaction.Transactional;
import model.Artisan;


import model.GoogleMapsUtils;
import model.Mission;
import repository.ArtisanRepository;
import repository.MissionRepository;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
@Component
public class MissionService {
	private final MissionRepository missionRepository;

	// @Lazy
	// private final ArtisanService artisanService ;
	private final ArtisanRepository artisanRepository;

	private final String API_URL = String.format("%s/%s/Missions App Mobile", Globalskeys.getAPI_URL(), Globalskeys.getAPI_ID());
	private final String API_KEY = Globalskeys.getAPI_KEY();

	private final RestTemplate restTemplate;
	private final ObjectMapper objectMapper;

	@Autowired
	public MissionService(MissionRepository missionRepository, ArtisanRepository artisanRepository,
		 RestTemplate restTemplate,
			ObjectMapper objectMapper) {
		this.missionRepository = missionRepository;
		// this.artisanService= artisanService;

		this.artisanRepository = artisanRepository;
		this.restTemplate = restTemplate;
		this.objectMapper = objectMapper;

	}

	public List<Mission> getAllMissions() {
		return missionRepository.findAll();
	}

	public Optional<Mission> getMissionById(Long id) {
		return missionRepository.findById(id);
	}

	public Optional<Mission> getMissionByRecordId(String idRecord) {
		return missionRepository.findMissionByRecordId(idRecord);
	}

	public Mission saveMission(Mission mission) {
		return missionRepository.save(mission);
	}

	public void deleteMission(Long id) {
		missionRepository.deleteById(id);
	}

	 public void assignMissionToArtisan(Mission mission, Artisan artisan) {
	        List<Artisan> existingArtisans = mission.getArtisans();
	        if (!existingArtisans.contains(artisan)) {
	            existingArtisans.add(artisan);
	            mission.setArtisans(existingArtisans);
	            saveMission(mission);

	         // Update the inverse side of the relationship
	            artisan.getMissions().add(mission);
	            artisanRepository.save(artisan);
	            // Update the ArtisansTest field in Airtable
	       //     List<String> artisanIds = existingArtisans.stream()
	        //            .map(Artisan::getId_record)
	         //           .collect(Collectors.toList());

	          //  updateArtisansInMissionRecord(mission.getId_record(), artisanIds);
	        }
	    }	
	
	
	
	/*
	 * 
	 * public void assignMissionToArtisan(Long idMission, Long idArtisan) {
		Optional<Artisan> artisanOptional = artisanRepository.findById(idArtisan);
	    Optional<Mission> missionOptional = missionRepository.findById(idMission);

	    if (artisanOptional.isPresent() && missionOptional.isPresent()) {
	        Artisan artisan = artisanOptional.get();
	        Mission mission = missionOptional.get();

	        mission.getArtisans().add(artisan);
	        missionRepository.save(mission);
	    } 
	   
	}*/
	
	

	public List<Mission> getMissionsByArtisanId(Long artisanId) {
		Artisan artisan = artisanRepository.findById(artisanId).orElse(null);
		if (artisan == null) {
			return Collections.emptyList();
		}

		return missionRepository.findByArtisansIdArtisan(artisan.getIdArtisan());
	}

	public Mission updateMissionStatus(Long missionId, Mission updatedMission) {
		Mission existingMission = missionRepository.findById(missionId).orElse(null);
		if (existingMission != null) {
			existingMission.setStatutMission(updatedMission.getStatutMission());
			// updatedMission.setBlocked(updatedMission.getBlocked() != null ?
			// updatedArtisan.getBlocked() : false);
			return missionRepository.save(existingMission);
		}

		return null;
	}

	
	public Mission updategiveBonus(Long missionId, Mission updatedMission) {
		Mission existingMission = missionRepository.findById(missionId).orElse(null);
		if (existingMission != null) {
			existingMission.setGiveBonus(updatedMission.getGiveBonus());
			// updatedMission.setBlocked(updatedMission.getBlocked() != null ?
			// updatedArtisan.getBlocked() : false);
			return missionRepository.save(existingMission);
		}

		return null;
	}
	public Mission saveDebutReel(Long missionId, Mission updatedMission) {
		Mission existingMission = missionRepository.findById(missionId).orElse(null);
		if (existingMission != null) {
			existingMission.setDebutReel(updatedMission.getDebutReel());
			// updatedMission.setBlocked(updatedMission.getBlocked() != null ?
			// updatedArtisan.getBlocked() : false);
			return missionRepository.save(existingMission);
		}

		return null;
	}
	
	
	
	public List<Mission> fetchMissionsFromExternalAPI() throws JsonMappingException, JsonProcessingException {
		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "Bearer " + API_KEY);
		headers.setContentType(MediaType.APPLICATION_JSON);

		HttpEntity<String> entity = new HttpEntity<>(headers);

		ResponseEntity<String> response = restTemplate.exchange(API_URL, HttpMethod.GET, entity, String.class);
		String jsonResponse = response.getBody();

		// Parse the JSON response using Jackson's ObjectMapper
		JsonNode root = objectMapper.readTree(jsonResponse);
		JsonNode records = root.get("records");

		// Extract the relevant data from the JSON and create a list of Mission objects
		List<Mission> missions = new ArrayList<>();
		for (JsonNode record : records) {
			String id = record.get("id").asText();
			JsonNode fields = record.get("fields");

			Mission mission = new Mission();
			mission.setId_record(id);
			
			
			String telclient = fields.has("Tél") ? fields.get("Tél").asText() : null;
			mission.setTelClient(telclient);
		//String telclient = fields.has("Tél") ? fields.get("Tél").asText().replaceAll("[^\\d]", "") : null;
		//	System.out.println("tel clieent : " + telclient);
			
			
			DateTimeFormatter formatter = DateTimeFormatter.ISO_OFFSET_DATE_TIME;
			String dateTimeStr = fields.has("Date/heure de l'intervention")
					? fields.get("Date/heure de l'intervention").asText()
					: null;
			
			if (dateTimeStr != null) {
			    OffsetDateTime dateTime = OffsetDateTime.parse(dateTimeStr, formatter);
			    mission.setDebutPrevu(dateTime);
			} else {
              System.out.print("Datetime is null");			}
			//	System.out.println("dateTimeStr " + dateTimeStr);
			
			

			String nomclient = fields.has("Nom/prénom client") ? fields.get("Nom/prénom client").asText() : null;
			mission.setNomClient(nomclient);
			String description = fields.has("Description") ? fields.get("Description").asText() : null;
			mission.setDescription(description);
			
			String moyenPaiement = fields.has("Mode paiement") ? fields.get("Mode paiement").asText() : null;
			mission.setMoyenPaiement(moyenPaiement);

			String typeMission = fields.has("Type d'intervention") ? fields.get("Type d'intervention").asText() : null;
			mission.setTypeMission(typeMission);

			String statutMission = fields.has("Statut de l'intervention")
					? fields.get("Statut de l'intervention").asText()
					: null;
			mission.setStatutMission(statutMission);
			
			mission.setPrixAAPayer(fields.has("Montant") ? fields.get("Montant").asDouble()
							: null);
			mission.setPrixMaxFournitures(fields.has("Fourniture") ? fields.get("Fourniture").asDouble()
					: null);
			mission.setPaiementCollecte(
					  fields.has("Paiement collecté") ? fields.get("Paiement collecté").asBoolean() : false
					);


			
		/*	List<String> metiersList = new ArrayList<>();
			JsonNode metiersNode = fields.get("Métiers concernés");
			if (metiersNode != null && metiersNode.isArray()) {
				for (JsonNode metier : metiersNode) {
					metiersList.add(metier.asText());
				}
			}*/
			mission.setMetier(fields.has("Métier concerné") ? fields.get("Métier concerné").asText() : null);
			
			
			mission.setQuartier(fields.has("Quartier") ? fields.get("Quartier").asText()
					: null);
			mission.setAdresse(fields.has("Adresse") ? fields.get("Adresse").asText()
					: null);
			
		    String location = fields.has("localisation") ? fields.get("localisation").asText() : null;

			mission.setLocalisation(location);
			
			if (location != null) {
		        GoogleMapsUtils.Coordinates coordinates = GoogleMapsUtils.extractCoordinatesFromGoogleMapsLink(location);

		        mission.setLatitude(coordinates.getLatitude());
		        mission.setLongitude(coordinates.getLongitude());
		   
		    }
			
			
			//mission.setLongitude(fields.has("longitude") ? fields.get("longitude").asDouble()
		//			: null);
		//	mission.setLatitude(fields.has("latitude") ? fields.get("latitude").asDouble()
		//			: null);
			String envoyerNotif = fields.has("Affectation manuelle") ? fields.get("Affectation manuelle").asText()
					: null;
			mission.setEnvoyerNotif(envoyerNotif);
			

			String autoAffectation = fields.has("Auto Affectation") ? fields.get("Auto Affectation").asText() : null;
			mission.setAutoAffectation(autoAffectation);


			// Process the list of ARTISANS associated with the Mission
			List<Artisan> missionArtisans = new ArrayList<>();
			JsonNode artisansNode = fields.get("Artisans");
			if (artisansNode != null && artisansNode.isArray()) {
				for (JsonNode artisanIdNode : artisansNode) {
					String artisanRecordId = artisanIdNode.asText();
					Optional<Artisan> artisanOptional = artisanRepository.findArtisanByRecordId(artisanRecordId);
					if (artisanOptional.isPresent()) {
						Artisan artisan = artisanOptional.get();
						
						missionArtisans.add(artisan);

					} else {
						System.out.println("Artisan not found");
					}
				}
			}
			mission.setArtisans(missionArtisans);
			missions.add(mission);


			// FOURNISSEUR
			/*JsonNode fournisseursNode = fields.get("FournisseursTest");
			if (fournisseursNode != null && fournisseursNode.isArray() && fournisseursNode.size() > 0) {
				// Get the first fournisseur record ID from the list
				String fournisseurRecordId = fournisseursNode.get(0).asText();
				Optional<Fournisseur> fournisseurOptional = fournisseurRepository
						.findFournisseurByRecordId(fournisseurRecordId);
			//	System.out.println("OPTIONAL FOURNISSEUR : " + fournisseurOptional);
				if (fournisseurOptional.isPresent()) {
					Fournisseur fournisseur = fournisseurOptional.get();
					mission.setFournisseur(fournisseur);
				//	System.out.println("FOURNISSEUR SET TO MISSION : " + fournisseur.getId_record() + "  "+fournisseur.getTel());
				//	System.out.println("MISSION FR  : " + mission.getFournisseur());

				} else {
					System.out.println("Fournisseur not found");
				}
			} else {
				System.out.println("No Fournisseurs found for the mission");
			}*/
			// Add the processed Mission to the list

		}

		return missions;
	}


}


