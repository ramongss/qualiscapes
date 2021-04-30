#' Get the 2019 Qualis CAPES database
#'
#' Read the dataset from preliminary 2019 Qualis CAPES database, saving in a
#' CSV file according to the argument `file`. Data available in:
#' <https://github.com/enoches/Qualis_2019_preliminar>.
#'
#' @param file Path to save the base (must be a CSV file)
#' @param ... Other arguments passed by [readr::write_csv()]
#'
#' @return Invisible, the updated base
#'
#' @export
get_qualis <- function(file, ...) {
  qualiscapes <- readr::read_rds(url("https://github.com/enoches/Qualis_2019_preliminar/raw/master/processamento-e-analise/dados-da-analise/novo_qualis_preliminar.rds"))
  readr::write_csv(qualiscapes, file, ...)
}
