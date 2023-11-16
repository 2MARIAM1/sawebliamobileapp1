export interface Artisan {
  id: number;
  email: string;
  password: string;
  user_type: string;
  nomComplet?: string;
  cin?: string;
  tel?: string;
  longitude?: number;
  latitude?: number;
  adresse?: string;
  quartier?: string;
  jocker?: boolean;
  nbrMissions?: number;
  totalCa?: number;
  totalBonus?: number;
  nbrRetards?: number;
  lastLogin?: Date;
  blocked?: boolean;
  metiers?: string[];
  fcmToken?: string;
}
