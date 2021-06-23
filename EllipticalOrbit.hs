import KeplerProblem

import Data.List

main = do
    let r0 = [1*rEarth, 0     ]
    let v0 = [0     , 1.2*vEarth]
    let mu = constGMSun
    let a = calcSemiMajorAxis r0 v0 mu

    let period = calcPeriod mu a

    let res = [keplerProblemSolution r0 v0 mu a i | i <- (linspace 0 (1*period) 5e2) ]
    writeFile "data.txt" . intercalate "\n" . map show $ res
