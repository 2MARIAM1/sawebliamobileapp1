package services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;
import model.Artisan;
import model.FeedbackArtisan;
import model.Mission;
import repository.FeedbackRepository;
import repository.MissionRepository;

@Service
@Transactional
@Component

public class FeedbackService {
	private final FeedbackRepository feedbackRepository ;
	private final MissionRepository missionRepository ;
	@Autowired
	public FeedbackService(FeedbackRepository feedbackRepository,MissionRepository missionRepository) {
		this.feedbackRepository = feedbackRepository ;
		this.missionRepository = missionRepository ;
	
	}
	

	public List<FeedbackArtisan> getAllFeedbacks() {
		return feedbackRepository.findAll();
	}

	public Optional<FeedbackArtisan> getFeedbackById(Long id) {
		return feedbackRepository.findById(id);
	}
	
	public FeedbackArtisan createFeedback(FeedbackArtisan feedback) {
		return feedbackRepository.save(feedback);
	}
	
	public void deleteFeedbackByMission(Long idMission) {
	    Optional<Mission> myMission = missionRepository.findById(idMission);

	    if (myMission.isPresent()) {
	        List<FeedbackArtisan> myfeedbacks = feedbackRepository.findAll();

	        for (FeedbackArtisan feedback : myfeedbacks) {
	            if (feedback.getMission() != null && feedback.getMission().getIdMission().equals(idMission)) {
	                feedbackRepository.delete(feedback);
	            }
	        }
	    }
	}



}
