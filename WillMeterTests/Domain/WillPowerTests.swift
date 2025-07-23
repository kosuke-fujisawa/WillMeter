import XCTest
@testable import WillMeter

final class WillPowerTests: XCTestCase {
    
    func testWillPowerInitialization() throws {
        // Given
        let initialValue = 100
        let maxValue = 100
        
        // When
        let willPower = WillPower(currentValue: initialValue, maxValue: maxValue)
        
        // Then
        XCTAssertEqual(willPower.currentValue, initialValue)
        XCTAssertEqual(willPower.maxValue, maxValue)
        XCTAssertEqual(willPower.percentage, 1.0, accuracy: 0.01)
    }
    
    func testWillPowerConsumption() throws {
        // Given
        let willPower = WillPower(currentValue: 100, maxValue: 100)
        let consumptionAmount = 30
        
        // When
        let result = willPower.consume(amount: consumptionAmount)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(willPower.currentValue, 70)
        XCTAssertEqual(willPower.percentage, 0.7, accuracy: 0.01)
    }
    
    func testWillPowerConsumptionExceedsAvailable() throws {
        // Given
        let willPower = WillPower(currentValue: 50, maxValue: 100)
        let consumptionAmount = 60
        
        // When
        let result = willPower.consume(amount: consumptionAmount)
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(willPower.currentValue, 50) // Should remain unchanged
    }
    
    func testWillPowerRestore() throws {
        // Given
        let willPower = WillPower(currentValue: 50, maxValue: 100)
        let restoreAmount = 30
        
        // When
        willPower.restore(amount: restoreAmount)
        
        // Then
        XCTAssertEqual(willPower.currentValue, 80)
        XCTAssertEqual(willPower.percentage, 0.8, accuracy: 0.01)
    }
    
    func testWillPowerRestoreExceedsMax() throws {
        // Given
        let willPower = WillPower(currentValue: 80, maxValue: 100)
        let restoreAmount = 30
        
        // When
        willPower.restore(amount: restoreAmount)
        
        // Then
        XCTAssertEqual(willPower.currentValue, 100) // Should cap at max
        XCTAssertEqual(willPower.percentage, 1.0, accuracy: 0.01)
    }
    
    func testWillPowerStatus() throws {
        // Given & When & Then
        let highWillPower = WillPower(currentValue: 80, maxValue: 100)
        XCTAssertEqual(highWillPower.status, .high)
        
        let mediumWillPower = WillPower(currentValue: 50, maxValue: 100)
        XCTAssertEqual(mediumWillPower.status, .medium)
        
        let lowWillPower = WillPower(currentValue: 20, maxValue: 100)
        XCTAssertEqual(lowWillPower.status, .low)
        
        let criticalWillPower = WillPower(currentValue: 5, maxValue: 100)
        XCTAssertEqual(criticalWillPower.status, .critical)
    }
    
    func testWillPowerCanPerformTask() throws {
        // Given
        let willPower = WillPower(currentValue: 50, maxValue: 100)
        
        // When & Then
        XCTAssertTrue(willPower.canPerformTask(cost: 30))
        XCTAssertTrue(willPower.canPerformTask(cost: 50))
        XCTAssertFalse(willPower.canPerformTask(cost: 60))
    }
}