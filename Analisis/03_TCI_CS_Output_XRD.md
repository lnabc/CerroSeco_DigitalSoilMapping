---
title: "TCI/Cerro Seco"
subtitle: "Resultados XRD"
author: "Carlos Guio"
date: "10.7.2021"
output:
  html_document:
    theme: journal
    highlight: tango
    keep_md: true
---








```
## 
## -- Column specification --------------------------------------------------------
## cols(
##   mine_largo = col_character(),
##   mine_corto = col_character(),
##   perfil = col_character(),
##   horizonte = col_character(),
##   porcentaje = col_double()
## )
```

## 

You can also embed plots, for example:


```r
p_riet_03 <- riet_03 %>%
  ggplot() +
  geom_waffle(aes(fill = mine_corto, values = porcentaje),
              show.legend = FALSE,
              size = 0.1, #lining spacing
              color = "white",
              flip = TRUE,
              radius = unit(2, "pt"))+
  coord_equal() +
  labs(fill = NULL, colour = NULL) +
  scale_fill_manual(values = unique(riet_03$colores))+
  facet_wrap(~horizonte, ncol = 1, strip.position = "left")+
  theme(plot.margin = margin(20, 10, 20, 10),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        plot.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        strip.placement = "outside",
        strip.text.y.left = element_text(colour = darken("#F5F2F1", 0.3, 
                                                       space = "HCL"), 
                                        face = "bold",
                                        angle = 0),
        strip.switch.pad.wrap = unit(0.5, "lines"))

p_riet_01 <- riet_01 %>%
  ggplot() +
  geom_waffle(aes(fill = mine_corto, values = porcentaje),
              show.legend = FALSE,
              size = 0.1, #lining spacing
              color = "white",
              flip = TRUE,
              radius = unit(2, "pt"))+
  coord_equal() +
  labs(fill = NULL, colour = NULL) +
  scale_fill_manual(values = unique(riet_01$colores))+
  facet_wrap(~horizonte, ncol = 1, strip.position = "left")+
  theme(plot.margin = margin(20, 10, 20, 10),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        plot.background = element_rect(fill = "white"),
        panel.grid = element_blank(),
        strip.placement = "outside",
        strip.text.y.left = element_text(colour = darken("#F5F2F1", 0.3, 
                                                       space = "HCL"), 
                                        face = "bold",
                                        angle = 0),
        strip.switch.pad.wrap = unit(0.5, "lines"))
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.





```r
mine_d_03 <- c(15, 10, 7.3, 4.5, 4.25, 4.175, 4.05, 3.75, 3.55, 3.35, 
            3.2, 2.98,2.71, 2.58, 2.52, 2.45)
mine_l_03 <- c("S", "I", "K/H", "","","G","C","F","","Q", "","Hb" ,"He","","", "")
mine_cols_03 <- c("#806dac","#c581a3","#9f742f","#9f742f","#2165aa","#eddc5e",
               "#38a6e3","#fc9681","#9f742f","#2165aa","#fc9681","#5ca22f",
               "#d26428", "#5ca22f", "#9f742f", "#2165aa")


DRX_CS03 <- DRX_df %>% dplyr::filter(ID == "CS03" & d < 17 & d > 2.295 )


p_xrd_03 <- ggplot() +
            geom_line(data = DRX_CS03 %>% dplyr::filter(TRATAMIENTO == "P"), 
                aes(x= d, y= I_plot), 
                size = 0.5,
                color = darken("#F5F2F1", 0.5, space = "HCL")) +
            geom_line(data = DRX_CS03 %>% dplyr::filter(TRATAMIENTO == "N"), 
                aes(x= d, y= I_plot), 
                size = 0.1,
                color = darken("#F5F2F1", 0.3, space = "HCL")) +
            geom_line(data = DRX_CS03 %>% dplyr::filter(TRATAMIENTO == "EG"), 
                aes(x= d, y= I_plot), 
                size = 0.1,
                color = darken("#F5F2F1", 0.3, space = "HCL")) +
            geom_line(data = DRX_CS03 %>% dplyr::filter(TRATAMIENTO == "C100"), 
                 aes(x= d, y= I_plot), 
                size = 0.1,
                color = darken("#F5F2F1", 0.3, space = "HCL")) +
            geom_text_repel(data = DRX_CS03,
                  aes(x = d, y = I_plot, color = TRATAMIENTO, label = ETIQUETA),
                  size = 2.5, #font size
                  colour = darken("#F5F2F1", 0.5, space = "HCL"),
                  family = "roboto",
                  hjust = 0,
                  direction = "y",
                  xlim = c(2.25, NA), #para que salgan de la gráfica
                  ylim = c(-0.8, NA), #para que salgan de la gráfica
                  nudge_x = 0.1,
                  segment.size = 0.4, #segment thickness
                  segment.curvature = -0.2, #curvature direction - for left
                  segment.alpha = .5,
                  segment.linetype = "dotted",
                  segment.ncp = 3,
                  segment.angle = 10,
                  point.padding = 0.05,
                  box.padding = 0.18) + #If too high, labels clump
            scale_y_continuous(limits = c(0,7), expand = c(0,0)) +
  #limits in scale_x_continuous would cut the line, not plot area: avoided
            scale_x_continuous(trans = trans_reverser('log10'), 
                     breaks= c(3,4,5, 7,10,15), 
                     labels = c(3,4,5,7,10,15),
                     sec.axis = sec_axis(~., breaks = mine_d_03,
                                         labels = mine_l_03))+
            facet_wrap(~ HZ, ncol = 1 ) + 
            labs(x = "distancia interplanar (Angstrom)")+
            theme(plot.margin = margin(20, 70, 20, 10), #top, right, bottom, left
                  panel.grid = element_line(colour = "white"),
                  axis.ticks.x.top =element_line(
                                  size = 0.1,
                                  arrow = arrow(length = unit(0.4, "lines"), 
                                                ends = "first", 
                                                type = "closed"),
                                                color = mine_cols_03),
                  axis.text.x = element_text(
                                  color = darken("#F5F2F1", 
                                                 0.3, 
                                                 space = "HCL")),
                  axis.text.x.top = element_text(margin = margin(0,0,16,0),
                                                 color = mine_cols_03,
                                                 size = 8,
                                                 face = "bold"),
                  axis.title.x.bottom = element_text(
                                  margin = margin(16, 0, 0, 0)),
                  strip.text = element_blank(),
                  legend.position = "none") +
                  # with coord_cartesian the limits cut the plot area
                  coord_cartesian(xlim = c(15.1, 2.54), ylim = c(0, 7), clip = "off") 
