import csv as csv
import numpy as np
from random import uniform
import math
import pandas as pd

data = pd.read_csv('./csv/train.csv')

fare_ceiling = 40
# then modify the data in the Fare column to = 39, if it is greater or equal to the ceiling
data[ data.Fare >= fare_ceiling] = fare_ceiling - 1.0
data['Gender']=df.Sex.map({'female':0,'male':1})
fare_bucket = 10

# Fill the missing ages
age_median = {}
for i in range (0, 2):
        for j in range (1,4):
                age_median[(i+j*3)] = data[(data['Gender'] == i) & (data['Pclass'] == j)].Age.median()
data['AgeNew'] = data.apply(lambda x: age_median.get(x.Gender + 3*x.Pclass) if math.isnan(x.Age) else x.Age, axis=1)

survive = {}

for i in xrange(3):
    for j in xrange(4):
        for k in xrange(5):
            female = data[(data.Gender==0) & (data.Pclass==(i+1)) \
            & (data.Fare>=j*fare_bucket) & (data.Fare < (j+1)*fare_bucket)\
            & (data.AgeNew>(k*20)) & (data.AgeNew<=((k+1)*20))]
            key = 0 + 10*i + 100*j + 1000*k
            survive[key] = female.Survived.mean();
        
            male = data[(data.Gender==1) & (data.Pclass==(i+1)) \
            & (data.Fare>=j*fare_bucket) & (data.Fare < (j+1)*fare_bucket)\
            & (data.AgeNew>(k*20)) & (data.AgeNew<=((k+1)*20))]
            key = 1 + 10*i + 100*j + 1000*k
            survive[key] = male.Survived.mean();

test_file = open('./csv/test.csv', 'rb')
test_file_object = csv.reader(test_file)
header = test_file_object.next()

prediction_file = open("genderbasedmodel.csv", "wb")
prediction_file_object = csv.writer(prediction_file)
prediction_file_object.writerow(["PassengerId", "Survived"])



for row in test_file_object:       # For each row in test.csv
    i = 0 if row[3] == 'female' else 1
    j = int(row[1]) - 1
    #print row[0], row[8]
    k = 0 if not row[8] else float(row[8]) // 10
    k = k if k <=3 else 3
    l = 4 if not row[4] else float(row[4]) // 20
    p = survive.get(i + 10*j + 100*k + 1000*l)
    
    if round(uniform(0,1),2) < p:
        prediction_file_object.writerow([row[0],'1'])    # predict 1
    else:
        prediction_file_object.writerow([row[0],'0'])    # predict 0
            
test_file.close()
prediction_file.close()

