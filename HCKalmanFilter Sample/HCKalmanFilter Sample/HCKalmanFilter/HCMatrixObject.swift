//
//  HCMatrixObject.swift
//  KalmanFilter
//
//  Created by Hypercube on 4/26/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import Foundation

class HCMatrixObject
{
    //MARK: - HCMatrixObject properties
    
    /// Dimension N of Matrix
    private var n: Int
    
    /// Dimension M of Matrix
    private var m: Int
    
    /// Matrix representation
    var matrix:[[Double]]
    
    //MARK: - Initialization
    
    /// Initailization of matrix with N and M dimensions
    init(n:Int,m:Int) {
        self.n = n;
        self.m = m;
        self.matrix = Array(repeating: Array(repeating: 0, count: self.m), count: self.n)
    }
    
    //MARK: - HCMatrixObject functions
    
    /// getIdentityMatrix Function
    /// ==========================
    /// For some dimension dim, return identity matrix object
    ///
    /// - parameters:
    ///   - dim: dimension of desired identity matrix
    /// - returns: identity matrix object
    static func getIdentityMatrix(dim:Int) -> HCMatrixObject
    {
        let identityMatrix = HCMatrixObject(n: dim, m: dim)
        
        for i in 0..<dim
        {
            for j in 0..<dim
            {
                if i == j
                {
                    identityMatrix.matrix[i][j] = 1.0
                }
            }
        }
        
        return identityMatrix
    }
    
    /// addElement Function
    /// ===================
    /// Add double value on (i,j) position in matrix
    ///
    /// - parameters:
    ///   - i: row of matrix
    ///   - j: column of matrix
    ///   - value: double value to add in matrix
    public func addElement(i:Int,j:Int,value:Double)
    {
        if self.matrix.count > i && self.matrix[i].count > j
        {
            self.matrix[i][j] = value;
        }
        else
        {
            print("error")
        }
    }
    
    /// setMatrix Function
    /// ==================
    /// Set complete matrix
    ///
    /// - parameters:
    ///   - matrix: array of array of double values
    public func setMatrix(matrix:[[Double]])
    {
        if self.matrix.count > 0
        {
            if (matrix.count == self.matrix.count) && (matrix[0].count == self.matrix[0].count)
            {
                self.matrix = matrix
            }
        }
    }
    
    /// getElement Function
    /// ===================
    /// Returns double value on specific position of matrix
    ///
    /// - parameters:
    ///   - i: row of matrix
    ///   - j: column of matrix
    
    public func getElement(i:Int,j:Int) -> Double?
    {
        if self.matrix.count <= i && self.matrix[i].count <= j
        {
            return self.matrix[i][j]
        }
        else
        {
            print("error")
            return nil
        }
    }
    
    /// Transpose Matrix Function
    /// =========================
    /// Returns result HCMatrixObject of transpose operation
    ///
    /// - returns: transposed HCMatrixObject object
    public func transpose() -> HCMatrixObject?
    {
        let result = HCMatrixObject(n: self.m,m: self.n)
        
        for i in 0..<self.n
        {
            for j in 0..<self.m
            {
                result.matrix[j][i] = self.matrix[i][j];
            }
        }
        
        return result
    }
    
    /// Matrix Determinant Function
    /// ===========================
    /// Returns matrix determinant value
    ///
    /// - returns: matrix determinant value
    public func determinant() -> Double
    {
        return self.determinant(n: self.n, mat: self, det: 0.0)
    }
    
    /// Matrix Determinant Helper Function
    /// ==================================
    /// Helper function for recursively search determinant value. 
    /// Returns submatrix accumulative determinant value.
    ///
    /// - parameters:
    ///   - n: dimension of submatrix
    ///   - mat: submatrix object
    ///   - det: accumulative previous submatrix determinant value
    /// - returns: submatrix accumulative determinant value
    private func determinant(n:Int, mat:HCMatrixObject, det:Double) -> Double
    {
        let submat = HCMatrixObject(n: n, m: n)
        var d = det
        
        if(n == 2)
        {
            return((mat.matrix[0][0] * mat.matrix[1][1]) - (mat.matrix[1][0] * mat.matrix[0][1]));
        }
        else
        {
            for c in 0..<n
            {
                var subi = 0
                for i in 1..<n
                {
                    var subj = 0
                    for j in 0..<n
                    {
                        if j == c
                        {
                            continue
                        }
                        
                        submat.matrix[subi][subj] = mat.matrix[i][j]
                        subj += 1
                    }
                    subi += 1
                }
                
                d = d + (Double(pow(Double(-1), Double(c))) * mat.matrix[0][c] * determinant(n: n-1,mat:submat,det: d))
            }
        }
        return d
    }

