
library(tidyverse)
library(rgdal) #leer polígono
library(sf) #manipular objetos espaciales tipo sf
library(raster) #manipular objetos raster
library(osmdata) #obtener datos de osm
library(ggplot2)
library(aqp) #Munsell to HEX colors
library(showtext) #fuentes de goolge
library(colorspace) #lighten or darken colors
library(ggrepel) #etiquetas 
library(ggsn) #escala gráfica
library(gggibbous) #moons with grain size %
library(patchwork) #plot + inset

knitr::opts_chunk$set(include = FALSE, echo = FALSE, warning = FALSE, message = FALSE, fig.align="center", fig.showtext = TRUE, fig.retina = 1, dpi = 300, out.width = "70%")

showtext_auto()


# Cargar datos de perfiles
hz <- readr::read_csv('https://raw.githubusercontent.com/cmguiob/TCI_CerroSeco_git/main/Datos/Suelos_CS_Horiz.csv')

#Select four profiles and relevant properties for plot
hz4 <- hz %>%
  dplyr::filter(ID %in% c("CS01", "CS02","CS03","CS04")) %>%
  dplyr::select(ID, BASE, TOPE, ESP, HZ, CON_POR, MX_H, MX_V, MX_C, CON_H, CON_V, CON_C, ARENA, LIMO, ARCILLA )



# Posibles escalas de color
col_scp <- c('#6AB6AA', '#4B6E8E', '#F9C93C', '#DA7543')
col_ito <- c('#56B4E9', '#009E73',"#E69F00", "#D55E00")

# Obtener fuentes
font_add_google(name = "Roboto Condensed", family= "robotoc")
font_add_google(name = "Roboto", family= "roboto")


# Definir theme
theme_set(theme_minimal(base_family = "roboto"))

theme_update(panel.grid = element_blank(),
             axis.text = element_text(family = "robotoc",
                                        color = "#c3beb8"),
             axis.title = element_blank(),
             axis.ticks.x =  element_line(color = "#c3beb8", size = .7),
             axis.ticks.y.right =  element_line(color = "#c3beb8", size = .7),
             legend.position = c(0,0.85),
             legend.direction = "vertical", 
             legend.box = "horizontal",
             legend.title = element_text(size = 13, 
                                         face = "bold", 
                                         color = "grey20", 
                                         family = "roboto"),
             legend.text = element_text(size = 10, 
                                        color = "#c3beb8", 
                                        family = "robotoc",
                                        face = "bold"),
             legend.key.size = unit(0.8, "cm"))



# Create color variables
hz4$RGBmx <- munsell2rgb(hz4$MX_H, hz4$MX_V, hz4$MX_C)
hz4$RGBco <-munsell2rgb(hz4$CON_H,hz4$CON_V , hz4$CON_C)

#Factor horizons to order
hz_bdf <- hz4 %>%
  dplyr::mutate(ID_HZ = paste(ID, HZ), #this orders by rownumber
         ID_HZ2 = factor(ID_HZ, ID_HZ)) %>%
  rowwise() %>%
  dplyr::mutate(GRUESOS = sum(ARENA,LIMO))%>%
  dplyr::mutate(GRANU_TOT = sum(ARENA + LIMO + ARCILLA))
  
hz_jdf <-  hz4 %>%
  dplyr::mutate(ID = factor(ID),
         ID_HZ = paste(ID, HZ), 
         ID_HZ2 = factor(ID_HZ, ID_HZ))%>% #order by rwonumber
  dplyr::mutate(CON_POR = ifelse(CON_POR == 0, 1, CON_POR), #handle 0% concen.
         n = 5*ESP*CON_POR / 100, #n for random number generation
         mean = 0.5*(BASE - TOPE), # mean for random number generation
         sd = 0.1*ESP)%>% #standard deviation for random number geneartion
  dplyr::mutate(samples = pmap(.[c("n","mean","sd")], rnorm))%>%
  unnest(samples)

# Points for jitter:
# mean: BASE - TOPE/2, sd = x*ESP, n = 5*CON_POR*ESP/100
# The problem with n: calculated with a multiple three rule, assuming that 1cm 
# which is 100% saturated has 5 concentrations, i.e. the size of concentrations is 2mm

head(hz_bdf, 10)


df_moon <- data.frame(x = 0, y = 0, ratio = c(0.25, 0.75), right = c(TRUE, FALSE))  

