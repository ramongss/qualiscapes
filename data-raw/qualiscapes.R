# load package
devtools::load_all(".")

# save the raw-data
qualiscapes <- get_qualis("data-raw/qualiscapes.csv")

# save in the package
usethis::use_data(qualiscapes, overwrite = TRUE)
