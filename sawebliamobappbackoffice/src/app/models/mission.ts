import { Artisan } from "./artisan";
import { Fournisseur } from "./fournisseur";
import { Client } from "./client";
import { Demande } from "./demande";
export interface Mission {
  idMission: number;
  fournisseur?: Fournisseur ;
  artisan?: Artisan ;
  client?: Client ;
  demande?: Demande ;
  longitude?: number ;
  latitude?: number ;
  adresse?: string ;
  quartier?: string;
  statutMission?: string;
  typeMission?: string;
  ponctualite?: string;
  description?: string;
  urgence?: boolean;
  metiers?: string[];
  debutPrevu?: Date;
  debutReel?: Date;
  finPrevue?: Date;
  finReelle?: Date;
  prixMaxFournitures?: number;
  prixAAPayer?: number;
  moyenPaiement?: string;
}


  //MIRRORING WHAT THE EMPLOYEE LOOKS LIKE FROM THE BACKEND