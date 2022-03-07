library(dplyr)

ENT18 <- rio::import("P:/FLORES/flores_2018/flores_ent_2018.fst")

str(ENT18)

ent18_prepa <- ENT18 %>%
  # sélection des variables utiles
  select(depsiege, cj, employeur, siren, regsiege) %>%
  # restriction aux associations : cj commençant par "92"
  filter(
    substr(cj, 1, 2) == "92" &
      employeur == "1" &
      substr(siren, 1, 1) != "P" &
      substr(depsiege, 1, 2) != "99" &
      # !(is.na(regsiege)) #pour supprimer les valeurs manquantes sur la variable regsiege
      regsiege != ""
  ) %>%
  # Création d'une variable METRO (dom/metro)
  mutate(
    metro = case_when(
      regsiege < 10 ~ "2 - DOM",
      TRUE ~ "1 - Métropole"
    )
  )

# ctrl+shift+c : (dé)commenter une ligne ou plusieurs
# NA : valeur manquante en R : is.na(x)

# Nombre d'entreprises par département
tab1 <- ent18_prepa %>%
  group_by(depsiege) %>%
  summarise(
    nb_ent = n()
  )

# Nombre d'entreprises par metro/dom
tab2 <- ent18_prepa %>%
  group_by(metro) %>%
  summarise(
    nb_ent = n()
  )

# Nombre d'entreprises par cj et par région du siège + marges
tab3 <- 
  # 1- on dénombre les entreprises dans les croisements 
  ent18_prepa %>%
  group_by(cj, regsiege) %>%
  summarise(
    nb_ent = n(),
    .groups = "drop" #option à utiliser pour supprimer l'aspect groupé du data
  ) %>%
  # 2 - On dénombre les entreprises selon une première marge (cj)
  bind_rows(
    ent18_prepa %>%
      group_by(cj) %>%
      summarise(
        nb_ent = n(),
        .groups = "drop"
      ) %>%
      # On ajoute une modalité à l'autre variable de croisements (sinon => NA)
      mutate(
        regsiege = "Ensemble"
      )
  ) %>%
  # 3 - On dénombre les entreprises selon une seconde marge (regsiege)
  bind_rows(
    ent18_prepa %>%
      group_by(regsiege) %>%
      summarise(
        nb_ent = n(),
        .groups = "drop"
      ) %>%
      # On ajoute une modalité à l'autre variable de croisements (sinon => NA)
      mutate(
        cj = "Ensemble"
      )
  ) %>%
  # 4 - On ajoute le nombre total d'entreprises
  bind_rows(
    ent18_prepa %>%
      summarise(
        nb_ent = n()
      ) %>%
      # On ajoute une modalité à l'autre variable de croisements (sinon => NA)
      mutate(
        cj = "Ensemble",
        regsiege = "Ensemble"
      )
  )
