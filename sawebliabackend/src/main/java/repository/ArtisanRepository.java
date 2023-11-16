package repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import model.Artisan;
import model.Mission;

@Repository
public interface ArtisanRepository extends JpaRepository<Artisan, Long>{
	@Query("SELECT a FROM Artisan a WHERE a.id_record = :idRecord")
    Optional<Artisan> findArtisanByRecordId(String idRecord);
}
