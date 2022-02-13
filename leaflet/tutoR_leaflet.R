library(sf)
library(leaflet)

# 0- Import data
load("data/iris_marseille_census_2018_dwell_dipl_and_sf.RData")

# 1- Reprojection of spatial layers
# leaflet needs sf objects in WGS84 projection

marseille_iris_sf <- marseille_iris_sf |> st_transform(crs = "epsg:4326")
marseille_armf_sf <- marseille_armf_sf |> st_transform(crs = "epsg:4326")

# 2- Merge dataframes
mars_iris_dw_dipl_sf <- marseille_iris_sf |>
  dplyr::left_join(
    dipl_tb |>
      dplyr::select(IRIS, dplyr::starts_with("P18_NSCOL15P")) |>
      dplyr::mutate(share_less_bac = (P18_NSCOL15P_DIPLMIN + P18_NSCOL15P_BEPC + P18_NSCOL15P_CAPBEP)/P18_NSCOL15P*100),
    by = c("code" = "IRIS")
  ) |>
  dplyr::left_join(
    dw_tb |>
      dplyr::select(-COM,-TYP_IRIS) |>
      dplyr::mutate(share_proprio = P18_RP_PROP/P18_RP*100),
    by = c("code" = "IRIS")
  )

# 3- Some coordinates
# https://www.openstreetmap.org/search?whereami=1&query=43.26983%2C5.39591#map=13/43.3048/5.4276
city_hall <- c(lat=43.2961743, lng=5.3699525)
stadium <- c(lat=43.26983, lng=5.39591)
bonne_mere <- c(lat=43.28393, lng=5.37125)

# 4- A first map with leaflet

leaflet() |>
  addTiles() |>
  # Add markers to locate some places
  addMarkers(lng=city_hall['lng'], lat=city_hall['lat'], popup = "Mairie") |>
  addMarkers(lng=stadium['lng'], lat=stadium['lat'], popup = "Vélodrome") |>
  addMarkers(lng=bonne_mere['lng'], lat=bonne_mere['lat'], popup = "Bonne-Mère") |>
  # Add municipal districts - first polygons
  addPolygons(
    data = marseille_armf_sf,
    weight = 2, #width of the borders
    color = "purple",
    fill = NA,
    group = "districts"
  ) |>
  # Add iris - second polygons
  addPolygons(
    data = mars_iris_dw_dipl_sf,
    weight = 1, #width of the borders
    opacity = 1,
    # Add a thematic : quantiles of shares of out-of-school persons 15 years of age or older by Iris
    fillColor = ~colorQuantile("YlOrRd", domain = share_less_bac, probs = seq(0,1,0.2))(share_less_bac),
    group = "iris"
  ) |>
  # Add legend
  addLegend(
    pal = colorQuantile("YlOrRd", domain = mars_iris_dw_dipl_sf$share_less_bac, probs = seq(0,1,0.2)),
    values = mars_iris_dw_dipl_sf$share_less_bac
  ) |>
  # Add control on layers
  addLayersControl(
    overlayGroups = c("districts", "iris")
  ) |>
  hideGroup('districts')



# Exercise 1
# Compute shares of out-of-school persons 15 years of age or older by districts and add its representation on the 
# previous map

# Exercise 2
# Make another leaflet map of Marseille with :
# markers for the museum called Mucem and for the prison called 'Les Baumettes' (search coordinates on openstreetmap.org)
# add iris and districts polygons with representation of shares of owners respectively by iris and districts
# study the distribution of these new variables to choose the better discretization method
# Add popups on each district/iris with its name/code, and its share of owners
