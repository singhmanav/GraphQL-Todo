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
    }
	
    func createTodo(request: Request, arguments: CreateTodoArguments) throws -> EventLoopFuture<Todo> {
        let todo = Todo(title: arguments.title, isCompleted: false)
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

extension TodoResolver {
	struct UpdateCompletionArguments: Codable {
	    let id: UUID
        let isCompleted: Bool
	}
	
    func updateCompletion(request: Request, arguments: UpdateCompletionArguments) throws -> EventLoopFuture<Bool> {
        Todo.find(arguments.id, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ todo in
                    todo.isCompleted = arguments.isCompleted
                    return todo.update(on: request.db)
                })
            .transform(to: true)
    }
}