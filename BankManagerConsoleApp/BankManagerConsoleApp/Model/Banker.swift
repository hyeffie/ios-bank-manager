//
//  Banker.swift
//  BankManagerConsoleApp
//
//  Created by Effie on 1/26/24.
//

import Foundation

final class Banker {
    private let name: String
    
    private let clientManager: ClientDequeuable
    
    private let taskOutput: TextOutputDisplayable
    
    private(set) var dailyClientStatistics: Int
    
    init(
        name: String,
        clientManager: ClientDequeuable,
        taskOutput: TextOutputDisplayable
    ) {
        self.name = name
        self.clientManager = clientManager
        self.taskOutput = taskOutput
        self.dailyClientStatistics = 0
    }
    
    func start(group: DispatchGroup) {
        DispatchQueue.global().async(group: group) { [weak self] in
            guard let self else { return }
            while let client = clientManager.dequeueClient() {
                work(for: client, time: 0.7)
            }
        }
    }
}

private extension Banker {
    func work(for client: Client, time: Double) {
        self.startTask(for: client)
        self.dailyClientStatistics += 1
        Thread.sleep(forTimeInterval: time)
        self.endTask(for: client)
    }
    
    func startTask(for client: Client) {
        self.taskOutput.display(output: "\(self.name): \(client.number)번 고객 \(client.taskType) 시작")
    }
    
    func endTask(for client: Client) {
        self.taskOutput.display(output: "\(self.name): \(client.number)번 고객 \(client.taskType) 완료")
    }
}
