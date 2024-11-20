/*
* DB Assignment 5
* Erin Zahner
* 22 November 2024
* */


/************************************************************************
* 1. Over how many years was the unemployment data collected?
 ************************************************************************/
db.unemployment.aggregate([
    { $group: { _id: "$Year" } },
    { $count: "numYears" }
])


/************************************************************************
* 2. How many states were reported on in this dataset?
 ************************************************************************/
db.unemployment.aggregate([
    { $group: { _id: "$State" } },
    { $count: "numStates" }
])


/************************************************************************
* 3. What does this query compute?
 ************************************************************************/
db.unemployment.find({Rate : {$lt: 1.0}}).count()



/************************************************************************
* 4. Find all counties with unemployment rate higher than 10%
 ************************************************************************/
db.unemployment.aggregate([
    { $match: { Rate: { $gt: 10.0 } } },
    { $group: { _id: "$County" } }
])




/************************************************************************
* 5. Calculate the average unemployment rate across all states.
 ************************************************************************/
db.unemployment.aggregate([
    { $group: { _id: null, averageRate: { $avg: "$Rate" } } }
])



/************************************************************************
* 6. Find all counties with an unemployment rate between 5% and 8%.
 ************************************************************************/
db.unemployment.aggregate([
    { $match: { Rate: { $gte: 5.0, $lte: 8.0 } } },
    { $group: { _id: "$County" } }
])




/************************************************************************
* 7. Find the state with the highest unemployment rate.
 * Hint. Use { $limit: 1 }
 ************************************************************************/
db.unemployment.aggregate([
    { $sort: { Rate: -1 } },
    { $limit: 1 }
])




/************************************************************************
* 8. Count how many counties have an unemployment rate above 5%.
 ************************************************************************/
db.unemployment.aggregate([
    { $match: { Rate: { $gt: 5.0 } } },
    { $group: { _id: "$County" } },
    { $count: "countiesAbove5Percent" }
])




/************************************************************************
* 9. Calculate the average unemployment rate per state by year.
 ************************************************************************/
db.unemployment.aggregate([
    { $group: {
        _id: { state: "$State", year: "$Year" },
        averageRate: { $avg: "$Rate" }
        }
    }
])




/************************************************************************
* 10. (Extra Credit) For each state, calculate the total unemployment
 * rate across all counties (sum of all county rates).
 ************************************************************************/
db.unemployment.aggregate([
    { $group: {
         _id: { state: "$State", year: "$Year" },
         totalRate: { $sum: "$Rate" }
      }
    }
])




/************************************************************************
* 11. (Extra Credit) The same as Query 10 but for states with
 * data from 2015 onward
 ************************************************************************/
db.unemployment.aggregate([
    { $match: { Year: { $gte: 2015 } } },
    {  $group: {
          _id: { state: "$State", year: "$Year" },
          totalRate: { $sum: "$Rate" }
      }
    }
])

