# Car Accidents in Chicago

## Introduction
  
This project goes through my process of analyzing 200,000 observations of car accidents in the city of Chicago.  In particular, I wanted to try and identify if there were any notable factors that were contributing to higher probabilities of injuries in these car accidents.  While not every city is the same, I believe some of these generalizations can be applied to driving conditions all over America to help us get a little bit more insight on what leads to car accidents & related injuries and how we keep ourselves as protected as possible.

## The Data
The dataset comes from the [City of Chicago](https://data.cityofchicago.org/), where they offer an API to search for and extract various data from a number of their different departments.  For this project I chose to select all car accident report data from January 7th, 2019 to January 7th, 2021.  2 years of sample size gave me the right amount of data I felt comfortable working with, and was more than enough to help find meaningful insights.

Below are the 15 variables I chose to select for all of my analysis.

Categorical Variables      | Continuous Variables    
-------------------------- | ---------------------- 
Primary Contributory Cause | Injuries  
Report Type                | Crash Date 
Traffic Way Type           | Posted Speed Limit
Lighting Condition         | Latitude
Roadway Surface Condition  | Longitude
First Crash Type           | Number of Cars Involved
Weather Condition
Hour
Month


## Exploratory Data Analysis

![crashhralc](https://user-images.githubusercontent.com/16946556/103946543-97d83e00-50eb-11eb-99f3-f891f02b1bd9.png)
![crashlightcond](https://user-images.githubusercontent.com/16946556/103946545-9870d480-50eb-11eb-8b2b-c7a950e6206b.png)
![crashnormalhr](https://user-images.githubusercontent.com/16946556/103946546-99096b00-50eb-11eb-86ac-e3abb3a33a6a.png)
![crashlatlong](https://user-images.githubusercontent.com/16946556/103946549-99096b00-50eb-11eb-8c48-6e7084dfb454.png)
![crashmonthly](https://user-images.githubusercontent.com/16946556/103948346-7cbafd80-50ee-11eb-8faa-de1fe80406b2.png)
![crashinjurywday](https://user-images.githubusercontent.com/16946556/103946553-99a20180-50eb-11eb-8633-310fa1936aae.png)
![crashtimeseries](https://user-images.githubusercontent.com/16946556/103946554-99a20180-50eb-11eb-9fdc-aa065bcd4ca7.png)
![crashinjurypercent](https://user-images.githubusercontent.com/16946556/103946555-99a20180-50eb-11eb-9292-de126fd26b6e.png)
![crashweather](https://user-images.githubusercontent.com/16946556/103946557-9a3a9800-50eb-11eb-9fd4-493df03cb1cc.png)
![crashprimcause](https://user-images.githubusercontent.com/16946556/103946771-eab1f580-50eb-11eb-9484-116f0397cfe0.png)



