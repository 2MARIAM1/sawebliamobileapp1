package model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;


@Entity
@Table(name= "feedbackArtisan")
public class FeedbackArtisan {

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	@Column(name = "id_feedback", nullable = false)
	private Long idFeedback;

	@ManyToOne(optional = true)
	@JoinColumn(name = "id_mission")
	private Mission mission;

	@Column(name = "type_fichier")
	private String typeFichier;

	@Column(name = "nom_fichier")
	private String nomFichier;

	@Column(name = "url")
	private String url;

	public FeedbackArtisan() {
	}

	public FeedbackArtisan(Long idFeedback, Mission mission, String typeFichier, String nomFichier, String url) {
		super();
		this.idFeedback = idFeedback;
		this.mission = mission;
		this.typeFichier = typeFichier;
		this.nomFichier = nomFichier;
		this.url = url;
	}

	public Long getIdFeedback() {
		return idFeedback;
	}

	public void setIdFeedback(Long idFeedback) {
		this.idFeedback = idFeedback;
	}

	public Mission getMission() {
		return mission;
	}

	public void setMission(Mission mission) {
		this.mission = mission;
	}

	public String getTypeFichier() {
		return typeFichier;
	}

	public void setTypeFichier(String typeFichier) {
		this.typeFichier = typeFichier;
	}

	public String getNomFichier() {
		return nomFichier;
	}

	public void setNomFichier(String nomFichier) {
		this.nomFichier = nomFichier;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	};

}
