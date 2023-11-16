package repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import model.FeedbackArtisan;

@Repository
public interface FeedbackRepository extends JpaRepository<FeedbackArtisan, Long>{
	
	
}
