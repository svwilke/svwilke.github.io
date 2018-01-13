import numpy as np
import cv2
import sys

def nearest_index(centers, pixel):
	min_index = -1
	min = 10000000
	for index, center in enumerate(centers):
		if distance_sq(center, pixel) < min:
			min = distance_sq(center, pixel)
			min_index = index
	return min_index


def distance_sq(c1, c2):
	c3 = []
	for i in range(len(c1)):
		c3.append(c2[i] - c1[i])
	return sum([x ** 2 for x in c3])

def recalc(clusters, centers):
	for index, cluster in enumerate(clusters):
		if len(cluster) > 0:
			sum = [0, 0, 0]
			for pixel in cluster:
				for i in range(len(pixel)):
					sum[i] += pixel[i]
			sum = [x / len(cluster) for x in sum]
			centers[index] = sum
		else:
			centers[index] = np.random.randint(0, 256, 3)
	return centers

image = cv2.imread(sys.argv[1])

K = int(sys.argv[3])
E = int(sys.argv[4])

centers = np.random.randint(0, 256, (K, 3))

height, width, depth = image.shape

for epoch in range(E):
	clusters = []

	for index in range(len(centers)):
		clusters.append([])

	for line in image:
		for pixel in line:
			clusters[nearest_index(centers, pixel)].append(pixel)

	centers = recalc(clusters, centers)

for y, line in enumerate(image):
	for x, pixel in enumerate(line):
		image[y, x] = centers[nearest_index(centers, pixel)]

cv2.imwrite(sys.argv[2], image)

