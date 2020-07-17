//
//  HCMatrixObject.swift
//  KalmanFilter
//
//  Created by Hypercube on 4/26/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import Foundation
import Surge

class HCMatrixObject
{
    //MARK: - HCMatrixObject properties
    
    /// Number of Rows in Matrix
    private var rows: Int
    
    /// Number of Columns in Matrix
    private var columns: Int
    
    /// Surge Matrix object
    var matrix: Matrix<Double>
    
    //MARK: - Initialization
    
    /// Initailization of matrix with specified numbers of rows and columns
    init(rows:Int,columns:Int) {
        self.rows = rows;
        self.columns = columns;
        self.matrix = Matrix<Double>(rows: self.rows, columns: self.columns, repeatedValue: 0.0)
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
        let identityMatrix = HCMatrixObject(rows: dim, columns: dim)
        
        for i in 0..<dim
        {
            for j in 0..<dim
            {
                if i == j
                {
                    identityMatrix.matrix[i,j] = 1.0
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
        if self.matrix.rows > i && self.matrix.columns > j
        {
            self.matrix[i,j] = value;
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
        if self.matrix.rows > 0
        {
            if (matrix.count == self.matrix.rows) && (matrix[0].count == self.matrix.columns)
            {
                self.matrix = Matrix<Double>(matrix)
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
        if self.matrix.rows <= i && self.matrix.columns <= j
        {
            return self.matrix[i,j]
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
        let result = HCMatrixObject(rows: self.rows, columns: self.columns)
        
        result.matrix = Surge.transpose(self.matrix)
        
        return result
    }
    
    /// Inverse Matrix Function
    /// =======================
    /// Returns inverse matrix object
    ///
    /// - returns: inverse matrix object
    public func inverseMatrix() -> HCMatrixObject?
    {
        let result = HCMatrixObject(rows: rows, columns: columns)
        
        result.matrix = Surge.inv(self.matrix)
        
        return result
    }
    
    /// Print Matrix Function
    /// =====================
    /// Printing the entire matrix
    public func printMatrix()
    {
        for i in 0..<self.matrix.rows
        {
            for j in 0..<self.matrix.columns
            {
                print("\(self.matrix[i,j]) ")
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
        let result = HCMatrixObject(rows: left.rows, columns: left.columns)
        
        result.matrix = Surge.add(left.matrix, right.matrix)
        
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
        let result = HCMatrixObject(rows: left.rows, columns: left.columns)
        
        if(left.rows == right.rows && left.columns == right.columns)
        {
            for i in 0..<left.matrix.rows
            {
                for j in 0..<left.matrix.columns
                {
                    result.matrix[i,j] = left.matrix[i,j] - right.matrix[i,j]
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
        let resultMatrix = Surge.mul(left.matrix, right.matrix)
        
        let result = HCMatrixObject(rows: resultMatrix.rows,columns: resultMatrix.columns)
        result.matrix = resultMatrix
        
        return result
    }
}
