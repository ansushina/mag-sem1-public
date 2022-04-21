# coding=utf-8
import random
import matplotlib.pyplot as plt
import numpy as np
from random import randint

epochs = 200
populationSize = 300
mapSize = 40


def genRoutes(n, lengthMax):
    result = []
    for i in range(n):
        t = np.arange(lengthMax)
        np.random.shuffle(t)
        result.append(t)
    return result


def getCostOfRoute(matrix, route):
    c = 0
    for i in range(len(route) - 1):
        c += matrix[route[i], route[i + 1]]
    c += matrix[route[len(route) - 1], route[0]]
    return c


def crossingover(sv1, sv2):
    v1 = list(sv1)
    v2 = list(sv2)


    randPos = randint(0, len(v1)-1)

    p1 = v1[:randPos]

    for i in range(len(v2)):
        if v2[i] not in p1:
            p1.append(v2[i])

    return p1


def mutation(v1):
    if random.random() < 0.005:
        print("mutation")
        p1 = random.randint(0, len(v1) - 1)
        p2 = random.randint(0, len(v1) - 1)
        t = v1[p1]
        v1[p1] = v1[p2]
        v1[p2] = t
    return v1


def get_rand(percentage):
    number = randint(0, 100)
    i = -1
    s = 0
    while s < number and i < len(percentage) -1 :
        i += 1
        s += percentage[i]
    return i


a = np.random.rand(mapSize, mapSize)
for i in range(mapSize):
    for j in range(i, mapSize):
        a[i][j] = a[j][i]
np.fill_diagonal(a, 0)
a = a * 100

routes = genRoutes(populationSize, mapSize)

m = a

historyForPlot = []


historyForPlot2 = []

for times in range(epochs):

    routes.sort(key=lambda e: getCostOfRoute(m, e), reverse=False)

    routesValues = [getCostOfRoute(m, e) for e in routes]

    valuesMax = max(routesValues) + 1
    diff = [valuesMax - r for r in routesValues]
    valuesSum = sum(diff)

    percentage = [diff[i] / valuesSum * 100 for i in range(len(routesValues))]

    count = len(routes)
    for k in range(count):
        p1 = get_rand(percentage)
        p2 = p1
        while p2 == p1:
            p2 = get_rand(percentage)
        child = crossingover(routes[p1], routes[p2])
        routes.append(mutation(child))

    routes.sort(key=lambda e: getCostOfRoute(m, e), reverse=False)

    k = randint(0, round(len(routes)/10))
    half  = round(len(routes)/2) - k
    routs_len = len(routes)
    routes = routes[:half] + routes[routs_len-k:]

    # print(routes)

    scores = []
    for e in routes:
        scores.append(getCostOfRoute(m, e))
    avgScore = np.average(scores)

    scores = []
    for e in routes:
        scores.append(getCostOfRoute(m, e))
    print("лучший маршрут : ", routes[0], " (длина =", np.round(scores[0], 2),
          ")")
    historyForPlot.append(avgScore)
    historyForPlot2.append(scores[0])

print(a)
plt.plot(historyForPlot)
plt.show()

plt.plot(historyForPlot2)
plt.show()