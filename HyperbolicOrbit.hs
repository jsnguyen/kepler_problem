import KeplerProblem

import Data.List

main = do
    let r0 = [1*rEarth, 0     ]
    let v0 = [0     , 1.6*vEarth]
    let mu = constGMSun
    let a = calcSemiMajorAxis r0 v0 mu

    let yr = 31557600 -- 1 yr in seconds

    let res = [keplerProblemSolution r0 v0 mu a i | i <- (range (-0.5*yr) (0.5*yr) 1e5) ]
    writeFile "data.txt" . intercalate "\n" . map show $ res
    putStrLn ("Done. Wrote data.txt!")