    /// Inverse Matrix Function
    /// =======================
    /// Returns inverse matrix object
    ///
    /// - returns: inverse matrix object
    public func inverseMatrix() -> HCMatrixObject?
    {
        let a = HCMatrixObject(n: 2*n, m: 2*n)
        let result = HCMatrixObject(n: n, m: n)
        var d:Double;
        
        for i in 0..<n
        {
            for j in 0..<n
            {
                a.matrix[i][j] = matrix[i][j]
            }
        }
        
        for i in 0..<n
        {
            for j in 0..<2*n
            {
                if j == (i+n) {
                    a.matrix[i][j] = 1
                }
            }
        }
        
        for i in stride(from: n-1, to: 1, by: -1)
        {
            if a.matrix[i-1][1] < a.matrix[i][1]
            {
                for j in 0..<n*2
                {
                    d = a.matrix[i][j]
                    a.matrix[i][j] = a.matrix[i-1][j]
                    a.matrix[i-1][j] = d
                }
            }
        }
        
        for i in 0..<n
        {
            for j in 0..<2*n
            {
                if j != i
                {
                    d = a.matrix[j][i] / a.matrix[i][i]
                    for k in 0..<n*2
                    {
                        a.matrix[j][k] = a.matrix[j][k] - (a.matrix[i][k] * d);
                    }
                }
            }
        }
        
        for i in 0..<n
        {
            d = a.matrix[i][i]
            for j in 0..<2*n
            {
                a.matrix[i][j] = a.matrix[i][j] / d
            }
        }
        
        for i in 0..<n
        {
            for j in n..<2*n
            {
                result.matrix[i][j-n] = a.matrix[i][j]
            }
        }
        
        return result
    }
    
    /// Print Matrix Function
    /// =====================
    /// Printing the entire matrix
    public func printMatrix()
    {
        for i in 0..<self.n
        {
            for j in 0..<self.m
            {
               print("\(self.matrix[i][j]) ")
            }
            print("---")
        }
    }
    
    //MARK: - Predefined HCMatrixObject operators
    
    /// Predefined + operator
    /// =====================
    /// Returns result HCMatrixObject of addition operation
    ///
    /// - parameters:
    ///   - left: left addition HCMatrixObject operand
    ///   - right: right addition HCMatrixObject operand
    /// - returns: result HCMatrixObject object of addition operation
    static func +(left:HCMatrixObject, right:HCMatrixObject) ->HCMatrixObject?
    {
        let result = HCMatrixObject(n: left.n,m: left.m)
        
        if(left.n == right.n && left.m == right.m)
        {
            for i in 0..<left.n
            {
                for j in 0..<left.m
                {
                    result.matrix[i][j] = left.matrix[i][j] + right.matrix[i][j]
                }
            }
        }
        
        return result
    }
    
    /// Predefined - operator
    /// =====================
    /// Returns result HCMatrixObject of subtraction operation
    ///
    /// - parameters:
    ///   - left: left subtraction HCMatrixObject operand
    ///   - right: right subtraction HCMatrixObject operand
    /// - returns: result HCMatrixObject object of subtraction operation
    static func -(left:HCMatrixObject, right:HCMatrixObject) ->HCMatrixObject?
    {
        let result = HCMatrixObject(n: left.n,m: left.m)
        
        if(left.n == right.n && left.m == right.m)
        {
            for i in 0..<left.n
            {
                for j in 0..<left.m
                {
                    result.matrix[i][j] = left.matrix[i][j] - right.matrix[i][j]
                }
            }
        }
        
        return result
    }
    
    /// Predefined * operator
    /// =====================
    /// Returns result HCMatrixObject of multiplication operation
    ///
    /// - parameters:
    ///   - left: left multiplication HCMatrixObject operand
    ///   - right: right multiplication HCMatrixObject operand
    /// - returns: result HCMatrixObject object of multiplication operation
    static func *(left:HCMatrixObject, right:HCMatrixObject) -> HCMatrixObject?
    {
        let result = HCMatrixObject(n: left.n,m: right.m)
        
        if(left.m == right.n)
        {
            for i in 0..<left.n
            {
                for j in 0..<right.m
                {
                    for k in 0..<left.m
                    {
                        result.matrix[i][j] += left.matrix[i][k] * right.matrix[k][j];
                    }
                }
            }
        }
        return result
    }
}
