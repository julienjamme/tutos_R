#Isochrones

library(sf)
library(osrm)

connecter <- function(user, password){
  nom <- "db_tpcarto"
  hote <- "10.233.106.178"
  port <- "5432"
  conn <- dbConnect(Postgres(), dbname=nom, host=hote, user="tpcarto", password="tpcarto",port=port)
  return(conn)
}

conn <- connecter(user, password)

sf_reg_metro <- st_read("tutos_R/postgis/reg_francemetro_2021.gpkg")
str(sf_reg_metro)
plot(st_geometry(sf_reg_metro))

maternites_metro <- sf::st_read(conn, query = "SELECT * FROM bpe21_metro WHERE TYPEQU='D107';")
str(maternites_metro)

mater <- maternites_metro[1,]
mater_coords <- st_coordinates(mater) %>% as.numeric

plot(st_geometry(sf_reg_metro))
points(x = mater_coords[1], y = mater_coords[2], pch = 4, lwd = 2, cex = 1.5, col = "red")

library(leaflet)

mater_coords <- st_coordinates(mater %>% st_transform(4326)) %>% as.numeric

leaflet() %>% 
  setView(lng = mater_coords[1], lat = mater_coords[2], zoom = 14) %>% 
  addTiles() %>% 
  addMarkers(lng = mater_coords[1], lat = mater_coords[2])

(iso <- osrmIsochrone(
  loc = mater_coords, # coordonnées du point de référence
  breaks = seq(0,60,10), # valeurs des isochrones à calculer en minutes
  res = 60 # détermine le nombre de points utilisés (res*res) pour dessiner les isochornes 
))
str(iso)

bks <-  sort(unique(c(iso$isomin, iso$isomax)))
pals <- hcl.colors(n = length(bks) - 1, palette = "Red-Blue", rev = TRUE)
plot(iso["isomax"], breaks = bks, pal = pals, 
     main = "Isochrones (in minutes)", reset = FALSE)
points(x = mater_coords[1], y = mater_coords[2], pch = 4, lwd = 2, cex = 1.5)

pal <- colorFactor("Greens", domain = iso$isomax, levels = bks[-1],reverse = TRUE)

leaflet() %>% 
  setView(lng = mater_coords[1], lat = mater_coords[2], zoom = 8) %>% 
  addTiles() %>% 
  addMarkers(lng = mater_coords[1], lat = mater_coords[2]) %>% 
  addPolygons(
    data=iso, 
    fillColor = ~pal(isomax),
    weight = 1,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.65
  )
