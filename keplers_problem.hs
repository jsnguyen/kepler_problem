import Data.List
import Debug.Trace

seriesOrder = 10
range start end step = takeWhile (<=end) $ iterate (+step) start

calcZ :: Double -> Double -> Double
calcZ x a = (x**2) / a

factorial :: (Integral a) => a -> a
factorial 0 = 1
factorial n = n * factorial (n - 1)

calcCTerm :: Double -> Int -> Double
calcCTerm z k = (-z)**(fromIntegral k) / (fromIntegral . factorial $ 2*k + 2)

zEpsilon = 1e-3

calcCSeries :: Double -> Int -> Double
calcCSeries z k
    | z < zEpsilon = sum [calcCTerm z i | i <- [0..k]]
    | otherwise = (1 - cos (sqrt z)) / z

calcSTerm :: Double -> Int -> Double
calcSTerm z k = (-z)**(fromIntegral k) / (fromIntegral . factorial $ 2*k + 3)

calcSSeries :: Double -> Int -> Double
calcSSeries z k
    | z < zEpsilon = sum [calcSTerm z i | i <- [0..k]]
    | otherwise = (sqrt z - sin (sqrt z)) / sqrt (z**3)

dot = (sum.) . zipWith (*)
norm = sqrt . sum . map (**2)

calcTn :: [Double] -> [Double] -> Double -> Double -> Double -> Double
calcTn r0 v0 mu xn a = do
    let z = calcZ xn a
    let c = calcCSeries z seriesOrder
    let s = calcSSeries z seriesOrder
    (dot r0 v0) / mu * xn**2 * c + (1 - (norm r0)/a) / (sqrt mu) * xn**3 * s + (norm r0)*xn / (sqrt mu)

calcF' :: [Double] -> [Double] -> Double -> Double -> Double -> Double
calcF' r0 v0 mu xn a = do
    let z = calcZ xn a
    let c = calcCSeries z seriesOrder
    let s = calcSSeries z seriesOrder
    xn**2 * c / (sqrt mu) + (dot r0 v0) / mu * xn * (1-z*s)  + (norm r0)*(1-z*c) / (sqrt mu)

newtonsMethod :: [Double] -> [Double] -> Double -> Double -> Double -> Double -> Double
newtonsMethod r0 v0 mu xn a t = do
    let tn = calcTn r0 v0 mu xn a
    let f' = calcF' r0 v0 mu xn a
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
calcSpecificEnergy r v mu = ((norm v)**2 / 2) - (mu/(norm r))

calcSemiMajorAxis :: Double -> Double -> Double
calcSemiMajorAxis mu epsilon = abs (mu / (2*epsilon))

calcF :: [Double] -> Double -> Double -> Double -> Double
calcF r0 mu x a = do
    let z = calcZ x a
    let c = calcCSeries z seriesOrder
    1 - x**2 / (norm r0) * c

calcG :: Double -> Double -> Double -> Double -> Double
calcG mu x a t = do
    let z = calcZ x a
    let s = calcSSeries z seriesOrder
    t - x**3 / (sqrt mu) * s

calcFDot :: [Double] -> [Double] -> Double -> Double -> Double -> Double
calcFDot r0 r mu x a = do
    let z = calcZ x a
    let s = calcSSeries z seriesOrder
    (sqrt mu) / ((norm r0) * (norm r)) * x * (z * s - 1)

calcGDot :: [Double] -> Double -> Double -> Double -> Double
calcGDot r mu x a = do
    let z = calcZ x a
    let c = calcCSeries z seriesOrder
    1 - x**2 / (norm r) * c

calcR :: Double -> Double -> [Double] -> [Double] -> [Double]
calcR f g r0 v0 = zipWith (+) (map (*f) r0) (map (*g) v0)

calcV :: Double -> Double -> [Double] -> [Double] -> [Double]
calcV fdot gdot r0 v0 = zipWith (+) (map (*fdot) r0) (map (*gdot) v0)

--keplersAlgorithm :: [Double] -> [Double] -> Double -> (Double,Double)
keplersAlgorithm :: [Double] -> [Double] -> Double -> ([Double],[Double])
keplersAlgorithm r0 v0 t = do
    let mu = constGMSun
    let epsilon = calcSpecificEnergy r0 v0 mu
    let a = calcSemiMajorAxis mu epsilon

    let x0 = (sqrt mu) * t / a
    let x = newtonsMethod r0 v0 mu x0 a t

    let f = calcF r0 mu x a
    let g = calcG mu x a t

    let r = calcR f g r0 v0

    let fdot = calcFDot r0 r mu x a
    let gdot = calcGDot r mu x a

    let v = calcV fdot gdot r0 v0
    
    --(t,x)
    (r,v)

main = do
    let r0 = [rEarth, 0     ]
    let v0 = [0     , 0.5*vEarth]
    let t  = 2629800 -- six months in seconds
    let yr = 31557600

    let mu = constGMSun
    let epsilon = calcSpecificEnergy r0 v0 mu
    let a = calcSemiMajorAxis mu epsilon
    
    let res = [keplersAlgorithm r0 v0 i | i <- (range (0*yr) (2*yr) 1e6) ]
    writeFile "data.txt" . intercalate "\n" . map show $ res