```


```r
mine_d_01 <- c(7.3, 4.5, 4.25, 4.175, 4.05, 3.75, 3.55, 3.35, 
            3.2, 2.98,2.71, 2.58, 2.52, 2.45)
mine_l_01 <- c("K/H", "","","G","C","F","","Q", "", "Hb" ,"He","","", "")
mine_cols_01 <- c("#9f742f","#9f742f","#2165aa","#eddc5e",
               "#38a6e3","#fc9681","#9f742f", "#2165aa","#fc9681", "#5ca22f",
               "#d26428", "#5ca22f", "#9f742f", "#2165aa")

DRX_CS01 <- DRX_df %>% dplyr::filter(ID == "CS01" & d < 15 & d > 2.295 )


p_xrd_01 <- ggplot() +
            geom_line(data = DRX_CS01 %>% dplyr::filter(TRATAMIENTO == "P"), 
                aes(x= d, y= I_plot), 
                size = 0.5,
                color = darken("#F5F2F1", 0.5, space = "HCL")) +
            geom_line(data = DRX_CS01 %>% dplyr::filter(TRATAMIENTO == "N"), 
                aes(x= d, y= I_plot), 
                size = 0.1,
                color = darken("#F5F2F1", 0.3, space = "HCL")) +
            geom_line(data = DRX_CS01 %>% dplyr::filter(TRATAMIENTO == "EG"), 
                aes(x= d, y= I_plot), 
                size = 0.1,
                color = darken("#F5F2F1", 0.3, space = "HCL")) +
            geom_line(data = DRX_CS01 %>% dplyr::filter(TRATAMIENTO == "C100"), 
                 aes(x= d, y= I_plot), 
                size = 0.1,
                color = darken("#F5F2F1", 0.3, space = "HCL"))+
            geom_text_repel(data = DRX_CS01,
                  aes(x = d, y = I_plot, color = TRATAMIENTO, label = ETIQUETA),
                  size = 2.5, #font size
                  colour = darken("#F5F2F1", 0.5, space = "HCL"),
                  family = "roboto",
                  hjust = 0,
                  direction = "y",
                  xlim = c(2.25, NA), #para que salgan de la gráfica
                  ylim = c(-0.8, NA), #para que salgan de la gráfica
                  nudge_x = 0.1,
                  segment.size = 0.4, #segment thickness
                  segment.curvature = -0.2, #curvature direction - for left
                  segment.alpha = .5,
                  segment.linetype = "dotted",
                  segment.ncp = 3,
                  segment.angle = 10,
                  point.padding = 0.05,
                  box.padding = 0.18) + #If too high, labels clump
            scale_y_continuous(limits = c(0,8), expand = c(0,0)) +
  #limits in scale_x_continuous would cut the line, not plot area: avoided
            scale_x_continuous(trans = trans_reverser('log10'), 
                     breaks= c(3,4,5, 7,10), 
                     labels = c(3,4,5,7,10),
                     sec.axis = sec_axis(~., breaks = mine_d_01,
                                         labels = mine_l_01))+
            facet_wrap(~ HZ, ncol = 1 ) + 
            labs(x = "distancia interplanar (Angstrom)")+
            theme(plot.margin = margin(20, 70, 20, 10), #top, right, bottom, left
                  panel.grid = element_line(colour = "white"),
                  axis.ticks.x.top =element_line(
                                  size = 0.1,
                                  arrow = arrow(length = unit(0.4, "lines"), 
                                                ends = "first", 
                                                type = "closed"),
                                                color = mine_cols_01),
                  axis.text.x = element_text(
                                  color = darken("#F5F2F1", 
                                                 0.3, 
                                                 space = "HCL")),
                  axis.text.x.top = element_text(margin = margin(0,0,16,0),
                                                 color = mine_cols_01,
                                                 size = 8,
                                                 face = "bold"),
                  axis.title.x.bottom = element_text(
                                  margin = margin(16, 0, 0, 0)),
                  strip.text = element_blank(),
                  legend.position = "none") +
                  # with coord_cartesian the limits cut the plot area
                  coord_cartesian(xlim = c(14, 2.5), ylim = c(0, 8), clip = "off") 
```


<img src="03_TCI_CS_Output_XRD_files/figure-html/layout_01-1.png" width="70%" style="display: block; margin: auto;" />

<img src="03_TCI_CS_Output_XRD_files/figure-html/layout_03-1.png" width="70%" style="display: block; margin: auto;" />
