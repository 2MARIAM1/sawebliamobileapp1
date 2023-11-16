package repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import model.Mission;

@Repository
public interface MissionRepository extends JpaRepository<Mission, Long>{
    List<Mission> findByArtisansIdArtisan(Long IdArtisan);
    @Query("SELECT m FROM Mission m WHERE m.id_record = :idRecord")
    Optional<Mission> findMissionByRecordId(String idRecord);


}
 