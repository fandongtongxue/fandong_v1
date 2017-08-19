import Vapor
import MySQLProvider

extension Droplet {
    func setupRoutes() throws {
        get("test"){ req in
            return "Hello Developer"
        }
        try resource("posts", PostController.self)
    }
}
