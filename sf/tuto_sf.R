# Require R>4.1.1
# Packages : data.table and dplyr

library(sf)
library(dplyr)

source("settings_s3.R", encoding = "UTF-8") #S3 connexion settings

comf_sf <- st_read("commune_francemetro_2021.shp")
arm13_sf <- st_read("armf_bdtopo_dep_13_2021.gpkg")

# Prendre des infos sur un objet sf
str(arm13_sf)
View(arm13_sf)
st_crs(arm13_sf)
plot(arm13_sf$geometry)

# Manipuler le dataframe sous-jacent comme un dataframe normal
arm13_sf <- arm13_sf %>%
  #renommer une variable
  rename(depcom = code) %>%
  #calculer la surface directement à partir de la géométrie
  mutate(surf_b = st_area(geometry))

# fusionner un fond pour unir l'ensemble des géométries
# des arrdts de Marseille => commune de marseille

com13_sf <- arm13_sf %>%
  summarise(
    #fusion des géométries
    geometry = st_union(geometry),
    #calcul de la surface totale
    surf = sum(surf),
    surf_b = sum(surf_b)
  )

str(com13_sf, max.level = 1)
plot(com13_sf$geometry)

# fusionner des géométries par groupe
# les epc de Bretagne

epc35_sf <- comf_sf %>%
  filter(dep == "35") %>%
  group_by(epc) %>%
  summarise(
    geometry = st_union(geometry),
    surf = sum(surf),
    .groups = "drop"
  )

# façons basiques de représenter
plot(epc35_sf$geometry)
plot(st_geometry(epc35_sf))

plot(
  st_geometry(epc35_sf), 
  col = sf.colors(18, categorical = TRUE), 
  border = 'grey', 
  axes = FALSE
)

# représenter une variable
plot(
  epc35_sf["epc"]
)

# représentation d'une variable numérique
epc35_sf <- epc35_sf %>%
  mutate(part_surf = surf/sum(surf)*100,
         #discrétisation
         part_surf_c = cut(part_surf, 4)
  )
plot(
  epc35_sf["part_surf_c"],
  pal = sf.colors(4)
)

# Quelques éléments sur la discrétisation d'une variable
# Idée = former des classes homogènes à partir d'une variable numérique

var_num <- comf_sf$surf

# 1-etude de la distribution de la variable
summary(var_num)
quantile(var_num, probs = seq(0,1,0.1))
hist(var_num, breaks = 100)

# choix d'une palette de couleurs
pal1 <- RColorBrewer::brewer.pal(n = 5, name = "YlOrRd")
#comparaison de différentes méthodes de discrétisation
plot(
  classInt::classIntervals(var_num, style = "quantile", n = 5),
  pal = pal1,
  main = "quantile"
)
plot(
  classInt::classIntervals(var_num, style = "pretty", n = 5),
  pal = pal1,
  main = "pretty"
)
plot(
  classInt::classIntervals(var_num, style = "sd", n = 6),
  pal = pal1,
  main = "sd"
)
plot(
  classInt::classIntervals(var_num, style = "kmeans", n = 5, rtimes = 5),
  pal = pal1,
  main = "kmeans"
)
#fisher = équivalent de jenks mais plus adaptée pour les grads jeux de données
plot(
  classInt::classIntervals(var_num, style = "fisher", n = 5),
  pal = pal1,
  main = "Fisher"
)

# choix de la méthode et discrétisation

classes <- classInt::classIntervals(var_num, style = "fisher", n = 5)
classes
classes$brks

# discrétisation 
var_num_d <- cut(var_num, breaks = classes$brks, include.lowest = TRUE, right = FALSE, ordered_result = TRUE)

barplot(table(var_num_d))

# représentation carto
comf_sf <- comf_sf %>%
  mutate(
    surf_d = cut(
      surf, 
      breaks = classes$brks, 
      include.lowest = TRUE, 
      right = FALSE, 
      ordered_result = TRUE
    )
  )

plot(
  comf_sf["surf_d"],
  pal = sf.colors(5),
  border = FALSE,
  main = 'fisher'
)

# ou directement

plot(
  comf_sf["surf"], 
  breaks = "quantile",
  border=FALSE,
  main = 'quantile'
)

plot(
  comf_sf["surf"], 
  breaks = "pretty",
  border=FALSE,
  main = 'pretty'
)

plot(
  comf_sf["surf"], 
  breaks = "kmeans",
  border=FALSE,
  main = 'kmeans'
)




