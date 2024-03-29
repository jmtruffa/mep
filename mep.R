library(tidyverse)
library(ggthemes)

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd('~/Google Drive/analisis financieros/mep/')
bonos_mep <- c("AL30", "AL30D", "GD30", "GD30D")


for (i in seq_along(bonos_mep)){
   download.file(paste('http://clasico.rava.com/empresas/precioshistoricos.php?e=',bonos_mep[i],'&csv=1', sep=''), paste('~/Google Drive/analisis financieros/mep/', bonos_mep[i], '.csv', sep =''), mode = 'wb')
   }

# for (i in bonos_mep){
#   download.file(paste0('https://www.rava.com/perfil/',i,'#:~:text=Bajar%20en-,formato,-Excel'), paste('~/Google Drive/analisis financieros/mep/', i, '.csv', sep =''), mode = 'wb')
# }


# pasar todo a map luego

al30 <- read_csv('AL30.csv')
al30d <- read_csv('AL30D.csv')
gd30 <- read_csv('GD30.csv')
gd30d <- read_csv('GD30D.csv')

#arreglo del 4-11
al30$cierre[al30['fecha'] == '2021-11-04'] = al30$cierre[al30['fecha'] == '2021-11-04'] * 1000
gd30$cierre[gd30['fecha'] == '2021-11-04'] = gd30$cierre[gd30['fecha'] == '2021-11-04'] * 1000

al30 <- al30 %>% select(fecha, cierre) %>% mutate(ticker = 'AL30')
al30d <- al30d %>% select(fecha, cierre) %>% mutate(ticker = 'AL30D')


gd30 <- gd30 %>% select(fecha, cierre) %>% mutate(ticker = 'GD30')
gd30d <- gd30d %>% select(fecha, cierre) %>% mutate(ticker = 'GD30D')


retail <- left_join(al30, al30d, by = 'fecha') %>% select (-ticker.x,-ticker.y) %>% drop_na() %>% mutate( mep = cierre.x / cierre.y)
idoneo <- left_join(gd30, gd30d, by = 'fecha') %>% select (-ticker.x,-ticker.y) %>% drop_na() %>% mutate( mep = cierre.x / cierre.y)

write_csv(retail, '~/Google Drive/analisis financieros/mep/mep-AL30.csv')
write_csv(idoneo, '~/Google Drive/analisis financieros/mep/mep-GD30.csv')
write_csv(al30, '~/Google Drive/analisis financieros/mep/AL30.csv')
write_csv(gd30, '~/Google Drive/analisis financieros/mep/GD30.csv')

grafretail <- retail %>% 
  group_by(fecha) %>%
  ggplot(aes(x = fecha, y = mep)) +
  geom_line() +
  theme_economist() +
  scale_x_date(date_breaks="1 month", date_labels="%Y %m") +
  scale_color_economist() +
  labs(title = "MEP con AL30",
       y = "calculado con precios de Cierre", x = "")

grafidoneo <- idoneo %>% 
  group_by(fecha) %>%
  ggplot(aes(x = fecha, y = mep)) +
  geom_line() +
  theme_economist() +
  scale_x_date(date_breaks="1 month", date_labels="%Y %m") +
  scale_color_economist() +
  labs(title = "MEP con GD30",
       y = "calculado con precios de Cierre", x = "")


#spread

spread = left_join(al30d, gd30d, by = 'fecha') %>% mutate(spread = cierre.x / cierre.y) %>% select(fecha, -cierre.x, -ticker.x, -cierre.y, -ticker.y, spread) %>% drop_na()

spread %>% 
  group_by(fecha) %>% 
  ggplot(aes(x = fecha, y=spread)) +
  geom_line() +
  theme_economist()+
  labs(title = "Spread AL30 / GD30",
       y = "calculado con precios de Cierre", x = "")

  



ggsave('~/Google Drive/analisis financieros/mep/MEPAL30.jpg', grafretail, units = "mm", width = 150, height = 75)
ggsave('~/Google Drive/analisis financieros/mep/MEPGD30.jpg', grafidoneo, units = "mm", width = 150, height = 75)
