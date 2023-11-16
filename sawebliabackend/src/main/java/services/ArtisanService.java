package services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.saweblia.sawebliabackend.Globalskeys;

import jakarta.transaction.Transactional;
import model.Artisan;
import model.Mission;
import repository.ArtisanRepository;
import repository.MissionRepository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
@Component

public class ArtisanService {
	private final ArtisanRepository artisanRepository;
	private final MissionRepository missionRepository;
	private final String API_URL = String.format("%s/%s/Artisans App Mobile", Globalskeys.getAPI_URL(),
			Globalskeys.getAPI_ID());
	private final String API_KEY = Globalskeys.getAPI_KEY();

	private final RestTemplate restTemplate;
	private final ObjectMapper objectMapper;

	@Autowired
	public ArtisanService(ArtisanRepository artisanRepository, MissionRepository missionRepository,
			RestTemplate restTemplate, ObjectMapper objectMapper) {
		this.restTemplate = restTemplate;
		this.missionRepository = missionRepository;
		this.objectMapper = objectMapper;
		this.artisanRepository = artisanRepository;
	}

	public List<Artisan> getAllArtisans() {
		return artisanRepository.findAll();
	}

	public Optional<Artisan> getArtisanById(Long id) {
		return artisanRepository.findById(id);
	}

	public Optional<Artisan> getArtisanByRecordId(String idRecord) {
		return artisanRepository.findArtisanByRecordId(idRecord);
	}

	public int getNumberOfMissionsForArtisan(Artisan artisan) {
		
		List<Mission> missionsActuelles = new ArrayList<>();
		List<Mission> allMissions =  artisan.getMissions();
		
		for(Mission mission : allMissions) {
			if("Programmée".equalsIgnoreCase(mission.getStatutMission()) || "En Cours".equalsIgnoreCase(mission.getStatutMission()) ) {
				missionsActuelles.add(mission);
			}
		}
		
		return missionsActuelles.size(); 
	}

	public List<Mission> getNewAvailableMissions(Long idArtisan) {

		Artisan artisan = artisanRepository.findById(idArtisan).orElse(null);
		List<Mission> myMissions = missionRepository.findAll();
		List<Mission> newMissions = new ArrayList<>();

		for (Mission mission : myMissions) {
			if ("A Programmer".equals(mission.getStatutMission())
					&& ("ON".equalsIgnoreCase(mission.getAutoAffectation()))) {

				boolean isMetierMatchFound = false;
				
					if (artisan.getMetiers().stream().anyMatch(m -> m.equalsIgnoreCase(mission.getMetier()))) {
						isMetierMatchFound = true;
					}
				
				if (isMetierMatchFound) {
					newMissions.add(mission);
				}

			}
			
			}

		
		System.out.println("NEW AVAILABLE MISSIONS : " + newMissions.toString());
		return newMissions;
	}

	public Artisan createArtisan(Artisan artisan) {
		return artisanRepository.save(artisan);
	}

	public Artisan addToBonus(Long idArtisan, Artisan updatedArtisan) {
		Artisan existingArtisan = artisanRepository.findById(idArtisan).orElse(null);
		if (existingArtisan != null) {
			if (existingArtisan.getTotalBonus() == null) {
				existingArtisan.setTotalBonus(0.0);
			}
			Double newBonus = updatedArtisan.getTotalBonus() + existingArtisan.getTotalBonus();
			existingArtisan.setTotalBonus(newBonus);
			return artisanRepository.save(existingArtisan);
		}
		return null;

	}

	public Artisan updateArtisan(Long idArtisan, Artisan updatedArtisan) {
		Artisan existingArtisan = artisanRepository.findById(idArtisan).orElse(null);
		if (existingArtisan != null) {
			return artisanRepository.save(existingArtisan);
		}
		return null;
	}

	public Artisan updatefcmtoken(Long idArtisan, Artisan updatedArtisan) {
		Artisan existingArtisan = artisanRepository.findById(idArtisan).orElse(null);
		if (existingArtisan != null) {
			existingArtisan.setFcmToken(updatedArtisan.getFcmToken());
			// updatedArtisan.setBlocked(updatedArtisan.getBlocked() != null ?
			// updatedArtisan.getBlocked() : false);
			return artisanRepository.save(existingArtisan);
		}

		return null;
	}

