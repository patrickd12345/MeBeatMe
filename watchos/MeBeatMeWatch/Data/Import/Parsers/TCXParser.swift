import Foundation
import os

/// Parser for TCX (Training Center XML) files
class TCXParser {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "TCXParser")
    
    func parse(data: Data, fileName: String) async throws -> RunRecord {
        logger.info("Parsing TCX file: \(fileName)")
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw AppError.parseFailed("Invalid UTF-8 encoding")
        }
        
        // Parse XML to extract track points
        let trackPoints = try parseTCXTrackPoints(from: xmlString)
        
        guard !trackPoints.isEmpty else {
            throw AppError.parseFailed("No track points found in TCX file")
        }
        
        // Calculate run metrics
        let (distance, duration, splits) = try calculateRunMetrics(from: trackPoints)
        
        let averagePace = duration > 0 ? Double(duration) / (distance / 1000.0) : 0
        
        logger.info("Parsed TCX: \(String(format: "%.2f", distance/1000))km in \(duration)s")
        
        return RunRecord(
            distance: distance,
            duration: duration,
            averagePace: averagePace,
            splits: splits,
            source: "tcx",
            fileName: fileName
        )
    }
    
    private func parseTCXTrackPoints(from xmlString: String) throws -> [TCXTrackPoint] {
        var trackPoints: [TCXTrackPoint] = []
        
        // Simple XML parsing for TCX track points
        let lines = xmlString.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("<Trackpoint>") {
                if let point = parseTrackPoint(from: lines, startingAt: lines.firstIndex(of: line) ?? 0) {
                    trackPoints.append(point)
                }
            }
        }
        
        return trackPoints
    }
    
    private func parseTrackPoint(from lines: [String], startingAt index: Int) -> TCXTrackPoint? {
        var time: Date?
        var distance: Double?
        var heartRate: Int?
        
        // Look for data in the next few lines
        for i in index..<min(index + 10, lines.count) {
            let line = lines[i]
            
            if line.contains("<Time>") {
                let timeString = line
                    .replacingOccurrences(of: "<Time>", with: "")
                    .replacingOccurrences(of: "</Time>", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                let formatter = ISO8601DateFormatter()
                time = formatter.date(from: timeString)
            } else if line.contains("<DistanceMeters>") {
                let distanceString = line
                    .replacingOccurrences(of: "<DistanceMeters>", with: "")
                    .replacingOccurrences(of: "</DistanceMeters>", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                distance = Double(distanceString)
            } else if line.contains("<HeartRateBpm>") {
                // Look for value in next line
                if i + 1 < lines.count {
                    let hrLine = lines[i + 1]
                    if hrLine.contains("<Value>") {
                        let hrString = hrLine
                            .replacingOccurrences(of: "<Value>", with: "")
                            .replacingOccurrences(of: "</Value>", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        heartRate = Int(hrString)
                    }
                }
            }
        }
        
        guard let time = time else { return nil }
        
        return TCXTrackPoint(
            time: time,
            distance: distance,
            heartRate: heartRate
        )
    }
    
    private func calculateRunMetrics(from trackPoints: [TCXTrackPoint]) throws -> (distance: Double, duration: Int, splits: [Split]) {
        guard trackPoints.count >= 2 else {
            throw AppError.parseFailed("Need at least 2 track points")
        }
        
        // TCX files often have cumulative distance, so use the last point's distance
        let totalDistance = trackPoints.compactMap { $0.distance }.last ?? 0
        
        // Calculate duration
        let startTime = trackPoints.first?.time ?? Date()
        let endTime = trackPoints.last?.time ?? Date()
        let duration = Int(endTime.timeIntervalSince(startTime))
        
        // Generate splits based on distance markers
        var splits: [Split] = []
        let splitDistance: Double = 1000 // 1km
        
        var currentSplitDistance: Double = 0
        var splitStartTime = startTime
        
        for point in trackPoints {
            if let pointDistance = point.distance {
                if pointDistance - currentSplitDistance >= splitDistance {
                    let splitDuration = Int(point.time.timeIntervalSince(splitStartTime))
                    let splitPace = splitDuration > 0 ? Double(splitDuration) / (splitDistance / 1000.0) : 0
                    
                    splits.append(Split(
                        distance: splitDistance,
                        duration: splitDuration,
                        pace: splitPace
                    ))
                    
                    currentSplitDistance = pointDistance
                    splitStartTime = point.time
                }
            }
        }
        
        return (totalDistance, duration, splits)
    }
}

/// Represents a TCX track point
struct TCXTrackPoint {
    let time: Date
    let distance: Double?
    let heartRate: Int?
}