p_moon <-  ggplot() +
  geom_moon(data = df_moon[1,], 
            aes(x = x , y = y ,ratio = ratio, right = right), 
            size = 10, 
            fill = darken("#c3beb8", 0.3, space = "HCL"),
            color = darken("#c3beb8", 0.3, space = "HCL"))+
  geom_text(data = df_moon[1,],
            aes(x = x, y = y + 0.3, label = "25% arcilla"),
            size = 3.5,
            family = "roboto",
            fontface = "bold",
            col = darken("#c3beb8", 0.3, space = "HCL"))+
    annotate(geom = "curve", 
             x = 0.06, 
             y = 0,
             xend = 0.1, 
             yend = 0.2, 
             curvature = 0.4,
             col = darken("#c3beb8", 0.3, space = "HCL"),
             size = 0.5)+
    geom_moon(data = df_moon[2,], 
            aes(x = x , y = y ,ratio = ratio, right = right), 
            size = 10, 
            fill = lighten("#c3beb8", 0.1, space = "HCL"),
            color = lighten("#c3beb8", 0.1, space = "HCL"))+
  geom_text(data = df_moon[2,],
            aes(x = x, y = y - 0.3, label = "75% arena & limo"),
            size = 3.5,
            family = "roboto",
            fontface = "bold",
            col = lighten("#c3beb8", 0.1, space = "HCL")) +
    annotate(geom = "curve", 
             x = -0.06, 
             y = 0,
             xend = -0.1, 
             yend = -0.2, 
             curvature = 0.4,
             col = lighten("#c3beb8", 0.1, space = "HCL"),
             size = 0.5)+
    lims(x = c(-0.5,0.5), y = c(-1, 1))+
  theme_void()




p_perfiles <- ggplot(hz_bdf, aes(x = reorder(ID, desc(ID)), y = ESP, fill = forcats::fct_rev(ID_HZ2))) + 
  geom_bar(position="stack", stat="identity", width = 0.35) +
  scale_fill_manual(values = rev(hz_bdf$RGBmx),
                    guide = FALSE) +
  geom_text_repel( data = hz_bdf,   
                   aes(y = BASE - (ESP/3), label = HZ),
                   color = darken(hz_bdf$RGBmx, .2, space = "HCL"),
                   size = 3,
                   face = "bold",
                   family = "robotoc",
                   hjust = 0,
                   direction = "y",
                   nudge_x = 0.3,
                   nudge_y = -3,
                   segment.size = .5,
                   segment.square = TRUE,
                   segment.curvature = 0.1,
                   segment.angle = 40,
                   segment.alpha = 0.5,
                   box.padding = 0.3)+
  #y: location from where jitter spreads out vertically, i,e. from the base minus half the tickness
  geom_jitter(data = hz_jdf, aes(x = ID, y = BASE - (ESP/2)),  
              width = 0.15, 
              # height: how far jitter spreads out to each side, i.e. half the tickness
              height = hz_jdf$ESP*0.5,
              size = 0.3,
              col = hz_jdf$RGBco,
              shape = 16)+
  geom_moon(data = hz_bdf %>% dplyr::filter(!is.na(ARCILLA)), aes(x = ID, 
                               y = BASE - (ESP/2), 
                               ratio = ARCILLA/100), 
             size = 4,
             right = TRUE,
             fill = darken("#c3beb8", 0.3, space = "HCL"),
             color = darken("#c3beb8", 0.3, space = "HCL"),
             position = position_nudge(x = -0.3))+
  geom_moon(data = hz_bdf %>% dplyr::filter(!is.na(ARENA)), aes(x = ID, 
                               y = BASE - (ESP/2), 
                               ratio = GRUESOS/100), 
             size = 4,
             right = FALSE,
             fill = lighten("#c3beb8", 0.1, space = "HCL"),
             color = lighten("#c3beb8", 0.1, space = "HCL"),
             position = position_nudge(x = -0.3))+
  geom_hline(yintercept = 0, col = '#f2d29b')+
  scale_y_reverse(breaks = c(0,100,200,300,400,500), 
                  labels=c("0", "100", "200", "300", "400", "500\ncm"))+
  scale_x_discrete(position = "top") +
  theme(axis.text.x = element_text(family = "robotoc",
                           colour = c('#DA7543','#DA7543','#4B6E8E', '#6AB6AA'),
                           face = "bold"),
               axis.ticks.x =  element_blank(),
        panel.grid.major.y = element_line(color = "#c3beb8", size = .4, linetype = c("13"))) +
  coord_cartesian(clip = "off")



p_layout <- p_perfiles + inset_element(p_moon, 0.62, -0.17, 1.12, 0.53) # l, b, r, t

p_layout



ggsave(file = "perfiles.png", plot = p_layout, device = "png", type = "cairo", path = here::here("graficas"), dpi = 300)

