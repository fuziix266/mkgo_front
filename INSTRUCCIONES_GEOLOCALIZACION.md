# Instrucciones para Configurar la Geolocalización

Para que la funcionalidad de geolocalización funcione correctamente, es necesario agregar los permisos de ubicación en los archivos de configuración nativos de Android e iOS.

## Android

1.  Abre el archivo `android/app/src/main/AndroidManifest.xml`.
2.  Agrega los siguientes permisos dentro de la etiqueta `<manifest>`:

    ```xml
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    ```

## iOS

1.  Abre el archivo `ios/Runner/Info.plist`.
2.  Agrega las siguientes claves y descripciones dentro de la etiqueta `<dict>`:

    ```xml
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Esta aplicación necesita acceso a tu ubicación para mostrarte los baños cercanos.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Esta aplicación necesita acceso a tu ubicación para mostrarte los baños cercanos.</string>
    ```

Una vez que hayas agregado estos permisos, la aplicación podrá solicitar y utilizar la ubicación del usuario.
