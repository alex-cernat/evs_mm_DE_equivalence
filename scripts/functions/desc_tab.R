## function to describe variables
##

desc_tab <- function(x, lab_warn = TRUE) {
  freq_tab <- cbind(table(x, useNA = "always"))
  prop_tab <- round(prop.table(freq_tab), 3)

  # make label coloumn
  lab_tab <- row.names(freq_tab)

  tab <- data.frame(
    Code = lab_tab,
    Freq. = as.numeric(freq_tab),
    Perc. = as.numeric(prop_tab) * 100
  )

  # prin quesiton if it's present
  if (!is.null(attr(x, "label", exact = TRUE))) {
    print(attr(x, "label"))
  }

  if (length(attr(x, "labels")) > 1) {

    attribute_lab <- attr(x, "labels")
    labs <- data.frame(Code = as.numeric(na.omit(attribute_lab)),
                       Labels = names(na.omit(attribute_lab)))
    tab <- merge(tab, labs, by = "Code", all.x = T)

    tab <- tab[, c(1, 4, 2:3)]
  }

  tab
}
