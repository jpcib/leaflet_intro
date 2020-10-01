install.packages("leaflet")
install.packages("rgdal")

#Cargamos paquetes necesarios

library(tidyverse)
library(leaflet)
library(rgdal)


x <- data.frame (5 + 5)

#creamos un mapa con leaflet.
  
m_prueba1 <- leaflet() %>% 
  addTiles("https://servicios.usig.buenosaires.gob.ar/mapcache/tms/1.0.0/amba_con_transporte_3857@GoogleMapsCompatible/{z}/{x}/{-y}.png") %>% #addTiles() nos da la capa base del mapa.Vacío agrega tiles default de OpenStreetMap
  addMarkers(lng = -58.445071, lat = -34.616823, popup = "Centro Geografico de la CABA") #agregamos marcador con popup
m_prueba1


#Opciones de Inicializacion para mapas interactivos (van dentro de parentesis original, puede estar vacio y usar los valores por defecto)

m_prueba2 <- leaflet (options = leafletOptions(minZoom = 1, maxZoom = 18)) %>% #Asignar valores de minZoom y maxZoom (*18 es el max)
  addTiles() %>% 
  addMarkers(lng = -58.445071, lat = -34.616823, popup = "Centro Geografico de la CABA") %>% 
  setMaxBounds(lng1 = -58.4311512, lat1 = -34.6038625, lng2 = -58.4689355, lat2 = -34.6483649) #Asignar rectangulo limites de visualizacion con coord de dos de sus vértices
m_prueba2

#agregamos un cítculo a nuestro mapa

m_prueba3 <- leaflet (options = leafletOptions(minZoom = 1, maxZoom = 18)) %>% #Asignar valores de minZoom y maxZoom *18 es el max
  addTiles() %>% 
  addMarkers(lng = -58.445071, lat = -34.616823, popup = "Centro Geografico de la CABA") %>% 
  addCircles(lng = -58.445071, lat = -34.616823, radius = 120, color = "Red", opacity = 1 ) %>% #coords del centro, radio, color y opacidad del borde
  setMaxBounds(lng1 = -58.4311512, lat1 = -34.6038625, lng2 = -58.4689355, lat2 = -34.6483649) #Asignar rectangulo limites de visualizacion
m_prueba3


#Descargamos el dataset de distritos económicos para poder graficarlos en el mapa
# https://data.buenosaires.gob.ar/dataset/distritos-economicos/archivo/juqdkmgo-742-resource


#Generamos un objeto data_distritos del Shapefile descargado, y preparamos los datos
data_distritos <- readOGR("E:/Escritorio/Lab/maps/distritos_economicos.shp", encoding = "UTF-8") #readOGR nos permite leer n .shp y utilizamos la codificación de caracteres "UTF-8".
data_distritos <- spTransform(data_distritos, CRS("+proj=longlat +datum=WGS84 +no_defs"))#spTransform nos permite asignar al .shp con el sistema de coordenadas WGS84 que es rl estándar


#A mapear!
m_distritos_caba <- leaflet (data_distritos, options = leafletOptions(minZoom = 10, maxZoom = 18)) %>% 
  #Podemos cargar mapas de base alternativos al default de OSM:
  addProviderTiles("Stamen.Toner") %>% 
  #Agregamos poligonos esta vez segun los datos que preparamos antes:
  addPolygons(data =  data_distritos, weight = 3.5, opacity = 1, smoothFactor = 1, fillOpacity = 0.2,
              color = "Red", stroke = TRUE,
              label = ~NOMBRE) %>% #dentro de addpolygons agregamos también las etiquetas (label) utilizamos ~ seguido del nombre de la columna que queramos asignar
  setView(lng = -58.445071, lat = -34.616823, zoom = 12)

m_distritos_caba

#Podemos tambien generar un color diferente para cada distrito y etiquetas que nos muestren datos interesantes:
#creamos un objeto que va a contener la paleta de colores asignada según el NOMBRE de los distritos.

pal_distritos <- colorFactor("Set1", domain = data_distritos$NOMBRE)


#Creamos las etiquetas con los datos que necesitemos mostrar de nuestro dataset, por ejemplo, incluimos las hectareas que ocupa cada distrito
#Creamos un pbjeto que contenga las etiquetas con HTMLtools. <strong> es para negritas, %s reserva un espacio para el dato y también puedo escribir strings.
etiquetas_dist <- sprintf(
  "<strong>%s</strong><br/>%s Hectareas",
  data_distritos$NOMBRE, data_distritos$HECTAREAS) %>% 
  lapply(htmltools::HTML)

#Y volvemos a generar un mapa reemplazando los colores de los poligonos
#modificamos tambien la opacidad del relleno

m_distritos_caba_2 <- leaflet (data_distritos, options = leafletOptions(minZoom = 10, maxZoom = 18)) %>%
  addProviderTiles("CartoDB.DarkMatter") %>%
  addPolygons(data =  data_distritos, weight = 3.5, opacity = 1, smoothFactor = 1, fillOpacity = 0.3,
              color = pal_distritos(data_distritos$NOMBRE), stroke = TRUE,
              label = etiquetas_dist, 
              #Tambien podemos resaltar los poligonos con los que interactuamos, también es una funcion dentro de addPolygons
              highlightOptions = highlightOptions(color = pal_distritos(data_distritos$NOMBRE), weight = 10, bringToFront = TRUE, fillOpacity = 0.6)) %>%
  #Por último agregamos referencias para los datos. Indicamos en que lugar queremos ubicarla, la misma paleta, y la información que queremos ver, luego el título
  addLegend("bottomright", pal = pal_distritos, values = data_distritos$NOMBRE, title = "Distritos creativos CABA") %>%  
  setView(lng = -58.445071, lat = -34.616823, zoom = 12)

m_distritos_caba_2
