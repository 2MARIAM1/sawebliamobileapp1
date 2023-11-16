package com.saweblia.sawebliabackend;


import org.springframework.beans.factory.annotation.Autowired;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import model.Artisan;
import model.Mission;
import repository.ArtisanRepository;
import services.ArtisanService;
import services.MissionService;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/missions")
public class MissionController {
    private final MissionService missionService;
    private final ArtisanService artisanService;
    private final ArtisanRepository artisanRepository;

    @Autowired
    public MissionController(MissionService missionService, ArtisanService artisanService,ArtisanRepository artisanRepository  ) {
        this.missionService = missionService;
        this.artisanService = artisanService;
        this.artisanRepository = artisanRepository;
    }
    
    //@CrossOrigin(origins = "http://localhost:4200")
    @GetMapping("/all")
    public ResponseEntity<List<Mission>> getAllMissions() {
        List<Mission> missions = missionService.getAllMissions();
        return new ResponseEntity<>(missions, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Mission> getMissionById(@PathVariable Long id) {
        Optional<Mission> mission = missionService.getMissionById(id);
        return mission.map(value -> new ResponseEntity<>(value, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    
    @PostMapping("/add")
    public ResponseEntity<Mission> createMission(@RequestBody Mission mission) {
        // Check if the client field is present
       /* if (mission.getClient() != null) {
            Optional<Client> client = clientService.getClientById(mission.getClient().getIdClient());
            if (!client.isPresent()) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            mission.setClient(client.get());
        }*/

        // Check if the demande field is present
      //  if (mission.getDemande() != null) {
        //    Optional<Demande> demande = demandeService.getDemandeById(mission.getDemande().getIdDemande());
         //   if (!demande.isPresent()) {
        //        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
         //   }
         //   mission.setDemande(demande.get());
       // }

        // Check if the artisan field is present
        if (mission.getArtisans() != null) {
            for (Artisan artisan : mission.getArtisans()) {
                Optional<Artisan> managedArtisan = artisanService.getArtisanById(artisan.getIdArtisan());
                if (!managedArtisan.isPresent()) {
                    return new ResponseEntity<>(HttpStatus.NOT_FOUND);
                }
            }
        }
        /*
        if (mission.getArtisans() != null) {
            List<Artisan> managedArtisans = new ArrayList<>();
            for (Artisan artisan : mission.getArtisans()) {
                Optional<Artisan> managedArtisan = artisanService.getArtisanById(artisan.getIdArtisan());
                if (managedArtisan.isPresent()) {
                    managedArtisans.add(managedArtisan.get());
                } else {
                    return new ResponseEntity<>(HttpStatus.NOT_FOUND);
                }
            }
            mission.setArtisans(managedArtisans);
        }*/


        // Check if the fournisseur field is present
        /*if (mission.getFournisseur() != null) {
            Optional<Fournisseur> fournisseur = fournisseurService.getFournisseurById(mission.getFournisseur().getIdFournisseur());
            if (!fournisseur.isPresent()) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            mission.setFournisseur(fournisseur.get());/
        }*/

        Mission savedMission = missionService.saveMission(mission);
        return new ResponseEntity<>(savedMission, HttpStatus.CREATED);
    }


    
    @PutMapping("/updatestatut/{id}")
    public ResponseEntity<Mission> updateMissionStatus(@PathVariable Long id, @RequestBody Mission mission) {
    	Mission updatedMission = missionService.updateMissionStatus(id, mission);
    	return updatedMission != null
                ? new ResponseEntity<>(updatedMission, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);

    }
    
    @PutMapping("/updategiveBonus/{id}")
    public ResponseEntity<Mission> updategiveBonus(@PathVariable Long id, @RequestBody Mission mission) {
    	Mission updatedMission = missionService.updategiveBonus(id, mission);
    	return updatedMission != null
                ? new ResponseEntity<>(updatedMission, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);

    }
    @PutMapping("/saveDebutIntervention/{id}")
    public ResponseEntity<Mission> saveDebutIntervention(@PathVariable Long id, @RequestBody Mission mission) {
    	Mission updatedMission = missionService.saveDebutReel(id, mission);
    	return updatedMission != null
                ? new ResponseEntity<>(updatedMission, HttpStatus.OK)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);

    }


    @PutMapping("/update/{id}")
    public ResponseEntity<Mission> updateMission(@PathVariable Long id, @RequestBody Mission mission) {
        Optional<Mission> existingMission = missionService.getMissionById(id);
        if (existingMission.isPresent()) {
            mission.setIdMission(id);
            Mission updatedMission = missionService.saveMission(mission);
            return new ResponseEntity<>(updatedMission, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
    
    
    @PutMapping("/{missionId}/assign-artisan/{artisanId}")
    public ResponseEntity<Mission> assignMissionToArtisan(@PathVariable Long missionId, @PathVariable Long artisanId) {
        Optional<Mission> missionOptional = missionService.getMissionById(missionId);
        Optional<Artisan> artisanOptional = artisanService.getArtisanById(artisanId);

        if (missionOptional.isPresent() && artisanOptional.isPresent()) {
            Mission mission = missionOptional.get();
            Artisan artisan = artisanOptional.get();

            // Use the assignMissionToArtisan method from MissionService
            missionService.assignMissionToArtisan(mission, artisan);

            return new ResponseEntity<>(mission, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }



    
    /*@PutMapping("/{missionId}/assign-artisan/{artisanId}")
    public ResponseEntity<Mission> assignMissionToArtisan(@PathVariable Long missionId, @PathVariable Long artisanId) {
        Optional<Mission> missionOptional = missionService.getMissionById(missionId);
        if (missionOptional.isPresent()) {
            Mission mission = missionOptional.get();
            missionService.assignMissionToArtisan(mission, artisanId);
            return new ResponseEntity<>(mission, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }*/

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> deleteMission(@PathVariable Long id) {
        Optional<Mission> mission = missionService.getMissionById(id);
        if (mission.isPresent()) {
            missionService.deleteMission(id);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
    @GetMapping("/by-artisan/{artisanId}")
    public ResponseEntity<List<Mission>> getMissionsByArtisanId(@PathVariable Long artisanId) {
        List<Mission> missions = missionService.getMissionsByArtisanId(artisanId);

        if (missions.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        return new ResponseEntity<>(missions, HttpStatus.OK);
    }
}
