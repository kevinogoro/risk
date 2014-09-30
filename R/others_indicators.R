psi_table <- function(values_ori, values_new, prefix_new = "new_"){
  
  t_ori <- freqtable(values_ori, add.total = FALSE)[,c(1,2,4)]
  t_new <- freqtable(values_new, add.total = FALSE)[,c(1,2,4)]
  
  names(t_new)[-1] <- paste(prefix_new, names(t_new)[-1], sep = "")
  
  psi_tbl <- join(t_ori, t_new, by = "category")
  
  psi_tbl$dif_dec <- psi_tbl[,5]-psi_tbl[,3]
  psi_tbl$coef <- psi_tbl[,5]/psi_tbl[,3]
  psi_tbl$w_ev <- log(psi_tbl[, 7])
  psi_tbl$idx <- psi_tbl[,6]*psi_tbl[,8]

  return(psi_tbl)

}
