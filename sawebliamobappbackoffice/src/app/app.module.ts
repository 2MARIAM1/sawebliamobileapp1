import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { MissionListComponent } from './mission-list/mission-list.component';
import { HttpClientModule } from '@angular/common/http';
import { ArtisanListComponent } from './artisan-list/artisan-list.component';

@NgModule({
  declarations: [
    AppComponent,
    MissionListComponent,
    ArtisanListComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,HttpClientModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
