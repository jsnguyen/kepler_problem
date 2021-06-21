#!/usr/bin/python3

import numpy as np
import matplotlib.pyplot as plt

def main():
    filename = 'data.txt'
    xs = []
    ys = []
    vxs = []
    vys = []
    with open(filename, 'r') as f:
        for line in f:
            l = line.replace('[','').replace(']','').replace('(','').replace(')','').split(',')
            l = [float(el) for el in l]
            xs.append(l[0])
            ys.append(l[1])
            vxs.append(l[2])
            vys.append(l[3])

    XS,YS = np.meshgrid(xs,ys)
    fig, ax = plt.subplots(figsize=(4,4))

    ax.plot(xs,ys, linestyle='none', marker='o')
    ax.quiver(xs, ys, vxs, vys)

    ax.set_aspect('equal')
    ax.grid()
    plt.show()

if __name__=='__main__':
    main()
