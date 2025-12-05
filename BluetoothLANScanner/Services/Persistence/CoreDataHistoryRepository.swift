//
//  CoreDataHistoryRepository.swift
//  BluetoothLANScanner
//
//  Created by Abylbek Khassenov on 05.12.2025.
//

import CoreData
import Foundation

final class CoreDataHistoryRepository {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }
}

extension CoreDataHistoryRepository: HistoryRepository {
    func saveSession(_ session: ScanSession) throws {
        let context = container.newBackgroundContext()
        var thrown: Error?

        context.performAndWait {
            let cdSession = CDScanSession(context: context)
            cdSession.id = session.id
            cdSession.type = session.type.rawValue
            cdSession.startedAt = session.startedAt
            cdSession.finishedAt = session.finishedAt

            for d in session.devices {
                let cdDevice = CDDevice(context: context)
                cdDevice.id = d.id
                cdDevice.name = d.name
                cdDevice.type = d.type.rawValue
                cdDevice.rssi = Int16(d.rssi ?? 0)
                cdDevice.mac = d.mac
                cdDevice.brand = d.brand
                cdDevice.scannedAt = d.scannedAt
                cdDevice.session = cdSession
            }

            do {
                try context.save()
            } catch {
                thrown = error
            }
        }

        if let thrown { throw thrown }
    }

    func fetchSessions(filter: ScanSessionFilter?) throws -> [ScanSession] {
        let context = container.viewContext
        let request: NSFetchRequest<CDScanSession> = CDScanSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]

        var predicates: [NSPredicate] = []

        if let f = filter {
            if let text = f.deviceNameContains, !text.isEmpty {
                predicates.append(NSPredicate(format: "ANY devices.name CONTAINS[cd] %@", text))
            }
            if let from = f.dateFrom {
                predicates.append(NSPredicate(format: "startedAt >= %@", from as NSDate))
            }
            if let to = f.dateTo {
                predicates.append(NSPredicate(format: "startedAt <= %@", to as NSDate))
            }
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        let items = try context.fetch(request)
        return items.map { $0.toDomain() }
    }

    func fetchSession(id: UUID) throws -> ScanSession? {
        let context = container.viewContext
        let request: NSFetchRequest<CDScanSession> = CDScanSession.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)

        return try context.fetch(request).first?.toDomain()
    }

    func deleteSession(id: UUID) throws {
        let context = container.viewContext
        let request: NSFetchRequest<CDScanSession> = CDScanSession.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)

        if let obj = try context.fetch(request).first {
            context.delete(obj)
            try context.save()
        }
    }
}
