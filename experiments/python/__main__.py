import numpy as np
import matplotlib.pyplot as plt
import soundfile as sf
import math

def getEnergy(samples):
    sum = math.sqrt(np.sum(np.square(samples))/len(samples))
    return sum

mean = 0
std = 1
num_samples = 48000
samples = list(np.random.normal(mean, std, size=num_samples))
#samples = [1]+[0]*(num_samples-1)

p = 12
fs = np.arange(0,1,0.1)
maxes = list()

for f in fs:
    samples = list(np.random.normal(mean, std, size=num_samples))
    #samples = [1,-1]*5+[0]*(num_samples-10)
    d_samples = list()
    for i in range(p):
        d_samples.append([0]*(475*(i+1))+[samples[i]*f for i in range(len(samples))])

    for ds in d_samples:
        samples = [samples[i]+ds[i] for i in range(len(samples))]

    samples = [sample / ((math.pow(f,1.35)*2.45+1.0)) for sample in samples]
    #samples = [sample / ((f*2+1.0)) for sample in samples]

    maxes.append(getEnergy(samples))

#print(len(samples))

#print(getEnergy(samples))

plt.plot(fs,maxes)
plt.show()

maximum = max(samples)
samples = [sample / maximum for sample in samples]

#sf.write('out.wav', samples, 48000)

