# Zillow Home Values

### **About the application**

This application is designed to monitor the average value of homes across the United States using data from Zillow. The user can compare home values on a county level using a line graph and interactive map.

The app can be ran locally, needing only two files: app.R and data.R. All data is downloaded from its source within the data.R file, so no external data is needed to run. Local copies of the data (from May 2020) are provided should either source be removed.

#### **Data source**

Data were compiled from [Zillow](https://www.zillow.com/research/data/) and the [tigris](https://cran.r-project.org/web/packages/tigris/tigris.pdf) package, which easily loads TIGER shapefiles from the United States Census Bureau into R. All these data are publically available. 

#### **Functionality**

On the *Plot and Table* tab, the user is presented with three inputs and two outputs. The plot allows the user to visualize the average home value over time in a specific state and for a specific size home (as determined by the number of bedrooms), which can be selected using the inputs to the left. The plot shows a line for each county in the state, and the red line is the county specified in the input. Below the plot, the table shows the filtered data used to build the plot, allowing the user to search for individual datapoints. 

The *Map* tab provides an overall visual of home values across the country for a specific year (1996 - 2020). The map is interactive and the user can pan and zoom to their will. Hovering over a specific county provides the user with the name of the county and the average home value for the year selected. The user can change the year and the size of the house with the inputs to the left. 

The *About the Data* tab provides the user with a general overview of the data behind the app and a link to the source code.
