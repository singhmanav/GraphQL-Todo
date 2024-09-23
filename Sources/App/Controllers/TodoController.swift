import Fluent
import Vapor
import Graphiti

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")

        todos.get(use: self.index)
        todos.post(use: self.create)
        todos.group(":todoID") { todo in
            todo.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> TodoDTO {
        let todo = try req.content.decode(TodoDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
}

final class TodoResolver {
    func getAllTodos(request: Request, _: NoArguments) throws -> EventLoopFuture<[Todo]> {
        Todo.query(on: request.db).all()
    }
}

extension TodoResolver {
    struct CreateTodoArguments: Codable {
        let title: String
    }
	
    func createTodo(request: Request, arguments: CreateTodoArguments) throws -> EventLoopFuture<Todo> {
        let todo = Todo(title: arguments.title)
        return todo.create(on: request.db).map { todo }
    }
}

extension TodoResolver {
	struct DeleteTodoArguments: Codable {
	    let id: UUID
	}
	
    func deleteTodo(request: Request, arguments: DeleteTodoArguments) throws -> EventLoopFuture<Bool> {
        Todo.find(arguments.id, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ $0.delete(on: request.db) })
            .transform(to: true)
    }
}