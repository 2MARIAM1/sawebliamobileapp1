import { Client } from "./client";

export interface Demande {
    idDemande: number;
    client?: Client;
    description?: string;
    urgence?: boolean;
    metierDemande?: string;
    typePrestation?: string;
  }
  