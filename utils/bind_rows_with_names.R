bind_rows_with_names <- function (mylist) {
  df <- dplyr::bind_rows(mylist)
  df$id <- rep(names(mylist), sapply(mylist, nrow))
  df %>% dplyr::select(id, everything())
}
