import { Component, OnInit } from '@angular/core';
import { MissionService } from '../services/mission.service';
import { Mission } from '../models/mission';

@Component({
  selector: 'app-mission-list',
  templateUrl: './mission-list.component.html',
  styleUrls: ['./mission-list.component.css']
})
export class MissionListComponent implements OnInit{
  showArtisanList = false;

  missions: Mission[] = [];

  constructor(private missionService: MissionService) {}

  ngOnInit() {
    this.getMissions();
  }

  getMissions(): void {
    this.missionService.getAllMissions().subscribe(
      (missions) => {
        this.missions = missions;
      },
      (error) => {
        console.log('Error fetching missions:', error);
      }
    );
  }


  showArtisans():void{
    this.showArtisanList = true;
  }
  hideArtisans(): void {
    this.showArtisanList = false;
  }
  

}