	public Artisan updateLastLogin(Long idArtisan, Artisan updatedArtisan) {
		Artisan existingArtisan = artisanRepository.findById(idArtisan).orElse(null);
		if (existingArtisan != null) {
			existingArtisan.setLastLogin(LocalDateTime.now());
			// updatedArtisan.setBlocked(updatedArtisan.getBlocked() != null ?
			// updatedArtisan.getBlocked() : false);
			return artisanRepository.save(existingArtisan);
		}

		return null;
	}

	public Artisan updateLocationArtisan(Long idArtisan, Artisan updatedArtisan) {
		Artisan existingArtisan = artisanRepository.findById(idArtisan).orElse(null);
		if (existingArtisan != null) {
			existingArtisan.setLongitude(updatedArtisan.getLongitude());
			existingArtisan.setLatitude(updatedArtisan.getLatitude());
			existingArtisan.setAdresse(updatedArtisan.getAdresse());
			// updatedArtisan.setBlocked(updatedArtisan.getBlocked() != null ?
			// updatedArtisan.getBlocked() : false);
			return artisanRepository.save(existingArtisan);
		}

		return null;
	}

	public void deleteArtisan(Long id) {
		artisanRepository.deleteById(id);
	}

	public List<Artisan> fetchartisanFromExternalAPI() throws JsonMappingException, JsonProcessingException {
		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "Bearer " + API_KEY);
		headers.setContentType(MediaType.APPLICATION_JSON);

		HttpEntity<String> entity = new HttpEntity<>(headers);

		ResponseEntity<String> response = restTemplate.exchange(API_URL, HttpMethod.GET, entity, String.class);
		String jsonResponse = response.getBody();

		// Parse the JSON response using Jackson's ObjectMapper
		JsonNode root = objectMapper.readTree(jsonResponse);
		JsonNode records = root.get("records");

		// Extract the relevant data from the JSON and create a list of DataModel
		// objects
		List<Artisan> artisans = new ArrayList<>();
		for (JsonNode record : records) {
			String id = record.get("id").asText();
			JsonNode fields = record.get("fields");

			Artisan artisan = new Artisan();
			artisan.setId_record(id);
			artisan.setNomComplet(fields.has("Artisan") ? fields.get("Artisan").asText() : null);

			artisan.setTel(
					fields.has("N° Téléphone") ? fields.get("N° Téléphone").asText().replaceAll("[() -]", "") : null);

			artisan.setCin(fields.has("N° C.I.N.") ? fields.get("N° C.I.N.").asText() : null);
			artisan.setLogin(fields.has("login") ? fields.get("login").asText() : null);
			artisan.setPassword(fields.has("password") ? fields.get("password").asText() : null);
		
			artisan.setBlocked(fields.has("Block") ? fields.get("Block").asBoolean() : false); 
			// artisan.setLongitude(fields.has("longitude") ?
			// fields.get("longitude").asDouble() : null);
			// artisan.setLatitude(fields.has("latitude") ?
			// fields.get("latitude").asDouble() : null);
			// artisan.setAdresse(fields.has("Adresse") ? fields.get("Adresse").asText() :
			// null);
			// artisan.setLocalisation(fields.has("Localisation") ?
			// fields.get("Localisation").asText() : null);

			List<String> metiersList = new ArrayList<>();
			JsonNode metiersNode = fields.get("Métier");
			if (metiersNode != null && metiersNode.isArray()) {
				for (JsonNode metier : metiersNode) {
					metiersList.add(metier.asText());
				}
			}
			artisan.setMetiers(metiersList);

			List<Mission> artisanMissions = new ArrayList<>();
			JsonNode missionsNode = fields.get("Missions App Mobile");
			if (missionsNode != null && missionsNode.isArray()) {
				for (JsonNode missionIdNode : missionsNode) {
					String missionRecordId = missionIdNode.asText();
					Optional<Mission> missionOptional = missionRepository.findMissionByRecordId(missionRecordId);
					if (missionOptional.isPresent()) {
						Mission mission = missionOptional.get();
						artisanMissions.add(mission);

					} else {
						System.out.println("Mission not found");
					}
				}
			}
			artisan.setMissions(artisanMissions);

			artisans.add(artisan);
		}

		return artisans;
	}
}
