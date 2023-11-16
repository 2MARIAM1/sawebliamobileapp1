import { ArtisanService } from './../services/artisan.service';
import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { Artisan } from '../models/artisan';


@Component({
  selector: 'app-artisan-list',
  templateUrl: './artisan-list.component.html',
  styleUrls: ['./artisan-list.component.css']
})
export class ArtisanListComponent implements OnInit{


  artisans: Artisan[] = [];

  @Output() backToMissions = new EventEmitter<void>();


  constructor(private artisanService: ArtisanService) {}

  ngOnInit() {
    this.getArtisans();
  }

  getArtisans(): void {
    this.artisanService.getArtisans().subscribe(
      (artisans) => {
        this.artisans = artisans;
      },
      (error) => {
        console.log('Error fetching artisans:', error);
      }
    );
  }

  onBackToMissions(): void {
    // Emit the event to notify HomeComponent
    this.backToMissions.emit();
  }

}
