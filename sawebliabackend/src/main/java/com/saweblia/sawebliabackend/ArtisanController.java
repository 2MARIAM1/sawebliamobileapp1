package com.saweblia.sawebliabackend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import model.Artisan;
import model.Mission;
import services.ArtisanService;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/artisans")
public class ArtisanController {
    private final ArtisanService artisanService;

    @Autowired
    public ArtisanController(ArtisanService artisanService) {
        this.artisanService = artisanService;
    }

    @GetMapping("/all")
    public ResponseEntity<List<Artisan>> getAllArtisans() {
        List<Artisan> artisans = artisanService.getAllArtisans();
        return new ResponseEntity<>(artisans, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Artisan> getArtisanById(@PathVariable("id") Long id) {
        Optional<Artisan> artisan = artisanService.getArtisanById(id);
        return artisan.map(value -> new ResponseEntity<>(value, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    
    @GetMapping("/{artisanId}/missions/count")
    public ResponseEntity<Integer> getNumberOfMissionsForArtisan(@PathVariable Long artisanId) {
        Optional<Artisan> artisanOptional = artisanService.getArtisanById(artisanId);
        
        if (artisanOptional.isPresent()) {
            Artisan artisan = artisanOptional.get();
            int numberOfMissions = artisanService.getNumberOfMissionsForArtisan(artisan);
            return ResponseEntity.ok(numberOfMissions);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/{artisanId}/missions")
    public ResponseEntity<List<Mission>> getArtisanMissions(@PathVariable Long artisanId) {
        Optional<Artisan> artisanOptional = artisanService.getArtisanById(artisanId);
        
        if (artisanOptional.isPresent()) {
            Artisan artisan = artisanOptional.get();
            List<Mission> missions = artisan.getMissions();
            return ResponseEntity.ok(missions);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    
    @GetMapping("/{artisanId}/newAvailableMissions")
    public ResponseEntity<List<Mission>> getNewAvailableMissions(@PathVariable Long artisanId){
    	
        Optional<Artisan> artisanOptional = artisanService.getArtisanById(artisanId);
        if (artisanOptional.isPresent()) {

         List<Mission> missions = artisanService.getNewAvailableMissions(artisanId) ;
         return ResponseEntity.ok(missions);

        }
        else 
        {
            return ResponseEntity.notFound().build();

        	
        }
    }


    @PostMapping("/add")
    public ResponseEntity<Artisan> createArtisan(@RequestBody Artisan artisan) {
        Artisan createdArtisan = artisanService.createArtisan(artisan);
        return new ResponseEntity<>(createdArtisan, HttpStatus.CREATED);
    }
    
    @PutMapping("/updatefcmtoken/{id}")
    public ResponseEntity<Artisan> updateFcmToken(@PathVariable Long id, @RequestBody Artisan artisan) {
    	Artisan updatedArtisan = artisanService.updatefcmtoken(id, artisan);
    	return updatedArtisan != null
                ? new ResponseEntity<>(updatedArtisan, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);

    }
    
    @PutMapping("/updateLastLogin/{id}")
    public ResponseEntity<Artisan> updateLastLogin(@PathVariable Long id, @RequestBody Artisan artisan) {
    	Artisan updatedArtisan = artisanService.updateLastLogin(id, artisan);
    	return updatedArtisan != null
                ? new ResponseEntity<>(updatedArtisan, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);

    }
    
    @PutMapping("/updateLocation/{id}")
    public ResponseEntity<Artisan> updateLocation(@PathVariable Long id, @RequestBody Artisan artisan) {
    	Artisan updatedArtisan = artisanService.updateLocationArtisan(id, artisan);
    	return updatedArtisan != null
                ? new ResponseEntity<>(updatedArtisan, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);

    }
    
    @PutMapping("/addToBonus/{id}")
    public ResponseEntity<Artisan> addToBonus(@PathVariable Long id, @RequestBody Artisan artisan) {
    	Artisan updatedArtisan = artisanService.addToBonus(id, artisan);
    	return updatedArtisan != null
                ? new ResponseEntity<>(updatedArtisan, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);

    }
   

    @PutMapping("/update/{id}")
    public ResponseEntity<Artisan> updateArtisan(@PathVariable("id") Long id, @RequestBody Artisan artisan) {
        Artisan updatedArtisan = artisanService.updateArtisan(id, artisan);
        return updatedArtisan != null
                ? new ResponseEntity<>(updatedArtisan, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
    
    

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> deleteArtisan(@PathVariable("id") Long id) {
        artisanService.deleteArtisan(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
