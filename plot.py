#!/usr/bin/python3

import numpy as np
import matplotlib.pyplot as plt

def main():
    filename = 'data.txt'
    xs = []
    with open(filename, 'r') as f:
        for line in f:
            xs.append(float(line))

    fig, ax = plt.subplots()
    ax.plot(xs)
    plt.show()

if __name__=='__main__':
    main()
