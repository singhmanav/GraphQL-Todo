import Fluent
import Vapor
import Graphiti

final class TodoResolver {
    func getAllTodos(request: Request, _: NoArguments) throws -> EventLoopFuture<[Todo]> {
        Todo.query(on: request.db).all()
    }
}

extension TodoResolver {
    struct CreateTodoArguments: Codable {
        let title: String
        let isCompleted: Bool
    }
	
    func createTodo(request: Request, arguments: CreateTodoArguments) throws -> EventLoopFuture<Todo> {
        let todo = Todo(title: arguments.title, isCompleted: arguments.isCompleted)
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