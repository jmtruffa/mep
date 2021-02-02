setwd('~/Documents/Data/mep/')
bonos_mep <- c("AL30", "AL30D", "GD30", "GD30D")


for (i in seq_along(bonos_mep)){
  download.file(paste('http://www.rava.com/empresas/precioshistoricos.php?e=',bonos_mep[i],'&csv=1', sep=''), paste(bonos_mep[i], '.csv', sep =''), mode = 'wb')
  }
