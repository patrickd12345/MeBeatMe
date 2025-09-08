import Foundation
import os

/// Parser for GPX (GPS Exchange Format) files
class GPXParser {
    private let logger = Logger(subsystem: "com.mebeatme.watch", category: "GPXParser")
    
    func parse(data: Data, fileName: String) async throws -> RunRecord {
        logger.info("Parsing GPX file: \(fileName)")
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw AppError.parseFailed("Invalid UTF-8 encoding")
        }
        
        // Parse XML to extract track points
        let trackPoints = try parseGPXTrackPoints(from: xmlString)
        
        guard !trackPoints.isEmpty else {
            throw AppError.parseFailed("No track points found in GPX file")
        }
        
        // Calculate run metrics
        let (distance, duration, splits) = try calculateRunMetrics(from: trackPoints)
        
        let averagePace = duration > 0 ? Double(duration) / (distance / 1000.0) : 0
        
        logger.info("Parsed GPX: \(String(format: "%.2f", distance/1000))km in \(duration)s")
        
        return RunRecord(
            distance: distance,
            duration: duration,
            averagePace: averagePace,
            splits: splits,
            source: "gpx",
            fileName: fileName
        )
    }
    
    private func parseGPXTrackPoints(from xmlString: String) throws -> [TrackPoint] {
        var trackPoints: [TrackPoint] = []
        
        // Simple XML parsing for GPX track points
        // In production, you'd want to use a proper XML parser
        let lines = xmlString.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("<trkpt") {
                if let point = parseTrackPoint(from: line) {
                    trackPoints.append(point)
                }
            }
        }
        
        return trackPoints
    }
    
    private func parseTrackPoint(from line: String) -> TrackPoint? {
        // Extract lat/lon from <trkpt lat="..." lon="...">
        let latPattern = #"lat="([^"]+)""#
        let lonPattern = #"lon="([^"]+)""#
        
        guard let latMatch = line.range(of: latPattern, options: .regularExpression),
              let lonMatch = line.range(of: lonPattern, options: .regularExpression) else {
            return nil
        }
        
        let latString = String(line[latMatch]).replacingOccurrences(of: "lat=\"", with: "").replacingOccurrences(of: "\"", with: "")
        let lonString = String(line[lonMatch]).replacingOccurrences(of: "lon=\"", with: "").replacingOccurrences(of: "\"", with: "")
        
        guard let lat = Double(latString),
              let lon = Double(lonString) else {
            return nil
        }
        
        // Extract time from <time>...</time> if present
        let timePattern = #"<time>([^<]+)</time>"#
        var time: Date?
        
        if let timeMatch = line.range(of: timePattern, options: .regularExpression) {
            let timeString = String(line[timeMatch])
                .replacingOccurrences(of: "<time>", with: "")
                .replacingOccurrences(of: "</time>", with: "")
            
            let formatter = ISO8601DateFormatter()
            time = formatter.date(from: timeString)
        }
        
        return TrackPoint(latitude: lat, longitude: lon, time: time)
    }
    
    private func calculateRunMetrics(from trackPoints: [TrackPoint]) throws -> (distance: Double, duration: Int, splits: [Split]) {
        guard trackPoints.count >= 2 else {
            throw AppError.parseFailed("Need at least 2 track points")
        }
        
        var totalDistance: Double = 0
        var splits: [Split] = []
        
        // Calculate distance between consecutive points
        for i in 1..<trackPoints.count {
            let prev = trackPoints[i-1]
            let curr = trackPoints[i]
            
            let segmentDistance = calculateDistance(
                from: (prev.latitude, prev.longitude),
                to: (curr.latitude, curr.longitude)
            )
            
            totalDistance += segmentDistance
        }
        
        // Calculate duration
        let startTime = trackPoints.first?.time ?? Date()
        let endTime = trackPoints.last?.time ?? Date()
        let duration = Int(endTime.timeIntervalSince(startTime))
        
        // Generate splits (every 1km)
        let splitDistance: Double = 1000 // 1km
        var currentSplitDistance: Double = 0
        var splitStartIndex = 0
        
        for i in 1..<trackPoints.count {
            let prev = trackPoints[i-1]
            let curr = trackPoints[i]
            
            let segmentDistance = calculateDistance(
                from: (prev.latitude, prev.longitude),
                to: (curr.latitude, curr.longitude)
            )
            
            currentSplitDistance += segmentDistance
            
            if currentSplitDistance >= splitDistance {
                // Create split
                let splitDuration = Int(trackPoints[i].time?.timeIntervalSince(trackPoints[splitStartIndex].time ?? startTime) ?? 0)
                let splitPace = splitDuration > 0 ? Double(splitDuration) / (currentSplitDistance / 1000.0) : 0
                
                splits.append(Split(
                    distance: currentSplitDistance,
                    duration: splitDuration,
                    pace: splitPace
                ))
                
                currentSplitDistance = 0
                splitStartIndex = i
            }
        }
        
        return (totalDistance, duration, splits)
    }
    
    private func calculateDistance(from: (Double, Double), to: (Double, Double)) -> Double {
        // Haversine formula for calculating distance between two points
        let earthRadius: Double = 6371000 // meters
        
        let lat1Rad = from.0 * .pi / 180
        let lat2Rad = to.0 * .pi / 180
        let deltaLatRad = (to.0 - from.0) * .pi / 180
        let deltaLonRad = (to.1 - from.1) * .pi / 180
        
        let a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLonRad / 2) * sin(deltaLonRad / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
}

/// Represents a GPS track point
struct TrackPoint {
    let latitude: Double
    let longitude: Double
    let time: Date?
}
