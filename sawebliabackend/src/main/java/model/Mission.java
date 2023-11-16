package model;

import java.time.OffsetDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

@Entity
@Table(name = "mission")
public class Mission {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id_mission",nullable=false)
    private Long idMission;
    
    
    //(fetch = FetchType.EAGER)
   // @JoinTable(
    //    name = "mission_artisan",
     //   joinColumns = @JoinColumn(name = "id_mission"),
      //  inverseJoinColumns = @JoinColumn(name = "id_artisan")
   // )
    //@Fetch(FetchMode.JOIN)

    @JsonIgnoreProperties("missions")
    @ManyToMany(mappedBy = "missions",fetch = FetchType.EAGER)
    private List<Artisan> artisans;
    
    

  //  @ManyToOne(optional = true)
  //  @JoinColumn(name = "id_fournisseur")
  //  private Fournisseur fournisseur;

   // @ManyToOne(optional = true)
    //@JoinColumn(name = "id_client")
    //private Client client;

    
    private String id_record ;
    private String envoyerNotif ;
    private String autoAffectation ;

	@Column(name = "longitude")
    private Double longitude;

    @Column(name = "latitude")
    private Double latitude;
    @Column(name = "localisation",length = 1000)
    private String localisation;

    @Column(name = "adresse")
    private String adresse;
    
    @Column(name= "quartier")
    private String quartier;

    @Column(name = "statut_mission")
    private String statutMission;
    
    @Column(name = "type_mission")
    private String typeMission;

    @Column(name = "ponctualite")
    private String ponctualite;

    @Column(name = "description",length = 1000)
    private String description;

    @Column(name = "urgence")
    private boolean urgence;
    
    @Column(name = "metier")
    private String metier;

    @Column(name = "debut_prevu")
    private OffsetDateTime debutPrevu;

    @Column(name = "debut_reel")
    private OffsetDateTime debutReel;

    @Column(name = "fin_prevue")
    private OffsetDateTime finPrevue;

    @Column(name = "fin_reelle")
    private OffsetDateTime finReelle;

    @Column(name = "prixmaxfournitures")
    private Double prixMaxFournitures;

    @Column(name = "prix_a_payer")
    private Double prixAAPayer;

    @Column(name = "moyen_paiement")
    private String moyenPaiement;
    
    @Column(name = "tel_client")
    private String telClient;
    
    @Column(name = "nomClient")
    private String nomClient;
    
    private boolean notificationSent;
    private boolean paiementCollecte;
    private boolean giveBonus ;
    private boolean isReminderSent ;
    
    

    
    public void addArtisan(Artisan artisan) {
        artisans.add(artisan);
    }

    public void removeArtisan(Artisan artisan) {
        artisans.remove(artisan);
    }
    

	public Mission() {}



	public Mission(Long idMission, List<Artisan> artisans, String id_record,
			String envoyerNotif, String autoAffectation, Double longitude, Double latitude, String localisation,
			String adresse, String quartier, String statutMission, String typeMission, String ponctualite,
			String description, boolean urgence, String metier, OffsetDateTime debutPrevu,
			OffsetDateTime debutReel, OffsetDateTime finPrevue, OffsetDateTime finReelle, Double prixMaxFournitures,
			Double prixAAPayer, String moyenPaiement, String telClient, String nomClient, boolean notificationSent,
			boolean paiementCollecte,boolean giveBonus,boolean isReminderSent) {
		super();
		this.idMission = idMission;
		this.artisans = artisans;
		this.id_record = id_record;
		this.envoyerNotif = envoyerNotif;
		this.autoAffectation = autoAffectation;
		this.longitude = longitude;
		this.latitude = latitude;
		this.localisation = localisation;
		this.adresse = adresse;
		this.quartier = quartier;
		this.statutMission = statutMission;
		this.typeMission = typeMission;
		this.ponctualite = ponctualite;
		this.description = description;
		this.urgence = urgence;
		this.metier = metier;
		this.debutPrevu = debutPrevu;
		this.debutReel = debutReel;
		this.finPrevue = finPrevue;
		this.finReelle = finReelle;
		this.prixMaxFournitures = prixMaxFournitures;
		this.prixAAPayer = prixAAPayer;
		this.moyenPaiement = moyenPaiement;
		this.telClient = telClient;
		this.nomClient = nomClient;
		this.notificationSent = notificationSent;
		this.paiementCollecte = paiementCollecte;
		this.giveBonus = giveBonus ;
		this.isReminderSent = isReminderSent ;
	}

