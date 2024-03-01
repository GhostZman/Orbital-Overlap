//
//  Orbital.swift
//  Orbital Overlap
//
//  Created by Phys440Zachary on 2/28/24.
//

import Foundation
import Observation

@Observable class Orbital {
    
    let bohrRadius = 0.529177210903 //Angstrom
    
    
    func findOverlap(spacing: Double, atomicNumber: Int, upperBounds: [Double], lowerBounds: [Double]) {
        
    }
    
    func cartesianToSpherical(xCoordinate: Double, yCoordinate: Double, zCoordinate: Double) -> [Double] {
        
        let r: Double = sqrt(pow(xCoordinate, 2)+pow(yCoordinate, 2)+pow(zCoordinate, 2))
        let theta: Double = acos(zCoordinate/r)
        let phi: Double = atan2(yCoordinate,xCoordinate)
        
        return [r, theta, phi]
    }
    
    func sphericalToCartesian(rCoordinate: Double, thetaCoordinate: Double, phiCoordinate: Double) -> [Double] {
        
        let x = rCoordinate*cos(phiCoordinate)*sin(thetaCoordinate)
        let y = rCoordinate*sin(phiCoordinate)*sin(thetaCoordinate)
        let z = rCoordinate*cos(thetaCoordinate)
        
        return [x,y,z]
    }
    
    func waveFunction1s(rCoordinate: Double, atomicNumber: Int) -> Double {
        return (1.0/sqrt(Double.pi))*pow((Double(atomicNumber)/self.bohrRadius), (3/2))*exp((-Double(atomicNumber)*rCoordinate)/(self.bohrRadius))
    }
    
    func distanceFormula(coordinates1: [Double], coordinates2: [Double]) -> Double {
        
        var sum: Double = 0.0
        
        for dim in 0...coordinates1.count - 1 {
            sum += pow(coordinates2[dim] - coordinates1[dim], 2)
        }
        
        return sqrt(sum)
    }
    
    /// Calculates the overlapping wave functions of 2 1s orbitals at some point
    /// - Parameters:
    ///   - separation: Separation between the 2 atoms in Angstrom
    ///   - atomicNumber1: Atomic number of the first atom
    ///   - atomicNumber2: Atomic number of the second atom
    ///   - testCoordinates: Cartesian coordinates [x, y, z]  at which to evaluate the wave function overlap
    func overlapping1sWaveFunctions(separation: Double, atomicNumber1: Int, atomicNumber2: Int, testCoordinates:[Double]) -> Double {
        
        let atom1Coordinates: [Double] = [separation/2.0, 0, 0]
        let atom2Coordinates: [Double] = [(-1)*separation/2.0, 0, 0]
        
        let distanceAtom1ToTest = distanceFormula(coordinates1: atom1Coordinates, coordinates2: testCoordinates)
        let distanceAtom2ToTest = distanceFormula(coordinates1: atom2Coordinates, coordinates2: testCoordinates)
        
        let waveFunction1 = waveFunction1s(rCoordinate: distanceAtom1ToTest, atomicNumber: atomicNumber1)
        let waveFunction2 = waveFunction1s(rCoordinate: distanceAtom2ToTest, atomicNumber: atomicNumber2)
        
        return waveFunction1*waveFunction2
    }
    
    func monteCarloMVT(upperBounds: [Double], lowerBounds: [Double], numGuess: Int, functionToIntegrate: (Double, Int) -> Double, atomicNumber: Int) async -> Double {
        let meanValue = await withTaskGroup(of: Double.self, returning: Double.self, body: { taskGroup in
            
            for _ in 1 ... numGuess {
                taskGroup.addTask {
                    var guess: [Double] = []
                    for dimension in 0 ... upperBounds.count {
                        guess.append(Double.random(in: lowerBounds[dimension] ... upperBounds[dimension]))
                        
                    }
                    let sphericalGuess = self.cartesianToSpherical(xCoordinate: guess[0], yCoordinate: guess[1], zCoordinate: guess[2])
                    
                    
                    return self.waveFunction1s(rCoordinate: sphericalGuess[0], atomicNumber: atomicNumber)
                }
            }
            var combinedTaskResults: [Double] = []
            for await result in taskGroup{
                combinedTaskResults.append(result)
            }
            var sum: Double = 0
            for element in combinedTaskResults {
                sum += element
            }
            return sum/Double(numGuess)
        })
        return meanValue
    }
}
