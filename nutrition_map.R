library(leaflet)
library(rgdal)
library(ggplot2)

#I merged the data with the shape file and saved it as a geojson
nut_data <- readOGR("ssd_nutrition_cluster_gam_2022.geojson")
plot(nut_data)



#get rid of percentage sign and convert to number
nut_data$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022 <- sapply(gsub("(?<=\\d)%", "",
                                                                      nut_data$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022, perl = T), as.numeric)
#remove nulls
nut_data_final <- subset(nut_data, nut_data$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022 != 0)

#checking the mean
summary(nut_data_final$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022)

# gam_bins <- c(0, 5, 10, 15, 20, 25, 30)
#
# gam_APal <- colorBin("YlOrRd", domain = nut_data_final$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022, bins = gam_bins)

#optional bin options
# gam_APal <- colorQuantile(palette = "YlOrRd", nut_data$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022, n=5)

#set colour ramp
pal <- colorNumeric(
  palette = "YlOrRd",
  domain = nut_data_final$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022)

#set pop-up content
nut_data_final$popup <- paste("<strong>",nut_data_final$ADM2_EN,"</strong>", "</br>",
                    nut_data_final$ADM1_EN, "</br>",
                    "Proxy GAM as of Dec 2022:",
                    prettyNum(paste0("<strong>",nut_data_final$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022,"<strong>"), big.mark = ","))

#create map
m <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = nut_data_final,
              stroke = T,
              weight = 0.2,
              smoothFactor = 0.3,
              color = "#ABABAB",
              opacity = 0.9,
              popup = ~popup,
              label = nut_data_final$ADM2_EN,
              highlightOptions = highlightOptions(color = "#E2068A", weight = 1.5,
                                                  bringToFront = TRUE, fillOpacity = 0.5),
              fillColor = ~pal(ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022),
              fillOpacity = 0.8) %>%
  addLegend("bottomright", pal = pal, values = nut_data_final$ssd_nutrition_cluster_gam_2022_Proxy.GAM.2022,
            title = "Proxy GAM South Sudan,</br> Dec 2022</br> Source: SSD Nutrition Cluster/UNICEF",
            labFormat = labelFormat(suffix = "%"),
            opacity = 1,
  )


m


# To find colour scale There are two ways of doing this, once with building the plot and once without building the plot.

# If we build the plot;

#library(ggplot2)

#df <- data.frame(x = 1:10, y = 1:10, col = 11:20)

#ggplot(df) +
  #geom_point(aes(x = x, y = y, colour = col))


# We can extract the scale and use it to retrieve the relevant information.

# Using build plot
#build <- ggplot_build(last_plot())

#scale <- build$plot$scales$get_scales("colour")
#breaks  <- scale$get_breaks()
#colours <- scale$map(breaks)

#data.frame(breaks = breaks, colours = colours)
#>   breaks colours
#> 1     NA  grey50
#> 2   12.5 #1D3F5E
#> 3   15.0 #2F638E
#> 4   17.5 #4289C1
#> 5   20.0 #56B1F7
# Alternatively, we can skip building the plot and use the scales themselves directly, provided we 'train' the scales by showing it the limits of the data.

#scale  <- scale_colour_continuous()
#scale$train(range(df$col))
#breaks  <- scale$get_breaks()
#colours <- scale$map(breaks)

#data.frame(breaks = breaks, colours = colours)