	public Long getIdMission() {
		return idMission;
	}

	public void setIdMission(Long idMission) {
		this.idMission = idMission;
	}

	public List<Artisan> getArtisans() {
		return artisans;
	}

	public void setArtisans(List<Artisan> artisans) {
		this.artisans = artisans;
	}


	public String getId_record() {
		return id_record;
	}

	public void setId_record(String id_record) {
		this.id_record = id_record;
	}

	public String getEnvoyerNotif() {
		return envoyerNotif;
	}

	public void setEnvoyerNotif(String envoyerNotif) {
		this.envoyerNotif = envoyerNotif;
	}

	public String getAutoAffectation() {
		return autoAffectation;
	}

	public void setAutoAffectation(String autoAffectation) {
		this.autoAffectation = autoAffectation;
	}

	public Double getLongitude() {
		return longitude;
	}

	public void setLongitude(Double longitude) {
		this.longitude = longitude;
	}

	public Double getLatitude() {
		return latitude;
	}

	public void setLatitude(Double latitude) {
		this.latitude = latitude;
	}

	public String getLocalisation() {
		return localisation;
	}

	public void setLocalisation(String localisation) {
		this.localisation = localisation;
	}

	public String getAdresse() {
		return adresse;
	}

	public void setAdresse(String adresse) {
		this.adresse = adresse;
	}

	public String getQuartier() {
		return quartier;
	}

	public void setQuartier(String quartier) {
		this.quartier = quartier;
	}

	public String getStatutMission() {
		return statutMission;
	}

	public void setStatutMission(String statutMission) {
		this.statutMission = statutMission;
	}

	public String getTypeMission() {
		return typeMission;
	}

	public void setTypeMission(String typeMission) {
		this.typeMission = typeMission;
	}

	public String getPonctualite() {
		return ponctualite;
	}

	public void setPonctualite(String ponctualite) {
		this.ponctualite = ponctualite;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public boolean isUrgence() {
		return urgence;
	}

	public void setUrgence(boolean urgence) {
		this.urgence = urgence;
	}

	public String getMetier() {
		return metier;
	}

	public void setMetier(String metier) {
		this.metier = metier;
	}

	public OffsetDateTime getDebutPrevu() {
		return debutPrevu;
	}

	public void setDebutPrevu(OffsetDateTime debutPrevu) {
		this.debutPrevu = debutPrevu;
	}

	public OffsetDateTime getDebutReel() {
		return debutReel;
	}

	public void setDebutReel(OffsetDateTime debutReel) {
		this.debutReel = debutReel;
	}

	public OffsetDateTime getFinPrevue() {
		return finPrevue;
	}

	public void setFinPrevue(OffsetDateTime finPrevue) {
		this.finPrevue = finPrevue;
	}

	public OffsetDateTime getFinReelle() {
		return finReelle;
	}

	public void setFinReelle(OffsetDateTime finReelle) {
		this.finReelle = finReelle;
	}

	public Double getPrixMaxFournitures() {
		return prixMaxFournitures;
	}

	public void setPrixMaxFournitures(Double prixMaxFournitures) {
		this.prixMaxFournitures = prixMaxFournitures;
	}

	public Double getPrixAAPayer() {
		return prixAAPayer;
	}

	public void setPrixAAPayer(Double prixAAPayer) {
		this.prixAAPayer = prixAAPayer;
	}

	public String getMoyenPaiement() {
		return moyenPaiement;
	}

	public void setMoyenPaiement(String moyenPaiement) {
		this.moyenPaiement = moyenPaiement;
	}

	public String getTelClient() {
		return telClient;
	}

	public void setTelClient(String telClient) {
		this.telClient = telClient;
	}

	public String getNomClient() {
		return nomClient;
	}

	public void setNomClient(String nomClient) {
		this.nomClient = nomClient;
	}

	public boolean isNotificationSent() {
		return notificationSent;
	}

	public void setNotificationSent(boolean notificationSent) {
		this.notificationSent = notificationSent;
	}

	public boolean getPaiementCollecte() {
		return paiementCollecte;
	}

	public void setPaiementCollecte(boolean paiementCollecte) {
		this.paiementCollecte = paiementCollecte;
	}

	public boolean getGiveBonus() {
		return giveBonus;
	}

	public void setGiveBonus(boolean giveBonus) {
		this.giveBonus = giveBonus;
	}

	public boolean isReminderSent() {
		return isReminderSent;
	}

	public void setReminderSent(boolean isReminderSent) {
		this.isReminderSent = isReminderSent;
	}

	
    
}

