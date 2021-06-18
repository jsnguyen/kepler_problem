import Data.List
import Debug.Trace

calcZ :: Double -> Double -> Double
calcZ x a = (x**2) / a

factorial :: (Integral a) => a -> a
factorial 0 = 1
factorial n = n * factorial (n - 1)

calcCTerm :: Double -> Int -> Double
calcCTerm z k = (-z)**(fromIntegral k) / (fromIntegral . factorial $ 2*k + 2)

calcCSeries :: Double -> Int -> Double
calcCSeries z k = sum [calcCTerm z i | i <- [0..k]]

calcSTerm :: Double -> Int -> Double
calcSTerm z k = (-z)**(fromIntegral k) / (fromIntegral . factorial $ 2*k + 3)

calcSSeries :: Double -> Int -> Double
calcSSeries z k = sum [calcSTerm z i | i <- [0..k]]

dot = (sum.) . zipWith (*)
norm = sqrt . sum . map (**2)

calcTn :: [Double] -> [Double] -> Double -> Double -> Double -> Double
calcTn r0 v0 mu xn a = do
    let z = calcZ xn a
    let c = calcCSeries z 4
    let s = calcSSeries z 4
    (dot r0 v0) / mu * xn**2 * c + (1 - (norm r0)/a) / (sqrt mu) * xn**3 * s + (norm r0)*xn / (sqrt mu)

calcf' :: [Double] -> [Double] -> Double -> Double -> Double -> Double
calcf' r0 v0 mu xn a = do
    let z = calcZ xn a
    let c = calcCSeries z 4
    let s = calcSSeries z 4
    xn**2 * c / (sqrt mu) + (dot r0 v0) / mu * xn * (1-z*s)  + (norm r0)*(1-z*c) / (sqrt mu)

newtonsMethod :: [Double] -> [Double] -> Double -> Double -> Double -> Double -> Double
newtonsMethod r0 v0 mu xn a t = do
    let tn = calcTn r0 v0 mu xn a
    let f' = calcf' r0 v0 mu xn a
    let xnp1 = xn + (t-tn)/f'
    if abs (t-tn) < 1e-6
        then xnp1
    else newtonsMethod r0 v0 mu xnp1 a t

constGMSun :: Double
constGMSun = 1.32712440018e11 -- km^3/s^2

auToKm :: Double
auToKm = 149597900 -- km

rEarth :: Double
rEarth = 1*auToKm

rMercury = 0.387*auToKm
vMercury = 47.36

vEarth :: Double
vEarth = 29.8 -- km/s

calcSpecificEnergy :: [Double] -> [Double] -> Double -> Double
calcSpecificEnergy v r mu = ((norm v)**2 / 2) - (mu/(norm r))

calcSemiMajorAxis :: Double -> Double -> Double
calcSemiMajorAxis mu epsilon = abs (mu / (2*epsilon))

main = do
    let r0 = [rEarth, 0     ]
    let v0 = [0     , vEarth]
    let mu = constGMSun
    let epsilon = calcSpecificEnergy v0 r0 mu
    let a = calcSemiMajorAxis mu epsilon

    let x0 = 0
    let t  = 6*2629800 -- six months in seconds
    print (newtonsMethod r0 v0 mu x0 a t)
    let res = [newtonsMethod r0 v0 mu x0 a i | i <-  [-j | j <- (reverse (map (**2) [1..1e4]))] ++  map (**2) [0..1e4]]
    writeFile "data.txt" . intercalate "\n" . map show $ res

