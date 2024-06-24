# course_app
**API Reference**
* [API Reference](https://github.com/Vhaooforjob/server_course_app)

## SETUP pubspec packages used:
0. **environment, dependencies, dev:**
 ```sh
   environment:
   sdk: '>=3.4.0 <4.0.0'

   dependencies:
   flutter:
      sdk: flutter
   cupertino_icons: ^1.0.6
   http: ^1.2.1
   webview_flutter: ^4.7.0
   video_player: ^2.2.14
   chewie: ^1.1.2
   flutter_html: ^3.0.0-beta.2
   salomon_bottom_bar: ^3.3.2
   carousel_slider: ^4.2.1
   jwt_decoder: ^2.0.1
   velocity_x: ^4.1.2
   shared_preferences: ^2.0.6
   floating_bottom_navigation_bar: ^1.5.2
   youtube_player_flutter: ^8.0.0
   intl: ^0.19.0
   flutter_rating_bar: ^4.0.0
   expandable_text: ^2.3.0
   
   dev_dependencies:
   flutter_test:
      sdk: flutter
   flutter_lints: ^3.0.0

   flutter:
   uses-material-design: true
   assets:
      - assets/images/
 ```
 
1. **Type flutter:**
   ```sh
   flutter clean
   ```
   ```sh
   flutter pub get / flutter upgrade
   ```
   ```sh
   flutter run
   ```
2. **Flutter set up IP Address run:**
   ```sh
   Open command Prompt:
   cmd -> ipconfig ->  IPv4 Address
   ```
   ```sh
   Or Run Modules Server to Get Address and Port: -> Address port
   ```
   ```sh
   follow lib -> configs -> ipconfigs 
   Change the final URL to: 
   final url = 'http://<IPAddress>:<Port>/';
   ```
   
