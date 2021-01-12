# Car Accidents in Chicago

## Introduction
  
This project goes through my process of analyzing 200,000 observations of car accidents in the city of Chicago.  In particular, I wanted to try and identify if there were any notable factors that were contributing to higher probabilities of injuries in these car accidents.  While not every city is the same, I believe some of these generalizations can be applied to driving conditions all over America to help us get a little bit more insight on what leads to car accidents & related injuries and how we keep ourselves as safe as possible.

## The Data
The dataset comes from the [City of Chicago](https://data.cityofchicago.org/), where they offer an API to search for and extract various data from a number of their different government departments.  For this project I chose to select all car accident report data from January 7th, 2019 to January 7th, 2021.  2 years of sample size gave me the right amount of data I felt comfortable working with, and was more than enough to help find meaningful insights.

Below are the 15 variables I chose to select for the analysis.

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

![crashtimeseries](https://user-images.githubusercontent.com/16946556/103946554-99a20180-50eb-11eb-9fdc-aa065bcd4ca7.png)

Very meaningful dropoff as a result of COVID-19 beginning in March of 2020.

![crashinjurypercent](https://user-images.githubusercontent.com/16946556/103946555-99a20180-50eb-11eb-9292-de126fd26b6e.png)

Seems to be an upward trend in % Chance of Injury from car accidents, but we'd need to look at a larger sample size and more historical data to know for sure.

![crashinjurywday](https://user-images.githubusercontent.com/16946556/103946553-99a20180-50eb-11eb-8633-310fa1936aae.png)
Weekends seem to carry a noticeably higher % chance of injuries from car accidents than weekdays do.

![crashmonthly](https://user-images.githubusercontent.com/16946556/103948906-6fead980-50ef-11eb-8193-18e8a39d6b7d.png)
It seems like the summer months tend to have a slightly higher % chance of car accident injuries than the winter months.  Keep in mind the sample size of the dataset is over 200,000 observations, so even a few % difference is meaningful.

![crashlightcond](https://user-images.githubusercontent.com/16946556/103946545-9870d480-50eb-11eb-8b2b-c7a950e6206b.png)
Driving at night appears to lead to higher probability of car accident injuries than driving during the day does.  That's probably something we could have guessed on our own, but it's interesting seeing the data actually affirm that belief.


One common phenomenon I found was that "UNKNOWN" was a pretty common fill in for most of the variables.  These car accident observations come from police reports, and the report is either made on the scene of the accident or back at the police department.  My guess is that a lot of these UNKNOWNS come from reports made at the police department where the police officers have less access to information, and/or simply don't see the need to accurately fill out every variable in the report.

![crashlatlong](https://user-images.githubusercontent.com/16946556/103946549-99096b00-50eb-11eb-8c48-6e7084dfb454.png)

The data also came with Latitude / Longtitude points that allow users to graph where every accident happened.  I'm not familiar with the layout of Chicago, but this could definitely be something worth looking into if you had more knowledge of the city and wanted to identify hot spots for car accidents so that you could make road changes such as adding signs & traffic signals to help better protect the safety of the citizens.

![crashnormalhr](https://user-images.githubusercontent.com/16946556/103946546-99096b00-50eb-11eb-86ac-e3abb3a33a6a.png)
I also analyzed the time of day of all the car accidents to see if anything significant stood out. Everything here seems pretty standard, you could do a deep dive on the time data and look at specific variables

![crashhralc](https://user-images.githubusercontent.com/16946556/103946543-97d83e00-50eb-11eb-99f3-f891f02b1bd9.png)
I took a subset of the original dataset and filtered out only the rows which had an alcohol-related cause, and re-did the time of day chart.  It's interesting how it's a complete reverse of the original chart, and how most of the accidents now occur throughout the night

![crashweather](https://user-images.githubusercontent.com/16946556/103946557-9a3a9800-50eb-11eb-9fd4-493df03cb1cc.png)
Weather is another important variable I believed would have an impact.  Fog and rain seem to be the most dangerous conditions to be driving in, and I was surprised snow was so far down the list.  People must be considerably more cautious during snow conditions, as well as more aware of their surrounds and their speed.

![crashprimcause](https://user-images.githubusercontent.com/16946556/103946771-eab1f580-50eb-11eb-9484-116f0397cfe0.png)
The final graph looks at Primary Contributory Causes of each car accident.  Disregarding traffic signals & signs, as well as the physical conditions of the driver seem to be the most likely causes to lead to injury.  Tying this data back to the longitude & latitude, graph, you could take a subset of the dataset and only filter out only the disregarding traffic signs cause and then analyze the lat/long plot to see if there were any areas in the city where maybe an additional traffic sign needs to be added.

![crashtypesbby](https://user-images.githubusercontent.com/16946556/103952188-d0c8e080-50f4-11eb-9275-099edd09024d.png)



