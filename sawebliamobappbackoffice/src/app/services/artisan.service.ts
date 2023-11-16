import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { Artisan } from '../models/artisan';

@Injectable({
  providedIn: 'root'
})
export class ArtisanService {
  private apiServerUrl = environment.apiBaseUrl;

  constructor(private http: HttpClient) { }

  getArtisans(): Observable<Artisan[]> {
    return this.http.get<Artisan[]>(`${this.apiServerUrl}/artisans/all`);
  }
}
