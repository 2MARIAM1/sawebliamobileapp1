import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

// import { NgModule } from '@angular/core';
// import { RouterModule, Routes } from '@angular/router';
// import { HomeComponent } from './home/home.component';
// import { ArtisanListComponent } from './artisan-list/artisan-list.component';

// const routes: Routes = [
//   { path: 'home', component: HomeComponent },
//   { path: 'artisan-list', component: ArtisanListComponent }, // Add this line
//   { path: '**', redirectTo: '/home', pathMatch: 'full' },
// ];

// @NgModule({
//   imports: [RouterModule.forRoot(routes)],
//   exports: [RouterModule],
// })
// export class AppRoutingModule {}