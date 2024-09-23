import NIOSSL
import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor

import GraphQL
import GraphQLKit
import GraphiQLVapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.memory), as: .sqlite)

    app.migrations.add(CreateTodo())
    try app.autoMigrate().wait()
    app.views.use(.leaf)

    // Register the schema and its resolver.
    app.register(graphQLSchema: todoSchema, withResolver: TodoResolver())

// Enable GraphiQL web page to send queries to the GraphQL endpoint
    if !app.environment.isRelease {
        app.enableGraphiQL()
    }


    // register routes
}
