<p align="center">
<img src="https://github.com/faisalmlalani/pluto/blob/master/Pluto/Assets.xcassets/app_icon.imageset/app_icon.png" width=200 height=200>
</p>

<p align="center">
<img src="https://img.shields.io/badge/version-1.0-red.svg">
<img src="https://img.shields.io/badge/platform-iOS-blue.svg">
<img src="https://img.shields.io/badge/phase-development-brightgreen.svg">
</p>

Pluto is a social map that displays events and breaking news around you.

## Features

* **MapKit**

   Apple's map library. 

* **Firebase**

   Used as a backend. I use the Realtime Database and Storage to hold event and user data, along with all photos shared. Firebase's new Cloud Functions for push notifications are also in the works. Login and signup are also set up.
   
* **Facebook & Google Sign-in**

  Users can sign in with Facebook or Google.
   
* **GeoFire**

  Firebase's location query library. Used to present events on the map as the user pans over to different locations.
  
* **Real-time Chat**

  Created my own real-time group chats for events. Users that add events are automically added to the event's group chat and can communicate successfully with other users. Photo-sharing included.
  
* **Calendar Sync**

  Events sync to the user's personal calendar once added.
  
* **Events**

  Events can be created, edited, and deleleted. Events that are successfully created are synced to the creator's calendar and presented to the public via the map.
