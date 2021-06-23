# Kepler Problem

Solution to the two body Kepler Problem in pure Haskell! Completely analytical (except for a series approximation for a couple of functions that are asymptotic at zero)!

Run with

    runhaskell EllipticalOrbit.hs
    python3 plot.py --iselliptical

<img src="./elliptical_orbit.gif" alt="elliptical orbit gif" width="200">

    runhaskell HyperbolicOrbit.hs
    python3 plot.py --ishyperbolic

<img src="./hyperbolic_orbit.gif" alt="hyperbolic orbit gif" width="200">

For the elliptical or hyperbolic cases respectively.
