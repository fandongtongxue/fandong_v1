import Vapor
import MySQLProvider

extension Droplet {
    func setupRoutes() throws {
        /*
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        get("userinfo") { req in
            let name = req.data["name"]
            if name == nil {
                return try JSON(node: [
                    "data":"",
                    "msg" : "用户名为空",
                    "state":0
                    ])
            }
            
            let mysqlDriver = try self.mysql()
            
            let result = try mysqlDriver.raw("select * from users where username='" + (name?.string)! + "';")
            let userinfo = result[0]
            return try JSON(node: [
                    "data":userinfo ?? nil ?? "",
                    "state":1,
                    "msg":"请求成功"
                ])
        }
 */
        get("test"){ req in
            return "Hello Developer"
        }
        try resource("posts", PostController.self)
    }
}
