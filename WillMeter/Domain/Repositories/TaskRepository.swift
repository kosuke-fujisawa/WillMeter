//
// TaskRepository.swift
// WillMeter
//
// ドメイン層：Taskエンティティの永続化抽象化

import Foundation

/// Taskエンティティの永続化を抽象化するRepository
/// ドメイン層の責務：データアクセスの抽象化（実装はインフラ層）
public protocol TaskRepository: Sendable {
    /// 全てのタスクを取得する
    /// - Returns: タスクの配列
    /// - Throws: 取得に失敗した場合のエラー
    func getAllTasks() async throws -> [Task]

    /// 指定されたIDのタスクを取得する
    /// - Parameter id: タスクのID
    /// - Returns: 指定されたIDのタスク（見つからない場合はnil）
    /// - Throws: 取得に失敗した場合のエラー
    func getTask(by id: UUID) async throws -> Task?

    /// タスクを保存する（新規作成または更新）
    /// - Parameter task: 保存するタスク
    /// - Throws: 保存に失敗した場合のエラー
    func save(_ task: Task) async throws

    /// タスクを削除する
    /// - Parameter id: 削除するタスクのID
    /// - Throws: 削除に失敗した場合のエラー
    func delete(by id: UUID) async throws

    /// 指定された条件でタスクを検索する
    /// - Parameters:
    ///   - status: タスクのステータス（nilの場合は全ステータス）
    ///   - category: タスクのカテゴリ（nilの場合は全カテゴリ）
    /// - Returns: 条件に合致するタスクの配列
    /// - Throws: 検索に失敗した場合のエラー
    func findTasks(status: TaskStatus?, category: TaskCategory?) async throws -> [Task]
}
