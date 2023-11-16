package model;

import java.time.LocalDateTime;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

@Entity
@Table(name= "artisan")
public class Artisan{
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id_artisan",nullable = false)
    private Long idArtisan;
    
  /*  @ManyToMany(fetch = FetchType.LAZY,
    	      cascade = {
    	              CascadeType.PERSIST,
    	              CascadeType.MERGE
    	          },mappedBy = "artisans")*/
    
    //@Fetch(FetchMode.JOIN)
    
    @JsonIgnoreProperties("artisans")  //If you want to fetch artisans with missions too
    @JoinTable(
        name = "artisan_mision",
        joinColumns = @JoinColumn(name = "id_artisan"),
        inverseJoinColumns = @JoinColumn(name = "id_mission")
    )
    //(fetch = FetchType.EAGER,mappedBy = "artisans", cascade = CascadeType.ALL)
    @ManyToMany(fetch = FetchType.EAGER)
    private List<Mission> missions ;
    
    private String id_record ;
    
    
    @Column(name="login")
    private String login ;
    
    
    @Column(name="password")
    private String password;

    @Column(name = "nom_complet")
    private String nomComplet;

    @Column(name = "cin")
    private String cin;

    @Column(name = "tel")
    private String tel;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "adresse")
    private String adresse;
    
    @Column(name = "localisation",length = 1000)
    private String localisation;
    
    @Column(name= "quartier")
    private String quartier;

    @Column(name = "jocker")
    private Boolean jocker;

    @Column(name = "nbr_missions")
    private Integer nbrMissions;

    @Column(name = "total_ca")
    private Double totalCa;

    @Column(name = "total_bonus")
    private Double totalBonus;

    @Column(name = "nbr_retards")
    private Integer nbrRetards;

    @Column(name = "last_login")
    private LocalDateTime lastLogin;

    @Column(name = "blocked")
    private Boolean blocked = false;
    
    @Column(name = "metiers")
    private List<String> metiers;
    
    @Column(name = "fcm_token")
    private String fcmToken;

    
    public Artisan() {
    	 this.blocked = false; 
}

    
	public String getLocalisation() {
		return localisation;
	}


	public void setLocalisation(String localisation) {
		this.localisation = localisation;
	}


	public Long getIdArtisan() {
		return idArtisan;
	}


	public void setIdArtisan(Long idArtisan) {
		this.idArtisan = idArtisan;
	}
	public String getFcmToken() {
		return fcmToken;
	}


	public void setFcmToken(String fcmToken) {
		this.fcmToken = fcmToken;
	}


	public String getNomComplet() {
		return nomComplet;
	}

	public void setNomComplet(String nomComplet) {
		this.nomComplet = nomComplet;
	}

	public String getCin() {
		return cin;
	}

	public void setCin(String cin) {
		this.cin = cin;
	}

	public String getTel() {
		return tel;
	}

	public void setTel(String tel) {
		this.tel = tel;
	}

	public Boolean isJocker() {
		return jocker;
	}

	public void setJocker(Boolean jocker) {
		this.jocker = jocker;
	}

	public Integer getNbrMissions() {
		return nbrMissions;
	}

	public void setNbrMissions(Integer nbrMissions) {
		this.nbrMissions = nbrMissions;
	}

	public Double getTotalCa() {
		return totalCa;
	}

	public void setTotalCa(Double totalCa) {
		this.totalCa = totalCa;
	}

	public Double getTotalBonus() {
		return totalBonus;
	}

	public void setTotalBonus(Double totalBonus) {
		this.totalBonus = totalBonus;
	}

	public Integer getNbrRetards() {
		return nbrRetards;
	}

	public void setNbrRetards(Integer nbrRetards) {
		this.nbrRetards = nbrRetards;
	}

	public LocalDateTime getLastLogin() {
		return lastLogin;
	}

	public void setLastLogin(LocalDateTime lastLogin) {
		this.lastLogin = lastLogin;
	}

	public Boolean getBlocked() {
		return blocked;
	}

	public void setBlocked(Boolean blocked) {
		this.blocked = blocked;
	}
	

	public List<String> getMetiers() {
		return metiers;
	}

	public void setMetiers(List<String> metiers) {
		this.metiers = metiers;
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
	
	

//	public Artisan(Long id, String email, String password, String user_type) {
//		super(id, email, password, user_type);
//		// TODO Auto-generated constructor stub
//	}

	public List<Mission> getMissions() {
		return missions;
	}

	public void setMissions(List<Mission> missions) {
		this.missions = missions;
	}

	public String getLogin() {
		return login;
	}

	public void setLogin(String login) {
		this.login = login;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public Boolean getJocker() {
		return jocker;
	}

	

	public String getId_record() {
		return id_record;
	}

	public void setId_record(String id_record) {
		this.id_record = id_record;
	}


	public Artisan(Long idArtisan, List<Mission> missions, String id_record, String login, String password,
			String nomComplet, String cin, String tel, Double longitude, Double latitude, String adresse,
			String localisation, String quartier, Boolean jocker, Integer nbrMissions, Double totalCa,
			Double totalBonus, Integer nbrRetards, LocalDateTime lastLogin, Boolean blocked, List<String> metiers,
			String fcmToken) {
		super();
		this.idArtisan = idArtisan;
		this.missions = missions;
		this.id_record = id_record;
		this.login = login;
		this.password = password;
		this.nomComplet = nomComplet;
		this.cin = cin;
		this.tel = tel;
		this.longitude = longitude;
		this.latitude = latitude;
		this.adresse = adresse;
		this.localisation = localisation;
		this.quartier = quartier;
		this.jocker = jocker;
		this.nbrMissions = nbrMissions;
		this.totalCa = totalCa;
		this.totalBonus = totalBonus;
		this.nbrRetards = nbrRetards;
		this.lastLogin = lastLogin;
		this.blocked = blocked;
		this.metiers = metiers;
		this.fcmToken = fcmToken;
	}

	
	


	

	
	
	
	
    
    

	
}
